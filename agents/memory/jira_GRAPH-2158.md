---
name: jira-graph-2158
description: "GRAPH-2158: bump @graph-services/specs from 0.9.31 to 0.9.42 in graph-sdk package.json; 1.1 pts, Epic GRAPH-1271"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9c26e632-2f6c-4a98-9737-7d38c2d6d818
---

GRAPH-2158: Update `@graph-services/specs` version to 0.9.42 in `packages/graph-sdk/package.json` (currently `0.9.31`).

**Why:** Keep graph-sdk aligned with latest graph service type definitions and API contracts.

**How to apply:** Single-line package.json edit + `rush update`; resolve any type errors that emerge. Scoped to graph-sdk only (6 other monorepo packages also at 0.9.31 are out of scope). Epic GRAPH-1271, Sprint 21, 1.1 pts.
