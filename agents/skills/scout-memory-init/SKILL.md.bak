---
name: scout-memory-init
description: Seed Scout's memory bank with a comprehensive set of useful memories about a codebase - architecture overview, domain concepts, coupling observations, execution flows, binary inventory, hub files, directory-template patterns, build system, test framework, and documentation pointers. Runs memory.init + memory_infer, then issues LLM-driven follow-up prompts to capture behavioral, navigational, and workflow knowledge that structural inference alone misses. Use when onboarding a new repo to Scout, when asked to "initialize scout memory", "seed memory", "scout-memory-init", or "create memories for <repo>". Produces a ready-to-use memory bank so future investigate/search calls can short-circuit through memory_search.
---

# Scout Memory Init — Comprehensive Memory Seeding

Seed Scout's memory bank with durable, searchable knowledge about a codebase in six passes: structural inference, architecture synthesis, behavioral flows, navigational hubs, workflow (build/test/docs), and a top-level overview memory. Each pass produces memories that subsequent passes can link to.

**Usage:** `/scout-memory-init <path>`

Examples:
- `/scout-memory-init .` (current directory)
- `/scout-memory-init ~/Downloads/dev/photoshop`

The repository must be attached and indexed in Scout (`scout list` shows it as "Watching").

---

## Design Rules

1. **LLM-driven, not deterministic.** Every phase gathers Scout data, then you — the agent — synthesize and call `memory_write`. Do not try to shell-script the memory creation; the point is to use judgment.
2. **Singleton architecture-overview.** If one exists, update in place (supersedes chain is noise).
3. **No git-churn hotspots.** Skip change-churn analysis. Focus on durable structural/behavioral knowledge.
4. **Auto-link across phases.** Flow/hub/pattern memories must set `relationships: [{type: "applies_to", target: "<domain concept title>"}]` so the graph is traversable.
5. **Quality over quantity.** Target ~55-90 entries total across all phases. Skip anything self-evident from the directory name alone.
6. **Aliases are mandatory on concept/hub entries.** Every entry written by Phase 1, 1.5, and 4 MUST end its `content` with an `Aliases / also known as: <canonical>, <alias_1>, ...` line AND mirror every alias as a lowercased tag. This is what `scout admin rebuild-synonyms` parses to bridge user vocabulary to codebase identifiers. No aliases → silent coverage gap.
6. **Never invent names.** Only reference symbols, files, and domains that Scout actually returned.

---

## Phase 0 — Validate & Initialize

Before anything else:

1. **Path sanity check.** Confirm `<path>` exists and is a git repo:
   ```bash
   cd <path> && git rev-parse --show-toplevel
   ```
   If not a repo, stop and report.

2. **Scout attached?** Call `mcp__scout__list_repositories`. The target path must appear. If missing, stop and ask the user to `scout attach <path>` first.

3. **Initialize memory bank** if not already:
   ```bash
   cd <path> && scout memory init
   ```
   This is idempotent — safe to run if `.scout/memory/` already exists.

4. **Check for existing memories.** Call `memory_list` on the repository. If >5 entries already exist, ask the user whether to (a) append to the existing bank, (b) wipe and reseed, or (c) abort. Default to (a).

Only proceed to Phase 1 once all four checks pass.

---

> **Valid `entity_type` values — the binary rejects anything else:** `concept`,
> `observation`, `discovery`, `decision`, `pattern`, `procedure`, `person`,
> `project`, `episode`. The category names used in the phases below (hub-file,
> flow, binary, build, test-pattern, doc-reference) are *descriptive only* —
> always pass a valid `entity_type` and keep the category as a tag. Mapping used
> below: hub-file → `observation`, binary/doc-reference → `concept`,
> flow/build → `procedure`, test-pattern → `pattern`.

## Phase 1 — Structural Inference (memory_infer)

Run Scout's built-in structural analysis:

```
memory_infer(repository=<path>)
```

This returns CodeRank domain clustering, coupling pairs, and top symbols with guidance on writing concept/observation/discovery memories. Follow its rules:

- **concept** entries (entity_type="concept", tier="knowledge", confidence 0.6-0.7): one per non-obvious domain. Describe layer (api/domain/infra/util) + key entry points.
- **observation** entries (entity_type="observation", tier="knowledge", confidence 0.5-0.6): one per high-coupling pair (strength > 0.3). Explain what types cross the boundary and why.
- **discovery** entries (entity_type="discovery", tier="working", confidence 0.5): one per low-cohesion domain (cohesion < 0.3). Name the concern, suggest a split.

Target: 15-25 entries from this phase. Skip domains with fewer than 50 files AND cohesion ≥ 0.9 (pure vendored/single-purpose trees contribute nothing useful).

After each `memory_write` call, note the exact title you used — later phases will reference these titles in `relationships`.

