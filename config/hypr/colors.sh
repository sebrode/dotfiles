#!/run/current-system/sw/bin/bash
# Read colors from pywal output
fg=$(sed -n '10p' ~/.cache/wal/colors)
accent=$(sed -n '3p' ~/.cache/wal/colors)

# Set colors dynamically using hyprctl
hyprctl keyword general:col.active_border "rgba($fg) rgba($accent) 45deg"
hyprctl keyword general:col.inactive_border "rgba(595959aa)"
