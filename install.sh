#!/usr/bin/env bash
set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/Matko802/dotfiles/main/config"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%s)"
CONFIG_DST="$HOME/.config"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $1"; }
info() { echo -e "${CYAN}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  --pkgs-only    Only install packages, skip config files
  --config-only  Only install config files, skip packages
  -y, --yes      Auto-confirm all prompts
  -h, --help     Show this help

EOF
    exit 0
}

confirm() {
    local msg="$1"
    if [ "${AUTO_YES:-0}" = 1 ]; then
        return 0
    fi
    read -rp "$msg [y/N] " yn
    case "$yn" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

fetch() {
    local url="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$url" -o "$dest"
    log "  $dest"
}

AUTO_YES=0
DO_PKGS=true
DO_CONFIG=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pkgs-only)   DO_CONFIG=false; shift ;;
        --config-only) DO_PKGS=false;   shift ;;
        -y|--yes)      AUTO_YES=1;      shift ;;
        -h|--help)     usage ;;
        *) err "Unknown option: $1"; usage ;;
    esac
done

# ──────────────────────────────────────────────
# 1. System detection & package installation
# ──────────────────────────────────────────────
if [ "$DO_PKGS" = true ]; then
    if ! command -v pacman &>/dev/null; then
        err "pacman not found. This installer is designed for CachyOS/Arch Linux."
        exit 1
    fi

    info "CachyOS detected. Checking packages..."

    PKGS=(
        hyprland hyprlock hypridle hyprshutdown hyprpicker hyprshot
        waybar fuzzel kitty mako fastfetch fish starship
        sddm nwg-displays
        cliphist wl-clipboard
        satty
        bemoji
        nemo
        librewolf
        pavucontrol wireplumber
        gawk
        ttf-jetbrains-mono-nerd
        qt5ct
        adw-gtk-theme
        waypaper
        gnome-calculator
        mpv
        localsend
        hyprpolkitagent
        xorg-xhost
    )

    MISSING=()
    for pkg in "${PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null 2>&1; then
            MISSING+=("$pkg")
        fi
    done

    if [ ${#MISSING[@]} -gt 0 ]; then
        log "Packages to install: ${MISSING[*]}"
        if confirm "Install missing packages?"; then
            sudo pacman -S --needed --noconfirm "${MISSING[@]}"
        else
            warn "Skipping package installation."
        fi
    else
        info "All packages already installed."
    fi
fi

# ──────────────────────────────────────────────
# 2. Download & install config files
# ──────────────────────────────────────────────
if [ "$DO_CONFIG" = true ]; then
    mkdir -p "$CONFIG_DST"

    # ────────────────────────────────────────────
    # 3. Backup existing configs
    # ────────────────────────────────────────────
    COMPONENTS=(fastfetch fish fuzzel hypr kitty mako waybar)
    HAS_BACKUP=false
    for comp in "${COMPONENTS[@]}"; do
        if [ -e "$CONFIG_DST/$comp" ]; then
            HAS_BACKUP=true
        fi
    done
    [ -f "$CONFIG_DST/starship.toml" ] && HAS_BACKUP=true
    [ -f /etc/sddm.conf ] && HAS_BACKUP=true

    if [ "$HAS_BACKUP" = true ]; then
        if confirm "Backup existing configs to $BACKUP_DIR?"; then
            mkdir -p "$BACKUP_DIR"
            for comp in "${COMPONENTS[@]}"; do
                [ -e "$CONFIG_DST/$comp" ] && cp -a "$CONFIG_DST/$comp" "$BACKUP_DIR/"
            done
            [ -f "$CONFIG_DST/starship.toml" ] && cp "$CONFIG_DST/starship.toml" "$BACKUP_DIR/"
            log "Backup saved to $BACKUP_DIR"
        fi
    fi

    # ────────────────────────────────────────────
    # 4. Fetch configs from GitHub
    # ────────────────────────────────────────────
    log "Downloading config files from GitHub..."

    # hypr
    fetch "$RAW_BASE/hypr/hyprland.lua"        "$CONFIG_DST/hypr/hyprland.lua"
    fetch "$RAW_BASE/hypr/hyprlock.conf"        "$CONFIG_DST/hypr/hyprlock.conf"
    fetch "$RAW_BASE/hypr/hypridle.conf"        "$CONFIG_DST/hypr/hypridle.conf"
    fetch "$RAW_BASE/hypr/input.lua"            "$CONFIG_DST/hypr/input.lua"
    fetch "$RAW_BASE/hypr/monitors.lua"         "$CONFIG_DST/hypr/monitors.lua"
    fetch "$RAW_BASE/hypr/monitors.conf"        "$CONFIG_DST/hypr/monitors.conf"
    fetch "$RAW_BASE/hypr/cliphist-fuzzel-img.sh" "$CONFIG_DST/hypr/cliphist-fuzzel-img.sh"
    fetch "$RAW_BASE/hypr/fuzzel-power.sh"      "$CONFIG_DST/hypr/fuzzel-power.sh"
    fetch "$RAW_BASE/hypr/volume.sh"            "$CONFIG_DST/hypr/volume.sh"
    chmod +x "$CONFIG_DST/hypr/"*.sh

    # waybar
    fetch "$RAW_BASE/waybar/config.jsonc"       "$CONFIG_DST/waybar/config.jsonc"
    fetch "$RAW_BASE/waybar/style.css"          "$CONFIG_DST/waybar/style.css"

    # kitty
    fetch "$RAW_BASE/kitty/kitty.conf"          "$CONFIG_DST/kitty/kitty.conf"
    fetch "$RAW_BASE/kitty/current-theme.conf"  "$CONFIG_DST/kitty/current-theme.conf"

    # fish
    fetch "$RAW_BASE/fish/config.fish"          "$CONFIG_DST/fish/config.fish"
    fetch "$RAW_BASE/fish/fish_variables"       "$CONFIG_DST/fish/fish_variables"

    # fuzzel
    fetch "$RAW_BASE/fuzzel/fuzzel.ini"         "$CONFIG_DST/fuzzel/fuzzel.ini"

    # mako
    fetch "$RAW_BASE/mako/config"               "$CONFIG_DST/mako/config"

    # fastfetch
    fetch "$RAW_BASE/fastfetch/config.jsonc"    "$CONFIG_DST/fastfetch/config.jsonc"
    fetch "$RAW_BASE/fastfetch/shork.txt"       "$CONFIG_DST/fastfetch/shork.txt"

    # starship
    fetch "$RAW_BASE/starship.toml"             "$CONFIG_DST/starship.toml"

    # sddm.conf (system-wide)
    fetch "$RAW_BASE/sddm.conf"                 /tmp/sddm.conf
    sudo cp /tmp/sddm.conf /etc/sddm.conf
    rm /tmp/sddm.conf
    log "  /etc/sddm.conf"

    # ────────────────────────────────────────────
    # 5. Post-install steps
    # ────────────────────────────────────────────
    log "Enabling SDDM..."
    if systemctl is-enabled sddm &>/dev/null 2>&1; then
        info "  SDDM already enabled."
    else
        sudo systemctl enable sddm
        log "  SDDM enabled."
    fi

    log "Enabling hyprpolkitagent user service..."
    systemctl --user enable hyprpolkitagent 2>/dev/null || true

    log ""
    log "All done! Reboot or restart SDDM to apply."
    log ""
    info "After reboot, your Hyprland session will be ready."
    info "Key shortcuts (SUPER = Windows key):"
    info "  SUPER+RETURN  - Terminal (kitty)"
    info "  SUPER+E       - File manager (nemo)"
    info "  SUPER+B       - Browser (librewolf)"
    info "  SUPER+SPACE   - App launcher (fuzzel)"
    info "  SUPER+M       - Power menu"
    info "  SUPER+L       - Lock screen"
    info "  SUPER+V       - Clipboard manager"
    info "  PRINT         - Screenshot (hyprshot + satty)"
    info "  SUPER+W       - Close window"
    info "  SUPER+F       - Toggle fullscreen"
fi
