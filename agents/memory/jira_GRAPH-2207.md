---
name: jira-graph-2207
description: "GRAPH-2207: add 'info' command to graph-sdk CLI showing version, linked state, and target environment"
metadata: 
  node_type: memory
  type: project
  originSessionId: c123872e-d558-464c-983b-cbc7f22dd962
---

GRAPH-2207: add `graph-sdk info` command displaying version (from package.json), linked state (`GRAPH_SDK_LINKED_DEV_BUILD`), and target environment (`GRAPH_SDK_ENV`). 2.1 pts, Epic GRAPH-1271.

**Why:** Plugin developers need a quick way to verify SDK configuration for debugging and bug reports.

**How to apply:** 1 new file `src/commands/info.ts` + register in `src/bin/cli.ts`. All data sources confirmed — no investigation needed before implementing.
