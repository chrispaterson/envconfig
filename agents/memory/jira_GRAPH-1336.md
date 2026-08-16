---
name: GRAPH-1336 — Extract common integration test utilities across graph-sdk integration tests
description: Ticket memory for GRAPH-1336: decisions, context, and origin notes
type: project
---

# GRAPH-1336 — Extract common integration test utilities across graph-sdk integration tests

**Type:** Story
**Created:** 2026-04-06
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created to eliminate duplicated setup code across the five command-specific integration test stories (GRAPH-1265, GRAPH-1266, GRAPH-1269, GRAPH-1270, GRAPH-1335). Intentionally blocked by all five so patterns can be identified empirically before extraction, rather than designing utilities upfront.

## Decisions

### 2026-04-06 — Defer until all blockers complete
Do not start this story until all 5 blockers are done — the shared patterns (path accessors, temp project setup) should emerge from real code, not be speculated. The existing `copyFixture` utility from GRAPH-1264 may already cover much of the scope; review it first before writing new utilities.
