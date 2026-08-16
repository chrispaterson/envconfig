---
name: reference-ims-self-serve-portal
description: "URL for Adobe's internal IMS self-serve portal, used to administer OAuth client config (grant types, scopes, offline_access) for clients like project-graph-sdk-v1"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 868698da-1fa1-4132-8f70-74e079528cc9
  modified: 2026-08-05T19:06:44.465Z
---

The Adobe IMS self-serve portal (for administering IMS OAuth client configuration — grant types, scopes, public/confidential status, refresh token support) is at https://imss.corp.adobe.com/

Chris Paterson administers the `project-graph-sdk-v1` IMS client via this portal. Confirmed 2026-08-05 that refresh tokens are supported for this client. See [[jira_GRAPH-3457]] for the incident where this came up: IMS moved `project-graph-sdk-v1` to a public client type, breaking `graph-plugins-core`'s CI password-grant token exchange (`scripts/ci/sdk-ims-token.sh`), which had to move to a refresh-token-based flow instead.
