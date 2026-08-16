---
name: GRAPH-1742 — SDK template eslint.config.mjs extends @graph/eslint-plugin instead of @graph/sdk
description: Ticket memory for GRAPH-1742: decisions, context, and origin notes
type: project
originSessionId: d5e818d4-d706-4c7d-bbca-26284b10038d
---
# GRAPH-1742 — SDK template eslint.config.mjs extends @graph/eslint-plugin instead of @graph/sdk

**Type:** Bug
**Created:** 2026-04-28
**Epic:** none

## Origin

Discovered while reviewing graph-sdk scaffolding output. The template at `packages/graph-sdk/templates/package/eslint.config.mjs` imports `{ graph } from "@graph/eslint-plugin"` directly, requiring consumers to add `@graph/eslint-plugin` as an explicit dependency even though it is not documented as a requirement. The fix is to change the import to `@graph/sdk` so the only peer the consumer needs is `@graph/sdk` itself.

## Decisions
<!-- Newest first -->

### 2026-04-28 — Bug filed
Template should import from `@graph/sdk` rather than `@graph/eslint-plugin` to avoid an undocumented transitive dependency requirement for scaffolded plugin packages.
