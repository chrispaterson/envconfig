---
name: graph-2304-graph-sdk-public-distribution-for-enterprise-plugin-authors
description: "Ticket memory for GRAPH-2304: decisions, context, and origin notes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 57e1469c-ddbb-4dad-9756-013608d1aa50
---

# GRAPH-2304 — Graph SDK public distribution for enterprise plugin authors

**Type:** Epic
**Created:** 2026-06-01
**Epic:** none (this is the Epic)

## Origin
Created to unblock enterprise customers who need to install and use the Graph SDK outside Adobe's internal monorepo. Distribution strategy is TBD — key open question is whether to publish to public npmjs.com or serve a downloadable artifact from the admin UI. Adobe legal/open-source review requirements are also unresolved.

## Decisions
<!-- Newest first -->

### 2026-06-01 — Epic created, strategy TBD
Distribution mechanism is undecided. Open questions: public npm vs. admin UI download, npm scope (@adobe/graph-sdk vs. unscoped), and whether internal dependencies or licensing block a public npm publish. No Stories created yet — investigation/spike needed first.
