---
name: Check git diff before making changes
description: Always check git status and diff to understand the direction of the user's changes before modifying files
type: feedback
---

When asked to fix tests or make changes, always check the git diff of modified files first to understand what direction the user's changes are going. If the user's changes reflect a clear intent (e.g., removing a parameter, simplifying a signature), fix surrounding code (like tests) to match that intent — do not undo the user's work to make tests pass.

**Why:** User removed the `directory` parameter from `getProjectRoot` and I undid that change to make the tests pass, reversing the user's explicit direction.

**How to apply:** Before changing any file in the git status, run `git diff <file>` to understand what the user changed and why. If tests fail because of the user's changes, update the tests to match the new behavior rather than reverting the user's changes.
