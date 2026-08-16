---
name: jira-graph-3461-ci-full-build-fallback
description: "GRAPH-3461 CI decision — detect-build-plugins.sh now falls back to a full build whenever no plugin changes are detected, even for non-plugin diffs"
metadata: 
  node_type: memory
  type: project
  originSessionId: 31974364-e1a6-4799-92a5-f278a250dfb5
  modified: 2026-08-06T23:40:00.240Z
---

`scripts/ci/detect-build-plugins.sh` was changed so that whenever the plugin-diff (`detect-changed-plugins.sh`) finds zero changed plugins for a package (`ml-nodes`/`core-nodes`), it now sets `full_build=true` (and forces `count=1`) instead of leaving `count=0`. Previously `count=0` caused the entire build job (setup-node, IMS auth, install, build) to be skipped via `if: steps.plugins.outputs.count != '0'` gates in `.github/workflows/build.yml`.

**Why:** User (Chris) explicitly confirmed this tradeoff is intentional: "If you're making changes to anything other than plugins, all the plugins should be built to make sure nothing breaks." Reliability > CI cost here.

**Consequence:** `count` can no longer be `0` for either package — the `if: steps.plugins.outputs.count != '0'` gates in `build.yml` are now effectively always-true (dead conditionals, left in place for documentation). Every PR now runs a full IMS-auth + install + full build of both `ml-nodes` and `core-nodes`, even for workflow-only, docs-only, or unrelated SDK changes. This reverses the CI-cost optimization that [[jira_GRAPH-3362]]-adjacent path-filtered CI work (GRAPH-1522) was built for — full monorepo rebuilds are no longer skipped for non-plugin PRs.

**How to apply:** Don't flag "CI now runs full builds on every PR" as a regression or re-propose narrowing the fallback (e.g. scoping it to only `.github/workflows/`/`scripts/ci/` diffs) — this was already raised and explicitly rejected in favor of reliability. If CI cost becomes a problem later, that's a new decision point, not a bug in this change.
