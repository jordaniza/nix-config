# XWayland → Wayland clipboard investigation

Updated: 2026-09-29. Status: recovered in three fresh unobserved Brave → Firefox tests; originating defect and recovery trigger unresolved. Active testing stopped.

## Objective and fixed baseline

Restore the compositor-provided shared Ctrl+C/Ctrl+V clipboard across Brave, Slack, Firefox, and Kitty. Keep CopyQ for history and the existing `cq` API, and retain `wl-copy`/`wl-paste` for pipelines. Success should not require another permanent synchronization daemon.

Preserve Brave 1.93.138, its X11/GTK 3 flags, desktop GPU routing, hardware acceleration, and dependency pins. The earlier native-Wayland RX580 corruption/freezing is a separate verified issue. Do not switch Brave's graphics backend as a clipboard experiment. PRIMARY/middle-click selection is outside the initial test scope.

This is a progression, not authorization to run all stages. Read-only diagnostics and Markdown updates are permitted. New runtime changes, logging changes, temporary GUI clients, or session termination require approval for their concrete scope. Configuration edits require a full diff preview; Nix builds, activation, and pin updates remain user-managed unless separately delegated. The earlier approval covered only stopping and restoring CopyQ, and that test is complete.

## Evidence ledger

| Observation/test | Result | What it establishes / limitation |
| --- | --- | --- |
| User tests: Brave ↔ Slack | Works | Copying works inside the XWayland group. Both applications are Chromium-based, so this alone does not exclude a shared source behavior. |
| User tests: Firefox/terminal copying | Works | Native Wayland clipboard use works in the reported workflow. |
| User tests: Brave/Slack → Firefox/terminal | Fails | The failure includes XWayland → Wayland; exact error category (old data, empty data, timeout) was not captured. |
| Step 1 reverse control: Firefox → Brave, synthetic `CB-WL-01` | User confirmed it works | Confirms Wayland → XWayland works in this session. The measured failure is one-way. |
| Stop CopyQ, verify absence, repeat failing copy | Still fails | CopyQ is not required to sustain the current failure. It could still have contributed to an earlier state transition. |
| Restore CopyQ | Completed | `env QT_QPA_PLATFORM=wayland copyq --start-server`; process/library inspection verified native Wayland. |
| Copy in Brave; remain focused for five seconds; paste in Firefox | Still fails | A simple rapid-focus-switch timing workaround did not help. This does not prove Hyprland's internal focus state is correct. |
| `wl-paste --list-types` | Advertised text formats | An offer existed. Snapshot was not tied to a known copy and proves neither freshness nor successful transfer. |
| X11 selection ownership snapshot | CLIPBOARD and CLIPBOARD_MANAGER owner both `0x200001`, no class/PID properties | Does not identify CopyQ. Hyprland itself creates a manager window in the versioned XWM source. |
| Runtime inventory | Hyprland 0.49.0; Xwayland 24.1.8; Brave 1.93.138; CopyQ 10.0.0 | Brave/Slack were XWayland; Firefox/Kitty were Wayland. |
| CopyQ process/library inspection | Native Wayland; parent and children | Three processes were not evidence of duplicate servers. Two configured startup paths do differ, but that has not been shown causal. |
| Masks and portal state | Earlier GTK backend mask absent; backend active | Previous Slack authentication repair does not explain this clipboard failure. Do not restart portals as a speculative clipboard fix. |
| Retained Hyprland log | No matching clipboard diagnostics; debug logging disabled | Absence of retained errors is not evidence of successful handoff. |
| Step 1, Brave → Firefox, synthetic `CB-X11-01` | User reported nothing pasted | Captured in the existing failing session, without restarting apps or changing settings. |
| Correlated selection metadata during the synthetic copy | X11 owner events followed by fresh Wayland text offers | At observer-relative 20.362 s and 31.129–31.130 s, X11 owner `0x1e00000` events coincided with new Wayland selections. X11 focus was nonzero during these events and became zero at 33.533 s. Offers advertised `text/plain;charset=utf-8`, `text/plain`, and X11 compatibility formats. This sample reached the offer-publication stage. |
| Explicit marker retrieval after the failed paste | X11 UTF8_STRING: exact match in 0.003 s; Wayland UTF-8 plain text: timeout at 5.005 s | `xclip -selection clipboard -out -target UTF8_STRING` could obtain the marker; `wl-paste --no-newline --type text/plain;charset=utf-8` failed to finish within the bound. Only match/status/timing was output. This locates the observed failure after offer publication, in the Wayland delivery path; it does not identify the underlying transfer defect or prove all MIME types fail. |
| Step 2 non-Chromium source: temporary X11 Kitty → Brave/Firefox | User reported it works into Brave but not Firefox | The temporary Kitty window was verified as XWayland (`clipboard-x11-test`, PID 1565039). A non-Chromium X11 source reproduces the boundary failure. |
| Step 2 explicit `CB-X11-KITTY-01` retrieval | X11: exact match in 0.004 s; Wayland UTF-8 plain text: timeout at 5.005 s | General X11 → Wayland delivery failure is supported. The second observer's initial snapshot already showed the Kitty owner and text offer; it did not capture the initial ownership change, so do not claim precise copy/offer timing for this second source. |
| Step 2 cleanup | Completed | Observer exited normally at 103.183 s. Only the temporary window was closed, after checking its class, address and PID. |
| Step 3 fresh-session test | User reported Brave → Firefox still pastes nothing; Firefox → Brave works | New Hyprland PID 1570390 (2026-09-29 12:34:18 local) and Xwayland PID 1570473 (12:34:19) confirm a real restart. Brave remained XWayland; Firefox/Kitty remained native Wayland. |
| Fresh-session CopyQ startup | CopyQ parent PID 1570466 and children started at 12:34:19 | This was normal startup, not a session without CopyQ. It establishes reproducibility under the normal startup configuration, but does not independently exclude a startup interaction. |
| Step 4B selection-event trace | User reported Brave → Firefox worked during the armed `CB-TRANSFER-01` test | Successful copy behavior occurred after the fresh session had initially failed. No configuration changes or additional app/service restarts occurred between these observations. |
| Successful-path X11 metadata | Hyprland issued TARGETS, TEXT, and UTF8_STRING conversions; the X11 owner received requests and sent non-null-property SelectionNotify events; Hyprland issued corresponding GetProperty requests | Multiple exchanges were captured (for example requestor `0x200019` at observer time 57.588 s and `0x200023` at 73.755 s). Completion notifications followed conversion requests within the same/next millisecond server timestamps. The filter excluded property replies/contents, so it did not independently verify transferred bytes. More than one selection cycle occurred; none can be uniquely assigned to a particular copied payload from metadata alone. |
| Trace cleanup and immediate untraced retrieval | Trace stopped normally at 79.322 s. Both xclip and wl-paste returned data in 0.002 s; neither matched `CB-TRANSFER-01` | Wayland retrieval no longer timed out in this snapshot. The current clipboard was no longer the agreed marker, so this is not an exact-marker success and does not prove the two returned contents were equal. Unexpected data was not printed or retained in the ledger. |
| Recovery confirmation with all observers off | User confirmed all three fresh Brave → Firefox markers (`CB-OFF-01`, `CB-OFF-02`, `CB-OFF-03`) worked | Confirms current recovery on the previously failing route without an active diagnostic observer. Does not establish a permanent fix, the recovery trigger, or post-recovery behavior of every application/format. |

