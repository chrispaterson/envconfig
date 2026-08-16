---
name: github-access
description: >-
  Canonical GitHub access for PRs, diffs, and API helpers. Today this is
  implemented with the GitHub CLI (`gh`); other skills reference this file
  instead of duplicating commands. Prefer this over MCP or web UI when automating
  PR tasks.
---

# GitHub access — canonical reference

## Policy

- **Default:** use `gh` for PR create/view/diff/edit, reviewer assignment, and JSON inspection.
- **Single place to change:** if PR workflow changes (different base branch, required checks, or GraphQL instead of REST), update **this skill only**; consumer skills stay prose-high-level.

## Prerequisites

- `gh` installed and authenticated (`gh auth status`). If not authenticated, consumer skills should warn and skip PR steps where needed.

## PR inspection

| Goal | Command |
|------|---------|
| Metadata | `gh pr view --json number,title,state,url,body,headRefName,baseRefName,labels,mergeStateStatus,updatedAt` (trim JSON keys to what you need) |
| Open PR in browser | `gh pr view -w` |
| Full diff (merge-base; **preferred** for “what this branch changes”) | `gh pr diff` |
| File names only | `gh pr diff --name-only` |

## PR create / update

- **Draft PR with multiline body:** write body to a temp file, then:
  ```bash
  gh pr create -B main -t "<title>" -F /path/to/body.md -d
  ```
- **Edit title:** `gh pr edit --title "<title>"`
- **Edit body:** `gh pr edit --body-file /path/to/body.md`
- **Add reviewers:** `gh pr edit --add-reviewer login1,login2`

Resolve PR number when needed: `gh pr view --json number -q '.number'`

## Repo diff when **no** PR exists yet

Use **three-dot** diff against the base so you only see this branch’s commits relative to the merge base — **not** two-dot:

```bash
git fetch origin
git diff origin/main...HEAD
```

**Do not** use `origin/main..HEAD` (two dots) for “what changed on this branch” when the branch may be behind base: two-dot compares tip commits and can include unrelated base changes. Three-dot uses the merge base.

When a PR exists, prefer `gh pr diff` (it already reflects merge-base semantics).

## `gh api` helpers

Resolve GitHub login from email (e.g. for reviewer assignment):

```bash
gh api "/search/users?q=<email>+in:email" --jq '.items[0].login'
```

## URLs for linking elsewhere

- PR URL: `gh pr view --json url -q '.url'`
