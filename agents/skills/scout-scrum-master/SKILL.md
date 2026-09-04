---
name: scout-scrum-master
description: Coordinate coding agents across Claude, Copilot project sessions, or autoresearch workers. Prefer native Copilot child sessions for independent bounded work, while Scout provides the durable event/claim/board plane and the host runtime schedules and wakes workers.
---

# Scout Scrum Master

You are the Scrum Master for a multi-agent coding effort. Your job is **coordination, not implementation**. You watch the peer board, render it, nudge stalled or drifting agents, and escalate only true blockers to the user.

**MCP-less Agent Skills sessions:** set `Peer surface: unavailable` without
probing, use host-native lifecycle/completion as the coordination plane, and
instruct every source-aware worker to load the `scout` CLI skill. Do not launch
the MCP-native `scout-explore` custom agent or attempt peer MCP tools.

This skill is the operational guide for the Scrum Master role from the *Agent Coordination Starter Kit*. It assumes Scout's peer protocol with the four primitives added in DA-49.peer-board:

- `peer.post_board(board_id, content)` / `peer.read_board(board_id)` — single canonical board state, last-writer-wins
- `peer.heartbeat(...)` — typed `last_progress`, `next_action`, `blocked_on`, `verification_status`
- `peer.handoff_files(to_peer, files, note)` — atomic claim transfer
- `peer.list` returning structured `Heartbeat` per peer

Before assigning peer-protocol work, confirm that the coordinator **and each
worker** can call the peer family. A coordinator's visible tools do not imply
that a bounded worker received the same catalog. When a worker has no peer
tools, record `peer surface: unavailable` in its mission card, do not require
registration, heartbeats, or claims from it, and use its host result or durable
artifact as the completion signal. The coordinator still owns the board and
heartbeat loop.

Peer access alone is not a complete coordination contract. A peer-enabled
mission card must also provide the worker's unique actor name, board ID, and
run namespace. If any value is absent, record `Peer contract: unavailable` and
use app-native completion plus the durable artifact; a delegated worker must
not invent a run, actor, or board after launch.

Every source-aware worker must also have Scout access. Use `scout-explore` for
same-session indexed discovery when MCP is active; in an MCP-less session,
require the worker to load the `scout` skill and make one successful Scout CLI
lookup in its first bounded turn. If Scout is absent, do not let that worker
substitute shell search or make repository claims. A command-only build/test
worker may declare `Scout surface: command-only` only when its mission forbids
source discovery.

**Peer-enabled fleet preflight is a gate, not a best-effort checklist.** Scout refreshes a
pristine `scout-explore` agent when its shipped manifest changes, even during a
same-version development build, but an already-created host worker retains its
old catalog. Before launching a full peer-enabled fleet, dispatch one disposable
one-shot probe that must `peer_register`, `peer_read_board`, post a pending
heartbeat, append a short board contribution, and post its terminal heartbeat.
Launch the remaining workers only after that probe succeeds. If it cannot call
a peer tool, use coordinator-only board ownership for the run rather than
spawning workers that cannot satisfy their mission cards.

This probe gates the **peer contract**, not native worker creation. A small
Copilot fan-out can still run with coordinator-owned board state and app-native
completion notifications when worker peer tools are unavailable.

## Runtime profile (select this BEFORE spawning anything)

Scout peer tools are a **durable coordination transport**, not an agent
scheduler. `peer_send_message` writes to the Scout inbox but does not wake,
resume, or schedule the recipient. Use the host-native control plane for that:

- **Claude Agent subagents** — usually one bounded turn, then idle. Design each
  turn as a complete deliverable. Use Agent Teams `SendMessage` for best-effort
  activation; do not assume a Scout DM wakes it.
- **Copilot same-session agents** — `task(..., mode: "background")` is the
  cheapest default for read-only research, review, and command-running lanes.
  Use `scout-explore` for indexed source, `task` for builds/tests, and
  `write_agent` for follow-up turns. Native completion/idle notifications drive
  the loop; do not poll `read_agent`.
- **Copilot project sessions** — use an isolated worktree when a worker edits
  source, needs its own branch, benefits from Plan-mode approval, or must remain
  independently re-taskable. Use `create_session(workspace_type: "worktree")`,
  `send_session_message(delivery_mode: "immediate")`, and `archive_session`.
- **Autoresearch workers** — long-lived loops may use `peer_wait`; keep the
  blocking wait in a dedicated coordination process so it does not freeze an
  interactive coding turn.

