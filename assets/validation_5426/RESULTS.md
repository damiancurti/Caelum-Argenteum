# Active climate-seal registry — issue #305 / 5.4.26

Author request: implement the optimization identified by #304 without disabling
NPC thermal simulation. Branch: feat/issue305-active-seal-registry, based on
#304's separate 41b40476 delivery (PR306). Native tests are agent evidence;
the author separately accepted #305 and authorized PR308 merge/issue closure on
2026-10-16, confirming all tests passed without reported exceptions.

## Production change

CaelumSealClimate.Delta enumerates a transient, map-scoped registry of channel
actors. Empty maps no longer traverse the full thinker list for every thermal
query. Creation/configuration registers idempotently; destruction unregisters
without allocation/rebuilding; load, old saves and hub restoration reconstruct
the index. Cache revision 1 adds no persistent actor schema or changed save data.

Only references are indexed. Eligibility, current accumulated climate, distance,
walls/floors, overlap sums and calm-wind ordering are evaluated as before. No
thermal simulation, physiology, targeting interval, combat or population rule is
disabled. The optimization runs in normal gameplay, including the automatic
>=500-combatant mode, and safely applies to smaller populations. If an external
configuration omits the registry handler, the original full-scan path remains.
That defensive fallback is code-reviewed, not separately engine-tested here.

## Functional native evidence

GZDoom 4.14.2 / Windows 11 / Vulkan; one unpaused engine, background rendering
enabled, 5% audio. Full production runtime:
`7c27a0f1d81ed0b146bd04b3d759f9028d76e3ab5ad9f4660d51c5d592255a85`.

The frozen 5.4.25 runtime (`ba234504f6cd502285e040f5276edb49ae5eea3b8bea786c62632451aa417e81`)
supplies the exact previous Delta method as an independent enumeration oracle;
unchanged Active/ClearPath helpers are shared. Accepted #252 geometry and probes
are reused rather than reconstructed.

- `issue305-02/registry-01`: 27 PASS, no FAIL. Empty/single/mixed overlapping
  channels, immediate configuration, ordering, current climate mutation, range,
  wall exclusion, owner inactivity/death/missing reference, unequipped seal,
  destruction, null cache entry, revision/map reconstruction and cancellation.
- Existing seal regressions: formulas 75, environment 12, interruptions 10,
  input 13, solid roof/floor 5 PASS. No changed elemental/climate formula.
- Current seed 2, load 11, hub departure/return 23 PASS.
- Previous-version seed 2, migration 11, migrated hub departure/return 23 PASS.
  Old/new packages use matching basenames; saves stay local under build.
- Total: 212 PASS lines on the current runtime, plus 2 on the previous-version
  seed. Every final functional run exits normally with zero failures.

Preserved failed attempt: `issue305-01/registry-01` has six failed assertions.
Registering only in PostBeginPlay was too late for immediate climate queries
after Spawn/ConfigureChannel. Adding the idempotent registration in configuration
fixed the reproduced failure. It is not included as a passing result. CA-KP-108
records the native lifecycle lesson.

## Performance method

Reuse #304's frozen MAP06 diagnostic baseline and observer, seed 116, Ryzen 9
5950X / RTX 3070 Ti, Vulkan 1280x720, VSync off, unlimited render cap. The finite
encounter budget remains 6,660 Mandingas with at most 1,000 alive, alongside normal
defenders and machinery. Only three production members differ: MAPINFO,
CaelumChannelEffect and CaelumSealClimate. The manifest records both package and
member hashes. No fixture/package build runs during timed observations.

The frozen diagnostic baseline predates #304's resurrection thermal-clock reset;
no resurrection occurs in these performance windows. The complete final 5.4.26
runtime is exercised separately by the functional tests above. Do not describe
the frozen timing control as a full campaign completion test.

Approach controls use 350 warm-up tics and 1,050 observation tics, in order
baseline/registry/registry/baseline. Combat controls load the identical saved
battle, then use 350 warm-up and 350 observation tics in the same order. No seal
is channeling in these timings; active-seal correctness is covered by the native
equivalence/regression suite. One engine runs at a time. Tics per wall second
measure simulation throughput, not displayed FPS. Profile wrappers are kept in
separate runs and their inclusive costs must not be added together.

Approach results, in measured simulation tics per wall second:

| Control | First run | Second run |
| --- | ---: | ---: |
| Original scan | 18.338 | 18.041 |
| Channel registry | 29.325 | 28.706 |

The mean improves by approximately 60%. Both controls retain 1,000 living
Mandingas, 600 defenders, 954 displaced attackers and 1,000 NPC thermal states;
no channel, corpse or projectile is present in this approach window. This is
the empty-index benefit with ordinary thermal simulation retained.

