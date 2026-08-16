---
name: graph-2506-graph-no-undeclared-fetch-source-eslint-rule
description: "Ticket memory for GRAPH-2506: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9dbb973a-d703-4677-8332-fe4be8be28a9
---

# GRAPH-2506 — graph/no-undeclared-fetch-source ESLint rule — enforce fetch origins and Lit src attributes are declared in manifest.json fetchSources

**Type:** Story
**Created:** 2026-06-11
**Epic:** GRAPH-2462 — Dev-time guardrails — development-time plugin constraint enforcement

## Origin
Arose from the same dev-time guardrails conversation as GRAPH-2504. The goal is to catch undeclared network dependencies before submission — both `fetch()` calls and `src` attributes in Lit templates must have their origins listed in `manifest.json`'s `fetchSources` array.

## Decisions
<!-- Newest first -->

### 2026-06-22 — Review redesign: usage-agnostic URL scan + downstream impact
PR #3084. Reviewer rejected the usage-based detection (fetch() arg / Lit `src=`). New approach: scan EVERY string literal + template-literal quasi for absolute `http(s)://` URLs and check each origin against `fetchSources`, regardless of how the URL is used ("if a URL is constructed, it'll be used somewhere"). Catches URLs built indirectly (const, helper, template interpolation). Relative URLs: ignored for now (no protocol+domain). File-suffix exclusion removed (left a comment as future use case).

Key refinement: broadened scan flagged `xmlns="http://www.w3.org/2000/svg"` SVG namespace declarations as false positives. Rule now skips URLs preceded by `xmlns`/`xmlns:prefix=` (namespace URIs are identifiers, not endpoints) but still reports genuine requests to the same host.

Second false-positive class found by linting graph-plugins-core/core-nodes: all 12 errors were `https://github.com/.../lygia/...` source-attribution comments embedded inside GLSL shader source stored as template literals (GLSL uses `//` comments; the shader text is compiled onto the GPU, never fetched). Refined to skip URLs whose line (within the scanned string) has a `//` marker not part of a `://` scheme. After this, **core-nodes lints clean** — all its URL hits were GLSL comments, no manifest changes needed there.

**Final decision (2026-06-22):** rule is REGISTERED but NOT enabled in graph.strict in PR #3084 (deferral comment added, mirroring no-module-scope-vars). Rule skips three non-fetch classes: relative URLs, `xmlns=` namespace URIs, and URLs inside `//` line comments. Two follow-ups created under epic GRAPH-2462:
- **GRAPH-2643** (3.1 pts provisional, component Nodes) — declare manifest.json fetchSources across graph-plugins-core ml-nodes (~154 genuine Firefly/DiArts/Sensei endpoint URLs in utility-diarts/utility-firefly + node-*-generate-* plugins). core-nodes already clean. Blocks GRAPH-2644.
- **GRAPH-2644** (1.1 pts, component SDK) — one-line enable of the rule in graph.strict; blocked by GRAPH-2643. Mirrors GRAPH-2514.

### 2026-06-11 — Implementation approach and key edge cases
Two detection mechanisms: `CallExpression` for `fetch()` with string-literal URL arg, and `TaggedTemplateExpression` + regex on `quasis` for Lit `html` template `src` attributes. URL origin extraction uses `new URL(value).origin` — needs try/catch since it throws on relative URLs (which should be silently skipped). Missing `fetchSources` in manifest.json treated as empty array, consistent with `extract-plugin.ts` default. Add `readFetchSources` helper to `plugin-manifest-utils.ts`.
