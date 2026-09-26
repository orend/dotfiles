# Global Codex Instructions

Applies to every Codex session (merged first, before any project `AGENTS.md`).

## Insights

In addition to completing the task, provide educational insights about the codebase along the way. Before and after writing code, give brief educational explanations about implementation choices using (with backticks):

"`★ Insight ─────────────────────────────────────`
[2-3 key educational points]
`─────────────────────────────────────────────────`"

Include these insights in the conversation, not in the codebase. Focus on insights specific to the code you just wrote or this codebase, rather than general programming concepts. Balance educational content with task completion, and keep each block to 2-3 points.

## Scope and completion

Treat a user request as authorization for routine, reversible implementation and
validation within its stated scope. Do not ask again for ordinary steps needed to
complete that work. Before reporting a change complete, run proportionate validation
and state the result and any remaining boundary. Ask before an irreversible or
external state change that the user has not explicitly authorized.

## RECON verification

Before reporting an ai-scribe-rags RECON / Smart Merge change done, or before pushing a
RECON branch, run `$recon-verify` from the changed worktree
(`recon_verify.py run --repo "$PWD"`) and report its per-rung result. Do not substitute a
hand-picked test command. If a rung is skipped or fails, say so.

## Agent routing

When the user asks to launch, delegate to, or use an agent, infer the agent type from
the requested work. Do not require the user to name an agent type. If the user names
an agent type explicitly, use that type when it is compatible with the task.

- A named skill that implements or repairs code, including `$implement-recon`, routes
  to `feature-implementer` unless the skill itself requires a different specialist.
- Pull-request review routes to `pr-reviewer`; read-only codebase or subsystem
  investigation routes to `research-investigator`.
- Focused mechanical work with objective acceptance criteria routes to
  `bounded-worker`. Bounded batch work that needs more judgment routes to
  `careful-worker`.
- Session-history pattern analysis routes to `session-analyzer`; broad recent-session
  mining routes to `session-explorer`; read-only Datadog incident investigation in a
  workspace that defines it routes to `datadog-miner`.
- Keep orchestration, task decomposition, ownership assignment, cross-agent synthesis,
  and final completion judgment in the root session. Give implementation workers
  explicit file or responsibility ownership and tell them to preserve concurrent work.

Skill selection and agent selection are independent: first honor every explicitly
named skill, then choose the configured agent whose responsibility matches that
skill's workflow. The user's request to run a skill through an agent is sufficient;
do not ask them to restate it with an agent-type name.

If the collaboration runtime rejects or does not expose the selected named agent
type, do not stop or ask the user to choose another type. Spawn a `default` agent
with the selected role's responsibilities in its prompt and apply these explicit
model settings:

- `feature-implementer` and `pr-reviewer`: GPT-6 Sol with `high` effort.
- `research-investigator`: GPT-6 Sol with `medium` effort.
- `bounded-worker` and `session-explorer`: GPT-6 Luna with `medium` effort.
- `careful-worker` and `session-analyzer`: GPT-6 Luna with `high` effort.
- `datadog-miner`: GPT-6 Sol with `high` effort.

Use a fresh or bounded history fork when an explicit model override is required, and
include all task, skill, ownership, safety, and verification context needed by that
agent. Treat this fallback as equivalent routing, not as permission to weaken the
selected role's constraints.

## Commit messages

Whenever you create a Git commit, use a concise Conventional Commit subject:
`type(scope): imperative summary`. The scope is optional; use a standard lowercase
type such as `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, or `ci`. Keep the
subject at most 72 characters, lowercase after the colon, and without a trailing
period. Add a body only when non-obvious context is needed. Never create a commit
with an empty, generic, or omitted message. This rule governs message quality only;
it does not authorize or require making a commit.

## AI Scribe worktree Python

AI Scribe worktrees are deliberately source-only. Do not probe for, create, or report
a missing worktree-local `.venv` as an environment issue. This rule overrides older
skill examples that spell `.venv/bin/python`.

- For a RAG `make` verification target, pass its canonical interpreter explicitly:
  `make test PYTHON=/Users/oren.dobzinski/lib/scribe/ai-scribe-rags/.venv/bin/python`.
  Use the direct canonical command below for model and eval worktrees, whose legacy
  Makefiles/setup guides may create a local environment.
- For direct or focused commands, run the canonical interpreter for the repository from
  the worktree root, with `PYTHONPATH="$PWD"` when imports need the repository root:
  - RAGs: `/Users/oren.dobzinski/lib/scribe/ai-scribe-rags/.venv/bin/python`
  - Model: `/Users/oren.dobzinski/lib/scribe/ai-scribe-model/.venv/bin/python`
  - Evals: `/Users/oren.dobzinski/lib/scribe/ai-scribe-evals/.venv/bin/python`
- If a canonical interpreter is unavailable or cannot import a required dependency, report
  that concrete failure. Do not first run an intentionally nonexistent `.venv` path.
