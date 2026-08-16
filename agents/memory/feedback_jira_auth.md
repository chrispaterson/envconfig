---
name: feedback_jira_auth
description: Jira CLI auth requires sourcing ~/.env before commands (not auth.sh alone)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9c26e632-2f6c-4a98-9737-7d38c2d6d818
  modified: 2026-08-03T18:40:42.427Z
---

Source `~/.env` before running `jira` CLI commands.

**Why:** Jira bearer credentials live in `~/.env`. `auth.sh` is unrelated — it only sets npm/artifactory keys.

**How to apply:** At the start of any session that uses the `jira` CLI, run `source ~/.env` first.

**Known gotcha (found 2026-08-03):** `~/.env` on this machine exports `JIRA_PAT_TOKEN`, but the `jira` CLI itself reads the standard `JIRA_API_TOKEN` env var. If the shell profile (outside `~/.env`) has a stale/expired `JIRA_API_TOKEN` already exported, sourcing `~/.env` does NOT override it (same var name, later `export` in a different file may or may not win depending on sourcing order) — the CLI silently authenticates with the stale token and every `jira issue view`/`search` 401s, while `jira me` (a local, no-network command) misleadingly appears to succeed. Direct REST calls using `$JIRA_API_TOKEN` (as in the jira-access skill's fallback section) have the same failure mode. **Diagnose:** if `jira issue view <known-issue>` 401s right after sourcing `~/.env`, run `env | grep -i jira` and compare `JIRA_API_TOKEN` against `JIRA_PAT_TOKEN` — if they differ, the stale one is winning. **Workaround:** `JIRA_API_TOKEN="$JIRA_PAT_TOKEN" jira ...` for a one-off, or fix the token-refresh script to export the name the CLI actually expects.
