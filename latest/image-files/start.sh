#!/bin/bash

# Fail fast
set -Eeuo pipefail

export DISPLAY=:0

# Start VNC server
Xvnc -SecurityTypes None -AlwaysShared=1 -geometry 1920x1080 :0 &

# Start noVNC server
./noVNC/utils/novnc_proxy --vnc localhost:5900 &

# Start openbox
openbox

# Start either TWS or IB Gateway
if [[ -z ${GATEWAY_OR_TWS} ]]; then
    printf 'GATEWAY_OR_TWS not set\n'
    exit 1
elif [[ ${GATEWAY_OR_TWS@L} = "gateway" ]]; then
    command='-g'
elif [[ ${GATEWAY_OR_TWS@L} = "tws" ]]; then
    command=
else
    printf "GATEWAY_OR_TWS must be either 'gateway' or 'tws': got '%s'\n" "$GATEWAY_OR_TWS"
    exit 1
fi

# forward correct port with socat
if [[ ${gateway_or_tws@l} = "gateway" ]]; then
    if [[ ${ibc_tradingmode:-live} = "live" ]]; then
        # ibgateway live
        port=4001
    else
        # ibgateway paper
        port=4002
    fi
elif [[ ${ibc_tradingmode:-live} = "live" ]]; then
    # tws live
    port=7496
else
    # tws paper
    port=7497
fi

printf "listening for incoming api connections on %s\n" $port
socat -d -d -d tcp-listen:8888,fork tcp:127.0.0.1:${port} &

# hacky way to get the major version for ib gateway/tws
tws_major_version=$(ls ~/jts/*/.)

# override /opt/ibc/config.ini with environment variables
./replace.sh ~/ibc/config.ini

# --on2fatimeout was previously supplied by gatewaystart.sh/twsstart.sh,
# so we need to supply it here. the rest of the arguments can be read from
# the config.ini file.

# exec /opt/ibc/scripts/ibcstart.sh "${tws_major_version}" $command \
#     "--user=${USERNAME}" \
#     "--pw=${PASSWORD}" \
#     "--on2fatimeout=${TWOFA_TIMEOUT_ACTION:-restart}"