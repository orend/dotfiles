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
- No markdown tables in Slack messages -- they render as plain text. Use bullet lists instead.
- When drafting text for the user to copy-paste, save it to `~/Downloads/` as a text file.

## Databricks

- Default Databricks profile: `modmed-mmic` (alias `mmic`). Always use `--profile mmic` or `--profile modmed-mmic` for CLI commands.
- Default SQL warehouse: Starter Warehouse (`b23748aff560f5b8`).
- When using the Databricks AI Dev Kit MCP tools, the profile is managed by the MCP server config - no flag needed.

## Skills & Config Layout

- Personal skills live in `~/lib/notes/.claude/skills/` and are symlinked to `~/.claude/skills/` for global availability.
- When creating a new personal skill: create in the notes repo first, then symlink.
- Global config (this file, settings.json) lives in `~/bin/dotfiles/claude/` and is symlinked to `~/.claude/`.
- Slash commands: source in `~/bin/dotfiles/claude/commands/`, symlinked to `~/.claude/commands/`. New user commands require a fresh Claude Code session (not picked up by `/reload-plugins`).
- See `~/lib/notes/repos/claude-config-layout.md` for the full layout.

## Running Claude Code (Warp workaround)

Warp has a 50k-line per-block cap (see [warpdotdev/Warp#8089](https://github.com/warpdotdev/Warp/issues/8089)) that truncates long Claude sessions. The `cc` function in `~/bin/dotfiles/bash/aliases` wraps Claude Code in tmux to sidestep it. Per-project tmux session named after `$(basename "$PWD")`.

| Command | Behavior |
|---|---|
| `cc` | Attach to this directory's tmux+claude, or create fresh if none |
| `cc --resume` | Same, plus open Claude's session picker on fresh creation (or if tmux is at a shell prompt) |
| `cc --continue` | Same, but auto-resume the most recent session |
| `cc-stop` | Kill this directory's tmux session (Claude's transcript is preserved on disk either way) |
| `cc-status` | `running` / `not running` for the current directory |

The function handles three cases: no session → create fresh; session exists with shell prompt → inject the claude command then attach; session exists with claude already running → just attach, don't clobber.

**Persistence:**
- Warp restart / tab close: tmux survives, Claude still running; `cc` reattaches transparently.
- Machine reboot: tmux dies. Resume via `cc --continue` (latest) or `cc --resume` (picker). Claude's JSONL transcripts at `~/.claude/projects/<project-path>/<session-uuid>.jsonl` are the durable state — tmux just smooths the "between turns" gap across Warp restarts.

Tmux scrollback inside the pane: `Ctrl-b [` enters copy-mode, arrows / PgUp / `/` to search, `q` exits. History limit is 1,000,000 lines (`~/bin/dotfiles/.tmux.conf`).
