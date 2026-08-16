---
name: jira-graph-2296
description: "GRAPH-2296: install command should prefer remote dependencies over local when available; --use-local-deps flag to override; filter list constrains which plugins are treated as local"
metadata: 
  node_type: memory
  type: project
  originSessionId: 66698db8-66d9-4b75-8a10-bedb109334f3
---

GRAPH-2296: `graph install` should prefer remote (registry) versions of dependencies over local source versions when available. A `--use-local-deps` flag restores the old local-first behavior.

**Why:** The value is that a filter-list install mirrors what the submit pipeline will see — only the filtered plugins are treated as local; all other deps resolve from the registry.

**How to apply:** When implementing, flip the lookup order in `getTransitiveDependencies` in `project-plugins.ts` (try remote first, fallback to local). Thread `--use-local-deps` through `cli.ts` → `installCommand()` → resolution logic. Cover the behavior change and flag in integration tests.

Key files: `src/commands/install.ts`, `src/plugins/project-plugins.ts`, `src/bin/cli.ts`
Epic: GRAPH-1271 | Points: 3.1
