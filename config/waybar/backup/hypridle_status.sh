#!/run/current-system/sw/bin/bash

HYPRIDLE_CMD="/run/current-system/sw/bin/hypridle"

if pgrep -x "$(basename "$HYPRIDLE_CMD")" > /dev/null; then
    # Running -> show the enabled icon
    echo '  '
else
    # Not running -> show the disabled icon
    echo '  '
fi
