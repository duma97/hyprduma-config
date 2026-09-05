# Installer package audit

Verified on 2026-09-05 against the live Arch package search API and AUR RPC API.
All 30 official package targets and all 6 AUR/helper names exist. No installer
package-name or repository-source changes were needed.

This is a dated snapshot, not a version pin. The installer installs the versions
available through the target machine's configured repositories. It does not need
the Arch testing repositories for the versions checked here.

## Official repositories

| Package | Repository | Version checked |
| --- | --- | --- |
| [`git`](https://archlinux.org/packages/extra/x86_64/git/) | extra | 2.55.0-1 |
| [`hyprland`](https://archlinux.org/packages/extra/x86_64/hyprland/) | extra | 0.56.2-2 |
| [`hyprlock`](https://archlinux.org/packages/extra/x86_64/hyprlock/) | extra | 0.9.6-3 |
| [`hyprshot`](https://archlinux.org/packages/extra/any/hyprshot/) | extra | 1.3.0-4 |
| [`kitty`](https://archlinux.org/packages/extra/x86_64/kitty/) | extra | 0.48.2-1 |
| [`swaybg`](https://archlinux.org/packages/extra/x86_64/swaybg/) | extra | 1.2.2-1 |
| [`wofi`](https://archlinux.org/packages/extra/x86_64/wofi/) | extra | 1.5.3-1 |
| [`nautilus`](https://archlinux.org/packages/extra/x86_64/nautilus/) | extra | 50.3-1 |
| [`wireplumber`](https://archlinux.org/packages/extra/x86_64/wireplumber/) | extra | 0.5.17-1 |
| [`pipewire-pulse`](https://archlinux.org/packages/extra/x86_64/pipewire-pulse/) | extra | 1.6.8-1 |
| [`brightnessctl`](https://archlinux.org/packages/extra/x86_64/brightnessctl/) | extra | 0.5.1-3 |
| [`playerctl`](https://archlinux.org/packages/extra/x86_64/playerctl/) | extra | 2.4.1-5 |
| [`adwaita-cursors`](https://archlinux.org/packages/extra/any/adwaita-cursors/) | extra | 50.0-1 |
| [`ttf-jetbrains-mono-nerd`](https://archlinux.org/packages/extra/any/ttf-jetbrains-mono-nerd/) | extra | 3.5.1-2 |
| [`htop`](https://archlinux.org/packages/extra/x86_64/htop/) | extra | 3.5.3-1 |
| [`neovim`](https://archlinux.org/packages/extra/x86_64/neovim/) | extra | 0.12.5-1 |
| [`ripgrep`](https://archlinux.org/packages/extra/x86_64/ripgrep/) | extra | 15.2.0-1 |
| [`fd`](https://archlinux.org/packages/extra/x86_64/fd/) | extra | 10.5.0-3 |
| [`lazygit`](https://archlinux.org/packages/extra/x86_64/lazygit/) | extra | 0.64.1-1 |
| [`tree-sitter-cli`](https://archlinux.org/packages/extra/x86_64/tree-sitter-cli/) | extra | 0.26.9-1 |
| [`base-devel`](https://archlinux.org/packages/core/any/base-devel/) | core | 1-2 |
| [`nodejs`](https://archlinux.org/packages/extra/x86_64/nodejs/) | extra | 26.8.1-2 |
| [`npm`](https://archlinux.org/packages/extra/any/npm/) | extra | 12.0.2-1 |
| [`unzip`](https://archlinux.org/packages/extra/x86_64/unzip/) | extra | 6.0-23 |
| [`curl`](https://archlinux.org/packages/core/x86_64/curl/) | core | 8.22.0-1 |
| [`tar`](https://archlinux.org/packages/core/x86_64/tar/) | core | 1.35-5 |
| [`gzip`](https://archlinux.org/packages/core/x86_64/gzip/) | core | 1.14-2 |
| [`wl-clipboard`](https://archlinux.org/packages/extra/x86_64/wl-clipboard/) | extra | 2.3.0-1 |
| [`python-debugpy`](https://archlinux.org/packages/extra/x86_64/python-debugpy/) | extra | 1.8.21-1 |
| [`fastfetch`](https://archlinux.org/packages/extra/x86_64/fastfetch/) | extra | 2.68.1-1 |

## AUR

| Package | Role | Version checked |
| --- | --- | --- |
| [`wlogout`](https://aur.archlinux.org/packages/wlogout) | Required logout menu | 1.2.2-0 |
| [`waypaper`](https://aur.archlinux.org/packages/waypaper) | Required wallpaper GUI | 2.8-1 |
| [`python-pywal`](https://aur.archlinux.org/packages/python-pywal) | Required palette generator | 3.3.0-11 |
| [`caelestia-shell`](https://aur.archlinux.org/packages/caelestia-shell) | Optional desktop shell | 2.4.0-1 |
| [`yay`](https://aur.archlinux.org/packages/yay) | Helper built only if neither helper is available | 13.0.1-1 |
| [`paru`](https://aur.archlinux.org/packages/paru) | Existing helper reused when available | 2.1.0-2 |

`python-pywal` is now in the AUR. Cached official-package pages can still show it
in Extra; the live official search returned no match, while the AUR RPC returned
the package. The same official-repository absence was checked for `wlogout`,
`waypaper`, and `caelestia-shell`.

The checked Hyprland, Neovim, and tree-sitter-cli versions satisfy the installer's
minimum-version checks. Package names and executable names differ in several
places: `neovim` supplies `nvim`, `ripgrep` supplies `rg`, `tree-sitter-cli` supplies
`tree-sitter`, and `python-pywal` supplies `wal`.

## Verification method

Official packages were queried with
`https://archlinux.org/packages/search/json/?name=PACKAGE` and matched by exact
package name in Core or Extra for x86_64/any. AUR entries were queried through
`https://aur.archlinux.org/rpc/v5/info?arg[]=PACKAGE` and matched by exact name.
Bootstrap targets (`git`, `base-devel`) and the optional Fastfetch/Caelestia targets
were included.

This check verifies names, sources, and available versions. It does not execute
pacman, build AUR packages, or validate the target machine's mirror/database state.
