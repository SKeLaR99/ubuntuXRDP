#!/bin/bash

set -e

mkdir -p /var/run/dbus

if [ ! -f /var/lib/dbus/machine-id ]; then
    dbus-uuidgen > /var/lib/dbus/machine-id
fi

dbus-daemon --system --fork

/usr/sbin/xrdp-sesman &
exec /usr/sbin/xrdp --nodaemon
