#!/bin/bash

set -e

echo "[1] Cleaning state..."
pkill -9 xrdp || true
pkill -9 xrdp-sesman || true

rm -f /var/run/xrdp/*.pid
rm -f /run/xrdp/*.pid
rm -f /run/dbus/pid

mkdir -p /run/dbus

echo "[2] Starting DBus..."
dbus-daemon --system --fork

echo "[3] Starting XRDP..."
/usr/sbin/xrdp-sesman &
sleep 1
/usr/sbin/xrdp &

echo "[4] Starting noVNC..."
Xvfb :1 -screen 0 1280x720x16 &
export DISPLAY=:1

sleep 2

startxfce4 &
x11vnc -display :1 -forever -shared -rfbport 5900 -nopw &
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

echo "[OK] system running"

tail -f /dev/null
