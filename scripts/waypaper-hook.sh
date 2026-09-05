#!/bin/sh
# Waypaper substitutes and escapes $wallpaper itself in post_command.
# post_command = /path/to/waypaper-hook.sh $wallpaper
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
exec python3 "$SCRIPT_DIR/theme.py" --hook "$@"
