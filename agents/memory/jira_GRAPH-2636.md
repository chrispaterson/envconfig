---
name: graph-2636-improve-patch-updatetype-error-message-in-submit-to-clarify-major-minor-only-plugin-versioning
description: "Ticket memory for GRAPH-2636: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 48944f1c-b58b-4da8-b87a-35e227dafd4f
---

# GRAPH-2636 — Improve 'patch' updateType error message in submit to clarify major/minor-only plugin versioning

**Type:** Story
**Created:** 2026-06-22
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin
Created to improve the UX of the graph-sdk submit command: when a user passes `--change-type patch`, the current error is generic. The fix adds a targeted guard clause explaining that plugins have no "patch" version and suggesting "minor" instead. Single file change in submit.ts + one test case; estimated 1.1 pts.

## Decisions
<!-- Newest first -->

### 2026-06-22 — Initial creation
Fix is a guard clause on `options.changeType` in `submit.ts` around line 205 — if value is `"patch"`, throw an informative error referencing major/minor-only versioning. `PluginUpdateType = "major" | "minor"` defined in `@graph-services/specs`. CLI option defined in `cli.ts:247`.
