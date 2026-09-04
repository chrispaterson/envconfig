---
name: jira-graph-4113
description: GRAPH-4113 — rename @adobe/graph-cli package to @graph/cli for monorepo consistency
metadata: 
  node_type: memory
  type: project
  originSessionId: eaa0c0f5-1980-45c2-a5bb-29aaab55ee73
  modified: 2026-09-04T23:06:03.738Z
---

GRAPH-4113: rename the CLI package from `@adobe/graph-cli` to `@graph/cli` so its scope matches the rest of the monorepo's `@graph/*` packages. The `@adobe/graph-cli` name was chosen when public-npm distribution was the plan; that path was dropped (see [[jira_GRAPH-2737_npm_vs_dc_distribution]]), so the differing scope no longer has a reason to exist.

Story, Epic GRAPH-2601 (Enterprise Ready SDK), component SDK, Sprint 28, assignee paterson. Created 2026-09-04.

Scope: rename in package.json + all internal references (imports, rush.json, dependency declarations, bin entries, workspace config, docs, distribution tooling); build/lint/test must pass; no dangling `@adobe/graph-cli` references. Note "the SDK" package set includes `@adobe/graph-cli` per [[terminology_the_sdk]] — this rename changes that identifier.

IMPLEMENTED — PR #3627 (draft), branch paterson/GRAPH-4113/rename-graph-cli-scope, 2026-09-04. Pure identity rename, no behavior change:
- package.json `name` + rush.json `packageName` → `@graph/cli`; `projectFolder` (packages/graph-cli) and the `graph` bin unchanged.
- graph-cli/src/index.ts: 3 logger root-category strings kept matching the package name.
- Comment/doc refs updated in graph-cli (sdk-license-banner.ts, tsdown.config.ts), graph-plugin-sdk (ts-config-utils.ts, docs/install-flow.md), graph-sdk-common (cli-logging.ts). NOTE: docs/graph-cli-sdk-split-architecture.md (5 refs) was reverted out of this PR at user request — a separate open PR revises that doc; those 5 @adobe/graph-cli refs remain until that PR lands.
- Moved 10 pending rush change files common/changes/@adobe/graph-cli/ → common/changes/@graph/cli/ + updated their packageName; added a new change entry (type patch) for the rename.
- Left `KEYCHAIN_SERVICE = "adobe-graph-cli"` (credential-store.ts) UNCHANGED — keychain key, not the npm identifier; renaming would orphan users' stored creds. Bare `graph-cli` folder/CLI references also left (folder unchanged).
- Verified: rush build --to @graph/cli OK; graph-cli lint + 24 tests pass; plugin-sdk 233 + sdk-common 207 tests pass; rush change --verify exit 0; no dangling @adobe/graph-cli refs. core-impact: no graph-plugins-core sub-package references the CLI package → Compatible.
- `git pr` tool's internal OAuth was expired; created the draft via `gh pr create` (open-pr skill path) instead. `git.corp.adobe.com` gh account token also invalid (needs `gh auth refresh -h git.corp.adobe.com`).
