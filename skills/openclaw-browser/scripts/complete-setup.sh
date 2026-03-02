#!/bin/bash

# OpenClaw Browser Setup - VNC+Chrome only
# This script installs VNC server, XFCE desktop, Chrome with remote debugging

echo "🚀 Starting OpenClaw Browser setup..."

# 1. Install GUI and VNC packages
echo "📦 Installing GUI and VNC packages..."
apt update && apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils tigervnc-standalone-server tigervnc-common

# 2. Start VNC server on display :2
echo "🖥️ Starting VNC server on display :2..."
vncserver :2 -geometry 1280x1024 -depth 24 -localhost no

# 3. Start XFCE desktop
echo "🎨 Starting XFCE desktop..."
export DISPLAY=:2 && startxfce4 &

# Wait for XFCE to start
echo "⏳ Waiting for XFCE to start..."
sleep 10

# 4. Start Chrome for OpenClaw with remote debugging
echo "🌍 Starting Chrome with remote debugging..."
export DISPLAY=:2 && google-chrome-stable --remote-debugging-port=18800 --no-sandbox --user-data-dir=/tmp/openclaw-browser &

# Wait for Chrome to start
echo "⏳ Waiting for Chrome to start..."
sleep 5

# 5. Test browser
echo "🧪 Testing browser with Google..."
export DISPLAY=:2 && google-chrome-stable https://google.com &

echo ""
echo "✅ Setup complete!"
echo ""
echo "🔌 VNC Connection Details:"
echo "   Host: 100.116.28.26"
echo "   Port: 5902"
echo "   Display: :2"
echo ""
echo "💡 To connect manually, use a VNC client with: 100.116.28.26:5902"
echo "📝 Use 'openclaw browser start' to connect OpenClaw to Chrome"
