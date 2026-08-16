---
name: sdk-velocity-roadmap
description: SDK delivery velocity analysis; SDK-only throughput collapsed to ~5 pts/sprint vs ~16-19 whole-team
metadata: 
  node_type: memory
  type: project
  originSessionId: 7dace58b-2911-45a4-938d-11d5476f9dbc
---

Velocity analysis done 2026-06-09 for SDK epic roadmap (story points = Jira customfield_10003; epic link = customfield_11800).

**Whole-team velocity** (all epics): ~16.5 pts/sprint over last 7 sprints; ~19.6 over sprints 19-21. Do NOT use this for SDK timelines — most recent velocity is non-SDK work.

**CAPACITY UPDATE (2026-06-09):** second engineer joining → multiply SDK per-sprint throughput by **1.5×** for planning. Blended planning pace ~12 → **~18 pts/sprint**. Also GRAPH-2458 Package Submission (5.2 pts) moved to a DIFFERENT TEAM — remove from our team's capacity/load (but it stays on the SDK roadmap; dependency GRAPH-1675 + its dates/links unchanged). LOCALIZATION (GRAPH-670 16.5 + GRAPH-1478 unscoped, ~27 pts total) expected to be handled MOSTLY by another team — model as ~75% off, ~25% (~7 pts) retained as placeholder. Epics kept in Jira at Graph 1.0 GA / Sep-Oct with ownership-flag comments; revisit when split confirmed.

NET capacity model (our team): ~100 pts on plate (96.5 pointed − ~20 loc offloaded + ~23 unscoped) vs ~175 capacity (~18/spr × ~9.7 spr) → ~75 pt buffer. Roadmap feasible before Nov GA. Core lane = 2461, 2462, 1263, 1205, 1271, 116, 2457.

**SDK-only throughput** (points of GRAPH-1271 + GRAPH-1263 stories completed per sprint, 2026):
- S18 ~23.7, S19 ~30.1, S20 ~8.5, S21 ~4.2, S22 ~5.2 → sharp collapse as team shifted off SDK.

**Remaining work** (pre-reorg): 54.2 pts across GRAPH-1271 (27.1) + GRAPH-1263 (27.1), plus 8 unpointed open stories (mostly docs). Timeline scenarios: recent pace (~5/spr) → early Nov 2026; blended (~12/spr) → late Aug; full-focus (~18/spr) → mid Jul.

**Roadmap field alignment (2026-06-09):** SDK epics scheduled via fixVersion + Target start/end. fixVersions are MILESTONE/release versions (Public Beta (July), Graph 1.0 GA (Nov 10), User Rampup (June)), NOT SDK 1.x — do not create SDK v1/v1.5/v2 fixVersions. Field IDs: Target start = customfield_25800, Target end = customfield_25801 (both date type, yyyy-mm-dd). Most SDK epics already had fixVersion+dates set by PM (don't clobber); only filled the 4 blanks (GRAPH-2462, 1478, 2458, 2457). GRAPH-2457 sequenced after GRAPH-2458 (scaffolding depends on submission).

**NOTE:** the "Public Beta" milestone fixVersion (id 327412) was renamed externally from "Public Beta (July)" to "Public Beta (Aug)" — beta slipped ~4 weeks later. Epics tagged by ID auto-updated; everywhere this file says "Public Beta (July)" now read "(Aug)". Extra runway before beta.

**RULE (user 2026-06-09):** fixVersion (milestone) MUST correlate with the epic's delivery/end date. Aligned all SDK epics accordingly: end ≤ mid-Aug → Public Beta (Aug) (id 327412); end Sep-Oct → Graph 1.0 GA (Nov 10) (id 327413). Fixed mismatches: GRAPH-1271, GRAPH-1205, GRAPH-116, GRAPH-645. No Sept/Oct milestone version exists, so Sept-Oct deliveries bucket into Graph 1.0 GA.

**Reprioritization (2026-06-09):** GRAPH-2461 + GRAPH-2462 set to Critical, scheduled Jun 8 → Jul 10 (current Sprint 23 + Sprint 24) as the must-do-soon pair (18.7 pts; needs ~9-10/spr = ~2× recent pace). The overlapping epics pushed to start Jul 13 (after the Critical pair): GRAPH-1271 (→Aug 3), GRAPH-1263 (→Aug 17), GRAPH-1205 (→Sep 14). Localization P1/P2 pushed OUT to AFTER public beta (2026-06-09): GRAPH-1478 P1 Sep 1-30, GRAPH-670 P2 Oct 1-31, both re-tagged Graph 1.0 GA (Nov 10) — relieves the Jul-Aug beta crunch. CONSEQUENCE/RISK: this cascade pushes most SDK work PAST the Public Beta (July) fixVersion they're still tagged to — fixVersions now lag the dates and need revisiting (likely move to Graph 1.0 GA) OR capacity added. Active sprint cadence: S23 Jun 8-20, S24 Jun 22-Jul 10.

**Top delivery risks:** (1) unscoped epics pinned to committed dates — GRAPH-116 (Sep), GRAPH-1478 (→Jul 15) — can't be planned. (GRAPH-2243 Plugin security dropped from SDK calc — covered by GRAPH-2462.) (2) Jun–Aug Public Beta window is densely overlapped (8 epics due Jul–Aug); cumulative team capacity is the real constraint, not any single window. (3) recent SDK pace ~5/spr vs ~12–15 needed to hit the roadmap.

Related: [[sdk-milestone-reorg]]. Jira CLI notes: [[feedback_jira_auth]], [[feedback_jira_mcp_storypoints]].
