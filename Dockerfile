FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# =====================================================
# 1. CORE SYSTEM + GUI + NETWORK TOOLS
# =====================================================
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
    x11-utils \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    pulseaudio \
    xrdp \
    firefox \
    && apt clean && rm -rf /var/lib/apt/lists/*

# =====================================================
# 2. USER SETUP (CODESPACE COMPATIBLE)
# =====================================================
RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo codespace

# =====================================================
# 3. XFCE SESSION FIX
# =====================================================
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown -R codespace:codespace /home/codespace

# =====================================================
# 4. XRDP CONFIG (SAFE MODE)
# =====================================================
RUN sed -i 's|port=3389|port=3389|g' /etc/xrdp/xrdp.ini || true

# =====================================================
# 5. START SCRIPT
# =====================================================
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389 6080

CMD ["/start.sh"]
