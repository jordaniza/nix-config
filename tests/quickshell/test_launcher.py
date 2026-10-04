#!/usr/bin/env python3
"""Exercise the real launcher with a fake Quickshell, never desktop IPC."""
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
        self.temporary = tempfile.TemporaryDirectory(prefix="power launcher ")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        mock = self.directory / "fake-quickshell"
        mock.write_text('''#!/usr/bin/env python3
import os, pathlib, sys, time
runtime = pathlib.Path(os.environ["XDG_RUNTIME_DIR"])
for fd in pathlib.Path("/proc/self/fd").iterdir():
    try:
        assert not os.readlink(fd).endswith("power.lock"), "Inherited lock"
    except FileNotFoundError:
        pass
with (runtime / "calls").open("a") as log:
    log.write(" ".join(sys.argv[1:]) + "\\n")
if sys.argv[1] == "ipc":
    if os.environ.get("TEST_HANG"):
        time.sleep(30)
    if not (runtime / "ready").exists():
        sys.exit(1)
    print("false" if os.environ.get("TEST_REJECT_OPEN") else "true")
else:
    if os.environ.get("TEST_FAIL_START"):
        sys.exit(7)
    time.sleep(0.05)
    (runtime / "ready").touch()
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
        self.launcher = self.directory / "power-menu"
        self.launcher.write_text('''#!/usr/bin/env bash
set -euo pipefail
readonly quickshell="$TEST_QS"
readonly shell_config="$TEST_CONFIG"
''' + (REPO / "config/quickshell/open-power.sh").read_text())
        self.launcher.chmod(0o700)
        self.env = {**os.environ, "XDG_RUNTIME_DIR": str(self.directory),
                    "PATH": str(self.directory) + os.pathsep + os.environ["PATH"],
                    "TEST_NOTIFY_LOG": str(self.directory / "notifications"),
                    "TEST_QS": str(mock), "TEST_CONFIG": str(self.directory / "config with spaces")}

    def run_launcher(self, **extra):
        return subprocess.run([str(self.launcher)], env={**self.env, **extra},
                              capture_output=True, text=True, timeout=8)

    def notifications(self):
        path = self.directory / "notifications"
        return [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []

    def assert_failure_notification(self):
        self.assertEqual(self.notifications(), [["--app-name=Power menu", "--icon=dialog-error",
                                                "Power menu could not open"]])

    def launches(self):
        return (self.directory / "calls").read_text().count("--daemonize")

    def test_initial_start_and_reuse(self):
        self.assertEqual(self.run_launcher().returncode, 0)
        self.assertEqual(self.run_launcher().returncode, 0)
        self.assertEqual(self.launches(), 1)
        self.assertEqual(self.notifications(), [])

    def test_concurrent_requests(self):
        processes = [subprocess.Popen([str(self.launcher)], env=self.env,
                     stdout=subprocess.PIPE, stderr=subprocess.PIPE) for _ in range(4)]
        for process in processes:
            process.communicate(timeout=8)
            self.assertEqual(process.returncode, 0)
        self.assertEqual(self.launches(), 1)
        self.assertEqual(self.notifications(), [])

    def test_failed_start_and_retry(self):
        self.assertEqual(self.run_launcher(TEST_FAIL_START="1").returncode, 7)
        self.assert_failure_notification()
        self.assertEqual(self.run_launcher().returncode, 0)

    def test_false_ipc_result_is_failure(self):
        self.assertEqual(self.run_launcher(TEST_REJECT_OPEN="1").returncode, 1)
        self.assert_failure_notification()

    def test_whole_request_deadline(self):
        before = time.monotonic()
        self.assertEqual(self.run_launcher(TEST_HANG="1").returncode, 124)
        self.assert_failure_notification()
        self.assertLess(time.monotonic() - before, 7.5)
        # The timeout must release the lock so a later attempt can succeed.
        self.assertEqual(self.run_launcher().returncode, 0)

    def test_missing_runtime_directory(self):
        self.assertNotEqual(self.run_launcher(XDG_RUNTIME_DIR="").returncode, 0)
        self.assert_failure_notification()

    def test_notification_failure_preserves_exit_status(self):
        self.assertEqual(self.run_launcher(TEST_FAIL_START="1", TEST_FAIL_NOTIFY="1").returncode, 7)
        self.assert_failure_notification()

    def test_notification_timeout_preserves_exit_status(self):
        before = time.monotonic()
        self.assertEqual(self.run_launcher(TEST_FAIL_START="1", TEST_HANG_NOTIFY="1").returncode, 7)
        self.assertLess(time.monotonic() - before, 4)
        self.assert_failure_notification()


if __name__ == "__main__":
    unittest.main()
