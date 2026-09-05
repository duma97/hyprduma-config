# Validation

## Experimental branch and release gate

The current changes are being prepared on `codex/experimental`. The existing
stable branch is named `master`; this repository does not currently have a
`main` branch. Keep the experimental changes off the stable branch until the
Arch desktop verification below is complete.

Current status: local automated checks passed; a real Arch installation and
desktop session are **not yet verified**. Record the tested commit, package
versions, hardware, failures and retest results before merging. In particular,
verify a fresh install, an install over existing configuration, a repeated
install, and the documented backup recovery procedure.

After the experimental branch is pushed, the test machine can obtain it with:

```sh
git clone --branch codex/experimental https://github.com/duma799/hyprduma-config.git
cd hyprduma-config
```

Run the automated checks first, then follow the installer and desktop checks
below. Merge into the stable branch only after resolving any failures.

## Local automated checks

From the repository root, with Python 3 and Neovim 0.12+ installed:

```sh
python3 tests/run_checks.py
```

This runs installer, theme and monitor-handler regression tests; checks the shell
wrappers; and loads all Neovim Lua files plus the Hyprland configuration in test
harnesses. HOME and XDG directories point to a temporary directory. Desktop
commands, package managers and plugin downloads are mocked or excluded.

The tests cover failed package installs before config replacement, backup and
symlink recovery, optional packages, Waypaper state, incomplete palette exports,
light/dark mode, concurrent wallpaper changes, monitor recovery without recursive
hooks, socket framing and shutdown, window shortcuts, damaged color caches,
literal filenames, Neovim terminal-buffer safety, parser fallback and theme state.

These checks do not start Hyprland or test real Wayland rendering. A stubbed Lua
API cannot verify the compositor's acceptance of every option. Neovim's focused
tests do not install plugins or language servers.

The imported lockfile was also checked with all 55 plugins loaded in an isolated
Neovim instance, with downloads and language-server startup disabled. The locked
`nvim-colorizer.lua` plugin emits a `vim.tbl_flatten` deprecation warning on
Neovim 0.12; it still loads successfully. This comes from the imported upstream
plugin, whose commit is retained in the lockfile.

Pywal 3.3.0's real argument parser and exporter were exercised for dark and light
palettes using fixed input colors. This verified the generated Lua/JSON and the
legacy `~/.config/wal` template lookup; image color extraction itself still needs
the Arch backend. Generation isolates both HOME and XDG paths so released and
newer Pywal versions read the staged templates.

## Arch desktop verification

Run these after installing on the intended Arch machine:

1. Inspect monitor names with `hyprctl monitors` and adjust `hyprland.lua` if needed.
2. Restart the Hyprland session to load the updated monitor handler. Check
   `hyprctl configerrors`; confirm the desktop, wallpaper and optional Caelestia
   shell start once.
3. Change wallpaper in Waypaper, including a filename with spaces. Try two rapid
   selections and verify the last palette wins. With multiple monitors, confirm
   their individual backgrounds remain selected.
4. Run `pywal '' light` and `pywal '' dark`; confirm Kitty, Hyprland borders and
   the optional shell change together. Use the installed script directly if the
   shell function has not been loaded.
5. Reload Hyprland several times and reconnect a monitor. Confirm there is no
   repeating Waypaper/Pywal process chain or duplicated shell.
6. Test `SUPER+L`, the optional `SUPER+N` sidebar, workspace moves, pseudo tiling
   and `CTRL+H/L` inside Neovim.
7. Open Neovim and let Lazy, Mason and Tree-sitter finish their initial downloads.
   Check `:Lazy`, `:Mason`, and `:checkhealth`. Open a source file, test completion,
   syntax highlighting, directory selection and a runner/debugger you use.

Installer execution is intentionally separate from automated checks because it
installs packages and replaces the selected user's configuration.

## Arch terminal investigation — 2026-09-05

Inspected experimental baseline `b21eaae` against the actual installation in
`/home/duma/hyprduma-config`, which was still on **master at `1f9568f`**.
An isolated `codex/experimental` worktree was used because live configuration
symlinks point into the master checkout; switching it would immediately change
active files and leave the old Hyprland config link dangling.

Observed on this machine:

- Bash reads `.bashrc` from `.bash_profile`. XDG config/cache/data overrides and
  `KITTY_CONFIG_DIRECTORY` were unset. The legacy Bash block unconditionally
  reads `~/.cache/wal/sequences`; the entire `~/.cache/wal` directory was absent.
- `wal`, `python-pywal`, and `ttf-jetbrains-mono-nerd` were missing. Fontconfig
  matched the requested Nerd Font to Nimbus Mono PS instead.
- Kitty 0.48.2 reads `~/.config/kitty/kitty.conf` through a valid symlink into
  master. Its parser accepts size 13 and opacity 0.8, with `JetBrains Mono` as
  the font request, and reports the missing color include. This confirms config
  discovery, but does not establish what an already-running window displays.
- Package logs show the old installer's combined official/AUR package request
  at 14:35, with no successful corresponding transaction. Subsequent Caelestia
  transactions completed. Config links and shell edits were created around
  14:57–14:58. The exact installer exit status was not retained; required
  installation is incomplete regardless of any completion banner.
- Existing Kitty backup directory is empty. The personal Hyprland Lua file and
  legacy Hyprland link both exist; neither was replaced during this repair.

Applied the experimental Bash migration with the original preserved as
`~/.bashrc.backup`. Added alias removal before defining the replacement function,
so sourcing the new block in an existing shell also works. A fresh interactive
Bash loads the function without a missing-wal error. All **65 regression tests**,
shell syntax checks, and Neovim/Hyprland harnesses pass on Arch.

Package installation requires a local sudo password; the attempted font install
was cancelled at that prompt. No font package or real palette was installed by
this investigation. To complete installation, run `python3 install.py` from the
experimental worktree in a local terminal, accepting the required dependencies.
It checks packages and generates the palette before activating config links,
and preserves existing destinations and numbered backups. Keep that worktree
at a permanent path before installation, since installed symlinks depend on it.
Then verify `fc-match 'JetBrainsMono Nerd Font'`, the generated files under
`${XDG_CACHE_HOME:-$HOME/.cache}/wal`, and a newly opened Kitty window. The desktop
release gate above remains open.
