# 5.4.39 / #339 - Voluntary-jump wall cushioning

The author chose ONLY a voluntary terrestrial jump, including descent after key
release. Native takeoff now arms revision-1 pawn state. Landing/support, death,
map travel, swimming, flight or telekinesis end it; immobilization still reduces
capacity to zero. No new coefficient or immunity is introduced.

GZDoom 4.14.2, Windows 11, Vulkan 1280x720, seed 282, one engine at a time,
unpaused background and 5% audio. The matched fixtures use a real +jump and
controlled horizontal velocity/contact position on the same flat map. The
separate native run uses +forward runup and +jump, repositioning before takeoff
without replacing horizontal velocity. These are mechanics checks, not FPS tests.

| Contact | Previous runtime | Corrected runtime |
| --- | --- | --- |
| Ascent, delta 5 MU/tic | 1495.376282 J retained, 1864 HP lost, fatal | 0 J retained, 0 HP lost |
| Descent, jump released, delta 5 | same fatal result | 0 J retained, 0 HP lost |
| Fall or launch without jumping | full energy retained | full energy retained |
| Immobilized voluntary jump | full energy retained | full energy retained |
| Excess delta 20 | full 23926.020508 J retained | 10752.049621 J retained, still fatal |

The corrected excess case applies capacity 6.592728923 once and loses 14194 HP.
The normal control body's initial health is 1248; this is not a guarantee for
other loads, attributes, health, equipment or impact velocities. The native-input
case delivers 352.735792 J at delta 2.428396093, entirely cushioned, and verifies
no repeated damage while forward remains held, native contact rearming and a
subsequent ordinary landing.

Fourteen qualified current runs pass 135 assertions; seven matched baseline
runs pass 41 expectations of the previous behavior. Current evidence includes
59 reused #211 capacity/load/health/elemental/buckler/body/pressure regressions,
real midair save/load, actual pre-change airborne-save migration, hub travel,
revision idempotence, incapacitation, death, flight/support cleanup and a native
preview start/restart. Swimming/telekinesis cleanup is source-reviewed; this
matrix does not claim a live swimming, held-body or 3D-floor scenario.

Old saves load conservatively without inferring a voluntary jump. The next real
jump arms the new state. Current airborne saves retain it. Impact latches and
existing grounded predicates are unchanged. Independent code review found no
blocker. Project validation and normal packaging pass; all 16,375 source,
tested-runtime and normal-package members agree.

Author acceptance: CA339-01 (origin 5.4.39 / #339) passed on 2026-10-18, with no
reported qualifications, after the current 5.4.40 preview. This confirmation
does not change the original native run counts or tested-runtime hashes.

Reproduction: prepare.py --directory issue339-recheck; use the shared
assets/validation_5422/run_native.ps1 with the generated scripts, -Map MAPQA,
separate labels; load.cfg uses -LoadGame jump.zds. --baseline pins 29c7dcb2:src.
Load a copied baseline save through legacy.cfg using a distinct filename.
The rules script uses -Fixture rules.pk3. manual.cfg is the visible author
scenario, with instructions, real HP and F6 reset; only hunger/thirst/sleep are
held steady while waiting. M/L can also review the separate #321 legend change.

Frozen probe sources, configs, hashes, raw compressed logs and the preview PNG
are archived; binaries/IWADs/runtime packages and private saves are not shipped.
Earlier attempts remain separate: a case-insensitive Mode/mode collision made
the first descent/fall selection invalid; a read-only WaterLevel assignment
prevented one fixture compiling; the excess oracle initially sampled capacity
after lethal trauma; the first input test lacked a runup; a later assertion
incorrectly required the contact latch to stay set despite native clear tics.
None is counted as qualified evidence. The archive gate rejects failed runs.
