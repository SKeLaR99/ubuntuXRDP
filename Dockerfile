FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt update && apt install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    pulseaudio \
    pulseaudio-utils \
    firefox \
    wine64 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo codespace

RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown codespace:codespace /home/codespace/.xsession

RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
