---
name: updatejira
description: Update an existing Jira issue (Story, Bug, or Epic) in the GRAPH project using the jira CLI. Infers issue key from branch name if not specified. Use when user invokes /updatejira or asks to update a Jira ticket.
user-invocable: true
---

# Update Jira Issue

## Purpose

Update an existing GRAPH issue using the **jira CLI** only. Revise summary, description, components, status, sprint membership, links, or comments as work progresses. The agent derives changes from conversation context when available, or asks the user.

**Jira command reference:** read and follow `~/agents/skills/jira-access/SKILL.md` for every concrete command (view, list, edit, move, sprint, link, comment, REST). Do not duplicate that table here.

**Do not** use Corp Jira MCP (`mcp__ada-mcp-gateway__*`) for this workflow unless the user explicitly overrides.

## Invocation

- `/updatejira` — infer issue key from current branch name (e.g. `paterson/GRAPH-530/plugin-types` → GRAPH-530)
- `/updatejira GRAPH-123` — update the specified issue

If neither invocation nor branch yields a key, ask the user.

## Body structure (when editing description)

### Stories

Preserve existing structure unless the user requests otherwise:

```
h1. User Story
As a [user],
I want [goal]
so that [reason].

h1. Acceptance Criteria
[clear, concise, and testable statements]

h1. Additional Notes
[optional section]
```

### Epics

```
h1. Summary
[one-paragraph summary of the Epic]

h1. Goals / Outcomes
* [goal or outcome 1]
* [goal or outcome 2]

h1. Scope
In Scope:
* [in-scope item 1]
* [in-scope item 2]
```

## Workflow

1. **Issue key** — Parse from args (e.g. `/updatejira GRAPH-530`) or infer from `git branch --show-current`. If ambiguous, ask.

2. **Fetch current state** — `jira issue view <KEY> --raw` (per `jira-access` skill). Parse fields needed for the edit (summary, description, status, components, issuetype, etc.).

3. **Determine what to update** — From conversation and user text (e.g. `/updatejira add focused imports to acceptance criteria`). If unclear, ask for: summary change, body/section updates, components, status transition, sprint add/remove, links, or Epic-only fields.

4. **Merge body edits** — When updating the description, merge user changes into the existing wiki structure; preserve sections not being changed.

5. **Apply updates** (jira CLI first, REST only if needed — see `jira-access` skill):
   - **Summary / description / simple fields:** `jira issue edit <KEY> --no-input ...` per local `jira issue edit --help`.
   - **Status:** `jira issue move <KEY> "<Status Name>"`.
   - **Sprint:** `jira sprint list` / `jira sprint add` (and removal patterns supported by your CLI version), per `jira-access` skill.
   - **Issue links:** `jira issue link ...` per `jira-access` skill.
   - **Comments only:** `jira issue comment add <KEY> -b "..."` when a comment is the right artifact (e.g. documenting a state change the CLI cannot perform).

6. **On failure** — Report stderr/stdout or HTTP status from REST; do not guess.

7. **Confirm** — One-line summary of what changed.

## Style

- Crisp, factual. No personal pronouns.
- Preserve Jira wiki markup (`h1.`, `*`, etc.) when editing bodies.
