---
name: jira-graph-2513
description: "Ticket memory for GRAPH-2513: remove module-level vars from graph-plugins-core node plugins"
metadata: 
  node_type: memory
  type: project
  originSessionId: deb9392c-56b5-4d0e-84af-ecfa92709231
---

# GRAPH-2513 — Remove module-level variable declarations from graph-plugins-core node plugins

**Type:** Story · **Points:** 5.1 · **Epic:** GRAPH-2462 · **Component:** Nodes · **Created:** 2026-06-12

Follow-up to [[jira_GRAPH-2504]] (the `graph/no-module-scope-vars` rule). Migrate the **34** node `plugin.ts` files that hold module-scope declarations — **10 in core-nodes, 24 in ml-nodes** — so the rule can be enabled. Most are immutable constants (shaders, regexes, endpoint/config maps, size limits); `node-debounce`'s `debounceMap = new Map()` is the one genuine mutable-state case.

**Depends on GRAPH-1571** (persistent NodeState/context object) — per-run state (debounceMap) can't be relocated until that context exists. Move immutable constants inside the `createNodePlugin({...})`/process scope. graph-plugins-core has no test framework, so verification is build + lint + manual. Blocks GRAPH-2514.
