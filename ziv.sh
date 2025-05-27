#!/bin/bash
# ZIVPN - توليد ملفات config مستقلة لكل حساب

echo -e "ZIVPN VPS - إنشاء حساب جديد بإعداد مستقل"

# مجلد الإعداد
CONFIG_DIR="/etc/zivpn"
mkdir -p "$CONFIG_DIR"

# طلب كلمة/كلمات المرور من المستخدم
echo -e "ZIVPN UDP Passwords"
read -p "Enter passwords separated by commas (example: pass1,pass2): " input_pass

if [ -z "$input_pass" ]; then
    echo "No passwords entered. Exiting."
    exit 1
fi

IFS=',' read -r -a passes <<< "$input_pass"

# إنشاء اسم عشوائي للملف
RANDOM_ID=$(head /dev/urandom | tr -dc a-z0-9 | head -c 6)
NEW_CONFIG="$CONFIG_DIR/config-$RANDOM_ID.json"

# كتابة الملف الجديد
echo "{
  \"listen\": \":5667\",
  \"timeout\": 60,
  \"config\": [" > "$NEW_CONFIG"

for pass in "${passes[@]}"; do
    echo "    \"$pass\"," >> "$NEW_CONFIG"
done

# إزالة الفاصلة الأخيرة
sed -i '$ s/,$//' "$NEW_CONFIG"
echo "  ]
}" >> "$NEW_CONFIG"

echo "Created config file: $NEW_CONFIG"

# توليد الشهادة إذا لم تكن موجودة
if [ ! -f "$CONFIG_DIR/zivpn.key" ]; then
    echo "Generating SSL cert..."
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" \
        -keyout "$CONFIG_DIR/zivpn.key" -out "$CONFIG_DIR/zivpn.crt"
fi

# تحديث ملف الخدمة ليستخدم الملف الجديد
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=zivpn VPN Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$CONFIG_DIR
ExecStart=/usr/local/bin/zivpn server -c $NEW_CONFIG
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# إعادة تشغيل الخدمة
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable zivpn.service
systemctl restart zivpn.service

echo -e "ZIVPN is running using: $NEW_CONFIG"
