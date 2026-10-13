# Issue #258 validation — 5.3.3

Implemented against `d974f859` (5.3.2). Final evidence: **9 completed engine
runs, 50 assertions**, GZDoom 4.14.2, Windows 11, Vulkan, fixed seed 184.
The fixture map is generated locally; no engine, IWAD, WAD, PK3 or save is
distributed. Package, fixture, executable and input-save fingerprints are in
`evidence.json`; all runs have exit code 0 and zero reported failures.

| Run | Evidence |
| --- | --- |
| `core-03` | 0/5/exactly-10/>10 boundaries; cancellation/completion/interruption; all movement/action command bits; skip/equipment entry; damage, critical needs, spell expiry/cancellation; real one-portion charges; chair/bed/bag classification; external momentum; accelerated serial cadence. |
| `physics-07` | Native airborne movement, collision/landing damage, swimmable volume, drowning damage, moving floor, exact recovery cadence and passive loss triggering exhaustion. |
| `death-02` | Terminal death through the ordinary damage route, with camera/lock cleanup. |
| `sewer-01` | Actual MAP02 ground exhaustion does not qualify for the bag exception. |
| `hub-02` | MAP03 → MAP04 → MAP03: lock/camera reanchor and no stale support. |
| `old-save-01`, `current-load-02`, `current-reload-02`, `rollback-01` | Genuine 5.3.2 zero-Sleep save, idempotent reconstruction/current reload, unrelated-resource preservation and rollback using the unchanged original save. |

Static validation: `python validate_project.py`, exit 0, `errors: []`.
Normal `build_dev.ps1`: exit 0, 16,055 source files, no directory entries.
The native fixture uses the final runtime hash recorded by the collector.

Reproduce with `python assets/validation_533/prepare.py`, then the adjacent
`run_native.ps1` using a fresh label, fixture, script and optional baseline/load
arguments. Audio is 5%; native background simulation remains unpaused.

Early diagnostic runs remain under `build/issue258`; they are not final passes. Fixture corrections
included native event ordering, sufficient landing time, and a survivable drop:
the original 180-unit drop killed the player through ordinary impact damage.

Ordinary-input/visual checks are **pending**: Computer Use reported a user
Escape interruption before selecting the window, and no further app input
was sent. No screenshot or physical-controller pass is claimed. The isolated
Spanish interactive build and minimized PowerShell terminal are prepared;
`Probar258` restarts it, F6 seeds zero Sleep, F8 seeds 11%, F9 logs state and
F10 quits the fixture. Native pause presentation and campaign visual review
remain in CA258-01. These isolated checks do not certify every map location.

Author acceptance: **pending CA258-01**. The author is away; agent checks do
not stand in for manual acceptance. Keep the tracked check until explicit
author confirmation, then record its originating 5.3.3/#258 history entry.
