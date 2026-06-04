FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------
# Base + GUI + XRDP stack
# ---------------------------
RUN apt-get update && apt-get install -y \
    xrdp \
    xorgxrdp \
    xfce4 \
    xfce4-goodies \
    dbus-x11 \
    x11-xserver-utils \
    x11vnc \
    xvfb \
    wget \
    curl \
    sudo \
    net-tools \
    iproute2 \
    python3 \
    python3-pip \
    novnc \
    websockify \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Firefox (non-snap stable build)
# ---------------------------
RUN wget -O /tmp/firefox.tar.bz2 \
    "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt && \
    ln -s /opt/firefox/firefox /usr/local/bin/firefox && \
    rm /tmp/firefox.tar.bz2

# ---------------------------
# User setup
# ---------------------------
RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo codespace

# ---------------------------
# XRDP config fix
# ---------------------------
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

RUN cat > /etc/xrdp/startwm.sh <<'EOF'
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
export XAUTHORITY=$HOME/.Xauthority
exec startxfce4
EOF

RUN chmod +x /etc/xrdp/startwm.sh

# ---------------------------
# noVNC setup
# ---------------------------
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ---------------------------
# Startup script (CRITICAL FIX)
# ---------------------------
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389 6080

CMD ["/start.sh"]
