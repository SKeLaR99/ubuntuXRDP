FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# =========================
# Core system + GUI stack
# =========================
RUN apt update && apt install -y \
    xfce4 \
    xfce4-session \
    xfce4-goodies \
    dbus-x11 \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    xauth \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    firefox \
    xrdp \
    && apt clean && rm -rf /var/lib/apt/lists/*

# =========================
# User setup
# =========================
RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo codespace

# =========================
# XFCE session config
# =========================
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown -R codespace:codespace /home/codespace

# =========================
# XRDP fix (safe mode)
# =========================
RUN sed -i 's|port=3389|port=3389|g' /etc/xrdp/xrdp.ini || true

# =========================
# Startup script
# =========================
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389 6080

CMD ["/start.sh"]
