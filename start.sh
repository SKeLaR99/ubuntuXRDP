#!/bin/bash
set -e

echo "[+] Starting UbuntuXRDP..."

# Prevent duplicates (IMPORTANT FIX)
pkill xrdp || true
pkill xrdp-sesman || true

# DBus required for XFCE stability
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Start XRDP (single instance only)
 /usr/sbin/xrdp-sesman
 /usr/sbin/xrdp

echo "[+] XRDP running on port 3389"

# Keep container alive
tail -f /dev/null
