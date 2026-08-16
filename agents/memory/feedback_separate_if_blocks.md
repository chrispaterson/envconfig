---
name: feedback_separate_if_blocks
description: "Split OR'd guard/assert conditions into separate if blocks for debuggability"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 21b2fcf1-99b3-4d54-b9ad-d57c650d4fe7
  modified: 2026-07-28T23:10:38.992Z
---

In assertion functions and guard clauses, don't combine multiple checks into a single `if` with `||`-ORed conditions. Give each condition its own `if` block that throws/returns.

**Why:** A single OR'd condition makes it impossible to tell which check failed when debugging; separate blocks read more clearly and each failure is attributable.

**How to apply:** When writing type predicates, assertion functions, or validation guards, break compound `||` conditions into one `if` per check. Share a single Error instance if the message is the same.
