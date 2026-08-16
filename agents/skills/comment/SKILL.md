---
name: comment
description: Add comments to selected or referenced code following project conventions. Use when user asks to add, update, or improve code comments or TSDoc.
user-invocable: true
---

# Add Comments

Add comments to the selected or referenced code following project conventions.

## Guidelines

- **Use TSDoc formatting**: Add concise TSDoc to exported functions, classes, and types. Should provide a summary of the function's purpose and document parameters, return, and exceptions.
- **Explain why, not how**: Comments should capture rationale, invariants, and constraints. BAD: `const cost = 20; // set cost to 20`. GOOD: `const cost = 20; // match competitor pricing`.
- **Keep comments short and scannable**: Avoid long paragraphs. One line or a brief block is usually enough.
- **Clarify complex logic**: For non-obvious algorithms or tricky code, add brief comments (e.g. name the algorithm: "Fisher-Yates shuffle"). If code is too complex to explain easily, prefer refactoring over heavy commenting.
- **Use consistent terminology**: Match terms used elsewhere in the project (e.g. "cart" vs "basket").
- **Don't over-comment**: Focus on high-value areas. Let clear code speak for itself; skip comments for obvious lines.
- **Avoid redundant comments**: Never restate what the code already shows. BAD: `int age = 25; // Declaring age as 25`. GOOD: `int age = 25; // default for new users`.
- **Document parameters and type parameters by effect, not identity**: Never just restate what a parameter or type parameter is. Instead, describe how it affects the function's behavior. BAD: `@param id - The id`. GOOD: `@param id - Used to look up the record and validate ownership`.
- **Ensure comments match the code**: Remove or update any outdated comments; misleading comments are worse than none.

Apply comments to the code the user has selected or referenced. Keep additions minimal and purposeful.
