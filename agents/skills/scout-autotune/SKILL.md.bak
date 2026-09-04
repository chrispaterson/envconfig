---
name: scout-autotune
description: Automatically tune Scout search quality for a repository. Analyzes project structure, generates or updates `.scout/scout.config.yaml` (ignore/boost/dampen rules), creates a query-set.toml for evaluation, then runs 48 parameter sweeps (including class-aware learned-ranker probes) to find optimal search tune params. Use when asked to "autotune", "scout-autotune", "tune search for <repo>", or "optimize search quality".
---

# Scout Autotune — Automated Search Quality Optimization

Analyze a project, configure `.scout/scout.config.yaml` rules, generate an evaluation query set, and sweep search parameters to find the optimal configuration for that repo.

**Usage:** `/autotune <path>`

Examples:
- `/autotune .` (current directory)
- `/autotune ~/Downloads/dev/photoshop`
- `/autotune /path/to/my-project`

The repository must be attached and indexed in Scout (`scout list` shows it as "Watching").

---

## Config file layout (post v0.9.67)

All per-repo configuration lives in a **single YAML file** at `<repo>/.scout/scout.config.yaml`. Legacy `.scoutignore` / `.scoutconfig` are auto-migrated on attach (originals preserved as `.bak`). Do not write new `.scoutignore` files.

Top-level keys (all optional):

```yaml
repository:
  repo_type: auto           # auto | code | documentation

ignore:                      # gitignore-style patterns excluded from indexing
  - docs/backlog/*/plans/
  - build/

dampen:                      # list of rules; factor in [0, 1] lowers rank
  - factor: 0.5
    patterns:
      - autoresearch/
  - factor: 0.65
    patterns:
      - docs/coding-agent/

boost:                       # list of rules; factor >= 1.0 raises rank
  - factor: 1.3
    patterns:
      - crates/search_cli/src/repository_manager/
  - factor: 1.2
    patterns:
      - crates/search/src/

tune:                        # per-repo search-pipeline overrides
  rerank_weight_nl: 0.4
  rrf_semantic_weight_nl: 1.2
  # ... (see crates/search/src/indexer/mod.rs::SearchTuneParams)

# Optional extras:
markdown: { ... }            # wikilink / frontmatter tuning for doc repos
ranking: { staleness_days: 90, hub_boost: 1.5, type_boosts: {} }
index: { include_paths: [], exclude_paths: [] }
projects: { auto_detect: true, overrides: {}, domain_walls: hard }
```

Template repo at `<scout-src>/scout_config/<name>.yaml` is seeded on attach and can be synced back with `scout admin sync-template`.

---

## Learned-ranker compatibility (v0.9.117+)

The sole shipping v17 model is `bundled:v17`, a 67-feature, 2-layer / 8-head /
`d_model=48` Listwise transformer trained with Seed 99 and anchored to the
normalized upstream composite score. v16 remains bundled only for explicit
rollback. Autotune always probes v17; it does not retain or sweep arbitrary
model paths.

The runtime supports independent blends for `identifier`, `natural_language`,
and `filtered` queries through `learned_ranker_blend_per_class`. The CLI keys
are `blend_class.identifier`, `blend_class.natural_language`, and
`blend_class.filtered`. Class overrides win over intent, caller, and global
defaults.

**Sweep protocol:**

1. **Rounds 1–44 run with v17 at global blend 1.0 and no class overrides.** Sweep upstream params against the ranker-on baseline. Before starting, remove stale class overrides by setting each `blend_class.*` key to `-1`.
2. **Rounds 45–48 probe global blends `{0.25, 0.5, 0.75, 1.0}`** on top of the saved upstream compound, with a separately captured blend-0 baseline. Each evaluation already reports NDCG by query class. Because one query belongs to exactly one class, the four global probes reveal the response curve for all three classes in only four evaluations.
3. **Persist a class-aware result.** Set global blend to `0`, then write the independently selected values to all three `blend_class.*` keys. Evaluate that compound twice before saving.

**Calibration run (recommended before Phase 4).** Before sweeping, measure current-config performance at blend=1.0 and blend=0.0 with class overrides removed. This quantifies how much v17 contributes before upstream tuning and prevents a stale per-class config from contaminating the baseline.

