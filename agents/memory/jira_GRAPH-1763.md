---
name: GRAPH-1763 — graph-sdk install does not remove stale tsconfig.json path entries and .plugin-dependencies symlinks when a dependency is removed from manifest.json
description: Ticket memory for GRAPH-1763: decisions, context, and origin notes
type: project
---

# GRAPH-1763 — graph-sdk install does not remove stale tsconfig.json path entries and .plugin-dependencies symlinks when a dependency is removed from manifest.json

**Type:** Bug
**Created:** 2026-04-29
**Epic:** none

## Origin
Discovered while working in ml-nodes: after removing `@adobe/datatype-image` from manifest.json and re-running `graph-sdk install`, the tsconfig.json path alias and `.plugin-dependencies` symlink for the removed dep were not cleaned up. The install command only adds/updates entries; it has no reconciliation pass to remove entries for deps that are no longer declared.

## Decisions
<!-- Newest first -->

### 2026-04-29 — Bug filed
Repro confirmed in ml-nodes: install adds but never removes stale path entries from tsconfig.json and stale symlinks from .plugin-dependencies when a dependency is dropped from manifest.json.
