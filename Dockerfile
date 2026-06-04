FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# -----------------------------
# Base system + GUI + XRDP + VNC tools
# -----------------------------
RUN apt-get update && apt-get install -y \
    xrdp \
    xorgxrdp \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    x11vnc \
    xvfb \
    wget \
    curl \
    ca-certificates \
    sudo \
    net-tools \
    iproute2 \
    locales \
    python3 \
    python3-pip \
    novnc \
    websockify \
    xz-utils \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Firefox (FIXED - correct .tar.xz handling)
# -----------------------------
RUN wget -O /tmp/firefox.tar.xz \
    "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    mkdir -p /opt/firefox && \
    tar -xJf /tmp/firefox.tar.xz -C /opt && \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox && \
    rm /tmp/firefox.tar.xz

# -----------------------------
# User setup
# -----------------------------
RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo codespace

# -----------------------------
# DBus setup
# -----------------------------
RUN mkdir -p /var/run/dbus

# -----------------------------
# XRDP configuration
# -----------------------------
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

RUN cat > /etc/xrdp/startwm.sh <<'EOF'
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
export XAUTHORITY=$HOME/.Xauthority
exec startxfce4
EOF

RUN chmod +x /etc/xrdp/startwm.sh

# -----------------------------
# noVNC setup
# -----------------------------
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# -----------------------------
# Startup script
# -----------------------------
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389 6080

CMD ["/start.sh"]
