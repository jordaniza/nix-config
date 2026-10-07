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

| Path                                   | Responsibility                                                 |
| -------------------------------------- | -------------------------------------------------------------- |
| `shell.qml`                            | Compose components and expose IPC                              |
| `components/power/PowerMenu.qml`       | Assemble the power UI and wire events                          |
| `components/power/PowerController.qml` | Actions, request state and errors                              |
| `shared/PopupWindow.qml`               | Monitor selection, placement, focus and dismissal              |
| `shared/ActionList.qml`                | Selection and activation                                       |
| `shared/VimNavigation.js`              | Keyboard navigation                                            |
| `shared/CommandRunner.qml`             | Process lifecycle                                              |
| `shared/open-menu.sh`                    | Bounded IPC request and failure notification                   |
| `shared/default.nix`                     | Shared menu command builder                                    |
| `components/power/default.nix`           | Power action/menu/status packages and JSON setting             |
| `components/screenshots/default.nix`     | Screenshot menu/copy packages and JSON settings                |
| `components/tmux/default.nix`            | tmux menu/status packages and JSON setting                     |
| `components/controls/default.nix`        | Controls command and complete leader-action registry           |
| `default.nix`                            | Compose feature exports, managed service and deployment        |
| `shared/StartupConfig.qml`             | Read generated `config.json` at startup                        |

`~/.config/quickshell/` contains behavior; `~/.config/theme/quickshell/` contains
appearance. The theme module provides a `quickshell/theme` link to that central
directory. QML imports use this link to stay inside Quickshell's configuration
root. Home Manager installs `shared/` and `components/` with
`recursive = true`, creating directories with individual file symlinks so `..`
imports stay within the installed configuration tree. Edit appearance in
`config/theme/quickshell/`.

Each feature's default.nix exports `packages`, `settings`, and optional
`statusPackages`. The root combines them into home.packages, config.json and the
service PATH. Feature scripts stay beside their QML: power-status.sh in power/,
copy-screenshot.sh in screenshots/, and tmux-status.sh in tmux/. The common
IPC opener lives in shared/ and is used by all four menu commands.

## Service lifecycle

Hyprland's login hook imports its display/session environment into the user
systemd manager, then restarts `quickshell.service`. Its logout hook stops the
service. This configuration does not currently use a systemd desktop-session
target, so the service has no automatic WantedBy target. Home Manager supplies
`Restart=on-failure`; retries wait two seconds and are limited to three starts in
30 seconds. An intentional service stop stays stopped. A compositor crash may
bypass the logout hook; display failures can then exhaust the restart limit.

Nix generates `~/.config/quickshell/config.json` with the power action command,
screenshot copy command, screenshot directory and tmux executable. `StartupConfig.qml` reads it
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
Opening any menu closes the others. Super+P opens power; Super+Shift+V opens screenshots.

The service still inherits the display/session environment and supplies PATH for
the Waybar status helper. Application command paths and the screenshot directory
come from the generated JSON; themes remain under `config/theme/`.

## tmux viewer

`tmux-menu` opens a centered, read-only floating session board, matching
Controls' width and normal height. A header gives session/attached counts and
Close; responsive cards show window counts, creation ages and indexed names. A purple filled circle
means attached; a muted hollow circle means detached. Session names are omitted.
Attached sessions come first, then oldest first; windows retain tmux index order.
j/k and arrows scroll, q/Escape closes. Enter has no action in this version.

Opening takes one snapshot with a direct Quickshell Process call to tmux.
Only the local default socket is queried, with server startup disabled. No session,
window or pane is created, attached, switched or closed. Linked windows appear
under each session containing them. Reopen to refresh; there is no menu polling.

Waybar uses `tmux-status` every ten seconds and displays total/attached sessions
beside the icon, for example `tmux: 4 sessions · 2 attached`. A session with several clients counts once.
Click or Super+Ctrl+T opens `tmux-menu` through the existing IPC launcher.
Super+T and Super+Shift+T retain their terminal bindings.
An absent server shows `tmux: 0 sessions · 0 attached` and an empty list. Other query failures show an unknown
count or a short menu error. Queries have bounded deadlines. Control characters in
window names display as spaces; long names elide at the right edge.

Waybar shows total sessions in white and attached sessions in the accent colour;
the count markup lives in `config/theme/waybar-tmux-counts.txt.in` and uses the shared
palette. The icon itself gains accent colour and the workspace-style underline
while the menu is open. Visibility changes signal the tmux module with RTMIN+9;
the existing ten-second refresh also clears stale state after a shell crash.

## Leader controls

Super+Space opens the centered Controls menu on the focused monitor. Press a
letter or click the matching button: p Power, t tmux, s Screenshots, c Clipboard,
b Bluetooth, i Internet/network, v Volume. q, Escape or the top-right Close button
dismisses. Unassigned keys do nothing and automatic repeat does not launch actions.
There is no navigation step. Microphone is deferred; Volume opens normal pulsemixer.

Power, tmux and screenshot history use the existing in-process menu instances.
`shared/MenuCoordinator.qml` applies the same switching policy to both leader
actions and standalone IPC requests, restoring the previous popup if opening
fails. `components/controls/ControlsController.qml` owns dispatch and duplicate
suppression. The authoritative seven-entry `controlsActions` list in components/controls/default.nix
defines each key, label and popup target or external command. Both the rendered
buttons and dispatch consume that same list through generated config.json. QML
contains only the popup-instance wiring, with no second list of leader letters.
External command argument arrays come from that registry,
with absolute executable paths. Each argument is shell-quoted before Hyprland's
exec dispatcher launches it, matching the existing keybindings' application owner
rather than parenting terminals under the Quickshell service. Clipboard retains the
existing cq-picker class, title and Kitty key overrides; Bluetooth, network and
volume retain their existing window titles. Quickshell closes Controls before requesting a terminal launch through Hyprland.

Theme-owned ControlsSurface renders the responsive button grid and errors.
The duplicate bottom-left close hint is removed. Dispatcher requests cannot
confirm tool readiness or later failures; native launch/focus needs manual checks.
Rebuild/apply through the normal user workflow and restart quickshell.service.

## Floating Controls and tmux

Controls and tmux use shared/FloatingMenuWindow.qml. They are ordinary floating
clients, centered on the focused monitor, with the central Hyprland theme's
focused/inactive border. Opening or explicitly reopening requests focus; blur
and outside clicks leave them visible. q/Escape, Close or the compositor close
binding dismiss them. Opening another Quickshell menu still replaces the current
menu. Power and screenshots retain their existing layer-shell popup behavior.

Super+F cycles mapped, non-hidden floating clients on visible workspaces across
monitors, including pinned windows. It wraps in client-list order, starts at the
first candidate when the active window is tiled/absent, and does nothing when
none qualify. The helper queries current state and focuses an address without
changing workspace or floating state. Hyprland 0.55 ignores cyclenext's visible
argument, so the helper filters explicitly. It saves no window payloads.

Tmux now uses a header, Close button and responsive session cards: up to three
columns, with one/two sessions filling the available columns. Attached state,
window count, creation age and literal indexed names remain read-only. Additional
rows or long window lists scroll. Query/socket/deadline behavior is unchanged.
LauncherAppearance shares only width constraints with Controls. All appearance
remains in config/theme/quickshell; future floating menus reuse the shared base.
