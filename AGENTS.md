# Global Agent Guide

## Pre-Completion Checklist

Before considering any code writing task done, run the following in **every package or module you touched**:

1. **Build** — The project must compile without errors. Use the appropriate command for the project (e.g. `rushx build`, `npm run build`, `tsc`).
2. **Lint** — No lint violations. Fix any reported issues. (e.g. `rushx lint`, `npm run lint`).
3. **Test** — All unit tests must pass. If you wrote code that has no existing tests, write tests for it first, then run them. Update test assertions only if the behavior change was intentional. (e.g. `rushx test`, `npm test`).
4. **Comments** — Review all code you touched and ensure comments follow the comment skill guidelines:
   - TSDoc on all exported functions, classes, and types (summary, `@param`, `@returns`, `@throws` where applicable).
   - Explain *why*, not *how* — capture rationale, invariants, and constraints, not what the code already shows.
   - Brief comments on non-obvious algorithms or tricky logic; name the algorithm if applicable.
   - Remove or update any outdated comments; misleading comments are worse than none.
   - Don't over-comment — skip obvious lines, focus on high-value areas.
5. **Formatting** — Run the project formatter if one is configured. (e.g. `rush format`, `npm run format`, `prettier --write`).

If any step fails, fix the issue and re-run before finishing.
