# NixOS configuration

The implementation backlog is in [TODO.md](TODO.md). The notes below record actual desktop troubleshooting results; they are not authorization to apply every workaround on every machine.

## Known desktop issues and fixes

Last verified: **2026-09-08**. Desktop observations unless stated otherwise. Preserve this working baseline while watching for recurrence after ordinary use, suspend/resume and reboot.

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
- Desktop GPUs: Radeon RX580 at PCI `0000:01:00.0` and the Ryzen 9 7950X integrated Radeon at `0000:11:00.0`. The monitor was last observed connected to the integrated GPU's `DP-4`; moving the cable to the RX580 was discussed but not verified.
- Native Wayland Brave with the RX580 explicitly selected reproduced severe visual corruption/freezing. The confirmed RX580 under **XWayland** rendered smoothly with hardware acceleration and survived short and overnight suspend tests.
- Preserve `--ozone-platform=x11 --gtk-version=3` in [config/brave/default.nix](config/brave/default.nix). This runs Brave through XWayland inside Hyprland, not a separate X11 desktop. Shared GPU selection remains **automatic**; these flags alone do not force the RX580.
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

### Intermittent symptoms: currently working, not established fixes

- **Slack clipboard:** copying from Slack and pasting into another application was reported to freeze/crash an app. It was no longer reproducible during diagnosis. Slack and Brave were then XWayland clients, Kitty/Telegram native Wayland, and CopyQ was running. No matching recent crash dump, OOM kill or clipboard-transfer error was found in the checks performed. Do not claim the portal repair fixed clipboard behavior; keep [TODO item 21](TODO.md#21--slack--other-app-clipboard-freezecrash) open for recurrence.
- **Microphone/dictation:** ChatGPT dictation worked during testing, and Brave had an active, unmuted input stream from the default Samson G-Track Pro. Earlier reports involved microphone loss after a period of use in calls and ChatGPT. Current success is not proof of long-term reliability or a portal-related cause.
- **Screen sharing:** the GTK backend repair may affect supporting dialogs, but no before/after test proved that it fixed sharing, freezes or echo. The Hyprland capture backend was already running.

If one recurs, note the time, app, action, selected devices and whether the machine recently resumed. Where practical, inspect the broken state before restarting or changing routing. For audio, `wpctl status` shows streams and connected devices without recording sound. Use non-sensitive synthetic content for clipboard tests. Do not collect actual clipboard history, login callback URLs, private recordings or full browser profiles.

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
