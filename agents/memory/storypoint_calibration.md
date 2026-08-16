---
name: storypoint_calibration
description: Story point calibration log — corrections to AI estimates with reasoning. Read before estimating; append after user corrections.
type: reference
originSessionId: 53059087-1bf5-4c87-a2d8-2788ee35ce74
modified: 2026-07-23T17:36:19.792Z
---
# Story Point Calibration Log

Each entry records a case where the user corrected an AI estimate. Claude reads this log before estimating to detect recurring patterns and apply adjustments.

## How to use this log

Before estimating, scan for:
- **Directional bias**: Am I consistently under/over-estimating for certain factor combinations?
- **Factor-specific patterns**: Which complexity factors do I most often get wrong?
- **Component patterns**: Are corrections clustered around a specific package or area (e.g. SDK, e2e tests)?

Surface any detected patterns explicitly in the estimate under a "Calibration adjustments" line.

## How to append entries

After the user confirms a corrected value, append a row to the table below:

| Date | Issue | AI Estimate | Final | Delta | Factor(s) | Reason |
|------|-------|-------------|-------|-------|-----------|--------|

Columns:
- **Delta**: signed Fibonacci step change (e.g. `+1`, `-1`, `+2`)
- **Factor(s)**: the complexity factor(s) most relevant to the correction (scope-clarity, technical-breadth, unknowns, dependencies, risk, testing-effort)
- **Reason**: the user's explanation, verbatim or paraphrased

## Calibration entries

| Date | Issue | AI Estimate | Final | Delta | Factor(s) | Reason |
|------|-------|-------------|-------|-------|-----------|--------|
| 2026-03-31 | GRAPH-998 | 3.1 | 2.1 | -1 | technical-breadth | No external consumers of GraphService outside the monorepo; compiler finds all call sites, making this purely mechanical |
| 2026-04-01 | GRAPH-1264 | 5.1 | 3.1 | -1 | scope-clarity | Dropped MSW mock server (6 intercepted routes) in favour of real credentials; remaining scope is just vitest config, fixture utility, and token env var handling |
| 2026-04-03 | GRAPH-1314 | 5.1 | 3.1 | -1 | technical-breadth | Wiring into 6 commands is mechanical (1-2 lines each); resolve-plugin-args.ts is the only real work |
| 2026-04-03 | GRAPH-1315 | 5.1 | 2.1 | -2 | scope-clarity, technical-breadth | Help menus split into separate story (GRAPH-1318); remaining work is purely mechanical code movement — copy/paste from cli.ts into factory functions, no new logic |
| 2026-04-06 | GRAPH-1336 | 3.1 | 2.1 | -1 | technical-breadth | Technical breadth only matters when new concepts are introduced across boundaries, not simply because many files are touched; touching 5 test files in one package with no new logic is not breadth |
| 2026-04-16 | GRAPH-1550 | 2.1 | 1.1 | -1 | technical-breadth, scope-clarity | One-line change (adding a path to existing paths); as easy as it gets |
| 2026-04-29 | GRAPH-1761 | 5.1 | 3.1 | -2 | risk | Validation is additive and only fires for already-misconfigured plugins; graph-services enforces the same rules at submission time so any in-flight project is already known-good — practical blast radius is near zero |
| 2026-04-29 | GRAPH-1769 | 3.1 | 2.1 | -1 | technical-breadth | Logging-only change with no functional impact; even lighter than mechanical wiring — just adding a log call, no new logic or state |
| 2026-05-01 | GRAPH-1806 | 5.1 | 3.1 | -2 | unknowns | ESLint rule authoring is a well-established framework with known patterns and good tooling (RuleTester, AST selectors); feasibility is certain so unknowns should have been rated none, not some |
| 2026-05-14 | GRAPH-2158 | 2.1 | 1.1 | -1 | unknowns | Pure version bump; flagging potential type errors was over-caution — a version bump with no logic change is always 1 point regardless of import site count |
| 2026-05-27 | GRAPH-2260 | 1.1 | 2.1 | +1 | technical-breadth, unknowns | graph-core-plugins is an external repo with hundreds of plugins; TypeScript errors from the bumps must be resolved manually across all consumers — not a 1-point bump |
| 2026-07-22 | GRAPH-3158 | 3.1 | 2.1 | -1 | scope-clarity, technical-breadth | Copyright-header ESLint rule with autofix, direct port of an existing Horizon reference implementation into tools/eslint-plugin-graph (4 existing rules, same createRule+RuleTester pattern); one rule file plus one config registration, applied globally (no per-package scoping decision needed) — clear scope and minimal risk, closer to 2 than 3 |
| 2026-07-23 | GRAPH-3159 | 3.1 | 2.1 | -1 | technical-breadth | Same class of work as GRAPH-3158: adding an options schema to the existing rule plus a second files:-scoped config block is incremental on top of a rule that already exists, not meaningfully harder than the original port; the ~92-file migration is fully autofix-driven so file count doesn't add real effort/risk |
