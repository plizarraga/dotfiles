
#!/usr/bin/env bash
set -euo pipefail

AGENTS="$HOME/.agents/skills"
CLAUDE="$HOME/.claude/skills"
CUSTOM="$HOME/dotfiles/ai/skills"
BACKUP_ROOT="$HOME/dotfiles/backups/skills"

MODE="${1:---dry-run}"

if [[ "$MODE" != "--dry-run" && "$MODE" != "--apply" ]]; then
  echo "Usage: $0 [--dry-run|--apply]"
  exit 1
fi

if [[ ! -d "$AGENTS" || ! -d "$CLAUDE" ]]; then
  echo "ERROR: Missing skills directories"
  exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP="$BACKUP_ROOT/$TIMESTAMP"

identical=0
different=0
linked=0

echo "=== Skills Synchronization ==="
echo "Mode: $MODE"
echo

# 1. Deduplicate identical directories in Claude.
for source in "$AGENTS"/*; do
  [[ -d "$source" && ! -L "$source" ]] || continue

  name=$(basename "$source")
  target="$CLAUDE/$name"

  # Internal/shared directories are excluded.
  [[ "$name" == _* ]] && continue

  # Never replace an existing symlink.
  [[ -L "$target" ]] && continue

  [[ -d "$target" ]] || continue

  if diff -rq "$source" "$target" >/dev/null; then
    echo "DEDUPLICATE: $name"
    ((identical+=1))

    if [[ "$MODE" == "--apply" ]]; then
      mkdir -p "$BACKUP/claude"
      mv "$target" "$BACKUP/claude/$name"
      ln -s "../../.agents/skills/$name" "$target"
    fi
  else
    echo "SKIP (different): $name"
    ((different+=1))
  fi
done

# 2. Link custom skills to the global directory and Claude.
if [[ -d "$CUSTOM" ]]; then
  for source in "$CUSTOM"/*; do
    [[ -d "$source" ]] || continue

    name=$(basename "$source")

    for target in "$AGENTS/$name" "$CLAUDE/$name"; do
      # Existing paths, including broken symlinks,
      # are never overwritten.
      if [[ -e "$target" || -L "$target" ]]; then
        continue
      fi

      echo "LINK: $target -> $source"
      ((linked+=1))

      if [[ "$MODE" == "--apply" ]]; then
        ln -s "$source" "$target"
      fi
    done
  done
fi

echo
echo "=== Summary ==="
echo "Identical duplicates: $identical"
echo "Different directories: $different"
echo "New links: $linked"

if [[ "$MODE" == "--apply" ]]; then
  echo "Backup: $BACKUP"
else
  echo "No changes made."
fi

