---
name: GRAPH-1472 — Add submit command integration tests
description: Ticket memory for GRAPH-1472: decisions, context, and origin notes
type: project
originSessionId: e4bfbe1e-605b-40c1-9212-974a7b030524
---
# GRAPH-1472 — Add submit command integration tests

**Type:** Story
**Created:** 2026-04-09
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created to extend the GRAPH-1263 integration test suite to cover the `submit` command. All other major graph-sdk commands (build, lint, dev, install) now have or are getting integration tests; submit was the remaining gap. The submit command touches real S3 uploads, plugin service state transitions, and source hash validation — behavior that unit tests mock away.

## Decisions
<!-- Newest first -->

### 2026-04-09 — Use @test namespace for staging submissions
The plugin service has built-in support for plugins in the `@test` namespace, intended for exactly this kind of integration test. Use a `@test` fixture plugin rather than coordinating with the team for a dedicated staging plugin. This resolves the main unknown flagged in the original estimate.
