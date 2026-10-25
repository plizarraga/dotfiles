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

# Claude loads ~/.claude/skills and enabled plugins; the same name in both appears twice.
# ~/.agents/skills is not read by Claude Code, so a copy only there is not a duplicate.
echo
echo "=== Plugin Skills Audit ==="

PLUGINS_JSON="$HOME/.claude/plugins/installed_plugins.json"
SETTINGS_JSON="$HOME/.claude/settings.json"

if [ -f "$PLUGINS_JSON" ] && [ -f "$SETTINGS_JSON" ]; then
  # One "plugin<TAB>skill" line per skill shipped by an enabled plugin.
  plugin_skills=$(python3 - "$PLUGINS_JSON" "$SETTINGS_JSON" <<'PY'
import json, os, sys

installed = json.load(open(sys.argv[1]))["plugins"]
enabled = json.load(open(sys.argv[2])).get("enabledPlugins", {})

for plugin, entries in installed.items():
    if not enabled.get(plugin):
        continue
    skills_dir = os.path.join(entries[0]["installPath"], "skills")
    if os.path.isdir(skills_dir):
        for skill in sorted(os.listdir(skills_dir)):
            print(f"{plugin}\t{skill}")
PY
  )

  found=0
  while IFS=$'\t' read -r plugin name; do
    [ -n "$name" ] || continue

    if [ -e "$CLAUDE/$name" ] || [ -L "$CLAUDE/$name" ]; then
      printf "PLUGIN-DUP %s (also in %s)\n" "$name" "$plugin"
      found=1
    fi
  done <<< "$plugin_skills"

  [ "$found" -eq 1 ] || echo "No duplicates with enabled plugins."
else
  echo "Skipped: Claude plugin metadata not found."
fi