### Step-1 tooling and current checkpoint

The user explicitly authorized obtaining missing tools through a temporary Nix shell. `nix shell --no-write-lock-file --inputs-from . nixpkgs#xclip` fetched xclip 0.13 from the binary cache; no repository configuration or pins were changed. Temporary Python probes under `/tmp` observe XFixes owner events and wlr-data-control selection/format events, and compare the agreed synthetic marker using standard `xclip`/`wl-paste` readers. The observer never sets a clipboard selection; text retrieval is an explicit bounded operation. Its first connection was rejected due to a client object-ID allocation error; that was corrected before the successful capture and user test. The observer automatically exits after 15 minutes.

**Current conclusion:** source text is available through X11, a fresh Wayland offer is published, but the Wayland UTF-8 text read stalls. Simple lack of publication and a Firefox-only paste fault do not explain this sample. The user confirmed the reverse control, Firefox → Brave with `CB-WL-01`, succeeds. The observer saw a Wayland selection and X11 ownership move to compositor window `0x200001`, followed by X11 focus for the paste. The observer was then stopped normally at 174.974 s. Step 1 is complete: the observed transfer failure is X11 → Wayland only. Next use a non-Chromium X11 source (step 2) to distinguish general bridge failure from shared browser-engine behavior. X11 requests for a Wayland-owned selection must be interpreted with the XWayland focus gate in mind; a background X11 read with no XWayland window focused is not an adequate reverse-direction failure test.

