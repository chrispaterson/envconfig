---
name: jira-graph-2501
description: GRAPH-2501 — migrate GLSL shader
metadata: 
  node_type: memory
  type: project
  originSessionId: 9f2418ea-6907-440d-9abb-bb10956d6707
---

GRAPH-2501 (Story, GRAPH project, Epic GRAPH-2243 Plugin security, component Nodes, relates to [[jira-GRAPH-2198]]). Unpointed (user skipped story-pointing).

Migrate the GLSL `#include` resolver from **synchronous `XMLHttpRequest`** to the platform `fetch`. Two identical copies in graph-plugins-core (an external repo):
- `core-nodes/src/utility-glsl/shader.ts` (`resolveDependencies`, ~line 39)
- `ml-nodes/src/node-generative-harmonization/glsl-shader.ts` (~line 97)

Why it exists: GRAPH-2198's `graph/no-globals` rule deliberately excludes `XMLHttpRequest` (it bypasses platform fetch security), so these two plugins fail `graph-sdk lint` once GRAPH-2198 ships. **Prerequisite for rolling out GRAPH-2198 cleanly.**

Refactor is non-trivial, not a one-liner: `resolveDependencies` (sync) is called by `loadProgram` (sync, a **publicly exported** util used by widget compositors), called by the async `render*` fns in render.ts. Options: make the chain async (public API signature change) OR pre-fetch/cache `#include`s before the sync render path. Est. ~5 (3 if the contained preload-cache path is taken).
