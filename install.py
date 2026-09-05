#!/usr/bin/env python3
"""Install the Arch desktop config after dependencies and theme generation succeed."""

import configparser
import importlib.util
import io
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# Colors
RESET = "\033[0m"
BOLD = "\033[1m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"

REPO_URL = "https://github.com/duma799/hyprduma-config.git"

PACMAN_PACKAGES = [
    "git", "hyprland", "hyprlock", "hyprshot", "kitty", "swaybg",
    "wofi", "nautilus", "wireplumber", "pipewire-pulse", "brightnessctl",
    "playerctl", "adwaita-cursors", "ttf-jetbrains-mono-nerd", "htop",
]
AUR_PACKAGES = ["wlogout", "waypaper", "python-pywal"]
NVIM_PACKAGES = [
    "neovim", "ripgrep", "fd", "lazygit", "tree-sitter-cli", "base-devel",
    "nodejs", "npm", "unzip", "curl", "tar", "gzip", "wl-clipboard", "python-debugpy",
]
REQUIRED_COMMANDS = [
    "git", "Hyprland", "hyprctl", "hyprlock", "hyprshot", "kitty",
    "swaybg", "wofi", "nautilus", "wpctl", "pactl", "brightnessctl", "playerctl",
    "htop", "wlogout", "waypaper", "wal", "bash", "python3", "pgrep",
]
NVIM_COMMANDS = [
    "nvim", "rg", "fd", "lazygit", "tree-sitter", "make", "cc", "node", "npm",
    "unzip", "curl", "tar", "gzip", "wl-copy", "wl-paste",
]
REQUIRED_FILES = [
    "hyprland.lua", "scripts/theme.py", "scripts/pywal.sh", "scripts/waypaper-hook.sh",
    "scripts/sync-caelestia-wallpaper.sh", "scripts/monitor-handler.py",
    "config/wal/templates/hyprland-colors.lua", "config/wal/templates/caelestia-scheme.json",
    "config/kitty/kitty.conf", "config/hyprlock/hyprlock.conf", "wallpapers/sakura.jpg",
]


class InstallError(RuntimeError):
    """A required step failed; do not activate the configuration."""


def config_home():
    return Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config")


def print_step(num, total, msg):
    print(f"\n{BOLD}{BLUE}[{num}/{total}]{RESET} {BOLD}{msg}{RESET}")


def print_ok(msg):
    print(f"  {GREEN}✓{RESET} {msg}")


def print_warn(msg):
    print(f"  {YELLOW}!{RESET} {msg}")


def print_err(msg):
    print(f"  {RED}✗{RESET} {msg}")


def print_info(msg):
    print(f"  {CYAN}→{RESET} {msg}")


def ask_yn(prompt, default=True):
    suffix = " [Y/n] " if default else " [y/N] "
    try:
        with open("/dev/tty") as tty:
            sys.stdout.write(f"  {MAGENTA}?{RESET} {prompt}{suffix}")
            sys.stdout.flush()
            answer = tty.readline()
    except OSError as exc:
        raise InstallError("An interactive terminal is required for installer choices") from exc
    if not answer:
        raise InstallError("No answer received from the terminal")
    answer = answer.strip().lower()
    return default if not answer else answer in ("y", "yes")


def run(cmd, capture=False, **kwargs):
    """Run an argument array without a shell; return output or success status."""
    try:
        result = subprocess.run(cmd, capture_output=capture, text=True, **kwargs)
    except OSError:
        return None if capture else False
    if capture:
        return result.stdout.strip() if result.returncode == 0 else None
    return result.returncode == 0


def require_run(cmd, message, **kwargs):
    if not run(cmd, **kwargs):
        raise InstallError(message)


def cmd_exists(name):
    return shutil.which(name) is not None


def unique_backup_path(path):
    backup = path.with_name(path.name + ".backup")
    suffix = 1
    while backup.exists() or backup.is_symlink():
        backup = path.with_name(f"{path.name}.backup.{suffix}")
        suffix += 1
    return backup


def preserve(path):
    backup = unique_backup_path(path)
    path.rename(backup)
    print_warn(f"Backed up {path} -> {backup}")
    return backup


def find_repo_dir():
    for candidate in (Path.cwd(), Path(__file__).resolve().parent):
        if (candidate / "scripts").is_dir() and any(
            (candidate / name).is_file() for name in ("hyprland.lua", "hyprland.conf")
        ):
            return candidate
    return None


