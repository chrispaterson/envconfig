# Memory Index

This file lists memory files stored for this project.

## Project

- [jira_GRAPH-3461.md](./jira_GRAPH-3461.md) — GRAPH-3461: IMS moved project-graph-sdk-v1 to public client, broke password-grant CI token acquisition; FIX = keep password grant, switch to confidential client firefly-graph-sdk-cicd-v1 + client_secret (S2S not needed, confirmed working 2026-08-06); related to GRAPH-2540 but doesn't close it; Epic GRAPH-2601
- [jira_GRAPH-3461_ci_full_build_fallback.md](./jira_GRAPH-3461_ci_full_build_fallback.md) — GRAPH-3461: detect-build-plugins.sh now falls back to full build (not skip) when no plugin changes detected; intentional reliability tradeoff over CI cost, user-confirmed 2026-08-06
- [jira_GRAPH-2736_build_parity_bugs.md](./jira_GRAPH-2736_build_parity_bugs.md) — GRAPH-2736: graph-cli vs graph-sdk build parity; distDir src/-prefix bug + sdk-paths.ts bundling bug both fixed+committed; discovery skipping extractPlugin() is intentional (not a bug); forPluginType-at-install-time gap filed as [[jira_GRAPH-3362]]
- [jira_GRAPH-3362.md](./jira_GRAPH-3362.md) — GRAPH-3362: move forPluginType from utility PluginConfig to manifest.json so install can read it without TS extraction; Epic GRAPH-2601, assigned paterson, in Sprint 26 (7/27-8/07)
- [bundling_tsdown_bugs.md](./bundling_tsdown_bugs.md) — GRAPH-2736: tsdown-bundled graph-cli/plugin-compiler/eslint-plugin; import.meta.url bug + recursive-type duplication when bundled output overwrites shared lib/. platform-exports does NOT bundle (reverted 2026-08-03) — packed as a tarball instead, closure rooted at platform-exports not plugin-compiler
- [jira_GRAPH-2736_platform_version_regression.md](./jira_GRAPH-2736_platform_version_regression.md) — GRAPH-2736: 2026-07-31 revert deleted graph-plugin-types/platform-version.ts, breaking graph-sdk + graph-plugin-services-client builds; FIXED 2026-08-03 by porting PlatformMajorVersion/resolvePlatformVersion from GRAPH-3361 sibling worktree
- [graph_sdk_logger_migration.md](./graph_sdk_logger_migration.md) — GRAPH-2736: graph-plugin-sdk migrated Logger (@logtape) to GraphLogger (@graph/logging); CommandOptions.logger stays optional + assertLoggerPresent guard due to graph-cli command-action.ts wrapper composition; notes pre-existing unrelated lint failures
- [jira_GRAPH-2467.md](./jira_GRAPH-2467.md) — GRAPH-2467: distribute platform deps (lit, SWC, @graph/platform-exports) as tarballs via graph-sdk install; 5-phase plan in resilient-hatching-glacier.md
- [jira_GRAPH-2736_platform_minor_versioning.md](./jira_GRAPH-2736_platform_minor_versioning.md) — GRAPH-2736: install-time platform dep provisioning now keyed by major.minor (not major-only); server-side discovery filter stays major-only per GRAPH-3363
- [sdk_milestone_reorg.md](./sdk_milestone_reorg.md) — SDK epics reorganized into 4 value milestones; GRAPH-1271 catch-all being split; created GRAPH-2457 (Project Scaffolding) + GRAPH-2458 (Package Submission)
- [sdk_velocity_roadmap.md](./sdk_velocity_roadmap.md) — SDK delivery velocity; SDK-only throughput collapsed to ~5 pts/sprint vs ~16-19 whole-team; don't use team velocity for SDK timelines

