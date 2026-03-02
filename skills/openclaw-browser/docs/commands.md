# OpenClaw Browser - Manual Commands Reference

## One-Command Complete Setup

```bash
bash setup-scripts/complete-setup.sh
```

## Step-by-Step Manual Setup

### 1. Install GUI/VNC Packages

```bash
apt update && apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils tigervnc-standalone-server tigervnc-common
```

### 2. Start VNC Server

```bash
vncserver :2 -geometry 1280x1024 -depth 24 -localhost no
```

### 3. Start XFCE Desktop

```bash
export DISPLAY=:2 && startxfce4 &
```

Wait for XFCE to start (approximately 10 seconds).

### 4. Start Chrome for OpenClaw

```bash
export DISPLAY=:2 && google-chrome-stable --remote-debugging-port=18800 --no-sandbox --user-data-dir=/tmp/openclaw-browser &
```

Wait for Chrome to start (approximately 5 seconds).

### 5. Connect OpenClaw to Chrome

```bash
openclaw browser start
```

### 6. Test Browser (Optional)

```bash
openclaw browser open https://google.com
```

## VNC Connection Details

- **Host**: 100.116.28.26
- **Port**: 5902
- **Display**: :2
- **Geometry**: 1280x1024
- **Depth**: 24-bit

Connection string: `100.116.28.26:5902`

## Troubleshooting

### VNC Server Already Running

If you get an error about VNC server already running on display :2, kill it first:

```bash
vncserver -kill :2
```

Then start it again:

```bash
vncserver :2 -geometry 1280x1024 -depth 24 -localhost no
```

### Chrome Not Starting

Check if Chrome is already running:

```bash
ps aux | grep chrome
```

Kill existing Chrome processes:

```bash
killall chrome
```

### Check Display Variable

Verify DISPLAY is set correctly:

```bash
echo $DISPLAY
```

Should output: `:2`

If not, set it manually:

```bash
export DISPLAY=:2
```

### OpenClaw Browser Commands

```bash
# Start OpenClaw browser connection
openclaw browser start

# Open URL
openclaw browser open https://example.com

# Take screenshot
openclaw browser screenshot

# Take snapshot (page structure)
openclaw browser snapshot
```
