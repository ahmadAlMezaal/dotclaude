---
description: Commit messages, branch names, PR bodies, and what needs asking first
---

# Git

## Commit messages

- Format: `type: subject`, using Conventional Commits.
- Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `build`,
  `ci`, `revert`. Nothing outside that list.
- An optional scope goes in brackets: `feat(auth): ...`. Keep it to one word.
- The subject is a lowercase imperative, under 72 characters including the
  prefix, with no trailing full stop.

  ```
  feat: add rate limiting to the login route
  fix: stop the storage migration dropping the auth key
  chore: bump vitest to 3.2
  ```

  Not `Added rate limiting.`, not `feat: Added rate limiting to login`.

- The subject says what the commit does, not which files it touched.
  `fix: reject expired sessions`, not `fix: update session.ts`.
- Add a body only when the reason is not obvious from the subject. Wrap at 72
  characters, explain why rather than what, and separate it from the subject
  with a blank line.
- Reference issues in the body as `Refs #12` or `Closes #12`, never in the
  subject.
- British English, no em-dashes, no exclamation marks, no emoji.
- One logical change per commit. If the subject needs "and", it is two commits.

## Branches

- Format: `kind/short-slug`, lowercase and hyphenated.
- `kind` is the same set as the commit types: `feat`, `fix`, `chore`,
  `refactor`, `docs`, `test`, `perf`, `build`, `ci`.

  ```
  feat/login-rate-limit
  fix/session-expiry
  chore/bump-vitest
  ```

- No ticket prefixes, no dates, no personal names in branch names.
- Branch from the default branch and keep it up to date by rebasing, not by
  merging the default branch back in.
- Never commit directly to `main` or `master`. If asked to commit while on the
  default branch, create a branch first.

## Pull request bodies

- Structure: a one-paragraph summary of what changed and why, then a short
  bullet list of the notable changes, then how it was verified.
- State the verification honestly: which command was run and what it printed.
  If it was not run, say so.
- Call out anything a reviewer would otherwise miss: a behaviour change, a
  migration, a dropped dependency, a follow-up left undone.
- No screenshots section unless there is a visual change. No checklist theatre.
- Same prose rules as everywhere else: British English, no em-dashes.

## What needs asking first

- Commit only when explicitly asked. Finishing a task is not permission to
  commit it.
- Push only when explicitly asked. Opening a PR is a separate ask again.
- Never `push --force`. Use `--force-with-lease`, and only on your own branch,
  and only when asked.
- Never amend, rebase, or reset a commit that has already been pushed.
- Never use `git checkout .`, `git reset --hard`, `git clean -fd`, or
  `git stash drop` on work you did not create in this session.
- Never commit `.env` files, credentials, tokens, keys, or anything matched by
  `.gitignore`. If a secret is already staged, stop and say so.
- Do not update `.gitignore`, git config, or hooks as a side effect of another
  task.
- Stage the files relevant to the change. Do not `git add -A` over a dirty
  working tree you did not inspect.
