#!/bin/bash
# Zivpn UDP Module installer - AMD x64
# Creator Zahid Islam
# Bash fixed by OpenAI

INSTALL_FLAG="/etc/zivpn/installed.flag"

if [[ -f "$INSTALL_FLAG" ]]; then
  read -p "This will create a new account. You may lose previous accounts. Continue? [Y/N]: " choice
  case "$choice" in
    [Yy]* ) echo "Continuing with reinstall...";;
    * ) echo "Aborted."; exit 0;;
  esac
fi

echo -e "Updating server"
sudo apt-get update && apt-get upgrade -y
systemctl stop zivpn.service 1> /dev/null 2> /dev/null

echo -e "Downloading UDP Service"
wget -q https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn
chmod +x /usr/local/bin/zivpn

mkdir -p /etc/zivpn

# Create default config if not exists
if [[ ! -f /etc/zivpn/config.json ]]; then
  echo '{"listen":"0.0.0.0:5667","target":"127.0.0.1:443","config":["zi"]}' > /etc/zivpn/config.json
fi

# Generate certs if not exists
if [[ ! -f /etc/zivpn/zivpn.key || ! -f /etc/zivpn/zivpn.crt ]]; then
  echo "Generating cert files:"
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=California/L=Los Angeles/O=ZIVPN/CN=zivpn" \
    -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
fi

sysctl -w net.core.rmem_max=16777216 > /dev/null 2>&1
sysctl -w net.core.wmem_max=16777216 > /dev/null 2>&1

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

# قراءة الباسوردات القديمة
existing_passwords=$(grep -oP '"config":\s*\K[^]+' /etc/zivpn/config.json | tr -d '"' | tr ',' '\n')

# تحويلها لـ associative array باش نتجنب التكرار
declare -A passwords_map
for p in $existing_passwords; do
  passwords_map["$p"]=1
done

# طلب باسوردات جديدة
echo -e "ZIVPN UDP Passwords"
read -p "Enter passwords separated by commas, example: passwd1,passwd2 (Press enter for Default 'zi'): " input_config

if [ -n "$input_config" ]; then
  IFS=',' read -ra new_passes <<< "$input_config"
  for p in "${new_passes[@]}"; do
    passwords_map["$p"]=1
  done
fi

# إعداد السطر النهائي
final_passwords=()
for key in "${!passwords_map[@]}"; do
  final_passwords+=("\"$key\"")
done

config_line="\"config\": [$(IFS=, ; echo "${final_passwords[*]}")]"

# تحديث config.json
sed -i -E "s/\"config\":\s*[^]]*/$config_line/" /etc/zivpn/config.json

# إعادة تشغيل الخدمة
systemctl daemon-reload
systemctl enable zivpn.service
systemctl restart zivpn.service

# إعداد iptables
iface=$(ip route get 1.1.1.1 | awk '{print $5; exit}')
iptables -t nat -A PREROUTING -i "$iface" -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp
ufw allow 5667/udp

# وضع علامة التثبيت لأول مرة
touch "$INSTALL_FLAG"

rm -f zi2.* 2> /dev/null
echo -e "ZIVPN Installed"
