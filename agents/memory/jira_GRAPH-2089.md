---
name: GRAPH-2089
description: GRAPH-2089: graph-sdk submit blocks documentation-only changes because they are not detected as a change
type: project
originSessionId: fa463c74-573e-4fc2-a243-8307cd639770
---
GRAPH-2089: `graph-sdk submit` blocks documentation-only changes (e.g., `doc.md`-only edits) because the change detection logic does not classify documentation files as changes. Submit skips or errors when only docs changed; it should proceed normally.

**Why:** Documentation updates are valid publishable changes and should not require a code diff to proceed.

**How to apply:** When implementing, look at the submit change detection logic and ensure documentation files (at minimum `doc.md`) are included in the diff check, or bypass change detection entirely for doc-only diffs.
