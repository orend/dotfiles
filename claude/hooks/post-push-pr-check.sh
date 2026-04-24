#!/usr/bin/env bash
# PostToolUse hook: after git push, remind Claude to check/update the PR.
# Defensive: the `if` glob matcher can misfire on compound Bash commands,
# so we validate the actual command here.

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# Only fire if the command actually starts with "git push"
if [[ ! "$CMD" =~ ^git[[:space:]]+push ]]; then
  exit 0
fi

echo '{"systemMessage": "A git push just happened. You MUST immediately: (1) Check if there is an open PR for this branch using gh pr view. If so, compare the PR description to the full commit history (git log main..HEAD). If the description is stale or missing recent changes, update it now using gh pr edit. (2) Check if the README needs updating. If so, update it, commit, and push. Do not ask for permission - just do it. If everything is current, say nothing."}'
