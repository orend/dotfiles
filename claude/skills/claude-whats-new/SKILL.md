---
name: claude-whats-new
description: >
  Check what's new in Claude Code and recommend features to adopt. Fetches the
  changelog, compares against your current setup, and suggests what to use.
  Use when you say "what's new in Claude Code", "any new features", "check
  changelog", "what am I missing", or "update my setup".
argument-hint: "[version or date]"
disable-model-invocation: false
---

# What's New in Claude Code

Fetch the latest Claude Code changelog, filter for features relevant to your
setup, and recommend what to adopt.

## Step 0: Choose scope

Ask the user before doing any scanning:

> "Check for new features for **this project only** or **all your repos**?"

If `$ARGUMENTS` contains "all" or "global", use all-repos mode.
If `$ARGUMENTS` contains "project" or "this", use project-only mode.
Otherwise, ask.

## Step 1: Check version and fetch changelog

```bash
claude --version 2>/dev/null | head -1
```

Check when this skill was last run and what scope was used:

```bash
cat ~/.claude/.whats-new-last-run 2>/dev/null || echo "never"
```

The marker file format is:
```
YYYY-MM-DD scope=project|all project=/path/to/project
```

Fetch the changelog. Two options, in order of preference:

First, check if the user is on the latest version:

```bash
INSTALLED=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
LATEST=$(curl -sL "https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md" | grep -oE '^## [0-9]+\.[0-9]+\.[0-9]+' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
echo "Installed: $INSTALLED, Latest: $LATEST"
```

If `$INSTALLED` == `$LATEST`, use the built-in command (faster, no network):
```bash
claude -p "/release-notes" 2>/dev/null
```

If `$INSTALLED` != `$LATEST`, use GitHub (shows versions the user hasn't installed yet):
```bash
curl -sL "https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md" | head -500
```

Also mention to the user that they're behind and suggest `claude update`.

Do NOT use context7 (doesn't index the changelog) or WebFetch on
`code.claude.com/docs/en/changelog` (JS-rendered, returns empty).

If `$ARGUMENTS` contains a version or date, filter to entries from that point forward.
If a last-run marker exists, only show features newer than that date.
Otherwise, show features from the last 30 days.

## Step 2: Scan setup

### Always scan (global setup):
```bash
# Hooks configured
grep -r "PreToolUse\|PostToolUse\|Stop\|SessionStart\|StopFailure\|PostCompact\|CwdChanged\|FileChanged\|TaskCreated\|ConfigChange" ~/.claude/settings.json 2>/dev/null | grep -v "^Binary"

# Plugin hooks
find ~/.claude/plugins/cache -name "hooks.json" -exec grep -l "hooks" {} \; 2>/dev/null | head -10

# Settings features in use
grep -o '"[a-zA-Z]*"' ~/.claude/settings.json 2>/dev/null | sort -u

# Installed plugins
for mkt in ~/.claude/plugins/cache/*/; do
  mkt_name=$(basename "$mkt")
  for p in "$mkt"/*/; do
    [ -d "$p" ] && echo "$mkt_name/$(basename "$p")"
  done
done 2>/dev/null | grep -v temp_git | sort

# MCP servers (global)
cat ~/.claude/.mcp.json 2>/dev/null | grep -o '"[^"]*":' | head -10

# Personal skills and agents
ls ~/.claude/skills/ ~/.claude/agents/ 2>/dev/null
```

### Project-only mode - scan current project:
```bash
# Project config
ls .claude/settings.json .claude/skills/ .claude/agents/ .claude/rules/ .mcp.json CLAUDE.md 2>/dev/null

# Project hooks
grep -r "hooks" .claude/settings.json 2>/dev/null

# Project MCP servers
cat .mcp.json 2>/dev/null | grep -o '"[^"]*":' | head -10

# Tech stack
ls package.json pyproject.toml Cargo.toml go.mod pom.xml Makefile 2>/dev/null
head -10 CLAUDE.md 2>/dev/null
```

### All-repos mode - also scan sibling repos:
```bash
# Find all repos with .claude/ config
for dir in ~/lib/*/ ~/lib/scribe/*/; do
  if [ -d "$dir/.claude" ] || [ -f "$dir/CLAUDE.md" ]; then
    echo "$dir: skills=$(ls "$dir/.claude/skills/" 2>/dev/null | wc -l | tr -d ' ') hooks=$(grep -c 'hooks' "$dir/.claude/settings.json" 2>/dev/null || echo 0)"
  fi
done
```

## Step 3: Match features to gaps

For each new changelog feature, check if the user is already using it.
Categorize as:

- **Already using** - skip
- **Relevant but not using** - recommend with specific suggestion
- **Not relevant to this scope** - skip

Focus on these feature categories (sorted by typical user impact):

**High impact - check first:**
1. New hook events (StopFailure, CwdChanged, FileChanged, TaskCreated, ConfigChange, InstructionsLoaded) - are they using all relevant events?
2. Path-scoped rules (`.claude/rules/` with glob patterns) - targeted instructions per file type
3. New slash commands and keybindings (transcript search, `/copy N`, `Ctrl+X Ctrl+E`, chord bindings)
4. Permission improvements (conditional `if` on hooks, compound bash rules, deny rule enforcement)
5. Skill/agent frontmatter (effort, maxTurns, disallowedTools, initialPrompt, disable-model-invocation)

**Medium impact:**
6. Settings features (conditional hooks, bare mode for scripting, `--console` auth)
7. Tool behavior changes (Read format, Bash permission patterns, tool streaming, `@` mention improvements)
8. Memory and context improvements (MEMORY.md truncation, token display, context compaction fixes)
9. Notification/UI features (statusline `rate_limits`, terminal notifications in tmux, idle-return prompt)

**Niche - only if relevant to the user's setup:**
10. Plugin development (userConfig, CLAUDE_PLUGIN_DATA, channels, plugin settings)
11. MCP improvements (OAuth, elicitation, deduplication, CIMD)
12. Enterprise/team features (managed-settings.d, allowedChannelPlugins, policy enforcement)

For **project-only mode**: prioritize features relevant to the project's tech stack.
For **all-repos mode**: flag features that could benefit multiple repos (e.g., "3 of your repos have Python but none use ruff hooks").

## Step 4: Present recommendations

For each recommended feature:

```
### {Feature name}
Available since: {version}
Scope: {global / project-specific / cross-repo}
What it does: {one sentence}
How it helps: {specific to what you found in Step 2}
To adopt: {exact config/command to add}
```

Sort by impact (most useful first).

## Step 5: Offer to implement

After presenting, ask:
"Want me to implement any of these? (numbers, 'all', or 'none')"

For each approved item, make the change (add hook, update settings, etc.)
and tell the user to restart Claude Code if hooks were modified.

## Step 6: Update marker

After completing the run, save the current date, scope, and project:

```bash
echo "$(date +%Y-%m-%d) scope={project|all} project=$(pwd)" > ~/.claude/.whats-new-last-run
```

This way the next run knows what was already checked and for what scope.
If the previous run was project-only on repo A, and this run is project-only
on repo B, show all features (different project). If same project and scope,
only show features newer than the marker date.
