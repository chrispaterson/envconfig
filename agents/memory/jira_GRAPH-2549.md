---
name: jira-graph-2549
description: "GRAPH-2549 Agent Plugin repo architecture — standalone, per-client manifests, not SDK-generated"
metadata: 
  node_type: memory
  type: project
  originSessionId: a563dee3-d4a2-4403-88ba-c37438c86125
  modified: 2026-08-26T18:26:55.578Z
---

`firefly-graph-agent-plugin` (repo at `/Users/paterson/projects/adobe/project-graph/firefly-graph-agent-plugin`) implements GRAPH-2549: replace the `make-docs`/`review-docs` graph-sdk commands with an Agent Plugin (agent-plugins.org v1.0.0 + agentskills.io) giving a developer's own coding agent local doc-authoring/review skills instead of calling Firefly's 3P LLM.

**Correction (2026-08-24):** initially assumed `@graph/sdk`'s `install` command would vendor/copy this repo's content into a developer's plugin project on `graph install`. User corrected this — wrong. This repo is **completely independent of the SDK**: no graph-sdk command generates, fetches, or references it. A developer installs it directly into their coding agent client, exactly like any other agent plugin, with zero interaction with graph-sdk.

**Actual per-client install mechanics** (confirmed via real published example `github.com/slackapi/slack-skills-plugin` + official docs):
- Root `plugin.json` ($schema `agent-plugins.org/schemas/1.0.0/plugin.schema.json`) + root `skills/*/SKILL.md` = the vendor-neutral layer. **Cursor reads this natively**, no extra files needed.
- **Claude Code** requires its own `.claude-plugin/plugin.json` (schema `json.schemastore.org/claude-code-plugin-manifest.json`) **and** a separate `.claude-plugin/marketplace.json` (self-referencing, `"source": "./"`) for self-service (non-curated) install: `/plugin marketplace add <owner>/<repo>` then `/plugin install <name>@<marketplace-name>`. Claude Code explicitly sat out the Aug 2026 cross-vendor agent-plugins.org 1.0 launch.
- **Codex** uses its own `.codex-plugin/plugin.json` (fields: name/version/description/author/homepage/repository/skills/mcpServers/interface) plus a marketplace catalog at `.agents/plugins/marketplace.json` (`source: {source: "local", path: "./"}`): `codex plugin marketplace add owner/repo` then `codex plugin add <name>`.
- All these wrapper directories coexist fine alongside the shared root `plugin.json`/`skills/`.

**How to apply:** when working on this repo or similar agent-plugin distribution work, don't assume a client-agnostic spec repo is installable as-is by every client — verify each client's actual marketplace/manifest requirements (they diverge in practice even though skills/SKILL.md content itself is shared and vendor-neutral). See [[terminology_the_sdk]] for what "the SDK" means in this repo family.

**Hardening pass (2026-08-26, branch `first-pass`, pushed):** modeled the repo on the gbrain plugin's structure. Renamed skills `author-plugin-docs`→`create-docs`, `review-plugin-docs`→`review-docs` (manifests use the `./skills/` glob, so no manifest edits). Added the 4th plugin type **utility** to both skills + `doc-format-spec.md` + `doc-template.md` — policy: utilities are shared code and normally ship NO creative-professional `doc.md`; `create-docs` explains rather than generating, `review-docs` treats a missing utility doc.md as expected. Added `skills/RESOLVER.md` (dispatch map) + `triggers:` frontmatter (mirrored exactly) + `skills/manifest.json` index. All skill knowledge is self-contained (no load-bearing corp-wiki URLs — external devs' agents can't fetch corp SSO pages). The two `doc-format-spec.md` copies are kept byte-identical.

**Deferred → GRAPH-3936** (created 2026-08-26, Relates GRAPH-2549, component SDK, no epic): broader dev-workflow skills beyond doc authoring — `scaffold-plugin`, `develop-node/widget/datatype/utility`, `review-plugin-code`, `submit-plugin` — each vendoring offline knowledge from the Graph Plugin Guide (wiki) + `graph-plugins-core/PLUGIN_DEVELOPMENT_GUIDE.md`, preserving the no-source-egress property. `submit-plugin` must be guarded (prod is the `submit` default; manifest-only bumps need `--force`).
