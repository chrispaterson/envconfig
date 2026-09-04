---
name: scout-bench-create
description: Guided workflow for product engineers to create benchmark evaluation suites for their repos. Produces a search quality query-set (TOML) that can be evaluated immediately with `scout evaluate`, and optionally agent outcome tasks (JSON) for the Scout team's centralized benchmark suite. Use when asked to "create a benchmark", "bench-create", "benchmark my repo", or "measure Scout quality on my repo".
---

# Scout Bench Create — Product Team Benchmark Contribution

Help a product engineer create a benchmark evaluation suite for their repo. The engineer provides domain knowledge (real questions, ground truth files); Scout tools assist with verification and discovery.

**Usage:** `/scout-bench-create <path>`

Examples:
- `/scout-bench-create .` (current directory)
- `/scout-bench-create ~/dev/my-project`

**Target path handling:** Resolve `<path>` to an absolute path at the start (e.g. `/Users/dev/my-project`) and pass `-r <path>` to every Scout CLI operation. Write output files under `<path>/.scout/evaluations/`. Validate with `scout evaluate -r <path> -q <path>/.scout/evaluations/<repo>-query-set.toml`.

The repository must be attached and indexed (`scout list` shows it as "Watching").

## What This Produces

Two files in the product team's repo at `.scout/evaluations/`:

1. **`<repo>-query-set.toml`** — Search quality evaluation (NDCG/MRR). Tests whether Scout finds the right code. **Self-service:** run `scout evaluate -r <path> -q <path>/.scout/evaluations/<repo>-query-set.toml` immediately for a quality score.

2. **`<repo>-bench-tasks.json`** (optional) — Agent outcome tasks. Contributed to the Scout team for the centralized with/without comparison benchmark. **Not self-service:** the Scout team selects and verifies the appropriate rubric and gold methodology for each repo's tasks.

## Two Systems, Clearly Separated

| What | File | Who owns gold | Self-service? |
|------|------|--------------|---------------|
| Search quality | `<repo>-query-set.toml` | **You** (grade files 0-3) | Yes — `scout evaluate` |
| Agent outcome | `<repo>-bench-tasks.json` | Scout team (selects appropriate rubric/gold methodology) | No — requires Scout infra |

The query-set TOML is the primary deliverable. The bench-tasks JSON is optional and additive.

## How This Complements `/scout-autotune`

- **Autotune** generates structural queries automatically (symbol lookups, path filters) and tunes ranking parameters. It measures whether the search pipeline works mechanically.
- **Bench-create** captures domain-expert questions only a product engineer can author ("how does X work in our system"). It measures whether Scout understands your codebase the way your team does.

Run autotune first for structural quality, then bench-create for domain-specific quality. If you run both, evaluate bench-create *after* autotune so scores reflect the tuned search parameters. They are complementary.

## Design Rules

1. **The product engineer owns the content.** They know their code, their team's real questions, and what "good" looks like. Scout tools assist; the engineer decides.
2. **Real questions only.** Queries must be questions engineers actually ask when working in this codebase. Not synthetic, not contrived.
3. **Gold must be verifiable.** Every judgment file path must be confirmed to exist in the repo right now. Use `go_to_definition`, `file_outline`, `find_references` to verify — never invent paths.
4. **Queries must discriminate.** If a question is trivially answerable by grepping a unique string, it won't differentiate Scout from baseline. Good queries require understanding: multi-file tracing, architectural questions, cross-module flows.
5. **Match existing format.** The query-set TOML uses the same format as all 30 existing Scout evaluation files. The bench-tasks JSON is a flat `{"slug": "prompt"}` map compatible with `harvest_agent_gold.py`.

## Prerequisites

1. **Scout installed and repo indexed:**
   ```bash
   scout list   # repo should appear as "Watching" (not "Indexing...")
   ```
2. **Familiarity with the codebase.** The person running this should work in this repo daily.
3. **No Scout source code needed.** This skill is self-contained.

---

## Phase 1: Orient (~2 min)

Use Scout tools to understand the repo's shape. This helps suggest relevant queries.

1. `scout architecture-overview -r <absolute-path>` — domains, entry points, hotspots
2. `scout top-symbols -r <absolute-path>` — most architecturally central symbols (CodeRank)
3. `scout coderank -r <absolute-path>` — most important files
4. `scout list-flows -r <absolute-path>` — detected execution flows

