# Memory Index

This file lists memory files stored for this project. Full detail lives in each linked file — entries here are short hooks only.

## Project

- [project_slack_gbrain_ingestion.md](./project_slack_gbrain_ingestion.md) — Slack→gbrain ingestion pipeline (slackdump + Slack MCP); xoxc token re-auth is manual

- [jira_GRAPH-4056.md](./jira_GRAPH-4056.md) — GRAPH-4056 E2E SDK workflow tests superseded by Epic GRAPH-4114 (child stories 4115-4122, one per CLI command group); 4056 closed Done
- [jira_GRAPH-997.md](./jira_GRAPH-997.md) — GRAPH-997: 401-from-graph-services IMS revalidation + reauth-on-401 retry; implemented PR #3585 (refactor did NOT fix it)
- [jira_GRAPH-3461.md](./jira_GRAPH-3461.md) — GRAPH-3461: IMS password-grant CI fix via confidential client + secret; Epic GRAPH-2601
- [jira_GRAPH-2737_npm_vs_dc_distribution.md](./jira_GRAPH-2737_npm_vs_dc_distribution.md) — GRAPH-2737 re-scoped to Adobe Dev Console self-service distribution; check GRAPH-2466 parent
- [jira_GRAPH-3461_ci_full_build_fallback.md](./jira_GRAPH-3461_ci_full_build_fallback.md) — GRAPH-3461: detect-build-plugins.sh falls back to full build, not skip, on no plugin changes
- [jira_GRAPH-2736_build_parity_bugs.md](./jira_GRAPH-2736_build_parity_bugs.md) — GRAPH-2736: graph-cli/graph-sdk build parity bugs (distDir, sdk-paths.ts); forPluginType gap → [[jira_GRAPH-3362]]
- [jira_GRAPH-2736_compiler_in_bundle_shipped.md](./jira_GRAPH-2736_compiler_in_bundle_shipped.md) — GRAPH-2736 compiler-in-bundle SHIPPED+live-verified (PR #3306); 2-part forward fix (closure + build-script pack); tsc-resolution fix; remaining core-nodes fails = GRAPH-2196 DOM libs
- [jira_GRAPH-3362.md](./jira_GRAPH-3362.md) — GRAPH-3362: move forPluginType to manifest.json; DEFERRED (platform-exports major bump); interim → [[jira_GRAPH-3860]]
- [jira_GRAPH-3860.md](./jira_GRAPH-3860.md) — GRAPH-3860: interim fix — scope TS extraction to utility plugins only at install; relates [[jira_GRAPH-3362]]
- [bundling_tsdown_bugs.md](./bundling_tsdown_bugs.md) — GRAPH-2736: tsdown bundling bugs (import.meta.url, recursive-type dup); platform-exports packed as tarball
- [jira_GRAPH-2736_platform_version_regression.md](./jira_GRAPH-2736_platform_version_regression.md) — GRAPH-2736: platform-version.ts revert; FIXED via GRAPH-3361 worktree port
- [graph_sdk_logger_migration.md](./graph_sdk_logger_migration.md) — GRAPH-2736: plugin-sdk Logger(@logtape)→GraphLogger(@graph/logging); logger optional w/ guard
- [jira_GRAPH-2467.md](./jira_GRAPH-2467.md) — GRAPH-2467: distribute platform deps as tarballs via graph-sdk install; 5-phase plan in resilient-hatching-glacier.md
- [jira_GRAPH-2736_platform_minor_versioning.md](./jira_GRAPH-2736_platform_minor_versioning.md) — GRAPH-2736: platform dep provisioning keyed major.minor; server discovery stays major-only (GRAPH-3363)
- [jira_GRAPH-3966.md](./jira_GRAPH-3966.md) — GRAPH-3966: investigate hardcoded ESLint ~9.39.0 pin vs versioned closure model; eslint is registry-resolved, not bundled; Epic GRAPH-2601
- [jira_GRAPH-4046.md](./jira_GRAPH-4046.md) — GRAPH-4046 Node 22→24 floor bump; @types/node@24 breaks app tree (esnext.iterator strict Map/Set vs signal-utils); NOT settled, recommend deferring the @types/node@24 bump; PR #3606; docs/Confluence outstanding
- [sdk_milestone_reorg.md](./sdk_milestone_reorg.md) — SDK epics reorganized into 4 value milestones; GRAPH-1271 split into GRAPH-2457/2458
- [sdk_velocity_roadmap.md](./sdk_velocity_roadmap.md) — SDK-only throughput ~5 pts/sprint vs ~16-19 whole-team; don't use team velocity for SDK timelines
- [project_graph_sdk_confluence_review.md](./project_graph_sdk_confluence_review.md) — `git pr merge` auto-reviews Plugin Developer Guide when graph-sdk changes; files Jira if stale
- [adobe_copyright_header_policy.md](./adobe_copyright_header_policy.md) — Adobe Legal: 2 header templates — internal ADOBE CONFIDENTIAL vs. SDK license-grant
- [jira_DEVSITE-2511.md](./jira_DEVSITE-2511.md) — DEVSITE-2511 DONE: firefly-graph EDS DevDocs repo/site created, public+standalone; feeds [[jira_GRAPH-3863]]
- [jira_GRAPH-645.md](./jira_GRAPH-645.md) — GRAPH-645: canonical Graph Developer Documentation Site Epic (developer.adobe.com/firefly-graph); reused 2026-08-31, doc stories re-parented here from GRAPH-2601
- [jira_GRAPH-3863.md](./jira_GRAPH-3863.md) — GRAPH-3863: port Plugin Developer Guide content to developer.adobe.com/firefly-graph; Epic GRAPH-645, Sprint 28
- [jira_GRAPH-3967.md](./jira_GRAPH-3967.md) — GRAPH-3967: collector Story for general developer-facing doc edits; Epic GRAPH-645, unassigned/no-sprint; Epic Link=customfield_11800 via REST
- [jira_GRAPH-3975.md](./jira_GRAPH-3975.md) — GRAPH-3975: placeholder Story for Product to define support strategy + replace lorem-ipsum Support section; Epic GRAPH-645; relates GRAPH-3967
- [jira_GRAPH-2549.md](./jira_GRAPH-2549.md) — GRAPH-2549: Agent Plugin repo standalone, decoupled from graph-sdk; per-client manifests (Claude/Codex/Cursor)
- [jira_GRAPH-3604.md](./jira_GRAPH-3604.md) — GRAPH-3604: versioned platform bundle archival (/graph/platform/version|major|current); DONE, bundles downloadable in prod
- [jira_GRAPH-3159.md](./jira_GRAPH-3159.md) — GRAPH-3159 SHIPPED (PR #3586): SDK license-grant banner on graph-cli built output via tsdown banner; --config-loader unrun gotcha; scope=graph-cli only, year 2023
- [jira_GRAPH-4026.md](./jira_GRAPH-4026.md) — GRAPH-4026 Epic: enable agentic plugin dev; developer-driven distribution only (no Adobe-run inference, per GRAPH-2532/33/34); baseline AGENTS.md=GRAPH-4025; spike GRAPH-4027 evaluates Agent Plugins/skills-npm/scoped CLAUDE.md
- [jira_GRAPH-2736_branch_closeout_stories.md](./jira_GRAPH-2736_branch_closeout_stories.md) — GRAPH-2736 closeout: stories GRAPH-4035 (cli cutover capstone)/4036 (compiler tsc)/4037 (plugin-sdk 3593+smoke) port remaining branch delta to main, Epic GRAPH-2601; merge 4036+4037 then 4035
- [jira_GRAPH-4045.md](./jira_GRAPH-4045.md) — GRAPH-4045: port multi-dev-server (ports + cross-package live peers, PR #3510/GRAPH-3880) from @graph/sdk to @graph/plugin-sdk; external→published translation; handoff attached
- [jira_GRAPH-4109.md](./jira_GRAPH-4109.md) — GRAPH-4109: correct graph-cli-sdk-split-architecture.md — platform bundles are public (non-IMS) endpoint per GRAPH-3604; Epic GRAPH-2601, Sprint 28
- [jira_GRAPH-4038.md](./jira_GRAPH-4038.md) — GRAPH-4038: un-skip vendored-npm platform-closure smoke test; external closure entry (@graph-services/specs) needs live pnpm-pack, NOT a bare entry.dir→resolveClosureEntryDir swap; PR #3622
- [jira_GRAPH-4113.md](./jira_GRAPH-4113.md) — GRAPH-4113: rename @adobe/graph-cli → @graph/cli for monorepo consistency; Epic GRAPH-2601, Sprint 28

### Backlog/history — graph-sdk & graph-plugins-core (mostly GRAPH-1271 era; see file for status)
GRAPH-1335 install integration tests · GRAPH-1336 shared integration test utils (blocked) · GRAPH-1472 submit integration tests · GRAPH-1497 dev command graphUrl fallback bug · GRAPH-1498 install skips tsconfig for no-dep plugins · GRAPH-1499 distDir 'src' ancestor bug · GRAPH-1516 401/403 auth integration tests · GRAPH-1517 POST /plugins rejection tests · GRAPH-1518 PATCH /plugins failures tests · GRAPH-1519 install remote dep resolution failure tests · GRAPH-1520 submit --status registry states tests · GRAPH-1521 submit partial-failure recovery tests · GRAPH-1522 path-filtered CI workflow for graph-sdk · GRAPH-1525 submit "No plugins found" by package name bug · GRAPH-1568 debug logs need plugin name · GRAPH-1601 normalize audit structural fixes · GRAPH-1708 submit tests silently skip on CI (missing secret) · GRAPH-1726 prettier not bundled in published SDK · GRAPH-1742 template eslint config wrong import · GRAPH-1746 install rewrites tsconfig wrong whitespace · GRAPH-1747 security: bearer token printed in errors · GRAPH-1749 template eslint dep not ensured installed · GRAPH-1761 assertIsInDevPluginManifest + changelog validation · GRAPH-1763 install leaves stale tsconfig/symlinks on dep removal · GRAPH-1769 CLI progress logging format · GRAPH-1787 dev command build validation blocks startup · GRAPH-1868 derive platformVersion from import path · GRAPH-1870 sort tsconfig paths alphabetically · GRAPH-1874 link command lockfile exclude · GRAPH-1875 login --switch-profile flag · GRAPH-2089 submit blocks doc-only changes bug · GRAPH-2129 unlink command · GRAPH-2158 bump @graph-services/specs · GRAPH-2171 install auto-adds doc.md to assets.internal · GRAPH-2196 per-plugin-type tsconfig templates (DOM libs) · GRAPH-2198 graph/no-globals ESLint rule (honors forPluginType) · GRAPH-2501 GLSL #include resolver XHR→fetch (prereq for GRAPH-2198) · GRAPH-2207 'info' command · GRAPH-2223 README link command instructions · GRAPH-2242 utility plugin widget/node classification · GRAPH-2254 error when zero plugins found · GRAPH-2286 'create' command scaffolding · GRAPH-2296 install prefers remote deps, --use-local-deps flag · GRAPH-2302 zPluginManifest strict schema validation · GRAPH-2304 Epic: public distribution strategy TBD · GRAPH-2336 docs update for GRAPH-2196 · GRAPH-2504 graph/no-module-scope-vars rule (registered, not enabled) · GRAPH-2506 graph/no-undeclared-fetch-source rule · GRAPH-2503 unlink BUILD ERROR, stderr swallowed · GRAPH-2513 remove module-level vars (34 plugins, depends GRAPH-1571) · GRAPH-2514 enable no-module-scope-vars (depends GRAPH-2513) · GRAPH-2636 improve "patch" updateType error message · GRAPH-2639 parallelize build with p-limit · GRAPH-2660 graph/no-pluginconfig-fields-in-manifest rule · GRAPH-2978 submit resolvePlugin omits platformVersionMajor bug · GRAPH-3361 dep resolution ignores platform major (PR #3297, blocked by GRAPH-3363) · GRAPH-3593 fix resolveExternal major conflation (blocks GRAPH-2652) · GRAPH-3594 CLOSED Cannot Reproduce · GRAPH-3660 DONE PR #3403 major-aware selectPlugins · GRAPH-3363 CONFIRMED FIXED prod 2026-08-04, unblocked GRAPH-3361 · GRAPH-3159 rescoped to SDK license text in build output · GRAPH-3264 short-form copyright header repo-wide (1231 files) · GRAPH-3352 unify duplicated GH Actions build/release logic · GRAPH-3373 WidgetResizeControllerOptions.target null regression · GRAPH-3377 widget-resize-controller.test.ts never runs (vitest gap) · GRAPH-3795 DONE PR #3441 Windows path-separator fixes · GRAPH-3597 bump core/ml-nodes @graph/* deps for GRAPH-3593
- [jira_GRAPH-2736_platform_download_auth_gap.md](./jira_GRAPH-2736_platform_download_auth_gap.md) — GRAPH-2736: platform-bundle download had zero auth; fixed w/ imsLogin + Bearer + redirect detection

## User

- [terminology_the_sdk.md](./terminology_the_sdk.md) — "the SDK" = 4 packages: @adobe/graph-cli, @graph/plugin-sdk, @graph/sdk-common, @graph/plugin-compiler

## Reference

- [gbrain_two_machine_setup.md](./gbrain_two_machine_setup.md) — gbrain host on Mac mini (`ssh Mini`, Postgres 17); MacBook uses loopback tunnel; mini ~/brain git write-through still blocked
- [reference_graph_cli_sdk_split_architecture.md](./reference_graph_cli_sdk_split_architecture.md) — graph-cli/SDK split architecture doc: docs/graph-cli-sdk-split-architecture.md
- [reference_ims_self_serve_portal.md](./reference_ims_self_serve_portal.md) — Adobe IMS self-serve portal (OAuth client admin) at https://imss.corp.adobe.com/
- [storypoint_calibration.md](./storypoint_calibration.md) — Story point correction history; read before estimating, append after corrections
- [reference_homeassistant_ssh_access.md](./reference_homeassistant_ssh_access.md) — `ssh homeassistant.local` gives root shell on live HA instance
- [reference_vpn_lan_access.md](./reference_vpn_lan_access.md) — On GlobalProtect VPN use `.local` mDNS names for LAN hosts; router UI via SSH tunnel
- [reference_devsite_docs_onboarding.md](./reference_devsite_docs_onboarding.md) — DevSite/Gatsby onboarding process; DONE for Graph — repo AdobeDocs/firefly-graph live, see [[jira_DEVSITE-2511]]
- [reference_adobedocs_gh_account.md](./reference_adobedocs_gh_account.md) — Public AdobeDocs PRs need `gh` account chrispaterson, not EMU paterson_adobe (git push works either way)
- [reference_authsh_needs_env.md](./reference_authsh_needs_env.md) — graph auth.sh needs `source ~/.env` first (ARTIFACTORY_API_KEY_CLOUD); else rush update 401s/hangs

## Feedback

- [feedback_jira_auth.md](./feedback_jira_auth.md) — Jira CLI needs `source ~/.env` first; auth.sh only sets npm vars
- [feedback_check_git_diff.md](./feedback_check_git_diff.md) — Check git status/diff before modifying files, to understand direction of user's changes
- [feedback_pre_completion_workflow.md](./feedback_pre_completion_workflow.md) — Run build/lint/test in every touched package before finishing; write tests if none exist
- [feedback_jira_mcp_storypoints.md](./feedback_jira_mcp_storypoints.md) — jira_update MCP silently fails for story points; use curl w/ jira CLI bearer token
- [feedback_eslint_disable_comments.md](./feedback_eslint_disable_comments.md) — eslint-disable needs inline justification: `// eslint-disable-next-line <rule> -- <reason>`
- [feedback_jira_wiki_markup.md](./feedback_jira_wiki_markup.md) — jira CLI requires Jira wiki markup directly; does not convert Markdown
- [feedback_jira_cli_create_escapes_markup.md](./feedback_jira_cli_create_escapes_markup.md) — jira create -b/-T mangles raw wiki (escapes --, +, breaks {{..<x>..}}); set description via REST PUT, not create
- [feedback_jira_wiki_strikethrough.md](./feedback_jira_wiki_strikethrough.md) — Jira -phrase- = strikethrough; CLI flags (--changelog) get struck through even in {{}}; escape boundary hyphens as \-
- [feedback_jira_no_cross_issue_refs_in_body.md](./feedback_jira_no_cross_issue_refs_in_body.md) — Never write inter-issue relationships/keys in Jira body text; use Epic Link + issue links instead
- [feedback_jira_bug_environment_field.md](./feedback_jira_bug_environment_field.md) — GRAPH Bug "environment" field: jira CLI --custom can't set it, use REST API
- [feedback_cli_link_state_isolation.md](./feedback_cli_link_state_isolation.md) — Fully clean one CLI's link/install artifacts before testing another; avoids spurious TS2719
- [feedback_comment_style.md](./feedback_comment_style.md) — Never use `//` comments; expanded `/** */` blocks only (custom ESLint rule, 4 SDK packages)
- [feedback_ha_core_restart.md](./feedback_ha_core_restart.md) — Don't ask before restarting HA Core; just do it (back up + `ha core check` first)
- [feedback_pr_creation_use_skill.md](./feedback_pr_creation_use_skill.md) — Always use pr-summary/open-pr skill for PRs; ad hoc `gh pr create` misses required checks
- [feedback_separate_if_blocks.md](./feedback_separate_if_blocks.md) — Split OR'd guard/assert conditions into separate if blocks (one throw each)
- [feedback_verify_ticket_fix_plans_live.md](./feedback_verify_ticket_fix_plans_live.md) — Live-test a ticket's cited root cause/fix against the real service before trusting it
- [feedback_skip_formatting_in_handoffs.md](./feedback_skip_formatting_in_handoffs.md) — Don't spend context on code-formatting rules in handoffs/plans; eslint --fix + rush format auto-fix them
