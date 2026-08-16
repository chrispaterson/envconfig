---
name: graph-2639-parallelize-graph-sdk-build-command-using-p-limit-with-per-cpu-subprocess-spawning
description: "Ticket memory for GRAPH-2639: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 48944f1c-b58b-4da8-b87a-35e227dafd4f
---

# GRAPH-2639 — Parallelize graph-sdk build command using p-limit with per-CPU subprocess spawning

**Type:** Story
**Created:** 2026-06-22
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin
Created to parallelize the graph-sdk build command across CPU cores using p-limit. The full implementation already exists in `lib/commands/build.js` (compiled artifact from a prior implementation) but `src/commands/build.ts` still uses a sequential `for...of` loop. Work is to port the algorithm back to source.

## Decisions
<!-- Newest first -->

### 2026-06-22 — Initial creation
`lib/commands/build.js` already has the complete parallel implementation: `CONCURRENCY_LIMIT = Math.max(1, os.cpus().length - 1)`, a `Map<pluginName, Promise>` for dep-ordering, and a deadlock-avoidance pattern (deps wait outside the p-limit slot before acquiring it). `p-limit` is NOT yet in `package.json` dependencies (only in lockfile transitively). Key invariant: dep promises must be awaited *outside* the concurrency slot to avoid deadlock.
