---
name: GRAPH-1499 — graph-sdk build resolves distDir incorrectly when project path contains a parent directory named 'src'
description: Ticket memory for GRAPH-1499: decisions, context, and origin notes
type: project
originSessionId: 759d72cc-3e68-4a76-82b2-e8a2c2495e69
---
# GRAPH-1499 — graph-sdk build resolves distDir incorrectly when project path contains a parent directory named 'src'

**Type:** Bug
**Created:** 2026-04-13
**Epic:** none

## Origin
Reported directly by user. Root cause is `project-plugins.ts:215` where `dir.replace(SRC_DIR_NAME, DIST_DIR_NAME)` uses `String.replace()`, which replaces the *first* occurrence of `"src"` in the absolute path rather than the terminal plugin-level `src` segment. Added to Graph Sprint 19 (Apr 13–24) without an Epic.

## Decisions
<!-- Newest first -->

### 2026-04-13 — Root cause identified
Fix must replace only the last `src` path segment, not the first — use `path.dirname(dir) + "/dist"` or a suffix-aware replacement so ancestor directories named `src` are not affected.
