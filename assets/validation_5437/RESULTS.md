# 5.4.37 / #318 - Current MAP03 attribution

The normal low-sky city now admits groups of100 attackers every350tics, subject
to the approved1,000-living admission cap,6,600 cumulative total and retained
resurrection. These tests use that production deployment and600 defenders.
They never instantiate the retired6,000-simultaneous case. No gameplay
optimization is introduced by this measurement supplement.

## Conditions and populations

GZDoom4.14.2, Windows11, Ryzen9 5950X/RTX3070Ti, Vulkan1280x720, seed282,
uncapped/vsync-off, unpaused background, audio5%, one engine at a time.
The main camera is(0,320,41), yaw180; front line(-14464,-14000,41), yaw270.
Peaceful warmup140tics; siege warmup3500; every measurement covers350world
intervals. At tic135 the observer sets the actual siege calendar threshold;
production deployment remains responsible for every group.

The peaceful map has2,203 actors and no active city defenders: residents are
inside private house maps. This is not a600-active-soldier peaceful test.
Both siege windows have600 living soldiers and993-998 living Mandingas, around
8,900 actors including inventory and helpers. Census, camera and settings are
recorded at the bounds. Invulnerable observer/player; ordinary actors, inventories,
geometry, thermal rules, collisions and AI remain. No consumer hardware or
configuration guarantee is inferred.

## Unprofiled observations

| Scene | Simulation tics/s,350-interval window | Later native FPS snapshot | Walls | Flat vertices | Native CPU All,ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Peaceful forward |35.004|546|235|41,763|1.400|
| Peaceful ground,pitch75 |34.992|177|4,243|90,492|4.416|
| Siege city |34.998|48|235|41,763|3.350|
| Siege front |34.739|35|1,146|49,887|4.979|

Native bench FPS/counters are **single later snapshots**, after the command's
settling delay. They are not350-tic means, presented-frame measurements or
stable60FPS evidence. GZDoom's pinned CheckBench implementation waits5seconds
then appends counters/timing; native All is CPU-side and includes waits, not
GPU time. Do not add its overlapping thread/setup/render categories together.
No PresentMon/ETW capture was active for this matrix. Screenshots precede the
observer's bulk trace flush to avoid that flush depressing their rolling FPS.

The scene worsens when looking down even with no active army; wall processing
increases about18times. CA-KP-111 explains GZDoom's broader angular traversal at
high pitch. This result does not identify the floor texture as the cause. During
the siege, similar central geometry coexists with much greater simulation work.
Near35simulation tics/s is compatible with a displayed frame rate below60.

## Sampled method attribution

Profile02 instruments the same frozen source; non-burst methods sample every
17tics, other named burst methods run their timers on every call. The table
contains own milliseconds per sampled tic, including zero-call sampled tics.
Full inclusive/own values, call counts and every measured method are retained
in each `attribution.json`; raw records remain in compressed native logs.

| Scope | Siege city,ms | Siege front,ms |
| --- | ---: | ---: |
| CombatActor.Tick |3.076|2.922|
| PortSiege.AttackerTarget |2.801|2.590|
| ThermalService.Integrate |0.922|0.909|
| DemonService.UpdateBreath |0.741|0.649|
| PortSiege.Pulse |0.656|0.652|
| ElementalStatus.Tick |0.628|0.602|
| DemonBreath.Mouth |0.609|0.572|
| CombatActor.UpdateCombatHealthEffects |0.606|0.626|
| PortSiege.WalkTo |0.549|0.545|
| ThermalBody.Get |0.510|0.510|
| CombatActor.UpdateActorOffensiveStatistics |0.498|0.510|

These are measured **scopes**, not a partition of all CPU time or the savings
obtainable by deleting each function. Own time subtracts instrumented active
children only; uninstrumented descendants and probe overhead remain inside.
For example, AttackerTarget includes its leader/shared-target and LOS work.
The front-line CannonTarget scope contributes0.721ms per sampled tic despite
only0.143calls/tic: sparse expensive bursts deserve a separate all-call probe.
No cost justifies removing an accepted combat, inventory or thermal rule.

Profiling changes measured callback cadence: city mean21.660->23.414ms, front
23.717->25.279ms. These are wall-clock-contained UI callback intervals, **not
presented frames**, and a single pair does not separate instrumentation from
run-to-run variance. Profiled native FPS snapshots482/174/47/33 are preserved
but not substituted for the unprofiled samples. No old simultaneous-army or
different-session benchmark is used to claim an improvement ratio.

## Audit and reproduction

Eight completed cases pass the archive gate: exit0, no script/VM/assertion
failure, matching runtime/fixture hashes, unique START/WINDOW/DONE/FRAMES_END,
continuous and monotonic351world timestamps per window, valid camera and exact
settings, four benchmark blocks in chronological run order. The gate separates
each benchmark byte range and preserves its original whole-file hash.

Independent review found that callback tic labels lag world-clock boundaries.
The report now requires the entire callback interval inside the measured
wall-clock interval. Method flushes at residue16/0 are added to their common
sample tic rather than overwritten; always-timed scopes retain their separate
cadence. The original logs permit these corrections without rerunning engines.

Frozen measurement base is ac7a7143, runtime dd8a768d020548a027035c62225832658f2ca0625e33b564991ab2fa1b976347.
Profile runtime373fee5ec382a2e975c6d8a316f4a28b8c3e2b43da94ad6ff1437fa4bf7f3925;
common fixture d5549b5aeffcc9e98e0994c793ddbb574e354b7eb8041c1ca6902d2a610d911c.
The final release changes only two runtime diagnostic version labels; archive.py
checks every source member and permits exactly those label substitutions.
The final label smoke also passes one native completion assertion; all16,375
source/final-tested/normal-package members agree. Its benchmark is excluded
because packaging ran concurrently: this is a compile/smoke check only. Project
validation and the normal build pass. Neither changes the eight measured cases.

Reproduce in fresh directories with `python assets/validation_5437/prepare.py
--directory issue318-current-fresh`, then `run_matrix.py --directory
issue318-current-fresh`; add `--profile` to prepare a separate instrumented
matrix. The runner rejects reuse of completed labels and overlapping engines.
Keep packages, engine, IWAD and private saves local. Archives contain the probe
sources, per-run configuration/launch hashes, PNGs, raw compressed logs and all
analytical outputs. Earlier local base02 lacks bench output because its5-tic
post-command wait was too short; profile01 was prepared but never run. Neither
is silently counted among these eight cases.

Next work: measure target/LOS and update subscopes with matched controls, verify
any production change through presentation traces and a longer normal siege.
Full-siege playability and all existing author checks remain unresolved.

Engine reference: [GZDoom g4.14.2 hw_clock.cpp](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/rendering/hwrenderer/data/hw_clock.cpp).
