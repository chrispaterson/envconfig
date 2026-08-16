---
name: jira-graph-2171
description: "GRAPH-2171: graph-sdk install auto-adds doc.md to assets.internal in manifest.json if file exists and not already listed"
metadata: 
  node_type: memory
  type: project
  originSessionId: a5f6719e-1725-47b7-a4d2-995852192078
---

GRAPH-2171: graph-sdk install should add `doc.md` to `manifest.json` `assets.internal` on install if the file exists and isn't already listed. 2.1 pts, Epic GRAPH-1271.

**Why:** Developers generating doc.md (via `make-docs`) had to also manually update manifest.json; install should keep assets.internal in sync automatically.

**How to apply:** Pattern already established in `make-docs.ts:ensureDocAssetInManifest()` (lines ~220–232). Wire the same logic into `install.ts` `install()` function with a file-existence check before mutating manifest. Tests go in `install.test.ts`.
