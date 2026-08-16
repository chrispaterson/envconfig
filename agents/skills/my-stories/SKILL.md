---
name: my-stories
description: Use when user invokes /my-stories or asks to see their Jira stories, backlog, current work, or open tickets in the GRAPH project.
user-invocable: true
---

# My Jira Stories

## Purpose
Fetch and display open Jira stories and bugs assigned to or owned by the user in the GRAPH project.

## Invocation
- `/my-stories` — fetch all open stories matching the default query

## JQL Query

```
project = Graph AND issuetype in (Story,Bug) AND ((component = SDK AND assignee is EMPTY) or assignee = paterson) and status != Done
```

This captures:
- SDK component stories with no assignee (shared ownership)
- Any story or bug directly assigned to `paterson`
- Excludes anything in `Done` status

## Workflow

1. **Run the query** with the jira CLI per `~/agents/skills/jira-access/SKILL.md`, for example:
   ```bash
   jira issue list -q 'project = Graph AND issuetype in (Story,Bug) AND ((component = SDK AND assignee is EMPTY) or assignee = paterson) and status != Done' \
     --plain --columns key,summary,status,customfield_10003,priority --paginate 0:200
   ```
   Adjust `--columns` to match fields your CLI version exposes (story points field name may appear as `customfield_10003` in `--raw` vs plain columns).

2. **Display results** in a table:

   | Key | Summary | Status | Points | Priority |
   |-----|---------|--------|--------|----------|
   | GRAPH-XXX | ... | In Progress | 3 | Medium |

   Pull from plain output columns or from `--raw` / JSON lines if using machine-readable output.

3. **Group by status** — In Progress first, then To Do, then any other open states.

4. **After the table**, print a one-line count: `X stories — Y in progress, Z to do.`
