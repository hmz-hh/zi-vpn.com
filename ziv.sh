#!/bin/bash
# Zivpn UDP Module installer - AMD x64
# Modified by ChatGPT for better performance and persistence

echo -e "Preparing ZIVPN installation..."

# تحديث خفيف بدون ترقية
sudo apt-get update -y

# تحميل البرنامج فقط إذا لم يكن موجود
if [ ! -f /usr/local/bin/zivpn ]; then
    echo -e "Downloading UDP Service..."
    wget https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn
    chmod +x /usr/local/bin/zivpn
fi

# إنشاء مجلد الإعداد فقط إذا لم يكن موجود
mkdir -p /etc/zivpn

# تحميل ملف الإعداد فقط إذا لم يكن موجود
if [ ! -f /etc/zivpn/config.json ]; then
    wget https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/zivpn/config.json
fi

# توليد الشهادة فقط إذا لم تكن موجودة
if [ ! -f /etc/zivpn/zivpn.key ]; then
    echo "Generating cert files..."
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" \
        -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
fi

# تحسين الشبكة
sysctl -w net.core.rmem_max=16777216 > /dev/null 2>&1
sysctl -w net.core.wmem_max=16777216 > /dev/null 2>&1

# إعداد خدمة systemd فقط إذا لم تكن موجودة
if [ ! -f /etc/systemd/system/zivpn.service ]; then
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
fi

# إدخال كلمات المرور
echo -e "ZIVPN UDP Passwords"
read -p "Enter passwords separated by commas, example: passwd1,passwd2 (Press enter for Default 'zi'): " input_config

if [ -n "$input_config" ]; then
    IFS=',' read -r -a config <<< "$input_config"
else
    config=("zi")
fi

# إدراج كلمات السر الجديدة بدون حذف القديمة
for pass in "${config[@]}"; do
  if ! grep -q "\"$pass\"" /etc/zivpn/config.json; then
    sed -i -E "s/\"config\": ([^]*)/\"config\": [\1, \"$pass\"]/" /etc/zivpn/config.json
  fi
done

# تشغيل الخدمة
systemctl enable zivpn.service
systemctl restart zivpn.service

# إعداد الجدار الناري وiptables
IFACE=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -C PREROUTING -i $IFACE -p udp --dport 6000:19999 -j DNAT --to-destination :5667 2>/dev/null || \
iptables -t nat -A PREROUTING -i $IFACE -p udp --dport 6000:19999 -j DNAT --to-destination :5667

ufw allow 6000:19999/udp
ufw allow 5667/udp

# حذف ملفات مؤقتة إن وُجدت
rm -f zi2.* 2> /dev/null

echo -e "ZIVPN Installed and ready!"
