---
description: Commit, push, create a PR, and draft a Slack review request. Or pass a PR URL to skip straight to the Slack message.
argument-hint: [GitHub PR URL]
---

## Routing

- **With arguments** (`$ARGUMENTS` is not empty): treat each argument as a GitHub PR URL and skip to the "Draft Slack Message" section below.
- **Without arguments** (`$ARGUMENTS` is empty): run the full "Ship and Request Review" flow.

---

## Ship and Request Review (no arguments)

Run these steps in order. Stop and tell the user if any step fails.

### 1. Stage and commit

1. Run `git status` and `git diff` (staged + unstaged) to see what changed.
2. Run `git log --oneline -5` to match the repo's commit-message style.
3. Stage the relevant changed files (prefer named files over `git add -A`). Do NOT stage files that look like secrets (`.env`, credentials).
4. Draft a concise commit message (1-2 sentences, "why" over "what"). Append:
   ```
   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   ```
5. Commit. If a pre-commit hook fails, fix the issue and create a NEW commit (never `--amend`).

### 2. Create branch and push

1. If already on a feature branch (not `main`/`master`), reuse it. Otherwise create one: `git checkout -b <descriptive-branch-name>`.
   - Exception: the notes repo (`~/lib/notes`) allows commits directly to master, so skip branch creation there.
2. `git push -u origin HEAD`

### 3. Create PR

1. Run `git log main..HEAD --oneline` (or `master..HEAD`) to see all commits on the branch.
2. Draft a PR title (under 70 characters) and body using this template:

    ```
    ## Summary
    <1-3 bullet points>

    ## Test plan
    <bulleted checklist>

    Generated with [Claude Code](https://claude.com/claude-code)
    ```

3. Create the PR:

    ```bash
    cat > /tmp/pr_body.md << 'EOF'
    <body content>
    EOF
    gh pr create --title "<title>" --body-file /tmp/pr_body.md --base main
    ```

   Use `--body-file` (never inline `--body` with markdown - zsh mangles it).

4. Capture the PR URL from the output.

### 4. Draft Slack message

Fall through to the "Draft Slack Message" section below, using the PR URL from step 3.

---

## Draft Slack Message

Use the `slack-message` skill and follow its "Review request workflow":

1. Parse the GitHub URL to extract `<owner>/<repo>` and the PR number (it will look like `https://github.com/<owner>/<repo>/pull/<N>`).
2. Fetch the PR via `gh pr view <N> --repo <owner>/<repo> --json title,body,author`. If the PR is in the current git repo, `--repo` can be omitted.
3. Draft a 1-3 sentence summary capturing the core change and, when non-obvious, the "why". Apply the skill's format rules strictly: no emojis, no em-dashes (use regular dashes or commas), no markdown tables. Use `<code>inline code</code>` for identifiers, function names, paths, and flags.
4. Build the HTML in exactly this shape:

    ```html
    please review: <a href="URL">URL</a><br><blockquote>Summary sentences here.</blockquote>
    ```

5. Show the user a Slack-mrkdwn preview (bold with `*text*`, blockquote with `>`) before copying.
6. Write the HTML to a timestamped temp file and run `~/bin/slack-clip` to push it onto the clipboard. Do not ask for approval - just show the preview and proceed.

    ```bash
    SLACK_FILE="/tmp/slack-msg-$(date +%H%M%S).html"
    cat > "$SLACK_FILE" << 'SLACKEOF'
    <your html here>
    SLACKEOF
    ~/bin/slack-clip "$SLACK_FILE"
    ```

7. End with: "Copied to clipboard - paste into Slack."

If multiple PR URLs are provided, draft each as its own `please review: ...<br><blockquote>...</blockquote>` section joined by `<br><br>`.