def check_arch():
    if not Path("/etc/arch-release").exists() or not cmd_exists("pacman"):
        raise InstallError("This installer requires Arch Linux or an Arch-based distribution")
    if os.geteuid() == 0:
        raise InstallError("Run as your normal user, with sudo available for package installation")
    if not cmd_exists("sudo"):
        raise InstallError("sudo is required to install system packages")


def check_version(command, pattern, minimum, label):
    output = run(command, capture=True)
    match = re.search(pattern, output or "")
    if match is None:
        raise InstallError(f"Cannot read {label} version; install a supported version before continuing")
    version = tuple(int(part or 0) for part in match.groups())
    if version < minimum:
        required = ".".join(map(str, minimum))
        raise InstallError(f"{label} {required} or newer is required")


def check_lua_config_support():
    check_version(["Hyprland", "--version"], r"\bHyprland\s+v?(\d+)\.(\d+)(?:\.(\d+))?\b",
                  (0, 55, 0), "Hyprland")
    print_ok("Installed Hyprland supports Lua configuration")


def install_aur_helpers():
    """Choose one installed helper; bootstrap only yay when neither is available."""
    for helper in ("yay", "paru"):
        if cmd_exists(helper):
            print_ok(f"Using {helper} for AUR packages")
            return helper
    if not ask_yn("Build yay to install the required AUR packages?"):
        raise InstallError("Required AUR packages need yay or paru; install them manually and rerun")
    require_run(["sudo", "pacman", "-S", "--needed", "--noconfirm", "git", "base-devel"],
                "Could not install prerequisites for yay")
    with tempfile.TemporaryDirectory(prefix="hyprduma-yay-") as directory:
        source = Path(directory) / "yay"
        require_run(["git", "clone", "https://aur.archlinux.org/yay.git", str(source)],
                    "Could not clone yay")
        require_run(["makepkg", "-si", "--noconfirm"], "Could not build/install yay", cwd=source)
    if not cmd_exists("yay"):
        raise InstallError("yay build completed but yay is unavailable on PATH")
    return "yay"


def install_packages(include_nvim=True, include_fastfetch=True):
    packages = list(PACMAN_PACKAGES)
    if include_nvim:
        packages.extend(NVIM_PACKAGES)
    if include_fastfetch:
        packages.append("fastfetch")
    print_info(f"Official packages: {' '.join(packages)}")
    print_info(f"AUR packages: {' '.join(AUR_PACKAGES)}")
    if not ask_yn("Install required official and AUR packages?"):
        print_info("Package installation skipped; installed dependencies will still be checked")
        return False
    require_run(["sudo", "pacman", "-S", "--needed", "--noconfirm", *packages],
                "Required official package installation failed; configs were not replaced")
    helper = install_aur_helpers()
    require_run([helper, "-S", "--needed", "--noconfirm", *AUR_PACKAGES],
                "Required AUR package installation failed; configs were not replaced")
    print_ok("Required packages installed")
    return True


def caelestia_installed():
    # Match Quickshell's named-config lookup used by the monitor handler.
    if not cmd_exists("qs"):
        return False
    roots = [config_home()]
    roots.extend(Path(item) for item in os.environ.get("XDG_CONFIG_DIRS", "/etc/xdg").split(":") if item)
    return any((root / "quickshell/caelestia/shell.qml").is_file() for root in roots)


def install_caelestia():
    if caelestia_installed():
        print_ok("Quickshell runtime and Caelestia shell are installed")
        return True
    if not ask_yn("Install optional Caelestia Shell (panel, notifications, and dynamic theming)?"):
        print_warn("Caelestia skipped; its panel and notification center will be unavailable")
        return False
    try:
        helper = install_aur_helpers()
        require_run([helper, "-S", "--needed", "--noconfirm", "caelestia-shell"],
                    "Caelestia package installation failed")
        if not caelestia_installed():
            raise InstallError("Quickshell runtime or a discoverable Caelestia shell.qml is missing")
    except InstallError as exc:
        print_warn(f"Optional Caelestia unavailable: {exc}")
        return False
    print_ok("Caelestia installed; it will start with your next Hyprland session")
    return True


