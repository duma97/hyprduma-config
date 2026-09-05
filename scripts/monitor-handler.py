#!/usr/bin/env python3
"""Restore desktop components for one Hyprland session without theme reload loops."""

import codecs
import hashlib
import os
from pathlib import Path
import shutil
import socket
import subprocess
import sys
import time

import theme


BACKEND_PROCESSES = {
    "swaybg": "swaybg",
    "swww": "swww-daemon",
    "awww": "awww-daemon",
    "hyprpaper": "hyprpaper",
    "mpvpaper": "mpvpaper",
    "gslapper": "gslapper",
}


def get_socket_path():
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not runtime or not signature:
        return None
    return Path(runtime) / "hypr" / signature / ".socket2.sock"


def is_running(name):
    result = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", name],
                            capture_output=True, text=True, timeout=5)
    return result.returncode == 0


def caelestia_installed():
    if not shutil.which("qs"):
        return False
    config_roots = [theme.xdg_path("XDG_CONFIG_HOME", ".config")]
    config_roots += [Path(item) for item in os.environ.get("XDG_CONFIG_DIRS", "/etc/xdg").split(":") if item]
    return any((root / "quickshell/caelestia/shell.qml").is_file() for root in config_roots)


def run_component(command):
    try:
        theme.run_required(command)
        return True
    except theme.ThemeError as error:
        print(f"monitor-handler: {error}", file=sys.stderr)
        return False


def ensure_components(startup=False, topology_changed=False):
    settings = theme.waypaper_settings()
    backend = settings["backend"]
    process = BACKEND_PROCESSES.get(backend)
    # One-shot/X11 or user-defined backends have no persistent process to check.
    # Restore on login or monitor changes; a running backend may still only know
    # about the previous outputs. Ordinary config reloads only recover failures.
    needs_restore = startup or topology_changed or (process is not None and not is_running(process))
    if backend != "none" and settings["wallpapers"] and needs_restore and shutil.which("waypaper"):
        run_component(["waypaper", "--restore", "--no-post-command"])
    if startup:
        try:
            # The installer and hook already generated colours; only refresh the
            # shell reference at login. No wal generation or hyprctl reload here.
            with theme.file_lock(theme.runtime_dir() / "theme-worker.lock"):
                theme.sync_wallpaper(theme.resolve_wallpaper())
        except theme.ThemeError as error:
            print(f"monitor-handler: {error}", file=sys.stderr)
    if caelestia_installed():
        # This is the CLI's native launch command: -n refuses duplicate instances,
        # -d detaches the actual Quickshell shell. The CLI itself is not a daemon.
        # The compositor's start event can precede readiness of shell services.
        # Retry failed login launches; -n makes each attempt safe if already up.
        attempts = 5 if startup else 1
        for attempt in range(attempts):
            if run_component(["qs", "-c", "caelestia", "-n", "-d"]):
                break
            if attempt + 1 < attempts:
                time.sleep(2)


def handle_event(line):
    event = line.partition(">>")[0]
    if event in ("configreloaded", "monitoradded", "monitorremoved"):
        try:
            ensure_components(topology_changed=event != "configreloaded")
        except (theme.ThemeError, OSError, subprocess.SubprocessError, ValueError) as error:
            print(f"monitor-handler: {error}", file=sys.stderr)


def listen(path):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.connect(str(path))
        ensure_components(startup=True)
        # Decoder preserves UTF-8 sequences split across recv boundaries.
        decoder = codecs.getincrementaldecoder("utf-8")(errors="replace")
        buffer = ""
        while data := connection.recv(4096):
            buffer += decoder.decode(data)
            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                handle_event(line)
    # EOF belongs to this session ending. Environment variables cannot discover
    # a later compositor's new signature: that session starts its own handler.


def main():
    path = get_socket_path()
    if path is None:
        print("monitor-handler: requires XDG_RUNTIME_DIR and HYPRLAND_INSTANCE_SIGNATURE", file=sys.stderr)
        return 1
    lock_name = hashlib.sha256(str(path).encode()).hexdigest()[:16]
    try:
        with theme.file_lock(theme.runtime_dir() / f"monitor-{lock_name}.lock", blocking=False):
            deadline = time.monotonic() + 10
            while True:
                try:
                    listen(path)
                    return 0
                except (ConnectionRefusedError, FileNotFoundError):
                    if time.monotonic() >= deadline:
                        raise theme.ThemeError(f"Session event socket did not become ready: {path}")
                    time.sleep(0.2)
    except BlockingIOError:
        return 0  # An existing handler already owns this session.
    except (theme.ThemeError, OSError, subprocess.SubprocessError, ValueError) as error:
        print(f"monitor-handler: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
