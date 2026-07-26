---
name: new-workspace-package
description: Add a new package to a pnpm workspace monorepo. Use when asked to create a shared package, extract code into a package, add a workspace, or set up packages/* wiring and workspace dependencies. Monorepos only.
---

# New workspace package

Only applies in a repo with a pnpm workspace root. If there is no
`pnpm-workspace.yaml`, say so and stop. Boundaries and dependency direction come
from the `monorepo` rule, follow that file rather than restating it.

## Decide whether it should exist

1. A package that only one app will ever use is an unnecessary boundary. Say so
   and put the code in the app instead.
2. Check it does not already exist under a different name before creating it.

## Create it

3. `packages/<name>/` with a `package.json` naming it under the same scope the
   other packages use. Read a sibling package to find that scope rather than
   inventing one.
4. Set `"exports"` to a single entry point. No `"main"` plus deep paths, and no
   consumer reaching past the entry point later.
5. Extend the shared tsconfig the other packages extend. Do not write a fresh
   compiler config.
6. Match the sibling packages on build tooling, test setup, and scripts. A
   package that builds differently from its neighbours is a maintenance cost, so
   if you must deviate, say why.

## Wire it up

7. Add it to the consuming workspace with `workspace:*`:
   `pnpm add <pkg> --filter <consumer> --workspace`.
8. Runtime needs go in `dependencies`. Build tools, types, and test tooling go
   in `devDependencies`. Anything the consumer must also install goes in
   `peerDependencies`.
9. Install from the repo root, never by cd-ing into the package.
10. Consumers import by package name. If you are moving existing code, replace
    the relative imports that climbed out of the workspace, and check none are
    left.

## Verify

11. Typecheck and build the new package, then typecheck every workspace that
    consumes it. A package that compiles alone can still break its consumers.
12. If you extracted existing code, run the tests of the workspace it came
    from, not just the new package's own.
13. Confirm the lockfile changed and is committed.
