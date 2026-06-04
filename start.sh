#!/bin/bash
set -e

echo "[+] Starting unified desktop stack..."

# Kill old instances (prevents your earlier bugs)
pkill Xvfb || true
pkill x11vnc || true
pkill websockify || true
pkill xrdp || true
pkill xrdp-sesman || true

# DBus (required for XFCE)
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# =========================
# VIRTUAL DISPLAY (FIX)
# =========================
export DISPLAY=:1
Xvfb :1 -screen 0 1280x720x16 &
sleep 2

# =========================
# XFCE SESSION
# =========================
startxfce4 &
sleep 2

# =========================
# VNC SERVER
# =========================
x11vnc -display :1 -forever -shared -rfbport 5900 -nopw &

# =========================
# NO VNC WEB BRIDGE
# =========================
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

# =========================
# XRDP (optional, safe start)
# =========================
/usr/sbin/xrdp-sesman &
/usr/sbin/xrdp &

echo "[+] Desktop ready (RDP + noVNC)"

tail -f /dev/null
