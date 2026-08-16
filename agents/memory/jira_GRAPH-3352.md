---
name: graph-3352-unify-duplicated-logic-across-github-actions-build-release-workflows
description: "Ticket memory for GRAPH-3352: CI/CD workflow deduplication story, epic link rationale, and implementation plan location"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4a81b341-1a95-4d49-997a-285b6368246c
  modified: 2026-07-29T23:30:52.976Z
---

# GRAPH-3352 — Unify duplicated logic across GitHub Actions build/release workflows

**Type:** Story
**Created:** 2026-07-29
**Epic:** GRAPH-2601 (Enterprise Ready SDK)

## Origin
Filed after an on-request audit of `.github/workflows/` and `.github/actions/` (build.yml, release-build.yml, release-deploy.yml, update-dev.yml, deploy.yml, publish.yml) found several copy/pasted blocks: the `build` job duplicated between build.yml/release-build.yml, Playwright summary-extraction logic duplicated in both files' smoke-test jobs, smoke-test job scaffolding duplicated wholesale, 8 dead `Checkout` steps preceding `s3-cf-deploy` calls (that composite action never reads repo files), and the release-notes "Deploy Status" table generation duplicated 4x within release-deploy.yml alone.

## Decisions

### 2026-07-29 — Epic Link chosen as GRAPH-2601, not GRAPH-26 or a new epic
No open epic is a clean fit for GitHub Actions tech-debt; user chose to link under GRAPH-2601 ("Enterprise Ready SDK") rather than GRAPH-26 (Release Readiness) or spinning up a new epic. Added to active sprint (Graph Sprint 26, 7/27–8/07) per user request.

### 2026-07-29 — Full 6-phase implementation plan written into the ticket description
The plan (remove dead checkouts → extract Playwright-summary script → unify the build job → extract smoke-test composite action → unify release-notes table generation → optional git-config/regex cleanup) lives entirely in the GRAPH-3352 description's "Additional Notes" section (not a separate doc), so a fresh worktree/agent session can `jira issue view GRAPH-3352` and follow it directly.
