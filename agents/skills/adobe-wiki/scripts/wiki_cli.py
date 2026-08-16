#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["atlassian-python-api", "markdown"]
# ///
"""
Confluence/Adobe Wiki CLI for Claude Code.

Commands: get, create, update, move, children, history, comments, comment, search

Environment Variables:
    ADOBE_WIKI_URL - Confluence base URL
    ADOBE_WIKI_PAT - Personal access token (Server/Data Center)
"""

import argparse
import os
import re
import sys
from urllib.parse import unquote_plus

try:
    from atlassian import Confluence
except ImportError:
    print("Error: atlassian-python-api not installed. Run: pip install atlassian-python-api", file=sys.stderr)
    sys.exit(1)

try:
    import markdown as md_lib
except ImportError:
    md_lib = None

def get_client():
    url = os.environ.get("ADOBE_WIKI_URL", "").rstrip("/")
    pat = os.environ.get("ADOBE_WIKI_PAT")

    if not url:
        print("Error: ADOBE_WIKI_URL not set", file=sys.stderr)
        sys.exit(1)

    if not pat:
        print("Error: ADOBE_WIKI_PAT not set", file=sys.stderr)
        sys.exit(1)

    try:
        return Confluence(url=url, token=pat)
    except Exception as e:
        print(f"Error connecting to Confluence: {e}", file=sys.stderr)
        sys.exit(1)


def extract_page_id(url_or_id: str, client: Confluence) -> str:
    """Return numeric page ID from a URL or pass through a bare ID."""
    if url_or_id.isdigit():
        return url_or_id

    # pageId= query param
    m = re.search(r'pageId=(\d+)', url_or_id)
    if m:
        return m.group(1)

    # /pages/viewpage.action?pageId=
    m = re.search(r'/pages/(\d+)', url_or_id)
    if m:
        return m.group(1)

    # /display/SPACE/Title style
    m = re.match(r'.*/display/([^/]+)/(.+)', url_or_id)
    if m:
        space, title = m.group(1), unquote_plus(m.group(2))
        page = client.get_page_by_title(space=space, title=title)
        if not page:
            print(f"Error: Page not found: space={space} title={title}", file=sys.stderr)
            sys.exit(1)
        return page["id"]

    print(f"Error: Cannot parse page ID from: {url_or_id}", file=sys.stderr)
    sys.exit(1)


def markdown_to_storage(text: str) -> str:
    """Convert Markdown to Confluence storage format (basic HTML)."""
    if md_lib:
        return md_lib.markdown(text, extensions=["extra", "tables"])
    # Minimal fallback: wrap in paragraph tags
    return f"<p>{text}</p>"


def format_page(page: dict, verbose: bool = False) -> str:
    title = page.get("title", "Untitled")
    page_id = page.get("id", "")
    space = page.get("space", {}).get("key", "") if isinstance(page.get("space"), dict) else ""
    lines = [f"[{page_id}] {title}"]
    if space:
        lines[0] = f"[{page_id}] {title}  (space: {space})"

    if verbose:
        version = page.get("version", {}).get("number", "?")
        lines.append(f"  Version: {version}")
        links = page.get("_links", {})
        if links.get("webui"):
            base = page.get("_links", {}).get("base", "")
            lines.append(f"  URL: {base}{links['webui']}")
        body = page.get("body", {}).get("storage", {}).get("value", "")
        if body:
            # Strip tags for preview
            clean = re.sub(r'<[^>]+>', '', body)
            clean = clean.strip()
            if clean:
                lines.append(f"  Content preview:\n    {clean}")

    return "\n".join(lines)


# ============ Commands ============

def cmd_get(client: Confluence, args):
    page_id = extract_page_id(args.url_or_id, client)
    try:
        page = client.get_page_by_id(page_id, expand="body.storage,version,space")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    print(format_page(page, verbose=True))

    body = page.get("body", {}).get("storage", {}).get("value", "")
    if body:
        print("\n--- Content (storage format) ---")
        print(body)


