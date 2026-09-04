---
name: jira-graph-3967
description: "GRAPH-3967: collector Story for general developer-facing documentation edits in firefly-graph repo"
metadata: 
  node_type: memory
  type: project
  originSessionId: 0c9bf9cc-a5d2-4c9a-af11-0a2f92d34a5f
  modified: 2026-08-27T23:14:52.301Z
---

GRAPH-3967 "Developer documentation edits — corrections and cleanup" is a collector Story for general edits/corrections to the developer-facing docs published at developer.adobe.com/firefly-graph (source in the firefly-graph repo under `src/pages/`).

- Epic Link: GRAPH-2601 (Enterprise Ready SDK) — same Epic as the doc-port work [[jira_GRAPH-3863]]. Note: user referred to it as the "GRAPH-3604 Epic", but GRAPH-3604 is a Story, not an Epic; confirmed GRAPH-2601 as the correct Epic.
- Created unassigned, not in a sprint (per request).
- Epic Link field is `customfield_11800`; `-P`/`--custom "Epic Link=..."` on the jira CLI did NOT populate it — set via REST PUT (204).
- Edit checklist (first item): remove the "Environment Configuration" section from the CLI Reference (`src/pages/guides/cli-reference/index.md`). Append new doc edits to the checklist as found.
