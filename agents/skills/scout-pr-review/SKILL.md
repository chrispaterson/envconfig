---
name: scout-pr-review
description: Review a pull request or branch with Scout's semantic analysis. Starts with bounded `review_pr` evidence, then targets unresolved or high-risk areas with impact, investigate, affected-test, memory, and dead-code analysis. Decomposes very large PRs into cohesive behavioral themes and tracks every changed file in a coverage ledger. Reviews correctness, architecture, security, test quality, agent integration, and supply-chain posture, including permissions, hooks, network, telemetry, updates and transcript access. Reads existing review threads to identify adverse advice and amplify useful suggestions; honors `.scout/review-policy.md` for repository-specific rules. Posts severity-rated inline findings pinned to changed lines and produces a structured verdict with coverage, evidence gaps, and validation status. Use when asked to review a pull request, review changes, audit a branch, check work before merge, inspect a large PR, assess correctness or security risks, or run `/scout-pr-review`.
---

# Scout PR Review

Deep code review powered by Scout's semantic analysis — not grep + eyeballing.

**Usage:** `/scout-pr-review [pr-number | branch-name]`

Run in any repository with Scout attached and indexed.

## Tool routing (read first)

Follow the active Scout transport. In an MCP-less Agent Skills session, load
the `scout` skill and run CLI commands through the host shell; never attempt an
MCP tool. This document uses host-neutral `scout.<name>` notation in some
examples. Translate it to these CLI forms:

| Operation | MCP-less CLI |
|---|---|
| `scout.review_pr` | `scout review-pr -r <repo> -s compare -b <base>` |
| `scout.changes_detect` | `scout changes-detect -r <repo> -s compare -b <base>` |
| `scout.changes_affected_tests` | `scout affected-tests -r <repo> -s compare -b <base>` |
| `scout.investigate` | `scout investigate start "<query>" -r <repo> --intent change` |
| `scout.investigate_expand` | `scout investigate expand <bundle_id> <targets...>` |
| `scout.impact` | `scout impact <symbol> -r <repo>` |
| `scout.dead_code` | `scout dead-code -r <repo>` |
| `scout.memory_search` | `scout memory search "<query>" -r <repo>` |

Use `scout <command> --help` for exact flags. Do not guess a CLI spelling from
the host-neutral notation.

## Track phases

PR review spans multiple phases and is a prime victim of context compaction.
Before Phase 1, use the host's task/todo facility when one is available and
create one item per phase. If the host has no task facility, maintain the same
ledger in your working context:

```
Phase 1: map change surface
Phase 2: architectural context
…
```

Mark in_progress when starting, completed when done. If any phase surfaces a finding, record it as a separate task so it isn't lost. In thematic mode, also create one task per theme and one final cross-theme integration task; do not replace the phase tasks with the theme tasks.

## Phase budget

| Phase | Target time | Notes |
|---|---|---|
| Setup | 1-3 min | Skip worktree for read-only review |
| 0. Policy + existing threads | 1-2 min | `.scout/review-policy.md` + `gh api .../comments` |
| 1. Change surface | 2 min | One whole-PR `review_pr` call |
| 1A. Thematic decomposition | 3-8 min | Very large PRs only; 3-7 themes + coverage ledger |
| 2. Architectural context | 3-5 min | Standard: one pass; thematic: one focused pass per theme |
| 3. Blast radius | 3-8 min | Packet impact first; targeted `impact` for unresolved/high-risk symbols per theme |
| 4. Architectural fit | 2-5 min | Only if phase 2 found patterns to compare against |
| 5. Correctness | 5-15 min | **Scales with commit count and diff size — cover every commit** |
| 6. Test quality | 3-5 min | Focus on changed public symbols |
| 7. Security | 2-5 min | Checklist, not prose |
| 8. Lint | 1-2 min | One command |
| 9. Affected tests | 1-10 min | Depends on suite speed |

If the total budget exceeds 60 min, switch to thematic mode rather than treating the PR as one undifferentiated stream. Still recommend splitting in the verdict when themes cannot be reviewed independently, shared contracts dominate the change, or validation cannot isolate the risk. Large commit counts (50+) or >1000-line diffs stretch Phase 5 proportionally: budget ~30 s per commit of reading time, plus the normal per-hunk correctness work. Never shrink coverage to fit the clock — a partial review that skips commits or themes is worse than an honest "this PR needs to be split."

---

## Setup

**Most reviews do NOT need a worktree.** Review read-only from the current workspace using the fetched remote base and head refs. Create a worktree only if:
- The PR has merge conflicts with its base branch (you need to see the merged state)
- You intend to run the code locally (not just read it)
- The PR touches build/config in a way that invalidates the current index