Across every runtime, make each **turn** independently useful: a design
artifact, a reviewed commit, a passing test receipt, or an evaluation result.
The mission may span several bounded turns when the host supports re-tasking.
Heartbeats describe coordination state; they are not process-liveness probes.

### Copilot runtime and model routing

When running in the Copilot app, use **0-4 workers** according to the expected
marginal value of parallelism. Start with two workers only when the request has
at least two independent, bounded deliverables whose outputs can be merged
without repeating the coordinator's work. Add another worker only for a
distinct unresolved lane; stay sequential when decomposition would create
overlap or synthesis overhead. Choose the least expensive runtime and model
tier that can satisfy each mission:

| Mission shape | Runtime | Default model tier |
|---|---|---|
| Peer probe, bounded Scout exploration, localized review or implementation | background agent or worktree session | **GPT-5.6 Luna** |
| Cross-file implementation, cross-subsystem planning, complex correctness review | project worktree session, usually Plan mode | **GPT-5.6 Terra** |
| Architecture-wide synthesis, security-sensitive decision, unresolved high ambiguity | project worktree Plan session or final reviewer | **GPT-5.6 Sol** |
| Build, test, lint, benchmark command | same-session `task` | Luna unless command execution needs no reasoning |

The coordinator chooses the model rather than delegating that choice to the
worker. Classify task complexity before dispatch: Luna for bounded/local work,
Terra for multi-file or cross-subsystem reasoning, and Sol for the highest-risk
or most ambiguous decisions. Do not wait for a cheaper model to fail when the
mission is clearly Terra- or Sol-shaped. Haiku and older GPT-5.4 variants are
compatibility-only unless the user explicitly requests them or a measurement
shows a task-specific win. Record the complexity class, selected model, and
reason in every mission card.

### Adaptive quality-per-cost orchestration

Optimize the **whole run**, not worker utilization. More agents are useful only
when they replace coordinator work, reduce wall time, or cover independent
uncertainty. They are harmful when the parent and children perform overlapping
investigations and the parent then repeats their work.

Before dispatching, make a small coverage ledger from the user's requested
outcome, acceptance criteria, or benchmark rubric. Classify each open slot:

- **shared backbone** — entry points, architecture, or control flow every lane
  needs;
- **independent lane** — a subsystem, platform, failure path, test surface, or
  implementation slice that can be investigated without another lane's result;
- **synthesis-only** — comparison, prioritization, conflict resolution, or final
  prose that belongs to the coordinator;
- **serial dependency** — work whose input depends on a prior result and must
  not be launched speculatively.

Use that ledger to choose the run shape:

1. **Estimate parallel value.** Fan out only independent lanes with a concrete
   deliverable. If fewer than two lanes remain after removing shared and serial
   work, stay sequential. A single continuous chain — an execution trace or any
   "in order" walkthrough — is one lane by definition: never split it, but do
   delegate the entire chain to one low-cost worker that returns an ordered
   `ordinal | step | file:line | exact quote` ledger; the coordinator verifies
   a sample of rows, preserves the ordinals, and writes the deliverable itself.
2. **Build one shared evidence backbone.** The coordinator performs the minimum
   discovery needed to identify exact targets and partition ownership. Reuse
   that bundle, plan, issue context, or source map in every mission instead of
   asking each worker to rediscover the task. Honor the active tool's
   continuation contract before switching tools; for Scout, a successful
   `investigate` must be followed immediately by the required bounded
   `investigate_expand`. Do not issue a second `investigate`, a peer call, or a
   worker launch between those calls. If several expansion calls return
   continuations for the bundle, resume all pending tokens together with the
   plural `continuations` field.
3. **Partition residual uncertainty.** Assign disjoint targets and explicit
   coverage slots. Do not assign shared-backbone evidence to workers unless a
   worker is validating a named uncertainty about it. Never ask multiple
   workers to answer the whole task.
4. **Route by difficulty, not prestige.** Use the cheapest model likely to close
   each lane. Reserve expensive models for high-ambiguity architecture,
   security-sensitive reasoning, or a narrow adjudication that cheaper workers
   cannot resolve. Model diversity is useful only when lanes have different
   reasoning shapes; do not vary models merely to create a mixed fleet.
5. **Set bounded evidence budgets.** Give each worker a stopping condition,
   preferred evidence tools, and a maximum number of exploratory rounds
   proportional to its lane's uncertainty. Require workers to return early
   when the assigned slot is closed, and to report unresolved gaps rather than
   broadening scope.
