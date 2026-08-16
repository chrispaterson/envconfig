---
name: graph-3597-update-graph-plugins-core-packages-to-latest-graph-dependencies-pick-up-graph-3593-fix
description: "Ticket memory for GRAPH-3597: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: b041920c-890f-4900-8a4d-fe41fa6fc683
  modified: 2026-08-13T04:32:54.837Z
---

# GRAPH-3597 — Update graph-plugins-core packages to latest @graph/* dependencies (pick up GRAPH-3593 fix)

**Type:** Story
**Created:** 2026-08-12
**Epic:** none (filed standalone per explicit user request)

## Origin
Filed at user request to implement the published fix for [[jira_GRAPH-3593]] in this repo (graph-plugins-core). Linked "Blocks" GRAPH-3593 (GRAPH-3593 is the Bug describing/fixing the root cause upstream in `@graph/sdk`; this Story is the downstream consumption step).

## Decisions

### 2026-08-12 — Scope: bump both packages' @graph/* deps to latest published
`core-nodes` and `ml-nodes` were both pinned to `@graph/sdk@3.0.1` (below `3.0.2`, the version confirmed still-buggy in GRAPH-3593's own notes, and below `3.0.3`, the latest published version which contains the fix). Also bumping the other `@graph/*` deps in both packages to latest while at it: `@graph/eslint-plugin` 1.4.6→1.4.8, `@graph/graph-plugin-types` 3.7.0→3.8.0, `@graph/platform-exports` 2.12.0→2.13.0. `@graph/graph-common-types` (core-nodes only) is already at latest (0.2.0), no change needed there. Added to Sprint 27 (8/10–8/21), assigned paterson.
