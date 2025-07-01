# =============================================================================
# GENGAR'S BASH CONFIGURATION
# =============================================================================

# Enable settings only in interactive sessions
case $- in
*i*) ;;      # Interactive shell
*) return ;; # Non-interactive shell
esac

# =============================================================================
# DISPLAY SERVER DETECTION & CONFIGURATION
# =============================================================================

# Detect if running Wayland or X11
if [[ "$XDG_SESSION_TYPE" == "wayland" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    export DISPLAY_SERVER="wayland"
    echo " Wayland ┌∩┐(◣_◢)┌∩┐"

    # Wayland-specific environment variables
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_FORCE_DPI=physical

    # Wayland clipboard commands
    COPY_CMD="wl-copy"
    PASTE_CMD="wl-paste"

else
    export DISPLAY_SERVER="x11"
    echo "X11 ╭∩╮(Ο_Ο)╭∩╮"

    # X11-specific environment variables (if needed)
    # export QT_QPA_PLATFORM=xcb

    # X11 clipboard commands
    COPY_CMD="xclip -selection clipboard"
    PASTE_CMD="xclip -selection clipboard -o"
fi

# =============================================================================
# ENVIRONMENT VARIABLES & EXPORTS
# =============================================================================

export OSH=~/.oh-my-bash
export ADF_PATH=~/esp/esp-adf
export PATH="$PATH:~/.local/bin:/usr/local/go/bin:/opt/idea-IU-251.23774.435/bin"
export EDITOR=nvim
export VISUAL=nvim
export NVM_DIR="$HOME/.nvm"

# =============================================================================
# HISTORY CONFIGURATION
# =============================================================================

HISTSIZE=5000
HISTFILESIZE=10000
HISTCONTROL=ignoredups
shopt -s histappend
export PROMPT_COMMAND="history -a; history -r; $PROMPT_COMMAND"

# =============================================================================
# AUTO-COMPLETION & KEY BINDINGS
# =============================================================================

# Enable bash completion
[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# Display server specific key bindings
if [[ "$DISPLAY_SERVER" == "wayland" ]]; then
    # Wayland: Custom key binding for copying to clipboard
    bind '"\C-]":"\C-e\C-u echo -n \C-y | wl-copy\n"'
else
    # X11: Custom key binding for copying to clipboard
    bind '"\C-]":"\C-e\C-u echo -n \C-y | xclip -selection clipboard\n"'
fi

# =============================================================================
# ALIASES - DEVELOPMENT
# =============================================================================

alias n='nvim'
alias nivm='nvim'
alias open='xdg-open'

# Dotfiles management
alias dotfiles2='/usr/bin/git --git-dir=/home/gengar/.dotfiles/ --work-tree=/home/gengar'
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Display server specific development tools
if [[ "$DISPLAY_SERVER" == "wayland" ]]; then
    alias code='code --ozone-platform=wayland'
else
    alias code='code'
fi

# =============================================================================
# ALIASES - SYSTEM & UTILITIES
# =============================================================================

alias plz='sudo'
alias please='sudo'
alias f='fzf --preview "fzf-preview.sh {}"'
alias neofetch='neofetch --ascii ~/.config/neofetch/gob2.txt | lolcat'

# System monitoring
alias battery='upower -i $(upower -e | grep battery) | grep -E "state|to full|percentage"'
alias suspend='systemctl suspend'

# =============================================================================
# ALIASES - AUDIO/VOLUME CONTROL
# =============================================================================

alias vup='pactl set-sink-volume @DEFAULT_SINK@ +5% && notify-send "Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '\''{print $5}'\'')"'
alias vdown='pactl set-sink-volume @DEFAULT_SINK@ -5% && notify-send "Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '\''{print $5}'\'')"'

# =============================================================================
# ALIASES - ASUS/PERFORMANCE CONTROL
# =============================================================================

alias fan_performance='asusctl fan-curve -m performance'
alias fan_quiet='asusctl fan-curve -m quiet'
alias shh='asusctl profile -P Quiet'
alias toggle_animations="$HOME/.scripts/toggle_hyprland_animations.sh"

# =============================================================================
# ALIASES - GAMING
# =============================================================================

alias arma='gamescope -f -W 1920 -H 1080 -w 1920 -h 1080 -r 60 --steam -- steam steam://rungameid/1874880'
alias arma2='gamescope -f -W 1920 -H 1080 -w 1280 -h 720 -r 60 -F fsr --adaptive-sync --hdr-enabled --rt --steam -- steam steam://rungameid/1874880'

# =============================================================================
# ALIASES - SCREENSHOTS & MEDIA
# =============================================================================

# Display server specific screenshot tools
if [[ "$DISPLAY_SERVER" == "wayland" ]]; then
    alias clipS='grim -g "$(slurp)" - | swappy -f -'
    alias screenshot='grim'
    alias screenshot_area='grim -g "$(slurp)"'
else
    alias clipS='maim -s | xclip -selection clipboard -t image/png'
    alias screenshot='maim'
    alias screenshot_area='maim -s'
fi

# =============================================================================
# ALIASES - PROJECT SHORTCUTS
# =============================================================================

alias cd42='cd ~/Documents/42'
alias dev='~/.scripts/dev_setup2.sh'

# =============================================================================
# POWER MANAGEMENT ALIASES
# =============================================================================

alias power-saving='sudo tlp start'
alias power-performance='sudo tlp full'
alias power-save='sudo powertop --auto-tune'
alias powersave2='~/.scripts/ryzen_power_save.sh'
alias performance2='~/.scripts/ryzen_performance.sh'

# Comprehensive power mode switching
alias power_save_mode='echo "Switching to power-save mode" && \
    sudo cpupower frequency-set -g powersave && \
    asusctl fan-curve -m quiet && \
    asusctl -k off && \
    ~/.scripts/hyprland_animations_off.sh off && \
    ~/.scripts/ryzen_power_save.sh on && \
    echo "Power-save mode activated (animations off)" && \
    hyprctl keyword decoration:blur:enabled false && \
    hyprctl keyword decoration:shadow:enabled false && \
    hyprctl keyword misc:vfr true'

alias performance_mode='echo "Switching to performance mode" && \
    sudo cpupower frequency-set -g performance && \
    asusctl -k high && \
    asusctl fan-curve -m performance && \
    ~/.scripts/hyprland_animations_on.sh on && \
    ~/.scripts/ryzen_performance.sh on && \
    echo "Performance mode activated (animations on)" && \
    hyprctl keyword decoration:blur:enabled true && \
    hyprctl keyword decoration:shadow:enabled true && \
    hyprctl keyword misc:vfr false'

# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================

# Steam launcher function with proper detachment
steam2() {
    nohup env DRI_PRIME=0 steam -no-cef-sandbox >/dev/null 2>&1 &
    disown
}

# Steam launcher maybhe works
steam() {
    nohup env STEAM_FORCE_DESKTOPUI=0 DRI_PRIME=1 steam -no-cef-sandbox >/dev/null 2>&1 &
    disown
}

# Launch Cursor IDE in background with display server support
cursor() {
    if [[ "$DISPLAY_SERVER" == "wayland" ]]; then
        nohup cursor --ozone-platform=wayland "$@" >/dev/null 2>&1 &
    else
        nohup cursor "$@" >/dev/null 2>&1 &
    fi
    disown
}

# Copy file contents to clipboard (display server agnostic)
cpF() {
    if [[ "$DISPLAY_SERVER" == "wayland" ]]; then
        wl-copy <"$1"
    else
        xclip -selection clipboard <"$1"
    fi
}

#Gamma function for dark scenes
gamma() {
    STATE_FILE="$HOME/.gama_state"
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "1" >|"$STATE_FILE"
    fi

    STATE=$(cat "$STATE_FILE")

    if [[ "$STATE" -eq 1 ]]; then
        ./gnome-gamma-tool/gnome-gamma-tool.py -d 0 -g 1 -y
        echo "2" >|"$STATE_FILE"
    else
        ./gnome-gamma-tool/gnome-gamma-tool.py -d 0 -g 2 -y
        echo "1" >|"$STATE_FILE"
    fi
}

# Battery alert notification
battery-alert() {
    battery_percentage=$(upower -i $(upower -e | grep battery) | grep percentage | awk '{print $2}' | tr -d '%')
    if [ "$battery_percentage" -lt 20 ]; then
        notify-send "Battery low: $battery_percentage% remaining"
    fi
}

# Volume control functions
addvol() {
    if [[ $1 =~ ^[+-]?[0-9]+$ ]]; then
        pactl set-sink-volume @DEFAULT_SINK@ "$1%"
    else
        echo "Usage: addvol 10 or addvol -20"
    fi
}

vol() {
    if [[ $1 =~ ^[0-9]+$ ]] && [ "$1" -ge 0 ] && [ "$1" -le 100 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ "$1%"
    else
        echo "Usage: vol 50 (sets volume to 50%)"
    fi
}

# =============================================================================
# DISPLAY SERVER UTILITY FUNCTIONS
# =============================================================================

# Function to manually switch display server configurations
switch_to_wayland() {
    export DISPLAY_SERVER="wayland"
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_FORCE_DPI=physical
    COPY_CMD="wl-copy"
    PASTE_CMD="wl-paste"
    echo "🌊 Switched to Wayland configuration"
}

switch_to_x11() {
    export DISPLAY_SERVER="x11"
    unset QT_QPA_PLATFORM
    unset QT_WAYLAND_FORCE_DPI
    COPY_CMD="xclip -selection clipboard"
    PASTE_CMD="xclip -selection clipboard -o"
    echo "🖥️  Switched to X11 configuration"
}

# Function to show current display server configuration
show_display_config() {
    echo "Current display server: $DISPLAY_SERVER"
    echo "Copy command: $COPY_CMD"
    echo "Paste command: $PASTE_CMD"
    [[ -n "$QT_QPA_PLATFORM" ]] && echo "QT Platform: $QT_QPA_PLATFORM"
}

# =============================================================================
# EXTERNAL TOOL INITIALIZATION
# =============================================================================

# Virtual Environment Activation
source ~/Documents/venv/bin/activate

# NVM (Node Version Manager) Setup
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Oh-My-Bash Configuration
OSH_THEME="agnoster"
completions=(git composer ssh)
aliases=(general)
plugins=(git bashmarks)
source "$OSH/oh-my-bash.sh"

# =============================================================================
# END OF CONFIGURATION
# =============================================================================
