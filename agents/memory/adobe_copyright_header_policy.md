---
name: adobe-copyright-header-policy
description: "Adobe Legal mandates two different copyright header templates — internal (ADOBE CONFIDENTIAL) vs. publicly-distributed SDK code — relevant to project-graph's copyright-header ESLint work"
metadata: 
  node_type: memory
  type: project
  originSessionId: e9182b6e-01ce-427e-897c-180f3e9edd11
  modified: 2026-07-28T00:42:17.091Z
---

Adobe Legal's `legalwiki` space has an authoritative page, "Copyright Notices for Source Code" (`https://wiki.corp.adobe.com/spaces/legalwiki/pages/1987870933/Copyright+Notices+for+Source+Code`), mandating a copyright header on every source file a developer creates. It names **two distinct canonical templates**, not one:

- `Source-Code.pdf` — the standard/internal header (the classic 17-line `ADOBE CONFIDENTIAL` block).
- `SDK-Source-Code.pdf` — for code distributed externally: a license-grant notice ("Adobe permits you to use, modify, and distribute this file in accordance with the terms of the Adobe license agreement accompanying it."), with **no "ADOBE CONFIDENTIAL" marking**.

Rule 4 on that page is explicit: *"If the source code is going to be made available to the public or becomes Open Source, remove 'ADOBE CONFIDENTIAL' in the copyright notice."*

**Why:** this was discovered while investigating the `graph/copyright-header` ESLint rule (GRAPH-3158, direct-ported from Horizon's implementation), which hardcodes the internal `ADOBE CONFIDENTIAL` header repo-wide — including for `packages/graph-sdk`, whose raw `src` is published and shipped to external plugin developers. That's a legal-policy mismatch, not a stylistic one.

**How to apply:** any copyright-header tooling in project-graph needs to distinguish internal-only code from code that ships as part of the published Graph SDK (`packages/graph-sdk`, and possibly `graph-plugin-types`/`platform-exports` — unconfirmed) and apply the SDK variant there instead. Tracked as a follow-up in [[jira_GRAPH-3159]].

**Update 2026-07-27:** Corey Lucier (Firefly) reached out directly via Slack confirming Firefly/Horizon/Boards use a short one-line header (`// © YYYY Adobe. All rights reserved. See /COPYRIGHT for details.`) instead of the verbose ADOBE CONFIDENTIAL block, driven by token-cost concerns — not cited as Legal policy, but stronger first-hand evidence than the earlier "personal wiki notes page" sighting. Implemented and shipped repo-wide (1231 files migrated) in [[jira_GRAPH-3264]] as a replacement of GRAPH-3158's header.

**Update 2026-07-27 (later same day):** User confirmed no real overlap between GRAPH-3264 and [[jira_GRAPH-3159]] after re-scoping the latter. GRAPH-3159 now targets the Adobe SDK license-grant text (`SDK-Source-Code.pdf`) on the *built/distributed artifacts* of the published Graph SDK — a Legal license-grant requirement applied at the build-output layer — while GRAPH-3264's short-form header is a source-level, repo-wide convention. Different files, different purposes; not competing.
