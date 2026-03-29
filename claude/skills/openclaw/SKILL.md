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

- **Gateway** (`openclaw gateway`): the actual server process, runs on the Mac Mini
- **Dashboard** (`openclaw dashboard`): just prints the UI URL and token, does not start a server
- **Tunnel**: SSH port forward from laptop localhost:18789 to Mac Mini localhost:18789
- The tunnel runs in a local tmux session named `openclaw`
- The gateway runs in a remote tmux session named `openclaw` on the Mac Mini

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
2. If down, start it in a tmux session on the Mac Mini
3. Grab the dashboard token
4. Set up an SSH tunnel in a local tmux session
5. Open the dashboard in the browser with the token

If the script isn't available or you need finer control, you can run the steps manually using the commands in the sections below.

## Common operations

### Check tunnel status
```bash
tmux has-session -t openclaw 2>/dev/null && echo "running" || echo "not running"
# or use the alias:
openclaw-status
```

### Stop the tunnel
```bash
tmux kill-session -t openclaw
# or use the alias:
openclaw-stop
```

### Restart the gateway (on Mac Mini)
```bash
ssh oren@192.168.1.13 "export PATH=/opt/homebrew/bin:\$PATH; tmux kill-session -t openclaw; tmux new-session -d -s openclaw 'openclaw gateway --port 18789'"
```

### Check gateway health
```bash
ssh oren@192.168.1.13 "export PATH=/opt/homebrew/bin:\$PATH; openclaw health"
```

## Troubleshooting

### "disconnected (1006): no reason"
The gateway crashed or was restarted (e.g. after an update). Restart the gateway on the Mac Mini, then re-run `openclaw-tunnel`.

### "site can't be reached"
The tunnel is down or the gateway isn't running. Run `openclaw-tunnel` to fix both.

### PATH issues on Mac Mini
SSH non-login shells don't have `/opt/homebrew/bin` in PATH. Always prefix remote commands with `export PATH=/opt/homebrew/bin:$PATH` or use the full path `/opt/homebrew/bin/openclaw`.

## Key details

- Mac Mini: oren@192.168.1.13
- OpenClaw binary: /opt/homebrew/bin/openclaw
- Gateway port: 18789
- Aliases defined in bash/aliases: `openclaw-stop`, `openclaw-status`
- Tunnel script: ~/bin/openclaw-tunnel (source: ~/bin/dotfiles/openclaw-tunnel)
