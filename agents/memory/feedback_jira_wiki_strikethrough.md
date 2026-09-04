---
name: feedback_jira_wiki_strikethrough
description: Jira wiki -phrase- = strikethrough; CLI flags like --changelog get struck through; escape boundary hyphens as \-
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5cf26d35-aaaf-4fe8-80ed-b9fe25712158
  modified: 2026-09-04T23:21:34.187Z
---

In Jira wiki markup, `-phrase-` renders as **strikethrough**. A CLI flag written in prose or monospace (`--changelog`, `-v/--verbose`) has hyphens at token boundaries, so one flag's hyphen pairs with another's and Jira strikes the text between them. This happens **even inside `{{monospace}}`** — the pairing crosses `{{...}}` span boundaries (e.g. `{{--bail}}, {{--concurrency <n>}}` renders half struck-through). `class="error"` checks do NOT catch it; grep the rendered HTML for `<del>` / `line-through`.

**Why:** boundary hyphens (non-word char before/after) are eligible strikethrough delimiters; word-internal hyphens (`graph-cli`, `GRAPH-1234`) are not.

**How to apply:** Escape every boundary hyphen as `\-` — it renders as a literal `-` in both prose and monospace with no visible backslash. Leave word-internal hyphens unescaped (escaping them can break issue-key auto-linking). Working transform: replace any `-` that is NOT between two `[A-Za-z0-9]` with `\-`, i.e. `re.sub(r'(?<![A-Za-z0-9])-|-(?![A-Za-z0-9])', r'\\-', text)`. Relates to [[feedback_jira_wiki_markup]], [[feedback_jira_cli_create_escapes_markup]]. Codified in the createjira skill's Wiki markup gotchas.
