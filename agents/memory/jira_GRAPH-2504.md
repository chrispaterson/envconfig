---
name: graph-2504-graph-no-module-scope-vars-eslint-rule
description: "Ticket memory for GRAPH-2504: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9dbb973a-d703-4677-8332-fe4be8be28a9
---

# GRAPH-2504 — graph/no-module-scope-vars ESLint rule — restrict module-level variable declarations in node plugin files

**Type:** Story
**Created:** 2026-06-11
**Epic:** GRAPH-2462 — Dev-time guardrails — development-time plugin constraint enforcement

## Origin
Arose from a conversation about using ESLint to catch module-level state in node plugin files. The rule should flag any `Program > VariableDeclaration` in files that define a node plugin, catching mutable module-scope state before submission.

## Decisions
<!-- Newest first -->

### 2026-06-12 — Implemented; rule registered but NOT enabled; rollout split into two follow-ups
Built the rule and opened draft PR #3039 (https://github.com/Adobe-CreativeCloud/graph/pull/3039). Key scope correction from the author during the session: the rule flags **every** module-level declaration (const/let/var), mutable *or* immutable — the immutable-vs-mutable distinction does not matter, because node plugins will receive a persistent context object ([[jira_GRAPH-2504]] driver is GRAPH-1571) so they never need module-scope vars.

Core-impact scan found **34 of 342** downstream node `plugin.ts` files (10 in core-nodes, 24 in ml-nodes) with module-scope declarations — mostly immutable constants (shaders, regexes, endpoint/config maps, size limits) plus one genuine mutable case (`node-debounce`'s `debounceMap = new Map()`). So GRAPH-2504 **registers** the rule in `strict.rules` but deliberately does **NOT** add it to the bundled `graph.strict` config (that would break downstream lint at next publish). Enablement deferred:
- **GRAPH-2513** (5.1) — migrate core-nodes/ml-nodes node plugins to remove module-level decls; depends on GRAPH-1571.
- **GRAPH-2514** (1.1) — flip the rule on in `graph.strict`; depends on GRAPH-2513.

Downstream consumes the *published* `@graph/sdk/eslint-plugin`, so this PR is safe to merge now (staged-rollout pattern, like GRAPH-2501 gating no-globals/GRAPH-2198).

### 2026-06-11 — Use createPluginManifestCollector() for detection
Reuse the existing `createPluginManifestCollector()` utility from `plugin-manifest-utils.ts` — it already detects `create*Plugin` calls via `CallExpression`. Check `state.createPluginCallNode` and that the callee name is specifically `createNodePlugin`. The actual plugin pattern is `export default createNodePlugin({...})`, not a named function export, so reimplementing export detection would be wrong. Model the implementation on `no-wick-datatype-name.ts` in the same package.
