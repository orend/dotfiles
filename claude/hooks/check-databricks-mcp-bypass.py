#!/usr/bin/env python3
"""PreToolUse hook for Bash: keep Databricks SQL on the AI Dev Kit MCP.

Blocks the unambiguous "run SQL without the MCP" INVOCATIONS, because the
execute_sql MCP tool fully covers them (auth + profile mmic + Starter
Warehouse) and a non-blocking nudge here failed across two self-improve
scans (2026-05-15 and 2026-06-26): raw `databricks api post
/api/2.0/sql/statements` and the invented `databricks sql execute`
subcommand kept recurring. These are always wrong, so they hard-block.

Matching is anchored at a command boundary (start of command, or right
after ;, &, |, or a subshell paren), so merely MENTIONING these strings
(a commit message, grep, echo, a heredoc of docs) does NOT trip the block;
only an actual invocation does.

SQL-only on purpose. Non-SQL Databricks REST (AI Gateway, MLflow,
serving-endpoint invocation) genuinely is NOT exposed by the MCP; that
goes through the `databricks-gateway-call` skill (token + curl), so it is
deliberately not matched here. If you must run raw SQL (e.g. debugging the
MCP itself), disable this hook for the run.

Input  : tool-call JSON on stdin.
Output : exit 0; JSON {"decision": "block", "reason": ...} when matched.
"""
import json
import re
import sys

# Command-boundary prefix: start of string, or right after a shell separator
# (; & | or an opening subshell paren; && and || are covered by & and |).
# Intentionally NOT a plain word boundary, so documentation/commit messages
# that merely quote these patterns mid-line are not blocked.
_B = r"(?:^|[;&|(])\s*"

PATTERNS = [
    (re.compile(_B + r"databricks\s+sql\s+(?:execute|query)\b"),
     "the invented `databricks sql ...` subcommand (the CLI has no `sql` command)"),
    (re.compile(_B + r"databricks\s+api\s+(?:post|get)\b[^\n]*?/api/2\.0/sql/statements\b"),
     "the raw `databricks api ... /api/2.0/sql/statements` call"),
    (re.compile(_B + r"curl\b[^\n]*?/api/2\.0/sql/statements\b"),
     "a raw curl to /api/2.0/sql/statements"),
]


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    if data.get("tool_name") != "Bash":
        sys.exit(0)

    command = (data.get("tool_input") or {}).get("command", "") or ""

    matched = next(
        (label for rx, label in PATTERNS if rx.search(command)),
        None,
    )
    if not matched:
        sys.exit(0)

    print(json.dumps({
        "decision": "block",
        "reason": (
            f"This runs SQL via {matched}, which bypasses the Databricks AI Dev "
            f"Kit MCP. Use the "
            f"`mcp__plugin_databricks-ai-dev-kit_databricks__execute_sql` tool "
            f"instead: it handles auth, the mmic profile, and Starter Warehouse "
            f"selection automatically. (Non-SQL Databricks REST like AI Gateway / "
            f"MLflow is not blocked here; use the databricks-gateway-call skill.)"
        ),
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
