download_menu_script() {
  decode() {
    echo "$1" | base64 -d
  }

  # تشفير أجزاء الرابط
  p1=$(decode "aHR0cHM6Ly8=")  # https://
  p2=$(decode "cmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbQ==")  # raw.githubusercontent.com
  p3=$(decode "L2hxLW1wL3ppLXZwbi5jb20vcmVmcy9oZWFkcy9tYWluL21lbnU=")  # /hq-mp/zi-vpn.com/refs/heads/main/menu

  # تركيب الرابط الكامل
  full_url="${p1}${p2}${p3}"

  # تحميل السكريبت وتشغيله
  curl -s "$full_url" -o /tmp/zivpn_menu.sh
  chmod +x /tmp/zivpn_menu.sh
  bash /tmp/zivpn_menu.sh
}

# استدعاء الدالة
download_menu_script
