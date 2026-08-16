---
name: graph-2660-graph-no-pluginconfig-fields-in-manifest-eslint-rule
description: "Ticket memory for GRAPH-2660: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: c98b47d3-9c27-43d5-9462-830a8f6430bc
---

# GRAPH-2660 — graph/no-pluginconfig-fields-in-manifest ESLint rule to flag pluginConfig-only properties in source manifest.json

**Type:** Story
**Created:** 2026-06-22
**Epic:** GRAPH-2601 — Enterprise Ready SDK

## Origin
Created because `extract-plugin.ts` merges pluginConfig and manifest.json with manifest.json winning (`...pluginConfig, ...manifestJson`), meaning a developer who mistakenly puts a pluginConfig-only field (e.g. `displayName`) in their source manifest.json will silently have the correct value from `plugin.ts` overwritten. The Zod schema runs post-merge so it cannot distinguish the origin of each field — a lint rule is required to enforce the contract at authoring time.

## Decisions
<!-- Newest first -->

### 2026-06-22 — Implementation approach
Rule lives in `packages/graph-eslint-plugin`, lints TypeScript files with an adjacent `manifest.json`, and reports at `Program:exit` — identical structural pattern to `no-undeclared-plugin-dependency`. Violations in `manifest.json` are reported against the `Program` node of the adjacent `.ts` file (no JSON linting required). Prohibited field list derived from `docs/plugin-properties.md` (all fields with "—" in the source manifest.json column).
