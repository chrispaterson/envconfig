---
name: jira_GRAPH-1875
description: GRAPH-1875 (Done, closed as known IMS limitation) — graph-sdk login cannot force IMS profile/org switching; duplicated by GRAPH-3411
type: project
originSessionId: ffe9f595-c58e-41de-91cc-33e1f2542c52
modified: 2026-08-03T18:40:29.316Z
---
GRAPH-1875: "graph login should always present IMS profile selection instead of auto-authenticating." Status: **Done**, closed as a known IMS limitation (not implemented). **Duplicated by GRAPH-3411** ("SDK login should always show login flow and org selector regardless of p[rompt]...", also Done) — confirmed via Jira's "IS DUPLICATED BY" link, so any future ask for this capability should point back to this ticket rather than reopening work.

**Final conclusion (Chris Paterson comment, 2026-06-25): "IMS does not provide a way to force profile switching."**

**Timeline:**
1. 2026-05-06 — first attempt, commit `dc9054fbd` on branch `paterson/GRAPH-1875/add-switch-profile-login-flag`, added `--switch-profile` using `prompt=select_account` (a Google OAuth convention, not a real Adobe IMS value). PR #2819 passed CI, got zero reviews, silently closed unmerged 2026-05-14. Never merged to `main`; not present in current `graph-sdk` code.
2. Ticket description was later corrected to the real documented IMS value: `prompt=login` (confirmed against the Adobe IMS wiki, "IMS authorize entry point", space `ims`, page 718766668 — `select_account` isn't a real IMS param; only `none`/`login` are documented).
3. `prompt=login` was tried and **still didn't achieve the goal** — the ticket's own acceptance-criteria notes explain why: `prompt=login` is NOT forwarded to external IdPs. Most plugin developers authenticate via federated SSO (Type 3, e.g. Okta), so their browser session is controlled by the external IdP, not IMS's own cookie — bypassing IMS's cookie does nothing for them; they get silently re-authenticated through the IdP's session regardless of the `prompt` param.
4. Conclusion: there is no IMS-level parameter that reaches into a federated IdP's session and forces an org/profile picker. Closed as Done/won't-fix given this is a platform limitation, not a graph-sdk bug.

**Do NOT re-suggest `prompt=login` (or any other IMS `prompt`/`reauth`/`idp_flow` param) as a fix without first re-verifying it changed for federated (Type 3) accounts specifically** — the previous investigation (including a documented reading of the same IMS wiki page) already reached and closed on this exact dead end.

**Not gated by grant type:** `graph-plugin-sdk` (Authorization Code + PKCE) and `graph-sdk` (implicit grant) share the identical `IMS_CLIENT_ID` ("project-graph-sdk-v1"), and `prompt` is an authorize-endpoint-level param orthogonal to `response_type` — so the same limitation applies to both packages' login flows regardless of which grant type is used.

**Jira auth gotcha (found 2026-08-03):** `~/.env` on this machine defines `JIRA_PAT_TOKEN`, but the `jira` CLI reads the standard `JIRA_API_TOKEN` env var. A stale `JIRA_API_TOKEN` from the shell profile (not `~/.env`) was shadowing the fresh PAT, causing persistent 401s on `jira issue view` even though `jira me` (a purely local, no-network command) appeared to "work" and a direct `curl` with `$JIRA_PAT_TOKEN` succeeded. Workaround: `JIRA_API_TOKEN="$JIRA_PAT_TOKEN" jira ...`, or fix whichever script writes `~/.env` to export the name the CLI expects. See [[feedback_jira_auth]].
