#!/bin/bash
# Zivpn UDP Module installer - AMD x64
# Creator Zahid Islam
# Modified by Hamza Tech

echo -e "Updating server"
sudo apt-get update && apt-get upgrade -y
systemctl stop zivpn.service 1> /dev/null 2> /dev/null

echo -e "Downloading UDP Service"
wget -q https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn
chmod +x /usr/local/bin/zivpn

mkdir -p /etc/zivpn

# Only download config.json if it doesn't exist
if [[ ! -f /etc/zivpn/config.json ]]; then
  wget -q https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/zivpn/config.json
fi

# Create certs if not exist
if [[ ! -f /etc/zivpn/zivpn.key || ! -f /etc/zivpn/zivpn.crt ]]; then
  echo "Generating cert files:"
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
fi

sysctl -w net.core.rmem_max=16777216 1> /dev/null
sysctl -w net.core.wmem_max=16777216 1> /dev/null

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

# Read new passwords
echo -e "ZIVPN UDP Passwords"
read -p "Enter passwords separated by commas (example: pass1,pass2) [Press enter for default 'zi']: " input_config
if [ -n "$input_config" ]; then
    IFS=',' read -r -a new_config <<< "$input_config"
else
    new_config=("zi")
fi

# Merge with existing passwords
if grep -q '"config":' /etc/zivpn/config.json; then
  existing_config=$(grep -oP '"config":\s*\K[^]+' /etc/zivpn/config.json | tr -d '" ')
  IFS=',' read -r -a old_config <<< "$existing_config"
  all_passwords=("${old_config[@]}" "${new_config[@]}")
else
  all_passwords=("${new_config[@]}")
fi

# Remove duplicates
uniq_passwords=($(printf "%s\n" "${all_passwords[@]}" | awk '!seen[$0]++'))

# Update config.json
new_config_str="\"config\": [$(printf "\"%s\"," "${uniq_passwords[@]}" | sed 's/,$//')]"
sed -i -E "s/\"config\":\s*[^]]*/${new_config_str}/" /etc/zivpn/config.json

systemctl enable zivpn.service
systemctl start zivpn.service

iptables -t nat -A PREROUTING -i $(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1) -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp
ufw allow 5667/udp

echo -e "ZIVPN Installed"
