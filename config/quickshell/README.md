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
| `open-menu.sh` | Bounded IPC request and failure notification |
| `default.nix` | Managed service, generated configuration and packaged commands |
| `shared/StartupConfig.qml` | Read generated `config.json` at startup |

`~/.config/quickshell/` contains behavior; `~/.config/theme/quickshell/` contains
appearance. The theme module provides a `quickshell/theme` link to that central
directory. QML imports use this link to stay inside Quickshell's configuration
root. Home Manager installs `shared/` and `components/` with
`recursive = true`, creating directories with individual file symlinks so `..`
imports stay within the installed configuration tree. Edit appearance in
`config/theme/quickshell/`.

## Service lifecycle

Hyprland's login hook imports its display/session environment into the user
systemd manager, then restarts `quickshell.service`. Its logout hook stops the
service. This configuration does not currently use a systemd desktop-session
target, so the service has no automatic WantedBy target. Home Manager supplies
`Restart=on-failure`; retries wait two seconds and are limited to three starts in
30 seconds. An intentional service stop stays stopped. A compositor crash may
bypass the logout hook; display failures can then exhaust the restart limit.

Nix generates `~/.config/quickshell/config.json` with the power action command,
screenshot copy command and screenshot directory. `StartupConfig.qml` reads it
at shell startup and passes the values to the menus. File watching is disabled;
restart Quickshell after activation to use new values. Edit the Nix declaration,
not the generated file. Read/parse errors appear in the journal. Menu commands send one IPC request,
with a three-second deadline and one-second kill grace. They never start or
restart Quickshell. Failures, including a QML `false` response, return exit 1 and
send a bounded error notification.

After `nixup`, restart the running shell with
`systemctl --user restart quickshell.service`. Future logins start it automatically.

## Debugging

Launcher failures send “Power menu could not open” through notify-send. Delivery
has a two-second timeout plus a one-second forced-kill grace; it preserves the
failure result (exit 1). Action failures appear in the popup. QML errors, action exit codes and action
stderr go to Quickshell's logs. Read the running instance's recent messages:

```sh
systemctl --user status quickshell.service
journalctl --user -u quickshell.service -n 100
```

Use `journalctl --user -u quickshell.service -f` to follow messages.
After fixing a startup failure that hit the retry limit, run
`systemctl --user reset-failed quickshell.service`, then restart the service. Opening without an identifiable
monitor returns failure and logs the reason.

## Tests and follow-up

See [tests/quickshell/README.md](../../tests/quickshell/README.md) for the commands
and coverage. Hyprland focus, monitor placement and actual lock/suspend behavior
need manual acceptance after build/activation.

TODO: cancellable restart/shutdown countdown with Cancel and
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
Opening either menu closes the other. Super+P opens power; Super+Shift+V opens screenshots.

The service still inherits the display/session environment and supplies PATH for
the Waybar status helper. Application command paths and the screenshot directory
come from the generated JSON; themes remain under `config/theme/`.
