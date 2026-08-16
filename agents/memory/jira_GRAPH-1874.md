---
name: jira_GRAPH-1874
description: GRAPH-1874: graph-sdk link command should add excludeLinksFromLockfile to pnpm-workspace.yaml; 2.1 pts, Epic GRAPH-1271
type: project
originSessionId: 0ab49832-0ea2-4103-99e5-fc37548a1456
---
GRAPH-1874: graph-sdk link command should add `excludeLinksFromLockfile: true` to `pnpm-workspace.yaml` to prevent local symlinks from polluting the pnpm lockfile.

**Why:** Without this field, every `graph-sdk link` run can dirty `pnpm-lock.yaml` with local link entries, causing spurious diffs and CI failures for developers who commit the lockfile.

**How to apply:** Change is fully contained in `createPNPMWorkspaceOverride()` in `link.ts` — prepend `"excludeLinksFromLockfile: true"` to the `lines` array before `"overrides:"`. Update `link.test.ts` assertion accordingly. No unlink command exists yet; AC note about unlink is a design constraint for future work.

Points: 2.1 | Epic: GRAPH-1271 (Graph SDK CLI improvements)
