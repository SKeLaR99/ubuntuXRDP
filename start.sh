#!/bin/bash

mkdir -p /var/run/dbus
dbus-daemon --system

service xrdp-sesman start
service xrdp start

echo ""
echo "================================="
echo "XRDP READY"
echo "Username: codespace"
echo "Password: codespace"
echo "Port: 3389"
echo "================================="
echo ""

tail -f /dev/null
