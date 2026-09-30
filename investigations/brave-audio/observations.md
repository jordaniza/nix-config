# Observations and app grid

Updated: 2026-09-29. Evidence classes: **measured** = instrumented observation; **reported** = user's direct experience without a paired trace; **source** = implementation evidence, not proof that a branch executed locally. Historical measurements are not claims about today's processes.

## Four-app grid

All entries below summarize the user's September 17 report, not a new controlled experiment. “Cold Brave” means the prior Brave processes are absent; it does not necessarily mean an OS reboot. Exact Wispr and Webcam Mic Test URLs are pending.

| App | Fresh browser process | Extended use before fault | Existing tab after fault begins elsewhere | New tab/window or reload after fault | After full Brave termination/relaunch |
| --- | --- | --- | --- | --- | --- |
| Wispr Flow web demo | Works | Reportedly reliable, including extensive use | A previously working tab can keep working | Reportedly degrades; reloading the working tab loses that advantage | Works again |
| Webcam Mic Test | Works | Seems more reliable; limited long-duration testing | Not established | Included in reported cross-app degradation | Works again |
| Google Meet | Works | Can become choppy/quiet; others cannot hear clearly while incoming audio continues | The affected meeting itself degrades; other previously open Meet tabs not characterized | Included in reported cross-app degradation | Works again |
| ChatGPT voice dictation | Works | Can degrade; waveform becomes uniformly high/low and words are missed | Affected dictation degrades; other pre-existing ChatGPT tabs not characterized | Included in reported cross-app degradation | Works again |

Do not invent a measured time-to-failure, app API, channel layout, processing constraint, or repeat count. “Voice dictation” here means the user's described dictation workflow, not an assumption about ChatGPT conversational voice mode.

## New reported observations

| ID | Observation | What it supports / does not establish |
| --- | --- | --- |
| U01 | Each of the four apps can work after starting Brave with no previous Brave process running. | Healthy startup baseline is possible. No timed new baseline was collected today. |
| U02 | Extensive Wispr use alone generally does not cause the problem. Webcam Mic Test seems more reliable but is less extensively tested. | Trigger may depend on workload, concurrency, processing or stream lifecycle. Does not establish which API differs. |
| U03 | Meet or ChatGPT use often precedes the first noticeable degradation. | Candidate trigger association; neither necessity nor sufficiency is established. |
| U04 | After degradation, new instances or reloads of all four apps can fail. | Cross-site scope and capture creation/reinitialization deserve attention. Precise stream creation times are missing. |
| U05 | An already-working Wispr tab can keep working while a newly opened Wispr tab fails; reloading the working one can break it. | Strong discriminant against uniform failure of every consumer. Tab lifetime must not be equated with track/stream lifetime. |
| U06 | A new window or new profile can also fail. | Profile-local state is less persuasive, but process independence is unresolved. Profile menu versus a separate user-data directory is pending clarification. |
| U07 | Fully terminating Brave using `pkill` and restarting restores operation. | Resettable state somewhere in the browser/connection/capture lifecycle. Closing Brave also destroys its server-side streams, so this does not prove the fault resides only in Brave. This records history, not a recommendation to kill it now. |
| U08 | Native/local recording remains good during browser problems; this has been checked repeatedly. | Do not repeat as the default next test. Native PipeWire capture bypasses the Pulse compatibility path. |
| U09 | September 29: user reports the same issue on their laptop and suspects Brave/Chromium rather than hardware. | Weakens a desktop-specific hardware cause. Laptop OS/audio backend, mic identity, browser version/profile configuration, affected apps and exact old-tab/new-tab/reset pattern are not yet established. A shared external mic or software stack has not been excluded. No laptop trace or live diagnostic was collected. |

## Existing measured evidence retained

