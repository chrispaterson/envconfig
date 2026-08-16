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
