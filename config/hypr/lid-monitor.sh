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

lock_noctalia() {
  local pid
  pid=$(systemctl --user show -p MainPID --value noctalia-shell.service 2>/dev/null || echo "")
  if [[ -n "$pid" && "$pid" != "0" ]]; then
    qs ipc --pid "$pid" call lockScreen lock >/dev/null 2>&1 || true
  fi
}

suspend_debounced() {
  # Prevent rapid re-suspends if lid event fires multiple times
  local stamp="${XDG_RUNTIME_DIR:-/tmp}/hypr-suspend.last"
  local now last=0
  now="$(date +%s)"
  [[ -f "$stamp" ]] && last="$(cat "$stamp" 2>/dev/null || echo 0)"

  if (( now - last >= 3 )); then
    echo "$now" > "$stamp"
    # small delay so lock surface is up before suspend
    sleep 0.4
    # prefer loginctl for unprivileged users
    loginctl suspend >/dev/null 2>&1 || systemctl suspend >/dev/null 2>&1 || true
  fi
}

reload_on_removal_if_needed() {
  if [[ "${HYPRLAND_EVENT:-}" == "monitorremoved" ]]; then
    local stamp="${XDG_RUNTIME_DIR:-/tmp}/hypr-reload.last"
    local now last=0
    now="$(date +%s)"
    [[ -f "$stamp" ]] && last="$(cat "$stamp" 2>/dev/null || echo 0)"

    if (( now - last >= 2 )); then
      echo "$now" > "$stamp"
      sleep 0.2
      hyprctl reload >/dev/null 2>&1 || true
    fi
  fi
}

# ---- main ----
mapfile -t ext < <(externals)

if lid_closed; then
  # If NO external monitors: lock with Noctalia and suspend
  if [[ ${#ext[@]} -eq 0 ]]; then
    lock_noctalia
    suspend_debounced
    exit 0
  fi

  # External monitor(s) present: disable internal and move workspaces as before
  hyprctl keyword monitor "${INTERNAL},disable" >/dev/null 2>&1 || true
  sleep 0.15

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
  # Lid opened: bring internal back. Noctalia stays locked until you unlock.
  ensure_internal_visible
fi

reload_on_removal_if_needed