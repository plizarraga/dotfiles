#!/usr/bin/env bash

set -euo pipefail

AGENTS="$HOME/.agents/skills"
CLAUDE="$HOME/.claude/skills"
CODEX="$HOME/.codex/skills"

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

# Codex still reads the deprecated ~/.codex/skills; real copies there duplicate a shared skill.
for source in "$CODEX"/*; do
  [ -d "$source" ] || continue
  [ -L "$source" ] && continue

  name=$(basename "$source")

  for target in "$AGENTS/$name" "$CLAUDE/$name"; do
    [ -d "$target" ] || continue

    if diff -rq "$source" "$target" >/dev/null; then
      printf "IDENTICAL  codex/%s\n" "$name"
    else
      printf "DIFFERENT  codex/%s\n" "$name"
    fi
    break
  done
done
