---
name: remember
description: Record a decision, context note, or key fact about a Jira ticket into its persistent memory file. Creates the file if it doesn't exist.
user-invocable: true
argument-hint: "[GRAPH-XXX] [note text]"
---

# Remember

Record a decision or context note about a Jira ticket into its persistent memory file at `~/agents/memory/jira_<KEY>.md`. Invoked by the user directly, or called by other skills (e.g. `createjira`, `polish`) to capture origin context automatically.

## Invocation forms

| Invocation | Behaviour |
|---|---|
| `/remember` | Infer ticket from branch name; derive note from conversation context |
| `/remember GRAPH-123` | Use the specified ticket; derive note from conversation context |
| `/remember we decided to use X because Y` | Infer ticket from branch; use provided text as the note |
| `/remember GRAPH-123 we decided to use X because Y` | Explicit ticket and note |

When called by another skill, the caller passes the issue key and any structured fields (origin, preservation branch, note text) as part of the invocation context.

---

## Workflow

### 1. Resolve the issue key

- Parse from arguments (e.g. `GRAPH-123`).
- If not in arguments, infer from `git branch --show-current` (e.g. `paterson/GRAPH-530/plugin-types` → `GRAPH-530`).
- If still ambiguous, ask the user.

### 2. Determine the note content

- If the invocation includes explicit text (after the optional key), use that as the note.
- Otherwise, derive a concise note from the current conversation — the most recent decision, scope change, approach choice, or key fact. Focus on *why*, not *what*.
- If context is insufficient to write a meaningful note, ask the user: *"What should I remember about GRAPH-XXX?"*

### 3. Create or update the memory file

Check for `~/agents/memory/jira_<KEY>.md`.

#### If the file does not exist — create it

Fetch the ticket summary from Jira so the file is self-contained: `jira issue view <KEY> --raw` (parse `fields.summary`, `fields.issuetype`, `fields.parent`) per `~/agents/skills/jira-access/SKILL.md`. Then write:

```markdown
---
name: GRAPH-XXXX — <summary>
description: Ticket memory for GRAPH-XXXX: decisions, context, and origin notes
type: project
---

# GRAPH-XXXX — <summary>

**Type:** Story | Bug | Epic
**Created:** <today's date>
**Epic:** <epic key and summary, or "none">

## Origin
<Derive from conversation context: why this ticket exists, how it came to be worked on.
If this was split out from another branch during a /polish scope reduction, record:
the source branch name, why it was deferred, and any caveats in the preserved snapshot.>

## Preservation Branch
<If applicable: the git branch name preserving split-out work, e.g.
`paterson/GRAPH-XXXX/scheduler-refactor`. Omit this section entirely if not a scope split.>

## Decisions
<!-- Newest first -->

### <today's date> — <short label>
<The note content from step 2.>
```

Then add a pointer to `~/agents/memory/MEMORY.md`:
```
- [GRAPH-XXXX — <summary>](./jira_GRAPH-XXXX.md) — <one-line hook>
```

#### If the file already exists — append to it

Prepend a new entry to the `## Decisions` section (newest first):

```markdown
### <today's date> — <short label>
<The note content from step 2.>
```

Do not modify the Origin, Preservation Branch, or frontmatter sections unless explicitly asked.

### 4. Confirm

Briefly confirm what was recorded and to which file. One line is enough.

---

## Guidelines

- **Only record meaningful notes**: scope changes, approach decisions, deferred work, discovered constraints, significant pivots. Skip trivial facts that are obvious from the code or ticket.
- **Explain why, not what**: the note should capture rationale that a future session cannot infer from code or git history alone.
- **Keep notes short**: two sentences maximum per entry. If it needs more, the ticket description is the right place.
- **Preservation branch notes** are especially important — always record the branch name verbatim so a future agent can check it out without searching.
