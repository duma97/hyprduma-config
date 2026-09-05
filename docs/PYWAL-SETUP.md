# Wallpaper and Pywal integration

The installer performs this setup. Use this guide to understand the workflow or
add the integration to an existing Hyprland installation. Commands below run on
Arch Linux from the root of this repository.

## Standalone setup

Install `swaybg` and `kitty` from the official repositories, and `waypaper` and
`python-pywal` from the AUR using your preferred helper. Python 3 is required.
Caelestia, wal-gtk, and pywalfox are optional integrations.

Back up the affected configuration before copying:

```bash
hypr_config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
hypr_setup_backup="$(mktemp -d "$HOME/hyprduma-pywal-backup.XXXXXX")"
for item in wal kitty waypaper; do
    if [ -e "$hypr_config_root/$item" ]; then
        cp -aL "$hypr_config_root/$item" "$hypr_setup_backup/$item"
    fi
done
if [ -e "$hypr_config_root/hypr/scripts" ]; then
    cp -aL "$hypr_config_root/hypr/scripts" "$hypr_setup_backup/scripts"
fi
mkdir -p "$hypr_config_root/wal/templates" "$hypr_config_root/hypr/scripts" \
    "$hypr_config_root/kitty" "$hypr_config_root/waypaper"
cp config/wal/templates/* "$hypr_config_root/wal/templates/"
cp scripts/*.py scripts/*.sh "$hypr_config_root/hypr/scripts/"
chmod +x "$hypr_config_root/hypr/scripts/"*.sh
cp config/kitty/kitty.conf "$hypr_config_root/kitty/kitty.conf"
```

Set these entries under `[Settings]` in `waypaper/config.ini`, preserving any
other settings. The default path below assumes `XDG_CONFIG_HOME` is unset; use
your actual hook path if it differs. Quote the executable path if it has spaces.

```ini
[Settings]
backend = swaybg
post_command = ~/.config/hypr/scripts/waypaper-hook.sh $wallpaper
```

Keep `$wallpaper` **unquoted in this INI value**: Waypaper substitutes and escapes
it. In an ordinary shell command, quote the image path as usual.

Generate the initial wallpaper and palette:

```bash
"$hypr_config_root/hypr/scripts/pywal.sh" "$PWD/wallpapers/sakura.jpg" dark
```

For an independently maintained Hyprland config, load the generated colors and
start the session handler:

```lua
local home = os.getenv("HOME")
local cache = os.getenv("XDG_CACHE_HOME") or home .. "/.cache"
local colors = cache .. "/wal/hyprland-colors.lua"
local file = io.open(colors, "r")
if file then
    file:close()
    local ok, err = pcall(dofile, colors)
    if not ok then print(tostring(err)) end
end
hl.on("hyprland.start", function()
    hl.exec_cmd('python3 "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/monitor-handler.py"')
end)
```

The repository's `hyprland.lua` already contains this integration; do not add a
second startup handler to it. Restart your Hyprland session after initial setup.

Add this to your Bash or Zsh configuration if the installer has not already added
a managed Bash block:

```bash
[ -f "${XDG_CACHE_HOME:-$HOME/.cache}/wal/sequences" ] && cat "${XDG_CACHE_HOME:-$HOME/.cache}/wal/sequences"
source "${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors-tty.sh" 2>/dev/null
pywal() { "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/pywal.sh" "$@"; }
```

## Usage

```bash
# A new wallpaper on all monitors; retain the last selected light/dark mode.
pywal "$HOME/Pictures/my wallpaper.jpg"

# Choose an explicit mode.
pywal "$HOME/Pictures/my wallpaper.jpg" light
pywal "" dark

# Refresh the saved image and mode without changing monitor assignments.
pywal
```

Waypaper can keep a different wallpaper on each monitor. The image passed by the
latest hook controls the shared palette and Caelestia wallpaper reference. Mode
changes persist across subsequent GUI selections. First use defaults to dark.

For palette generation without desktop commands, use:

```bash
python3 scripts/theme.py --generate-only /path/to/image.jpg light
```

This publishes cache and theme state, but does not change Waypaper settings,
reload Hyprland, signal Kitty, or invoke optional desktop integrations. It is the
mode used by the installer. It is not a read-only check; `--preflight` checks the
required executable and template files without generation or writes.

## What gets updated

| Component | Behavior |
| --- | --- |
| Hyprland | Generated border colors, then one reload |
| Caelestia | Watched wallpaper and scheme files; no restart |
| Kitty | Pywal color include and SIGUSR1 reload for the current user |
| Bash/Zsh | Generated sequences read when a shell opens |
| GTK | Color-scheme preference on an active session; wal-gtk if installed |
| Firefox | pywalfox update if installed and configured |
| Neovim | Only when its optional Pywal colorscheme is selected |

The coordinator generates in a temporary cache, validates required exports, and
publishes complete files using atomic replacement. A failed generation leaves
the previously published palette in place. A desktop integration failure is
reported separately after publication. Concurrent requests wait for the latest
selection to finish; an older generated palette is discarded if it was superseded.

Use the wrapper for theme changes instead of a bare `wal` call, which bypasses
serialization, saved mode, and Caelestia publication.

## Customization and state

Edit `config/wal/templates/hyprland-colors.lua` for border colors and
`config/wal/templates/caelestia-scheme.json` for the shell palette. When installed
with symlinks, the corresponding files under `wal/templates` are the same files.
Pywal template braces are doubled (`{{` and `}}`); placeholders such as
`{color4.strip}` remain single. The coordinator writes the scheme's `mode` field
from the requested light/dark mode. Refresh with `pywal` after changing templates.

Default generated locations:

- `~/.cache/wal/`: palette exports and `hyprland-colors.lua`.
- `~/.local/state/hyprduma/theme.json`: saved image and mode.
- `~/.local/state/caelestia/scheme.json`: published shell palette.
- `~/.local/state/caelestia/wallpaper/`: current image link and `path.txt`.
- `$XDG_RUNTIME_DIR/hyprduma/`: queue and locks, falling back to the cache root.

Cache, config, and state paths honor the corresponding XDG environment variables.

## Troubleshooting

Run `pywal` in a terminal and read its error output. There is no shared `/tmp`
log file and no PID file to delete. Locks are released by the operating system
when a worker exits. Do not delete lock files while another update is running.

If a saved image was moved, provide its new path. If the saved theme JSON itself
was manually damaged, move it aside before selecting a new image:

```bash
mv "${XDG_STATE_HOME:-$HOME/.local/state}/hyprduma/theme.json" \
   "${XDG_STATE_HOME:-$HOME/.local/state}/hyprduma/theme.json.invalid"
```

For wallpaper recovery without generating another theme:

```bash
waypaper --restore --no-post-command
```

For Caelestia, check the actual Quickshell instance:

```bash
qs -c caelestia ipc show
qs -c caelestia -n -d
```

If necessary, stop it with `qs -c caelestia kill`, then start it again. Avoid
killing the `caelestia` CLI process: it is not the running shell.

Kitty includes `colors-kitty.conf`; check that this file exists under your Pywal
cache. Reload with `pkill -USR1 -u "$(id -u)" -x kitty`. Hyprland configuration
errors are available through `hyprctl configerrors`.
