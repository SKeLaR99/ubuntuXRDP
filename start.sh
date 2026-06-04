#!/bin/bash
set -e

mkdir -p /var/run/dbus

# DBus
dbus-daemon --system --fork || true

if [ ! -f /var/lib/dbus/machine-id ]; then
    dbus-uuidgen > /var/lib/dbus/machine-id
fi

# =========================
# XRDP
# =========================
/usr/sbin/xrdp-sesman &
/usr/sbin/xrdp &

# =========================
# Virtual display for noVNC
# =========================
Xvfb :1 -screen 0 1280x720x16 &
export DISPLAY=:1

# XFCE desktop
sleep 2
startxfce4 &

# VNC server
x11vnc -display :1 -nopw -forever -shared -rfbport 5900 &

# noVNC web client
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &

wait
