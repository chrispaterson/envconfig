---
name: feedback_jira_no_cross_issue_refs_in_body
description: Never write inter-issue relationships in Jira body text; use Jira links/Epic Link instead
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5cf26d35-aaaf-4fe8-80ed-b9fe25712158
  modified: 2026-09-04T23:21:43.037Z
---

Never mention the relationship between issues in a Jira description (Story/Epic/Bug/anything): no other issue keys, no "blocks / blocked by / child of / superseded by / see Epic GRAPH-1234 / child Stories A–H" prose.

**Why:** those relationships belong in Jira's native features (Epic Link, issue links like Blocks/Relates), which are flexible, changeable, and rendered by Jira's UI. Prose copies drift out of sync and leave people unsure which place to implement/trust.

**How to apply:** Express structure with Jira links/Epic Link, not prose. Keep each description self-contained about *its own* work. Historical/context references to other tickets also go in as links, not body text. Example: on the GRAPH-4114 epic + child stories, the harness/parity/child relationships are all links; bodies name no keys. Codified in the createjira skill ("Cross-issue references"). Relates to [[jira_GRAPH-4056]].
