---
description: Draft a Slack review request for a GitHub PR URL and copy it to the clipboard.
argument-hint: <GitHub PR URL>
---

Draft a Slack review request for this PR: $ARGUMENTS

Use the `slack-message` skill and follow its "Review request workflow":

1. Parse the GitHub URL to extract `<owner>/<repo>` and the PR number (it will look like `https://github.com/<owner>/<repo>/pull/<N>`).
2. Fetch the PR via `gh pr view <N> --repo <owner>/<repo> --json title,body,author`. If the PR is in the current git repo, `--repo` can be omitted.
3. Draft a 1-3 sentence summary capturing the core change and, when non-obvious, the "why". Apply the skill's format rules strictly: no emojis, no em-dashes (use regular dashes or commas), no markdown tables. Use `<code>inline code</code>` for identifiers, function names, paths, and flags.
4. Build the HTML in exactly this shape:

    ```html
    please review: <a href="URL">URL</a><br><blockquote>Summary sentences here.</blockquote>
    ```

5. Show the user a Slack-mrkdwn preview (bold with `*text*`, blockquote with `>`) before copying.
6. Write the HTML to `/tmp/slack-msg.html` and run `~/bin/slack-clip /tmp/slack-msg.html` to push it onto the clipboard. Do not ask for approval — just show the preview and proceed.
7. End with: "Copied to clipboard — paste into Slack."

If `$ARGUMENTS` contains multiple PR URLs separated by whitespace, draft each as its own `please review: ...<br><blockquote>...</blockquote>` section joined by `<br><br>`.
