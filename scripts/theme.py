#!/usr/bin/env python3
"""Generate and publish one wallpaper palette; Waypaper owns the wallpaper itself.

The last selected monitor supplies the shared palette. Requests preserve the last
explicit light/dark choice and coalesce while wal is running. No desktop command
runs before a complete, validated generation has been published.
"""

import argparse
import configparser
from contextlib import contextmanager
import fcntl
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


class ThemeError(RuntimeError):
    pass


def xdg_path(variable, default):
    return Path(os.environ.get(variable) or Path.home() / default)


def cache_dir():
    return xdg_path("XDG_CACHE_HOME", ".cache") / "wal"


def state_dir():
    return xdg_path("XDG_STATE_HOME", ".local/state")


def theme_state_path():
    return state_dir() / "hyprduma" / "theme.json"


def runtime_dir():
    root = Path(os.environ.get("XDG_RUNTIME_DIR") or cache_dir().parent) / "hyprduma"
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    if root.is_symlink() or root.stat().st_uid != os.getuid():
        raise ThemeError(f"Runtime directory is not owned by this user: {root}")
    root.chmod(0o700)
    return root


def read_json(path):
    if not path.exists():
        return {}
    try:
        value = json.loads(path.read_text())
        if not isinstance(value, dict):
            raise ValueError("expected an object")
        return value
    except (ValueError, OSError) as error:
        raise ThemeError(f"Cannot read {path}: {error}") from error


def atomic_write(path, content):
    """Replace a whole file, so file watchers never observe partial JSON/text."""
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(content if isinstance(content, bytes) else content.encode())
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(name, path)
    finally:
        Path(name).unlink(missing_ok=True)


def atomic_json(path, value):
    atomic_write(path, json.dumps(value, indent=2) + "\n")


@contextmanager
def file_lock(path, blocking=True):
    # Never unlink a flock file: existing waiters must retain the same inode.
    descriptor = os.open(path, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    try:
        flags = fcntl.LOCK_EX | (0 if blocking else fcntl.LOCK_NB)
        fcntl.flock(descriptor, flags)
        yield
    finally:
        os.close(descriptor)


def waypaper_settings():
    """Read Waypaper's multiline monitor paths and optional XDG state file."""
    source = xdg_path("XDG_CONFIG_HOME", ".config") / "waypaper/config.ini"
    try:
        config = configparser.ConfigParser(interpolation=None)
        config.read(source)
        backend = config.get("Settings", "backend", fallback="swaybg")
        wallpapers = config.get("Settings", "wallpaper", fallback="")
        if config.getboolean("Settings", "use_xdg_state", fallback=False):
            source = state_dir() / "waypaper/state.ini"
            state = configparser.ConfigParser(interpolation=None)
            state.read(source)
            backend = state.get("State", "backend", fallback=backend)
            wallpapers = state.get("State", "wallpaper", fallback=wallpapers)
    except (configparser.Error, ValueError) as error:
        raise ThemeError(f"Cannot parse Waypaper settings in {source}: {error}") from error
    return {
        "backend": backend,
        "wallpapers": [Path(item).expanduser() for item in wallpapers.splitlines() if item],
    }


def configured_wallpaper():
    """First available monitor wallpaper; saved theme or hook args take priority."""
    return next((path.resolve() for path in waypaper_settings()["wallpapers"] if path.is_file()), None)


def resolve_wallpaper(wallpaper=None, pending=None):
    if wallpaper:
        candidate = Path(wallpaper).expanduser()
    else:
        saved = pending or read_json(theme_state_path())
        candidate = Path(saved["wallpaper"]) if saved.get("wallpaper") else None
        if candidate is None or not candidate.is_file():
            candidate = configured_wallpaper()
        if candidate is None and (cache_dir() / "wal").is_file():
            candidate = Path((cache_dir() / "wal").read_text().strip()).expanduser()
    if candidate is None or not candidate.is_file():
        raise ThemeError(f"Wallpaper file not found: {candidate or '(none saved)'}")
    if "\n" in str(candidate) or "\r" in str(candidate):
        raise ThemeError("Wallpaper filenames cannot contain line breaks")
    return candidate.resolve()


def templates_directory(explicit=None):
    if explicit:
        return Path(explicit).expanduser().resolve()
    repository_templates = Path(__file__).resolve().parent.parent / "config/wal/templates"
    if repository_templates.is_dir():
        return repository_templates
    return xdg_path("XDG_CONFIG_HOME", ".config") / "wal/templates"


def preflight(templates, wallpaper=None):
    if not shutil.which("wal"):
        raise ThemeError("wal is missing; install python-pywal first")
    for name in ("hyprland-colors.lua", "caelestia-scheme.json"):
        if not (templates / name).is_file():
            raise ThemeError(f"Required template missing: {templates / name}")
    if wallpaper:
        resolve_wallpaper(wallpaper)


def run_required(command, **kwargs):
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True, timeout=180, **kwargs)
    except subprocess.CalledProcessError as error:
        detail = (error.stderr or error.stdout or "").strip()
        raise ThemeError(f"{command[0]} failed (exit {error.returncode}): {detail}") from error
    except (OSError, subprocess.TimeoutExpired) as error:
        raise ThemeError(f"{command[0]} failed: {error}") from error
    return result


