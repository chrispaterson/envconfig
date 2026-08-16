---
name: Pre-completion quality workflow
description: Always run build, lint, tests, and format in every touched package before finishing a code task
type: feedback
---

Before finishing any code writing task, run in every touched package:
1. `rushx build` — verify TypeScript compiles
2. `rushx lint` — verify no ESLint violations
3. `rushx test` — run unit tests; create tests first if none exist for new code
4. Formatting is automatic via the auto-format.sh PostToolUse hook

**Why:** User wants reliable quality gates enforced consistently across all packages, not just optional validation.

**How to apply:** This is a hard requirement, not optional. Do not consider a task done until all three steps pass in every package touched. If tests don't exist for code you wrote, write them before running.
