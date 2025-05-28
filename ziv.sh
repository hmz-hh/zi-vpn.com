#!/bin/bash
# 🚀 Zivpn UDP Module installer - AMD x64
# 👤 Creator: hamza
# ⚙️ Bash by PowerMX

echo -e "🔄 Updating server..."
systemctl stop zivpn.service 1> /dev/null 2> /dev/null

echo -e "📥 Downloading UDP Service binary..."
wget https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn 1> /dev/null 2> /dev/null

echo -e "🔧 Setting executable permissions..."
chmod +x /usr/local/bin/zivpn

echo -e "📁 Creating configuration directory..."
mkdir /etc/zivpn 1> /dev/null 2> /dev/null

echo -e "📥 Downloading default config file..."
wget https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/zivpn/config.json 1> /dev/null 2> /dev/null

echo -e "🔐 Generating RSA certificate (please wait)..."
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
  -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" \
  -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt" > /dev/null 2>&1
echo -e "✅ Certificate created at /etc/zivpn/zivpn.crt"

echo -e "📶 Tuning system network buffers..."
sysctl -w net.core.rmem_max=16777216 1> /dev/null 2> /dev/null
sysctl -w net.core.wmem_max=16777216 1> /dev/null 2> /dev/null

echo -e "📝 Creating systemd service..."
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=🛡️ zivpn VPN Server
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

echo -e "🔑 ZIVPN UDP Passwords"
read -p "🧾 Enter passwords separated by commas (e.g. passwd1,passwd2). Press Enter for default 'zi': " input_config

if [ -n "$input_config" ]; then
    IFS=',' read -r -a config <<< "$input_config"
    if [ ${#config[@]} -eq 1 ]; then
        config+=(${config[0]})
    fi
else
    config=("zi")
fi

new_config_str="\"config\": [$(printf "\"%s\"," "${config[@]}" | sed 's/,$//')]"
echo -e "🛠️ Updating configuration file with new passwords..."
sed -i -E "s/\"config\": ?[[:space:]]*\"zi\"[[:space:]]*/${new_config_str}/g" /etc/zivpn/config.json

echo -e "🔄 Enabling and starting ZIVPN service..."
systemctl enable zivpn.service 1> /dev/null
systemctl start zivpn.service

echo -e "🌐 Adding iptables rules for UDP forwarding..."
iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -A PREROUTING -i "$iface" -p udp --dport 6000:19999 -j DNAT --to-destination :5667

echo -e "🧱 Allowing UFW firewall ports..."
ufw allow 6000:19999/udp 1> /dev/null
ufw allow 5667/udp 1> /dev/null

echo -e "🧹 Cleaning up temporary files..."
rm zi2.* 1> /dev/null 2> /dev/null

echo -e "✅ ZIVPN Installed successfully and running!"