Present a summary:
```
Your repo: <N> files, <languages>
<M> domains detected: <list>
Top symbols: <5-8 most central>
Key flows: <3-5 detected flows>
```

Ask the engineer:
> "Which areas are most important to your team? What questions do you ask most often when working here?"

---

## Phase 2: Author Queries (~10 min)

Guide the engineer to create **15-25 queries** across three classes:

### Identifier queries (6-10)
Exact symbol names the engineer searches for. Mix of:
- **High-centrality** (top_symbols results — everyone searches these)
- **Team-specific** (symbols only this team knows about)
- **Ambiguous** (common names that test Scout's disambiguation)

Ask: "What are the key classes, functions, or types you look up regularly?"

### Natural language queries (5-10)
Conceptual questions about how the code works. These should be:
- **Architectural:** "how does the rendering pipeline process filters"
- **Multi-file:** answers span 3+ files across modules
- **Discriminating:** can't be answered by grepping a unique string

Ask: "If a new team member asked 'how does X work here?', what would X be?"

Quality bar — good NL queries look like these (from an Adobe Express benchmark):
- "Trace how a property edit flows from the UI through the ECS to the renderer"
- "How does the co-editing conflict resolution rebase local changes against server ordering"
- "How does the keybinding registry resolve conflicts between multiple matching bindings"

### Filtered queries (4-6)
Scoped searches with path or extension constraints:
- `paths = ["src/api/"]` — limit to a subdirectory
- `extensions = ["ts", "tsx"]` — limit to file types
- `definitions_only = true` — only definition-site chunks

Ask: "When you search, do you often scope to a specific directory or file type?"

---

## Phase 3: Grade (~15 min)

For each query, establish ground truth by grading files:

### Grading scale
- **3 (Perfect):** THE definitive file for this query. The one you'd send a colleague.
- **2 (Highly relevant):** Important related code. Part of the answer.
- **1 (Relevant):** Contains some related code. Supporting context.
- **0 (Not relevant):** Should NOT appear in results (use sparingly — only for known distractors).

### Process per query

**For identifier queries:**
1. Run `scout go-to-definition <name> -r <absolute-path>`
2. Present the top 10-15 candidate files to the engineer
3. Engineer assigns grades (typically 8-12 files per query)
4. **Verify every path exists:** run `scout file-outline <path> -r <absolute-path>` for each candidate — if it fails, the path is stale/wrong. Remove it.

**For natural language and filtered queries (domain-knowledge first):**

Both NL and filtered queries use `search`, which is non-deterministic — Scout may miss files that should be in the judgment set. To avoid circular measurement (only grading what Scout already finds):

1. **Before showing any results**, ask the engineer:
   > "Based on your knowledge of this codebase, what 2-3 files would you expect to be most relevant for this question?"
2. Record those files as the engineer's domain-knowledge anchors (grade 2-3).
3. Run the query via Scout:
   - NL → `scout search "<question>" -r <absolute-path>`
   - Filtered → `scout search "<terms>" -r <absolute-path> -e <ext> -p <path>`
4. Present Scout's top 10-15 results for additional grading — the engineer may upgrade, add, or mark results as irrelevant (grade 0).
5. **Verify every path exists** (domain-knowledge and Scout-surfaced alike) with `scout file-outline <path> -r <absolute-path>`.

This ensures the judgment set includes files the engineer knows *should* appear, even if Scout fails to retrieve them — making the benchmark capable of exposing recall gaps.

### Common grading patterns
- Definition file = 3, test file for it = 2, consumer that imports it = 1
- Core implementation = 3, related utility = 2, config that references it = 1
- For NL: the file that best explains the concept = 3, supporting files = 2, tangential = 1

---

## Phase 4: Write & Validate (~2 min)

### Write the query-set TOML

```toml
description = "<Project name> search quality evaluation — <brief description>"

[[queries]]
id = "ident-1"
query = "<SymbolName>"
class = "identifier"

[[queries]]
id = "nl-1"
query = "how does the caching layer invalidate stale entries"
class = "natural_language"

[[queries]]
id = "filtered-1"
query = "ErrorHandler middleware"
class = "filtered"
extensions = ["ts"]
paths = ["src/api/"]

[judgments."ident-1"]
"path/to/Definition.ts" = 3
"path/to/usage.ts" = 2
"path/to/related.ts" = 1

[judgments."nl-1"]
"src/cache/CacheInvalidator.ts" = 3
"src/cache/TTLPolicy.ts" = 2
"src/config/cache.ts" = 1

[judgments."filtered-1"]
"src/api/middleware/ErrorHandler.ts" = 3
"src/api/middleware/index.ts" = 1
```

Save to: `.scout/evaluations/<repo>-query-set.toml`

### Validate immediately

Ensure the daemon is warm before evaluating — a freshly started daemon returns all-zeros. Run `scout status -r <path>` and confirm the repo shows "Watching" (not "Indexing..."). If the daemon just restarted, run one search first to warm the caches.

```bash
scout evaluate -r <path> -q <path>/.scout/evaluations/<repo>-query-set.toml
```

**Interpreting results:**
- Identifier queries should score MRR ≥ 0.8 (Scout almost always finds definitions)
- NL queries typically score NDCG@5 = 0.3-0.7 depending on repo complexity
- If ALL queries score 0.000 — the daemon is likely cold or still indexing. Check `scout status -r <path>`.

### Diagnosing zero scores

A query scoring 0.000 is not necessarily wrong gold — it may be exactly the retrieval gap the benchmark exists to expose. Diagnose before changing judgments:

| Symptom | Cause | Action |
|---------|-------|--------|
| All queries score 0.000 | Cold/indexing daemon | Run `scout status` — wait for "Watching" state |
| One query scores 0.000, path doesn't exist | Stale path (file renamed/deleted) | Re-verify with `file_outline`, update path |
| One query scores 0.000, paths all exist, Scout returns other files | Genuine retrieval gap | **Keep the judgment** — this is a valid benchmark signal |
| One query scores 0.000, paths exist, Scout returns nothing | Empty retrieval for this query shape | Check query class is correct (NL vs identifier); if correct, keep — it's a real gap |
| Low score but not zero | Scout finds some but not all gold files | Normal — this is what NDCG measures |

**Do not change valid gold to fit current Scout results.** A zero-score NL query with verified paths is the most valuable kind of benchmark entry — it exposes where Scout needs to improve.

---

## Phase 5 (Optional): Agent Outcome Tasks

For engineers who want to contribute to Scout's agent-vs-baseline benchmark:

### Format

Flat JSON map — each key is a task slug, each value is the natural-language prompt:

```json
{
  "brick-lifecycle": "Trace the full lifecycle of a Brick from registration through dependency resolution, activation, to deactivation. Show the key files and functions involved.",
  "ecs-edit-flow": "Trace how a property edit flows from the UI component through the ECS transaction to the renderer update. List every file in the chain.",
  "auth-token-refresh": "How does the OAuth token refresh mechanism work when a request fails with 401? Trace from the HTTP interceptor through token storage to retry."
}
```

Save to: `.scout/evaluations/<repo>-bench-tasks.json`

### Quality bar for tasks

Good tasks are:
- **Architectural** — require understanding 5+ files across 2+ modules
- **Multi-hop** — can't be answered from a single file or grep
- **Discriminating** — an agent with Scout should find significantly more relevant files than an agent with only grep/glob/read
- **Realistic** — questions engineers actually ask or would ask a senior teammate

Bad tasks:
- "Find the main entry point" (trivial)
- "What language is this written in" (no code understanding needed)
- "Find all TODO comments" (grep handles this fine)

### What happens next

1. Commit both files to your repo: `git add .scout/evaluations/ && git commit -m "Add Scout benchmark suite"`
2. Post in `#scout-search-support`: "Benchmark ready for <repo>"
3. The Scout team will:
   - Pull the query-set into `scout_config/evaluations/` for centralized regression
   - Wire bench-tasks into a `benchmark-<repo>.sh` script with quality rubrics
   - Run the with/without comparison and publish results
   - Add to the release regression suite

---

## Output Summary

When complete, tell the engineer (using the resolved absolute path):

```
Done! Your benchmark suite is ready:

  <path>/.scout/evaluations/<repo>-query-set.toml   — <N> graded queries (search quality)
  <path>/.scout/evaluations/<repo>-bench-tasks.json  — <M> agent tasks (outcome quality)

Search quality (immediate):
  scout evaluate -r <path> -q <path>/.scout/evaluations/<repo>-query-set.toml
  NDCG@5: <score>   MRR: <score>   Recall@10: <score>

Next steps:
  1. cd <path> && git add .scout/evaluations/ && git commit -m "Add Scout benchmark suite"
  2. Post in #scout-search-support: "Benchmark ready for <repo>"
  3. The Scout team reviews, selects the appropriate rubric/gold methodology, and runs the with/without comparison
```
