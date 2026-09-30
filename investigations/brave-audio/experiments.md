# Experiment ledger and next decision

Updated: 2026-09-17. No live experiment is currently running. Completed rows preserve results so they are not requested again without a new question.

## Completed work

| ID | Question / intervention | Result | Limit / decision |
| --- | --- | --- | --- |
| L01 | Native PipeWire capture while browser capture fails | User reported clean local audio during broken ChatGPT capture (E04), repeatedly reinforced by U08. | Do not repeat routinely. Native capture bypasses pipewire-pulse. |
| L02 | Restore missing audio-server real-time priority | Direct RTKit configuration restored RR20, including after reboot (E05). | Audio failure recurred with priorities intact. Preserve repair; do not call it a complete audio fix. |
| L03 | Move Samson off failing USB controller | New controller verified; failure returned without another suspend/new USB errors (E06). | Do not repeat port moves to explain every occurrence. Device recreation also resets streams. |
| T1 | Locate capture timing loss with an audio-category trace | Per-stream multi-second bursts and 1,214 FIFO drops; two sibling streams regular (E01–E03). | Completed. Re-trace only to answer a new mapped boundary/onset question, not just to rediscover overruns. |
| L04 | Review package history as onset explanation | User correction established symptoms predated upgrade (E10). | Original upgrade-causation theory superseded. No informal downgrade against current profile. |
| L05 | Inspect sources for upstream delivery candidates | H1a peek/drop candidate and H1b queue-starvation patch found; relevant public sources rechecked September 17. | Code applicability is not execution evidence. No patch or upgrade tested. |
| L06 | Investigate September 16 missing Samson | Device absent and webcam default measured; subsequent improvement reported. | Separate availability episode; watcher captured no reconnect events. No proven durable fix. |
| L07 | Windows/profiles/apps and complete Brave restart | September 17 report supplies four-app grid and old-tab/new-tab asymmetry. Full restart reportedly recovers. | Not a controlled new experiment; exact process isolation and stream lifetimes unknown. Avoid broad repetition. |

## Invalid shortcuts already identified

- In the previously inspected PipeWire-Pulse 1.4.7 implementation, ordinary source-output latency fields were hard-coded zero. That query cannot locate backlog; this limitation was recorded in the [onset report](../../reports/2026-09-10-brave-audio-onset-timeline.md). Reinspect implementation if choosing a different version/metric.
- Zero `pw-top` ERR counts do not negate Chromium FIFO drops.
- `effects=NO_EFFECTS` in an internals view does not establish absence of all later WebRTC processing.
- Processing/glitch logs are not all cached/replayed in media-internals. Do not promise retrospective logs it does not expose.
- Site labels cannot be assigned from stream creation order alone.
- Recreating a tab, device or service changes state. Recovery is not proof of the layer fixed.

## P01 — Test the browser/Pulse-client isolation boundary

Status: **planned, not executed**. The first step is clarification of an already reported test, not asking the user to redo it. Exact Wispr/test URLs and the new-profile launch method were requested September 17.

Question: while a known capture remains bad in the original Brave instance, can a separately verified browser/audio-service/Pulse client capture correctly from the same source?

Why this question is new: a profile-menu window can share the existing browser infrastructure. This experiment is only justified if U06 did not already establish independent clients. If that was already tested with sufficient identity evidence, enter its result here and skip reproduction.

### Preconditions and bounded procedure

1. Use a naturally occurring bad state; do not restart the original Brave or audio services. Preserve one known-working Wispr tab if available.
2. Take one metadata snapshot to establish actual microphone, browser/audio-service PID, Pulse client and capture-stream IDs. Record what cannot be mapped. If the microphone is missing or different across captures, classify this as a routing/availability incident instead and stop P01.
3. If a new launch is needed, prepare its exact command first: same installed Brave binary and working X11/GTK3/GPU policy, separate temporary user-data directory, one agreed test page, no sign-in, no normal-profile copy, no new processing flags. Launch only with a scoped user agreement. Keep the original process running.
4. Verify distinct browser and audio-service PIDs and Pulse clients; a second window is insufficient. Use the same microphone explicitly. The clean profile introduces settings/extension differences; log them as a confound rather than claiming a pure process comparison.
5. Compare one short synthetic spoken phrase locally in the original bad capture and new independent capture, plus the preserved good tab if available. No private meeting or audio upload. If a site records/uploads by design, disclose that before use and use an agreed synthetic input.
6. Record outcomes and stop. Do not expand into four apps × multiple profiles × multiple devices. If failure is not currently reproducible, mark inconclusive and wait; no indefinite “try for a while” task.

### Predicted outcomes and decisions

| Outcome | Interpretation | Next decision |
| --- | --- | --- |
| Independent client good, original still bad, same source | Supports instance/client/stream-specific state; weakens a uniform device-wide failure. Does not distinguish browser state from per-client server starvation or profile configuration. | Focus the paired server/client timing probe on the original bad client; retain the independent one as a control. |
| Independent client also bad, older Wispr still good | Broader sensitivity to new capture creation; verify device and processing equivalence. | Prioritize server-side per-stream allocation/queue delivery and actual stream lifecycle mapping; do not declare global hardware failure. |
| Everything recovers when a new client starts | The diagnostic disturbed state. | Record exactly what changed; result is inconclusive for isolation. Do not silently repeat until a desired result appears. |
| No failure, wrong source, no distinct clients, or no mapped active capture | Preconditions not met. | Stop and record inconclusive. No new claim about root cause. |

## P02 — Locate the delay across the server/client boundary

Status: queued design work, not enabled. Hypotheses: H1b versus H1a/other client-read behavior.

Required measurements: monotonic times, an explicit mapping of one affected Pulse stream, server enqueue/send or deferred-delivery events, client read-callback/peek/drop counts and byte lengths, plus Chromium InputController delivery. Never collect PCM. Preserve a concurrently regular control stream when possible.

Interpretation: regular server delivery but bursty client consumption favors the client side; already-bursty server delivery with observed pending-message skips supports H1b. Server “pending read” messages alone do not prove the whole causal sequence. Missing events or unmatched IDs are inconclusive.

Before proposing execution, establish available diagnostics, exact version/symbols, attach privileges, overhead, privacy filters and automatic stop/restore. No working paired probe has yet been prepared. Do not ask the user to spend time collecting an unvalidated trace or repeat T1 as a substitute. A minimal H1b backport comparison is an alternative controlled experiment only after an exact diff and approval; no package upgrade is implicitly authorized.

## Result template

```text
Run ID / date and local time:
Hypothesis and new question:
Precondition: currently good/bad; same source verified?
Browser version, browser PID, audio-service PID, Pulse client/stream IDs:
App alias and tab/track creation times (unknown fields explicitly marked):
Single intervention / original state preserved:
Predicted outcomes:
Observed result / evidence path:
Confounds and unavailable measurements:
Conclusion: supported / weakened / inconclusive (not just “worked”):
Next decision and stopping condition:
Restoration / remaining background processes:
```
