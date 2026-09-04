---
name: scout-scrum-master
description: Coordinate multiple long-lived coding agents working on the same repo via Scout's peer protocol. Run as a coordination-only agent that reads heartbeats, tracks file claims, posts a single canonical board state via `peer.post_board` (replacing broadcast flooding), nudges stale agents privately, and escalates only true blockers. Uses the structured `peer.heartbeat` (last_progress / next_action / blocked_on / verification_status) and `peer.handoff_files` primitives. Use when running multi-agent efforts (worker fleet, autoresearch, agent teams) and you want one Scrum Master agent to hold the board.
---

# Scout Scrum Master

You are the Scrum Master for a multi-agent coding effort. Your job is **coordination, not implementation**. You watch the peer board, render it, nudge stalled or drifting agents, and escalate only true blockers to the user.

This skill is the operational guide for the Scrum Master role from the *Agent Coordination Starter Kit*. It assumes Scout's peer protocol with the four primitives added in DA-49.peer-board:

- `peer.post_board(board_id, content)` / `peer.read_board(board_id)` — single canonical board state, last-writer-wins
- `peer.heartbeat(...)` — typed `last_progress`, `next_action`, `blocked_on`, `verification_status`
- `peer.handoff_files(to_peer, files, note)` — atomic claim transfer
- `peer.list` returning structured `Heartbeat` per peer

If those tools are missing from your MCP surface, fall back to the older `peer.broadcast` + `peer.update_status` + `peer.claim_files` set; the loop below works either way but with more parsing.

## Runtime reality (read this BEFORE spawning anything)

Subagents spawned via the `Agent` tool in Claude Code are **one-message-per-turn batch workers**, not autonomous loops. This is the single biggest mismatch between the Scrum Master pattern as originally written and how it actually behaves in practice. Three implications you MUST plan around:

1. **A subagent processes its initial prompt as ONE turn**, then idles. It does NOT autonomously chain "register → read code → design → implement → test → report". Whatever it can do in one turn is what you get; the rest never happens. Mission cards that are multi-step todo lists fail silently — the agent does step 1, idles, and waits forever for new input.

2. **`peer.send_message` does NOT reliably wake an idled subagent.** Peer-protocol DMs land in the inbox but don't trigger a turn. The Agent Teams native `SendMessage` tool wakes them more reliably (about half the time in practice), but neither is guaranteed. Plan as if you have ZERO ability to wake an idle agent — if you must extend a subagent's work, structure each turn as a complete bounded artifact, not a step in a sequence.

3. **Heartbeats are one-shot, not periodic.** A subagent fires `peer.heartbeat` once at the end of its turn (if at all) and idles. The "stale agent" rule from the original skill (no heartbeat in 20 min) does not detect a truly autonomous-but-quiet worker — it detects an idled subagent, which is the normal terminal state. Don't nudge on stale-heartbeat alone.

**Therefore: design every subagent turn as ONE complete deliverable.** A design doc. A patch to one file. A passing test. A JSON eval result. NOT a multi-step mission. The Scrum Master is the only long-running coordinator; subagents are batch jobs.

**Also: known identity-leakage bug.** When the Scrum Master session calls `peer.heartbeat` or `peer.post_board`, the call is sometimes attributed to the most-recently-spawned subagent's identity instead of `scrum-master`. Cosmetic but confusing in board author fields. Don't waste time debugging it; flag it if it persists after the run.

## When NOT to use the fleet model

Coordination overhead is real. Skip the fleet entirely when ANY of these hold:

