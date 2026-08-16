---
name: graph-3593-graph-sdk-resolveexternal-sends-wrong-platform-major-filter-to-plugin-service-graph-3361-fix-regression-causing-false-platform-version-mismatch-errors
description: "Ticket memory for GRAPH-3593: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: c8b2190c-d8f3-4f04-971a-9f9d0bbd36e7
  modified: 2026-08-13T01:58:39.380Z
---

# GRAPH-3593 — graph-sdk resolveExternal() sends wrong platform-major filter to plugin service (GRAPH-3361 fix regression), causing false Platform version mismatch errors

**Type:** Bug
**Created:** 2026-08-13
**Epic:** none

## Origin
Surfaced while troubleshooting the #GRAPH-2652 Slack thread's "big problem" (platform version mismatch build errors on stage for ~19 gen-ai nodes) on branch `biddle/GRAPH-2652-add-explicit-shuffle-interface-to-node-p` in graph-plugins-core. Initial theory (a huge unpublished platform-major-2 migration gap) was disproven by empirically patching `@graph/sdk`'s `resolveExternal()` locally and confirming platform-major-2 versions of the primitives already exist and resolve cleanly on stage.

## Decisions

### 2026-08-13 — Root cause found; filed as new linked bug rather than reopening GRAPH-3361
`resolveExternal()` (in `project-plugins.ts`, `@graph/sdk`) sends the dependency's own plugin majorVersion as the `platformVersion.major` filter to `PluginService.resolvePlugin()`, instead of `requestingPlatformMajor` — a regression baked into [[jira_GRAPH-3361]]'s own shipped fix plan (which itself specified `platformVersion: { major: Number(pluginMajorVersion), minor: 0 }`, the same conflation). Verified by patching the one line locally (node_modules only, not committed) to use `requestingPlatformMajor`: every "Platform version mismatch" error disappeared and datatype-boolean/widget-video/utility-firefly/datatype-string all resolved with `platformVersionMajor: 2` on stage. User chose to file GRAPH-3593 as a new Bug linked "is caused by" GRAPH-3361 rather than reopening the Done ticket. Suggested fix: change `dependencyPlatformVersion` to `{ major: requestingPlatformMajor }` in `Adobe-CreativeCloud/graph` repo, then republish `@graph/sdk`. Blocks GRAPH-2652 from building/submitting on stage.

### 2026-08-12 — Fixed and PR opened: Adobe-CreativeCloud/graph#3374
The `GRAPH-3593/fix-resolveexternal-platform-major-filter` worktree had been branched from local `main` *before* GRAPH-3361's PR #3297 merged into `origin/main`, so the buggy line didn't exist in the worktree yet (grep for `resolveExternal`/`requestingPlatformMajor` came up empty at first). Fast-forwarding to `origin/main` pulled in the merged GRAPH-3361 fix (commit 61d7b5c62), which then contained the exact bug described above. One-line fix applied in `project-plugins.ts`; also corrected the existing GRAPH-3361 regression test in `project-plugins.test.ts` that had encoded the bug's wrong expected value (`platformVersion: { major: 3 }` — the dependency's own major — instead of the requester's), and a paragraph in `install-flow.md` that documented the buggy behavior as intended. Live-verified against `graph-plugins-core/ml-nodes` on stage: published SDK (3.0.2) fails ("Unable to resolve remote plugin manifest"), fixed build resolves cleanly with `platformVersionMajor: 2` manifests. `core-nodes` also depends on `@graph/sdk` but is pinned to an old published major (2.11.6, predates GRAPH-3361 entirely) — didn't get a live A/B there due to an interactive IMS auth prompt in the sandbox, but the fix touches the same shared code path with no package-specific branching, so no additional risk expected.
