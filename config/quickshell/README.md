# Quickshell menus

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
| `open-menu.sh` | Serialized launch/reuse under a five-second deadline |

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

## Screenshot history

Run `screenshot-history` to open/focus the right-hand drawer on the focused screen.
It spans the available height below Waybar. PNGs in `~/Pictures/Screenshots` appear
newest first by modification time, with previews, filename and modification date.
j/k, arrows and Tab move selection without wrapping; the mouse wheel scrolls.
Enter or a row click copies the image as `image/png`, closing only after the copy
command succeeds. q/Escape and outside-click dismiss. A copy error keeps the drawer
open with a short message. A hung copy command has a three-second deadline.

Qt's FolderListModel reads metadata and tracks directory changes only while the
drawer is open. ListView creates rows near the viewport; previews load
asynchronously at thumbnail size with image caching disabled. Closing destroys
the list/model/previews. There is no index, pagination, custom watcher or daemon.
Opening either menu closes the other. Hotkey assignment remains a follow-up.

Both launcher commands share `open-menu.sh`, one startup lock, and the environment
needed by both menus, so either may start Quickshell first. `shell.qml` reads the
three environment values into one startup object when the shell root is created
and passes them into the menus as properties. Opening the drawer does not reread
the environment. After `nixup`, restart the existing Quickshell instance before
testing `screenshot-history`; changing installed files does not update a running
instance's environment.