def generate(request, output):
    """Run wal in isolation; a failed export cannot reuse any old cache files."""
    # Released Pywal 3.3.0 reads ~/.config/wal directly, while newer versions
    # honor XDG_CONFIG_HOME. Point both at the same isolated template directory.
    home = output / "home"
    config = home / ".config"
    generated = output / "wal"
    generated.mkdir()
    shutil.copytree(request["templates"], config / "wal/templates")
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(config), XDG_CACHE_HOME=str(output / "cache"),
               PYWAL_CACHE_DIR=str(generated))
    command = ["wal", "-i", request["wallpaper"], "-n", "-s", "-t", "-e"]
    if request["mode"] == "light":
        command.append("-l")
    run_required(command, env=env)
    try:
        colours = read_json(generated / "colors.json")
        all_colours = [colours["colors"][f"color{i}"] for i in range(16)]
        all_colours += [colours["special"][key] for key in ("background", "foreground", "cursor")]
        if not all(re.fullmatch(r"#[0-9a-fA-F]{6}", value) for value in all_colours):
            raise ValueError("invalid palette colour")
        scheme = read_json(generated / "caelestia-scheme.json")
        if not scheme.get("colours") or not all(
            re.fullmatch(r"[0-9a-fA-F]{6}", value) for value in scheme["colours"].values()
        ):
            raise ValueError("invalid Caelestia palette")
        for name in ("hyprland-colors.lua", "colors-kitty.conf", "sequences", "colors-tty.sh"):
            content = (generated / name).read_text()
            if not content.strip() or re.search(r"\{(?:color\d+|background|foreground)(?:\.\w+)?\}", content):
                raise ValueError(f"incomplete export: {name}")
    except (KeyError, TypeError, ValueError, OSError) as error:
        raise ThemeError(f"wal did not produce a complete valid palette: {error}") from error
    scheme["mode"] = request["mode"]
    atomic_json(generated / "caelestia-scheme.json", scheme)
    # wal -n skips its own wallpaper cache; preserve the path explicitly.
    atomic_write(generated / "wal", request["wallpaper"] + "\n")
    return generated


def sync_wallpaper(wallpaper):
    destination = state_dir() / "caelestia/wallpaper"
    destination.mkdir(parents=True, exist_ok=True)
    descriptor, name = tempfile.mkstemp(prefix=".current.", dir=destination)
    os.close(descriptor)
    Path(name).unlink()
    try:
        Path(name).symlink_to(wallpaper)
        os.replace(name, destination / "current")
    finally:
        Path(name).unlink(missing_ok=True)
    atomic_write(destination / "path.txt", str(wallpaper) + "\n")


def publish(request, generated):
    # Each watched file is replaced atomically, and saved state is written last.
    for source in generated.iterdir():
        if source.is_file():
            atomic_write(cache_dir() / source.name, source.read_bytes())
    sync_wallpaper(request["wallpaper"])
    atomic_write(state_dir() / "caelestia/scheme.json", (generated / "caelestia-scheme.json").read_bytes())
    atomic_json(theme_state_path(), {"wallpaper": request["wallpaper"], "mode": request["mode"]})


def set_wallpaper(wallpaper):
    """Explicit CLI images apply to all monitors; hook requests preserve monitor choices."""
    if os.environ.get("WAYLAND_DISPLAY") or os.environ.get("DISPLAY"):
        run_required(["waypaper", "--wallpaper", wallpaper, "--monitor", "All", "--no-post-command"])
        return
    # A TTY invocation saves the same state Waypaper restores at the next login.
    config_path = xdg_path("XDG_CONFIG_HOME", ".config") / "waypaper/config.ini"
    source = config_path
    try:
        config = configparser.ConfigParser(interpolation=None)
        config.read(source)
        if config.getboolean("Settings", "use_xdg_state", fallback=False):
            source = state_dir() / "waypaper/state.ini"
            path, section = source, "State"
            state = configparser.ConfigParser(interpolation=None)
            state.read(source)
        else:
            path, section, state = config_path, "Settings", config
    except (configparser.Error, ValueError) as error:
        raise ThemeError(f"Cannot parse Waypaper settings in {source}: {error}") from error
    if not state.has_section(section):
        state.add_section(section)
    state[section].setdefault("backend", config.get("Settings", "backend", fallback="swaybg"))
    state[section]["monitors"] = "All"
    state[section]["wallpaper"] = wallpaper
    output = io.StringIO()
    state.write(output)
    atomic_write(path, output.getvalue())


