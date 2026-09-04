---
name: feedback_jira_cli_create_escapes_markup
description: jira CLI create -b/-T runs markdown→wiki conversion that mangles raw wiki markup; set descriptions via REST PUT
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5cf26d35-aaaf-4fe8-80ed-b9fe25712158
  modified: 2026-09-04T23:02:32.986Z
---

`jira issue create` / `jira epic create` with `-b/--body` or `-T/--template` run the body through jira-cli's markdown→wiki conversion, which **escapes** raw Jira wiki markup: `--flag`→`\-\-flag`, `+`→`\+`, and it breaks `{{monospace <token>}}` spans (the `<token>` is eaten as an HTML tag). This silently corrupts a hand-authored wiki-markup body.

**Why:** the CLI assumes `-b/-T` input is Markdown and converts it; it does not treat the input as already-wiki.

**How to apply:** To store *raw wiki markup* unchanged, set the description via REST PUT `/rest/api/2/issue/KEY` with `{"fields":{"description":"<wiki>"}}` (or `jira issue edit --body`, which does NOT convert). Workflow that works: create the issue with a placeholder body, then PUT the real wiki description. Verify by fetching `expand=renderedFields` and checking the HTML for `class="error"` and stray `{{`. Relates to [[feedback_jira_wiki_markup]].
