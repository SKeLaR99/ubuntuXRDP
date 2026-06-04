FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV MOZ_ENABLE_WAYLAND=0
ENV LIBGL_ALWAYS_SOFTWARE=1

# =========================
# Core system + desktop
# =========================
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xrdp \
    xorgxrdp \
    dbus-x11 \
    xauth \
    sudo \
    wget \
    curl \
    ca-certificates \
    locales \
    iproute2 \
    net-tools \
    pulseaudio \
    pulseaudio-utils \
    xvfb \
    x11vnc \
    git \
    python3 \
    docker.io \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# =========================
# Firefox (non-snap)
# =========================
RUN wget -O /tmp/firefox.tar.xz \
    "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    mkdir -p /opt && \
    tar -xJf /tmp/firefox.tar.xz -C /opt && \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox && \
    rm -f /tmp/firefox.tar.xz

# =========================
# noVNC setup
# =========================
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify

# =========================
# User setup
# =========================
RUN groupadd -f docker && \
    useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo,docker codespace

# XFCE session
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown -R codespace:codespace /home/codespace

# XRDP config
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

RUN cat > /etc/xrdp/startwm.sh <<'EOF'
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4
EOF

RUN chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

# =========================
# Startup script
# =========================
COPY start.sh /start.sh
RUN chmod +x /start.sh

# =========================
# Ports
# =========================
EXPOSE 3389 6080

VOLUME ["/home/codespace"]

CMD ["/start.sh"]
