---
name: feedback_jira_wiki_markup
description: jira CLI requires Jira wiki markup directly — it does NOT convert Markdown
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9d0e79e5-34ed-4d4f-b620-8939ea076b35
---

Use **Jira wiki markup** with the **`-b/--body` flag** (and `comment add`, and `edit -b`). The `-b` flag is a **literal passthrough** — it stores exactly what you give it, so give it wiki markup. This is the reliable path; default to it.

**Critical `-b` vs `-T` distinction (verified GRAPH-2501, 2026-06):**
- `-b "..."` (and `edit -b`, `comment add`) — **literal**, no conversion. Give it **wiki markup**. Markdown passed here is stored raw and renders as literal `##`/backticks.
- `-T <file>` (template, create only) — runs a **Markdown→wiki conversion** that *escapes* wiki-significant chars. Passing wiki markup to `-T` mangles it (stray backslashes on `-`, `*`, `(`). If you ever use `-T`, feed it Markdown, not wiki markup. Simplest rule: **always use `-b` with wiki markup; avoid `-T`.**

**Why:** mixing the wrong format with the wrong flag produces broken Jira output (literal `##`/backticks, or backslash-escaped `\-`/`\*`).

**How to apply (wiki syntax for `-b`):**
- Headings: `h2. Heading`
- Bold: `*bold*`
- Inline code: `{{symbol}}`
- Code blocks: `{code:typescript}...{code}`
- Bullet lists: `* item` (nested: `** item`)
- Numbered lists: `# item`

The jira-access skill's formatting section claims Markdown is auto-converted; that only holds for `-T`/interactive, not `-b`. Prefer `-b` + wiki markup.
