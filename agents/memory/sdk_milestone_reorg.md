---
name: sdk-milestone-reorg
description: SDK epics reorganized into 4 value milestones (from milestones.md); GRAPH-1271 was a catch-all being split
metadata: 
  node_type: memory
  type: project
  originSessionId: 7dace58b-2911-45a4-938d-11d5476f9dbc
---

The Graph SDK roadmap is organized around 4 value milestones defined in `milestones.md` (repo root). GRAPH-1271 (DX Enhancements) had become a catch-all dumping ground; we are splitting its work + 5 orphaned stories into the right milestones.

**The 4 milestones (priority):**
1. **Stability & Distribution** (Critical) — epics: GRAPH-1263 (Integration Testing, 27.1 pts), GRAPH-2461 (SDK release, quality & distribution). GRAPH-2461 absorbed GRAPH-2304 (public distribution) on 2026-06-09 — GRAPH-2304 closed as Done/superseded, not enough scope for two epics. GRAPH-2461 holds: GRAPH-2465 (3.1, pre-merge checklist w/ graph-core-plugins regression), GRAPH-2467 (3.1, bundle SDK runtime deps), GRAPH-2466 (distribution mechanism, strategy TBD/unpointed — carries forward GRAPH-2304's goals/scope/open-questions; split into real stories once npm-vs-admin-UI strategy is chosen), plus codebase-maintainability stories moved from GRAPH-1271: GRAPH-1315 (2.1 CLI factory refactor), GRAPH-1572 (1.1 getProjectPlugins remote-dep option), GRAPH-1868 (2.1 derive platformVersion). GRAPH-2461 scope now explicitly includes "SDK codebase maintainability". Pointed total ~11.5.

GRAPH-646 (8.1, enable @typescript-eslint/no-unsafe-type-assertion as error) was REMOVED from GRAPH-2461 on 2026-06-09 and had its SDK component stripped — it's a whole-graph-repo change, not SDK-specific, and shouldn't gate SDK milestones. Now fully decoupled: no epic, no component; needs a non-SDK home.
2. **Plugin Development Guardrails** (High) — epics: GRAPH-1205 (IMS auth, 17.6 pts), GRAPH-116 (Plugin test framework, needs breakdown), GRAPH-2462 (Dev-time guardrails, seeds GRAPH-2198 5.1 + GRAPH-2302 2.1 — created 2026-06-09). GRAPH-2243 (Plugin security) DROPPED from SDK calc 2026-06-09 — its SDK-relevant work (restricting globals) is delivered via GRAPH-2462; it has no SDK component and is linked to GRAPH-2462. Do not count it in SDK roadmap totals.
3. **Plugin Localization** (Medium) — epics: GRAPH-670 (Phase 2, 16.5 pts), GRAPH-1478 (Phase 1, needs breakdown).
4. **Polish & Refinement** (Medium) — GRAPH-1271 slimmed to ~8 true DX-polish stories; docs stories GRAPH-2161/1916/1771 were moved to GRAPH-645, then COMPLETED + removed (they were SDK-change followups); GRAPH-645 now empty/unscoped, moved to Graph 1.0 GA milestone with dates cleared (2026-06-09); plus two new epics created below.

**Created 2026-06-09:**
- **GRAPH-2457** — Project Scaffolding (seed: GRAPH-2286 'new' command). Depends on Package Submission (GRAPH-2458). Pulled forward 2026-06-09 to Aug 3 → Aug 14, fixVersion Public Beta (Aug), right after GRAPH-2458 finishes ~Jul 31.
- **GRAPH-2458** — Package Submission (seeds: GRAPH-2296, GRAPH-2171, GRAPH-2128). Priority Major ("next most important" per user 2026-06-09). **Blocked by GRAPH-1675** (Package Support — server-side package entity in Plugin Service, owner Lisa Han, epic GRAPH-1646; unestimated/New/no dates). PLANNING ASSUMPTION (user 2026-06-09): assume GRAPH-1675 is ready by the time GRAPH-2461+2462 finish (~Jul 10), so GRAPH-2458 pulled forward to Jul 13 → Jul 31, fixVersion Public Beta (July). Blocked-by link kept; if 1675 slips past early July, 2458 slips with it. (User chose to leave 1675 with Plugin Service team, not escalate directly.)

**Still TODO:** break down empty-shell epics GRAPH-116 / GRAPH-1478 (need product scope input); decide SDK distribution strategy (npm vs admin-UI) then split GRAPH-2466 into real stories. All mechanical re-parenting is complete.

**Velocity context:** see [[sdk-velocity-roadmap]]. SDK-only throughput has fallen to ~5 pts/sprint (team shifted off SDK); whole-team velocity is ~16-19 pts/sprint. 54.2 pts remained across GRAPH-1271+1263 before this reorg.
