# Power menu

`power-menu` opens/focuses the top-right popup on the focused monitor.
If focus information is unavailable, a single connected screen is accepted.
Waybar uses this command on both machines.

Lock starts selected. j/k, arrows and Tab/Shift+Tab move selection; Enter or a row
click executes immediately. q/Escape and outside-click dismiss.
Lock uses loginctl → hypridle → Hyprlock; suspend retains before-sleep locking.
The menu can reopen during dispatch, but further execution waits for completion.
Closing hides the menu; the Quickshell process stays alive.

Waybar's power icon uses the workspace accent and a 2px underline while the menu
is visible. Visibility changes refresh custom signal 8 on the current user's
Waybar processes, including keyboard opens and all normal close paths.
`power-menu-status` reads the IPC visibility property and returns Waybar JSON;
unavailable, timed-out or invalid responses show the inactive style. Waybar reads
the state at startup and on these signals. After an abrupt Quickshell crash, the
last icon state remains until the next refresh or Waybar reload.

## Structure

| Path | Responsibility |
| --- | --- |
| `shell.qml` | Compose components and expose IPC |
| `components/power/PowerMenu.qml` | Assemble the power UI and wire events |
| `components/power/PowerController.qml` | Actions, request state and errors |
| `shared/PopupWindow.qml` | Monitor selection, placement, focus and dismissal |
| `shared/ActionList.qml` | Selection and activation |
| `shared/VimNavigation.js` | Keyboard navigation |
| `shared/CommandRunner.qml` | Process lifecycle |
| `open-power.sh` | Serialized launch/reuse under a five-second deadline |

`~/.config/quickshell/` contains behavior; `~/.config/theme/quickshell/` contains
appearance. The theme module provides a `quickshell/theme` link to that central
directory. QML imports use this link to stay inside Quickshell's configuration
root. Home Manager installs `shared/` and `components/` with
`recursive = true`, creating directories with individual file symlinks so `..`
imports stay within the installed configuration tree. Edit appearance in
`config/theme/quickshell/`.

The launcher uses flock's command mode. Its five-second deadline includes lock
waiting, startup and IPC, with a one-second forced-kill grace. A timed-out detached
instance may finish starting hidden and be reused on the next invocation.

## Debugging

Launcher failures send “Power menu could not open” through notify-send. Delivery
has a two-second timeout plus a one-second forced-kill grace; it preserves the
original failure status. Action failures appear in the popup. QML errors, action exit codes and action
stderr go to Quickshell's logs. Read the running instance's recent messages:

```sh
quickshell log --path "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell" --tail 100
```

Add `--follow` to watch new messages. If startup fails, run `power-menu` in a
terminal to see its startup/IPC diagnostics. Opening without an identifiable
monitor returns failure and logs the reason.

## Tests and follow-up

See [tests/quickshell/README.md](../../tests/quickshell/README.md) for the commands
and coverage. Hyprland focus, monitor placement and actual lock/suspend behavior
need manual acceptance after build/activation.

TODO: hotkey assignment; cancellable restart/shutdown countdown with Cancel and
Run now. Restart/shutdown currently execute immediately.