| ID | Finding | Provenance and limits |
| --- | --- | --- |
| E01 | T1: in 17.889834 s, stream C had 1,643 input callbacks, 429 downstream processing/delivery calls and 1,214 processing FIFO overruns (~73.9% discarded). Largest incoming callback gap 5,457.767 ms. One burst delivered 547 nominal 10-ms blocks in 8.094 ms. | [September 10 T1 analysis](../../reports/2026-09-10-brave-audio-trace-t1.md). Raw compressed trace SHA-256 `4b712984372360094d47283910e2fe30dd3b152f5c718a562b555d72293c86e8`. Derived counts imported from the existing analysis, not recalculated today. No raw trace copied here. |
| E02 | Two other streams had comparatively regular timing on the same Pulse mainloop thread during C's gaps. | Same T1. Rules against that whole thread simply being blocked for several seconds. Does not certify A/B waveform quality or exclude shorter scheduling effects. |
| E03 | C's delay is visible at InputController, before speech processing; per-call processing was fast. Overrun attribution and downstream lost-block accounting agree. | Same T1; source correspondence S01/S02. Does not locate the origin upstream of InputController. |
| E04 | Native `pw-record` capture was reported clean while ChatGPT dictation remained broken. | [September 10 internals, current investigation contract](../../reports/2026-09-10-brave-microphone-internals.md#current-investigation-contract-and-hypothesis-register). User listened locally; agent did not collect or listen to audio. |
| E05 | A Realtime portal credential failure was repaired using direct RTKit. RR priority 20 was verified for all three audio services. The microphone fault later recurred with priorities retained. | Same internals report, recovery and recurrence sections. Scheduling repair is real but insufficient as a general microphone fix. |
| E06 | Samson was moved from hub/controller `0000:0e:00.0` to controller `0000:11:00.4`, port `5-2`. Fault recurred without another suspend and without a newly logged USB error. | Same internals report. Old USB resume failures were real, but neither that controller nor a new suspend is necessary for every recurrence. |
| E07 | During an earlier fault, Samson and three Brave inputs were unmuted at unity gain, 48 kHz; populated graph ERR counts were zero in a short sample. Inputs shared Brave's audio-service process/Pulse client. | Same internals report. Snapshots do not rule out transient gain changes. Graph counters do not measure Chromium FIFO loss. |
| E08 | Input-volume adjustment was explicitly enabled in the observed audio-service flags. | Same internals report. Presence of an AGC-related feature is not proof of fault, nor proof it differs from the release default. |
| E09 | September 16 after reboot, Samson was absent from USB/ALSA/PipeWire and webcam was the active default. User confirmed Samson had power. Recovery was later reported, but reconnect was not captured. | [September 16 report](../../reports/2026-09-16-brave-focus-and-microphone.md#recurring-outgoing-audio-failure-after-reboot). Separate incident; do not substitute it for the same-source concurrent-good/bad evidence. |
| E10 | User corrected the onset history: voice problems preceded the September 1 Brave upgrade, which was attempted as a remedy. | [Onset timeline correction](../../reports/2026-09-10-brave-audio-onset-timeline.md). Do not revive “the update caused onset” based on package timestamps. |
| E11 | September 29 repository inspection confirms a common NixOS base, Brave package input, browser flags/extensions and PipeWire-Pulse configuration for desktop and laptop. RX580 selection and the direct-RTKit workaround are desktop-only. | Static configuration evidence, detailed below. Does not verify which revision/generation is currently activated on the laptop or its selected microphone. |

## Desktop/laptop configuration comparison — September 29

The user correctly pointed out that laptop configuration is available in this repository. Inspect it before asking the user to reconstruct shared configuration.

| Component | Shared or different? | Repository evidence |
| --- | --- | --- |
| NixOS package base | Both use the same `nixpkgs` input and lock revision through the common configuration; device detection selects the hardware module. | [flake.nix](../../flake.nix), [flake.lock](../../flake.lock) |
| Brave package | Both select `inputs.brave-nixpkgs.legacyPackages.x86_64-linux.brave`; desktop applies an additional GPU wrapper. Same package source pin, not identical wrappers or independently verified running binaries. | [Brave module](../../config/brave/default.nix) |
| Browser display flags | Both receive `--ozone-platform=x11` and `--gtk-version=3`. | [Brave module](../../config/brave/default.nix) |
| Managed browser extensions and profile-picker policy | Same declared extension list and policy. Installation/enabled state, synced preferences, browser experiments and per-profile settings were not read on the laptop. | [Brave module](../../config/brave/default.nix), [policy module](../../config/brave/nixos.nix) |
| Audio services | Both enable PipeWire, ALSA support and PulseAudio compatibility; standalone PulseAudio is disabled. Hyprland specialisation explicitly enables WirePlumber for both. | [configuration.nix](../../configuration.nix) |
| Direct RTKit workaround | Only desktop receives the `rtportal.enabled=false` / direct-RTKit settings. Laptop does not receive this workaround. | [audio-realtime.nix](../../config/audio-realtime.nix) |
| GPU override | Desktop selects RX580 for Brave and for Hyprland; laptop sets `customHardware.gpu=null`, retains automatic GPU selection and has no desktop render-node override. | [desktop hardware](../../hardware/desktop.nix), [laptop hardware](../../hardware/laptop.nix), [Brave module](../../config/brave/default.nix) |
| Hardware family | Desktop config enables AMD KVM/microcode; laptop enables Intel KVM/microcode. Microphone model/use is not established by either hardware module. | Hardware modules above |

Interpretation: the two machines are not independent tests of Brave against different OS audio backends. Their declared common components include both Brave and PipeWire-Pulse, plus browser flags/extensions. U09 weakens the desktop-specific GPU/USB/RTKit-workaround explanations while leaving H1c and H1b unresolved. Laptop runtime scheduling could differ because the RTKit workaround is desktop-only; similar symptoms alone do not prove an identical mechanism on both machines. No new broad diagnostics or automatic extension/flag changes are justified by this static comparison.

## Baseline and unresolved mappings

Last verified historical stack: Brave 1.93.138 / reported Chromium 151.0.7922.173; PipeWire/Pulse 1.4.7; WirePlumber 0.5.10; libpulse 17.0. Source matches below use these versions; today's running executable versions have not been independently re-inventoried. Nix configuration still preserves X11/GTK3 and desktop RX580 selection. RX580 display at 3440x1440@144 was verified September 16; it is not an audio fix.

September 17 service-mask inventory was unchanged: user `xdg-desktop-portal-rewrite-launchers.service`; system console-getty, gdm, network-local-commands and system audio units/sockets. No masks changed. This is a required baseline check, not a new lead or evidence of correct audio timing.

Pending: exact demo/test URLs; whether “new profile” was process-independent; whether existing Wispr retains a MediaStream/audio-source object between dictations; which microphone each compared capture actually uses; app-to-renderer-to-input-controller mapping; exact onset time and stream creation sequence. None should be silently assumed.
