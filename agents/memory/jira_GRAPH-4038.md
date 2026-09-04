---
name: jira-graph-4038
description: "GRAPH-4038 un-skip vendored-npm platform-closure smoke test; external closure entry needs live pnpm-pack, not a bare entry.dir→resolveClosureEntryDir swap"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9659a0dc-952c-4e7f-ad04-e18d1e1e8ae9
  modified: 2026-09-04T18:42:41.665Z
---

GRAPH-4038 (Story, Epic GRAPH-2601, component SDK): un-skip `packages/graph-cli/integration/vendored-npm-smoke.test.ts` and make it green. Split out of [[jira_GRAPH-2736_branch_closeout_stories]] (GRAPH-4037). Draft PR Adobe-CreativeCloud/graph#3622.

**Non-obvious:** the ticket framed the fix as "just resolve each entry's dir via `resolveClosureEntryDir` instead of `entry.dir`", but that alone does NOT pass. The closure now includes the external entry `@graph-services/specs` (reached via `@graph/plugin-compiler` → `@graph/eslint-plugin`), which carries `resolveFrom` and no `dir`. Its resolved node_modules dir has a `dist/` folder but **no `*.tgz`** — so reading a pre-built dist tarball throws "No tarball". Fix mirrors `common/scripts/stage-platform-tarballs.mjs` dual path: workspace entries (`entry.dir` defined) copy their built `dist/*.tgz`; external entries (`entry.dir === undefined`) are packed live via `packWithPnpm(rushPnpm, resolveClosureEntryDir(entry), workDir)`.

Test runs only under `vitest.config.integration.ts` (default `vitest.config.ts` = src globs only), so it does NOT gate PR CI. Requires `rush build --to @graph/plugin-compiler --to @graph/platform-exports` first for the workspace dist tarballs. Change file type `none` (test-only).
