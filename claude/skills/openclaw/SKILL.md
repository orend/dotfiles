---
name: openclaw
description: >
  Manage OpenClaw on the Mac Mini - start gateway, open dashboard, troubleshoot connectivity.
  Use when user says "openclaw", "open openclaw", "connect to openclaw", "openclaw dashboard",
  or reports OpenClaw connection issues.
user-invocable: true
---

# OpenClaw on Mac Mini

OpenClaw runs on a Mac Mini (oren@192.168.1.13). The gateway listens on port 18789.
Access from the laptop is via SSH tunnel.

## Architecture

- **Gateway**: managed by a LaunchAgent (`~/Library/LaunchAgents/ai.openclaw.gateway.plist`). Control with `openclaw gateway start/stop/restart/status`.
- **Dashboard** (`openclaw dashboard`): just prints the UI URL and token, does not start a server
- **Token**: lives in `~/.openclaw/openclaw.json` at `gateway.auth.token`
- **Tunnel**: SSH port forward from laptop localhost:18789 to Mac Mini localhost:18789, runs in a local tmux session named `openclaw`

## Prerequisites

The laptop must be on the **orbi38** wifi network to reach the Mac Mini at 192.168.1.13.
Remind the user to check their wifi if SSH connections fail.

## Quick start

When the user asks to connect to OpenClaw, run the script directly:

```bash
openclaw-tunnel
```

This will:
1. Check if the gateway is running on the Mac Mini (via `openclaw health`)
2. If down, start it via the LaunchAgent (`openclaw gateway start`)
3. Read the dashboard token from `~/.openclaw/openclaw.json`
4. Set up an SSH tunnel in a local tmux session
5. Open the dashboard in the browser with the token

If the script isn't available or you need finer control, you can run the steps manually using the commands in the sections below.

## Common operations

### Check tunnel status
```bash
openclaw-status
```

### Stop the tunnel
```bash
openclaw-stop
```

### Gateway control (on Mac Mini)
```bash
ssh oren@192.168.1.13 "export PATH=/opt/homebrew/bin:\$PATH; openclaw gateway status"
ssh oren@192.168.1.13 "export PATH=/opt/homebrew/bin:\$PATH; openclaw gateway start"
ssh oren@192.168.1.13 "export PATH=/opt/homebrew/bin:\$PATH; openclaw gateway restart"
```

### Check gateway health
```bash
ssh oren@192.168.1.13 "export PATH=/opt/homebrew/bin:\$PATH; openclaw health"
```

### Get token
```bash
ssh oren@192.168.1.13 "jq -r '.gateway.auth.token' ~/.openclaw/openclaw.json"
```

## Troubleshooting

### "disconnected (1006): no reason"
The gateway crashed or was restarted (e.g. after an update). Restart the gateway on the Mac Mini with `openclaw gateway restart`, then re-run `openclaw-tunnel`.

### "site can't be reached"
The tunnel is down or the gateway isn't running. Run `openclaw-tunnel` to fix both.

### PATH issues on Mac Mini
SSH non-login shells don't have `/opt/homebrew/bin` in PATH. Always prefix remote commands with `export PATH=/opt/homebrew/bin:$PATH`.

## Key details

- Mac Mini: oren@192.168.1.13
- OpenClaw binary: /opt/homebrew/bin/openclaw
- OpenClaw config: ~/.openclaw/openclaw.json
- LaunchAgent: ~/Library/LaunchAgents/ai.openclaw.gateway.plist
- Gateway port: 18789
- Aliases defined in bash/aliases: `openclaw-stop`, `openclaw-status`
- Tunnel script: ~/bin/openclaw-tunnel (source: ~/bin/dotfiles/openclaw-tunnel)
