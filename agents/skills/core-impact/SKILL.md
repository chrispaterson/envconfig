---
name: core-impact
description: Assess the impact of monorepo changes on graph-plugins-core by capturing baseline and modified build logs, diffing them, and interpreting the results. Use when changes to graph-sdk or related packages may affect downstream core plugins.
user-invocable: true
---

# Core Impact Check

## Purpose

Determine whether changes in the current monorepo worktree break or affect any sub-packages in `graph-plugins-core`. Captures a baseline build before linking local changes, then a modified build after, and interprets the diff.

## Paths

- Monorepo worktrees: `~/projects/adobe/project-graph/<repo>[-<GRAPH-XXX>]/`
- Core repo: `~/projects/adobe/project-graph/graph-plugins-core/`

---

## Workflow

### 1. Identify What Changed

Get the diff from the current monorepo worktree to understand which packages and API surfaces changed:

```bash
git diff main...HEAD --name-only          # changed files
git diff main...HEAD -- 'packages/*/src'  # API surface changes
```

Note which `@graph/*` packages have modified exports or public interfaces — these are the ones that could affect core.

### 2. Identify Affected Sub-Packages

Scan `~/projects/adobe/project-graph/graph-plugins-core/` for sub-packages that depend on the changed packages:

```bash
grep -rl '"@graph/sdk"' ~/projects/adobe/project-graph/graph-plugins-core/*/package.json
```

Repeat for any other `@graph/*` packages that changed. Only run the impact check on sub-packages that have a dependency match — skip unrelated ones.

If no sub-packages match, report that and stop.

### 3. Link the Monorepo

From the current monorepo worktree root, globally link the local SDK:

```bash
rush-pnpm link -g @graph/sdk
```

### 4. For Each Affected Sub-Package

Run steps A–D in sequence for each sub-package identified in step 2.

#### A. Capture Baseline

```bash
cd ~/projects/adobe/project-graph/graph-plugins-core/<sub-package>
graph-sdk unlink && pnpm run build -v --log-file baseline.log
```

This ensures the baseline reflects the published SDK, not any previously linked local state.

#### B. Link Local Changes

```bash
graph-sdk link
```

#### C. Capture Modified Build

```bash
pnpm run build -v --log-file modified.log
```

#### D. Diff and Interpret

```bash
diff baseline.log modified.log
```

Interpret the diff:
- Lines only in `modified.log` (prefixed `>`) — new errors, warnings, or output introduced by the local changes
- Lines only in `baseline.log` (prefixed `<`) — errors or warnings that the local changes resolved
- Focus on TypeScript errors, missing exports, type mismatches, and unresolved imports

Summarise per sub-package:
- **Compatible** — no meaningful diff, or only resolved issues
- **Warning** — new warnings but no errors; likely safe but worth noting
- **Breaking** — new TypeScript errors or unresolved imports; the change breaks this sub-package

### 5. Report

Present a table of results across all checked sub-packages:

```
Sub-package             | Result      | Notes
------------------------|-------------|-----------------------------
graph-plugins-core/foo  | Compatible  |
graph-plugins-core/bar  | Breaking    | TS2345 on MyPlugin.create()
graph-plugins-core/baz  | Warning     | deprecated export still used
```

For any breaking sub-package, quote the relevant diff lines so the cause is immediately visible.

### 6. Cleanup

Unlink local changes from each sub-package to restore clean state:

```bash
cd ~/projects/adobe/project-graph/graph-plugins-core/<sub-package>
graph-sdk unlink
```

Ask the user before skipping cleanup if they want to leave a sub-package linked for further investigation.

---

## Error Handling

| Situation | Action |
|-----------|--------|
| `rush-pnpm link` fails | Stop; local SDK is not linkable — report the error |
| `graph-sdk unlink` fails (no linked state) | Proceed; baseline build will reflect published SDK |
| Baseline build fails | Note it, proceed — modified diff will still show deltas |
| No sub-packages depend on changed packages | Report and stop; no impact assessment needed |
