#!/bin/bash
# SessionStart hook: remind to run /self-improve if it's been >14 days.
#
# Emits two channels when the threshold is crossed:
#   1. terminalSequence (OSC 9): macOS / Warp / iTerm desktop notification
#      and a bell. Surfaces immediately, without polluting Claude's context.
#   2. systemMessage: tells Claude to raise the reminder verbally on its
#      first response, as a fallback if the OS notification is missed.
#
# Marker file is updated by self-improve itself after each run.

MARKER="$HOME/.claude/.self-improve-last-run"
DAYS_THRESHOLD=14

if [ ! -f "$MARKER" ]; then
  date +%s > "$MARKER"
  exit 0
fi

LAST_RUN=$(cat "$MARKER" 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$(( (NOW - LAST_RUN) / 86400 ))

[ "$ELAPSED" -lt "$DAYS_THRESHOLD" ] && exit 0

# Claude Code encodes paths by replacing / and . with -
CWD_ENCODED=$(pwd | sed 's|^/||; s|[/.]|-|g')
SESSION_DIR="$HOME/.claude/projects/-${CWD_ENCODED}"
SESSION_COUNT=0
if [ -d "$SESSION_DIR" ]; then
  SESSION_COUNT=$(ls "$SESSION_DIR"/*.jsonl 2>/dev/null | grep -v '/agent-' | wc -l | tr -d ' ')
fi

[ "$SESSION_COUNT" -lt 5 ] && exit 0

# Build the JSON via python so escape sequences are correctly preserved.
python3 - "$ELAPSED" "$SESSION_COUNT" "$(basename "$PWD")" <<'PY'
import json, sys
elapsed, count, proj = sys.argv[1:4]
title = "Claude Code: /self-improve overdue"
body = f"{elapsed}d, {count} sessions in {proj}"
# OSC 9 = iTerm/Warp/macOS Terminal desktop notification.
# Two BELs: one inside the OSC sequence (terminator), one extra for audible tick.
term_seq = f"\x1b]9;{title}: {body}\x07\x07"
print(json.dumps({
    "systemMessage": (
        f"IMPORTANT: It has been {elapsed} days since the last "
        f"/self-improve run and this project has {count} sessions. "
        "You MUST proactively tell the user this and ask if they "
        "want to run /self-improve now. Do this in your very first response."
    ),
    "terminalSequence": term_seq,
}))
PY
exit 0
