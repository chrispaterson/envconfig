---
name: feedback_skip_formatting_in_handoffs
description: "Don't spend context on code-formatting rules in handoffs/plans; eslint --fix + rush format auto-fix them"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 63fb13a2-775a-4fb4-b169-7826db4e1d0f
  modified: 2026-09-02T00:29:29.423Z
---

When writing handoff prompts, plans, or reviews, do not spend context enumerating code-formatting / style rules — comment style (`//` → `/** */`), copyright headers, curly braces, print width, etc. In this repo `eslint --fix` and `rush format` auto-fix all of them.

**Why:** The user considers this wasted context; the fixers handle it mechanically, so listing the rules adds nothing an agent needs.

**How to apply:** In handoffs/plans, keep only the non-mechanical design rules the fixers can't decide (e.g. no `as` assertions → use type predicates; guard clauses/early returns; split OR'd guards). For the rest, a one-liner "run `eslint --fix` and `rush format`" suffices. Still run them as part of [[feedback_pre_completion_workflow]]. Note the comment-style rule origin is [[feedback_comment_style]], but it is auto-fixable so don't belabor it.
