---
name: GRAPH-1518 — Integration tests: submit PATCH state transition failure cases
description: Ticket memory for GRAPH-1518; covers PATCH /plugins/{id} 409/400 failures after S3 upload in submit command
type: project
originSessionId: 87f6cad0-a9ae-4508-a805-a8a29318c433
---
# GRAPH-1518 — Integration tests: submit PATCH state transition failure cases

**Type:** Story
**Created:** 2026-04-14
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created as part of a coverage gap analysis. The PATCH step of the submit workflow (transitioning to PendingReview) can fail with 409 (DependenciesNotAvailable), 400 (FilesNotUploaded), or 400 (invalid re-submit). None tested.

## Decisions

### 2026-04-14 — 409 case is achievable end-to-end on staging
Submit a dependency plugin and immediately submit a dependent plugin before the dependency reaches Available state. This is a real race condition scenario.

**Why:** Avoids needing any mocking; tests the real graph-services behavior.

### 2026-04-14 — FilesNotUploaded case is most complex
May require a local test proxy to intercept the S3 PUT, or a checksum mismatch injected into the manifest files map. Assess during implementation and time-box the approach.
