#!/usr/bin/env python3
"""Exercise the IPC adapter with fake commands; never desktop IPC or services."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest

REPO = Path(__file__).resolve().parents[2]


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="menu ipc ")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        mock = self.directory / "fake-quickshell"
        mock.write_text('''#!/usr/bin/env python3
import json, os, pathlib, sys, time
with pathlib.Path(os.environ["TEST_CALLS"]).open("a") as log:
    log.write(json.dumps(sys.argv[1:]) + "\\n")
if sys.argv[1] != "ipc":
    sys.exit(99)
if os.environ.get("TEST_HANG"):
    time.sleep(30)
print(os.environ.get("TEST_RESULT", "true"))
sys.exit(int(os.environ.get("TEST_EXIT", "0")))
''')
        mock.chmod(0o700)
        notifier = self.directory / "notify-send"
        notifier.write_text('''#!/usr/bin/env python3
import json, os, pathlib, sys, time
with pathlib.Path(os.environ["TEST_NOTIFY_LOG"]).open("a") as log:
    log.write(json.dumps(sys.argv[1:]) + "\\n")
if os.environ.get("TEST_HANG_NOTIFY"):
    time.sleep(30)
sys.exit(9 if os.environ.get("TEST_FAIL_NOTIFY") else 0)
''')
        notifier.chmod(0o700)
        self.launcher = self.directory / "menu"
        self.launcher.write_text('''#!/usr/bin/env bash
set -euo pipefail
readonly quickshell="$TEST_QS"
readonly shell_config="$TEST_CONFIG"
readonly menu_target="${TEST_MENU_TARGET:-power}"
readonly menu_title="${TEST_MENU_TITLE:-Power menu}"
''' + (REPO / "config/quickshell/open-menu.sh").read_text())
        self.launcher.chmod(0o700)
        self.env = {**os.environ,
                    "PATH": str(self.directory) + os.pathsep + os.environ["PATH"],
                    "TEST_CALLS": str(self.directory / "calls"),
                    "TEST_NOTIFY_LOG": str(self.directory / "notifications"),
                    "TEST_QS": str(mock), "TEST_CONFIG": str(self.directory / "config with spaces")}
        # The adapter no longer needs a runtime directory for a startup lock.
        self.env.pop("XDG_RUNTIME_DIR", None)

    def run_launcher(self, **extra):
        return subprocess.run([str(self.launcher)], env={**self.env, **extra},
                              capture_output=True, text=True, timeout=8)

    def records(self, name):
        path = self.directory / name
        return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

    def assert_failure(self, result, title="Power menu"):
        self.assertEqual(result.returncode, 1)
        self.assertIn(title + " could not open.", result.stderr)
        self.assertEqual(self.records("notifications")[-1],
                         ["--app-name=" + title, "--icon=dialog-error", title + " could not open"])

    def test_each_target_sends_one_ipc_request(self):
        for target, title in [("power", "Power menu"), ("screenshots", "Screenshots")]:
            self.assertEqual(self.run_launcher(TEST_MENU_TARGET=target,
                                              TEST_MENU_TITLE=title).returncode, 0)
            self.assertEqual(self.records("calls")[-1],
                ["ipc", "--path", self.env["TEST_CONFIG"], "call", target, "open"])
        self.assertEqual(len(self.records("calls")), 2)
        self.assertEqual(self.records("notifications"), [])

    def test_failed_ipc_never_attempts_startup(self):
        self.assert_failure(self.run_launcher(TEST_EXIT="7"))
        self.assertEqual(len(self.records("calls")), 1)
        self.assertEqual(self.run_launcher().returncode, 0)

    def test_false_empty_and_invalid_results(self):
        for value in ["false", "", "unexpected"]:
            with self.subTest(value=value):
                self.assert_failure(self.run_launcher(TEST_RESULT=value))
        self.assertEqual(len(self.records("notifications")), 3)

    def test_screenshot_failure_notification(self):
        self.assert_failure(self.run_launcher(TEST_MENU_TARGET="screenshots",
            TEST_MENU_TITLE="Screenshots", TEST_EXIT="1"), "Screenshots")

    def test_request_timeout(self):
        before = time.monotonic()
        self.assert_failure(self.run_launcher(TEST_HANG="1"))
        self.assertLess(time.monotonic() - before, 5)
        self.assertEqual(len(self.records("calls")), 1)

    def test_notification_failure_keeps_failure_result(self):
        result = self.run_launcher(TEST_RESULT="false", TEST_FAIL_NOTIFY="1")
        self.assert_failure(result)
        self.assertIn("Could not deliver the error notification.", result.stderr)

    def test_notification_timeout(self):
        before = time.monotonic()
        self.assert_failure(self.run_launcher(TEST_RESULT="false", TEST_HANG_NOTIFY="1"))
        self.assertLess(time.monotonic() - before, 4)


if __name__ == "__main__":
    unittest.main()
