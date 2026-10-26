# Claude model routing

Use the explicit `claude-opus-5-5` model ID in settings and noninteractive workers:

```bash
claude -p --model claude-opus-5-5 --effort high --output-format json 'Your task'
```

The installed `claude-opus` launcher supplies that explicit model and forwards
arguments unchanged. Use `claude-opus -p --effort high --output-format json`
for workers, or `claude-opus` for an interactive session.

On October 26, 2026, the `opus` alias resolved to
`system.ai.claude-opus-5-5[1m]`, which the configured API rejected. Setting
`CLAUDE_CODE_DISABLE_1M_CONTEXT=1` did not change that resolution. The explicit
ID completed a bounded request and reported `canonicalModel: claude-opus-5-5`.
This is a model-ID routing workaround, not evidence of a context-size limit.

The bad alias comes from the root-owned managed settings at
`/Library/Application Support/ClaudeCode/managed-settings.json`. A default-model
probe still selected the unavailable managed Sonnet alias despite the user model
setting; `--settings` with just `model` did not repair that either. Use the explicit
CLI model rather than treating a user settings edit alone as a verified fix.
The launcher preserves managed authentication, permissions and gateway settings.
Changing the managed alias mapping itself requires its administrator.

When checking a route, inspect `modelUsage` in the JSON result. An unavailable
model error with empty usage does not establish that a worker ran. Do not switch
model versions silently. Recheck the alias before returning to it.

Runtime settings are local; preserve other fields when updating
`~/.claude/settings.json`. This repository's settings file is the portable source.
