"""Monitor recovery and IPC tests; never invoke a live desktop or backend."""
from contextlib import nullcontext
import importlib.util
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import MagicMock, Mock, call, patch

ROOT = Path(__file__).resolve().parents[1]
THEME_SPEC = importlib.util.spec_from_file_location("theme", ROOT / "scripts/theme.py")
THEME = importlib.util.module_from_spec(THEME_SPEC)
THEME_SPEC.loader.exec_module(THEME)
SPEC = importlib.util.spec_from_file_location("monitor_handler", ROOT / "scripts/monitor-handler.py")
handler = importlib.util.module_from_spec(SPEC)
with patch.dict(sys.modules, {"theme": THEME}):
    SPEC.loader.exec_module(handler)


class MonitorHandlerTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="hyprduma-monitor-test-")
        self.addCleanup(temporary.cleanup)
        self.home = Path(temporary.name)
        environment = {
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.home / "config"),
            "XDG_CONFIG_DIRS": str(self.home / "system-config"),
            "XDG_CACHE_HOME": str(self.home / "cache"),
            "XDG_STATE_HOME": str(self.home / "state"),
            "XDG_RUNTIME_DIR": str(self.home / "runtime"),
            "HYPRLAND_INSTANCE_SIGNATURE": "test-session",
        }
        self.env = patch.dict(os.environ, environment)
        self.env.start()
        self.addCleanup(self.env.stop)
        self.wallpaper = self.home / "wallpaper with space.jpg"
        self.wallpaper.write_bytes(b"fixture")

    def components(self, backend, *, startup=False, topology_changed=False, running=False, wallpapers=None, caelestia=False):
        settings = {"backend": backend, "wallpapers": [self.wallpaper] if wallpapers is None else wallpapers}
        with patch.object(handler.theme, "waypaper_settings", return_value=settings), \
             patch.object(handler, "is_running", return_value=running) as process, \
             patch.object(handler, "caelestia_installed", return_value=caelestia), \
             patch.object(handler.shutil, "which", side_effect=lambda name: "/fake/bin/" + name), \
             patch.object(handler, "run_component") as commands, \
             patch.object(handler.theme, "file_lock", return_value=nullcontext()), \
             patch.object(handler.theme, "runtime_dir", return_value=self.home / "runtime"), \
             patch.object(handler.theme, "resolve_wallpaper", return_value=self.wallpaper), \
             patch.object(handler.theme, "sync_wallpaper") as sync:
            handler.ensure_components(startup=startup, topology_changed=topology_changed)
        return commands, process, sync

    def test_startup_restores_once_without_post_command_and_syncs_saved_wallpaper(self):
        commands, process, sync = self.components("swaybg", startup=True, running=True)
        commands.assert_called_once_with(["waypaper", "--restore", "--no-post-command"])
        process.assert_not_called()
        sync.assert_called_once_with(self.wallpaper)

    def test_running_backend_does_not_restore_on_reload(self):
        for backend, process_name in handler.BACKEND_PROCESSES.items():
            with self.subTest(backend=backend):
                commands, process, sync = self.components(backend, running=True)
                commands.assert_not_called()
                process.assert_called_once_with(process_name)
                sync.assert_not_called()

    def test_monitor_change_restores_even_when_backend_is_running(self):
        commands, process, sync = self.components("swaybg", topology_changed=True, running=True)
        commands.assert_called_once_with(["waypaper", "--restore", "--no-post-command"])
        process.assert_not_called()
        sync.assert_not_called()

    def test_missing_backend_restores_without_hook_on_reload(self):
        for backend, process_name in handler.BACKEND_PROCESSES.items():
            with self.subTest(backend=backend):
                commands, process, sync = self.components(backend, running=False)
                commands.assert_called_once_with(["waypaper", "--restore", "--no-post-command"])
                process.assert_called_once_with(process_name)
                sync.assert_not_called()

    def test_custom_or_oneshot_backend_restores_only_at_startup(self):
        for backend in ("custom", "feh"):
            with self.subTest(backend=backend):
                commands, process, _ = self.components(backend, startup=True)
                commands.assert_called_once_with(["waypaper", "--restore", "--no-post-command"])
                process.assert_not_called()
                commands, process, _ = self.components(backend)
                commands.assert_not_called()
                process.assert_not_called()

    def test_disabled_backend_and_empty_wallpaper_never_restore(self):
        for startup in (True, False):
            with self.subTest(startup=startup):
                commands, _, _ = self.components("none", startup=startup)
                commands.assert_not_called()
                commands, _, _ = self.components("swaybg", startup=startup, wallpapers=[])
                commands.assert_not_called()

    def test_optional_shell_is_launched_through_quickshell_instance_guard(self):
        commands, _, _ = self.components("swaybg", running=True, caelestia=True)
        commands.assert_called_once_with(["qs", "-c", "caelestia", "-n", "-d"])
        self.assertFalse(any("caelestia shell" in str(item) for item in commands.call_args_list))

    def test_no_optional_shell_launch_when_it_is_unavailable(self):
        commands, _, _ = self.components("swaybg", running=True, caelestia=False)
        commands.assert_not_called()

    def test_login_retries_failed_shell_launch_until_success(self):
        original = handler.run_component
        with patch.object(handler.theme, "run_required", side_effect=[
            handler.theme.ThemeError("display not ready"), None,
        ]) as launch, patch.object(handler.time, "sleep") as sleep, \
             patch("sys.stderr"):
            with patch.object(handler, "run_component", side_effect=original):
                # Keep wallpaper work out of this shell startup regression.
                with patch.object(handler.theme, "waypaper_settings", return_value={"backend": "none", "wallpapers": []}), \
                     patch.object(handler, "caelestia_installed", return_value=True), \
                     patch.object(handler.theme, "resolve_wallpaper", side_effect=handler.theme.ThemeError("no wallpaper")):
                    handler.ensure_components(startup=True)
        self.assertEqual(launch.call_count, 2)
        sleep.assert_called_once_with(2)

    def test_caelestia_requires_runtime_and_qml_entrypoint(self):
        entry = Path(os.environ["XDG_CONFIG_HOME"]) / "quickshell/caelestia/shell.qml"
        entry.parent.mkdir(parents=True)
        entry.write_text("fixture")
        with patch.object(handler.shutil, "which", return_value=None):
            self.assertFalse(handler.caelestia_installed())
        with patch.object(handler.shutil, "which", return_value="/fake/bin/qs"):
            self.assertTrue(handler.caelestia_installed())
            entry.unlink()
            self.assertFalse(handler.caelestia_installed())

    def test_caelestia_can_come_from_xdg_system_config(self):
        entry = Path(os.environ["XDG_CONFIG_DIRS"]) / "quickshell/caelestia/shell.qml"
        entry.parent.mkdir(parents=True)
        entry.write_text("fixture")
        with patch.object(handler.shutil, "which", return_value="/fake/bin/qs"):
            self.assertTrue(handler.caelestia_installed())

    def test_process_checks_are_exact_and_restricted_to_current_user(self):
        with patch.object(handler.subprocess, "run", return_value=Mock(returncode=0)) as run:
            self.assertTrue(handler.is_running("swww-daemon"))
        self.assertEqual(run.call_args.args[0], ["pgrep", "-u", str(os.getuid()), "-x", "swww-daemon"])
        with patch.object(handler.subprocess, "run", return_value=Mock(returncode=1)):
            self.assertFalse(handler.is_running("swww-daemon"))

    def test_event_filter_only_recovers_on_relevant_events(self):
        with patch.object(handler, "ensure_components") as ensure:
            for line in ("monitoradded>>DP-1", "monitorremoved>>DP-1", "configreloaded>>"):
                handler.handle_event(line)
            for line in ("activewindow>>app,title", "workspace>>1", "focusedmon>>DP-1,1"):
                handler.handle_event(line)
        self.assertEqual(ensure.call_count, 3)
        self.assertEqual(ensure.call_args_list, [call(topology_changed=True),
                                               call(topology_changed=True),
                                               call(topology_changed=False)])

    def test_failed_recovery_does_not_stop_event_stream(self):
        with patch.object(handler, "ensure_components", side_effect=[OSError("backend failed"), None]) as ensure, \
             patch("sys.stderr"):
            handler.handle_event("monitoradded>>DP-1")
            handler.handle_event("monitorremoved>>DP-1")
        self.assertEqual(ensure.call_count, 2)

    def test_utf8_and_event_lines_can_span_multiple_ipc_reads(self):
        line_one = "monitoradded>>экран-日本"
        line_two = "configreloaded>>"
        payload = (line_one + "\n" + line_two + "\n").encode("utf-8")
        # Cut inside a Cyrillic code point, then inside the following event name.
        split = payload.index("э".encode("utf-8")) + 1
        chunks = [payload[:split], payload[split:-8], payload[-8:], b""]
        connection = MagicMock()
        connection.__enter__.return_value = connection
        connection.recv.side_effect = chunks
        path = self.home / "runtime/hypr/test-session/.socket2.sock"
        with patch.object(handler.socket, "socket", return_value=connection), \
             patch.object(handler, "ensure_components") as ensure, \
             patch.object(handler, "handle_event") as event:
            handler.listen(path)
        connection.connect.assert_called_once_with(str(path))
        ensure.assert_called_once_with(startup=True)
        self.assertEqual(event.call_args_list, [call(line_one), call(line_two)])
        self.assertEqual(connection.recv.call_count, len(chunks))

    def test_eof_returns_without_reconnecting_to_finished_session(self):
        with patch.object(handler.theme, "file_lock", return_value=nullcontext()), \
             patch.object(handler.theme, "runtime_dir", return_value=self.home / "runtime"), \
             patch.object(handler, "listen", return_value=None) as listen:
            self.assertEqual(handler.main(), 0)
        listen.assert_called_once()

    def test_socket_startup_race_retries_then_terminates_normally(self):
        with patch.object(handler.theme, "file_lock", return_value=nullcontext()), \
             patch.object(handler.theme, "runtime_dir", return_value=self.home / "runtime"), \
             patch.object(handler, "listen", side_effect=[FileNotFoundError(), None]) as listen, \
             patch.object(handler.time, "sleep") as sleep:
            self.assertEqual(handler.main(), 0)
        self.assertEqual(listen.call_count, 2)
        sleep.assert_called_once_with(0.2)

    def test_socket_startup_timeout_returns_failure(self):
        with patch.object(handler.theme, "file_lock", return_value=nullcontext()), \
             patch.object(handler.theme, "runtime_dir", return_value=self.home / "runtime"), \
             patch.object(handler, "listen", side_effect=ConnectionRefusedError()), \
             patch.object(handler.time, "monotonic", side_effect=[0, 11]), \
             patch("sys.stderr"):
            self.assertEqual(handler.main(), 1)

    def test_existing_handler_lock_exits_without_starting_second_handler(self):
        with patch.object(handler.theme, "file_lock", side_effect=BlockingIOError()), \
             patch.object(handler.theme, "runtime_dir", return_value=self.home / "runtime"), \
             patch.object(handler, "listen") as listen:
            self.assertEqual(handler.main(), 0)
        listen.assert_not_called()

    def test_missing_session_environment_fails_without_starting_components(self):
        with patch.dict(os.environ, {"HYPRLAND_INSTANCE_SIGNATURE": ""}), \
             patch.object(handler, "listen") as listen, patch("sys.stderr"):
            self.assertEqual(handler.main(), 1)
        listen.assert_not_called()


if __name__ == "__main__":
    unittest.main()
