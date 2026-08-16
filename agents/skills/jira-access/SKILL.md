---
name: jira-access
description: >-
  Canonical Jira access for GRAPH (read/write, JQL, sprint, transitions, comments,
  REST fallbacks). Today this is implemented with the jira CLI
  (ankitpokhrel/jira-cli); other skills reference this file instead of duplicating
  commands. Prefer this over Corp Jira MCP (ada-mcp-gateway) for reliability.
---

# Jira access (GRAPH) — canonical reference

## Policy

- **Default:** use the `jira` CLI for all Jira operations in GRAPH workflows.
- **Do not** depend on `mcp__ada-mcp-gateway__*` for create, read, update, search, comment, or sprint unless the user explicitly overrides (e.g. CLI broken in this session).
- **Single place to change:** if the team switches tools (different CLI, REST-only, or MCP again), update **this skill only**, then grep other skills for any stray literals.

## Prerequisites

- `jira` on `PATH`, configured for `https://jira.corp.adobe.com` (typically `~/.config/.jira/.config.yml`).
- **Always `source ~/.env` before any `jira` command.** Jira bearer credentials live in `~/.env`.
- Default project: pass `-p GRAPH` when the configured default might not be GRAPH.
- If `JIRA_API_TOKEN` (or equivalent) is required in a given environment and unset, skip mutating Jira steps and warn (see consumer skills like `do`).

## Command cheat sheet

| Goal | Command |
|------|---------|
| Current Jira user | `jira me` |
| OS username (reporter/assignee hints) | `whoami` |
| View issue (plain) | `jira issue view GRAPH-123 --plain` |
| View issue + comments | `jira issue view GRAPH-123 --plain --comments 100` |
| View issue (JSON for parsing) | `jira issue view GRAPH-123 --raw` |
| Search / list | `jira issue list -q '<JQL>' --plain --columns key,summary,status` (add columns as needed) |
| Order / pagination | Prefer `--order-by` / `--reverse` and `--paginate 0:N`. **Do not** put `ORDER BY` inside `-q` — it often triggers JQL parse errors in this CLI. |
| Components hint | `jira issue list -q 'project = GRAPH AND component is not EMPTY' --plain --columns key,summary,components --paginate 0:30` |
| Create issue | `jira issue create ... --no-input` (add `--raw` when the agent must parse the new key from stdout/JSON) |
| Assign | `jira issue assign GRAPH-123 $(whoami)` |
| Transition | `jira issue move GRAPH-123 "In Development"` (status name must match Jira) |
| Active sprint | `jira sprint list --table --plain --state active` |
| Add to sprint | `jira sprint add <SPRINT_ID> <ISSUE-KEY>` |
| Link two issues | `jira issue link <INWARD> <OUTWARD> <LinkType>` (e.g. `Blocks`, `Relates`; names must match Jira) |
| Link remote URL (e.g. GitHub PR) | `jira issue link remote GRAPH-123 "<URL>" "GitHub Pull Request"` |
| Comment | `jira issue comment add GRAPH-123 "body text" --no-input` (positional arg, no `-b` flag; `--no-input` is **required** in automation — without it the CLI waits on an interactive prompt and silently adds nothing) |

## `jira issue create` (GRAPH)

Always use `--no-input` for automation.

- `-p GRAPH`, `-t Story|Bug|Epic`, `-s "..."`, `-b "..."` or `-T /path/to/body.txt`
- `-r <user>` / `-a <user>` — reporter / assignee (often `$(whoami)`). Omit `-a` when the issue should stay unassigned per team rules.
- `-C <Name>` — component (repeat for multiple). Names must match Jira exactly.
- **Epic Link** (Story/Bug): `-P <EPIC-KEY>` and/or `--custom "Epic Link=<EPIC-KEY>"` (GRAPH maps Epic Link in `~/.config/.jira/.config.yml`). If one form fails, try the other.
- **Epic** create: `--custom "Epic Name=<name>"` (often same as summary).

Parse the new key from `--raw` output or from the printed URL.

## `jira issue edit`

Use for field updates when supported by the installed CLI version:

```bash
jira issue edit GRAPH-123 --no-input ...
```

