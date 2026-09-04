---
name: jira-graph-997
description: "GRAPH-997 401-from-graph-services IMS revalidation + reauth-on-401; implemented PR #3585"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4697a260-6506-44c2-a556-19fe1302747d
  modified: 2026-09-01T18:47:01.603Z
---

GRAPH-997 (Story, component SDK): "Handle 401 Unauthorized from graph services with IMS token revalidation and user-friendly error messaging."

**Status:** Implemented 2026-09-01 on branch `paterson/GRAPH-997/handle-401-ims-revalidation`, draft PR https://github.com/Adobe-CreativeCloud/graph/pull/3585. Was NOT fixed by the GRAPH-2736 SDK-split refactor — that added the `AuthProvider.getValidAccessToken` hook but left it unused in the request path.

**Root cause:** `PluginService._requestWithStatus` in `packages/graph-plugin-services-client/src/plugin-service.ts` threw a generic `API request failed` for any non-OK status — no 401 branch, no IMS revalidation, no retry. SDK passed a static `StoredCredentials` snapshot (no `getValidAccessToken`).

**Fix (3 parts, layering preserved):**
1. services-client `_requestWithStatus`: on 401, call `this._auth.getValidAccessToken()`, retry once with refreshed token via `new Headers(...)`; clearer 401 error when unrecoverable. Non-401 + providers without the hook unchanged.
2. new `packages/graph-plugin-sdk/src/auth/ims-auth-provider.ts` `ImsAuthProvider` implements `getValidAccessToken`: `validateAccessToken` (IMS validate_token) then `imsLogin({ reauth: true })`.
3. `imsLogin` gains `reauth?` option — bypasses the `expiresAt` reuse shortcut to force refresh-token renewal (browser fallback). Wired into `getPluginService`.

**Tests:** services-client 68/68, sdk 233/233. core-impact on ml-nodes = Compatible (auth runs at submit time, not the plugin compile path). Change file only required for `@graph/graph-plugin-services-client` (`@graph/plugin-sdk` is non-published).

Gotchas hit: `git b` and `git pr` aliases invoke a nested `claude` CLI that hangs — create worktree/PR manually or via open-pr skill. rush `install-run/.bin/rushx` ENOENT on @graph/cache build → bootstrap with `node common/scripts/install-run-rush.js --help`. origin/main advanced twice mid-session; rebased. Epic context: [[jira_GRAPH-2736_compiler_in_bundle_shipped]].