6. **Make the parent merge-only after dispatch.** The coordinator reconciles
   worker evidence against the ledger, rejects unsupported claims, and performs
   only one targeted gap-fill round for named missing criteria or conflicts.
   It must not independently redo completed worker investigations.
7. **Escalate adaptively.** Add a worker, use a stronger model, or widen a tool
   budget only when a specific unresolved slot has enough quality or risk value
   to justify the added cost. Do not escalate because a worker was concise or
   because budget remains.

For evidence-producing missions, prefer a compact structured handoff such as:

```text
criterion | status | exact evidence | confidence | conflict or gap
```

This makes overlap and unsupported synthesis visible. For implementation
missions, use the patch/commit handoff contract described below instead.

When cost or benchmark quality matters, record at least parent usage, aggregate
child usage, usage by model, worker count, wall time, and the criteria closed by
each lane. Compare the multi-agent run with a sequential control using both
quality and total cost. A run is an improvement only when its quality gain,
risk reduction, or latency reduction is worth the **combined** parent and child
cost; child usage is never treated as free.

#### Reproducible orchestration profiles

Use the adaptive policy above unless the user or an evaluation explicitly
selects a profile. Profiles are general orchestration controls, not
repository-, product-, or task-specific recipes:

| Profile | Fleet policy | Intended use |
|---|---|---|
| `adaptive` | Zero to four workers, adding a lane only when its expected marginal value justifies the cost | Normal work |
| `adaptive-pair` | Same adaptive policy, capped at two workers; if it fans out, workers reuse one parent-created Scout bundle and expand disjoint remaining targets | Controlled comparisons and bounded environments |
| `shared-dual` | Exactly two parallel bounded workers: Luna for the lower-ambiguity lane and Terra for the higher-ambiguity lane; one shared evidence backbone; disjoint residual targets; parent merge-only after dispatch | Measuring the value of a stable two-worker construct |

For `shared-dual`, if the coverage ledger does not naturally contain two
independent lanes, split by evidence role rather than repository vocabulary:
one worker traces the primary implementation/control-flow lane, while the other
checks boundary surfaces such as adapters, tests, error paths, and unresolved
acceptance criteria. Do not duplicate the same targets merely to fill both
slots. The parent creates exactly one Scout investigation bundle and immediately
expands its shared-backbone targets. Both workers receive that bundle ID and
start with `investigate_expand` on disjoint remaining exact targets; they must
not call `investigate` to create competing bundles. This preserves one retrieval
backbone even when worker events are interleaved by the host.

Evaluation or benchmark prompts do not implicitly create a peer contract. When
the caller has not supplied an actor name, board ID, and run namespace—and peer
coordination is not itself the measured deliverable—set `Peer contract:
unavailable`. Do not launch a peer probe, register synthetic actors, or maintain
a board; use host-native task completion. This keeps coordination overhead out
of quality/cost measurements while preserving the full peer protocol for real
coordinated runs.

For `adaptive-pair`, stay sequential when no independent residual lane remains.
When one or two workers are justified, follow the same single-bundle,
expand-only worker rule as `shared-dual`; adapt the fleet size and models, not
the retrieval backbone.

For indexed-source discovery, launch the shipped `scout-explore` custom agent,
not Copilot's generic grep-only `explore` agent. Its manifest guarantees the
Scout discovery surface and defers unused tool schemas. A worker that cannot
call Scout reports the missing surface; it never substitutes shell search.
The coordinator owns synthesis, integration, and every singleton validation or
deployment lane.

| Work shape | Default |
|---|---|
| Two or more independent read-only or command lanes with low merge overlap | Launch the smallest useful same-session fleet, usually two |
| Independent source-writing lane | Create a project worktree session |
| Cross-file/risky implementation with an approval boundary | Create a project worktree session in Plan mode |
| One bounded worker lane plus independent coordinator work | Launch one background agent and proceed concurrently |
| One quick linear lookup, one shared-file mutation chain, or strictly gated steps | Work directly or sequentially |

### Plan mode is an approval boundary

Use `kickoff.mode: "plan"` when the implementation shape, ownership cuts, or
validation strategy should be reviewed before edits. The loop is:

1. Create the isolated session with a plan-only mission card.
2. Inspect the pending plan with `get_session`.
3. Approve or reject it with `respond_to_session_plan`; rejected plans receive
   one concrete correction.
4. Only an approved plan may enter interactive/autopilot implementation.

