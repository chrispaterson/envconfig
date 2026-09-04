---
name: do
description: Use when user says "do GRAPH-XXX", "let's do GRAPH-XXX", "work on GRAPH-XXX", "pick up GRAPH-XXX", or "begin GRAPH-XXX". Fetches the Jira issue, detects where work stands, implements the story end-to-end, and opens a ready-for-review PR on GitHub.
user-invocable: true
---

# Do Story

## Purpose

Take a Jira story from In Development to a GitHub PR ready for review in one command. Detects where work stands and picks up from the right step — so running `/do` on an existing worktree resumes rather than restarts.

## Invocation

- `/do GRAPH-123`
- "do GRAPH-123" / "let's do GRAPH-123" / "work on GRAPH-123" / "pick up GRAPH-123"

## Jira and GitHub CLIs

All **Jira** operations: read and follow `~/agents/skills/jira-access/SKILL.md` (CLI only; do not use Corp Jira MCP unless the user explicitly overrides).

All **`gh`** operations: read and follow `~/agents/skills/github-access/SKILL.md`.

---

## Workflow

### Phase 1 — Setup

#### 1. Resolve the Issue Key

Parse the GRAPH-XXX key from the invocation args or the user's message. If none found, ask the user.

#### 2. Locate and Enter the Worktree

Search for an existing worktree for this issue:

```bash
find ~/projects/adobe/project-graph -maxdepth 1 -type d -name "*GRAPH-XXX*"
```

- **Found** — set that directory as the working directory for all subsequent steps.
- **Not found** — run `git b -y -t "<short semantic name>" GRAPH-XXX` to create it.
  - `-y` runs the script non-interactively (auto-confirms prompts, no browser, fails fast instead of blocking on input).
  - `-t` supplies the branch name directly. Fetch the issue first (step 3 — you need it anyway) and derive a short kebab-friendly name from the summary. Passing it here means the script skips both the summary re-fetch and the nested `claude --print` call it would otherwise spawn just to name the branch. If for some reason you don't have a name, omit `-t` and the script will fall back to naming it itself.
  - Parse the `Worktree: <path>` line it prints on success and set that as the working directory.

#### 3. Fetch the Issue

Always run this step for context, regardless of stage.

Fetch with the jira CLI (see `jira-access` skill):

```bash
jira issue view GRAPH-XXX --raw
```

Parse `fields.summary`, `fields.description`, `fields.status.name`, and `fields.issuetype.name` from the JSON output. Optionally also read `fields.assignee`, `fields.customfield_10003`, `fields.components` when useful.

For **Bug** issues, also extract:

- Steps to reproduce (`fields.description` — look for reproduction steps, expected vs actual behaviour)
- Affected version / environment if present

Display a one-line summary:

```
GRAPH-XXX [<issuetype>]: <summary> [<status>]
```

Carry the issue type forward — Phase 2 branches on it.

#### 4. Detect Current Stage

Run these checks in parallel to determine where the work stands and capture the diff for later use:

```bash
gh pr view --json state,url 2>/dev/null   # PR already open?
git log main...HEAD --oneline             # commits ahead of main?
git status --short                        # uncommitted changes?
git diff main...HEAD                      # full diff — pass to polish at step 8
git diff main...HEAD --name-only          # changed file list — pass to polish at step 8
```

| Signal                          | Jump to                                          |
| ------------------------------- | ------------------------------------------------ |
| PR already open                 | Nothing to do — work is complete                 |
| Commits ahead of main, no PR    | Step 8 (polish)                                  |
| Uncommitted changes, no commits | Step 7 (implement) — pick up mid-stream          |
| Clean tree, no commits          | Step 5 (rush setup), then step 6 (read and plan) |

#### 5. Rush Setup

Only run this step when starting fresh (clean tree, no commits).

If `rush.json` exists at the git root:

```bash
source auth.sh     # authenticate against the npm mirror (required before rush update)
nvm use 2>/dev/null || true
rush update
```

Skip and warn if `auth.sh` is not found.

---

### Phase 2 — Implementation

#### 6. Read and Plan

