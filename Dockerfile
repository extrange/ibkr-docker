FROM ghcr.io/extrange/ibkr:10.19

RUN apt-get update && apt-get install -y ncat

CMD [ "./start.sh" ]