#!/bin/bash
# SessionStart hook: remind to run /skill-workshop if it's been >30 days.
# Checks a marker file that skill-workshop updates after each run.

MARKER="$HOME/.claude/.skill-workshop-last-run"
DAYS_THRESHOLD=30

# If marker doesn't exist, create it and skip (first run)
if [ ! -f "$MARKER" ]; then
  date +%s > "$MARKER"
  exit 0
fi

LAST_RUN=$(cat "$MARKER" 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$(( (NOW - LAST_RUN) / 86400 ))

if [ "$ELAPSED" -ge "$DAYS_THRESHOLD" ]; then
  # Count sessions for current project
  CWD_ENCODED=$(pwd | sed 's|^/||; s|/|-|g')
  SESSION_DIR="$HOME/.claude/projects/-${CWD_ENCODED}"
  SESSION_COUNT=0
  if [ -d "$SESSION_DIR" ]; then
    SESSION_COUNT=$(ls "$SESSION_DIR"/*.jsonl 2>/dev/null | grep -v '/agent-' | wc -l | tr -d ' ')
  fi

  if [ "$SESSION_COUNT" -ge 5 ]; then
    echo "It's been ${ELAPSED} days since your last /skill-workshop run and this project has ${SESSION_COUNT} sessions. Consider running /skill-workshop to discover new automation candidates."
  fi
fi

exit 0
