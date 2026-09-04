---
name: jira-graph-4026
description: "GRAPH-4026 Epic — enable agentic plugin development; developer-driven distribution only, no Adobe-run inference"
metadata: 
  node_type: memory
  type: project
  originSessionId: 94ca712a-2d5f-4bcc-b790-766be9d8b901
  modified: 2026-09-01T18:41:30.869Z
---

GRAPH-4026 "Enable Agentic Plugin Development for the Graph SDK" (Epic, component SDK, created 2026-09-01). Package/distribute agent guidance (skills, AGENTS.md/CLAUDE.md, MCP) so plugin devs direct their OWN agents to build compliant plugins.

**Core design principle (liability):** distribution must be pull-based / developer-initiated. Adobe never runs the developer's code through an Adobe/Firefly-hosted LLM. This is the direct mitigation of the make-docs/review-docs ThreatForge threats [[jira_GRAPH-3461]]-adjacent → GRAPH-2532 (source exfil), GRAPH-2533 (indirect prompt injection), GRAPH-2534 (malicious LLM-generated docs). Home-rolled "install + run skills" command is OUT for this reason.

**Baseline / minimum:** docs-site AGENTS.md = GRAPH-4025 (relates).

**Spike GRAPH-4027** under this epic evaluates 3 developer-driven mechanisms: (1) Agent Plugins agent-plugins.org, (2) skills-npm (antfu/skills-npm), (3) scoped AGENTS.md/CLAUDE.md. Criteria: cross-client portability, versioning to platform major/minor, install friction, always-loaded context cost, reuse by internal CI review job, maintenance. Prior art: firefly-graph-agent-plugin (first-pass branch), Adobe-DxE adobe-code-review plugin.

**Two use cases (from Slack C084XR5E92N thread):** proactive dev-enablement (THIS epic) vs defensive submission-review (Talos vs custom worker-manager LLM job; hard part = prod IMS/service-token/network, owned by graph-services). Shared artifact = the review/guidance skill. create-plugin scaffolding skill considered but deferred (outcome, not a distribution mechanism).
