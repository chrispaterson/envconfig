---
name: jira-devsite-2511
description: DEVSITE-2511 — EDS DevDocs onboarding for Project Graph (Done); repo/site details for publishing external SDK/plugin docs
metadata: 
  node_type: memory
  type: project
  originSessionId: aaa4ef07-8014-40e1-a94a-42d2a529a4fa
  modified: 2026-08-24T21:30:08.651Z
---

DEVSITE-2511 ("Onboard Project Graph to EDS DevDocs") is **Done** (closed 2026-08-13, reporter Pat Hyde, worked by Savitha Angadi).

**Outcome:**
- Public devsite repo created: `https://github.com/AdobeDocs/firefly-graph`. paterson added as repo admin — access requires accepting the GitHub email invite (uses non-corp/public GitHub account `chrispaterson`, not the GHEC/federated `paterson_adobe`, which DevSite cannot use).
- Branding decision (Janice Pearce, 2026-08-05/13): product is branded **Firefly Graph**, not "Project Graph" — repo name, path, and site title all use `firefly-graph`.
- Site will be **public** and **standalone** — explicitly NOT nested under the Firefly Services umbrella (`developer.adobe.com/firefly-services/graph` was rejected).
- Stage URL: `https://developer-stage.adobe.com/firefly-graph/`. Supported content blocks reference: `https://developer-stage.adobe.com/dev-docs-reference/`.
- Final public URL will be `developer.adobe.com/firefly-graph`.

**Why it matters:** This closes the onboarding/infrastructure half of getting Graph SDK/plugin docs external. The remaining work is authoring/porting content — tracked in [[jira_GRAPH-3863]].

**How to apply:** Before doing any further public-docs work, confirm the GitHub invite has been accepted and content pushes to `AdobeDocs/firefly-graph` render correctly on stage before asking DevSite to add the Fastly domain-mapping entry (go-live is NOT automatic — DevSite must be notified first per Savitha Angadi's 2026-08-13 comment).
