#!/bin/bash

# Fail fast
set -Eeuo pipefail

export DISPLAY=:0

# Clear previous lockfile
rm -f /tmp/.X0-lock

# Start VNC server
Xvnc -SecurityTypes None -AlwaysShared=1 -geometry 1920x1080 :0 &

# Start noVNC server
./noVNC/utils/novnc_proxy --vnc localhost:5900 &

# Start openbox
openbox &

# Start either TWS or IB Gateway
if [[ -z ${GATEWAY_OR_TWS:-} ]]; then
    # Start TWS by default if not specified
    GATEWAY_OR_TWS=tws
    command=
elif [[ ${GATEWAY_OR_TWS@L} = "gateway" ]]; then
    command='-g'
elif [[ ${GATEWAY_OR_TWS@L} = "tws" ]]; then
    command=
else
    printf "GATEWAY_OR_TWS must be either 'gateway' or 'tws': got '%s'\n" "$GATEWAY_OR_TWS"
    exit 1
fi

# Forward correct port with socat
if [[ ${GATEWAY_OR_TWS@L} = "gateway" ]]; then
    if [[ ${IBC_TradingMode:-live} = "live" ]]; then
        # IBGateway Live
        port=4001
    else
        # IBGateway Paper
        port=4002
    fi
elif [[ ${IBC_TradingMode:-live} = "live" ]]; then
    # TWS Live
    port=7496
else
    # TWS Paper
    port=7497
fi

printf "Listening for incoming API connections on %s\n" $port
socat -d -d TCP-LISTEN:8888,fork TCP:127.0.0.1:${port} &

# Hacky way to get the major version for IB Gateway/TWS
TWS_MAJOR_VERSION=$(ls ~/Jts/ibgateway/.)

# IB's installer records the location of the JRE it unpacked for its own use in
# .install4j/inst_jre.cfg. That extraction directory (…<pid>.dir) is deleted as
# soon as the installation finishes, so IBC can no longer find a Java
# installation at runtime (see issue #155). Point IBC at the JRE that ships
# with the Gateway/TWS installation instead.
java_path_args=()
if [[ -x ~/Jts/ibgateway/"${TWS_MAJOR_VERSION}"/jre/bin/java ]]; then
    java_path_args=("--java-path=$HOME/Jts/ibgateway/${TWS_MAJOR_VERSION}/jre/bin")
else
    printf "Warning: no JRE found at %s, falling back to IBC's own detection\n" \
        "$HOME/Jts/ibgateway/${TWS_MAJOR_VERSION}/jre/bin"
fi

# Override /opt/ibc/config.ini with environment variables
./replace.sh ~/ibc/config.ini

# --on2fatimeout was previously supplied by gatewaystart.sh/twsstart.sh,
# so we need to supply it here. The rest of the arguments can be read from
# the config.ini file.

exec /opt/ibc/scripts/ibcstart.sh "${TWS_MAJOR_VERSION}" $command \
    "--user=${USERNAME:-}" \
    "--pw=${PASSWORD:-}" \
    "--on2fatimeout=${TWOFA_TIMEOUT_ACTION:-restart}" \
    "--tws-settings-path=${TWS_SETTINGS_PATH:-}" \
    "${java_path_args[@]}"
