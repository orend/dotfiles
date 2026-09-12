#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 --home PATH --notes-dir PATH [--dry-run|--check]" >&2
}

target_home=""
notes_dir=""
mode="apply"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --home) target_home=${2:?missing value for --home}; shift 2 ;;
    --notes-dir) notes_dir=${2:?missing value for --notes-dir}; shift 2 ;;
    --dry-run) mode="dry-run"; shift ;;
    --check) mode="check"; shift ;;
    *) usage; exit 2 ;;
  esac
done

if [ -z "$target_home" ] || [ -z "$notes_dir" ]; then
  usage
  exit 2
fi

dotfiles_dir=$(cd "$(dirname "$0")/.." && pwd)
manifest="$dotfiles_dir/codex/shared-skills.tsv"
issues=0

test -f "$dotfiles_dir/codex/AGENTS.md" || { echo "missing Codex instructions" >&2; exit 1; }
test -f "$dotfiles_dir/claude/CLAUDE.md" || { echo "missing Claude instructions" >&2; exit 1; }
shopt -s nullglob
agent_sources=("$dotfiles_dir"/codex/agents/*.toml)
shopt -u nullglob
[ "${#agent_sources[@]}" -gt 0 ] || { echo "missing Codex agent sources" >&2; exit 1; }

while IFS=$'\t' read -r skill destinations; do
  case "$skill" in ""|\#*) continue ;; esac
  test -f "$notes_dir/codex/skills/$skill/SKILL.md" || {
    echo "missing canonical skill: $notes_dir/codex/skills/$skill/SKILL.md" >&2
    exit 1
  }
  IFS=, read -r -a clients <<< "$destinations"
  for client in "${clients[@]}"; do
    case "$client" in agents|codex|claude) ;; *) echo "invalid client '$client' for $skill" >&2; exit 1 ;; esac
  done
done < "$manifest"

link_managed() {
  local source=$1 destination=$2 expected actual
  expected=$(realpath "$source")
  if [ -L "$destination" ]; then
    actual=$(realpath "$destination" 2>/dev/null || true)
    if [ "$actual" = "$expected" ]; then
      echo "ok $destination"
      return
    fi
  elif [ ! -e "$destination" ]; then
    if [ "$mode" = "check" ]; then
      echo "missing $destination (expected $source)" >&2
      issues=1
      return
    fi
    if [ "$mode" = "dry-run" ]; then
      echo "would link $destination -> $source"
      return
    fi
    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
    echo "linked $destination -> $source"
    return
  fi

  echo "conflict $destination (expected $source); left unchanged" >&2
  issues=1
}

link_managed "$dotfiles_dir/codex/AGENTS.md" "$target_home/.codex/AGENTS.md"
link_managed "$dotfiles_dir/claude/CLAUDE.md" "$target_home/.claude/CLAUDE.md"

while IFS=$'\t' read -r skill destinations; do
  case "$skill" in ""|\#*) continue ;; esac
  source="$notes_dir/codex/skills/$skill"
  IFS=, read -r -a clients <<< "$destinations"
  for client in "${clients[@]}"; do
    case "$client" in
      agents) destination="$target_home/.agents/skills/$skill" ;;
      codex) destination="$target_home/.codex/skills/$skill" ;;
      claude) destination="$target_home/.claude/skills/$skill" ;;
      *) echo "invalid client '$client' for $skill" >&2; exit 1 ;;
    esac
    link_managed "$source" "$destination"
  done
done < "$manifest"

for source in "${agent_sources[@]}"; do
  link_managed "$source" "$target_home/.codex/agents/$(basename "$source")"
done

if [ "$issues" -ne 0 ]; then
  exit 1
fi
