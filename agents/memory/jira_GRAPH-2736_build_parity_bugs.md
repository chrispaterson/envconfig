---
name: graph-2736-build-parity-bugs
description: "Bugs found comparing graph-sdk vs new graph-cli build output on graph-plugins-core (GRAPH-2736 SDK split); Bugs 1 and 3 fixed+committed; discovery skipping extractPlugin() is intentional, not a bug"
metadata: 
  node_type: memory
  type: project
  originSessionId: 99977699-8e91-4a40-9141-afd37bfbc175
  modified: 2026-07-30T02:08:39.049Z
---

# GRAPH-2736 — graph-cli vs graph-sdk build parity bugs

Branch: `paterson/GRAPH-2736/migrate-sdk-subcommands-versioned-bundles`. Found while verifying that `graph build` (new split CLI stack: `@adobe/graph-cli` → `@graph/plugin-sdk` → `@graph/plugin-compiler`) produces the same output as legacy `graph-sdk build` for `graph-plugins-core/core-nodes` (427 plugins) and `ml-nodes`.

See also [[bundling_tsdown_bugs]] for the tsdown-bundling-specific bug class (Bug 3 below) found while smoke-testing the bundled `graph-cli`/`graph-plugin-compiler` against `ml-nodes`.

## Bug 1 — distDir leaked a `src/` prefix (FIXED, committed)

Committed as `4cd08c7f1` ("Fix distDir derivation to strip project src/ prefix, not projectRoot-relative path"). No longer uncommitted as previously noted here.

`packages/graph-sdk-common/src/project-plugin.ts`'s `createProjectPlugin()` computed:
```ts
distDir: path.join(projectRoot, DIST_DIR_NAME, path.relative(projectRoot, srcPath))
```
`path.relative(projectRoot, srcPath)` is relative to the *project root*, not `<root>/src`, so a plugin at `<root>/src/node-x` got `distDir = <root>/dist/src/node-x` instead of `<root>/dist/node-x`. Same bug class as the historical GRAPH-1499 (`String.replace` first-match path bug), just via `path.relative` from the wrong base.

Fixed by computing relative to `path.join(projectRoot, SRC_DIR_NAME)` instead. Same bug was duplicated a second time in `packages/graph-plugin-compiler/src/build/index.ts` (computing `pluginSourcemapBaseUrl` independently instead of reusing `plugin.distDir`) — fixed by reordering to construct `plugin` first and reuse `plugin.distDir`.

Files touched (uncommitted on this branch): `graph-sdk-common/src/project-plugin.ts` (+tests), `graph-plugin-compiler/src/build/index.ts` (+`index.test.ts`), `graph-plugin-compiler/src/build/project-plugin.test.ts`, `graph-plugin-sdk/src/server/dev-server.test.ts`.

This bug broke `.plugin-dependencies` cross-plugin type resolution (symlinks pointed at `dist/<name>`, actual output landed at `dist/src/<name>` — dangling symlinks) and produced wrong `outDir`/sourcemap URLs.

**Why: fixing this was necessary just to get dist output parity at all** — before the fix, `graph build` wrote every plugin's output to the wrong path.

## Not a bug — graph-plugin-sdk discovery intentionally skips extraction

**Corrected 2026-07-21 (user feedback):** an earlier pass through this file characterized `graph-plugin-sdk/src/project-plugins.ts` discovering local plugins via raw `JSON.parse(manifestFileContents)` (never calling `extractPlugin()`) as a regression versus legacy `graph-sdk/src/plugins/project-plugins.ts` (which does call `extractPlugin(dir, pluginsLogger)` during discovery). **It is not a bug — it was a deliberate change from `graph-sdk`'s behavior**, made to avoid expensive TypeScript parsing during discovery by deferring `extractPlugin()` to build time instead. Do not propose "wire `extractPlugin()` into discovery" as a fix for anything, and do not treat any divergence from legacy `graph-sdk`'s discovery behavior as inherently a parity bug — confirm with the user first, since some divergences (like this one) are intentional improvements, not gaps.

The originally-observed symptom is still real and still worth tracking separately, just not attributable to "discovery is missing a call it should have": `forPluginType` (whether a `utility` plugin needs DOM lib types) isn't in source `manifest.json` — it's derived by parsing `plugin.ts`'s `createUtilityPlugin(...)` call, which only happens during extraction/build. Since `getPluginTSConfig()` runs at **install** time (before any extraction), it can't see `forPluginType` yet, so DOM-dependent utility plugins (e.g. `utility-thumbnail-strip`, using `HTMLCanvasElement`/`document`) get the wrong `lib` set and fail typecheck (`TS2304: Cannot find name 'HTMLCanvasElement'`) — and this very likely explains the ~70 other typecheck failures seen in a `core-nodes` rebuild too (widget-literal-type mismatches like `"@adobe/widget-depthmap-inline"` not assignable to `"@adobe/widget-depthmap"`).