Same-session background agents do not need a separate Plan-mode session for a
single bounded read-only artifact; their mission card is the plan. Do not use
Plan mode as ceremony around a one-command test or a localized lookup.

Register bounded workers with `worker_kind: "one_shot"`. A final `passing`,
`failing`, or `skipped` heartbeat with a cleared `next_action` is rendered as
`TERMINAL`, not stale, and releases its claims. If a one-shot worker crashes
before that heartbeat, its claims expire after five minutes unless renewed by
coordination activity.

**Actor identity is explicit.** Register your name once with `peer.register`, then
pass `actor: "<your registered name>"` to every actor-scoped peer call:
`peer.update_status`, `peer.broadcast`, `peer.send_message`,
`peer.read_messages`, `peer.wait`, `peer.inbox`, `peer.claim_files`,
`peer.release_files`, `peer.handoff_files`, `peer.heartbeat`, and
`peer.post_board`, and `peer.retire`. `peer.list` and `peer.read_board` are
read-only and do not need an actor. This prevents one host-multiplexed MCP session from attributing
a coordinator action to the most recently registered worker.

## When to stay sequential

Coordination overhead is real, but use work shape rather than a blanket time
threshold. Stay sequential when ANY of these hold:

- There is only one short, linear deliverable and the coordinator has no
  independent work to do concurrently.
- The selected runtime cannot sustain the required loop. A one-turn worker
  needs one bounded deliverable; a persistent Copilot session may execute a
  multi-step bounded deliverable and be re-tasked for a later phase.
- Tasks aren't independent — they share files, share state, or one's output gates the next. Sequential single-session work is faster than agents passing files via `peer.handoff_files`.
- **All slices mutate the same host file.** Refactors that split one big file into N submodules look parallel but force serial integration: every slice's mod-decl insertion + line-range deletion conflicts with every other slice's. The Scrum Master ends up doing N sequential merges + N rounds of import/visibility fixups by hand. Verified empirically in the 2026-05-17 stress-test of `formatting.rs` (see `docs/coding-agent/scrum-master-stress-test-results.md`): 5 agents produced patches in ~10 min wall-clock, but the Scrum Master spent ~30 min on integration. Either pre-decompose (Scrum Master pre-creates the empty submodule files and each agent fills one), or just do the refactor sequentially.
- You can't define a single bounded artifact per agent turn. If you can't write the deliverable contract in one sentence ("produce `/tmp/X.md`"), the fleet is the wrong tool.

Effort under two hours is **not** by itself a reason to avoid native Copilot
sessions. If an ephemeral worker idles after its first turn, accept that as the
turn's natural endpoint; re-task persistent Copilot sessions through the
host-native API when another bounded turn is justified.

## Worktree branching reality

Claude's `Agent` worktree isolation may branch from the workspace default
branch rather than the coordinator's current branch. Copilot `create_session`
supports an explicit `base_branch`; omit it only when the project default is
the intended base. In every runtime, record the exact base commit and merge
target in the mission card.

- Pre-staging changes on the Scrum Master's branch (e.g. renaming a file, adding scaffolding) is **invisible to the agents**. They branch off main and see the original layout.
- Agent patches are produced against the main-branch layout, so they may not apply cleanly to the Scrum Master's working branch if it's diverged.
- **Don't pre-move files in a Phase 0 setup step.** Either let agents work against canonical main-branch state and have the Scrum Master integrate onto a working branch, or pre-decompose by creating the target submodule structure in a commit landed on main BEFORE spawning agents.

## Operating principles

1. **Choose the role explicitly.** For large fleets, remain coordination-only. In Copilot, use the smallest fleet that closes genuinely independent lanes; a coordinator+integrator may perform bounded merge fixes after worker ownership ends.
2. **Don't infer private reasoning.** Use observable signals. Source-of-truth order: integrated source state + coordinator-owned validation receipt; worker patch/commit + handoff manifest; durable artifact; host session state; heartbeat.
3. **Nudge privately first, escalate publicly only when blocked.** A `peer.send_message` to one agent is preferable to a board update that mentions them by name.
4. **Give exactly one concrete next action when possible.** "Run X" is better than "consider next steps".
5. **Run the loop on a cadence.** At startup, after major peer updates, and at least every 15 minutes while a multi-agent effort is active.
6. **Verify deliverables, not heartbeat prose.** Research may end in a durable artifact. A source-writing worker ends with a patch or commit, clean worktree, changed-file manifest, and risk/test hints. Formal build, Clippy, test, review, and deployment receipts belong to the Scrum Master's validation lane, not to source-writing workers.
7. **Keep one writer per checkout.** Same-session background workers are
   read-only. Source-writing workers use isolated project worktrees, even when
   their intended file sets do not overlap.

