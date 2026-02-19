#!/usr/bin/env bash
set -euo pipefail

# Debounce: hotplug/reload can trigger multiple times quickly.
# This lock ensures only one restart runs at a time.
lock="${XDG_RUNTIME_DIR:-/tmp}/waybar-restart.lock"
exec 9>"$lock"
flock -n 9 || exit 0

# Kill by pattern (works for waybar, waybar-wrapped, and nix store paths)
pkill -TERM -f '(^|/)(waybar|waybar-wrapped)( |$)' 2>/dev/null || true

# If anything is still alive after a tiny moment, kill harder.
sleep 0.05
pkill -KILL -f '(^|/)(waybar|waybar-wrapped)( |$)' 2>/dev/null || true

# Extra safety: wait until no waybar remains (but don't hang).
for _ in {1..20}; do
  pgrep -f '(^|/)(waybar|waybar-wrapped)( |$)' >/dev/null || break
  sleep 0.01
done

# Start a fresh one detached from this script (like "& disown")
nohup waybar >/dev/null 2>&1 &
disown || true
