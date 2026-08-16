---
name: jira-graph-3377
description: "GRAPH-3377: bug — graph-ui widget-resize-controller.test.ts is never executed by rushx test (vitest config gap)"
metadata:
  node_type: memory
  type: project
  originSessionId: df94a497-096a-47d6-b014-e8d93ba9233f
  modified: 2026-07-30T18:52:32.182Z
---

GRAPH-3377: `packages/graph-ui/src/widget-resize-controller.test.ts` (added in PR #3212, tests `WidgetResizeController`) is never picked up by `rushx test`. `vitest.config.ts`'s `storybookTest` plugin overrides `test.include` to only `src/**/*.stories.@(js|jsx|mjs|ts|tsx)`; `vitest.unit.config.ts` only includes `./src/test/**/*.test.ts` with `environment: "node"` (no DOM). The file lives directly under `src/`, needs a browser/DOM environment (Lit custom elements), and matches neither.

**Why:** Discovered while adding a regression test for [[jira_GRAPH-3373]] — the new test (and the 4 pre-existing ones in that file) only ran when pointed at via a throwaway vitest config override; CI has never exercised this coverage. Predates GRAPH-3373 and is unrelated to the null/undefined type bug, so it was filed separately rather than expanding that PR's scope (user's explicit choice: "file a follow-up ticket only", backlog/unassigned, not sprinted).

**How to apply:** Fix needs a vitest project/config that runs plain, non-story `*.test.ts` files requiring a browser/DOM environment, wired into the `test` script alongside the existing two runs, without breaking story-based or node-unit discovery. No Epic link; unassigned; not in a sprint.