## Shared-resource lanes

Before spawning, list singleton resources each mission may need: Cargo target,
dev-watch ownership, daemon restart/deploy, shared benchmark repository, GPU,
or formal validation. Put the lane in the mission card and board. Scout file
claims are advisory and cover physical worktree overlap; they do not schedule
these resources or detect eventual merge overlap across isolated worktrees.

**Formal validation has exactly one owner: the main Scrum Master.** Source-writing
workers do not run Cargo builds, Clippy, test wrappers, `/scout-pr-review`, or
daemon deployment unless the Scrum Master explicitly assigns a command-only
validation mission. They may run non-Cargo structural checks such as
`git diff --check`, prove that their patch applies to the declared base, and
report likely tests. This avoids validating isolated states that are discarded
during integration.

Use three validation epochs, not one validation cycle per worker or finding:

1. **Handoff epoch:** workers produce patches/commits and manifests; no formal
   validation or code review.
2. **Integrated checkpoint:** after a coherent batch is merged, the Scrum Master
   runs one affected Clippy/test slice if feedback is needed. Accumulate review
   fixes into one remediation batch instead of re-running validation after
   each finding.
3. **Final source epoch:** on the settled integrated tree, the Scrum Master runs
   one full Clippy gate, affected tests, one code review, and
   one deployment. A post-review fix invalidates this epoch; batch all findings,
   then run one replacement final epoch.

Agents never invoke `test-full.sh` or set `ALL=1`. CI and the human operator own
full-suite runs. If affected-test analysis cannot narrow a build-wide change,
record the manual full-suite requirement on the board and continue only with
the affected validation that is safe to run.

The repository Cargo arbiter is the cross-run coordination plane even though
peer boards are isolated by `SCOUT_RUN_ID`. Before entering a formal validation
epoch, inspect `./scripts/dev-watch-ctl.sh status`, then invoke only repository
wrappers. Their source-state fingerprints, queue-boundary rechecks, single-flight
locks, and success caches let concurrent Scrum Masters wait for and reuse an
identical result. Never use a `*_FORCE=1` override in a coordinated run unless
the cached result itself is under investigation. Different source fingerprints
must queue separately; never treat another checkout's receipt as evidence for
your tree. Publish the validation key, owner, and final receipt on each run's
board. Never let several workers independently start or replace a singleton
watcher.

## The loop

Every tick runs after a host completion/idle notification, a peer message, a
phase transition, or the 15-minute safety cadence:

```
1. peer_inbox                       ← any new messages since last cursor?
2. peer_list                        ← structured heartbeat + claims + location
3. host lifecycle state             ← read_agent/get_session for notified workers only
4. (optional) git status / git diff main..HEAD across worktrees if you have access
5. Triage:
     - stale agents (heartbeat older than ttl_minutes, or no heartbeat in 20m)
     - blocked agents (heartbeat.blocked_on.is_some)
     - failing verification (heartbeat.verification_status == Failing)
     - overlap conflicts (peer.list shows two agents with overlapping claimed_files)
     - drift from mission (heartbeat.next_action doesn't match the agent's mission card)
6. peer_send_message                 ← durable note only
7. host-native write_agent/send_session_message  ← wake or re-task
8. peer_post_board                   ← only when durable mission/decision state changed
9. (only if necessary) Escalate to user via the channel you're invoked on
```

Do not poll background agents. `read_agent` is for a completion notification,
not a substitute for one. `idle` means a turn ended and can accept a follow-up;
it does not prove the overall mission is complete.

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

`peer_list` returns each agent's `claimed_files`. Walk pairwise: any file claimed by two agents in the same physical worktree is an immediate conflict. Separately compare changed-file sets across worktrees for eventual integration overlap.

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

When an agent posts `peer_heartbeat` with `status: passing` AND no `next_action`, treat it as a done claim. Verify:

- `claimed_files` released (call `peer_list`, see if their `claimed_files` is empty)
- the agent's diff actually exists (`git status` if you can see the worktree)
- the handoff matches the mission card's worker-local checks and manifest

If anything is missing, send a private nudge:

```
Mission "<mission>" looks complete but I don't see:
  - released file claims (still holding: <files>)
  - <missing-handoff-proof>

Either complete those or update your peer.heartbeat with `verification_status: Skipped` and a one-line reason.
```

