---
name: feedback-ha-core-restart
description: "Don't ask for confirmation before restarting Home Assistant Core on homeassistant.local; just do it"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: bd51c751-4db7-4fb0-a240-b20e271eca5f
  modified: 2026-07-23T05:03:51.367Z
---

Restart Home Assistant Core (`ssh homeassistant.local 'ha core restart'`) directly after applying config/automation/dashboard changes there — do not use AskUserQuestion to confirm first.

**Why:** User explicitly said "you don't need to ask me if you should restart the HA Core, just go ahead and do it" after being asked twice in one session. Still back up files before editing and run `ha core check` before restarting, but the restart itself doesn't need a confirmation gate.

**How to apply:** Applies specifically to this repo (`/Users/paterson/projects/homeassistant`) and the `homeassistant.local` SSH target. Still worth flagging notable side effects of a change in a text message before/while uploading, just don't gate the restart step behind a question.
