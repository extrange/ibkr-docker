# IBKR TWS in Docker

![](screenshot.jpg)

## Features

- **Fully containerized** IBKR TWS instance + [IBC Alpha](https://github.com/IbcAlpha) in Docker, no external dependencies
- **TWS API access** (automatically configured), proxied to localhost internally via `nginx`
- **Supports noVNC** (a browser-based VNC client, proxied via Websockify)
- **Autorestarts TWS automatically** (for example, due to daily logoff)

## Getting Started

- Install [Docker](https://docs.docker.com/get-docker/)
- Clone this repo:
  - `git clone https://github.com/extrange/ibkr-docker.git`
  - `cd ibkr-docker`
- Enter your credentials:
  - Create 2 files named `.username` and `.password` and input your IBKR username/password accordingly
- Build the image:
  - `docker-compose build`
- Start the container:
  - `docker-compose up -d`
  - TWS API is available on port `8888` by default
  - You can view the noVNC client at [localhost:6080/vnc.html](http://localhost:6080/vnc.html)
- To stop: `docker-compose down`

## Paper vs Live Account

This container is setup to connect to a paper account. To switch to a live account:

- Modify nginx.conf's `proxy_pass` accordingly:
  - Live Account: `7496`
  - Paper Account: `7497`
- Modify `app/config.ini`:
  - `TradingMode=live`

You will have to restart the container after making these changes.

## Changes from the default config.ini

```config
AcceptBidAskLastSizeDisplayUpdateNotification=accept
AcceptIncomingConnectionAction=accept
AcceptNonBrokerageAccountWarning=yes
TradingMode=paper
```

## Known Issues

- If either of `.username` or `.password` are missing, Docker [creates empty folders with the same name](https://github.com/docker/compose/issues/5377)

## Todo

- optimize noVNC (download and setup websockify)
