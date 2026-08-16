---
name: feedback-cli-link-state-isolation
description: "When comparing two CLI tools against the same consumer project, fully clean each tool's linking/install artifacts before testing the other"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 99977699-8e91-4a40-9141-afd37bfbc175
  modified: 2026-07-20T21:27:37.645Z
---

Never run two different CLI tools' `link`/`install` commands back-to-back on the same consumer project without fully cleaning the first tool's artifacts before testing the second.

**Why:** While comparing `graph-sdk build` vs the new `graph build` (see [[jira_GRAPH-2736_build_parity_bugs]]) on `graph-plugins-core/core-nodes`, running `graph install` (new CLI) right after `graph-sdk link` (legacy CLI) left both mechanisms' symlinks active simultaneously — `pnpm-workspace.yaml` link: overrides from `graph-sdk link` plus `.platform-dependencies` symlinks from `graph install`. This produced spurious TypeScript `TS2719` "two different types with this name exist, but they are unrelated" duplicate-type-identity errors that looked like a real architectural bug in the new CLI, but were actually just contaminated test state from overlapping override mechanisms.

**How to apply:** Before switching which CLI/tool you're testing against a shared consumer project, fully reset: run the first tool's own `unlink` command, delete all its generated artifacts (`.platform-dependencies`, `.plugin-dependencies`, per-plugin `tsconfig.json`, `eslint.config.mjs`), and restore `node_modules` via a plain `pnpm install` (or equivalent) — don't just overlay the second tool's install on top. This applies generally whenever comparing dev-linked/local-linked tooling states, not just this specific SDK split.
