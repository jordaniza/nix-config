# TODO

Updated: 2026-10-04. Backlog only; implementation changes still require approval.

## Next

- [ ] Verify desktop idle behaviour: displays off at 15 minutes, lock at 30, and locked resume after manual suspend. Startup is verified; never automatically sleep the desktop.
- [ ] Make Hyprland the base desktop, initially keeping GDM/keyring; retire the specialisation and `hyprswitch` after validation.
- [ ] Audit the laptop's existing Hyprland/Waybar/Wofi/Mako files before enabling its device overlay.
- [ ] Define laptop locking and lid-close behaviour, including docked use and AC versus battery.

## Reliability

- [ ] Continue the [Brave microphone investigation](investigations/brave-audio/README.md) from its existing evidence and test ledger.
- [ ] Diagnose screen-sharing echo and fix picker behaviour; resolve the recorded GTK4 theme import problem.
- [ ] Recheck the repaired Brave → Slack handoff across profiles and after resume.
- [ ] Restore an explicit Brave profile chooser alongside direct profile shortcuts.
- [ ] Consolidate CopyQ startup; verify the Super+V picker and `cq` CLI edge cases.

## Maintenance

- [ ] Remove the word "rice" from all theming identifiers and documentation, updating shared color declarations and every consumer together without changing appearance.
- [ ] Investigate a gradual move to Quickshell as the shared desktop UI, potentially replacing Waybar and Mako. Assess shared state, theming and keyboard navigation against feature parity, durable notification history, failure recovery and maintenance cost; retain existing components until replacements are ready.
- [ ] Review Quickshell's native APIs and D-Bus integrations as replacements for Bash adapters, starting with power actions and menu-state integration with Waybar. Prefer native, event-driven integration where supported; retain shell adapters where needed.
- [ ] Choose a replacement for the removed whatsapp-for-linux package; assess Karere before installing a replacement.
- [ ] Review and explain the explicitly preserved SSH defaults before changing agent forwarding, connection sharing, keepalives, or known-host behavior.

- [ ] Upgrade NixOS/Home Manager/Nixvim together in a separate change from desktop migration; preserve the working GPU configuration and required pins.
- [ ] Make `llm`/`llt` package upgrades explicit; verify availability and compatibility of the requested Sonnet 5 target. The stale clarity-template model is already repaired.
- [ ] Validate stable Foundry 1.7.1 after activation: check forge/cast/anvil/chisel and run representative project tests.

## Nice-to-haves

- [ ] Laptop low/critical battery notifications, with configurable thresholds and no repeated-alert spam.
- [ ] Both machines: check this Nix repo's upstream branch in the background; notify on newly detected commits and remind every 12 hours while unmerged. Consider a Waybar indicator; no automatic pull or rebuild.
- [ ] Investigate hibernation per machine: swap/encryption/resume requirements and locked session recovery. Enable menu actions only after testing.
- [ ] Improve Waybar: restrained layout, correct network labels, laptop-aware battery, microphone state, notification visibility and update status.
- [ ] Add a keyboard-friendly power menu shared by Waybar and a hotkey, with confirmation for session-ending actions.
- [ ] Add a compact calendar to the bar clock.
- [ ] Make Waybar's Bluetooth/audio/network TUIs consistent: Vim navigation, sensible floating size and clean exit.
- [ ] Improve pane presets: reliable thirds and the requested mixed-width layout, with predictable behaviour for different window counts.
- [ ] Add a reversible fullscreen focus-mode shortcut.
- [ ] Agree and apply a subtle shared theme across the bar, launcher, locker and dialogs.

## Reference

Desktop config ownership, manual locking and idle startup are implemented; their remaining tests are listed above.

GPU and clipboard recurrence notes belong in [known issues](README.md#known-desktop-issues-and-fixes).
The [archived detailed backlog](TODO.archive-2026-09-30.md) is historical context, not the current task list.
