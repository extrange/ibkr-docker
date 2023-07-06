host="localhost"
port="8888"

# 使用 nmap 命令检查端口是否打开
result=$(nmap -p $port $host | grep -w $port | awk '{print $2}')

# 检查结果
if [ "$result" = "open" ]; then
  echo "Port $port is open on host $host"
else
  echo "Port $port is not open on host $host"
  socat -d -d TCP-LISTEN:8888,fork TCP:127.0.0.1:${port} &
fi
