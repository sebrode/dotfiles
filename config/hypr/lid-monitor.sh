#!/usr/bin/env bash
set -euo pipefail

INTERNAL="eDP-1"

lid_closed() {
  grep -qi "closed" /proc/acpi/button/lid/*/state 2>/dev/null
}

# list active monitor names in current order
monitors() {
  hyprctl monitors | awk '/Monitor/ {print $2}'
}

externals() {
  monitors | grep -v "^${INTERNAL}$"
}

move_ws() {
  local ws="$1"
  local mon="$2"
  hyprctl dispatch moveworkspacetomonitor "$ws" "$mon" >/dev/null 2>&1 || true
}

focus_mon() {
  local mon="$1"
  hyprctl dispatch focusmonitor "$mon" >/dev/null 2>&1 || true
}

if lid_closed; then
  # Disable laptop panel if present
  hyprctl keyword monitor "${INTERNAL},disable" >/dev/null 2>&1 || true

  # Figure out which externals are active (first two)
  sleep 0.1
  mapfile -t ext < <(externals)

  # If we have at least one external, pin 1-2 there
  if [[ ${#ext[@]} -ge 1 ]]; then
    move_ws 1 "${ext[0]}"
    move_ws 2 "${ext[0]}"
    focus_mon "${ext[0]}"
  fi

  # If we have a second external, pin 3-4 there, otherwise keep them on ext[0]
  if [[ ${#ext[@]} -ge 2 ]]; then
    move_ws 3 "${ext[1]}"
    move_ws 4 "${ext[1]}"
  elif [[ ${#ext[@]} -ge 1 ]]; then
    move_ws 3 "${ext[0]}"
    move_ws 4 "${ext[0]}"
  fi

else
  # Lid open: enable internal again
  hyprctl keyword monitor "${INTERNAL},preferred,auto,1.333333" >/dev/null 2>&1 || true
fi
