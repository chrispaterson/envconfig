---
name: jira_GRAPH-1868
description: GRAPH-1868: derive platformVersion from create*Plugin import path in graph-sdk; deprecate manifest.json platformVersion field
type: project
originSessionId: 23439cda-339f-4867-b808-3164bc0ac03b
---
GRAPH-1868: Derive platformVersion from create*Plugin import path in graph-sdk; deprecate manifest.json `platformVersion` field.

**Why:** The import path already encodes the platform version (e.g. `@graph/platform-exports/v1/node-plugin.js` → 1). The `platformVersion` field in manifest.json is redundant. The `no-mismatched-platform-version` ESLint rule was prototyped in GRAPH-1806 but removed in favour of this SDK-level fix.

**How to apply:** Scope is narrow — primarily `extract-plugin.ts` (AST import-path extraction, make `platformVersion` optional in `assertManifestJson` with deprecation warning) plus `docs/plugin-lifecycle.md`. Pattern is known from GRAPH-1806 ESLint `ImportDeclaration` visitor. Phase 3 (removing field from `@graph-services/specs`) is a separate follow-up. Story: 2.1 pts, Sprint 20, relates to Epic GRAPH-1271.
