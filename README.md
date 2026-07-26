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
| `skills/<name>/` | `~/.claude/skills/<name>/` |

Skills are linked one directory at a time, not as a single directory link,
because a skill is discovered at `~/.claude/skills/<name>/SKILL.md` and one
extra level of nesting would hide it. A skill renamed or deleted in the repo
leaves a broken link behind, so the script prunes those on the next run, but
only ones pointing back into this repo. Skills from anywhere else are left
alone.

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
optin/             per-project rules, linked only where they apply
  monorepo.md        apps/packages workspaces
  react-native.md    Expo and React Native apps
  deployment.md      scoped to CI, containers, and deploy config
skills/            procedures, loaded when the task matches the description
  open-pr/           diff, verify, write the body, create the PR
  add-tests/         pick the behaviours, write them, run them honestly
  migrate-to-mmkv/   AsyncStorage or SecureStore to MMKV, data included
  new-workspace-package/  scaffold and wire a packages/* workspace
install.sh         idempotent linker for the global layer
link.sh            links optin rules into the project you are standing in
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

## Using this in a new repo

For everything in `rules/` and `skills/`, nothing. They are global. Clone the
new project, open Claude in it, and the TypeScript, testing, and git rules are
already loaded. There is no per-repo setup step.

Only the opt-ins need a decision. From the project root:

```sh
~/dotclaude/link.sh                          # list what is available
~/dotclaude/link.sh react-native             # link one
~/dotclaude/link.sh monorepo deployment      # or several
```

That creates `.claude/rules/<name>.md` as a symlink. To drop one, delete the
symlink. Rerunning is harmless.

Then commit the symlink, or add `.claude/rules/` to the project's `.gitignore`
if the rest of the team does not share this setup. Git stores symlinks fine,
but the link only resolves on a machine that has this repo cloned at the same
path.

## Rules or a skill

Two different mechanisms, and putting something in the wrong one is why it gets
ignored.

A **rule** is a standing constraint on how code is written. It is either always
loaded or loaded because you touched a file matching its `paths`. You do not
invoke it and it does not know what you are trying to do. "Arrow functions
assigned to a const" is a rule.

A **skill** is a procedure for a kind of task. It is loaded when its
`description` matches what you asked for, so the description is the trigger and
is the most important line in the file. "Open a PR" is a skill: check the diff,
run the suite, write the body, create it.

The test is whether it constrains code or sequences work. `Use MMKV, never
AsyncStorage` constrains code, so it is a rule. `Add a new package to the
workspace` sequences work, so it is a skill.

A skill should defer to the rules rather than repeat them. `skills/open-pr`
does not restate the commit format, it points at `rules/git.md`. Restating is
how the two drift apart and start contradicting each other.

Skills are global here, like `rules/`. There is no `optin-skills/`, because a
skill only loads when its description matches the request, so a stack-specific
one stays dormant everywhere it does not apply. `migrate-to-mmkv` says React
Native in its description and opens by checking the repo actually is one. That
is cheaper than another symlink layer.

Anything that applies to only one project belongs in that project's own
`.claude/skills/`, not here.

## Writing a skill

- The `description` is the trigger and the most important line in the file.
  Write it as the phrases you would actually type, including the ones you would
  type when you have forgotten the tool's name. Name the stack if it is
  stack-specific, and say what it covers.
- Open by checking the skill applies, and stop if it does not.
- Sequence the work. Numbered steps in the order they happen.
- Defer to the rules rather than repeating them. Repetition is how two files
  drift into contradicting each other.
- Say where the honest failure modes are. "Quote both results", "say which
  platform it was checked on".

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
