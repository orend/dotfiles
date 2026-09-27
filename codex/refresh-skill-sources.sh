#!/usr/bin/env bash
# Move the detached skill-source worktrees that repo-owned client skill links load
# from (~/.agents, ~/.claude, ~/.codex skills) to the latest origin/main.
set -euo pipefail
for repo in ai-scribe-rags ai-scribe-model; do
  wt="$HOME/lib/scribe/worktrees/skills-src-$repo"
  if ! git -C "$wt" diff --quiet || ! git -C "$wt" diff --cached --quiet; then
    echo "dirty, skipped: $wt" >&2
    continue
  fi
  git -C "$wt" fetch -q origin main
  git -C "$wt" checkout -q --detach origin/main
  echo "$repo $(git -C "$wt" rev-parse --short HEAD)"
done
