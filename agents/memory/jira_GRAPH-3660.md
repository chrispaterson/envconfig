---
name: jira-graph-3660
description: "GRAPH-3660: make SDK selectPlugins/buildDependencyGraph major-aware (name:major, not bare name) for same-name local-new-major + external-old-major plugins; follow-up hardening for GRAPH-3649's targeted prefer-local fix"
metadata: 
  node_type: memory
  type: project
  originSessionId: eceff27e-b0da-45c1-b703-2b8f3b84d920
  modified: 2026-08-17T20:19:47.254Z
---

GRAPH-3660 (Story, Sprint 27 8/10-8/21, assignee paterson, Epic GRAPH-2601, component Plugin Service, Relates GRAPH-3649).

Follow-up to [[jira_GRAPH-3649]]. That PR (#3389, biddle) fixed the `submit` "No plugins found" symptom by preferring the local (`external: false`) entry during **seed** resolution in `selectPlugins` — correct and minimal for the seed-only path, but a patch over a deeper inconsistency.

**Root problem:** `selectPlugins` (~L493) and `buildDependencyGraph` (~L160) in `packages/graph-sdk/src/plugins/project-plugins.ts` both key plugins by bare `name` (`Map<name,index>`, last-write-wins), whereas the rest of the module keys by `name:major` via `getPluginMapKey` (L62 / `ProjectPluginMap`) precisely because name isn't unique once a local new-major coexists with a published old-major. `getProjectPlugins` appends externals after locals (L445), so bare-name maps resolve the duplicated name to the **external old-major** entry.

**Latent bugs left by GRAPH-3649 (this Story fixes):** dependency graph collapses local v2 + external v1 into one node (the external); consumers' edges attach to the external old-major node, local new-major node has zero dependents. So `include: ["dependencies"|"dependents"]` expansion (`build --to`, submit-with-deps) walks a major-blind graph. Masked today only because nothing local depends on the new major yet.

**Fix direction:** key selection + dep-graph on `name:major`; resolve each dep edge by the dependent's pinned `majorVersion`; then the prefer-local seed workaround can be removed/subsumed, GRAPH-3649 regression test still passing.

Plan: user approves PR #3389 as-is and asks biddle to add a `// TODO(GRAPH-3660)` comment referencing this Story.

**IMPLEMENTED 2026-08-17, PR #3403 (draft):** GRAPH-3649's PR #3389 was still unmerged/open when this was done, so implemented directly on main rather than layering on top of it — this fix generalizes and supersedes #3389's targeted patch (still relates to it, doesn't close it).

- `buildDependencyGraph`: replaced bare-name `indexByName` with `buildIndexByKey` (keyed by `getPluginMapKey(name, version)`); dependency edges resolved via new `forEachInScopeDependency` helper using each dependent's pinned `majorVersion` from its manifest, not bare depName.
- `selectPlugins`: "dependencies" expansion now uses the same `forEachInScopeDependency`/`buildIndexByKey` helpers (previously had its own independently-bugged bare-name loop — this was the second copy of the same bug pattern). Seed resolution (bare `pluginNames[]` → index, since build/submit callers have no way to specify a major) uses new `buildSeedIndexByName`, which prefers the local (`external: false`) entry on name collision — same policy as #3389 but implemented once, consistently.
- Tests added in `project-plugins-ordering.test.ts` under `describe("selectPlugins major-aware coexistence (GRAPH-3660)")`: local-major-2 + external-major-1 same-name pair with one dependent pinned to each major; covers seed resolution, `dependencies` expansion, `dependents` expansion. Had to hand-order the test fixture array (not derive via `sortPluginsByDependencyOrder`) to deterministically reproduce the bug — an accidental topological-sort ordering was masking the seed-resolution bug in an early draft of the test.
- core-impact check: `core-nodes` fully compatible (baseline vs. locally-linked-SDK build logs identical modulo ordering noise); `ml-nodes` has a **pre-existing, unrelated** build failure (`@graph/platform-exports` missing `computed` export + unknown `shuffle` prop) present identically in both baseline and modified — not caused by this change.
- `rushx build`/`lint`/`test` all pass for `@graph/sdk` (520 tests). Rush change file added (patch bump).
