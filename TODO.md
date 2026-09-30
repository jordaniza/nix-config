# NixOS desktop and laptop TODO

Updated: 2026-09-29. Planning backlog, not authorization to implement everything at once. Completed implementation and remaining runtime validation are tracked separately below.

Goal: keep Nix's declarative, shared-machine configuration and the Hyprland + tmux workflow, while making everyday desktop interactions reliable and pleasant. Prefer small, understandable modules over a wholesale desktop replacement.

## Effort and ROI

- Effort **L**: a localized change and focused checks, usually under half a day.
- Effort **M**: several related components or cross-machine testing, roughly half a day to two days.
- Effort **H**: uncertain diagnosis, migration, or multiple days of testing.
- ROI **H**: resolves a frequent blocker, security gap, or substantial maintenance burden. **M**: meaningful convenience or narrower reliability improvement. **L**: mostly cosmetic or occasional benefit.
- Estimates include validation, but intermittent failures can require longer observation. ROI is qualitative, not a calculated financial return.

| ID  | Work item                                                          | Effort | ROI | Priority                         |
| --- | ------------------------------------------------------------------ | ------ | --- | -------------------------------- |
| 01  | Finish Brave → Slack handoff validation after the portal repair    | L      | H   | P0                               |
| 02  | Restore explicit Brave profile chooser and profile shortcuts       | L      | H   | P0                               |
| 03  | Reliable lock screen, idle and laptop lid/suspend handling         | M      | H   | P0                               |
| 04  | Diagnose ChatGPT voice and patchy microphone use in Brave/apps     | M      | H   | P1                               |
| 05  | Fix screen-sharing echo in Brave                                   | H      | H   | P1                               |
| 06  | Predictable, better-looking screen-share selection dialog          | M      | H   | P1                               |
| 07  | Make Hyprland the normal desktop; migrate config into Home Manager | H      | H   | P1                               |
| 08  | Controlled NixOS/Home Manager/graphics-stack update                | M      | H   | P1                               |
| 09  | Finish CopyQ startup consolidation and `cq` validation             | M      | H   | P1                               |
| 10  | Upgrade `llm` / `llt` to Sonnet 5; Sonnet 4.6 template repair done | M      | H   | P1                               |
| 11  | Finish exact pane-layout presets                                   | M      | H   | P2                               |
| 12  | Reversible fullscreen focus-mode preset                            | L      | H   | P2                               |
| 13  | Consistent Vim navigation and `q` exit for Waybar TUIs             | M      | H   | P2                               |
| 14  | Minimal, more usable Waybar                                        | M      | M   | P2                               |
| 15  | Better keyboard-friendly power menu                                | L      | M   | P2                               |
| 16  | Inline calendar attached to the bar clock                          | L      | M   | P2                               |
| 17  | Replace custom Foundry packaging/overlay with nixpkgs Foundry      | M      | M   | P2                               |
| 20  | Consult on and apply a light, ergonomic visual theme               | M      | M   | P3 implementation; consult early |

P0: immediate reliability/security. P1: core functionality and foundations. P2: workflow improvements. P3: final polish. Priority also accounts for dependencies, not just effort.

