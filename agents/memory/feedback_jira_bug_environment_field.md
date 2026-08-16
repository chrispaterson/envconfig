---
name: feedback_jira_bug_environment_field
description: "GRAPH project Bug issue type requires native \"environment\" field that jira CLI --custom can't set; must create via REST API"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: cccf8da9-8799-4b7b-b6c0-a1713c5b19f7
---

`jira issue create -t Bug` in the GRAPH project fails with `environment: Environment is required.` (HTTP 400). `environment` is a native Jira field (not a customfield), so `jira-cli`'s `--custom` flag rejects it ("Invalid custom fields used in the command: environment") since it only handles fields registered as customfields in `~/.config/.jira/.config.yml`.

**Why:** Confirmed via `GET /rest/api/2/issue/createmeta/GRAPH/issuetypes/1` (issuetype id 1 = Bug) — `environment` shows up in the required-fields list alongside `summary`, `issuetype`, `reporter`, `project`. No CLI flag exists for it (checked `jira issue create --help`); `-e`/`--original-estimate` is a different field.

**How to apply:** When creating a Bug in GRAPH, skip the `jira` CLI and POST directly to `${JIRA_URL}/rest/api/2/issue` with `Authorization: Bearer ${JIRA_API_TOKEN}` (from `source ~/.env`), including `"environment": "<free text>"` in `fields`. Same request can set `customfield_11800` (Epic Link) in one shot, avoiding the separate Epic Link PUT workaround. Stories/Epics have not hit this in observed sessions — check `createmeta/GRAPH/issuetypes/<id>` first if a new issue type 400s with an unfamiliar required-field name.
