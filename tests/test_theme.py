"""Theme regression tests with temporary state and no real desktop commands."""
import configparser
from concurrent.futures import ThreadPoolExecutor
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import threading
import time
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("theme_tests_module", ROOT / "scripts/theme.py")
theme = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(theme)


class Colour:
    def __init__(self, value):
        self.strip = value.lstrip("#")

    def __str__(self):
        return "#" + self.strip


class ThemeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="hyprduma-theme-tests-")
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name).resolve()
        self.environ = {
            "HOME": str(self.home), "XDG_CONFIG_HOME": str(self.home / "config"),
            "XDG_CACHE_HOME": str(self.home / "cache"), "XDG_STATE_HOME": str(self.home / "state"),
            "XDG_RUNTIME_DIR": str(self.home / "runtime"),
        }
        env = patch.dict(os.environ, self.environ, clear=True)
        env.start()
        self.addCleanup(env.stop)
        self.templates = ROOT / "config/wal/templates"
        self.image_a = self.home / "first #100% image.jpg"
        self.image_b = self.home / "second 'image'.jpg"
        self.image_a.touch()
        self.image_b.touch()

    def exported_palette(self, command, **kwargs):
        """Simulate wal's outputs by rendering the repository's actual templates."""
        self.assertEqual(command[0], "wal")
        self.assertTrue({"-n", "-s", "-t", "-e"}.issubset(command))
        env = kwargs["env"]
        output = Path(env["PYWAL_CACHE_DIR"])
        self.assertNotEqual(output, theme.cache_dir())
        # Released Pywal ignores XDG_CONFIG_HOME; both lookup paths must work.
        legacy_config = Path(env["HOME"]) / ".config"
        self.assertNotEqual(Path(env["HOME"]), self.home)
        self.assertEqual(Path(env["XDG_CONFIG_HOME"]), legacy_config)
        colours = {f"color{i}": f"#{i:02x}{i:02x}{i:02x}" for i in range(16)}
        special = {"background": "#ffffff" if "-l" in command else "#000000",
                   "foreground": "#123456", "cursor": "#abcdef"}
        (output / "colors.json").write_text(json.dumps({"colors": colours, "special": special}))
        values = {key: Colour(value) for key, value in dict(colours, **special).items()}
        for source in (legacy_config / "wal/templates").iterdir():
            (output / source.name).write_text(source.read_text().format_map(values))
        for name in ("colors-kitty.conf", "sequences", "colors-tty.sh"):
            (output / name).write_text("complete export\n")
        return subprocess.CompletedProcess(command, 0, "", "")

    def test_failed_generation_preserves_cache_and_desktop(self):
        old = theme.cache_dir() / "colors.json"
        old.parent.mkdir(parents=True)
        old.write_text("old palette")
        with patch.object(theme, "run_required", side_effect=theme.ThemeError("wal failed")), \
             patch.object(theme, "update_desktop") as desktop, patch.object(theme, "set_wallpaper") as wallpaper:
            with self.assertRaisesRegex(theme.ThemeError, "wal failed"):
                theme.submit(str(self.image_a), "dark", self.templates)
        self.assertEqual(old.read_text(), "old palette")
        self.assertFalse(theme.theme_state_path().exists())
        desktop.assert_not_called()
        wallpaper.assert_not_called()

    def test_missing_export_cannot_reuse_stale_cache(self):
        with patch.object(theme, "run_required", return_value=None), patch.object(theme, "update_desktop") as desktop:
            with self.assertRaisesRegex(theme.ThemeError, "complete valid palette"):
                theme.submit(str(self.image_a), "dark", self.templates)
        desktop.assert_not_called()

    def test_light_mode_saved_and_generate_only_does_not_touch_desktop(self):
        with patch.object(theme, "run_required", side_effect=self.exported_palette), \
             patch.object(theme, "update_desktop") as desktop, patch.object(theme, "set_wallpaper") as wallpaper:
            theme.submit(str(self.image_a), "light", self.templates, generate_only=True)
        scheme = theme.read_json(theme.state_dir() / "caelestia/scheme.json")
        self.assertEqual(scheme["mode"], "light")
        self.assertEqual(scheme["colours"]["background"], "ffffff")
        self.assertEqual(theme.read_json(theme.theme_state_path())["wallpaper"], str(self.image_a))
        self.assertEqual((theme.state_dir() / "caelestia/wallpaper/current").resolve(), self.image_a)
        desktop.assert_not_called()
        wallpaper.assert_not_called()

    def test_switching_mode_reuses_image_and_hook_preserves_mode(self):
        with patch.object(theme, "run_required", side_effect=self.exported_palette), \
             patch.object(theme, "update_desktop"), patch.object(theme, "set_wallpaper") as wallpaper:
            theme.submit(str(self.image_a), "dark", self.templates, generate_only=True)
            theme.submit("", "light", self.templates)
            theme.submit(str(self.image_b), None, self.templates, hook=True)
        saved = theme.read_json(theme.theme_state_path())
        self.assertEqual(saved, {"wallpaper": str(self.image_b), "mode": "light"})
        wallpaper.assert_not_called()

    def test_newest_selection_replaces_slow_request(self):
        started = threading.Event()
        release = threading.Event()
        real_generate = theme.generate
        generated, published = [], []
        real_publish = theme.publish

        def slow_generate(request, output):
            generated.append(request["wallpaper"])
            if request["wallpaper"] == str(self.image_a):
                started.set()
                if not release.wait(5):
                    raise AssertionError("Second request never arrived")
            return real_generate(request, output)

        def publish(request, output):
            published.append(request["wallpaper"])
            return real_publish(request, output)

        with patch.object(theme, "run_required", side_effect=self.exported_palette), \
             patch.object(theme, "generate", side_effect=slow_generate), \
             patch.object(theme, "publish", side_effect=publish), \
             patch.object(theme, "update_desktop"), ThreadPoolExecutor(max_workers=2) as pool:
            first = pool.submit(theme.submit, str(self.image_a), "light", self.templates, False, True)
            self.assertTrue(started.wait(5))
            second = pool.submit(theme.submit, str(self.image_b), None, self.templates, False, True)
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline:
                pending = theme.read_json(theme.runtime_dir() / "theme-pending.json")
                if pending.get("wallpaper") == str(self.image_b):
                    break
                time.sleep(0.01)
            release.set()
            first.result(timeout=5)
            second.result(timeout=5)
        self.assertEqual(generated, [str(self.image_a), str(self.image_b)])
        self.assertEqual(published, [str(self.image_b)])
        self.assertEqual(theme.read_json(theme.theme_state_path())["mode"], "light")

    def test_hook_failure_is_nonzero(self):
        with patch.object(theme.shutil, "which", return_value="/stub/wal"), \
             patch.object(theme, "run_required", side_effect=theme.ThemeError("generation failed")):
            self.assertEqual(theme.main(["--hook", str(self.image_a)]), 1)
            self.assertEqual(theme.main(["--hook"]), 1)

    def test_multimonitor_config_and_state_paths(self):
        path = Path(os.environ["XDG_CONFIG_HOME"]) / "waypaper/config.ini"
        path.parent.mkdir(parents=True)
        path.write_text(f"[Settings]\nbackend = swaybg\nwallpaper = {self.image_a}\n    {self.image_b}\n")
        self.assertEqual(theme.waypaper_settings()["wallpapers"], [self.image_a, self.image_b])
        self.assertEqual(theme.resolve_wallpaper(str(self.image_b)), self.image_b)
        path.write_text("[Settings]\nbackend = swaybg\nuse_xdg_state = True\n")
        state = theme.state_dir() / "waypaper/state.ini"
        state.parent.mkdir(parents=True)
        state.write_text(f"[State]\nbackend = swww\nwallpaper = {self.image_b}\n")
        self.assertEqual(theme.waypaper_settings()["backend"], "swww")
        self.assertEqual(theme.configured_wallpaper(), self.image_b)

    def test_explicit_cli_image_uses_waypaper_without_post_hook(self):
        with patch.dict(os.environ, {"WAYLAND_DISPLAY": "test"}), \
             patch.object(theme, "run_required") as run:
            theme.set_wallpaper(str(self.image_b))
        run.assert_called_once_with(["waypaper", "--wallpaper", str(self.image_b), "--monitor", "All", "--no-post-command"])

    def test_tty_wallpaper_is_restorable_and_preserves_other_settings(self):
        config = Path(os.environ["XDG_CONFIG_HOME"]) / "waypaper/config.ini"
        config.parent.mkdir(parents=True)
        config.write_text("[Settings]\nbackend = swww\npost_command = custom-hook $wallpaper\nuse_xdg_state = True\n")
        with patch.object(theme, "run_required") as run:
            theme.set_wallpaper(str(self.image_b))
        run.assert_not_called()
        self.assertIn("custom-hook", config.read_text())
        self.assertEqual(theme.configured_wallpaper(), self.image_b)
        self.assertEqual(theme.waypaper_settings()["backend"], "swww")

    def test_desktop_update_failure_is_reported_after_valid_publication(self):
        with patch.object(theme, "run_required", side_effect=self.exported_palette), \
             patch.object(theme, "update_desktop", side_effect=theme.ThemeError("reload failed")):
            with self.assertRaisesRegex(theme.ThemeError, "reload failed"):
                theme.submit(str(self.image_a), "dark", self.templates, hook=True)
        self.assertTrue(theme.theme_state_path().is_file())

    def test_malformed_waypaper_config_is_a_recoverable_theme_error(self):
        config = Path(os.environ["XDG_CONFIG_HOME"]) / "waypaper/config.ini"
        config.parent.mkdir(parents=True)
        invalid_contents = (
            "wallpaper = missing section\n",
            "[Settings]\n[Settings]\n",
            "[Settings]\nuse_xdg_state = not-a-boolean\n",
        )
        for content in invalid_contents:
            with self.subTest(content=content):
                config.write_text(content)
                with self.assertRaisesRegex(theme.ThemeError, "Cannot parse Waypaper settings.*config.ini"):
                    theme.waypaper_settings()
                with patch.object(theme, "run_required") as run:
                    with self.assertRaisesRegex(theme.ThemeError, "Cannot parse Waypaper settings.*config.ini"):
                        theme.set_wallpaper(str(self.image_b))
                run.assert_not_called()
                self.assertEqual(config.read_text(), content)
        config.write_text(f"[Settings]\nwallpaper = {self.image_a}\n")
        self.assertEqual(theme.configured_wallpaper(), self.image_a)

    def test_malformed_waypaper_state_is_preserved_and_identified(self):
        config = Path(os.environ["XDG_CONFIG_HOME"]) / "waypaper/config.ini"
        config.parent.mkdir(parents=True)
        config.write_text("[Settings]\nuse_xdg_state = true\n")
        state = theme.state_dir() / "waypaper/state.ini"
        state.parent.mkdir(parents=True)
        original = "wallpaper = missing state section\n"
        state.write_text(original)
        with self.assertRaisesRegex(theme.ThemeError, "Cannot parse Waypaper settings.*state.ini"):
            theme.waypaper_settings()
        with self.assertRaisesRegex(theme.ThemeError, "Cannot parse Waypaper settings.*state.ini"):
            theme.set_wallpaper(str(self.image_b))
        self.assertEqual(state.read_text(), original)
        self.assertEqual(config.read_text(), "[Settings]\nuse_xdg_state = true\n")

    def test_tty_parse_error_clears_failed_request_and_allows_retry(self):
        config = Path(os.environ["XDG_CONFIG_HOME"]) / "waypaper/config.ini"
        config.parent.mkdir(parents=True)
        config.write_text("not a valid ini\n")
        with patch.object(theme, "run_required", side_effect=self.exported_palette), \
             patch.object(theme, "update_desktop") as desktop:
            with self.assertRaisesRegex(theme.ThemeError, "Cannot parse Waypaper settings"):
                theme.submit(str(self.image_a), "dark", self.templates)
            self.assertFalse((theme.runtime_dir() / "theme-pending.json").exists())
            self.assertFalse(theme.theme_state_path().exists())
            desktop.assert_not_called()
            config.write_text("[Settings]\nbackend = swaybg\n")
            theme.submit(str(self.image_b), "light", self.templates)
        self.assertEqual(theme.configured_wallpaper(), self.image_b)
        self.assertEqual(theme.read_json(theme.theme_state_path())["mode"], "light")
        desktop.assert_called_once_with("light")


if __name__ == "__main__":
    unittest.main()
