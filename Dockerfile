FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# =====================================================
# 1. CORE DESKTOP + VNC STACK
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
    firefox \
    xrdp \
    && apt clean && rm -rf /var/lib/apt/lists/*

# =====================================================
# 2. FIREFOX FIX (CRITICAL - CONTAINER STABILITY)
# =====================================================
ENV MOZ_DISABLE_CONTENT_SANDBOX=1
ENV MOZ_DISABLE_RDD_SANDBOX=1
ENV MOZ_ENABLE_WAYLAND=0

# =====================================================
# 3. USER SETUP
# =====================================================
RUN useradd -m -s /bin/bash codespace && \
    echo "codespace:codespace" | chpasswd && \
    usermod -aG sudo codespace

# =====================================================
# 4. XFCE SESSION FIX
# =====================================================
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown -R codespace:codespace /home/codespace

# =====================================================
# 5. XRDP SAFE CONFIG
# =====================================================
RUN sed -i 's|port=3389|port=3389|g' /etc/xrdp/xrdp.ini || true

# =====================================================
# 6. START SCRIPT
# =====================================================
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389 6080

CMD ["/start.sh"]