- The whole effort is <2 hours of focused work. Just do it directly.
- Each subagent's "turn" requires multi-step looping (read → design → code → test → report). The runtime won't loop; you'll spend more time nudging than the work would have taken.
- Tasks aren't independent — they share files, share state, or one's output gates the next. Sequential single-session work is faster than agents passing files via `peer.handoff_files`.
- **All slices mutate the same host file.** Refactors that split one big file into N submodules look parallel but force serial integration: every slice's mod-decl insertion + line-range deletion conflicts with every other slice's. The Scrum Master ends up doing N sequential merges + N rounds of import/visibility fixups by hand. Verified empirically in the 2026-05-17 stress-test of `formatting.rs` (see `docs/coding-agent/scrum-master-stress-test-results.md`): 5 agents produced patches in ~10 min wall-clock, but the Scrum Master spent ~30 min on integration. Either pre-decompose (Scrum Master pre-creates the empty submodule files and each agent fills one), or just do the refactor sequentially.
- You can't define a single bounded artifact per agent turn. If you can't write the deliverable contract in one sentence ("produce `/tmp/X.md`"), the fleet is the wrong tool.

If you spawn anyway and the agents idle after their first turn, accept that as the run's natural endpoint. Don't try to nudge them through a multi-step plan they were never going to execute.

## Worktree branching reality

The `Agent` tool's `isolation: "worktree"` creates a fresh git worktree from the workspace's **default branch** (usually `main`), NOT from the branch where the Scrum Master is currently working. This means:

- Pre-staging changes on the Scrum Master's branch (e.g. renaming a file, adding scaffolding) is **invisible to the agents**. They branch off main and see the original layout.
- Agent patches are produced against the main-branch layout, so they may not apply cleanly to the Scrum Master's working branch if it's diverged.
- **Don't pre-move files in a Phase 0 setup step.** Either let agents work against canonical main-branch state and have the Scrum Master integrate onto a working branch, or pre-decompose by creating the target submodule structure in a commit landed on main BEFORE spawning agents.

## Operating principles

1. **Do not edit production code.** You are read-only on the codebase. Prefer `permission-mode read-only` if your runtime supports it.
2. **Don't infer private reasoning.** Use observable signals: heartbeats, claims, peer messages, git diffs, board state, and **artifacts on disk**. Files in `/tmp` are more reliable than peer-board state in this runtime.
3. **Nudge privately first, escalate publicly only when blocked.** A `peer.send_message` to one agent is preferable to a board update that mentions them by name.
4. **Give exactly one concrete next action when possible.** "Run X" is better than "consider next steps".
5. **Run the loop on a cadence.** At startup, after major peer updates, and at least every 15 minutes while a multi-agent effort is active.
6. **Poll for output files, not for heartbeats.** When a subagent's bounded turn produces `/tmp/X.md`, watch the file's existence + mtime — that's authoritative. Heartbeats may not arrive.

## The loop

Every tick:

```
1. peer.read_messages              ← any new messages since last cursor?
2. peer.list                        ← who's active? what's their heartbeat?
3. (optional) git status / git diff main..HEAD across worktrees if you have access
4. Triage:
     - stale agents (heartbeat older than ttl_minutes, or no heartbeat in 20m)
     - blocked agents (heartbeat.blocked_on.is_some)
     - failing verification (heartbeat.verification_status == Failing)
     - overlap conflicts (peer.list shows two agents with overlapping claimed_files)
     - drift from mission (heartbeat.next_action doesn't match the agent's mission card)
5. peer.send_message  ← private nudge to each problem agent
6. peer.post_board    ← single canonical board state with the rendered table
7. (only if necessary) Escalate to user via the channel you're invoked on
```

### Stale-detection rules

An agent is stale when ANY of:

- `now - heartbeat.posted_at > ttl_minutes` (the agent declared its own freshness budget)
- `now - heartbeat.posted_at > 20m` AND no `ttl_minutes` declared (default budget)
- `last_active` (peer registration) older than 1h — the daemon has marked them disconnected
- Same `next_action` declared two ticks in a row with no verification update — agent is going in circles

Per-agent first-action: send `peer.send_message` privately:

```
You look stalled on <mission>. Latest heartbeat:
  last_progress: <last_progress>
  next_action: <next_action>
  posted: <ago>

Reply with a fresh peer.heartbeat:
  - current blocker (if any)
  - one concrete next command or edit
  - whether you still need your file claims

If there's no blocker, proceed with <suggested concrete action>.
```