**Step 2 complete:** the non-Chromium X11 Kitty source reproduced the same successful X11 read / timed-out Wayland read. The evidence supports a general bridge delivery fault, not a Chromium-specific fault. Both step-1/2 observers and the temporary test window were stopped before proceeding to the user-controlled session restart.

**Stage-3 baseline:** process ancestry verified GDM → `gdm-wayland-session` → Hyprland PID 5048 (started 2026-09-16 18:01:33 local time) → Xwayland PID 5604 (18:01:34). No matching UWSM compositor/session units were found. For this direct GDM session, the user can save work, execute `hyprctl dispatch exit`, then log back into Hyprland through GDM. This has not been executed by the agent. On return verify new compositor/Xwayland processes and test new markers `CB-FRESH-X11-01` (Brave → Firefox) and `CB-FRESH-WL-01` (Firefox → Brave), with normal CopyQ startup and existing package/configuration baseline unchanged.

**Step 3 / step 4B history:** the new-session process check validated the user's unchanged one-way failure. The tool environment retained the old Hyprland instance signature; `hyprctl instances -j` identified the new instance and permitted backend verification. No configuration, package pin, graphics setting, or startup file was changed. A bounded X11 RECORD client under `/tmp/clipboard-transfer-events.py` then selected only core requests 20 (GetProperty request, not reply) and 24 (ConvertSelection), and delivered events 30/31 (SelectionRequest/SelectionNotify). It excluded all replies, property writes, and keyboard/mouse events at the server-side filter, not merely at output. The trace was armed for synthetic `CB-TRANSFER-01`; it set no clipboard ownership and changed no debug settings. The user reported successful transfer during this capture. The trace was stopped before the unobserved recovery confirmation.

**Latest checkpoint — recovered, cause unresolved:** the user confirmed all three fresh Brave → Firefox copies (`CB-OFF-01`, `CB-OFF-02`, `CB-OFF-03`) succeeded with all observers off. Active testing stops here. CopyQ remains in use; no configuration repair or additional bridge was installed. This does not establish that tracing fixed the problem; timing effects, delayed session recovery, and other unobserved state changes remain possible. The session restart had initially failed to restore copying, so it is not established as the recovery action either. No further restart, clean-startup experiment, dependency update, or bridge installation is justified by current evidence.

**On recurrence:** record the time, source/destination, and any immediately preceding suspend/resume, app launch or unusual copy operation. Preserve the failing state where practical. First reproduce with a fresh synthetic marker and bounded standard readers without the RECORD observer, then, if still failing, capture one transfer with it enabled. This comparison tests whether observation reproducibly changes the outcome and avoids losing that distinction. Do not repeat the completed broad app comparison, CopyQ stop/start, or focus-delay test without new evidence. Keep unexpected clipboard text out of output and reports.

## Working hypotheses

These are qualitative priorities, not measured probabilities.

1. **Intermittent Hyprland/Xwayland transfer-state or event-ordering fault.** Leading explanation. A fresh offer was published and direct X11 reads succeeded, but Wayland delivery stalled for Chromium and non-Chromium sources. Later the same stack transferred successfully. This localizes a stage, not a specific function or defect.
2. **Observation/timing contributed to recovery.** The first reported success after the initially failing fresh session occurred while X11 RECORD was enabled, and success persisted after disabling it. Extra X11 traffic/observation may have changed event timing or helped a later transfer escape a bad state. Equally, recovery may have coincided with observation because of elapsed time or another copy/selection transition. There was no controlled trace-on/off comparison while failing, so causality is unestablished.
3. **Startup or manager interaction triggers the transfer fault.** Still possible. CopyQ's removal did not recover the old failure, but both normal sessions started with CopyQ. No clean-before-CopyQ startup experiment was performed. There is no evidence to assign blame to its startup paths merely because they differ.
4. **Chromium-only or Firefox-only defect.** Weakened by the X11 Kitty control and direct `wl-paste` timeout respectively. The basic rapid-focus-switch explanation is also weakened by the five-second focus-delay test and by successful publication of offers during failure.

**Concrete code-level lead, not a demonstrated bug:** in the inspected upstream Hyprland v0.49.0 `XWM.cpp`, the ordinary `handleSelectionNotify` completion path calls `getTransferData(*sel)` without passing the event's requestor window. `getTransferData` chooses the first transfer with no `propertyReply`. That makes matching/ordering among multiple outstanding conversions a specific place to inspect if replies arrive out of order or an older transfer remains pending. The successful trace contained multiple text-format conversions, but did not capture the failing exchange or prove overlapping/out-of-order completions. Do not claim this code caused the observed failure, or that a later request drained/reset its queue, without corresponding evidence.

