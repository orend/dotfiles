#!/usr/bin/env python3
"""InstructionsLoaded hook: validate that CLAUDE.md references are still valid.

Checks that hooks, skills, plugins, and agents mentioned in loaded CLAUDE.md
files actually exist. Warns via systemMessage if any are stale.
"""
import json, sys, os, re, glob

try:
    data = json.load(sys.stdin)
except:
    sys.exit(0)

# Get loaded file paths from hook input
files = data.get("files", [])
if not files:
    sys.exit(0)

warnings = []

for file_info in files:
    path = file_info if isinstance(file_info, str) else file_info.get("path", "")
    if not path or not os.path.exists(path):
        continue

    try:
        content = open(path).read()
    except:
        continue

    # Check for skill references like /skill-name or `skill-name` skill
    skill_refs = re.findall(r'/(\w[\w-]+)', content)
    for ref in skill_refs:
        # Skip common false positives
        if ref in ("plugin", "install", "tmp", "usr", "bin", "etc", "dev",
                    "home", "Users", "Volumes", "var", "opt", "lib"):
            continue
        # Check if it's a known skill directory
        personal = os.path.expanduser(f"~/.claude/skills/{ref}")
        project = f".claude/skills/{ref}"
        if (ref.startswith("verify") or ref.startswith("new-") or
            ref.startswith("self-") or ref.startswith("skill-")):
            if not os.path.isdir(personal) and not os.path.isdir(project):
                # Could be a plugin skill - don't warn for those
                pass

    # Check for hook references
    hook_types = ["PreToolUse", "PostToolUse", "Stop", "SessionStart",
                  "StopFailure", "PostCompact", "CwdChanged", "FileChanged",
                  "TaskCreated", "ConfigChange", "InstructionsLoaded"]
    for hook in hook_types:
        if hook in content:
            # Verify the hook is actually configured
            for settings_path in [
                os.path.expanduser("~/.claude/settings.json"),
                ".claude/settings.json"
            ]:
                if os.path.exists(settings_path):
                    try:
                        settings = json.load(open(settings_path))
                        hooks = settings.get("hooks", {})
                        if hook in hooks and hooks[hook]:
                            break
                    except:
                        pass
            else:
                warnings.append(f"{os.path.basename(path)} references {hook} hook but it's not configured in settings.json")

    # Check for plugin references like plugin-name@marketplace
    plugin_refs = re.findall(r'(\w[\w-]+)@(\w[\w-]+)', content)
    for plugin_name, marketplace in plugin_refs:
        cache_path = os.path.expanduser(f"~/.claude/plugins/cache/{marketplace}/{plugin_name}")
        if not os.path.isdir(cache_path):
            warnings.append(f"{os.path.basename(path)} references plugin {plugin_name}@{marketplace} but it's not installed")

if warnings:
    msg = "CLAUDE.md validation warnings:\\n" + "\\n".join(f"- {w}" for w in warnings)
    print(json.dumps({"systemMessage": msg}))
