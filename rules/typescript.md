---
description: TypeScript and TSX conventions that hold in every repository
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.cts"
---

# TypeScript

## Functions

- Declare functions as arrow functions assigned to a `const`. Never use a
  `function` declaration or a `function` expression.

  ```ts
  export const parseUser = (raw: unknown): User => { ... }
  ```

  Not `export function parseUser(raw: unknown): User { ... }`.

- The one exception is where the language requires it: generator functions
  (`function*`) and code that genuinely needs hoisting or its own `this`.
- Methods inside a `class` or an object literal stay as methods. The rule is
  about standalone functions.

## Comments

- Write no code comments. If a line needs explaining, rename the variable or
  extract a named function until it explains itself.

  ```ts
  const isEligible = user.age >= 18 && user.verifiedAt !== null
  if (isEligible) { ... }
  ```

  Not `// check the user can vote`.

- Do not add JSDoc blocks, `// TODO`, `// FIXME`, section banners, or
  `// eslint-disable` without a stated reason on the same line.
- Never leave commented-out code. Delete it, git remembers.
- Existing comments in a file you are editing stay unless they are wrong. Do not
  strip them as a drive-by change.

## Exports

- Named exports only. No `export default`, including for React components.
- Exception: files a framework requires to default-export, such as Next.js
  `page.tsx`, `layout.tsx`, `route.ts`, and config files.
- Exported functions declare an explicit return type. Internal helpers may let
  the return type infer.

  ```ts
  export const getSession = async (id: string): Promise<Session | null> => { ... }
  ```

## Types

- Prefer `type` aliases. Reach for `interface` only when declaration merging or
  `extends` on a class is actually needed.
- Never use `any`. Use `unknown` and narrow it, or write the real type.
- Never use the non-null assertion `!`. Narrow with a check, an early return, or
  a type guard.

  ```ts
  const user = await findUser(id)
  if (!user) return null
  return user.email
  ```

  Not `return (await findUser(id))!.email`.

- Do not use `as` to silence an error. `as const` is fine, and so is a cast at a
  genuine boundary such as a parsed JSON payload, but validate at that boundary
  rather than asserting through it.
- Do not use `@ts-ignore`. If a suppression is unavoidable use `@ts-expect-error`
  with the reason on the same line, so it fails once the underlying issue is
  fixed.
- Type function parameters and public surfaces. Do not annotate what is already
  obvious from the initialiser: `const count = 0`, not `const count: number = 0`.

## Style

- `const` by default, `let` only when reassignment is real, never `var`.
- Prefer early returns to nested conditionals.
- Prefer `??` and `?.` over `||` and manual null checks where the difference
  between nullish and falsy matters.
- Do not use enums. Use a union of string literals, or an object with
  `as const`.
- Async errors surface. Do not wrap a call in `try/catch` only to swallow it or
  log and continue.
