# Global Claude Instructions

## Scope and completion

Treat a user request as authorization for routine, reversible implementation and
validation within its stated scope. Do not ask again for ordinary steps needed to
complete that work. Before reporting a change complete, run proportionate validation
and state the result and any remaining boundary. Ask before an irreversible or
external state change that the user has not explicitly authorized.

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
