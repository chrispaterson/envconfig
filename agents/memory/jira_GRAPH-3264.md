---
name: jira-graph-3264-short-form-copyright-header
description: "Ticket memory for GRAPH-3264: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 62b36f2e-9c0a-4401-82d5-9e13db8511fd
  modified: 2026-07-28T00:42:04.189Z
---

# GRAPH-3264 — Replace verbose ADOBE CONFIDENTIAL copyright header with short-form Adobe header

**Type:** Story
**Created:** 2026-07-27
**Epic:** GRAPH-2601 — Enterprise Ready SDK
**Sprint:** Graph Sprint 26 (7/27–8/08), assigned to Chris Paterson
**Linked:** Relates to [[jira_GRAPH-3158]], [[jira_GRAPH-3159]]

## Origin
Corey Lucier (Firefly team) reached out via Slack DM (2026-07-24, https://adobe-3di.slack.com/archives/D0BKJ1WRUP8/p1784894272101079) flagging that Graph adopted the "super verbose legacy" ADOBE CONFIDENTIAL header (from GRAPH-3158) and that token cost matters. Firefly, Horizon, and Boards instead use a short one-liner: `// © 2026 Adobe. All rights reserved. See /COPYRIGHT for details.` — he asked Graph to follow suit and add an enforcing rule.

## Decisions

### 2026-07-27 — Scoped as full replacement, not an added variant
User chose "replace repo-wide" over "add as new option": the short-form header should replace the verbose block emitted by `tools/eslint-plugin-graph/src/rules/copyright-header.ts` (`generateCopyrightHeader`), not sit alongside it as a config choice.

### 2026-07-27 — Overlap with GRAPH-3159 flagged, then resolved as non-issue
Initially flagged an open question: whether this short-form header also satisfies the "no ADOBE CONFIDENTIAL" Legal requirement for SDK-distributed code, potentially superseding/simplifying [[jira_GRAPH-3159]]. **Resolved same day by the user: no real overlap.** GRAPH-3159 was re-scoped by the user (title/AC updated) to cover the Adobe SDK license-grant text on the *built/distributed artifacts* of the published Graph SDK (per `SDK-Source-Code.pdf`), not the raw repo source. GRAPH-3264's short-form header applies to repo source everywhere (including `packages/graph-sdk/src`, migrated in the same PR) for token-cost/convention reasons. The two tickets act on different files (source vs. built output) for different reasons (convention vs. Legal license grant) — not competing or redundant. See [[adobe_copyright_header_policy.md]] for the Legal-policy background.

**Correction to prior memory:** [[adobe_copyright_header_policy.md]] previously noted the short one-line format as "seen on a colleague's personal wiki notes page ... NOT part of official Legal policy ... should not be assumed to apply here." Corey's direct Slack message is stronger, first-hand evidence that this format is an active, real convention at Firefly/Horizon/Boards (not just a stray wiki note) — though it's still a team-convention/cost argument, not confirmed as Adobe Legal policy.