def validate_repo(repo, include_nvim=True, include_fastfetch=True):
    required = list(REQUIRED_FILES)
    if include_nvim:
        required.extend(["config/nvim/init.lua", "config/nvim/lazy-lock.json"])
    if include_fastfetch:
        required.extend(["config/fastfetch/config.jsonc", "config/fastfetch/ascii/arch.txt"])
    missing = [name for name in required if not (repo / name).is_file()]
    if missing:
        raise InstallError("Repository is incomplete: " + ", ".join(missing))
    for name in ("scripts/pywal.sh", "scripts/waypaper-hook.sh", "scripts/sync-caelestia-wallpaper.sh"):
        if not os.access(repo / name, os.X_OK):
            raise InstallError(f"Required script is not executable: {repo / name}")


def ensure_git():
    if cmd_exists("git"):
        return
    if not ask_yn("Git is required to clone the repository. Install git?"):
        raise InstallError("Cannot clone the repository without git")
    require_run(["sudo", "pacman", "-S", "--needed", "--noconfirm", "git"],
                "Git installation failed")
    if not cmd_exists("git"):
        raise InstallError("git is unavailable after installation")


def clone_repo():
    repo = find_repo_dir()
    if repo:
        print_ok(f"Using repo at: {repo}")
        return repo
    target = Path.home() / "hyprduma-config"
    try:
        validate_repo(target)
    except InstallError:
        pass
    else:
        print_ok(f"Using existing repository at {target}")
        return target
    ensure_git()
    # Keep any old checkout untouched until a complete replacement has been cloned.
    with tempfile.TemporaryDirectory(prefix=".hyprduma-clone-", dir=target.parent) as directory:
        staged = Path(directory) / "repo"
        require_run(["git", "clone", REPO_URL, str(staged)], "Repository clone failed; existing checkout is unchanged")
        validate_repo(staged)
        backup = preserve(target) if target.exists() or target.is_symlink() else None
        try:
            staged.rename(target)
        except OSError:
            if backup is not None:
                backup.rename(target)
            raise
    print_ok(f"Repository cloned to {target}")
    return target


def make_symlink(src, dst):
    """Create dst -> src, preserving every previous destination under a unique name."""
    if not src.exists():
        raise InstallError(f"Cannot link missing source: {src}")
    if dst.is_symlink() and dst.resolve() == src.resolve():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    backup = preserve(dst) if dst.exists() or dst.is_symlink() else None
    try:
        dst.symlink_to(src)
    except OSError:
        if backup is not None:
            backup.rename(dst)
        raise


def write_preserving(path, content):
    """Replace a text config atomically, retaining the original including symlinks."""
    if path.is_file() and path.read_text() == content:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, prefix=".hyprduma-", delete=False) as stream:
        temporary = Path(stream.name)
        stream.write(content)
    backup = None
    try:
        if path.exists() or path.is_symlink():
            backup = preserve(path)
        temporary.replace(path)
    except OSError:
        if backup is not None:
            backup.rename(path)
        raise
    finally:
        temporary.unlink(missing_ok=True)
    return True


def prepare_waypaper_config(repo):
    config = configparser.ConfigParser(interpolation=None)
    ini = config_home() / "waypaper" / "config.ini"
    if ini.exists():
        with ini.open() as stream:
            config.read_file(stream)
    if not config.has_section("Settings"):
        config.add_section("Settings")
    settings = config["Settings"]
    if not settings.get("backend"):
        settings["backend"] = "swaybg"
    if not settings.get("folder"):
        settings["folder"] = str(repo / "wallpapers")
    # Use the coordinator's wallpaper parser so multi-monitor settings behave identically.
    spec = importlib.util.spec_from_file_location("hyprduma_theme", repo / "scripts" / "theme.py")
    theme = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = theme
    spec.loader.exec_module(theme)
    try:
        wallpaper = theme.configured_wallpaper()
    except theme.ThemeError as exc:
        raise InstallError(str(exc)) from exc
    initialize_wallpaper = wallpaper is None
    if initialize_wallpaper:
        wallpaper = repo / "wallpapers" / "sakura.jpg"
        settings["wallpaper"] = str(wallpaper)
    hook = str(config_home() / "hypr" / "scripts" / "waypaper-hook.sh")
    # Waypaper escapes the substitution itself; surrounding quotes break space paths.
    settings["post_command"] = shlex.quote(hook) + ' $wallpaper'
    state_setup = None
    if config.getboolean("Settings", "use_xdg_state", fallback=False):
        state_path = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "waypaper/state.ini"
        state = configparser.ConfigParser(interpolation=None)
        if state_path.exists():
            with state_path.open() as stream:
                state.read_file(stream)
        if not state.has_section("State"):
            state.add_section("State")
        if not state["State"].get("backend"):
            state["State"]["backend"] = settings["backend"]
        if initialize_wallpaper or not state["State"].get("wallpaper"):
            state["State"]["wallpaper"] = settings.get("wallpaper") or str(wallpaper)
        state_setup = (state_path, state)
    return config, Path(wallpaper), state_setup


