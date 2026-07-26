# Global preferences

These apply in every repository on every machine. Stack-specific rules live in
`rules/` (loaded by path) and `optin/` (linked per project).

## Prose

- Write all prose in British English: chat replies, commit messages, PR bodies,
  documentation, code comments, and user-facing UI copy. Use "colour",
  "behaviour", "organise", "licence" (noun), "analyse", "centre", "-ise" not
  "-ize".
- Keep American English where the API demands it. CSS properties and values
  (`color`, `background-color`, `text-align: center`), HTML attributes, and
  third-party identifiers keep their required spelling. Never rewrite
  `color: red` to `colour: red`.
- When naming variables or functions, follow the spelling convention already
  used in that codebase rather than imposing British spelling on it.
- Never use em-dashes. Use a comma, a full stop, or brackets instead. This
  applies to replies, commits, docs, UI copy, and the rule files in this repo.
- No exclamation marks in commits, PR bodies, or documentation.

## Working style

- Answer the question asked. Do not add unrequested refactors, extra files, or
  speculative abstractions to a change.
- When a request is ambiguous in a way that changes the output, ask before
  building rather than after.
- Say plainly when something is untested, partially done, or failing. Report the
  actual command output rather than a summary of it.
- Prefer editing an existing file over creating a new one.
- Do not create README files, summary documents, or migration notes unless they
  were asked for.

## Tooling defaults

- Package manager: pnpm. Do not run `npm install` or `yarn` in a pnpm repo.
- Node version comes from `.nvmrc` or `engines` in `package.json`. Do not
  upgrade it as a side effect of another task.
- Never edit lockfiles by hand.
- Never read, print, or commit `.env` files, credentials, or tokens.
