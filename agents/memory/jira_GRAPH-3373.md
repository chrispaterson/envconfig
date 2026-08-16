---
name: jira-graph-3373
description: "GRAPH-3373: bug — WidgetResizeControllerOptions.target return type incorrectly excludes null, regression from lint cleanup commit"
metadata: 
  node_type: memory
  type: project
  originSessionId: 69084e92-e915-497a-87e7-5a9961fee7ec
  modified: 2026-07-30T18:20:42.583Z
---

GRAPH-3373: `WidgetResizeControllerOptions.target` in `packages/platform-exports/src/v1/widget-resize-controller.ts` had its return type narrowed from `() => Element | null | undefined` to `() => Element | undefined` in commit `ff2ec6192` (PR #3277, GRAPH-3161, "Eliminate all lint warnings in remaining packages"). The corresponding `this._targetGetter() ?? undefined` normalization in `_syncObservation()` was also collapsed to `this._targetGetter()` in the same commit.

**Why:** DOM selector patterns (`querySelector` etc.) legitimately return `null`, so the narrowed type is a real regression, not dead code that lint correctly flagged.

**How to apply:** Fix is to restore `null` to both the `target` option type and the `_targetGetter` field type, and restore the `?? undefined` normalization. No Epic link; assigned to paterson; added to Sprint 26 (7/27-8/07).
