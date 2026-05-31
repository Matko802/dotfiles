OPTIONS="󰌾 Lock\n󰒲 Suspend\n Reboot\n󰐥 Shutdown\n󰠚 Log Out"

SELECTION=$(printf "$OPTIONS" | fuzzel --dmenu --lines=5 --width=15)

case "$SELECTION" in
    *"Lock")
        hyprlock
        ;;
    *"Suspend")
        systemctl suspend
        ;;
    *"Reboot")
        systemctl reboot
        ;;
    *"Shutdown")
        systemctl poweroff
        ;;
    *"Log Out")
        hyprctl dispatch 'hl.dsp.exit()'
        ;;
esac
