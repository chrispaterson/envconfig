---
name: jira_GRAPH-4045
description: GRAPH-4045: port multi-dev-server (ports + cross-package live peers, PR #3510/GRAPH-3880) from @graph/sdk to @graph/plugin-sdk
metadata:
  type: project
  modified: 2026-09-02T01:13:09.191Z
---

GRAPH-4045 Story — port the multi-dev-server feature that landed in the legacy `@graph/sdk` (PR #3510, GRAPH-3880) onto the new split `@graph/plugin-sdk` dev server. Assigned paterson, Sprint 28, Epic GRAPH-2601. Created 2026-09-01.

**IMPLEMENTED — draft PR [#3599](https://github.com/Adobe-CreativeCloud/graph/pull/3599)** (branch `paterson/GRAPH-4045/port-multi-dev-server`, 2026-09-01). All build/lint/test green in graph-plugin-sdk. What landed, per file:
- `const/dev-server.ts`: `DEV_SERVER_PORT_RANGE_START/END` = 3001/3010.
- `server/dev-server-discovery.ts` (new) + test: `scanDevServerRange` + `selectDevServerPort` (same-package collision throw). Near-verbatim port; import `PackageName` from `../package-name.js`.
- `server/dev-server-registry.ts` (new) + test: `~/.graph/dev-servers` registry, `findLocalPeer`, interface-hash gate. Renamed const `GRAPH_SDK_VERSION`→`GRAPH_PLUGIN_SDK_VERSION`; DEV_SERVER_PROTOCOL_VERSION=1 + dir kept identical for interop.
- `project-plugins.ts`: added `sourcePackage?` to `PublishedPlugin`; injected `findLocalPeer` short-circuit into `resolveExternal` before the catalog fetch (returns PublishedPlugin+sourcePackage; assertResolvedManifest on peer manifest; falls back on read failure).
- `server/dev-server.ts`: `packageName?` on DevServerOptions + `/health`.
- `commands/dev.ts`: full rewrite to bind-before-build scan/bind loop (race retry + explicit `--port` collision error), publishRegistry, registry watcher + reconcile, before-build fingerprint snapshot. Kept useLocal/reporter/forEachPlugin.
- `commands/install.ts`: `readPreviousSymlinkTargets` before purge + live-peer→published fallback warning (`plugin.published && !plugin.sourcePackage && previousWasLivePeer`).
- test helper: added `buildPublishedPlugin` to `test/project-plugin-builder.ts` (one justified `no-unsafe-type-assertion` disable — source manifest stands in for full catalog manifest).

DECISION (platform-minor, was open): registry stays platformMajor-only for interop → live-peer match is MAJOR-ONLY ("use whatever is live"), documented at the findLocalPeer match site. Relates [[jira_GRAPH-2736_platform_minor_versioning]].
Core-impact: NONE — no graph-plugins-core pkg depends on @graph/plugin-sdk (ml-nodes/core-nodes build via legacy @graph/sdk CLI, untouched).
Base branch note: worktree based on 8cad1a233; origin/main advanced to 43d16fada (unrelated GRAPH-3588 capsule work) — base is still an ancestor so PR diff is clean.

Full porting handoff attached to the ticket (`dev-server-parity-handoff.md`). Key points:
- It's a re-implementation, not a file copy: the ProjectPlugin type model was refactored from graph-sdk's flat `external?: boolean` into graph-plugin-sdk's `DiscoveredPlugin(published:false) | PublishedPlugin(published:true)` union. Main task = translate `external` → `published`; add `sourcePackage?` to graph-plugin-sdk's `PublishedPlugin` (NOT the shared graph-sdk-common base).
- Peer-resolution seam = `resolveExternal` in packages/graph-plugin-sdk/src/project-plugins.ts (~line 161), analog of #3510's getTransitiveDependencies hook.
- New files to port: server/dev-server-discovery.ts, server/dev-server-registry.ts, utils/package-name.ts.
- Already aligned: `notifyRebuild(plugins?)` + `refreshPlugins()` exist; platform-MAJOR matching agrees with post-GRAPH-3593 invariant. Keep registry layout `~/.graph/dev-servers/<pid>.json` + DEV_SERVER_PROTOCOL_VERSION identical so old+new dev servers interoperate during migration.
- Highest runtime risk: distDir/interfaceHash correctness (verify new build emits `.d.ts` at derived distDir). Open decision: platform-MINOR matching (registry carries only platformMajor; our provisioning is major.minor — see [[jira_GRAPH-2736_platform_minor_versioning]]).

Relates: part of the GRAPH-2736 SDK subcommand migration; sibling closeout stories [[jira_GRAPH-2736_branch_closeout_stories]]. Epic GRAPH-2601.
