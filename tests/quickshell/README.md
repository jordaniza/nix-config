# Quickshell tests

These are repository tests: commit this directory with the power-menu implementation.
They exercise production components and scripts, rather than report-only copies.

From the repository root, run the suites with the existing flake's pinned tools:

```sh
nix-shell --impure tests/quickshell/shell.nix --run \
  'python3 tests/quickshell/run.py && python3 tests/quickshell/test_launcher.py && python3 tests/quickshell/test_power_status.py && python3 tests/quickshell/test_screenshot_copy.py && python3 tests/quickshell/test_tmux_status.py'
```

Or enter the environment and run each suite independently:

```sh
nix-shell --impure tests/quickshell/shell.nix
python3 tests/quickshell/run.py
python3 tests/quickshell/test_launcher.py
python3 tests/quickshell/test_power_status.py
python3 tests/quickshell/test_screenshot_copy.py
python3 tests/quickshell/test_tmux_status.py
```

The environment supplies Python, Nix, Bash, coreutils, jq and Qt 6 tools,
including the matching QML import and Qt plugin paths. It reuses `flake.lock` and
the repository's existing machine-ID/impure evaluation. Entering it may fetch or
build test dependencies; it does not activate the desktop configuration.

## Contents and coverage

| File                      | Purpose                                                                                                                                                                     |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tst_power.qml`           | Eight Qt test cases covering action selection, Vim keys, auto-repeat, duplicate dispatch, start/exit failure recovery, invalid inputs, row growth and surface padding       |
| `run.py`                  | Stages declared file/link layout, checks local imports, and runs QtTest plus native Quickshell theme loading offscreen                                                      |
| `tst_theme.qml`           | Instantiates theme components and the production startup configuration reader with Nix-generated synthetic paths                                                            |
| `test_launcher.py`        | Seven cases covering exact IPC routing, failed/false/invalid responses, no startup attempts, request timeout and error notifications, using fake Quickshell and notify-send |
| `test_power_status.py`    | Five cases covering active/inactive state, failed/invalid IPC, timeouts and the user-scoped Waybar refresh signal, using fake Quickshell/pkill                              |
| `tst_screenshots.qml`     | Six cases covering PNG filtering/order, virtualized rows, scrolling/Vim navigation, copy completion/failures, duplicate Enter and empty folders                             |
| `test_screenshot_copy.py` | Four cases verifying exact image bytes/MIME type, missing files, clipboard failures and timeout, with fake wl-copy                                                          |
| `shell.nix`               | Pinned tools and Qt paths for reproducible execution                                                                                                                        |
| `tst_tmux.qml`            | Grouping/window order, literal names, ages, refresh, failed queries, deadlines and read-only scrolling/dismissal with a fake process                                        |
| `test_tmux_status.py`     | Counts and theme colours, menu visibility, IPC failures/timeouts, empty server, query failures/timeouts and user-scoped refresh with fake tmux/Quickshell/pkill             |

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

Theme fixtures use the theme module's actual file declarations, rather than copying
the source directory. Every QML file registered in `qmldir` must be deployed. This
catches a new theme component that exists in the repository but is missing from
Home Manager's install declarations, before Qt starts.

Launcher failures must emit one generic notification per failed invocation and
return failure (exit 1), even if notification delivery fails or times out.
Successful requests emit none. Menu commands must never start Quickshell. These assertions use a fake
`notify-send`; the tests never contact the real notification service.

The native theme check uses the pinned Quickshell binary, an isolated runtime,
cache and state directory, and the offscreen platform. Display, Hyprland and power
command variables are removed; the session-bus address points to an absent socket.
It also reads the generated JSON through the production `StartupConfig.qml`, checking
both command paths and a screenshot directory containing a space and `#`. Package
builders are stubbed during Nix evaluation, so those commands cannot perform host
actions. This exercises Nix JSON generation, deployment and native QML reading.
It never opens the production menu or executes a power action. It catches imports
that exist on disk but leave Quickshell's virtual configuration root. This check
does not exercise the native PanelWindow backend, focus or rendering on Hyprland.

Screenshot fixtures are generated in the temporary test directory. Copy tests never
read or write the live clipboard. After activation, manually verify drawer height,
focus, image preview sizing, and pasting into an application. No performance
benchmark or native Hyprland window acceptance is implied by these tests.

