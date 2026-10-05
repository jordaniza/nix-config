#!/usr/bin/env python3
"""Test counts and menu state with fake tmux/IPC/pkill; no live desktop calls."""
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET

REPO = Path(__file__).resolve().parents[2]


class TmuxStatusTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        expression = '''
        let
          palette = import %s/config/theme/palette.nix;
          files = import %s/config/theme/render.nix {
            pkgs.replaceVars = path: values: builtins.replaceStrings
              (map (name: "@" + name + "@") (builtins.attrNames values))
              (map toString (builtins.attrValues values)) (builtins.readFile path);
          };
        in { format = files.waybarTmuxCounts; inherit (palette) white accent; }
        ''' % (REPO, REPO)
        cls.theme = json.loads(subprocess.check_output(
            ["nix-instantiate", "--eval", "--strict", "--json", "--expr", expression], text=True))

    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="tmux status ")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        scripts = {
            "tmux": '''assert sys.argv[1:] == ["-N", "-u", "-L", "default", "list-sessions", "-F", "#{session_attached}"]
assert "TMUX" not in os.environ
assert os.environ["LC_ALL"] == "C"
if os.environ.get("STALL"): time.sleep(10)
print(os.environ.get("OUTPUT", ""), end="")
sys.exit(int(os.environ.get("CODE", "0")))
''',
            "quickshell": '''assert sys.argv[1:] == ["ipc", "--path", os.environ["TEST_CONFIG"], "prop", "get", "tmux", "visible"]
if os.environ.get("IPC_STALL"): time.sleep(10)
print(os.environ.get("VISIBLE", "false"))
sys.exit(int(os.environ.get("IPC_CODE", "0")))
''',
            "pkill": '''pathlib.Path(os.environ["TEST_SIGNAL_LOG"]).write_text(json.dumps(sys.argv[1:]))
sys.exit(1)  # No running Waybar is valid.
''',
        }
        for name, body in scripts.items():
            path = self.root / name
            path.write_text("#!/usr/bin/env python3\nimport json, os, pathlib, sys, time\n" + body)
            path.chmod(0o700)
        counts = self.root / "counts.txt"
        counts.write_text(self.theme["format"])
        values = {"tmux": self.root / "tmux", "quickshell": self.root / "quickshell",
                  "shell_config": self.root / "config with spaces", "counts_format_file": counts}
        self.command = "\n".join("readonly " + key + "=" + shlex.quote(str(value))
                                 for key, value in values.items())
        self.command += "\n" + (REPO / "config/quickshell/tmux-status.sh").read_text()
        self.env = {**os.environ, "PATH": str(self.root) + os.pathsep + os.environ["PATH"],
                    "TEST_CONFIG": str(values["shell_config"]),
                    "TEST_SIGNAL_LOG": str(self.root / "signals"), "TMUX": "/unwanted/socket,1,0"}

    def status(self, **extra):
        result = subprocess.run(["bash", "-euo", "pipefail", "-c", self.command],
                                env={**self.env, **extra}, capture_output=True, text=True,
                                timeout=6, check=True)
        return json.loads(result.stdout)

    def counts(self, result):
        markup = ET.fromstring("<root>" + result["text"] + "</root>")
        self.assertEqual(markup[0].attrib["foreground"], "#" + self.theme["white"])
        self.assertEqual(markup[1].attrib["foreground"], "#" + self.theme["accent"])
        return "".join(markup.itertext())

    def test_counts_sessions_not_clients_and_colors(self):
        result = self.status(OUTPUT="0\n3\n1\n0\n")
        self.assertEqual(self.counts(result), "tmux: 4 sessions · 2 attached")
        self.assertEqual(result["class"], ["attached"])

    def test_detached(self):
        self.assertEqual(self.counts(self.status(OUTPUT="0\n0\n")), "tmux: 2 sessions · 0 attached")

    def test_no_server(self):
        for message in ["no server running on /synthetic/default\n",
                        "error connecting to /synthetic/default (No such file or directory)\n"]:
            self.assertEqual(self.counts(self.status(OUTPUT=message, CODE="1")), "tmux: 0 sessions · 0 attached")

    def test_errors_do_not_claim_zero(self):
        for output, code in [("permission denied", "1"), ("invalid", "0")]:
            result = self.status(OUTPUT=output, CODE=code, VISIBLE="true")
            self.assertEqual(result["text"], "—")
            self.assertEqual(result["class"], ["error", "active"])

    def test_timeout(self):
        self.assertEqual(self.status(STALL="1")["class"], ["error"])

    def test_open_then_closed_keeps_counts(self):
        for visible, classes in [("true", ["attached", "active"]), ("false", ["attached"])]:
            result = self.status(OUTPUT="2\n0\n", VISIBLE=visible)
            self.assertEqual(self.counts(result), "tmux: 2 sessions · 1 attached")
            self.assertEqual(result["class"], classes)

    def test_invalid_failed_or_timed_out_ipc_keeps_counts(self):
        for extra in [{"VISIBLE": "unexpected"}, {"VISIBLE": "true", "IPC_CODE": "1"}, {"IPC_STALL": "1"}]:
            result = self.status(OUTPUT="1\n", **extra)
            self.assertEqual(self.counts(result), "tmux: 1 session · 1 attached")
            self.assertEqual(result["class"], ["attached"])

    def test_refresh_is_user_scoped_and_accepts_no_bar(self):
        result = subprocess.run(["bash", "-euo", "pipefail", "-c", self.command, "tmux-status", "--refresh"],
                                env=self.env, capture_output=True, text=True, timeout=3, check=True)
        self.assertEqual(result.stdout, "")
        self.assertEqual(json.loads((self.root / "signals").read_text()),
                         ["--signal", "RTMIN+9", "--euid", str(os.geteuid()),
                          "--exact", r"waybar|\.waybar-wrapped"])


if __name__ == "__main__":
    unittest.main()
