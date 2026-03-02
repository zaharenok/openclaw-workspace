#!/bin/bash

# Script for setting up VNC and OpenClaw browser environment

# Install GUI and VNC packages
apt update && apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils tigervnc-standalone-server tigervnc-common

# Start VNC server on display :2
vncserver :2 -geometry 1280x1024 -depth 24 -localhost no

# Start XFCE desktop
export DISPLAY=:2 && startxfce4 &

# Wait for XFCE to start
sleep 10

# Start Chrome for OpenClaw with remote debugging
export DISPLAY=:2 && google-chrome-stable --remote-debugging-port=18800 --no-sandbox --user-data-dir=/tmp/openclaw-browser &

# Wait for Chrome to start
sleep 5

# Start OpenClaw browser
export DISPLAY=:2 && openclaw browser start

# Test browser open
export DISPLAY=:2 && openclaw browser open https://google.com

echo "Setup complete! Connect to VNC: 100.116.28.26:5902"