# Issue #252 - Seal climate and channel presentation

Version: 5.4.21. Native target: GZDoom 4.14.2, Windows 11, Vulkan.
Base: `a3b305b6` (`integration/v54-accepted-251-238`).
Implementation branch: `feat/issue252-seal-climate-extensions`.

Validation is in progress. No author acceptance, merge or issue closure is claimed.
`prepare.py` freezes normal source bytes and deterministic isolated fixtures;
`run_native.ps1` runs one engine at a time, hidden, unpaused, with 5% sound.
Fixtures, IWADs, engines and generated saves stay local under `build/`.

Current native probes cover the numerical accumulation sequences, weather/thermal
agreement and removal, native and actor-built walls/floors, armor bypass with
physical Toughness, SI continuous force, native input, gravity overlap/expiry and
flight, and all five ground-emblem/camera lifecycles. Final save/travel/performance
and author-scene evidence remain outstanding.

Early development failures are preserved rather than overwritten:
- `issue252-dev-01`: reserved ZScript identifier `state`; renamed before execution.
- `issue252-dev-02`: 75 formula checks passed, but the runner expected a differently
  ordered completion marker. Earth's zero-height endpoint reached the native floor;
  the trace now distinguishes an obstruction from contact at its destination.
  Input fixture had no equipped weapon; reused the accepted native equipment helper.
- `issue252-dev-03`: native LineTracer callbacks are data scope; the callback now
  classifies immutable actor types without calling gameplay methods.
- `issue252-dev-05`: an Actor/Player ternary required an explicit common Actor type.
- `issue252-legacy-01/seed-01`: orchestration started the engine before preparation
  finished. The log reported a missing `legacy.cfg` while packages were still being
  replaced. The author's CrashReport matches this command line, reports no active
  level and a native C0000005 read at address 0x8. ZIP SHA-256:
  `1aff7af8169cb8607ba82be4b61fbddcbfbac19aeb8980d95f179422792c2d2a`.
  The local ZIP is preserved with the failed run; it is not distributed. The runner
  now requires the final manifest, scripts and matching package hashes before
  launch, and treats missing-file output as failure. Fully prepared `seed-02` and
  the current runtime's `issue252-dev-08/upgrade-01` both completed successfully.
  This startup failure is not evidence of a crash during Seal gameplay.

Engine declarations verified from the installed 4.14.2 `gzdoom.pk3`:
`Actor.A_QuakeEx`, `QF_SHAKEONLY`, `LineTracer.Trace`/`TraceCallback`,
`TraceResults.Distance`, `PlayerInfo.cheats` and `CF_CHASECAM`.
Native quake damage/thrust are disabled; authored Earth damage and force remain
separate. The existing trap emblems and jewelry icons are owned runtime assets.