**Confirmed via a clean, contemporaneous rebuild (before this correction):** legacy `graph-sdk build` on current core-nodes source = 426/426 succeed, 0 failures. New `graph build` (with Bug 1 fixed) = still ~71 failures, all traced to this `forPluginType`-at-install-time gap.

**Open question, not diagnosed further:** given discovery-time extraction is intentionally out, what's the correct place/mechanism to make `forPluginType` (or an equivalent DOM-vs-worker `lib` signal) available before `install()` generates each plugin's tsconfig? Whoever picks this back up needs to design within the "no expensive parsing at discovery" constraint, not just re-add `extractPlugin()` to the discovery path.

**Filed as [[jira_GRAPH-3362]]** (2026-07-29, Epic GRAPH-2601): chosen fix direction is to move `forPluginType` out of the utility `PluginConfig` and into source `manifest.json`, so `install` can read it directly without any TS parsing.

**Status as of 2026-07-21:** whether the underlying typecheck failures are still present is unverified. A later full `install`/`build`/`lint` run against `ml-nodes` (see Bug 3 below) succeeded end-to-end, but `ml-nodes` doesn't build any DOM-dependent utility plugin itself (its own 29 plugins are node/utility types that don't need `forPluginType`; `utility-thumbnail-strip` only appears there as an already-resolved external *dependency*, never rebuilt from source). So that run doesn't confirm anything either way here. Re-verify against `core-nodes` (or any project that builds `utility-thumbnail-strip`/similar from its own source) to check current status.

## Bug 3 — sdk-paths.ts's fixed-hop-count `import.meta.url` broke once bundled into graph-cli (FIXED, committed)

Committed as `43d7feace`. `packages/graph-plugin-sdk/src/const/sdk-paths.ts` derived `CLI_PKG_DIR`/`TEMPLATES_DIR`/`PACKAGE_TEMPLATE_DIR`/`PLUGINS_TEMPLATE_DIR`/`PLATFORM_LINK_ROOT` from its own `import.meta.url` using a fixed 3-`path.dirname()`-hop assumption — the exact same pattern `graph-plugin-compiler`'s `lib-paths.ts` had (see [[bundling_tsdown_bugs]]). Once the SDK-subcommand-bundling work (GRAPH-2740) bundled `@graph/plugin-sdk` into `graph-cli`'s single `lib/index.js` (workspace dep, inlined), this computation resolved one directory too high (`packages/` instead of `packages/graph-cli/`), breaking `install()`'s template-copying (`ENOENT: .../packages/templates/plugins/tsconfig.json`) and its temporary local dev-link mechanism that symlinks `.platform-dependencies` to sibling monorepo packages for testing without a real Graph Services fetch.

Fix: deleted `sdk-paths.ts` entirely; `install()` and `getPluginTSConfig()` now take `packageTemplateDir`/`pluginsTemplateDir`/`platformLinkRoot` as explicit parameters, computed once by `graph-cli/src/index.ts` (whose own depth — `src/index.ts` vs bundled `lib/index.js`, both exactly one level below the package root — is stable in both source and bundled form) and threaded down. Verified via a full `install` → `build` → `lint` run against `ml-nodes`, all three commands succeeding end-to-end through the real bundled artifacts (67 installed, 29 built, 29 linted).

**Pattern to watch for going forward:** any module that computes a package-relative path from its own `import.meta.url`/`__dirname` using a fixed hop count is a latent bug the moment that module becomes a bundling target (either directly, or transitively via a `workspace:*` dependency someone decides to inline). Audit for this pattern (`fileURLToPath(import.meta.url)` + `path.dirname`/`path.join(..., "..", "..")`) in any package before adding it to a `tsdown` `deps.alwaysBundle` list.

## Testing gotcha learned

Never run `graph-sdk link`/`install` and `graph install`/`graph build` back-to-back on the same consumer project without fully cleaning between them (`graph-sdk unlink`, delete `.platform-dependencies`/`.plugin-dependencies`/per-plugin `tsconfig.json`/`eslint.config.mjs`, restore `node_modules` via a plain `pnpm install`). Overlapping symlink mechanisms from both CLIs active at once produces spurious `TS2719` duplicate-type-identity errors that look like a real bug but are just contaminated test state.

`ProgressLogger` (`packages/graph-sdk-common/src/progress-logger.ts`) makes `.log()`/`.success()`/`.fail()` hard no-ops whenever `process.stdout.isTTY` is false — so piping/redirecting `graph` command output (including capturing it via a script/tool) silently swallows every error message; the process just exits 1 with zero output. To see the real error, force a pseudo-TTY, e.g. `script -q /tmp/out.txt <command>` on macOS. This is a real, pre-existing usability bug (unrelated to the SDK-bundling work) worth fixing separately — every CI run or piped invocation currently hides all diagnostics on failure.
