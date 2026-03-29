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

```bash
HTML='<your html here>'
echo "$HTML" | hexdump -ve '1/1 "%.2x"' | xargs printf "set the clipboard to {text:\" \", «class HTML»:«data HTML%s»}" | osascript -
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
3. Convert to HTML
4. Copy to clipboard using the hexdump/osascript approach above
5. Tell the user "Copied to clipboard - paste into Slack"

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
