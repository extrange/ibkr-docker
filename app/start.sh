#!/bin/bash

# Clear Xvfb lockfile
rm -f /tmp/.X0-lock

# Start Xvfb so that TWS/IBGateway will run
Xvfb :0 -ac -screen 0 1920x1080x24 &

export DISPLAY=:0

# Start VNC server, listening at 5900 by default
x11vnc -ncache 10 -ncache_cr -display :0 -forever -shared -bg -noipv6 &

# Start nginx reverse proxy
nginx -c /nginx.conf

# Start noVNC server
./noVNC/utils/novnc_proxy --vnc localhost:5900 &

# Load username/password from Docker secret
IBKR_USERNAME=$(cat /run/secrets/ibkr_username)
IBKR_PASSWORD=$(cat /run/secrets/ibkr_password)

# Replace username/password (with '/'s escaped) to config.ini file for IBC
sed -i "s/\(IbLoginId=\).*/\1${IBKR_USERNAME//\//\\/}/" /opt/ibc/config.ini
sed -i "s/\(IbPassword=\).*/\1${IBKR_PASSWORD//\//\\/}/" /opt/ibc/config.ini

# Start TWS and automatically restart if it dies
while true; do
    /opt/ibc/twsstart.sh -inline
    sleep 5
done