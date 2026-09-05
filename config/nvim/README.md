# neoduma-config

My Neovim configuration built with [lazy.nvim](https://github.com/folke/lazy.nvim).

![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-green?logo=neovim&logoColor=white)

## Features

- **Lazy-loaded plugins** for fast startup
- **Transparent background** with terminal blur support (WezTerm/Ghostty)
- **Theme sync** across Neovim, WezTerm, and Ghostty with `Space c` keymaps
- **LSP** with Mason for auto-installing language servers (Lua, Python, TypeScript/JavaScript, HTML, CSS, Tailwind, JSON, Bash)
- **Autocompletion** via nvim-cmp with snippets, buffer, path, and cmdline sources
- **Fuzzy finding** with Telescope (files, grep, directory scoping)
- **Code runner** built-in keymaps + code_runner.nvim for Python, JS, Lua, Rust, Go, C/C++, and more
- **Debugging** with DAP (Python)
- **Formatting** on save via conform.nvim (stylua, black, prettier, shfmt, rustfmt, gofmt)
- **Linting** via nvim-lint (ruff, eslint_d, luacheck, shellcheck) — only runs if the binary is installed
- **Git integration** with gitsigns, lazygit, and git blame (via snacks.nvim)
- **Cursor animations** with mini.animate and beacon.nvim
- **Neovide** support with particle effects, smooth scrolling, and transparency
- **Custom colorschemes** including a handmade grayscale theme and pywal support

## Colorschemes

Switch themes with keymaps that sync your terminal background:

| Keymap | Theme |
|---|---|
| `Space cu` | Ultraviolet (default) |
| `Space cg` | Gruvbox (hard contrast) |
| `Space ct` | Tokyo Night |
| `Space cn` | Nightfox |
| `Space cf` | Token |
| `Space cb` | Toggle transparency |

Also includes `unyielding-grayscale` and `pywal` as custom colorschemes in `colors/`.

## Keymaps

Leader key is `Space`. Press it and wait to see all groups via which-key.

**Navigation**
| Keymap | Action |
|---|---|
| `<C-h/j/k/l>` | Move between windows |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<C-p>` | Find files |
| `<Alt-f>` | Live grep |
| `<Alt-d>` | Search and scope into directory |
| `<C-n>` | Toggle Neo-tree file explorer |

**Editing**
| Keymap | Action |
|---|---|
| `<C-d>` / `<C-u>` | Scroll down/up (centered) |
| `v` then `J`/`K` | Move selected lines down/up |
| `v` then `<`/`>` | Indent and keep selection |
| `Space p` | Paste without yanking replaced text |
| `Space d` | Delete to void register |

**Code**
| Keymap | Action |
|---|---|
| `Space rr` | Run current file |
| `Space rs` | Run selection (visual) |
| `Space rl` | Run current line |
| `Space rc` | Run via code_runner |
| `Space rp` | Open Python REPL |
| `Space fm` | Format buffer |
| `Space ll` | Trigger linting |

**LSP**
| Keymap | Action |
|---|---|
| `K` | Hover docs |
| `gd` / `gD` | Go to definition / declaration |
| `gi` / `gr` | Go to implementation / references |
| `Space ca` | Code action |
| `Space rn` | Rename |
| `[d` / `]d` | Previous / next diagnostic |

**Debug (DAP)**
| Keymap | Action |
|---|---|
| `Space db` | Toggle breakpoint |
| `Space dc` | Continue |
| `Space di` / `Space do` | Step into / over |
| `Space dt` | Toggle debug UI |
| `Space dx` | Terminate |

**Git**
| Keymap | Action |
|---|---|
| `Space gg` | Lazygit |
| `Space gb` | Git blame line |
| `Space gf` | File history (lazygit) |
| `Space gB` | Git browse (open in browser) |

**Other**
| Keymap | Action |
|---|---|
| `Space z` | Zen mode |
| `Space s` | Scratch buffer |
| `Space w` | Save |
| `Space q` | Quit |
| `Space tc` | Close terminal buffers, preserving edited files |
| `Space hP` / `Space hn` | Previous / next Harpoon file |
| `Space hp` | Preview Git hunk |
| `<C-/>` | Toggle terminal |
| `<Esc>` (terminal) | Exit terminal mode |

## Plugin List

| Plugin | Purpose |
|---|---|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [alpha-nvim](https://github.com/goolord/alpha-nvim) | Dashboard |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippets |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP installer |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP configuration |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatting |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Linting |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debugging |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in gutter |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Lazygit, zen mode, terminal, scratch buffers |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [tabline.nvim](https://github.com/kdheepak/tabline.nvim) | Buffer tabs |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap hints |
| [mini.animate](https://github.com/echasnovski/mini.animate) | Cursor animations |
| [beacon.nvim](https://github.com/rainbowhxch/beacon.nvim) | Cursor flash on jump |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Surround motions |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets |
| [code_runner.nvim](https://github.com/CRAG666/code_runner.nvim) | Code runner |
| [markview.nvim](https://github.com/OXY2DEV/markview.nvim) | Markdown preview |
| [claudecode.nvim](https://github.com/coder/claudecode.nvim) | Claude Code integration |
| [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim) | Gruvbox theme |
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Tokyo Night theme |
| [nightfox.nvim](https://github.com/EdenEast/nightfox.nvim) | Nightfox theme |
| ultraviolet / token | Custom colorschemes (vendored in `colors/`) |

## Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── vim-options.lua   # Core editor settings
│   ├── keymaps.lua       # All keybindings + theme sync
│   ├── custom-colors.lua # Transparency and highlight overrides
│   ├── token/            # Token colorscheme (vendored)
│   └── plugins/          # One file per plugin (lazy.nvim spec)
└── colors/               # Custom colorschemes
    ├── ultraviolet.lua
    ├── token.lua
    ├── unyielding-grayscale.lua
    └── pywal.lua
```

## Terminal Sync

Theme switching saves the active theme in Neovim's state directory, so it persists without a terminal-specific config. It also writes the active theme to `~/.config/wezterm/current_theme.txt` and updates the background color in `~/.config/ghostty/config`. This keeps your terminal and editor in sync. Existing WezTerm/Ghostty configs are updated when present. Paths respect `XDG_CONFIG_HOME`.

## Requirements

- Neovim >= 0.12
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for Telescope grep)
- [fd](https://github.com/sharkdp/fd) (for directory search)
- `git`, a C compiler, `make`, `curl`, `tar`, `unzip`, and `gzip` for plugin/parser/server installation
- `tree-sitter-cli` >= 0.26.1 (from the system package manager, not npm)
- Node.js and npm for Mason language servers
- `wl-clipboard` on Wayland for the system clipboard
- A [Nerd Font](https://www.nerdfonts.com/) (icons everywhere)
- Optional: [lazygit](https://github.com/jesseduffield/lazygit), [WezTerm](https://wezfurlong.org/wezterm/) or [Ghostty](https://ghostty.org/), [Neovide](https://neovide.dev/)

## Install

This directory was imported from the Mac configuration in `~/.config/nvim`.
Run `python3 install.py` from the Hyprduma repository and enable Neovim installation.
The original Mac configuration is unchanged.

On first launch, lazy.nvim installs the locked plugins and builds the configured
Tree-sitter parsers. Mason installs the listed language servers. Both steps need
network access; use `:Lazy`, `:Mason`, and `:checkhealth` to inspect their status.
Run `:Lazy build nvim-treesitter` if parser installation was interrupted.

Formatting, linting, debugging, and code execution require the corresponding tools:

- Python: `python3`, `debugpy` (Arch: `python-debugpy`), `black`, `ruff`.
- Web: Node.js, `prettier`, and optional `eslint_d`; TypeScript execution also needs `ts-node`.
- Lua/shell: `lua`, `stylua`, `luacheck`, `bash`, `shfmt`, `shellcheck`.
- Other runners: a C/C++ compiler, Go, Java JDK, or Rust/Cargo for that language.
- Claude integration: the separately installed and authenticated `claude` CLI.

The installer supplies core editor dependencies and Python debugging. Language-specific
formatters, linters, runtimes, and Claude are optional; install the ones you use.
`Space rr` safely runs a saved file, including names with spaces. `Space rc` uses
the configured language runner; the Rust runner expects a Cargo project.

The repo copy retains the Mac themes, plugins, lockfile, transparency/bold settings,
and keymaps, with fixes for fresh parser installation, dependency ordering, empty
directory selections, terminal buffer cleanup, filename handling, duplicate Noice
configuration, and theme persistence. `Space hP` avoids the existing `Space hp`
Git-hunk binding. Pywal uses `XDG_CACHE_HOME` and detects rapid palette changes.
