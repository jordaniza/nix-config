# NixOS desktop and laptop TODO

Updated: 2026-09-08. Planning backlog, not authorization to implement everything at once.

Goal: keep Nix's declarative, shared-machine configuration and the Hyprland + tmux workflow, while making everyday desktop interactions reliable and pleasant. Prefer small, understandable modules over a wholesale desktop replacement.

## Effort and ROI

- Effort **L**: a localized change and focused checks, usually under half a day.
- Effort **M**: several related components or cross-machine testing, roughly half a day to two days.
- Effort **H**: uncertain diagnosis, migration, or multiple days of testing.
- ROI **H**: resolves a frequent blocker, security gap, or substantial maintenance burden. **M**: meaningful convenience or narrower reliability improvement. **L**: mostly cosmetic or occasional benefit.
- Estimates include validation, but intermittent failures can require longer observation. ROI is qualitative, not a calculated financial return.

| ID  | Work item                                                          | Effort | ROI | Priority                              |
| --- | ------------------------------------------------------------------ | ------ | --- | ------------------------------------- |
| 01  | Reliable Brave → Slack sign-in/link handoff                        | L      | H   | P0                                    |
| 02  | Restore explicit Brave profile chooser and profile shortcuts       | L      | H   | P0                                    |
| 03  | Reliable lock screen, idle and laptop lid/suspend handling         | M      | H   | P0                                    |
| 04  | Diagnose ChatGPT voice and patchy microphone use in Brave/apps     | M      | H   | P1                                    |
| 05  | Fix screen-sharing echo in Brave                                   | H      | H   | P1                                    |
| 06  | Predictable, better-looking screen-share selection dialog          | M      | H   | P1                                    |
| 07  | Make Hyprland the normal desktop; migrate config into Home Manager | H      | H   | P1                                    |
| 08  | Controlled NixOS/Home Manager/graphics-stack update                | M      | H   | P1                                    |
| 09  | Reliable CopyQ + pipe-friendly `cq` terminal workflow              | M      | H   | P1                                    |
| 10  | Repair `llm` / `llt` support for Claude Sonnet 5                   | M      | H   | P1                                    |
| 11  | Finish exact pane-layout presets                                   | M      | H   | P2                                    |
| 12  | Reversible fullscreen focus-mode preset                            | L      | H   | P2                                    |
| 13  | Consistent Vim navigation and `q` exit for Waybar TUIs             | M      | H   | P2                                    |
| 14  | Minimal, more usable Waybar                                        | M      | M   | P2                                    |
| 15  | Better keyboard-friendly power menu                                | L      | M   | P2                                    |
| 16  | Inline calendar attached to the bar clock                          | L      | M   | P2                                    |
| 17  | Replace custom Foundry packaging/overlay with nixpkgs Foundry      | M      | M   | P2                                    |
| 18  | Declarative desktop RX580 selection for Brave                      | M      | M   | P2                                    |
| 19  | Isolate RX580 suspend/runtime-power-management failure             | H      | H   | P1 diagnosis; fixes gated by evidence |
| 20  | Consult on and apply a light, ergonomic visual theme               | M      | M   | P3 implementation; consult early      |
| 21  | Fix freezes/crashes when pasting from Slack into another app       | M      | H   | P0                                    |

P0: immediate reliability/security. P1: core functionality and foundations. P2: workflow improvements. P3: final polish. Priority also accounts for dependencies, not just effort.

## Current baseline: preserve what works

- Brave's shared package now defaults to `--ozone-platform=x11 --gtk-version=3` in `configuration.nix`. Its normal launchers therefore use XWayland, without requiring an X11 desktop.
- Hyprland's browser shortcuts no longer force native Wayland or use `--use-fake-ui-for-media-stream`. Keep ordinary media permission prompts; do not restore automatic camera/microphone approval as a workaround.
- Persistent GPU selection is still automatic. Normal Brave selected the integrated Radeon; manually forcing the RX580 under XWayland also worked with hardware acceleration.
- Native Wayland with the RX580 render node selected reproduced the familiar severe corruption. XWayland on the confirmed RX580 rendered correctly and survived both a short and an overnight suspend cycle.
- A separate suspend cycle left the RX580 in runtime PM `error`, with UVD initialization timeouts. Subsequent successful cycles do not close this issue or certify the hardware.
- As of the latest connector check, the monitor is still on integrated-GPU `DP-4`; the direct-to-RX580 cable test has not happened. Cross-GPU handoff is a hypothesis, not a proven root cause.
- Keep the working generation and GPU test results as a baseline. Do not combine a graphics update, GPU routing changes, and compositor migration in one diagnostic experiment.
- Existing dirty worktree changes belong to the user. Do not reset them. Preserve the intentional machine-ID/`--impure` workflow and justified unstable inputs; purity and swap cleanup are not priorities here.

