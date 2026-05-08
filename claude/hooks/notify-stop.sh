#!/bin/bash
# Stop hook:
#   1. Emit OSC 777 to Warp (Mailbox entry + macOS toast).
#   2. Rename this tmux session with a "● " prefix as a persistent visible
#      indicator that Claude is done (survives Claude's OSC 0 title updates
#      because #S is under our control, not Claude's).
# Restored on UserPromptSubmit via restore-session-name.sh.

TITLE="Claude Code"
BODY="Done"
PROJECT=$(basename "$PWD")
[ -n "$PROJECT" ] && BODY="Done in $PROJECT"

# Resolve the correct pane_tty for THIS hook invocation (not "most recently
# used", which could be a different Warp tab when multiple Claudes run).
resolve_pane_tty() {
    [ -z "$TMUX" ] && return 1
    if [ -n "$TMUX_PANE" ]; then
        tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null && return 0
    fi
    tmux display-message -p '#{pane_tty}' 2>/dev/null
}

if [ -n "$TMUX" ]; then
    emit() { printf '\033Ptmux;\033\033]777;notify;%s;%s\007\033\\' "$TITLE" "$BODY"; }
else
    emit() { printf '\033]777;notify;%s;%s\007' "$TITLE" "$BODY"; }
fi
emit_to() { { emit > "$1"; } 2>/dev/null; }

PANE_TTY=$(resolve_pane_tty)
if [ -n "$PANE_TTY" ]; then
    emit_to "$PANE_TTY"
else
    emit_to /dev/tty || {
        PARENT_TTY=$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d ' ')
        if [ -n "$PARENT_TTY" ] && [ "$PARENT_TTY" != "?" ] && [ "$PARENT_TTY" != "??" ]; then
            emit_to "/dev/$PARENT_TTY"
        fi
    }
fi

# Set @claude_idle on the session; the tmux set-titles-string format conditionally
# prepends "● " when @claude_idle is truthy AND the client isn't focused.
# This gives inbox-style semantics: dot shows only when you're not looking.
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    CURRENT_SESSION=$(tmux display-message -p -t "$TMUX_PANE" '#S' 2>/dev/null)
    if [ -n "$CURRENT_SESSION" ]; then
        tmux set-option -t "$CURRENT_SESSION" @claude_idle 1 2>/dev/null
        tmux refresh-client -S 2>/dev/null
    fi
fi
exit 0
