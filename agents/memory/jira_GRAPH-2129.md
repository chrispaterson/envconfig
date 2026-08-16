---
name: jira-graph-2129
description: "GRAPH-2129: graph-sdk unlink command to reverse graph-sdk link and restore published SDK version"
metadata: 
  node_type: memory
  type: project
  originSessionId: 2357fb5e-2c22-4704-9fcb-0f5883ffebaf
---

GRAPH-2129: add `graph-sdk unlink` command that reverses `graph-sdk link` and restores the consumer project to use the published SDK.

**Why:** `graph-sdk link` overwrites `pnpm-workspace.yaml` with `link:` overrides but provides no way to undo this, leaving developers stuck unless they manually delete the file and re-run `pnpm install`.

**How to apply:** Implementation is an inverse of `linkCommand` in `src/commands/link.ts`. Unlink should: detect whether `pnpm-workspace.yaml` was written by `link` (check for `overrides:` + `link:` pattern), delete/clear the file, run `pnpm install`. Gate behind same `GRAPH_SDK_LINKED_DEV_BUILD=true` env var. Touch 3 files: `link.ts`, `link.test.ts`, `cli.ts`. Estimated 2.1 pts.

Epic: GRAPH-1271 | Sprint: Graph Sprint 21 (217336) | Assignee: paterson
