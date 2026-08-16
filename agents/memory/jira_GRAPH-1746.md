---
name: GRAPH-1746 — graph-sdk install modifies tsconfig.json whitespace formatting
description: Ticket memory for GRAPH-1746: decisions, context, and origin notes
type: project
originSessionId: d5e818d4-d706-4c7d-bbca-26284b10038d
---
# GRAPH-1746 — graph-sdk install modifies tsconfig.json whitespace formatting

**Type:** Bug
**Created:** 2026-04-28
**Epic:** none

## Origin

Observed during normal SDK development: `graph install` rewrites `tsconfig.json` files with whitespace that differs from prettier's expected formatting, causing `rushx lint` to report formatter violations. The install command should write tsconfig output that already conforms to prettier's rules (tabs, trailing newlines, etc.) so no post-install reformatting is needed.

## Decisions
<!-- Newest first -->

### 2026-04-28 — Bug filed
The root cause is likely that the install command serializes JSON with `JSON.stringify` defaults (2-space indent) rather than the tab-indented style that prettier enforces in this repo.
