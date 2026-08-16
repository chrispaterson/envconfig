---
name: GRAPH-1335 — Add install command integration tests
description: Ticket memory for GRAPH-1335: decisions, context, and origin notes
type: project
---

# GRAPH-1335 — Add install command integration tests

**Type:** Story
**Created:** 2026-04-06
**Epic:** GRAPH-1263 — Graph SDK Integration Testing

## Origin
Created to extend the GRAPH-1263 integration test suite to cover the `install` command, which sets up `.plugin-dependencies/` symlinks and writes `tsconfig.json` path mappings for plugins with declared dependencies. Unit tests mock the filesystem so the real symlink/tsconfig pipeline is never exercised.

## Decisions

### 2026-04-06 — Use test-plugins fixtures
Adapt existing `plugins/test-plugins` fixtures rather than creating new ones from scratch — that's what they're there for. The recursive dependency test case in particular should reuse or lightly extend existing fixtures that already declare inter-plugin dependencies.
