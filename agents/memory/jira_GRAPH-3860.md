---
name: graph-3860-extract-manifest-for-utility-plugins-only-at-install
description: "Ticket memory for GRAPH-3860: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: e6e6118b-75f9-4641-a5f6-9447f8ce988b
  modified: 2026-08-31T23:19:50.695Z
---

# GRAPH-3860 — Extract manifest for utility plugins only at install time, to unblock forPluginType

**Type:** Story
**Created:** 2026-08-24
**Epic:** GRAPH-2601 — Enterprise Ready SDK

## Origin
Interim fix for the `forPluginType` install-time gap tracked in [[jira_GRAPH-3362]]. The long-term fix (move `forPluginType` out of utility `PluginConfig` into `manifest.json`) is deferred because it would require a major version bump in `platform-exports`, which isn't wanted right now. Instead, `install()` will run TS extraction scoped to just `utility`-type plugins, so `forPluginType` is available before `tsconfig.json` generation — without extracting every plugin (preserving the discovery-time extraction-avoidance behavior GRAPH-2736 relies on for other plugin types).

## Decisions

### 2026-08-24 — Created, assigned, sprinted
Filed as a Story under Epic GRAPH-2601, assigned to paterson, added to Graph Sprint 28 (8/24–9/5, sprint id 224482). Linked "Relates" to GRAPH-3362.

### 2026-08-31 — Implemented as string-match shim; PR #3574
Target is the NEW split SDK (`@graph/plugin-sdk`), not legacy `graph-sdk`. Root cause confirmed live: new-SDK discovery (`findManifestsIn` in `packages/graph-plugin-sdk/src/project-plugins.ts`) reads only `manifest.json`; utility plugins declare `forPluginType` in `plugin.ts` (`UtilityPluginConfig`, still in `platform-exports/v1/utility-plugin.ts`), so `getPluginTSConfig` (`ts-config-utils.ts`) never saw it → DOM utilities got WebWorker libs → TS2304. `SourceManifest.forPluginType` (`graph-sdk-common/src/manifest.ts`) already existed as the destination slot.

Decided (with user) NOT to run a TS parse or call the compiler's `extractPlugin` (compiler is subprocess-only via `pluginExec`; not a static dep of the CLI). Instead: interim **string-match** shim in `install.ts` (`installPlugin`), utility-plugins-only, regex `/forPluginType\s*:\s*["'](node|widget)["']/`, populate `plugin.manifest.forPluginType` before `getPluginTSConfig`. Non-utility/published untouched. **Fatal** (`SDKError`) when `forPluginType` present but non-literal; **missing plugin.ts is non-fatal** (left for build). eslint `require-atomic-updates` disabled with justification (single-exec per plugin via `installedPluginNames` dedupe). Validated regex vs all 10 real core utility plugins. build/lint/test green (217). E2E `/verify-sdk` smoke test NOT yet run (user chose skip-to-PR). Delete shim when [[jira_GRAPH-3362]] lands.
