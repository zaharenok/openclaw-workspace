---
name: openclaw-browser
description: Scripted OpenClaw browser setup on a VPS with VNC+Chrome. Trigger: when user asks to deploy a browser-driven OpenClaw agent; installs GUI, VNC, starts XFCE, Chrome with remote debugging for OpenClaw browser control.
---

# OpenClaw Browser Skill

This skill provides a VNC-based browser environment for OpenClaw automation. It includes setup scripts for visual browser access via VNC.

## Bundled Resources

- **scripts/complete-setup.sh** - One-command full installation (VNC+XFCE+Chrome)
- **docs/commands.md** - Manual step-by-step commands reference

## Quick Start

Run complete setup:
```bash
bash /root/.openclaw/workspace/skills/openclaw-browser/scripts/complete-setup.sh
```

Then connect OpenClaw to Chrome:
```bash
openclaw browser start
```

## Setup Components

The script installs:

1. **GUI Environment**: XFCE4 desktop with VNC server
2. **VNC Server**: Display :2 on port 5902 (accessible via 100.116.28.26:5902)
3. **Chrome**: With remote debugging on port 18800 for OpenClaw control

## Manual Setup (Step-by-Step)

If you prefer to run commands individually:

```bash
# 1. Install GUI/VNC packages
apt update && apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils tigervnc-standalone-server tigervnc-common

# 2. Start VNC server
vncserver :2 -geometry 1280x1024 -depth 24 -localhost no

# 3. Start XFCE desktop
export DISPLAY=:2 && startxfce4 &

# Wait for XFCE to start (10 seconds)

# 4. Start Chrome for OpenClaw
export DISPLAY=:2 && google-chrome-stable --remote-debugging-port=18800 --no-sandbox --user-data-dir=/tmp/openclaw-browser &

# 5. Connect OpenClaw to Chrome
openclaw browser start
```

## VNC Connection

- **Host**: 100.116.28.26
- **Port**: 5902
- **Display**: :2
- **Connection string**: `100.116.28.26:5902`

Use any VNC client (RealVNC, TigerVNC, Remmina, etc.) to connect.

## Notes

- Chrome runs with `--no-sandbox` for VNC compatibility
- Remote debugging port 18800 allows OpenClaw to control Chrome via CDP
- Display :2 is used to avoid conflicts with other X11 sessions
- After setup, use `openclaw browser` commands to control the browser
