---
name: jira-graph-2198
description: GRAPH-2198 graph/no-globals ESLint rule — design decisions beyond the literal AC
metadata: 
  node_type: memory
  type: project
  originSessionId: 5bd39577-8c2d-467e-a466-feb8250f6018
---

GRAPH-2198: custom `graph/no-globals` ESLint rule in `@graph/eslint-plugin` (PR #3023, branch paterson/GRAPH-2198/...). Restricts global API usage to a per-plugin-type allowlist; effective list = `all ∪ options[pluginType]`. Wired into `graph.strict`; lists live in `src/globally-allowed-keys.ts`.

Non-obvious decisions made during implementation (validated against real `graph-plugins-core` core-nodes+ml-nodes via `graph-sdk link`/`graph-sdk lint`):

- **ECMAScript built-ins are never flagged**: the TS scope analysis (`globalScope.through`) resolves Array/JSON/Promise/etc. as standard-lib globals, so only non-ECMAScript host globals (DOM/worker/fetch APIs) reach the rule. This is why the allowlist contains no ES built-ins.
- **`forPluginType` (GRAPH-2242) determines a utility's runtime**: `createUtilityPlugin({ forPluginType: "node" | "widget" })`. The rule resolves the effective type from this, NOT just the create-fn name. node→Web Worker runtime, widget→DOM. **Defaults to "node" (Web Worker) when omitted** — a bare `createUtilityPlugin` never uses the `utility` allowlist key. Almost all utilities are "node"; utility-thumbnail-strip is "widget".
- **Helper modules inherit the sibling `plugin.ts` type**: a file with no create-plugin call (controller.ts, gl.ts) reads the directory's `plugin.ts` to resolve type. Without this, widget-context utility helpers using `document` would false-positive.
- **Allowlist bucketed by runtime availability, not usage site**: Worker-exposed globals → `all` (safe everywhere since node/datatype/node-utilities run in a Worker that's a subset of window); window-only globals (`document`, `ResizeObserver`) → `widget`. Type detection uses regex on plugin.ts text, not AST.
- **It's a SECURITY allowlist, intentionally tighter than the platform lib** (the real reason it's not redundant with GRAPH-2196's per-type tsconfig libs, which are additive + suppressible via `as any`/`@ts-ignore`). `XMLHttpRequest` is deliberately excluded even though the corpus used it (bypasses platform fetch security) → spun off [[jira-GRAPH-2501]] to migrate those usages to fetch. `globally-allowed-keys.ts` documents the deny-list (XHR, localStorage/sessionStorage/indexedDB, WebSocket/EventSource) + a guard test. Known hole: `(globalThis/self as any).X` property-access escapes can't be caught by scope analysis — review + runtime sandbox are the real boundary.

Related: [[jira_GRAPH-2242]] (forPluginType origin), [[jira_GRAPH-2196]] (per-type tsconfig), [[jira-GRAPH-2501]] (XHR→fetch prerequisite).
