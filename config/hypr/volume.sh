VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep MUTED)
SYNC_HINT="-h string:x-canonical-private-synchronous:volume"

if [ -n "$MUTE" ]; then
    notify-send -a "Volume" -u low -i "audio-volume-muted" \
        $SYNC_HINT \
        -h int:value:0 \
        -t 2000 \
        "Muted"
else
    ICON="audio-volume-high"
    if [ "$VOL" -lt 30 ]; then ICON="audio-volume-low"; elif [ "$VOL" -lt 70 ]; then ICON="audio-volume-medium"; fi

    notify-send -a "Volume" -u low -i "$ICON" \
        $SYNC_HINT \
        -h int:value:"$VOL" \
        -t 2000 \
        "Volume: ${VOL}%"
fi   
