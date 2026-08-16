---
name: ESLint disable comment justification
description: Always include an inline justification when adding eslint-disable-next-line comments
type: feedback
---

Always append a justification after the rule name when writing `eslint-disable-next-line` comments:

```ts
// eslint-disable-next-line <rule> -- <explanation of why the suppression is safe/necessary>
```

**Why:** Makes suppressions self-documenting and reviewable; a bare disable comment gives no signal about intent.

**How to apply:** Every `eslint-disable`, `eslint-disable-next-line`, or `eslint-disable-line` comment must include ` -- <reason>` after the rule name(s).
