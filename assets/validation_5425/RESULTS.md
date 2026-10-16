# Issue #304 — MAP06 performance and retained corpses

Status: implementation, native functional tests and performance controls complete.
CA304-01 (origin 5.4.25 / #304) passed author review on 2026-10-16, without
reported exceptions. The author authorized PR306 merge and issue closure.
Baseline: main 351b949a (5.4.24), plus the focused 5.4.25 corpse archive.
Engine: GZDoom 4.14.2, Windows 11; Ryzen 9 5950X, RTX 3070 Ti,
driver 32.0.15.7688. Frozen packages and raw run records identify exact hashes.

## Scope and reproducibility

`study.json` is the diagnostic configuration. `prepare_study.py` produces
independent native packages from the same source tree, retaining actual MAP06
geometry, 600 defenders, commander, machinery, AI, resources and collisions.
Native deployment reports one commander, 42 guns and 12 hostile machines
(six attacking guns plus six rams); the attacking guns are included in both
machine and gun totals and must not be double counted. Operators belong to the
existing Mandinga/defender populations. The player and other map content remain.
Only the diagnostic reinforcement budget changes to 6660 total / 1000 living
Mandingas. The final 60-body group is supported without discarding reserves.
Arrival of the initial 1000 is compressed; subsequent ordinary runs retain the
existing reinforcement cadence. The forced-casualty budget test is separate
from natural-battle timing and is not evidence of a naturally completed siege.

Controls use seed 116, Vulkan, 1280x720, VSync disabled, uncapped rendering,
5% audio, background rendering/audio enabled and background pausing disabled.
One engine runs at a time. The standing >=500 living-combatant policy remains
automatic and counts offscreen actors. `run_native.ps1` saves command line,
initial/final config, hardware, package hashes, UTC times and process exit.
`run_suite.ps1` alternates controls; `analyze.py` reports each repetition.

The early observation window follows 350 warm-up tics and spans 1050 tics.
It contains 1000 living Mandingas and 600 living defenders, with 954 Mandingas
changing position in the sampled seconds. It is an approach/deployment phase:
zero projectile/corpse counts must not be presented as sustained combat.
Velocity alone is unsuitable for measuring A_Chase/TryMove movement, so the
observer also compares positions. Native profiles use every 37th tic and
separate instrumented packages; inclusive scopes overlap. RenderOverlay
intervals are rendering callbacks, **not displayed FPS or GPU durations**.
PresentMon was not captured in these runs; no displayed FPS is claimed.

## Exactly what the controls change

- **Thermal off:** NPCStep returns immediately for NPCs; ThermalBody.Get returns
  null for CaelumCombatActor; NPC thermal Impulse, Motion.Path/Physics/SetVelocity
  and Motion.Support stop before thermal work. Player thermal state and global
  weather remain active. Ordinary Fire damage, burning, attacks, armor,
  Toughness, elemental effects, sound and resources remain. Cheap calls to the
  guarded functions and some nominal-effort helpers still exist. This is not
  removal of every instruction whose name contains “thermal”. Temperature
  penalties, cooling/heating, thermal damage, Air modifiers and cold-triggered
  self-warming can consequently diverge in longer runs.
- **Target 3 seconds:** only the existing TARGET_UPDATE_TICS constant changes
  from 8 to 105. Command updates, individual actions, defenders, movement,
  attack checks and other clocks remain. At high density a leader supplies a
  cached target for its group; invalid dead targets are rejected immediately,
  but acquisition can wait for the next refresh. 105/8 = 13.125 times fewer
  scheduled refresh opportunities does not imply 13.125 times faster gameplay.
- **Models:** a diagnostic MODELDEF maps CaelumPortDefender's existing world
  sprite/frame names (including CAGN/CAGC/SHGW) to accepted Domingo MD3 frames.
  There is no proxy actor, additional AI or modified equipment/collision.
  The prototype has 10689 vertices, 17447 triangles, one surface and 375 stored
  animation frames. This is a fixed visual substitute, not a final modular
  soldier or a production migration. Early natural windows may have soldiers
  outside the camera; a separate compact 600-soldier render control isolates
  presentation. Its simulation is explicitly frozen and is not a battle test.

## Production corpse archive

Only MAP06 receives the 100-visible/active-corpse FIFO budget. Excess bodies
and attached inventories retain identity/state but leave rendering, collision
links and native ticking lists. Dropped loot stays in the world. Redemption
explicitly searches the map-local dormant list and restores normal simulation
before reviving the same body. The current dead player remains available to
its camera. Old saves import existing corpses once in stable thinker order,
because historical death timestamps did not exist. Dormant bodies still consume
memory; resurrection still has work proportional to the retained bodies.
Resurrection also restarts NPC thermal scheduling: no accumulated dead interval
is integrated when either an archived or an ordinary corpse returns to life.

Native evidence: issue304-09 redemption/save/travel and the accepted-runtime
5.4.24 save migrated in issue304-compat-load-01. These cover 100 active plus
5 dormant bodies, FIFO, no body/inventory ticks while dormant, retained loot,
same-body revival, resumed ticking, re-death ordering, hub travel and normal
process exit. This native evidence is separate from the author acceptance above.

Final frozen runtime ba234504f6cd502285e040f5276edb49ae5eea3b8bea786c62632451aa417e81
passes 49 newly emitted assertions across corpse/FIFO, Redemption, save, load,
hub travel, other-map isolation, current dead-player protection and thermal-clock
tests. The real-Mandinga manual-fixture smoke reports 0 alive / 100 visible / 5
suspended, then 105 alive / 0 / 0 after Redemption. Every final process exits 0.
Some DONE counters include assertions saved before loading; 49 counts only new
PASS lines in the final runs, not those cumulative totals. The native 5.4.24
migration evidence remains applicable: the subsequent change only resets thermal
clocks during revival and does not change archive/save schema. Earlier benchmark
packages predate that reset and the explanatory comment correction; neither
changed code path runs in these no-resurrection performance controls.
The rebuilt development PK3 has the same 16193 members, sizes and CRCs as this
final frozen runtime. Static validation and the generated document index pass.

Failed development runs are retained. The author's crash report matches
issue304-05/redemption-01. Symbolized native stack: GC::SingleStep ->
GC::FullGC -> D_Cleanup. Three issues were addressed: snapshot corpses before
moving thinker lists; use a map-local non-ticking list instead of STAT_STATIC
(which survives map cleanup and is skipped on hub reload); and never create
an archive from death callbacks during level teardown. The final targeted run
restored all 105 bodies and exited with code 0. See CA-KP-016.

## Early measurements

Nominal simulation rate is 35 tics/s. Uninstrumented controls:

| Variant | Observed tics/s by repetition | Interpretation |
| --- | --- | --- |
| Ordinary thermal, 8-tic target period | 17.329; 17.372; 17.416 | Stable approach-phase baseline |
| NPC thermal disabled | 27.747; 29.494; 28.861 | Faster, but changes physiology and later workload |
| Target period 105 tics | 17.595; 19.176 | Smaller and variable wall-clock gain |
| Thermal retained; zero seal-query control | 28.150; 28.495 | Nearly the thermal-off gain with all 1000 NPC thermal states retained |

The zero-seal control is an intentionally isolated diagnostic: Delta returns
zero and is valid only with no active seal channels. Observer-v4 records zero
channels throughout those samples. This return must **not** become production
logic: active seals still require their full climate effects. A production
registry/cache should remove repeated empty list scans while retaining effects.

Early runs used observer v1 and retained the unpaused siege notice overlay.
Observer v3/v4 closes it before measurement; detailed-4-base repeats the base
at 17.416 tics/s and detailed-6-thermal-off reaches 28.861. Native position
counters confirm continued simulation. A model repetition (early-5) overlapped
package preparation and is retained as an exploratory run, excluded from
presentation conclusions. The separate render controls had no such preparation.

In 28 sampled tics from the deeper profile, CombatActor.Tick averages 36.635 ms
inclusive. NPCStep contributes 21.637 ms inclusive; the shared climate-seal
lookup contributes 20.301 ms, overlapping NPCStep/Advance/Environment.Sample.
Pure Integrate contributes 0.219 ms, shelter wind queries 0.865 ms, and siege
sight calls 6.175 ms. These overlapping figures must not be summed. The 105-tic
profile reduces sampled sight calls from 24038 to 2191 and their average from
6.175 to 0.391 ms; CombatActor.Tick falls to 30.154 ms. Sampling covers 28 tics,
not every rare burst. Instrumented rates are not the uninstrumented comparison.

Other early sampled inclusive costs (ms/tic) are demon breath bookkeeping 1.439,
potions 0.091, elemental status 0.540, siege Tick 0.927, WalkTo 0.729, actor
contact-latch update 0.050, collisions 0.0005, reinforcement Tick 0.046 and
corpse archive Tick 0.0005. Native actor Tick is 8.666 inclusive and 0.460
exclusive of instrumented descendants. Projectile work is absent in this early
phase; it must not be extrapolated to active combat. Sampling water is 0.003,
roof checks 0.046, fire sampling 0.003 and coverage 0.026. These figures describe
this scene, not upper bounds on those systems.

## Natural battle and replenishment

Two uninstrumented 7000-tic observation windows include deployment, actual
projectiles, deaths and ordinary reinforcement opportunities. Overall rates
are 10.118 tics/s with NPC thermal simulation and 29.376 without. In the common
late interval, map tics 6020 through 7385, they are **4.832 versus 24.999**.
These are simulation rates against nominal 35, not displayed FPS. This long
pair is one repetition; the repeated short approach controls above establish
their own variation rather than an invented late-run confidence interval.

Both long runs reach 1200 successfully deployed Mandingas, with 5460 still in
reserve. At the last observed tic, 875 Mandingas and 595 defenders remain alive;
100 corpses are active and 230 are dormant. The late interval has 876-972 living
Mandingas, 595-597 defenders and 3-58 projectiles. Sparse death-cause counters
record 319 Mandinga deaths through tic 7350, none caused by thermal damage.
Population and projectile counts coincide at sampled tics in this pair. That
does not prove all continuous state or future behavior remains identical after
disabling physiology. These runs do **not** exhaust the 6660 reserve; the
separate boundary control below does.

A separate saved-combat probe starts both variants from the same save near map
tic 6000, with 350 warm-up and 350 observed tics. Staging retains physiology
and bypasses only the known-empty seal lookup; staging wall time is not a
performance result (package preparation also occurred during staging). Both
measured variants use the ordinary eight-tic targeting period. Nine sampled
tics show CombatActor.Tick at 143.254 ms inclusive with thermal work versus
15.178 without. UpdateBreath is 121.354 inclusive / 47.995 exclusive versus
3.188 inclusive; this is the breath-management call path, not proof that visible
flame drawing costs that amount. Climate ApplyThermal contributes 78.587 ms
versus 0.231, while numeric Integrate contributes 0.325 versus 0.005. These
scopes overlap and must not be summed. Remaining breath-path work deserves a
separate follow-up after the active-seal registry is measured.

Other sampled active-combat costs include siege sight queries 6.789 ms, siege
Tick 1.583, elemental status 0.602, actor projectile Tick 0.071, simple elemental
projectile Tick 0.028, collision callbacks 0.007, reinforcement Tick 0.059 and
corpse archive Tick 0.038. Rare cannon shots and peak collision bursts are not
established by nine sampled tics. Instrumented probe rates (5.140/32.750 tics/s)
are attribution evidence, separate from the uninstrumented long pair above.
Both probe windows contain 933-972 Mandingas, 596 defenders, 100 active corpses,
132-171 dormant bodies and 3-11 projectiles.

Saved-control development failures are retained: stage-01 quit before a save
was available; stage-02 waits for saving and passes. Probe-01 used a native
load path incorrectly; probe-02 was stopped deliberately because commands ran
before save loading restored settings. Probe-03 waits after load and completes
both variants with normal exits. None of these failures is an accepted timing
sample or an additional production crash.

## Sprite/model render control

All four compact 600-soldier controls sustain approximately 35 tics/s with
simulation explicitly frozen. Render callback interval medians are 2.930 and
3.076 ms for sprites, versus 5.349 and 5.347 ms for the prototype MD3. The p95
values are 3.890/4.336 ms versus 6.200/6.046 ms; p99 is 5.097/5.416 versus
7.421/7.403 ms. These are callback intervals, not measured displayed frames.
The model therefore costs roughly 1.8 times the interval in this controlled
view. It is a substantial model (600 copies represent about 10.47 million
triangles before culling); this does not predict the cost of optimized models
with distance LOD or of the future modular implementation.

Final v4 captures visually confirm the actual sprite/MD3 substitution with the
same camera and 600-soldier grid, without the conversation overlay. Native bench
snapshots report CPU All 2.102 ms for sprites and 4.884 for models; S:Render is
0.264 versus 0.667 ms and Setup totals 1.180 versus 1.238. These are single native
snapshots, separate from repeated callback statistics. Native thinker overlays
show only the unfrozen player/view in this deliberately static render control.

## Finite reserve and late-corpse control

The forced-casualty control passes 61 native assertions: initial cap, deliberately
blocked placement without losing reserves, conservation through replenishment,
exact total 6660 and final group 60. It ends at 960 living Mandingas, 5700 dead
(100 active plus 5600 dormant), and 600 living defenders. The controller kills
100 per diagnostic step, including before the last 60-member group; this
explains the final 960. The ceiling is respected throughout. This is a boundary
and accumulated-corpse workload, not a naturally completed combat encounter.

## Previous evidence and candidate follow-ups

Historical #121/#128 sight/shared-perception improvements are already integrated.
#132 compared a full army with a 2000-live cap; its FPS difference did not
isolate thermal work. #140's 64.5% solver-only saving excluded environment,
actor processing and rendering, and its mass-scene comparison was cancelled.
Those figures cannot be reused as the current 1000-live result.

The current broad profile motivates measuring environmental queries separately
from numeric heat integration, then checking empty/global effect lookups,
shelter/water sampling, line-of-sight bursts and render submission. A typed
ThinkerIterator filters a linked-list traversal; it is not an indexed registry
of matching classes. Cache/registry changes may preserve gameplay better than
disabling physiology. Reduced sampling or a simplified NPC model would change
response timing or simulation and need their own focused design/acceptance.
No permanent thermal removal or targeting-cadence change is delivered here.
On 2026-10-16 the author requested implementation of the registry option in
separate issue #305. Its changes and performance results belong to that patch.

Recommended order for separately scoped work:

1. Maintain a map-owned registry of active climate-seal channels, with an empty
   fast path and correct spawn/end/load/hub invalidation. This preserves authored
   climate effects; the zero-channel control demonstrates the opportunity but
   does not validate a registry implementation. Test overlapping active seals,
   movement through walls/range, cancellation, death and old-save reconstruction.
2. Reuse environment/geometry samples only where the inputs and validity are
   shared. Weather-date, position, cover, water, equipment and local sources
   must invalidate appropriately. The numeric solver is already small here;
   another solver-only optimization would target the wrong dominant cost.
3. Consider a bounded target refresh schedule. The 3-second control sharply
   reduces sight-query work but produces only a modest total gain while climate
   lookup dominates. It also delays acquiring new targets. Preserve individual
   combat and the accepted >=500-combatant policy; measure responsiveness before
   accepting any permanent cadence change.
4. For future modular soldiers, use lower-detail geometry at distance and avoid
   submitting all prototype detail for hundreds of bodies. This benchmark does
   not establish that all 3D is slower than all sprites: it measures this mesh,
   mapping and camera. A future LOD implementation needs its own visual review.

Reduced thermal frequency or simplified NPC physiology are possible alternatives,
but change response timing or rules and require author decisions. Dormant corpses
still retain memory and save data; dropped loot remains active by design. No
measured full-map memory reduction or rare-event maximum is claimed.

## Reproduction and artifacts

Use this patch's source and fresh build directories/labels. The runners refuse
an existing engine and preserve previous run files. `prepare.py` freezes the
production runtime and corpse fixtures; `prepare_author.py` builds the real-map
manual control. `run_final_checks.ps1` executes the scoped native regression
matrix. `run_manual.ps1` opens the author control when the author returns.

For the performance study, `prepare_study.py --directory <fresh-name>` creates
the basic variants and scripts. `run_suite.ps1 -Directory <name> -Suite early`
and `-Suite render` run alternating controls. The optional preparation scripts
add deep profiles, zero-seal and natural-death controls. `run_followups.ps1`
selects the detailed/natural/capture groups; pass `-Fixture observer.pk3` for a
fresh build using the final observer. Historical observer versions remain
identified by their recorded hashes; `refresh_observer.py` never overwrites them.
`prepare_late.py` and `run_late.ps1` provide the saved-combat control, including
the native filename and post-load ordering requirements found above.

`analysis.json`, `late-on.json` and `late-off.json` summarize the raw records.
`evidence/` retains compressed logs, configuration, run metadata, manifests and
representative captures; `collect_evidence.py` records uncompressed hashes.
Generated runtimes, development engine/IWAD, saves, symbols and crash dumps stay
local in build. The final native clock change is tested separately from earlier
performance packages rather than relabeling those packages as the final binary.
