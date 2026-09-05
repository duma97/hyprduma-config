#!/bin/sh
# Compatibility entry point: use saved theme state, never scrape process args.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
exec python3 "$SCRIPT_DIR/theme.py" --sync-wallpaper-only "$@"
