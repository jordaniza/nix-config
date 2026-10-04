#!/usr/bin/env python3
"""Run the real Qt components offscreen with a fake process; no power commands."""
import argparse
import json
import os
import re
from pathlib import Path
import shutil
import struct
import zlib
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument("--qmltestrunner", default="qmltestrunner")
parser.add_argument("--quickshell", default="quickshell")
args = parser.parse_args()
repo = Path(__file__).resolve().parents[2]
# Pure evaluation of the existing theme adapter: no Nix build or store output.
expression = '''
let
  files = import %s/config/theme/render.nix {
    pkgs.replaceVars = path: values:
      builtins.replaceStrings
        (map (name: "@" + name + "@") (builtins.attrNames values))
        (map toString (builtins.attrValues values))
        (builtins.readFile path);
  };
in files.quickshell
''' % repo
rendered = json.loads(subprocess.check_output(
    ["nix-instantiate", "--eval", "--strict", "--json", "--expr", expression], text=True))
# Evaluate the module's file declarations without evaluating its packages.
deployment_expression = """
builtins.mapAttrs (_: file: {
  source = toString file.source;
  recursive = file.recursive or false;
}) (import %s/config/quickshell/default.nix {
  config = {}; lib = {}; pkgs = {};
}).xdg.configFile
""" % repo
deployment = json.loads(subprocess.check_output(
    ["nix-instantiate", "--eval", "--strict", "--json", "--expr", deployment_expression],
    text=True))
with tempfile.TemporaryDirectory(prefix="quickshell-test-") as temporary:
    fixture = Path(temporary)
    # Separate source trees reproduce store-backed directory symlink traversal.
    store = fixture / "store"
    store.mkdir()
    for index, (name, entry) in enumerate(deployment.items()):
        source = Path(entry["source"])
        backing = store / str(index)
        target = fixture / "config" / name
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.is_dir():
            shutil.copytree(source, backing)
            if entry["recursive"]:
                target.mkdir()
                for file in backing.rglob("*"):
                    installed = target / file.relative_to(backing)
                    if file.is_dir():
                        installed.mkdir(parents=True, exist_ok=True)
                    else:
                        installed.parent.mkdir(parents=True, exist_ok=True)
                        installed.symlink_to(file)
            else:
                target.symlink_to(backing, target_is_directory=True)
        else:
            shutil.copyfile(source, backing)
            target.symlink_to(backing)
    theme = fixture / "config/theme/quickshell"
    shutil.copytree(repo / "config/theme/quickshell", theme)
    (theme / "Theme.qml").write_text(rendered)
    # Evaluate the theme module's consumer link, retaining its central location.
    alias_expression = """
    (import %s/config/theme/default.nix {
      config = {
        xdg.configHome = %s;
        lib.file.mkOutOfStoreSymlink = path: path;
      };
      lib = {}; pkgs = {};
    }).xdg.configFile."quickshell/theme".source
    """ % (repo, json.dumps(str(fixture / "config")))
    alias_target = json.loads(subprocess.check_output(
        ["nix-instantiate", "--eval", "--strict", "--json", "--expr", alias_expression], text=True))
    (fixture / "config/quickshell/theme").symlink_to(alias_target, target_is_directory=True)
    # Quickshell scans local imports as filesystem paths before Qt loads them.
    for directory, _, filenames in os.walk(fixture / "config/quickshell", followlinks=True):
        for filename in filenames:
            if not filename.endswith(".qml"):
                continue
            qml = Path(directory) / filename
            for relative in re.findall(r'^\s*import\s+"([^"]+)"', qml.read_text(), re.MULTILINE):
                logical_path = Path(os.path.abspath(qml.parent / relative))
                if not logical_path.is_relative_to(fixture / "config/quickshell"):
                    raise SystemExit(f"Import leaves Quickshell root: {relative!r} from {qml.relative_to(fixture)}")
                if not (qml.parent / relative).exists():
                    raise SystemExit(f"Unresolvable import {relative!r} from {qml.relative_to(fixture)}")
    tests = fixture / "tests/quickshell"
    tests.mkdir(parents=True)
    for test_name in ["tst_power.qml", "tst_screenshots.qml"]:
        shutil.copy(repo / "tests/quickshell" / test_name, tests)
    # Small synthetic PNGs and distinct mtimes; never read the user's captures.
    fixtures = tests / "fixtures"
    fixtures.mkdir()
    (tests / "empty-fixtures").mkdir()
    def chunk(kind, data):
        return (struct.pack(">I", len(data)) + kind + data
                + struct.pack(">I", zlib.crc32(kind + data)))
    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(b"\x00\x80\x80\x80")) + chunk(b"IEND", b""))
    for index in range(40):
        name = "newest # &.png" if index == 39 else f"capture-{index:02}.png"
        capture = fixtures / name
        capture.write_bytes(png)
        os.utime(capture, (1700000000 + index, 1700000000 + index))
    (fixtures / "ignore.txt").write_text("Not an image")
    (fixtures / "ignore.png").mkdir()
    runtime = fixture / "runtime"
    runtime.mkdir(mode=0o700)
    env = {**os.environ, "QT_QPA_PLATFORM": "offscreen", "QT_QUICK_BACKEND": "software",
           "QT_QUICK_CONTROLS_STYLE": "Basic", "QT_QPA_PLATFORMTHEME": "",
           "QT_STYLE_OVERRIDE": "", "XDG_RUNTIME_DIR": str(runtime)}
    subprocess.run([args.qmltestrunner, "-input", str(tests)], env=env, check=True)

    # Exercise Quickshell's own import resolver without desktop connections/windows.
    smoke = fixture / "config/quickshell/test_theme.qml"
    shutil.copy(repo / "tests/quickshell/tst_theme.qml", smoke)
    native_env = {**env, "XDG_CACHE_HOME": str(fixture / "cache"),
                  "XDG_STATE_HOME": str(fixture / "state"),
                  "DBUS_SESSION_BUS_ADDRESS": "unix:path=" + str(fixture / "no-bus"),
                  "QS_DISABLE_FILE_WATCHER": "1",
                  "TEST_SCREENSHOT_FOLDER": fixtures.as_uri()}
    for key in ["DISPLAY", "WAYLAND_DISPLAY", "HYPRLAND_INSTANCE_SIGNATURE", "POWER_ACTION", "SCREENSHOT_COPY", "SCREENSHOT_DIRECTORY"]:
        native_env.pop(key, None)
    result = subprocess.run([args.quickshell, "--path", str(smoke), "--no-color"],
                            env=native_env, capture_output=True, text=True, timeout=10)
    output = result.stdout + result.stderr
    if result.returncode != 0 or "THEME_LOAD_OK" not in output or "Failed to load configuration" in output:
        raise SystemExit(output)
    print("PASS: native Quickshell theme loading (offscreen, isolated runtime)")
