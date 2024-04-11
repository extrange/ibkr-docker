#!/usr/bin/env bash

docker run \
-p '6089:6080' \
-p '8888:8888' \
--ulimit nofile=10000 \
-e USERNAME \
-e PASSWORD \
-e GATEWAY_OR_TWS=gateway \
-e IBC_TradingMode=paper \
-e IBC_AcceptNonBrokerageAccountWarning=yes \
-e IBC_AcceptIncomingConnectionAction=accept \
-d \
image