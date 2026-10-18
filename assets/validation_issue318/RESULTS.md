# MAP06 performance audit â€” issue #318

Audit delivery: 5.4.28, 2026-10-17. Tested gameplay baseline: 5.4.27,
`006a2fff1f2505df8f4c26e123557ad885162a6e`. Issue:
[#318](https://github.com/damiancurti/Caelum-Argenteum/issues/318).

## Outcome and scope

Current variable-sky follow-up: Variable-height sky follow-up (#318): the isolated city uses 184-MU physical sky over house/shop districts and retains 1,024 MU around walls, towers and the nonresidential exterior. Original house footprints, roof heights and street widths remain. Normal source MAP06, gameplay code and the normal package are unchanged.

Fresh paired ETW means (tall opaque walls versus zoned sky): exterior forward 280.79-284.08 versus 330.73-337.53 FPS; exterior ground 103.47-114.89 versus 121.75-123.65.
Within the residential street, forward means are 268.93-272.96 versus 261.85-268.56 FPS; ground-facing means are 205.90-244.94 versus 219.61-252.60.
With 600 defenders, the 1,000-attacker city view measures 3.85-5.05 versus 6.42-7.16 FPS and the front line 3.72-4.44 versus 3.53-4.39. The unchanged opaque control is substantially slower than in the earlier session despite identical package/config/population records; the cause is not established. Compare fresh pairs only, not historical FPS as a new baseline.

All 24 current matched measurement windows complete with ETW events bracketing their trimmed QPC intervals. The same observer is used across variants; full poses/options/populations are verified. Three successful native runs log 871 passing assertions. Two earlier fixture failures are retained and qualified. Deterministic map generation and exact package comparisons pass: only MAP06 and its cartography checksum differ from the corresponding house baseline.

During this batch the author permanently retired the 6,000-simultaneous-attacker scale. The final active test was stopped immediately; three already-completed runs and the interrupted fourth remain archived outside the current comparison. Never rerun that scale. Continue with peace and 1,000/600 controls; do not invent a new production budget.

The low sky limits flight and removes standing room on closed house roofs. Streets remain thermally outdoors; shops retain their real roof and windows. These are diagnostic geometry choices pending author review (CA318-05), not adopted production restrictions. No new army budget or playable full-siege guarantee follows. Full conditions and raw distributions are in the final variable-height section below. The following house results are historical controls from their own session.

Current house follow-up: all 160 original footprints and roof heights remain;
private interiors retain real resident bodies/inventories and native doorstep
deployment. Thirteen isolated functional runs and 28 valid ETW windows pass.
With ordinary shells, peaceful forward/ground means are 36.62-37.03 /
28.54-29.76 FPS. Diagnostic full-height opaque walls improve those views to
402.03-405.19 / 165.66-166.03 FPS. The 1,000-attacker central view improves
from 6.81-8.33 to 27.97-29.88 FPS, while the front line does not improve.
Both 6,000-attacker variants remain near 0.7 FPS and 12 tics/s. CAH158 exceeds
1,000 FPS with three residents. These results support separate interiors and
real occlusion, but do not establish a playable full siege, adopt tall walls
or choose a new army budget. Full conditions, tails, profiles and exclusions
are in the final house section below.

The following paragraphs summarize earlier checkpoints, using their own matched
camera and population controls; they are not a paired before/after comparison
against the final house experiment.

The peaceful city and ground-facing slowdown are reproduced. About 35 simulation
tics/s coexist with 8â€“12 application presents/s. Removing doors helps substantially
but does not solve the problem. A diagnostic collinear-boundary merger greatly
reduces renderer wall work; it is not a production-compatible map. Full-army siege
simulation also stalls severely. The author then removed demon-breath radiation
and approved retaining absorbed contact power on burning victims. This delivery
implements that correction, with revisioned status/breath migration, alongside
the measurements and standing policy against routine global actor scans. #318
remains open for bounded deployment, further geometry work and playability acceptance.
The later conservative geometry pass is integrated; its evidence follows.
The earlier unrestricted merge remains diagnostic.

Native city doors are now integrated and verified (230 assertions): forward
ETW means 18.46-18.84 FPS, pitch75 means 12.61-12.69 FPS; still below target.
The later flat-army battery passes 40 runs. At 1,000/600, sustained means are
53.54 FPS (sprites) and 43.76 (Domingo), with normal tic throughput but visible
frame-time spikes. At 6,000/1,000, sustained means remain 0.86/0.81 FPS. The final
flat section preserves all repeats, inventory ablations and limitations.

The author requested exhaustive attribution before removing dispensable work.
This audit probes 89 selected methods (90 in the deeper radiation profile,
93 in the final contact-heat profile),
component ablations, doors, geometry, renderer controls and reference-map entries.
It does **not** establish an exact, additive partition of every CPU/GPU operation.
Unexecuted branches, uninstrumented native calls, instrumentation overhead,
scheduling interactions and compositor coverage are explicit limits. Disabling
gameplay in a diagnostic control does not establish that it is dispensable.

## Reproduction and measurement

- GZDoom 4.14.2, Windows 11, Ryzen 9 5950X, NVIDIA RTX 3070 Ti; Vulkan hardware
  polygon renderer, native 1280Ã—720 except the labelled 640Ã—360 control.
- Fresh maps, skill 2, RNG seed 116, controlled character profile, invulnerable
  player. No user campaign save is modified. Fixed input, background simulation
  and rendering enabled, master audio 0.05, VSync and frame caps disabled.
- One engine at a time; no package build during timing. Each owned process has a
  watchdog and its temporary keep-awake request is released in `finally`.
- Main peaceful view: MAP06 `(-2048,320,0)`, yaw 180, pitch 0/75. Additional
  entrance/centre positions: `(0,320,0)` and `(-4096,320,0)`. Siege reference:
  `(-14464,-14000,0)`, yaw 270. Coordinates are diagnostic observations, not new
  gameplay data. Full camera/population samples are retained in each log.
- Ordinary peaceful windows use 140 warm-up tics and 350 observation tics.
  Reference MAP01 uses its native `(-1600,0,0)`, yaw 0 entry; MAP02 uses
  `(0,0,0)`, yaw 90. Pitches are 0/75. These are fixed entry references, not full
  traversal or boss-combat certification.
- Raw `WorldTick` timestamps measure simulation progress. `RenderOverlay`
  intervals are labelled callbacks, not displayed frames. Interior samples
  exclude both boundary tics. Long windows and short siege-onset windows must
  not be treated as equally representative steady-state samples.
- PresentMon 2.6.0 ETW collection was explicitly authorized for Windows elevation.
  Matching uses PID and host-QPC log detection with 200-ms polling, trimming
  300 ms after window detection and 500 ms before end detection. It is not exact
  per-tic correlation. FPS is `1000 / mean(MsBetweenPresents)`, not a mean of
  instantaneous reciprocal FPS. Raw CSV and distributions remain available.
- ETW reports `Other`, swapchain `0x0`, `Composed: Copy with GPU GDI` here.
  Application-present cadence agrees with native callbacks; display-change
  coverage varies. These are application presents, not guaranteed monitor
  frames. GPU/wait fields do not isolate scene shader execution.
- `profilethinkers -t` is one later simulation-tic snapshot. Native `bench`
  counts/timers are a later single CPU-renderer snapshot, not window means or
  GPU duration; worker/main scopes overlap. Runs with the longer postwait leave
  enough time for its five-wall-second capture delay. Earlier missing bench
  output is retained and is not evidence of zero renderer cost.
- Selected ZScript methods are wrapped every 17th tic, with separate always-on
  startup/Pump scopes. Exclusive time subtracts only instrumented children;
  native work and probe overhead remain. Independent review verified original
  method bodies/fields in the normal profile and the deeper `AbsorbedAt` body.

## Peaceful city: doors and shared simulation

The native census has 13,618 actors, 600 soldiers, zero Mandingas, 960 door
leaves and 7,680 invisible solid door blockers. Eight blockers approximate each
leaf's collision. Their `Tick` computes a position and calls `SetOrigin` even
when the closed door has not moved. Ordinary siege target/pathfinding pulses
are absent in this peaceful phase; soldiers still run shared physiology,
statistics, equipment and collision-related work.

Matched ABBA door-removal controls destroy exactly 960 leaves and 7,680 blockers
after placement, leaving 4,978 actors and all 600 soldiers:

| View | Baseline application presents/s | No doors application presents/s |
| --- | ---: | ---: |
| Forward | 11.82, 11.35 | 19.41, 19.44 |
| Down 75Â° | 8.44, 8.68 | 12.41, 14.27 |

This is the combined door system's effect: updates, collision helpers, sprites
and resulting visibility/interactions. It does not isolate rendering or native
relink cost. Doors remain in production. A promising equivalent-work reduction
is avoiding unchanged-position relinking; moving-door/use/anti-crush/save tests
are still required. Sector doors and PolyObject sliding/swing doors are native
alternatives, not automatically faster or drop-in replacements.

The peaceful profile (`components-01-profile`, 20 sampled interior tics) reports:

| Scope | Inclusive ms/sample tic | Exclusive ms/sample tic | Calls/sample tic |
| --- | ---: | ---: | ---: |
| SlidingDoorBlocker.Tick | 6.271 | 5.761 | 7,680 |
| CombatActor.Tick | 3.421 | 1.109 | 600 |
| ThermalShelter.WindBlocked | 0.859 | 0.859 | 17.2 |
| HingedDoorLeaf.BlockerPosition | 0.510 | 0.510 | 7,680 |
| WeightPressure.WorldTick | 0.431 | 0.182 | 1 |
| CityCarbine.Tick | 0.330 | 0.191 | 600 |
| CombatActor.UpdateCombatHealthEffects | 0.245 | 0.204 | 600 |
| SlidingDoorLeaf.Tick | 0.193 | 0.193 | 960 |
| CombatActor.UpdateActorOffensiveStatistics | 0.167 | 0.167 | 600 |
| PopulationState.Refresh | 0.155 | 0.155 | 1 |

Full measured methods, calls, bursts and exact values are in `evidence/analysis.json`.
Inclusive parent/child values must not be summed as independent costs. The
post-window native thinker snapshot independently identifies blocker work
(5.305 ms) above defenders (2.591 ms); it is not the same sample/window mean.

Component variants independently disable common combat Tick, NPC thermal work,
health/offensive-stat updates, carbine Tick, contact-latch updates, population
refresh, pressure updates, interaction hints or custom HUD overlays. A common
combat-Tick ablation does not disable descendant equipment work; HUD removal
does not remove the native status bar. Carbine removal also changes visuals.
Each variant's exact injection is in `prepare.py`; manifests hash changed members.
Small single-run gains are exploratory, not established independent cost shares.

## Geometry, camera and renderer controls

MAP06 contains 86,382 linedefs, 81,469 vertices and 1,574 sectors. Its generator
removes identical-cell interior edges but retains many collinear 64-MU boundary
segments. Per-frame work, rather than map area or total walls alone, matters:

| Diagnostic snapshot | Wall-processing calls | Flats | Sprites | Portal setups |
| --- | ---: | ---: | ---: | ---: |
| Original, forward | 64,565 | 2,193 | 2,483 | 2 |
| Original, down 75Â° | 83,010 | 2,573 | 3,087 | 4 |
| Collinear merger, forward | 19,283 | 2,202 | 2,516 | 2 |
| Collinear merger, down 75Â° | 24,874 | 2,573 | 3,087 | 4 |

`Walls` counts native `HWWall.Process` calls, not unique final visible walls.
Removing doors leaves the original wall counts unchanged. GZDoom 4.14.2 broadens
the horizontal frustum with pitch; above 46Â° it removes that angular restriction.
At this FOV/aspect, 45Â° already reaches 83,010 calls, as do 47Â° and 75Â°. This is
not proof of a universal sudden slowdown at exactly 46Â°. The ordinary camera
does not use the additional vertical subsection clipping of out-of-bounds views.

Opaque one-sided walls and qualifying closed sectors can occlude angular
traversal. An actor, masked middle texture or two-sided moving PolyObject is
not an equivalent occluder. Corridors can therefore be much cheaper than an
open city despite having many walls in the complete map. MAP06 has 2,264
Line_Horizon and 752 3D-floor control definitions, without explicit map
portals/mirrors. Its measured portal setups are not classified by type and do
not establish several full-city redraws. Disabling portals drops the portal
count to zero but retains 64,565 /
83,010 wall calls; it does not remove the dominant geometry work.

Matched controls at the downward view measure about 8.48 baseline presents/s,
8.90 at 640Ã—360, 9.00 with dynamic lights/actor shadows disabled, 8.74 with the
weapon hidden and 8.92 using the user's other settings at controlled resolution/
caps. Those single runs do not establish a meaningful small gain. Freezing
non-player actors gives 22.36 forward / 16.29 downward; player/events remain
active and geometry remains expensive. None of these is a production fix.

The merger reduces linedefs to 27,900, vertices to 22,987 and referenced sides
to 50,528. It retains all sectors/things and normalized special-line records,
joining only compatible oriented, collinear degree-two boundaries. It knowingly
changes texture phase where original 64-MU pieces reset a 128-MU pattern.
Longer line endpoints can also alter `ThermalShelter.WindBlocked/Connected`
classification. It is therefore a diagnostic ablation, not proven visual,
thermal, collision-route or save equivalence. No existing campaign save was
loaded with it. Combining this geometry with removed doors still falls short
of a general 60-FPS guarantee. See final individual runs below.

The first merger retained sparse old sidedef indices and failed native loading
with `has no front sector`. Corrected v2 densely remaps referenced sides and
vertices. GZDoom's 4.14.2 UDMF loader allocates from referenced-side count and
rejects original indices at or above that count. The failure and its diagnostics are
preserved; it is not counted as a successful performance run.

## Author-supplied city examples

The local archives are `gz_bigcity.zip` (inkoalawetrust; SHA-256
69458227134e8584f4ebd23c7468f5562694dfa4f28eb26ea5f6dbc4759d54c3)
and `HGCCITY-R1.zip` (Hans George Campbell, 2023-10-01; SHA-256
711d358eff567afad570021ba3e20170faa5ebe9a322d2d8097e9032d76147d2).
The supplied forum URL could not be read because access was denied; conclusions
come from the actual local packages. No external WAD/PK3, models, textures,
IWAD or executable is incorporated into Caelum or distributed as evidence.

| Authored topology | gz_bigcity OPENCITY | HGC City MAP01 | Original MAP06 |
| --- | ---: | ---: | ---: |
| Sectors | 2,995 | 5,596 | 1,574 |
| Lines | 13,744 | 27,154 | 86,382 |
| One-sided lines | 844 | 2,889 | Not counted in this comparison |
| 3D-floor control definitions (special 160) | 83 | 9 | 752 |
| Placed things | 7,512 | 3,397 | 427 |

Placed things are not runtime population. gz_bigcity has 5,784 static trees
moved to STAT_INFO, outside the default thinking-actor iterator; the extended
census reports 1,687 thinking actors plus those trees, and zero living monsters.
HGC reports 2,889 thinking actors and 339 living monsters in its initial census.
Neither loads Caelum's 600 soldiers, physiology, custom door helpers or siege.
HGC has no MODELDEF/ZSCRIPT lump and uses substantial sector/slope architecture;
gz_bigcity combines ordinary map geometry, decorative models/voxels and a
parallax sky camera. Its SmallCityModel is a miniature monument, not proof that
whole playable houses were converted to models. Models alone are not native BSP
occluders and do not supply an arbitrary walkable house collision mesh.

The final `*-03` fixed-view runs use the same 4.14.2/Vulkan/1280x720 setup,
140 warm-up and 350 measurement tics, unpaused background and 5% audio. Position,
pitch and yaw are restored every tic; monsters remain active. Native bench FPS
below are later point samples, **not ETW frame-window means**. PresentMon is
unavailable for these examples. Separate callback distributions remain in JSON.

| Map/view, body coordinates and yaw | Native bench FPS | Wall calls | Flats | Sprites |
| --- | ---: | ---: | ---: | ---: |
| gz_bigcity street (0,2000,-8), yaw90 | 73 | 5,087 | 731 | 2,694 |
| Same, pitch75 | 39 | 11,891 | 1,718 | 7,290 |
| gz_bigcity west street (-6000,2000,-8), yaw0 | 46 | 9,067 | 1,374 | 6,791 |
| Same, pitch75 | 42 | 11,791 | 1,619 | 6,937 |
| HGC quay street (-3500,-3200,-8), yaw90, facing facade | 306 | 3,462 | 587 | 1,088 |
| Same, forced pitch75 | 184 | 7,150 | 1,293 | 1,554 |
| HGC north position (0,7000,0), yaw0, near wall | 256 | 5,576 | 1,102 | 1,004 |
| Same, forced pitch75 | 135 | 10,675 | 1,983 | 1,661 |

Additional HGC views: quay-east close garage 223 FPS (5,205 walls); riverbank
between containers 246 FPS (5,072 walls); open south avenue (0,-5600,-8), yaw0,
140 FPS (2,796 walls/550 flats/888 sprites); same forced pitch75, 134 FPS
(7,361/1,263/1,542). The open avenue captures establish a broad street view.
Their earlier window callback rates were 155.10/68.29 per second, so the later
bench points 140/134 cannot stand in for whole-window frame distributions.

All twelve windows maintain about 35 simulation tics/s. HGC disables freelook,
jumping and crouching; downward views are forced diagnostics outside its authored
rules. Captures show the northern HGC position close to a wall and the quay view
facing a facade with active monsters; these do not certify an open panoramic
city route. gz_bigcity street captures show open scenery and its downward views
also fall below 60. Total sector count therefore cannot predict the result.
Walls, flats, sprite/model work, camera direction, occlusion and simulation must
be distinguished. This comparison does not isolate texture cost independently.

Earlier runs are preserved with qualifications: initial fixtures failed UI field/
STAT_INFO qualification; both were corrected. Early labels containing 'aerial'
actually returned to ground height and are **not aerial evidence**. Early HGC
views began in the ship cabin and later bench coordinates drifted. The `*-02`
auxiliary-camera experiment produced a uniformly obscured image; all its timings
are excluded. The final `*-03` native player-camera captures were inspected.
No two engines ran concurrently in these measurements; the author's separate
instance started after the first suite and was retained until they closed it.

The author's door near (-800,-1550) is PolyObject 2, with start spot
(-832,-1588), anchor (-856,-1176), Polyobj_StartLine and two use/push faces
calling Polyobj_DoorSwing(2,-16,64,105). Its source rectangle is 48x8 MU.
The native engine supplies movement/collision; it does not approximate this leaf
with eight custom blocker actors. The nearby garage switch is a separate ACS
script moving tagged floors. Copying the example's blocking flag verbatim would
block above the door too; finite-height MAP06 collision needs separate validation.
Native non-crushing PolyObjects can still thrust bodies on obstruction. Their
active DoorSwing also rejects repeated activation rather than renewing the hold.

On 2026-10-17 the author authorized a measured native-door replacement and
explicitly waived old-save compatibility. This supersedes the migration gate
for the forthcoming door map; existing backups and prior save evidence remain.
The replacement is integrated and validated as described below.

## Integrated native doors: final checkpoint

MAP06 now retains 960 visual leaves and uses 960 finite-height native PolyObjects,
with zero custom blocker actors (7,680 removed). The authored city boundaries
and materials are unchanged by the native insertion; the final map has 1,565
sectors and 65,661 lines. Four contour lines per leaf add renderer work, but
removing the blocker simulation still improves FPS. Other maps retain their
existing door implementation. Old MAP06 saves are outside the author-approved
compatibility scope; current saves and hub transitions remain tested.

Final uninstrumented ABBA measurements use Vulkan, 1280x720, seed 116, skill 2,
600 active soldiers and the same camera (-2048,320,0), yaw 180. These are ETW
application-present means, not display refresh or callback rates:

| View | Conservative geometry + old doors | Native doors |
| --- | ---: | ---: |
| Forward | 14.58 / 10.30 FPS | 18.84 / 18.46 FPS |
| Pitch75 | 8.46 / 9.57 FPS | 12.69 / 12.61 FPS |
| One repeatedly operated pair | 9.10 FPS | 19.11 FPS |

All 12 performance runs (including two instrumented controls) maintain about
35 simulation tics/s. Baseline variability is retained; no single exact speedup
is claimed. The old blocker Tick averages 6.31277 ms/sample tic across 7,680
calls. Native retained leaf Tick averages 0.18136 ms across 960 calls; the active
pair guard averages 0.00465 ms inclusive. That guard number excludes native C++
rotation and rendering; nested profile scopes cannot be added. Native thinking
actors fall from 13,618 to 5,938. Complete intervals/tails are recorded below
and in issue318-native-perf-01/analysis.json. MAP06 still falls far short of 60 FPS.

Final native correctness evidence: issue318-native-08 has 214 new PASS assertions
across eight runs, and issue318-door-collision-01 adds 16, totaling 230. Saved DONE
counters are cumulative and are not summed. Coverage includes every leaf/face,
600 correct NPC home references and a real defender request, both axes/sides,
actual use outside the visual proxy, player touch, hold/reversal, shootable and
mid-tic moving obstruction without thrust/damage, roof passage, model alignment,
active-motion save/reload, current MAP06 save/hub and cartography. Closed/open
missiles, default hitscan and thermal rays match the legacy pair: these doors
are not opaque walls and do not block every trace type. Native tests are not
author acceptance; CA318-01/02/03 remain pending.

The deterministic verifier regenerates the map twice byte-identically, compares
its pre-native geometry prefix against the conservative checkpoint, and checks
960 IDs/contours and finite collision flags. Final MAP06 SHA256:
983eedc138878cc333fa84262f8d9d9b811fc0536ee8e5468b6ee5a14c014393.
Independent engine-source review explains the local guard ordering, floating
angle division, back-side use flag and NOINTERACTION visual fix (CA-KP-118).
Failed intermediate tests remain preserved: native01/05 fixture compilation,
native02/07 fixture timing, and native04/06 exposed the model rising to its own
midtexture floor. Final08 fixes and retests those cases.

## Mansion and sewer references

| Native entry | Forward application presents/s | Down 75Â° application presents/s |
| --- | ---: | ---: |
| MAP01 mansion | 89.93, 88.97 | 66.66, 65.28 |
| MAP02 sewers | 256.49, 261.88 | 246.74, 239.96 |

MAP01 native snapshots process 7,742 / 12,358 walls; MAP02 processes 422 / 1,226.
They are reference entry locations with normal actors, not stripped copies.
The mansion's downward p99 callback interval is around 21 ms, so average FPS
above 60 does not mean every frame meets 16.67 ms. No entire route, later hub
state or boss battle is certified by these fixed entries.

## Siege, thermal radiation and time advancement

Normal gameplay still deploys 6,000 Mandingas plus the commander synchronously.
The existing opt-in staged mode is a separate diagnostic control; it is not
automatically enabled by this audit. The production >=500-living-combatant
policy is already active and counts offscreen living combatants.

In the full-army profile, deployment/registration takes 221.14 ms inclusive.
That is a startup spike, but does not account for subsequent severe stalls.
At tic 153, two elemental-stream heat transfers take 1,657.50 ms in total.
They evaluate 13,204 recipients (6,602 per transfer); `ReceivedWatts` takes
1,485.70 ms inclusive. Its 1,452.88-ms exclusive bucket includes the originally
uninstrumented `ThermalFire.AbsorbedAt`, not merely loop overhead. A simulation
tic has a nominal 28.57-ms wall budget. The longer initial profile reaches only
tic 253, exits after 243.34 wall seconds without a completed-window marker, and
is retained as incomplete evidence. Its record does not identify a watchdog
termination; the reason for the early end is unconfirmed.
Windows also reports the measured process as unresponsive during these stalls;
continued tic progress does not establish an infinite loop or deadlock.

Each transfer scans all actors and processes every supported living recipient.
Four flame segments each repeat source-to-segment visibility; each unoccluded
segment then calls `AbsorbedAt`, with a 4Ã—4 receiver visibility grid. At that
sample this permits up to 845,056 receiver traces; the bound is not an observed
count. Cost scales with active transfers Ã— eligible recipients as well as
whole-actor scans. Caching receiver-independent segment work is a candidate,
but measured segment visibility is only about 33 ms of the much larger total.

In the previous runtime, the approved four-metre range bounds direct contact;
thermal radiation has inverse-square falloff without a finite cutoff, allows self-radiation and
normalizes received power to the emitter budget. Arbitrarily skipping distant
or offscreen bodies changes thermal rules and possibly other recipients' shares.
A Mandinga-breath-off control removes that attack/heat/resource behavior only
in a diagnostic package; its result cannot justify deleting production physiology.
Deeper attribution and full per-run outcomes follow in the generated tables.

The deeper old-runtime profile measures 1,653.35/1,828.76 ms in two Transfer
calls at tics 153/170. AbsorbedAt accounts for 1,436.86/1,612.55 ms and
26,408 calls in each sampled tic. Its 16 receiver traces per call imply 422,528
receiver traces, derived from call counts; native trace time is not isolated.
There are 62 active Mandinga streams at the end, not 6,000 simultaneous emitters.
The deep window completes, but process shutdown does not; retain the distinction
between a completed measurement window and a successfully completed process.

Disabling Mandinga breath from spawn with 6,000 attackers reduces a 35-tic onset
window from 54.90 s to 3.48 s. A longer 350-tic disabled control still takes
41.47 s. Native catch-up batches tics between renders, so this is not playable
frame presentation. Disabling all breath only after tic 140 has a 52.16-second
transition stall: StopBreath settles pending radiation synchronously. That
source-supported explanation is a hypothesis, not a separately instrumented
settlement measurement. The controls retain distinct labels and scopes.

## Production contact-heat correction and compatibility

The final breath uses BlockThingsIterator only for local contacts, preserves
native cone/wall and faction/Redemption restrictions, and divides the previous
absorption budget among current contacts before applying armor once. The victim
stores the absorbed watts with the existing unresisted burn duration and
nonstacking priority. Real tics accumulate joules; normal player/NPC thermal
updates consume them once. No per-emitter whole-world scan or forced per-tic NPC
environment update remains in this breath path. Existing resource spending,
health DOT, cold/combat activation, visuals and normal army counts remain.
Cold-triggered breath no longer warms its own emitter; this follows the explicit
no-radiation correction without inventing a replacement AI rule.

Revision 1 of status heat initializes old unknown contact power to zero.
Revision 1 of breath heat discards old paid-but-untransferred radiation once,
preserving paid-resource history and already-integrated heat. Resurrection clears
queued/active heat. Generic burns do not silently add or extend contact power.
Rest acceleration and journey forecasting are blocked while heat is active or
pending. The utility wand retains its separately approved radiation and global
Transfer scan; that remaining scan and the existing time-skip safety searches
are recorded remediation work under the new strict-exception policy.

`prepare_contact.py` freezes the exact current source and the real old runtime.
`contact_suite.py` covers direct/distant/outside-cone/walled/self reception,
multiple contacts above the shared 7-kW budget, armor once, duration/nonstacking,
fractional final tics, health-healing Toughness, logical versus real steps,
fire visuals, resurrection, isolated NPC temperature increase by joules/inertia,
scheduled queue retention, player consumption, save/reload/repeat, post-load
consumption, hub return and genuine previous-runtime upgrade/repeated upgrade.
NPC temperature checks use an isolated frozen actor and controlled elapsed time;
they do not claim exhaustive autonomous movement or campaign-hub coverage.
Earlier fixture compile/setup/path failures are preserved and explained below.

### Final 1,000-attacker result

All controls retain 600 soldiers and the commander. These are short onset
windows, not sustained-battle acceptance; ETW has only 9-12 intervals per run.

| Runtime/control | Wall seconds for 175 tics | Interior tics/s | Observed application FPS |
| --- | ---: | ---: | ---: |
| Previous radiation | 88.13 | 1.97 | 0.11 |
| Mandinga breath disabled from spawn | 6.59 | 26.50 | 2.09 |
| Final contact heat, run 1 | 8.87 | 19.71 | 1.20 |
| Final contact heat, run 2 | 8.63 | 20.90 | 1.20 |

This is a major reduction of the thermal stall, **not a playable result**.
The new runs still have maximum observed presentation intervals of 1.67/2.01 s.
Contact-stage peaceful views remain 12.55 FPS forward / 8.46 downward, with approximately
35 simulation tics/s. Remaining onset costs include moving door placement
(7.51 ms/sample tic inclusive), 7,680 blockers (7.16 ms), attacker target queries
(5.97 ms), and common combat ticking (25.21 ms, containing other profiled work).
Local breath PaidTick costs 6.30 ms/sample tic; no global Transfer call occurs.
These are ten instrumented sample tics, not exact additive uninstrumented costs.

The actual accelerated-time API succeeds from site 4: 8,193 accelerated tics,
terminal CA_EVENT_SIEGE_INTERRUPT, target reached and siege deployed. Its onset
still presents about 1.22 FPS. The earlier site-1 attempts return CA_FAST_UNSAFE
and never start; they remain failed reproduction attempts, not passing siege
tests. This does not certify the author's original save or the full 6,000-army
time-skip path. The #132 staged control averages 8.01 application FPS at about
30.72 simulation tics/s in its shorter, growing-population window; it does not
establish the required normal deployment solution.

## Integrated conservative geometry and opaque-space control

The author requested fewer redundant sectors and effective opaque boundaries.
`compact_open_geometry.py`, enabled only by the MAP06 port extension, merges
identical untagged world sectors, removes invisible boundaries within them and
joins collinear physically open boundaries. It rejects unsupported plane/tag/
vertex fields and preserves unknown linedef flags. It does not merge physical
wall or 3D-roof-edge segments, whose endpoints affect thermal shelter.

| Structure | Original | Conservative production map |
| --- | ---: | ---: |
| Sectors | 1,574 | 1,563 |
| Linedefs | 86,382 | 61,817 |
| Sidedefs | 167,492 | 118,362 |
| Vertices | 81,469 | 57,350 |
| Things | 427 | 427 |
| Separate 3D control sectors | 752 | 752 |

The pass removes 2,544 redundant invisible lines and performs 22,021 open-boundary
joins. Independent verification compares every oriented boundary on the original
grid, full physical endpoints, resolved materials/lights/sector properties,
specials, tagged sectors and things. Unoptimized serialization is byte-identical
to the original; two independent optimized generations match the delivered WAD:
`fa9a6932ef20e79115d7dc211df864400e87f529f9d1c966a26215d404efda00`.
The original owned WAD is archived with provenance under `legacy_5427`:
`8d62ef32ad584ed43e21613bc216cdfac4423469481eba8ce594da3e0b3ed26c`.

Native original/candidate/fresh-reload probes sample 3,006 authored-data-derived
positions: all houses' rooms, entrances, internal doorways, windows, roofs and
above-roof space, plus gates, gun routes/platforms, street/entry and river.
All 35,353 placement, floor/ceiling, roof/wind, 3D-volume and ten-ray records match
exactly in all four runs. These traces ignore actors and do not certify actual
NPC pathfinding or every interactive route. Street captures preserve the visible
layout. `issue318-geometry-02/{STATIC,NATIVE,samples}.json` records this evidence.

Twelve separate normal/legacy native runs pass 117 new assertions: inside MAP06
save continuation, repeated load/save, save outside with a visited MAP06 hub,
return/reload, rollback to the original package/save pair, and fresh compact-map
save/hub round trips. These peaceful-city fixtures verify the controller, population revision/counts,
first/last defender identity, inactive siege phase, one door reference/position
and player creation state; they do not certify an active siege or every identity. The normal and
`-LegacyMap06Furnished` packages differ only in maps/MAP06.wad. Compatibility
continues old geometry; it does not convert indices or reset the campaign.
Use `run_dev.bat --legacy-map06-furnished` for an already visited furnished city,
including off-map saves. Keep the original save/package pair for rollback.

`issue318-geometry-01` uses original/safe/safe/original order at pitches 0/75,
followed by separately labelled closed-house controls. All retain 600 soldiers,
960 doors and 7,680 blockers. Forward native wall work falls 64,565 to 44,775;
flats 2,193 to 1,723. Native forward counters are 12-14 original versus 14-15 safe;
window callbacks are 12.56-13.71 versus 14.80-14.97/s. Ground native wall work falls
83,010 to 58,757; flats 2,573 to 1,999. These are modest improvements, not 60 FPS.
One original ground repeat's later bench records pitch 0 despite pitch 75 at its
window and screenshot; that bench is excluded from matched ground attribution.
Confirmation runs pin pitch and record it at the window end. The baseline
confirmation partially overlapped package hashing, so confirmation timings/FPS
are excluded from attribution; their later renderer counts support geometry
inspection only. Raw anomalies and measurements remain.
The geometry PresentMon elevation was canceled by Windows and launched no
collector (`pid:null`); runner text saying "global collector" merely means local
collection was suppressed. No geometry result is claimed as ETW-presented FPS.

The separate `closed-interiors` experiment lowers 160 house interior ceilings
and closes two shared wall sectors with non-sky planes. Forward native work falls
to 1,737 walls / 145 flats, with a native counter near 60 and 59.50 callbacks/s;
the downward control has 2,863 walls / 217 flats and 58.52 callbacks/s. Captures
show the cost: facades extend upward and overhead/roof space is lost. This is
not equivalent and is **excluded from production**. Transparent walls cannot
correctly hide visible background, and invisible occluders would produce missing
scenery. Distance-triggered real closures also alter collision, shots, sight and
flight; 1,000 MU was an illustrative question, not an approved gameplay value.
No district split, dynamic closure or flight restriction is implemented.

Reproduce static/native preparation with `geometry_verify.py --directory <new>`;
run `run.py` with its generated scan/reload scripts. Build normal and furnished
legacy packages into a fresh evidence directory's current/legacy/runtime.pk3,
then run `geometry_save_suite.py --directory <new>`. Preserve old outputs and
frozen source packages. CA318-02 covers author geometry/continuity checks.

## Researched large-map optimization priorities

1. Avoid redundant stationary-door work while preserving collision and use.
2. Merge unnecessary boundaries with deliberate UV treatment and verified
   thermal/collision behavior; plan line-index/save migration before production.
3. Improve real occlusion and shorten simultaneous sightlines where the approved
   layout permits it. Remove only measured dispensable sector/3D-floor detail.
4. Evaluate physically separate interiors/districts or hub maps if needed.
   This requires state continuity and author approval for layout/siege changes;
   a portal is not free map streaming.
5. Bound ordinary deployment and eliminate repeated per-emitter/per-body work
   without silently changing combat, resources or thermal rules. Recheck both
   ongoing combat and time-skip catch-up; a fast spawn alone is insufficient.
6. Compare node-builder settings on identical geometry. ZDBSP's partition,
   split-cost and diagonal-cost tradeoffs are candidates, not a universal preset.
   Prebuilding/compression may help loading/storage without increasing runtime
   FPS. REJECT is not a rendering streaming system.

Primary sources, checked 2026-10-17 (engine code pinned to `g4.14.2`):

- [Frustum and pitch](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_drawinfo.cpp#L386)
- [BSP traversal, clipping and wall counters](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_bsp.cpp#L335)
- [Horizon/portal rendering](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_portal.cpp)
- [Renderer CPU counters](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/rendering/hwrenderer/data/hw_clock.cpp)
- [Physical map sections](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/maploader/renderinfo.cpp)
- [UDMF sidedef loading](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/maploader/udmf.cpp#L2395)
- [Sector doors](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/p_doors.cpp),
  [PolyObjects](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/po_man.cpp)
- [ZDBSP's documented node-tuning options](https://github.com/rheit/zdbsp#node-tuning-options)
- [Graf's historical renderer/play-simulation distinction](https://forum.drdteam.org/viewtopic.php?t=6180)
  is context, not a modern GZDoom settings recipe. Current engine source and
  measured controls govern the claims above. Wiki pages blocked by Anubis were
  not treated as inspected documentation.

The maintained lessons are [CA-KP-110 onward](../../docs/KNOWN_PITFALLS.md).

## Evidence and rerunning

`EVIDENCE_MANIFEST.json` records local-original and sanitized public-content
SHA-256 values. `evidence/` contains compressed native logs, run records,
config commands, manifests, closed PresentMon CSVs and selected captures.
No executable, IWAD, generated PK3, campaign save or full personal INI is
distributed. Paths/unrelated configuration are redacted. `analysis.json`
contains per-run cadence distributions, calls and startup bursts.

Use a local licensed development IWAD and installed engine. `prepare.py` creates
isolated immutable packages; `prepare_addons.py` creates the door-removal addon;
`geometry_probe.py` creates the explicitly non-equivalent geometry control.
`refresh_observer.py` freezes observer revisions. `run.py` refuses overlapping
engine processes and reused labels. `suite.py` defines the matched groups.
`analyze.py` reads raw logs and closed collector CSVs; `archive_evidence.py`
publishes sanitized evidence. Observer revisions actually used are retained in
`evidence/observers/`, with their package hashes in run records.

Example commands from the repository root (use a fresh directory/labels when
repeating; never overwrite earlier failures):

```powershell
python assets/validation_issue318/prepare.py --directory issue318-rerun --variants base profile
python assets/validation_issue318/run.py --directory issue318-rerun --variant base --label city-front --site 1 --pitch 0
python assets/validation_issue318/run.py --directory issue318-rerun --variant base --label city-down --site 1 --pitch 75
python assets/validation_issue318/analyze.py --directory issue318-rerun
```

For the old-runtime migration fixture, retain the frozen baseline package under
build/issue318-audit-02/base/runtime.pk3 (expected hash is checked explicitly).
On a fresh Windows checkout, reproduce it using a detached baseline worktree
and the owned instrumentation; neither that checkout nor its IWAD is published:

```powershell
git worktree add --detach build/issue318-baseline-source 006a2fff1f2505df8f4c26e123557ad885162a6e
python assets/validation_issue318/prepare.py --directory issue318-audit-02 --source build/issue318-baseline-source/src --variants base
python assets/validation_issue318/prepare_contact.py --directory issue318-contact-rerun
python assets/validation_issue318/contact_suite.py --directory issue318-contact-rerun
```

The expected baseline hash deliberately rejects different bytes, including a
different checkout line-ending policy. Keep the original Windows checkout
conventions when reproducing that exact fixture. Functional runs do not require
ETW; their `--global-presentmon` option suppresses starting a local collector.

If ETW collection is unavailable, callbacks remain labelled callbacks; no
presented-FPS value is invented. The audit does not claim input-to-photon latency,
an exact GPU breakdown or comprehensive save regression of hypothetical fixes.

## Final individual measurements and validation

<!-- MEASUREMENTS_START -->
Application-present intervals are ETW observations, not monitor refresh. N<30 is a short sample: tails are omitted here; raw descriptive quantiles remain in JSON. A transition stall may lie outside the trimmed ETW intervals; consult full native window/tic timestamps and raw CSV too.

### issue318-audit-02

| Run | Window/process | Tics/s | App FPS | N | Mean ms | p95 ms | p99 ms | Max ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| army1000-01-old | complete | 1.97 | 0.11 | 9 | 9236.92 | - | - | 10846.09 |
| army1000-02-off | complete | 26.50 | 2.09 | 12 | 478.09 | - | - | 1528.35 |
| army1000-03-old-profile | incomplete/failed | - | - | 0 | - | - | - | - |
| components-02-base | complete | 34.87 | 12.27 | 113 | 81.53 | 90.65 | 94.86 | 99.44 |
| components-04-base | complete | 34.94 | 12.21 | 110 | 81.89 | 104.89 | 122.81 | 126.58 |
| components-15-base | complete | 35.07 | 11.58 | 107 | 86.35 | 118.00 | 129.31 | 145.61 |
| doors-01-base | complete | 35.16 | 11.82 | 109 | 84.59 | 90.92 | 96.09 | 107.36 |
| doors-02-base | complete | 35.11 | 19.41 | 176 | 51.52 | 58.16 | 59.78 | 63.51 |
| doors-03-base | complete | 35.07 | 19.44 | 180 | 51.44 | 57.09 | 59.00 | 63.03 |
| doors-04-base | complete | 35.12 | 11.35 | 105 | 88.13 | 104.27 | 109.48 | 111.47 |
| doors-05-base | complete | 34.97 | 8.44 | 78 | 118.46 | 138.17 | 144.76 | 151.37 |
| doors-06-base | complete | 34.96 | 12.41 | 115 | 80.60 | 118.36 | 137.10 | 158.03 |
| doors-07-base | complete | 34.96 | 14.27 | 129 | 70.08 | 77.35 | 78.97 | 92.60 |
| doors-08-base | complete | 34.91 | 8.68 | 78 | 115.20 | 139.09 | 144.73 | 150.10 |
| encounter-01-base | complete | 0.62 | 0.03 | 1 | 31218.37 | - | - | 31218.37 |
| geometry-01-base | incomplete/failed | - | - | 0 | - | - | - | - |
| geometry2-01-base | complete | 35.03 | 20.04 | 185 | 49.90 | 63.38 | 75.36 | 79.53 |
| geometry2-02-base | complete | 35.07 | 16.72 | 154 | 59.81 | 74.65 | 99.88 | 106.66 |
| geometry2-03-base | complete | 35.07 | 15.32 | 138 | 65.27 | 80.16 | 85.02 | 86.92 |
| geometry2-04-base | complete | 35.03 | 20.94 | 194 | 47.75 | 58.26 | 61.38 | 70.20 |
| geometry2-05-base | complete | 35.07 | 33.46 | 309 | 29.89 | 35.12 | 38.19 | 39.28 |
| geometry2-06-base | complete | 34.97 | 26.09 | 241 | 38.33 | 45.25 | 50.57 | 60.95 |
| pitch-01-base | complete | 34.93 | 8.76 | 81 | 114.15 | 147.23 | 154.61 | 162.22 |
| pitch-02-base | complete | 35.10 | 7.93 | 73 | 126.11 | 147.33 | 163.19 | 179.47 |
| pitch-03-base | complete | 34.94 | 8.18 | 74 | 122.19 | 137.71 | 144.26 | 150.78 |
| pitch-04-base | complete | 35.06 | 8.40 | 78 | 119.06 | 132.46 | 138.73 | 146.23 |
| portals-01-base | complete | 35.01 | 11.57 | 107 | 86.47 | 102.66 | 111.12 | 126.72 |
| portals-02-base | complete | 35.18 | 8.81 | 81 | 113.52 | 126.08 | 135.93 | 146.53 |
| references-01-base | complete | 34.99 | 89.93 | 832 | 11.12 | 12.90 | 14.10 | 20.00 |
| references-02-base | complete | 35.02 | 66.66 | 617 | 15.00 | 17.61 | 20.78 | 23.87 |
| references-03-base | complete | 35.05 | 65.28 | 604 | 15.32 | 18.47 | 21.07 | 26.08 |
| references-04-base | complete | 35.01 | 88.97 | 822 | 11.24 | 13.04 | 13.96 | 14.31 |
| references-06-base | complete | 34.99 | 256.49 | 2371 | 3.90 | 5.48 | 6.12 | 7.08 |
| references-07-base | complete | 35.00 | 246.74 | 2231 | 4.05 | 5.31 | 6.17 | 7.85 |
| references-08-base | complete | 35.00 | 239.96 | 2171 | 4.17 | 5.71 | 6.80 | 8.67 |
| references-09-base | complete | 34.99 | 261.88 | 2420 | 3.82 | 5.43 | 6.54 | 8.85 |
| render-01-base | complete | 34.86 | 11.74 | 108 | 85.16 | 97.84 | 100.65 | 106.89 |
| render-02-base | complete | 34.92 | 19.82 | 183 | 50.44 | 55.55 | 64.49 | 67.33 |
| render-03-base | complete | 34.85 | 8.48 | 79 | 117.92 | 136.84 | 144.78 | 147.41 |
| render-04-base | complete | 34.97 | 14.10 | 130 | 70.94 | 79.97 | 83.10 | 93.24 |
| render-05-base | complete | 34.96 | 22.36 | 206 | 44.72 | 50.41 | 53.28 | 76.14 |
| render-06-base | complete | 35.12 | 16.29 | 151 | 61.40 | 66.91 | 68.63 | 73.97 |
| render-07-base | complete | 34.91 | 8.90 | 82 | 112.32 | 136.68 | 144.88 | 146.61 |
| render-08-base | complete | 35.07 | 9.00 | 81 | 111.07 | 118.63 | 126.58 | 128.75 |
| render-09-base | complete | 35.01 | 8.74 | 81 | 114.37 | 130.64 | 137.89 | 141.28 |
| render-10-base | complete | 34.95 | 8.92 | 82 | 112.15 | 121.37 | 125.00 | 130.04 |
| render-11-base | complete | 35.03 | 10.46 | 96 | 95.61 | 109.92 | 130.50 | 136.72 |
| render-12-base | complete | 34.97 | 8.65 | 80 | 115.60 | 131.53 | 139.52 | 147.89 |
| render-13-base | complete | 35.07 | 11.73 | 109 | 85.23 | 95.94 | 104.56 | 112.43 |
| render-14-base | complete | 35.21 | 8.32 | 77 | 120.16 | 135.57 | 141.46 | 142.25 |
| staged-01-base | complete | 30.72 | 8.01 | 175 | 124.91 | 572.39 | 953.04 | 1150.28 |
| components-03-blockers-off | complete | 35.11 | 17.12 | 155 | 58.41 | 64.43 | 69.26 | 74.08 |
| components-05-blockers-stationary | complete | 35.02 | 15.90 | 147 | 62.90 | 75.62 | 82.87 | 86.30 |
| encounter-02-breath-off | complete | 0.60 | 0.58 | 1 | 1738.92 | - | - | 1738.92 |
| components-09-carbine-off | complete | 35.03 | 10.99 | 102 | 90.96 | 111.48 | 117.77 | 119.90 |
| components-10-contacts-off | complete | 35.13 | 12.41 | 115 | 80.55 | 93.70 | 106.64 | 109.98 |
| components-13-hints-off | complete | 35.06 | 13.00 | 120 | 76.91 | 89.96 | 93.16 | 98.78 |
| components-14-hud-off | complete | 35.19 | 12.82 | 118 | 77.99 | 93.08 | 105.24 | 111.92 |
| mandinga-02-off | complete | 9.86 | 0.55 | 1 | 1814.44 | - | - | 1814.44 |
| mandinga-03-off-long | complete | 8.42 | 0.49 | 19 | 2053.35 | - | - | 4488.92 |
| components-06-npc-tick-off | complete | 34.89 | 14.24 | 132 | 70.23 | 83.61 | 89.58 | 94.43 |
| components-11-population-off | complete | 34.97 | 13.00 | 120 | 76.93 | 85.94 | 91.01 | 100.81 |
| components-12-pressure-off | complete | 34.91 | 13.38 | 121 | 74.76 | 84.11 | 85.31 | 92.09 |
| components-01-profile | complete | 35.07 | 12.11 | 111 | 82.56 | 90.12 | 97.05 | 109.49 |
| references-05-profile | complete | 34.98 | 88.05 | 810 | 11.36 | 13.42 | 14.88 | 16.91 |
| references-10-profile | complete | 35.01 | 244.48 | 2245 | 4.09 | 5.67 | 6.37 | 7.25 |
| siege-01-profile | incomplete/failed | - | - | 0 | - | - | - | - |
| skip-01-profile | incomplete/failed | 34.23 | - | 0 | - | - | - | - |
| smoke-profile-02 | complete | 34.86 | 10.52 | 14 | 95.07 | - | - | 111.46 |
| mandinga-04-deep-full | window complete / exit failed | 0.61 | - | 0 | - | - | - | - |
| mandinga-01-profile-off | complete | 9.05 | 0.54 | 1 | 1863.05 | - | - | 1863.05 |
| components-08-stats-off | complete | 34.97 | 13.56 | 126 | 73.72 | 82.75 | 87.37 | 89.94 |
| components-07-thermal-off | complete | 34.90 | 13.97 | 129 | 71.59 | 83.25 | 92.23 | 93.74 |

### issue318-contact-01

| Run | Window/process | Tics/s | App FPS | N | Mean ms | p95 ms | p99 ms | Max ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| army1000-new-01 | complete | 19.44 | 1.15 | 8 | 871.99 | - | - | 1786.39 |
| army1000-new-02 | complete | 19.69 | 1.16 | 9 | 865.15 | - | - | 1774.40 |
| army1000-new-profile-01 | complete | 19.34 | 1.16 | 9 | 863.41 | - | - | 1504.85 |

### issue318-contact-02

| Run | Window/process | Tics/s | App FPS | N | Mean ms | p95 ms | p99 ms | Max ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| army1000-final-01 | complete | 19.71 | 1.20 | 10 | 834.22 | - | - | 1669.15 |
| army1000-final-02 | complete | 20.90 | 1.20 | 9 | 835.15 | - | - | 2013.40 |
| army1000-skip-01 | incomplete/failed | 34.97 | - | 0 | - | - | - | - |
| army1000-skip-02 | complete | 20.93 | 1.22 | 9 | 820.75 | - | - | 1502.96 |
| army1000-final-profile | complete | 18.75 | 1.12 | 9 | 892.81 | - | - | 1820.86 |
| city-final-down | complete | 34.89 | 8.46 | 77 | 118.16 | 136.48 | 146.22 | 150.26 |
| city-final-front | complete | 34.91 | 12.55 | 114 | 79.67 | 92.33 | 95.18 | 95.97 |

### issue318-native-perf-01

| Run | Window/process | Tics/s | App FPS | N | Mean ms | p95 ms | p99 ms | Max ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| active-pair | complete | 35.13 | 9.10 | 82 | 109.95 | 157.34 | 183.44 | 185.63 |
| idle-0-1 | complete | 34.97 | 14.58 | 132 | 68.61 | 78.62 | 83.46 | 93.80 |
| idle-0-4 | complete | 34.98 | 10.30 | 95 | 97.09 | 135.68 | 146.43 | 147.97 |
| idle-75-1 | complete | 35.06 | 8.46 | 78 | 118.26 | 147.60 | 169.48 | 174.24 |
| idle-75-4 | complete | 34.92 | 9.57 | 88 | 104.53 | 114.25 | 117.98 | 118.22 |
| active-pair | complete | 34.96 | 13.33 | 123 | 75.05 | 86.26 | 93.62 | 97.14 |
| active-pair | complete | 35.04 | 19.11 | 177 | 52.32 | 61.18 | 66.62 | 67.35 |
| idle-0-2 | complete | 35.04 | 18.84 | 170 | 53.07 | 61.95 | 65.34 | 69.08 |
| idle-0-3 | complete | 34.92 | 18.46 | 171 | 54.17 | 61.90 | 70.77 | 82.99 |
| idle-75-2 | complete | 35.02 | 12.69 | 118 | 78.83 | 89.44 | 97.77 | 102.75 |
| idle-75-3 | complete | 34.96 | 12.61 | 116 | 79.32 | 92.43 | 95.54 | 103.55 |
| active-pair | complete | 35.03 | 17.05 | 157 | 58.67 | 67.69 | 71.59 | 77.78 |

### Final 1,000-attacker profile

10 sampled onset tics; inclusive/exclusive times include probe overhead. Do not add nested inclusive costs. No ElementalStream.Transfer call occurs in this window.

| Method | Inclusive ms/sample tic | Exclusive ms/sample tic | Calls/sample tic |
| --- | ---: | ---: | ---: |
| CaelumHingedDoorLeaf.PlaceAtProgress | 7.5100 | 7.4929 | 32.00 |
| CaelumSlidingDoorBlocker.Tick | 7.1619 | 6.6476 | 7680.00 |
| CaelumPortSiege.AttackerTarget | 5.9686 | 5.9686 | 282.20 |
| CaelumCombatActor.Tick | 25.2077 | 3.4192 | 1601.00 |
| CaelumThermalFire.AbsorbedAt | 2.0359 | 2.0359 | 181.00 |
| CaelumElementalStream.Contact | 1.9549 | 1.8677 | 4562.70 |
| CaelumThermalShelter.WindBlocked | 1.3000 | 1.3000 | 45.70 |
| CaelumDemonBreath.PaidTick | 6.3042 | 1.2011 | 62.00 |
| CaelumDemonBreath.Mouth | 0.7988 | 0.7988 | 1125.00 |
| CaelumDemonService.UpdateBreath | 8.0577 | 0.7772 | 1601.00 |
| CaelumElementalStatus.Tick | 0.7627 | 0.7100 | 1602.00 |
| CaelumWeightPressure.MassAbove | 0.6778 | 0.6778 | 1602.00 |
| CaelumCombatActor.UpdateCombatHealthEffects | 0.7461 | 0.6410 | 1601.10 |
| CaelumPortSiege.Pulse | 8.1283 | 0.6054 | 462.20 |
| CaelumWeightPressure.Update | 1.2654 | 0.5876 | 1602.00 |
| CaelumThermalBody.Get | 0.5671 | 0.5671 | 5722.80 |
| CaelumHingedDoorLeaf.BlockerPosition | 0.5314 | 0.5314 | 7936.00 |
| CaelumPortSiege.WalkTo | 0.7317 | 0.4942 | 180.00 |
| CaelumElementalStatus.TickBurnHeat | 0.0526 | 0.0526 | 1602.00 |
| CaelumElementalStatus.ApplyBurnHeat | 0.0036 | 0.0036 | 87.40 |
| CaelumElementalStatus.TakeBurnHeat | 0.0027 | 0.0027 | 46.70 |
<!-- MEASUREMENTS_END -->

Final validation:

- `issue318-functional-06`: 12 runs, 69 new assertions and one legacy seed marker;
  exit 0, no native errors/FAIL/watchdog and keep-awake released in every run.
  Saved DONE counters are cumulative and are not summed as new assertions.
- Independent read-only review verified those outcomes and exact source/fixture
  member equivalence; no additional production blocker was found.
- The project validator required updating two diagnostic release labels and
  shortening CONTEXT below its existing 2,500-word limit. The final native
  `issue318-functional-07/contact-final-labels` passes another 13 contact checks.
  All gameplay bytes match the complete suite; only the two release strings
  differ. `PACKAGE_VERIFICATION.json` verifies this exact qualification and all
  16,193 contact-stage members. The final native08 runtime is checked against
  every current source and normal-package member; the exact post-contact
  geometry/cartography/door member list is recorded in PACKAGE_VERIFICATION.json.
  The geometry03 furnished legacy package preserves the contact-stage runtime.
- `python build_document_index.py`, `python validate_project.py` and the normal
  `build_dev.ps1` packaging pass. No production diagnostic hook is included.
  The final PK3 SHA-256 is recorded in PACKAGE_VERIFICATION.json.
- Failed functional-01/02 runs expose fixture API/class-name errors and deferred
  PostBeginPlay setup respectively; functional-03 has an incorrect test
  precondition; functional-04 has a duplicated absolute save path. They were
  fixed in the tooling, preserved and followed by successful final tests.
- Earlier geometry v1 fails native sparse-sidedef loading; incomplete old profiles
  and unsafe-site skip attempts are not passing measurements. Missing callbacks
  are unavailable data, never zero rendering cost. Unrun extra component repeats
  remain unrun, so single-component ablations are exploratory.
- Author acceptance is pending as CA318-01/02/03. Whole MAP06 playability, bounded
  ordinary deployment and sustained combat remain unresolved under #318.
- Owned engines and completed authorized ETW sessions are stopped; temporary
  keep-awake requests are released. Dependency hashes are collected after the
  runs and explicitly labelled retrospective, not per-run attestations.

<!-- FLAT_START -->
## Flat armies: sprites, Domingo model and inventory ablation

The author requested 6,000 Mandingas versus 1,000 soldiers, then the same
battery at 1,000 versus 600, and explicitly authorized removing Mandinga
inventory for a diagnostic comparison. These changes are fixtures only.
Normal gameplay army totals, inventory and art are unchanged.

Both counts use one flat sector/four boundary lines, Vulkan 1280x720,
seed 116, skill 2, 48-MU spacing, 100 columns, identical overhead camera and
35 warmup tics. All bodies activate together with opposing native hate
groups and valid targets, retain solid collisions, production stats,
thermal simulation, breath, damage and resources. The soldiers use their
native sword/shield AI outside the MAP06 siege controller: there are no
city routes, carbine orders, cannon crews, commander or reinforcements.
This isolates the flat battle; it does not certify the full MAP06 siege.

The visual addon contains only MODELDEF mappings. Both army classes use
the existing Domingo MD3 (10,689 vertices, 17,447 triangles, 375 frames;
SHA256 bdc078573426bf82d94dc6b1d6a97f7236cdf31cdf271eabd9ef5512e1f81fa5).
Sparse pose samples follow existing actor sprite-state timings, with
native interpolation, existing scale and double-sided drawing. It adds
no body/proxy/animation thinker and changes no combat state. This is an
approved substitute, not a final Mandinga asset or a model LOD study.

Inventory removal occurs once after deferred PostBeginPlay initializes
the bodies and before the measurement window. It removes all native
inventory objects from each Mandinga, keeps the supply revision and
verifies zero inventory at removal, window start and end. The 6,000-body
case removes 18,000 stacked objects/108,000 units; the 1,000-body case
removes 3,000 objects/18,000 units. No recurring cleanup scan is installed.
Absence of potions can change longer combat outcomes; that is a gameplay
qualification, not permission to remove them from production.

Removing inventory also changes carried weight, effective collision mass
and attack air cost. The difference measures the complete inventory
ablation, not exclusively the Tick cost of the removed objects. Matching
short-run casualties/health does not prove identical resource histories.

Short onset windows cover 175 tics (5 simulated seconds); sustained
windows cover 1,050 tics (30 simulated seconds). Frozen controls stop all
nonplayer actor thinkers at the window boundary and measure 350 tics:
they isolate drawing plus remaining player/events, not playable combat.
DORMANT_STAT also excludes those bodies from ordinary thinker iterators:
event workloads change and the final ordinary census reads zero, although
the bodies remain visible. Do not subtract this result as pure AI cost.
The initial catch-up burst can put frozen-window tic throughput above 35;
it is not evidence of faster combat. Profiling is a separate instrumented
run sampled every 17 tics; inclusive nested scopes must not be added.

ETW records application presents, not monitor refresh. Short windows with
fewer than 30 intervals do not support meaningful tail claims.
Reported percentiles are empirical values of each capture, not stable
estimates of future tails; a threshold of 30 does not make p99 precise.
Frozen-control FPS must never be reported as active combat. No two engines
run together; background simulation/rendering and 5% audio remain enabled.

### 6,000 versus 1,000

| Run | Tics/s | App FPS | ETW N | Mean frame ms | p95 ms | p99 ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| frozen-models-02 | 36.60 | 26.16 | 226 | 38.23 | 39.17 | 39.48 |
| frozen-models-03 | 36.60 | 26.16 | 226 | 38.22 | 39.11 | 39.39 |
| frozen-sprites-01 | 37.31 | 169.40 | 1464 | 5.90 | 7.88 | 9.32 |
| frozen-sprites-04 | 37.32 | 170.06 | 1469 | 5.88 | 7.68 | 8.73 |
| inventory-empty-02 | 19.21 | 1.12 | 9 | 894.45 | - | - |
| inventory-empty-03 | 19.53 | 1.14 | 9 | 879.29 | - | - |
| inventory-empty-models-01 | 20.51 | 1.23 | 9 | 815.26 | - | - |
| inventory-empty-models-02 | 20.41 | 1.23 | 9 | 813.82 | - | - |
| inventory-kept-01 | 14.48 | 0.85 | 10 | 1178.23 | - | - |
| inventory-kept-04 | 15.43 | 0.90 | 10 | 1105.11 | - | - |
| models-02 | 15.81 | 0.93 | 9 | 1075.59 | - | - |
| models-03 | 16.34 | 0.96 | 9 | 1038.02 | - | - |
| sprites-01 | 15.83 | 0.93 | 10 | 1074.88 | - | - |
| sprites-04 | 15.66 | 0.92 | 10 | 1087.89 | - | - |
| sustained-empty-models | 18.17 | 1.07 | 61 | 936.95 | 1082.58 | 1114.28 |
| sustained-empty-sprites | 19.29 | 1.14 | 61 | 880.36 | 1028.27 | 1117.23 |
| sustained-models | 13.75 | 0.81 | 61 | 1238.32 | 1443.67 | 1498.79 |
| sustained-sprites | 14.68 | 0.86 | 61 | 1157.81 | 1329.33 | 1398.78 |
| combat-profile | 15.13 | 0.89 | 10 | 1127.51 | - | - |
| inventory-empty-profile | 18.66 | 1.10 | 10 | 912.06 | - | - |

Native counts, health and startup (raw log fields):
First-tic delay is wall latency until the next WorldTick. It includes
deferred initialization, remaining tic work and initial drawing, not
exclusive PostBeginPlay CPU time. Spawn+activation alone is incomplete.

| Run | Spawn+activation ms | First-tic delay ms | Final native census | Total living health |
| --- | ---: | ---: | --- | ---: |
| inventory-empty-02 | 21.319 | 211.220 | actors=7077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| inventory-empty-03 | 21.204 | 210.195 | actors=7077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| inventory-empty-models-01 | 22.849 | 526.973 | actors=7077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| inventory-empty-models-02 | 25.537 | 497.310 | actors=7077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| inventory-kept-01 | 22.294 | 210.607 | actors=25077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| inventory-kept-04 | 21.244 | 208.311 | actors=25077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| models-02 | 22.364 | 469.865 | actors=25077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| models-03 | 20.771 | 456.778 | actors=25077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| sprites-01 | 22.709 | 209.168 | actors=25077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| sprites-04 | 22.703 | 208.655 | actors=25077 mandingas=6000 soldiers=855 valid_targets=6770 dead=145 hurt=78 breaths=4 | 5292829 |
| sustained-empty-models | 21.771 | 463.679 | actors=7166 mandingas=5549 soldiers=648 valid_targets=6193 dead=803 hurt=278 breaths=14 | 4705386 |
| sustained-empty-sprites | 21.867 | 207.183 | actors=7166 mandingas=5549 soldiers=648 valid_targets=6193 dead=803 hurt=278 breaths=14 | 4705386 |
| sustained-models | 22.866 | 475.354 | actors=25613 mandingas=5620 soldiers=627 valid_targets=6247 dead=753 hurt=268 breaths=18 | 4736832 |
| sustained-sprites | 21.459 | 208.725 | actors=25613 mandingas=5620 soldiers=627 valid_targets=6247 dead=753 hurt=268 breaths=18 | 4736832 |

### 1,000 versus 600

| Run | Tics/s | App FPS | ETW N | Mean frame ms | p95 ms | p99 ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| frozen-models-02 | 36.00 | 105.40 | 953 | 9.49 | 10.24 | 10.70 |
| frozen-models-03 | 36.13 | 106.09 | 938 | 9.43 | 10.13 | 10.47 |
| frozen-sprites-01 | 35.67 | 472.47 | 4176 | 2.12 | 2.50 | 2.89 |
| frozen-sprites-04 | 35.69 | 469.08 | 4148 | 2.13 | 2.56 | 2.93 |
| inventory-empty-02 | 36.39 | 40.56 | 158 | 24.65 | 94.01 | 200.84 |
| inventory-empty-03 | 36.47 | 37.16 | 148 | 26.91 | 96.23 | 208.92 |
| inventory-empty-models-01 | 36.87 | 43.81 | 165 | 22.83 | 32.66 | 131.09 |
| inventory-empty-models-02 | 37.22 | 42.78 | 164 | 23.38 | 47.65 | 128.53 |
| inventory-kept-01 | 36.57 | 33.09 | 132 | 30.22 | 102.13 | 217.62 |
| inventory-kept-04 | 36.60 | 26.58 | 107 | 37.62 | 132.05 | 222.88 |
| models-02 | 36.66 | 35.46 | 140 | 28.20 | 59.89 | 149.13 |
| models-03 | 37.37 | 40.79 | 156 | 24.52 | 43.75 | 128.55 |
| sprites-01 | 36.59 | 36.34 | 145 | 27.52 | 100.90 | 213.45 |
| sprites-04 | 36.56 | 30.10 | 115 | 33.22 | 114.99 | 243.01 |
| sustained-empty-models | 35.28 | 42.74 | 1233 | 23.40 | 30.99 | 52.51 |
| sustained-empty-sprites | 35.21 | 49.86 | 1441 | 20.06 | 28.45 | 94.56 |
| sustained-models | 35.36 | 43.76 | 1268 | 22.85 | 27.27 | 42.98 |
| sustained-sprites | 35.26 | 53.54 | 1548 | 18.68 | 22.31 | 99.76 |
| combat-profile | 36.84 | 28.96 | 107 | 34.53 | 115.87 | 255.13 |
| inventory-empty-profile | 36.50 | 36.78 | 146 | 27.19 | 90.53 | 197.34 |

Native counts, health and startup (raw log fields):
First-tic delay is wall latency until the next WorldTick. It includes
deferred initialization, remaining tic work and initial drawing, not
exclusive PostBeginPlay CPU time. Spawn+activation alone is incomplete.

| Run | Spawn+activation ms | First-tic delay ms | Final native census | Total living health |
| --- | ---: | ---: | --- | ---: |
| inventory-empty-02 | 4.591 | 128.578 | actors=1663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| inventory-empty-03 | 4.160 | 127.601 | actors=1663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| inventory-empty-models-01 | 4.788 | 364.190 | actors=1663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| inventory-empty-models-02 | 4.180 | 363.132 | actors=1663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| inventory-kept-01 | 4.681 | 128.348 | actors=4663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| inventory-kept-04 | 4.371 | 128.415 | actors=4663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| models-02 | 4.703 | 371.961 | actors=4663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| models-03 | 4.468 | 363.549 | actors=4663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| sprites-01 | 4.705 | 128.954 | actors=4663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| sprites-04 | 4.656 | 128.378 | actors=4663 mandingas=1000 soldiers=438 valid_targets=1357 dead=162 hurt=63 breaths=5 | 1180297 |
| sustained-empty-models | 4.878 | 364.782 | actors=1702 mandingas=592 soldiers=278 valid_targets=869 dead=730 hurt=218 breaths=9 | 683507 |
| sustained-empty-sprites | 5.042 | 133.302 | actors=1702 mandingas=592 soldiers=278 valid_targets=869 dead=730 hurt=218 breaths=9 | 683507 |
| sustained-models | 4.700 | 364.226 | actors=5036 mandingas=638 soldiers=240 valid_targets=877 dead=722 hurt=163 breaths=3 | 692777 |
| sustained-sprites | 4.568 | 130.621 | actors=5036 mandingas=638 soldiers=240 valid_targets=877 dead=722 hurt=163 breaths=3 | 692777 |

### Sampled subsystem costs

Values below are **exclusive ms/sample tic**, not GPU costs. Nested
inclusive costs and call counts are retained in analysis.json.
The CombatActor.Tick remainder includes code and native work outside
the selected probes; this table is not a complete engine profiler.

| Method | 7000 full | 7000 empty | 1600 full | 1600 empty |
| --- | ---: | ---: | ---: | ---: |
| CaelumCombatActor.Tick | 13.90 | 13.78 | 3.06 | 2.97 |
| CaelumDemonBreath.Mouth | 4.74 | 4.54 | 0.71 | 0.69 |
| CaelumCombatActor.NativeTick | 4.54 | 4.25 | 0.93 | 0.87 |
| CaelumWeightPressure.MassAbove | 4.41 | 4.06 | 0.80 | 0.79 |
| CaelumDemonService.UpdateBreath | 3.58 | 3.44 | 0.57 | 0.55 |
| CaelumWeightPressure.Update | 3.10 | 1.21 | 0.31 | 0.19 |
| CaelumElementalStatus.Tick | 2.69 | 2.67 | 0.60 | 0.58 |
| CaelumCombatActor.UpdateCombatHealthEffects | 2.39 | 2.44 | 0.52 | 0.54 |
| CaelumThermalBody.Get | 2.33 | 2.32 | 0.48 | 0.51 |
| CaelumCarbineWorld.Restore | 2.20 | 2.18 | 1.30 | 1.28 |
| CaelumCombatActor.UpdateActorOffensiveStatistics | 2.13 | 2.14 | 0.46 | 0.48 |
| CaelumCombatActor.CollidedWith | 1.88 | 0.66 | 0.65 | 0.35 |
| CaelumThermalBody.Refresh | 1.39 | 0.94 | 0.28 | 0.22 |
| CaelumThermalRuntime.NPCStep | 1.17 | 1.04 | 0.23 | 0.17 |
| CaelumDemonBreath.CanReach | 0.94 | 0.99 | 0.16 | 0.17 |
| CaelumCombatActor.IsCombatIdle | 0.87 | 0.87 | 0.19 | 0.18 |
| CaelumDemonService.Initialize | 0.83 | 0.83 | 0.14 | 0.13 |
| CaelumCombatActor.ResourceRecoveryActive | 0.76 | 0.75 | 0.15 | 0.12 |
| CaelumDemonService.UpdatePotions | 0.71 | 0.71 | 0.13 | 0.13 |
| CaelumWeightPressure.WorldTick | 0.68 | 0.52 | 0.15 | 0.11 |
| CaelumThermalMotion.Physics | 0.62 | 0.61 | 0.14 | 0.13 |
| CaelumDemonService.StopBreath | 0.46 | 0.47 | 0.08 | 0.08 |
| CaelumPopulationState.Refresh | 0.43 | 0.19 | 0.06 | 0.03 |
| CaelumThermalMotion.Path | 0.40 | 0.39 | 0.09 | 0.08 |

Reproduce with flat_army_fixture.py (default 6,000/1,000, or
--mandingas 1000 --soldiers 600), flat_controls.py, flat_suite.py and
flat_inventory_suite.py. Use fresh directories; preserve old labels.
Stop the authorized ETW collector before analyze.py reads its CSV, then
run flat_report.py. Runtime/member hashes, exact commands, native logs,
CPU samples, raw ETW and selected captures accompany the evidence.
<!-- FLAT_END -->

<!-- HOUSES_BEGIN -->
## Separate house interiors versus full-height house walls

Author-requested follow-up, 2026-10-17. Production keeps all 160 original
960-by-1,216-MU house footprints and 184-MU roofs. Front-door Use loads
one private CAH000..CAH159 map, retaining real resident bodies and finite
inventories; defenders emerge at their original doors during the siege.
Shops/factories remain in the city. Six original painted sign designs
identify the 64 shops using their existing merchandise categories.

### Comparison at a glance

Ranges below contain the two completed per-run means for each condition,
not minimum/maximum instantaneous FPS or confidence intervals. A is the
184-MU shell; B adds full-height opaque house walls. All siege rows retain
600 defenders. The nominal simulation rate is 35 tics/s.

| Scene | A app FPS | B app FPS | A tics/s | B tics/s |
| --- | ---: | ---: | ---: | ---: |
| Peaceful city, forward | 36.62-37.03 | 402.03-405.19 | 34.96-35.05 | 35.00-35.00 |
| Peaceful city, ground | 28.54-29.76 | 165.66-166.03 | 34.98-35.02 | 35.00-35.00 |
| 1,000 attackers, city centre | 6.81-8.33 | 27.97-29.88 | 34.98-34.99 | 34.98-35.03 |
| 1,000 attackers, front line | 24.76-24.89 | 22.24-22.68 | 34.99-35.02 | 34.99-35.00 |
| 6,000 attackers, city centre | 0.69-0.69 | 0.70-0.71 | 11.76-11.79 | 11.96-12.15 |
| Private interior CAH158 | 1084.20-1091.11 | 1065.57-1128.91 | 35.00-35.00 | 35.00-35.00 |

Real opaque closure strongly improves the two peaceful street views.
The 1,000-attacker central view also improves, but remains below 60 FPS;
its p99 frame intervals are 112-131 ms even with occlusion. The front-line
view does not improve: both native snapshots contain 1,146 wall jobs,
and B records lower FPS in these repeats. This is not a uniform map-wide
gain or proof that the geometry alone caused that smaller regression.

The private interior exceeds 1,000 application presents/s with three
residents and 44 actors; this does not represent the entire city or a
large indoor battle. At 6,000 attackers both variants remain near 0.7 FPS
and 12 simulation tics/s. Thirty simulated seconds take about 86-89 real
seconds. Opaque walls do not solve the full-army simulation bottleneck.
Bounded normal attacker deployment and measured actor-work reduction
remain necessary; this test does not choose a new combat budget.

Static final-WAD verification confirms all four outer house boundaries,
160 portals/return starts and correct sign categories. MAP06 changes from
1,565 sectors/65,661 lines/2,987 things to 765/42,945/491. Each of the 160
private interiors has five sectors, 194 lines, 16 map things and four
native door leaves. All private WADs regenerate byte-for-byte; sign
generation is byte-identical under the pinned Windows PowerShell 5.1
and .NET Framework rasterizer. Counts do not include runtime-created props.

Full exterior MAP06 regeneration also matches byte-for-byte; its result
is recorded in issue318-houses-static-02/EXTERIOR_REGENERATION.json.

Native functional checks cover actual Use in houses 0/119/120/158/159,
return position, three/four residents, injury, gear durability, ammunition,
finite inventory, current saves on both sides, fresh birth plus immediate
travel, 600 unique deployments, cannon reassignment, blocked placement and
retry, death, burning, bolas, resurrection memory and active/expired
Redemption. The same real body travels; absent-map combat is suspended.
A due siege starts when returning to the city. These are isolated engine
checks, not author acceptance of the entire campaign or multiplayer.

Functional runtime07 differs from08 only in the MAP06 cartography
checksum; runtime08 differs from09 only in six regenerated sign PNGs
and their license. Resident/door/cannon gameplay code is unchanged.

With 600 instantiated residents, the native compressed save grows from
331,899 bytes before visiting ten houses to 2,063,831 bytes afterward.
All 600 identities remain unique/alive. This is a measured hub-storage
cost; no linear extrapolation, memory-leak diagnosis or whole-campaign
memory/transition-latency guarantee follows from it.

### Matched performance conditions

A (`houses`) is the production house-shell prototype. B (`opaque`) keeps
the same private interiors, XY footprints, lines, vertices and map things,
but extends house walls to the existing 1,024-MU sky ceiling.
The original 184-MU sector is shared with unrelated structures, so B
adds one sector and reassigns only 10,880 house sides. It does not raise
the shared original sector. Its closed ceiling uses the existing opaque
roof material: leaving F_SKY1 on both sides invokes hw_CheckClip's sky
exception and does not block background BSP traversal. Wall materials
remain unchanged. The paired packages differ only in MAP06 and
its cartography checksum. B remains diagnostic, with changed sight,
projectile/flight paths and thermal geometry; it is not a renderer-only
toggle. No tall walls or reduced army budget are adopted in production.

GZDoom 4.14.2, Vulkan 1280x720, Ryzen 9 5950X/RTX 3070 Ti, seed116,
skill2, uncapped presentation, unpaused background simulation/rendering
and 5% audio. Each run uses a fresh isolated process/configuration.
No concurrent engine or package build runs during measurement.
The ordinary inventory, sprite art, RPG bodies, collisions and resources
remain enabled. The 1,000-Mandinga control changes only the diagnostic
attacker count; 600 defenders and the commander remain.

Peaceful views use site0 `(0,320,0)`, yaw180, pitch0/75: 140 warmup and
350 observation tics. Siege windows start after 700 warmup tics and run
1,050 tics (30 simulated seconds); 1,000 attackers use sites0 and4
(`-14464,-14000,0`, yaw270), while 6,000 use site0. Each condition runs
A-B-B-A. Interior benchmarks load CAH158 through native changemap and
retain its native start; actual door Use is covered by functional checks.
Separate instrumented 1,000- and 6,000-attacker profiles sample every17 tics during
a 350-tic window; their FPS is not mixed with the uninstrumented repeats.

The earlier `issue318-houses-perf-01` site1 camera was on a newly solid
house boundary and failed native placement. Its data is retained as an
invalid-camera diagnostic, excluded from this comparison. Directory02
has legal cameras but retains sky ceilings in the tall closed sectors;
it is an ineffective-occluder control, not the requested final B.
Directory03 corrects that ceiling material and repeats the full comparison.
The final observer
checks `TestMobjLocation` at the measurement boundary and records camera
coordinates/populations. Matching camera and initial populations does
not establish identical combat trajectories under different geometry.

Early directory03 `interior-*` labels remained in MAP06 because changemap
was requested before the first level finished loading. They are excluded
from the interior results. Corrected `house-interior-*` commands first
wait for MAP06, then change level; native bench must identify CAH158 and
every census must contain its three residents.

ETW measures application presents, not display refresh. Host marker
detection polls at 200 ms and trims 300 ms at the start/500 ms at the end;
no exact per-tic correlation is claimed. Tails are empirical capture
percentiles; fewer than30 intervals do not support a tail report.
Renderer `bench` snapshots are separate CPU-side diagnostics, not GPU
timings or a complete additive breakdown. Its native five-second delay
requires at least210 postwait tics. The earlier directory02 peace/1,000
runs used35 and did not produce a bench file; final directory03 uses210
and records these snapshots after each measurement window.

### Peaceful city

| Variant / run | Complete | Tics/s | App FPS | ETW N | Mean ms | p95 ms | p99 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| houses-6000 / peace-0-1 | True | 34.96 | 36.62 | 338 | 27.31 | 31.02 | 33.65 |
| houses-6000 / peace-0-4 | True | 35.05 | 37.03 | 343 | 27.00 | 29.92 | 31.60 |
| houses-6000 / peace-75-1 | True | 34.98 | 29.76 | 275 | 33.60 | 36.79 | 37.58 |
| houses-6000 / peace-75-4 | True | 35.02 | 28.54 | 264 | 35.04 | 37.72 | 39.05 |
| opaque-6000 / peace-0-2 | True | 35.00 | 405.19 | 3744 | 2.47 | 2.98 | 3.47 |
| opaque-6000 / peace-0-3 | True | 35.00 | 402.03 | 3716 | 2.49 | 3.03 | 3.58 |
| opaque-6000 / peace-75-2 | True | 35.00 | 166.03 | 1534 | 6.02 | 7.24 | 7.95 |
| opaque-6000 / peace-75-3 | True | 35.00 | 165.66 | 1531 | 6.04 | 7.33 | 8.03 |

### 1,000 Mandingas / 600 defenders

| Variant / run | Complete | Tics/s | App FPS | ETW N | Mean ms | p95 ms | p99 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| houses-1000 / siege1000-0-1 | True | 34.99 | 6.81 | 198 | 146.95 | 251.70 | 300.19 |
| houses-1000 / siege1000-0-4 | True | 34.98 | 8.33 | 244 | 120.04 | 210.42 | 261.63 |
| houses-1000 / siege1000-4-1 | True | 34.99 | 24.76 | 726 | 40.39 | 70.66 | 94.67 |
| houses-1000 / siege1000-4-4 | True | 35.02 | 24.89 | 725 | 40.17 | 70.90 | 96.34 |
| opaque-1000 / siege1000-0-2 | True | 34.98 | 27.97 | 820 | 35.76 | 61.84 | 131.06 |
| opaque-1000 / siege1000-0-3 | True | 35.03 | 29.88 | 870 | 33.46 | 56.94 | 112.29 |
| opaque-1000 / siege1000-4-2 | True | 35.00 | 22.68 | 665 | 44.09 | 82.90 | 112.88 |
| opaque-1000 / siege1000-4-3 | True | 34.99 | 22.24 | 647 | 44.97 | 78.70 | 111.96 |

### 6,000 Mandingas / 600 defenders

| Variant / run | Complete | Tics/s | App FPS | ETW N | Mean ms | p95 ms | p99 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| houses-6000 / siege6000-1 | True | 11.79 | 0.69 | 61 | 1443.66 | 1598.10 | 1652.85 |
| houses-6000 / siege6000-4 | True | 11.76 | 0.69 | 62 | 1447.00 | 1616.58 | 1700.60 |
| opaque-6000 / siege6000-2 | True | 11.96 | 0.70 | 61 | 1421.64 | 1557.62 | 1594.68 |
| opaque-6000 / siege6000-3 | True | 12.15 | 0.71 | 61 | 1400.70 | 1556.58 | 1566.90 |

### Private interior CAH158

| Variant / run | Complete | Tics/s | App FPS | ETW N | Mean ms | p95 ms | p99 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| houses-6000 / house-interior-1 | True | 35.00 | 1084.20 | 9804 | 0.92 | 1.14 | 1.38 |
| houses-6000 / house-interior-4 | True | 35.00 | 1091.11 | 10088 | 0.92 | 1.15 | 1.41 |
| opaque-6000 / house-interior-2 | True | 35.00 | 1128.91 | 10211 | 0.89 | 1.10 | 1.32 |
| opaque-6000 / house-interior-3 | True | 35.00 | 1065.57 | 9640 | 0.94 | 1.18 | 1.46 |

### Instrumented profiles

| Variant / run | Complete | Tics/s | App FPS | ETW N | Mean ms | p95 ms | p99 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| houses-1000-profile / profile-siege1000 | True | 34.77 | 8.71 | 81 | 114.79 | 146.98 | 161.80 |
| houses-6000-profile / profile-siege6000 | True | 11.40 | 0.67 | 20 | 1491.13 | - | - |
| opaque-1000-profile / profile-siege1000 | True | 34.92 | 30.71 | 285 | 32.56 | 56.26 | 60.94 |
| opaque-6000-profile / profile-siege6000 | True | 11.65 | 0.68 | 20 | 1464.04 | - | - |

### Native renderer snapshots after peaceful windows

These are individual native bench samples after the timed window, with
the same stationary scene. CPU-side render/setup clocks may overlap
worker threads; do not sum them into an additive CPU/GPU budget.

| Variant / view | Walls | Flats | Sprites | Wall render ms | Wall setup ms | All ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| houses / pitch0 | 34297 | 1127 | 628 | 8.97 | 11.81 | 24.84 |
| opaque / pitch0 | 738 | 65 | 403 | 0.17 | 0.16 | 1.19 |
| houses / pitch75 | 41833 | 1199 | 631 | 11.18 | 15.59 | 31.98 |
| opaque / pitch75 | 4727 | 124 | 474 | 1.30 | 1.98 | 5.21 |

### Sampled CPU methods

Exclusive milliseconds per sampled tic. These probes cover selected
methods; native/uninstrumented work and instrumentation overhead remain.
Inclusive nested costs must not be summed. Full costs, counts, bursts,
censuses, camera state and CPU samples are retained in analysis/raw logs.

| Method | 1000 houses | 1000 opaque | 6000 houses | 6000 opaque |
| --- | ---: | ---: | ---: | ---: |
| CaelumPortSiege.AttackerTarget | 3.50 | 3.56 | 18.82 | 18.72 |
| CaelumCombatActor.Tick | 3.00 | 3.05 | 12.69 | 12.75 |
| CaelumDemonService.UpdateBreath | 0.70 | 0.69 | 4.18 | 4.34 |
| CaelumDemonBreath.Mouth | 0.62 | 0.62 | 3.63 | 3.72 |
| CaelumWeightPressure.Update | 0.38 | 0.40 | 3.21 | 3.16 |
| CaelumElementalStatus.Tick | 0.67 | 0.69 | 3.14 | 3.05 |
| CaelumPortSiege.Pulse | 0.61 | 0.61 | 3.06 | 3.07 |
| CaelumCombatActor.UpdateCombatHealthEffects | 0.61 | 0.61 | 2.62 | 2.62 |
| CaelumWeightPressure.MassAbove | 0.53 | 0.53 | 2.33 | 2.46 |
| CaelumThermalShelter.WindBlocked | 0.42 | 0.44 | 2.35 | 2.37 |
| CaelumThermalBody.Get | 0.53 | 0.53 | 2.26 | 2.01 |
| CaelumElementalStream.ReceivedWatts | 1.85 | 1.90 | 2.00 | 2.02 |
| CaelumCombatActor.UpdateActorOffensiveStatistics | 0.47 | 0.46 | 1.97 | 2.01 |
| CaelumCombatActor.NativeTick | 0.42 | 0.43 | 1.86 | 1.91 |
| CaelumThermalBody.Refresh | 0.38 | 0.39 | 1.66 | 1.70 |
| CaelumElementalStream.Contact | 1.12 | 1.18 | 1.22 | 1.18 |
| CaelumWeightPressure.WorldTick | 0.18 | 0.19 | 1.04 | 0.79 |
| CaelumDemonBreath.CanReach | 0.18 | 0.18 | 1.00 | 0.98 |
| CaelumPopulationState.Refresh | 0.12 | 0.13 | 0.89 | 0.57 |
| CaelumThermalRuntime.NPCStep | 0.22 | 0.22 | 0.76 | 0.88 |
| CaelumCombatActor.IsCombatIdle | 0.20 | 0.20 | 0.83 | 0.87 |
| CaelumDemonService.Initialize | 0.15 | 0.15 | 0.84 | 0.82 |
| CaelumDemonBreath.PaidTick | 0.71 | 0.72 | 0.80 | 0.80 |
| CaelumThermalService.Integrate | 0.20 | 0.19 | 0.79 | 0.80 |
| CaelumCombatActor.ResourceRecoveryActive | 0.15 | 0.16 | 0.70 | 0.78 |

Reproduce with house_fixture.py, house_suite.py, house_verify.py and
house_perf.py. Keep immutable evidence directories and stop the authorized
ETW session before analyze.py/house_report.py. Old fixture failures and
invalid-camera runs are preserved, not counted as successful acceptance.
Normal synchronous attacker deployment remains unresolved; this experiment
does not close #318 or replace author checks CA318-01..04.

<!-- HOUSES_END -->

<!-- CEILINGS_BEGIN -->
## Variable-height physical sky over house districts

Author-requested follow-up, 2026-10-17. This is an isolated diagnostic
against the previously tested tall opaque walls. Normal source MAP06,
its gameplay code and the normal package remain unchanged.

House/shop lots plus half the existing road width receive the existing
184-MU house-roof height as physical ceiling. Retained houses derive
their district from their footprint, doorstep and authored road endpoint.
The perimeter wall-walk belt and nonresidential exterior remain at their
existing 1,024 MU; higher floors/3D volumes are excluded. Open streets
retain F_SKY1. Solids whose floor reaches 184 MU close with their own
opaque roof material, avoiding the native both-sky clipping exception.

A temporary cell-flat marker splits shared sectors before compaction and
is removed from the final WAD. Normal baseline regeneration is byte-exact;
two diagnostic regenerations are byte-identical. Floor-cell properties,
footprints, doors, map things and high control volumes are preserved.
The diagnostic has 767 sectors/43,000 lines/491 things, versus normal
765/42,945/491. The added 55 lines partition ceiling zones.

### Native functional checks

Three successful runs log 871 passing assertions: all 160 doorsteps fit defender
dimensions under ceiling184 and remain thermally outdoors; 64 shops keep
entrance access, 160-MU interior headroom, real shelter and original window
heights; 40 wall/tower positions keep standing room and ceiling1024.
Actual upward movement stops under the low sky. A closed house roof has
no standing headroom: this removes roof access, rather than creating a
new walkable roof surface. Native Use/return and 600 unique defender
deployments/cannon reassignment also pass. Counts use PASS log records,
because a map transition can reconstruct the handler and reset its local
DONE counter. This does not replace author
acceptance of elevated views, transitions, flight or complete playability.
With the local package prepared and other engines closed, preview with
`python assets/validation_issue318/house_preview.py --directory issue318-ceilings-01 --variant zoned-1000`.
The isolated preview uses normal input and its own config/saves; CA318-05
records the outstanding author check. No preview is launched during timing.

Two early fixture failures remain archived: geometry-01 exceeded the
ZScript register limit with unrolled checks; geometry-02 waited35 tics
after an upward launch and observed the player back on the floor. The
corrected loop and one-tic observation pass in geometry-03. No runtime
gameplay fix was made to turn those fixture failures into passes.

### Fresh matched presentation measurements

GZDoom4.14.2, Vulkan1280x720, Ryzen9 5950X/RTX3070Ti, seed116, skill2,
uncapped unpaused background rendering, 5% audio, ordinary sprites and
inventories. One engine at a time. The same immutable observer is used
for both shapes. Each condition runs opaque-zoned-zoned-opaque.
No profiling instrumentation is added to gameplay methods.

Sites0 `(0,320,0)` and4 `(-14464,-14000,0)` remain in the high region.
Site5 is the authored HouseRoad(0), facing90 along its residential street;
native camera markers prove ceiling184 in zoned and1024 in opaque.
Peace:140 warmup/350 observation tics, pitch0/75. Siege:700 warmup/
1050 observation tics, 600 defenders and1000 attackers. All24 windows
assert valid camera collision and initial populations. Geometry can alter
combat trajectories; end censuses are retained for every run.

ETW measures application presents, not display refresh. The collector
is bounded to30 minutes. Every included process has presentation events
before and after its trimmed QPC observation window. Host markers use
200-ms polling and300/500-ms edge trims; no exact per-tic correlation
or complete additive CPU/GPU attribution is claimed.

| Scene | Tall opaque walls FPS | Zoned sky FPS | Tall tics/s | Zoned tics/s |
| --- | ---: | ---: | ---: | ---: |
| Exterior city view, forward | 280.79-284.08 | 330.73-337.53 | 35.01-35.01 | 35.00-35.00 |
| Exterior city view, ground | 103.47-114.89 | 121.75-123.65 | 34.99-34.99 | 35.01-35.01 |
| Residential street, forward | 268.93-272.96 | 261.85-268.56 | 34.98-34.99 | 34.99-35.01 |
| Residential street, ground | 205.90-244.94 | 219.61-252.60 | 34.99-34.99 | 34.99-35.00 |
| 1,000 attackers, city view | 3.85-5.05 | 6.42-7.16 | 33.87-34.32 | 34.81-34.88 |
| 1,000 attackers, front line | 3.72-4.44 | 3.53-4.39 | 33.09-33.80 | 33.34-34.19 |

Ranges contain two per-run means, not instantaneous FPS extremes or
confidence intervals. Earlier normal-shell/opaque results were captured
in another session; compare the fresh paired controls above for this
experiment, rather than treating historical values as a new third arm.

| Variant / run | App FPS | Tics/s | ETW N | p95 ms | p99 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| opaque-1000 / siege1000-0-1 | 5.05 | 34.32 | 152 | 496.57 | 543.70 |
| opaque-1000 / siege1000-0-4 | 3.85 | 33.87 | 116 | 535.28 | 597.24 |
| opaque-1000 / siege1000-4-1 | 4.44 | 33.80 | 134 | 541.17 | 559.82 |
| opaque-1000 / siege1000-4-4 | 3.72 | 33.09 | 116 | 561.60 | 594.44 |
| opaque-6000 / peace-0-0-1 | 284.08 | 35.01 | 2628 | 5.18 | 6.30 |
| opaque-6000 / peace-0-0-4 | 280.79 | 35.01 | 2542 | 5.22 | 6.55 |
| opaque-6000 / peace-0-75-1 | 103.47 | 34.99 | 957 | 11.58 | 12.51 |
| opaque-6000 / peace-0-75-4 | 114.89 | 34.99 | 1063 | 10.68 | 12.01 |
| opaque-6000 / peace-5-0-1 | 268.93 | 34.99 | 2488 | 5.48 | 6.44 |
| opaque-6000 / peace-5-0-4 | 272.96 | 34.98 | 2472 | 5.26 | 6.40 |
| opaque-6000 / peace-5-75-1 | 205.90 | 34.99 | 1865 | 6.64 | 7.66 |
| opaque-6000 / peace-5-75-4 | 244.94 | 34.99 | 2264 | 6.23 | 8.30 |
| zoned-1000 / siege1000-0-2 | 7.16 | 34.88 | 211 | 318.15 | 389.87 |
| zoned-1000 / siege1000-0-3 | 6.42 | 34.81 | 188 | 398.04 | 469.26 |
| zoned-1000 / siege1000-4-2 | 4.39 | 34.19 | 132 | 525.59 | 548.74 |
| zoned-1000 / siege1000-4-3 | 3.53 | 33.34 | 109 | 553.32 | 576.22 |
| zoned-6000 / peace-0-0-2 | 337.53 | 35.00 | 3122 | 4.46 | 5.72 |
| zoned-6000 / peace-0-0-3 | 330.73 | 35.00 | 3060 | 4.61 | 5.73 |
| zoned-6000 / peace-0-75-2 | 123.65 | 35.01 | 1119 | 9.98 | 11.58 |
| zoned-6000 / peace-0-75-3 | 121.75 | 35.01 | 1127 | 9.94 | 10.75 |
| zoned-6000 / peace-5-0-2 | 268.56 | 35.01 | 2485 | 5.49 | 6.63 |
| zoned-6000 / peace-5-0-3 | 261.85 | 34.99 | 2424 | 5.59 | 6.79 |
| zoned-6000 / peace-5-75-2 | 219.61 | 34.99 | 2032 | 6.46 | 7.69 |
| zoned-6000 / peace-5-75-3 | 252.60 | 35.00 | 2336 | 5.10 | 6.31 |

Tail percentiles are withheld when fewer than30 intervals are available.

### Unresolved difference between sessions

The unchanged tall-wall control is slower than in house-perf-03.
Exact runtime, engine, initial configuration and full population/end
censuses match. Independent review also matched the final INI and
breath counts. The observer adds only site5 and two CeilingZ log fields.
Native callbacks slow along with ETW, so this is not merely an ETW
parser artifact. Process CPU samples are aggregate CPU time across
all process threads, not main-thread/GPU utilization. They use the
first/last available samples strictly inside each trimmed window.

| Control | Historical FPS / callbacks per s / tics per callback / CPU-s per s | Current values |
| --- | ---: | ---: |
| site0 / siege1000-0-1 | 27.968 / 28.256 / 1.239 / 0.943 | 5.053 / 5.192 / 6.631 / 1.027 |
| site0 / siege1000-0-4 | 29.885 / 30.192 / 1.159 / 0.935 | 3.850 / 3.951 / 8.603 / 0.979 |
| site4 / siege1000-4-1 | 22.679 / 22.924 / 1.528 / 0.928 | 4.440 / 4.810 / 7.061 / 0.996 |
| site4 / siege1000-4-4 | 22.236 / 22.653 / 1.546 / 0.952 | 3.724 / 3.929 / 8.463 / 1.014 |

This supports a tighter simulation/rendering time budget in this
session; the cause of the session difference is not identified.
Post-window thinker snapshots also cost more, but they cannot prove
a thermal, power, scheduling or external-application cause. No such
cause is asserted. Use only the fresh paired controls for the ceiling
comparison and do not treat earlier siege FPS as a current guarantee.

### Native renderer work after the peaceful window

These are point samples after the timed window, not ETW FPS or GPU
durations. CPU renderer clocks can overlap; they must not be summed.

| View | Tall wall jobs / flats / flat vertices | Zoned wall jobs / flats / flat vertices |
| --- | ---: | ---: |
| site0 / pitch0 | 738 / 65 / 107523 | 235 / 65 / 41763 |
| site0 / pitch75 | 4727 / 124 / 134238 | 4243 / 138 / 90492 |
| site5 / pitch0 | 727 / 24 / 111903 | 713 / 61 / 72105 |
| site5 / pitch75 | 1445 / 45 / 120669 | 1432 / 84 / 81981 |

### Retired full-army tests

During this batch the author ruled out 6,000 simultaneous actors and
instructed that this size never be tested again. Three earlier full-army
runs had completed; the fourth owned engine was stopped immediately
on request. Its incomplete-run traceback is an intentional author stop,
not an observed engine crash. All four raw records remain preserved
outside the current24-window comparison. AUTHOR_STOP.json records
the decision. The siege6000 runner now refuses execution. No further
full-army run is required or authorized; no replacement production
army budget is invented. Peaceful runs named *-6000 contain zero
attackers; their suffix identifies the prepared historical package.

### Reproduction and package scope

From the tested house-perf-03 baseline, run `ceiling_perf.py prepare`,
then `ceiling_perf.py observer`. Preparation refuses to overwrite an
existing evidence directory; use `--directory` for a fresh local run.
Use run.py with checks-v3.pk3 and the generated geometry.cfg, portals.cfg
and deploy.cfg for the functional checks. With one authorized PresentMon
collector, run peace and siege1000 serially. Do not run siege6000.
Wait for CSV release before
analysis. Run analyze.py with this directory and its explicit collector,
then `ceiling_report.py --directory NEW`. A new-directory reproduction
writes its report/verification inside that build directory, preserving
the canonical results of this run. The default directory and baseline
are declared in ceiling_zones.json.

Exact package comparison verifies that opaque controls are unchanged;
zoned packages differ from the corresponding house baseline only in
MAP06 and its cartography checksum. All four use the same observer hash.
The baseline MAP06 still matches src. Policy and source
authorities are in ceiling_zones.json; geometry metadata, packages hashes,
configs, native logs, captures and ETW are retained in the evidence.
Normal bounded attacker deployment, acceptable siege FPS and author review
remain open under #318. Diagnostic ceilings are not adopted production
geometry and do not select a new army budget.

<!-- CEILINGS_END -->
