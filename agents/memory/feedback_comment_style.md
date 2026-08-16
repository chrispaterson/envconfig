---
name: feedback-comment-style
description: "Never use // comments; always use JSDoc-style /** */ blocks, even for single-line comments, with line breaks after /** and before */. Enforced via a custom ESLint rule in graph-sdk-common."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f27a63b9-5c6c-4457-b53c-8bf24fc0ea3d
  modified: 2026-07-23T02:00:53.471Z
---

Never use `//` line comments in code, in any language/project. Always use `/** */` block comments instead — even for a single line of explanation.

For a single-line comment, still use the multi-line block form, not the compact `/** comment */` one-liner:

```
// Wrong (// style)
// this explains the invariant

// Wrong (compact block style)
/** this explains the invariant */

// Correct
/**
 * this explains the invariant
 */
```

**Why:** explicit user instruction (2026-07-22) — the user dislikes both `//` and single-line `/** ... */` comments and wants every comment, regardless of length, in the expanded block form with `/**` on its own line, the text on its own line(s) prefixed with ` * `, and `*/` on its own closing line.

**How to apply:** applies to all comments I write across all projects and languages that support block comments (TS/JS, CSS, etc.) — not just TSDoc on exported symbols, but inline rationale comments too. When editing existing code that already has `//` comments, only convert them if I'm touching that comment anyway (per the "smallest correct change" default) — don't do a drive-by reformat of unrelated `//` comments unless asked.

**Exception — never convert directive comments.** `eslint-disable(-next-line/-line)`, `eslint-enable`, `eslint-env`, `globals`, `exported`, and TypeScript's `@ts-expect-error`/`@ts-ignore`/`@ts-nocheck`/`@ts-check` only work as single-line comments (`//` or single-line `/* */`) immediately adjacent to the line they affect. Expanding them into a starred block silently breaks the directive. Leave these exactly as-is.

**Additional formatting rules (added 2026-07-22, same session):**
- A block comment must have a blank line immediately above it, unless it's the first line of the file or the line above ends with `{`, `(`, or `[` (i.e. it's the first thing inside a newly opened block/object/array/argument list). This is a simple last-char heuristic, not full AST block-boundary analysis — a comment right after a `switch` `case:` label or an arrow function's `=>` still requires a blank line above it.
- A comment's content lines are wrapped at 120 columns (matching this repo's prettier `printWidth`) once its ` * ` prefix and indentation are accounted for. A single word that alone exceeds the width (e.g. a long URL) is kept intact rather than broken mid-word. The 120 figure came from the project's existing convention, not the user's `.vimrc` — checked `~/.vimrc` (symlinked to `~/envconfig/.vimrc`) and it has no `textwidth`/`colorcolumn` set, so there's no personal-editor value to read here; if asked again, don't assume it's been added since — re-check the actual file if it matters.

## Tooling: enforced via custom ESLint rule

In the `migrate-sdk-subcommands-versioned-bundles` branch of project-graph, this is enforced automatically by a custom ESLint rule rather than manual vigilance:

- Rule implementation: `packages/graph-sdk-common/src/require-block-comments.ts` (plus `.test.ts`), exported from `packages/graph-sdk-common/src/eslint-plugin.ts` as the `sdkCommon` plugin object, published via the package export `@graph/sdk-common/eslint-plugin.js`.
- Registered as `sdk-common/require-block-comments` in the `eslint.config.js` of all four SDK toolchain packages: `graph-sdk-common` (self, via relative `./lib/eslint-plugin.js` import), `graph-plugin-compiler`, `graph-plugin-sdk`, `graph-cli` (via the package-name import).
- This is deliberately separate from `@graph/eslint-plugin` (the `graph-eslint-plugin` package), which lints plugin *authors'* code (consumers of the SDK) — `graph-sdk-common`'s plugin only lints the SDK toolchain's own source.
- Autofixable via `eslint --fix` / `rushx lint:fix`. Correctly skips directive comments, merges consecutive `//` lines into one block, relocates trailing same-line `//` comments onto their own line above the code, and — critically — walks back past any directive comment immediately above a trailing comment's line so the directive stays adjacent to its target (a real bug hit and fixed during implementation: inserting the new block between a directive and its target silently broke the directive and caused ESLint to strip it as "unused").
- I initially tried ESLint's built-in/core `multiline-comment-style` rule (`["error", "starred-block"]`) as a lower-effort alternative — it only produces plain `/* */` (single star), not JSDoc-style `/** */`, so it doesn't actually satisfy this preference. Superseded by the custom rule above; don't reintroduce it for this purpose.

**Before relying on this in a future session:** verify the rule file, its plugin export, and the `eslint.config.js` registrations in those four packages still exist as described — this reflects the state as of 2026-07-22 and may have moved or been renamed since.
