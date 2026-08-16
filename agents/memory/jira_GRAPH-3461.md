---
name: graph-3461-ims-public-client-change-broke-non-interactive-password-grant-token-acquisition-graph-plugins-core-ci-graph-integration-tests
description: "Ticket memory for GRAPH-3461: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 170d4b74-e965-4f93-9d2d-8bc04e0de02d
  modified: 2026-08-06T23:16:23.537Z
---

# GRAPH-3461 — IMS public client change broke non-interactive password-grant token acquisition (graph-plugins-core CI + graph integration tests)

**Type:** Bug
**Created:** 2026-08-05
**Epic:** GRAPH-2601

## Origin
Created as a follow-on from GRAPH-3457 (the `@graph/sdk` dependency-bump ticket). Landing that PR revealed IMS moved the `project-graph-sdk-v1` OAuth client to a "public" grant type, breaking password-grant CI token acquisition in both `graph-plugins-core` (`scripts/ci/sdk-ims-token.sh`) and `graph` (`integration/setup.ts` + `docs/integration-testing.md`).

## Decisions

### 2026-08-06 — SUPERSEDES the S2S plan below: actual fix is password grant against a different confidential client, no S2S needed
Landed fix (commit `5da97e14`, "switch to different client id") keeps `grant_type=password` in `scripts/ci/sdk-ims-token.sh` but swaps `client_id` from the now-public `project-graph-sdk-v1` to `firefly-graph-sdk-cicd-v1` (a confidential client) and adds `client_secret=${GRAPH_SDK_TEST_CLIENT_SECRET}` to the request. Password grant is sufficient for CI — a Server-to-Server (`client_credentials`) credential is NOT required. The `continue-on-error` stopgap in `.github/workflows/build.yml` was reverted (commit `0f3c7e90`), i.e. the real fix is confirmed working, not just prepped. The entire "Fix direction: dedicated S2S credential" thread below (client_credentials swap in `integration/setup.ts`, the developer-console stage-access blocker, the org-310936 approval chase) was the abandoned path — kept here for history only.

### 2026-08-05 — Confirmed dropping client_secret alone doesn't fix it
Tested live: removing `client_secret` from the password-grant curl call changed the error from `invalid_client: unexpected client_secret parameter` to `unsupported_grant_type` — password grant itself is rejected for public clients, not just the secret param.

### 2026-08-05 — Fix direction: dedicated Server-to-Server credential, not a refresh token
Decided against reusing a refresh token off the human-login public client (`project-graph-sdk-v1`); instead provision a separate Adobe IMS OAuth Server-to-Server (`client_credentials`) credential dedicated to CI/automation. Open question before implementing: does the plugin-service backend authorize `client_credentials` (service-identity) tokens equivalently to user-delegated ones?

### 2026-08-05 — Linked to GRAPH-2540, but does not close it
GRAPH-2540 (Open ThreatForge threat: `GRAPH_SDK_ACCESS_TOKEN` env-var exposure in CI) is related but not resolved by this fix — the env-var leakage vectors are independent of which grant type mints the token. The S2S approach does satisfy GRAPH-2540's "utility account, not personal account" mitigation. Action item added to GRAPH-3461: scope the new S2S credential minimally (skip `firefly_api` if unused) rather than blanket-granting `AdobeID, openid, firefly_api`.

### 2026-08-05 — GRAPH-3457's PR has a temporary stopgap
PR #498 (GRAPH-3457) has `continue-on-error: true` added to the Build job in `.github/workflows/build.yml`, committed only to the PR branch (not `main`), so PR #498 isn't blocked while this ticket is worked. Remove that workaround once GRAPH-3461 lands.

### 2026-08-05 — Live IMSS inspection of the two stage clients (imss.corp.adobe.com)
Confirmed on stage (`#/client/stage/...`):
- **`project-graph-sdk-v1`**: Authentication Type = **PUBLIC**; **Service Tokens = "Not available for this type of client"** (a public client structurally cannot mint service/S2S tokens — this is the hard blocker, not just the missing secret); Password grant is still listed but ineffective for public; no Organization/Org-ID field anywhere on the page. paterson is in **Client Admins** (aportill, delarre, hmitchell, justinwillis, khyde, paterson, rbenedetti, saykumar) → can edit this client but cannot un-PUBLIC it.
- **`firefly_graph_sdk_cicd`** (the CI-dedicated client): grant types = **Refresh token + Authorization code** only, and the **grant-type field is locked to self-serve editing** — cannot add `client_credentials` via IMSS. So retrofitting this client is not a self-serve option.

