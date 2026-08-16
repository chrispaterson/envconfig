---
name: jira-graph-2286
description: "GRAPH-2286: add 'create' command to graph-sdk CLI for scaffolding new plugins (prompt for PluginType + category, generate manifest.json + plugin.ts)"
metadata: 
  node_type: memory
  type: project
  originSessionId: c7b0657f-4172-4668-b898-3b235238d3e5
---

GRAPH-2286: add `graph-sdk create` CLI command that prompts for PluginType and category, then scaffolds `manifest.json` and `plugin.ts` in the `src/` directory.

**Why:** Plugin authors currently have to hand-write boilerplate manifest and plugin.ts files; a create command reduces setup friction and ensures correct structure from the start.

**How to apply:** Command follows the same structure as `list-plugins.ts` + cli.ts registration. Uses `inquirer` (already a dependency, used in `submit.ts`) for prompts. Templates go in `templates/plugins/` — need manifest.json and per-type plugin.ts scaffolds for all 6 plugin types. Only `datatype` has an existing fixture (`default-datatype-plugin.ts`); the rest need to be authored.

Epic: GRAPH-1271
Points: 2.1
Status: New (not in sprint)
