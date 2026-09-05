---
name: getcontext
description: Load full context for the current work session — fetches the Jira ticket, PR diff, and memory notes so the agent is ready to assist without re-explaining. Use when starting a session on an in-progress story, or any time the user invokes /getcontext.
user-invocable: true
argument-hint: "[GRAPH-XXX]"
---

# Get Context

## Purpose

Orient the agent in the current work session by loading:
1. The Jira ticket (acceptance criteria, status, description)
2. The GitHub PR diff (what has been done, what remains)
3. Durable decisions and context for the issue from GBrain

After running this skill, the agent should be ready to answer questions, continue implementation, or review decisions — without the user needing to re-explain the work.

## Tooling

- **Jira:** `~/agents/skills/jira-access/SKILL.md` (use `jira issue view … --raw`; do not use Corp Jira MCP by default).
- **GitHub PRs:** `~/agents/skills/github-access/SKILL.md`.

## Invocation

- `/getcontext` — infer issue key from branch name
- `/getcontext GRAPH-123` — load context for a specific issue

---

## Workflow

### Step 1 — Resolve Issue Key

Parse the GRAPH-XXX key from `$ARGUMENTS`. If not provided, infer from the current branch:

```bash
git branch --show-current
```

Pattern: `<username>/GRAPH-XXX/<slug>` → extract `GRAPH-XXX`.

If no key can be found, ask the user.

### Step 2 — Load GBrain Notes

Search the configured private GBrain for the exact issue key using `search`, then read relevant pages with `get_page`. Check the legacy `jira_<KEY>` token when necessary. Prefer the maintained page for that exact issue; imported sources and transcripts provide supporting context. Cite the pages used and distinguish dated decisions from current ticket status.

Use MCP tools when available. For CLI fallback, first supply `export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"`, then use the equivalent installed `gbrain` commands, consulting their help as needed.


If GBrain is unavailable, say that retrieval failed; do not report "no memory". Continue with available Jira and Git context. An empty successful lookup simply means no relevant brain notes were found.

### Step 3 — Fetch the Jira Ticket

Per `~/agents/skills/jira-access/SKILL.md`:

```bash
jira issue view GRAPH-XXX --raw
```

Extract and display:
- **Summary** — one-line title
- **Status** — current workflow state (e.g. In Development, In Review)
- **Acceptance Criteria** — pull from the description (usually under "Acceptance Criteria" heading)
- **Story Points** — `customfield_10003` value if set

### Step 4 — Fetch the PR Diff

Per `~/agents/skills/github-access/SKILL.md` — use `gh pr view` and `gh pr diff` for the current branch. If no PR exists yet, use `git diff origin/main...HEAD` (three dots) per the `github-access` skill.

Analyze the diff to determine:
- **What has been implemented** — summarize completed work by file/area
- **What appears incomplete or missing** relative to the acceptance criteria
- **Any obvious issues** — failing patterns, TODO comments, incomplete tests

If no PR exists yet, note that and check for local commits ahead of main:
```bash
git log origin/main..HEAD --oneline
```

### Step 5 — Present Context Summary

Output a structured summary in this format:

```
## Context: GRAPH-XXX — <Summary>

**Status:** <Jira status>
**PR:** <PR URL or "None yet">

### Acceptance Criteria
<Extracted AC bullets from Jira description>

### What's Done (from PR diff)
<Bulleted summary of completed implementation areas>

### What Remains
<Bulleted gaps between AC and current diff — be specific>

### Memory Notes
<Relevant GBrain decisions with page citations; label any retrieval failure>

### Open Questions / Flags
<Any risks, TODOs, or decisions noted in the diff or memory>
```

End with a single line:

```
Ready — ask me anything about GRAPH-XXX or continue the implementation.
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| No branch / no GRAPH key in branch | Ask the user for the issue key |
| Jira issue not found | Report and stop; ask user to verify the key |
| No open PR, no local commits ahead | Note "No PR and no commits yet — nothing implemented" |
| `gh` not authenticated | Warn; skip PR diff step and continue with Jira context |
| `jira` fails (auth or CLI) | Report; stop or continue with PR + memory only per user preference |
| No relevant brain notes | Show "None" |
| GBrain lookup fails | State retrieval failed; continue with available context |
