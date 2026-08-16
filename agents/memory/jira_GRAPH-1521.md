---
name: GRAPH-1521 — Integration tests: submit partial failure and orphaned PendingUpload recovery
description: Ticket memory for GRAPH-1521; covers multi-step submit workflow interruption and re-run behavior
type: project
originSessionId: 87f6cad0-a9ae-4508-a805-a8a29318c433
---
# GRAPH-1521 — Integration tests: submit partial failure and orphaned PendingUpload recovery

**Type:** Story
**Created:** 2026-04-14
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created as part of a coverage gap analysis. The submit workflow is POST /plugins → S3 upload → PATCH. If interrupted after POST but before PATCH, the plugin is orphaned in PendingUpload. Re-running submit hits a completely untested code path.

## Decisions

### 2026-04-14 — May expose missing feature, not just missing test
This story should assess whether the SDK recovers from orphaned PendingUpload state. If recovery isn't implemented, the story should add a clear error message AND create a follow-up story for the implementation. Don't bundle both into this ticket if the implementation work is non-trivial.

**Why:** Keeps this story bounded as a test/diagnostic story; avoids scope creep into a larger feature.

### 2026-04-14 — Sequence after GRAPH-1517 and GRAPH-1518
The submit workflow infrastructure built in those stories reduces setup cost here.
