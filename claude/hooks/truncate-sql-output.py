#!/usr/bin/env python3
"""PostToolUse hook: truncate large execute_sql results to keep context small."""
import json, sys

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
if "execute_sql" not in tool:
    sys.exit(0)

output = data.get("tool_output", "")
if not isinstance(output, str):
    sys.exit(0)

lines = output.split("\n")
if len(lines) <= 60:
    sys.exit(0)

header = lines[:3]
body = [l for l in lines[3:] if l.strip()]
if len(body) <= 40:
    sys.exit(0)

truncated = header + body[:20] + [
    f"\n... ({len(body) - 20} more rows truncated, {len(body)} total) ..."
]
print(json.dumps({"output": "\n".join(truncated)}))