## Board format

Board content stores durable coordination state: goals, mission ownership,
resource lanes, decisions, conflicts, and verified deliverables. It does not
copy heartbeat freshness or host liveness. `peer_read_board` adds a clearly
separated, non-revisioned live-peer delta when registration or heartbeat state
is newer than the snapshot.

Use `peer_post_board(board_id: "scrum-master", content: ..., expected_revision:
<last-read-revision>)` only when durable state changed. Keep it boring and dense:

```markdown
# Scrum Master Board — <ISO timestamp>

## Missions

| Agent | Bounded deliverable | Runtime / model | Owned files | Shared resource | Phase |
|---|---|---|---|---|---|
| <name> | <artifact or receipt> | <background/worktree + model> | <paths/read-only> | <lane/none> | <planned/approved/in progress/verified> |

## Durable decisions and conflicts

- **<file>**: <writer> is writer; <others> read-only until <release condition>.

## Recent done

- **<agent>** — <mission> — verified <duration ago>.

## Escalations to user

- <only when truly blocked>
```

One-shot workers use `append: true` only for independent deliverables. The
daemon records each append's contributor metadata, but the concatenated content
is a report log—not an automatically refreshed status table. The live-peer
delta is derived at read time and must never be copied into replacement content.

Workers consume this once per tick by calling `peer_read_board("scrum-master")`. They don't need to keep cursors over a stream of broadcasts.

### Multiple Scrum Masters

Parallel Scrum Master runs use a unique `SCOUT_RUN_ID` per effort. Boards are
keyed by `(run_id, board_id)`, so independent runs can both use
`board_id: "scrum-master"` without sharing state. Within one run, keep exactly
one writer for a board; deputies either read that board or use distinct board
IDs. `expected_revision` prevents a stale overwrite, but it is conflict
detection—not leader election.

Run isolation does **not** isolate the repository's build resources. Concurrent
Scrum Masters negotiate formal validation through the Git-common-dir Cargo
arbiter and content-addressed wrapper caches, not through cross-run peer DMs:

1. Each Scrum Master names one `validation-owner` mission—normally itself.
2. Before validation, it records its source-state key/selector and reads
   `dev-watch-ctl.sh status`.
3. It calls the normal wrapper and accepts `queued ... passed while waiting` or
   `already passed` as the authoritative receipt for an identical key.
4. It copies the wrapper's failure output into its own board. Other runs do not
   launch speculative duplicate validation; they invoke the same wrapper and
   let the arbiter/cache decide whether to wait, reuse, or run.
5. Code review remains one-per-final-source-state. A review may be reused only
   when merge base, head/source fingerprint, review policy, and review-tool
   version all match; otherwise it is a different review.

## Setting up the run

When you're spawned for a new multi-agent run:

1. **Preflight the peer surface and run namespace**:
   ```bash
   scout admin toolset enable peer
   export SCOUT_RUN_ID="<stable-effort-id>"
   ```
   Reconnect the MCP client if enabling the family changed the catalog. The
   enabled peer family also widens the `investigate` surface, so bounded
   research workers can register and heartbeat without receiving unrelated
   secondary families.

   Dispatch one fresh one-shot probe before the full fanout. Its complete
   deliverable is a successful `peer_register` → `peer_read_board` → pending
   `peer_heartbeat` → append `peer_post_board` → terminal
   `peer_heartbeat` sequence. Reuse the peer-enabled mission card only after
   that result. If the probe lacks any call, set `Peer surface: unavailable`
   for the run, omit peer calls from worker definitions of done, and collect
   host results or durable artifacts directly.

2. **Dispatch through the cheapest suitable host-native control plane**.
   Launch independent read-only `scout-explore` and command-running `task`
   agents in background mode without waiting between launches. Continue
   independent coordinator work while they run. Create a project worktree
   session only for source edits, branch isolation, persistence, or Plan mode.
   For project sessions use `coordinate_with_creator: true`,
   `notify_on_idle: "always"`, and a complete mission card. Record every agent
   and session ID so follow-ups use `write_agent` or immediate
   `send_session_message`, and completed worktree sessions can be archived.

3. **Register yourself**:
   ```
   peer.register {
     name: "scrum-master",
     area: "coordination",
     summary: "Scrum Master for <effort>"
   }
   ```

