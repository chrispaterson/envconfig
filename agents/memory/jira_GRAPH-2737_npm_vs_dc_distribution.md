---
name: jira-graph-2737-npm-vs-dc-distribution
description: GRAPH-2737 re-scoped 2026-08-18 from public-npm-via-OSO to Adobe Developer Console self-service SDK distribution
metadata: 
  node_type: memory
  type: project
  originSessionId: 70f11a07-b129-49ba-9e13-b5a0a3f76f3c
  modified: 2026-08-19T03:02:57.186Z
---

**UPDATE 2026-08-18: DONE.** GRAPH-2737 has been re-scoped. Summary is now "Distribute @adobe/graph-cli via Adobe Developer Console SDK Onboarding"; description/AC/dependencies rewritten to the DC-onboarding flow below, IDOPS-31375 dropped as a blocker, and a comment logs the rationale (linking the 2026-07-27 Slack thread + GRAPH-3315). Still worth checking whether GRAPH-2466 (the parent it implements) needs a similar update.

GRAPH-2737 ("Publish @adobe/graph-cli to npm via Adobe Open Source Office") was open/New as of 2026-08-18, originally scoped around getting OSO review + npm org publishing secrets, blocked on IDOPS-31375 (IMS OAuth client → PUBLIC type) — this is the prior state, superseded by the update above.

**Why:** Slack (#prj-graph-core) shows the team moving away from public npm as the distribution mechanism:
- 2026-06-23: Ben Delarre — public npm isn't viable (no external Adobe npm registry); proposed alternative is a small CLI binary that pulls IMS-gated tarballs from an Adobe-hosted endpoint (Admin Console / developer extensibility platform).
- 2026-07-27: Janice Pearce surfaces the **Adobe Developer Console Onboarding Tool (SDK Onboarding)** — a self-service Confluence-documented path (support: #adobe-developer-console, contact Manik Jindal). Sayash Kumar explicitly calls it "an alternative to the public NPM publishing." Ben Delarre confirms it's not npm-compatible (binary blob hosting) but satisfies the ToU-acceptance requirement; plan becomes: distribute the CLI binary via DC, then fetch platform-exports/deps from an authenticated endpoint at build time. DC product intake form is the first step; ToU review tracked in GRAPH-3315.

**How to apply:** Before doing further work on GRAPH-2737, check whether a DC-distribution ticket already exists/supersedes it. GRAPH-2737 implements GRAPH-2466 ("Provide a public distribution mechanism for the Graph SDK", Done) — that parent may also need revisiting. Related: [[jira_GRAPH-3461]] (IMS/DC access work), [[jira_GRAPH-2467]] (platform dep tarball distribution — same DC-endpoint approach).