def update_desktop(mode):
    """Optional integrations fail visibly; palette generation remains committed."""
    commands = [["wal-gtk"], ["pywalfox", "update"]]
    if os.environ.get("DBUS_SESSION_BUS_ADDRESS"):
        commands.append(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", f"prefer-{mode}"])
    if os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"):
        commands.append(["hyprctl", "reload"])
    errors = []
    for command in commands:
        if shutil.which(command[0]):
            try:
                run_required(command)
            except ThemeError as error:
                errors.append(str(error))
    # Kitty reloads its configured colour include on SIGUSR1. Restrict to this user.
    if shutil.which("pkill"):
        result = subprocess.run(["pkill", "-USR1", "-u", str(os.getuid()), "-x", "kitty"],
                                capture_output=True, text=True, timeout=10)
        if result.returncode not in (0, 1):
            errors.append(f"Kitty reload failed: {result.stderr.strip()}")
    if errors:
        raise ThemeError("Palette saved, but some desktop updates failed: " + "; ".join(errors))


def submit(wallpaper, mode, templates, generate_only=False, hook=False):
    root = runtime_dir()
    metadata_lock = root / "theme-queue.lock"
    pending_path = root / "theme-pending.json"
    result_path = root / "theme-result.json"
    with file_lock(metadata_lock):
        pending = read_json(pending_path)
        result = read_json(result_path)
        saved = pending or read_json(theme_state_path())
        request = {
            "revision": max(pending.get("revision", 0), result.get("revision", 0)) + 1,
            "wallpaper": str(resolve_wallpaper(wallpaper, saved)),
            "mode": mode or saved.get("mode", "dark"),
            "templates": str(templates),
            "generate_only": generate_only,
            "set_wallpaper": bool(wallpaper) and not hook and not generate_only,
        }
        atomic_json(pending_path, request)
    # All callers wait for completion. A later caller can take over after a crash;
    # the OS releases both locks, and the pending request remains on disk.
    with file_lock(root / "theme-worker.lock"):
        while True:
            with file_lock(metadata_lock):
                current = read_json(pending_path)
                if not current:
                    result = read_json(result_path)
                    if result.get("error"):
                        raise ThemeError(result["error"])
                    return
            error = None
            try:
                with tempfile.TemporaryDirectory(prefix="theme-", dir=root) as staging:
                    generated = generate(current, Path(staging))
                    with file_lock(metadata_lock):
                        if read_json(pending_path).get("revision") != current["revision"]:
                            continue  # A newer selection arrived during generation.
                        if current.get("set_wallpaper"):
                            set_wallpaper(current["wallpaper"])
                        publish(current, generated)
                    if not current["generate_only"]:
                        update_desktop(current["mode"])
            except (ThemeError, OSError, subprocess.SubprocessError) as caught:
                error = str(caught)
            with file_lock(metadata_lock):
                if read_json(pending_path).get("revision") == current["revision"]:
                    atomic_json(result_path, {"revision": current["revision"], "error": error})
                    pending_path.unlink()
                # Otherwise immediately try the latest queued selection, even if
                # this generation failed. Do not discard its requested mode.


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("wallpaper", nargs="?", help="image path; omit to use saved wallpaper")
    parser.add_argument("mode", nargs="?", choices=("light", "dark"))
    parser.add_argument("--generate-only", action="store_true", help="publish files without touching the running desktop")
    parser.add_argument("--preflight", action="store_true", help="check wal/templates without writing files")
    parser.add_argument("--templates-dir", type=Path)
    parser.add_argument("--sync-wallpaper-only", action="store_true", help="refresh Caelestia wallpaper reference without generating colors")
    parser.add_argument("--hook", action="store_true", help="require the explicit wallpaper passed by Waypaper")
    args = parser.parse_args(argv)
    try:
        if args.hook and not args.wallpaper:
            raise ThemeError("Waypaper hook requires $wallpaper in post_command")
        if args.sync_wallpaper_only:
            with file_lock(runtime_dir() / "theme-worker.lock"):
                sync_wallpaper(resolve_wallpaper(args.wallpaper))
            return 0
        templates = templates_directory(args.templates_dir)
        preflight(templates, args.wallpaper)
        if args.preflight:
            return 0
        submit(args.wallpaper, args.mode, templates, args.generate_only, args.hook)
        print("Theme applied" if not args.generate_only else "Theme generated and saved")
        return 0
    except (ThemeError, OSError, ValueError, configparser.Error) as error:
        print(f"theme: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