Former item 21 is tracked under [README known clipboard issues](README.md#clipboard-boundary-failure-2026-09-29): delivery recovered, cause unresolved. It is on recurrence watch rather than an active repair task; this does not mark it fixed.

GPU policy (18) is implemented and the user reports the GPU working well on September 29. Historical RX580 suspend/native-Wayland faults (19) are on [recurrence watch](README.md#gpu-status-and-recurrence-watch-2026-09-29), not active diagnostic tasks.

## Current baseline: preserve what works

- Brave's shared package uses `--ozone-platform=x11 --gtk-version=3` in `config/brave/default.nix`. Its normal launchers therefore use XWayland, without requiring an X11 desktop.
- Hyprland's browser shortcuts no longer force native Wayland or use `--use-fake-ui-for-media-stream`. Keep ordinary media permission prompts; do not restore automatic camera/microphone approval as a workaround.
- Desktop Brave persistently selects the GPU defined in `hardware/desktop.nix` through its application wrapper; laptop selection remains automatic. The user reports the GPU working well as of September 29. Preserve this setup.
- Native Wayland with the RX580 render node selected reproduced the familiar severe corruption. XWayland on the confirmed RX580 rendered correctly and survived both a short and an overnight suspend cycle.
- A separate suspend cycle left the RX580 in runtime PM `error`, with UVD initialization timeouts. Subsequent successful cycles do not close this issue or certify the hardware.
- Earlier graphics diagnostics observed integrated-GPU `DP-4`; that historical topology is not a fresh statement about the working setup. Cross-GPU handoff was a hypothesis, not a proven root cause.
- Keep the working generation and GPU test results as a baseline. Do not combine a graphics update, GPU routing changes, and compositor migration in one diagnostic experiment.
- Existing dirty worktree changes belong to the user. Do not reset them. Preserve the intentional machine-ID/`--impure` workflow and justified unstable inputs; purity and swap cleanup are not priorities here.

## Immediate reliability and security

### 01 — Brave → Slack handoff

- [x] Remove the user mask on `xdg-desktop-portal-gtk.service`, start the GTK backend and restore the main portal's OpenURI interface. The September 29 inventory found the backend still unmasked and active.
- [x] Verify a token-free `slack://` browser link and actual Slack browser sign-in after the repair. See the [confirmed fix and evidence](README.md#confirmed-fix-brave-could-not-hand-off-slack-sign-in).
- [ ] Finish the cross-profile, fresh-login and suspend/resume handoff checks, including ordinary external links. Successful sign-in during diagnosis does not establish all of these cases. Keep callback URLs out of logs.
- [ ] Preserve the working `hyprland;gtk` portal ownership during the Home Manager/session migration in 07; resolve any remaining GNOME session-environment conflicts there. Portal restarts can interrupt screen sharing.

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

- [ ] Continue from the [canonical Brave audio investigation](investigations/brave-audio/README.md): four-app grid, ranked hypotheses, completed experiments, primary sources and decision log. The September 10 trace demonstrated per-stream burst delivery and processing-FIFO loss; its server-versus-client origin remains unresolved.
- [ ] Resolve the September 17 old-tab/new-tab distinction: an existing Wispr tab can remain good while new/reloaded captures fail across sites; terminating Brave restores operation. Clarify whether the reported new-profile test had independent browser/audio-service processes before considering the bounded P01 comparison. Do not repeat the broad website/profile/native-recording matrix.
- [ ] Preserve the working RTKit/GPU configuration and keep the September 16 missing-Samson incident separate unless it recurs during the measured fault. No private call audio or full diagnostic payloads by default.
- [ ] Acceptance after a candidate fix: validate Wispr Flow demo, Webcam Mic Test, Google Meet and ChatGPT dictation, including existing versus newly acquired captures and use beyond the observed onset time. Specify durations and results; reconnect/resume reliability is a separate validation claim.
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

- [ ] As part of the merge and specialisation removal, replace the tracked `hypr` symlink with actual configuration files in this repository and have Home Manager deploy them. Preserve the working desktop RX580 GPU ordering and DP-1 3440x1440@144 Hz setting; verify subsequent Hyprland edits appear in this repository's `git diff`.
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

### 09 — CopyQ and `cq` integration

- [x] Keep CopyQ and the existing indexed CLI (`cq 0` calls `copyq read 0`); no replacement clipboard manager was installed.
- [x] Add Super+V to open `cq ls` in a centered floating Kitty window, sized to 50% of the monitor in each dimension with a 900-pixel width cap. Enter selects and closes; cancellation closes; no automatic paste. The live Hyprland binding loaded without configuration errors. Kitty's paste shortcut is configured as Alt+V.
- [x] Implement newest-first `j`/`k` browsing, `/` to enter literal case-insensitive search, Escape to return to filtered navigation, and Escape again to close. Synthetic interaction tests, shell syntax and whitespace checks passed.
- [ ] Confirm the Nix-managed `cq` and Kitty changes are activated and the complete Super+V → select → manual-paste workflow works interactively. The configuration work and synthetic checks do not establish activation or end-to-end desktop behaviour.
- [ ] Reconcile the XDG autostart entry (`QT_QPA_PLATFORM=xcb copyq`) with Hyprland's separate `copyq --start-server`; use one session-owned startup path and verify capture from both native Wayland and XWayland applications.
- [ ] Verify stdout, stderr and exit-status behaviour for multiline text, empty history, invalid indices, Unicode and `cq 0 | another-command`, using synthetic data.
- [ ] Document persistence/clear behaviour and consider secret/password exclusions and history limits. Clipboard contents should not leak into diagnostic logs. Delivery failures and the earlier Slack freeze/crash report are tracked in [known issues](README.md#clipboard-boundary-failure-2026-09-29).

### 10 — `llm` / `llt` → Claude Sonnet 5

- [x] Audit `llt = "llm -t clarity"`, the template and plugin registry: installed `llm` 0.30 and `llm-anthropic` 0.24 already support Sonnet 4.6, and the global default was already `anthropic/claude-sonnet-4-6`. The template still explicitly selected retired Sonnet 4.0.
- [x] With user approval, change only the model in `~/.config/io.datasette.llm/templates/clarity.yaml` to `anthropic/claude-sonnet-4-6`. Template validation and local model resolution passed; no API request was sent. This is the immediate repair, not completion of the separate Sonnet 5 migration.
- [ ] Make LLM package upgrades explicit and maintainable. They currently use the hardcoded unstable tarball in `config/packages.nix`, shared with Claude Code, through `config/pythonPkgs.nix`; `nix flake update` does not move that tarball pin. A dedicated LLM flake input was proposed but has not been implemented or approved.
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

## Completed GPU policy and historical issues

- [x] Implement desktop-only Brave GPU selection through the existing hardware configuration and application wrapper, using the PCI by-path render node and an explicit missing-device error. Laptop selection remains automatic.
- [x] Record the user's September 29 report that the GPU is working well. Preserve the working setup; no further GPU experiment is scheduled.

Former items 18–19 now live in [README's GPU status and recurrence watch](README.md#gpu-status-and-recurrence-watch-2026-09-29). The report establishes current usability, not a newly measured graphics-stack root cause or completion of every historical suspend/laptop test.

## Design consultation

### 20 — Light rice, high ergonomics

- [ ] Consult before selecting a theme: dark/light, warm/cool/neutral palette, density, font size, border/gap size, transparency, animations, and tolerance for always-visible status information.
- [ ] Bring two or three restrained directions with small previews. Start with readable, mostly opaque surfaces and subtle focus indication as a proposal, not an assumed preference.
- [ ] Agree the bar/launcher/locker/calendar/power-menu interaction pattern and a keyboard cheat sheet; unify GTK/Qt appearance where practical without hiding important permissions/status.
- [ ] Apply shared design tokens through Home Manager with desktop/laptop overrides. Preserve performance, legibility and a straightforward way to revert.

## Suggested execution order

1. Finish Slack handoff validation, restore the profile chooser and establish secure laptop locking (01–03).
2. Diagnose voice, echo and capture behaviour on the working browser baseline (04–06). Consult on layout/theme preferences now without undertaking the full styling pass.
3. Plan the version target and migration together, but execute the system update and Hyprland migration in separate validated steps (08, 07). Preserve the working GPU setup; reopen diagnosis only if symptoms return.
4. Finish daily tools: clipboard, Sonnet 5, focus/layout presets and TUI consistency (09–13). Small independent wins can happen before the migration.
5. Polish Waybar, calendar and power menu; consolidate Foundry (14–17), then finish the agreed visual theme (20).

## Acceptance checklist for each significant change

- [ ] Evaluate/build the relevant Nix configuration and inspect the diff; no unrelated rewrites or automatic lock-file updates.
- [ ] Preserve a rollback generation and existing external-config changes before moving ownership into Home Manager.
- [ ] Test desktop and laptop where affected: cold login, ordinary use, lock, suspend/resume, and external-monitor/docked cases.
- [ ] Verify actual launch commands, selected GPU/devices and user-visible behaviour; record limitations rather than marking a workaround as a root-cause fix.
- [ ] Keep credentials, browser profiles, clipboard history and private call data out of the repository and diagnostic artifacts.
