# Global Claude Instructions

## Memory

User profile and cross-project preferences are stored in `~/.claude/memory/`. Read `~/.claude/memory/MEMORY.md` at the start of each conversation to load context about the user.

## Git Rules

- Always create a new branch before committing. Never commit directly to main/master. Exception: the notes repo (`~/lib/notes`) where committing to master is fine.
- When asked to "commit and push" or create a PR, create a feature branch first (except in notes repo).
- Before creating a branch or pushing, always `git fetch origin main && git rebase origin/main` to ensure the branch is current. Resolve conflicts before proceeding.

## Writing Style

- No emojis unless explicitly requested.
- No em dashes. Use regular dashes or commas instead.
- When drafting Slack messages: use Slack mrkdwn format (bold with `*text*`, not `**text**`).
- When drafting text for the user to copy-paste, save it to `~/Downloads/` as a text file.

## Skills & Config Layout

- Personal skills live in `~/lib/notes/.claude/skills/` and are symlinked to `~/.claude/skills/` for global availability.
- When creating a new personal skill: create in the notes repo first, then symlink.
- Global config (this file, settings.json) lives in `~/bin/dotfiles/claude/` and is symlinked to `~/.claude/`.
- See `~/lib/notes/repos/claude-config-layout.md` for the full layout.
