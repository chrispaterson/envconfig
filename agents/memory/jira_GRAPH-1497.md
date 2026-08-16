---
name: GRAPH-1497 — Fix dev command default graph URL to use production firefly.adobe.com endpoint
description: Ticket memory for GRAPH-1497: decisions, context, and origin notes
type: project
originSessionId: eacef0f1-96b5-4e53-a456-bbf566e8af65
---
# GRAPH-1497 — Fix dev command default graph URL to use production firefly.adobe.com endpoint

**Type:** Story
**Created:** 2026-04-13
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin
The `devCommand` in `packages/graph-sdk/src/commands/dev.ts:101` falls back to `http://graph.corp.adobe.com/graph/edit` when no `--graphUrl` flag is passed. This is an internal corp URL rather than the production firefly.adobe.com endpoint, so the printed "open Graph in dev mode" link is wrong for external plugin developers. Created as part of the GRAPH-1271 SDK DX improvements epic.

## Decisions
<!-- Newest first -->

### 2026-04-13 — Initial creation
Single-line fix: update the default `graphUrl` fallback on `dev.ts:101` to the correct production `firefly.adobe.com` URL. The exact URL path needs to be confirmed before implementation.
