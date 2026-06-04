#!/bin/bash
set -e

echo "[+] Starting Unified Desktop (FIXED FIREFOX + XFCE + NO VNC)..."

# =====================================================
# CLEAN OLD STATE (PREVENT PORT ERRORS)
# =====================================================
pkill -f Xvfb || true
pkill -f x11vnc || true
pkill -f websockify || true
pkill -f xfce4 || true
pkill -f xrdp || true

fuser -k 6080/tcp || true
fuser -k 5900/tcp || true

# =====================================================
# DBUS (XFCE REQUIREMENT)
# =====================================================
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# =====================================================
# VIRTUAL DISPLAY
# =====================================================
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime
mkdir -p /tmp/runtime
chmod 700 /tmp/runtime

Xvfb :1 -screen 0 1280x720x24 -ac +extension GLX +render -noreset &
sleep 2

# =====================================================
# XFCE SESSION
# =====================================================
startxfce4 >/tmp/xfce.log 2>&1 &
sleep 5

# =====================================================
# 🔥 FIREFOX DEFAULT BROWSER FIX (IMPORTANT PART)
# =====================================================
echo "[+] Applying Firefox default browser fix..."

export BROWSER=firefox

ln -sf /usr/bin/firefox /usr/bin/x-www-browser || true
ln -sf /usr/bin/firefox /usr/bin/gnome-www-browser || true

xdg-settings set default-web-browser firefox.desktop || true

mkdir -p /home/codespace/.config
echo "firefox.desktop" > /home/codespace/.config/mimeapps.list || true

# =====================================================
# VNC SERVER (DISPLAY EXPORT)
# =====================================================
x11vnc -display :1 \
    -forever \
    -shared \
    -rfbport 5900 \
    -nopw \
    -xkb &

# =====================================================
# NO VNC WEB BRIDGE (6080 FIXED)
# =====================================================
websockify \
    --web=/usr/share/novnc/ \
    6080 localhost:5900 &

# =====================================================
# XRDP (OPTIONAL PARALLEL)
# =====================================================
/usr/sbin/xrdp-sesman &
/usr/sbin/xrdp &

echo "[+] SYSTEM READY: XFCE + FIREFOX + RDP + NO VNC"

tail -f /dev/null
