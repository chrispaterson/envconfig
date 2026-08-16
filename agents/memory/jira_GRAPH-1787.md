---
name: GRAPH-1787 — Graph SDK dev command should skip build validation on startup
description: Ticket memory for GRAPH-1787: decisions, context, and origin notes
type: project
---

# GRAPH-1787 — Graph SDK dev command should skip build validation on startup

**Type:** Bug
**Created:** 2026-04-30
**Epic:** none

## Origin
Created directly by user to track the observation that the `dev` command runs build validation on startup — unnecessary for an active development workflow where errors surface naturally through the file watcher. Blocking startup on validation adds latency without benefit.

## Decisions
<!-- Newest first -->

### 2026-04-30 — Bug filed
Assigned to paterson and added to Graph Sprint 20 (216219). No Epic linked — standalone SDK bug. Fix should remove or skip the build validation step in the `dev` command startup path.
