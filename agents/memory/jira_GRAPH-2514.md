---
name: jira-graph-2514
description: "Ticket memory for GRAPH-2514: enable graph/no-module-scope-vars in graph.strict"
metadata: 
  node_type: memory
  type: project
  originSessionId: deb9392c-56b5-4d0e-84af-ecfa92709231
---

# GRAPH-2514 — Enable graph/no-module-scope-vars rule in @graph/eslint-plugin strict config

**Type:** Story · **Points:** 1.1 · **Epic:** GRAPH-2462 · **Component:** SDK · **Created:** 2026-06-12

The "flip the switch" follow-up to [[jira_GRAPH-2504]]. One-line change: add `"graph/no-module-scope-vars": "error"` to the `graph.strict.rules` map in `packages/graph-eslint-plugin/src/index.ts`, and remove the registered-but-not-enabled comment left in `strict.rules` by GRAPH-2504. Add a `rush change` entry. **Depends on GRAPH-2513** (downstream node plugins must be migrated first, or core-nodes/ml-nodes lint breaks).
