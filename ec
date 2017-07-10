#!/bin/sh
which osascript > /dev/null 2>&1 && osascript -e 'tell application "Emacs" to activate'
echo $(emacsclient -c -d localhost:0 -a '' $*)
