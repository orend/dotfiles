#!/bin/bash
# SessionStart hook: remind to run /claude-whats-new if it's been >7 days.

MARKER="$HOME/.claude/.whats-new-last-run"
DAYS_THRESHOLD=7

# If marker doesn't exist, create it and skip (first run)
if [ ! -f "$MARKER" ]; then
  date +%Y-%m-%d > "$MARKER"
  exit 0
fi

# Read date from marker (format: YYYY-MM-DD or "YYYY-MM-DD scope=... project=...")
LAST_DATE=$(head -1 "$MARKER" | cut -d' ' -f1)
LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_DATE" +%s 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$(( (NOW - LAST_EPOCH) / 86400 ))

if [ "$ELAPSED" -ge "$DAYS_THRESHOLD" ]; then
  # Check if snoozed
  SNOOZE="$HOME/.claude/.whats-new-snoozed"
  if [ -f "$SNOOZE" ]; then
    SNOOZE_UNTIL=$(cat "$SNOOZE" 2>/dev/null || echo 0)
    if [ "$NOW" -lt "$SNOOZE_UNTIL" ]; then
      exit 0
    fi
    rm -f "$SNOOZE"
  fi

  echo "{\"systemMessage\": \"BLOCKING INSTRUCTION: Before responding to ANYTHING the user says, you must first mention: It has been ${ELAPSED} days since the last /claude-whats-new run. Ask if they want to check what is new in Claude Code. Then answer their question. If the user declines, snooze by running: echo \$((\$(date +%s) + ${DAYS_THRESHOLD}*86400)) > ~/.claude/.whats-new-snoozed\"}"
fi

exit 0
