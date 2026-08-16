---
name: GRAPH-1525
description: Bug — graph-sdk submit prints "No plugins found" when targeting plugin by package name in core-nodes
type: project
originSessionId: 80ed3486-e412-4f46-b7d7-f0ef5e2a046a
---
GRAPH-1525: `graph-sdk submit` prints "No plugins found" when run with a specific plugin package name from `graph-plugins-core/core-nodes`. Affects at least `@adobe/widget-angle-radian-inline` and `@adobe/node-create-layer`. No submission occurs.

**Why:** The submit command is not resolving plugins by package name when invoked from a multi-plugin workspace directory; the plugin discovery/filtering logic silently returns an empty set.

**How to apply:** Bug is in the submit command plugin discovery path. Investigate how submit filters/matches plugins when package names are passed as positional args vs. scanning the CWD.

Sprint: Graph Sprint 19 (Apr 13–24, 2026), sprint ID 214792. No Epic parent.
