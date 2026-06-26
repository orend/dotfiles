# Global Claude Instructions

## Memory

User profile and cross-project preferences are stored in `~/.claude/memory/`. Read `~/.claude/memory/MEMORY.md` at the start of each conversation to load context about the user.

## Git Rules

- Always create a new branch before committing. Never commit directly to main/master. Exceptions: `~/lib/notes` and `~/bin/dotfiles` (personal repos where committing and pushing to master is fine).
- When asked to "commit and push" or create a PR, create a feature branch first (except in `~/lib/notes` and `~/bin/dotfiles`).
- Before creating a branch or pushing, bring the branch up to date with its base, then resolve conflicts before proceeding:
  - Normal branch off `main`: `git fetch origin main && git rebase origin/main`.
  - **Stacked** feature branch (based on another feature branch, not `main`): rebase onto that base branch, never onto `main` (rebasing a stack onto `main` detaches it from its base and forces a shared-history rewrite).
  - If the working tree is dirty (e.g. `~/lib/notes` usually has a modified `meetings-modmed.org`), `git stash` or commit first so the rebase doesn't abort, then restore.

## Writing Style

- Be concise. Default to the shortest response that fully answers. Skip preamble ("Great question", "I'll look into..."), recap, and meta-commentary about what you just did. Lead with the answer; cut everything that isn't load-bearing.
- For research/lookup answers: open with the direct finding in 1-2 sentences, then bullet the evidence. Don't restate the question, don't include "Insight" blocks unless the user asked for educational framing, don't list options the user didn't ask for.
- For recommendations: give one recommendation with the key tradeoff in one sentence. Only enumerate alternatives if the user asks for a menu.
- No emojis unless explicitly requested.
- No em dashes. Use regular dashes or commas instead.
- When drafting Slack messages: use Slack mrkdwn format (bold with `*text*`, not `**text**`).
- No markdown tables in Slack messages -- they render as plain text. Use bullet lists instead.
- When drafting text for the user to copy-paste, save it to `~/Downloads/` as a text file.

## Databricks

- Default Databricks profile: `modmed-mmic` (alias `mmic`). Always use `--profile mmic` or `--profile modmed-mmic` for CLI commands.
- Default SQL warehouse: Starter Warehouse (`b23748aff560f5b8`).
- When using the Databricks AI Dev Kit MCP tools, the profile is managed by the MCP server config - no flag needed.
- For SQL queries, prefer the `mcp__plugin_databricks-ai-dev-kit_databricks__execute_sql` MCP tool. Do not use raw `curl modmed-mmic.cloud.databricks.com/api/2.0/sql/statements` or `databricks api post /api/2.0/sql/statements` - they bypass the MCP's auth, profile, and warehouse selection, and the 2026-05-15 self-improve scan found this pattern persisting in 12 sessions across 4 projects.

## Code Quality

- When the catch-tracebacks PostToolUse hook surfaces a deprecation warning (Pydantic v1 `.parse_obj`/`.dict`/`.json`, Node 20 GitHub Actions, langchain successor APIs, etc.), fix it in the same turn. Do not file it as "noted for later" - these keep recurring across sessions when deferred, and the same hook surfaces them again at the next invocation.
- When a Python venv hook denies a `python3`/`pytest` invocation, retry with `source <venv>/bin/activate && <command>` or `<venv>/bin/python <args>`. Don't switch to system python unless the task genuinely needs it.

## Code Review

- When asked to review a PR ("review PR N", "review this PR", "review and approve if ok"), do a quick direct review yourself: read the diff, sanity-check the substantive logic, verify shared-code blast radius and CI, then `gh pr review --approve` with a concise body (non-blocking notes inline) if it's clean. Do NOT invoke the multi-agent `code-review` skill pipeline (parallel reviewers + per-issue confidence scoring) unless I explicitly ask for the multi-agent or thorough review.

## Skills & Config Layout

- Personal skills live in `~/lib/notes/.claude/skills/` and are symlinked to `~/.claude/skills/` for global availability.
- When creating a new personal skill: create in the notes repo first, then symlink.
- Global config (this file, settings.json) lives in `~/bin/dotfiles/claude/` and is symlinked to `~/.claude/`.
- See `~/lib/notes/repos/claude-config-layout.md` for the full layout.