## Immediate reliability and security

### 01 — Brave → Slack handoff

- [ ] Remove the stale user mask on `xdg-desktop-portal-gtk.service` and verify the fallback backend starts. The mask still points to `/dev/null`; previous inspection found the Slack URI handler already correctly associated with `slack.desktop`.
- [ ] Declare portal backend ownership explicitly: Hyprland for supported capture interfaces, a working fallback for OpenURI/FileChooser/Settings as appropriate to the installed versions. Resolve any remaining GNOME session-environment conflicts.
- [ ] Test a complete Slack browser sign-in, a `slack://` handoff, and an ordinary external link from each relevant Brave profile, after login and after suspend. Do not publish authentication callback URLs in logs.
- [ ] Treat successful handoff as the acceptance test, rather than merely having portal processes running. Portal restarts can interrupt screen-sharing sessions; schedule them accordingly.

### 02 — Brave profile chooser

- [ ] Restore an explicit chooser action for the general browser hotkey, separate from direct personal/work-profile shortcuts. The saved `profile.show_picker_on_startup` is currently `false`; existing profile shortcuts explicitly select `Default` and `Profile 1`.
- [ ] Verify the supported profile-picker mechanism for the installed Brave version; preserve all existing profiles, extensions, bookmarks and sessions. Do not replace a live profile's full `Local State` file declaratively.
- [ ] Check cold start, already-running Brave, Wofi and hotkeys. Keep external URLs going to the intended profile without unexpectedly opening a chooser every time.

### 03 — Lock screen and laptop safety

- [ ] Add a declaratively managed locker and idle service, e.g. Hyprlock + Hypridle after checking the target versions' options, including the required NixOS authentication/PAM integration.
- [ ] Cover manual lock, idle lock, lock-before-suspend, resume, laptop lid close, docked/external-monitor use and AC versus battery behaviour. Keep desktop SSH/idle requirements separate from laptop policy.
- [ ] Review the desktop's current `InhibitDelayMaxSec=0` against reliable pre-sleep locking. Do not assume a timed command has actually secured the session.
- [ ] Test that the session is locked before sleep, cannot flash unlocked on resume, and behaves safely when the locker fails. Do not enable automatic suspend until locking works.

## Audio, calls and capture

### 04 — ChatGPT voice / patchy microphone support

