---
name: jira-graph-4056
description: GRAPH-4056 (E2E SDK workflow tests) superseded by Epic GRAPH-4114 with per-command child stories 4115-4122
metadata: 
  node_type: memory
  type: project
  originSessionId: 5cf26d35-aaaf-4fe8-80ed-b9fe25712158
  modified: 2026-09-04T23:02:43.279Z
---

GRAPH-4056 ("[QE] Test and Automate E2E SDK workflows") was a QE story to bring graph-cli/@graph/plugin-sdk to integration-test parity with the retired graph-sdk. It was filled with a full CLI user-flow catalog, then **restructured** (2026-09-04):

- Superseded by **Epic GRAPH-4114** ("E2E SDK Workflow Testing", Relates GRAPH-2601). Epic holds the shared "virtual plugin project" harness mechanics (createTempProject from `plugins/test-plugins/src/*` fixtures, spawn CLI as subprocess), command surface, and the parity map.
- 8 child Stories, one per flow group: **GRAPH-4115** auth/session · **4116** list plugins · **4117** install · **4118** build · **4119** lint/format · **4120** dev server · **4121** submit · **4122** cross-cutting.
- GRAPH-4056 closed as Done, comment points to the Epic.

Harness proven in `packages/graph-sdk/integration/test-helpers.ts`; port CLI path to graph-cli built entry (`@adobe/graph-cli` `lib/index.js`), not old `lib/bin/cli.js`. Related backlog: GRAPH-1335/1472/1516-1522/1708.
