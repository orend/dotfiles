#!/usr/bin/env bash
# Move the detached skill-source worktrees that repo-owned client skill links load
# from (~/.agents, ~/.claude, ~/.codex skills) to the latest origin/main.
# --background detaches and logs to ~/.cache/refresh-skill-sources.log (session-start hooks).
set -euo pipefail

if [ "${1:-}" = "--background" ]; then
  mkdir -p "$HOME/.cache"
  nohup "$0" >>"$HOME/.cache/refresh-skill-sources.log" 2>&1 </dev/null &
  exit 0
fi

# Claude and Codex sessions often start together; one refresh at a time.
lock="${TMPDIR:-/tmp}/refresh-skill-sources.lock"
if ! mkdir "$lock" 2>/dev/null; then
  if [ -n "$(find "$lock" -maxdepth 0 -mmin +5 2>/dev/null)" ]; then
    rmdir "$lock" && mkdir "$lock"
  else
    echo "$(date '+%F %T') busy, skipped" >&2
    exit 0
  fi
fi
trap 'rmdir "$lock"' EXIT

export GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=10"
for repo in ai-scribe-rags ai-scribe-model; do
  wt="$HOME/lib/scribe/worktrees/skills-src-$repo"
  if [ ! -d "$wt" ]; then
    echo "$(date '+%F %T') missing, skipped: $wt" >&2
    continue
  fi
  if ! git -C "$wt" diff --quiet || ! git -C "$wt" diff --cached --quiet; then
    echo "$(date '+%F %T') dirty, skipped: $wt" >&2
    continue
  fi
  if ! git -C "$wt" fetch -q origin main; then
    echo "$(date '+%F %T') fetch failed, kept $(git -C "$wt" rev-parse --short HEAD): $wt" >&2
    continue
  fi
  git -C "$wt" checkout -q --detach origin/main
  echo "$(date '+%F %T') $repo $(git -C "$wt" rev-parse --short HEAD)"
done
