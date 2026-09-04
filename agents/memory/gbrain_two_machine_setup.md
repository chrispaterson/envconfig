---
name: gbrain-two-machine-setup
description: "gbrain: brain host MOVED from M1 Ultra to the Mac mini (`ssh Mini`) — verified 2026-08-22. Postgres 17 + pgvector on the Mini; work MacBook REPAIRED 2026-08-22 and is now a direct Postgres client over a loopback SSH tunnel."
metadata:
  node_type: memory
  type: reference
  modified: 2026-08-23
---

gbrain architecture. **Host moved to the Mac mini** (user-confirmed 2026-08-22). The
Ultra-as-host description below it is history — do not act on it.

## Current host: Mac mini (`ssh Mini` → `Mini.local`, user `chrispaterson`)

Verified 2026-08-22 by direct probe:

- `gbrain status` → `Mode: local`, v0.46.21.0, `pages=1272`, `embed=100%`, last sync
  `2026-08-22T21:32:53Z`.
- `~/.gbrain/config.json`: `engine=postgres`,
  `database_url=postgresql://localhost:5432/gbrain`, `embedding_model=ollama:nomic-embed-text`
  (768d), `chat_model`/facts extraction `ollama:qwen38-27b`, `schema_pack=gbrain-base-v2`.
- Postgres 17 running from `/usr/local/...` (Intel brew prefix — the mini is Intel, so
  paths differ from the Ultra's `/opt/homebrew`).
- Brain repo `~/brain` on `main`, remote `https://github.com/chrispaterson/brain.git`.
- gbrain binary at `~/.bun/bin/gbrain` (bun shim — non-interactive SSH needs
  `export PATH="$HOME/.bun/bin:$PATH"` first, same quirk as the Ultra had).

## Status as of 2026-08-23 (MacBook repaired)

The thin-client design was **abandoned**, not fixed. Every machine is now a direct
Postgres client over a loopback SSH tunnel to the mini. Nothing serves HTTP on 3131
anywhere, and nothing needs to — items 1-3 of the old "known-broken" list were
artifacts of the retired thin-client design, not defects.

**Work MacBook — repaired 2026-08-22.** `io.gbrain.db-tunnel` runs
`ssh -N -L 127.0.0.1:5432:127.0.0.1:5432 Mini`; `~/.gbrain/config.json` is
`engine=postgres`; `gbrain whoami` → `{"transport":"local"}`. The old
`io.gbrain.tunnel` is parked in `~/Library/LaunchAgents/disabled/`. Verified working
**both on and off GlobalProtect VPN**. Full detail, including the two gotchas below,
in [[infra/macbook-gbrain-db-tunnel]].

- The MacBook's `database_url` **must name the role**:
  `postgresql://chrispaterson@localhost:5432/gbrain`. The username-less URL the Studio
  uses works there only because its OS user matches the DB role; the MacBook's OS user
  is `paterson`, so libpq would otherwise send the wrong role.
- Embedding runs on whichever machine holds the CLI, against `M1-Ultra.local:11434`.
  Reachable from the MacBook on VPN (IPv6/mDNS), so no local override is needed.

**Still open — the mini's `~/brain` merge conflict.** Re-verified 2026-08-23: still
`UU infra/home-service-status-page.md`, plus uncommitted edits to `computers/mac-studio.md`,
`people/ben-delarre.md`, `people/corey-lucier.md`, `people/jeremy-biddle.md`. Write-through
commits stay blocked until it is resolved, so **pages captured from any machine land in
Postgres but do not reach the git mirror.** Also still present: heavy taxonomy drift from
untracked top-level dirs not in `RESOLVER.md`.

**The Ultra's stale `~/brain` clone** — the mini's is ahead. Don't write to the Ultra's copy.

## History: the 2026-08-18 PGLite → Postgres migration (was on the Ultra)

PGLite is embedded single-writer Postgres — one process per data dir — so every harness
spawning its own `gbrain serve` got `database is already open`. Fixed by making one machine
the owner with real Postgres + pgvector and everyone else a client. That design still
stands; only the owner machine changed (Ultra → Mini).

Other durable details from that work: OAuth clients are minted on the host with
`gbrain auth register-client <name> --scopes "read write"`; the client secret must be passed
as the **flag** (not env) to `gbrain init --mcp-only ... --force` or it won't persist. Do
**not** `claude mcp add gbrain` — it collides with the `gbrain@gbrain` plugin's own entry.
ZeroEntropy reranker sunsets 2026-09-04 → `gbrain config set search.reranker.model
voyage:rerank-2.5` (needs VOYAGE_API_KEY; the mini's `voyage_api_key` is currently empty).

Brain repo credential quirk: global helper `credential.https://github.com.helper = gh`
serves the WORK account → "Repository not found" on the personal repo. Fix in
`~/brain/.git/config` with a URL-scoped empty helper entry ahead of
`store --file ~/.gbrain/git-credentials`.

See [[reference_vpn_lan_access]] — reaching `Mini.local` / `M1-Ultra.local` at all depends
on the IPv6/mDNS workaround while the work VPN is up.
