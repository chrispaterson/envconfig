---
name: GRAPH-1519 — Integration tests: install remote dependency resolution failure cases
description: Ticket memory for GRAPH-1519; covers GET /plugins.resolve 404 and auth failure cases during graph-sdk install
type: project
originSessionId: 87f6cad0-a9ae-4508-a805-a8a29318c433
---
# GRAPH-1519 — Integration tests: install remote dependency resolution failure cases

**Type:** Story
**Created:** 2026-04-14
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created as part of a coverage gap analysis. `graph-sdk install` calls `GET /plugins.resolve` for remote dependencies. The happy path is tested but three failure modes are not: non-existent dep (404), non-Available dep (404 — registry hides non-Available plugins), and auth failure (401/403).

## Decisions

### 2026-04-14 — Non-Available fixture needs staging coordination
The "dep exists but is in PendingReview" case requires a fixture plugin permanently in that state on staging. Flag as a dependency during sprint planning — needs team coordination before dev-complete.

**Why:** Cannot reliably reproduce this state in-test without either admin access or a coordinated fixture.

### 2026-04-14 — Depends on GRAPH-1516
Reuse the `withBadToken()` helper from GRAPH-1516 for the auth failure case.
