#!/run/current-system/sw/bin/bash
battery_percentage=$(cat /sys/class/power_supply/BAT1/capacity)

echo "Battery: $battery_percentage%"
