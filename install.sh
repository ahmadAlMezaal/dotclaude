#!/usr/bin/env bash
#
# Links this repo into ~/.claude so every project on this machine picks up the
# same instructions. Safe to run repeatedly.
#
#   CLAUDE.md  ->  ~/.claude/CLAUDE.md
#   rules/     ->  ~/.claude/rules/shared
#
# Never touches ~/.claude/settings.json, which holds auth and machine state.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd -P)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
RULES_DIR="$CLAUDE_DIR/rules"
LINK_MD="$CLAUDE_DIR/CLAUDE.md"
LINK_RULES="$RULES_DIR/shared"
STAMP="$(date +%Y%m%d%H%M%S)"

info() { printf '  %s\n' "$1"; }
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }

[ -f "$REPO_DIR/CLAUDE.md" ] || fail "no CLAUDE.md next to install.sh, is \$REPO_DIR right? ($REPO_DIR)"
[ -d "$REPO_DIR/rules" ]     || fail "no rules/ directory next to install.sh ($REPO_DIR)"

printf 'Installing from %s\n' "$REPO_DIR"
printf 'Target %s\n\n' "$CLAUDE_DIR"

mkdir -p "$RULES_DIR"

# --- CLAUDE.md ---------------------------------------------------------------
# A real file gets backed up before it is replaced. A symlink is ours to
# overwrite, so a second run is a no-op rather than a second backup.
if [ -e "$LINK_MD" ] && [ ! -L "$LINK_MD" ]; then
  BACKUP="$CLAUDE_DIR/CLAUDE.md.backup"
  if [ -e "$BACKUP" ]; then
    BACKUP="$CLAUDE_DIR/CLAUDE.md.backup.$STAMP"
  fi
  mv "$LINK_MD" "$BACKUP"
  info "backed up existing CLAUDE.md to $BACKUP"
fi

ln -sfn "$REPO_DIR/CLAUDE.md" "$LINK_MD"
info "CLAUDE.md -> $LINK_MD"

# --- rules/ ------------------------------------------------------------------
# ln -sfn replaces an existing symlink cleanly. A real directory would have the
# link created inside it, so move it out of the way first.
if [ -d "$LINK_RULES" ] && [ ! -L "$LINK_RULES" ]; then
  BACKUP="$RULES_DIR/shared.backup.$STAMP"
  mv "$LINK_RULES" "$BACKUP"
  info "backed up existing rules/shared directory to $BACKUP"
elif [ -e "$LINK_RULES" ] && [ ! -L "$LINK_RULES" ]; then
  BACKUP="$RULES_DIR/shared.backup.$STAMP"
  mv "$LINK_RULES" "$BACKUP"
  info "backed up existing rules/shared file to $BACKUP"
fi

ln -sfn "$REPO_DIR/rules" "$LINK_RULES"
info "rules/ -> $LINK_RULES"

# --- verify ------------------------------------------------------------------
[ -L "$LINK_MD" ]    || fail "$LINK_MD is not a symlink"
[ -L "$LINK_RULES" ] || fail "$LINK_RULES is not a symlink"
[ -f "$LINK_MD" ]    || fail "$LINK_MD does not resolve to a file"
[ -d "$LINK_RULES" ] || fail "$LINK_RULES does not resolve to a directory"

printf '\nDone. Global rules now active in every project on this machine:\n'
for rule in "$REPO_DIR"/rules/*.md; do
  info "$(basename "$rule")"
done

printf '\nPer-project rules live in optin/ and are linked one at a time, e.g.\n'
printf '  mkdir -p .claude/rules\n'
printf '  ln -sfn %s/optin/react-native.md .claude/rules/react-native.md\n' "$REPO_DIR"
