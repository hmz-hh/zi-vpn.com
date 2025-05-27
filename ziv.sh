#!/bin/bash
# Zivpn UDP Module installer - AMD x64
# Creator Zahid Islam
# Modified by PowerMX (Debug Version)

echo -e "Updating server"
sudo apt-get update && apt-get upgrade -y
systemctl stop zivpn.service
echo -e "Downloading UDP Service"
wget https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn
chmod +x /usr/local/bin/zivpn
mkdir -p /etc/zivpn
wget https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/zivpn/config.json

echo "Generating cert files:"
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
  -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" \
  -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"

sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=zivpn VPN Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=/usr/local/bin/zivpn server -c /etc/zivpn/config.json
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=debug
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

echo -e "ZIVPN UDP Passwords"
read -p "Enter passwords separated by commas (e.g., pass1,pass2): " input_config

if [ -n "$input_config" ]; then
    IFS=',' read -r -a config <<< "$input_config"
else
    config=("zi")
fi

if ! command -v jq &> /dev/null; then
    sudo apt-get install jq -y
fi

temp_file=$(mktemp)
current_config=$(jq '.config' /etc/zivpn/config.json)
for pass in "${config[@]}"; do
    current_config=$(echo "$current_config" | jq --arg pass "$pass" '. + [$pass] | unique')
done
jq --argjson new_config "$current_config" '.config = $new_config' /etc/zivpn/config.json > "$temp_file"
mv "$temp_file" /etc/zivpn/config.json

systemctl daemon-reload
systemctl enable zivpn.service
systemctl restart zivpn.service

# إصلاح قاعدة iptables
interface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -A PREROUTING -i $interface -p udp --dport 6000:19999 -j DNAT --to-destination :5667

ufw allow 6000:19999/udp
ufw allow 5667/udp

echo -e "ZIVPN Installed. Check status with: systemctl status zivpn.service"
