#!/usr/bin/env bash
# Hook: check-pr-before-push
# Prevents pushing to a branch whose PR is already merged.

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Allow pushes to main/master - no PR check needed
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  exit 0
fi

state=$(gh pr view "$branch" --json state -q .state 2>/dev/null)

if [[ "$state" == "MERGED" ]]; then
  echo "BLOCKED: The PR for branch '$branch' is already merged."
  echo "Create a new branch from main instead of pushing to this one."
  exit 2
fi

# No PR exists or PR is still open - allow the push
exit 0
