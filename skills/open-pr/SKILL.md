---
name: open-pr
description: Open a pull request for the current branch. Use when asked to open, raise, or put up a PR, or to push a branch for review. Covers checking the diff, running the suite, writing the body, and creating the PR.
---

# Open a PR

Commit message, branch name, and PR body format come from the `git` rule. Do not
restate them here, follow that file. This skill is the procedure around it.

## Before writing anything

1. `git status` and `git branch --show-current`. If the branch is `main` or
   `master`, stop and say so. Work moves to a `kind/short-slug` branch first.
2. `git diff origin/<default>...HEAD --stat`, then read the full diff. Do not
   describe a change you have not read.
3. Check for anything that should not ship: a `.env`, a key, a stray
   `console.log`, an `it.only`, commented-out code, a debug flag left on.

## Verify

4. Run typecheck, lint, and the test suite. Whatever the repo actually uses.
5. Quote the real output. If something fails, fix it or say plainly that it
   fails and stop. Never open a PR described as verified when it was not.
6. If nothing was run because the repo has no such command, say that instead of
   implying it passed.

## Write

7. Summary paragraph: what changed and why, in the terms a reviewer cares
   about. Not a file-by-file walk.
8. Bullets for the notable changes. A behaviour change, a migration, a new
   dependency, a dropped one.
9. A verification section with the commands and their actual result.
10. Call out anything left undone or deliberately out of scope.

## Create

11. Push the branch, then `gh pr create` with the body from a heredoc so the
    formatting survives.
12. Return the PR URL.

## Do not

- Do not open a PR without being asked, even when a branch looks finished.
- Do not force-push to make the history tidy before opening it.
- Do not add reviewers, labels, or milestones unless asked.
- Do not mark it ready for review if the work is a draft in substance.