---

## Phase 1.5 — High-Value Symbol + File Coverage

**Purpose.** Phase 1 produces domain-level concept memories, but domain
granularity is too coarse for query-vocabulary bridging. Users search
for specific concepts: `ImageMode`, `PSDFormat`, `SaveUsingFormat`,
`TImageDocument`. If no memory entry names those symbols in its
title/body/tags/aliases, synonym expansion can't bridge a user's
query to the codebase's vocabulary. This phase closes that gap.

**Why it exists.** Direct outcome of the 2026-05-05 Photoshop
self-evaluation where queries like "PSD file format reading" returned
peripheral handlers (CloudPSD, EXR, AVIF) because the core `PSDFormat`
parser had no memory entry mentioning it as an alias. Same class of
miss on "file save export dialog" — only PDF dialogs surfaced because
the generic save path wasn't covered.

### 1.5a. Top symbols — concept coverage for identifiers

1. Call `mcp__scout__top_symbols(repository=<path>, limit=30)`.
2. Filter to symbols **not already mentioned** in any Phase 1 entry's
   tags, aliases, or title. (Call `memory_list` once at the start of
   this phase; build a lowercase set of all tags + alias tokens
   across existing entries; filter the top-30 list against it.)
3. Group remaining symbols by domain (use their file path + CodeRank
   domain mapping). Batch 1–3 tightly-related symbols per memory —
   e.g. `TImageDocument` + `ImageState` + `TFileBasedDocument` all
   describe the document model and should share one entry.
4. For each group, write one `concept` memory:

```
memory_write(
  title="Concept: <umbrella name>",       # e.g. "Concept: Document Model (TImageDocument family)"
  entity_type="concept",
  tier="knowledge",
  confidence=0.65,
  tags=["<domain-tag>", "<symbol-names-as-tags>", ...],  # MIRROR every alias as a tag
  content="<one-paragraph description that names all grouped symbols,
           explains the role each plays, points at the file(s) where
           they live, and ends with:>

Aliases / also known as: <canonical_symbol>, <short_name>, <abbrev>, <conceptual_synonym>, ...",
  relationships=[{"type": "applies_to", "target": "<Phase 1 domain concept title>"}]
)
```

**Alias discipline is mandatory here.** This is the phase whose
explicit purpose is to populate the synonym index. Every entry MUST
end with the `Aliases / also known as:` line AND mirror every alias
as a tag — otherwise `scout admin rebuild-synonyms` has nothing to
mine.

Target: 10-20 memories from this sub-phase. Skip a symbol if any
Phase 1 domain entry already names it prominently in body or tags.

### 1.5b. Top files — hub coverage for central files

Same pattern, but for files instead of symbols. Catches cases where
the file matters but its top symbol is generic (e.g. `UImageFormat.h`
exports `TImageFormat` — the file is the story, not the class).

1. Call `mcp__scout__top_files(repository=<path>, limit=20)`.
   The output is now sorted by **centrality** (CodeRank × √sym_count+1)
   as of v0.9.73 — leaf utilities like `MathFunctions.h` no longer
   dominate; the top is real hub files. Use that ranking.
2. Filter out files already named by Phase 1 domain entries OR by
   Phase 1.5a concept entries (track titles as you go).
3. For each remaining file, write one `hub-file` memory:

```
memory_write(
  title="Hub: <file-basename>",
  entity_type="observation",
  tier="knowledge",
  confidence=0.65,
  tags=["hub", "<domain-tag>", "<basename-as-tag>", "<key-symbol-tags>"],
  content="Path: <full path>. Centrality: <score>. Syms: <N>.
           Key exports: <2-4 key symbols from file_outline>.
           When you edit here: <one-line scenario>.

Aliases / also known as: <basename>, <basename-no-ext>, <key_symbols...>, <conceptual_name>",
  relationships=[{"type": "applies_to", "target": "<owning domain concept>"}]
)
```

Target: 5-15 hub-file memories from this sub-phase. This is distinct
from Phase 4a (which drills into the top 5 domains); Phase 1.5b is
for centrally-ranked files REGARDLESS of domain.

### Overlap with Phase 4a

Phase 4a goes domain-by-domain and picks 2-3 non-obvious hub files per
domain. Phase 1.5b goes by global centrality rank. Overlap is fine —
if the same file would be selected by both, write it once in 1.5b
(earlier phase wins) and note the title; Phase 4a skips duplicates.
Phase 1.5b tends to surface cross-domain hubs (e.g. `TImageDocument.h`
sits in `interfaces` but is central to half the domains); Phase 4a
tends to surface domain-local hubs.

---

## Phase 2 — Architecture Overview Synthesis (singleton)

Produce **one** `architecture-overview` memory — the "first read" entry for every future session.