- [ ] Reproduce and distinguish ChatGPT voice conversation, dictation, microphone capture and output playback. Firefox working is the control, not proof that Brave's permissions or device routing are correct.
- [ ] Compare the same microphone/output in Firefox, a clean Brave profile and the normal Brave profile. Check site permissions, selected input, per-site Shields/extension effects, mute/gain, PipeWire/WirePlumber routing, and wired versus Bluetooth profiles where relevant.
- [ ] Inspect browser WebRTC diagnostics and user-service logs during failure, including after suspend/device reconnect. Change one variable at a time; do not disable browser security globally or assume the missing portal explains all microphone faults.
- [ ] Acceptance: a real voice conversation and dictation test work repeatedly, including after reconnect/resume, without changing the working GPU baseline.
- Documentation boundary: the [official OpenAI product documentation](https://learn.chatgpt.com/docs/use-chatgpt) checked for this planning pass does not establish the cause of this Brave/Linux failure. Keep it an open diagnostic item, not a promised configuration fix.

### 05 — Screen-sharing echo

- [ ] Establish who hears the echo and when: microphone-only call, tab share, window share, full-display share, and shared audio on/off if offered. Check for duplicate meeting tabs/devices.
- [ ] Compare headphones with speakers; inspect whether an output-monitor/loopback source or the remote call audio is being captured again. Compare Firefox and Brave with the same endpoints.
- [ ] Check echo cancellation and audio routing only after reproducing the relevant path. Avoid a blanket system-wide echo-cancellation filter until the cause is known.
- [ ] Acceptance: another participant confirms no echo during sustained sharing, with microphone and intended shared audio both preserved. Requires a coordinated test call.

### 06 — Screen-share dialog: behaviour before appearance

- [ ] Identify which UI is misbehaving: Brave's source picker, portal chooser, or Hyprland capture backend. Capture a non-sensitive screenshot and reproduction steps.
- [ ] Repair focus, keyboard navigation, repeated prompts, cancellation, window/monitor selection and multi-monitor behaviour; verify what is actually shared, including XWayland windows.
- [ ] Fix the previously observed GTK4 theme import referencing a nonexistent `gnome-themes-extra` CSS file. Make GTK/Qt theme ownership consistent; the missing CSS was real, but was not proven to cause every dialog problem.
- [ ] Style the functioning chooser consistently with the final desktop theme. Check sharing after resume and ensure cancellation/sharing indicators work. Depends on 01; coordinate final configuration with 07.

## System foundations and maintenance

### 07 — Hyprland as the real desktop, Home Manager as config owner

- [ ] Move Hyprland enablement, portals, PipeWire/WirePlumber, Bluetooth and required session services into the normal NixOS configuration. Remove GNOME-as-base and the Hyprland specialisation after validating the replacement.
- [ ] Choose the login/session arrangement explicitly. Keeping a display manager does not require running the GNOME desktop; preserve keyring unlock and authentication services that are actually needed.
- [ ] Migrate the external `~/.config/hypr` repository and related Waybar/launcher/notification/wallpaper settings into Home Manager, preserving existing scripts and uncommitted changes. Avoid competing autostarts and competing file owners.
- [ ] Replace the current `hyprswitch`/specialisation-dependent workflow and ensure `nixup` cannot unexpectedly activate GNOME. Separate common desktop settings from desktop/laptop hardware modules.
- [ ] Acceptance: ordinary boot, login and rebuild select Hyprland on both machines; keyring, portals, sound, lock and capture work. Retain a known-good boot generation for rollback until validated.

### 08 — Controlled system update

- [ ] Choose and verify a currently supported NixOS release at implementation time; align Home Manager and Nixvim compatibility, then review release notes and changed options.
- [ ] Record current versions and compare the currently mixed stack: NixOS 25.05/kernel 6.12.50/Mesa 25.0.7/Hyprland 0.49.0 with separately updated Brave 1.93.138.
- [ ] Evaluate/build before activation; test desktop and laptop separately with rollback available. Upgrade separately from the DE migration and GPU-routing experiments so regressions remain attributable.
- [ ] Retest acceleration, suspend, lock, audio, Slack handoff and screen capture. Keep intentional impurity and necessary package pins unless they cause a specific problem.

### 17 — Foundry from nixpkgs

- [ ] Use the nixpkgs Foundry package from a deliberately chosen pinned input; the current Brave unstable input already contains `pkgs.foundry` (observed package version 1.7.1), but confirm compatibility before selecting it as the shared source.
- [ ] Replace all custom `foundry-bin` references: flake apps (`forge`, `cast`, `anvil`, `chisel`), development shell, default package, system packages and exported overlay. Commented overlay code is not the only remaining dependency.
- [ ] Verify versions, an existing project's `forge build`/`forge test`, local Anvil startup and required Solidity compiler resolution. Remove obsolete custom packaging only after confirming nothing references it.

## Clipboard and LLM tools

### 21 — Slack → other-app clipboard freeze/crash

- [ ] Diagnose the reported freeze/crash when copying from Slack and pasting into a different application (not Slack). Confirm which process freezes or crashes and record affected destination apps; the cause is not yet established.
- [ ] Reproduce with non-sensitive plain text versus rich content, compare native Wayland and XWayland destinations, and isolate CopyQ's involvement. Do not assume this shares the cause of the repaired Slack sign-in handoff.
- [ ] Acceptance: repeated Slack-to-other-app copy/paste succeeds without hangs or crashes, including after suspend. Keep clipboard contents and credentials out of diagnostic logs.

### 09 — CopyQ and `cq` integration

- [ ] Repair and consolidate the existing integration rather than replace it: `config/shell-scripts/cq.sh` already implements indexed reads, and `cq 0` reaches `copyq read 0`.
- [ ] Reconcile the XDG autostart entry (`QT_QPA_PLATFORM=xcb copyq`) with Hyprland's separate `copyq --start-server`; use one session-owned startup path and verify capture from both native Wayland and XWayland applications.
- [ ] Make `cq 0` output only the selected text to stdout; keep errors on stderr and return useful status codes. Check multiline text, empty history, invalid indices, Unicode and `cq 0 | another-command` using synthetic data.
- [ ] Preserve the `cq ls` searchable workflow, provide a GUI toggle hotkey, document persistence/clear behaviour, and consider secret/password exclusions and history limits. Clipboard contents should not leak into diagnostic logs.

### 10 — `llm` / `llt` → Claude Sonnet 5

- [ ] Audit the existing `llt = "llm -t clarity"` alias, saved `clarity` template and the installed `llm-anthropic` plugin/model registry. Packages currently come from the separate unstable tarball through `config/pythonPkgs.nix`; this is not necessarily a standalone script bug.
- [ ] Update/pin compatible `llm`, Anthropic plugin and SDK versions; use the exact requested API model `claude-sonnet-5`, rather than silently substituting another Sonnet model.
- [ ] Check templates/options for unsupported manual thinking budgets and non-default sampling parameters; account for adaptive thinking and parse streamed content appropriately. These are documented Sonnet 5 migration considerations. [Anthropic migration guide](https://platform.claude.com/docs/en/models/sonnet-5/migration-guide)
- [ ] Acceptance: model discovery recognizes Sonnet 5, `llt` retains the clarity prompt, stdin piping and streaming work, and errors are legible. Keep API keys outside the Nix store; get approval before a paid API smoke test.

## Window management and everyday controls

### 11 — Pane presets

- [ ] Preserve and review `~/.config/hypr/scripts/pane-layout.sh`, already bound to Super+N/comma/period. It supports `thirds`, `wide-left` and `wide-right`, but currently requires specific pane counts/arrangements.
- [ ] Make a three-column `1/3 | 1/3 | 1/3` preset predictable, and implement the requested `hstack(1/2,1/2)1/3,2/3` arrangement. Confirm the exact orientation first: is this two half-height panes in a one-third-width column beside a two-thirds-width pane?
- [ ] Define deterministic window ordering, reversibility, focus preservation, behaviour for missing/extra/floating windows, and sensible laptop-size fallbacks. Avoid hard-coded pixel geometry.
- [ ] Acceptance: repeatable results from different starting layouts; no lost windows, unintended cross-workspace moves or permanent floating-state changes.

### 12 — Focus-mode toggle

- [ ] Add one consistent shortcut to fullscreen the active window and return it to its previous tiled/floating geometry and focus state.
- [ ] Confirm whether focus mode hides Waybar and suppresses notifications, or only enlarges the window. Keep it distinct from an application's own fullscreen shortcut and define an obvious escape.

### 13 — Waybar TUI navigation contract

- [ ] Inventory current click targets: `bluetuith`, `pulsemixer` and `nmtui`. Define `h/j/k/l`, Enter/Space and `q` consistently, with a visible hint and no leftover terminal after exit.
- [ ] Use supported per-app keymaps first. If a TUI cannot meet the contract, propose a suitable replacement instead of globally intercepting typing; `q` and Vim keys must remain typeable in SSID/password/search fields.
- [ ] Standardize terminal title, floating placement, sizing, focus and toggle behaviour. Verify Bluetooth, audio input/output/volume and Wi-Fi controls on both machines.

### 14 — Waybar cleanup

- [ ] Keep a restrained layout: workspaces left, clock/calendar centre, concise audio/network/battery/power status right. Make recording/microphone state easy to see.
- [ ] Remove cluttered separators and fix misleading labels (the Ethernet format currently says `wlan`). Replace hard-coded desktop interface names with appropriate per-machine or automatic selection.
- [ ] Make battery status laptop-aware; tune spacing, typography, contrast and tooltips. Consolidate duplicated Waybar files under one Home Manager owner during 07.
- [ ] Reuse the interaction contract from 13 and visual decisions from 20; check the ultrawide desktop and laptop rather than optimizing only one screen.

### 15 — Power menu

- [ ] Provide lock, logout, suspend, reboot and shutdown with keyboard navigation, cancellation and confirmation for destructive/session-ending actions.
- [ ] Show hibernate only after its storage/resume configuration is verified; consider suspend-then-hibernate for the laptop only if supported and tested. The existing menu currently advertises hibernate unconditionally.
- [ ] Route suspend through the verified lock-before-sleep flow from 03, and honour relevant inhibitors. Share one implementation between Waybar and a hotkey.

### 16 — Inline calendar

- [ ] Add a compact month calendar to the Waybar clock tooltip/popover, with today's date highlighted and useful month navigation.
- [ ] Confirm preferred week start, date format, week numbers and timezone display. This is a date calendar initially; account/event integration is a separate scope decision.

## GPU policy and remaining investigation

### 18 — Force the desktop GPU when wanted

- [ ] Decide whether normal desktop Brave should always use the RX580 or expose a separate RX580 launcher while leaving the default automatic. Current working manual launch uses `DRI_PRIME=pci-0000_01_00_0` and `--render-node-override=/dev/dri/by-path/pci-0000:01:00.0-render` with X11/GTK3.
- [ ] If made persistent, gate it on the existing desktop/laptop detection and scope the environment to Brave, not every application. Prefer the verified PCI by-path link over unstable `renderD128` numbering; handle a missing device explicitly.
- [ ] Verify cold launches from Wofi, hotkeys and external links, and that browser relaunches preserve the policy. Confirm actual `GL_RENDERER`, not merely requested flags. Test laptop portability and sleep/wake before declaring reliable.
- [ ] Do not treat GPU pinning as a fix for 19 or change the monitor cable/compositor GPU at the same time.

### 19 — RX580 suspend and cross-GPU diagnosis

- [ ] Compare suspend with the RX580 idle versus holding an active browser context, recording runtime PM state and kernel logs before/after. Current evidence is mixed: one failed cycle and subsequent clean cycles, including overnight.
- [ ] From a clean boot, test whether avoiding runtime autosuspend changes the failure rate; select a scoped, reversible method and document power-consumption implications. Do not apply broad AMD kernel flags indiscriminately.
- [ ] Separately test direct monitor connection to the RX580, verify Hyprland and Brave GPU ownership, adapt the connector rule if necessary, and repeat native Wayland rendering. Current monitor rule targets integrated-GPU `DP-4`.
- [ ] Re-test after the controlled graphics-stack update. Escalate to firmware or hardware isolation only as evidence warrants; neither successful browsing nor a runtime PM `error` alone proves hardware health/failure.
- [ ] Keep the working XWayland path available throughout; do not conclude that software workarounds have fixed the underlying native-Wayland issue.

## Design consultation

### 20 — Light rice, high ergonomics

- [ ] Consult before selecting a theme: dark/light, warm/cool/neutral palette, density, font size, border/gap size, transparency, animations, and tolerance for always-visible status information.
- [ ] Bring two or three restrained directions with small previews. Start with readable, mostly opaque surfaces and subtle focus indication as a proposal, not an assumed preference.
- [ ] Agree the bar/launcher/locker/calendar/power-menu interaction pattern and a keyboard cheat sheet; unify GTK/Qt appearance where practical without hiding important permissions/status.
- [ ] Apply shared design tokens through Home Manager with desktop/laptop overrides. Preserve performance, legibility and a straightforward way to revert.

## Suggested execution order

1. Repair Slack handoff and the profile chooser; establish secure laptop locking (01–03).
2. Diagnose voice, echo and capture behaviour on the working browser baseline (04–06). Consult on layout/theme preferences now without undertaking the full styling pass.
3. Plan the version target and migration together, but execute the system update and Hyprland migration in separate validated steps (08, 07). Continue GPU diagnosis as its own experiment track (19).
4. Finish daily tools: clipboard, Sonnet 5, focus/layout presets and TUI consistency (09–13). Small independent wins can happen before the migration.
5. Polish Waybar, calendar and power menu; consolidate Foundry and any chosen desktop GPU policy (14–18), then finish the agreed visual theme (20).

## Acceptance checklist for each significant change

- [ ] Evaluate/build the relevant Nix configuration and inspect the diff; no unrelated rewrites or automatic lock-file updates.
- [ ] Preserve a rollback generation and existing external-config changes before moving ownership into Home Manager.
- [ ] Test desktop and laptop where affected: cold login, ordinary use, lock, suspend/resume, and external-monitor/docked cases.
- [ ] Verify actual launch commands, selected GPU/devices and user-visible behaviour; record limitations rather than marking a workaround as a root-cause fix.
- [ ] Keep credentials, browser profiles, clipboard history and private call data out of the repository and diagnostic artifacts.
