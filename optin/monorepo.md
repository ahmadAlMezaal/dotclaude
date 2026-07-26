---
description: Workspace boundaries, dependency direction, and where commands are run
---

# Monorepo

Link this only in a repository that actually has a workspace root with `apps/`
and `packages/`.

## Layout

- `apps/*` are deployable units: a web app, a mobile app, a service. Nothing
  imports from an app.
- `packages/*` are shared libraries. They are imported by apps and by other
  packages.
- New shared code goes in a package. Do not reach across into another app's
  source, and do not add a relative import that climbs out of the current
  workspace.

## Dependency direction

- Apps depend on packages. Packages depend on packages. Packages never depend on
  apps.
- No import cycles between packages. If two packages need each other, the shared
  part belongs in a third package.
- Import across workspaces by package name, never by relative path.

  ```ts
  import { formatMoney } from '@repo/currency'
  ```

  Not `import { formatMoney } from '../../../packages/currency/src/format'`.

- Inside a package, import by relative path. Do not import a package from within
  itself by its own name.

## Workspace dependencies

- Declare every cross-workspace dependency in that workspace's `package.json`
  using the `workspace:*` protocol. An import that is not declared is a bug even
  if the bundler resolves it.
- A package's own `dependencies` are what it needs at runtime. Build tools,
  types, and test tooling go in `devDependencies`.
- Add a dependency to the workspace that uses it, not to the root. The root
  `package.json` holds only the workspace config and repo-wide tooling.
- Keep a shared dependency on one version across workspaces. If two workspaces
  need different majors, say so rather than silently duplicating.
- Install with `pnpm add <pkg> --filter <workspace>` rather than editing
  `package.json` by hand.

## Commands

- Run scripts through the workspace filter from the repo root:

  ```
  pnpm --filter @repo/api test
  pnpm --filter web dev
  ```

- Run repo-wide tasks through the task runner at the root rather than looping
  over directories by hand.
- Do not `cd` into a workspace to run `pnpm install`. Install from the root so
  the lockfile stays coherent.
- After changing a package's public surface, build or typecheck the workspaces
  that consume it, not just the package itself.

## Package boundaries

- Every package exports through a single entry point defined in its
  `package.json` `exports` field. Do not deep-import another package's internal
  files.
- A change to a package's exported surface is a change to every consumer. Check
  the call sites before claiming it is done.
- Keep app-specific logic in the app. A package that only one app will ever use
  is an unnecessary boundary.
