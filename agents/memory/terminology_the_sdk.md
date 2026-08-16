---
name: terminology-the-sdk
description: "When the user says \"the SDK\" they mean 4 specific packages; \"legacy SDK\" means @graph/sdk"
metadata: 
  node_type: memory
  type: user
  originSessionId: 87a8352c-a61f-4ffe-85ce-fdfdc5b5af66
  modified: 2026-07-29T23:00:13.557Z
---

When the user refers to "the SDK" or "the sdk", they generally mean the set of four packages together, not a single package:

- `@adobe/graph-cli`
- `@graph/plugin-sdk`
- `@graph/sdk-common`
- `@graph/plugin-compiler`

**How to apply:** When asked to make changes, check parity, or investigate "the SDK", consider all four packages in scope unless the user narrows it to one explicitly. Relevant to ongoing work like [[jira_GRAPH-2736_build_parity_bugs]] and [[bundling_tsdown_bugs]], which already deal with cross-package parity among these four.

The "legacy SDK" is a separate, distinct package: `@graph/sdk`. Do not conflate it with the four packages above — when the user says "legacy sdk" they mean this one package specifically, likely for comparison/migration purposes against the current four-package SDK.

Full architecture details (roles, dependency graph, install/build sequence) are written up in `docs/graph-cli-sdk-split-architecture.md` at the repo root — see [[reference_graph_cli_sdk_split_architecture]]. Read that doc for authoritative detail rather than relying on this summary.
