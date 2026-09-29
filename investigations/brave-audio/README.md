# Brave microphone degradation investigation

Updated: 2026-09-29 (Asia/Dubai). Status: unresolved; a capture delivery failure has been measured, but its originating component and trigger are not established.

This is the canonical investigation index. Read it before proposing another test. The Markdown files live in Git's working tree; historical reports and public-source caches under `reports/` are ignored. No recordings, browser profiles, private call data, or authentication URLs belong here.

## Current conclusion

The leading area is **per-stream delivery on the PipeWire-Pulse → libpulse → Brave audio-service path**, including state shared by a browser instance or its Pulse connection. This is narrower than “the microphone is broken,” but it does not establish whether the server or browser is responsible.

Two independent evidence types support that scope:

1. **Measured, September 10:** one browser input stream received multi-second bursts and lost 1,214 of 1,643 input buffers at its processing FIFO; two other streams on the same Pulse mainloop thread remained comparatively regular. The affected website was not identified. See E01 in [observations](observations.md).
2. **User-reported, September 17:** fresh Brave initially works; Meet/ChatGPT use can precede degradation; subsequently new/reloaded captures across sites fail while an existing Wispr tab can keep working. Fully terminating Brave and relaunching restores operation. See U01–U08 and the app grid.

**Cross-machine update, September 29:** the user reports the same issue on their laptop (U09). Repository inspection (E11) confirms both machines share the NixOS package base, Brave package input, X11/GTK3 flags, declared extensions and PipeWire-Pulse configuration. RX580 selection and the direct-RTKit workaround are desktop-only. This weakens a desktop-specific hardware explanation but does not isolate Chromium from shared audio software/settings. The laptop's activated generation, microphone and full old-tab/new-tab/restart pattern remain unverified. Do not extend the desktop trace finding to the laptop. The previously discussed PipeWire patch explains a possible failure mechanism, not yet the app-specific trigger.

An open tab is not proof of a continuously open microphone stream. A new profile is not proof of an independent browser process or Pulse connection. These two distinctions matter to the next test.

## Navigation

- [Observations and four-app grid](observations.md): evidence IDs, provenance, confidence and missing information.
- [Hypotheses](hypotheses.md): ranked explanations, support, contradictions and discriminating tests. Preserves earlier H1/H1a/H1b/H2/H3/H4 identifiers.
- [Experiment ledger and next test](experiments.md): completed tests, limits, and one staged next experiment.
- [Online evidence](sources.md): primary sources, exact versions, retrieval status and applicability limits.
- [Decision log](decisions.md): why we changed direction and when repetition is justified.

## Working rules

- Every new action must name a hypothesis, a question it can distinguish, a bounded procedure, predicted outcomes, and a stopping condition. Log the result before proposing the next action.
- Use the existing broken state when possible. Do not ask for a fresh full four-app matrix merely to reconfirm the user's report.
- Preserve a working tab as a control. Record whether its capture track actually survives between dictations.
- Record app identity, browser/audio-service PID, Pulse client and stream identity where available. Unknown mappings stay unknown; never infer them from tab order.
- Do not repeat native recording, USB moves, service restarts, cold restarts, or generic profile tests without a new discriminating question. See the completed-test ledger.
- Treat “working right now” and “reset restores it” as recovery observations, not root-cause findings.
- No raw audio, AEC dumps, full WebRTC exports, private URLs or page content by default. Prefer timing, buffer counts, lifecycle, format and gain metadata. A waveform UI alone does not localize a fault.
- Keep GPU, browser version, normal profile and the repaired RTKit setup fixed during audio experiments. Runtime interventions and configuration changes require their own scoped authorization; this documentation task did not authorize killing processes or restarting services.

## What happens next

No reproduction is running. No settings have changed during this consolidation.

The repository already establishes the laptop's configured OS/audio stack (E11); do not ask the user to reconstruct it. Remaining laptop clarifications are whether it uses a different microphone and whether the distinctive failure/reset pattern matches. These concern existing observations, not a new test matrix. Then resolve whether the reported “new profile” already used a separately verified browser/audio-service process. If not, the next proposed experiment is a **simultaneous comparison with one independent Brave instance while the original remains broken**, not another profile-menu test. Exact app URLs are also pending. See P01 in [experiments](experiments.md), including its limitations and result branches.

The unresolved technical boundary remains server delivery versus per-stream client consumption. The known upstream starvation patch is a testable candidate, not permission for a speculative upgrade or patch.
