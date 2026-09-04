---
name: jira-graph-4109
description: "GRAPH-4109: correct graph-cli-sdk-split-architecture.md — platform bundles are public (non-IMS) endpoint, not IMS-gated; Epic GRAPH-2601, Sprint 28"
metadata: 
  node_type: memory
  type: project
  originSessionId: bb789344-f94c-42b6-89a3-7fdc0f37753d
  modified: 2026-09-04T22:26:57.937Z
---

GRAPH-4109 (Story, Epic [[jira_GRAPH-2601 is Enterprise Ready SDK]] = GRAPH-2601, Sprint 28 id 224482, assignee paterson) — doc fix: `docs/graph-cli-sdk-split-architecture.md` in Adobe-CreativeCloud/graph still describes platform bundles as "served from an IMS-authenticated Graph Services endpoint" / "accessible only with a valid IMS token." That premise is stale.

**Why:** IMS gating on the bundle endpoint was walked back — Ben endorsed Sayash's GRAPH-3604 no-IMS design (Slack #prj-graph-core 2026-08-13/17), decision recorded 2026-08-19. GRAPH-3604 (public bundle delivery, `/graph/platform/version|major|current`) is DONE and live; prod endpoint verified ungated. Access control now lives at the SDK/dev-server layer (IMS login to *use* the SDK), not at the CDN download.

**How to apply:** the fix reframes Section 1 Summary + Problem 1, the platform-dependency install line (~line 29), and the Mermaid sequence diagram (remove Authorization: Bearer on bundle fetch + Graph Services→IMS profile lookup). Preserve four-package split, per-plugin version targeting, plugin-compiler-as-subprocess. Relates [[jira_GRAPH-3604]].

**Status:** DONE via draft PR #3626 (branch paterson/GRAPH-4109/docs-public-platform-bundle) 2026-09-04. All 5 ACs addressed; docs-only, no Rush change file needed (docs/ not a Rush project). Note: `git pr` OAuth session was expired — created PR with `gh pr create -R Adobe-CreativeCloud/graph -H <branch>` (remote is SSH alias git@github-adobe:, so gh needs explicit -R/-H).

**Added scope (beyond original ACs, per Chris 2026-09-04):** doc also corrected to say `@adobe/graph-cli` is distributed as a DOWNLOAD via the Adobe Developer Console (SDK onboarding flow), NOT public npm — no external Adobe npm registry exists. Updated Problem 1/2 prose, the `npm install -g` code block, the Section 3 package table, and the Section 4 Mermaid (npm participant → Adobe Developer Console). See [[jira_GRAPH-2737_npm_vs_dc_distribution]].
