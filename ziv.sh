#!/bin/bash

echo -e "Updating server..."
sudo apt-get update && sudo apt-get upgrade -y
systemctl stop zivpn.service 2>/dev/null

echo -e "Installing ZIVPN UDP binary..."
wget -q https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn
chmod +x /usr/local/bin/zivpn

mkdir -p /etc/zivpn

# Generate certs if not exist
if [[ ! -f /etc/zivpn/zivpn.key || ! -f /etc/zivpn/zivpn.crt ]]; then
  echo "Generating cert files..."
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=California/L=Los Angeles/O=ZIVPN/CN=zivpn" \
    -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
fi

# Create default config if missing
if [[ ! -f /etc/zivpn/config.json ]]; then
  echo '{"listen":"0.0.0.0:5667","target":"127.0.0.1:443","config":["zi"]}' > /etc/zivpn/config.json
fi

# Ask for new passwords
echo -e "Enter new passwords (comma-separated), e.g. pass1,pass2 [leave blank to skip]:"
read -p "Passwords: " input_config

# Read current config
current_config=$(grep -oP '"config":\s*\K[^]+' /etc/zivpn/config.json | tr -d '" ' | tr ',' '\n')
declare -A password_map

# Add current passwords
for p in $current_config; do
  password_map["$p"]=1
done

# Add new passwords if provided
if [[ -n "$input_config" ]]; then
  IFS=',' read -ra new_passes <<< "$input_config"
  for p in "${new_passes[@]}"; do
    password_map["$p"]=1
  done
fi

# Build config line
config_line=$(printf "\"%s\"," "${!password_map[@]}" | sed 's/,$//')
sed -i -E "s/\"config\":\s*[^]]*/\"config\":$config_line/" /etc/zivpn/config.json

# Create service file
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=ZIVPN UDP
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/zivpn server -c /etc/zivpn/config.json
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info

[Install]
WantedBy=multi-user.target
EOF

# Enable and restart service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable zivpn.service
systemctl restart zivpn.service

# Open ports
iptables -t nat -A PREROUTING -i \$(ip route get 1.1.1.1 | awk '{print \$5; exit}') -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp
ufw allow 5667/udp

echo -e "ZIVPN Installed and running!"
