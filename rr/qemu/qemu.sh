#!/bin/sh

: "${cpu_count:=1}"
: "${disk_file:?}"
: "${mem:="1G"}"
: "${cdrom_iso:=}"
: "${sound_enable:=}"

if [ -n "$cdrom_iso" ]; then
    # shellcheck disable=2034
    cdrom_flags="-cdrom \"$cdrom_iso\""
fi

if [ -n "$sound_enable" ]; then
    # shellcheck disable=2034
    sound_flags="-soundhw all"
fi

if [ -n "$flash_file" ]; then
    flash_flags="\
        -device piix3-usb-uhci \
        -drive id=pendrive,file="$flash_file",format=raw,if=none \
        -device usb-storage,drive=pendrive \
        -boot menu=on \
"

fi
echo \

cmd="$(cat <<'EOF'
$qemu_cmd \
-smp "$cpu_count" \
-hda "$disk_file" \
-m "$mem" \
$cdrom_flags \
$sound_flags \
# END
EOF
)"

eval "$cmd"

