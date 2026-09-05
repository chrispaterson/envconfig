---
name: polish
description: Post-change cleanup pass — find dead code, stale comments, missing docs, and over-scoped changes on the current branch.
user-invocable: true
---

# Polish

Run a cleanup pass over the current branch's changes to catch loose ends before the work is considered done.

## Workflow

### 1. DIFF — Understand the Change Surface

If a diff and file list were passed in by the caller (e.g. the `do` skill), use them directly and skip this step.

Otherwise, use `gh pr diff` (see `~/.agents/skills/github-access/SKILL.md`) to get the authoritative diff for this branch — this compares against the remote base branch and avoids false positives from a stale local `main`. Also run `gh pr diff --name-only` to get the file list.

If no PR exists yet, fall back to `git diff main...HEAD` and `git diff main...HEAD --name-only`, but note that local `main` may be behind the remote.

---

### 2. SCAN — Check Each Category

Work through each category below. Collect findings — do not fix anything yet.

#### A. Dead Code

Search the repo for utilities, functions, types, constants, and imports that this branch introduced or modified in a way that may have made previously-used things obsolete:

- Look at every symbol that was **deleted from a call site** in the diff. Is it still referenced anywhere else?
- Look at every module that was **replaced or refactored**. Did the old module or helper lose all its consumers?
- Search for any `TODO: remove`, `@deprecated`, or inline notes added during this work that were never acted on.
- Check for **unused imports** in every changed file.

Flag each item: what it is, where it lives, and why you believe it is now dead.

#### B. Stale or Missing Comments

For every function, class, type, or constant that was **changed or added** in the diff:

- Is the existing TSDoc still accurate? If the signature, behavior, or purpose changed, the doc probably needs updating.
- Is there TSDoc at all on exported symbols? If not, flag it as missing.
- Are there inline comments that describe behavior that no longer exists?
- Does any comment say "TODO" or "FIXME" that this branch was supposed to resolve?

Do **not** flag comments on unchanged surrounding code — stay focused on what the diff touched.

#### C. Documentation (Markdown / Docs)

Ask: does this change affect something user-visible, API-public, or architecturally significant enough that a doc should be updated or created?

Check:
- Does the repo have a `docs/` folder, a `README.md`, or a `CHANGELOG` that is relevant to this change?
- Did any public API surface (exported functions, CLI flags, config schema, events) change in a way that a consumer would need to know about?
- If the project has a plugin or extension SDK, does the developer guide need updating?

Flag any doc that appears out of date or newly required. Do not create docs automatically — only flag and recommend.

#### D. Scope — Is This Branch Doing Too Much?

Review the full diff holistically:

- Does the branch contain changes that are **logically independent** — things that could ship separately without depending on each other?
- Are there refactors mixed in with feature work, or infrastructure changes mixed in with bug fixes?
- Are there any changes that feel **exploratory or experimental** — things that aren't quite ready but got bundled in?

If the branch is over-scoped, identify the natural split points: what belongs here vs. what should be broken out into its own ticket and branch.

---

### 3. REPORT — Present Findings

Present findings grouped by category. For each item include:

- **What**: a short label
- **Where**: file and line number (or symbol name)
- **Why**: one sentence explaining the issue

Example format:

```
## Dead Code
- `formatLegacyOutput` in `src/utils/format.ts:42` — was only called from `renderOld.ts`, which was deleted in this branch

## Stale Comments
- TSDoc on `GraphBuilder.build()` still mentions the `legacyMode` option, which was removed

## Documentation
- `docs/sdk/plugin-api.md` covers `onNodeAdded` but the signature changed in this branch

## Scope
- Changes to `packages/runtime/scheduler` appear independent of the main fix in `packages/sdk` — could be its own ticket
```

After the report, ask: *"Which of these would you like to address?"*

---

### 4. ACT — Fix Selected Items

Handle only the items the user approves. For each:

- **Dead code**: delete the dead symbol and its tests. Remove now-unused imports. Run the build to confirm nothing breaks.
- **Stale/missing comments**: apply fixes following the `comment` skill guidelines — TSDoc on exports, explain *why* not *how*, keep it concise.
- **Documentation**: update or draft the relevant markdown. Do not create new files unless the user confirms they want them.
- **Scope reduction**: for each split-out item, follow this sequence — confirm the full plan with the user before touching anything:
  1. **Snapshot** — create a preservation branch from the current branch so the work is not lost:
     ```
     git checkout -b <descriptive-branch-name>
     git push -u origin <descriptive-branch-name>
     ```
     Name the branch after the work being split out (e.g. `user/ISSUE-123/scheduler-refactor`). Push it so the remote has a copy.
  2. **Return** — switch back to the original branch: `git checkout -`
  3. **Revert** — remove the split-out changes from the current branch using `git checkout origin/main -- <paths>` or targeted edits.
  4. **File ticket** — use the `createjira` skill to create the Jira story. In the ticket description, include:
     - A summary of what the split-out work does and why it was deferred
     - The preservation branch name and URL so the next agent can start from working code rather than rebuilding from scratch
     - Any known caveats or TODOs left in the snapshot

---

### 5. VERIFY

For every package touched during the Act phase, run in sequence:

- **Build** — `rushx build` (or the appropriate command for the project)
- **Lint** — `rushx lint`
- **Test** — `rushx test`

Fix any failures before finishing.
