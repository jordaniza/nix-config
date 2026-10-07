#!/usr/bin/env python3
"""Exercise the production focus helper without desktop IPC."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / "config/hyprland/scripts/cycle-floating.sh"

class FloatingCycle(unittest.TestCase):
    def run_cycle(self, clients, active=None, monitors=None, fail=""):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            fake = root / "hyprctl"
            fake.write_text("""#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
args=sys.argv[1:]
if args == ["-j", os.environ.get("FAIL_QUERY")]:
    sys.exit(1)
if args[0] == "-j":
    print(os.environ[args[1].upper()])
else:
    Path(os.environ["CALLS"]).write_text(json.dumps(args))
    sys.exit(int(os.environ.get("FAIL_DISPATCH", "0")))
""")
            fake.chmod(0o755)
            env={**os.environ, "PATH":str(root)+os.pathsep+os.environ["PATH"],
                 "CLIENTS":json.dumps(clients), "ACTIVEWINDOW":json.dumps(active or {}),
                 "MONITORS":json.dumps(monitors or [{"id":0,"activeWorkspace":{"id":1},"specialWorkspace":{"id":0}}]),
                 "CALLS":str(root/"calls"), "FAIL_QUERY":fail,
                 "FAIL_DISPATCH":"1" if fail=="dispatch" else "0"}
            result=subprocess.run(["sh",str(SCRIPT)],env=env,capture_output=True,text=True)
            calls=json.loads((root/"calls").read_text()) if (root/"calls").exists() else []
            return result.returncode,calls

    def client(self, address, **changes):
        return {"address":address,"mapped":True,"floating":True,"hidden":False,
                "pinned":False,"workspace":{"id":1},**changes}

    def test_cycle_and_wrap(self):
        a,b=self.client("0xa"),self.client("0xb")
        self.assertEqual(self.run_cycle([a,b],a),(0,["dispatch","focuswindow","address:0xb"]))
        self.assertEqual(self.run_cycle([a,b],b),(0,["dispatch","focuswindow","address:0xa"]))

    def test_excludes_tiled_hidden_unmapped_other_workspace(self):
        windows=[self.client("0xt",floating=False),self.client("0xh",hidden=True),
                 self.client("0xu",mapped=False),self.client("0xo",workspace={"id":4}),
                 self.client("0xa")]
        self.assertEqual(self.run_cycle(windows),(0,["dispatch","focuswindow","address:0xa"]))

    def test_all_visible_monitors_and_special_workspace(self):
        monitors=[{"activeWorkspace":{"id":1},"specialWorkspace":{"id":0}},
                  {"activeWorkspace":{"id":3},"specialWorkspace":{"id":-99}}]
        clients=[self.client("0xa"),self.client("0xb",workspace={"id":3}),
                 self.client("0xc",workspace={"id":-99})]
        self.assertEqual(self.run_cycle(clients,clients[0],monitors)[1][-1],"address:0xb")
        self.assertEqual(self.run_cycle(clients,clients[1],monitors)[1][-1],"address:0xc")

    def test_pinned_and_single_candidate(self):
        pinned=self.client("0xa",pinned=True,workspace={"id":7})
        self.assertEqual(self.run_cycle([pinned],pinned),(0,["dispatch","focuswindow","address:0xa"]))

    def test_empty_candidates_do_nothing(self):
        self.assertEqual(self.run_cycle([]),(0,[]))
        self.assertEqual(self.run_cycle([self.client("0xt",floating=False)]),(0,[]))

    def test_query_failure_does_not_dispatch(self):
        for query in ["monitors","clients","activewindow"]:
            status,calls=self.run_cycle([self.client("0xa")],fail=query)
            self.assertNotEqual(status,0)
            self.assertEqual(calls,[])

    def test_dispatch_failure_is_reported(self):
        status,calls=self.run_cycle([self.client("0xa")],fail="dispatch")
        self.assertNotEqual(status,0)
        self.assertEqual(calls,["dispatch","focuswindow","address:0xa"])

if __name__ == "__main__":
    unittest.main()