The tmux tests never read the user's sessions or start a server. After activation,
check the Waybar total/attached count, vertical window names, session ages, scrolling
and reopening to refresh. V1 queries only the default local socket; custom sockets
and remote servers are outside its scope. Enter has no action. Counts refresh every
ten seconds; the menu is a snapshot taken when opened.

Automatic tmux focus remains deferred. Once focused, j/k scroll an overflowing list
and q/Escape dismiss. Check the icon's accent/underline on open and removal on close,
including outside-click and switching menus. Total sessions stay white and attached
sessions purple. Offscreen Qt tests cannot validate compositor keyboard ownership.

## Centered controls box

`tst_controls.qml` tests the production content offscreen: keyboard dismissal,
unassigned and modified keys, the mouse Close button, and responsive width limits.
It runs through the existing `run.py` command above. `test_launcher.py` also checks
the controls IPC target and failure notification using fake commands. The native
theme smoke test loads the controls content through the declared deployment.

Use already-installed matching Qt tools when available. Entering the pinned Nix
test shell may fetch/build dependencies and requires the user's explicit delegation.
These tests never contact live desktop IPC or execute power actions.

After rebuilding/applying, manually check Super+Space on each monitor, initial
keyboard focus without a mouse click, q/Escape and mouse dismissal, focus returning
to the previous app, repeated opening without duplicates, outside-click dismissal,
switching between menus, and fitting the smallest display. Exclusive keyboard
focus is enabled only for the visible controls box; the existing menus retain
their OnDemand policy. Offscreen tests cannot verify compositor focus or placement.

### Controls actions

The controls suite now covers all seven letters and matching mouse buttons,
unknown/modified/repeated keys, disabled dispatch, duplicate requests, fake
launch requests, shell quoting, popup switching, failed opening with prior-menu restoration,
failure/retry, and button bounds at each responsive width. It tests the production
controller and shared menu coordinator with fake launch callbacks and fake menus.
The native smoke test checks the complete seven-entry action registry and argument arrays,
including paths containing spaces and #. The existing commands above run this suite.

After applying, manually check each letter and button, keyboard focus handoff to
the popup/terminal, q/Close and outside-click dismissal, reopening after a launch,
and the existing standalone shortcuts. Hyprland dispatch has no application
readiness or exit-status acknowledgement: a terminal that starts successfully can
still fail to run its child tool. Such later failures are outside this suite.
The microphone shortcut is deferred; Volume uses the existing pulsemixer command.

### Controls visual refinement

The existing `run.py` command also checks the controls box's active-focus edge,
button hover edge and inset hotkey, alongside dispatch parity and button bounds
at 960, 922, 656, 640 and 272 logical pixels. The test window is tall enough for
the narrow, single-column fallback. Commands and coordinator behavior are unchanged.
After activation, check the larger centered launcher on each display and scale,
the purple edge while focused, hover feedback, readable labels/keycaps, and
keyboard focus handoff after opening a command. Offscreen Qt cannot establish
Hyprland keyboard ownership or fit on unusually short displays.

### Feature module composition

The existing run.py command evaluates the root Quickshell module through its
feature imports using stubbed builders. It checks all six installed command
packages, stages the declared deployment, and checks the complete generated JSON
through the native loading test. No packages are built. The command-adapter suites
read the relocated production scripts in shared/ and components/<feature>/;
their existing fake commands still prevent live IPC/power/clipboard operations.
Run the same suite commands above after changing module composition or paths.
After activation, manually check existing menu commands and Waybar status updates.

## Floating menus

Run python3 tests/quickshell/test_floating_cycle.py for the production cycle
script with fake hyprctl: visible/hidden/tiled filtering, wraparound, multiple
monitors, pinned and special workspaces, empty candidates and query failures.
The main runner also exercises the shared floating window offscreen, with fake
focus dispatch and no desktop socket. It checks open/refocus, blur retention,
close/reopen and fixed-size constraints.

After user-managed activation, verify Super+F through ordinary floating apps
and Controls/tmux; focused/inactive borders; q/Escape/Close/compositor close;
reopening and center/monitor placement on desktop/laptop. These compositor
behaviors need live acceptance; power/screenshots still dismiss on outside click.
