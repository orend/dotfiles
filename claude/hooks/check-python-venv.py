#!/usr/bin/env python3
"""PreToolUse hook for Bash: block python/pytest invocations when the
project has a .venv that isn't active, and tell Claude exactly how to
retry. The self-improve detector found 53 venv-related failures across
projects and explicitly said the right fix is a precondition check, not
a manual reminder, so this hook denies-with-instruction rather than
warning-and-allowing.

Second check: when there is NO project .venv, a bare `python`/`pip` (not
python3/pip3) is nudged toward python3/pip3. On macOS there is no bare
`python` on PATH, so it exits 127 (command not found). That nudge is
non-blocking (self-improve 2026-06-26 found 27 such command-not-found
failures across 3 repos).

SAFE_PATTERNS keeps one-shot diagnostics (``python3 -c``, ``-V``,
``which python``, explicit absolute paths) from being blocked, since
those don't need the project venv.

Input  : tool-call JSON on stdin (tool_name, tool_input).
Output : exit 0 + JSON {"decision": "block", "reason": "..."} when blocking;
         exit 0 + JSON {"systemMessage": "..."} for the bare-python nudge;
         exit 0 silently otherwise.
"""
import json
import os
import re
import sys
from pathlib import Path

PYTHON_CMD = re.compile(
    r"(?:^|[\s|;&(])(?:python3?|pytest|uv\s+run\s+(?:pytest|python))(?:\s|$)"
)

# Bare `python`/`pip` (NOT python3/pip3, NOT pipenv/ipython) used as an actual
# command (start of line or right after a shell separator), so the word
# "python" inside a commit message or echo does not trip the nudge.
BARE_PY_PIP = re.compile(r"(?:^|[;&|(])\s*(?:python|pip)(?![\w])")

# Invocations that legitimately don't need a project venv:
#  - version probes
#  - one-shot ``-c`` snippets (stdlib only is the common case)
#  - explicit absolute python paths (user is overriding deliberately)
SAFE_PATTERNS = re.compile(
    r"(?:^|\s)("
    r"python3?\s+-V\b|"
    r"python3?\s+--version\b|"
    r"python3?\s+-c\s|"
    r"which\s+python|"
    r"\.venv/bin/python|"
    r"venv/bin/python|"
    r"/usr/bin/python|"
    r"/opt/[^\s]*/python|"
    r"/Library/Frameworks/Python"
    r")"
)

ACTIVATES_VENV = re.compile(
    r"(?:^|\s|;|&&|\|\|)(?:source|\.)\s+[^\s]*venv/bin/activate"
)


def find_venv(start_dir):
    """Walk up from start_dir looking for a .venv/ directory.

    Stops at /, $HOME, or after 6 levels (more is almost certainly noise)."""
    try:
        p = Path(start_dir).resolve()
    except (OSError, RuntimeError):
        return None
    home = Path.home()
    for _ in range(6):
        if (p / ".venv").is_dir():
            return p / ".venv"
        if p == Path("/") or p == home:
            break
        p = p.parent
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    if data.get("tool_name") != "Bash":
        sys.exit(0)

    command = (data.get("tool_input") or {}).get("command", "") or ""

    if not PYTHON_CMD.search(command) and not BARE_PY_PIP.search(command):
        sys.exit(0)
    if SAFE_PATTERNS.search(command):
        sys.exit(0)
    if ACTIVATES_VENV.search(command):
        sys.exit(0)

    cwd = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    venv_dir = find_venv(cwd)

    if not venv_dir:
        # No project venv to activate. A bare `python`/`pip` still fails on macOS
        # (no such binary on PATH), so nudge toward python3/pip3 without blocking.
        if BARE_PY_PIP.search(command) and not os.environ.get("VIRTUAL_ENV"):
            print(json.dumps({
                "systemMessage": (
                    "On macOS there is no bare `python`/`pip` on PATH; use "
                    "`python3`/`pip3` (or activate a project .venv, e.g. "
                    "`.venv/bin/python`). Bare `python` exits 127 (command not found)."
                ),
            }))
        sys.exit(0)

    # A project venv exists. Only python3/pytest invocations need it active.
    if not PYTHON_CMD.search(command):
        sys.exit(0)

    virtual_env = os.environ.get("VIRTUAL_ENV", "")
    if virtual_env:
        try:
            if Path(virtual_env).resolve() == venv_dir.resolve():
                sys.exit(0)
        except (OSError, RuntimeError):
            pass

    try:
        rel = venv_dir.relative_to(Path(cwd))
        venv_disp = str(rel)
    except ValueError:
        venv_disp = str(venv_dir)

    print(json.dumps({
        "decision": "block",
        "reason": (
            f"Project venv at `{venv_disp}` is not active "
            f"(VIRTUAL_ENV={'unset' if not virtual_env else virtual_env}). "
            f"Retry with one of:\n"
            f"  source {venv_disp}/bin/activate && <command>\n"
            f"  {venv_disp}/bin/python <args>\n"
            f"  {venv_disp}/bin/pytest <args>\n"
            f"This is enforced because ~53 venv-related failures showed up "
            f"in a self-improve scan. If you genuinely need the system "
            f"python (one-shot diagnostic), use `python3 -c '...'` or call "
            f"`/usr/bin/python3` explicitly; both bypass this check."
        ),
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
