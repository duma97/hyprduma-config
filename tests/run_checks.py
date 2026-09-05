#!/usr/bin/env python3
"""Run local regression checks without installing packages or touching user config."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def main():
    repository = Path(__file__).resolve().parents[1]
    for command in ("nvim", "bash"):
        if not shutil.which(command):
            raise SystemExit(f"Required for these checks: {command}")
    with tempfile.TemporaryDirectory(prefix="hyprduma-checks-") as temporary:
        env = dict(os.environ, HOME=temporary, XDG_CONFIG_HOME=temporary + "/config",
                   XDG_DATA_HOME=temporary + "/data", XDG_STATE_HOME=temporary + "/state",
                   XDG_CACHE_HOME=temporary + "/cache", XDG_RUNTIME_DIR=temporary + "/runtime",
                   PYTHONDONTWRITEBYTECODE="1")
        for variable in ("WAYLAND_DISPLAY", "DISPLAY", "HYPRLAND_INSTANCE_SIGNATURE",
                         "DBUS_SESSION_BUS_ADDRESS", "NVIM_APPNAME", "VIMINIT", "EXINIT"):
            env.pop(variable, None)
        commands = [[sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"]]
        commands.extend(["bash", "-n", str(path)] for path in sorted((repository / "scripts").glob("*.sh")))
        commands.append(["nvim", "--headless", "-u", "NONE", "-l", "tests/check_hyprland.lua"])
        commands.append(["nvim", "--headless", "-u", "NONE", "-l", "tests/check_nvim.lua"])
        for command in commands:
            subprocess.run(command, cwd=repository, env=env, check=True, timeout=120)
    print("All local regression checks passed.")


if __name__ == "__main__":
    main()
