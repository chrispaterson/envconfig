---
name: adobe-wiki
description: Confluence/Adobe Wiki integration - get, create, update, move pages, manage comments, and search. Use for any Confluence wiki tasks.
disable-model-invocation: false
argument-hint: <command> [options]
allowed-tools:
  - Bash
---

# Adobe Wiki Skill

Full Confluence integration for Claude Code.

## Usage

```bash
uv run ./scripts/wiki_cli.py <command> [options]
```

Run commands from the `adobe-wiki` directory (or pass an absolute path to `wiki_cli.py`).

## Commands

| Command                                                              | Description                |
| -------------------------------------------------------------------- | -------------------------- |
| `get <URL\|PAGE_ID>`                                                 | Get page content           |
| `create -s "Title" --space KEY [--parent URL\|ID] [--content "..."]` | Create page                |
| `update <URL\|PAGE_ID> --content "..." [--title "..."]`              | Update page content        |
| `move <URL\|PAGE_ID> --parent <URL\|ID>`                             | Move page under new parent |
| `children <URL\|PAGE_ID>`                                            | List child pages           |
| `history <URL\|PAGE_ID> [--limit N]`                                 | Page revision history      |
| `comments <URL\|PAGE_ID>`                                            | View page comments         |
| `comment <URL\|PAGE_ID> "<text>"`                                    | Add comment to page        |
| `search "<CQL>" [--limit N]`                                         | Search with CQL            |

## Examples

```bash
# Get page content
uv run ./scripts/wiki_cli.py get https://wiki.corp.adobe.com/pages/123456789

# Create page
uv run ./scripts/wiki_cli.py create -s "Deployment Runbook" --space DI --content "# Deployment Steps"

# Create as child of another page
uv run ./scripts/wiki_cli.py create -s "Q1 Release Notes" --space DI --parent 123456789

# Update page content (Markdown)
uv run ./scripts/wiki_cli.py update 123456789 --content "# Updated Runbook\nSee PR #456 for changes."

# Update page title only
uv run ./scripts/wiki_cli.py update 123456789 --title "Deployment Runbook v2"

# Move page
uv run ./scripts/wiki_cli.py move 123456789 --parent 987654321

# List child pages
uv run ./scripts/wiki_cli.py children 123456789

# Page history
uv run ./scripts/wiki_cli.py history 123456789 --limit 5

# View comments
uv run ./scripts/wiki_cli.py comments 123456789

# Add comment
uv run ./scripts/wiki_cli.py comment 123456789 "Updated after review in OZ-123"

# Search with CQL
uv run ./scripts/wiki_cli.py search "space=DI AND title~'deploy'" --limit 10
```

## Configuration

Environment variables:

- `ADOBE_WIKI_URL` - Confluence base URL (e.g. `https://wiki.corp.adobe.com`)
- `ADOBE_WIKI_PAT` - Personal access token
