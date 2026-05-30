VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep MUTED)

if [ -n "$MUTE" ]; then
    dunstify -a "Volume" -u low -i "audio-volume-muted" -r 9993 -h int:value:0 -t 2000 "Muted"
else
    dunstify -a "Volume" -u low -i "audio-volume-high" -r 9993 -h int:value:"$VOL" -t 2000 "Volume: ${VOL}%"
fi