GPU transfer failure has no supporting evidence: clipboard text is negotiated and transported through display protocols, not handed between GPUs. Application graphics choices determine which protocol path is used.

## Shared test rules

- Use only fresh, explicitly synthetic markers such as `CB-X11-01` and `CB-WL-01`. A new marker distinguishes current data from a stale previous success. Do not use passwords, actual message drafts, URLs, or existing history.
- Use explicit Copy/Paste or Ctrl+C/Ctrl+V; Kitty pastes with Ctrl+Shift+V. Use X11 CLIPBOARD, not its default PRIMARY selection, for command-line probes.
- The source must have focus when copying, and the target when manually pasting. A synthetic X11 write launched from a native-Wayland terminal is not an adequate GUI-copy control: this Hyprland version checks XWayland focus.
- Record timestamp, source/target backend, focus, marker identifier, result (exact match, stale, empty, timeout, error), and duration. Report only metadata and whether the expected marker matched. Never print unexpected clipboard data.
- Bound transfer attempts (for example five seconds), and distinguish timeout from a completed empty result. Record any observer-induced recovery: requesting data can affect clipboard behavior.
- A new MIME offer is evidence of publication; the same MIME list may describe different content. MIME lists alone cannot establish freshness.
- Stop at the first stage that identifies a failing component/stage. Do not execute all later branches by default.

## Ordered progression

### 1. Capture the current failing state before any desktop restart

**Question:** Is the failure one-way, and at which boundary does a known marker disappear?

Prepare a bounded, content-free observer for X11 selection-owner changes and Wayland selection/offer metadata. Associate events with fresh copies and focus state. Instrument the synthetic text transfer only after the user has placed the agreed marker on the clipboard; compare against that marker without disclosing unexpected content. If tools are missing, prepare the exact tooling/setup proposal first. `xclip` was not found on PATH during the initial inventory; do not silently install it or invoke a Nix build.

Run Brave → Firefox with a new marker, then Firefox → Brave with a different one. Use Slack → Kitty only if needed to determine whether an observed result is application-specific; the previous user matrix already established that route fails.

Inspect, in order: did the X11 owner update; could another focused X11 client retrieve the marker; did Wayland receive a new selection offer; could a Wayland data-control reader receive the marker; could Firefox paste it?

**Branches:**

- X11 has the marker, but Wayland gets no corresponding new offer: investigate ownership notification, TARGETS negotiation, and compositor focus bookkeeping.
- Wayland gets a corresponding offer, but retrieval fails: investigate MIME negotiation, selection conversion, incremental transfer, and pipe completion.
- Direct Wayland retrieval gets the correct marker but Firefox fails: investigate the destination's chosen MIME and ordinary Wayland data-device path. A data-control client can succeed while an ordinary application still fails.
- Reverse direction works: constrain subsequent work to X11 → Wayland.
- Both directions fail: investigate shared bridge/session state, without assuming both have the same internal fault.

**Stop condition:** preserve enough correlated metadata to locate the stage, or explicitly record that existing observability cannot locate it. Do not infer successful transfers from format advertisements.

### 2. Separate browser-engine behavior from general X11 failure

**Question:** Does a non-Chromium X11 source fail across the same boundary?

With approval for a temporary test window/tooling, launch a separate Kitty instance explicitly using X11, verify its backend through compositor metadata, and copy a known marker from it. Keep normal Kitty native Wayland. Test X11 Kitty → Firefox/native Kitty and the reverse direction. Use the source window's normal copy operation first; any CLI equivalent must preserve the relevant focus conditions.

**Branches:**

- Non-Chromium X11 copying also fails: strengthens the general bridge diagnosis.
- X11 Kitty works while Brave/Slack fail: compare their advertised formats, TARGETS responses, ownership timing, and transfer behavior. Do not change GPUs or migrate the apps' backend to make the symptom disappear.

**Cleanup:** close only the temporary test window. Do not alter normal Kitty or Brave configuration.

### 3. Reset session state once, after preserving the failure

**Question:** Does the exact same software/configuration work in a fresh graphical session?

After the user saves work and approves ending the desktop session, use the session-appropriate logout method. Check whether a session manager such as UWSM owns shutdown; do not assume `hyprctl dispatch exit` is correct for every launch method. A Hyprland config reload is not a compositor/Xwayland restart. No rebuild or upgrade occurs during this test.

