#!/bin/sh

USAGE="$(cat <<EOF
-d <disk_file> [-m <mem>] [-c <cpus>] [-D]

-D: dry run

All Settings
=============
$(
<"$0" grep -E '^ *:'
)
EOF
)"
while getopts 'hDd:c:m:' opt; do case "$opt" in
    m)      mem="$OPTARG" ;;
    c)      cpu_count="$OPTARG" ;;
    d)      disk_file="$OPTARG" ;;
    D)      dry_run=1 ;;
    h|*)    echo "$USAGE" >&2; exit 1 ;;
esac done
shift $((OPTIND-1))


: "${qemu_cmd:="qemu-system-x86_64"}"
: "${cpu_count:=1}"
: "${disk_file:?}"
: "${mem:="1G"}"
: "${cdrom_iso:=}"
: "${sound_enable:=1}"

if [ -n "$cdrom_iso" ]; then
    # shellcheck disable=2034
    cdrom_flags="-cdrom \"$cdrom_iso\""
fi

if [ -n "$sound_enable" ]; then
    # shellcheck disable=2034
    sound_flags="-soundhw all"
fi

if [ -n "$flash_file" ]; then
    # shellcheck disable=2034,2016
    flash_flags='
-device piix3-usb-uhci \
-drive id=pendrive,file="$flash_file",format=raw,if=none \
-device usb-storage,drive=pendrive \
-boot menu=on \
'
fi

cmd="$(cat <<'EOF'
$qemu_cmd \
-smp "$cpu_count" \
-hda "$disk_file" \
-m "$mem" \
$cdrom_flags \
$sound_flags \
$flash_flags \
# END
EOF
)"

if [ -n "$dry_run" ]; then
    echo "would run:"
    eval echo "$cmd"
else
    (set -x; eval "$cmd")
fi
