# NixOS configuration

The implementation backlog is in [TODO.md](TODO.md). The notes below record actual desktop troubleshooting results; they are not authorization to apply every workaround on every machine.

## Known desktop issues and fixes

Notes updated: **2026-09-29**. Verification dates and limitations are recorded per issue; this is not a fresh validation of the whole desktop. Desktop observations unless stated otherwise. Preserve the working baseline while watching for recurrence after ordinary use, suspend/resume and reboot.

### Start with service masks and actual capabilities

Before changing packages or application settings, inspect persistent user/system overrides:

```sh
systemctl --user list-unit-files --state=masked,masked-runtime
systemctl list-unit-files --state=masked,masked-runtime
systemctl --user status xdg-desktop-portal.service xdg-desktop-portal-gtk.service xdg-desktop-portal-hyprland.service
journalctl --user -b -u xdg-desktop-portal.service --no-pager
```

A service definition symlinked to `/dev/null` is a systemd **mask**: starting that service is forbidden. It is not output redirection. A mask under `~/.config/systemd/user/` survives reboot and can override the service supplied by NixOS. Some masks are intentional; investigate relevant ones, never blanket-unmask them.

Also check the required API, not just whether a process is running. For external application opening:

```sh
busctl --user get-property org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.OpenURI version
```

After the repair below OpenURI advertised interface version 5. A future version may differ; successful interface access and a real handoff are the important checks.

### Confirmed fix: Brave could not hand off Slack sign-in

- **Symptom:** Brave displayed its external-application permission prompt, but approving it did nothing. Terminal `xdg-open 'slack://'` and a separate `gio open` test could launch Slack.
- **Cause demonstrated:** `~/.config/systemd/user/xdg-desktop-portal-gtk.service` was a symlink to `/dev/null`. The GTK backend was masked/inactive. The main portal and Hyprland backend were running, but the main portal lacked OpenURI, FileChooser and Settings. Logs reported failure to create the GTK application-chooser proxy.
- **Architecture:** the installed configuration prefers `hyprland;gtk` per capability. Hyprland handles supported capture/shortcut functions; GTK supplies other capabilities, including the AppChooser backend used by the main portal's OpenURI interface. Keeping this GTK backend does not mean running the GNOME desktop.
- **Evidence:** a token-free local HTML link (`<a href="slack://">Open Slack</a>`) reproduced the failure without authentication. A D-Bus metadata trace captured Brave calling OpenURI and receiving an immediate error. Restoring the backend made the test link and actual Slack browser sign-in work.

The repair performed, recorded for reference rather than automatic execution:

```sh
systemctl --user unmask xdg-desktop-portal-gtk.service
systemctl --user start xdg-desktop-portal-gtk.service
systemctl --user restart xdg-desktop-portal.service
```

This removed the user-level mask; it did not replace it with another redirect. Both services became active and OpenURI appeared. Portal restarts can interrupt screen sharing. No Nix rebuild, Slack reinstall, MIME change or graphics change was needed. The mask's creator is unknown; no recreating instruction was found in the configuration files searched. Its removal persists unless something recreates it.

