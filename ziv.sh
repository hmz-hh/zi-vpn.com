#!/bin/bash
# ZIVPN UDP Installer (مبسّط)

echo -e "Updating server..."
apt-get update -y && apt-get upgrade -y

# تحميل البرنامج إذا غير موجود
if [ ! -f /usr/local/bin/zivpn ]; then
    echo -e "Downloading UDP Service..."
    wget -q https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn
    chmod +x /usr/local/bin/zivpn
fi

# إنشاء مجلد الإعداد
mkdir -p /etc/zivpn

# توليد الشهادة إذا غير موجودة
if [ ! -f /etc/zivpn/zivpn.key ]; then
    echo "Generating cert files..."
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" \
        -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
fi

# إعداد الشبكة (مرة وحدة كافية)
sysctl -w net.core.rmem_max=16777216 > /dev/null
sysctl -w net.core.wmem_max=16777216 > /dev/null

# أخذ كلمات السر من المستخدم
echo -e "ZIVPN Passwords:"
read -p "Enter passwords separated by commas (default: zi): " input_pass

if [ -z "$input_pass" ]; then
    input_pass="zi"
fi
IFS=',' read -r -a pass_array <<< "$input_pass"

# توليد اسم ملف جديد عشوائي
RANDOM_ID=$(head /dev/urandom | tr -dc a-z0-9 | head -c 6)
CONFIG_FILE="/etc/zivpn/config-$RANDOM_ID.json"

# كتابة config الجديد
echo "{
  \"listen\": \":5667\",
  \"timeout\": 60,
  \"config\": [" > "$CONFIG_FILE"
for pass in "${pass_array[@]}"; do
    echo "    \"$pass\"," >> "$CONFIG_FILE"
done
sed -i '$ s/,$//' "$CONFIG_FILE"
echo "  ]
}" >> "$CONFIG_FILE"

# إعداد الخدمة لتستخدم الملف الجديد
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=ZIVPN UDP Server
After=network.target

[Service]
ExecStart=/usr/local/bin/zivpn server -c $CONFIG_FILE
Restart=always
RestartSec=3
WorkingDirectory=/etc/zivpn
User=root
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# تفعيل وتشغيل الخدمة
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable zivpn.service
systemctl restart zivpn.service

# فتح المنافذ
IFACE=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -C PREROUTING -i $IFACE -p udp --dport 6000:19999 -j DNAT --to-destination :5667 2>/dev/null || \
iptables -t nat -A PREROUTING -i $IFACE -p udp --dport 6000:19999 -j DNAT --to-destination :5667

ufw allow 6000:19999/udp
ufw allow 5667/udp

echo -e "ZIVPN installed and running with config: $CONFIG_FILE"
