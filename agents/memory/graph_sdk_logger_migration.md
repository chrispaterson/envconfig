---
name: graph-sdk-logger-migration
description: "graph-plugin-sdk migrated from @logtape/logtape Logger to @graph/logging GraphLogger; CommandOptions.logger stays optional + assertLoggerPresent guard because of graph-cli's command-action.ts composition"
metadata:
  node_type: memory
  type: project
  originSessionId: 7420ffe5-9158-4d64-9391-d3d9b7e9127f
  modified: 2026-07-29T01:55:46.888Z
---

Completed (GRAPH-2736 branch): every `@logtape/logtape` `Logger` type in `packages/graph-plugin-sdk/src` was replaced with `GraphLogger` from `@graph/logging`. The old `src/logger.ts` (`getLogger(component)` factory with per-command default args) was deleted. Every function that takes a `logger` parameter now calls `parentLogger.child("<kebab-name>")` at its own entry and uses that child for its own logging + as the value forwarded to further nested calls (so log categories nest by call depth, e.g. `build.for-each-plugin.get-project-plugins`).

**Exception — top-level exported command functions** (`build`, `dev`, `install`, `lint`, `format`, `login`, `logout`, `submit`, `listPluginsCommand`): these do **not** self-child. `packages/graph-cli/src/command-action.ts`'s `getCommandAction`/`getPositionalCommandAction` already do `parentLogger.child(progressLogger.infinitive)` before invoking the action, so the logger they receive is already correctly named (e.g. "build", "install"). Re-childing there would double-nest (`build.build`).

**Why `CommandOptions.logger` is `logger?: GraphLogger` (optional), not required:** `command-action.ts`'s wrapper function signature is `(options: TOptions) => Promise<void>` where `TOptions extends CommandOptions`, but it's invoked with a _partial_ options object (raw CLI/commander options, or `buildOptions()`'s return value) that never includes `logger` — the wrapper injects `{ ...options, logger, onPlugin }` itself before calling the real `action`. Making `logger` required in `CommandOptions` breaks this (confirmed via `packages/graph-cli/src/command-action.test.ts` and `index.ts`'s positional `dev` `buildOptions` callback, which return objects without `logger` by design). Fixing this on the graph-cli side would require an `Omit<TOptions, "logger"|"onPlugin">` + cast-free reconstruction, which isn't achievable without `as` for a generic `T`.

Resolution: kept `logger?: GraphLogger` on `CommandOptions`, added `export function assertLoggerPresent(logger: GraphLogger | undefined): asserts logger is GraphLogger` in `command-options.ts`, and every one of the 9 command functions calls `assertLoggerPresent(logger)` as its first line. This is a real runtime invariant (graph-cli always supplies one) that TS can't express structurally given the existing wrapper design, so it's enforced via an assertion function per [[project_graph_typescript_conventions]] instead of `as`.

**Pre-existing, unrelated lint failures** (confirmed present on baseline before this migration touched anything, via `git stash` + `rushx lint`): `src/package-name.ts:33,37` and `src/server/dev-server.ts` (4 occurrences) fail `sdk-common/require-block-comments` ("Add a blank line above this block comment") inside `||`-chained boolean expressions — the project's own Prettier formatter strips manually-added blank lines in that position, so the rule and formatter fight each other. `src/test/mock-logger.ts:9` has a pre-existing `no-unsafe-type-assertion` warning. None of these are from the logger migration; don't attribute them to it.
