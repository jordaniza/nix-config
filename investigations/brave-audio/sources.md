# Online evidence register

Reviewed: 2026-09-17. Use primary sources. A relevant implementation or upstream fix is not proof of the local trigger. Historical local versions are in [observations](observations.md); Brave-specific patches and build options have not been exhaustively audited.

| ID | Source and verification | Relevant evidence | Applicability limit |
| --- | --- | --- | --- |
| S01 | [Chromium 151.0.7922.173 processing_audio_fifo.cc](https://chromium.googlesource.com/chromium/src/+/refs/tags/151.0.7922.173/services/audio/processing_audio_fifo.cc), fetched through Gitiles `format=TEXT`, decoded and checked today | Full FIFO causes an overrun event and drops the incoming buffer. Corresponds to the measured T1 accounting. | Explains the observed loss point, not why input arrives in bursts. |
| S02 | [Chromium 151.0.7922.173 audio_processor_handler.h](https://github.com/chromium/chromium/blob/151.0.7922.173/services/audio/audio_processor_handler.h), raw official mirror fetched after Gitiles returned HTTP 503 | Exact-version handler declares the processing FIFO capacity used by the earlier analysis. | Do not enlarge it as a diagnosis; buffering can retain latency while hiding drops. |
| S03 | [PipeWire commit f75fc4c85c74b0bda18dee032370494f27ce18b6](https://github.com/PipeWire/pipewire/commit/f75fc4c85c74b0bda18dee032370494f27ce18b6), [patch](https://github.com/PipeWire/pipewire/commit/f75fc4c85c74b0bda18dee032370494f27ce18b6.patch), fetched and inspected today | Patch dated July 20, 2026 changes capture handling to try flushing queued client messages before skipping delivery. Its explanation describes persistent capture starvation from sibling messages. | Strong H1b candidate, not a runtime match. The documented example uses a playback sibling; capture-only client interference remains an inference. No current package inclusion or upgrade recommendation inferred. |
| S04 | [PipeWire 1.4.7 pulse-server.c](https://github.com/PipeWire/pipewire/blob/1.4.7/src/modules/module-protocol-pulse/pulse-server.c), raw upstream tag fetched today | `do_process_done` around lines 1300–1305 skips capture delivery when the client's outgoing-message queue is nonempty. | Confirms upstream version susceptibility, not the local branch's execution. Previous report inspected installed patch list; today's binary has not been re-audited. |
| S05 | [Chromium 151.0.7922.173 pulse_input.cc](https://chromium.googlesource.com/chromium/src/+/refs/tags/151.0.7922.173/media/audio/pulse/pulse_input.cc), fetched through Gitiles `format=TEXT`, decoded and checked today | Read loop breaks on null data or zero length before its normal drop call. The file also implements source-volume control. | H1a/H4 mechanisms only: no positive-length hole or causal gain change has been observed. |
| S06 | [PulseAudio 17.0 stream API](https://github.com/pulseaudio/pulseaudio/blob/v17.0/src/pulse/stream.h), public page fetched today; peek/drop contract examined in the earlier exact-version audit | Distinguishes empty reads from holes and specifies advancing past a hole. | Contract evidence, not a trace of what Brave received. |
| S07 | [Chromium user-data directory documentation](https://chromium.googlesource.com/chromium/src/+/main/docs/user_data_dir.md), fetched today | Profiles are subdirectories within a user-data directory; a separate directory can be specified at launch. | This is current architectural documentation, not proof that the user's profile test launched separate processes. Verify identities. |
| S08 | [Chromium audio-service README](https://chromium.googlesource.com/chromium/src/+/main/services/audio/README.md), fetched today | Describes Linux audio service as a separate process providing core audio device access. | Current architecture, not exact-version proof of stream-to-page ownership. Historical local shared-service PID evidence is stronger for this machine. |

The browser web fetcher failed on some exact-tag/commit URLs. Public content was retrieved directly with curl where listed; failures and successful fallbacks are retained here instead of pretending all pages were available through one tool. No screenshots, forum anecdotes or generic “disable acceleration” suggestions are being used as root-cause evidence.

Public-source snapshots and SHA-256 hashes are kept in the ignored local folder `reports/brave-audio-public-sources/`. Their [manifest](../../reports/brave-audio-public-sources/MANIFEST.md) makes retrieval reproducible. These are public code excerpts/full source files, not private audio evidence. The durable URLs, version tags and interpretations above remain available in Git even if the local cache is absent.

## Claims we are not making

- That Meet and ChatGPT use identical constraints, or Wispr avoids WebRTC/audio processing. Exact app behavior is unmeasured.
- That a flat dictation waveform means AGC failure.
- That the September 1 browser update caused original onset; the user corrected that account.
- That an upstream patch has been tested locally or a current distribution upgrade contains it.
- That ChatGPT/Meet is a necessary trigger, or that clean transcription certifies glitch-free audio.
