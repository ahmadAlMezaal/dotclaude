#!/usr/bin/env bash
#
# Links optin rules into the project in the current directory.
#
#   cd ~/code/my-expo-app
#   ~/dotclaude/link.sh react-native monorepo
#
# Run with no arguments to list what is available and what is already linked.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd -P)"
OPTIN_DIR="$REPO_DIR/optin"
TARGET_DIR="$PWD/.claude/rules"

info() { printf '  %s\n' "$1"; }
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }

[ -d "$OPTIN_DIR" ] || fail "no optin/ directory in $REPO_DIR"

if [ "$#" -eq 0 ]; then
  printf 'Available optin rules:\n'
  for rule in "$OPTIN_DIR"/*.md; do
    name="$(basename "$rule" .md)"
    if [ -L "$TARGET_DIR/$name.md" ]; then
      info "$name (linked here)"
    else
      info "$name"
    fi
  done
  printf '\nUsage: %s <name> [name ...]\n' "$(basename "$0")"
  printf 'Run from the root of the project you want to link into.\n'
  exit 0
fi

for name in "$@"; do
  source_file="$OPTIN_DIR/${name%.md}.md"
  [ -f "$source_file" ] || fail "no optin rule called '${name%.md}', run with no arguments to list them"
done

mkdir -p "$TARGET_DIR"

for name in "$@"; do
  base="${name%.md}"
  ln -sfn "$OPTIN_DIR/$base.md" "$TARGET_DIR/$base.md"
  info "$base.md -> .claude/rules/$base.md"
done

printf '\nLinked into %s\n' "$TARGET_DIR"
printf 'These resolve only on a machine with this repo cloned at %s\n' "$REPO_DIR"
