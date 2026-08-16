---
name: graph-2223-update-sdk-readme-md-installation-instructions-to-use-full-path-graph-sdk-link
description: "Ticket memory for GRAPH-2223: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: c6f4c532-7ec8-4fca-89e8-464c3e57b397
---

# GRAPH-2223 — Update SDK README.md installation instructions to use full-path graph-sdk link

**Type:** Story
**Created:** 2026-05-19
**Epic:** none

## Origin
Created to improve the SDK developer onboarding experience. The existing "Installation for SDK developers" section in `README.md` recommends `rush-pnpm link -g @graph/sdk`, which requires a global npm link step. The new approach skips that entirely and has developers invoke the SDK directly via its full path: `node ../graph/packages/graph-sdk/.bin/graph-sdk.js link`.

## Decisions
<!-- Newest first -->

### 2026-05-19 — Created
Documentation-only change to `packages/graph-sdk/README.md`, lines 17–29. Replace the `rush-pnpm link -g @graph/sdk` instruction with the full-path invocation pattern; no code or test changes required.