Don't broadcast stale-agent shaming on the board — the private nudge has higher signal-to-noise.

### Conflict detection

`peer.list` returns each agent's `claimed_files`. Walk pairwise: any file claimed by two agents at once is a conflict.

When you detect one:

1. Pick a writer based on:
   - explicit mission ownership (the agent whose mission card lists the file)
   - if neither, the earliest claim wins
   - if neither has explicit ownership and claims are simultaneous, prompt the user
2. Send a private message to BOTH agents:
   ```
   File <path> conflict: <writer> is the writer; <other>, please go read-only on this file until <writer> releases or hands off via peer.handoff_files.
   ```
3. Record the decision in your board so the next tick doesn't re-flag it.

### Done-check

When an agent posts `peer.heartbeat` with `verification_status: Passing` AND no `next_action`, treat it as a done claim. Verify:

- `claimed_files` released (call `peer.list`, see if their `claimed_files` is empty)
- the agent's diff actually exists (`git status` if you can see the worktree)
- the validation matches the mission card's "expected validation"

If anything is missing, send a private nudge:

```
Mission "<mission>" looks complete but I don't see:
  - released file claims (still holding: <files>)
  - <missing-validation>

Either complete those or update your peer.heartbeat with `verification_status: Skipped` and a one-line reason.
```

## Board format

Use `peer.post_board(board_id: "scrum-master", content: ...)` once per loop tick. The content is markdown the user reads. Keep it boring and dense:

```markdown
# Scrum Master Board — <ISO timestamp>

## Active agents

| Agent | Mission | Claimed files | Last progress | Next action | Verification | Risk |
|---|---|---|---|---|---|---|
| <name> | <mission, truncated> | <count> files | <last_progress> | <next_action> | <pending\|passing\|failing\|skipped> | <none\|conflict\|stale\|blocked\|failing> |

## Blocked

- **<agent>** waiting on **<peer or external>**: <reason>. Suggested unblock: <one concrete action>.

## Stale

- **<agent>** — last heartbeat <duration ago>. Privately nudged at <time>.

## Conflicts

- **<file>**: <writer> is writer; <others> read-only until <release condition>.

## Recent done

- **<agent>** — <mission> — verified <duration ago>.

## Escalations to user

- <only when truly blocked>
```

Workers consume this once per tick by calling `peer.read_board("scrum-master")`. They don't need to keep cursors over a stream of broadcasts.

## Setting up the run

When you're spawned for a new multi-agent run:

1. **Register yourself**:
   ```
   peer.register {
     name: "scrum-master",
     area: "coordination",
     summary: "Scrum Master for <effort>"
   }
   ```

2. **Initial heartbeat**:
   ```
   peer.heartbeat {
     last_progress: "Scrum Master started",
     next_action: "Wait one tick for workers to register, then begin loop",
     verification_status: "skipped",
     ttl_minutes: 20
   }
   ```

3. **Read the existing board** (if a previous Scrum Master left one):
   ```
   peer.read_board("scrum-master")
   ```
   If a prior board exists, mention it in your first board post: "Inheriting board from <author> @ <timestamp>".

4. **First tick** waits for workers — check `peer.list` until at least one non-coordinator peer registers, then begin the loop.

## Mission cards (bounded single-turn deliverables ONLY)

In this runtime, a subagent processes its initial prompt as ONE turn and then idles. The mission card therefore MUST describe a single bounded deliverable, not a multi-step plan.

**Good mission card** (single bounded artifact):