**Default (no worktree):**
```bash
# 1. Identify the PR and retain its exact remote refs
PR_BASE=$(gh pr view <number> --json baseRefName --jq .baseRefName)
PR_HEAD=$(gh pr view <number> --json headRefName --jq .headRefName)
BASE_REF="origin/$PR_BASE"
HEAD_REF="origin/$PR_HEAD"
gh pr view <number> --json headRefName,baseRefName,title,body,additions,deletions,changedFiles,commits
PR_SIZE=$(gh pr view <number> --json additions,deletions,changedFiles \
  --jq '[.additions, .deletions, .changedFiles] | @tsv')
IFS=$'\t' read -r PR_ADDITIONS PR_DELETIONS PR_CHANGED_FILES <<<"$PR_SIZE"

# 2. Confirm Scout has the repository indexed
scout list | grep <repo-name>

# 3. Fetch both refs and enumerate EVERY commit in the PR (not just the tip)
git fetch origin "$PR_BASE" "$PR_HEAD"
COMMITS=$(git rev-list --reverse "$BASE_REF..$HEAD_REF")
COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')
echo "PR has $COMMIT_COUNT commit(s) — review ALL of them"

# Size the bounded review packet and select a review mode from the largest
# pressure signal. The MCP surface clamps max_chars to 24,000 bytes.
PR_CHANGED_LINES=$((PR_ADDITIONS + PR_DELETIONS))
REVIEW_MODE=standard
if (( PR_CHANGED_LINES > 2000 || PR_CHANGED_FILES > 50 || COMMIT_COUNT > 40 )); then
  REVIEW_MAX_CHARS=24000
  REVIEW_MODE=thematic
elif (( PR_CHANGED_LINES > 500 || PR_CHANGED_FILES > 20 || COMMIT_COUNT > 15 )); then
  REVIEW_MAX_CHARS=18000
else
  REVIEW_MAX_CHARS=12000
fi
echo "Review mode: $REVIEW_MODE; packet budget: $REVIEW_MAX_CHARS bytes ($PR_CHANGED_LINES changed lines, $PR_CHANGED_FILES files, $COMMIT_COUNT commits)"

# Oldest → newest, full subject line (no --oneline truncation)
git log --reverse --format='%h %s%n    %an, %ad%n' --date=short "$BASE_REF..$HEAD_REF"
if [[ "$REVIEW_MODE" == "thematic" ]]; then
  # Commit-to-path inventory for the Phase 1A coverage ledger.
  git log --reverse --format='commit %H %s' --name-status "$BASE_REF..$HEAD_REF"
fi

# Inventory the aggregate diff. In thematic mode, defer full source reads to
# the theme lanes instead of flooding one context with the entire patch.
git diff "$BASE_REF...$HEAD_REF" --stat
git diff "$BASE_REF...$HEAD_REF" --name-status
git diff "$BASE_REF...$HEAD_REF" --numstat
if [[ "$REVIEW_MODE" == "standard" ]]; then
  git diff "$BASE_REF...$HEAD_REF"
fi
```

**Cover every commit — do not stop at the tip.** A PR with 50 commits gets a 50-commit review, not a 10-commit review. The aggregate delta is the right input for Scout tools (`review_pr`, `investigate`, targeted `impact`) because they operate on the squashed change. In standard mode, walk the list commit-by-commit:

```bash
# Review every commit, oldest first. Do NOT truncate the list.
for sha in $COMMITS; do
  echo "=== $(git log -1 --format='%h %s' "$sha") ==="
  git show --stat "$sha"
  git show "$sha"
done | less      # or pipe into your review notes
```

In thematic mode, Phase 1A assigns each changed path and commit to a cohesive
theme. Each lane reads the final diff for its assigned paths and the relevant
path-filtered portion of every commit that touched them. The integration pass
reviews mixed-theme commits and shared boundaries. This preserves complete
coverage without making every lane reread the whole PR.

Flag:
- Commits that mix unrelated changes (refactor + feature + fix in one commit)
- Commits that introduce and then revert the same code (noise — suggest squashing)
- Reverted / reinstated hunks where the net is zero (ask the author what the intent was)
- Commits whose message contradicts what the diff actually does
- Large commits (>300 lines) with no rationale in the message

If the PR has more than ~50 commits, thematic mode is mandatory. The review
budget still grows with real change volume; themes organize coverage but do not
justify sampling. Warn in the verdict when splitting would make the change
meaningfully safer or more tractable.

**If you need a worktree:**
```bash
git worktree add /tmp/scout-review-<id> "$HEAD_REF"
# Scout auto-attaches within 5s; poll once:
for i in 1 2 3 4 5 6; do
  scout list 2>/dev/null | grep -q "scout-review-<id>" && break
  sleep 5
done
```

---

## Phase 0: Policy + Existing Threads

