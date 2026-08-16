---
name: GRAPH-1601 — [GRAPH-SDK] Fix structural pattern inconsistencies identified in normalize audit
description: Ticket memory for GRAPH-1601: decisions, context, and origin notes
type: project
originSessionId: fa30f576-91de-45ec-be64-f7b60eaa1d38
---
# GRAPH-1601 — [GRAPH-SDK] Fix structural pattern inconsistencies identified in normalize audit

**Type:** Story
**Created:** 2026-04-21
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin
Created from a `/normalize --audit src/` run on `packages/graph-sdk` during the same session that fixed Group 4 (subprocess invocation: `spawnSync` → async `spawn` in `build.ts`, `promisify(exec)` → `spawnAsync` in `link.ts`). The audit produced `normalize-audit.md` at the package root; this story covers the 9 remaining groups. Story pointed at 5.1 — primary driver is Group 10 (error propagation refactor + test rewrites); most other groups are mechanical substitutions.

## Decisions
<!-- Newest first -->

### 2026-04-21 — Group 4 already resolved; 9 groups remain
Groups 1–3, 5–10 are the scope of this story. Group 4 was fully resolved in `paterson/GRAPH-1573/fix-sdk-link-command` (the branch active when the audit ran) — do not re-implement it.
