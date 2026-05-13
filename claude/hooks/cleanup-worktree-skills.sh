#!/usr/bin/env bash
# Strip duplicate skill dirs that git checks out into scribe worktrees.
#
# Scribe (ai-scribe-model) commits its skills under .claude/skills/<name>/ as
# real tracked files. Every `git worktree add` therefore re-creates them at
# .claude/worktrees/<branch>/.claude/skills/<name>/. Claude Code's skill loader
# walks into those worktree subtrees and emits suffixed dupes like
# add-specialty-handler-skill-XXXXX in the available-skills list.
#
# Only add-specialty-handler is actually producing dupes today; the four other
# scribe skills (debug-l2, extend-workflow, run-local, update-ejson-schema) are
# not. We scrub only the one known offender to minimize the per-branch
# "deleted: <path>" delta inside each worktree's `git status`.
#
# Safe to run on every session start: rm -rf is idempotent, nullglob avoids
# erroring when zero worktrees exist.

set -u
shopt -s nullglob

for d in "$HOME"/lib/scribe/ai-scribe-model/.claude/worktrees/*/.claude/skills/add-specialty-handler; do
  rm -rf "$d"
done

exit 0