Two cheap reads before diving in. Both are optional but make the review more grounded.

**Repo review policy** — if the repo ships one, load it:
```bash
cat .scout/review-policy.md 2>/dev/null || echo "(no repo policy)"
```
This lets teams add repo-specific rules (security must-checks, performance invariants, deprecated patterns) without editing this skill. Apply every check from the policy output in Phase 5 / 7 alongside the built-in checklists.

**Existing review threads** — pull what other reviewers have already said:
```bash
gh api "repos/:owner/:repo/pulls/<number>/comments" \
  --jq '.[] | "\(.user.login) on \(.path):\(.line // .original_line): \(.body)"'
gh pr view <number> --json reviews \
  --jq '.reviews[] | "\(.author.login) [\(.state)]: \(.body)"'
```

Read them. Note:
- **Adverse advice**: a human comment that would make the PR worse if followed (e.g., "just catch and ignore this error", "no need for tests here"). Flag it in the review output's *Adverse Advice Detected* section — don't just stay silent, because silence reads as agreement.
- **Good suggestions worth amplifying**: comments that flagged real issues the author hasn't acted on yet. Restate and support them in the *Suggestions Worth Supporting* section so they don't get lost.
- **Already-flagged issues**: don't re-raise things other reviewers already caught — cite them instead ("agreed with @alice on auth.rs:42").

---

## Phase 1: Change Surface

One bounded call. Establishes the changed roots, impact, affected tests, and
changed-surface dead-code evidence without immediately repeating its
constituent analyses.

Use the `REVIEW_MAX_CHARS` selected during Setup: 12,000 bytes for ordinary
PRs, 18,000 when changed lines, files, or commits cross the large-PR threshold,
and the tool maximum of 24,000 for very large PRs. The largest pressure signal
wins so a low-line-count PR spread across many files or commits is not
undersized.

```
scout.review_pr(
  repository: "<repo>",
  scope: "compare",
  base_ref: "<BASE_REF from Setup, normally origin/main>",
  max_depth: 3,
  max_chars: <REVIEW_MAX_CHARS from Setup>
)
```

Record from the response:
- **Evidence status**: `INCOMPLETE`, bounded change analysis, unknown probes,
  source truncation, and omitted rows are follow-up obligations, not negative evidence.
