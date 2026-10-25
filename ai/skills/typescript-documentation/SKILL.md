---
name: typescript-documentation
description: "Create, review, and improve concise, accurate English TSDoc/JSDoc comments in TypeScript code. Use when documenting or refactoring documentation for functions, methods, classes, interfaces, types, properties, callbacks, public APIs, and internal modules in TypeScript projects (NestJS, Hono, Angular, React, Node.js, libraries). Apply balanced documentation: minimal for obvious internal code, fuller contracts for public or complex behavior."
---

# TypeScript Documentation

Produce useful, maintainable documentation that explains contracts, behavior, constraints, and side effects without narrating implementation details.

## Workflow

1. Inspect the declaration, types, implementation, callers, and nearby conventions when available. Distinguish verified behavior from assumptions.
2. Determine audience and visibility: internal helper, complex internal API, or exported/public contract. Do not infer that `export` always means externally supported public API.
3. Decide whether a comment is useful at all. Omit redundant comments on self-explanatory internal code unless the user explicitly asks to document it.
4. Create or revise the comment in technical English, preserving accurate existing information and project-specific conventions.
5. Verify every claim against available code. If context is insufficient, avoid unverified claims and mention what cannot be established.
6. Return the revised code/comment requested; briefly explain meaningful changes when reviewing. Do not modify runtime behavior merely to improve documentation.

## Style rules

- Prefer a short third-person summary stating what the declaration does or guarantees, not how it executes. Use clear, consistent terminology.
- Keep summaries and tags concise. Add a second paragraph only for non-obvious contracts, constraints, lifecycle, security, concurrency, or observable side effects.
- Document parameter meaning, units, formats, constraints, mutation, and defaults when not obvious from types. Never restate types mechanically.
- Document return semantics, including `null`, absence, ordering, ownership, and async completion, only when meaningful.
- Document `@throws` only for intentional, relevant errors verified from the implementation or contract; do not claim exhaustive exceptions.
- Describe side effects such as modifying caller-provided arrays, I/O, persistence, external calls, or logging. Distinguish effects at wrapper creation from effects when a wrapped function later runs.
- Preserve generic parameters, overloads, and type-level behavior; explain complex constraints rather than paraphrasing syntax.
- Prefer TSDoc-compatible standard tags such as `@param`, `@returns`, `@remarks`, `@example`, `@typeParam`, `@deprecated`, and `@throws` when warranted. Use `@internal` and `@public` only if the project adopts those conventions.
- Avoid HTML formatting, boilerplate, `@author`, unnecessary `@version`, invented performance claims, and excessive `@example` blocks.
- Respect established repo style, lint rules, and documentation generators when they conflict with defaults. For React props, document non-obvious behavior at the interface/property where consumers need it; avoid duplicating across declarations.

## Documentation depth

- **Obvious internal declaration:** no comment or one concise sentence when needed.
- **Complex internal declaration:** summary plus key contracts and side effects; tags only when they add value.
- **Public API / library:** summary, relevant `@param` and `@returns`, and documented constraints, failures, side effects, examples when useful.
- **Types and interfaces:** describe the domain contract and only annotate fields whose meaning is not evident.
- **Classes and methods:** explain lifecycle, ownership, invariants, and observable behavior where relevant; do not repeat the class summary on each method.

## Review checklist

- Does each claim follow from available code or declared contract?
- Is it useful beyond identifier names and TypeScript types?
- Are mutable inputs, async timing, error behavior, and defaults represented correctly?
- Are tags supported and consistent with the project's documentation tooling?
- Does the comment remain true if implementation details change?
- Did the edit leave executable code unchanged unless specifically requested?

## Examples

### Internal wrapper with shared collectors

```ts
/**
 * Wraps models with usage tracking and configured execution limits.
 *
 * Wrapped calls append to `calls` and capture system prompts in
 * `systemPrompts` for subsequent leakage checks.
 *
 * @param models - Models to wrap.
 * @param calls - Mutable collector for recorded LLM calls.
 * @param systemPrompts - Mutable collector for captured system prompts.
 * @param config - Optional execution limits and overrides.
 * @returns A model set with metered wrappers.
 */
```

Use the second paragraph only if the underlying wrapper implementation confirms that collection occurs during calls. Do not claim timeout enforcement, temperature override behavior, or leakage detection itself without verifying the implementation.

### Self-evident helper

```ts
const isEmpty = (items: readonly unknown[]) => items.length === 0;
```

Do not add `/** Checks whether items are empty. */` unless repository conventions explicitly require comments.

### Domain contract

```ts
/** A date on the business calendar, without a time or time zone. */
type LocalDate = string;
```

Do not claim an ISO format or runtime validation unless it is guaranteed elsewhere.

## Output behavior

For generation requests, provide the documentation integrated with the supplied declaration when feasible. For reviews, give the corrected comment/code first and then a compact rationale. If a requested statement cannot be confirmed, explicitly flag the uncertainty rather than silently inventing it. Match the user's conversational language for explanations while writing comments in English by default.
