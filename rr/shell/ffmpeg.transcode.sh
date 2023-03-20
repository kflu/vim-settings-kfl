#!/bin/sh


USAGE="$(cat <<EOF
$(basename "$0") -s <SRC_DIR> -d <DEST_DIR>

It copies src to dest dir (create), transcodes mp4/MP4, then deletes the
original video (in dest dir) upon success.
EOF
)"
while getopts 'hs:d:' opt; do case "$opt" in
    s)    SRC_DIR="$OPTARG" ;;
    d)    DEST_DIR="$OPTARG" ;;
    h|*)  echo "$USAGE" >&2; exit 1 ;;
esac done
shift $((OPTIND-1))

: "${SRC_DIR:?}"
: "${DEST_DIR:?}"

mkdir -p "$DEST_DIR"
echo "Copying $SRC_DIR -> $DEST_DIR"
rsync -avz "$SRC_DIR" "$DEST_DIR"

cd "$DEST_DIR" || exit 1

find . -type f -name '*.mp4' -or -name '*.MP4' | \
while read -r fn; do
    echo "Transcoding $fn ====================="
    (
    cd "$(dirname "$fn")" || exit 1
    set -x
    ffmpeg -nostdin -vc h264_nvenc -preset medium \
        -i "$(basename "$fn")" \
        "transcoded.$(basename "$fn")"
    ) \
    && echo "$(date): Successfully tanscoded $fn. Now Deleting" \
    && rm "$fn"
done
