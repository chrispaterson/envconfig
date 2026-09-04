---
name: graph-3159-add-sdk-license-text-to-built-sdk-artifacts
description: "GRAPH-3159 SHIPPED (draft PR #3586): Adobe SDK license-grant banner on @adobe/graph-cli built output via tsdown banner + --config-loader unrun"
metadata: 
  node_type: memory
  type: project
  originSessionId: e9182b6e-01ce-427e-897c-180f3e9edd11
  modified: 2026-09-01T19:03:45.070Z
---

# GRAPH-3159 — Add SDK license text to built SDK artifacts

**Type:** Story
**Created:** 2026-07-23
**Epic:** GRAPH-2601 — Enterprise Ready SDK
**Retitled/rescoped by user on 2026-07-27** (was "Remove ADOBE CONFIDENTIAL headers from SDK-distributed code; enforce SDK license header instead").

## Origin
Split out from GRAPH-3158 (the `graph/copyright-header` ESLint rule) after wiki research surfaced that Adobe Legal's `legalwiki` "Copyright Notices for Source Code" page mandates two distinct header templates — `Source-Code.pdf` (internal, "ADOBE CONFIDENTIAL") and `SDK-Source-Code.pdf` (public/distributed, license-grant text, no confidentiality marking) — and that publicly distributed code must use the latter.

## Current scope (as of 2026-07-27)
AC now reads: files bundled/distributed as part of the published Graph SDK carry the Adobe SDK license-grant text (per `SDK-Source-Code.pdf`), preserving the first-creation copyright year. The "built/distributed artifacts" framing means this targets the SDK's **build output**, not the raw repo `src` files — a deliberate narrowing from the original scope (see below).

## Decisions

### 2026-07-23 — Scope target identified as packages/graph-sdk
Repo research (via Explore agent) confirmed `packages/graph-sdk` (`@graph/sdk`) is the package whose raw `src` is published and consumed by external plugin developers — ~92 `.ts` files carried the ADOBE CONFIDENTIAL header there at the time. `graph-plugin-types` and `platform-exports` are also directly installed by external plugin developers per SDK install docs but were left as an open flag, not yet confirmed in/out of scope.

### 2026-07-23 — Storypointed at 2.1
AI initial read was 3.1 (parameterizing the existing hardcoded rule + new config override). User corrected to 2.1: same class of work as GRAPH-3158 itself (which was corrected 3.1→2.1) — extending an already-built rule with an options schema plus a second `files:`-scoped block is incremental, and the 92-file migration is fully autofix-driven so file count doesn't add real effort/risk. **Note:** this estimate was made against the *original* (raw-`src`) scope; re-verify against the built-artifacts scope before relying on it.

### 2026-07-27 — Confirmed no overlap with GRAPH-3264
[[jira_GRAPH-3264]] (short-form `// © YYYY Adobe...` header, token-cost driven) migrated `packages/graph-sdk/src` along with the rest of the repo to the short-form header — that's a source-level, repo-wide convention change. This ticket's rescoped AC is about the SDK's *built/distributed artifacts* carrying the separate Legal-mandated SDK license-grant text — a different layer (build output vs. source) and a different reason (Legal compliance vs. token cost). User confirmed directly: no real overlap. See [[adobe_copyright_header_policy.md]].

## IMPLEMENTATION — SHIPPED 2026-09-01 (draft PR #3586)

**Final scope decision (user, 2026-09-01):** target **only `@adobe/graph-cli`** (the npm-published CLI) — NOT the other 3 SDK packages, NOT platform-exports/plugin-types, NOT legacy graph-sdk. Single **fixed copyright year 2023** (earliest commit / first-creation), NOT per-file git year. **The 2.1 storypoint estimate and the "packages/graph-sdk raw-src ESLint override" plan above are STALE** — final impl is a build-output banner on graph-cli only. Branch `paterson/GRAPH-3159/sdk-license-header-artifacts`.

**Mechanism:** `packages/graph-cli/src/sdk-license-banner.ts` exports `SDK_LICENSE_BANNER` (`/*! Copyright 2023 Adobe. All Rights Reserved. … Adobe permits you to use, modify, and distribute this file in accordance with the terms of the Adobe license agreement accompanying it. */`, verbatim AC sentence). `tsdown.config.ts` sets `banner: SDK_LICENSE_BANNER`. graph-cli tsconfig is `noEmit:true`, so heft emits nothing — the whole `lib/` is just tsdown's bundled `lib/index.js`(+map), no shebang; banner becomes the file header.

**KEY GOTCHA — `tsdown --config-loader unrun`:** importing a `src/*.ts` module INTO `tsdown.config.ts` fails with tsdown's default config loader ("Cannot find module …sdk-license-banner / Try setting --config-loader to unrun") because it resolves the `.js` specifier literally and no compiled `.js` exists under `noEmit`. Fix: build scripts (`build`, `_phase:build`, `build:watch`) pass `tsdown --config-loader unrun`. Applies to any future SDK config that imports shared TS.

**Test gotcha:** graph-cli `vitest.setup.ts` does `vi.mock("node:fs", …)` with **memfs** — a unit test CANNOT `readFileSync` real build output (ENOENT). So the test asserts the exported constant, not the built file.

**ESLint trap:** `graph/copyright-header` auto-STRIPS any block comment containing the literal `ADOBE CONFIDENTIAL` (treats it as a legacy header). Comments explaining this work must reword to "internal confidential-source block". String literals / test titles are exempt (rule inspects comments only).

**Impact:** Compatible for graph-plugins-core (CLI app changed, consumed as binary, no `@graph/*` library API surface; bundle functionally identical apart from leading comment). rush change type = `patch`.
