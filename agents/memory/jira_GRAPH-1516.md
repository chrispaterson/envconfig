---
name: GRAPH-1516 — Integration tests: auth failure handling across graph-service calls
description: Ticket memory for GRAPH-1516; covers 401/403 error paths in submit and install; creates withBadToken() helper
type: project
originSessionId: 87f6cad0-a9ae-4508-a805-a8a29318c433
---
# GRAPH-1516 — Integration tests: auth failure handling across graph-service calls

**Type:** Story
**Created:** 2026-04-14
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created as part of a coverage gap analysis comparing graph-sdk integration tests against the full graph-services API surface. Auth failure paths (401/403 from graph-services) were completely untested — users got opaque errors or stack traces rather than clear messages.

## Decisions

### 2026-04-14 — withBadToken() helper is a shared dependency
This story produces a `withBadToken()` test helper that overrides `GRAPH_SDK_ACCESS_TOKEN` with an invalid value in the subprocess environment. This helper is explicitly referenced as a dependency in GRAPH-1519 (install remote dep failures) and GRAPH-1521 (partial failure recovery). Implement it in `test-helpers.ts` alongside `createTempProject`.

**Why:** Keeps auth simulation consistent across all stories that need it rather than each test rolling its own approach.
