FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# =====================================================
# 1. CORE PACKAGES (XFCE + XRDP + VNC STACK)
# =====================================================
RUN apt update && apt install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-session \
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
    xorgxrdp \
    xdg-utils \
    exo-utils \
    xdg-user-dirs \
    && apt clean && rm -rf /var/lib/apt/lists/*

# =====================================================
# 2. FIREFOX STABILITY FIX
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
    usermod -aG sudo codespace && \
    adduser xrdp ssl-cert || true

# =====================================================
# 4. XFCE SESSION CONFIG (NOVNC)
# =====================================================
RUN echo "startxfce4" > /home/codespace/.xsession && \
    chown -R codespace:codespace /home/codespace

# =====================================================
# 5. XRDP FIX (BLUE SCREEN FIX)
# =====================================================
RUN cat > /etc/xrdp/startwm.sh <<'EOF'
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4
EOF

RUN chmod +x /etc/xrdp/startwm.sh

# =====================================================
# 6. DEFAULT BROWSER FIX (XFCE ERROR FIX)
# =====================================================
RUN mkdir -p /usr/share/applications && \
    cat > /usr/share/applications/firefox.desktop <<EOF
[Desktop Entry]
Name=Firefox
Exec=firefox %u
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF

# =====================================================
# 7. START SCRIPT
# =====================================================
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389 6080

CMD ["/start.sh"]
