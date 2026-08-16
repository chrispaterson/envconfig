---
name: graph-2302-graph-sdk-error-on-unknown-fields-in-manifest-json-at-plugin-discovery
description: "Ticket memory for GRAPH-2302: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9be105da-653f-4500-ac78-ea05d1dcc5f9
---

# GRAPH-2302 — graph-sdk: error on unknown fields in manifest.json at plugin discovery

**Type:** Story
**Created:** 2026-06-01
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin

Created to surface typos and misconfigured fields in `manifest.json` at discovery time rather than letting them silently pass through. The field ownership split (manifest.json vs plugin.ts) is documented in `docs/plugin-lifecycle.md` and served as the reference for the allowed set.

## Decisions
<!-- Newest first -->

### 2026-06-12 — Implemented (PR #3041, draft)
Final approach differs from the 2026-06-01 plan: instead of hand-coded key enumeration, used `STRICT_MANIFEST_SCHEMAS` (module-level map of `zManifestEssential.merge(zManifest<Type>).strict()` for all 5 PluginTypes, `satisfies Record<PluginType, unknown>`). Validation runs in `extractPlugin` AFTER `localizeDefinition` (schema needs `displayName`/`description` as `{en-US:...}` objects, which localization produces — incl. nested port/data displayNames via recursive `localizeStrings`). Dev-only `publish`+`forPluginType` stripped via spread+`delete` before `safeParse`. Error reuses submit.ts prefix `Invalid dist manifest.json for plugin <name>:`. KEPT the existing `isPluginName(name, type)` early check — it cross-checks name's embedded type vs declared type, which `zPluginName` does NOT (schema only enforces the char regex, catching underscores). resource branch wired for type-completeness but unreachable via extractPlugin (no createResourcePlugin). Had to fix `project-plugins.test.ts` `makeManifestJson` version `1.0.0`→`1.0` (failed `zPluginVersion` `^\d+\.\d+(-beta|-dev)?$`). Core-impact: ran built extractPlugin over all 438 core-nodes+ml-nodes plugins → 0 failures. zod 4.4.3.

### 2026-06-01 — Implementation approach
Change is inline in `extractPlugin` in `extract-plugin.ts` (~line 463) — no standalone `assertManifestJson` function exists; validation is done in-place. Allowed set: `name`, `version`, `platformVersion`, `type`, `tags`, `dependencies`, `assets`, `fetchSources`, plus `publish` (dev-only submit gate on `InDevPluginManifest` — must be included or plugins using publish control will break).
