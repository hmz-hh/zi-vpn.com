#!/bin/bash
# Zivpn UDP Module installer - AMD x64
# Creator hamza
# Bash by PowerMX

echo -e "Updating server"
systemctl stop zivpn.service 1> /dev/null 2> /dev/null

echo -e "Downloading UDP Service"
wget https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn 1> /dev/null 2> /dev/null
chmod +x /usr/local/bin/zivpn
mkdir -p /etc/zivpn 1> /dev/null 2> /dev/null

wget https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/zivpn/config.json 1> /dev/null 2> /dev/null

echo "Generating cert files:"
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"

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

# Install jq if not found
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found, installing..."
    apt-get update -qq
    apt-get install -y -qq jq
fi

# Read old config passwords
mapfile -t old_config < <(jq -r '.config[]' /etc/zivpn/config.json)

echo -e "ZIVPN UDP Passwords"
read -p "Enter passwords separated by commas, example: passwd1,passwd2 (Press enter for Default 'zi'): " input_config

if [ -n "$input_config" ]; then
    IFS=',' read -r -a new_config <<< "$input_config"
    if [ ${#new_config[@]} -eq 1 ]; then
        new_config+=("${new_config[0]}")
    fi
else
    new_config=("zi")
fi

# Merge and remove duplicates
declare -A seen
merged=()
for pw in "${old_config[@]}" "${new_config[@]}"; do
    [[ -z "$pw" ]] && continue
    if [[ -z "${seen[$pw]}" ]]; then
        merged+=("$pw")
        seen[$pw]=1
    fi
done

# Convert to JSON and save
json_array=$(printf '%s\n' "${merged[@]}" | jq -R . | jq -s .)
jq --argjson arr "$json_array" '.config = $arr' /etc/zivpn/config.json \
    > /etc/zivpn/config.tmp && mv /etc/zivpn/config.tmp /etc/zivpn/config.json

systemctl enable zivpn.service
systemctl restart zivpn.service

# Port forwarding
iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
iptables -t nat -A PREROUTING -i "$iface" -p udp --dport 6000:19999 -j DNAT --to-destination :5667
ufw allow 6000:19999/udp
ufw allow 5667/udp

rm zi2.* 1> /dev/null 2> /dev/null

echo -e "ZIVPN Installed"
