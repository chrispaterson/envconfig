---
name: reference-adobedocs-gh-account
description: "Creating PRs on the public AdobeDocs GitHub org needs the chrispaterson gh account, not the EMU paterson_adobe"
metadata: 
  node_type: memory
  type: reference
  originSessionId: b4e8fcf8-4979-4882-9a54-5734e0ed5aef
  modified: 2026-08-27T19:40:55.820Z
---

The `firefly-graph` repo (and other public `AdobeDocs/*` repos) live on the **public**
github.com org. The default active `gh` account `paterson_adobe` is an Enterprise Managed
User (EMU) and gets `GraphQL: Unauthorized: As an Enterprise Managed User, you cannot access
this content (createPullRequest)` when creating PRs there.

Fix: switch to the personal `chrispaterson` account for the API call, then switch back:

```
gh auth switch --hostname github.com --user chrispaterson
gh pr create ...
gh auth switch --hostname github.com --user paterson_adobe
```

`git push` over SSH works fine under either account — only the gh API (PR create/edit/view)
is gated. Both accounts are authed in the keyring. See [[reference_devsite_docs_onboarding]]
and [[jira_DEVSITE-2511]] for the firefly-graph DevDocs repo context.
