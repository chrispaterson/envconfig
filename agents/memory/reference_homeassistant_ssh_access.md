---
name: reference-homeassistant-ssh-access
description: "How to access the user's live Home Assistant instance — ssh homeassistant.local gives root shell access"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 6180e34c-af40-499e-9d07-960195fe9421
  modified: 2026-07-23T22:08:46.020Z
---

The user's Home Assistant instance is reachable at `ssh homeassistant.local`. This logs straight into a root shell on the HA host — no separate user/sudo step, no key setup needed beyond what's already configured.

Use this for live actions on the real instance: checking `ha core check`/`ha core logs`, restarting core (`ha core restart` — see [[feedback_ha_core_restart]] for the no-confirmation-needed policy), inspecting `/config`, tailing logs, or verifying a change actually took effect on-device.

The local directory `/Users/paterson/projects/homeassistant` is a working copy/mirror of the HA root filesystem for editing config/automations/dashboards — edits made there still need to reach the live instance (sync or scp) and then a core restart/reload before they take effect.
