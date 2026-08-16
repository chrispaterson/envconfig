---
name: graph-2242-classify-utility-plugins-as-widget-or-node-context-via-new-createutilityplugin-property
description: "Ticket memory for GRAPH-2242: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: f3392f09-f5c9-4c31-b765-1c2e1ab1ae51
---

# GRAPH-2242 — Classify utility plugins as widget or node context via new createUtilityPlugin property

**Type:** Story
**Created:** 2026-05-22
**Epic:** none

## Origin

Created to prevent node plugins (WebWorker, no DOM) from accidentally importing widget-only utility plugins. The three-PR migration approach was chosen to avoid a big-bang breaking change: add optional → annotate all plugins → make required.

## Decisions
<!-- Newest first -->

### 2026-05-22 — initial estimate and scope
Three-PR migration: (1) add optional `context: "widget" | "node"` to `UtilityPluginConfig` in `platform-exports`, (2) annotate all utility plugins in `graph-plugins-core`, (3) make `context` required. Enforcement AC (node plugin importing a widget utility surfaces as an error) is the uncertain piece — implementation approach (graph-sdk validator vs. ESLint rule) must be clarified before starting step 3. Estimated 3.1 pts.
