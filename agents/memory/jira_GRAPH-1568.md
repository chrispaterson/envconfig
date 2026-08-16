---
name: GRAPH-1568 — Include plugin name in graph-sdk debug log messages
description: Ticket memory for GRAPH-1568: decisions, context, and origin notes
type: project
---

# GRAPH-1568 — Include plugin name in graph-sdk debug log messages

**Type:** Story
**Created:** 2026-04-17
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin

Created from `/createjira Story` request: improve graph-sdk debug logging so messages include the originating plugin name; parent Epic GRAPH-1271; intentionally left unassigned and not added to the current sprint.

## Decisions

### 2026-04-17 — Story points set to 1.1
After reviewing `packages/graph-sdk/src/commands/dev.ts`, estimate revised from 3.1 proposal to **1.1** (team-confirmed AI estimate). Jira updated; description tightened so AC matches “enrich existing debug calls where plugin is already in scope,” not an SDK-wide logging redesign.

### 2026-04-17 — Ticket creation
Scope captured in Jira: plugin-attributed debug output when debug logging is enabled, without losing clarity for core vs plugin messages.
