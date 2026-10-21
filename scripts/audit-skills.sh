#!/usr/bin/env bash

set -euo pipefail

AGENTS="$HOME/.agents/skills"
CLAUDE="$HOME/.claude/skills"
CODEX="$HOME/.codex/skills"

# diff exits 0 when identical, 1 when different, and 2 when it cannot compare.
compare() {
  local source="$1" target="$2" label="$3" status=0

  diff -rq "$source" "$target" >/dev/null || status=$?

  case "$status" in
    0) printf "IDENTICAL  %s\n" "$label" ;;
    1) printf "DIFFERENT  %s\n" "$label" ;;
    *) printf "ERROR      %s\n" "$label" ;;
  esac
}

echo "=== Duplicate Skills Audit ==="

for source in "$AGENTS"/*; do
  [ -d "$source" ] || continue
  [ -L "$source" ] && continue

  name=$(basename "$source")
  target="$CLAUDE/$name"

  if [ -d "$target" ] && [ ! -L "$target" ]; then
    compare "$source" "$target" "$name"
  fi
done

# Codex still reads the deprecated ~/.codex/skills; real copies there duplicate a shared skill.
for source in "$CODEX"/*; do
  [ -d "$source" ] || continue
  [ -L "$source" ] && continue

  name=$(basename "$source")

  for target in "$AGENTS/$name" "$CLAUDE/$name"; do
    [ -d "$target" ] || continue

    compare "$source" "$target" "codex/$name"
    break
  done
done
