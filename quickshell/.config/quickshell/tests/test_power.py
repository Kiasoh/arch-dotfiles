"""Run with python3 tests/test_power.py; never changes hardware settings."""
import json
import os
from pathlib import Path
import subprocess
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def run_ui(config, **environment):
    if os.environ.get("QT_QPA_PLATFORM") == "offscreen":
        runtime = config / "runtime"
        runtime.mkdir(mode=0o700)
        # Only replace the unavailable layer-shell window backend in temporary copies.
        for path in config.glob("*.qml"):
            source = path.read_text()
            if "PanelWindow {" not in source:
                continue
            size = "\n    implicitWidth: 800"
            if path.name == "PolkitPrompt.qml":
                size += "\n    implicitHeight: 600"
            source = source.replace("PanelWindow {", "FloatingWindow {" + size)
            source = "\n".join(line for line in source.splitlines()
                               if not line.strip().startswith(("anchors {", "exclusionMode:", "WlrLayershell.")))
            path.write_text(source + "\n")
        environment.update(WAYLAND_DISPLAY="", DISPLAY="", XDG_RUNTIME_DIR=str(runtime))
    result = subprocess.run(
        ["quickshell", "-p", str(config), "--no-color"],
        env={**os.environ, **environment},
        text=True, capture_output=True, timeout=8,
    )
    return result.stdout + result.stderr


class ReadHelpers(unittest.TestCase):
    def run_helper(self, script, response, *args, status=0):
        with tempfile.TemporaryDirectory() as directory:
            tool = Path(directory) / "hyprctl"
            tool.write_text('#!/bin/sh\nprintf "%s\\n" "$TEST_RESPONSE"\nexit "$TEST_STATUS"\n')
            tool.chmod(0o755)
            return subprocess.run(
                ["bash", str(ROOT / "scripts" / script), *args],
                env={**os.environ, "PATH": directory + ":" + os.environ["PATH"],
                     "TEST_RESPONSE": json.dumps(response), "TEST_STATUS": str(status)},
                text=True, capture_output=True,
            )

    def test_monitor_is_selected_by_name_and_preserves_fractional_modes(self):
        monitors = [
            {"name": "eDP-1", "width": 1920, "height": 1080,
             "refreshRate": 144, "scale": 1, "x": 0, "y": 0,
             "availableModes": ["1920x1080@144.00Hz", "1920x1080@60.00Hz"]},
            {"name": "HDMI-A-1", "width": 2560, "height": 1440,
             "refreshRate": 59.94, "scale": 1.25, "x": 1920, "y": 0,
             "availableModes": ["2560x1440@59.94Hz", "1920x1080@120.00Hz"]},
        ]
        result = self.run_helper("qs-read-monitor.sh", monitors, "HDMI-A-1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), monitors[1])

    def test_missing_monitor_is_an_error(self):
        result = self.run_helper("qs-read-monitor.sh", [], "gone")
        self.assertNotEqual(result.returncode, 0)

    def test_hypr_failure_is_not_reported_as_disabled_effects(self):
        result = self.run_helper("qs-read-hypr.sh", {}, status=1)
        self.assertNotEqual(result.returncode, 0)

    def test_visual_options_keep_asymmetric_gaps(self):
        option = {"option": "general:gaps_out", "css": "4 8 12 16", "set": True}
        result = self.run_helper("qs-read-hypr.sh", option)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["general:gaps_out"], "4 8 12 16")


class GpuHelper(unittest.TestCase):
    def test_unconfirmed_gpu_mode_is_a_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            for name, script in {
                "envycontrol": '#!/bin/sh\nif [ "$1" = --query ]; then echo hybrid; fi\nexit 0\n',
                "sleep": '#!/bin/sh\nexit 0\n',
            }.items():
                tool = Path(directory) / name
                tool.write_text(script)
                tool.chmod(0o755)
            result = subprocess.run(
                ["bash", str(ROOT / "scripts/qs-gpu-mode.sh"), "integrated"],
                env={**os.environ, "PATH": directory + ":" + os.environ["PATH"]},
                text=True, capture_output=True,
            )
            self.assertNotEqual(result.returncode, 0, "An unconfirmed GPU switch must not report success")


class AsusHelper(unittest.TestCase):
    def test_checks_active_profile_instead_of_saved_policy(self):
        with tempfile.TemporaryDirectory() as directory:
            tool = Path(directory) / "asusctl"
            tool.write_text('#!/bin/sh\nprintf "Active profile: %s\\n\\nAC profile Performance\\nBattery profile Quiet\\n" "$ACTIVE_PROFILE"\n')
            tool.chmod(0o755)
            for active, expected in [("Performance", 0), ("Balanced", 1)]:
                with self.subTest(active=active):
                    result = subprocess.run(
                        ["bash", str(ROOT / "scripts/qs-asus-profile.sh"), "Performance"],
                        env={**os.environ, "PATH": directory + ":" + os.environ["PATH"], "ACTIVE_PROFILE": active},
                        text=True, capture_output=True,
                    )
                    self.assertEqual(result.returncode, expected, result.stderr)