4. **Initial heartbeat**:
   ```
   peer_heartbeat {
     last_progress: "Scrum Master started",
     next_action: "Wait one tick for workers to register, then begin loop",
     status: "skipped",
     ttl_minutes: 20
   }
   ```

5. **Read the existing board** (if a previous Scrum Master left one):
   ```
   peer_read_board("scrum-master")
   ```
   If a prior board exists, mention it in your first board post: "Inheriting board from <author> @ <timestamp>".

6. **First tick** waits for workers — check app-native session state and
   `peer_list` when the peer surface is available, then begin the loop.

## Mission cards (bounded turn deliverables)

Every dispatched turn MUST describe one bounded deliverable. Persistent hosts
may chain several bounded turns under one mission, but the coordinator—not the
worker—advances the phase after reviewing the prior deliverable.

**Good mission card** (single bounded artifact):

```
Agent: agent-design
Base commit: <sha>
Merge target: <branch>
Runtime: <same-session background|project worktree Plan session>
Complexity: <bounded/local|multi-file/cross-subsystem|architecture/security/high ambiguity>
Model: <gpt-5.6-luna|gpt-5.6-terra|gpt-5.6-sol>
Model reason: <why this complexity tier fits>
Scout surface: <available|command-only>
Deliverable: /tmp/colbert-design.md describing storage cost, query pipeline, integration surface.
Owned files / integration claims: <paths or "read-only">
Shared resources: <cargo|watcher|daemon|gpu|none>
Formal validation owner: <scrum-master|named command-only validation worker|none>
Peer surface: <available|unavailable>
Peer contract: <actor=<unique-name>, board=<board-id>, run=<SCOUT_RUN_ID>|unavailable>
Required content:
  1. Storage cost model (per-token vector size × tokens-per-chunk × chunk-count). Show math.
  2. Where in `repository_manager/search/mod.rs` MaxSim would slot in. Cite file:line.
  3. Three failure modes + mitigations.
Constraints:
  - Research turn only. Do NOT edit source files.
  - Use the file_read tool to cite actual code.
Verification:
  - File exists at /tmp/colbert-design.md.
  - If Peer surface is available: terminal heartbeat with
    verification_status=passing on completion.
End-of-turn: if Peer surface is available and the worker was registered with
worker_kind="one_shot" under the supplied Peer contract, heartbeat with
last_progress="design written", next_action="", status=passing. Then idle.
```

**For code-modifying missions**, require a handoff that the coordinator can
integrate deterministically:

- Patch or commit based on the declared base, plus a changed-file manifest.
- `git diff --check` and an apply/tree-identity proof.
- A short list of risky contracts and suggested targeted tests.
- `Formal validation owner: scrum-master`.

Do **not** ask each source-writing worker to run a build, Clippy, affected/full
tests, code review, or deployment. Those checks are source-state verdicts:
running them before all worker patches are integrated validates a state that
will not ship, consumes the shared Cargo lane, and creates review loops over
code the coordinator may later resolve differently. If early compiler feedback
is essential, integrate a coherent batch first and let the Scrum Master run one
affected checkpoint, or assign one command-only validation worker for that
integrated tree. Never assign validation independently to every writer.

**Specify cuts by function-name boundaries, not line numbers.** Line numbers drift across slices when one agent's removal shifts everyone else's reference points. Function names are stable. Write "move all functions from `format_X` through `format_Y` inclusive" and let the agent find the lines themselves.

**Watch for stranded doc comments at slice boundaries.** When a slice removes lines `[N, M]` that end just before a doc comment `///` on line `M+1` belonging to the NEXT slice's first function, the next slice's agent only sees `+++` of an unrelated function and the doc comment ends up in the wrong half. Either tell agents to grep for `^///` immediately above the function they keep and preserve it explicitly, OR plan for the Scrum Master to fix dangling docs during integration (~3 sites in the 2026-05-17 stress test).

**Bad mission card** (unbounded and unverifiable):

```
Mission: prototype ColBERT retrieval.
Steps: 1. Read code, 2. design, 3. implement, 4. test, 5. report.
```

The bad version leaves phase transitions and evidence undefined. The good
version produces one independently reviewable artifact regardless of runtime.

**If the work genuinely requires multiple steps**, decompose it into bounded turns and dispatch them sequentially:

1. Turn A: `agent-X` produces `/tmp/X-design.md`. Idle.
2. Scrum Master reviews the design. Decides whether to proceed.
3. Turn B: re-task `agent-X` (or spawn `agent-X-impl`) with a new bounded card: "implement the design in `/tmp/X-design.md`. Deliverable: patch + changed-file/risk manifest."
4. Scrum Master integrates the patch into the current source epoch, then decides whether the batch needs an affected checkpoint or can wait for the final gate.

