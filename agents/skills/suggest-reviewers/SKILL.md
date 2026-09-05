---
name: suggest-reviewers
description: Analyze the current branch's diff using git blame to identify and rank suggested PR reviewers, then optionally assign them via gh. Use when user invokes /suggest-reviewers or asks who should review a PR.
user-invocable: true
---

# Suggest PR Reviewers

## Purpose
Analyze the current branch's diff against its base using git blame to identify who previously authored the changed lines. Present a ranked list of suggested reviewers and, when the user confirms, assign them to the PR via `gh`.

**`gh` syntax:** `~/.agents/skills/github-access/SKILL.md`.

## Required commands
- `git branch --show-current`
- `gh pr view --json number,baseRefName` (to detect existing PR and its base)
- `bash .cursor/commands/scripts/suggest-reviewers.sh <base-branch>`
- `gh api "/search/users?q=<email>+in:email" --jq '.items[0].login'` (resolve GitHub username from email)
- `gh pr edit <number> --add-reviewer <login1>,<login2>,...`

If `gh` is unavailable, present the reviewer list without assigning.

## How the script works
`suggest-reviewers.sh` diffs the current branch against the merge base and:
1. **Blame ranking** — For every modified or deleted hunk, runs `git blame` on the *old* lines at the merge base to find who wrote the code being changed. Ranks authors by number of lines.
2. **Log ranking** — For every changed file, queries `git log` at the merge base for recent contributors. Ranks authors by commit count.
3. Filters out the current user (`git config user.email`) and bot/noreply addresses.
4. Outputs tab-separated sections: `BLAME_RANKING`, `LOG_RANKING`, `CHANGED_FILES`.

Each ranking row is: `Name\tEmail\tCount`.

## Workflow
1. Get current branch: `git branch --show-current`.
2. Determine base branch:
   - If a PR exists: `gh pr view --json number,baseRefName --jq '.baseRefName'`.
   - Otherwise default to `main`.
3. Run the analysis: `bash .cursor/commands/scripts/suggest-reviewers.sh <base-branch>`.
4. Parse the output and present to the user as a ranked table with two sections:
   - **By lines authored** (blame) — people who wrote the code being changed.
   - **By recent activity** (log) — people who recently committed to the affected files.
5. Ask the user which people to assign as reviewers (or suggest the top candidates).
6. For each selected reviewer, resolve their GitHub username:
   - Try: `gh api "/search/users?q=<email>+in:email" --jq '.items[0].login'`
   - If no result, ask the user for the GitHub handle.
7. Assign: `gh pr edit --add-reviewer <login1>,<login2>,...`
8. Confirm assignment to the user.

## Edge cases
- **All new files**: Blame ranking will be empty. Rely on log ranking and suggest contributors to nearby or related files.
- **No PR yet**: Skip assignment steps; present the reviewer list for future use.
- **Large diff (>50 files)**: The script handles this but may be slow. Warn the user if runtime exceeds ~30 seconds.

## Style
- Crisp, factual. No personal pronouns.
