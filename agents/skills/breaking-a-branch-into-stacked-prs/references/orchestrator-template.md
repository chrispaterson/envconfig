# Orchestrator template

Controller for landing an N-PR branch breakdown. Fill the `{{PLACEHOLDERS}}`. Companion:
`worker-template.md`. Keep this file + a durable progress file; delegate all build/test work.

## Placeholders
- `{{REPO}}` — e.g. `owner/repo`
- `{{PRIMARY_CHECKOUT}}` — a clone permanently on `{{BASE_BRANCH}}` where you run git/worktree ops
- `{{BASE_BRANCH}}` — usually `main`
- `{{SOURCE_BRANCH}}` — the oversized branch holding the finished code
- `{{AUTHOR}}` — who does the internal pre-review (often the operator driving you)
- `{{REVIEWER_HANDLE}}` / `{{REVIEWER_CHAT}}` — external reviewer's VCS handle / chat id
- `{{CONCURRENCY}}` — max PRs in flight at once (≈3)
- `{{WORKER_TEMPLATE}}` / `{{MANIFEST}}` / `{{PROGRESS}}` — absolute paths
- `{{MERGE_CMD}}` — e.g. `gh pr merge <pr> --auto` (repo default / merge queue; never force-squash)

## Why the split (context budget)
You hold only the queue + progress file. Each PR is built by a **fresh worker sub-agent**
(isolated context); you receive only a compact JSON line. Never run a PR's build/test yourself.

**Dispatch:** point a fresh sub-agent at `{{WORKER_TEMPLATE}}` with a tiny prompt:
"Read {{WORKER_TEMPLATE}} and run BUILD mode for SUBTASK=<key> BASE=<branch>; take your file
list from the {{MANIFEST}} section for <key>; return only the final JSON line."

## Worker result contract (last line = strict JSON)
```json
{"status":"ready_for_pre_review|ci_failed|blocked","subtask":"<key>","pr":<n>,"url":"<pr url>","branch":"<br>","worktree":"<abs>","reviewer_summary":"one sentence: what the PR does","note":"one line"}
```
REVISE returns the same shape; CONFLICT returns `{"status":"resolved|blocked",...}`.

## Progress file protocol
`{{PROGRESS}}`, one line per task, durable state. States:
`PENDING | BUILDING | PRE_REVIEW <pr> | AWAITING_REVIEW <pr> | MERGING <pr> | PAUSED <reason> | MERGED`.
Record each task's **branch** (needed to compute the next task's stacked BASE). On startup:
finalize any MERGING that since merged, then resume.

## The loop (per tick: A, then B, then C)

**Base (stacking):** a task's `BASE` = the immediately-preceding task's branch if it's not yet
MERGED, else `{{BASE_BRANCH}}`.

**(A) Finalize sweep** — for each `MERGING <pr>`:
- `gh pr view <pr> --json state,mergeStateStatus,autoMergeRequest`
- `MERGED` → close sub-task; roll story up if it was the last; from `{{PRIMARY_CHECKOUT}}`:
  `git worktree remove <wt> --force && git branch -D <br> && git fetch --prune`. Set `MERGED`.
- Still OPEN + healthy (queued) → **wait, no timeout.** `BEHIND` → `gh pr update-branch <pr>`.
- ⚠️ Do NOT treat `autoMergeRequest==null` / `mergeStateStatus UNKNOWN` as a fault — merge
  queues report that even when correctly queued. Confirm real queue membership (queue's
  GraphQL entry) before flagging. Genuine faults (CLOSED-unmerged, unresolvable DIRTY, truly
  absent from queue) → `PAUSED merge-fault`, notify {{AUTHOR}} with the URL.

**(B) Advance each in-flight task one step:**
- `PRE_REVIEW <pr>` — await {{AUTHOR}}'s decision. Approve → handoff: `gh pr ready <pr>`;
  set tracker "in review"; assign `{{REVIEWER_HANDLE}}`; ping `{{REVIEWER_CHAT}}` one sentence
  from `reviewer_summary` **with the full PR URL, and no greeting** — the reviewer is
  tracking the process, so lead with what the PR does, not "Hi <name>". Set `AWAITING_REVIEW`. Changes → dispatch
  worker REVISE with feedback; if it has stacked dependents, rebase them after (CONFLICT worker each).
- `AWAITING_REVIEW <pr>` — poll `gh pr view <pr> --json reviewDecision`. APPROVED → `{{MERGE_CMD}}`,
  set `MERGING`. CHANGES_REQUESTED/new comments → `PAUSED review`, notify {{AUTHOR}} (with URL);
  stop building *past* it, but keep advancing other in-flight tasks.

**(C) Fill the window** — while in-flight (`BUILDING|PRE_REVIEW|AWAITING_REVIEW|MERGING`) count
< `{{CONCURRENCY}}` AND next `PENDING` task's BASE branch exists: dispatch ONE BUILD worker
(builds are sequential — each needs the prior branch). On its JSON: `ci_failed`/`blocked` →
`PAUSED`, notify; `ready_for_pre_review` → store `{pr,url,branch,worktree,reviewer_summary}`,
set `PRE_REVIEW`, and notify {{AUTHOR}} for pre-review with the URL.

## Escalation
Per-task problems PAUSE that task (notify with URL) and stop building past it — other tasks
continue. Hard-stop the whole loop only on environment failures (VCS API blocked, auth down).
A slow merge queue is never a reason to pause.
