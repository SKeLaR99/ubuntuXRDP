#!/bin/bash
set -e

echo "[+] Starting FIXED UbuntuXRDP stack..."

# =====================================================
# CLEAN STATE (FIXES 6080 / 5900 ERRORS)
# =====================================================
pkill -f Xvfb || true
pkill -f x11vnc || true
pkill -f websockify || true
pkill -f xfce4 || true
pkill -f xrdp || true

fuser -k 6080/tcp || true
fuser -k 5900/tcp || true

# =====================================================
# DBUS (FIX FOR XFCE CRASHES)
# =====================================================
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# =====================================================
# VIRTUAL DISPLAY (CRITICAL FIX)
# =====================================================
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime
mkdir -p /tmp/runtime
chmod 700 /tmp/runtime

Xvfb :1 -screen 0 1280x720x24 -ac +extension GLX +render -noreset &
sleep 2

# =====================================================
# XFCE (STABLE START ORDER)
# =====================================================
startxfce4 >/tmp/xfce.log 2>&1 &
sleep 5

# =====================================================
# FIREFOX HARD FIX (IMPORTANT)
# =====================================================
export GTK_THEME=Adwaita
export LIBGL_ALWAYS_SOFTWARE=1

# =====================================================
# VNC SERVER
# =====================================================
x11vnc -display :1 \
    -forever \
    -shared \
    -rfbport 5900 \
    -nopw \
    -xkb &

# =====================================================
# NO VNC WEB BRIDGE
# =====================================================
websockify \
    --web=/usr/share/novnc/ \
    6080 localhost:5900 &

# =====================================================
# XRDP (OPTIONAL, ISOLATED)
# =====================================================
/usr/sbin/xrdp-sesman &
/usr/sbin/xrdp &

echo "[+] SYSTEM READY: XFCE + FIREFOX + RDP + NO VNC"

tail -f /dev/null