Run `jira issue edit --help` locally for supported flags (`--summary`, `--description` / body flags, etc.). If the CLI cannot set a field, use the REST fallback below.


## Fetching structured fields from `--raw`

`jira issue view GRAPH-XXX --raw` returns JSON. Have the agent parse `fields.summary`, `fields.description`, `fields.status.name`, `fields.assignee`, `fields.components`, `fields.customfield_10003` (story points), `fields.issuetype`, `fields.parent`, etc., as needed for the calling skill.

## JQL examples

- Single issue: `key = GRAPH-123`
- Epics for current user: `project = GRAPH AND issuetype = Epic AND assignee = currentUser() AND status != Done`
- List with ordering: use CLI `--order-by updated --reverse` instead of inline `ORDER BY`.

## Body / comment formatting — write Jira wiki markup directly

**The installed `jira` CLI stores the body verbatim — it does NOT convert Markdown.** Whatever string is passed to `-b` / `-T` / a comment arg is persisted byte-for-byte (verified via `jira issue view <KEY> --raw`: submitted `h2.`, `*bold*`, and backticks all came back unchanged). The Jira web UI then interprets that stored text as **Jira wiki markup**. So Markdown syntax renders literally — `## Heading` shows the `##`, `**bold**` shows the `**`, and `` `code` `` shows the backticks. Always author bodies and comments in Jira wiki markup:

| Want | Jira wiki markup (write this) | Markdown that does NOT work |
|---|---|---|
| Heading | `h2. Heading` (`h1.`–`h6.`) | `## Heading` |
| Bold | `*bold*` | `**bold**` |
| Italic | `_italic_` | `*italic*` |
| Inline code / monospace | `{{inline}}` | `` `inline` `` |
| Bullet list | `* item` (nest with `**`) | `- item` |
| Numbered list | `# item` | `1. item` |
| Quote | `{quote}...{quote}` | `> quote` |
| Code block | `{code:java}...{code}` or `{code}...{code}` | ` ```lang ... ``` ` |
| Link | `[text|https://url]` | `[text](https://url)` |
| Horizontal rule | `----` | `---` |

Note `*` is **bold** in Jira wiki, not a bullet — a bullet is `*` only at the **start of a line**. Inline `*emphasis*` is bold; use `_..._` for italic.

**Do not trust `jira issue view --raw` formatting against `--plain`.** The `--plain` view re-renders stored content for the terminal (e.g. it prints a stored `h2.` heading back as `##`), so it is *not* a faithful preview and cannot be used to judge how the web UI will render. To verify what is actually stored, read `fields.description` (or `comment.comments[].body`) from `--raw`.

## REST fallback — fields the CLI cannot set

When the CLI cannot set a field (e.g. story points, Epic Link), use `$JIRA_API_TOKEN` directly — it is set by `source ~/.env` and is the same credential the CLI uses internally. Do **not** try to extract the token from `--debug` output (that approach is blocked by the auto-mode classifier).

```bash
source ~/.env

# Update any field
curl -s -o /dev/null -w "%{http_code}" -X PUT \
  "${JIRA_URL}/rest/api/2/issue/GRAPH-123" \
  -H "Authorization: Bearer ${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"fields":{"customfield_10003":5.1}}'

# Delete a comment
curl -s -o /dev/null -w "%{http_code}" -X DELETE \
  "${JIRA_URL}/rest/api/2/issue/GRAPH-123/comment/<COMMENT_ID>" \
  -H "Authorization: Bearer ${JIRA_API_TOKEN}"
```

`204` means success for both. Comment IDs come from `jira issue view GRAPH-123 --raw` → `fields.comment.comments[].id`.

## Setting the Epic Link

The CLI flags (`-P`, `--custom "Epic Link=..."`) are silently ignored for Epic Link updates because `customfield_11800` is not registered in `~/.config/.jira/.config.yml`. Use the REST fallback instead:

```bash
source ~/.env
curl -s -o /dev/null -w "%{http_code}" -X PUT \
  "${JIRA_URL}/rest/api/2/issue/GRAPH-123" \
  -H "Authorization: Bearer ${JIRA_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"fields":{"customfield_11800":"GRAPH-2601"}}'
```

Verify with: `jira issue view GRAPH-123 --raw | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['fields'].get('customfield_11800'))"`
