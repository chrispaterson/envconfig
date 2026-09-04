---
name: jira-graph-2736-branch-closeout-stories
description: GRAPH-2736 branch closeout — 3 new stories (4035/4036/4037) port remaining branch-ahead delta to main
metadata: 
  node_type: memory
  type: project
  originSessionId: 7c9b8ec1-e321-426a-ae51-955f9304f0ea
  modified: 2026-09-01T22:56:44.575Z
---

Closing out branch `paterson/GRAPH-2736/migrate-sdk-subcommands-versioned-bundles` requires landing its remaining branch-ahead delta into main. Most of the migration already merged via the GRAPH-3699/3708/3725/3731 phase stories (all marked Done), but three pieces were marked Done WITHOUT reaching main. Created 3 independent Stories under Epic **GRAPH-2601** (Enterprise Ready SDK) on 2026-09-01 to port them:

- **GRAPH-4035** — graph-cli cutover (CAPSTONE): delete migrated dead code (src/auth, src/logging, commands/{login,logout,list-plugins}, manifest-discovery, sdk-error, idempotent-value, project-utils, const/file-names), move @graph/plugin-sdk|sdk-common|graph-plugin-types deps→devDeps, flip rush.json `shouldPublish:true`. Supersedes dropped sub-task GRAPH-3729 (dropped 2026-08-24). Merge LAST.
- **GRAPH-4036** — graph-plugin-compiler: resolve tsc from plugin dir not project root (branch commit 21193cfce). Independent, land now.
- **GRAPH-4037** — graph-plugin-sdk: carry GRAPH-3593 fix (dependencyPlatformMajor = requestingPlatformMajor) into migrated project-plugins.ts. PR #3591. IMPORTANT: this is the real fix for `graph install` on main throwing "Platform version mismatch ... must share the same platform major" — graph-cli's index.ts imports install from @graph/plugin-sdk (not @graph/sdk), and only @graph/sdk's copy got PR #3374's fix; the plugin-sdk copy was never fixed on main. Rescoped 2026-09-01: smoke-test un-skip removed, split to GRAPH-4038.
- **GRAPH-4038** — graph-cli: un-skip AND green the vendored-npm platform-closure smoke test. Un-skip alone leaves it red (`entry.dir undefined`): closure now has an external entry (@graph-services/specs via @graph/plugin-compiler→@graph/eslint-plugin) carrying `resolveFrom` not `dir`; test must use `resolveClosureEntryDir` helper. Doesn't block PR CI (default vitest globs src only; integration config runs it). Not yet dispatched.

MERGED to main 2026-09-01 via merge queue (squash), capstone-last order: #3590 (4036), #3591 (4037), #3592 (4035, sha d45e8b3e9). Worktrees cleaned up, local branches deleted, integration worktree restored to GRAPH-2736 branch. main's `graph install` platform-major error is now fixed. Remaining: GRAPH-4038 (smoke test) + test-plugin updates (deferred).

Original plan — Merge order: 4036 + 4037 first → 4035 capstone → validate new graph-cli → then test-plugin updates (still deferred). Goal: make @adobe/graph-cli independently publishable = viable migration target away from @graph/sdk (graph-sdk NOT deleted). Each story dispatched to a `do` sub-agent that ports the slice onto a fresh branch off origin/main. Relates [[jira_GRAPH-2736_build_parity_bugs]], [[jira_GRAPH-2467]].
