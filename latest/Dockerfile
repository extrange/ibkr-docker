FROM debian:12 AS setup

ENV IBC_VERSION=3.20.0

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates git libxtst6 libgtk-3-0 openbox procps python3 socat tigervnc-standalone-server unzip wget2 xterm \
    # https://github.com/extrange/ibkr-docker/issues/74
    libasound2 \
    libnss3 \
    libgbm1 \
    libnspr4

# Setup noVNC for browser VNC access
RUN git clone --depth 1 https://github.com/novnc/noVNC.git && \
    chmod +x ./noVNC/utils/novnc_proxy && \
    git clone --depth 1 https://github.com/novnc/websockify.git /noVNC/utils/websockify

# Override default noVNC file listing
COPY image-files/index.html /noVNC

# Download and setup IBC
RUN wget2 https://github.com/IbcAlpha/IBC/releases/download/${IBC_VERSION}/IBCLinux-${IBC_VERSION}.zip -O ibc.zip \
    && unzip ibc.zip -d /opt/ibc \
    && rm ibc.zip

ENV INSTALL_FILENAME="ibgateway-10.36.1c-standalone-linux-x64.sh"

# Fetch hashes
RUN wget2 "https://github.com/extrange/ibkr-docker/releases/download/10.36.1c-latest/ibgateway-10.36.1c-standalone-linux-x64.sh.sha256" \
    -O hash

# Download IB Gateway (which contains TWS) and check hashes
RUN wget2 "https://github.com/extrange/ibkr-docker/releases/download/10.36.1c-latest/ibgateway-10.36.1c-standalone-linux-x64.sh" \
    -O "$INSTALL_FILENAME" \
    && sha256sum -c hash \
    && chmod +x "$INSTALL_FILENAME" \
    && yes '' | "./$INSTALL_FILENAME"  \
    && rm "$INSTALL_FILENAME"

# Copy scripts
COPY image-files/start.sh image-files/replace.sh /

RUN mkdir -p ~/ibc && mv /opt/ibc/config.ini ~/ibc/config.ini

RUN chmod a+x ./*.sh /opt/ibc/*.sh /opt/ibc/scripts/*.sh

CMD [ "/start.sh" ]