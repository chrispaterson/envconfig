---
name: jira-graph-2254
description: "GRAPH-2254: error when no plugins found for a command; add meaningful error/throw when ProjectPlugin[] is empty"
metadata: 
  node_type: memory
  type: project
  originSessionId: a7cd0fa9-4466-4905-8f86-a3a7ca251261
---

GRAPH-2254: When any SDK command runs and `getProjectPlugins` returns an empty array, throw a meaningful error with a non-zero exit code.

**Why:** Currently commands silently no-op or log inconsistently (submit logs error, make-docs/review-docs log info, build/lint/install/dev do nothing). Developer has no feedback when run in a directory with no plugins.

**How to apply:** Fix likely lives in `getProjectPlugins` (project-plugins.ts) or as a shared guard. Note `list-plugins` may need to opt out since 0 results is valid output for that command. Unit test required.

Estimate: 2.1 pts. Epic: GRAPH-1271. Sprint: Graph Sprint 22 (May 25–Jun5).
