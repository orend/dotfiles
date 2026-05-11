#!/usr/bin/env python3
"""PostToolUse hook for Bash: surface Python tracebacks and Pydantic
deprecation warnings as a structured systemMessage so Claude self-corrects
on the next turn instead of glossing over them in long stdout.

Input  : tool-call JSON on stdin (tool_name, tool_input, tool_output).
Output : exit 0 + optional JSON {"systemMessage": ...} on stdout.

Also appends a one-line record per detection to
``~/.claude/tracebacks.log`` so the next /self-improve scan can see
whether the pattern is still bleeding into sessions.
"""
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

LOG_PATH = Path(os.path.expanduser("~/.claude/tracebacks.log"))

# Patterns we care about. Order matters: more-specific first.
PATTERNS = [
    # Standard CPython traceback header. Anchored at line-start so we
    # don't match the phrase appearing in docs / test fixtures.
    (re.compile(r"^Traceback \(most recent call last\):", re.MULTILINE), "python_traceback"),
    # Pydantic v2 deprecation chatter — observed 9x in last self-improve scan.
    (re.compile(r"PydanticDeprecatedSince\d+"), "pydantic_deprecation"),
    # Node.js GitHub Action deprecation — observed 8x.
    (re.compile(r"Node\.js \d+ actions are deprecated"), "node_action_deprecation"),
]

# Bash commands that legitimately produce tracebacks as part of normal
# operation. Skip the warning when the command matches any of these.
EXPECTED_TRACEBACK_COMMANDS = re.compile(
    r"\b(pytest|unittest|make test|python -m unittest|tox|nox|"
    r"poetry run pytest|uv run pytest)\b"
)


def extract_last_traceback(text):
    """Return the last python traceback in *text* as (error_class, error_msg, top_frame)
    or (None, None, None) if no traceback is present.

    "Last" because chained tracebacks (caused by …) end with the real cause."""
    blocks = list(re.finditer(r"^Traceback \(most recent call last\):", text, re.MULTILINE))
    if not blocks:
        return (None, None, None)
    start = blocks[-1].start()
    block = text[start:start + 4000]  # cap at 4 KB — final-line summary is what we want
    # Final non-empty line of the block is "ErrorClass: message"
    final_line = next(
        (l for l in reversed(block.splitlines()) if l.strip() and ":" in l),
        ""
    )
    m = re.match(r"^(?:[\w.]+\.)?(\w*(?:Error|Warning|Exception))\s*:\s*(.+)$", final_line)
    error_class, error_msg = (m.group(1), m.group(2).strip()) if m else (None, final_line.strip())
    # Top frame for context — the first 'File "..."' line in the block
    frame_match = re.search(r'File "([^"]+)", line (\d+)(?:, in (\S+))?', block)
    top_frame = (
        f'{frame_match.group(1)}:{frame_match.group(2)}'
        + (f' in {frame_match.group(3)}' if frame_match and frame_match.group(3) else '')
        if frame_match
        else None
    )
    return (error_class, error_msg, top_frame)


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    if data.get("tool_name") != "Bash":
        sys.exit(0)

    command = (data.get("tool_input") or {}).get("command", "")
    if EXPECTED_TRACEBACK_COMMANDS.search(command):
        sys.exit(0)

    output = data.get("tool_output") or ""
    if not isinstance(output, str):
        output = str(output)
    if len(output) < 30:
        sys.exit(0)

    hits = []
    for pat, kind in PATTERNS:
        if pat.search(output):
            hits.append(kind)

    if not hits:
        sys.exit(0)

    # Build a structured systemMessage. Keep it short — every char counts in
    # Claude's context. Mention the kind and the diagnostic so Claude can
    # ground its next action.
    parts = []
    if "python_traceback" in hits:
        cls, msg, frame = extract_last_traceback(output)
        if cls:
            line = f"Python {cls}: {msg}"
            if frame:
                line += f" — {frame}"
            parts.append(line)
        else:
            parts.append("Python traceback detected (no parseable summary)")
    if "pydantic_deprecation" in hits:
        parts.append("Pydantic v2 deprecation warning — replace .parse_obj / .dict / .json with .model_validate / .model_dump / .model_dump_json")
    if "node_action_deprecation" in hits:
        parts.append("Node.js action deprecation warning — bump the GitHub Action to Node 20 or 22")

    body = " · ".join(parts)
    # Cap to keep context-friendly.
    if len(body) > 360:
        body = body[:357] + "…"

    # Log for /self-improve consumption.
    try:
        LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        with LOG_PATH.open("a", encoding="utf-8") as f:
            ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            kinds = ",".join(hits)
            f.write(f"{ts}\t{kinds}\t{body}\n")
    except OSError:
        pass

    print(json.dumps({
        "systemMessage": (
            f"Hook caught a diagnostic in the last Bash output: {body}. "
            "Inspect and fix on this turn — don't ship until clean."
        )
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
