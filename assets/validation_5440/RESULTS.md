# 5.4.40 / #325 - Shared rest and time-advance safety

Twenty-eight qualified native runs pass 278 assertions on GZDoom 4.14.2,
Windows 11, Vulkan 1280x720, seed 282, one engine at a time, unpaused background,
5% audio. These are behavioral/resource checks, not presented-FPS measurements.
Earlier prototype successes and failures are archived separately and not added
to this final count. Author check CA325-01 remains pending.

The same policy now governs lying down, T and Y: living visible hostiles at
1023/1024 MU block; 1025 MU, an opaque intervening wall, friendly/dead bodies
do not. Combat/siege/ground/water/busy/critical-needs rules remain. Active arcane
cloud rejects all three, including unscanned personal substeps. Ending it removes
that block; native PowerFlight takeoff must finish falling before ground rest
is valid again. The test waits 70 native tics rather than asserting instant rest.

Actual carried-bag Use and bed Used/dialogue start ordinary rest, T and Y.
The real MAP01 workshop context passes reachable and wrong-floor checks; this
is an eligibility test, not an end-to-end crafting recipe. Real MAP02 furniture
is found, reachable, available to time skip and opens its actual rest dialogue.
No author campaign acceptance is inferred from these isolated probes.

Burn, bleed, poison, disease, retained burn heat and thermal injury each pass
normal-plus-accelerated accounting and continued rest. The native windows cover
315 and 424 personal tics. The 350-W diagnostic burn contributes exactly 3150
and 4240 J integrated plus pending; its remaining duration falls by tics/35.
The burn HP control loses 9 and 12 HP, while thermal applied damage increases
216 and 290 HP in the sampled windows. Diagnostic doses are not gameplay balance.
Physical movement/firearm activity remains real-step-only; no world AI or
physics is claimed to advance during personal batches.

New attacks interrupt even with zero HP loss; regeneration cannot hide them.
New visible enemies stop T and Y. DOT and thermal death stop every mode. Separate
pain clocks preserve earlier physical pain until its own expiry; resurrection
and real MAP01 Rulo preparation clear both before subsequent real periodic damage.
Healthy forecasts remain available; effects that the model omits report an
explicit unavailable estimate without forbidding a manual destination.

A current active-rest/T save retains health, marked bag, support and serial.
A genuine pre-change active-rest save loads and can accelerate; both source
save hashes are retained. Three #339 ascent/descent/immobilized regressions pass
against the integrated runtime. Independent code review found no functional
blocker. The final two corrections replace a malformed accent in the Spanish
cloud reason and a comment, followed by localization-index regeneration.
archive.py proves those four text/index members are the only difference from
the main matrix; final native cloud, legacy-load and jump checks use the corrected
runtime. All 16,376 final-tested/source/normal package members agree.

Project validation and normal packaging pass. Reproduce with prepare.py
--directory issue325-recheck, then the shared validation_5422/run_native.ps1
using generated scripts and unique labels. Most cases use MAP99; ruloreset and
mapstation use MAP01, mapfurniture MAP02. save.cfg creates rest-current.zds;
load.cfg -LoadGame rest-current.zds reloads it. The legacy check requires a copy
of the retained old-runtime rest-legacy.zds, kept private. jump-ascent/descent/
immobilized use -Fixture jump.pk3 -Map MAPQA. Re-preparation reproduces the exact
final runtime and both fixture hashes. Native logs/configs, frozen probe sources
and hash records are archived; packages, saves, IWAD and engine are not shipped.

Earlier attempts include fixture compilation/provenance/context repairs and
the prematurely asserted cloud landing. They remain under their original
manifests, not silently counted as completed production validation. This patch
does not claim every unsupported third-party power, multiplayer session or
long campaign has been tested.
