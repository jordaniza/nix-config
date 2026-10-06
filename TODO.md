# TODO

Updated: 2026-10-06. Repository status and backlog; implementation changes still require approval. A configured feature is not proof of activation or runtime acceptance on either machine.

## Next

- [ ] Make Super+F refocus an open, unfocused Quickshell menu and cycle through other floating windows, so returning to a menu never requires the mouse. Include Quickshell layer surfaces explicitly in the focus flow.
- [ ] Verify the configured Super+Ctrl+T → `tmux-menu` binding after user-managed activation. Super+T opens tmux; Super+Shift+T opens a plain terminal.
- [ ] Revisit tmux menu keyboard focus before adding interactive actions. The exclusive-focus attempt did not resolve it and its tmux-specific changes were removed at the user's request; defer investigation while the viewer is read-only.
- [ ] Verify desktop idle behaviour: displays off at 15 minutes, lock at 30, and locked resume after manual suspend. Startup is verified; never automatically sleep the desktop.
- [ ] Record remaining acceptance of the base Hyprland desktop on both machines: login, keyring and normal workflows. The specialisation and `hyprswitch` are already absent from the configuration.
- [ ] Audit and validate the laptop's Hyprland/Waybar/Wofi/Mako configuration. Its device overlay is already wired; activation and runtime acceptance are separate checks.
- [ ] Validate the configured laptop idle policy: dim at 3 minutes, lock at 5, displays off at 6 and suspend at 20. Review lid-close behavior, including docked use and AC versus battery.

## Reliability

- [ ] Continue the [renewed Brave microphone investigation](reports/2026-10-05-brave-audio-deep-dive.md) from its current evidence and Firefox comparison plan. Consult the [historical completed-test ledger](reports/investigations/brave-audio/experiments.md) before proposing another experiment.
- [ ] Diagnose screen-sharing echo and picker behavior. Verify the configured GTK4 dark-theme integration if the earlier import symptom recurs; configuration is not proof of runtime repair.
- [ ] Recheck the repaired Brave → Slack handoff across profiles and after resume.
- [ ] Restore an explicit Brave profile chooser alongside direct profile shortcuts.
- [ ] Verify CopyQ startup and the Super+V picker/`cq` CLI edge cases. The XDG entry already excludes Hyprland with `NotShowIn=Hyprland;`; Hyprland starts the server directly. Review backend differences if they cause a reproducible issue.

## Maintenance

- [ ] Defer npm activation cleanup to a separate reviewed change: move package downloads out of activation, choose explicit version/update ownership and preserve existing npm configuration.
- [ ] Defer laptop swap cleanup to a separate reviewed change: verify the existing Btrfs swapfile and choose one creation mechanism in place of overlapping `swapDevices`, tmpfiles and custom activation logic.
- [ ] Add one safe entry point for existing Nix parsing, shell syntax checks and Python adapter tests; document QML tool requirements. This does not authorize entering a build-capable test shell.
- [ ] Remove obsolete configuration boilerplate and duplicate module imports in small reviewed changes, checking usage before deleting files.
- [ ] Remove the word "rice" from all theming identifiers and documentation, updating shared color declarations and every consumer together without changing appearance.
- [ ] Investigate a gradual move to Quickshell as the shared desktop UI, potentially replacing Waybar and Mako. Assess shared state, theming and keyboard navigation against feature parity, durable notification history, failure recovery and maintenance cost; retain existing components until replacements are ready.
- [ ] Review Quickshell's native APIs and D-Bus integrations as replacements for Bash adapters, starting with power actions and menu-state integration with Waybar. Prefer native, event-driven integration where supported; retain shell adapters where needed.
- [ ] Verify `whatsapp` launches the configured ZapZap package after rebuilding and reloading Zsh.
- [ ] Review and explain the explicitly preserved SSH defaults before changing agent forwarding, connection sharing, keepalives, or known-host behavior.

- [ ] Record remaining NixOS/Home Manager/Nixvim 26.05 acceptance on both machines after user-managed builds/activation. The input branches are already configured for 26.05; preserve the working GPU configuration and required pins, and keep future dependency updates separate.
- [ ] Make `llm`/`llt` package upgrades explicit; verify availability and compatibility of the requested Sonnet 5 target. The stale clarity-template model is already repaired.
- [ ] Validate stable Foundry 1.7.1 after activation: check forge/cast/anvil/chisel and run representative project tests.

## Nice-to-haves

- [ ] Laptop low/critical battery notifications, with configurable thresholds and no repeated-alert spam.
- [ ] Both machines: check this Nix repo's upstream branch in the background; notify on newly detected commits and remind every 12 hours while unmerged. Consider a Waybar indicator; no automatic pull or rebuild.
- [ ] Investigate hibernation per machine: swap/encryption/resume requirements and locked session recovery. Enable menu actions only after testing.
- [ ] Improve Waybar: restrained layout, correct network labels, laptop-aware battery, microphone state, notification visibility and update status.
- [ ] Add a cancellable restart/shutdown countdown with Cancel and Run now to the existing power menu. Actions currently execute immediately; retain manual lock/suspend acceptance on both machines.
- [ ] Add a compact calendar to the bar clock.
- [ ] Make Waybar's Bluetooth/audio/network TUIs consistent: Vim navigation, sensible floating size and clean exit.
- [ ] Improve pane presets: reliable thirds and the requested mixed-width layout, with predictable behaviour for different window counts.
- [ ] Add a reversible fullscreen focus-mode shortcut.
- [ ] Validate shared-theme appearance on both machines and review any remaining application-specific adapters as separate migrations.
- [ ] Review persistent Neovim sessions and tmux split presets from the earlier setup notes.
- [ ] Define and test laptop Btrfs snapshots and recovery.
- [ ] Consider distinct desktop/laptop hostnames for easier identification, retaining the earlier setup task.

## Configured features

Present in the repository as of 2026-10-06. These entries record implementation, not completed runtime validation.

- [x] Base Hyprland desktop with GDM and GNOME keyring retained; GNOME Shell disabled and the specialisation removed.
- [x] Shared theme palette, native appearance files and adapters under `config/theme/`.
- [x] Quickshell service-managed startup and one Nix-generated configuration file for paths and commands.
- [x] Keyboard-friendly power menu shared by Waybar and Super+P; restart/shutdown confirmation remains pending above.
- [x] Screenshot history drawer with copy action and Super+Shift+V binding.
- [x] Read-only tmux viewer, Waybar counts and Super+Ctrl+T binding, configured on 2026-10-05.
- [x] ZapZap package and `whatsapp` Zsh alias replacing the removed whatsapp-for-linux command.
- [x] NixOS/Home Manager/Nixvim input branches set to 26.05.

## Reference

Desktop config ownership, manual locking and idle startup are implemented; their remaining tests are listed above.

GPU and clipboard recurrence notes belong in [known issues](README.md#known-desktop-issues-and-fixes).
The earlier setup notes' remaining editor/session and snapshot tasks are retained above; this file owns the current task list.
