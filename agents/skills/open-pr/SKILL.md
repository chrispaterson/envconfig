---
name: open-pr
description: Open or create a GitHub PR for the current branch. Creates a draft PR with full pr-summary analysis if none exists, then opens it in the browser. Use when user invokes /open-pr.
user-invocable: true
---

# Open Pull Request

## Purpose
Open a GitHub PR for the current branch in the browser. If a PR already exists and is OPEN, open it. If no PR exists or it is closed, create a draft PR (with title and Summary / How to test / Risk / checkboxes filled via pr-summary-style analysis), then open it. Do not stage or touch unstaged or untracked files.

## Required commands

- `git fetch` and `git branch --show-current`.
- All **`gh`** commands: `~/agents/skills/github-access/SKILL.md`.
- **Jira** (when branch contains a GRAPH key): `jira issue view --plain --comments 100 <ISSUE-KEY>` per `~/agents/skills/jira-access/SKILL.md`.
- Commit messages unique to branch: `git log --format=%B --author="$(git config user.name)" <base>..HEAD` (two-dot is OK here — commit list, not file diff).
- Repo diff when no PR: `git diff <base>...HEAD` (**three dots**, per `github-access` skill — not two-dot).

If `gh` is unavailable, stop and describe the issue.

## Branch and base
- Branch format convention: `<username>/<issue-key>/<semantic-name>` (e.g. `paterson/GRAPH-328/graph-services-bump`).
- Base branch: `main` (or `origin/main`) unless the user specifies otherwise.

## When creating draft: pr-summary analysis
When creating the draft (no existing OPEN PR), do **not** use only the raw template and a branch-derived title. Follow the same analysis and section rules as in the `pr-summary` skill:
- Fetch commit messages unique to this branch: `git log --format=%B origin/main..HEAD` (or base from context). Use these as the **primary source** for goal, intent, and context.
- If the branch name contains an issue key (e.g. GRAPH-318), run `jira issue view --plain --comments 100 <ISSUE-KEY>` and use the output as additional context for Goal and how the PR applies to that issue.
- Fetch repo diff: `git diff origin/main...HEAD` (three dots; or equivalent base). Use for file-level and code-level detail.
- Derive from commit messages + diff: **Goal**, **Side Quests (by A Snarky AI)**, **Changes**, file bullets per package (`##### <Package Name>`), change type, checklist. Derive a concise **PR title** (verb phrase or scope; prefix with `[ISSUE-KEY] ` when issue key present in branch). See `pr-summary` skill for exact Summary structure and checkbox rules.
- Start from `.github/PULL_REQUEST_TEMPLATE.md`. Replace only: `### Summary`, `### How to test`, `### Risk / Rollout`; update `### Type of change` and `### Checklist` checkboxes. Leave Linked Issue(s), Screenshots, Breaking change details, etc. unchanged.
- If an issue key was derived from the branch, set the line containing `Closes #` to `Closes #<issue-key>` (use Closes by default).
- Add `<!-- pr-summary-last-sha: <sha> -->` at the end of `### Summary` using `git rev-parse HEAD`.
- Create draft with that **derived title** and the filled body: `gh pr create -B main -t "<derived title>" -F <body-file> -d`. Write the body to a temp file and pass with `-F` so newlines and special characters are preserved.

## Workflow
1. Get current branch: `git branch --show-current`.
2. Check for existing PR: `gh pr view --json number,state` (capture state: OPEN, CLOSED, or no PR).
3. If a PR exists and state is OPEN: run `gh pr view -w` and stop.
4. If no PR or state is CLOSED:
   - Run the **pr-summary analysis** (commit messages unique to branch + repo diff) and derive title and Summary / How to test / Risk / checkboxes per the `pr-summary` skill.
   - Build the PR body from the template with those sections replaced and Closes # substituted if issue key present.
   - Create draft PR: `gh pr create -B main -t "<derived title>" -F <body-file> -d`.
   - Then run `gh pr view -w`.
5. Confirm to the user that the PR was created (if applicable) and opened in the browser.

## Style
- Crisp, factual. No personal pronouns.
