---
name: jira-graph-2196
description: "GRAPH-2196: per-plugin-type tsconfig.json templates to enforce global scope restrictions (no DOM libs for node/datatype/utility/resource plugins)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 47de0134-4bf6-4919-860f-767d34a3e84b
---

GRAPH-2196: Split `templates/plugins/tsconfig.json` into per-plugin-type variants so node/datatype/utility/resource plugins exclude DOM libraries, and widget plugins retain them.

**Why:** Node-type plugins run outside a browser; DOM globals are unavailable at runtime. A shared template silently allows TypeScript to compile code that uses `document`, `window`, etc., causing runtime failures.

**How to apply:** Change is in `install.ts:131` — select template based on `plugin.type` (already in scope). Create 2–3 template files in `templates/plugins/`. Five plugin types: `node`, `datatype`, `utility`, `resource` → no DOM; `widget` → keep DOM.

Epic: GRAPH-1271 (SDK DX Enhancements). Sprint 217336. 2.1 pts.
