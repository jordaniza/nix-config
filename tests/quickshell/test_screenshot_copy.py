#!/usr/bin/env python3
"""Exercise the production copy adapter with a fake wl-copy; no live clipboard."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]


class CopyTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="screenshot copy ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.capture = self.root / "capture # & ' .png"
        self.payload = b"\x89PNG\r\n\x1a\n\x00synthetic\xff"
        self.capture.write_bytes(self.payload)
        copier = self.root / "wl-copy"
        copier.write_text('''#!/usr/bin/env python3
import json, os, pathlib, sys, time
root = pathlib.Path(os.environ["TEST_COPY_ROOT"])
(root / "arguments").write_text(json.dumps(sys.argv[1:]))
(root / "payload").write_bytes(sys.stdin.buffer.read())
if os.environ.get("TEST_HANG"):
    time.sleep(30)
sys.exit(int(os.environ.get("TEST_EXIT", "0")))
''')
        copier.chmod(0o700)
        self.env = {**os.environ, "TEST_COPY_ROOT": str(self.root),
                    "PATH": str(self.root) + os.pathsep + os.environ["PATH"]}

    def copy(self, path, **extra):
        return subprocess.run(["bash", "-euo", "pipefail",
            str(REPO / "config/quickshell/components/screenshots/copy-screenshot.sh"), str(path)],
            env={**self.env, **extra}, capture_output=True, timeout=6)

    def test_image_bytes_and_mime_type(self):
        self.assertEqual(self.copy(self.capture).returncode, 0)
        self.assertEqual((self.root / "payload").read_bytes(), self.payload)
        self.assertEqual(json.loads((self.root / "arguments").read_text()),
                         ["--type", "image/png"])

    def test_missing_file_does_not_touch_clipboard(self):
        self.assertNotEqual(self.copy(self.root / "missing.png").returncode, 0)
        self.assertFalse((self.root / "arguments").exists())

    def test_clipboard_failure_is_reported(self):
        self.assertEqual(self.copy(self.capture, TEST_EXIT="9").returncode, 9)

    def test_hung_clipboard_is_bounded(self):
        self.assertEqual(self.copy(self.capture, TEST_HANG="1").returncode, 124)


if __name__ == "__main__":
    unittest.main()
