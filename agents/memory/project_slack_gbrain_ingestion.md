---
name: project-slack-gbrain-ingestion
description: "Recurring Slack→gbrain ingestion system — scripts, scheduled task, and the token-expiry gotcha"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9d518f67-6da7-42b0-abba-82ec2563812c
  modified: 2026-08-25T01:17:41.236Z
---

Slack is mirrored into gbrain as verbatim daily pages (`type: slack`): channels at `slack/<channel>/YYYY-MM-DD`, DMs at `slack/dm/<person>/YYYY-MM-DD`. Set up 2026-08-18.

**Toolkit:** `~/slack-ingest/` — `run-channels.sh` (slackdump, zero-LLM), `transform.py` (channel render), `dm_transform.py` + `render-dms.sh` (DM render, auto-detects connector block vs backfill line format), `import-to-ultra.sh` (rsync→Ultra + host `gbrain sync` + `extract links`), `dm-people.json` (12 DM targets), `users.json`/`user-overrides.json`. Authoritative doc: `~/slack-ingest/RECURRING.md`. The old `run-ingest.sh`/`HANDOFF-schedule.md` are STALE (pre-Postgres, single-channel, dead `~/paterson/brain` path).

**Sources:** channels prj-graph-core `C084XR5E92N`, prj-graph-plugins `C0ANK4FL49W`, prj-graph-noderunners `C0BHUBYUZDL`; 12 DMs (see dm-people.json).

**Schedule (since 2026-08-24 — channels only, zero-LLM):** launchd agent `com.paterson.slack-ingest-channels` (`~/Library/LaunchAgents/`) runs `cron-channels.sh` hourly at :17, weekdays 7am–7pm PT, rolling 14-day window, idempotent. This REPLACED the old Claude Code scheduled task `slack-to-gbrain-ingest` (now retired/disabled), which cost ~$12–27/run as a full agent. `cron-channels.sh` = lock + logging + PATH + once/day token-expiry desktop alert → `run-channels.sh` → `import-to-ultra.sh`. Logs in `~/slack-ingest/logs/`. **DMs dropped** (needed the MCP connector + an agent); DM pages go stale, `dm_transform.py`/`render-dms.sh`/`dm-people.json` kept but unused.

**Architecture:** slackdump auth + Slack MCP connector run on the MacBook; brain host ops run on the Ultra over SSH. slackdump CANNOT read Enterprise-Grid DMs (team_is_restricted) → DMs use the Adobe Slack MCP connector (`slack_read_channel` with user_id as channel_id; its server-id hash can change per session → resolve via ToolSearch). NEVER import via gbrain MCP `put_page` — MCP writes skip `people/*` mention-linking; must use file+rsync+`gbrain extract links --by-mention` on the host. Relates [[gbrain_two_machine_setup]].

**Gotcha:** slackdump `xoxc` token dies on Slack logout → `run-channels.sh` exits 4, `cron-channels.sh` logs it + fires a once/day desktop alert; no channels ingest until re-auth. Re-auth is Chris-only: pull xoxc token + `d` cookie from browser → `slackdump workspace import`. (Token was expired as of 2026-08-24 — needs re-auth before the job does anything.)

**Backfill done 2026-08-18:** core 176, plugins 52, noderunners 21, DMs 374 pages — imported/embedded/linked (910 slack pages total).
