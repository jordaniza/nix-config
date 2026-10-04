#!/usr/bin/env python3
"""Test the status bridge with fake IPC and pkill; never signal the real bar."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest

REPO = Path(__file__).resolve().parents[2]


class PowerStatusTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="power status ")
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        for name, body in {
            "quickshell": '''assert sys.argv[1:] == ["ipc", "--path", os.environ["TEST_CONFIG"], "prop", "get", "power", "visible"]
if os.environ.get("TEST_HANG"):
    time.sleep(30)
print(os.environ.get("TEST_VISIBLE", "false"))
sys.exit(int(os.environ.get("TEST_EXIT", "0")))
''',
            "pkill": '''pathlib.Path(os.environ["TEST_SIGNAL_LOG"]).write_text(json.dumps(sys.argv[1:]))
sys.exit(1)  # No running Waybar is a valid case.
''',
        }.items():
            path = self.directory / name
            path.write_text("#!/usr/bin/env python3\nimport json, os, pathlib, sys, time\n" + body)
            path.chmod(0o700)
        self.command = self.directory / "power-menu-status"
        self.command.write_text('''#!/usr/bin/env bash
set -euo pipefail
readonly quickshell="$TEST_QS"
readonly shell_config="$TEST_CONFIG"
''' + (REPO / "config/quickshell/power-status.sh").read_text())
        self.command.chmod(0o700)
        self.env = {**os.environ, "PATH": str(self.directory) + os.pathsep + os.environ["PATH"],
                    "TEST_QS": str(self.directory / "quickshell"),
                    "TEST_CONFIG": str(self.directory / "config with spaces"),
                    "TEST_SIGNAL_LOG": str(self.directory / "signals")}

    def status(self, **extra):
        result = subprocess.run([str(self.command)], env={**self.env, **extra},
                                capture_output=True, text=True, timeout=4, check=True)
        return json.loads(result.stdout)

    def test_active(self):
        self.assertEqual(self.status(TEST_VISIBLE="true"), {"text": "power", "class": "active"})

    def test_inactive(self):
        self.assertEqual(self.status(), {"text": "power", "class": ""})

    def test_invalid_or_failed_ipc(self):
        for extra in [{"TEST_VISIBLE": "unexpected"}, {"TEST_VISIBLE": "true", "TEST_EXIT": "1"}]:
            with self.subTest(extra=extra):
                self.assertEqual(self.status(**extra)["class"], "")

    def test_timeout(self):
        before = time.monotonic()
        self.assertEqual(self.status(TEST_HANG="1")["class"], "")
        self.assertLess(time.monotonic() - before, 3)

    def test_refresh_is_user_scoped_and_accepts_no_bar(self):
        result = subprocess.run([str(self.command), "--refresh"], env=self.env,
                                capture_output=True, text=True, timeout=4, check=True)
        self.assertEqual(result.stdout, "")
        self.assertEqual(json.loads((self.directory / "signals").read_text()),
                         ["--signal", "RTMIN+8", "--euid", str(os.geteuid()),
                          "--exact", r"waybar|\.waybar-wrapped"])


if __name__ == "__main__":
    unittest.main()
