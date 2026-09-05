---
name: storypoint
description: Use when user invokes /storypoint or asks to estimate, size, or point a Jira story. Infers issue key from branch name if not specified.
user-invocable: true
---

# Story Point Estimation

## Purpose
Estimate story points for a Jira issue using Fibonacci scale, then update the issue in Jira after confirmation. Estimates are stored with a `.1` suffix (e.g. `5.1`) to signal they are AI-estimated but not yet voted on by the team.

## Invocation
- `/storypoint` — infer issue key from current branch name (e.g. `paterson/GRAPH-1170/feat/...` → GRAPH-1170)
- `/storypoint GRAPH-123` — point the specified issue

## Fibonacci Scale

| Points | Signal |
|--------|--------|
| 1 | Trivial — config tweak, single-line fix, zero unknowns |
| 2 | Simple — clear scope, 1–2 files, minimal risk |
| 3 | Small-medium — well-understood pattern, light investigation |
| 5 | Medium — multiple components, some unknowns, moderate test effort |
| 8 | Large — complex, significant unknowns, cross-cutting, or refactor |
| 13 | Very large — major feature, many unknowns; **consider splitting** |
| 21 | Too large — **must be broken down before pointing** |

## Pre-estimation research (required)

Before scoring any factor, investigate the codebase to answer the questions a good engineer would ask before starting the work. Do not leave things as unknowns that can be resolved by reading the code.

Minimum research for every story:

- **Who are the consumers of the changed API or interface?** Grep for call sites, imports, and type references. Count affected files and packages — this directly determines technical breadth and risk.
- **What are the downstream effects?** Trace the data flow: what reads the output of the changed code, what tests exercise it, and what runtime behaviour depends on it?
- **Is the approach already established?** Check if a similar pattern exists in the codebase (another rule, another command, another validation). A prototyped or repeated pattern drives unknowns to zero.
- **Are there external dependencies?** Identify any published packages, external services, or other teams whose types or APIs the change must respect.

Rate "Unknowns" as **none** unless investigation genuinely cannot resolve the question before implementation begins. Vague AC is a scope-clarity problem, not an unknowns problem.

## Complexity Factors

Assess each factor **after** completing the pre-estimation research above:

1. **Scope clarity** — how well-defined are the acceptance criteria? Vague AC adds points.
2. **Technical breadth** — how many packages, files, or systems are involved? (Count from research, not guesses.)
3. **Unknowns / investigation** — research required, new technology, unclear approach? Rate none if research resolved it.
4. **Dependencies** — external teams, APIs, data migrations, or third-party integrations?
5. **Risk** — could this break existing behavior or require rollback planning? (Informed by consumer count from research.)
6. **Testing effort** — unit only, or integration and e2e tests needed?

## Calibration

Read the maintained calibration page `notes/storypoint-calibration` from the configured private GBrain using `get_page`. If it has moved, search for `storypoint_calibration` and resolve the maintained page; `sources/claude-memory/storypoint_calibration` is historical evidence. Use GBrain MCP tools when available; for CLI fallback, supply `export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"` and consult the installed command's help.

Scan the log for:
- **Directional bias**: consistent under/over-estimation across entries
- **Factor patterns**: which complexity factors are most often wrong
- **Component patterns**: corrections clustered around a package or area (e.g. SDK, e2e)

If patterns are found, apply adjustments and call them out explicitly in the estimate output under a "Calibration adjustments" line. If a successful lookup finds no entries, skip calibration silently. If retrieval fails, say calibration was unavailable; do not treat that as an empty log.

After the user provides a correction (any change to the AI estimate before writing to Jira), update the GBrain calibration table. Read the page using `get_page` with `include_content: true`, preserve the full canonical content, and write it back with `put_page` at the same slug. Include dated provenance for the user's correction, avoid repeating an identical entry, and verify the saved row with a read-back. If the write fails, report that calibration was not saved; do not repeat a successful Jira update when retrying the brain write.

Never append calibration data to `~/agents/memory`, the public configuration repository, or Claude auto-memory. Keep the existing table columns:
```
| <date> | <issue-key> | <ai-estimate>.1 | <final>.1 | <delta> | <factor(s)> | <reason> |
```

## Workflow

