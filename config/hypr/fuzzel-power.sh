OPTIONS="󰌾 Lock\n󰒲 Suspend\n Reboot\n󰐥 Shutdown\n󰠚 Log Out"
SELECTION=$(printf "$OPTIONS" | fuzzel --dmenu --lines=5 --width=15)
case "$SELECTION" in
    *"Lock")
        hyprlock
        ;;
    *"Suspend")
        hyprlock & sleep 1 && systemctl suspend
        ;;
    *"Reboot")
        hyprshutdown -t 'Restarting...' --post-cmd 'systemctl reboot'
        ;;
    *"Shutdown")
        hyprshutdown -t 'Shutting down...' --post-cmd 'systemctl poweroff'
        ;;
    *"Log Out")
        hyprshutdown -t 'Logging out...'
        ;;
esac
