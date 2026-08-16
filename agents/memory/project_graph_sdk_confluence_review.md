---
name: graph-sdk Confluence review on PR merge
description: When merging a PR that touches packages/graph-sdk/, Claude is triggered to review the Plugin Developer Guide and file a Jira ticket if doc updates are needed
type: project
---

When a PR touching `packages/graph-sdk/` is merged via `git pr merge`, the `~/bin/git-aliases/pr` script automatically invokes `claude --print` to:

1. Review the Plugin Developer Guide (Confluence page ID 3769393821) against the diff
2. Create a GRAPH Jira ticket if documentation updates are needed

**Why:** The Plugin Developer Guide must stay in sync with SDK changes. Manual review was easy to forget at merge time.

**How to apply:** If the user asks about SDK changes and doc updates, this review already happens at merge time. If they're mid-PR, remind them the review triggers automatically on `git pr merge`.