1. **Resolve issue key**: Parse from invocation args, or infer from `git branch --show-current` (e.g. `paterson/GRAPH-1170/...` → GRAPH-1170). If neither yields a key, ask the user.

2. **Read calibration log**: Load the maintained GBrain calibration page and check for patterns (see Calibration section above).

3. **Fetch the issue** with the jira CLI per `~/agents/skills/jira-access/SKILL.md` — e.g. `jira issue view GRAPH-XXX --raw`. Extract `fields.summary`, `fields.description`, and `fields.customfield_10003` (story points) from the JSON.

4. **Analyze** the story against all six complexity factors. Weight each factor relative to the others — a story with vague AC and broad technical scope is more than additive.

5. **Present estimate** in this format:
   ```
   Estimate: **X.1 points**

   Primary driver: [1–2 sentence explanation of what dominates the estimate]

   Complexity breakdown:
   - Scope clarity: [clear / some gaps / vague]
   - Technical breadth: [narrow / moderate / broad]
   - Unknowns: [none / some / significant]
   - Dependencies: [none / internal / external]
   - Risk: [low / medium / high]
   - Testing effort: [unit / integration / e2e]

   Flags: [anything that could change this estimate — assumptions, open questions]
   ```

6. **Handle corrections**: If the user disagrees and provides a different value with a reason, record it before proceeding:
   - Save the correction in the GBrain calibration page, following the Calibration section above
   - Use the user's corrected value as the final estimate

7. **Confirm with user**: Ask "Update GRAPH-XXX to X.1 points?" before writing to Jira.

8. **Update Jira** on confirmation: use the **REST + bearer token** pattern in `~/agents/skills/jira-access/SKILL.md` for `customfield_10003`. Do **not** use Corp Jira MCP for story points — it silently fails for this field. Story points are stored as `<estimate> + 0.1` (e.g. 5 → `5.1`) to indicate estimated but not yet team-voted.

   A `204` response from `curl` means success.

9. **Add a comment** with the jira CLI (`jira issue comment add`, per `~/agents/skills/jira-access/SKILL.md`) using this structure:

   ```
   h3. Story Point Estimate: *X.1 points*

   *Primary driver:* [1–2 sentence explanation of what dominates the estimate]

   *Complexity breakdown:*
   - Scope clarity: [clear / some gaps / vague]
   - Technical breadth: [narrow / moderate / broad]
   - Unknowns: [none / some / significant]
   - Dependencies: [none / internal / external]
   - Risk: [low / medium / high]
   - Testing effort: [unit / integration / e2e]

   *Flags:* [anything that could change this estimate — assumptions, open questions]
   ```

10. **Print the team review line** for posting to Slack/team channels:

    ```
    Story: <summary> Points: <whole number> <size label>
    ```

    Size labels (Fibonacci → label):
    | Points | Label |
    |--------|-------|
    | 1 | XXSmall |
    | 2 | XSmall |
    | 3 | Small |
    | 5 | Medium |
    | 8 | Large (max per sprint) |
    | 13+ | (prompt to split before pointing) |

    Use the issue type as the label prefix — `Story:` for Stories, `Bug:` for Bugs.

    Example: `Story: Add shell completion support Points: 3 Small https://jira.corp.adobe.com/browse/GRAPH-1113`
    Example: `Bug: IMS login port selection always picks last port Points: 1 XXSmall https://jira.corp.adobe.com/browse/GRAPH-1173`

11. **Confirm** the update to the user with the issue key and final point value.

## Common Mistakes

- **Anchoring on effort alone** — points measure complexity + risk + unknowns, not just hours.
- **Ignoring vague AC** — if acceptance criteria are unclear, the scope can expand; add points.
- **Underweighting cross-cutting changes** — touching multiple packages multiplies testing and risk.
- **Pointing stories that need splitting** — if an estimate lands at 13+, prompt the user to split before proceeding.
- **Skipping the flags section** — surface assumptions that could invalidate the estimate.
- **Leaving resolvable questions as unknowns** — "unknown" means the answer cannot be found before implementation starts, not that you haven't looked yet. If a grep, a file read, or tracing a call chain would answer it, do that first. A good engineer knows who consumes the API they are changing before they start.
