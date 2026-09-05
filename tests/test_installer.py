"""Exercise installer failure boundaries without installing packages or touching a desktop."""
import configparser
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("installer", ROOT / "install.py")
installer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(installer)


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="hyprduma-installer-test-")
        self.addCleanup(self.directory.cleanup)
        self.home = Path(self.directory.name) / "home with % space"
        self.home.mkdir()
        self.env = patch.dict(os.environ, {"HOME": str(self.home), "XDG_CONFIG_HOME": str(self.home / "config with % space"), "XDG_STATE_HOME": str(self.home / "state with % space")})
        self.env.start()
        self.addCleanup(self.env.stop)

    def repository(self, name="repository"):
        repo = self.home / name
        for name in installer.REQUIRED_FILES + [
            "config/nvim/init.lua", "config/nvim/lazy-lock.json",
            "config/fastfetch/config.jsonc", "config/fastfetch/ascii/arch.txt",
        ]:
            path = repo / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture")
            if path.suffix == ".sh":
                path.chmod(0o755)
        # The wallpaper resolver lives in the separately tested theme coordinator.
        (repo / "scripts/theme.py").write_text("def configured_wallpaper():\n    return None\n")
        return repo

    def test_official_package_failure_aborts_before_aur(self):
        with patch.object(installer, "ask_yn", return_value=True), \
             patch.object(installer, "run", return_value=False) as run, \
             patch.object(installer, "install_aur_helpers") as helper:
            with self.assertRaisesRegex(installer.InstallError, "official package installation failed"):
                installer.install_packages()
        helper.assert_not_called()
        command = run.call_args.args[0]
        self.assertEqual(command[:3], ["sudo", "pacman", "-S"])
        self.assertTrue(set(installer.AUR_PACKAGES).isdisjoint(command))

    def test_aur_failure_propagates_and_package_sources_are_separate(self):
        with patch.object(installer, "ask_yn", return_value=True), \
             patch.object(installer, "run", side_effect=[True, False]) as run, \
             patch.object(installer, "install_aur_helpers", return_value="paru"):
            with self.assertRaisesRegex(installer.InstallError, "AUR package installation failed"):
                installer.install_packages(False, False)
        calls = [call.args[0] for call in run.call_args_list]
        self.assertEqual(calls[1], ["paru", "-S", "--needed", "--noconfirm", *installer.AUR_PACKAGES])
        self.assertNotIn("neovim", calls[0])
        self.assertNotIn("fastfetch", calls[0])

    def test_existing_helper_does_not_build_another(self):
        with patch.object(installer, "cmd_exists", side_effect=lambda name: name == "paru"), \
             patch.object(installer, "run") as run:
            self.assertEqual(installer.install_aur_helpers(), "paru")
        run.assert_not_called()

    def test_helper_build_uses_owned_temporary_directory_and_argument_arrays(self):
        exists = Mock(side_effect=[False, False, True])
        with patch.object(installer, "cmd_exists", exists), \
             patch.object(installer, "ask_yn", return_value=True), \
             patch.object(installer, "run", return_value=True) as run:
            self.assertEqual(installer.install_aur_helpers(), "yay")
        calls = run.call_args_list
        source = Path(calls[1].args[0][-1])
        self.assertEqual(calls[2].kwargs["cwd"], source)
        self.assertFalse(source.parent.exists())
        self.assertTrue(all(isinstance(call.args[0], list) for call in calls))
        self.assertNotIn("paru", str(calls))

    def test_git_bootstrap_is_independent_of_aur_helper(self):
        with patch.object(installer, "cmd_exists", side_effect=[False, True]), \
             patch.object(installer, "ask_yn", return_value=True), \
             patch.object(installer, "run", return_value=True) as run:
            installer.ensure_git()
        self.assertEqual(run.call_args.args[0], ["sudo", "pacman", "-S", "--needed", "--noconfirm", "git"])

    def test_missing_unreadable_unparseable_and_old_hyprland_fail(self):
        for output in (None, "", "version unknown", "Hyprland v0.54.3"):
            with self.subTest(output=output), patch.object(installer, "run", return_value=output):
                with self.assertRaises(installer.InstallError):
                    installer.check_lua_config_support()
        with patch.object(installer, "run", return_value="Hyprland v0.55.1 built from branch main"):
            installer.check_lua_config_support()

    def test_incomplete_repo_fails_before_dependency_or_theme_commands(self):
        repo = self.repository()
        (repo / "scripts/theme.py").unlink()
        with patch.object(installer, "run") as run:
            with self.assertRaisesRegex(installer.InstallError, "scripts/theme.py"):
                installer.preflight(repo)
        run.assert_not_called()
        self.assertFalse((installer.config_home() / "hypr").exists())

    def test_missing_dependency_never_generates_or_activates(self):
        repo = self.repository()
        with patch.object(installer, "cmd_exists", side_effect=lambda name: name != "wal"), \
             patch.object(installer, "run") as run:
            with self.assertRaisesRegex(installer.InstallError, "wal"):
                installer.preflight(repo, False, False)
        run.assert_not_called()
        self.assertFalse(installer.config_home().exists())

    def test_generation_failure_preserves_active_config_and_uses_repo_templates(self):
        repo = self.repository()
        original = installer.config_home() / "hypr" / "hyprland.lua"
        original.parent.mkdir(parents=True)
        original.write_text("old active config")
        with patch.object(installer, "cmd_exists", return_value=True), \
             patch.object(installer, "check_lua_config_support"), \
             patch.object(installer, "run", side_effect=[True, False]) as run:
            with self.assertRaisesRegex(installer.InstallError, "Initial theme generation failed"):
                installer.preflight(repo, False, False)
        self.assertEqual(original.read_text(), "old active config")
        for call in run.call_args_list:
            self.assertIn(str(repo / "config/wal/templates"), call.args[0])
        self.assertIn("--generate-only", run.call_args.args[0])
        self.assertFalse((installer.config_home() / "waypaper" / "config.ini").exists())

    def test_main_preflight_failure_never_activates(self):
        with patch.object(installer, "check_arch"), \
             patch.object(installer, "ask_yn", return_value=False), \
             patch.object(installer, "install_packages"), \
             patch.object(installer, "clone_repo", return_value=self.repository()), \
             patch.object(installer, "preflight", side_effect=installer.InstallError("failed")), \
             patch.object(installer, "install_hypr_config") as activate, \
             patch.object(installer, "print_post_install") as complete:
            with self.assertRaises(installer.InstallError):
                installer.main()
        activate.assert_not_called()
        complete.assert_not_called()

    def test_clone_failure_leaves_personal_checkout_in_place(self):
        old = self.home / "hyprduma-config"
        old.mkdir()
        (old / "hyprland.conf").write_text("personal changes")
        with patch.object(installer, "find_repo_dir", return_value=None), \
             patch.object(installer, "ensure_git"), \
             patch.object(installer, "run", return_value=False):
            with self.assertRaisesRegex(installer.InstallError, "clone failed"):
                installer.clone_repo()
        self.assertEqual((old / "hyprland.conf").read_text(), "personal changes")
        self.assertFalse(list(self.home.glob("hyprduma-config.backup*")))
        self.assertFalse(list(self.home.glob(".hyprduma-clone-*")))

    def test_successful_clone_preserves_old_checkout_with_numbered_backup(self):
        source = self.repository("complete source")
        old = self.home / "hyprduma-config"
        old.mkdir()
        (old / "hyprland.conf").write_text("personal changes")
        old.with_name("hyprduma-config.backup").write_text("older backup")

        def clone(command):
            import shutil
            shutil.copytree(source, command[-1])
            return True

        with patch.object(installer, "find_repo_dir", return_value=None), \
             patch.object(installer, "ensure_git"), patch.object(installer, "run", side_effect=clone):
            self.assertEqual(installer.clone_repo(), old)
        self.assertEqual((self.home / "hyprduma-config.backup.1/hyprland.conf").read_text(), "personal changes")
        self.assertEqual((self.home / "hyprduma-config.backup").read_text(), "older backup")
        installer.validate_repo(old)

    def test_failed_clone_activation_restores_original_checkout(self):
        source = self.repository("complete source")
        target = self.home / "hyprduma-config"
        target.mkdir()
        (target / "private.txt").write_text("keep")
        rename = Path.rename

        def clone(command):
            import shutil
            shutil.copytree(source, command[-1])
            return True

        def fail_staged(path, destination):
            if path.name == "repo":
                raise OSError("simulated rename error")
            return rename(path, destination)

        with patch.object(installer, "find_repo_dir", return_value=None), \
             patch.object(installer, "ensure_git"), patch.object(installer, "run", side_effect=clone), \
             patch.object(Path, "rename", fail_staged):
            with self.assertRaisesRegex(OSError, "simulated rename error"):
                installer.clone_repo()
        self.assertEqual((target / "private.txt").read_text(), "keep")
        self.assertFalse(list(self.home.glob("hyprduma-config.backup*")))

    def test_invalid_clone_never_moves_existing_checkout(self):
        target = self.home / "hyprduma-config"
        target.mkdir()
        (target / "private.txt").write_text("keep")
        with patch.object(installer, "find_repo_dir", return_value=None), \
             patch.object(installer, "ensure_git"), patch.object(installer, "run", return_value=True):
            with self.assertRaisesRegex(installer.InstallError, "incomplete"):
                installer.clone_repo()
        self.assertEqual((target / "private.txt").read_text(), "keep")

    def test_symlink_backups_preserve_each_target_and_reruns_are_idempotent(self):
        source = self.home / "source"
        source.mkdir()
        destination = self.home / "config"
        destination.mkdir()
        (destination / "personal.lua").write_text("personal")
        destination.with_name("config.backup").write_text("earlier backup")
        installer.make_symlink(source, destination)
        installer.make_symlink(source, destination)
        self.assertEqual(destination.resolve(), source.resolve())
        self.assertEqual((self.home / "config.backup.1/personal.lua").read_text(), "personal")
        self.assertFalse((self.home / "config.backup.2").exists())

    def test_hyprland_link_failure_restores_legacy_config(self):
        repo = self.repository()
        legacy = installer.config_home() / "hypr/hyprland.conf"
        legacy.parent.mkdir(parents=True)
        legacy.write_text("legacy configuration")
        symlink = installer.make_symlink

        def fail_final(src, dst):
            if dst.name == "hyprland.lua":
                raise OSError("simulated link error")
            return symlink(src, dst)

        with patch.object(installer, "make_symlink", side_effect=fail_final):
            with self.assertRaisesRegex(OSError, "simulated link error"):
                installer.install_hypr_config(repo)
        self.assertEqual(legacy.read_text(), "legacy configuration")
        self.assertFalse(legacy.with_name("hyprland.conf.backup").exists())

    def test_text_config_backups_and_idempotence(self):
        path = installer.config_home() / "waypaper/config.ini"
        path.parent.mkdir(parents=True)
        path.write_text("original")
        self.assertTrue(installer.write_preserving(path, "replacement"))
        self.assertFalse(installer.write_preserving(path, "replacement"))
        self.assertTrue(installer.write_preserving(path, "third"))
        self.assertEqual(path.with_name("config.ini.backup").read_text(), "original")
        self.assertEqual(path.with_name("config.ini.backup.1").read_text(), "replacement")

    def test_waypaper_percent_paths_and_hook_arguments_survive_roundtrip(self):
        repo = self.repository()
        ini = installer.config_home() / "waypaper/config.ini"
        ini.parent.mkdir(parents=True)
        original = "[Settings]\nfolder = /pictures/100% nice\nbackend = swww\npost_command = old-custom-hook\n"
        ini.write_text(original)
        config, wallpaper, state = installer.prepare_waypaper_config(repo)
        self.assertEqual(config["Settings"]["folder"], "/pictures/100% nice")
        self.assertEqual(config["Settings"]["backend"], "swww")
        self.assertEqual(wallpaper, repo / "wallpapers/sakura.jpg")
        self.assertEqual(ini.read_text(), original)
        installer.install_pywal(repo, config)
        result = configparser.ConfigParser(interpolation=None)
        result.read(ini)
        self.assertTrue(result["Settings"]["post_command"].endswith(" $wallpaper"))
        self.assertIn("config with % space", result["Settings"]["post_command"])
        self.assertEqual(result["Settings"]["folder"], "/pictures/100% nice")
        self.assertEqual(ini.with_name("config.ini.backup").read_text(), original)
        installer.install_pywal(repo, config)
        self.assertFalse(ini.with_name("config.ini.backup.1").exists())
        self.assertEqual((self.home / ".bashrc").read_text().count("# Import pywal colorscheme from cache"), 1)

    def test_fresh_waypaper_settings_use_swaybg(self):
        config, wallpaper, state = installer.prepare_waypaper_config(self.repository())
        self.assertEqual(config["Settings"]["backend"], "swaybg")
        self.assertEqual(config["Settings"]["wallpaper"], str(wallpaper))

    def test_state_enabled_initialization_preserves_existing_state_and_percent_paths(self):
        repo = self.repository()
        # Read the actual coordinator parser, including Waypaper XDG state handling.
        (repo / "scripts/theme.py").write_text((ROOT / "scripts/theme.py").read_text())
        ini = installer.config_home() / "waypaper/config.ini"
        ini.parent.mkdir(parents=True)
        ini.write_text("[Settings]\nuse_xdg_state = true\nbackend = swaybg\n")
        state_path = Path(os.environ["XDG_STATE_HOME"]) / "waypaper/state.ini"
        state_path.parent.mkdir(parents=True)
        original_state = "[State]\nwallpaper = /deleted/wallpaper.jpg\nfill = fit\n"
        state_path.write_text(original_state)
        config, wallpaper, state = installer.prepare_waypaper_config(repo)
        self.assertEqual(state_path.read_text(), original_state)
        self.assertEqual(state[1]["State"]["wallpaper"], str(wallpaper))
        self.assertEqual(state[1]["State"]["fill"], "fit")
        self.assertEqual(state[1]["State"]["backend"], "swaybg")
        installer.install_pywal(repo, config, state)
        self.assertEqual(state_path.with_name("state.ini.backup").read_text(), original_state)
        config2, wallpaper2, state2 = installer.prepare_waypaper_config(repo)
        self.assertEqual(wallpaper2, wallpaper.resolve())
        installer.install_pywal(repo, config2, state2)
        self.assertFalse(state_path.with_name("state.ini.backup.1").exists())

    def test_missing_state_copies_valid_config_wallpaper(self):
        repo = self.repository()
        (repo / "scripts/theme.py").write_text((ROOT / "scripts/theme.py").read_text())
        wallpaper = repo / "wallpapers/sakura.jpg"
        ini = installer.config_home() / "waypaper/config.ini"
        ini.parent.mkdir(parents=True)
        ini.write_text(f"[Settings]\nuse_xdg_state = true\nwallpaper = {wallpaper}\n")
        config, selected, state = installer.prepare_waypaper_config(repo)
        self.assertEqual(selected, wallpaper.resolve())
        self.assertEqual(state[1]["State"]["wallpaper"], str(wallpaper))
        self.assertEqual(state[1]["State"]["backend"], "swaybg")

    def test_existing_multimonitor_state_and_backend_are_preserved(self):
        repo = self.repository()
        (repo / "scripts/theme.py").write_text((ROOT / "scripts/theme.py").read_text())
        wallpaper = repo / "wallpapers/sakura.jpg"
        ini = installer.config_home() / "waypaper/config.ini"
        ini.parent.mkdir(parents=True)
        ini.write_text("[Settings]\nuse_xdg_state = true\nbackend = swaybg\n")
        state_path = Path(os.environ["XDG_STATE_HOME"]) / "waypaper/state.ini"
        state_path.parent.mkdir(parents=True)
        state_path.write_text(f"[State]\nbackend = swww\nwallpaper = /missing-first.jpg\n    {wallpaper}\n")
        config, selected, state = installer.prepare_waypaper_config(repo)
        self.assertEqual(selected, wallpaper.resolve())
        self.assertEqual(state[1]["State"]["backend"], "swww")
        self.assertEqual(state[1]["State"]["wallpaper"], f"/missing-first.jpg\n{wallpaper}")

    def test_malformed_waypaper_state_has_actionable_installer_error(self):
        repo = self.repository()
        (repo / "scripts/theme.py").write_text((ROOT / "scripts/theme.py").read_text())
        ini = installer.config_home() / "waypaper/config.ini"
        ini.parent.mkdir(parents=True)
        ini.write_text("[Settings]\nuse_xdg_state = true\n")
        state = Path(os.environ["XDG_STATE_HOME"]) / "waypaper/state.ini"
        state.parent.mkdir(parents=True)
        original = "invalid state without a section\n"
        state.write_text(original)
        with self.assertRaisesRegex(installer.InstallError, "Cannot parse Waypaper settings.*state.ini"):
            installer.prepare_waypaper_config(repo)
        self.assertEqual(state.read_text(), original)
        self.assertFalse(state.with_name("state.ini.backup").exists())

    def test_invalid_waypaper_boolean_has_actionable_installer_error(self):
        repo = self.repository()
        (repo / "scripts/theme.py").write_text((ROOT / "scripts/theme.py").read_text())
        ini = installer.config_home() / "waypaper/config.ini"
        ini.parent.mkdir(parents=True)
        original = "[Settings]\nuse_xdg_state = invalid\n"
        ini.write_text(original)
        with self.assertRaisesRegex(installer.InstallError, "Cannot parse Waypaper settings.*config.ini"):
            installer.prepare_waypaper_config(repo)
        self.assertEqual(ini.read_text(), original)

    def test_neovim_version_requirement_before_theme_generation(self):
        repo = self.repository()
        with patch.object(installer, "cmd_exists", return_value=True), \
             patch.object(installer, "check_lua_config_support"), \
             patch.object(installer, "run", return_value="NVIM v0.11.9") as run:
            with self.assertRaisesRegex(installer.InstallError, "Neovim 0.12.0"):
                installer.preflight(repo, True, False)
        self.assertEqual(run.call_args.args[0], ["nvim", "--version"])

    def test_managed_bashrc_migrates_legacy_alias_and_preserves_user_lines(self):
        bashrc = self.home / ".bashrc"
        original = (
            "export PERSONAL=1\n"
            "# Import pywal colorscheme from cache\n"
            "(cat ~/.cache/wal/sequences &)\n"
            "\n# To add support for TTYs (optional)\n"
            "source ~/.cache/wal/colors-tty.sh 2>/dev/null\n"
            "\n# Alias for pywal color generator\n"
            "alias pywal='~/.config/hypr/scripts/pywal.sh'\n"
            "export OTHER=2\n"
        )
        bashrc.write_text(original)
        installer.update_bashrc(installer.config_home())
        updated = bashrc.read_text()
        self.assertIn("# BEGIN hyprduma pywal", updated)
        self.assertIn("XDG_CACHE_HOME", updated)
        self.assertIn("config with % space", updated)
        self.assertNotIn("alias pywal=", updated)
        self.assertIn("export PERSONAL=1", updated)
        self.assertIn("export OTHER=2", updated)
        self.assertEqual(bashrc.with_name(".bashrc.backup").read_text(), original)
        installer.update_bashrc(installer.config_home())
        self.assertFalse(bashrc.with_name(".bashrc.backup.1").exists())
        self.assertTrue(installer.run(["bash", "-n", str(bashrc)]))

    def test_incomplete_managed_bashrc_block_fails_during_preflight(self):
        repo = self.repository()
        bashrc = self.home / ".bashrc"
        bashrc.write_text("# BEGIN hyprduma pywal\nmissing end marker\n")
        with patch.object(installer, "cmd_exists", return_value=True), \
             patch.object(installer, "check_lua_config_support"), \
             patch.object(installer, "run", return_value=True) as run:
            with self.assertRaisesRegex(installer.InstallError, "incomplete or duplicated"):
                installer.preflight(repo, False, False)
        self.assertEqual(run.call_count, 1)
        self.assertIn("--preflight", run.call_args.args[0])
        self.assertFalse(installer.config_home().exists())

    def test_caelestia_cli_alone_is_not_shell_installation(self):
        with patch.object(installer, "cmd_exists", side_effect=lambda name: name == "caelestia"):
            self.assertFalse(installer.caelestia_installed())

    def test_caelestia_can_run_without_cli_from_xdg_config_roots(self):
        for root in (installer.config_home(), self.home / "system-config"):
            with self.subTest(root=root):
                entry = root / "quickshell/caelestia/shell.qml"
                entry.parent.mkdir(parents=True, exist_ok=True)
                entry.write_text("fixture")
                with patch.dict(os.environ, {"XDG_CONFIG_DIRS": str(self.home / "system-config")}), \
                     patch.object(installer, "cmd_exists", side_effect=lambda name: name == "qs"), \
                     patch.object(installer, "run") as run:
                    self.assertTrue(installer.caelestia_installed())
                run.assert_not_called()
                entry.unlink()

    def test_caelestia_requires_discoverable_qml_even_with_runtime(self):
        with patch.dict(os.environ, {"XDG_CONFIG_DIRS": str(self.home / "system-config")}), \
             patch.object(installer, "cmd_exists", return_value=True), \
             patch.object(installer, "run", return_value="/custom/not-discoverable/shell.qml") as run:
            self.assertFalse(installer.caelestia_installed())
        run.assert_not_called()

    def test_optional_caelestia_never_launches_shell(self):
        with patch.object(installer, "caelestia_installed", return_value=True), \
             patch.object(installer, "run") as run:
            self.assertTrue(installer.install_caelestia())
        run.assert_not_called()

    def test_skipping_optional_caelestia_reports_unavailable(self):
        with patch.object(installer, "caelestia_installed", return_value=False), \
             patch.object(installer, "ask_yn", return_value=False), \
             patch.object(installer, "run") as run:
            self.assertFalse(installer.install_caelestia())
        run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
