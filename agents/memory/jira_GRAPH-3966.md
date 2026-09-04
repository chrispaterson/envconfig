---
name: GRAPH-3966 — Investigate ESLint ~9.39.0 requirement under the versioned platform closure model
description: Ticket memory for GRAPH-3966: decisions, context, and origin notes
type: project
---

# GRAPH-3966 — Investigate ESLint ~9.39.0 requirement under the versioned platform closure model

**Type:** Story
**Created:** 2026-08-27
**Epic:** GRAPH-2601 — Enterprise Ready SDK

## Origin
Filed while working the GRAPH-2736 branch (migrate SDK sub-commands into versioned platform bundles). Noticed a tension: the SDK `lint`/pre-build path hard-pins the ESLint engine via `REQUIRED_ESLINT_SEMVER = "~9.39.0"` in [get-eslint-override-config-file.ts](packages/graph-sdk/src/utils/get-eslint-override-config-file.ts) and throws if the project's own config doesn't declare `eslint` at that range — but under the new closure model, `buildPlatformPackageJson` in [platform-provision.ts](packages/graph-plugin-sdk/src/platform-provision.ts) intentionally leaves `eslint` undeclared so npm resolves it from the registry, while the config and `@graph/eslint-plugin` it runs are versioned inside the bundle. The engine version pin does not travel with the bundle it is paired to. Relates [[jira_GRAPH-2736_build_parity_bugs]].

## Decisions

### 2026-08-27 — Scope: investigation only, recommendation required
Spike to answer where ESLint resolves from at lint time under the closure model, whether the required version should be sourced from the versioned bundle instead of a hardcoded SDK constant, whether the hard-throw can reject valid projects targeting older platform versions, and whether `eslint` should become a declared closure dependency. Created in backlog (no sprint) under GRAPH-2601.
