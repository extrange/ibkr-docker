# Debian's apt is faster than Ubuntu's
FROM debian:latest

# procps is needed for twsstart.sh on Debian
RUN apt update && \
    apt install -y \
    git \
    nginx \ 
    procps \
    python3 \
    unzip \ 
    wget \
    x11vnc \
    xterm \
    xvfb

# Download and install offline version of TWS
RUN wget https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh -O install.sh \
    && chmod +x install.sh \
    && yes '' | ./install.sh \
    && rm install.sh

# Install the specified version of IBC
ARG ibc_version=3.11.0
RUN wget https://github.com/IbcAlpha/IBC/releases/download/$ibc_version/IBCLinux-$ibc_version.zip -O ibc.zip \
    && unzip ibc.zip -d /opt/ibc \
    && rm ibc.zip

# Setup noVNC for browser VNC access
RUN git clone https://github.com/novnc/noVNC.git && \
    chmod +x ./noVNC/utils/novnc_proxy

# Copy config files over
COPY config.ini twsstart.sh /opt/ibc/
COPY start.sh nginx.conf ./

# Set permissions
RUN chmod +x *.sh /opt/ibc/*.sh /opt/ibc/*/*.sh

CMD [ "./start.sh" ]