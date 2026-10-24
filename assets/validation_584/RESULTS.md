# Issue #496 - Second map soundtrack, 5.8.4

All nineteen author-supplied recordings are packaged for their named destinations.
The author confirmed creation with Suno and destination mapping on 2026-10-24.
No current map is rebound: these destinations await their authored maps.

## Static/audio checks

- All nineteen original WAVs are retained byte-for-byte, with source filenames
  and hashes in the catalogue/provenance. Total source size: 654,453,060 bytes.
- All nineteen OGGs fully decode; stereo 48 kHz, 56 min 47.24 s total source
  duration. Vorbis quality 6, no filters/cuts/normalization/resampling.
- Two independent conversions produce identical output bytes and provenance.
- Clean project validation and fresh documentation index.
- All 16,836 final PK3 entries match `src/` bytes and membership exactly.
  Final package SHA-256:
  `51bc22edd4f661c340398b71df44658ed184063262a075734faf94f6296f3faa`.

## Native GZDoom 4.14.2

Final `playback-03` starts each of the nineteen tracks successfully and lets it
play for one second: **19 PASS, zero failures**. `playback-02` provides an earlier
19-pass run before only the two diagnostic release strings changed. Complete
audio decoding above covers file integrity beyond the native one-second samples.
The runner records engine/GPU/config/package/fixture hashes and uses 5% audio,
unpaused background operation and a private generated room.

Preserved `playback-01` is a failed fixture startup: `Play` is a reserved ZScript
keyword, and inherited runner defaults still named the prior fixture's map.
Both fixture-only defects were corrected before the successful runs. No
production gameplay defect or music decoding failure was observed.

## Author check

CA496-MUSIC-01 remains pending. `author_terminal.ps1` opens the listening room;
F1/F2 select tracks and F3 restarts. Confirm audible quality, complete playback
and end/repeat transitions. Automatic decoding and native starts do not establish
author listening acceptance. No performance/FPS claim is made.

Rebuild with `build_dev.ps1`, then run `prepare.py`. The soundtrack preparation
script accepts the explicitly fingerprinted FFmpeg executable. `collect.py`
verifies final source/package identity, second encode and final native evidence.
Private PK3s, configurations, engine/IWAD files and helper dependencies remain
under ignored `build/`; only fixture source and evidence are tracked.
