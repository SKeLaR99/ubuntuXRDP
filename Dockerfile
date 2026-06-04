FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    xrdp \
    xorgxrdp \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xauth \
    dbus-x11 \
    pulseaudio \
    pulseaudio-utils \
    sudo \
    wget \
    curl \
    ca-certificates \
    locales \
    iproute2 \
    net-tools \
    docker.io \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Firefox directly from Mozilla (avoids Ubuntu Snap)
RUN wget -O /tmp/firefox.tar.xz \
    "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    mkdir -p /opt && \
    tar -xJf /tmp/firefox.tar.xz -C /opt && \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox && \
    rm -f /tmp/firefox.tar.xz

# Create user
RUN groupadd -f docker && \
    useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo,docker codespace

# DBus machine id
RUN mkdir -p /var/run/dbus && \
    dbus-uuidgen > /var/lib/dbus/machine-id

# XFCE session
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown -R codespace:codespace /home/codespace

# XRDP configuration
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

RUN cat > /etc/xrdp/startwm.sh <<'EOF'
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4
EOF

RUN chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY pulse-client.conf /etc/pulse/client.conf
COPY start.sh /start.sh

RUN chmod +x /start.sh

VOLUME ["/home/codespace"]

EXPOSE 3389

CMD ["/start.sh"]