1. Check if `memory_read(title="Architecture Overview")` already returns something. If yes: you will overwrite it in place (same title = update).
2. Gather from existing state:
   - Top 5 domains by file count (from Phase 1 data)
   - Top 3 coupling hotspots (highest strengths)
   - Call `mcp__scout__architecture_overview(repository=<path>)` for cohesion metrics
   - Call `mcp__scout__top_files(repository=<path>, limit=10)` for CodeRank anchors
3. Write a single memory:

```
memory_write(
  title="Architecture Overview",
  entity_type="concept",
  tier="knowledge",
  confidence=0.8,
  tags=["overview", "architecture", "start-here"],
  content="<~600-800 token synthesis covering: 1) one-line repo purpose, 2) top 5 domains with 1-line purpose each, 3) top 3 coupling hotspots with 'why it matters', 4) primary type system(s), 5) pointer to first-to-read files>"
)
```

This memory is the landing page. Future agents running `memory_search "architecture"` should find this first.

---

## Phase 3 — Behavioral: Flows + Binaries

Captures what *runs*, which structural inference misses entirely.

1. Call `mcp__scout__list_flows(repository=<path>, limit=30)`.
2. For each flow group (cluster flows sharing an entry kind + domain), write one `flow` memory:

```
memory_write(
  title="Flow: <verb phrase>",   # e.g. "Flow: PDF Open Pipeline"
  entity_type="procedure",
  tier="knowledge",
  confidence=0.65,
  tags=["flow", "<domain-tag>", "<kind>"],
  content="Entry point: <symbol> at <file:line>. Dispatches through: <3-5 key callees>. Criticality: <score>. Why an agent edits here: <one line>.",
  relationships=[{"type": "applies_to", "target": "<Phase 1 domain concept title>"}]
)
```

3. Detect binaries: scan for clusters of `main()` functions or equivalent entry points (from `list_flows` kind="main" or "cli"). For each distinct binary/plugin/app, write one `binary` memory:

```
memory_write(
  title="Binary: <name>",        # e.g. "Binary: Distiller"
  entity_type="concept",
  tier="knowledge",
  confidence=0.65,
  tags=["binary", "entry-point"],
  content="Path: <root dir>. Entry: <main file>. Purpose: <one line>. Build target: <if known>.",
  relationships=[{"type": "applies_to", "target": "<owning domain concept>"}]
)
```

Target: 5-15 flow memories + 3-10 binary memories. Combine flows that share the same entry type and adjacent callees rather than creating one memory per flow.

---

## Phase 4 — Navigational: Hub Files + Parallel Patterns

### 4a. Hub files

For each of the top 5 domains from Phase 2:

1. Call `mcp__scout__top_files(repository=<path>, path_prefix="<domain-root-or-representative-path>", limit=5)`.
2. Pick the 2-3 files whose purpose isn't obvious from the filename. Call `mcp__scout__file_outline` on each.
3. Write one `hub-file` memory per file:

```
memory_write(
  title="Hub: <file-basename>",
  entity_type="observation",
  tier="knowledge",
  confidence=0.6,
  tags=["hub", "<domain-tag>"],
  content="Path: <full path>. CodeRank: <score>. Exports: <2-3 key symbols>. When you edit here: <scenario>.",
  relationships=[{"type": "applies_to", "target": "<domain concept>"}]
)
```

Target: 8-15 hub-file memories.

### 4b. Parallel patterns (directory templates)

1. Call `mcp__scout__investigate(repository=<path>, query="parallel patterns and directory templates", intent="understand")`.
2. Scout surfaces detected `parallel_patterns` with pattern_id + member list. For each pattern with ≥4 members:

```
memory_write(
  title="Pattern: <template shape>",  # e.g. "Pattern: Filter<Name>/ sibling dirs"
  entity_type="pattern",
  tier="procedures",
  confidence=0.7,
  tags=["pattern", "scaffolding", "<domain-tag>"],
  content="Template: <shape>. Members: <N siblings>. Reference sibling: <one representative>. To add a new member, use Scout's propose_shell tool with pattern_id=<id> and new_name=<NewName>. Files typically touched: <file list>.",
  relationships=[{"type": "applies_to", "target": "<owning concept>"}]
)
```

Target: 2-8 pattern memories, depending on how template-heavy the repo is.

---

## Phase 5 — Workflow: Build + Test + Docs

### 5a. Build system detection

Look for top-level build files:

```bash
cd <path> && ls -1 | grep -iE '^(makefile|cmakelists\.txt|build\.xml|package\.json|pyproject\.toml|cargo\.toml|go\.mod|.*\.sln|.*\.xcodeproj|gradle.*|\.bazelrc|BUILD)'
```

Also check for `.harness/init.sh`, `build.sh`, `scripts/build*`. Write one `build` memory:

