#!/bin/sh

# Debug mode - uncomment to enable
# set -x

# Handle -n flag (don't wait)
NO_WAIT=""
if [ "$1" = "-n" ]; then
    NO_WAIT="-n"
    shift
fi

# Activate Emacs if on macOS
which osascript > /dev/null 2>&1 && osascript -e 'tell application "Emacs" to activate'

# Function to open directory in dired mode
open_in_dired() {
    local dir="$1"
    # Get absolute path
    local abs_dir=$(cd "$dir" && pwd)
    if [ -n "$NO_WAIT" ]; then
        emacs --eval "(progn (dired \"$abs_dir\") (delete-other-windows))" &
    else
        emacs --eval "(progn (dired \"$abs_dir\") (delete-other-windows))"
    fi
}

# Try emacsclient first (with proper terminal handling)
# If argument is a directory, use dired
if [ $# -eq 0 ] || [ -d "$1" ]; then
    dir="${1:-.}"
    abs_dir=$(cd "$dir" && pwd)
    if emacsclient $NO_WAIT -c --eval "(progn (dired \"$abs_dir\") (delete-other-windows))" 2>/dev/null; then
        # emacsclient succeeded
        exit 0
    fi
else
    if emacsclient $NO_WAIT -c "$@" 2>/dev/null; then
        # emacsclient succeeded
        exit 0
    fi
fi

# emacsclient failed, fall back to emacs
# If no arguments, open current directory in dired
if [ $# -eq 0 ]; then
    open_in_dired "."
else
    # Check if argument is a directory
    if [ -d "$1" ]; then
        open_in_dired "$1"
    else
        # Regular file or other argument
        if [ -n "$NO_WAIT" ]; then
            emacs "$@" &
        else
            emacs "$@"
        fi
    fi
fi
