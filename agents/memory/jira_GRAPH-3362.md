---
name: graph-3362-move-forplugintype-from-utility-pluginconfig-to-manifest-json
description: "Ticket memory for GRAPH-3362: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7a0a0afb-7db4-4354-8503-7bab7db82ab7
  modified: 2026-07-30T02:08:07.329Z
---

# GRAPH-3362 — Move forPluginType from utility PluginConfig to manifest.json

**Type:** Story
**Created:** 2026-07-29
**Epic:** GRAPH-2601 — Enterprise Ready SDK

## Origin
`forPluginType` currently lives in the utility plugin's `PluginConfig`, which requires statically analyzing the plugin's TypeScript source (extraction) before `install` can pick the right `tsconfig.json`. The old SDK did install+build in one step so this was fine; the new SDK defers extraction until build time, so install can no longer rely on it. Moving `forPluginType` into `manifest.json` lets install read it without invoking TypeScript/the extractor.

## Decisions

### 2026-08-24 — Long-term fix deferred; scoped interim fix chosen instead
Moving `forPluginType` fully into `manifest.json` would require a major version bump in `platform-exports`, which isn't wanted right now — so that migration is deferred, not abandoned. Short-term direction: extract the manifest only for utility plugins (i.e. run the TS extraction step, scoped to just the `utility` plugin type, at install time) so `install()` can read `forPluginType` without needing the full `platform-exports` major bump.

### 2026-07-29 — Created, assigned, sprinted
Filed as a Story under Epic GRAPH-2601, assigned to paterson, added to Graph Sprint 26 (7/27–8/07, sprint id 221356).
