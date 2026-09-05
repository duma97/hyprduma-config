#!/bin/sh
# Usage: pywal.sh [wallpaper_path] [light|dark]
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
exec python3 "$SCRIPT_DIR/theme.py" "$@"
