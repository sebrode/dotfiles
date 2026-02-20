#!/usr/bin/env bash
set -euo pipefail

INTERNAL="eDP-1"

lid_closed() {
  grep -qi "closed" /proc/acpi/button/lid/*/state 2>/dev/null
}

monitors() {
  hyprctl monitors | awk '/Monitor/ {print $2}'
}

externals() {
  monitors | grep -v "^${INTERNAL}$" || true
}

move_ws() {
  local ws="$1" mon="$2"
  hyprctl dispatch moveworkspacetomonitor "$ws" "$mon" >/dev/null 2>&1 || true
}

focus_mon() {
  local mon="$1"
  hyprctl dispatch focusmonitor "$mon" >/dev/null 2>&1 || true
}

ensure_internal_visible() {
  hyprctl keyword monitor "${INTERNAL},preferred,auto,1.333333" >/dev/null 2>&1 || true
  hyprctl dispatch dpms on "${INTERNAL}" >/dev/null 2>&1 || true

  for ws in $(seq 1 10); do
    move_ws "$ws" "$INTERNAL"
  done

  focus_mon "$INTERNAL"
  hyprctl dispatch workspace 1 >/dev/null 2>&1 || true
}

reload_on_removal_if_needed() {
  # If this run was triggered by monitor removal, Hyprland can end up with
  # missing workspaces / dead layer surfaces. A reload fixes it for you.
  # Debounce so we don't crash by reloading 10 times in a second.
  if [[ "${HYPRLAND_EVENT:-}" == "monitorremoved" ]]; then
    local stamp="${XDG_RUNTIME_DIR:-/tmp}/hypr-reload.last"
    local now
    now="$(date +%s)"

    local last=0
    [[ -f "$stamp" ]] && last="$(cat "$stamp" 2>/dev/null || echo 0)"

    # only allow one reload every 2 seconds
    if (( now - last >= 2 )); then
      echo "$now" > "$stamp"
      # tiny delay so outputs settle before reload
      sleep 0.2
      hyprctl reload >/dev/null 2>&1 || true
    fi
  fi
}

# ---- main ----
if lid_closed; then
  hyprctl keyword monitor "${INTERNAL},disable" >/dev/null 2>&1 || true

  sleep 0.15
  mapfile -t ext < <(externals)

  if [[ ${#ext[@]} -eq 0 ]]; then
    ensure_internal_visible
    reload_on_removal_if_needed
    exit 0
  fi

  move_ws 1 "${ext[0]}"
  move_ws 2 "${ext[0]}"
  focus_mon "${ext[0]}"

  if [[ ${#ext[@]} -ge 2 ]]; then
    move_ws 3 "${ext[1]}"
    move_ws 4 "${ext[1]}"
  else
    move_ws 3 "${ext[0]}"
    move_ws 4 "${ext[0]}"
  fi
else
  ensure_internal_visible
fi

reload_on_removal_if_needed