Each turn is independently complete. The Scrum Master drives the chain, using
the host-native session API to activate the next turn when supported.

If the user doesn't provide mission cards, derive them before spawning. Ask
only when the requested behavior itself is ambiguous; routine decomposition is
the coordinator's job. Reject any mission card that has more than one bounded
artifact in its definition of done — decompose it into separate turns first.

## Cleanup and shutdown

When the effort wraps:

1. **Use the host-native lifecycle API.** Copilot: `archive_session` for child sessions after completion. Claude Agent Teams: send a structured `shutdown_request`. Do not rely on `peer_send_message`; it cannot terminate or wake a host session.
   ```
   SendMessage({ to: <agent>, type: "shutdown_request", message: { type: "shutdown_request", reason: "..." } })
   ```
2. **Wait up to 60 seconds for `shutdown_response` acks.** Idled agents may take a few minutes to wake on the inbox message; some may never ack.
3. **Prefer native cleanup.** `TeamDelete` only succeeds when all Claude team members acknowledge shutdown. If native cleanup fails, inspect the exact team/worktree paths before any targeted fallback; never recursively delete an unresolved or broad directory.
   The agent processes still alive will be reaped by the harness later. Worktrees managed by `Agent` tool isolation **usually** auto-clean when their process exits — but not always. See step 7.
4. **Retire the coordinator.** Call `peer_retire(actor: "<coordinator>")` after
   its final board post. This releases any lingering claims and hides the
   completed loop peer from normal `peer_list` output; use
   `include_retired: true` only for audit. One-shot workers become `TERMINAL`
   only when their final heartbeat explicitly clears `next_action`, has no
   blocker, and reports passing or skipped verification. Failing verification
   remains active and keeps claims so the worker can repair its deliverable.
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

- **Applying one-turn limits to persistent Copilot sessions.** An ephemeral
  worker may stop after step 1, but a Copilot child session can complete a
  multi-step bounded deliverable and accept later turns. Bound the artifact,
  not every internal command.
- **Trying to wake via Scout.** `peer_send_message` is durable inbox delivery, not activation. Use Copilot `send_session_message`, Claude Agent Teams `SendMessage`, or the autoresearch worker control plane.
- **Treating "stale heartbeat" as a problem.** In this runtime, an idled subagent that sent its end-of-turn heartbeat IS in its terminal state. Stale = done. Don't escalate or re-spawn unless the deliverable is missing.
- **Polling `peer.list`/`peer.heartbeat` instead of `/tmp` files.** Artifacts on disk are the source of truth. Peer-board state lags and may be misattributed (see the identity-leakage note).
- **Posting too often.** Default cadence is 15 minutes. Bump to 5 minutes only during active conflict resolution.
- **Reading messages without filtering.** Use `peer.read_messages(since: <last_cursor>)` so you don't reprocess old messages.
- **Treating `verification_status: Skipped` as suspicious by default.** Some missions (docs-only, read-only research) legitimately skip. Trust the agent's reason.
- **Nudging on the board instead of privately.** Public nudges humiliate; private DMs steer.
- **Blocking on missing `peer.heartbeat`.** Older agents may still use `peer.update_status`. Read both; prefer the structured one when present.
- **Blocking on `TeamDelete` when agents don't ack shutdown.** Force-clean the team and task dirs after a 60-second timeout (see Cleanup section). Lingering peer.list entries are harmless.
- **Applying the old `<2h` heuristic to native Copilot sessions.** Duration is
  not the gate; independence and boundedness are. Two separate 30-minute
  evidence lanes should usually run as child sessions.

## Reference: how the board replaces broadcast flooding

**Before** (the old protocol): every tick produced a `peer.broadcast` with the full board markdown. Over an 8-hour run, a worker reading the board had to find the most recent of ~32 broadcasts. Stale messages accumulated until pruning.

**After**: `peer_post_board` updates one revisioned row keyed by `(run_id, board_id)`. `peer_read_board` returns just that row. The Scrum Master can post every tick without polluting the message stream, and optimistic concurrency prevents a stale coordinator from overwriting a newer board.

If you find yourself wanting to broadcast the board, post it instead. Use `peer.broadcast` only for one-shot signals (e.g., "soak release frozen, no new attaches for 30 minutes").
