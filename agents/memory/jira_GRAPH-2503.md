---
name: GRAPH-2503 — graph-sdk unlink fails with BUILD ERROR (exit code 1)
description: Ticket memory for GRAPH-2503: decisions, context, and origin notes
type: project
---

# GRAPH-2503 — graph-sdk unlink fails with BUILD ERROR (exit code 1)

**Type:** Bug
**Created:** 2026-06-11
**Epic:** GRAPH-1271 — SDK Developer Experience (DX) Enhancements

## Origin

Reported via Slack by patricio (patriciog/generative_harmonization) running `graph-sdk unlink` in `ml-nodes`. The command exits with code 1 and a BUILD ERROR with no actionable diagnostic — the real pnpm error is swallowed because `spawnAsync` in `link.ts` sets `stdio: ['ignore', 'pipe', 'pipe']` but never reads the stderr pipe. Two fixes needed: surface stderr in the error output, and investigate why `pnpm install` fails in the consumer project during unlink (likely bad `link:` paths in the generated `pnpm-workspace.yaml`).

## Decisions
<!-- Newest first -->

### 2026-06-11 — Bug filed from Slack report
Reported by a user in ml-nodes; error trace points to `link.js:20` (the `spawnAsync` close handler). Root cause investigation delegated to implementer — the stderr-swallowing issue is confirmed structural, but the exact pnpm failure reason requires running with stderr surfaced.
