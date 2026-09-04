---
name: jira-graph-4046
description: "GRAPH-4046 Node 22→24 floor bump; @types/node@24 breaks app tree (esnext.iterator vs signal-utils); NOT settled — recommend deferring the @types/node@24 bump; PR #3606"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7853c301-0389-4a3c-ab05-aa159d902c17
  modified: 2026-09-04T18:18:19.048Z
---

GRAPH-4046 (Sprint 28): raise minimum Node.js 22→24 for the SDK/CLI + docs. Monorepo PR **#3606** (draft) opened 2026-09-02.

**What landed (graph monorepo):** `.nvmrc` 22→24; `rush.json` nodeSupportedVersionRange `>=24.0.0 <25.0.0`; CI `node-version "22"→"24"` (release-deploy.yml + `setup-repo`/`generate-llm-release-notes` composite actions; build.yml inherits from `.nvmrc`). `@graph/sdk` (packages/graph-sdk) + `@adobe/graph-cli` (packages/graph-cli): add `engines.node >=24.0.0`, bump `@types/node`→24.13.3.

**ROOT CAUSE (refined):** `@types/node@24` pulls in the newer **`esnext.iterator`** TS lib (via `/// <reference lib>`), which makes built-in Map/Set iterators the strict `MapIterator`/`SetIterator` requiring `[Symbol.dispose]`. `signal-utils@0.21.1` (latest; used by ~10 app pkgs via graph-common-types `readonly-signals.ts` → `ReadonlySignalMap`/`ReadonlySignalSet`) declares its iterators as plain `IterableIterator` → no longer satisfy ReadonlyMap/Set → `@graph/graph-document` (+ app tree, all TS 5.8.3) fail to compile. **Why main is green:** `@types/node@22` provides `esnext.disposable` (needed for the repo's `using`/`Symbol.dispose` usage) WITHOUT the strict `esnext.iterator` lib; the 24.x line bundles both. The app tree gets disposable *accidentally* via `@types/node` leaking through test tooling (vitest→vite `.d.ts` carries `/// <reference types="node" />`; pnpm resolves that peer to the max = 24 once 24 exists).

**Landmine:** `ensureConsistentVersions:true` (common-versions.json, NOT rush.json) forces one `@types/node` repo-wide — a 2-package bump blocks `rush update` at the version-mismatch check unless 24.13.3 is added to `allowedAlternativeVersions`.

**Options (as of 2026-09-04 — NOT settled):**
1. **Defer the @types/node@24 bump (RECOMMENDED).** Ship the Node-24 floor + `engines.node>=24` on the 2 CLI pkgs; keep `@types/node@22` repo-wide. Zero cascade, main stays green. The 24.x types line is the sole trigger; front-end doesn't need it.
2. **pnpm patch signal-utils** (`common/pnpm-patches/signal-utils@0.21.1.patch`, iterator types → MapIterator/SetIterator; register in pnpm-config.json `globalPatchedDependencies` with path `../pnpm-patches/...` — resolved relative to `common/temp`, NOT repo root). Type-only, full build+tests green. User disliked patching a dep.
3. **Separate tests from lib build** ("Node types out of front-end"): cascades into an epic — app tree gets `esnext.disposable` only via the leak (removing it breaks cache/resources until each declares the lib); `@graph/resources` prod generics depend on `ResourceTypeMap` augmentations that live ONLY in its test files (excluding tests → `ResourceTypeKey=never`, 16 errors); replacement test-typecheck re-pulls node@24 (tests import src). Out of scope for a version bump. NOT pursued.

User said "let's not do this work right now"; full root-cause writeup posted as a GRAPH-4046 comment 2026-09-04. PR #3606 draft currently reflects option 2.

**Still outstanding (separate targets, noted on ticket):** `AdobeDocs/firefly-graph` public repo (3 "Node.js v22 or later" lines: src/pages/index.md, guides/index.md, guides/creating-plugins/index.md — needs `chrispaterson` gh account for the PR, see [[reference_adobedocs_gh_account]]); Confluence Plugin Guide 3769393821 + CLI Reference 3769909643 (wiki PAT was 401 at handoff).

Handoff attachment (`node24-bump-handoff.md`) assumed a pre-split 2-package world and did NOT anticipate the ensureConsistentVersions/signal-utils cascade. Relates [[terminology_the_sdk]].
