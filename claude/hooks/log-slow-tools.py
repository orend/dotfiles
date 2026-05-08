#!/usr/bin/env python3
"""PostToolUse hook: log tool calls that took longer than 30s."""
import json, sys, os
from datetime import datetime

data = json.load(sys.stdin)
duration_ms = data.get("duration_ms", 0)
if duration_ms < 30000:
    sys.exit(0)

tool = data.get("tool_name", "unknown")
duration_s = duration_ms / 1000
ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
log = os.path.expanduser("~/.claude/slow-tools.log")

with open(log, "a") as f:
    f.write(f"{ts}  {duration_s:6.1f}s  {tool}\n")
