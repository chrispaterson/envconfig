---
name: reference-devsite-docs-onboarding
description: "How to get product documentation published on developer.adobe.com (the internal \"Developer Website\"/DevSite system)"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 73e84529-3201-49bd-bcc3-c37b2cc068b4
  modified: 2026-08-24T21:30:28.698Z
---

To publish documentation on developer.adobe.com, onboard through the "Developer Website" (DevSite) system, distinct from developer.adobe.com/developer-console (API/project management tool) and adobeprerelease.com (Creative Cloud beta-app access community).

Two content stacks:
- **Gatsby** — for structured technical documentation. Content lives in the public GitHub org `https://github.com/orgs/AdobeDocs/`, authored in Markdown. Requires a personal (non-corp) GitHub account and every author must sign the Adobe CLA.
- **Helix** — for marketing/landing-page content, authored in Google Docs via a Helix sidekick browser tool.

Onboarding steps (Gatsby path):
1. Sign the Adobe Contributor License Agreement (CLA).
2. Fill out the "Onboarding Tracker" wiki page with GitHub account + team info (minimum ask).
3. If a new team (not already in AdobeDocs org), also request a team via github.com/orgs/AdobeDocs/teams and add a row to the "Developer Site URL Namespace and Mapping" wiki table (repo name + optional URL, status = New).
4. DevSite team watches the tracker, files a Jira ticket (project DEVSITE), sets up repo/team access.
5. Author content using `gatsby-theme-aio` (nav, markdown, modular content system); deploy via the repo's GitHub Actions "Deploy" workflow (choose branch, dev/prod target).

Support/questions: Slack channel `#adobeio-devsite-onboarding`.

Separately, `git.corp.adobe.com/AdobeDocs` (private/internal repo, corp GitHub) is the path for Adobe Experience Cloud product teams publishing confidential/internal content — not for public SDK docs.

**Why:** DevSite (external, public GitHub, Gatsby/Helix, Fastly CDN) and Parliament (internal, corp GitHub, Jenkins, database-backed) are separate systems — a 2026 investigation (see Confluence "Developer Documentation" strategy page, space AdobeCloudPlatform) found merging them not viable due to differing security/build requirements, so the onboarding path depends on whether the docs are for external (public) or internal (behind-firewall) audiences.

**How to apply:** When Project Graph SDK docs need to go live on developer.adobe.com, use the public Gatsby/AdobeDocs path above, not the corp-internal Parliament workflow.

**Update 2026-08-24 — onboarding done for Graph.** This process completed for Project Graph via [[jira_DEVSITE-2511]] (Done, 2026-08-13): repo `AdobeDocs/firefly-graph` created, branded "Firefly Graph" (not "Project Graph"), public and standalone (not under Firefly Services). paterson has repo admin access via non-corp GitHub account `chrispaterson`. Stage: `https://developer-stage.adobe.com/firefly-graph/`; final public URL `developer.adobe.com/firefly-graph`. Content-authoring work is tracked separately in [[jira_GRAPH-3863]].