@unittest.skipUnless((os.environ.get("WAYLAND_DISPLAY") or os.environ.get("QT_QPA_PLATFORM") == "offscreen")
                     and shutil.which("quickshell"), "Requires Quickshell and Wayland or QT_QPA_PLATFORM=offscreen")
class PowerUi(unittest.TestCase):
    def test_password_prompt(self):
        with tempfile.TemporaryDirectory(prefix="qs-polkit-test-") as directory:
            config = Path(directory)
            for name in ["PolkitPrompt.qml", "Theme.qml", "colors.json"]:
                shutil.copy(ROOT / name, config / name)
            shutil.copytree(ROOT / "components", config / "components")
            shutil.copy(ROOT / "tests/polkit-ui.qml", config / "shell.qml")
            output = run_ui(config)
            self.assertIn("POLKIT_UI_PASS", output, output)
            self.assertNotIn("POLKIT_UI_FAIL", output, output)

    def test_auth_prompt_lifecycle(self):
        with tempfile.TemporaryDirectory(prefix="qs-auth-test-") as directory:
            config = Path(directory)
            for name in ["PolkitPrompt.qml", "Theme.qml", "colors.json"]:
                shutil.copy(ROOT / name, config / name)
            # Scope.children is append-only; expose objects only in this test copy.
            source = (ROOT / "auth.qml").read_text().replace(
                "id: root", "id: root\n    readonly property alias testAgent: agent\n"
                "    readonly property var testPrompt: promptLoader.item", 1)
            (config / "Auth.qml").write_text(source)
            shutil.copytree(ROOT / "components", config / "components")
            (config / "scripts").mkdir()
            shutil.copy(ROOT / "tests/auth-agent.py", config / "scripts/qs-polkit-agent.py")
            shutil.copy(ROOT / "tests/auth-ui.qml", config / "shell.qml")
            output = run_ui(config)
            self.assertIn("AUTH_UI_PASS", output, output)
            self.assertNotIn("AUTH_UI_FAIL", output, output)

    def test_controls_and_authentication(self):
        with tempfile.TemporaryDirectory(prefix="qs-power-test-") as directory:
            config = Path(directory)
            for name in ["Power.qml", "PowerState.qml", "Theme.qml", "colors.json"]:
                shutil.copy(ROOT / name, config / name)
            shutil.copytree(ROOT / "scripts", config / "scripts")
            shutil.copytree(ROOT / "components", config / "components")
            shutil.copy(ROOT / "tests/power-ui.qml", config / "shell.qml")
            binary = config / "bin"
            binary.mkdir()
            # Only the external commands are replaced; real QML controls and processes run.
            monitors = ([{"name": "eDP-1"}] if os.environ.get("QT_QPA_PLATFORM") == "offscreen"
                        else json.loads(subprocess.check_output(["hyprctl", "-j", "monitors"])))
            fixture = [{"name": m["name"], "width": 1920, "height": 1080,
                        "transform": 0, "refreshRate": 144, "scale": 1,
                        "availableModes": ["1920x1080@144.00Hz", "1920x1080@60.00Hz"]}
                       for m in monitors]
            (config / "monitors.json").write_text(json.dumps(fixture))
            (config / "count").write_text("0")
            tools = {
                "envycontrol": '#!/bin/sh\necho hybrid\n',
                "asusctl": '#!/bin/sh\nif [ "$2" = set ]; then echo "$3" > "$MOCK_CONFIG/profile"; fi\nif [ "$3" = Unavailable ]; then sleep 1; fi\nprintf "Active profile: %s\\n\\nAC profile Performance\\nBattery profile Quiet\\n" "$(cat "$MOCK_CONFIG/profile")"\n',
                "hyprctl": """#!/bin/sh
if [ "$2" = monitors ]; then
    cat "$MOCK_CONFIG/monitors.json"
else
    printf '{"option":"%s","int":0}\\n' "$3"
fi
""",
                "pkexec": '#!/bin/sh\nn=$(cat "$MOCK_CONFIG/count"); n=$((n+1)); echo "$n" > "$MOCK_CONFIG/count"\ncase "$n" in 1) exit 126;; 2) echo "Permission denied" >&2; exit 1;; *) exit 0;; esac\n',
            }
            for name, script in tools.items():
                tool = binary / name
                tool.write_text(script)
                tool.chmod(0o755)
            (config / "profile").write_text("Balanced")
            try:
                output = run_ui(config, PATH=str(binary) + ":" + os.environ["PATH"], MOCK_CONFIG=str(config))
            except subprocess.TimeoutExpired as error:
                output = (error.stdout or b"").decode() + (error.stderr or b"").decode()
            self.assertIn("POWER_UI_PASS", output, output)
            self.assertNotIn("POWER_UI_FAIL", output, output)


if __name__ == "__main__":
    unittest.main()
