---
name: jira-graph-2736
description: "GRAPH-2736 (migrate-sdk-subcommands-versioned-bundles) — graph-cli build's dependency-ordering race is fixed (commits 93d90526b, 71d687b4d); manual smoke test against real plugins still pending"
metadata: 
  node_type: memory
  type: project
  originSessionId: b41bbb9e-9e68-4008-b6e6-75c231660b22
---

GRAPH-2736 splits `@graph/sdk` into `graph-sdk` (SDK) and `graph-cli` (CLI), on branch
`paterson/GRAPH-2736/migrate-sdk-subcommands-versioned-bundles`, to let build/submit/lint be
locked to a platform version. Work-in-progress path:
`../../GRAPH-2740/GRAPH-2736/migrate-sdk-subcommands-versioned-bundles/packages/`.

**Bug found and fixed:** `graph-cli build` produces flaky TypeScript errors — a different
plugin fails each run — that don't occur with the current `pnpm run build` (`graph-sdk build`).

Root cause: `graph-cli`'s `forEachPlugin` (`packages/graph-cli/src/project-plugins.ts:363`) builds
all plugins concurrently via `pLimit(os.cpus().length - 1)` over a topologically-sorted list
(`dependency-sorter.ts` — correct Kahn's-algorithm sort over `manifest.json` deps, including
widget-only deps declared there). The sort order is correct, but `pLimit` is only a concurrency
cap / sliding window — it starts the next queued plugin as soon as a slot frees, without waiting
for that plugin's actual dependencies to *finish* building. A plugin and its dependency can land in
the same concurrency window and race.

Old `graph-sdk build` (`packages/graph-sdk/src/commands/build.ts`) instead builds strictly
sequentially in a `for` loop over the sorted list — docstring explicitly says this guarantees a
dependency's `dist/` output exists before the dependent builds.

Why the error looks unrelated to the real cause: each plugin's ambient type registration
(`PluginDatatypeMap`/`PluginWidgetMap` augmentation) is appended to `dist/<plugin>/index.d.ts` by
`addPluginTypeMapAugmentation`, which runs *after* bundling. If a dependent's `tsc` typecheck races
ahead of that, the dependency's type isn't registered yet, so TypeScript reports a confusing
structural mismatch (wrong literal type / missing key) instead of a "not found" error.

Verified via direct repro: building `node-convert-bounding-box-to-vector2` in isolation with the
*old* `build-plugin.js`, before its declared dep `@adobe/widget-vector2-inline` had been built,
reproduced the exact same error — confirms this is purely a build-ordering artifact, not a problem
with the `.platform-dependencies` split or the TS types themselves.

Ruled out (not the cause): duplicate module identity from the new `.platform-dependencies`
symlinks (realpaths are identical to old `node_modules/@graph/*`); the new exact-match (non-
wildcard) `@graph/*` tsconfig `paths` entries added by `graph-cli install` (flagged "Temporary to
test the SDK" in the source) — these don't intercept real subpath imports, so they're currently a
no-op, not buggy.

**Fix applied (2026-07-13):** `forEachPlugin`
(`packages/graph-cli/src/project-plugins.ts:363`) now has a real dependency-aware scheduler — a
promise-memoized `schedule(plugin)` that recursively awaits its direct dependencies' own scheduled
promises (looked up via `manifest.dependencies` + `getPluginMapKey`, same pattern as
`getTransitiveDependencies`) *before* acquiring a `p-limit` slot to run the callback. Key
invariant: the dependency awaits must happen outside `limit()`, or a full pool of dependents can
deadlock waiting on dependencies that never get a turn. No changes needed to
`dependency-sorter.ts` — it still provides the acyclic-graph guarantee via the cycle check inside
the cached `projectPlugins` `IdempotentValue`. Independent plugins still build concurrently (capped
by `os.cpus().length - 1`) — this was explicitly a speed goal too, since `graph-sdk`'s own
`build.ts` never had concurrency at all (see GRAPH-2639 below), so this fix makes `graph-cli`
strictly faster than the old SDK while also being correct.

Executed via superpowers:subagent-driven-development: commits `93d90526b` (scheduler) and
`71d687b4d` (added test round required by task review — original test only covered dependency
ordering, not that independent plugins still run concurrently). Final whole-branch review: ready to
merge, no Critical/Important findings. Full plan with test code:
`docs/superpowers/plans/2026-07-13-graph-cli-build-dependency-ordering.md` on this branch.

**Still open:** the plan's manual smoke test (Step 6 — running real `graph-cli build` against a
node plugin that depends on a datatype/widget plugin, a few times in a row, to confirm no more
flaky errors) was deferred — no such fixture was available in the implementer subagent's sandbox.
The real reproduction path is a subprocess (`pluginExec` in `platform-dependencies.ts`), which none
of the new unit tests exercise. Do this manual check before considering GRAPH-2736 fully closed.
Minor, non-blocking findings from review, not yet acted on: `pLimit(os.cpus().length - 1)` throws
on single-CPU hosts (pre-existing, not introduced by this fix — consider `Math.max(1, ...)` as a
follow-up).

**Correction — the "reusable fix in build.js" lead was stale:** as of 2026-07-13,
`graph-sdk/lib/commands/build.js` on this branch does NOT contain the `CONCURRENCY_LIMIT`/promise-map
scheduler described in [[graph-2639-parallelize-graph-sdk-build-command-using-p-limit-with-per-cpu-subprocess-spawning]] —
it's back to a plain sequential `for` loop, matching `src/commands/build.ts`. The compiled artifact
must have been regenerated from the still-sequential source after GRAPH-2639 was filed. Don't rely
on porting an existing implementation; the scheduler needs to be designed fresh (done in the plan
above) for both `graph-cli` (this ticket) and, separately, GRAPH-2639's `graph-sdk` build command.
