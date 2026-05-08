---
name: slack-message
description: >
  Draft concise Slack messages from recent context (PRs, features, announcements).
  Use when user says "slack message", "write a slack message", "share on slack",
  or asks to summarize work for the team.
user-invocable: true
---

# Slack Message Drafter

Draft a concise Slack message and copy it to the clipboard with rich text formatting.

## Format rules

- No emojis
- No em dashes - use regular dashes or commas
- No markdown tables - Slack doesn't render them
- 1-3 sentences unless the user asks for more
- Include relevant links (PR URLs, doc links) inline

## Clipboard copy (rich text)

Always use this approach to copy to clipboard. It puts HTML on the macOS clipboard,
which Slack renders as formatted text when pasted.

IMPORTANT: You MUST set `dangerouslyDisableSandbox: true` on the Bash call because
osascript needs system UI access which the sandbox blocks.

Write the HTML to a timestamped temp file first, then call slack-clip with the file path.
Use a timestamp suffix so successive messages don't overwrite each other.

```bash
# Step 1: Write HTML to timestamped temp file (sandboxed, no approval needed)
cat > /tmp/slack-msg-$(date +%H%M%S).html << 'SLACKEOF'
<your html here>
SLACKEOF

# Step 2: Copy to clipboard (needs dangerouslyDisableSandbox: true)
~/bin/slack-clip /tmp/slack-msg-$(date +%H%M%S).html
```

**Important:** capture the filename in a variable so both steps use the same path:

```bash
# Step 1:
SLACK_FILE="/tmp/slack-msg-$(date +%H%M%S).html"
cat > "$SLACK_FILE" << 'SLACKEOF'
<your html here>
SLACKEOF

# Step 2: (needs dangerouslyDisableSandbox: true)
~/bin/slack-clip "$SLACK_FILE"
```

### HTML formatting for Slack

| Slack renders as | Use HTML |
|-----------------|----------|
| **bold** | `<b>text</b>` |
| _italic_ | `<i>text</i>` |
| `code` | `<code>text</code>` |
| blockquote | `<blockquote>text</blockquote>` |
| link | `<a href="url">text</a>` |
| line break | `<br>` |

Do NOT use mrkdwn syntax (*, `, >) - it won't render from pasted text.

## Workflow

1. Identify what the user wants to communicate
2. Draft the message
3. Show a preview to the user using Slack mrkdwn formatting (bold with *text*, bullet lists)
4. Convert to HTML
5. Copy to clipboard using the hexdump/osascript approach above
6. Tell the user "Copied to clipboard - paste into Slack"

## Examples

**PR announcement:**
```html
Merged PR #300: GI L2 support. Chose Option A (status quo handler) after analyzing 4 approaches - details in the PR description. No changes needed for existing specialties.
```

**Review request:**
```html
please review: <a href="https://github.com/modmed/ai-platform-dev-tools/pull/28">https://github.com/modmed/ai-platform-dev-tools/pull/28</a><br><blockquote>Adds <code>claude plugin validate</code> as a step in <code>/verify-plugin</code>. Catches structural issues like broken YAML frontmatter that silently drops skill metadata at runtime.</blockquote>
```

For multiple PRs, separate with `<br><br>`:
```html
please review: <a href="URL1">URL1</a><br><blockquote>Summary 1</blockquote><br><br>please review: <a href="URL2">URL2</a><br><blockquote>Summary 2</blockquote>
```

## Review request workflow

When the user asks for a review request or says "request review":

1. Find open PRs by the user: `gh pr list --author @me --state open --json number,url,title,body`
2. If in a specific repo, filter to that repo. If not, ask which PRs to include.
3. For each PR: URL as link, summary in blockquote with code formatting where appropriate
4. Copy to clipboard using the HTML approach
5. Tell the user "Copied to clipboard - paste into Slack"

## Posting directly via Slack MCP

When the user asks to **post to a channel or DM** (not just copy to clipboard), use the `slack_send_message` MCP tool with **mrkdwn formatting** — NOT the HTML clipboard approach.

**Critical mrkdwn rules for `slack_send_message`:**
- Blockquote: `>text` on its own line (never use `&gt;` — that is an HTML entity and will render literally)
- Inline code: `` `text` `` (backticks)
- Bold: `*text*`
- Links: plain URL — Slack auto-links (no `<a href>` tags)
- Line breaks: actual `\n` in the string

**Review request format for direct posting:**
```
please review: https://github.com/modmed/org/pull/N
>Summary sentence. Second sentence if needed.
```

The `>` must be at the start of a new line with no space before it. Example call:
```
slack_send_message(channel_id=..., message="please review: https://...\n>Summary here.")
```

Always show a preview before posting and confirm the channel/recipient.