**Baseline capture.** The Phase 4a baseline and rounds 1–44 use v17 at blend 1.0. Step 4e captures a second, ranker-off baseline after upstream winners are saved; that second baseline is the reference for class selection.

**Why this differs from the earlier workflow.** A single global blend forces all
query classes to accept the same trade-off. The v17 live panel showed that a
repo can benefit strongly on NL or filtered queries while identifiers prefer
zero. The shared-probe method obtains three independent optima without tripling
the evaluation count.

**Note on RankingSignal knobs.** The per-signal runtime knobs (`signal_weight.<name>` / `signal_disable.<name>`) are NOT swept by the default 48-round plan — there are ~10 signals and sweeping them blindly doubles the sweep count. If a run of `SCOUT_RANKING_TRACE=1` reveals a specific signal dominates failures, add 2–4 targeted rounds manually (e.g., `signal_weight.name_match 0.5`, `signal_weight.name_match 1.5`).

---

## Phase 1: Validate Prerequisites

Run these checks. STOP and report if any fail:

1. **Path exists and is a git repo:**
   ```bash
   cd <path> && git rev-parse --show-toplevel
   ```

2. **Scout daemon is running:**
   ```bash
   scout daemon status
   ```

3. **Repo is attached and indexed:**
   ```bash
   scout list
   ```
   The repo must appear as "Watching" with files indexed. If not: `scout attach <path>` and wait for indexing to complete.

4. **Check for existing config:**
   ```bash
   CONFIG="<path>/.scout/scout.config.yaml"
   if [ -f "$CONFIG" ]; then cat "$CONFIG"; else echo "NO_CONFIG"; fi
   ```
   If the config exists, **preserve it as the starting point** — all Phase 2 modifications build on top of it. If it already has a `tune:` section, note those as the current tuned values. Legacy `.scoutignore` / `.scoutconfig` are auto-migrated on attach; do not create new ones.

5. **Check for existing query-set:**
   ```bash
   # Query sets live in scout_config/evaluations/{repo-name}-query-set.toml (in the Scout source tree).
   REPO_NAME=$(basename <path>)
   QS="<scout-src>/scout_config/evaluations/${REPO_NAME}-query-set.toml"
   if [ -f "$QS" ]; then echo "Found: $QS"; else echo "NO_QUERY_SET"; fi
   ```
   If a query-set already exists, ask: **"Found existing query-set at `<path>`. Use it, or generate a new one?"**

---

## Phase 2: Project Analysis + `scout.config.yaml` generation

### Step 2a: Profile the repository

Use Scout tools — NOT grep/glob:

1. **`mcp__scout__list_repositories`** — confirm repo path and file count
2. **`mcp__scout__architecture_overview`** — domains, entry points, hotspots
3. **`mcp__scout__file_outline`** on root directory — top-level structure
4. **`mcp__scout__deep_search`** with query `"project architecture and main entry points"` — understand the codebase
5. **`mcp__scout__top_symbols`** — discover key types and functions

From this, determine:
- **Language mix** (primary + secondary languages)
- **Source directories** (where the real code lives)
- **Test directories** (unit, integration, e2e)
- **Generated/vendored code** (node_modules, vendor, generated, proto stubs, etc.)
- **Documentation directories**
- **Build artifacts / config directories**
- **High-value entry points** (main files, API handlers, core types)

### Step 2b: Generate or update `ignore` / `dampen` / `boost`

If `.scout/scout.config.yaml` already exists, **read it first** and preserve all existing rules. Only add new rules that are clearly missing. Do NOT remove or change existing rules unless they are obviously wrong.

If it doesn't exist, generate one from scratch.

**Rule categories to consider:**

**`ignore:`** (exclude from indexing entirely):
- Build output directories (`build/`, `dist/`, `target/`, `out/`, `.next/`)
- Package manager directories (`node_modules/`, `vendor/`, `.venv/`)
- Generated code (proto stubs, GraphQL codegen, OpenAPI clients)
- Binary/media files
- IDE/editor config (`.idea/`, `.vscode/` settings)
- Lock files (`package-lock.json`, `yarn.lock`, `Cargo.lock`, `pnpm-lock.yaml`)