- **Scope match**: Do the changed symbols match what the PR description claims? Flag undeclared scope creep (unrelated symbols changed) and missing scope (description says X but X isn't touched).
- **Starred symbols (★)**: high-reference, high-blast-radius. These become Phase 3 targets.
- **Deleted symbols**: potential dangling references. These become Phase 3 targets.
- **New public symbols**: permanent API commitments.
- **Affected surfaces / domains**: cross-cutting signal — multiple surfaces touched = architectural change, even if each surface's diff is small.
- **Affected tests**: note every changed symbol with zero visible affected tests and
  whether test rows were omitted or the source response was truncated.
- **Changed-surface dead code**: candidate-only evidence; unknown or unprobed
  text-reference counts are not proof of absence.

Do **not** immediately repeat `changes_detect`, `changes_affected_tests`, or
`dead_code`. Call a constituent tool only when `review_pr` reports an
incomplete, unknown, omitted, or risky evidence slot that matters to the
verdict. Use the same fetched `BASE_REF`.

---

## Phase 1A: Very-Large PR Thematic Decomposition

Run this phase when `REVIEW_MODE=thematic`. Also promote a nominally standard
review to thematic mode after Phase 1 when the packet shows size-driven
omissions and the change spans at least four distinct domains or execution
surfaces. A single unknown probe is not enough to trigger thematic mode.

Build **normally 3-7 large, cohesive themes** from:

- The PR title/body and commit subjects (claimed intent)
- `review_pr` domains, changed roots, affected flows, and convergence points
- File/line inventory and commit-to-path relationships
- Runtime or architectural responsibility

A theme is a behavior or responsibility such as "index persistence migration,"
"MCP request routing," or "CLI and configuration surface" — never an arbitrary
equal-sized batch of files. Keep a feature's implementation, tests, fixtures,
docs, and configuration in the same theme. Prefer fewer substantial themes;
split only when the parts have genuinely different contracts or failure modes.
Create an explicit integration theme for shared schemas, migrations, feature
flags, permissions, or boundary adapters that couple two or more themes.
Do not invent three themes for a genuinely single-purpose mechanical change.
If more than seven irreducible themes remain, process them in bounded waves and
recommend splitting the PR rather than hiding the tail in "miscellaneous."

Create and maintain this ledger before launching any focused review:

| Theme | Intent | Primary paths | Commits | Risky symbols | Shared boundaries | Evidence status |
|---|---|---|---|---|---|---|
| `<name>` | `<behavior>` | `<exact paths>` | `<SHAs>` | `<symbols>` | `<contracts>` | complete/incomplete |

Coverage rules:

1. Every changed path has exactly one primary theme. Shared files may appear as
   secondary context in other themes, but one lane owns their final-hunk review.
2. Every commit maps to at least one theme. A mixed commit maps to every theme
   whose hunks it changes and is also inspected by the integration owner.
3. Every packet row for a changed, deleted, public, or starred symbol maps to a
   theme. Cross-theme convergence points map to the integration theme.
4. Unassigned paths, commits, hunks, risky symbols, or size-driven omissions
   block the verdict. "Miscellaneous" is not an acceptable catch-all theme.

### Focused theme lanes

If Scout-capable review agents are available, run independent themes in
parallel (normally no more than four at once); otherwise process them
sequentially in the current context. Do not delegate a theme to an agent that
cannot call Scout. Give each lane the exact base/head refs, PR intent, policy,
existing-thread notes, primary and shared paths, relevant commits, risky
symbols, and the applicable rows from the Phase 1 packet.

`review_pr` is whole-diff scoped; it has no path filter. Route it deliberately:

- Reuse the Phase 1 packet when it is current and complete for the theme.
- A theme lane may call `review_pr` once when it did not receive a current
  packet, when the original packet used less than 24,000 bytes and omitted
  evidence for that theme (retry at 24,000), or when its source state changed.
- A theme may run `review_pr` against a narrower delta only when that exact
  theme already exists as a real checkout/ref with a truthful base and head.
  Do not rewrite history or cherry-pick a synthetic theme branch just to make
  the tool appear theme-scoped.
- Never rerun the same 24,000-byte `review_pr` call against the same source
  state after it returns the same omissions. Switch to targeted `investigate`,
  `impact`, `changes_affected_tests`, or `dead_code` follow-ups instead.

Each lane then applies Phases 2-7 to its theme and returns:

```markdown
### Theme: <name>
- Scope reviewed: <paths, commits, risky symbols>
- `review_pr`: <reused/called/not needed>; evidence <complete/incomplete>
- Cross-theme contracts checked: <list>
- Findings: <severity + exact path:line>
- Test gaps: <list>
- Unresolved evidence: <list or none>
```

The main reviewer owns the final integration pass: reconcile duplicate or
conflicting findings, trace shared contracts end-to-end, verify every ledger
row is complete, and run lint plus affected tests once for the whole PR. Theme
lanes do not issue independent verdicts.

---

## Phase 2: Architectural Context

Before judging anything, understand the territory. In standard mode, make
these two calls in parallel. In thematic mode, run one focused `investigate`
per theme using its behavior and exact paths; share or batch memory results
when themes overlap rather than issuing duplicate lookups.

```
scout.investigate(
  query: "<the feature/module the PR modifies>",
  repository: "<repo>",
  intent: "change"
)

scout.memory_search(
  query: "<same feature/module>",
  repository: "<repo>"
)
```

`memory_search` surfaces prior decisions, gotchas, and architectural notes the PR author may have overlooked. If a memory entry directly addresses the change, cite it in the review.

`investigate` returns entry points, inline definitions, caller/callee relationships, convergence nodes, and a `bundle_id` for follow-up. Read the result carefully — it tells you:
- How the changed code fits into the broader system
- **Convergence points**: symbols multiple changed functions flow through. High-risk even if the PR didn't touch them directly.
- **Unexpected connections**: callers or callees the author may not have considered
- **Existing patterns**: error handling, naming, module organization in this area

**Drill via `investigate_expand`** (batch 4-10 distinct regions per call — adjacent same-file ranges merge into one block; file ranges and `asset:<id>` expansions are free in the bundle; send another expand for unread files):
```
scout.investigate_expand(
  bundle_id: "<id from investigate>",
  targets: ["SymbolA", "SymbolB", "src/module/changed.rs:50-120", "asset:<id>", ...]
)
```

---

## Phase 3: Blast Radius

Blast-radius analysis covers **every commit in the PR** — not just the tip, not just the latest few. The `review_pr` call in Phase 1 operates on the full fetched base-to-head delta and already includes bounded impact evidence for changed roots. In thematic mode, assign each risky symbol to its owning lane and reserve cross-theme callers and convergence nodes for the integration pass.

Risky symbols = changed-public + starred (★) + deleted + signature-changed + behavior-changed. Start with packet rows. If changed roots were omitted, call `changes_detect` once to recover the unresolved set. Do not filter by commit range — a regression in the first commit of a 50-commit PR is just as shippable as one in the last commit.

Use targeted `impact` only where the packet left caller evidence omitted,
ambiguous, incomplete, or unusually risky. CodeRank-weighted risk is tiered by confidence:

```
scout.impact(
  symbol: "<symbol>",
  repository: "<repo>",
  direction: "upstream",
  max_depth: 3,
  include_tests: false
)
```

If the unresolved risky-symbol set is large (>15), batch via
`explain_symbol(symbols: [...])` first to see which callers overlap — a single
shared caller across many symbols is often the real blast-radius story. Then
call `impact` on the remaining distinct unresolved targets. The packet still
counts omitted roots and impact rows, so do not mistake its byte cap for
coverage or silently skip the tail.

For each risky symbol, verify:
- **Signature changes**: every caller handles the new contract. Check each caller, not "callers were updated."
- **Behavioral changes** (new early-returns, retries, errors, nil returns): callers that assumed the old behavior.
- **Deleted symbols**: zero references in `find_references` (if non-zero → PR is broken).
- **Type field changes**: constructors, serializers, pattern matches, JSON round-trips all updated.
- **Convergence nodes from Phase 2**: still correct under the new contracts.

**Also run `dead_code` after the change** to catch orphans the deletion/rename created:
```
scout.dead_code(
  repository: "<repo>",
  path_prefix: "<modified area>",
  min_confidence: 0.7
)
```
New results that weren't dead before are orphans created by this PR.

---

## Phase 4: Architectural Fit

Skip this phase if Phase 2's investigate didn't surface clear existing patterns.

Checks:
- **Pattern consistency**: error handling, naming, module organization match Phase 2's patterns? Deviations justified?
- **Near-duplicates**: use `search` (semantic) not just `keyword_search`, since duplicates often have different names:
  ```
  scout.search(query: "<what the new function does — natural language>", repository: "<repo>")
  ```
- **Premature abstraction**: new trait/interface/base class has ≥2 concrete users? If 1, inline it.
- **File growth**: `file_outline` on modified files. 50+ symbols is a smell — but only flag if this PR caused the growth.
- **Dependency direction**: new imports go the right way (core doesn't import CLI, model doesn't import controller). The Phase 2 investigate results show the call-graph direction.

---

## Phase 5: Correctness

Read the actual changed code. **Cover EVERY commit in the PR, oldest first** —
the list from the Setup block's `$COMMITS` variable. Do not stop at the tip or
sample. Do not trust only the squashed diff to reveal intent — intermediate
commits often show an author trying approach A, reverting it, then shipping
approach B; that history matters for judging whether A's concerns have been
fully addressed in B.

In standard mode, read each commit directly:
```bash
git show "$sha"
```

In thematic mode, each lane reads the final aggregate diff for its primary
paths, then the relevant portion of every assigned commit:

```bash
git diff "$BASE_REF...$HEAD_REF" -- <theme-primary-paths>
git show "$sha" -- <theme-primary-paths>
```

The integration owner reads every mixed-theme commit's full stat and diff
around shared boundaries. Mark a commit complete only after all of its changed
paths are covered across the theme ledger.
Then for each modified function in that commit, work adversarially — checklist form:

- [ ] **Inputs**: empty string, zero, negative, nil/null, max-size, unicode, concurrent duplicate calls
- [ ] **Loops**: 0 / 1 / 1M iterations; upper bound exists if data is external; no O(n²) on external input
- [ ] **Error paths**: every error path from creation to user. Context preserved? Resources cleaned up (files closed, locks released, state rolled back)?
- [ ] **State mutations**: shared state (global, cache, DB) left consistent on halfway failure? Transaction or rollback?
- [ ] **Concurrency**: lock order deadlock-free? Locks not held across await/yield? No shared state without synchronization?
- [ ] **Numeric**: integer overflow, division by zero, float `==`, narrowing conversions
- [ ] **Panics/unwraps** (Rust) / **unchecked errors** (Go) / **missing null-checks** (TS/JS): every new one justified?
- [ ] **Commit hygiene**: does this commit do one thing? Does its message describe the diff? Any code added here and removed by a later commit in the same PR (noise)?

Use `explain_symbol` on modified functions to see their callers + callees in one call — cheaper than reading them individually.

**Agent-facing surfaces** — apply when the diff touches MCP instructions, MCP prompts, hooks, or client/model handling. This delivery-semantics class is invisible to per-function correctness review but silently breaks what reaches the agent:

- [ ] **Client/model gating**: any branch on `client_info.name`, model, or a client string uses an EXACT/specific match, not a loose `contains(...)` that captures unintended clients (e.g. `contains("claude")` also matches Claude Desktop `claude-ai`). A wrong gate silently drops instructions for some clients. Confirm the unknown/default branch is the SAFE one (serve full, not lean).
- [ ] **Delivery timing**: guidance the agent needs at session start is actually present at `initialize` — not gated behind a hook or lazy install that hasn't run yet for an existing or just-attached repo (an upgraded hook command is stale until reinstall + session reload).
- [ ] **MCP prompt arg completeness**: every argument a prompt's text references (e.g. "requires `base_ref`") is declared as a `PromptArgument` AND threaded into the rendered tool call — not just named in prose.
- [ ] **Absolute behavioral rules**: instruction text avoids hard "never/always" constraints that can conflict with higher-priority host/system guidance (e.g. Codex requiring progress updates); scope them as defaults that yield to the host.
- [ ] **Docs + memory in sync**: README/CLAUDE.md and any `.scout/memory/*` entry surfaced by `memory_search` match the new implementation. Stale **memory** is worse than stale docs — it actively misleads the next agent reviewing this exact area. Grep canonical-source claims (constant names, file paths, workflows) against the code and flag contradictions.

**If the commit count is large**, track progress by theme first:
create or update a host task named `Phase 5 theme N/M: <name>`, with assigned
commit and path counts in its description. Without a host task facility, add
the same entry to the working ledger. Add per-commit entries only for a theme
with more than 20 commits or when compaction recovery needs finer checkpoints.

---

## Phase 6: Test Quality

Not "do tests exist" — "would these tests catch a regression?"

For each new or changed public function:
- [ ] At least one test calls it directly
- [ ] Bug fixes include a test that reproduces the bug (revert-the-fix → test fails)
- [ ] Error/edge paths tested, not just happy path. 10:1 happy:error ratio is a smell.
- [ ] Assertions check **values**, not just `is_ok()` / `!= nil`
- [ ] No execution-order / timing / external-state dependencies (network, non-temp filesystem)
- [ ] Serialization round-trips tested for persisted/wire types

For each **changed symbol with zero affected tests** from Phase 1: name it in Test Gaps.

---

## Phase 7: Security Checklist

Skip irrelevant items, but never skip the check.

- [ ] **Secrets**: no hardcoded tokens, keys, passwords in code/fixtures/configs/comments/logs
- [ ] **Injection**: external input (user/network/file/env) flowing into shell / SQL / HTML / paths / logs / regex — validated or escaped at boundary?
- [ ] **Resource exhaustion**: unbounded allocations from external size fields; unlimited loop iterations on external data; missing timeouts on network/IPC; unlimited concurrent task spawning; file reads without size limits
- [ ] **Path traversal**: external paths canonicalized + root-checked; `../`, symlink following, null bytes handled
- [ ] **Deserialization**: malformed input doesn't crash; length limits, recursion depth limits, unexpected types handled
- [ ] **Permissions**: new files not world-writable (0666/0777); new listeners bind to loopback unless intentional; new auth/authz paths don't bypass existing checks
- [ ] **Dependencies**: new deps necessary, reputable, maintained, no known advisories

**Agent-integration & supply-chain posture** — apply whenever the diff touches
installers, hooks, tool permissions, MCP tool definitions, network endpoints,
telemetry, or update paths. Tools that integrate with coding agents earn trust
by being transparent about exactly these surfaces (in Scout:
`install_mcp_permissions`, `*_hooks.rs`, `SCOUT_MCP_TOOLS`/`SCOUT_BASH_COMMANDS`,
`mcp_server/*_tools.rs`, `auto_update.rs`, `analytics.rs`, `gateway/`,
`consent.rs`; other repos have equivalents). Never skip this block on such a
diff — these are the findings third-party security audits of agent plugins
flag first:

- [ ] **Pre-approved permissions stay read-only**: any change to an
      auto-allowed tool/command list preserves the invariant that nothing
      file-mutating or state-changing is pre-approved — the host's per-use
      prompt is the security boundary for mutations. (Scout: guarded by
      `claude_code_allowlist_is_read_only`; a PR adding a `#[tool(...)]` must
      also classify it — allow-listed or prompt-gated — and add its
      `PER_TOOL` row.) Narrow, verified exceptions must be init-gated,
      path-confined, and refused over remote transports (the memory-bank
      writers are the model).
- [ ] **Agent-config writes are disclosed + reversible**: new or changed
      hooks, CLAUDE.md sections, or settings writes are idempotent,
      self-cleaning when disabled, covered by the uninstall scrubber, and
      reflected in the first-attach consent summary and the security &
      data-flow page — in the same PR.
- [ ] **New network destination or payload**: any new outbound endpoint — or
      new content added to an existing payload — is documented with its gate.
      Content-bearing telemetry (queries, file paths, code) must be opt-in;
      only anonymized counters may ride an opt-out. No hardcoded endpoints
      without an env override.
- [ ] **Update/install path unchanged in kind**: changes to auto-update or
      installers preserve transport security + artifact hash verification +
      rollback, and never widen *what* gets executed or *where* it comes from
      without explicit review.
- [ ] **File access stays confined**: new file reads/writes resolve through
      the canonicalize + repo-root check (Scout: `resolve_repo_target`); no
      new code path accepts absolute or `..` paths without it.
- [ ] **Transport gating**: new mutating daemon requests are refused by the
      HTTP allowlist (`is_http_permitted`); content-serving tools stay
      env-gated and fail-closed over HTTP; nothing new is forwarded over
      federation unintentionally.
- [ ] **Transcript/session data**: anything reading `~/.claude` (or another
      agent's session store) is operator-invoked, keeps its output local, and
      is documented on the security page.
- [ ] **Consent freshness**: a material change to the installed footprint or
      network behavior bumps `CONSENT_VERSION` so existing users see the
      updated first-attach summary.

---

## Phase 8: Lint

Lint is a mandatory review gate. Do not issue a verdict when it was skipped or
when the latest result covers an older source state.

For Scout, force the running dev-watch process to lint every workspace crate
and target, then require `rc=0 phase=clippy`:

```bash
./scripts/dev-watch-ctl.sh clippy
./scripts/smartsleep.sh
```

Do not accept a throttled `phase=build` result. If dev-watch is unavailable,
run `./scripts/check-clippy.sh`, which performs the standalone full pass. The
forced watcher gate is validation-only and must never run `clippy --fix` or
otherwise modify source during a review.

For other repositories, identify the linter from repo config and run it:

```bash
# Rust
cargo clippy --all-targets --no-deps -- -D warnings && cargo fmt --check
# TypeScript/JS
npx eslint . && npx prettier --check .
# Python
ruff check . && ruff format --check .
# Go
golangci-lint run && gofmt -l .
```

Note findings; do **not** auto-fix in a review.

---

## Phase 9: Run Affected Tests

Confirm the tests Phase 1 identified actually pass on this branch.

**Preferred** (Scout repo ships this; many forks too):
```bash
SCOPE=compare BASE_REF="$BASE_REF" ./scripts/test-affected.sh
```

`compare` diffs from the merge base with the fetched remote `BASE_REF`, so it covers the branch's
own changes and ignores commits that landed on the base after the fork. Keep
`compare` for a PR review — it is deliberately PR-wide. `SCOPE=commit` narrows
to the last commit alone and is for local iteration, not review sign-off.

**Fallback** — if the script doesn't exist, run the full suite instead. Do NOT construct ad-hoc `grep | xargs` pipelines to pass tests to the runner; they silently skip tests with special characters and give false "all pass" signal.

Report:
- All pass → green signal in verdict
- Any failure → **CRITICAL** finding (regardless of Phase 5/6). List each failing test with its assertion/error message.
- Can't map diff (no daemon, no index) → note the gap

---

## Review Output

```markdown
## PR Review: <title>

### Summary
<2-4 sentences: what the PR does, scope match, overall risk level>
- Review mode: <standard / thematic with N themes>

### Change Surface
- <N> symbols changed, <N> new, <N> deleted
- Starred (high-impact): <list or "none">
- Surfaces touched: <list>
- Scope: <match / creep / missing>

### Blast Radius
- Per risky symbol: callers checked, gaps found
- Unupdated callers: <list or "none">
- Dangling references: <list or "none">
- New orphans (dead_code): <list or "none">

### Prior Knowledge Surfaced
- <memory entries cited from Phase 2, or "none relevant">

### Thematic Coverage
(Include only for thematic reviews.)

| Theme | Paths/commits covered | `review_pr` evidence | Findings | Unresolved |
|---|---|---|---|---|
| `<name>` | `<counts>` | reused/called; complete/incomplete | `<counts by severity>` | `<list or none>` |

- Cross-theme integration: <contracts and convergence points checked>
- Unassigned paths/commits/risky symbols: none (required for a verdict)

### Findings

Format each line-tied finding as `[SEVERITY] path:line — description`. This
exact format is parsed by the post-to-PR step to emit inline diff comments.
Findings without a `path:line` go into the overall body instead.

**CRITICAL** (blocks merge — correctness bug, data loss, failing test, security hole):
- [CRITICAL] src/foo.rs:42 — <description>

**HIGH** (fix before merge — blast-radius gap, unhandled error path, untested public API):
- [HIGH] src/bar.rs:17 — <description>

**MEDIUM** (follow-up — architectural concern, test gap, non-blocking lint):
- [MEDIUM] src/baz.rs:88 — <description>

**LOW** (optional — style, naming, minor simplification):
- [LOW] src/qux.rs:5 — <description>

### Test Gaps
- Zero-coverage public symbols: <list>
- Missing regression test for: <scenario>
- Weak assertions / flaky patterns: <list>

### Affected-Test Run
- <N> affected tests ran; <F> failed — or "all passed"
- Failures: <list with file:line and error, or "none">

### Lint
- <command/gate used and result; a skipped or stale lint result blocks verdict>

### Security
- <flagged items with severity, or "No issues found">
- Agent-integration posture (only when the diff touched installers, hooks,
  permissions, endpoints, telemetry, or update paths): <each posture item
  checked, with pass/finding — or "not applicable to this diff">

### Adverse Advice Detected
(Include this section only if Phase 0 found a human comment that would make the
PR worse. Describe the comment, explain why it's harmful, propose the safe
alternative. Omit the heading entirely when empty.)

### Suggestions Worth Supporting
(Include only if Phase 0 found other-reviewer comments that raise real issues
the author hasn't addressed. Restate them, explain the broader value, and take
a position — agreed, partially agreed, disagreed. Omit when empty.)

### Verdict
**Approve** / **Approve with nits** / **Request changes**

<Blocking items that must resolve before merge. Non-blocking noted but don't hold the PR.>
```

**Three verdict levels**, not four. CRITICAL findings → Request changes. HIGH findings → Request changes unless author agrees to fix in follow-up. MEDIUM/LOW only → Approve with nits.

---

## Posting to the PR (opt-in)

Do **not** auto-post. Show the review to the user first and ask:
1. Submit this review, or iterate on the findings first?
2. If submitting: Approve / Request changes / Comment only?

Confirm git identity before posting — a wrong-account comment is hard to unsend:
```bash
git config user.email
gh api user -q .login
```

**Post as a single GitHub Review** (overall body + inline comments in one atomic
action) so that inline findings land pinned to their diff lines, not buried in a
wall-of-text body comment:

```bash
# Gather PR metadata needed for the API call.
gh pr view <number> --json baseRefName,headRefOid,headRefName \
  --jq '{base: .baseRefName, sha: .headRefOid, head: .headRefName}'

# Build the comments[] array from every `[SEVERITY] path:line — …` finding.
# For a Rust + jq approach on smaller reviews, construct the JSON by hand in a
# heredoc. For larger reviews, assemble comments[] programmatically.
#
# Example — three inline findings + overall body:
gh api -X POST "repos/{owner}/{repo}/pulls/<number>/reviews" \
  --input - <<'JSON'
{
  "commit_id": "<headRefOid from above>",
  "event": "REQUEST_CHANGES",
  "body": "## PR Review: <title>\n\n<overall body — Summary, Change Surface, Blast Radius, Prior Knowledge, Test Gaps, Affected-Test Run, Security, Adverse Advice, Suggestions, Verdict. Omit the Findings list — those land inline as comments[] below. End with the footer below.>\n\n---\n*Reviewed with ❤️ by [Claude Code](https://claude.ai) 🤖 and [Scout](https://github.com/Adobe-AIFoundations/scout)*",
  "comments": [
    { "path": "src/foo.rs", "line": 42, "side": "RIGHT",
      "body": "**[CRITICAL]** <description>\n\n*Reviewed with ❤️ by [Claude Code](https://claude.ai) 🤖 and [Scout](https://github.com/Adobe-AIFoundations/scout)*" },
    { "path": "src/bar.rs", "line": 17, "side": "RIGHT",
      "body": "**[HIGH]** <description>\n\n*Reviewed with ❤️ by [Claude Code](https://claude.ai) 🤖 and [Scout](https://github.com/Adobe-AIFoundations/scout)*" },
    { "path": "src/qux.rs", "line": 5, "side": "RIGHT",
      "body": "**[LOW]** <description>\n\n*Reviewed with ❤️ by [Claude Code](https://claude.ai) 🤖 and [Scout](https://github.com/Adobe-AIFoundations/scout)*" }
  ]
}
JSON
```

**`event` values:**
- `APPROVE` — Approve
- `REQUEST_CHANGES` — Request changes (use when any CRITICAL or non-deferred HIGH findings exist)
- `COMMENT` — Comment only (discussion/nits, no approve/block signal)

**`side: "RIGHT"`** pins the comment to the PR's new version of the file. Use
`"LEFT"` only for comments on removed lines in the base version — rare in a
forward-looking review.

**Attribution footer** — every posted body (overall + each inline comment) must
end with the footer shown above. It makes Claude-assisted reviews discoverable
via search and separates tool-assisted findings from human ones in governance
audits.

**No line-tied findings?** If every finding is structural/general, drop the
`comments` array entirely and post body-only.

**Fallback** — if `gh api /reviews` fails (auth scope, enterprise host quirks),
post the overall body via `gh pr comment <number> --body-file <path>` and
accept the loss of inline pinning. Flag this in the response so the user knows.

---

## Cleanup

Only if you created a worktree in Setup:

```bash
cd -
scout detach /tmp/scout-review-<id>
git worktree remove /tmp/scout-review-<id>
```
