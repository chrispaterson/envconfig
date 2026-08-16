---
name: bundling_tsdown_bugs
description: "tsdown bundling of graph-cli/graph-plugin-compiler/graph-eslint-plugin (GRAPH-2736): fixed-hop-count import.meta.url bug class, and deps.alwaysBundle duplicating recursive types when bundled output overwrites a shared lib/. platform-exports specifically does NOT bundle anymore (reverted 2026-08-03) -- it's packed as a tarball instead (closure rooted at platform-exports, not plugin-compiler) since it must stay installable, not merged into another artifact"
metadata:
  node_type: memory
  type: project
  originSessionId: 5fcce13d-69bd-434e-94b4-182dcefc94c4
  modified: 2026-08-03T21:37:26.062Z
---

# tsdown bundling of graph-cli / graph-plugin-compiler

Repo: `migrate-sdk-subcommands-versioned-bundles` (GRAPH-2736 branch). See [[jira_GRAPH-2736_build_parity_bugs]] for the broader build-parity investigation this work is part of.

## What shipped

- Design: `docs/superpowers/specs/2026-07-20-graph-cli-plugin-compiler-bundling-design.md`
- Plan: `docs/superpowers/plans/2026-07-20-graph-cli-plugin-compiler-bundling.md` (local-only, gitignored via `.git/info/exclude`'s `plans/` entry — not in the repo history, only on this machine)
- Both `@adobe/graph-cli` and `@graph/plugin-compiler` now build via `tsdown` (Rolldown) instead of per-file Heft/tsc emit, inlining their `workspace:*` dependencies (`deps.alwaysBundle` in each package's `tsdown.config.ts`) so `graph-cli` can eventually publish to public npm and `plugin-compiler` can ship as a standalone artifact with no proprietary-code leakage.
- `graph-plugin-compiler`'s `build.js`/`lint.js` subprocess entries merged into one `cli.js` with `build`/`lint` subcommands; `@graph/plugin-sdk`'s `pluginExec` updated to match.
- Rush's phased `build` command invokes `_phase:build`, not the plain `build` npm script — both must be kept in sync (already the convention in every other package) or `rush build`/CI silently never runs `tsdown`. Caught this exact regression during Task 6 verification; fixed in the same session.

## The recurring bug class: fixed-hop-count `import.meta.url` path resolution

Multiple modules computed their own package root via a _fixed_ number of `path.dirname()`/`path.join(..., "..", "..")` calls from their own `import.meta.url`, assuming the compiled file always sits at the same relative depth below the package root as the source file did. That assumption silently breaks the moment the module becomes part of a bundle — the final chunk's path (and thus `import.meta.url` at runtime) reflects the _entry point's_ depth, not the original source file's.

Found and fixed twice in this work:

1. `graph-plugin-compiler/src/const/lib-paths.ts` — fixed by deleting it and computing `templatesDir` inside the new merged `src/cli.ts` entry point instead (both `src/cli.ts` and bundled `lib/cli.js` sit exactly one level below the package root, so the hop count is stable there).
2. `graph-plugin-sdk/src/const/sdk-paths.ts` — same pattern, broke once `@graph/plugin-sdk` got bundled _into_ `graph-cli`. Fixed by deleting it and threading `packageTemplateDir`/`pluginsTemplateDir`/`platformLinkRoot` as explicit parameters from `graph-cli/src/index.ts` (same one-level-below-root depth argument).

**Rule of thumb for future bundling work:** before adding any workspace package to a `tsdown` `deps.alwaysBundle` list, grep it for `import.meta.url`/`fileURLToPath` combined with `path.dirname`/`path.join(..., "..")` — that pattern is a latent bug the moment the package stops being installed as its own standalone `lib/` tree. The fix is always the same shape: compute the path once at the actual entry point (which has a depth-symmetry guarantee between source and bundled form) and pass it down as a parameter, rather than letting a shared/nested module derive it from its own location.

## Second bug class: `deps.alwaysBundle` silently duplicates types, breaking recursive/self-referential type consumers when the bundled output overwrites a package's normal `lib/`

Found while adding tsdown bundling to `platform-exports` (a platform-dependency bundle alongside `graph-plugin-compiler` and `graph-eslint-plugin`; `graph-plugin-types` is no longer separately bundled at all — see below).

`platform-exports`'s tsdown config had `@graph/graph-plugin-types` in `deps.alwaysBundle`, with tsdown's `outDir` overwriting the package's own `lib/` — the same `lib/` that `heft build` produces and that every other in-repo `workspace:*` consumer (graph-sdk, graph-plugin-compiler, the real node/widget plugins in graph-plugins-core, ...) resolves types from. Bundling `@graph/graph-plugin-types` into that shared `lib/` inlines both the JS _and_ the type declarations — tsdown's dts step **re-declares** the type rather than re-exporting it via `import type`. For most types this is harmless (duplicated but structurally identical). But `graph-plugin-types/widget-bindings.ts` has a self-referential recursive type (`AnyNodeWidgetBinding` → `TypedNodeWidgetBinding` → `NodeWidgetSlotBindings` → `AnyNodeWidgetBinding` again) built on a branded interface (`OuterPortDefinitionForBinding` with a `__outer: true` marker). Duplicating this recursive type via bundling silently broke assignability for downstream consumers (`@graph/sdk`'s `widget-binding-types.test.ts` failed to build with confusing `__outer` errors) even though the _source_ type definitions were completely unchanged.

Ruled out red herrings before finding this: it looked exactly like a type-system regression from an unrelated merged PR (GRAPH-2816 "repeated slots"), and separately looked like tsdown's multi-entry code-splitting into shared chunks (confirmed NOT the cause — reproduced with a single-entry, non-split build too). The actual cause was purely "is this package's types duplicated via bundling into a `lib/` other consumers also read," confirmed by bisecting with plain `heft build` (no tsdown) vs. the full `heft + tsdown` pipeline.

**First attempted fix (superseded):** exclude `@graph/graph-plugin-types` from `alwaysBundle` on the theory that it's separately available as a sibling platform-dependency bundle at runtime, so it never needed inlining in the first place. This worked, but was fragile — it depended entirely on `graph-plugin-types` staying a separately-distributed sibling, which changed almost immediately (see next paragraph), silently invalidating the fix.

**The actual, general-purpose fix:** the real problem was never _which_ dependency got bundled — it was that the bundled output overwrote the _same_ `lib/` that in-repo `workspace:*` consumers also read. The robust fix is to never let that happen for a package with in-repo consumers: point tsdown's `outDir` at a separate directory (`lib-bundle/`, gitignored, added to `config/rush-project.json`'s `outputFolderNames`) so `heft build`'s plain, unbundled `lib/` is completely untouched and is all any in-repo consumer ever sees. The standalone tarball is then assembled from `lib-bundle/` in a _scratch staging copy_ of the package (not the real package directory) via `common/scripts/create-plugin-sdk-bundle-additive.sh`, which also strips `workspace:*`-versioned deps from the staged `package.json` (they're now inlined, and `pnpm pack` fails outright trying to resolve a workspace-protocol version from a directory that isn't a registered pnpm workspace member) before running `pnpm pack` against the staging directory. With this split, bundling `@graph/graph-plugin-types` (or anything else) into `platform-exports` is completely safe regardless of whether it's separately distributed — no in-repo consumer is ever exposed to the duplicated/bundled copy, so there's nothing for it to conflict with.

**Current architecture (superseding the original plan in this file's own "What shipped" section above):** `graph-plugin-types` is no longer bundled or separately distributed at all. Instead, `platform-exports/src/v1/types.ts` re-exports everything from both `@graph/graph-plugin-types` and `@graph/graph-common-types`, and only `graph-plugin-compiler`, `platform-exports`, and `graph-eslint-plugin` remain in `PLATFORM_DEPENDENCY_LINKS`. `graph-plugin-compiler` and `graph-eslint-plugin` still bundle `@graph/graph-plugin-types` directly (safe for `graph-eslint-plugin` — it only touches plain values/types like `isPluginType`/`PluginTypeMap`, never the recursive widget-binding types) via the direct-overwrite (non-additive) approach, since neither has anywhere near the number of in-repo consumers `platform-exports` does and neither hits the recursive-type case. `platform-exports` is the one package that needed the additive/separate-`lib/`-output treatment.

## 2026-07-31: platform-exports tsdown bundling actually shipped, after two same-day reverts of a different (non-tsdown) approach

Earlier the same day, a tarball/closure-based bundling approach (`common/scripts/pack-platform-tarball.mjs`,
`platform-closure.mjs`, moving `lit`/`@lit-labs/signals`/`@lit/context` into real `dependencies`) was
tried for the whole `@graph/*` platform closure and fully reverted twice (`b3ab3b291`, `052c50cde`).
The revert left two things broken that were unrelated to bundling and had to be fixed first:

1. `graph-plugin-compiler`/`graph-sdk-common`'s build scripts still called the now-deleted
   `pack-platform-tarball.mjs` (dangling reference, `rushx build` failed outright).
2. `platform-exports` itself had `lit`/`@lit-labs/signals`/`@lit/context` left in
   `peerDependencies` only, with no matching `devDependencies` entries — broke its own
   `heft build` (tsc couldn't resolve the modules for its own compile step). Fixed by adding
   matching `devDependencies` entries, mirroring the existing `eslint` peer+dev pattern already
   used in `graph-plugin-compiler`.
3. Separately (deeper, NOT fixed — see [[jira_GRAPH-2736_platform_version_regression]]): the same
   revert commit also deleted `graph-plugin-types/src/platform-version.ts`, unrelated business
   logic, breaking `graph-sdk`'s build. Flagged to paterson rather than guessed at.

After that cleanup, `platform-exports` got its own `tsdown.config.ts` (this time using tsdown,
not the tarball approach): `outDir: "lib-bundle"` (additive, separate from heft's `lib/` — applying
the lesson from the recursive-type bug above, re-verified still live since `graph-plugin-types`'
`AnyNodeWidgetBinding` recursive type is still present), `platform: "neutral"`, `sourcemap: "inline"`
(literally inlined as base64 data URI, not a sibling `.map` file), `dts: true`, and
`deps.alwaysBundle` naming only the 4 in-repo `@graph/*` deps (`graph-common-types`, `graph-icons`,
`graph-plugin-types`, `resources`) — peerDependencies (lit, spectrum-web-components, babylonjs,
mediabunny) stay external automatically since tsdown only force-bundles what `alwaysBundle` names.
`lib-bundle/` added to `.gitignore` and `config/rush-project.json`'s `outputFolderNames`.

`rush update` also unexpectedly hard-aborts (exit 1, `AlreadyReportedError` from
`VersionMismatchFinder.ensureConsistentVersions`) if _any_ pre-existing cross-package version-specifier
mismatch exists anywhere in the repo, even completely unrelated ones — `--bypass-policy` does NOT
bypass this (that flag only covers `gitPolicy`, a different check). Found 3 pre-existing mismatches
(`@bomb.sh/tab`, `semver`, `@types/semver` between `@graph/sdk`'s `~`-range specifiers and
`graph-cli`/`graph-plugin-compiler`'s exact pins) blocking the update needed to add `tsdown` as a
platform-exports devDependency; fixed by aligning `@graph/sdk` to the exact-pin specifiers.
Do **not** try to route around this with `rush-pnpm --rush-skip-checks install` — it uses
`autoInstallPeers: true` (vs. rush's normal `false`) and pollutes the temp lockfile with spurious
top-level peerDependency entries that diverge from the canonical `common/config/rush/pnpm-lock.yaml`.

## 2026-08-03: the platform-exports tsdown bundling above was reverted again — final answer is "pack, don't bundle"

The `platform-exports` tsdown bundling described in the section above (lib-bundle/, `dts: true`,
`sourcemap: "inline"`, `deps.alwaysBundle` for the 4 in-repo deps) shipped and then, in the very
next session, paterson reverted it: "I forgot this has to be an installable package, so we need to
pack it... I don't think we need to bundle it after all." The tsdown.config.ts, its devDependency,
and the `lib-bundle` output-folder wiring were all removed; the only part kept was the unrelated
fix that had to happen alongside it (adding `lit`/`@lit-labs/signals`/`@lit/context` as
`devDependencies` so `platform-exports`'s own `heft build` can resolve them for its own
type-checking — those stay peerDependencies for real consumers, but a package needs its own peer
deps as devDependencies too if its own build imports them, same pattern as `eslint` in
`graph-plugin-compiler`).

**Why bundling was the wrong call here:** per `docs/graph-cli-sdk-split-architecture.md` and
`docs/superpowers/specs/2026-07-20-graph-cli-plugin-compiler-bundling-design.md`, `platform-exports`
is proprietary and can never be published to public npm — but plugin authors' own `plugin.ts` source
imports it directly by name (`@graph/platform-exports/widget-plugin.js`, confirmed in
`plugins/test-plugins/package.json`), so their own local `tsc` needs it resolvable as a real
installed package, not merged into some other artifact. That's a distribution problem (get an
installable tarball to plugin authors without touching public npm), not a bundling problem — hence
"pack it" (`pnpm pack` → tarball, fetched later by `graph install` from Graph Services per
[[jira_GRAPH-2467]], not yet wired) rather than "bundle it" (inline deps into one file, which is
what `@graph/plugin-compiler`'s *own*, separate, already-designed tsdown bundling does for its own
internal use — unrelated to this).

**The actual root cause of the original (`b3ab3b291`/`052c50cde`) revert, finally identified:** the
deleted `platform-closure.mjs` computed its `@graph/*` closure rooted at `@graph/plugin-compiler`
(10 packages, including `@graph/eslint-plugin` and `@graph/sdk-common` — CLI/lint tooling with
unrelated npm deps like `@typescript-eslint/utils`, `chalk`, `cli-spinners`). That's why the earlier
"pack the whole closure" attempt felt bloated with "seemingly unrelated libraries." Rooting the
closure at `@graph/platform-exports` instead yields exactly 7 packages, all genuinely
runtime-relevant: `platform-exports`, `graph-common-types`, `graph-icons`, `graph-plugin-types`,
`resources`, `cache`, `logging` — pulling only `idb`, `signal-polyfill`, `signal-utils`,
`@logtape/logtape`, `@graph-services/specs` as real npm deps.

**What shipped instead (2026-08-03, via subagent-driven-development on
`docs/superpowers/plans/2026-08-03-platform-exports-pack-pipeline.md`):** revived
`common/scripts/platform-closure.mjs` (root fixed to `@graph/platform-exports`) and
`common/scripts/pack-platform-tarball.mjs` (unchanged generic `rush-pnpm pack --pack-destination
dist` wrapper), wired into all 7 closure packages' `_phase:build`/`build` scripts. No tsdown, no
bundling, no `lib-bundle`. Each package now produces its own `dist/<name>-<version>.tgz` on build.
Caught one process bug in the fix loop: an implementer subagent's `git add
packages/platform-exports/package.json` (whole-file stage) accidentally swept unrelated
already-uncommitted `lit`/`@lit-labs/signals`/`@lit/context` devDependency lines into its commit —
worth remembering that "stage only the exact task files" instructions need per-hunk staging
(`git add -p`) when a file has both in-scope and out-of-scope uncommitted changes, not just a
file-path allowlist.

Explicitly out of scope for this pass (separate, partly backend-blocked effort): wiring
`graph-sdk`/`graph install` to actually fetch and consume these tarballs. See [[jira_GRAPH-2467]].

## Testing note

`ProgressLogger` (`graph-sdk-common/src/progress-logger.ts`) silently no-ops all output (`.log`/`.success`/`.fail`) when `process.stdout.isTTY` is false, so piped/redirected `graph` command runs show zero error output on failure (just exit 1). Use `script -q /tmp/out.txt <command>` (macOS) to force a pseudo-TTY when debugging a silent failure. Pre-existing, unrelated to bundling, but real — worth its own fix.
