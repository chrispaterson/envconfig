---
name: graph-2336-update-plugin-developer-guide-for-per-plugin-type-tsconfig-lib-selection-graph-2196
description: "Ticket memory for GRAPH-2336: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8c8e5d38-0cf8-45d1-9682-6ae1afcf60d3
---

# GRAPH-2336 — Update Plugin Developer Guide for per-plugin-type tsconfig lib selection (GRAPH-2196)

**Type:** Story
**Created:** 2026-06-03
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin

Created automatically after reviewing PR #2970 (GRAPH-2196). That PR changed `graph-sdk install` to write a type-appropriate TypeScript `lib` array into each plugin's `tsconfig.json`, but the Plugin Developer Guide was not updated to document this behavior. Two pages need updating.

## Decisions
<!-- Newest first -->

### 2026-06-03 — Initial scope

Two wiki pages need updating: (1) graph-sdk CLI Reference (`install` section) — add a note that `install` configures the `lib` array based on plugin type (widget → DOM, node/datatype/utility → WebWorker, utility with `forPluginType: "widget"` → DOM); (2) Developing Utilities — add `forPluginType` to the `createUtilityPlugin()` field reference table and a prose note explaining that omitting it defaults to WebWorker types. Estimated 1.1 pts.
