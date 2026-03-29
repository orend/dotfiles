#!/bin/bash
# SessionStart hook: remind to run /self-improve if it's been >14 days.
# Checks a marker file that self-improve updates after each run.

MARKER="$HOME/.claude/.self-improve-last-run"
DAYS_THRESHOLD=14

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
  # Claude Code encodes paths by replacing / and . with -
  CWD_ENCODED=$(pwd | sed 's|^/||; s|[/.]|-|g')
  SESSION_DIR="$HOME/.claude/projects/-${CWD_ENCODED}"
  SESSION_COUNT=0
  if [ -d "$SESSION_DIR" ]; then
    SESSION_COUNT=$(ls "$SESSION_DIR"/*.jsonl 2>/dev/null | grep -v '/agent-' | wc -l | tr -d ' ')
  fi

  if [ "$SESSION_COUNT" -ge 5 ]; then
    echo "{\"systemMessage\": \"IMPORTANT: It has been ${ELAPSED} days since the last /self-improve run and this project has ${SESSION_COUNT} sessions. You MUST proactively tell the user this and ask if they want to run /self-improve now. Do this in your very first response.\"}"
  fi
fi

exit 0
