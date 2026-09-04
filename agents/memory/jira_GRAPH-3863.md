---
name: jira-graph-3863
description: "GRAPH-3863 — publish external Plugin Developer Guide/SDK docs to developer.adobe.com/firefly-graph; Epic GRAPH-2601, Sprint 28"
metadata: 
  node_type: memory
  type: project
  originSessionId: aaa4ef07-8014-40e1-a94a-42d2a529a4fa
  modified: 2026-08-24T23:00:15.330Z
---

GRAPH-3863 ("Publish external Plugin Developer Guide / SDK docs to developer.adobe.com/firefly-graph") created 2026-08-24, Story, Epic GRAPH-2601 (Enterprise Ready SDK), assigned paterson, added to Graph Sprint 28 (8/24–9/4).

**Why:** With [[jira_DEVSITE-2511]] (EDS DevDocs onboarding) Done and the `AdobeDocs/firefly-graph` repo/GitHub access in place, the remaining gap for external plugin/SDK documentation is porting real content — there was no live public docs site before this, only the internal Confluence Plugin Developer Guide (page 3769393821, kept in sync via the automated `git pr merge` review — see [[project_graph_sdk_confluence_review]]).

**How to apply:** Scope is to port/adapt the Confluence Plugin Developer Guide into the firefly-graph EDS repo, validate on stage, then coordinate with DevSite for the Fastly go-live step. Reconcile known-stale content first — GRAPH-2336 flagged the guide as out of date re: per-plugin-type tsconfig `lib` selection (GRAPH-2196); check its status before republishing externally.

**Progress (2026-08-24):** All 10 Confluence pages + overview ported into `src/pages/guides/*` (working tree, not yet committed), replacing dummy Analytics-template content; nav rewired in `config.md`/`index.md`; dummy pages + petstore API demo deleted. Local `adp-devsite-utils runLint --internal-links-only` passes clean (0 issues, 16 files).

Critical scope note: the SDK is being revamped into `@adobe/graph-cli` (binary `graph`) — see `~/projects/adobe/project-graph/GRAPH-2740/GRAPH-2736/migrate-sdk-subcommands-versioned-bundles/packages/graph-cli`. Verified against source (not just the old Confluence CLI Reference) that the command surface changed substantially: `install`/`build`/`lint`/`format` dropped per-plugin filtering (whole-project only, only `dev` still filters by plugin name); `plugins` lost `--include`/`--type` filters; `submit` was reworked from per-plugin major/minor interactive prompts to a single whole-project archive submitted to a named `--channel` (default `release`) with a required `--changelog` (10-500 chars) — no more `--status`/`--force`/`--new-only`/`--skip-build`. `GRAPH_SDK_ENV=stage` env var name was *not* renamed despite the CLI rebrand (still controls `login`/`submit` stage vs prod); `--graph-url` is a separate per-command flag for `install`/`dev`. CLI Reference and Submitting Plugins pages were fully rewritten (not just find/replaced) to reflect this.

Still open before this ticket can close: (1) validate rendering on stage (https://developer-stage.adobe.com/firefly-graph/) — not done this session, no stage deploy access from here; (2) notify DevSite team ahead of go-live for the Fastly domain-mapping step — communication action, needs explicit user go-ahead; (3) actual publish/go-live. Nothing has been committed or pushed yet.