- [project_graph_sdk_confluence_review.md](./project_graph_sdk_confluence_review.md) — On `git pr merge`, Claude auto-reviews the Plugin Developer Guide if graph-sdk changed and files a Jira if doc updates needed
- [jira_GRAPH-1335.md](./jira_GRAPH-1335.md) — GRAPH-1335: install command integration tests; adapt test-plugins fixtures for symlink/tsconfig/recursive-dep cases
- [jira_GRAPH-1336.md](./jira_GRAPH-1336.md) — GRAPH-1336: extract shared integration test utilities; blocked by 5 stories, defer until all done to extract real patterns
- [jira_GRAPH-1472.md](./jira_GRAPH-1472.md) — GRAPH-1472: submit command integration tests; use @test namespace plugins for staging submissions
- [jira_GRAPH-1497.md](./jira_GRAPH-1497.md) — GRAPH-1497: fix dev command default graphUrl fallback to production firefly.adobe.com endpoint (dev.ts:101)
- [jira_GRAPH-1498.md](./jira_GRAPH-1498.md) — GRAPH-1498: install skips tsconfig.json for plugins with no dependencies (install.ts:75-78 early return)
- [jira_GRAPH-1499.md](./jira_GRAPH-1499.md) — GRAPH-1499: build distDir wrong when ancestor dir is named 'src' (project-plugins.ts:215 String.replace first-match bug)
- [jira_GRAPH-1516.md](./jira_GRAPH-1516.md) — GRAPH-1516: integration tests for 401/403 auth failures in submit+install; creates withBadToken() helper
- [jira_GRAPH-1517.md](./jira_GRAPH-1517.md) — GRAPH-1517: integration tests for POST /plugins rejection cases (bad manifest, NoScopeFound, 424 dep not resolved)
- [jira_GRAPH-1518.md](./jira_GRAPH-1518.md) — GRAPH-1518: integration tests for PATCH /plugins/{id} failures (409 DepsNotAvailable, 400 FilesNotUploaded, re-submit)
- [jira_GRAPH-1519.md](./jira_GRAPH-1519.md) — GRAPH-1519: integration tests for install remote dep resolution failures (404, non-Available, auth); depends on GRAPH-1516
- [jira_GRAPH-1520.md](./jira_GRAPH-1520.md) — GRAPH-1520: integration tests for submit --status across all registry states (PendingUpload, Removed, PendingLocalization)
- [jira_GRAPH-1521.md](./jira_GRAPH-1521.md) — GRAPH-1521: integration tests for submit partial failure / orphaned PendingUpload recovery; may expose missing feature
- [jira_GRAPH-1522.md](./jira_GRAPH-1522.md) — GRAPH-1522: dedicated path-filtered CI workflow for graph-sdk; skips full monorepo rebuild, PR preview deploy, smoke tests for SDK-only PRs
- [jira_GRAPH-1525.md](./jira_GRAPH-1525.md) — GRAPH-1525: bug — graph-sdk submit prints "No plugins found" when targeting plugin by package name in core-nodes
- [jira_GRAPH-1568.md](./jira_GRAPH-1568.md) — GRAPH-1568: graph-sdk debug logs should include plugin name for plugin-scoped messages
- [jira_GRAPH-1601.md](./jira_GRAPH-1601.md) — GRAPH-1601: fix 9 structural pattern inconsistencies in graph-sdk/src/ from normalize audit (Groups 1–3, 5–10; Group 4 already done)
- [jira_GRAPH-1708.md](./jira_GRAPH-1708.md) — GRAPH-1708: bug — submit+plugin-service integration tests silently skip on CI; GRAPH_SDK_ACCESS_TOKEN secret never configured
- [jira_GRAPH-1726.md](./jira_GRAPH-1726.md) — GRAPH-1726: bug — prettier in devDependencies not bundled in published SDK; fix already staged locally
- [jira_GRAPH-1742.md](./jira_GRAPH-1742.md) — GRAPH-1742: bug — SDK template eslint.config.mjs imports @graph/eslint-plugin instead of @graph/sdk, requiring undocumented dep
- [jira_GRAPH-1746.md](./jira_GRAPH-1746.md) — GRAPH-1746: bug — graph-sdk install rewrites tsconfig.json with wrong whitespace, causing prettier lint failures
- [jira_GRAPH-1747.md](./jira_GRAPH-1747.md) — GRAPH-1747: security bug — graph-sdk prints Authorization bearer token in error output; must redact before any logging
- [jira_GRAPH-1749.md](./jira_GRAPH-1749.md) — GRAPH-1749: bug — graph-sdk template adds eslint.config.mjs with eslint/config dependency but doesn't ensure it's installed; build fails
- [jira_GRAPH-1761.md](./jira_GRAPH-1761.md) — GRAPH-1761: add assertIsInDevPluginManifest to extract-plugin.ts (wick naming + dep completeness) and changelog length validation to submit.ts
- [jira_GRAPH-1763.md](./jira_GRAPH-1763.md) — GRAPH-1763: bug — graph-sdk install leaves stale tsconfig.json path entries and .plugin-dependencies symlinks when deps removed from manifest.json
- [jira_GRAPH-1769.md](./jira_GRAPH-1769.md) — GRAPH-1769: Graph SDK CLI progress logging 'action plugin N of total plugin-name' for all commands; 2.1 pts, Epic GRAPH-1271
- [jira_GRAPH-1787.md](./jira_GRAPH-1787.md) — GRAPH-1787: bug — graph-sdk dev command runs build validation on startup; should skip it so dev server starts immediately
- [jira_GRAPH-1868.md](./jira_GRAPH-1868.md) — GRAPH-1868: derive platformVersion from create\*Plugin import path in graph-sdk; deprecate manifest.json platformVersion field
- [jira_GRAPH-1870.md](./jira_GRAPH-1870.md) — GRAPH-1870: sort tsconfig.json paths alphabetically before writing; single sort call in install.ts:156, 1.1 pts
- [jira_GRAPH-1874.md](./jira_GRAPH-1874.md) — GRAPH-1874: graph-sdk link command: add excludeLinksFromLockfile: true to pnpm-workspace.yaml; 2.1 pts, Epic GRAPH-1271
- [jira_GRAPH-1875.md](./jira_GRAPH-1875.md) — GRAPH-1875: add --switch-profile flag to graph-sdk login command to force IMS profile selection; 3-file change, 2.1 pts
- [jira_GRAPH-2089.md](./jira_GRAPH-2089.md) — GRAPH-2089: bug — graph-sdk submit blocks documentation-only changes; change detection doesn't classify doc.md edits as changes
- [jira_GRAPH-2198.md](./jira_GRAPH-2198.md) — GRAPH-2198: graph/no-globals ESLint rule; honors forPluginType, helper files inherit sibling plugin.ts, allowlist bucketed by Worker-vs-window runtime; ES built-ins never flagged; security allowlist excludes XMLHttpRequest et al.
- [jira_GRAPH-2501.md](./jira_GRAPH-2501.md) — GRAPH-2501: migrate GLSL shader #include resolver from sync XMLHttpRequest to fetch (core-nodes + ml-nodes); prerequisite for GRAPH-2198 rollout
- [jira_GRAPH-2129.md](./jira_GRAPH-2129.md) — GRAPH-2129: graph-sdk unlink command to reverse graph-sdk link and restore published SDK version; 2.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2158.md](./jira_GRAPH-2158.md) — GRAPH-2158: bump @graph-services/specs from 0.9.31 to 0.9.42 in graph-sdk package.json; 1.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2171.md](./jira_GRAPH-2171.md) — GRAPH-2171: graph-sdk install auto-adds doc.md to assets.internal in manifest.json if file exists; 2.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2196.md](./jira_GRAPH-2196.md) — GRAPH-2196: per-plugin-type tsconfig.json templates; node/datatype/utility/resource exclude DOM libs, widget retains; install.ts:131 selects by plugin.type; 2.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2207.md](./jira_GRAPH-2207.md) — GRAPH-2207: add 'info' command to graph-sdk CLI showing version, linked state, and target environment; 2.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2223.md](./jira_GRAPH-2223.md) — GRAPH-2223: update SDK README.md installation instructions to use full-path graph-sdk link instead of rush-pnpm link -g; 1.1 pts
- [jira_GRAPH-2242.md](./jira_GRAPH-2242.md) — GRAPH-2242: classify utility plugins as widget or node context via new createUtilityPlugin property; 3-PR migration, enforcement approach TBD; 3.1 pts
- [jira_GRAPH-2254.md](./jira_GRAPH-2254.md) — GRAPH-2254: error when no plugins found for a command; throw meaningful error when ProjectPlugin[] is empty; 2.1 pts
- [jira_GRAPH-2286.md](./jira_GRAPH-2286.md) — GRAPH-2286: add 'create' command to graph-sdk CLI; prompts for PluginType + category, scaffolds manifest.json + plugin.ts; 2.1 pts
- [jira_GRAPH-2296.md](./jira_GRAPH-2296.md) — GRAPH-2296: install command should prefer remote dependencies over local when available; --use-local-deps flag to override; filter list constrains which plugins are treated as local; 3.1 pts
- [jira_GRAPH-2302.md](./jira_GRAPH-2302.md) — GRAPH-2302: validate merged manifest via zPluginManifest strict schema in extractPlugin; branch select on type + .strict().safeParse(); covers unknown fields + name format; 2.1 pts
- [jira_GRAPH-2304.md](./jira_GRAPH-2304.md) — GRAPH-2304: Epic — Graph SDK public distribution for enterprise plugin authors; strategy TBD (public npm vs. admin UI download)
- [jira_GRAPH-2336.md](./jira_GRAPH-2336.md) — GRAPH-2336: update Plugin Developer Guide docs for per-plugin-type tsconfig lib selection (from GRAPH-2196); 1.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2504.md](./jira_GRAPH-2504.md) — GRAPH-2504: graph/no-module-scope-vars ESLint rule; flags ALL module-level decls in node plugin files; rule REGISTERED but NOT enabled in graph.strict (rollout split to GRAPH-2513/2514); PR #3039; 2.1 pts, Epic GRAPH-2462
- [jira_GRAPH-2506.md](./jira_GRAPH-2506.md) — GRAPH-2506: graph/no-undeclared-fetch-source ESLint rule; fetch() + Lit html src attrs must have origins in manifest.json fetchSources; 3.1 pts, Epic GRAPH-2462
- [jira_GRAPH-2503.md](./jira_GRAPH-2503.md) — GRAPH-2503: bug — graph-sdk unlink fails with BUILD ERROR; pnpm install exits code 1 and stderr is swallowed in spawnAsync
- [jira_GRAPH-2513.md](./jira_GRAPH-2513.md) — GRAPH-2513: remove module-level vars from 34 graph-plugins-core node plugins (10 core-nodes + 24 ml-nodes); depends on GRAPH-1571; 5.1 pts; follow-up to GRAPH-2504
- [jira_GRAPH-2514.md](./jira_GRAPH-2514.md) — GRAPH-2514: enable graph/no-module-scope-vars in graph.strict (one-line); depends on GRAPH-2513; 1.1 pts
- [jira_GRAPH-2636.md](./jira_GRAPH-2636.md) — GRAPH-2636: improve "patch" updateType error in submit to explain major/minor-only versioning; guard in submit.ts:205; 1.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2639.md](./jira_GRAPH-2639.md) — GRAPH-2639: parallelize graph-sdk build with p-limit; full impl already in lib/build.js, src/build.ts still sequential; p-limit missing from package.json; 3.1 pts, Epic GRAPH-1271
- [jira_GRAPH-2660.md](./jira_GRAPH-2660.md) — GRAPH-2660: graph/no-pluginconfig-fields-in-manifest ESLint rule; flags pluginConfig-only fields in source manifest.json; 2.1 pts, Epic GRAPH-2601
- [jira_GRAPH-2978.md](./jira_GRAPH-2978.md) — GRAPH-2978: bug — graph-sdk submit resolvePlugin omits platformVersionMajor, causing spurious major version bumps; Epic GRAPH-2458
- [jira_GRAPH-3361.md](./jira_GRAPH-3361.md) — GRAPH-3361: bug — graph-sdk dependency resolution ignores platform major; PR #3297; now ALSO hard-errors on any platform-major mismatch in the chain (breaks ml-nodes/core-nodes today, user-accepted); blocked end-to-end by [[jira_GRAPH-3363]]
- [jira_GRAPH-3593.md](./jira_GRAPH-3593.md) — GRAPH-3593: GRAPH-3361's own fix plan conflated pluginMajorVersion with platform major in resolveExternal(); verified fix (use requestingPlatformMajor) eliminates false "Platform version mismatch" errors; blocks GRAPH-2652
- [jira_GRAPH-3594.md](./jira_GRAPH-3594.md) — GRAPH-3594: CLOSED Cannot Reproduce — 3 TS errors don't exist on main (only on stale biddle/GRAPH-2652 branch); main's official canShuffle+utility-firefly-v1 approach avoids them
- [jira_GRAPH-3363.md](./jira_GRAPH-3363.md) — GRAPH-3363: graph-services -1 match-any-minor sentinel; CONFIRMED FIXED on stage+prod 2026-08-04, live-verified via ml-nodes install; blocked GRAPH-3361, now unblocked
- [jira_GRAPH-3159.md](./jira_GRAPH-3159.md) — GRAPH-3159: rescoped 2026-07-27 to "Add SDK license text to built SDK artifacts" (build-output layer, not raw src); no overlap with GRAPH-3264; Epic GRAPH-2601
- [jira_GRAPH-3264.md](./jira_GRAPH-3264.md) — GRAPH-3264: replaced verbose ADOBE CONFIDENTIAL header with short-form `// © YYYY Adobe...` header repo-wide (1231 files); confirmed no overlap with GRAPH-3159; Epic GRAPH-2601
- [jira_GRAPH-3352.md](./jira_GRAPH-3352.md) — GRAPH-3352: unify duplicated GitHub Actions build/release logic (build job, Playwright summary, smoke-test scaffolding, dead checkouts, release-notes table); 6-phase plan in ticket description; Epic GRAPH-2601
- [jira_GRAPH-3373.md](./jira_GRAPH-3373.md) — GRAPH-3373: bug — WidgetResizeControllerOptions.target return type wrongly narrowed (dropped null) by lint-cleanup commit ff2ec6192; restore null + `?? undefined` normalization
- [jira_GRAPH-3377.md](./jira_GRAPH-3377.md) — GRAPH-3377: bug — graph-ui widget-resize-controller.test.ts never runs under rushx test (vitest config gap); follow-up filed while fixing GRAPH-3373, unassigned/backlog
- [jira_GRAPH-3597.md](./jira_GRAPH-3597.md) — GRAPH-3597: Story, no Epic — bump core-nodes+ml-nodes @graph/* deps to latest (sdk 3.0.1→3.0.3 for GRAPH-3593 fix, eslint-plugin/graph-plugin-types/platform-exports also bumped); Blocks-links GRAPH-3593; Sprint 27, assigned paterson
- [jira_GRAPH-2736_platform_download_auth_gap.md](./jira_GRAPH-2736_platform_download_auth_gap.md) — GRAPH-2736: platform-bundle download had zero auth (no Bearer header, CDN redirect masqueraded as 200); fixed with pre-flight imsLogin + Bearer header + redirect detection; end-to-end auth against pr-3306 still unverified (no cached IMS creds)
- [adobe_copyright_header_policy.md](./adobe_copyright_header_policy.md) — Adobe Legal mandates 2 header templates: internal ADOBE CONFIDENTIAL vs. SDK license-grant for publicly-distributed code (legalwiki space)

## User

- [terminology_the_sdk.md](./terminology_the_sdk.md) — "the SDK" means 4 packages together: @adobe/graph-cli, @graph/plugin-sdk, @graph/sdk-common, @graph/plugin-compiler

## Reference

- [reference_graph_cli_sdk_split_architecture.md](./reference_graph_cli_sdk_split_architecture.md) — graph-cli/SDK split architecture doc lives at docs/graph-cli-sdk-split-architecture.md
- [reference_ims_self_serve_portal.md](./reference_ims_self_serve_portal.md) — Adobe IMS self-serve portal (OAuth client admin, e.g. project-graph-sdk-v1) is at https://imss.corp.adobe.com/
- [storypoint_calibration.md](./storypoint_calibration.md) — Story point correction history; read before estimating, append after user corrections
- [reference_homeassistant_ssh_access.md](./reference_homeassistant_ssh_access.md) — `ssh homeassistant.local` gives root shell on the live HA instance; local project dir is just a mirror for editing
- [reference_devsite_docs_onboarding.md](./reference_devsite_docs_onboarding.md) — How to onboard docs onto developer.adobe.com (DevSite/Gatsby+AdobeDocs GitHub org, CLA, Onboarding Tracker, #adobeio-devsite-onboarding)

## Feedback

- [feedback_jira_auth.md](./feedback_jira_auth.md) — Jira CLI requires sourcing ~/.env first (not auth.sh alone); auth.sh only sets npm vars
- [feedback_check_git_diff.md](./feedback_check_git_diff.md) — Check git diff before making changes: Always check git status and diff to understand the direction of the user's changes before modifying files
- [feedback_pre_completion_workflow.md](./feedback_pre_completion_workflow.md) — Run build, lint, tests in every touched package before finishing any code task; create tests if none exist
- [feedback_jira_mcp_storypoints.md](./feedback_jira_mcp_storypoints.md) — jira_update MCP silently fails for story points; use curl with jira CLI bearer token instead
- [feedback_eslint_disable_comments.md](./feedback_eslint_disable_comments.md) — eslint-disable comments must include an inline justification after the rule name: `// eslint-disable-next-line <rule> -- <reason>`
- [feedback_jira_wiki_markup.md](./feedback_jira_wiki_markup.md) — jira CLI requires Jira wiki markup directly; does NOT convert Markdown
- [feedback_jira_bug_environment_field.md](./feedback_jira_bug_environment_field.md) — GRAPH Bug issue type requires native "environment" field; jira CLI --custom can't set it, use REST API instead
- [feedback_cli_link_state_isolation.md](./feedback_cli_link_state_isolation.md) — Fully clean one CLI's link/install artifacts before testing another on the same project; overlapping symlinks produce spurious TS2719 errors
- [feedback_comment_style.md](./feedback_comment_style.md) — Never use `//` comments; always use expanded `/** */` blocks (own lines); enforced via custom ESLint rule in graph-sdk-common (4 SDK packages)
- [feedback_ha_core_restart.md](./feedback_ha_core_restart.md) — Don't ask before restarting HA Core on homeassistant.local; just do it (still back up + `ha core check` first)
- [feedback_pr_creation_use_skill.md](./feedback_pr_creation_use_skill.md) — Always use pr-summary/open-pr skill for PRs in project-graph; ad hoc `gh pr create` misses the required `[GRAPH-XXX]` title + ticket-in-body CI check
- [feedback_separate_if_blocks.md](./feedback_separate_if_blocks.md) — Split OR'd guard/assert conditions into separate if blocks (one throw each) for debuggability
- [feedback_verify_ticket_fix_plans_live.md](./feedback_verify_ticket_fix_plans_live.md) — A ticket's confidently-cited root cause/fix plan can still be wrong; live-test against the real service (not just mocks) before trusting prescribed values verbatim
