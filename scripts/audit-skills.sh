#!/usr/bin/env bash

set -euo pipefail

AGENTS="$HOME/.agents/skills"
CLAUDE="$HOME/.claude/skills"

echo "=== Duplicate Skills Audit ==="

for source in "$AGENTS"/*; do
  [ -d "$source" ] || continue
  [ -L "$source" ] && continue

  name=$(basename "$source")
  target="$CLAUDE/$name"

  if [ -d "$target" ] && [ ! -L "$target" ]; then
    if diff -rq "$source" "$target" >/dev/null; then
      printf "IDENTICAL  %s\n" "$name"
    else
      printf "DIFFERENT  %s\n" "$name"
    fi
  fi
done
