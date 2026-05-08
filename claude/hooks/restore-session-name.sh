#!/bin/bash
# UserPromptSubmit hook: clear @claude_idle on the tmux session so the "● "
# prefix stops rendering. Paired with notify-stop.sh which sets it.
# (Name kept for settings.json compatibility even though we no longer rename.)

[ -z "$TMUX" ] || [ -z "$TMUX_PANE" ] && exit 0

CURRENT_SESSION=$(tmux display-message -p -t "$TMUX_PANE" '#S' 2>/dev/null)
if [ -n "$CURRENT_SESSION" ]; then
    tmux set-option -t "$CURRENT_SESSION" -u @claude_idle 2>/dev/null
    tmux refresh-client -S 2>/dev/null
fi
exit 0
