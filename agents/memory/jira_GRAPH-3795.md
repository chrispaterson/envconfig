---
name: jira-graph-3795
description: "GRAPH-3795 - normalize graph-sdk path separators for Windows compatibility; sourced from Adrien Kaiser's Slack patch; Epic GRAPH-2601"
metadata: 
  node_type: memory
  type: project
  originSessionId: ee3e6c8e-407c-4259-8b58-fd6ce9cc75e7
  modified: 2026-08-19T18:35:15.636Z
---

GRAPH-3795: Story to make graph-sdk emit POSIX (forward-slash) path separators consistently, and correctly detect Windows-style absolute paths, so the CLI works on Windows. Epic Link: GRAPH-2601 ("Enterprise Ready SDK"). Added to Graph Sprint 27 (8/10-8/22), assigned to paterson.

**Why:** External contributor Adrien Kaiser (akaiser@adobe.com) reported Windows breakage via Slack (channel C04MN7FQTJN, thread 2026-08-19) and supplied a patch against `@graph/sdk@3.0.5` with three fixes:
1. `pathToFileURL()` before dynamic `import()` in `.bin/graph-sdk.js` — applies cleanly to current main, safe.
2. `path.isAbsolute()` instead of `source.startsWith("/")` in `build-worker.ts`'s `rewritePlatformImportsPlugin` — applies cleanly to current main, safe.
3. POSIX-normalized `tsconfig.json` `paths`/`outDir` generation in `install.ts` — the *actual* POSIX-pathing fix (tsconfig fields must always use forward slashes regardless of host OS), but the patch hunk does NOT apply cleanly to current `install.ts` (refactored since 3.0.5 — no more `existingTsconfig`/`getTSConfig`, dependency list comes from a recursive `getAllDependencies()` walk). The patch also bundles an unrelated change (merging pre-existing tsconfig `paths` back in, switching from resolved recursive deps to raw `manifest.json` deps) that risks reintroducing the stale-path bug fixed in [[jira_GRAPH-1763]] — should NOT be carried over verbatim.

**How to apply:** When implementing, take hunks 1 and 2 near-verbatim; reimplement only the separator-normalization piece of hunk 3 against current `install.ts` (~lines 132, 137, 142: `path.posix.join` for the `paths` values, `.replaceAll(path.sep, path.posix.sep)` on `outDir`). Credit Adrien Kaiser in the PR. Ben Delarre (delarre@adobe.com) is aware and wants this folded into the SDK rebuild in flight.

**Status (2026-08-19): DONE, PR #3441 (draft)** — branch `paterson/GRAPH-3795/fix-graph-sdk-windows-path-separators`. Implemented as: `.bin/graph-sdk.js` wraps `cliPath` in `pathToFileURL(...).href` before dynamic import (matches existing pattern in `get-eslint-override-config-file.ts:166`); `build-worker.ts` swapped `source.startsWith("/")` for `path.win32.isAbsolute(source)` (superset covering POSIX/drive-letter/UNC, host-OS-independent so testable without a real Windows box); `install.ts` switched tsconfig `paths` entries to `path.posix.join` (string values, not real fs paths) and normalized `outDir` via `.replaceAll("\\", "/")` — note: `.split(path.sep).join("/")` (the pattern already used elsewhere in `dev-server.ts`/`build.ts`) is correct in production but **cannot be unit-tested by mocking `path.relative` alone**, since `path.sep` stays `"/"` on a POSIX test runner; `.replaceAll("\\", "/")` avoids that trap. Also found mutating the global `path.sep` in a test breaks memfs (it reads `path.sep` internally) — don't do that. Core-impact check: core-nodes and ml-nodes both Compatible (identical build output before/after; ml-nodes' pre-existing TS2305/TS2353 errors present in both). `graph-cli`/`graph-sdk-common` have the identical `.bin` dynamic-import bug, intentionally left out of scope.