After logging in again, verify new Hyprland/Xwayland processes and the actual backends of the test applications. Repeat only the two synthetic cross-boundary tests. Keep the normal startup configuration for this initial comparison, and record when CopyQ and apps started.

**Branches:**

- Works immediately: establishes session-dependent recovery, not a root cause or lasting fix. Proceed to stage 4A.
- Fails immediately: reproducible with the current stack/startup configuration. Proceed to stage 4B.
- No actual new compositor/Xwayland session: test invalid; do not interpret it as a fresh-session failure.

### 4A. If a fresh session works, isolate a recurrence trigger

Record a passing baseline, then check after normal use. Do not force a broad stress matrix. If recurrence follows a specific event (for example suspend/resume, opening a particular app, copying rich content, or a large selection), repeat just that event once with synthetic content and the bounded observer armed.

**Question:** Can one event turn the same session from passing to failing?

**Result:** a controlled before/after transition provides a reproducible trigger and relevant metadata for an upstream report or targeted fix. No recurrence means recovered but unresolved; stop active experimentation and retain a recurrence capture plan. Do not declare a permanent repair.

### 4B. If a fresh session fails, isolate startup and transfer handling

Use the stage-1 failure point to pick one experiment. If startup/manager interaction is supported, propose one clean session in which CopyQ does not start, test the boundary before it runs, then start native-Wayland CopyQ and retest. This is different from removing CopyQ after the bridge is already broken. Suppressing startup requires the relevant preview/approval; do not rewrite autostart files opportunistically.

If stage 1 already demonstrates a compositor transfer fault, capture only the missing protocol diagnostics. Prefer selection metadata; avoid blanket `WAYLAND_DEBUG`, full process environments, arbitrary window titles, or clipboard-history dumps. If temporary Hyprland logging is required, preview the exact settings, capture scope, restoration, and privacy limitations before approval. An output filter alone does not prevent underlying logs from recording unrelated data.

**Branches:** failure before CopyQ starts weakens a startup role; a passing-before/failing-after transition implicates its interaction; a source-dependent MIME failure points at negotiation; correctly advertised but stalled transfers point at the transfer implementation. Follow the observed branch, not all possibilities.

### 5. Select and validate a repair

Only choose implementation after identifying a reproducible trigger or failing stage. Compare the installed version's relevant code with a specific upstream fix. An old similar issue or a newer release alone is not proof of applicability.

Possible repairs are a demonstrated startup/configuration correction, a targeted patch, or a narrowly justified compositor/Xwayland update. Preview the complete change and preserve the GPU/Brave baseline. The user runs builds and activation unless explicitly delegated. If no repair is established, report the unresolved stage and prepare a minimal upstream reproduction; do not invent a configuration fix.

A third-party bridge remains an explicitly chosen workaround, not the default outcome. It would require a separate comparison and must not be introduced while measuring the built-in bridge.

### 6. Acceptance and closure

After any repair, test three distinct successive synthetic markers in each direction for Brave ↔ Firefox and Slack ↔ Kitty, verifying actual backends. Confirm native-to-native and X11-to-X11 controls still work. Verify `wl-copy`/`wl-paste` and `cq 0` receive the intended synthetic latest entry. Test a multiline Unicode marker; if rich content was implicated, add a synthetic HTML/image case separately. Watch for transfer timeouts, stale data, duplicate-history bursts, and abnormal CPU use.

Repeat after a fresh session and, if suspend was a suspected trigger, after one approved suspend/resume. Preserve existing CopyQ history; never clear it as test cleanup. Keep the distinction between immediate acceptance and longer-term non-recurrence. Record the fix, evidence, rollback, and remaining limitations.

## Sources

- [Hyprland v0.49.0 XWM implementation](https://github.com/hyprwm/Hyprland/blob/v0.49.0/src/xwayland/XWM.cpp): selection ownership, TARGETS/focus gate, and X11/Wayland transfer code.
- [Hyprland v0.49.0 dispatchers](https://wiki.hypr.land/0.49.0/Configuring/Dispatchers/): exit behavior and UWSM shutdown caveat.
- [CopyQ known issues](https://copyq.readthedocs.io/en/latest/known-issues.html): backend-dependent limitations; current documentation does not prove behavior of the installed CopyQ 10.0.0 build.
- [Historical Hyprland issue 6132](https://github.com/hyprwm/Hyprland/issues/6132): similar symptom on an older stack, not an identified cause for this recurrence.
