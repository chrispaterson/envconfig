---
name: jira-graph-645
description: GRAPH-645 is the canonical Graph Developer Documentation Site Epic (developer.adobe.com/firefly-graph)
metadata: 
  node_type: memory
  type: project
  originSessionId: 5eb422e1-0f3f-43d2-a496-04d98e557a4a
  modified: 2026-08-31T19:26:25.609Z
---

GRAPH-645 "Plugin Development & Documentation Site" is the **canonical Epic for the Graph Developer Documentation site** (external docs at developer.adobe.com/firefly-graph, source repo AdobeDocs/firefly-graph EDS/AEM; preview main--adp-devsite--adobedocs.aem.live/firefly-graph). Reused instead of creating a new doc Epic on 2026-08-31. Assignee/reporter Chris Paterson; components SDK + Plugin Service; status To Do.

Description refreshed from the prj-graph Slack thread (2026-08-27, C084XR5E92N). Scope covers: port of internal Plugin Guide wiki adapted for external audience (CLI via Adobe Dev Console download, no npm; internal Slack/wiki refs removed), external support/contact mechanism, CLI download URL ([[jira_GRAPH-2737_npm_vs_dc_distribution]]), org-ID acquisition docs, submission specifics, internal dogfooding, release-sync automation (platform-version pages already auto-generated via daily workflow; CLI changelog publish process TBD; historical/version-specific docs), platform-version-specific Plugin Development Guide + code-generated API docs (Ben Delarre's ask), and a PRD kickoff (Hao Xu/Shalini Ahuja).

Child stories re-parented from GRAPH-2601 (Enterprise Ready SDK) onto GRAPH-645: [[jira_GRAPH-3863]] (publish external guide), [[jira_GRAPH-3967]] (doc edits/cleanup), [[jira_GRAPH-3975]] (support strategy). Related: [[jira_DEVSITE-2511]] (firefly-graph repo/site creation).

SPIKE stories created 2026-08-31 under GRAPH-645 (component SDK, reporter Chris, unassigned/no-sprint; outcome = decide what to build): GRAPH-3998 (define CLI publish process for reference+changelog docs sync), GRAPH-3999 (platform-version-specific Plugin Development Guide + generated API reference — Ben Delarre's ask, largest open question), GRAPH-4000 (external onboarding: org ID acquisition + plugin submission/publishing, TODOs #3/#4). PRD kickoff (Product-led, Hao/Shalini) is captured in the Epic description, not a separate ticket.
