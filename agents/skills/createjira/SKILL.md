---
name: createjira
description: Create a Jira issue (Story, Bug, or Epic) in the GRAPH project using the jira-access conventions. Use when the user invokes /createjira or asks to create a Jira ticket.
user-invocable: true
---

# Create Jira Issue

## Purpose

Create a Jira issue using the **jira-access** patterns (today: `jira` CLI). Use when the user wants a Story, Bug, or Epic. Derive summary and body from conversation context when possible, or ask. Apply the template below, then create and optionally sprint/link via CLI.

Story pointing is not part of this workflow. If the user wants an estimate for a new or existing Story, they can invoke `/storypoint` separately.

**Do not rely on Corp Jira MCP** for this workflow: treat MCP as unavailable or unreliable for create/search/link unless the user explicitly asks for it and the CLI cannot be used.

## Jira commands (single source)

All Jira access patterns (CLI syntax, auth, JQL, sprint/link/comment, REST fallbacks): **read and follow** `~/agents/skills/jira-access/SKILL.md`. Do not duplicate command tables here.

## Invocation

- `/createjira Story` — Story (**Epic Link required** for GRAPH practice).
- `/createjira Bug` — Bug (Epic optional).
- `/createjira Epic` — Epic (no Epic Link; Epic-specific fields).

If the user names an Epic (e.g. "in GRAPH-1263 Epic"), use that key and skip Epic discovery for that ticket.

## Body templates

### Story

```
h1. User Story
As a [user],
I want [goal]
so that [reason].

h1. Acceptance Criteria
[clear, concise, and testable statements]

h1. Additional Notes
[optional]
```

### Bug

```
h1. Problem
[observable problem and impact]

h1. Steps to Reproduce
[enumerated steps]
```

### Epic

```
h1. Summary
[one paragraph]

h1. Goals / Outcomes
* [goal 1]
* [goal 2]

h1. Scope
In Scope:
* [item 1]
* [item 2]
```

### Wiki markup gotchas

Bodies are **Jira wiki markup** (the CLI does not convert Markdown). Common breakages:

- **Never put literal `{`, `}`, `[`, or `]` inside a `{{monospace}}` span.** Jira still parses `{...}` as a macro and `[...]` as a link *inside* monospace, which shatters the span (the text renders raw and the following line breaks out into a `<p>`). This bites when quoting code: `{{createTempProject(names, { opts })}}` and `{{spawnSync(node, [cli, ...args])}}` both break. Reword to drop the braces/brackets from the span (e.g. `{{createTempProject}}` + prose), or escape each with a backslash (`\{`, `\}`, `\[`, `\]`).
- `[text]` anywhere in prose is a **link**, not literal brackets — escape or reword when you mean literal `[...]` (e.g. a `[plugins...]` CLI arg).
- **A hyphen at a token boundary triggers strikethrough.** Jira renders `-phrase-` as struck-through, so a CLI flag like `--changelog` (or `-v/--verbose`) gets eaten: one flag's hyphen pairs with another's, striking the text between — and this happens **even inside `{{monospace}}`**, pairing across span boundaries. Escape every boundary hyphen as `\-` (renders as a literal `-` in both prose and monospace, no visible backslash). Word-internal hyphens (`graph-cli`, `GRAPH-1234`) are safe and must stay unescaped or they break issue auto-linking. A working escape regex: replace any `-` that is **not** between two `[A-Za-z0-9]` with `\-`.
- **Do not author bodies with `jira ... create -b/-T`.** `issue create`/`epic create` run the body through a Markdown→wiki conversion that mangles raw wiki markup (escapes `--`→`\-\-`, `+`→`\+`, eats `<tags>` in `{{}}`). Create with a placeholder body, then set the real wiki via REST `PUT /rest/api/2/issue/KEY` `{"fields":{"description":"..."}}` (or `jira issue edit --body`, which does not convert).
- Verify before trusting a render: fetch `expand=renderedFields` via REST and check the HTML for `class="error"`, stray `{{`, `<del>`/`line-through`, or unexpected `<p>` breaks. See `jira-access` for the token/REST pattern.

### Cross-issue references

**Never mention the relationship between issues in body text** — no other issue keys, no "blocks / blocked by / child of / superseded by / see Epic GRAPH-1234 / child Stories A–H" prose in a description. Those relationships belong in Jira's native features (**Epic Link**, **issue links** like Blocks/Relates), which are flexible, changeable, and rendered by Jira's UI. Prose copies drift out of sync and leave people unsure which place to trust. Express the structure with links; keep each description self-contained about *its own* work. (Historical/context references to other tickets also go in as links, not prose.)

## Workflow

1. Parse issue type (`Story`, `Bug`, `Epic`) and any user-supplied Epic key or "add to sprint" intent.
2. **Epic issue type**: skip sprint question (step 3) and Epic discovery (step 4) unless the user also asked for sprint (normally N/A for Epics). Use Epic template and Epic CLI create (CLI reference above).
3. **Sprint**: If not already stated, ask: "Add to current sprint?" If yes, plan `-a <whoami>` when the team convention is to assign sprint work to the creator; otherwise follow user preference.
4. **Epic selection** (Story required; Bug optional): If no Epic key was given, list Epics via CLI, for example:
   ```bash
   jira issue list -p GRAPH \
     -q 'project = GRAPH AND issuetype = Epic AND assignee = currentUser() AND status != Done' \
     --order-by updated --reverse \
     --plain --columns key,summary,status --paginate 0:50
   ```
   Do not put `ORDER BY` inside `-q` for this CLI — it triggers a JQL parse error; use `--order-by` / `--reverse` instead.
   If **not** adding to sprint, prefer an Epic in **In Progress** when one exists. Present keys and ask which Epic. If the user supplied a key (e.g. GRAPH-1263), use it.
5. **Components**: Infer from summary, paths, or `jira issue view` / `jira issue list` on similar work. Match Jira component names exactly; if ambiguous, ask.
6. **Summary and body**: From context or by asking. Present derived summary + body for confirmation when appropriate.
7. Build the wiki body from the template.
8. **Create** with `jira issue create` (Stories/Bugs/Epics per CLI reference). Use `--raw` when the agent must parse the new key.
9. On failure, report stderr/stdout and stop.
10. **Link issues** (optional): `jira issue link ...` when the user asked or context requires it.
11. **Sprint**: If yes in step 3: `jira sprint list --table --plain --state active` → `jira sprint add <SPRINT_ID> <ISSUE-KEY>`. If no active sprint, say so.
12. **Memory**: After success, run the **remember** skill with the new issue key.

## Style

- Crisp, factual. No personal pronouns.
- Summaries concise and descriptive.
- Bodies: testable acceptance criteria (Stories), reproducible steps (Bugs), outcome-focused (Epics).
