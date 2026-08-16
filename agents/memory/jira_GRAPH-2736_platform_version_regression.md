---
name: jira-graph-2736-platform-version-regression
description: "GRAPH-2736 branch: 2026-07-31 'revert bundling approach' commit (b3ab3b291) deleted graph-plugin-types/src/platform-version.ts, breaking graph-sdk + graph-plugin-services-client builds -- FIXED 2026-08-03 by porting PlatformMajorVersion/resolvePlatformVersion back from the GRAPH-3361 worktree; rush build now clean repo-wide"
metadata:
  node_type: memory
  type: project
  modified: 2026-08-03T23:27:10.069Z
  originSessionId: e6d3772c-7f7d-4a20-9803-ee5e1540afcc
---

# graph-sdk build broken by over-scoped revert (2026-07-31)

Repo: `migrate-sdk-subcommands-versioned-bundles` (GRAPH-2736 branch). Discovered while
implementing tsdown bundling for `platform-exports` (see [[bundling_tsdown_bugs]]) and
verifying downstream consumers still build.

## What's broken

`rushx build` in `packages/graph-sdk` fails with 5 `TS2724` errors — `make-docs.ts`,
`submit.ts`, `project-plugins.ts`, and `platform-version.test.ts` all import
`resolvePlatformVersion` and `PlatformMajorVersion` from
`@graph/graph-plugin-types/platform-version.js`, but that module no longer exports them
(only `isPlatformVersion` remains).

## Root cause

Commit `b3ab3b291` ("revert bundling approach", 2026-07-31 17:39) — part of reverting an
abandoned tarball/closure-based bundling experiment for the `@graph/*` platform
dependency closure — **also deleted** `packages/graph-plugin-types/src/platform-version.ts`
(41 lines) in the same commit. That file's `resolvePlatformVersion`/`PlatformMajorVersion`
exports are unrelated to bundling; they're real business logic that `graph-sdk` depends on
for platform-major-version resolution (the same area as [[jira_GRAPH-3361]] /
[[jira_GRAPH-3363]]). The revert appears to have swept in an unrelated file deletion,
likely because the two changes were commingled in the working tree before the revert was
committed.

Two related build-script breaks from the _same_ revert pair were also found and fixed in
this session (unrelated to platform-version.ts, purely mechanical):

- `graph-plugin-compiler` and `graph-sdk-common`'s `_phase:build`/`build` scripts still
  called the now-deleted `common/scripts/pack-platform-tarball.mjs` — fixed by dropping
  the dangling call.
- `platform-exports`'s own `lit`/`@lit-labs/signals`/`@lit/context` moved from
  `dependencies` to `peerDependencies` with no matching `devDependencies` entries, breaking
  its own `heft build` (tsc couldn't resolve the modules for its own compilation) — fixed
  by adding matching `devDependencies` entries (mirrors the existing `eslint` peer+dev
  pattern in `graph-plugin-compiler`).

## Fixed (2026-08-03)

Also broke a 6th consumer discovered later: `packages/graph-plugin-services-client/src/plugin-service.ts`
(imports `PlatformMajorVersion`) — same root cause, found when paterson ran `rush build` directly.

paterson had a separate agent session partially port `platform-version.ts` back from a sibling
worktree, `/Users/paterson/projects/adobe/project-graph/GRAPH-3361/fix-datatype-plugin-platform-version`
(the actual GRAPH-3361 branch doing platform-major-only dependency resolution work) — but that port
only copied `PlatformVersion`/`ManifestPlatformVersion`/`isPlatformVersion`/`normalizePlatformVersion`,
missing the `PlatformMajorVersion` interface and `resolvePlatformVersion` function, so the build
stayed broken. Completed the port by copying those two pieces verbatim from the reference worktree
(confirmed byte-identical intent via its TSDoc). All usage sites across the repo already matched this
exact API shape (no call-site changes needed) — the export was the only gap.

Verified clean after the fix: `graph-plugin-types`, `graph-sdk`, `graph-plugin-services-client`, and
`graph-plugin-sdk` all build+lint+test clean, and a full repo-wide `rush build` succeeds (43
packages, only pre-existing cosmetic `NPM_AUTH_CLOUD` env-interpolation warnings on the
[[bundling_tsdown_bugs]] pack-pipeline packages, not build failures).

**Lesson:** when porting a file back from a reference branch/worktree after an over-scoped revert,
diff the full file against the reference rather than trusting a partial restoration looks complete —
the missing tail (`PlatformMajorVersion` + `resolvePlatformVersion`) wasn't obvious from a build error
naming only one missing symbol at a time (`graph-sdk`'s error mentioned `resolvePlatformVersion`
first; `graph-plugin-services-client`'s mentioned only `PlatformMajorVersion` since it doesn't import
the other symbol) — the two errors were the same underlying gap, discovered piecemeal instead of at
once, since not every consumer of the file happened to build in the same session.
