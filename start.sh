#!/bin/bash

set -e

echo "[+] Starting XRDP + noVNC hybrid system..."

# =====================================================
# DBUS (YOUR ORIGINAL WORKING LOGIC - KEPT)
# =====================================================
mkdir -p /var/run/dbus

if [ ! -f /var/lib/dbus/machine-id ]; then
    dbus-uuidgen > /var/lib/dbus/machine-id
fi

dbus-daemon --system --fork

# =====================================================
# ================= XRDP (UNCHANGED CORE) =============
# =====================================================
/usr/sbin/xrdp-sesman &
exec /usr/sbin/xrdp --nodaemon &

# =====================================================
# ================= noVNC (ISOLATED LAYER) ============
# =====================================================

export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime
mkdir -p /tmp/runtime

# virtual display ONLY for noVNC
Xvfb :1 -screen 0 1280x720x24 -ac +extension GLX +render -noreset &
sleep 2

# XFCE ONLY for noVNC session
startxfce4 >/tmp/xfce-novnc.log 2>&1 &
sleep 3

# VNC bridge
x11vnc -display :1 -forever -shared -rfbport 5900 -nopw -xkb &

# Web bridge
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

echo "[+] XRDP (3389) + noVNC (6080) READY"

tail -f /dev/null
