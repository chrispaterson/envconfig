---
name: GRAPH-1498 — graph-sdk install does not create tsconfig.json when plugin has no dependencies
description: Ticket memory for GRAPH-1498: decisions, context, and origin notes
type: project
originSessionId: 759d72cc-3e68-4a76-82b2-e8a2c2495e69
---
# GRAPH-1498 — graph-sdk install does not create tsconfig.json when plugin has no dependencies

**Type:** Bug
**Created:** 2026-04-13
**Epic:** none

## Origin
Bug discovered in `src/commands/install.ts:75-78` — the early-return guard `if (dependencies.length === 0) return` exits before the `tsconfig.json` write block, so plugins with no dependencies never receive a `tsconfig.json`. Added directly to Graph Sprint 19 (Apr 13–24) with no Epic.

## Decisions
<!-- Newest first -->

### 2026-04-13 — Root cause identified
The fix is to move the `tsconfig.json` write (lines 131–149) before the early-return guard, or restructure so it always runs regardless of dependency count.
