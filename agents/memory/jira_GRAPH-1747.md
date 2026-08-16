---
name: GRAPH-1747 — graph-sdk logs Authorization header with bearer token on request failure
description: Ticket memory for GRAPH-1747: decisions, context, and origin notes
type: project
originSessionId: d5e818d4-d706-4c7d-bbca-26284b10038d
---
# GRAPH-1747 — graph-sdk logs Authorization header with bearer token on request failure

**Type:** Bug
**Created:** 2026-04-28
**Epic:** none

## Origin

Security issue: on HTTP request failures, graph-sdk prints the full request details including the `Authorization: Bearer <token>` header. Users copy-paste error output into bug reports and Slack, inadvertently leaking credentials. The fix should redact all `Authorization` header values before any logging or error output.

## Decisions
<!-- Newest first -->

### 2026-04-28 — Bug filed
Auth headers must be redacted (e.g. replaced with `Bearer [REDACTED]`) before appearing in any log, error message, or debug output — even at verbose/debug log levels.
