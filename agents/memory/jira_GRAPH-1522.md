---
name: jira_GRAPH-1522
description: GRAPH-1522: dedicated path-filtered CI workflow for graph-sdk build/unit tests; skips full monorepo rebuild, PR preview deploy, and smoke tests for SDK-only PRs
type: project
originSessionId: d5c3d686-0565-4f9d-9cd6-19b2d1ebfb13
---
# GRAPH-1522 — Create dedicated path-filtered CI workflow for graph-sdk build and unit tests

Epic: GRAPH-1263 (Graph SDK Integration Testing)
Points: 3.1

## Origin

Created during review of GRAPH-1268 (graph-sdk-integration.yml). Observed that build.yml runs the full monorepo rebuild, deploys a PR preview environment to AWS, and runs Playwright smoke tests on every PR — none of which are needed for SDK-only changes.

## Key decisions

- Use native GitHub Actions `on.push.paths` / `on.pull_request.paths` — no third-party action needed (same pattern as graph-sdk-integration.yml)
- The `graph-sdk-unit` job in graph-sdk-integration.yml is redundant with what build.yml already does; the new workflow should consolidate this
- Main architectural question: skip build.yml steps via step-level `if:` conditions (simpler) vs. restructuring build.yml into separate jobs (cleaner but more disruptive)

**How to apply:** If scope expands to full build.yml job restructuring, estimate grows to 5.

## Scope

Files expected to change:
- `.github/workflows/graph-sdk-build.yml` — new file
- `.github/workflows/graph-sdk-integration.yml` — remove/replace graph-sdk-unit job
- `.github/workflows/build.yml` — add changes detection + conditional skipping of PR preview deploy and smoke tests for SDK-only PRs

After merge: branch protection required checks need updating (admin step).
