#!/bin/bash
# Zivpn UDP Module installer - AMD x64
# Creator hamza

echo -e "Updating server"
sudo apt-get update && sudo apt-get upgrade -y
systemctl stop zivpn.service 1> /dev/null 2> /dev/null
echo -e "Downloading UDP Service"
wget https://github.com/hq-mp/zi-vpn.com/raw/refs/heads/main/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn 1> /dev/null 2> /dev/null
chmod +x /usr/local/bin/zivpn
mkdir -p /etc/zivpn 1> /dev/null 2> /dev/null
wget https://raw.githubusercontent.com/hq-mp/zi-vpn.com/refs/heads/main/config.json -O /etc/zivpn/config.json 1> /dev/null 2> /dev/null

read -p "Enter number of days for certificate validity (default 365): " cert_days
cert_days=${cert_days:-365}

echo "Generating cert files for $cert_days days:"
openssl req -new -newkey rsa:4096 -days "$cert_days" -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"

sysctl -w net.core.rmem_max=16777216 1> /dev/null 2> /dev/null
sysctl -w net.core.wmem_max=16777216 1> /dev/null 2> /dev/null

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
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

echo -e "ZIVPN UDP Passwords"
echo -n "Enter passwords separated by commas, example: passwd1,passwd2 (Press enter for Default 'zi'): "
read input_config

if [ -n "$input_config" ]; then
    IFS=',' read -r -a config <<< "$input_config"
    for i in "${!config[@]}"; do
        config[$i]=$(echo "${config[$i]}" | xargs)
    done
    if [ ${#config[@]} -eq 1 ]; then
        config+=("${config[0]}")
    fi
else
    config=("zi")
fi

new_config_str="\"config\": [$(printf '"%s",' "${config[@]}" | sed 's/,$//')]"
new_config_str="${new_config_str}]"

sed -i -E "s/\"config\": ?[[:space:]]*\"zi\"[[:space:]]*/${new_config_str}/g" /etc/zivpn/config.json

systemctl enable zivpn.service
systemctl start zivpn.service

iptables -t nat -A PREROUTING -i $(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1) -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp
ufw allow 5667/udp
rm zi2.* 1> /dev/null 2> /dev/null

echo -e "ZIVPN Installed"
