---
name: breaking-a-branch-into-stacked-prs
description: Use when one branch or PR has grown too large to review (hundreds of files, thousands of lines, many mixed concerns) and must be shipped as a sequence of small single-concept PRs that merge one at a time while keeping the main branch green — especially when the sequence is long enough that driving it by hand, or in a single agent's context, is impractical.
---

# Breaking a Branch into Stacked PRs

## Overview

Take one oversized, already-written branch and ship it as a **narrated sequence of small,
single-concept PRs** that merge one at a time. Two ideas make this tractable:

1. **Orchestrator / worker split** — a lightweight *orchestrator* holds only the queue and a
   durable progress file; each PR is built by a *fresh worker sub-agent* whose heavy tool
   output (builds, tests, CI logs) lives and dies in its own context. This keeps the driver's
   context flat across dozens of PRs.
2. **Stacked pipeline** — the finished code already exists on the big branch, so each PR
   *extracts its slice* rather than re-implementing, and stacks on the previous PR's branch so
   builds stay green and merges stay ordered.

The whole run is also a **teaching sequence for the reviewer**: PR bodies describe what each
piece does and how it fits the architecture — never the extraction mechanics.

## When to use

- A feature branch has ballooned (100s of files) and reviewers can't sensibly review it whole.
- You want a clean, single-concept-per-PR history and to keep `main` green at every merge.
- The sequence is long (10s of PRs) — too much to babysit manually or hold in one context.

**Not for:** a branch that's already small enough to review as one PR; genuinely independent
work that isn't one tangled branch.

## The method

### 1. Decompose (get the real diff, then slice it)
- Use the **three-dot** diff (`git diff main...BRANCH`) for the branch's *own* contribution —
  NOT two-dot, which pollutes with `main`'s advancement since the merge-base. Note how far
  behind `main` the branch is; expect reconciliation later.
- Group files into **single-concept slices** ordered by dependency (foundation packages/types
  first, consumers last). Aim <400 LOC/PR of reviewable hand-written code (soft; exclude
  lockfiles/generated).
- Build a **file manifest**: map every changed file to exactly one slice. Flag *shared*
  files (registration files, `rush.json`) for per-hunk handling, and *regenerated* files
  (lockfiles) as "never extract — regenerate." Disjoint slices are what make stacking clean.
  Don't silently drop files; surface ambiguous ones for a human decision.

### 2. Track it
- One **story per phase**, one **sub-task per PR**, under an epic. Titles = the deliverable,
  numbered in merge order. Bodies describe *what the PR delivers*, not how it was carved out.
- ⚠️ Verify the tracker's **sub-task workflow** — it often differs from the story workflow
  (e.g. sub-tasks may lack "In Development"/"Ready to Merge"). Don't assume shared helper
  scripts use valid transitions.

### 3. Set up the orchestrator + worker
Use the two templates in `references/`:
- **[orchestrator-template.md](references/orchestrator-template.md)** — the controller loop,
  queue, progress-file protocol, gates, concurrency, finalize/cleanup.
- **[worker-template.md](references/worker-template.md)** — one PR end-to-end in an isolated
  context, returning a compact JSON result.

The orchestrator dispatches each worker with a *tiny* prompt that points at the worker
template + the task's manifest slice; it keeps only the returned JSON. It never builds/tests.

### 4. Run the pipeline
- **Stack:** each PR branches off the previous PR's branch (if unmerged, else the base
  branch); its PR base is that branch too (GitHub auto-retargets to the base on merge).
- **Concurrency:** keep up to N PRs in flight (N≈3); build ahead one at a time as slots free.
- **Gates:** optional *author pre-review* before the external reviewer, then reviewer handoff
  (assign + one-line ping **with the PR URL**). Pause the *affected task* (not the whole
  loop) on changes-requested.
- **Merges are fire-and-forget:** enable auto-merge / merge queue; **a slow queue is not a
  failure** — never impose a hard merge timeout. Only escalate on a genuine fault.
- **Finalize on merge:** close the sub-task, roll the story up when its last sub-task merges,
  remove the worktree.

## Pitfalls (learned the hard way)

| Pitfall | Do this |
|---|---|
| Two-dot diff inflates the fileset | Use `git diff main...BRANCH` (three-dot) |
| Reviewer drowns in "how it was migrated" | PR body = what it does + how it fits; never the extraction |
| Docs-only slice runs full build | Skip `rush`/build-test when no packages touched |
| Sub-task tracker transitions differ from stories | Verify transitions before scripting them |
| Merge-queue reports `autoMergeRequest=null` when healthy | Verify real queue membership before flagging a fault |
| Team `git b`/`git pr` aliases prompt interactively / spawn nested agents | Drive plain `git`/`gh`/tracker CLI directly in the worker |
| Building ahead of approval | Accept that upstream changes force rebasing stacked dependents |
| One giant agent runs out of context | Orchestrator holds only queue+progress; workers are disposable |

## Common mistakes
- Letting the orchestrator do a PR's build/test (context blows up) — always delegate.
- Waiting for merge before starting the next PR — pipeline on the merge-queue wait instead.
- Hard-stopping the whole queue on one stuck PR — pause just that task.
- Dropping files that don't fit a slice — flag them; the leftovers are usually a real gap.