def preflight(repo, include_nvim=True, include_fastfetch=True):
    validate_repo(repo, include_nvim, include_fastfetch)
    commands = list(REQUIRED_COMMANDS)
    if include_nvim:
        commands.extend(NVIM_COMMANDS)
    if include_fastfetch:
        commands.append("fastfetch")
    missing = [name for name in commands if not cmd_exists(name)]
    if missing:
        raise InstallError("Required commands are missing: " + ", ".join(missing))
    check_lua_config_support()
    if include_nvim:
        check_version(["nvim", "--version"], r"NVIM v(\d+)\.(\d+)\.(\d+)", (0, 12, 0), "Neovim")
        check_version(["tree-sitter", "--version"], r"tree-sitter (\d+)\.(\d+)\.(\d+)",
                      (0, 26, 1), "tree-sitter-cli")
        require_run(["python3", "-c", "import debugpy"], "python-debugpy is required for Neovim's Python debugger")
    require_run(["python3", str(repo / "scripts" / "theme.py"), "--templates-dir",
                 str(repo / "config" / "wal" / "templates"), "--preflight"],
                "Theme prerequisite/template validation failed")
    config, wallpaper, state = prepare_waypaper_config(repo)
    prepare_bashrc(config_home())
    require_run(["python3", str(repo / "scripts" / "theme.py"), "--templates-dir",
                 str(repo / "config" / "wal" / "templates"), "--generate-only", str(wallpaper)],
                "Initial theme generation failed; configs were not replaced")
    return config, state


def install_hypr_config(repo):
    hypr = config_home() / "hypr"
    hypr.mkdir(parents=True, exist_ok=True)
    make_symlink(repo / "config" / "hyprlock" / "hyprlock.conf", hypr / "hyprlock.conf")
    make_symlink(repo / "wallpapers", Path.home() / "wallpapers")
    (Path.home() / "Pictures" / "Screenshots").mkdir(parents=True, exist_ok=True)
    legacy = hypr / "hyprland.conf"
    legacy_backup = preserve(legacy) if legacy.exists() or legacy.is_symlink() else None
    try:
        make_symlink(repo / "hyprland.lua", hypr / "hyprland.lua")
    except (InstallError, OSError):
        if legacy_backup is not None:
            legacy_backup.rename(legacy)
        raise
    print_ok("Installed Hyprland, lock screen, and wallpaper links")


def install_pywal(repo, waypaper_config, waypaper_state=None):
    config_dir = config_home()
    make_symlink(repo / "config" / "wal" / "templates", config_dir / "wal" / "templates")
    make_symlink(repo / "scripts", config_dir / "hypr" / "scripts")
    make_symlink(repo / "config" / "kitty", config_dir / "kitty")
    stream = io.StringIO()
    waypaper_config.write(stream)
    write_preserving(config_dir / "waypaper" / "config.ini", stream.getvalue())
    if waypaper_state is not None:
        state_path, state = waypaper_state
        stream = io.StringIO()
        state.write(stream)
        write_preserving(state_path, stream.getvalue())
    update_bashrc(config_dir)
    print_ok("Installed pywal templates, scripts, Kitty, and Waypaper integration")