### 2026-08-05 — S2S credential must be minted in Developer Console STAGE, and self-serve is blocked
CI authenticates against **stage** (`GRAPH_SDK_ENV=stage`), so the new OAuth Server-to-Server credential must come from the **stage** Developer Console — `https://developer-stage.adobe.com/console/` (prod is `https://developer.adobe.com/console/`). Environment is chosen by where the project is initialized.
- **Prod** Developer Console org ID (grabbed while exploring): `0EDB7DFF6A5A594C0A494125@AdobeOrg`. Stage org may differ — use whatever org the stage credential is actually created under.
- **Blocker:** on stage (org **310936**), `/console/projects` redirects to a **"Restricted access — You do not have developer access and need admin approval to use developer tools"** banner. Cannot self-serve create the credential; need a System Admin on stage org 310936 to grant developer access (or mint the credential directly).

### 2026-08-05 — The DC "self-serve onboarding" tool is a red herring for this
`https://developer-stage.adobe.com/onboarding/` (wiki `AdobeCloudPlatform/2650979117`) is for **publishing SDK binary downloads** to Developer Console (product cards, Download Groups, Promote-to-Prod) — the Enterprise Node Publishing / distribution workstream, NOT OAuth credential creation. Its "Request Access" only grants access to a product card via an IAM group; it does not grant the developer access the console credential flow needs.

### 2026-08-05 — Code prep landed (client_credentials swap in graph-sdk integration setup)
Implemented the `client_credentials` swap in `packages/graph-sdk/integration/setup.ts` ahead of the credential existing: removed the `grant_type=password` + username/password path; now POSTs `grant_type=client_credentials` to the stage **v3** endpoint (`https://ims-na1-stg1.adobelogin.com/ims/token/v3`) using env vars `GRAPH_SDK_TEST_CLIENT_ID` + `GRAPH_SDK_TEST_CLIENT_SECRET` + `GRAPH_SDK_TEST_SCOPE` (all three required to run; absent → exchange skipped, staging suites skip via `describe.skipIf`). Updated `.env.test.local.example` and `docs/integration-testing.md` to match. Lint green, `setup.ts` typechecks. **Unverifiable end-to-end until the stage S2S credential exists AND the plugin-service backend-authz question is answered** (does it accept a service identity vs user-delegated token?). Note: CI's own `graph-sdk-integration.yml` consumes a pre-minted `GRAPH_SDK_ACCESS_TOKEN` secret, not these env vars — that token is minted by `graph-plugins-core`'s `scripts/ci/sdk-ims-token.sh` (separate repo, needs the same swap there).

### 2026-08-05 — Second password-grant casualty found in THIS repo
`.github/scripts/release-notes/ims-token.mjs` also does `grant_type=password` (token/v1, env vars `IMS_USER`/`IMS_PASSWORD`/`IMS_CLIENT_ID`/`IMS_CLIENT_SECRET`) and will break identically if its `IMS_CLIENT_ID` is the now-public client. Not yet fixed — same `client_credentials` treatment needed. `graph-cli/src/auth/ims-client.ts` + `graph-sdk/src/auth/adobe-ims-login.ts` are end-user interactive login (authorization_code/refresh), correctly out of scope.

### 2026-08-05 — Unblock path = people, not self-serve
Asked broadly in team channel (adobe-3di `#C084XR5E92N`, 2026-08-05) for someone able to grant stage-org developer access. Fallback contacts for Developer Console: **#adobe-developer-console** (`C3ZUVG0JJ`) and **Manik Jindal** (majindal); Janice Pearce + Hao Xu already have a live DC-team engagement via the Enterprise Node Publishing thread. Cleanest single ask: "developer access in Developer Console **stage** org 310936 to create an OAuth Server-to-Server credential for Graph SDK CI (GRAPH-3461)." Still-open code-side task: grep how CI obtains the token today (`scripts/ci/sdk-ims-token.sh`, `integration/setup.ts`) so the `client_credentials` swap is ready the moment access lands.
