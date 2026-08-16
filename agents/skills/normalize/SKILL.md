---
name: normalize
description: Find and unify inconsistent structural patterns in the codebase. Post-change mode (default) scans the current branch diff; audit mode scans a package or the whole repo.
user-invocable: true
argument-hint: "[--audit [scope|all]]"
---

# Pattern Normalization Skill

Normalize inconsistent structural patterns. Arguments: $ARGUMENTS

## Mode Detection

Parse $ARGUMENTS to determine mode and scope:

| Invocation | Mode | Scope |
|---|---|---|
| `/normalize` | Post-change | Files changed in current branch (`git diff main...HEAD`) |
| `/normalize --audit` | Audit | Current directory |
| `/normalize --audit src/` | Audit | Specified path |
| `/normalize --audit all` | Audit | Entire repository root |

---

## Workflow

### 1. SCAN — Detect Pattern Groups

**Post-change mode**: Run `git diff main...HEAD --name-only` to get the changed files. Read those files to identify patterns, then search the full repo for all instances of those same patterns so any fix will be complete.

**Audit mode**: Use the Explore agent to scan all files within the scope path.

In both modes, look for structural inconsistencies across these categories — but do not limit to them:

- **Logging** — multiple logging mechanisms used for the same purpose (e.g. `console.log/warn/error` mixed with a structured logger, or multiple loggers used interchangeably)
- **Error handling** — `try/catch`, `.catch()`, `Result`/`Either` types, unhandled rejections used inconsistently for the same kind of operation
- **Command invocation** — different patterns for spawning/executing shell commands and handling their output or errors
- **Async patterns** — `async/await`, raw `.then()` chains, and callbacks mixed for the same category of operation
- **API call wrapping** — fetch/HTTP calls with inconsistent error checking, retry logic, or response handling
- **Type definition style** — `interface` vs `type` vs inline for structurally similar shapes

**Minimum bar for flagging a group**: at least 2 distinct variants AND at least 3 total instances. Single-use outliers are not worth normalizing.

**False positives**: If two patterns look similar but serve genuinely different purposes (e.g. debug logging vs. structured event logging), treat them as separate patterns — not inconsistencies.

For each group, record:
- All distinct variants with representative code snippets and source locations
- File count per variant
- Whether the pattern spans multiple packages/modules (flag for potential extraction)

---

### 2. REPORT — Present Findings

Present one section per pattern group:

```
## [Category: Pattern Name]

Found N variants across X files:

**Variant A** (12 files — most common)
// src/foo.ts:42
<code snippet>

**Variant B** (5 files)
// src/bar.ts:17
<code snippet>

**Variant C** (2 files)
<code snippet>
```

**Audit mode only**: After presenting all groups in the conversation, write the full report to a markdown file named `normalize-audit.md` in the current working directory. The file should contain all groups with code snippets, file locations, impact notes, and a priority summary table. Announce the file path after writing it.

After all groups, summarize the count and ask: *"Which of these would you like to normalize?"*

---

### 3. APPROVE — Canonical Selection

Handle groups one at a time. For each group the user selects, present:

```
Pattern: [Category Name]

Which form should be canonical?

  1. Variant A  (most common — 12 files)
  2. Variant B  (5 files)
  3. Variant C  (2 files)
  4. Write my own canonical form
  5. Extract to a shared utility     [only shown when pattern spans 3+ packages/modules]
  6. Skip this pattern
```

**Option 4 — Write my own**: Ask the user to provide the canonical snippet or utility signature. Confirm the final form before proceeding.

**Option 5 — Extract to shared utility**: Propose:
1. The utility function name, signature, and where it belongs (e.g. a shared module, a new utility file)
2. A brief implementation sketch
3. Which files would import it and how their call sites would change

Confirm with the user before creating anything.

After all selections, display a full plan (every group, every action) and ask for final confirmation before making any changes.

---

### 4. APPLY — Normalize Instances

For each approved group, in order:

1. **If extracting a shared utility**: create the utility file first, then update all call sites.
2. **Replace** all non-canonical instances with the canonical form.
3. **Update imports** as needed (add, remove, or rewrite import paths).
4. **Do not** change unrelated code in touched files.

Announce each file as it is modified.

---

### 5. VERIFY

Detect the project's build tooling from `package.json` scripts, config files, or CLAUDE.md. For every package or module touched, run the appropriate commands in sequence:

- **Build** — compile the project (e.g. `npm run build`, `rushx build`, `tsc`)
- **Lint** — check for lint violations (e.g. `npm run lint`, `rushx lint`)
- **Test** — run the test suite (e.g. `npm test`, `rushx test`)

Fix any failures introduced by the normalization before finishing. Do not skip verification even if changes appear trivial.

---

## Guidelines

- **Scope discipline (post-change mode)**: Detect patterns from the diff, but find and fix *all* instances across the repo so the normalization is complete, not partial.
- **Cross-package/module extraction**: When the same pattern appears in 3+ packages or modules, strongly prefer extraction to a shared location. Present the coupling-vs-duplication tradeoff and let the user decide.
- **Preserve semantics**: Normalization must not change behavior. If the canonical replacement would alter semantics in any instance, flag it explicitly and ask before applying.
- **Canonical selection bias**: Prefer the most common variant as the default suggestion. Surface the most recently introduced variant as an alternative when it appears to be a deliberate improvement over the older form.
