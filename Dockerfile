FROM ghcr.io/extrange/ibkr:10.19

# Copy scripts
COPY image-files/start.sh ./

RUN chmod a+x *.sh /opt/ibc/*.sh /opt/ibc/scripts/*.sh

CMD [ "./start.sh" ]