---
name: GRAPH-1726 — prettier not bundled in published SDK because it was in devDependencies
description: Ticket memory for GRAPH-1726: decisions, context, and origin notes
type: project
originSessionId: f4273545-c8b3-42f6-9250-85e427562417
---
# GRAPH-1726 — prettier not bundled in published SDK because it was in devDependencies

**Type:** Bug
**Created:** 2026-04-27
**Epic:** none

## Origin
Discovered that `prettier` was placed in `devDependencies` in `packages/graph-sdk/package.json`, which means it is not installed when consumers install the published SDK package. Any SDK command relying on prettier at runtime fails for end users. The fix (moving `prettier` to `dependencies`) was already made locally (visible in `git diff package.json`) when the ticket was filed.

## Decisions
<!-- Newest first -->

### 2026-04-27 — Bug filed; local fix already staged
prettier moved from devDependencies to dependencies in the working copy. Ticket created to track the fix through review and release; added to Graph Sprint 20 (Apr 27–May 8) and assigned to paterson.
