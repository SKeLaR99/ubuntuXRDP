FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV BROWSER=firefox

# =====================================================
# 1. CORE DESKTOP + VNC + XRDP STACK
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
    xdg-utils \
    exo-utils \
    xdg-user-dirs \
    && apt clean && rm -rf /var/lib/apt/lists/*

# =====================================================
# 2. FIREFOX STABILITY FIX (CONTAINER MODE)
# =====================================================
ENV MOZ_DISABLE_CONTENT_SANDBOX=1
ENV MOZ_DISABLE_RDD_SANDBOX=1
ENV MOZ_ENABLE_WAYLAND=0
ENV LIBGL_ALWAYS_SOFTWARE=1

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
# 5. XRDP CONFIG (SAFE)
# =====================================================
RUN sed -i 's|port=3389|3389|g' /etc/xrdp/xrdp.ini || true

# =====================================================
# 6. START SCRIPT
# =====================================================
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389 6080

CMD ["/start.sh"]