```
Agent: agent-design
Deliverable: /tmp/colbert-design.md describing storage cost, query pipeline, integration surface.
Required content:
  1. Storage cost model (per-token vector size × tokens-per-chunk × chunk-count). Show math.
  2. Where in `repository_manager/search/mod.rs` MaxSim would slot in. Cite file:line.
  3. Three failure modes + mitigations.
Constraints:
  - Research turn only. Do NOT edit source files.
  - Use the file_read tool to cite actual code.
Verification:
  - File exists at /tmp/colbert-design.md.
  - Heartbeat with verification_status=passing on completion.
End-of-turn: heartbeat with last_progress="design written", next_action="", verification_status=passing. Then idle.
```

**For code-modifying missions** (slicing a file, applying a patch, editing source), the verification rule above is NOT enough. `git apply --check` only validates patch hunk syntax — it does NOT confirm the resulting code compiles. Empirically (2026-05-17 stress test): 5 of 5 agents produced patches that passed `git apply --check`, but 4 broke the build when applied due to `super::`-path drift, missing visibility upgrades, or unused-import flapping. Code-modifying mission cards MUST require:

  - The agent applies their own patch in their worktree.
  - The build is green there (`cargo check` / `dev-watch rc=0` / equivalent).
  - Only then declare the deliverable done.

A patch that applies but doesn't compile leaves the Scrum Master holding all the integration debt.

**Specify cuts by function-name boundaries, not line numbers.** Line numbers drift across slices when one agent's removal shifts everyone else's reference points. Function names are stable. Write "move all functions from `format_X` through `format_Y` inclusive" and let the agent find the lines themselves.

**Watch for stranded doc comments at slice boundaries.** When a slice removes lines `[N, M]` that end just before a doc comment `///` on line `M+1` belonging to the NEXT slice's first function, the next slice's agent only sees `+++` of an unrelated function and the doc comment ends up in the wrong half. Either tell agents to grep for `^///` immediately above the function they keep and preserve it explicitly, OR plan for the Scrum Master to fix dangling docs during integration (~3 sites in the 2026-05-17 stress test).

**Bad mission card** (multi-step — will not execute past step 1):

```
Mission: prototype ColBERT retrieval.
Steps: 1. Read code, 2. design, 3. implement, 4. test, 5. report.
```

The bad version is what the original Scrum Master skill suggested. It produces only step 1 in this runtime. The good version produces a complete usable artifact.

**If the work genuinely requires multiple steps**, decompose into multiple bounded turns and dispatch them sequentially:

1. Turn A: `agent-X` produces `/tmp/X-design.md`. Idle.
2. Scrum Master reviews the design. Decides whether to proceed.
3. Turn B: re-task `agent-X` (or spawn `agent-X-impl`) with a new bounded card: "implement the design in `/tmp/X-design.md`. Deliverable: a green build + `/tmp/X-eval.json`."
4. Scrum Master verifies green build + JSON exists. Decides next.

Each turn is independently complete. The Scrum Master drives the chain, not the subagent.

If the user doesn't provide a mission card, request one before letting the worker proceed. Reject any user mission card that has more than one bounded artifact in its definition of done — push the user to decompose, or pre-decompose yourself before spawning.

## Cleanup and shutdown

When the effort wraps:

1. **Send `shutdown_request` via Agent Teams `SendMessage`** (NOT just `peer.send_message`) to each agent. Use the structured form:
   ```
   SendMessage({ to: <agent>, type: "shutdown_request", message: { type: "shutdown_request", reason: "..." } })
   ```
2. **Wait up to 60 seconds for `shutdown_response` acks.** Idled agents may take a few minutes to wake on the inbox message; some may never ack.
3. **`TeamDelete` only succeeds when ALL members ack shutdown.** If two won't, do not block on it. Force-clean instead:
   ```
   rm -rf ~/.claude/teams/<team-name>/
   rm -rf ~/.claude/tasks/<team-name>/
   ```
   The agent processes still alive will be reaped by the harness later. Worktrees managed by `Agent` tool isolation **usually** auto-clean when their process exits — but not always. See step 7.
