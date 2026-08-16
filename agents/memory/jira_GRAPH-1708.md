---
name: GRAPH-1708 — graph-sdk integration tests silently skip on CI due to missing GRAPH_SDK_ACCESS_TOKEN
description: Ticket memory for GRAPH-1708: decisions, context, and origin notes
type: project
---

# GRAPH-1708 — graph-sdk integration tests (submit, plugin-service) silently skip on CI due to missing GRAPH_SDK_ACCESS_TOKEN

**Type:** Bug
**Created:** 2026-04-24
**Epic:** GRAPH-1263

## Origin
Discovered while wiring up GitHub Actions CI for graph-plugins-core (GRAPH-1557). Investigation revealed that GRAPH_SDK_ACCESS_TOKEN has never been configured as a secret in the graph repo, so the submit and plugin-service integration test suites silently skip on every CI run via describe.skipIf(!accessToken). The GRAPH_SDK_TEST_* credentials only exist in developers' local .env.test.local files and have never been added to any CI secret store.

## Decisions
<!-- Newest first -->

### 2026-04-24 — Initial discovery
submit.test.ts and plugin-service.test.ts both use describe.skipIf(!accessToken), giving a false-green CI signal with zero registry coverage. Needs a technical account or rotated IMS token secret (GRAPH_SDK_ACCESS_TOKEN) to unblock — password-grant credentials (GRAPH_SDK_TEST_*) are the local-dev-only mechanism and are not suitable for CI without being added as secrets.
