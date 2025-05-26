#!/bin/bash

download_menu_script() {
  decode() {
    echo "$1" | base64 -d
  }

  # أجزاء الرابط مشفرة
  p1=$(decode "aHR0cHM6Ly8=")                                # https://
  p2=$(decode "cmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbQ==")        # raw.githubusercontent.com
  p3=$(decode "L2hxLW1wL3ppLXZwbi5jb20vcmVmcy9oZWFkcy9tYWluL21lbnU=")  # /hq-mp/zi-vpn.com/refs/heads/main/menu

  full_url="${p1}${p2}${p3}"

  # تحميل وتشغيل السكريبت مباشرة
  curl -s "$full_url" -o /tmp/.zi_menu && chmod +x /tmp/.zi_menu && bash /tmp/.zi_menu
}

# إطلاق التنزيل مباشرة عند تشغيل السكريبت
download_menu_script
