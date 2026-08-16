---
name: reference-graph-cli-sdk-split-architecture
description: Architecture proposal doc for the graph-cli/SDK split lives at docs/graph-cli-sdk-split-architecture.md
metadata: 
  node_type: memory
  type: reference
  originSessionId: 87a8352c-a61f-4ffe-85ce-fdfdc5b5af66
  modified: 2026-07-29T23:00:25.399Z
---

The authoritative architecture proposal for splitting `@graph/sdk` (legacy) into the four current SDK packages lives at `docs/graph-cli-sdk-split-architecture.md` in the `migrate-sdk-subcommands-versioned-bundles` working copy of project-graph.

It covers, for [[terminology_the_sdk]]:
- Motivation: proprietary platform-code protection (IMS-gated bundles) + external/public npm distribution + per-plugin `platformVersion` targeting.
- Package roles: `@adobe/graph-cli` (thin public CLI), `@graph/plugin-sdk` (orchestration, IMS auth, discovery, drives `build`/`install`/`lint`/`format`/`list-plugins`), `@graph/plugin-compiler` (the versioned platform bundle, invoked as a subprocess per plugin via `pluginExec`, never imported), `@graph/sdk-common` (shared base, depends on neither, keeps dep graph acyclic).
- A documented open implementation gap: `plugin-sdk`'s `platform-dependencies.ts` still resolves the per-plugin subprocess by the legacy name `sdk` (`.plugin-dependencies/@graph/sdk/lib/bin/...`) instead of `plugin-compiler` — the bundle-fetching path isn't fully repointed yet.
- A mermaid sequence diagram for `graph install`: CLI → plugin-sdk → IMS login → discover plugins/platformVersions → per-version fetch of plugin-compiler bundle from Graph Services → install into `.plugin-dependencies/@graph/plugin-compiler`.

**How to apply:** Before making claims about how the CLI/SDK split works, or planning work on GRAPH-2736 (migrate SDK subcommands to versioned bundles), read this doc directly rather than relying on memory — it's the design source of truth and may be updated as the migration proceeds.
