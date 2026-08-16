---
name: GRAPH-1749 — graph-sdk template adds eslint.config.mjs with eslint/config dependency but does not ensure it is installed
description: Ticket memory for GRAPH-1749: decisions, context, and origin notes
type: project
originSessionId: 290a45db-622e-466b-ab6b-332fdbcb8634
---
# GRAPH-1749 — graph-sdk template adds eslint.config.mjs with eslint/config dependency but does not ensure it is installed

**Type:** Bug
**Created:** 2026-04-28
**Epic:** none

## Origin
Reported during template scaffolding review: graph-sdk writes an eslint.config.mjs that imports from eslint/config but does not install or validate the presence of that dependency in the scaffolded project, causing a module-not-found build error for consumers who don't have it.

## Decisions
<!-- Newest first -->

### 2026-04-28 — Initial filing
graph-sdk template adds eslint.config.mjs with eslint/config dependency but does not ensure it is installed — build fails with module-not-found if dependency is absent.