**Update hypothesis, not proven version regression:** [Chromium changed Linux external opening to prefer portals on 2026-03-24](https://chromium.googlesource.com/chromium/src/+/d77f8537054f74f8212f9e468d4b5035127d7fde). A Brave update could have exposed the existing mask. Why the browser's intended `xdg-open` fallback did not rescue this launch was not established.

### Working graphics baseline: RX580 and Brave

- Observed stack: NixOS 25.05, kernel 6.12.50, Mesa 25.0.7, Hyprland 0.49.0 and Brave 1.93.138. These are historical test versions, not recommended upgrade targets.
- Desktop GPUs: Radeon RX580 at PCI `0000:01:00.0` and the Ryzen 9 7950X integrated Radeon at `0000:11:00.0`. Earlier diagnostics observed the monitor on integrated-GPU `DP-4`; that historical observation does not establish the current connection.
- Native Wayland Brave with the RX580 explicitly selected reproduced severe visual corruption/freezing. The confirmed RX580 under **XWayland** rendered smoothly with hardware acceleration and survived short and overnight suspend tests.
- Preserve `--ozone-platform=x11 --gtk-version=3` in [config/brave/default.nix](config/brave/default.nix). This runs Brave through XWayland inside Hyprland, not a separate X11 desktop. The desktop wrapper selects the GPU defined in [hardware/desktop.nix](hardware/desktop.nix); laptop selection remains automatic. A missing or unreadable desktop render node prevents launch and prints an error to stderr, without a notification popup.
- Brave uses the separate `brave-nixpkgs` pin for 1.93.138. Downgrading to base `pkgs.brave` 1.82.172 caused immediate SIGTRAP crashes with the existing profile, including with extensions disabled; an empty temporary profile stayed open with the same GPU wrapper. Profile downgrade incompatibility is the leading explanation, not a confirmed failing component. The user reports the GPU working well on September 29; the exact launch/profile/renderer validation matrix was not recorded with that report. Configuration changes alone do not activate this setup.
- For a controlled desktop-only comparison, after confirming the PCI mapping and render-node path exists, the following previously worked. Fully quit Brave through its UI first so the launch is not absorbed by an existing instance. It uses the normal `Default` profile; do not run it automatically or on the laptop.

```sh
DRI_PRIME=pci-0000_01_00_0 brave \
  --profile-directory=Default \
  --ozone-platform=x11 \
  --gtk-version=3 \
  --render-node-override=/dev/dri/by-path/pci-0000:01:00.0-render
```

Verify `GL_RENDERER` in `brave://gpu`: it must name **Radeon RX 580**, not Ryzen 9 7950X, for an RX580 test. Recheck after suspend; do not infer GPU switching without comparing renderer reports. Prefer verified PCI/by-path mappings over assuming `renderD128` always identifies the same GPU.

Other observations to keep separate:

- GTK 3 launch selection worked around the earlier Brave startup failure. A missing GTK 4 Adwaita-dark CSS import was real, but was not proven to be the cause of every crash. The installed GTK portal uses **GTK 3**; masking it is not a GTK 4 theme repair.
- Native Wayland also produced the fatal message `Custom primaries aren't supported`. Disabling `WaylandWpColorManagerV1` allowed that test to start, but did not fix RX580 native-Wayland corruption. It is not a necessary addition to the working XWayland baseline.
- One separate suspend attempt produced RX580 UVD initialization timeouts and runtime-power-management `error`; reboot cleared that state. Later successful tests do not close the PM issue or certify the hardware. Cross-GPU transfer/synchronization remains a hypothesis, not a demonstrated root cause.
- Do not reintroduce `--use-fake-ui-for-media-stream`, disable GPU acceleration globally, or combine a graphics upgrade, GPU routing change and compositor migration in one experiment.

### GPU status and recurrence watch: 2026-09-29

**Current status:** the user reports the GPU is working well. Desktop Brave GPU selection is implemented in the wrapper and hardware configuration above; keep the working XWayland/GTK 3 settings. Former TODO items 18–19 are no longer active implementation/diagnostic tasks.

The earlier native-Wayland corruption and RX580 runtime-PM/UVD failure remain historical evidence, not a claim of a currently broken GPU. No new root cause or comprehensive suspend/laptop validation was established by the current report.

If a graphics or suspend symptom returns, record the time, actual renderer, connector/GPU ownership, runtime-PM state and relevant kernel logs before changing settings. Use the prior mixed evidence (one failed cycle and later successful cycles, including overnight) to choose one discriminating comparison. Idle versus active-browser suspend, scoped runtime-autosuspend behaviour and monitor routing are possible comparisons, not a standing instruction to run all of them. Keep graphics updates, GPU routing changes and compositor migration separate; preserve the working XWayland path and avoid broad AMD flags or hardware conclusions without evidence.

### Intermittent symptoms: currently working, not established fixes

- **Brave microphone investigation, updated 2026-09-17:** start with the [canonical evidence, app grid and experiment ledger](investigations/brave-audio/README.md). A September 10 trace measured per-stream burst delivery and dropped audio before browser speech processing. The originating server/client fault remains unresolved. This later evidence and the September 17 old-tab/new-tab observations supersede generic microphone troubleshooting as the default next step.
- **Clipboard:** the earlier Slack freeze/crash report and the September 29 XWayland → Wayland delivery failure remain unresolved known issues, currently on recurrence watch. See the [clipboard evidence and recurrence guidance below](#clipboard-boundary-failure-2026-09-29); the portal repair and new picker shortcuts are not established fixes for either symptom.
- **Microphone/dictation:** ChatGPT dictation worked during testing, and Brave had an active, unmuted input stream from the default Samson G-Track Pro. Earlier reports involved microphone loss after a period of use in calls and ChatGPT. Current success is not proof of long-term reliability or a portal-related cause.
- **Screen sharing:** the GTK backend repair may affect supporting dialogs, but no before/after test proved that it fixed sharing, freezes or echo. The Hyprland capture backend was already running.

If one recurs, note the time, app, action, selected devices and whether the machine recently resumed. Where practical, inspect the broken state before restarting or changing routing. For audio, `wpctl status` shows streams and connected devices without recording sound. Use non-sensitive synthetic content for clipboard tests. Do not collect actual clipboard history, login callback URLs, private recordings or full browser profiles.

### Clipboard boundary failure: 2026-09-29

**Known issue, recovered but not fixed.** This section now owns former TODO item 21. Active diagnostics are paused until recurrence; the clipboard picker improvements do not establish a bridge repair.

The [clipboard investigation progression and evidence ledger](investigations/clipboard/README.md) records the ordered tests, hypotheses, decision branches, and acceptance criteria. On recurrence, capture the failing boundary before restarting applications or the desktop. Exiting Hyprland ends the session and closes its applications; it is not a way to preserve and return to the old session.

- **Separate earlier Slack freeze/crash report:** copying from Slack and pasting into another application was reported to freeze/crash an app, but the symptom was not reproducible during diagnosis. Slack and Brave were XWayland clients, Kitty/Telegram native Wayland, and CopyQ was running. No matching recent crash dump, OOM kill or clipboard-transfer error was found. If this symptom returns, identify the affected process and destination before testing synthetic plain versus rich content and backend differences. Do not conflate it with the timed-out delivery below or with Slack sign-in. Closure needs repeated successful pastes without hangs/crashes, including after suspend.

- **User reproduction:** Brave ↔ Slack copying works; Firefox/terminal copying works; Slack → Firefox or terminal fails, as does Brave → the external clipboard. The later synthetic reverse control, Firefox → Brave with `CB-WL-01`, succeeded. The observed failure is XWayland → Wayland only. No freeze/crash was confirmed in this recurrence.
- **Correlated synthetic capture:** after copying `CB-X11-01` from Brave, Firefox pasted nothing. X11 owner changes coincided with new Wayland text offers. A standard `xclip` read returned the exact marker in 0.003 s, while `wl-paste` requesting UTF-8 plain text timed out after five seconds. This locates the observed failure after offer publication, during delivery; the underlying transfer defect remains unresolved. Details and limitations are in the investigation ledger.
- **Non-Chromium control, completed:** a temporary Kitty window verified as XWayland reproduced the failure: its synthetic text pasted into Brave but not Firefox. `xclip` retrieved the marker in 0.004 s; `wl-paste` timed out at five seconds. The observer and temporary window were then closed. The observed fault affected general X11 → Wayland delivery, rather than only Brave/Slack.
- **Fresh-session comparison, completed:** after the user restarted the graphical session, new Hyprland/Xwayland PIDs and app backends were verified. Brave → Firefox still pasted nothing; Firefox → Brave worked. Normal CopyQ startup occurred. The fault reproduced in the fresh session under the normal startup configuration. The subsequent selection-metadata trace and recovery are recorded below; these are completed experiments, not pending restart instructions.
- **Current status — recovered, cause unresolved:** during the selection-metadata trace, the user reported Brave → Firefox worked. After the trace was stopped, the user confirmed three successive fresh markers (`CB-OFF-01`, `CB-OFF-02`, `CB-OFF-03`) copied from Brave to Firefox correctly with all observers off. Active testing has stopped. No configuration repair or extra bridge was applied; CopyQ remains in use. Neither tracing nor the earlier session restart is established as the recovery cause. On recurrence, preserve the failing state and follow the ledger's standard-reader-before-trace comparison; do not repeat the completed broad tests without new evidence.
- **Runtime inventory:** Hyprland 0.49.0, Brave 1.93.138, Xwayland 24.1.8. Brave and Slack are XWayland clients; Firefox and Kitty are native Wayland clients. The GPU does not transfer clipboard text; the relevant part of Brave's graphics workaround is its X11 display backend. Preserve the existing GPU, XWayland and GTK 3 settings.
- **Read-only evidence:** `wl-paste --list-types` returned text formats, which proves an offer exists but not that it is current or transferable. The X11 CLIPBOARD and CLIPBOARD_MANAGER selections shared owner window `0x200001`; its class and PID properties were absent, so it was not identified as CopyQ. Clipboard contents/history were not requested. These observations were not synchronized with a synthetic copy operation.
- **CopyQ:** loaded-library inspection found CopyQ 10.0.0 using the native Wayland Qt plugin. Its three processes were one parent with two children, not demonstrated duplicate servers. The two configured startup paths still differ: Hyprland runs `copyq --start-server`, whereas the XDG entry requests `QT_QPA_PLATFORM=xcb copyq`. This discrepancy is not a proven cause.
- **Service state:** the GTK portal backend is unmasked and active; the earlier Slack authentication mask has not returned. No clipboard-specific cause was established from the service inventory. Hyprland debug logging was disabled.
- **Completed CopyQ isolation test, user approved:** `copyq exit` reported `Terminating server.` and a subsequent process check found no matching CopyQ processes. Brave/Slack/Hyprland were left running. The user reported the same failure on retesting. CopyQ was then restored with `env QT_QPA_PLATFORM=wayland copyq --start-server`; process and loaded-library inspection verified it was running with the native Wayland Qt plugin. Stopping CopyQ was insufficient to recover the bridge; this does not exclude CopyQ having contributed to an earlier stuck state. Hyprland and Xwayland had 157 and 41 open file descriptors respectively at the later snapshot, without an obvious large descriptor accumulation.
- **Completed focus-delay test:** the user reported that keeping Brave focused for five seconds after a fresh copy still did not allow pasting into Firefox. This did not support a simple rapid-focus-switch explanation. In [Hyprland v0.49.0's XWM source](https://github.com/hyprwm/Hyprland/blob/v0.49.0/src/xwayland/XWM.cpp), `handleSelectionNotify` rejects TARGETS replies when `m_focusedSurface` is absent, but no runtime trace demonstrated that rejection here. The retained rolling log contained no matching clipboard diagnostics. The same source shows Hyprland creates its own CLIPBOARD_MANAGER owner, reinforcing that the earlier owner ID alone did not identify CopyQ. The failure remains unresolved. Do not restart Xwayland, which would disrupt its applications, or add a bidirectional synchronization script as an untested fix.
- **Source context:** [CopyQ's known issues](https://copyq.readthedocs.io/en/latest/known-issues.html) describe backend-dependent clipboard limitations. [Hyprland issue 6132](https://github.com/hyprwm/Hyprland/issues/6132) records a similar boundary failure on an older version; it is not evidence that the same historical regression caused this recurrence.

### Reusable handoff diagnostic: observe the failing boundary

1. Check the registered handler with `xdg-mime query default x-scheme-handler/slack`; inspect its desktop entry and executable.
2. Compare a direct launch using `XDG_UTILS_DEBUG_LEVEL=2 xdg-open 'slack://'` with a clickable token-free link in Brave. A typed address may become a search instead.
3. Inspect service masks, logs and the actual interface as above.
4. Start the following in a terminal, then click the test link and approve it while the trace is active:

```sh
timeout 300s dbus-monitor --session --profile \
  "type='method_call',interface='org.freedesktop.portal.OpenURI'" \
  "type='error'"
```

This prints metadata to the terminal, not a trace file or URL payloads. Match calls and replies by serial/reply serial. A sender such as `:1.32` is a temporary bus name, not a PID. Resolve the name actually seen in the trace with:

```sh
busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus GetConnectionUnixProcessID s ':1.32'
```

An empty or expired capture proves nothing. Do not use unfiltered payload traces during real authentication. After an approved, targeted repair, repeat both the minimal reproduction and the real workflow.

## Earlier setup notes

This is a bit of a primer on the nix stuff. I'm sure there's a lot here that's wrong but we can learn as we go!

- [] Configure user profile
- [] Background image
  - copy across
- [x] Copilot
- [] Power & hibernation
- [] Btrfs snapshots (& test)
- More Nixvim:
  - [x] Solidity setup
    - [x] basic LSP
    - [x] GD
    - [x] rn
    - [x] GD to imports (might depend on project)
  - [x] Split buffers and use tabs
  - [x] navigate between windows
  - [] session that actually works
- [x] Configure VS Code & extensions if needed
- [x] Turn off cmp for markdown as it's annoying
- [x] Hook up to external display
- [x] Have a shell that uses vim motions better
  - [x] zsh - need to set fg
  - [x] tmux
    - [] Nicer presets for window splits
- [x] ssh
  - [x] Good local ssh setup
  - [x] Prevent standby
  - [] change hostnames to make it a bit easier

## Ultimate workflow

## Ricing

Once the workflow is sorted with gnome for things like tailscale and tmux, we can explore using hyprland and enable vim motions across the whole VM.

# BASICS

You have a copy of the nix files in 2 places:

/etc/nixos
~/.nix/ we keep stuff here to keep it out of root stuff

You can run using the nix command:

```sh
sudo nixos-rebuild switch --flake ~/.nix#default
```

(which I have aliased to `nixup`)

don't use home-manager as we are seeing this as a complete system.

On home manager you have:

- pkgs (these are system packages you can install in home.nix)
- Home manager packages (these have home-manager config settings)

Example: trash-cli you need to do at the top of home.nix

# Gnome

Gnome extensions need a few things

1. Install the extension as a package in home.nix
2. Add the extension UUID to enable it
3. Config the extension by exporting dconf - someone in github has a tool to convert to home manager
4. Log back in if you need to activate a new extension as we can't reload the shell in wayland - TBC about X

# Flakes and Nixvim

Not super clear from the docs but nixvim needs to be installed as a flake to be accessible by home manager, then you can configure it

# foundry

Forge is extremely tricky as:

- It aint a nixpkg
- It's hard to install due to some issues with solc binaries

There's a flake that takes care of the forge installation that's been added to flake.nix

# Post install steps

On a fresh profile, there are some manual steps you'll need to take:

- [] Setup Hardware config for the specific machine
  - [] There are sample config files in the [Hardware directory](./devices)
  - [] You need to add the /etc/machine_id to flake.nix to dynamically switch
- [] Sync Brave profiles -> easiest to do this manually and takes a few minutes
- [] Authorize password managers and logins
- [] Login to Google accounts where relevant
- [] Login to copilot using :Copilot
- [] Install npm globals (TODO: fix [see below](#npm-globals))
- [] Set ssh config
- [] Setup and backgrounds or user icons

# NPM Globals

Atm we have an issue that NPM globals not available as packages can't easily be added.
We fix this by allowing globals to be installed in /home and changing the npm path.

There's a startup script that runs but if you enable it, it will run on boot every time - this adds ~5mins to boot.
We can conditionally run it but some issues with that. For now you can just run the command as it's 1 package but as this grows we will
need a proper solution.

-- os

206 2024-08-10 00:18:28  
207 2024-08-10 00:19:19

-- hm

162 2024-08-10 00:18:31  
163 2024-08-10 00:19:32
