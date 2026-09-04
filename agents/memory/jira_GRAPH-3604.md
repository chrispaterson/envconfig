---
name: jira-graph-3604
description: "GRAPH-3604 versioned platform bundle archival; DONE — prod live, bundles downloadable as of 2026-08-26"
metadata: 
  node_type: memory
  type: project
  originSessionId: 66e361c7-933f-4afc-b287-b10e503f45b1
  modified: 2026-08-26T23:27:40.179Z
---

GRAPH-3604 (filed by Sayash Kumar 2026-08-13, off a Slack design thread with Ben Delarre/Chris Paterson) covers how versioned SDK platform bundles survive from build storage through to prod, since every `platform.major.minor` must stay resolvable across all app versions, not just the latest deploy hash.

Design settled on:
- No IMS auth on the bundle endpoint — it's just type declarations (no runtime code), and Adobe doesn't gate static resources behind IMS for perf reasons; real access control is the SDK/dev-server refusing to resolve plugin deps without login.
- `/graph/platform/current/` — latest bundle per environment (PR/dev/stage/preprod/prod), updated every deploy.
- `/graph/platform/version/<major.minor>/` — immutable per-version archive, **prod only**, `graph.adobe.com` only (not firefly.adobe.com), published only during prod deploys. Overwrites of an existing version are explicitly allowed (reserves ability to patch).
- `/graph/platform/major/<major>` — floating, 302-redirects to the latest minor for that major, via a small mapping table (e.g. `{"1":"1.7","2":"2.17"}`) updated on each release.
- Filenames inside a version bundle keep their own package version suffix (e.g. `graph-cache-1.0.11.tgz`) rather than a constant name — Miguel Garcia's call, so you can identify package contents per platform version; ties to why `platform-closure.json` exists.

**Live-verified artifact shape (2026-08-25, curl + real SDK install against preprod graph.corp.adobe.com):** `/graph/platform/version/<major.minor>/` serves `platform-closure.json` (manifest: `[{name, tarball}]`) plus each closure package's tarball as its own file at that same path — e.g. `/graph/platform/version/2.17/graph-cache-1.0.11.tgz`. All unauthenticated (no Authorization header needed, confirmed via bare curl). **This is NOT a single combined `platform.tar.gz` archive** — that shape was a self-authored assumption (baked into this branch's own `common/scripts/pack-platform-bundle.mjs` / `stage-platform-tarballs.mjs` comments) that turned out not to match what graph-services actually deployed; `curl .../platform/version/2.17/platform.tar.gz` 403s (AccessDenied — object doesn't exist) on both preprod and prod. Don't trust this branch's own staging-script comments about the CDN shape without curling the real endpoint first.

Implementation split across two PRs (both by Miguel Garcia):
- `graph-services#443` — adds the CloudFront behaviors/function for `/version` and `/major` redirect.
- `graph#3442` — wires prod/preprod deploy to copy the build's platform bundle into the version archive and update the major→minor redirect table. Chris LGTM'd this 2026-08-25.

Rollout status as of 2026-08-25: verified working in preprod via curl (200 on version fetch, 302 redirects correct, 404 on unknown major) AND via a real `graph install` download of platform version 2.17 (7/7 real tarballs fetched, correct gzip bytes). Prod (`graph.adobe.com`) still 403'd as of 2026-08-25 ~5pm, pending Miguel's prod apply (Chris had already LGTM'd `graph#3442` that morning). Historical bundles were seeded manually (Chris built locally, sent `output-all.zip`, Miguel uploaded to S3). The v2.2 gap in history (repo jumped 2.1→2.3) was never a blocker.

**Update 2026-08-26 (direct correction from Chris):** prod rollout is done — bundles are downloadable now. Don't describe this as "pending" or frame the v2.2 gap as something being waited on; both were resolved/moot by this date. Treat the 2026-08-25 "still 403s" line above as historical, not current status.

**Why:** keeps this branch's staging scripts (`common/scripts/stage-platform-tarballs.mjs`, `.github/actions/build-and-upload/action.yml`) correctly scoped — they only produce and stage the bundle; the archival/redirect logic lives in graph-services infra, not this repo.

**How to apply:** when touching platform bundle staging/upload code in this branch, don't try to reimplement archival or version-redirect logic locally — that's owned by graph-services PRs #443/#3442. If asked about "why is v2.2 missing" or CDN redirect behavior, this is the source of truth. Before implementing an SDK client against this endpoint, curl the real deployed path first rather than trusting this repo's own staging-script comments — see [[feedback_verify_ticket_fix_plans_live]] (same lesson, this time the wrong "spec" was my own code, not a ticket). Relates [[jira_GRAPH-2736_platform_minor_versioning]].
