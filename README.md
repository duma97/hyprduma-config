# HyprDuma

Personal Arch Linux desktop configuration: Hyprland Lua, Waypaper/Pywal colors,
optional Caelestia shell, Kitty, Fastfetch, and the Neovim setup imported from my Mac.

- [Installation and recovery](docs/README.md)
- [Verified package names and sources](docs/PACKAGES.md)
- [Desktop shortcuts](docs/KEYBINDS.md)
- [Wallpaper and theme setup](docs/PYWAL-SETUP.md)
- [Neovim features, shortcuts, and dependencies](config/nvim/README.md)
- [Development checks](docs/TESTING.md)

Install on Arch Linux with Python 3; Hyprland 0.55+ is required. The optional
Neovim configuration requires Neovim 0.12+ and tree-sitter-cli 0.26.1+.

```bash
git clone https://github.com/duma799/hyprduma-config.git ~/hyprduma-config
python3 ~/hyprduma-config/install.py
```

The installer checks dependencies and theme generation before activating the
configuration. Existing destinations and replaced checkouts receive numbered
backups. Configuration directories are symlinked to this checkout, so keep it in
place and edit the installed files or repository files interchangeably.
