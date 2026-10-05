# Quickshell tests

These are repository tests: commit this directory with the power-menu implementation.
They exercise production components and scripts, rather than report-only copies.

From the repository root, run the suites with the existing flake's pinned tools:

```sh
nix-shell --impure tests/quickshell/shell.nix --run \
  'python3 tests/quickshell/run.py && python3 tests/quickshell/test_launcher.py && python3 tests/quickshell/test_power_status.py && python3 tests/quickshell/test_screenshot_copy.py'
```

Or enter the environment and run each suite independently:

```sh
nix-shell --impure tests/quickshell/shell.nix
python3 tests/quickshell/run.py
python3 tests/quickshell/test_launcher.py
python3 tests/quickshell/test_power_status.py
python3 tests/quickshell/test_screenshot_copy.py
```

The environment supplies Python, Nix, Bash, coreutils and Qt 6 tools,
including the matching QML import and Qt plugin paths. It reuses `flake.lock` and
the repository's existing machine-ID/impure evaluation. Entering it may fetch or
build test dependencies; it does not activate the desktop configuration.

## Contents and coverage

| File | Purpose |
| --- | --- |
| `tst_power.qml` | Eight Qt test cases covering action selection, Vim keys, auto-repeat, duplicate dispatch, start/exit failure recovery, invalid inputs, row growth and surface padding |
| `run.py` | Stages declared file/link layout, checks local imports, and runs QtTest plus native Quickshell theme loading offscreen |
| `tst_theme.qml` | Instantiates all theme component types through Quickshell's import resolver without creating a window |
| `test_launcher.py` | Seven cases covering exact IPC routing, failed/false/invalid responses, no startup attempts, request timeout and error notifications, using fake Quickshell and notify-send |
| `test_power_status.py` | Five cases covering active/inactive state, failed/invalid IPC, timeouts and the user-scoped Waybar refresh signal, using fake Quickshell/pkill |
| `tst_screenshots.qml` | Six cases covering PNG filtering/order, virtualized rows, scrolling/Vim navigation, copy completion/failures, duplicate Enter and empty folders |
| `test_screenshot_copy.py` | Four cases verifying exact image bytes/MIME type, missing files, clipboard failures and timeout, with fake wl-copy |
| `shell.nix` | Pinned tools and Qt paths for reproducible execution |

Each command returns nonzero on failure. QtTest also counts setup and teardown. Failure cases intentionally emit diagnostics while checking recovery. The launcher deadline
case deliberately takes approximately three seconds.

The tests never call shutdown, restart, suspend, lock or live desktop IPC. They
use temporary directories which are removed afterwards; no generated fixtures
or results need committing. Runtime monitor placement, outside-click dismissal,
focus restoration and actual lock/suspend behavior still need deliberate manual
acceptance on the desktop and laptop after activation.

Before QtTest starts, the runner checks every local QML import against the staged
filesystem without collapsing `..` across symlinks. This catches directory links
that redirect imports outside the configuration. Setting either shared/component
directory back to non-recursive deployment makes this check fail.

Launcher failures must emit one generic notification per failed invocation and
return failure (exit 1), even if notification delivery fails or times out.
Successful requests emit none. Menu commands must never start Quickshell. These assertions use a fake
`notify-send`; the tests never contact the real notification service.

The native theme check uses the pinned Quickshell binary, an isolated runtime,
cache and state directory, and the offscreen platform. Display, Hyprland and power
command variables are removed; the session-bus address points to an absent socket.
It never opens the production menu or executes a power action. It catches imports
that exist on disk but leave Quickshell's virtual configuration root. This check
does not exercise the native PanelWindow backend, focus or rendering on Hyprland.

Screenshot fixtures are generated in the temporary test directory. Copy tests never
read or write the live clipboard. After activation, manually verify drawer height,
focus, image preview sizing, and pasting into an application. No performance
benchmark or native Hyprland window acceptance is implied by these tests.