def prepare_bashrc(config_dir):
    bashrc = Path.home() / ".bashrc"
    content = bashrc.read_text() if bashrc.exists() else ""
    script = shlex.quote(str(config_dir / "hypr" / "scripts" / "pywal.sh"))
    snippet = (
        "# BEGIN hyprduma pywal\n"
        "# Import pywal colorscheme from cache\n"
        '[ -f "${XDG_CACHE_HOME:-$HOME/.cache}/wal/sequences" ] && cat "${XDG_CACHE_HOME:-$HOME/.cache}/wal/sequences"\n'
        'source "${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors-tty.sh" 2>/dev/null\n'
        "unalias pywal 2>/dev/null || true\n"
        f"pywal() {{ {script} \"$@\"; }}\n"
        "# END hyprduma pywal\n"
    )
    legacy = (
        "# Import pywal colorscheme from cache\n"
        "(cat ~/.cache/wal/sequences &)\n"
        "\n# To add support for TTYs (optional)\n"
        "source ~/.cache/wal/colors-tty.sh 2>/dev/null\n"
        "\n# Alias for pywal color generator\n"
        "alias pywal='~/.config/hypr/scripts/pywal.sh'\n"
    )
    if "# BEGIN hyprduma pywal\n" in content:
        updated, count = re.subn(r"(?m)^# BEGIN hyprduma pywal\n.*?^# END hyprduma pywal(?:\n|$)",
                                lambda match: snippet, content, flags=re.DOTALL)
        if count != 1:
            raise InstallError("The managed pywal block in .bashrc is incomplete or duplicated")
    elif legacy in content:
        updated = content.replace(legacy, snippet, 1)
    elif "# Import pywal colorscheme from cache" in content:
        print_warn("Kept a custom .bashrc pywal block; update its paths manually if using XDG directories")
        return
    else:
        updated = content + "\n" + snippet
    return updated


def update_bashrc(config_dir):
    content = prepare_bashrc(config_dir)
    if content is not None:
        write_preserving(Path.home() / ".bashrc", content)


def install_fastfetch_config(repo):
    make_symlink(repo / "config" / "fastfetch", config_home() / "fastfetch")
    print_ok("Installed Fastfetch config")


def install_nvim_config(repo):
    make_symlink(repo / "config" / "nvim", config_home() / "nvim")
    print_ok("Installed Neovim config")


def print_banner():
    print(f"""{CYAN}{BOLD}
        
▄▄ ▄▄ ▄▄ ▄▄ ▄▄▄▄  ▄▄▄▄  ▄▄▄▄  ▄▄ ▄▄ ▄▄   ▄▄  ▄▄▄  
██▄██ ▀███▀ ██▄█▀ ██▄█▄ ██▀██ ██ ██ ██▀▄▀██ ██▀██ 
██ ██   █   ██    ██ ██ ████▀ ▀███▀ ██   ██ ██▀██ 
        
               Auto-Installer{RESET}
""")


def print_post_install(status):
    print(f"\n{BOLD}{GREEN}Required configuration installed successfully.{RESET}")
    for name, installed in status.items():
        print_info(f"{name}: {'installed/available' if installed else 'skipped/unavailable'}")
    hypr = config_home() / "hypr"
    print(f"""
Next steps:
  1. Edit app preferences, monitors, and workspaces in {hypr / 'hyprland.lua'}.
  2. Restart the Hyprland session to load the new monitor handler (start-hyprland).
     Later config-only edits can be applied with hyprctl reload.
  3. Select wallpapers with Waypaper (SUPER + W); the hook updates colors automatically.
     Manual theme update: {hypr / 'scripts' / 'pywal.sh'} /path/to/wallpaper.jpg

Existing configs and old checkouts are preserved as .backup, .backup.1, etc.
The desktop has not been launched or reloaded by this installer.
See docs/KEYBINDS.md for shortcuts and docs/README.md for optional applications.
""")


def main():
    print_banner()
    check_arch()
    include_nvim = ask_yn("Install the bundled Neovim config and its dependencies?")
    include_fastfetch = ask_yn("Install the bundled Fastfetch config?")
    print_step(1, 5, "Install required packages")
    packages = install_packages(include_nvim, include_fastfetch)
    print_step(2, 5, "Locate or clone repository")
    repo = clone_repo()
    print_step(3, 5, "Validate prerequisites and generate initial theme")
    waypaper = preflight(repo, include_nvim, include_fastfetch)
    print_step(4, 5, "Optional Caelestia shell")
    caelestia = install_caelestia()
    print_step(5, 5, "Activate configuration with backups")
    install_pywal(repo, *waypaper)
    if include_fastfetch:
        install_fastfetch_config(repo)
    if include_nvim:
        install_nvim_config(repo)
    install_hypr_config(repo)
    print_post_install({"Package installation": packages, "Caelestia": caelestia,
                        "Fastfetch config": include_fastfetch, "Neovim config": include_nvim})


if __name__ == "__main__":
    try:
        main()
    except (InstallError, OSError, configparser.Error) as exc:
        print_err(str(exc))
        print_warn("Installation did not complete. Review the error and any backups before retrying.")
        sys.exit(1)
    except KeyboardInterrupt:
        print(f"\n{YELLOW}Interrupted by user{RESET}")
        sys.exit(130)
