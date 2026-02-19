#!/run/current-system/sw/bin/bash

# Path to hypridle executable
HYPRIDLE_CMD="/run/current-system/sw/bin/hypridle"

# Log file for debugging (optional)
LOG_FILE="$HOME/.config/waybar/hypridle_toggle.log"

# Function to log messages
log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

log "Toggling Hypridle..."

# Check if hypridle is running
if pgrep -x "$(basename "$HYPRIDLE_CMD")" > /dev/null; then
    log "Hypridle is running. Attempting to kill..."
    pkill -x "$(basename "$HYPRIDLE_CMD")"
    
    # Verify if hypridle was killed
    if pgrep -x "$(basename "$HYPRIDLE_CMD")" > /dev/null; then
        log "Failed to kill Hypridle."
        notify-send "Hypridle" "Failed to disable" >/dev/null 2>&1 &
    else
        log "Hypridle killed successfully."
        notify-send "Hypridle" "Disabled" >/dev/null 2>&1 &
    fi
else
    log "Hypridle is not running. Starting..."
    "$HYPRIDLE_CMD" >/dev/null 2>&1 &
    
    # Allow hypridle some time to start
    sleep 0.5
    
    # Verify if hypridle started
    if pgrep -x "$(basename "$HYPRIDLE_CMD")" > /dev/null; then
        log "Hypridle started successfully."
        notify-send "Hypridle" "Enabled" >/dev/null 2>&1 &
    else
        log "Failed to start Hypridle."
        notify-send "Hypridle" "Failed to enable" >/dev/null 2>&1 &
    fi
fi

log "Toggle script completed."
exit 0

