# Decision log

## 2026-09-29 — Same symptom reported on laptop

User reports recurrence on the laptop. Record as U09, not as a new instrumented reproduction. This further deprioritizes hardware specific to the desktop. It does not establish whether the microphone, OS audio stack, Brave version or profile settings differ, or whether the entire distinctive lifecycle/reset pattern reproduces.

Clarify those existing circumstances before choosing a new experiment. No renewed USB-port trials, graphics changes or broad diagnostics. Shared browser/client state and shared audio-server behavior remain leading alternatives; the earlier specific PipeWire patch has not explained the app-trigger relationship. Added H1c to represent the broader client-state candidate separately from the narrow H1a hole hypothesis. Only investigation documentation was updated; no runtime actions were taken.

Follow-up: user pointed out laptop configuration is in the repository. Inspected the common flake, laptop/desktop hardware modules, Brave modules and audio configuration; recorded E11 with a comparison table. Both machines declare the same Brave package source and PipeWire-Pulse base; only desktop has RX580 overrides and the direct-RTKit workaround. The configured shared stack is now established without asking the user or launching diagnostics. Runtime generation and mic selection remain distinct unknowns. Do not claim the laptop observation isolates Brave from PipeWire or expand into generic extension/flag troubleshooting merely because those settings are also shared.

## 2026-09-17 — Consolidate before more diagnostics

User explicitly requested a structured, persistent investigation because repeated broad diagnostics were taking too long without progress. Created this dossier with an app grid, evidence IDs, ranked hypotheses, completed tests, online sources and a next-test contract.

The September 10 T1 timing trace is the strongest measured evidence. It must not be lost behind the later missing-microphone episode. The trace established per-stream burst delivery and drops before speech processing, but did not separate server from client or map the affected website.

User's new old-tab/new-tab/reload/reset observations strengthen stream/client lifecycle questions. They do not justify inventing a particular app's media constraints. Requested only the two missing details needed to choose the next comparison: exact Wispr/test URLs and how the new profile was launched. No assumption that a profile-menu window is process-independent.

Rechecked the primary source for the earlier H1b candidate and relevant exact-version Chromium paths. Retained H1b as a concrete candidate, not a diagnosis. No live tracing, audio capture, process termination, browser launch, service restart, package change, build or activation was performed in this consolidation. Required read-only service-mask inventory was unchanged.

## Superseded explanations and conditions for reopening them

| Explanation / repeated action | Decision | Reopen only if |
| --- | --- | --- |
| Generic microphone/USB failure explains every occurrence | Separate the documented missing-device incident from simultaneous native-good/browser-bad failures. | A new failing-state snapshot shows device disappearance or same-time native capture failure. |
| Lost audio-server RT priority explains the recurrent issue | Repair verified; later failure occurred at RR20. | A recurrence includes measured priority loss or missed deadlines correlated to the affected stream. |
| September 1 Brave update caused onset | User corrected symptoms to before the update. | New dated evidence changes that history; never infer onset from package timestamps alone. |
| AGC/AEC must be broken because audio is quiet/flat | T1 directly demonstrated a prior delivery/drop mechanism. | Regular mapped input and an observed downstream processing/gain failure provide new evidence. |
| Repeat the full app/window/profile/native-recording matrix | Existing evidence already supplies those broad comparisons. | A particular missing boundary is named in advance and the smaller targeted test cannot answer it. |
| Reboot/restart/replug recovered audio, therefore fixed | Reset success is a state-boundary clue. | A scoped intervention prevents a repeatable failure under a specified validation period. |

## Completion criterion

A root-cause claim requires a measured failure boundary plus a controlled intervention whose expected effect is observed, with confounds recorded. A practical workaround can be documented earlier but must be labeled as such.

After any candidate fix, validate the four-app grid once with explicit exposure durations, at least one Meet/ChatGPT session beyond the observed pre-fix onset time, existing versus newly acquired captures, and relaunch/reload behavior. These are future acceptance checks, not a request to start another exhaustive matrix now. Long-term reliability and suspend behavior remain separate claims.
