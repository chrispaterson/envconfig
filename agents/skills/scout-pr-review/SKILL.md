---
name: scout-pr-review
description: Review a pull request using Scout's semantic analysis tools. Works on any repo with Scout attached. Blast-radius assessment via `impact`, architectural analysis via `investigate`, test-gap detection via `affected_tests`, memory-informed context via `memory_search`, dead-code check after changes, correctness + security review including agent-integration/supply-chain posture (permission grants, hook installs, network destinations, telemetry gates, update paths, transcript access). Reads existing PR review threads to flag adverse advice and amplify good suggestions; honors `.scout/review-policy.md` for repo-specific rules. Posts findings as inline diff comments pinned to specific lines via `gh api /reviews`. Produces a structured verdict with severity-rated findings. Use when asked to review a PR, review changes, or check a branch before merge.
---

# Scout PR Review

Deep code review powered by Scout's semantic analysis — not grep + eyeballing.

**Usage:** `/scout-pr-review [pr-number | branch-name]`

Run in any repository with Scout attached and indexed.

## Tool routing (read first)

Some Scout tools are MCP-only — no `scout` CLI equivalent. Call them as MCP tools (`mcp__scout__*`), never as Bash:

**MCP-only** (calling via `scout <name>` WILL FAIL):
- `mcp__scout__changes_detect`
- `mcp__scout__changes_affected_tests` — CLI `scout affected-tests` exists and returns formatted text; MCP returns structured JSON. Prefer MCP for parsing.
- `mcp__scout__investigate`
- `mcp__scout__investigate_expand`
- `mcp__scout__impact`
- `mcp__scout__dead_code`
- `mcp__scout__memory_search`

**Both forms work** (pick whichever fits): `scout list`, `scout attach`, `scout detach`, `scout call-graph`, `scout find-references`, `scout keyword-search`, `scout regex-search`, `scout file-outline`, `scout go-to-definition`, `scout explain-symbol`, `scout top-symbols`, `scout search`, `scout coderank`, `scout doctor`.

## Track phases with TaskCreate

PR review spans 9 phases and is a prime victim of context compaction. Before Phase 1, create one task per phase so progress survives compaction:

```
TaskCreate(subject: "Phase 1: map change surface", ...)
TaskCreate(subject: "Phase 2: architectural context", ...)
...
```

Mark in_progress when starting, completed when done. If any phase surfaces a finding, record it as a separate task so it isn't lost.

## Phase budget

| Phase | Target time | Notes |
|---|---|---|
| Setup | 1-3 min | Skip worktree for read-only review |
| 0. Policy + existing threads | 1-2 min | `.scout/review-policy.md` + `gh api .../comments` |
| 1. Change surface | 2 min | One `changes_detect` call |
| 2. Architectural context | 3-5 min | One `investigate` + one `memory_search` |
| 3. Blast radius | 3-8 min | `impact` on every risky symbol from Phase 1, batched and triaged by CodeRank |
| 4. Architectural fit | 2-5 min | Only if phase 2 found patterns to compare against |
| 5. Correctness | 5-15 min | **Scales with commit count and diff size — walk every commit** |
| 6. Test quality | 3-5 min | Focus on changed public symbols |
| 7. Security | 2-5 min | Checklist, not prose |
| 8. Lint | 1-2 min | One command |
| 9. Affected tests | 1-10 min | Depends on suite speed |

If the total budget exceeds 60 min the PR is too big — recommend splitting in the verdict. Large commit counts (50+) or >1000-line diffs stretch Phase 5 proportionally: budget ~30 s per commit of reading time, plus the normal per-hunk correctness work. Never shrink coverage to fit the clock — a partial review that skips commits is worse than an honest "this PR needs to be split."

---

## Setup

**Most reviews do NOT need a worktree.** Review read-only from the current workspace using `git diff main...<branch>`. Create a worktree only if:
- The PR has merge conflicts with main (you need to see the merged state)
- You intend to run the code locally (not just read it)
- The PR touches build/config in a way that invalidates the current index

**Default (no worktree):**
```bash
# 1. Identify the PR
gh pr view <number> --json headRefName,baseRefName,title,body,additions,deletions,changedFiles,commits

# 2. Confirm Scout has main indexed
scout list | grep <repo-name>

# 3. Fetch and enumerate EVERY commit in the PR (not just the tip)
git fetch origin <branch>
COMMITS=$(git rev-list --reverse main..origin/<branch>)
COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')
echo "PR has $COMMIT_COUNT commit(s) — review ALL of them"

# Oldest → newest, full subject line (no --oneline truncation)
git log --reverse --format='%h %s%n    %an, %ad%n' --date=short main..origin/<branch>

# Aggregate diff (use for Phase 1+ Scout tools)
git diff main...origin/<branch> --stat
git diff main...origin/<branch>
```

**Cover every commit — do not stop at the tip.** A PR with 50 commits gets a 50-commit review, not a 10-commit review. The aggregate `git diff` above is the right input for Scout tools (`changes_detect`, `investigate`, `impact`) because they operate on the squashed delta. But when reading the change (Phase 5 onward) walk the list commit-by-commit:

```bash
# Review every commit, oldest first. Do NOT truncate the list.
for sha in $COMMITS; do
  echo "=== $(git log -1 --format='%h %s' "$sha") ==="
  git show --stat "$sha"
  git show "$sha"
done | less      # or pipe into your review notes
```

