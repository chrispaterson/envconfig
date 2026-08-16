---
name: GRAPH-1520 — Integration tests: submit --status additional plugin registry states
description: Ticket memory for GRAPH-1520; covers PendingUpload, Removed, PendingLocalization states in submit --status
type: project
originSessionId: 87f6cad0-a9ae-4508-a805-a8a29318c433
---
# GRAPH-1520 — Integration tests: submit --status additional plugin registry states

**Type:** Story
**Created:** 2026-04-14
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created as part of a coverage gap analysis. Current status tests only validate PendingReview and Available. Three other registry states (PendingUpload, Removed, PendingLocalization) are reachable but untested.

## Decisions

### 2026-04-14 — PendingUpload is achievable in-test without fixtures
Call `POST /plugins` directly via the SDK plugin service client to create an entry, then immediately run `--status` before uploading files. No staging coordination needed.

**Why:** Deterministic and doesn't require admin access.

### 2026-04-14 — Removed and PendingLocalization need staging fixtures
These states require pre-seeded fixture plugins on staging (e.g. `@test/datatype-removed-fixture`). Must coordinate with the team before the story is dev-complete. Flag as a blocking dependency during sprint planning.
