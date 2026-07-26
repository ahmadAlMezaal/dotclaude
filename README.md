# dotclaude

Shared Claude Code instructions, kept in one place so every machine I work on
behaves the same way. Clone it, run one script, and the rules are live in every
project on that box.

## Quick start

```sh
git clone https://github.com/<you>/dotclaude.git ~/dotclaude
cd ~/dotclaude
./install.sh
```

That is the whole setup. The script is idempotent, so rerunning it after a
`git pull` is harmless and does nothing new.

To update later:

```sh
cd ~/dotclaude && git pull
```

No reinstall needed. The symlinks point at the working tree, so a pull is
enough.

## What install.sh does

| Repo | Link |
| --- | --- |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `rules/` | `~/.claude/rules/shared` |

- An existing real `~/.claude/CLAUDE.md` is moved to `~/.claude/CLAUDE.md.backup`
  before the link is made. That happens once. On later runs the target is
  already a symlink, so nothing is backed up again.
- A real `~/.claude/rules/shared` directory is moved to
  `shared.backup.<timestamp>` for the same reason.
- `~/.claude/settings.json` is never touched. It holds auth tokens and
  machine-specific state, so it stays out of this repo entirely.
- Works on macOS and Linux, including a Raspberry Pi. Bash and coreutils only,
  no dependencies.
- Set `CLAUDE_HOME` to install somewhere other than `~/.claude`, which is
  mainly useful for testing.

## Layout

```
CLAUDE.md          user-level instructions, loaded in every session
rules/             global rules, apply in every repo on the machine
  typescript.md      scoped to **/*.{ts,tsx}
  testing.md         scoped to test files and runner config
  git.md             unconditional
optin/             per-project rules, linked by hand only where they apply
  monorepo.md        apps/packages workspaces
  react-native.md    Expo and React Native apps
  deployment.md      scoped to CI, containers, and deploy config
install.sh         idempotent linker
```

The split matters. `rules/` is only for things that are true in every single
repository. Anything that would be wrong somewhere belongs in `optin/`.

"Use MMKV instead of expo-secure-store" is correct in an Expo app and nonsense
in a Fastify service, so it lives in `optin/react-native.md`. Path scoping
cannot rescue it, because `**/*.tsx` matches web and backend code just as
happily as it matches a mobile screen.

## Load order

1. `~/.claude/CLAUDE.md`, this repo's `CLAUDE.md`. Loaded at launch, every
   session, every project.
2. `~/.claude/rules/shared/*.md`, this repo's `rules/`. A file with no `paths`
   frontmatter loads at launch. A file with `paths` loads only once a matching
   file is actually touched.
3. The project's own `./CLAUDE.md`, if it has one.
4. The project's `./.claude/rules/*.md`, which is where symlinked `optin/` rules
   land. Same `paths` behaviour as above.

Later layers are more specific and win where they overlap, so a project rule
beats a global one. That only works if the files do not contradict each other in
the first place, which is why the writing rules below exist.

`paths` frontmatter is the only mechanism here that actually saves context. An
`@path` import loads at launch whatever the session turns out to be about, so it
buys nothing.

## Adding an optin rule to a project

```sh
mkdir -p .claude/rules
ln -sfn ~/dotclaude/optin/react-native.md .claude/rules/react-native.md
```

Then commit the symlink, or add `.claude/rules/` to the project's
`.gitignore` if the rest of the team does not share this setup. Git stores
symlinks fine, but the link only resolves on a machine that has this repo
cloned at the same path.

Link several where they apply:

```sh
ln -sfn ~/dotclaude/optin/monorepo.md   .claude/rules/monorepo.md
ln -sfn ~/dotclaude/optin/deployment.md .claude/rules/deployment.md
```

To drop one, delete the symlink.

## Writing a rule

- Under 200 lines. Longer files get followed less.
- Concrete and checkable. "Arrow functions assigned to a const" is a rule.
  "Write clean code" is not.
- Show the wrong version next to the right one where the distinction is subtle.
- No contradictions between files. Where two rules disagree the model picks one
  arbitrarily, which is worse than having neither.
- Path-scope anything stack-specific with `paths` frontmatter.
- If it matters in only one repository, it belongs in that repository's own
  `CLAUDE.md`, not here.

## What stays out

This repo is public, so it carries nothing employer-specific: no internal
package names, ticket prefixes, staging URLs, hostnames, or team conventions.
`~/.claude/settings.json` is never symlinked, since it carries auth and machine
state.
