---
name: jira-graph-2467
description: "GRAPH-2467: bundle platform runtime deps as tarballs so graph-sdk install can distribute them without npm/pnpm"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9289eb2e-8c9f-4682-b536-11a1a28c9a90
---

GRAPH-2467: Bundle SDK Runtime Deps — distribute platform deps (lit, SWC, @graph/platform-exports, etc.) via tarballs downloadable by the SDK install command, eliminating npm/pnpm requirement for plugin authors.

**Why:** Plugin authors must currently run npm/pnpm to install platform deps. Goal is SDK-only workflow (tarball download + unpack).

**5-phase plan** (plan file: resilient-hatching-glacier.md):
1. `packages/graph-app/scripts/pack-platform-bundle.ts` — post-build script that reads platform-modules.json, copies npm package contents from node_modules, packs as `platform-bundle-{major}.{minor}-{hash}.tar.gz`
2. CI: upload tarball to `s3://prj-graph-build-storage/platform-bundles/` in release-build.yml
3. `packages/graph-plugin-services-client` — add `getPlatformBundle(platformVersion)` method; `GRAPH_SDK_PLATFORM_BUNDLE_URL` env var override to unblock before backend ships
4. `packages/graph-sdk/src/commands/install.ts` — download+unpack bundle into `.plugin-dependencies/__platform__/{version}/`, symlink packages into plugin `.plugin-dependencies/`, add tsconfig paths
5. Decouple SDK bundle from shared @graph/* packages (mark external in tsdown config)

**How to apply:** Phase 1 is the foundation; phases are sequential dependencies. Backend endpoint (GET /platform-bundles) is external-team dependency — env var override unblocks SDK work.

**Key reuse:**
- Tarball pack: `packTar()` + `createGzip()` + `pipeline()` from build.ts
- Tarball unpack: `fetch → arrayBuffer → Buffer → pipeline(createGunzip(), unpackTar())` from project-plugins.ts lines ~300-320
- platform-modules.json: `packages/platform-exports/platform-modules.json` (version + modules map)
- import-map.json emitted by vite to `packages/graph-app/dist/import-map.json`