**`dampen:`** (index but rank lower; `factor` in `[0, 1]`):
- Test files and directories (`factor: 0.6`)
- Example/sample code (`factor: 0.5`)
- Documentation markdown (`factor: 0.7`)
- Config files, CI/CD pipelines (`factor: 0.4`)
- Migration files (`factor: 0.5`)
- Storybook stories (`factor: 0.4`)
- Fixture/mock data (`factor: 0.3`)

**`boost:`** (rank higher; `factor >= 1.0`):
- Core source directories containing business logic (`factor: 1.3`)
- API/handler directories (`factor: 1.2`)
- Type definitions, interfaces, models (`factor: 1.2`)
- Main entry points (`factor: 1.3`)

**Present the proposed YAML to the user for approval before writing it.** Show what's new vs. what was preserved from the existing file.

### Step 2c: Write the config and reload

Edit `<path>/.scout/scout.config.yaml` directly (it's a regular YAML file) and then reload the daemon:

```bash
scout admin refresh-config <path>
```

> `refresh-config` replaces the old `refresh-scoutignore` command. It re-reads the full YAML including the `tune:` section.

---

## Phase 3: Query Set Generation

Generate a query-set TOML for evaluating search quality. Save it at `<scout-src>/scout_config/evaluations/{repo-name}-query-set.toml` (inside the Scout source tree, alongside other eval files).

### Step 3a: Design queries

Create **15-25 queries** across three classes:

| Class | Count | Description |
|-------|-------|-------------|
| `identifier` | 6-10 | Exact symbol names (types, functions, constants) — mix of popular and niche |
| `natural_language` | 5-10 | Conceptual questions about what code does ("how does authentication work", "error handling for network requests") |
| `filtered` | 4-6 | Identifier + extension/path filter (`extensions = ["rs"]`, `paths = ["src/api"]`) |

**Good queries:**
- Use real symbols discovered via `top_symbols` and `deep_search`
- NL queries should describe behavior/purpose, not symbol names
- Filtered queries should test that filters narrow results correctly
- Mix easy (unique names) and hard (common names, conceptual) queries

**For each query, provide relevance judgments:**
- Grade 3 (Perfect): The definitive file for this query
- Grade 2 (Highly relevant): Contains important related code
- Grade 1 (Relevant): Contains some related code
- Grade 0 (Not relevant): Should not appear in results

Use `mcp__scout__search`, `mcp__scout__go_to_definition`, and `mcp__scout__find_references` to determine ground truth files for each query.

### Step 3b: Write query-set.toml

```toml
description = "<Project name> search quality evaluation"

[[queries]]
id = "ident-1"
query = "<SymbolName>"
class = "identifier"

[judgments.ident-1]
"path/to/definition.rs" = 3
"path/to/usage1.rs" = 2
"path/to/related.rs" = 1

[[queries]]
id = "nl-1"
query = "how does the caching layer work"
class = "natural_language"

[judgments.nl-1]
"src/cache/mod.rs" = 3
"src/cache/lru.rs" = 2
"src/config/cache_config.rs" = 1

[[queries]]
id = "filt-1"
query = "ErrorHandler"
class = "filtered"
extensions = ["ts"]

[judgments.filt-1]
"src/errors/handler.ts" = 3
"src/middleware/error.ts" = 2
```

### Step 3c: Validate the query set

```bash
scout evaluate -q <query-set-path> -r <path>
```

If any queries score 0.0 across the board, the judgments are probably wrong — fix them before proceeding.

---

## Phase 4: Parameter Sweep (48 rounds)

### Step 4a: Establish baseline

Normalize ranker state before capturing the baseline. A negative class value
removes that override from the in-memory map:

```bash
scout admin set-tune --path <path> learned_ranker_model_path bundled:v17
scout admin set-tune --path <path> learned_ranker_blend 1.0
for class in identifier natural_language filtered; do
  scout admin set-tune --path <path> "blend_class.$class" -1
done
```

```bash
scout evaluate -q <query-set-path> -r <path> --json > baseline.json 2>&1
```

Extract and display baseline metrics:
```bash
python3 -c "
import json
text = open('baseline.json').read()
d = json.loads(text[text.find('{'):])
agg = d['aggregate']
print(f\"Baseline — NDCG@5: {agg['mean_ndcg_5']:.4f}  NDCG@10: {agg['mean_ndcg_10']:.4f}  MRR: {agg['mean_mrr']:.4f}\")
for cls in sorted(d.get('by_class', {}).keys()):
    c = d['by_class'][cls]
    print(f\"  {cls:20s} NDCG@5={c['mean_ndcg_5']:.4f}  NDCG@10={c['mean_ndcg_10']:.4f}  ({c.get('query_count', '?')} queries)\")
"
```

### Step 4b: Define sweep plan

Sweep the most impactful parameters first. Each sweep tests a single parameter change against the baseline.

**Sweep schedule (48 rounds):**

> Rounds 1–44 run with `bundled:v17` at global blend 1.0 and no class overrides. Rounds 45–48 probe four non-zero blends on top of the saved upstream compound; Step 4e combines the three independently selected class optima.

| Round | Parameter | Values to test | Why |
|-------|-----------|----------------|-----|
| 1-3 | `rerank_confidence_threshold` | 0.2, 0.5, 0.6 | Biggest universal impact — controls dampening activation |
| 4-5 | `rerank_weight_nl` | 0.40, 0.70 | Reranker influence on NL |
| 6-7 | `rerank_weight_ident` | 0.35, 0.65 | Reranker influence on ident |
| 8-9 | `rerank_weight_filtered` | 0.25, 0.55 | Reranker influence on filtered |
| 10-11 | `rerank_candidates_nl` | 20, 40 | Reranker window size for NL |
| 12-13 | `rerank_candidates_ident` | 10, 25 | Reranker window size for ident |
| 14-15 | `rerank_floor` | 0.30, 0.60 | Minimum dampened score |
| 16-17 | `rrf_semantic_weight_nl` | 0.8, 1.5 | Semantic vs BM25 balance for NL |
| 18-19 | `rrf_bm25_weight_nl` | 0.5, 1.2 | BM25 weight for NL |
| 20-21 | `rrf_semantic_weight_ident` | 0.5, 1.0 | Semantic weight for ident |
| 22-23 | `rrf_bm25_weight_ident` | 1.0, 1.6 | BM25 weight for ident |
| 24-25 | `rerank_evidence_budget_nl` | 600, 1200 | Text budget for NL evidence extraction |
| 26-27 | `rerank_evidence_budget_ident` | 400, 800 | Text budget for ident evidence extraction |
| 28-29 | `prf_top_k` | 5, 15 | PRF document count |
| 30 | `prf_confidence_threshold` | 0.60 | PRF skip threshold |
| 31-32 | `recency_weight_nl` | 0.05, 0.15 | Rank-by-attribute: recency sigmoid weight on NL (v0.9.61+) |
| 33-34 | `recency_weight_ident` | 0.02, 0.10 | Rank-by-attribute: recency on identifier queries |
| 35-36 | `recency_midpoint_days` | 14, 90 | Sigmoid half-value (sharper vs gentler decay) |
| 37-38 | `coderank_weight_nl` | 0.10, 0.30 | Rank-by-attribute: file-level CodeRank boost on NL |
| 39-40 | `coderank_weight_ident` | 0.05, 0.20 | Rank-by-attribute: CodeRank on ident |
| 41-42 | `symbol_popularity_weight_nl` | 0.10, 0.25 | Rank-by-attribute: per-symbol popularity boost on NL (v0.9.61+) |
| 43-44 | `symbol_popularity_weight_ident` | 0.10, 0.25 | Rank-by-attribute: per-symbol popularity on ident |
| 45-48 | `learned_ranker_blend` class probes | 0.25, 0.5, 0.75, 1.0 | Measure all three class response curves in four shared evaluations after rounds 1–44 are compounded. A separate blend-0 evaluation is the class-selection baseline. |

**Learned-ranker notes (rounds 45–48):**
- Force `learned_ranker_model_path = "bundled:v17"`; model selection is not a sweep dimension.
- Remove any existing class override before rounds 1–48 with `blend_class.<class> -1`, otherwise it takes precedence over the global probe.
- Run the probes only after Step 4e has compounded and saved the upstream winners from rounds 1–44.
- For each class, compare `{0, 0.25, 0.5, 0.75, 1.0}` using that class's `mean_ndcg_5`. Keep 0 unless the best non-zero value clears the class-size variance threshold. When candidates are within 0.002, prefer the lower blend.
- The final config always carries `learned_ranker_model_path: bundled:v17`, global blend `0`, and explicit values for all three class keys. This makes opt-in behavior inspectable and prevents a caller/global default from silently enabling a rejected class.

**Rank-by-attribute notes (rounds 31-44):**
- Only meaningful when `bm25_legacy_mode: false` (default from v0.9.61).
- `recency` promotes recently-modified files; `coderank` promotes well-referenced files; `symbol_popularity` promotes well-referenced symbols (orthogonal to file-level coderank).
- Weights above ~0.3 tend to over-promote hubs/recent files and regress precise identifier queries — keep test values conservative.
- The three signals compose in MAXSCORE without interference as long as total per-clause ceiling stays below ~0.5 — higher values should be offset with tighter midpoints.
- Run them LATE in the sweep because they interact with RRF weights; tune RRF first for a better starting point.

### Step 4c: Generate and execute sweep script

**Generate a bash script** to run all sweeps — this is far more efficient than individual tool calls. The script should:
- Set each parameter via `set-tune`
- Run eval and extract metrics to CSV
- Reset to defaults between sweeps via `refresh-config`

**CLI syntax:**
- `scout admin set-tune --path <repo> <KEY> <VALUE>` — in-memory, no restart
- `scout admin refresh-config <repo>` — re-reads YAML from disk (resets in-memory overrides)
- `scout admin save-tune <repo>` — persists current in-memory `tune:` back into `.scout/scout.config.yaml`

```bash
#!/bin/bash
set -euo pipefail

REPO="<absolute-path>"
QS="<query-set-path>"
OUTDIR="autotune_results"
mkdir -p "$OUTDIR"

apply_ranker_baseline() {
  scout admin set-tune --path "$REPO" learned_ranker_model_path bundled:v17 >/dev/null
  scout admin set-tune --path "$REPO" learned_ranker_blend 1.0 >/dev/null
  for class in identifier natural_language filtered; do
    scout admin set-tune --path "$REPO" "blend_class.$class" -1 >/dev/null
  done
}

SWEEPS=(
  "1 rerank_confidence_threshold 0.2"
  "2 rerank_confidence_threshold 0.5"
  "3 rerank_confidence_threshold 0.6"
  # ... all 44 entries ...
)

echo "round,param,value,ndcg5,ndcg10,mrr,nl5,ident5,filt5" > "$OUTDIR/sweep_results.csv"
apply_ranker_baseline

for entry in "${SWEEPS[@]}"; do
  read -r round param value <<< "$entry"
  echo "=== Round $round: $param=$value ==="

  scout admin set-tune --path "$REPO" "$param" "$value" > /dev/null 2>&1
  scout evaluate -q "$QS" -r "$REPO" --json > "$OUTDIR/sweep_${round}.json" 2>&1

  python3 -c "
import json
text = open('$OUTDIR/sweep_${round}.json').read()
d = json.loads(text[text.find('{'):])
agg = d['aggregate']
bc = d.get('by_class', {})
nl5 = bc.get('natural_language', {}).get('mean_ndcg_5', 0)
id5 = bc.get('identifier', {}).get('mean_ndcg_5', 0)
fl5 = bc.get('filtered', {}).get('mean_ndcg_5', 0)
print(f'$round,$param,$value,{agg[\"mean_ndcg_5\"]:.4f},{agg[\"mean_ndcg_10\"]:.4f},{agg[\"mean_mrr\"]:.4f},{nl5:.4f},{id5:.4f},{fl5:.4f}')
" >> "$OUTDIR/sweep_results.csv"

  # Reset to baseline (re-reads YAML from disk, discarding in-memory override)
  scout admin refresh-config "$REPO" > /dev/null 2>&1
  apply_ranker_baseline
  echo "  Done: round $round"
done

echo "=== Sweep complete ==="
```

Run the script with a generous timeout (each round takes ~30-60s depending on repo size):
```bash
bash autotune_sweep.sh
```

### Step 4d: Analyze results and select winners

Analyze the CSV with variance-aware decision rules:

```python
python3 -c "
import json, csv

text = open('autotune_results/baseline.json').read()
bd = json.loads(text[text.find('{'):])
base = {
    'ndcg5': bd['aggregate']['mean_ndcg_5'],
    'nl5': bd['by_class']['natural_language']['mean_ndcg_5'],
    'id5': bd['by_class']['identifier']['mean_ndcg_5'],
    'fl5': bd['by_class']['filtered']['mean_ndcg_5'],
}

class_counts = {cls: bd['by_class'][cls].get('query_count', 5)
                for cls in bd['by_class']}

winners = []
with open('autotune_results/sweep_results.csv') as f:
    for row in csv.DictReader(f):
        n5 = float(row['ndcg5'])
        delta = n5 - base['ndcg5']
        regressions = {}
        for cls, key in [('nl', 'nl5'), ('id', 'id5'), ('fl', 'fl5')]:
            cls_full = {'nl':'natural_language','id':'identifier','fl':'filtered'}[cls]
            count = class_counts.get(cls_full, 5)
            threshold = 0.01 if count >= 10 else (0.02 if count >= 5 else 0.03)
            reg = float(row[f'{cls}5']) - base[f'{cls}5']
            if reg < -threshold:
                regressions[cls_full] = reg
        is_winner = delta >= 0.005 and not regressions
        if is_winner:
            winners.append((row['param'], row['value'], delta, n5))

for p, v, d, n5 in winners:
    print(f'  WIN: {p} = {v}  (NDCG@5: {n5:.4f}, +{d:.4f})')
if not winners:
    print('No strict winners — proceed to relaxed compound selection')
"
```

**Decision rules (variance-aware):**
- **Keep** a parameter change if it improves aggregate NDCG@5 by >= 0.005 without regressing any class beyond its variance threshold.
- **Variance thresholds by class size:**
  - 10+ queries: regression > 0.01 is real
  - 5-9 queries: regression > 0.02 is real
  - <5 queries: regression > 0.03 is real
- If a class has <8 queries, treat regressions of 0.01-0.02 as noise unless consistent across multiple sweeps with different parameters.

**Fallback when strict rules produce zero winners — relaxed compound selection:**
1. Sort all sweeps by aggregate NDCG@5 delta (descending).
2. Take the top 3-5 candidates that improve aggregate by >= 0.005.
3. Check whether their class "regressions" are consistent (same class regresses across many sweeps regardless of parameter = baseline was a high roll) or specific (only one parameter causes it = real regression).
4. If inconsistent/noisy, proceed to compound with the top candidates.
5. If consistent and specific to one parameter, exclude that parameter.

### Step 4e: Compound best values

After selecting winners (strict or relaxed):

1. Set ALL winning parameter values together:
   ```bash
   scout admin set-tune --path <path> <param1> <best_value1>
   scout admin set-tune --path <path> <param2> <best_value2>
   # ... for each winner
   ```

2. Evaluate the compound configuration (2 runs to check stability):
   ```bash
   scout evaluate -q <query-set-path> -r <path> --json > compound_a.json 2>&1
   scout evaluate -q <query-set-path> -r <path> --json > compound_b.json 2>&1
   ```

3. Compare both compound runs against baseline. A real improvement should appear in both runs.

4. If compound is worse than individual bests (interaction effects), try removing winners one at a time to find the conflict.

5. **Try expanding**: if the compound is better than baseline, try adding the next-best candidate from the sweep results and re-evaluate. Stop when adding more parameters doesn't help.

6. **Class-aware learned-ranker probes**: the upstream compound is now the
   baseline for v17. Save upstream winners to disk, remove stale class
   overrides, capture the blend-0 result, then run four shared probes:
   ```bash
   scout admin save-tune "$REPO"
   scout admin set-tune --path "$REPO" learned_ranker_model_path bundled:v17
   for class in identifier natural_language filtered; do
     scout admin set-tune --path "$REPO" "blend_class.$class" -1
   done

   scout admin set-tune --path "$REPO" learned_ranker_blend 0
   scout evaluate -q "$QS" -r "$REPO" --json > "$OUTDIR/blend_0.json"

   for blend in 0.25 0.5 0.75 1.0; do
     scout admin set-tune --path "$REPO" learned_ranker_blend "$blend"
     scout evaluate -q "$QS" -r "$REPO" --json > "$OUTDIR/blend_${blend}.json"
   done
   ```
   Parse each file's `by_class` block. For each of `identifier`,
   `natural_language`, and `filtered`, select the blend with the highest
   `mean_ndcg_5` among `{0, 0.25, 0.5, 0.75, 1.0}`. Keep 0 unless the best
   candidate improves over blend 0 by at least the class-size variance
   threshold from Step 4d. Prefer the lower blend when scores are within
   0.002.

7. **Apply and verify the class compound**:
   ```bash
   scout admin set-tune --path "$REPO" learned_ranker_model_path bundled:v17
   scout admin set-tune --path "$REPO" learned_ranker_blend 0
   scout admin set-tune --path "$REPO" blend_class.identifier "$BEST_IDENT"
   scout admin set-tune --path "$REPO" blend_class.natural_language "$BEST_NL"
   scout admin set-tune --path "$REPO" blend_class.filtered "$BEST_FILTERED"
   scout evaluate -q "$QS" -r "$REPO" --json > "$OUTDIR/class_compound_a.json"
   scout evaluate -q "$QS" -r "$REPO" --json > "$OUTDIR/class_compound_b.json"
   ```
   Both runs must be aggregate-non-regressing within 0.002 versus blend 0 and
   must not regress a class beyond its Step 4d variance threshold. If the
   compound fails, remove the weakest class winner and repeat. Save only the
   verified compound.

### Step 4f: Save optimal parameters

`scout admin save-tune` persists the current in-memory `tune:` section into `.scout/scout.config.yaml`. Non-tune keys (ignore/boost/dampen/etc.) are preserved.

```bash
# After the winning set-tune calls are in memory:
scout admin save-tune <path>

# Optional sanity reload — should be a no-op because the YAML matches in-memory state
scout admin refresh-config <path>
```

Then **propagate the tuned config back to the Scout source tree** so the template tracks the winning values:

```bash
scout admin sync-template --repo <path> --scout-src <path-to-scout-src>
# Or rely on SCOUT_SRC env var:
#   SCOUT_SRC=/Users/acostin/Downloads/dev/scout scout admin sync-template --repo <path>
```

This copies `<path>/.scout/scout.config.yaml` into `<scout-src>/scout_config/<name>.yaml`. The template name is resolved via git remote origin → directory name. Do not `cp` manually — `sync-template` handles the name resolution and preserves any header comments the template needs.

### Step 4g: Verify persisted class state

After `save-tune`, refresh the config and confirm the model, global zero, and
all three class values survive the round trip. Do not restore the caller's old
global blend: the verified class compound is the autotune result.

### Step 4h: Clean up

Remove temporary sweep artifacts:
```bash
rm -rf autotune_results/
rm -f autotune_sweep.sh
```

The query-set at `<scout-src>/scout_config/evaluations/` is intentionally kept — it's useful for future re-evaluation.

---

## Phase 5: Report Results

Present a summary to the user:

```
## Autotune Results for <project>

### scout.config.yaml
- <N> ignore rules, <N> dampen rules, <N> boost rules
- [New / Updated from existing]

### Query Set
- <N> queries (<N> identifier, <N> NL, <N> filtered)
- Saved to: <scout-src>/scout_config/evaluations/<name>-query-set.toml

### Parameter Sweep (48 rounds — 44 upstream + 4 shared class probes)
| Metric    | Baseline | Tuned Upstream | Class-aware v17 | Delta (total) |
|-----------|----------|----------------|-----------------|---------------|
| NDCG@5    | 0.XXXX   | 0.XXXX         | 0.XXXX          | +0.XXXX       |
| NDCG@10   | 0.XXXX   | 0.XXXX         | 0.XXXX          | +0.XXXX       |
| NL@5      | 0.XXXX   | 0.XXXX         | 0.XXXX          | +0.XXXX       |
| Ident@5   | 0.XXXX   | 0.XXXX         | 0.XXXX          | +0.XXXX       |
| Filtered@5| 0.XXXX   | 0.XXXX         | 0.XXXX          | +0.XXXX       |

### Winning Parameters
<list of upstream parameters that were changed from defaults, with values>

### Learned-ranker class blends
- Model: `bundled:v17`
- Global blend: `0.0`
- Identifier: `0.XX`
- Natural language: `0.XX`
- Filtered: `0.XX`

### Saved to
`tune:` section of `<path>/.scout/scout.config.yaml`
Template mirrored into `<scout-src>/scout_config/<name>.yaml`
```

---

## Important Notes

- **Run-to-run variance**: Expect ~±0.005 aggregate NDCG, but per-class variance scales inversely with query count. A class with 5 queries may swing ±0.015.
- **Reset between sweeps**: Each upstream sweep tests ONE parameter change against the normalized v17 baseline. `scout admin refresh-config <repo>` reloads YAML and drops in-memory overrides, so immediately reapply model v17, global blend 1.0, and remove class overrides as shown in `apply_ranker_baseline`. Don't stack changes until the compound phase.
- **Existing config**: Always preserve existing `ignore` / `boost` / `dampen` rules. The user may have carefully tuned patterns. Only add to them.
- **Query set quality matters more than quantity**: 15 well-judged queries beat 50 poorly-judged ones. Use Scout tools to verify ground truth.
- **The daemon must be running throughout**: Parameter changes via `set-tune` modify in-memory state on the daemon. If the daemon restarts, the in-memory overrides are lost (the saved `tune:` section in YAML is still loaded on startup).
- **CLI syntax gotchas**:
  - `set-tune` uses `--path <path>` (flag form).
  - `save-tune` takes `<path>` as a **positional** argument.
  - `refresh-config` takes `<path>` as a **positional** argument.
  - `sync-template` uses `--repo` and `--scout-src` flags.

---

## Autotune v2 — Failure-mode-aware tuning (2026-05-02)

The classic sweep treats every parameter as independent and optimises the
single aggregate NDCG scalar. Experience across 20+ repos shows this leaves
lift on the table:

- **Each repo's winning knob is different.** illustrator won on
  `rerank_evidence_budget_nl`, dropins on `rerank_weight_nl`, nimbus on
  `rerank_confidence_threshold`, consumer on `prf_confidence_threshold`. A
  universal sweep order wastes rounds on knobs that can't move the needle
  for this repo.
- **Independent-axis sweeps miss interactions.** `rrf_semantic_weight_nl`
  and `rrf_bm25_weight_nl` should be a ratio, not two axes. Similarly
  `rerank_candidates_nl` × `rerank_evidence_budget_nl`.
- **Aggregate NDCG obscures class trade-offs.** A +0.04 NL lift that costs
  -0.02 identifier may be the right move for an NL-dominated repo and the
  wrong move for an identifier-heavy one.

### v2 additions (opt-in; the classic sweep still works)

**Step 0: Failure-mode classification.** Before the sweep, probe each
scoring-0 query and classify into one of four patterns (from the consumer
deep-dive, 2026-05-02):

| Pattern | Signal | Lever |
|---|---|---|
| **A** — interface definitions underranked | NL query misses `I*.h` / signature-heavy defs | pre-rerank symbol injection (enabled when CodeRank + symbol-graph loaded), raise `rerank_candidates_nl` |
| **B** — judgment too narrow | scout's top is semantically adjacent, judgment names a sibling | broaden judgments (not a tuning issue) |
| **C** — `.h`/`.cpp` mismatch | ident query lands on header, judgment on source | use the `.h`/`.cpp` pair auto-judging pass; no tuning change |
| **D** — symbol spread across many files | ident name appears in 20+ files, judgment picks 8 | lean on semantic (`rrf_semantic_weight_ident`↑), relax filters |

Emit a classification summary early so the sweep plan can skip knobs the
dominant pattern doesn't address.

**Paired-knob sweeps.** Instead of two axes, sweep the ratio:

```
rrf_ratio_nl ∈ {0.5, 0.7, 1.0, 1.5, 2.0}   # bm25 / sem
rerank_density_nl ∈ {low, med, high}       # joint (candidates, evidence_budget)
```

This halves the dimensionality and captures correlation.

**Per-class Pareto selection.** Instead of picking the config with best
aggregate NDCG, find the Pareto frontier across (ident, NL, filtered) and
let the caller pick a point on it based on the repo's primary use case.

**Diagnostic output.** At the end of the sweep, emit "this repo wants X"
hints based on which knobs produced the biggest delta:

```
DIAGNOSTICS
  Top-lever:  rerank_evidence_budget_nl  (+0.040 NL solo)
  Pattern-A score: 7/12 NL failures — pre-rerank symbol injection expected to help further.
  Saturated knobs: rrf_bm25_weight_ident (±0.001 across full sweep)
```

v2 steps are documented here for future implementation; the current skill
still executes Phase 1-5 as described above. A v2-aware run would insert
failure-mode classification before Phase 4 and substitute the paired-knob
sweep plan for Step 4b.
