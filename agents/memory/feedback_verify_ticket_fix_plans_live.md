---
name: feedback_verify_ticket_fix_plans_live
description: A Jira ticket's own confidently-stated root-cause analysis and fix plan can still be wrong — verify against the live service before implementing exactly as written
metadata:
  type: feedback
  originSessionId: dd0c813d-8bb0-470a-b2fd-5dbd7a350e6d
  modified: 2026-07-30T22:20:43.807Z
---

When a bug ticket includes a detailed, code-cited "confirmed by direct code inspection" root cause and an exact fix plan (specific values, specific call sites), don't implement it verbatim without independently verifying the prescribed values actually work — the ticket author can still be wrong about server-side behavior they didn't directly test.

**Why:** [[jira_GRAPH-3361]]'s ticket stated `platformVersion: { major: X, minor: 0 }` was a "safe floor" for resolving plugin dependencies, with a plausible-sounding rationale ("minor bumps are additive/backwards-compatible"). Implementing it exactly as specified and then live-testing against the real staging plugin service (not just unit tests with mocks) revealed `minor: 0` actually 404s in practice — a separate `graph-services` bug ([[jira_GRAPH-3363]]) where the model/SQL layer treats `minor: 0` as falsy ("no restriction," matching the ticket's assumption) but the controller's post-check uses `??` (which does not default on explicit `0`), so it stays as a literal `0` and fails a `resolvedMinor > requestedMinor` ceiling check. Unit tests with mocked `resolvePlugin` would never have caught this since they don't exercise the real server logic.

**How to apply:** For any fix touching an external service integration (HTTP API, database query, third-party SDK), after implementing per the ticket/spec, do a live smoke test against a real (stage/sandbox) instance of that service before considering the fix complete — don't rely solely on mocked unit tests to validate the fix actually works end-to-end. If the live test reveals a problem, treat it as a real, separate finding worth its own investigation/ticket rather than silently reverting to "whatever makes the mock pass."
