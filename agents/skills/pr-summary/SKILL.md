---
name: pr-summary
description: Prepare and update PR title and description based on repo-wide diff analysis. Replaces Summary, How to test, Risk/Rollout sections and updates checkboxes. Also runs rush change. Use when user invokes /pr-summary or wants to update a PR description.
user-invocable: true
---

# PR Summary Update (gh)

## Purpose

Prepare and update PR description based on repo-wide diff analysis using `gh`. Replace only specific sections and update checkboxes as specified.

## Required commands

- `git fetch` to get the latest diff from the base branch.
- All **`gh`** usage: `~/agents/skills/github-access/SKILL.md` (including `gh pr view`, `gh pr diff`, `gh pr edit`, and three-dot `git diff` when no PR exists).
- **Jira** context for the linked issue (when branch or context has a GRAPH key): `jira issue view --plain --comments 100 <ISSUE-KEY>` per `~/agents/skills/jira-access/SKILL.md`.

**Use the diff as the sole source for analysis** — do not use `git log`.

If `gh` is unavailable, stop and describe the issue.

## PR body constraints

- Do not call out dependency version changes in `package.json` per package; do not mention lock file changes (e.g. `pnpm-lock.yaml`).

## Analysis steps

1. Fetch PR metadata and body with `gh pr view`. Get base ref: from `baseRefName` when a PR exists, otherwise use `origin/main` (or `main`).
2. If an issue key can be derived from the head branch name (e.g. GRAPH-318), run `jira issue view --plain --comments 100 <ISSUE-KEY>` and use the output as additional context for Goal and how the PR applies to that issue.
3. Fetch repo diff: `gh pr diff` when a PR exists. When creating a draft PR, use `git diff <base>...HEAD` (three dots). **Do not use two-dot diff** (`<base>..HEAD`): when the branch is behind the base, two-dot compares the two tip trees and incorrectly includes changes from the base that the branch does not have. Three-dot diff uses the merge base and shows only the branch's changes. **Use the diff as the sole source for analysis**—do not use `git log`.
4. Read `.github/PULL_REQUEST_TEMPLATE.md` from the repo root to get the PR body template. Ignore any existing PR body content entirely — always start fresh from the template.
5. Use the **full diff** (`gh pr diff` or `git diff <base>...HEAD`) to fill out every section in the template. Do **not** add a "New since last update" subsection. The filled template becomes the new PR body.
6. Build a concise replacement for `### Summary` using **the diff only**:
   - `#### Goal` derived from the diff (what the changes accomplish)
   - `#### Changes`: key moves/additions/deletions; notable type/API/signature changes; import path updates; new exports. Write as high-level bullet points — do **not** break down changes by package or file.
7. Determine the change type from the diff.
8. Derive a concise PR title from the goal and key changes (e.g. verb phrase or refactor scope; avoid vague titles like "WIP" or "Updates"). Prefix the title with the issue key in brackets when available (e.g. `[GRAPH-328] `). Derive the issue key from the PR head branch name when it contains a pattern like `GRAPH-123` or similar; otherwise omit the prefix.
9. Check for added or updated code comments in the diff. Treat comment updates as documentation changes.
10. For every change give your best effort guess, no need to confirm with the user.

## Checklist confirmation

- If there is a checklist, complete it with your best guess based on the changes.

## Update PR title

1. Set the PR title with `gh pr edit --title "<title>"` using the title derived in the analysis steps.
2. Use the format `[ISSUE-KEY] <derived title>` when an issue key can be derived from the head branch (e.g. branch `paterson/GRAPH-328/Graph-services-bump` → `[GRAPH-328] Bump @graph-services/specs to 0.9.21 and adjust plugin-manager typings`). If no issue key is present in the branch name, use only the derived title.

## Update PR body

1. Start from a clean copy of `.github/PULL_REQUEST_TEMPLATE.md` — ignore the existing PR body entirely.
2. Fill in every section of the template based on the diff analysis.
3. Ensure all package names, file names, versions, commands, and paths are wrapped in backticks. **Jira linking**: Wrap any word that starts with `graph-` (e.g. `graph-editor`, `graph-ui`, `graph-plugin-types`) in backticks—except the actual issue key (e.g. GRAPH-530)—so GitHub does not auto-link them as Jira issues.
4. Apply with `gh pr edit --body-file <updated-file>`.

## Changelog files (rush change)

**Skip this entire section** if the repository is not Rush-managed. A repository is Rush-managed if a `rush.json` file exists at the repo root. If it does not exist, omit all changelog steps silently.

Run this for **every PR** (in Rush repos) so change files exist for versioning and changelogs.

**Do not run `rush change` interactively or with `--bulk`.** Instead, write change files directly — one per modified package.

### Steps

1. **Identify modified packages** from the diff: list files changed under `packages/` and map each to its `packageName` (read from the package's `package.json`). Ignore repo-wide lock file changes (`pnpm-lock.yaml` lives at the repo root and is not per-package). Packages where the only substantive change is a dependency version bump still require a change file with `type: "patch"`.

2. **Reconcile existing change files** under `common/changes/`:
   - For every package directory found under `common/changes/`, check whether that package has any diff in the current branch.
   - If a package has **no diff** but has a change file, **delete the change file** — it is stale.
   - If a package **has a diff** and already has a change file, **delete it** — it will be replaced with a fresh one.

3. **For each modified package**, write a change file at:

   ```
   common/changes/<scope>/<package-name>/<branch-slug>_<YYYY-MM-DD-HH-MM>.json
   ```

   where `<scope>` is the npm scope (e.g. `@graph`), `<package-name>` is the unscoped name (e.g. `graph-sdk`), `<branch-slug>` is derived from the current branch name (replace `/` with `-`, lowercase), and the timestamp is the current UTC time.

   File format:

   ```json
   {
     "changes": [
       {
         "packageName": "@scope/package-name",
         "comment": "<concise summary of only the changes made to this specific package>",
         "type": "<major|minor|patch|none>"
       }
     ],
     "packageName": "@scope/package-name"
   }
   ```

   - The `comment` must describe **only what changed in this package** — not the PR goal or changes in other packages. Derive it from the diff for that package's files only.
   - Write the `comment` as if it will appear verbatim in a public `CHANGELOG.md` read by package consumers: describe the observable impact (new capability, fixed behavior, changed API) from the user's perspective. Avoid implementation-level language ("refactored X", "moved Y", "renamed Z internally") — instead describe what the user can now do, what was broken and is now fixed, or what API/behavior changed and how. Use plain English, present tense, active voice.
   - Choose `type` based solely on the impact of **this package's changes**: `major` for breaking API changes, `minor` for new non-breaking features or API additions, `patch` for bug fixes or non-breaking improvements, `none` for internal/tooling-only changes with no consumer impact.

4. **Commit and push** the new change files:
   ```bash
   git add common/changes/
   git rm --cached common/changes/... # for any deleted files not auto-staged
   git commit -m "chore: update rush change files for <issue or PR scope>"
   git push
   ```

## Final confirmation

- Print a short success note that the PR title and body were updated.
- Remove any temporary working files used for editing.

## Style

- Crisp, factual, official tone.
- No personal pronouns.
