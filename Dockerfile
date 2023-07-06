FROM ghcr.io/extrange/ibkr:10.19

RUN apt-get install -y nmap cron

# Copy scripts
COPY image-files/start.sh ./
RUN chmod +x ./start.sh

# 复制 check-port.sh 文件到容器中
COPY check-port.sh /check-port.sh
RUN chmod +x /check-port.sh

# 复制 cronjob 文件到容器中
COPY cronjob /etc/cron.d/cronjob
RUN chmod 0644 /etc/cron.d/cronjob
RUN crontab /etc/cron.d/cronjob

CMD [ "./start.sh" ]