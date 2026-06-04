#!/bin/bash
set -e

echo "[+] Starting UbuntuXRDP Unified Desktop..."

# =====================================================
# A. CLEANUP (FIXES 6080 + 5900 CONFLICT ISSUES)
# =====================================================
pkill -f Xvfb || true
pkill -f x11vnc || true
pkill -f websockify || true
pkill -f xfce4 || true
pkill -f xrdp || true

fuser -k 6080/tcp || true
fuser -k 5900/tcp || true

# =====================================================
# B. DBUS (FIXES XFCE CRASHES)
# =====================================================
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# =====================================================
# C. VIRTUAL DISPLAY (FIXES "NO X SERVER")
# =====================================================
export DISPLAY=:1
export XDG_RUNTIME_DIR=/tmp/runtime
mkdir -p /tmp/runtime
chmod 700 /tmp/runtime

Xvfb :1 -screen 0 1280x720x24 -ac +extension GLX +render -noreset &
sleep 2

# =====================================================
# D. XFCE SESSION (FIXES BLACK SCREEN / LOGIN FREEZE)
# =====================================================
startxfce4 >/tmp/xfce.log 2>&1 &
sleep 3

# =====================================================
# E. FIREFOX COMPATIBILITY FIX (IMPORTANT)
# =====================================================
# Prevent sandbox crashes in container environments
export MOZ_DISABLE_CONTENT_SANDBOX=1
export MOZ_DISABLE_RDD_SANDBOX=1

# =====================================================
# F. VNC SERVER (DISPLAY BRIDGE)
# =====================================================
x11vnc -display :1 \
    -forever \
    -shared \
    -rfbport 5900 \
    -nopw \
    -xkb &

# =====================================================
# G. NO VNC WEB LAYER (FIXES 502 ERROR ROOT CAUSE)
# =====================================================
websockify \
    --web=/usr/share/novnc/ \
    6080 localhost:5900 &

# =====================================================
# H. XRDP (OPTIONAL PARALLEL ACCESS)
# =====================================================
/usr/sbin/xrdp-sesman &
/usr/sbin/xrdp &

echo "[+] System ready: RDP + noVNC active"

tail -f /dev/null
