---
name: jira_GRAPH-1870
description: GRAPH-1870: sort tsconfig.json paths alphabetically before writing; fix is a sort call in install.ts before paths assignment
type: project
originSessionId: acca14e9-80a3-4370-8980-ef0ec413dbb7
---
GRAPH-1870: Sort tsconfig.json paths alphabetically before writing for stable output.

**Why:** Paths are currently written in depth-first dependency traversal order, which is unstable — adding/removing/reordering deps changes the traversal path and produces spurious diffs.

**How to apply:** The fix is a single sort in `graph-sdk/src/commands/install.ts` around line 156, before `tsconfig.compilerOptions.paths = paths`. Use `Object.fromEntries(Object.entries(paths).sort(([a], [b]) => a.localeCompare(b)))`. Add a unit test asserting sorted order.

Epic: GRAPH-1271 (SDK Developer Experience Enhancements). Points: 1.1.