```
memory_write(
  title="Build System",
  entity_type="procedure",
  tier="procedures",
  confidence=0.7,
  tags=["build", "workflow"],
  content="Primary: <cmake|msbuild|gradle|...>. Entry command: <./build.sh | cmake --build . | ...>. Config files: <paths>. Known caveats: <if detected, e.g. requires Xcode 26, Windows-only, etc.>."
)
```

### 5b. Test pattern detection

1. From Phase 1 domains, identify test-related ones by name substring (`test`, `unittest`, `spec`, `pilot`, `automation`, `aat`, `qa`).
2. For each distinct test framework/style detected (e.g. GoogleTest, pytest, AcroPilot, AAT/COM), write one `test-pattern` memory:

```
memory_write(
  title="Test Framework: <name>",
  entity_type="pattern",
  tier="procedures",
  confidence=0.65,
  tags=["testing", "<framework-tag>"],
  content="Scope: <what it covers>. Location: <path pattern>. Typical test file shape: <one line>. How to run: <command or entry point>. When to use this framework vs others in the repo: <one line>."
)
```

Target: 1-4 test-pattern memories (most repos have 1-2; polyglot/legacy repos may have more).

### 5c. Documentation pointers

1. Call `mcp__scout__docs_stats(repository=<path>)`. If the repo has indexed docs:
   - Call `mcp__scout__docs_topic_clusters(repository=<path>, max_clusters=8)`.
   - For each cluster with a clear central doc (highest in-degree), write one `doc-reference` memory:

```
memory_write(
  title="Docs: <cluster topic>",
  entity_type="concept",
  tier="reference",
  confidence=0.6,
  tags=["docs", "<topic-tag>"],
  content="Central doc: <path>. Topic: <one line>. Related docs: <2-3 siblings>. Read this before: <scenario>."
)
```

2. Also surface obvious root docs: README.md, CONTRIBUTING.md, AGENTS.md, CLAUDE.md, ARCHITECTURE.md. One memory per existing root doc:

```
memory_write(
  title="Docs: <filename>",
  entity_type="concept",
  tier="reference",
  confidence=0.7,
  tags=["docs", "root"],
  content="Path: <path>. Purpose: <one-line from the first heading or summary>. Read before: <scenario>."
)
```

If `docs_stats` returns zero indexed docs, skip this phase silently.

Target: 2-10 doc-reference memories.

---

## Phase 6 — Report

After all phases complete, print a summary to the user:

```
Memory seeding complete for <repo>.

Entries written by phase:
- Structural (Phase 1): N concept/observation/discovery
- Symbol + File Coverage (Phase 1.5): N concepts + N hub-files
- Architecture Overview (Phase 2): 1 singleton
- Behavioral (Phase 3): N flows + N binaries
- Navigational (Phase 4): N hub-files + N patterns
- Workflow (Phase 5): 1 build + N test-patterns + N doc-references

Total: <grand total> entries.

Next steps:
- Browse: memory_list on <repo>
- Search: memory_search "<query>"
- Read the start-here entry: memory_read title="Architecture Overview"
```

Then call `memory_lint(repository=<path>)` and surface any warnings (stale, contradictions, broken links).

---

## Invocation Rules

- **Every phase ends with at least one `memory_write` call.** If a phase produces zero useful memories, say so explicitly in the summary — silence is ambiguous.
- **Confidence calibration.** Concept/overview: 0.7-0.8. Observation/flow/hub/pattern/test: 0.6-0.7. Discovery/hotspot: 0.5. Never exceed 0.8 — leave room for "written" (human-authored) entries later.
- **Source field.** Every entry written by this skill uses `source: "inferred"`. Never set `source: "written"` — that's reserved for human/agent explicit capture.
- **Tag hygiene.** Use consistent tags across phases: `architecture`, `overview`, `flow`, `hub`, `pattern`, `build`, `testing`, `docs`, plus per-domain tags drawn from Phase 1 entries.
- **Stop conditions.** Abort with a clear report if: Scout isn't attached, repository isn't indexed, `memory.init` fails, or any phase's Scout call returns an error three times in a row.
- **Do not spawn subagents.** This skill runs in the main session only — memory_write is stateful and subagent context isn't shared back.

---

## Failure Modes

| Symptom | Cause | Remedy |
|---|---|---|
| `memory_infer` returns "bank not initialised" | `scout memory init` skipped | Run it, retry |
| No flows returned | Language not supported by `list_flows`, or repo is header-only | Skip Phase 3 silently |
| No docs | No markdown indexed | Skip Phase 5c silently |
| Budget blown (>100 memories) | Likely writing duplicates | Stop, call `memory_lint`, dedupe before continuing |
| Auto-link warnings: "target not found" | Title mismatch between phases | Re-list Phase 1 entries with `memory_list`, match titles exactly |
