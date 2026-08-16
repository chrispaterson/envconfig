---
name: jira-graph-2736-platform-minor-versioning
description: "GRAPH-2736 install-time platform dependency provisioning now keyed by exact major.minor, not major-only"
metadata:
  node_type: memory
  type: project
  originSessionId: a0d2c4d9-4bd6-43dd-ae74-68281362aec8
  modified: 2026-08-01T00:20:52.195Z
---

GRAPH-2736 (branch `paterson/GRAPH-2736/migrate-sdk-subcommands-versioned-bundles`): `graph-cli install`'s
platform-dependency provisioning (in `@graph/plugin-sdk`'s `platform-provision.ts` + `commands/install.ts`) was
originally spec'd (see `docs/superpowers/specs/2026-07-27-npm-driven-platform-dependency-install-design.md`) to
bucket the shared `.platform-dependencies/<dir>/node_modules` install by platform **major only** — all plugins
on the same major shared one install regardless of minor.

**Why:** User corrected this 2026-07-31 — minor must also be honored. Reasoning: a plugin declaring a higher
minor may depend on platform additions a lower-minor install doesn't have, so sharing one install across minors
under the same major is unsafe.

**How to apply:** The directory/package key changed from `<major>` to `<major>.<minor>` throughout
`platform-provision.ts` (`provisionPlatformMajor` → `provisionPlatformVersion`, `buildPlatformPackageJson` now
takes a full `PlatformVersion`) and `commands/install.ts` (dedup Map keyed by the new `platformVersionDirName()`
helper instead of a `Set<number>` of majors). Design spec doc updated to match. This is scoped to **local
install-time provisioning only** — it does NOT touch the separate, deliberately major-only server-side discovery
filter in `graph-plugin-services-client/plugin-service.ts` (`PlatformMajorVersion`), which stays major-only per
[[jira_GRAPH-3363]] (server-side minor filtering proved unreliable) — different concern, not revisited here.