Flag:
- Commits that mix unrelated changes (refactor + feature + fix in one commit)
- Commits that introduce and then revert the same code (noise — suggest squashing)
- Reverted / reinstated hunks where the net is zero (ask the author what the intent was)
- Commits whose message contradicts what the diff actually does
- Large commits (>300 lines) with no rationale in the message

If the PR has more than ~50 commits, the review budget grows linearly — adjust the phase timings below and warn in the verdict that splitting would make review tractable. Do NOT skip commits to fit a budget.

**If you need a worktree:**
```bash
git worktree add /tmp/scout-review-<id> origin/<branch>
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

One call. Establishes the symbols, files, and surfaces the PR touches.

```
mcp__scout__changes_detect(
  repository: "<repo>",
  scope: "compare",
  base_ref: "main"
)
```

Record from the response:
- **Scope match**: Do the changed symbols match what the PR description claims? Flag undeclared scope creep (unrelated symbols changed) and missing scope (description says X but X isn't touched).
- **Starred symbols (★)**: high-reference, high-blast-radius. These become Phase 3 targets.
- **Deleted symbols**: potential dangling references. These become Phase 3 targets.
- **New public symbols**: permanent API commitments.
- **Affected surfaces / domains**: cross-cutting signal — multiple surfaces touched = architectural change, even if each surface's diff is small.

Also run:
```bash
scout affected-tests -r <repo> -s compare -b main
```
Or (for structured JSON): `mcp__scout__changes_affected_tests`. Note every changed symbol with **zero** affected tests — those become Phase 6 targets.

---

## Phase 2: Architectural Context

Before judging anything, understand the territory. Two parallel calls:

```
mcp__scout__investigate(
  query: "<the feature/module the PR modifies>",
  repository: "<repo>",
  intent: "change"
)

mcp__scout__memory_search(
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

**Drill via `investigate_expand`** (MCP-only, batch 6-12 targets per call — file ranges and `asset:<id>` expansions are FREE):
```
mcp__scout__investigate_expand(
  bundle_id: "<id from investigate>",
  targets: ["SymbolA", "SymbolB", "src/module/changed.rs:50-120", "asset:<id>", ...]
)
```

---

## Phase 3: Blast Radius

Blast-radius analysis covers **every commit in the PR** — not just the tip, not just the latest few. The `changes_detect` call in Phase 1 already operates on the full `main..origin/<branch>` delta, so its output is the complete set of risky symbols across the entire PR. Feed all of them into `impact`.

Risky symbols = changed-public + starred (★) + deleted + signature-changed + behavior-changed. These come from Phase 1's `changes_detect` response. Do not filter by commit range — a regression in the first commit of a 50-commit PR is just as shippable as one in the last commit.

Use `impact` — the purpose-built tool. CodeRank-weighted risk, tiered by confidence. One call per risky symbol:

```
mcp__scout__impact(
  symbol: "<symbol>",
  repository: "<repo>",
  direction: "upstream",
  max_depth: 3,
  include_tests: false
)
```

If the risky-symbol set is large (>15), batch via `explain_symbol(symbols: [...])` first to see which callers overlap — a single shared caller across many symbols is often the real blast-radius story. Then call `impact` on the remaining distinct targets. If the set is very large (>40 symbols), still cover them all, but budget accordingly: `impact` is cheap individually (sub-second) and Scout's symbol graph is already loaded, so the real cost is your reading time on the results. Triage by CodeRank score — highest-impact first — but do not skip the tail.

For each risky symbol, verify:
- **Signature changes**: every caller handles the new contract. Check each caller, not "callers were updated."
- **Behavioral changes** (new early-returns, retries, errors, nil returns): callers that assumed the old behavior.
- **Deleted symbols**: zero references in `find_references` (if non-zero → PR is broken).
- **Type field changes**: constructors, serializers, pattern matches, JSON round-trips all updated.
- **Convergence nodes from Phase 2**: still correct under the new contracts.

**Also run `dead_code` after the change** to catch orphans the deletion/rename created:
```
mcp__scout__dead_code(
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
  mcp__scout__search(query: "<what the new function does — natural language>", repository: "<repo>")
  ```
- **Premature abstraction**: new trait/interface/base class has ≥2 concrete users? If 1, inline it.
- **File growth**: `file_outline` on modified files. 50+ symbols is a smell — but only flag if this PR caused the growth.
- **Dependency direction**: new imports go the right way (core doesn't import CLI, model doesn't import controller). The Phase 2 investigate results show the call-graph direction.

---

## Phase 5: Correctness

Read the actual changed code. **Walk EVERY commit in the PR, oldest first** — the list from the Setup block's `$COMMITS` variable. Do not stop at the tip. Do not sample. Do not trust the squashed diff to reveal intent — intermediate commits often show an author trying approach A, reverting it, then shipping approach B; that history matters for judging whether A's concerns have been fully addressed in B.

For each commit:
```bash
git show "$sha"
```
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

**If the commit count is large**, track progress explicitly: create a `TaskCreate(subject: "Phase 5 commit N/M: <sha> <subject>")` per commit and mark each completed as you finish it. This makes a partial review recoverable across compaction.

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

Identify the linter from repo config and run it:

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
SCOPE=compare BASE_REF=main ./scripts/test-affected.sh
```

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
