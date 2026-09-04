---
name: reference-authsh-needs-env
description: "rush auth.sh silently needs `source ~/.env` first (ARTIFACTORY_API_KEY_CLOUD); without it rush update 401s/hangs"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 7853c301-0389-4a3c-ab05-aa159d902c17
  modified: 2026-09-02T17:50:49.085Z
---

In the `graph` monorepo, `source auth.sh` reads `ARTIFACTORY_API_KEY_CLOUD` and derives `NPM_AUTH_CLOUD` (used by `common/config/rush/.npmrc`). That key lives in **`~/.env`, NOT the shell profile**. So the correct order is:

```bash
source ~/.env && source auth.sh   # THEN rush update/build
```

If you run `source auth.sh` without `~/.env` first, `ARTIFACTORY_API_KEY_CLOUD` is empty; auth.sh prints a "Missing" warning (easy to miss if you redirect to /dev/null) and leaves `NPM_AUTH_CLOUD` empty → `rush update` / vendored `install-run-rush` fail with npm **E401** against artifactory-uw2, or (with the global rush) hang at 0% CPU. Cost two failed `rush update` runs on GRAPH-4046 before diagnosis.

Also: run rush under the repo's Node via `nvm use` (reads `.nvmrc`); the global `rush` shim can otherwise execute under a stale Node on PATH. Prefer `node common/scripts/install-run-rush.js <cmd>` to guarantee the pinned rush + current Node. Extends [[feedback_jira_auth]] (which covers ~/.env for the jira CLI).
