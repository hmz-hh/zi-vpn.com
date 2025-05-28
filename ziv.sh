#!/bin/bash
# … (بقية السكريبت كما هو)

# 1) تنصيب jq إذا لم يكن موجودًا
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found, installing..."
    apt-get update -qq
    apt-get install -y -qq jq
fi

# 2) قراءة قائمة الـconfig الحالية
mapfile -t old_config < <(jq -r '.config[]' /etc/zivpn/config.json)

# 3) إدخال كلمات المرور الجديدة
echo -e "ZIVPN UDP Passwords"
read -p "Enter passwords separated by commas, example: passwd1,passwd2 (Press enter for Default 'zi'): " input_config
if [ -n "$input_config" ]; then
    IFS=',' read -r -a new_config <<< "$input_config"
    # إذا أدخل كلمة واحدة فقط، كررها ليتوافق مع الشكل القديم
    if [ ${#new_config[@]} -eq 1 ]; then
        new_config+=("${new_config[0]}")
    fi
else
    new_config=("zi")
fi

# 4) دمج القديم مع الجديد وحذف المكرّر
declare -A seen
merged=()
for pw in "${old_config[@]}" "${new_config[@]}"; do
    # نتجاهل العناصر الفارغة
    [[ -z "$pw" ]] && continue
    if [[ -z "${seen[$pw]}" ]]; then
        merged+=("$pw")
        seen[$pw]=1
    fi
done

# 5) تحويل المصفوفة إلى JSON وكتابة الملف
# نبني تمثيل JSON يدويًا: ["pw1","pw2",…]
json_array=$(printf '%s\n' "${merged[@]}" | jq -R . | jq -s .)
jq --argjson arr "$json_array" '.config = $arr' /etc/zivpn/config.json \
    > /etc/zivpn/config.tmp && mv /etc/zivpn/config.tmp /etc/zivpn/config.json

# 6) تفعيل وتشغيل الخدمة كما في السكريبت الأصلي
systemctl enable zivpn.service
systemctl restart zivpn.service

# … (بقية السكريبت: iptables, ufw, cleanup, الخ.)
