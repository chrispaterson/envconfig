---
name: jira-graph-2736-platform-download-auth-gap
description: "graph-cli install's platform-bundle download had no auth at all; fixed with checkCredentials+Bearer header, verified live end-to-end (no infra gap — earlier 'CDN blocker' finding was a wrong-version test error)"
metadata: 
  node_type: memory
  type: project
  originSessionId: d035bcd2-b859-4e62-9a69-f93503015c3d
  modified: 2026-08-05T02:25:27.003Z
---

Tested `@adobe/graph-cli install` against a live PR preview env (https://pr-3306.graph.corp.adobe.com) to verify platform-bundle download auth and unpack behavior, per [[terminology_the_sdk]].

**Finding:** an anonymous `curl` to `${graphUrl}/sdk/<major>.<minor>/platform-closure.json` on the PR env returns a 302 (CloudFront Function) redirecting to the app shell (`/graph/`, 200 `text/html`) — not a clean 401/403. `fetch()` follows redirects by default, so the existing client code in `gatherClosureTarballsFromEndpoint` (packages/graph-plugin-sdk/src/platform-provision.ts) would see `response.ok === true` and then crash on `.json()` parsing HTML. Worse: that function sent **no Authorization header at all** — even a logged-in CLI user's request would still be anonymous and hit the same redirect.

**Fix applied 2026-08-04** (commit not yet made at time of writing; touches `platform-provision.ts`, `auth/ims-login.ts`, `auth/ims-client.ts`, `auth/ims-consts.ts`, and their tests):
- Added `checkCredentials({ store?, logger })` in `auth/ims-login.ts`: a pure, non-interactive check — reads stored `StoredCredentials` and, if present, confirms them against IMS's real `GET/POST <ENV>/ims/validate_token/v1` endpoint (`client_id` + `type=access_token` query params, token as `Authorization: Bearer` header per the Adobe IMS wiki spec, page ID 767754917). Returns the credentials only if IMS reports `valid: true`; returns `undefined` for no-stored-creds, IMS-says-invalid, or a failed validation request (logged as a warning) — every `undefined` case is the caller's cue to fall back to the full `imsLogin`.
- Added `validateAccessToken(accessToken, logger)` in `auth/ims-client.ts` implementing that endpoint call; new `VALIDATE_TOKEN_PATH` const in `ims-consts.ts`.
- `gatherClosureTarballs` in `platform-provision.ts` now does: `const checked = await checkCredentials({ logger }); const { accessToken } = checked ?? (await imsLogin({ logger }));` — so an already-authenticated caller never triggers `imsLogin`'s browser/refresh flow at all, per [[terminology_the_sdk]] user's explicit ask ("I don't want to always login because they may already have logged in").
- `gatherClosureTarballsFromEndpoint` sends `Authorization: Bearer <accessToken>` on both the manifest and tarball fetches, and explicitly checks `response.redirected` to throw a clear "not an authentication problem, credentials were already verified" error instead of an opaque JSON-parse crash on the CDN's redirect-to-HTML.
- Note: the wiki page found first for "check credentials" (`IMS API - check token`, `/ims/check/vN/token`) is a **different, unrelated** endpoint — browser-only SSO/"remember me" cookie-based token creation, not validation of an existing token. Don't confuse the two if revisiting this.

**SUPERSEDED 2026-08-05 — the "CDN gate isn't Bearer-aware, infra blocker" conclusion below was WRONG, caused by testing the wrong platform version. Do not act on it.** ~~CONFIRMED live 2026-08-05... the CDN gate does NOT honor `Authorization: Bearer`... structurally cannot authenticate... needs an infra-side fix...~~ — all of that was based on requesting `/sdk/2.1/platform-closure.json`. `2.1` came from a local `test-plugins` fixture manifest and was never cross-checked against what this PR's CI actually staged.

**Root cause of the whole investigation, and the actual resolution:** the real platform version CI stages for this PR (per the live `build.yml` run's "Stage platform closure tarballs" step, `PLATFORM_VERSION_DIR: 2.17`) is **2.17**, not 2.1. Verified via `gh run view --job=<id> --log` on the PR's latest (green) `build.yml` run:
- "Stage platform closure tarballs" step succeeded, `PLATFORM_VERSION_DIR=2.17`.
- "Upload build output to S3" step succeeded with **no errors**, uploading `graph/sdk/2.17/platform-closure.json` + 7 tarballs to `s3://prj-graph-build-storage/build/<merge-sha>/graph/sdk/2.17/`. Note `github.sha` on a `pull_request`-triggered run is the **merge commit**, not the branch head SHA `gh run list`/`gh pr view` report — they differ (`b1ee26bdf7...` vs `c483e3170...` for this PR).
- "PR Deployment" step (the `aws-deploy` composite action) succeeded, writing the CloudFront KeyValueStore entry `pr-3306 → <that same merge-sha>`.

Re-running the same in-process `checkCredentials` + `fetch` test against the **corrected** URL `https://pr-3306.graph.corp.adobe.com/graph/sdk/2.17/platform-closure.json` (note also the `/graph` prefix, matching `DEFAULT_GRAPH_URL`'s `.../graph` base — the no-prefix `/sdk/...` path was always wrong too) returned **200, `application/json`, `redirected: false`, real manifest body** — using a genuine `Authorization: Bearer <token>` from `checkCredentials`.

**Conclusion: there is no infra/CDN gap at all.** CI upload, CloudFront's PR→SHA routing, S3 bucket policy, and this session's `checkCredentials`/`validateAccessToken`/Bearer-header client fix all work correctly together, verified live end-to-end. No Jira ticket needed for infra/CDN. The only real, lasting deliverable from this whole thread is the `graph-plugin-sdk` code fix (pre-flight `checkCredentials`, `Authorization: Bearer` header, `response.redirected` detection) — which is now empirically confirmed working, not just unit-tested.

**How to apply:** if a similar 403/redirect shows up again on a `/graph/sdk/<major>.<minor>/...` request, check the *actual* staged platform version from that PR's `build.yml` run logs (`PLATFORM_VERSION_DIR` in the "Stage platform closure tarballs" step) before suspecting CDN/auth config — a version mismatch produces a failure that looks identical to an auth/infra problem.