##### Story / Task

Re-read the full issue: summary, description, acceptance criteria. Display the acceptance criteria clearly.

Explore the codebase to find relevant packages and files.

Present a brief implementation plan (2–5 bullets) before writing any code. If the approach has meaningful tradeoffs, pause and confirm with the user.

##### Bug

Re-read the bug report: steps to reproduce, expected behaviour, actual behaviour. Display these clearly.

More important than fixing the Bug is fully understanding its cause. Once the cause is understood, then the solution becomes obvious. Until you are certain of the cause, do not implement a solution. Instead iterate via hypothesis, test, reset until the root cause becomes clear and reproducible. It's ok if your test isn't the final solution as long as it informs the final solution. Once the root cause is well understood, provide a brief summary of it before proceeding to implement the fix.

If the bug is filed with the component being SDK, you'll want to attempt to reproduce by using the graph-sdk CLI in the graph-plugins-core repo packages at ~/projects/adobe/project-graph/graph-plugins-core/<package>. To do you'll:

```bash
# for each package in graph-plugins-core
cd ~/projects/adobe/project-graph/graph-plugins-core/<package>
../../graph/packages/graph-sdk/.bin/graph-sdk.js link # uses the main branch version of the graph-sdk and related libraries
./node_modules/.bin/graph-sdk <command> # invoke the linked sdk
```

#### 7. Implement

##### Story / Task

Follow the TDD workflow: write failing tests first, implement to make them pass, refactor. The exception to this is graph-core-plugins because it currently doesn't have a test framework.

Make the smallest correct change that satisfies all acceptance criteria.

##### Bug

If possible, write a failing test that demonstrates the bug exactly as described, then run it to confirm it fails in the expected way. Do not proceed to the fix until reproduction is confirmed.

Make the smallest correct change that fixes the bug.

#### 8. Polish

Run the `polish` skill, passing the diff and file list captured in step 4. Polish will skip its own diff step since the diff is already available. Also tell polish to treat any scope findings as flag-only — no branch splits or Jira tickets mid-flow.

#### 9. Core Impact Check

Check the worktree directory name to determine which repo this is:

- **Is `graph`** — run the `core-impact` skill to verify downstream sub-packages aren't broken. Pass the diff from step 4 so core-impact can skip its own change-surface analysis. If any sub-packages are **Breaking**, fix the issues before proceeding to the PR.
- **Any other repo** — run a build to confirm the changes compile cleanly:

#### 10. Rush Change Files

Skip this step if the repo is not Rush-managed (no `rush.json` at the repo root). Otherwise, CI runs `rush change --verify` on every PR and fails the build if any changed package lacks a change description — so a change file must exist before the PR is opened.

**Do not run `rush change` interactively or with `--bulk`** (it prompts and blocks in a non-interactive session). Instead, follow the same workaround as the `pr-summary` skill's "Changelog files (rush change)" section: write the change file(s) directly under `common/changes/<scope>/<unscoped-package-name>/<branch-slug>_<YYYY-MM-DD-HH-MM>.json`, one per modified package, then commit and push. See that section for the exact JSON format, the `comment`/`type` rules, and how to reconcile stale change files.

Verify locally before pushing: `node common/scripts/install-run-rush.js change --verify` should report no missing change descriptions.

---

### Phase 3 — Pull Request

#### 11. Create Draft PR

```bash
git pr -y
```

The `-y` flag auto-confirms creation and, with no TTY, prints the PR URL instead of opening a browser. Report that URL to the user.

---

## Error Handling

| Situation             | Action                                            |
| --------------------- | ------------------------------------------------- |
| Issue not found       | Report and stop; ask user to verify the key       |
| `auth.sh` missing     | Skip `rush update`; warn that deps may be stale   |
| `rush update` fails   | Warn; proceed but note stale deps                 |
| Build/lint/test fails | Fix before creating PR; do not create a broken PR |
| Jira operations fail  | Warn but do not block — continue to PR            |
| `rush change --verify` fails | Write the missing change file(s) per step 10; do not create a PR without it — CI blocks on it |
