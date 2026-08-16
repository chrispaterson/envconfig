---
name: GRAPH-1761 — Add pre-submission manifest validation to graph-sdk
description: Ticket memory for GRAPH-1761: decisions, context, and origin notes
type: project
originSessionId: 53059087-1bf5-4c87-a2d8-2788ee35ce74
---
# GRAPH-1761 — Add pre-submission manifest validation to graph-sdk

**Type:** Story
**Created:** 2026-04-29
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin
Emerged from a coworker review of `graph-services/services/api/src/controllers/plugins.ts`. The server enforces wick naming, dependency completeness, and changelog length at POST /plugins time; the SDK had no equivalent checks, so developers only discovered errors after a full API round-trip. Plan was iterated in conversation before the ticket was filed.

## Decisions
<!-- Newest first -->

### 2026-04-29 — Implementation approach finalised
`assertIsInDevPluginManifest` assertion function added to `extract-plugin.ts`, called on the `merged` object before `localizeDefinition` — catches errors at discovery time across all commands. Changelog length validation (10–500 chars) added to `getChangelogAndUpdateType` in `submit.ts`. No zod in the SDK; wick check uses a local regex constant (`/^@adobe\/datatype-wick-[a-z0-9-]{1,20}$/`). Implementation plan attached to ticket.