def cmd_create(client: Confluence, args):
    space = args.space
    if not space:
        print("Error: --space is required", file=sys.stderr)
        sys.exit(1)

    body = ""
    if args.content:
        body = markdown_to_storage(args.content)

    parent_id = None
    if args.parent:
        parent_id = extract_page_id(args.parent, client)

    try:
        if parent_id:
            page = client.create_page(
                space=space,
                title=args.summary,
                body=body,
                parent_id=parent_id,
                type="page",
                representation="storage",
            )
        else:
            page = client.create_page(
                space=space,
                title=args.summary,
                body=body,
                type="page",
                representation="storage",
            )

        page_id = page.get("id", "")
        links = page.get("_links", {})
        base = links.get("base", "")
        webui = links.get("webui", "")
        print(f"\nCreated: {page_id}")
        print(f"Title: {args.summary}")
        print(f"Space: {space}")
        if base and webui:
            print(f"URL: {base}{webui}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_update(client: Confluence, args):
    page_id = extract_page_id(args.url_or_id, client)

    try:
        page = client.get_page_by_id(page_id, expand="body.storage,version,space")
    except Exception as e:
        print(f"Error fetching page: {e}", file=sys.stderr)
        sys.exit(1)

    title = args.title or page["title"]
    space_key = page.get("space", {}).get("key", "")

    if args.content:
        body = markdown_to_storage(args.content)
    else:
        body = page.get("body", {}).get("storage", {}).get("value", "")

    try:
        client.update_page(
            page_id=page_id,
            title=title,
            body=body,
            type="page",
            representation="storage",
        )
        print(f"Updated: {page_id}")
        print(f"Title: {title}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_move(client: Confluence, args):
    page_id = extract_page_id(args.url_or_id, client)
    parent_id = extract_page_id(args.parent, client)

    try:
        # atlassian-python-api move: update parent via REST
        client.move_page(
            space_key=None,
            page_id=page_id,
            target_id=parent_id,
            position="append",
        )
        print(f"Moved page {page_id} under parent {parent_id}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_children(client: Confluence, args):
    page_id = extract_page_id(args.url_or_id, client)

    try:
        children = client.get_child_pages(page_id)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if not children:
        print("No child pages found.")
        return

    print(f"Child pages ({len(children)}):\n")
    for child in children:
        print(format_page(child))


def cmd_history(client: Confluence, args):
    page_id = extract_page_id(args.url_or_id, client)

    try:
        versions = client.history(page_id)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if isinstance(versions, dict):
        results = versions.get("results", [versions])
    else:
        results = versions if isinstance(versions, list) else []

    results = results[: args.limit]
    print(f"History for page {page_id} (last {len(results)} versions):\n")
    for v in results:
        num = v.get("number", v.get("version", {}).get("number", "?"))
        by = v.get("by", {}).get("displayName", "Unknown") if isinstance(v.get("by"), dict) else "Unknown"
        when = v.get("when", "")
        msg = v.get("message", "")
        line = f"  v{num}  {when[:19]}  by {by}"
        if msg:
            line += f"  — {msg}"
        print(line)


def cmd_comments(client: Confluence, args):
    page_id = extract_page_id(args.url_or_id, client)

    try:
        comments = client.get_page_comments(page_id, expand="body.view", depth="all")
        results = comments.get("results", [])
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if not results:
        print("No comments found.")
        return

    print(f"Comments ({len(results)}):\n")
    for c in results:
        author = c.get("version", {}).get("by", {}).get("displayName", "Unknown")
        when = c.get("version", {}).get("when", "")[:19]
        body = re.sub(r'<[^>]+>', '', c.get("body", {}).get("view", {}).get("value", "")).strip()
        print(f"  [{when}] {author}:")
        print(f"    {body}\n")


def cmd_comment(client: Confluence, args):
    page_id = extract_page_id(args.url_or_id, client)

    try:
        client.add_comment(page_id, args.text)
        print(f"Comment added to page {page_id}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_search(client: Confluence, args):
    try:
        results = client.cql(args.cql, limit=args.limit)
        items = results.get("results", [])
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if not items:
        print("No results found.")
        return

    print(f"Found {len(items)} result(s):\n")
    for item in items:
        content = item.get("content", item)
        page_id = content.get("id", "")
        title = content.get("title", item.get("title", "Untitled"))
        space = content.get("space", {}).get("key", "") if isinstance(content.get("space"), dict) else ""
        links = content.get("_links", {})
        base = links.get("base", "")
        webui = links.get("webui", "")
        line = f"[{page_id}] {title}"
        if space:
            line += f"  (space: {space})"
        print(line)
        if base and webui:
            print(f"  URL: {base}{webui}")
        print()


# ============ Main ============

def main():
    parser = argparse.ArgumentParser(description="Confluence/Adobe Wiki CLI for Claude Code")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # get
    p = subparsers.add_parser("get", help="Get page content")
    p.add_argument("url_or_id", help="Page URL or numeric ID")

    # create
    p = subparsers.add_parser("create", help="Create a new page")
    p.add_argument("--summary", "-s", required=True, help="Page title")
    p.add_argument("--space", required=True, help="Space key")
    p.add_argument("--parent", help="Parent page URL or ID")
    p.add_argument("--content", "-c", help="Page body (Markdown)")

    # update
    p = subparsers.add_parser("update", help="Update page content or title")
    p.add_argument("url_or_id", help="Page URL or numeric ID")
    p.add_argument("--content", "-c", help="New body (Markdown)")
    p.add_argument("--title", "-t", help="New title")

    # move
    p = subparsers.add_parser("move", help="Move page under a new parent")
    p.add_argument("url_or_id", help="Page URL or numeric ID")
    p.add_argument("--parent", required=True, help="New parent page URL or ID")

    # children
    p = subparsers.add_parser("children", help="List child pages")
    p.add_argument("url_or_id", help="Page URL or numeric ID")

    # history
    p = subparsers.add_parser("history", help="Show page revision history")
    p.add_argument("url_or_id", help="Page URL or numeric ID")
    p.add_argument("--limit", type=int, default=10, help="Max versions to show (default: 10)")

    # comments
    p = subparsers.add_parser("comments", help="View page comments")
    p.add_argument("url_or_id", help="Page URL or numeric ID")

    # comment
    p = subparsers.add_parser("comment", help="Add a comment to a page")
    p.add_argument("url_or_id", help="Page URL or numeric ID")
    p.add_argument("text", help="Comment text")

    # search
    p = subparsers.add_parser("search", help="Search with CQL")
    p.add_argument("cql", help="CQL query string")
    p.add_argument("--limit", type=int, default=10, help="Max results (default: 10)")

    args = parser.parse_args()
    client = get_client()

    commands = {
        "get": cmd_get,
        "create": cmd_create,
        "update": cmd_update,
        "move": cmd_move,
        "children": cmd_children,
        "history": cmd_history,
        "comments": cmd_comments,
        "comment": cmd_comment,
        "search": cmd_search,
    }

    commands[args.command](client, args)


if __name__ == "__main__":
    main()
