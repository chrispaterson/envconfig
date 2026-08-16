---
name: jira-graph-3363
description: "GRAPH-3363: bug — graph-services discovery endpoints must accept platformVersion: -1 as a match-any-minor sentinel; CONFIRMED FIXED on stage+prod 2026-08-04"
metadata:
  node_type: memory
  type: project
  originSessionId: dd0c813d-8bb0-470a-b2fd-5dbd7a350e6d
  modified: 2026-08-04T23:08:38.722Z
---

Filed 2026-07-30 while implementing [[jira_GRAPH-3361]]. Component: Plugin Service. Unassigned, not in sprint. Linked as **blocks** GRAPH-3361. Title/description revised three times (2026-07-30 x2, 2026-07-31) — current title: "Plugin discovery endpoints must accept platformVersion: -1 as a match-any-minor sentinel."

**The principle:** platform major is the only real compatibility boundary between a plugin and the platform. Platform minor versions are additive, backwards-compatible — a plugin never needs to be republished when minor advances. The discovery endpoints (`plugins.resolve` single + batch, `GET /plugins` list) should never filter by minor, only by major equality.

**Agreed convention (2026-07-31, after talking to the Plugin Service team):** rather than omitting `platformVersion` (silently defaults to `1` server-side, not "unrestricted") or sending `0` (hits a real SQL-vs-controller inconsistency, see below), `graph-sdk` now always sends an explicit **`platformVersion: -1`** as a sentinel meaning "match on major only." Shipped client-side in PR #3297 (`plugin-service.ts`'s `PLATFORM_MINOR_MATCH_ANY` constant, sent unconditionally by `resolvePlugin`/`listPlugins`/`batchResolvePlugins`). **Server side is what GRAPH-3363 now tracks.**

**What the server needs to do (currently doesn't):**
- **Schema**: `zResolvePluginQuery`/`zResolvePluginsQuery`/`zListPluginsQuery` all use `platformVersion: z.coerce.number().pipe(z.int().gte(0)).optional()` — `gte(0)` rejects `-1` outright with a 400. Needs to allow `-1`.
- **SQL layer** (`base.ts`'s `findHighestVersion`, `views.ts`'s `findLatestAvailable`): currently skips the minor filter only when `platformVersion.minor` is falsy (i.e. `0`, by JS-truthiness accident). Needs to also treat `-1` as "skip filter."
- **Controller layer** (`plugins-resolve.ts`, `index.ts`'s `listPlugins`): re-checks `resolvedPlatformVersion > requestedPlatformVersion` after the SQL query. An explicit `-1` needs to bypass this check entirely, never causing a 404.

**Confirmed live against stage** (before the `-1` decision): `{ pluginName: "@adobe/datatype-number:1", platformVersion: { major: 1, minor: 0 } }` → 404, even though the same plugin resolves with no filter at all — proved the controller's ceiling check, not the SQL layer, blocks `minor: 0`. Also confirmed omitting the field defaults to `minor: 1` in both layers (not unrestricted) — silently excludes anything published at minor 2+.

**CONFIRMED FIXED on both stage and prod (2026-08-04).** Raw HTTP check: `platformVersionMajor=1&platformVersion=-1` → 200 OK on both environments; `platformVersion=0` → still 404 on both (unchanged, as expected — confirms the server specifically special-cased `-1`, not a broader change). Full `graph-sdk install` against `ml-nodes` (graph-plugins-core) on both environments: resolution itself now succeeds end-to-end with no 400s/404s from minor-version handling. Installs now correctly stop only at genuine [[jira_GRAPH-3361]] platform-major chain mismatches (the intentional hard error) — e.g. stage: `node-rgbx` (major 2) → `datatype-image` (major 1); prod: `node-object-stitch` (major 2) → `widget-image` (major 1). Those are real, separate, unmigrated-ecosystem failures, not a GRAPH-3363 regression. Comment posted to the ticket with this confirmation; not resolved/closed (left to the Plugin Service team's own workflow).