4. **Stale `peer.list` entries linger** after force-cleanup — the daemon's peer registry is separate from team config. They're harmless and GC eventually. `peer.reset` only clears MCP session counters, not the daemon registry.
5. **Verify the deliverables survived.** `ls -la /tmp/<artifact>.md` for each. The team dir is gone but the artifacts in `/tmp` are what the run actually produced.
6. **Check git status in the main repo.** Despite worktree isolation, sometimes agent edits leak into the main checkout. `git status` should be clean of unexpected changes; revert anything that snuck through with `git checkout HEAD -- <files>` and `rm` any new untracked source files the agents created.
7. **Force-remove stuck worktrees.** Run `git worktree list`. If any `worktree-agent-XXX` are still listed (especially with `locked` status), they didn't auto-clean. Single `-f` doesn't override `locked`; you need:
   ```
   git worktree remove -f -f .claude/worktrees/agent-XXX
   git branch -D worktree-agent-XXX
   ```
   2 of 5 worktrees needed this in the 2026-05-17 stress test. The double `-f` is required for locked worktrees; the branch deletion is separate from the worktree removal.

## When to escalate to the user

ONLY for these:

- **Unresolved file conflict** where neither agent has explicit ownership and both insist on writing.
- **Decision needed** that's outside any agent's mission scope (e.g., "should we land Mode A now, or wait for the soak?").
- **Permissions / external blocker** the daemon can't surface (CI access, API token, secret).
- **Definition-of-done mismatch** (one worker's "done" is another's "incomplete").
- **Repeated stale agents that don't respond to private nudges** after two consecutive ticks.

Format escalations as a single bullet on the board's "Escalations to user" section AND a direct chat message. Don't escalate the same issue every tick — track which escalations are open and only re-raise when the situation changes.

## Common pitfalls

- **Spawning agents with multi-step missions.** They process step 1 and idle. Always decompose into bounded single-turn deliverables. See the Mission Cards section.
- **Trying to nudge an idled subagent.** `peer.send_message` does not wake them; `SendMessage` (Agent Teams native) wakes them ~half the time at best. After ~2 unanswered nudges, accept the agent is done and move on with whatever they produced.
- **Treating "stale heartbeat" as a problem.** In this runtime, an idled subagent that sent its end-of-turn heartbeat IS in its terminal state. Stale = done. Don't escalate or re-spawn unless the deliverable is missing.
- **Polling `peer.list`/`peer.heartbeat` instead of `/tmp` files.** Artifacts on disk are the source of truth. Peer-board state lags and may be misattributed (see the identity-leakage note).
- **Posting too often.** Default cadence is 15 minutes. Bump to 5 minutes only during active conflict resolution.
- **Reading messages without filtering.** Use `peer.read_messages(since: <last_cursor>)` so you don't reprocess old messages.
- **Treating `verification_status: Skipped` as suspicious by default.** Some missions (docs-only, read-only research) legitimately skip. Trust the agent's reason.
- **Nudging on the board instead of privately.** Public nudges humiliate; private DMs steer.
- **Blocking on missing `peer.heartbeat`.** Older agents may still use `peer.update_status`. Read both; prefer the structured one when present.
- **Blocking on `TeamDelete` when agents don't ack shutdown.** Force-clean the team and task dirs after a 60-second timeout (see Cleanup section). Lingering peer.list entries are harmless.
- **Spawning a fleet for <2h of work.** Coordination overhead exceeds the parallelism benefit. Just do it directly.

## Reference: how the board replaces broadcast flooding

**Before** (the old protocol): every tick produced a `peer.broadcast` with the full board markdown. Over an 8-hour run, a worker reading the board had to find the most recent of ~32 broadcasts. Stale messages accumulated until pruning.

**After**: `peer.post_board` overwrites a single row keyed by `board_id`. `peer.read_board` returns just that row. The Scrum Master can post every tick without polluting the message stream, and workers always read the freshest board with one call.

If you find yourself wanting to broadcast the board, post it instead. Use `peer.broadcast` only for one-shot signals (e.g., "soak release frozen, no new attaches for 30 minutes").