Saved-combat results:

| Control | First run | Second run |
| --- | ---: | ---: |
| Original scan | 5.271 | 5.245 |
| Channel registry | 9.749 | 9.669 |

The mean improves by approximately 85%. The common sampled interval is
6405..6720 (ten 35-tic observations per run), inside the planned 6377..6727 window.
All four runs have identical sampled populations and projectile counts:
933..972 living Mandingas, 596 defenders, 100 active corpses, 132..171 archived
corpses, 3..11 projectiles, 1,200 deployed and 5,460 still in reserve. All approach
rows also match (30 observations per run). No natural-battle completion of the
6,660 budget is claimed here. #304's separate forced budget check remains the
boundary evidence.

This removes a substantial cost but does not bring the battle to 35 tics/s.
The number of matching actors is no longer found by scanning the whole thinker
list on every climate query; other combat and thermal costs still remain.

The previous #304 saved-combat profile is reusable: its instrumented runtime
hash `253c79986773d44af019054a50aa5c0278c318e51fcafeb24420c93e221c7bab`
is byte-identical to the new study's profile-base package. It uses the same
saved battle, seed, observer, warm-up and observation bounds (6377..6727).
Only the post-measurement wait before quitting differs. The existing nine
sampled-tic profile in validation_5425/late-on.json:probe-03 is retained as prior
evidence instead of rerunning an unchanged control. Current registry profiling
is separate from the repeated uninstrumented comparisons above.

Nine sampled tics in each profiled saved-combat run give these average inclusive
costs in milliseconds per sampled tic (not per individual call):

| Function | Original scan | Registry |
| --- | ---: | ---: |
| CombatActor.Tick | 143.254 | 63.226 |
| DemonService.UpdateBreath | 121.354 | 49.477 |
| ThermalRuntime.NPCStep | 57.911 | 2.328 |
| SealClimate.ApplyThermal | 78.587 | 0.059 |
| ThermalService.Integrate | 0.325 | 0.290 |

ApplyThermal has the same 3,130 calls across those samples: its empty seal lookup
cost falls by over 99.9%. Thermal integration remains active. Inclusive entries
overlap, so their times cannot be summed. UpdateBreath still contains 47.857 ms
of exclusive time per sampled tic, versus 47.995 before: the next useful
profiling target is its remaining internal work. This does not establish that
rendering the visible breath effect is responsible. Sight costs 6.143 ms in the
new profile. No optimization of either subsystem is included in this issue.

The inherited #304 manifest originally labeled its separate 105-tic targeting
experiment. Corrected #305 metadata explicitly records the actual unchanged
8-tic cadence verified in every native START record. Original inherited
manifests and source-study settings are preserved; runtime/fixture bytes were
never changed during or between the comparisons.

## Reproduction and evidence

Run `prepare.py --directory <fresh-name>` and the shared native runner with
`registry.pk3`, `registry.cfg`, MAP99 and marker CA305 for equivalence; then run
`run_functional.ps1 -Directory <fresh-name>`. Preparation pins the previous
runtime by hash and requires its local build artifact. `prepare_performance.py`
likewise requires #304's frozen study and saved battle; it refuses existing output
directories. Use `run_performance.ps1` groups early, late and late-profile.

`analyze.py` reuses #304's window calculation; `collect.py` preserves native logs,
run metadata, configurations and manifests through its immutable evidence
collector. Text logs are deterministically compressed; evidence manifests hash
their decompressed original bytes. The logs intentionally retain CA252/CA304
markers from the shared probes. Runtime PK3s, engine, IWAD, saves and crash dumps
are local development dependencies and are not distributed with this evidence.

## Resumed delivery verification (2026-10-16)

At the author's request, delivery resumed with commit/push authorized. Comparing
every member of the tested production package against current src/ confirms
16,193 byte-identical files, with no additions or omissions. This permits reuse
of the recorded functional and performance evidence without rerunning unchanged
long benchmarks. A fresh native `resume-equivalence-01` replay passes all 27
checks and exits normally. Project validation reports no errors; the normal
build packages all 16,193 runtime members. No engine or keep-awake helper remains
active after these checks. Manual acceptance remains separate.

The author had deferred manual checks while away. Subsequently, on 2026-10-16,
the author confirmed all tests passed and authorized merge/closure. CA304-01 and
CA307-01 are recorded as accepted in HISTORY and removed from pending_test.txt.
No new control or visual presentation is introduced by #305. Temporary keep-awake
covered native tests and was released afterward.
