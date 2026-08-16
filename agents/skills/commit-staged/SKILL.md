---
name: commit-staged
description: Analyze staged changes, generate a detailed commit message, and run git commit + push. Use when user invokes /commit-staged or wants to commit staged changes.
user-invocable: true
---

# Commit Staged

## Purpose
Analyze only staged changes, generate a detailed commit message (to feed `/pr-summary` when it reviews commit history), then run `git commit`. Do not stage or touch unstaged or untracked files.

## Required commands
- `git status`
- `git diff --cached`

Do not run `git add` or `git add -A`.

## Scope rules
- Consider only the staged diff. Ignore unstaged and untracked files.
- Only what is already staged will be committed.

## Commit message requirements
As detailed as possible—enough context for the agent running `/pr-summary` to understand what changed and why. Include:
- What was changed: files, APIs, behavior.
- Why: goal or fix.
- Any non-obvious implications.

Multi-line is expected: use a subject line plus body. These messages will be squashed on merge; they exist to document the PR.

## Workflow
1. Run `git status` and `git diff --cached`.
2. If nothing is staged, say so and do not run any git write commands.
3. Write a detailed commit message (subject + body, as much context as needed). Pass the message safely to `git commit` so newlines and quotes are preserved (e.g. write to a temp file and use `git commit -F <file>`).
4. Run `git commit` with that message. Do not run `git add` or `git add -A`. Do not use `--no-verify` or force flags.
5. Run `git push` to push the commit up to the remote.

## Style
- Crisp, factual. No personal pronouns.
