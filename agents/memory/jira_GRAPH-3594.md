---
name: graph-3594-typescript-build-errors-in-node-firefly-generate-image-plugin-ts
description: "Ticket memory for GRAPH-3594 — decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: e3c3b20e-424f-446b-8c42-1bea4707c8aa
  modified: 2026-08-13T02:10:20.094Z
---

# GRAPH-3594 — TypeScript build errors in node-firefly-generate-image/plugin.ts (missing 'computed' export, missing utility-firefly/firefly-api.js, unrecognized 'shuffle' field)

**Type:** Bug
**Created:** 2026-08-13
**Epic:** none

## Origin
Surfaced as a side effect of live-verifying the [[jira_GRAPH-3593]] fix against `graph-plugins-core`/ml-nodes (branch `biddle/GRAPH-2652-add-explicit-shuffle-interface-to-node-p`, stage): once the platform-version resolution bug was fixed, `graph-sdk build @adobe/node-firefly-generate-image` got past dependency resolution and hit 3 pre-existing TypeScript errors in `src/node-firefly-generate-image/plugin.ts` — missing `computed` export from `@graph/platform-exports/node-plugin.js`, missing `@adobe/utility-firefly/firefly-api.js` module, and `shuffle` not recognized in the `NodePluginConfig` type. GRAPH-3593's own description flagged these as "tracked separately."

## Decisions

### 2026-08-13 — Closed as Cannot Reproduce: errors don't exist on main
User created worktree `paterson/GRAPH-3594/fix-firefly-generate-image-build-errors` (branched from current `main`, not the stale `biddle/GRAPH-2652-...` branch) intending to fix the 3 TS errors. Testing there with the GRAPH-3593-fixed SDK binary showed `node-firefly-generate-image`, `node-gemini-generate-video-fl`, `node-runway-generate-video`, and `node-topaz-upsample-video` all build with **zero errors** — nothing to fix. Root cause: `main` already has GRAPH-2652 merged via the official path (PR #510 + follow-up #526 "Updating canShuffle to account for upstream inputs"), which uses `canShuffle: inputPorts => computed(...)` instead of a `shuffle:` config property, and keeps `@adobe/utility-firefly` at `majorVersion: 1` (local source, always in sync) instead of the abandoned v2 bump. The 3 errors were an artifact of the stale exploratory `biddle` branch, not a real defect on the path forward. Closed with resolution "Cannot Reproduce"; no code changes made. Once GRAPH-3593 publishes, `main` should build/submit cleanly as-is.

### 2026-08-13 — Filed as a single Bug covering all 3 errors
User asked to open a Bug for "the broken items in this repo" referring to these 3 TS errors. Filed as one ticket (GRAPH-3594) rather than three, since they were all discovered together in the same file/build attempt — noted in the ticket that the `shuffle` error is likely expected WIP fallout from GRAPH-2652 landing ahead of the corresponding `NodePluginConfig` type update, while the other two look independent. No Epic attached (ambiguous which Epic fits); added to Graph Sprint 27 and assigned to paterson per user confirmation. Linked "Relates" to GRAPH-3593 and set to "Blocks" GRAPH-2652.
