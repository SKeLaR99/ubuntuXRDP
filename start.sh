#!/bin/bash
set -e

echo "[+] Starting dual desktop system (XRDP + noVNC)..."

# =====================================================
# CLEAN OLD PROCESSES (PREVENT PORT ERRORS)
# =====================================================
pkill -f Xvfb || true
pkill -f x11vnc || true
pkill -f websockify || true
pkill -f xfce4 || true
pkill -f xrdp || true

fuser -k 6080/tcp || true
fuser -k 5900/tcp || true
fuser -k 3389/tcp || true

# =====================================================
# DBUS (XFCE REQUIREMENT)
# =====================================================
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# =====================================================
# ================= NOVNC STACK ======================
# =====================================================
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime
mkdir -p /tmp/runtime
chmod 700 /tmp/runtime

Xvfb :1 -screen 0 1280x720x24 -ac +extension GLX +render -noreset &
sleep 2

startxfce4 >/tmp/xfce.log 2>&1 &
sleep 5

x11vnc -display :1 \
    -forever \
    -shared \
    -rfbport 5900 \
    -nopw \
    -xkb &

websockify \
    --web=/usr/share/novnc/ \
    6080 localhost:5900 &

# =====================================================
# ================= XRDP STACK =======================
# =====================================================
service dbus restart || true
/usr/sbin/xrdp-sesman &
/usr/sbin/xrdp &

echo "[+] SYSTEM READY:"
echo "   - RDP:   port 3389"
echo "   - noVNC: port 6080"

tail -f /dev/null
