FROM debian:latest

RUN apt update && \
    apt install --no-install-recommends -y \
    git libxtst6 openbox procps python3-pip tigervnc-standalone-server wget2 xterm

# Download and install TWS
RUN wget2 https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh -O install.sh \
    && chmod +x install.sh \
    && yes '' | ./install.sh \
    && rm install.sh

# Setup noVNC for browser VNC access
RUN git clone https://github.com/novnc/noVNC.git && \
    chmod +x ./noVNC/utils/novnc_proxy && \
    git clone https://github.com/novnc/websockify.git /noVNC/utils/websockify && \
    pip install numpy

# Override default noVNC file listing
COPY index.html /noVNC

COPY start.sh ./
RUN chmod +x start.sh

CMD [ "./start.sh" ]