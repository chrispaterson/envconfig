---
name: GRAPH-1517 — Integration tests: submit server-side manifest and scope rejection cases
description: Ticket memory for GRAPH-1517; covers POST /plugins 400/403/424 rejection responses in submit command
type: project
originSessionId: 87f6cad0-a9ae-4508-a805-a8a29318c433
---
# GRAPH-1517 — Integration tests: submit server-side manifest and scope rejection cases

**Type:** Story
**Created:** 2026-04-14
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created as part of a coverage gap analysis. `POST /plugins` on graph-services can return 400 (invalid manifest, NoScopeFound, MissingDependencies), 403 (non-allowlisted @test scope account), and 424 (dependency not resolved). None of these rejection paths were tested.

## Decisions

### 2026-04-14 — Reuse fixture manifest overrides pattern
Follow the same pattern as `build.test.ts` which injects TypeScript type errors into fixture files. Modify `manifest.json` in-test to produce the specific rejection case rather than creating new fixtures.

**Why:** Keeps the fixture count small and makes the failure condition explicit in the test body.
