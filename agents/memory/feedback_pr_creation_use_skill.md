---
name: feedback-pr-creation-use-skill
description: "Always use the pr-summary/open-pr skills to create or edit PRs in project-graph, not ad hoc `gh pr create`"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 66175486-f881-4de5-a585-7d8d329e5c2e
  modified: 2026-07-23T19:58:20.383Z
---

Always use the `pr-summary` (or `open-pr`) skill to create/update PRs in the `project-graph` repo — never hand-craft a PR title/body with a bare `gh pr create`/`gh pr edit`.

**Why:** Manually created a PR for GRAPH-3166 with an ad hoc title ("Port Codeowners Review Cli") and a free-form body. CI's "Validate Jira Ticket" check failed: this repo enforces that the PR title starts with `[GRAPH-XXX]` and that the body contains the ticket key. The `pr-summary` skill already encodes these rules (title format `[ISSUE-KEY] <title>`, body must start from `.github/PULL_REQUEST_TEMPLATE.md` with a `Closes GRAPH-XXX` line) — using it from the start would have avoided the failed check and a round-trip.

**How to apply:** When opening a PR (e.g. at the end of the `do` skill's workflow, or via `git pr`), follow up immediately with the `pr-summary` skill to set the correct title/body, rather than trusting a generic `gh pr create -t/-b` invocation. If `git pr`'s own auto-generated title/body is used, still verify it matches `[GRAPH-XXX] ...` and contains the ticket key before considering the PR done — check `gh pr checks <number>` afterward to confirm the Jira-validation check passes.
