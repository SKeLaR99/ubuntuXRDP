FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

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
    ca-certificates \
    locales \
    iproute2 \
    docker.io \
    wine64 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Mozilla Firefox (non-Snap)
RUN wget -O /tmp/firefox.tar.xz \
    "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar -xJf /tmp/firefox.tar.xz -C /opt && \
    ln -s /opt/firefox/firefox /usr/local/bin/firefox && \
    rm -f /tmp/firefox.tar.xz

# Create user
RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo,docker codespace

# Locale
RUN locale-gen en_US.UTF-8

# XFCE startup
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown codespace:codespace /home/codespace/.xsession

# XRDP configuration
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

RUN printf '#!/bin/sh\nunset DBUS_SESSION_BUS_ADDRESS\nunset XDG_RUNTIME_DIR\nexec startxfce4\n' \
    > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY pulse-client.conf /etc/pulse/client.conf
COPY start.sh /start.sh

RUN chmod +x /start.sh

VOLUME ["/home/codespace"]

EXPOSE 3389

CMD ["/start.sh"]
