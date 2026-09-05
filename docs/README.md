# HyprDuma installation

This is an Arch Linux desktop configuration. Hyprland uses Lua and requires
version 0.55 or newer. The optional Neovim setup requires Neovim 0.12 or newer
and tree-sitter-cli 0.26.1 or newer.

The defaults target eDP-1 at 1920×1080/60 Hz and DP-1 at 1920×1080/144 Hz with
a 180-degree transform. Workspaces 1–4 use DP-1 and 5–10 use eDP-1. Adjust these
settings in `hyprland.lua` for your hardware.

## Install

Run as your normal user on Arch, with sudo available:

```bash
git clone https://github.com/duma799/hyprduma-config.git ~/hyprduma-config
python3 ~/hyprduma-config/install.py
```

The installer asks whether to include Neovim and Fastfetch, installs required
packages, validates the repository and runtime versions, generates the initial
theme, offers Caelestia, and activates the configuration. It installs supporting
files before linking the main Hyprland configuration. It does not launch or
explicitly reload the desktop. Hyprland itself can detect changes to its config
when installation takes place inside a running session.

If dependencies are already provisioned, decline the package-installation prompt.
The same prerequisite checks still run. Missing commands, unsupported versions,
failed package transactions, and failed palette generation stop activation.

The package lists in [`install.py`](../install.py) are the source of truth:

- Official packages are installed with pacman, including Hyprland, Kitty, swaybg,
  the launcher, screenshot/audio utilities, htop, and a Nerd Font.
- `wlogout`, `waypaper`, and `python-pywal` are installed from the AUR.
- The installer reuses yay or paru. If neither is present, it offers to build
  only yay in a fresh temporary directory.
- Neovim dependencies are installed only when its config is selected. These
  include ripgrep, fd, lazygit, parser build tools, Node.js/npm, the Wayland
  clipboard tools, and Python debugpy.

The installer is not a macOS installer. The bundled Neovim configuration was
imported from a Mac, but the desktop and package setup target Arch Linux.

## Optional applications

Caelestia provides the panel, notification center, and its own lock screen. Its
availability is checked separately from a launcher executable. Skipping it is
supported: the wallpaper and desktop shortcuts still work, `Super+L` falls back
to the bundled Hyprlock screen, and `Super+N` has no notification center to open.
Do not start a second notification daemon alongside Caelestia.

The application variables at the top of `hyprland.lua` default to Kitty,
Nautilus, Telegram, Spotify, VS Code, and the Zen Flatpak. Telegram, Spotify,
VS Code, Flatpak, and Zen are personal choices and are not installed automatically.
Install your choices or change the variables before using their shortcuts.

Neovim keeps the Mac configuration's Ultraviolet default, custom colorschemes,
transparency/bold options, plugin lockfile, and navigation. Pywal is a selectable
Neovim colorscheme rather than an automatic replacement for your chosen theme.
Language runtimes, formatters, linters, and the authenticated Claude CLI remain
optional; see the [Neovim guide](../config/nvim/README.md).

## Files and backups

Configuration destinations normally live under `~/.config`; the installer and
desktop scripts also honor `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, and `XDG_STATE_HOME`.

| Repository source | Installed destination |
| --- | --- |
| `hyprland.lua` | `hypr/hyprland.lua` |
| `config/hyprlock/hyprlock.conf` | `hypr/hyprlock.conf` |
| `scripts/` | `hypr/scripts/` |
| `config/wal/templates/` | `wal/templates/` |
| `config/kitty/` | `kitty/` |
| `config/fastfetch/` | `fastfetch/`, when selected |
| `config/nvim/` | `nvim/`, when selected |
| `wallpapers/` | `~/wallpapers` |

Existing destinations are preserved as `.backup`, `.backup.1`, and so on. A
correct existing symlink is retained without another backup. Waypaper settings
and the managed Bash block are written with backups when their content changes.
Custom Bash integration that does not match the known previous block is preserved
and reported for manual adjustment.

A previous checkout is never deleted to make room for a clone. A replacement is
cloned and validated first, then the old directory is moved to a numbered backup.
A failed clone leaves the original checkout in place. When running an outdated
local installer/check-out directly, update it deliberately; it is not silently
reset or pulled over personal changes.

To restore a configuration, inspect its numbered backups, move the current
installed destination aside, and restore the chosen backup to its original name.
Retain checkout backups while inspecting old symlinks: their original contents
may live inside the preserved checkout. The installer does not undo package
installations when a later step fails.

## Wallpaper and colors

The initial wallpaper defaults to `wallpapers/sakura.jpg` only when no valid
Waypaper wallpaper is saved. New Waypaper settings explicitly select swaybg;
an existing backend and per-monitor choices are preserved.

- `Super+W`: select a wallpaper in Waypaper. The most recently changed monitor
  supplies the shared color palette.
- `pywal /path/to/image.jpg`: apply a wallpaper to all monitors and generate its
  colors. A TTY invocation saves the wallpaper for the next desktop login.
- `pywal "" light` or `pywal "" dark`: keep the selected wallpaper and change mode.
- `pywal`: refresh the saved image and mode.

The Bash function is available after opening a new shell. For Zsh, add the
function shown in the [Pywal guide](PYWAL-SETUP.md).

One coordinator handles generation, validation, serialized updates, and atomic
publication of watched files. Palette changes do not restart Caelestia. One
session handler restores Waypaper and starts the optional shell. Recovery uses
`waypaper --restore --no-post-command`, which cannot invoke the theme hook again.

## Start and inspect

From a TTY:

```bash
start-hyprland
```

After installing inside an existing session, restart the session to load the new
startup handler. A plain config reload does not execute `hyprland.start` callbacks.
For ordinary config edits, use `hyprctl reload` and inspect `hyprctl configerrors`.

Useful diagnostics inside Hyprland:

```bash
hyprctl configerrors
hyprctl monitors
waypaper --restore --no-post-command
qs -c caelestia ipc show
```

Theme errors are printed to stderr and return a nonzero status. Run the wrapper
in a terminal to see them:

```bash
"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/pywal.sh"
```

For a missing session handler, start it in a terminal to see its errors:

```bash
python3 "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/monitor-handler.py"
```

The handler has a per-session lock, so a second invocation exits without starting
a second listener. It exits when that compositor's event socket closes.

See [desktop shortcuts](KEYBINDS.md), [theme troubleshooting](PYWAL-SETUP.md),
and [development checks](TESTING.md). Static and isolated tests on macOS do not
replace a live Arch installation and Hyprland session test.
