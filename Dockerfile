FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Base packages + XFCE + XRDP
# =========================
RUN apt update && apt install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    dbus-x11 \
    x11-xserver-utils \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    pulseaudio \
    xfce4-terminal \
    firefox \
    && apt clean && rm -rf /var/lib/apt/lists/*

# =========================
# Create user (Codespaces safe)
# =========================
RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo codespace

# =========================
# XFCE session setup
# =========================
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown codespace:codespace /home/codespace/.xsession && \
    chmod +x /home/codespace/.xsession

# =========================
# XRDP config fix
# =========================
RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || true && \
    echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config && \
    sed -i 's|port=3389|port=3389|g' /etc/xrdp/xrdp.ini && \
    sed -i 's|use_vsock=true|use_vsock=false|g' /etc/xrdp/xrdp.ini || true

# =========================
# Startup script (CRITICAL FIX)
# =========================
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
