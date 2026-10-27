# Known pitfalls and verified lessons â€” Caelum Argenteum

Status: integrated engineering register (issue #22, patch 4.36.1b).
Prepared: 2026-09-23. Inherits the project's release after integration.
Inspected baseline: `1dc390576fa330d37ff543526fc7e69a397fc28f` (PR #7).

## CA-KP-180 - Check seating occupancy before moving a player
Status/evidence: RESOLVED-VERIFIED (native engine and upstream source)
First recorded / last checked: 2026-10-27 / 2026-10-27
Issue / PR: #410; sofa seating delivery5.8.29
Affected baseline: 28e4cd65 plus initial5.8.29 working tree
Environment: GZDoom4.14.2, Windows11, Vulkan,1280x720/60cap
Scope: CaelumRestFurniture.Seat; chairs, beds and sofa proxies

SetOrigin followed by the player's TestMobjLocation does not prove that another
solid actor is absent. GZDoom's PIT_CheckThing enables its unblocking exception
when testing a player at its already-current XY. The native lifecycle reproducer
therefore seated through a solid chair despite unchanged player collision flags.
Upstream g4.14.2 src/playsim/p_map.cpp, P_TestMobjLocation and PIT_CheckThing,
https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/p_map.cpp establish the cause.

Validate the destination first with a non-player probe carrying the prospective
occupant's full radius/height. Ignore only that same occupant through the probe's
CanCollideWith callback; all other objects and map geometry remain blockers.
The furniture lends its own collision as before. Only a successful preflight
moves the player. No tick scan or persistent probe is introduced.

Evidence: assets/validation_5829 lifecycle4 reproduces three failures; lifecycle7
passes12 checks including blocked/clear sofas, existing chairs/beds, standing,
owner destruction and a nearby occupant. Final delivery checks repeat the fixture.
Hidden seat proxies additionally use their visible parent's sight target; testing
visibility of a RenderStyle None proxy is not equivalent to testing the sofa.
Author corroboration: pending CA410-SOFAS-01. This does not audit unrelated
teleport/placement callers or establish multiplayer acceptance.

## CA-KP-179 - Share historical weather and settle before changing dirt
Status/evidence: RESOLVED-VERIFIED (native engine)
First recorded / last checked: 2026-10-27 / 2026-10-27
Issue / PR: #502; regional object history delivery
Affected baseline: ecdea2b9 plus5.8.28 working tree; validation_5828
Environment: GZDoom4.14.2, Windows11, Vulkan,1280x720/60cap
Scope: CaelumContaminationObject, CaelumContaminationStorage, weather cache

Independently evaluating each elapsed weather minute for1,000 receivers cost
9,868.688ms for a day. A shared transient cache keyed by date and complete
climate/location metadata reduced it to86.9435ms with identical results. Keep
receiver concentration/area integration individual. The32-page memory bound
only controls cached weather; eviction must never truncate elapsed time.

A storage regression also exposed dirt accruing after cleaning from the loaded
interval preceding it. Settle pending history before every read/write/contact,
including normal loaded intervals. Do not resample expensive geometry for each
read: retain staggered sampling and advance only the known interval anchor.
Native pickup, storage/toss, current/old saves, hub, roof/rain, tiny areas,
partial-minute reference integration and cache eviction regress this behavior.

Evidence: assets/validation_5828/RESULTS.md and report.json;71 native PASS,
zero final failures/static errors. Matched1,000-object P99 renderer callbacks
17.4808/17.4962ms; PresentMon denied, so no displayed-frame/FPS claim. Replay
remains linear in elapsed minutes; no arbitrary-year scalability claim.
Author acceptance: PENDING CA502-WEATHER-HISTORY-01. Natural object climate only;
unrecorded temporary seals and other unfinished #502 adapters remain separate.

## CA-KP-178 - Check existing furniture after adding a new installation
Status/evidence: RESOLVED-VERIFIED (native engine)
First recorded / last checked: 2026-10-27 / 2026-10-27
Issue / PR: #410; mansion bathroom delivery
Affected baseline: 2a67b934 plus5.8.22 working tree; validation_5822
Environment: GZDoom4.14.2, Windows11, unchanged campaign mansion
Scope: CaelumMansionBathrooms and quest preparation ordering

Checking only new fixture collision and use was insufficient. The first layout
could fit its twelve actors while preventing later creation of existing tables
101/103: their south chairs collided with new tubs. Native access probes reported
the tables missing. A separate visual review caught a basin at a door approach.

Prepare the accepted furnishing layout before installing additions, validate
the additions against actual local solids and check the combined final layout:
new approaches/postures/exits, old beds/tables/chairs and full door sweeps.
Inspect the actual posture camera in every orientation: successful seating
alone did not detect six wall-facing views; changing fixture angles corrected them.
The final twelve placements pass those checks without moving accepted furniture
or changing map geometry. Failed bath-layout/access logs remain private evidence.
This is an installation-order/collision lesson, not authorization to remove or
hide existing furniture. Author placement corroboration remains pending.


## CA-KP-177 - Release map-owned reservations before the hub snapshot
Status/evidence: RESOLVED-VERIFIED (native engine)
First recorded / last checked: 2026-10-26 / 2026-10-26
Issue / PR: #411; camp-cooking delivery
Affected baseline: 7b41e3fc plus5.8.21 working tree; validation_5821
Environment: GZDoom4.14.2, Windows11, private two-map hub
Scope: CaelumCampWorld.WorldUnloaded and CaelumCampCooking fire reservation

The player cancelled an attended camp recipe after arriving in another map,
but the original hub snapshot still retained Fire.Busy. On return, the fire
was correctly extinguished and fuel preserved, yet its reservation blocked use.
The native failed probe printed busy=1,lit=0,fuel=9968,expected=9968.

Cancel matching camp cooking while the departing map's typed fire registry is
still available in WorldUnloaded, before its snapshot is retained. Then apply
the existing extinguish rule. The later player-side map guard remains defensive,
but cannot replace releasing a reference owned by the departing map.

Regression: camp-hub06 and final hub checks retain unburned wood, free the fire,
keep original ingredients and create no unattended meals. No global actor scan
is added. The earlier private camp-hub04/05 logs preserve the failure.
Limitations: this lesson covers camp recipe ownership, not all cross-map tasks;
author CA411-COOKING-01 remains pending.

## CA-KP-176 - Elevated storage needs vertical collision and usable reach
Status/evidence: RESOLVED-VERIFIED (native engine)
First recorded / last checked: 2026-10-26 / 2026-10-26
Issue / PR: #410; kitchen-fixture delivery
Affected baseline: b68f93ae plus5.8.20 working tree; validation_5820
Environment: GZDoom4.14.2, Windows11, Vulkan1280x720, unchanged mansion geometry
Scope: CaelumKitchenCupboard; native storage reach and installation

An overhead cupboard inherited the ground chest's collision flags and foot-origin
distance check. Native placement rejected the counter below despite separate
vertical extents. CANPASS fixed that placement, but the ordinary3D distance still
left almost no usable approach in front of the counter. Only the elevated
subclass now measures existing reach from the user's eye to the cupboard centre,
preserving line of sight, authority and native lock checks. Ground chests keep
their original behavior. Do not remove collision or enlarge global UseRange.

Regression: validation_5820 mansion scenario tests both fixtures in real geometry,
clear standing positions, inventory source lookup and overhead native storage
access. Core checks cover limits, locks and ordinary chest carrying; save/hub
checks preserve contents. Earlier failed probes remain in the private build
directory. Author appearance/function check CA410-FIXTURES-01 is pending.
Limitations: this is not a general rotated furniture collision solver or a
rendering performance benchmark.

## CA-KP-175 - A carried Inventory sprite is not its visible Spawn artwork
Status/evidence: RESOLVED-VERIFIED (native engine and visual capture)
First recorded / last checked: 2026-10-26 / 2026-10-26
Issue / PR: #410; delivery PR links this prepared-meal slice
Affected baseline: 09b96c41 plus V5.8.18 working tree; final package in validation_5818
Environment: GZDoom 4.14.2, Windows 11, Vulkan 1280x720, private peaceful fixture
Scope: CaelumDiningTable.RefreshDisplays; CaelumDiningPreparedMeal descendants

Symptom: the real meal remained in table inventory, while a display actor copying
that Inventory's Sprite appeared invisible. Quantity assertions alone passed.
Native evidence records held and default-object Sprite values of 0, while the
four declared Spawn aliases resolve to visible indices 4798/4799/4800/613 in the
recorded package. Sprite indices are package-local, not production identifiers.

Cause: held inventory and actor defaults do not supply the visible Spawn-frame
property needed by a separate scene actor. GetDefaultByType also requires a
class, not the Name returned by an item-class lookup.
Fix: dedicated display subclasses declare the actual FBRD/FRBF/FRFS/FPCH Spawn
states; obtain existing scale from GetDefaultByType(item.GetClass()). Keep the
real Inventory as the table's authoritative item. Do not copy its hidden Sprite.

Reproduction/regression: validation_5818 m-services checks real placement,
withdrawal, native journal use and explicit non-TNT1 display aliases; tableview
captures the rendered table. The fixture's no-restock subclass includes a copy
of the existing small-table MODELDEF under its private class name.
Evidence: table-final-services02 (21 PASS/0 FAIL), table-final-capture02 and
captures/meals-table.png in assets/validation_5818. Failed probes stay in build.
Author acceptance: CA410-MEALS-01 passed on 2026-10-26, without qualifications.
Existing ration models are unchanged.
Limitations: painted world sprites remain billboards at the existing consumable
scale; visual acceptance is independent of successful inventory assertions.

## CA-KP-174 - Native crouch and safe exits during tent rest

Status/evidence: ENGINE-VERIFIED, #412, 2026-10-26; GZDoom4.14.2/Windows11.
Affected implementation: CaelumTentRest; assets/validation_5815/entry-report.json.

PlayerPawn.CrouchMove changes the factor/view but restores the old Height until
PlayerPawn.Tick applies FullHeight*crouchfactor. An immediate placement probe
must project that same native Height after CrouchMove; changing FullHeight or
Radius is neither necessary nor accepted. Restore the saved factor through
native CrouchMove, so a new ceiling can prevent standing.

The old generic furniture exit uses the furniture radius as a distance gate.
For an elongated sleeping bag that rejects a clear tent entrance. Check the
actual player capsule at the saved entrance and local fallback candidates;
include floor, water and sight. Never teleport into a newly occupied entrance.
Reserve the same bag during pre-sleep equipment cleaning, and release its
entry state on cancellation as well as normal waking.

Regression: entry-core-05, entry-clean-02, entry-exit-02 and native UI/save runs.
No per-tic full-world scan is added: tent entry/exit is event-driven, placement
uses a local blockmap and MAXPLAYERS reservations. Native menu events validate
routing; they are not a claim of physical-key or multiplayer author acceptance.

## CA-KP-172 - Separate a low furniture footprint from the user's capsule

Status/evidence: RESOLVED-VERIFIED for bag clearance, #412, 2026-10-26.
Affected baseline: fcee0384; GZDoom 4.14.2, Windows 11/Vulkan.
Scope: CaelumRestBag.HasRoom; assets/validation_5815/RESULTS.md.

The radius-46 bag probe extended to the player's height. It rejected an accepted
tent berth even though the existing 88-by-40.4-unit model and a crouched body
fit. Native original-repro/final-repro runs retain the before/after result.
Check the real body separately, then a low oriented envelope derived from the
existing model. Include small off-center obstacles and floor support throughout
the footprint; a few perimeter points do not cover its interior. The circumscribed
grid used here deliberately permits a small conservative edge overhang.

Bag models are outside the blockmap. Obtain active reservations from the bounded
player table, including pending pre-sleep cleaning, and use separating axes for
bag/bag overlap. Do not resize accepted characters, art or tents to make a probe
pass. Native crouching must be held during a crouched-body fixture; releasing
the input can restore standing height before the assertion. A helper body sized
from that later height is not evidence for a crouched second occupant.

The selected comparison calls clearance every native tic in the same peaceful
tent scene. Frame callbacks remain near the 60-FPS cap; this is not GPU/display
presentation or large-map acceptance. Two footprint/body checks and a real solo
sleep are not a two-client network test. Author check CA412-BAG-01 and shared
cooperative clock integration remain pending.

## CA-KP-171 - Native food quantities, copies and forecast isolation

Status/evidence: ENGINE-VERIFIED, #410, 2026-10-26; assets/validation_5814.
Native Inventory.CreateCopy can return self while clamping Amount. A lot ledger
must retain the oldest clamped quantity, not assume that only a newly allocated
copy changes counts. Successful Use consumes metadata once; the native caller
(or dining adapter) still decrements Amount. A failed/boxed Use must consume
neither. Native merges, partial tosses and coffer/merchant transfers require
explicit lot transfer rather than interpreting a new actor as fresh food.

Keep forecasts independent of live lot/illness objects and rebase the clock
after committing a travelled inventory. Otherwise the same elapsed journey
ages the remaining food twice. Capture storage climate before the dining
adapter temporarily changes Owner, and restore the table context afterward.
Old native saves verify fresh migration; old-package rollback uses the original
save, never an overwritten upgraded save. Fixtures must grant the persistent
Box ownership flag; a temporary live boolean is normalized away on load.

Food registration uses spawn events and a typed census only on world load,
including older owned/ground ration stacks. Each native stack owns one saved
clock; no per-tic global actor/inventory scan is added. One-second updates are
staggered, climate samples cache the civil minute, and constant Limbo exposure
integrates directly. The 500-stack peaceful callback comparison is recorded;
it establishes neither an unbounded stack limit nor city/siege performance.

## CA-KP-173 - Verify manual fixture startup, not only automated checks

Status/evidence: ENGINE-VERIFIED; #411 / PR507; 2026-10-26.
Affected baseline: 50e3e27d; GZDoom 4.14.2, Windows 11/Vulkan, final05.
Scope: assets/validation_5813/prepare.py and run_native.ps1.

The author's original manual script began with a nested exec of the canonical
controls, followed by wait/setup/binds. Running that exact script left default
engine bindings and never seeded the fixture. Adding unrelated trailing echo
commands made a separate probe pass: the precise engine scheduling cause remains
UNCONFIRMED. Passing automated scenarios did not establish a working author menu.

Inline the owned control-file commands, install diagnostic bindings before the
delayed setup, query them natively, and check a readiness marker before handoff.
The exact corrected manual entry and its smoke extension both initialize. Retain
the failed original local log; selected passing evidence is in validation_5813.
Remote key injection did not reach this game window. Binding queries and scripted
commands are not proof of physical-key acceptance; CA411-FIRE-01 remains pending.
Regression: prepare.py, then run_native.ps1 -Script manual-smoke -Runtime final05
-Checks with a fresh label; also verify the unchanged manual interactive entry.

## CA-KP-170 - Camp fuel stacks and immutable native test archives

Status/evidence: ENGINE-VERIFIED, #411, 2026-10-26; assets/validation_5813.
The existing recipe catalogue resolves one native stack per material. Returning
unburned fuel as a second attached stack hides the previous stack from crafting
counts. Merge whole grams into the matching stack and preserve the fractional
gram as saved mass-bearing metadata; test conservation over refill/recovery.

Spawn registration can precede deferred native PostBeginPlay. An immediately
usable newly assembled heat source explicitly registers during preparation;
PostBeginPlay deduplicates, destruction removes it, and save/hub load performs
one typed census. The registry owns only current-map declared heat sources;
there is no routine all-actor scan or new population cap. Fixed-source before/
after and one burning camp rendering measurements are recorded in the evidence;
they do not establish a worst case for arbitrarily many player-built fires.
The unrelated ranch census remains unchanged.

Never rewrite a fixture PK3 while an engine still has it open: a later hub map
read can fail with No map despite valid new archive contents. The affected
hub-final03 attempt timed out; rebuilding only after exit and rerunning the same
route passed. The fixture builder now refuses regeneration with GZDoom running.
Keep immutable runtime labels, raw failed attempts and final successful evidence.

## CA-KP-169 - Household work must preserve native stock and hidden metadata

Status/evidence: ENGINE-VERIFIED, #502/PR506,2026-10-25; baseline eedb1b87.
Environment: GZDoom4.14.2/Windows11/Vulkan1280x720; evidence:
assets/validation_5812/domestic. Author check CA502-HOUSEKEEPING-01 passed2026-10-25.

ZScript names are case-insensitive: local `chest`/`day` shadowed saved `Chest`/
`Day`, silently losing the selected coffer and repeatedly zeroing elapsed work.
Use distinct candidate/civil-date identifiers and test the actual scheduler,
not only direct arithmetic calls. Household targets are initialized after the
spawned fixtures receive their native initialization/linking.

Parked traveling merchants are not found by the normal actor iterator. Restore
the explicit saved registry after Travelled, then perform one typed legacy
adoption census on MAP03. Preserve the actual body, inventory, identity and
wallet; test return to the original map for duplicates and reset stock. This
one load/travel census is bounded by the city's64 authored shops, not a routine
per-tic scan. Household membership uses existing resident records (4, or8 after
the approved relocation); targets use one map-local spatial query/static grid.

Hidden contamination-carrier Inventory is metadata, not stored merchandise.
Exclude it from coffer slots and cargo weight. Otherwise a legitimate exact
payment can fail because its change and soap require the slot occupied by an
invisible record. Keep capacity rejection atomic and test ordinary repurchase,
fractional soap, wallet/stock conservation and the original save rollback.

Accelerated personal time must also drive the loaded household's native steps;
merely updating its WorldTick omits waiting/rest. Bound collision batches between
rendered frames and reject an exact-date forecast that cannot model shared water
mutations. This does not implement history for unloaded households.

## CA-KP-168 - World-object exposure must follow native inventory ownership

Status/evidence: ENGINE-VERIFIED, #502/PR506, 2026-10-25, baseline d801ae4c.
Environment: GZDoom 4.14.2/Windows 11/Vulkan, 1280x720; evidence:
assets/validation_5812/objects. CA502-OBJECTS-01 accepted on 2026-10-25.

A map-local exposure node must close elapsed time before CreateCopy or
AttachToOwner, leave owned/Box storage, and re-register on native tossing.
Copy concentration without copying its scheduler. Guard bDestroyed before
inventory lookup during teardown. A seated chair temporarily loses collision,
so its current solid flag alone cannot define physical exposure eligibility;
use its native class default as well. Test these native transitions rather
than only calling the mathematical model or assigning Owner in fixtures.

Spawn events and a shared weather service maintain staggered local nodes.
One CaelumContaminationWorld census at WorldLoaded repairs legacy/map actors;
its correctness need is attaching previously unregistered physical objects.
The bound is the loaded native actor population, not each visible subset.
Measured initial registration: 1,019 actors/1,000 nodes, 0.9535 ms; idempotent
MAP03 census: 3,738 actors/1,518 nodes, 0.7785 ms. This exception does not
authorize recurrent per-tic/per-recipient scans or imply a universal cost bound.

The matched peaceful 1,000-object renderer comparison recorded baseline/final
p95 17.157/17.385 ms, p99 17.443/17.892 ms, worst 17.747/18.883 ms; both samples
contain 1,199 callbacks and 700 tics. PresentMon trace access was denied.
Do not infer displayed-frame or whole-campaign performance from those callbacks.
Elapsed clocks rebase on load/hub return: preserving concentration does not
implement historical exposure in unloaded maps. Keep that limitation explicit.

## CA-KP-167 - Continuous native contacts need shared ownership and elapsed clocks

Status/evidence: ENGINE-VERIFIED, #502/PR506,2026-10-25, baseline c6508075.
Environment: GZDoom4.14.2/Windows11/Vulkan,1280x720; evidence:
assets/validation_5812/contact. Author check CA502-CONTACT-01 accepted2026-10-25.

Active/passive native collision callbacks can report the same pair repeatedly.
Create one shared saved link and update it once from elapsed world time; a brief
blocked movement still needs its first world-tic dose even if native collision
leaves a gap. End contact on separation/invalid ownership rather than preserving
an old collision forever. Rebase transient time after hub/load so map absence
cannot become retroactive physical contact. Rebind cached outer equipment
endpoints without per-tic allocation. Native TryMove, stationary clock, brief
contact, separation, current/old saves, hub and rollback tests cover these paths.

A peaceful1,000-body/500-pair native comparison retained similar callback cadence:
mean16.667/16.668ms, p9517.366/17.391, p9918.103/18.082, worst22.949/19.611.
Both ran700tics with1,000 survivors; only the final500 receivers gained exposure.
No global actor scan is introduced: registration searches only local pair lists,
and only active pairs tick. No population cutoff or offscreen suspension exists.
AI/thermal/movement were equally disabled for this isolated cost comparison.
PresentMon access failed; callback timing is not displayed-frame or campaign
performance acceptance. Follow CA-KP-110/115 rather than claiming FPS from35Hz.

## CA-KP-166 - Hidden inventory carriers must leave world links before attachment

Status/evidence: ENGINE-VERIFIED, #502, GZDoom4.14.2,2026-10-25.
Evidence: assets/validation_5812/npc; the author's local CrashReport.zip is
preserved in ignored build/issue502-hygiene/npc-hub02-author-crash.zip.

Spawning a hidden inventory actor then calling owner.AddInventory alone omits
Inventory.BecomeItem. The item retains sector/blockmap/thinker-world participation.
Under repeated NPC contamination, two native hub tests crashed in CAH001 with
C0000005, write to0xbeefcafe. AttachToOwner invokes BecomeItem before AddInventory;
using it removes the reproduced crash. Native source reference:
https://github.com/ZDoom/gzdoom/blob/g4.14.2/wadsrc/static/zscript/actors/inventory/inventory.zs

Use the complete native attachment path for created hidden inventory. Existing
owned contamination carriers use lazy attachment revision1: BecomeItem once,
preserving owner and all stored values. Never reset contamination as migration.
DetachFromOwner is an empty notification by default; removing an inventory item
requires the owner's removal/drop path. Test fixtures must reacquire hub-owned
NPC inventory from its owner rather than retaining cross-map player references.

Regression: current save/load and hub return, previous-runtime saves and hub
return, idempotent migration, original-runtime rollback, real-clock NPC exposure
and previously accepted melee/calendar behavior. The author accepted CA502-NPC-01 on2026-10-25; this is separate from those
engine checks.

## CA-KP-165 - Native melee defaults to None; test the delivery path

Status/evidence: ENGINE-VERIFIED; #502,5.8.12,2026-10-25; author review pending.
Environment: GZDoom4.14.2/Windows11/Vulkan. Evidence: assets/validation_5812/combat.

The engine declaration of A_CustomMeleeAttack defaults its damage type to None.
Direct diagnostic DamageMobj(...,'Melee') calls therefore do not establish that
an authored attack follows the same route. Three production NPC call sites omit
that argument. Existing player None damage bypasses directed defenses; changing
the argument would also change shield/evasion/armor behavior and needs its own
review. The contamination adapter instead marks the synchronous native delivery,
restores its previous mark afterward and rejects unrelated None damage.

Regressions cover a native sword LineAttack, A_CustomMeleeAttack with its original
None type, explicitly directed shield contact, evasion and unmarked generic damage.
A friendly diagnostic attacker can fail native melee-range checks against the
player despite a manually assigned target: use a hostile fixture with autonomous
AI disabled, rather than replacing the actual attack with direct damage. Wait for
native PostBeginPlay before testing modeled NPC loadouts (CA-KP-160).

## CA-KP-164 - Interactive diagnostics must yield and isolate scenario state

Status/evidence: ENGINE-VERIFIED diagnostic correction; author acceptance pending.
First recorded / last checked: 2026-10-25 / 2026-10-25.
Issue: #502,5.8.12. GZDoom4.14.2/Windows11/Vulkan,1280x720,60FPS cap,
5% audio, unpaused background. Evidence: assets/validation_5812/surfaces/responsiveness.

The surface laboratory advanced30 world minutes in one network event. Native
timing measured53-55ms inside that command and70-72ms worst render-callback
intervals. Repeated rain setup also jumped days without resetting the synthetic
surface epoch, producing a103ms interval while replaying pending exposure.
Old equipped dirt survived the body reset, making rain seem to contaminate the
character even though the exterior comparison was being washed.

Interactive F5 now schedules at most16 shared personal steps or2ms per native
tic, preserving all steps and counting normal clock progress toward the target.
Duplicate presses cannot queue additional work; scenario resets cancel it.
The CAS502-only fixture clears body/equipment and sparse surface history after
its artificial date jump. Production persistence and contamination are unchanged.
Matched repeated-action maxima are17.86ms for rain setup and17.53ms for wait;
the dry control retains its22.50ms maximum. These are native callback intervals,
not application presents or GPU/display timing; prior PresentMon trace access
was denied. Short diagnostic windows do not establish campaign-wide60FPS.

Keep a diagnostic's untouched controls separate from the player's exposure.
Label whether a reading measures body, outer equipment, ambient source or
comparison surface. Test the author-facing action as well as its underlying
arithmetic, including repeated setup, cancellation and contaminated prior state.

## CA-KP-163 - Explicit local actor occupancy for sanitary seating

Status/evidence: ENGINE-VERIFIED / RESOLVED-VERIFIED
First recorded / last checked: 2026-10-25 / 2026-10-25
Issue: #502,5.8.12 posture continuation. GZDoom4.14.2/Windows11/Vulkan.
Evidence: assets/validation_5812/postures; pose-core-c fails, pose-core-d and
pose-final-core pass. The production toilet and player remain solid; noclip is off.

In the isolated fixture, SetOrigin plus TestMobjLocation accepted the toilet center
while a solid CaelumRestChair occupied that same point. Therefore that test alone
was insufficient for this entry path. Sanitary entry/exit and collision restoration
now additionally inspect overlapping solid actors with a local BlockThingsIterator,
using their horizontal extents and vertical overlap. Do not infer an engine-wide
cause from this reproduction. Keep the native geometry/floor check as well.

The query runs on explicit entry/exit and while one of the three local fixtures
awaits clearance after release. It does not enumerate the world or run per NPC.
The blocked-exit fixture verifies no telefrag, no forced movement and delayed
solid restoration. No new frame-time or campaign-wide performance claim is made.

## CA-KP-162 - Forecast exposure with the same local shelter as execution

Status/evidence: ENGINE-VERIFIED / RESOLVED-VERIFIED
First recorded / last checked: 2026-10-25 / 2026-10-25
Issue: #502, 5.8.9 immersion continuation.
Evidence: assets/validation_589/immersion, wait01..04 and RESULTS.md.

The weather journal's cached Shelter is not an interchangeable input for the
thermal exposure model. After moving into the partial 3D water fixture, that
forecast used ambient contamination 5.572831045166 while native thermal contact
used 5.759055277581. Both paths now use the same ClimateShelter classification
with current thermal roof/wind geometry. The 35-personal-tic wait then matches
exactly at C=21.180438728835. Do not widen tolerances to hide a different physical
input. Capture independent forecast state, share its classification policy with
execution, and decline exact predictions for dynamic geometry not yet modeled.
This evidence is limited to the tested player wait/travel integration; it is not
a guarantee for every weather, map or future reservoir projection.

## CA-KP-161 - Avoid reserved names and State statement ambiguity in ZScript

Status/evidence: ENGINE-VERIFIED / RESOLVED-VERIFIED
First recorded / last checked: 2026-10-24 / 2026-10-24
Issue: #502. Baseline: 87dceb9e plus the persistent-state changes.
Evidence: assets/validation_589/storage/native, core01/core02 and core04.
GZDoom 4.14.2 rejects a method named Protected. A local named state can also
misparse at the start of a write statement (`state.Concentration = ...`), where
the parser expects a State expression. Renaming these to IsShielded and entry
compiles and passes the same native fixture. Do not infer that every occurrence
of the identifier state is invalid; the verified failure is this statement form.

## CA-KP-160 - Do not retain live actor references into an unloaded hub

**Evidence:** native isolated test, 5.8.8/#411;
`assets/validation_588/deploy`, failed deployhub01 and passing deployhub04.

A carried test record's pointers to a deployed tent and its inventory become
null while that map is unloaded. The map's own saved tent, original item and
collision parts still survive. Do not interpret the absent cross-map pointer
as lost property or recreate a replacement item. Verify the loaded structure
locally after returning, using its saved identity data and original quantity.
Transient typed registries must rebuild once on map/save/hub load and track
subsequent creation/destruction; they must not own or manufacture the objects.
The camp registry skips local block queries entirely on maps with no tents.

**Scope/performance:** one typed tent census per load, no periodic global scan.
The actor population is the loaded map; the output is bounded by actual deployed
tents, not an invented gameplay cap. The isolated 20-tent/1,600-part diagnostic
repeats the census 100 times: mean 0.008428 ms, maximum 0.037800 ms on the recorded
Ryzen 9 5950X/GZDoom 4.14.2 run measure02. This is a load-census cost, not a frame
presentation or rendering-acceptance claim. Normal shelter sampling uses the
local blockmap only when that registry is nonempty.

## CA-KP-159 - Finish a local line iterator before nested collision queries

Status/evidence: ENGINE-VERIFIED / RESOLVED-VERIFIED
First recorded / last checked: 2026-10-24 / 2026-10-24
Issue: #411. Baseline: bf9cb340 plus the placement worktree changes; probe02
fails and probe03 fixes the traversal. GZDoom 4.14.2 / Windows 11 / Vulkan.
Scope: CaelumPlacementGeometry.Fits and native BlockLinesIterator.

A four-MU liquid strip inside an otherwise dry footprint passed validation
when TestMobjLocation ran during an active line iteration. The fixture could
independently enumerate both strip boundaries and reject an individual liquid
sample, yet the combined pass skipped those boundaries. Adding a point-sector
terrain guard alone did not fix it. Snapshotting the local Line references
before support/collision queries fixes the same reproduction. This establishes
iterator invalidation by nested native collision traversal; the internal engine
counter mechanism is not inferred as source-verified from this experiment.

Finish the bounded spatial query before invoking another native collision query
inside its processing. This snapshot is local to one explicit placement action;
it is not authorization for routine global scans. Keep the snapshot transient,
with no simulation yield while its map references are used.

Evidence: assets/validation_588/native/core01, core02, strip03 and core04 logs;
core05 retains the narrow-strip regression alongside 3D water and dry elevated
support. Run the core script against probe02/probe03 to compare. Author manual
acceptance remains pending as CA411-PLACEMENT-01. No FPS claim is made.

## CA-KP-158 - Saved readiness is not a migration gate; hub identity is not a raw pointer

Status/evidence: ENGINE-VERIFIED; #411 / 5.8.6, 2026-10-24, GZDoom 4.14.2.
Evidence: assets/validation_586/RESULTS.md and retained legacy-load/return logs.

A save can restore a resident registry with Ready already true. A new migration
inside its initialization path will then never run unless the saved schema
revision is checked independently. Run the additive, idempotent revision check
before that readiness shortcut. Verify an actual pre-patch save loaded directly
inside an already initialized house, then leave, return and reload migrated state.

Preserve native actor pointers while explicitly transporting bodies, chests and
inventory. After placing a chest in a native hub map, however, unloading that map
can clear an external actor pointer. On revisiting the map, verify its stable TID,
lawful/lock tokens, contents, quantity and uniqueness; pointer equality across
native hub restoration is not a valid universal identity assertion. The production
registry should release its pending relocation reference once placement succeeds.

Invisible interaction portals still need sight/reach validation. Use
SF_IGNOREVISIBILITY when the portal itself is intentionally invisible; default
CheckSight rejected every payment even though the visible menu opened correctly.
Test the real session action, not only a direct call to the transaction function.

## CA-KP-157 - Moving swimmable planes and resolving source identity are separate

Status/evidence: ENGINE-VERIFIED geometry; OPEN quality integration. #414,
2026-10-23, GZDoom 4.14.2 / Windows 11. Evidence: validation_580/RESULTS.md.

Use native `Sector.MoveCeiling` on a swimmable 3D-floor control sector and convert
the desired height with `ceilingplane.PointToDist`; the destination is a plane
distance, not an assumed unsigned world height. In the bounded horizontal-pair
fixture, attached surfaces, native WaterLevel and thermal sampling follow the
move. Native sector references/planes and map-local EventHandler fields survive
save/load and hub return. An unrelated control sector remains unchanged.

Do not infer source identity from the player's containing sector alone: the
swimmable volume can use a separate control sector. The existing #408 reader
returns unidentified in this case, even though native immersion is correct.
Check quality, conservation, boundaries and persistence independently. This
proof does not establish concentration chemistry, arbitrary connected terrain,
calendar catch-up, production flow rates or rendering performance at scale.

## CA-KP-156 - HUBPOWER alone loses pending recovery outside a hub

Status/evidence: ENGINE-VERIFIED; #472, 2026-10-23, GZDoom 4.14.2 / Windows 11.
Evidence: assets/validation_5714/RESULTS.md and native travel logs. The initial
cross-map test retained the mate contents but lost its pending recovery Powerup.
GZDoom's PlayerPawn.FinishLevel removes nonpersistent powers when leaving a hub;
INVENTORY.HUBPOWER only covers FINISH_SameHub. The new mate recovery explicitly
uses INVENTORY.PERSISTENTPOWER as well, preserving its remaining timed doses.

Use an actual transition to a different cluster when the item contract promises
cross-map effects. Same-map saves and same-hub tests cannot establish this case.
Keep this policy local to the affected power; it does not authorize changing
unrelated consumables or deathmatch rules. Native save/load and timed expiry
must still pass after adding persistence.

## CA-KP-155 - Lethal native damage can detach a ticking inventory

Status/evidence: ENGINE-VERIFIED; #479, 2026-10-23, GZDoom 4.14.2 / Windows 11.
Evidence: assets/validation_578/owner_death_report.json and its native logs.

CaelumSupportStatus.Tick validated Owner on entry, but DamageMobj could kill
the recipient, synchronously call OwnerDied and destroy/detach the inventory.
The later Owner.health read then aborted the VM. Revalidate the owner after
callback-producing native damage before accessing it again or processing another
effect. The fix does not require a global scan or a save-schema change.

Include lethal outcomes and simultaneous effects in periodic-damage tests;
nonlethal arithmetic, expiry and ordinary controls did not cover this lifetime.
Private reset controls must recreate dead actors instead of changing corpse health.
Set test damage/health after deferred PostBeginPlay when its initialization can
overwrite those fields. Accepted art and unrelated gameplay need not be retested.

## CA-KP-154 - Removing a MODELDEF include needs a complete-package check

Status/evidence: ENGINE-VERIFIED and agent visual inspection; #479, 2026-10-22,
GZDoom 4.14.2 / Windows 11 / Vulkan. Evidence:
assets/validation_578/diagnostics/painted-gallery-01-art-00.png and its native
log/launch record, contrasted with visuals/painted-final-gallery3-art-world-00.png
and painted_report.json. Author art acceptance remains pending.

The sprite correction removed a MODELDEF include, but a small add-on over the
earlier full PK3 still displayed the previously registered world model. The
new first-person sprite already loaded correctly, so texture/state assertions
alone did not reveal that mismatch. Omitting a model definition in a later lump
does not unregister the definition contributed by the earlier package.

Validate removal/replacement of model bindings with a complete rebuilt package
and no obsolete add-on. Match every packaged entry to src and inspect the world
actor as well as inventory/first-person views. Keep overlay-only evidence
separate; the rebuilt #479 package renders the requested billboard sprites.

## CA-KP-153 - Declare overlay state use and keep shared hand layers stable

Status/evidence: ENGINE-VERIFIED and agent visual inspection; #479, 2026-10-22,
GZDoom 4.14.2 / Windows 11 / Vulkan / 1280x720. Evidence:
assets/validation_578/RESULTS.md, diagnostics/gallery-01.txt and
visuals/complete-gallery-contact.png. Author check CA479-01 remains pending.

A new Actor frame bank used by weapon PSprites must declare
`States(Actor,Weapon,Overlay)`; otherwise native loading reports states not
flagged for weapon/overlay use even when their textures exist. Descriptive PNG
filenames under sprites also enter the native frame-name parser: keep these
first-person projections under graphics and reference them through TEXTURES.

When reusing appearance hands, retain the hand overlay across frames. Clearing
and recreating it each update lost the shared placement and left a floating hand.
Use the same grip in the projected texture offsets, pose pivot and layer
placement; review native captures for every type/tier. The final gallery resolves
all 18 icon/pose variants and shows distinct native frames. Asset-resolution
assertions alone do not prove grip alignment or author acceptance.

## CA-KP-152 - Bound OBJ surface runs when baking material shading

Status/evidence: CODE-VERIFIED and isolated native reproduction; #471,
2026-10-22, GZDoom 4.14.2 / Windows 11 / Vulkan. Author visual acceptance
CA471-ART-01 passed on 2026-10-22. Evidence: assets/validation_576/RESULTS.md and
failure-diagnosis.json; deterministic generator and per-model surface counts
in assets/generators/alchemy_ingredients_manifest.json.

Every `usemtl` run creates a new OBJ surface, even when its material appeared
earlier. Per-face baked shading produced 63?232 surfaces in this batch; the
first isolated saltpeter model had 182. The author reported `Trying to create
zero size texture` after all setup assertions passed. The failure persisted
without the gallery overlay and disappeared with the models invisible.

Target-engine sources: [model.h, MD3_MAX_SURFACES=32](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/models/model.h#L30),
[OBJ loading and rendering](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/models/models_obj.cpp#L633),
[Vulkan texture size guard](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/rendering/vulkan/textures/vk_hwtexture.cpp#L138).
RenderFrame indexes surface skin IDs without the i<32 guard present in AddSkins.
Do not rely on benign results from an out-of-range read: some earlier runs
rendered, others terminated. Native process completion and actual visual review
are required in addition to setup assertions.

Group opaque faces contiguously by material before export; this batch now has
8?20 surfaces per new mesh with unchanged face/vertex counts. Enforce the limit
in generation and verification. This also avoids unnecessary surface submissions;
no frame-rate improvement is claimed without measurement. Keep independent
accepted meshes untouched. Do not apply a global renderer/backend workaround.

## CA-KP-151 - Hidden-window screenshots can retain a stale scene

Status/evidence: ENGINE-VERIFIED; #470, 2026-10-22. Baseline 992da877 plus
5.7.4; GZDoom 4.14.2 / Windows 11 / Vulkan / 1280 x 720. Author check
CA470-01 passed author review on 2026-10-22. Evidence: assets/validation_574/report.json,
final-hidden/final-visible logs and visuals/hidden-view.png versus mansion-view.png.

The hidden native process accepted network events, moved the player to the
station, opened crafting and reported passing assertions, but its screenshot
still showed the initial outdoor view. Closing the introductory conversation
was necessary for the fixture but did not resolve the hidden rendering issue.
Matched hidden/visible launches with the same package and fixture confirmed
that a visible window rendered the requested station view. Record window
visibility in evidence. Do not infer visual correctness from simulation checks
or use a hidden-window screenshot without confirming its scene/camera.
This is a measured environment-specific behavior, not a claim about every
GZDoom backend or every background window. Use a visible background window
for visual/presentation capture when the author has authorized live tests;
keep the usual unpaused/5%-audio settings and avoid overlapping native runs.
PresentMon separately required Windows privileges unavailable in this session;
render callbacks do not establish display cadence or GPU duration.

## CA-KP-150 - Clamping elapsed time does not prevent replay after a clock rewind

Status/evidence: ENGINE-VERIFIED; #406, 2026-10-22. Baseline 5.7.2 versus the
5.7.3 source-clock guard; package identities and commands are retained in
assets/validation_573/report.json. GZDoom 4.14.2 / Windows 11 / Vulkan,
Ryzen 9 5950X / RTX 3070 Ti, unpaused background, 5% audio.

Scope: CaelumEnvironmentProp.SyncResourceClock, using persisted campaign time.
The previous `max(0, now - stamp)` still assigned `stamp = now` when time moved
backward. Returning to the previously credited time then regenerated the same
interval a second time. The prior runtime fails three boundary assertions;
the monotonic guard passes them without changing rates, capacity or saved data.

Prevention: ignore observations at or below the credited stamp; advance the
stamp only when applying a genuinely new interval. An unstamped legacy source
initializes at its first observation without invented historical credit. Use
one capped arithmetic catch-up, preserving fractional extraction carry and
calendar identity. If a recovery deadline is recalculated during a rewind,
include the delay until the credited stamp is reached. Calendar dates and
source elapsed-time stamps have different origins: convert the delay only.
The guard-only build reproduced an early deadline; the final patch corrects
it. Merchants retain their own authoritative stock clocks.

Reproduce with validation_573/prepare.py and run_native.ps1, Script boundaries,
against baseline/current packages. The same native fixture tests a million-day
catch-up without iterating missed days. Matrix/save/hub checks cover partitioned
elapsed time, cap, finite/decorative exceptions and save compatibility. This
clock-correctness result does not establish rendering performance or author
acceptance by itself. The author separately passed CA406-01 on 2026-10-22.

## CA-KP-149 - Cache production quotes and process only elapsed stock deficits

Status/evidence: ENGINE-VERIFIED; #385, 2026-10-21. Baseline e38871f5 plus
the 5.6.11 patch; final package identity in assets/validation_5611/report.json.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, Ryzen 9 5950X / RTX 3070 Ti,
1280x720, 60-FPS cap, unpaused background at 5% audio.

Scope: CaelumShopRestock and the existing full crafting-blueprint quote. The
392-product library takes 18.2631 ms to quote every product at once in a deliberately
fully depleted fixture. Repeating those quotes each world tic would introduce
unnecessary work. Cache each product's duration when its first deficit appears;
retain a next-due timestamp and one earliest deadline per merchant. Full native
stock needs no quote. An inactive merchant catches up only when opened, using
arithmetic capped at its current deficit, never a loop over historical units.

Measured 30-day catch-up was 0.0146 ms; idle active-shop guard averaged 0.000086 ms
over 1,000 calls. There is no world-actor scan. Ten seconds of isolated open-library
callbacks averaged 60.019 FPS, p95 16.792 ms, p99 17.069 ms, worst 29.173 ms. These
are application callbacks, not OS presentation or city/mansion acceptance.
Reproduce with validation_5611 prepare.py and the generated perf.cfg; report.json
contains complete commands/environment and native/perf-final-01.txt raw samples.
Regression: serial/concurrent deadlines, no repeated load/open output, exact-item
trade-ins and full catalogue coverage in checks.zs. CA385-01 passed author review on 2026-10-21.

## CA-KP-148 - Native inventory transitions can reset a cached world sprite

Status/evidence: ENGINE-VERIFIED. First recorded / last checked: 2026-10-21.
Issue: #387; baseline f4c87d6e plus the 5.6.7 object-art patch. Environment:
GZDoom 4.14.2 / Windows 11, private CLTHQA/TMAINT fixtures, unpaused, 5% audio.
Scope: CaelumClothingPickup's local derived presentation cache.

Symptom: an unchanged garment type is insufficient to validate its sprite cache.
CreateTossable may return the same native object and reset it to Spawn. The cached
type then still matches while the visible sprite is the default formal outfit.
Acquisition also hides the native object's sprite until its next ownership tick.

Prevention: cache the resolved sprite index as transient data and require the
actual sprite/frame to match before skipping the refresh. Resolve unacquired
items through PreviewItemType, not the default ItemType. Rebuild owned and world
presentation locally after native transitions; do not add a global actor scan,
saved visual identity or another item grant.

Evidence/regression: validation_567 suite-02 reproduced 24 wrong dropped sprites;
final native checks drop/reacquire all 25 types and inspect their next engine tick,
plus HC/BS argument pickups rejected for capacity. Current and actual old saves
and hub/non-hub travel verify transient reconstruction. Native fixture compile
errors and pre-tick diagnostic failures are retained separately from passing runs.
This evidence covers object presentation, not unfinished worn/preview/first-person
art or a rendering-performance acceptance.

## CA-KP-147 - Move clothing moisture ownership without duplicating armor profiles

Status/evidence: ENGINE-VERIFIED. First recorded / last checked: 2026-10-21.
Issue: #386; baseline b92de0b3 plus the 5.6.6 clothing patch. Environment:
GZDoom 4.14.2 / Windows 11, private Doom II development fixture, unpaused,
5% audio; exact package/configuration hashes in assets/validation_566/report.json.
Scope: CaelumClothing, CaelumThermalBody/Data/Service, native inventory weight.

Constraint: existing armor profiles already include underclothes. Turning the
implicit outfit into inventory items must neither add that insulation twice nor
leave its old water reserve behind as a second copy. Native dry UnitWeight also
does not by itself include ThermalWaterKg in capacity or display calculations.

Prevention: a numbered, one-time conversion moves BaseWaterKg onto four native
garments and preserves equipped armor IDs. Armor still selects the complete
thermal profile. Water is shared within its existing capacity; changes of
capacity drain excess into an explicit runoff counter before evaporation, with
no latent cooling. Stored pieces retain their own water. Native transfer and
equipped/carry summaries use wet mass once, while valuation uses dry inputs.

Evidence/regression: validation_566's suite crafts all 25 garments and exercises
wet chest capacity refusal, exact transfers, armor coexistence and runoff mass
conservation. Actual wet armored 5.5.8a and 5.6.5 saves migrate; original-package
rollback, revised saves and hub/non-hub travel are tested separately. CA386-01
passed author acceptance on 2026-10-21. No NPC wardrobe or large-map performance
claim follows from these isolated checks.

## CA-KP-146 - Manual combat thrust must respect DONTTHRUST

Status/evidence: AUTHOR-REPORTED and RESOLVED-VERIFIED, #382/5.6.5, 2026-10-21.
Baseline: 59f9844c. Environment: GZDoom 4.14.2 / Windows 11, isolated LOCKTEST.
Scope: CaelumPlayer.ApplyAttackPushToTarget and CaelumCombatActor.ApplyActorAttackPush.

The author reported that a blunt hit broke a padlock and also moved its chest,
despite the chest's existing DONTTHRUST flag. Combat applies an explicit Thrust
after successful damage; this bypassed the native damage-thrust protection.
The original real-hit check asserted break/theft/content but omitted position.
`push-before-01` adds that assertion and reproduces movement. Both helpers now
reject receivers with bDONTTHRUST before computing or applying impulse. Reset
LastAttackPushForce/LastCombatPushForce first, so a previous successful push
cannot leak into the player's uppercut vertical addition.

Evidence: assets/validation_565/push-report.json records real-hit and save/reload
passes plus positive controls for ordinary combatants and rocks. Movable rocks
explicitly clear DONTTHRUST; rooted/fixed objects retain it. The runtime delta
is limited to those two helpers. Independent review is static; the author
accepted the corrected CA382-01 retest on 2026-10-21. This does not redefine pushes from unrelated systems such as
PolyObjects (CA-KP-118), nor teleport a chest moved by an earlier saved hit.

## CA-KP-145 - Compare saved identity values across hub graph reconstruction

Status/evidence: RESOLVED-VERIFIED, #382/5.6.5, 2026-10-21.
Baseline: cee86040 plus the uncommitted #382 implementation; final source/package
hashes are recorded in assets/validation_565/report.json.
Environment: GZDoom 4.14.2 / Windows 11; TMAINT -> THAZARD -> TMAINT.
Scope: CaelumLawfulIdentity, CaelumLockIdentity and native chest/key access.

A stationary chest and traveling key/profile can reference the same Object
before leaving a hub map but distinct reconstructed Object copies on return.
Pointer equality therefore rejected the owner's key and lawful title even
though native item ownership and contents survived. A same-map save/load alone
did not expose this defect. The isolated hub-01 reproducer failed two identity
checks; hub-02 passes all four after comparing nonempty serialized value tokens.

Generate an identity once, save it and compare its value at entitlement/access
boundaries. Household title uses the authored map identity; new player titles
and lock pairs use a dedicated random stream with four 31-bit words. Never
replace native Actor.Inv/Owner or regenerate identities during load. Keep the
stationary-world/traveling-player round trip in the regression set; direct
pickup/drop and same-map save tests cover different serialization paths.

Evidence: validation_565 retains the failed and corrected run logs plus current
save/reload/travel checks. Independent review confirmed the affected boundaries.
CA382-01 passed author acceptance on 2026-10-21. This establishes the tested hub behavior, not a
general guarantee for every engine object graph or mathematically unique RNG IDs.

## CA-KP-144 - Keep a nested exec on its own configuration line

Status/evidence: AUTHOR-REPORTED and CODE-VERIFIED, 2026-10-20.
Scope: interactive fixtures #377/#381/#378/#384, GZDoom 4.14.2.
The author reported missing book/chest setup in #378/#381; their startup logs
contain no setup events. #384 similarly omitted its interactive preparation.
Upstream g4.14.2 src/common/console/c_dispatch.cpp FExecList::AddCommand parses
a line beginning with exec specially: every remaining argument is a filename.
Consequently `exec controls.cfg; wait 35; netevent setup` does not enqueue the
following gameplay commands as intended. Put the controls exec on one physical
line and the complete wait/setup chain on the next. Do not split an intentional
wait chain across physical lines (CA-KP-098 still applies).

The isolated automated suites did not use that nested exec prefix; their passes
did not verify the author launcher. Manual setup commands recovered the objects;
the author then accepted CA378-01 and CA381-01. The corrected automatic launch
is source-verified, not yet a new native startup result. Keep that distinction
until a fresh launch actually confirms readiness. Each fixture correction is
committed to its own issue branch and leaves frozen production packages intact.

## CA-KP-143 - Guard native death callbacks and every unblock route

Status/evidence: RESOLVED-VERIFIED, #384/5.6.4, 2026-10-20.
Baseline: a3e25502; final source/package hashes in assets/validation_564/report.json.
Environment: GZDoom 4.14.2 / Windows 11, native DropItem fixture and actual MAP02.
Scope: CaelumCombatActor.Die, A_CaelumNoBlocking and frozen-death states.

Native Actor.Die calls OwnerDied and WorldThingDied before setting KILLED.
A KILLED check alone does not prevent reentry; use a transient dispatch guard
as well. A_NoBlocking clears solidity but does not itself consume DropItem
metadata. Commit a serialized entitlement before calling it, and retain it
across resurrection. An old suspended archive's current non-solid flag is not
proof of prior delivery: inspect the archived pre-suspension state.

GenericFreezeDeath/A_FreezeDeathChunks calls native A_NoBlocking directly,
bypassing a differently named project wrapper. Audit inherited states as well
as local calls. The correction delegates chunks to a metadata-free plain Actor
while the original owns BossDeath/drop. Do not copy engine implementation code
when the native routine can provide the effect. Old serialized Actor ice states
need both phases redirected, entry functions suppressed and remaining tics
preserved; append new states instead of shifting historical indices.

Reproduce with validation_564's probe and old ice-save/ice-finish scripts.
Separate baselines fail four dispatch/drop checks and one resurrected-ice check;
final tests pass, including saved phase/timer checks. Allow deferred
PostBeginPlay before fixture damage, and reacquire map-local fixture bodies by
TID after hub travel: player inventory pointers to a departed map are cleared.
No new per-tic global census or drop catalogue is involved. Native tokens are
fixture-only; current campaign DropItem metadata is empty. CA384-01 passed
author review on 2026-10-20; the fixture does not establish campaign balance or performance.

## CA-KP-142 - Normalize work before reversing rounded material quantities

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #378/5.6.3, 2026-10-20.
Environment: GZDoom 4.14.2 / Windows 11; `assets/validation_563`.

Trigger: introducing a shared time base across efficiencies while material loss
already affects rounded input quantities. Multiplying the rounded inputs by the
inverse efficiency does not recover that base. One proportional bronze output
uses 5/3/2 inputs at 25/50/100%; naive inverse scaling produces bases 5/6/8.

Rule: preserve the requested output and operation shape. For proportional
subrecipes, recompute each input at the reference efficiency before summing.
For fixed-input batches with rounded output yields, preserve the reference batch
duration and normalize by its actual output. Keep actual material consumption
separate from the time calculation; freezing a started task also freezes its
output-based practice claim.

Verification: native tests cover one-unit bronze convergence at mastery, the
fixed bronze batch's original 25% time per unit, stock-partial recursive output
credit, cancellation and frozen started-task time. This is a numerical lesson,
not authorization to change recipe proportions or material yield.

## CA-KP-141 - Nested native owners need explicit travel and TID restoration

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #381/5.6.2, 2026-10-20.
Environment: GZDoom 4.14.2 / Windows 11; `assets/validation_562`.
Primary source: [GZDoom 4.14.2 g_level.cpp](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/g_level.cpp),
`FLevelLocals::StartTravel` and `FinishTravel`.

Native travel moves the pawn and its direct inventory. A chest Actor referenced
by an inventory handle and that chest's own inventory need explicit lifecycle
hooks. Merely retaining pointers does not keep them alive. Do not give an
Inventory item its own Inv list: Inv is also its sibling link in its owner's list.

The focused probe moved the owner and contents through STAT_TRAVELLING and back
to their original statistic lists in the handle's Travelled hook. Their identity,
owner and quantities survived. A stronger test with a nonzero chest TID then
failed lookup after every transition despite those other checks passing.
Unlink the map-local TID chain before departure (retain the integer separately),
and reinsert it on arrival as well as restoring world/thinker links. The corrected
runtime passes both hub returns and non-hub travel. Bookkeeping is bounded by
the carried owner's native inventory, not a global actor scan.

Also bind content policy to the travelling owner: a cardinal labyrinth chest
must not consult its new map to decide whether to seed its old catalogue.
Tests preserve a partial allocation through MAP02 -> THAZARD -> MAP02.
These results do not establish full multiplayer or rendering performance.

## CA-KP-140 - Revalidate the selected trade item as well as its price

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #377/5.6.1, 2026-10-20.
Environment: GZDoom 4.14.2 / Windows 11; isolated native merchant fixtures.
Baseline: `2c90af69` (5.6.0), `assets/validation_561`.

Palomo's sale snapshot rebuilds the visible rows and may select another product
when the prior row disappears. The old Execute path compared only the quoted
price after refreshing. Removing selected raw copper while raw tin remained
allowed the equal-price replacement to be sold. The baseline fixture reproduces
the unintended quantity/payment change; the revised fixture rejects it.

Capture product, mode, quantity and price before refresh, and reject any changed
part before committing. City rows additionally retain the exact native object
reference. A UI snapshot is neither ownership nor permission: the city service
also checks that the session belongs to the requesting pawn and active vendor.
This lesson concerns the tested synchronous trade path, not a claim of complete
multiplayer support or fault injection for native allocation exhaustion.

## CA-KP-139 - Console waits do not prove queued fixture events have advanced

Status/evidence: ENGINE-VERIFIED, #369/5.5.8, 2026-10-20.
Environment: GZDoom 4.14.2, Windows 11/Vulkan; isolated bull inspection room.
Evidence: `assets/validation_558/evidence-coat`, superseded pose failure,
diagnostic07 and final coat-poses logs.

At initial map load, the idle screenshot ran before the queued idle setup
event. Setup and its assertion then arrived at tic 17; the helper still held
its previous tic-16 charge pose despite an idle owner. A diagnostic direct
UpdateVisual selected idle immediately, ruling out incorrect pose routing.
That forced call is diagnostic evidence only, not a passing native-tick test.

Gate the check from WorldTick after setup, and defer the following pose until
the check runs. The final test records setup 17, helper update 18 and check 19,
then passes all 13 pose checks without forcing UpdateVisual. Console `wait`
and screenshot ordering alone do not establish simulation-event completion.
Retain failed/diagnostic logs separately; this finding required no production
combat or presentation-logic change.

## CA-KP-138 - Hub teardown must prevent lazy recreation through the final tic

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #369/5.5.8, 2026-10-19.
Environment: GZDoom 4.14.2, Windows 11/Vulkan; private two-map hub and actual
pre-5.5.8 runtime. Evidence: `assets/validation_558`, failed current06 hub save
and corrected current07 save/return.

WorldUnloaded runs before SnapshotLevel, but that ordering does not prove that
no actor Tick can occur between them. The first bull-model registry released
all helpers on WorldUnloaded; the final tic lazily recreated four helpers.
Their saved spawntime was 56 and the map snapshot time 57. The old runtime
loaded the active map, then failed on hub return with Unknown object class.

Set a map-transition gate before teardown, and keep lazy recreation disabled
until WorldLoaded resets it. Restore the owner's native sprite before retiring
the helper. Maintain a typed registry by spawn/destruction; rebuild once on
WorldLoaded, with population bounded by the map's presentation helpers. No
routine global actor scan is needed. Test both active and inactive map JSON
for helper instances, then load and return with the actual previous runtime.
The corrected snapshots contain zero helpers and both native return paths pass.
Archived owners need independent helper retirement because their Tick is stopped.

Related animation check: native MD3 interpolation follows state time, even
when a custom frame selector follows distance. Repeating an integer frame can
produce forward interpolation and snapback on a stationary body. #369 disables
interpolation only for distance-driven gaits and checks stopped rendered samples;
time-driven clips retain native interpolation. This is not an FPS acceptance.

## CA-KP-137 - A combat clock refresh can commit an attack

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #310/5.5.1, 2026-10-18.
Baseline: accepted #309, ca8206bc. GZDoom 4.14.2, Windows 11, Vulkan,
private native fixtures. Scope: CaelumCombatDispatch and pawn attack adapters.

`RefreshWeaponAttackClock` is not a read-only timer query: a mature physical
preparation can release its hit, and a completed magical preparation can pay
Anima and spawn projectiles. Checking receiver authority only immediately before
starting the next action is too late. Apply `CaelumPlayerAuthority.CanMutate`
before any refresh or special-weapon request in a dispatch service. Keep the
original branch order and native state owner behind compatible pawn adapters.

Regression: prepare real physical and magical actions, make their clocks mature,
then invoke each dispatch route with prediction enabled or a stale player.mo.
No resource, timer, pending-state, latch, block or projectile count may change.
Test null/detached receivers and restore legitimate authority as a positive
control. #310's 31 native guard checks and exact source normalization are in
assets/validation_551. These checks do not establish full network multiplayer
support or a performance improvement; author acceptance remains separate.

## CA-KP-136 - Held native Reload can continually reset an action

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #309/5.5.0, 2026-10-18.
Baseline: 1da6beb7; GZDoom 4.14.2, Windows/Vulkan.
Evidence: assets/validation_550; author confirmation remains CA309-01.

Symptom: R held never completes a charge/reload; empty-magazine Fire also
continually resets automatic reload. A native Ready state can redispatch held
buttons every tic. Direct calls and pulse-only tests do not exercise this loop.
Apply the authored one-request-per-press rule at the native callback with
`player.oldbuttons`, and make a same-weapon active reload request idempotent.
Do not add a saved latch where the engine already owns button history. Requests
during unavailable weapon states are not buffered by this edge-only policy.

Regression: all six representative manual routes under held/pulse input,
prepared-charge expiry, four automatic empty-magazine routes, and existing
interruption/persistence boundaries. Observe whether a shot happened during
the interval: a later failed attempt can reset the last-shot diagnostic flag.
Clear that flag at case start to avoid counting an earlier weapon's shot.
Keep baseline failures and probe failures distinct from production changes.

For long native command tests, chain bounded `exec` files explicitly. An
oversized one-line matrix lost its setup; splitting it into independent lines
scheduled separate wait continuations and allowed the final line to quit early.
Require ordered checkpoints and the final completion marker, and hash all
chained scripts alongside the runtime/fixture. See preserved #309 magic runs.

## CA-KP-135 - Transient encounter ownership must rebuild after save load

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #361/5.4.47, 2026-10-18.
Evidence: assets/validation_5447; the author accepted revised NPC-only CA361-01
on 2026-10-18. The cache lesson below concerns the superseded initial candidate.

Scope update: the author subsequently excluded the player from siege focus to
preserve seal balance. The final #361 code therefore removes this player cache
entirely; the verified initial-candidate lifecycle lesson remains historical
engineering evidence, not a description of a cache still used in production.

Symptom/cause: the isolated focus controls passed, but the old real siege save
left the player's transient encounter reference null. NPCs used their existing
saved ownership and correctly reached maximum adrenaline. Eager WorldLoaded
assignment alone did not establish the reference in that restored event-handler
lifecycle. The private control also initially parked a new port before its native
spawn lifecycle had published it; that is a fixture defect, not a production fix.

Fix/prevention: reconstruct the transient reference lazily once after load, then
maintain it with native spawn/destruction/travel events. Remember that an empty
result has been resolved, so peaceful maps do not repeat discovery every tic.
Use existing per-body ownership for crowds. Read-time cache inputs must observe
the forced adrenaline before testing a hit. Channels can spend it between normal
updates; verify the first damage and post-spend state as well as periodic ticks.

Validate with old/current saves and both real hub legs, not only a fresh isolated
map. Preserve resource costs, damage and combat timers. Do not infer a measured
FPS benefit from eliminated arithmetic; #361 explicitly defers FPS evaluation.

QA follow-up: the NPC-only revision's first hub draft printed intermediate DONE
markers but quit before its last queued city assertion executed. A wrapper that
accepts any DONE cannot certify the complete route. Emit final success only after
checking every expected checkpoint and the final map, and leave a native update
window after network/save requests before quitting or travelling again. Preserve
partial logs as partial evidence; never count their first checkpoint as a full
round-trip test. Final npc_evidence verifies the ordered three-stage route.

## CA-KP-134 - Hub wipe protection counts presentations, not tics

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #334/5.4.46, 2026-10-18.
Native g4.14.2 replay and lifecycle evidence: assets/validation_5446. Source
image preservation was visually checked; the author accepted the corrected
animation in CA334-02 on2026-10-18. No FPS result is claimed.

Author feedback2026-10-18 rejected the initial candidate's double exit wipe.
Identical endpoint images do NOT make Melt neutral: Wiper_Melt shifts source
columns downward. Fade blends corresponding pixels without that displacement.
Controls using globalwipe3 therefore missed the defaultwipe1 failure. Select
Fade3 for the possible initial house pass, then Melt1 after the source hold;
keep the user's global setting unchanged. Native selection/count assertions
still do not constitute author visual acceptance. Test default Melt explicitly.

Symptom/cause: native same-hub NoWipe can expire before queued ChangeLevel
completion at uncapped FPS. An actual exit shows28 presentations in28.27ms before
PreTravelled, versus1 capped. setTransition(0) is a no-op, not cancellation.
Separate the engine counter from custom arrival overlays and the loading icon.

Fix/prevention: following the revised author contract, house Use captures its
own source image and requests Melt after arrival protection, independently of
ship/cart presentation. Capture with the player to hide their own body. An
auxiliary camera at the same point can show its interior instead. Do not pass
null to SetCameraToTexture: native code dereferences viewpoint->Level. Binding
a harmless helper and destroying it immediately retires the native renderer
reference without clearing the pixels. Repeat after hub restoration: saved
canvas bindings can otherwise overwrite the source despite CaptureSuspended.
Scope ownership to the request/destination and consume its ACK once; cancel on
save load, new game, death before commitment or unrelated travel. No actor-wide
search is added for doors; capture starts only after a valid Use.

Validation: observe both visited hub directions with capped/uncapped FPS and
another global wipetype. Check old/new saves, duplicate/stale ACKs and incomplete
vehicle arrival. Inspect a frozen source before and after arrival; passing
event counts cannot detect a wrong camera image. A final screenshot alone cannot
prove a wipe. Record fixture failures separately from runtime defects.

References: GZDoom[g4.14.2](https://github.com/ZDoom/gzdoom/tree/g4.14.2),
g_level.cpp, d_main.cpp, r_data/r_canvastexture.cpp, common/objects/dobjgc.h,
common/objects/dobject.cpp, p_saveg.cpp; CaelumMenuAudio and CaelumHousePortal.

## CA-KP-133 - Shootable navigation markers are not combat targets

Status/evidence: ENGINE-VERIFIED, #357 / 5.4.45, 2026-10-18.
[validation_5445](../assets/validation_5445/RESULTS.md): the author's actual
autosave and isolated 41-assertion Mandinga/Zupay controls. Author retest pending.

Symptom/cause: native chase assigns an invisible, shootable and invulnerable
CaelumSewerEscapeTarget to Actor.target. Breath accepted those flags plus reach
and sight, entered a looping firing state and prevented route advancement.
Twenty artillery operators in the saved siege were paying for this false fire.

Remedy: exclude the technical navigation class at the shared breath reach/aim
predicate. Preserve its native chase flags. Cold and restraints remain separate
reasons to fire; do not suppress them merely because target is a route marker.
The existing per-body update retires active emitters without scanning actors.

Regression: replay the same private save, track the original affected IDs,
assert no navigation-only fire after update, and check their displacement.
Exercise real targets, range, finite resources, cold, real bolas and saved
emitters. Broad NOTARGET rejection would change unrelated target rules.

Limits: these checks establish the local bug fix, not a measured FPS gain or
general pathfinding correctness. The inherited +/-32768-MU flat diagnostic made
native CheckSight false for a valid nearby dummy; the bounded +/-16384 control
passes. Preserve that fixture failure; do not infer the exact engine cause or
alter gameplay geometry from it.

## CA-KP-132 - Structural notices must cover wear even without HP damage

Status/evidence: ENGINE-VERIFIED private candidate, #354 / 5.4.44, 2026-10-18.
[validation_5444](../assets/validation_5444/RESULTS.md): 3,958 native assertions,
two cached-read combat audits and 18 matched presentation windows. The candidate
is not adopted; no consistent extra FPS benefit was demonstrated.

Symptom/cause: an impact can wear armor while Toughness cancels all HP damage.
Returning before notifying the owner's cache leaves derived values stale.
Native initialization, personality migration, replacement and scripted repair
are separate writers; observing only health changes cannot cover them.

Remedy for experiments: notify the affected NPC before zero-HP early returns
and after each inspected structural write. Keep ownership at the caller when
the armor-state object has no owner; never discover it by scanning all actors.
Keep scalar/weight guards and the staggered fallback until separately justified.

Regression: compare every assigned cached output immediately with the original
calculation; exercise real armor wear/repair, initialization and migration. Use
an unnotified-write negative control. Its forced expired deadline proves the
refresh path, not a real 100-tic wait or immediate correctness. Aggregate battle
equality supplements, but cannot replace, individual cached-read audits.

Limits: future writers must maintain the notification contract. Removing guard
reads does not establish a useful whole-game FPS gain. Report each candidate
against its adjacent controls, including negative pairs, rather than using the
ratio of overall medians. Retain conservative production guards when the added
contract has no demonstrated consistent benefit.

## CA-KP-131 - Validate the game presentation chain after startup changes

Status/evidence: ENGINE-VERIFIED capture control, #353 / 5.4.43, 2026-10-18.
[validation_5443](../assets/validation_5443/RESULTS.md) preserves the native
startup controls and matched comparison. This is a capture lesson, not a
general explanation of Vulkan/Windows driver behavior.

Symptom: a completed native replay can yield PresentMon records with swapchain
0x0, runtime Other and Composed: Copy with GPU GDI instead of game presentations.
Thirty-six initial comparison windows were excluded. A larger ETW buffer alone
did not fix the startup pilot. With the same observer/engine/initial settings,
waiting 35 tics before uncapping restored a nonzero DXGI Composed: Flip chain.
The underlying driver/window startup mechanism was not established.

Remedy: preserve the tested capped startup, uncap after 35 tics, then begin the
presentation window at tic +70. Keep the initial simulation census at the first
restored tic. Do not silently shift the saved-state comparison to the FPS start.
Track the full 700-tic replay separately from the shorter warmed presentation
window and its one-second end trims. Callback counts are not replacement FPS.

Regression: require PID/runtime/fixture identity, the validated nonzero DXGI
chain, positive complete intervals, monotonic QPC timestamps, surrounding
coverage, and host/engine duration agreement. Reject missing or GDI-only frames;
do not relax the gate to obtain a number. Compare gains only against controls
in the same new batch. Atomically replace collector request files; release both
the capture supervisor and the temporary power request after testing.

## CA-KP-130 - Derived caches and target subscriptions need map-local lifetimes

Status/evidence: ENGINE-VERIFIED, #353 / 5.4.43, 2026-10-18.
[validation_5443](../assets/validation_5443/RESULTS.md): 3,705 final-runtime
assertions, save/reload/forward migration, native hub round trip and two
700-tic cached-read audits with zero mismatches. Author CA353-01 remains pending.

Symptom/cause: a transient reference is omitted from serialization but can still
survive travel on the actual player or carried actor object. A cache deadline
from another map can delay refresh; subscribers can retain a departed player
or a former command leader. Clearing only the dead target's incoming list does
not remove a dead leader from its own target's outgoing subscription.

Remedy: use map-local deadlines and explicitly discard derived caches/population
references on house/summon/converted travel. Bind through the existing population
census, without another global discovery pass. Clear player subscriptions in
PreTravelled; invalidate a retiring target and unwatch its own leader entry.
Unwatch entries that lose leadership. Serialized revisions migrate idempotently;
actual health, inventory and resources are not replaced by cached values.

Regression: test actual native death/destruction, leader withdrawal, player and
three carried-body travel paths, old/new saves and repeated cache initialization.
Require both legs of a hub test: an early DONE marker alone is insufficient.
For a saved observation handler, start through a transient first-WorldTick latch
and compare exact initial tics/state; do not assume WorldLoaded starts a restored
handler. Keep native cached-read audits separate from normal-runtime FPS windows.

Limits: a per-map phase spreads fallback work, not simultaneous cold creation.
The 500-body census is an existing opportunity count, not an instantaneous HUD
count. Raw timings from an audit contain extra calculations and are not normal
gameplay performance. Changes to target cadence change the evolving battle.

## CA-KP-129 - A staggered cache must preserve assignments and active clocks

Status/evidence: ENGINE-VERIFIED diagnostic, #318 / 5.4.42, 2026-10-18.
[validation_5442](../assets/validation_5442/RESULTS.md) contains 1,068 native checks,
three audited normal-combat windows and the presented-frame comparison. The
candidate is not yet a production deployment or a complete save/hub proof.

Symptom/cause: skipping a derived-stat method on unchanged inputs can leave
outputs modified by another consumer. The carbine multiplies Speed while
reloading; a cache that only returns compounds that penalty. Moving an entire
resource/timer block behind a 100-tic gate changes active recovery, stun and
combat deadlines. An early maximum-adrenaline return also stopped the player's
combat timer. A global scan to discover changes would reproduce the original
scaling problem instead of solving it.

Remedy: cache the actual dependencies and restore every assigned output. Send
native ownership/use/stack/split and damage/death notifications to the affected
owner or subscribed group. Direct item-field writes need explicit invalidation;
a later fallback is not a same-tic correctness guarantee. Distribute fallback
deadlines by stable actor/group phase, while retaining active resource steps,
physics and independent timers. The saturated-resource fast path must not bank
unearned elapsed recovery. Audit cached reads against original calculations in
separate correctness runs, then disable that extra audit for FPS measurements.

Limits: this prototype still pays lightweight per-call dependency guards and
common observer/counter overhead. A 100-tic phase distribution does not bound
cold-cache initialization. Maximum adrenaline is an authored rule change;
compare original/simplified formulas at the same maximum to isolate its algebra.
The thermal solver already ran periodically at 35 tics; changing to 100 changes
integration and reaction timing. Numerical controls that flush old environments
before events do not bound runtime paths that remap the new environment over
elapsed time. Target search at 100 tics also changes combat outcomes; retain
native attack LOS/range checks and report that behavior change explicitly.

Regression: mutate each dependency, break/repair armor, spend/recover resources,
reload repeatedly, consume/stack/split/transfer the last item, kill a shared
target, preserve combat clocks and compare normal-combat checkpoints. Aggregate
HP/resource totals alone do not prove each actor's state. Require exact native
read audits, matched seed/camera, full ETW interval bounds and repeated controls.
Console `wait` dispatch can differ by one or two simulation tics across runs.
Arm the experiment in advance, start inside WorldTick at an absolute saved-map
tic, record the arming/start/end tics and reject late or unarmed runs. Never
conceal a shifted initial state with a tolerance on its resulting HP/resources.

## CA-KP-128 - Freezing a map does not isolate an update subsystem

Status/evidence: ENGINE-VERIFIED diagnostic controls, #318 / 5.4.41,
2026-10-18. [validation_5441](../assets/validation_5441/RESULTS.md) retains
66 valid windows and the limitations of the fixed-scene replay.

Symptom/cause: disabling a parent Tick can also prevent the supposedly enabled
child from running, producing a false zero cost. Level freeze alone does not
stop code before Super.Tick, custom WorldTick handlers, or the inherited
Powerup.Tick countdown. An initial control lost 22 regeneration helpers.
Loading a save can overwrite diagnostic server CVars; transient thermal caches
must be warmed again. Restoring immediately before checking poses can conceal
external mutation instead of detecting it.

Remedy: preserve an immutable scene/call trace, dispatch the selected family
directly, count actual executions, gate dependencies explicitly and check all
other family counters remain zero. Include native inherited behavior in the
freeze boundary. Start controls after load, warm caches outside the window,
and compare poses before restoration. Reject changed populations, unexpected
spawns, health loss or missing actors. Repeat and bracket each pass with all-off.
Pin the seed, source, runtime, engine, camera and configuration; reject partial
matrices. Neutralized effects and fields not fully restored must be documented.

Limits: the baseline still runs the engine, renderer and diagnostic traversal.
MSTimeF measures elapsed wall time, including possible descheduling, not thread
or process CPU time; label the batch delta accordingly.
Its subtraction includes instrumented wrappers/dependencies, not a theoretical
zero-overhead body cost. Restoration and guard costs remain in diagnostic FPS.
Native bench must fall inside the active window and remains a snapshot; do not
substitute it for ETW presentation percentiles or sum isolated cores as normal
combat savings. A measured cost alone does not make a gameplay rule dispensable.

Regression: exact call counts and zero off-family executions, stable actors,
poses/references before restore, and matching provenance across all 66 cases.
Use normal-play A/B tests to validate a later production optimization.

## CA-KP-127 - Rest interruption needs damage provenance and personal-time effects

Status/evidence: ENGINE-VERIFIED, #325 / 5.4.40, 2026-10-18. GZDoom 4.14.2,
Windows; assets/validation_5440, 28 native runs/278 assertions. CA325-01 pending.

Symptom/cause: lying down and time advance used different geographic/effect
vetoes. Treating any HP decrease as a new attack interrupted permitted periodic
injury; comparing only net health also lets healing conceal a new hit. A single
pain remainder cannot distinguish an earlier attack from later, longer DOT pain.

Remedy: share the entry/batch policy, classify the existing periodic emitter,
subtract its actual HP loss from active session baselines, and interrupt on new
accepted attacks independently of net loss. Keep separate revisioned pain clocks;
old pain remains nonperiodic until expiry, with all reset/journey paths aligned.
Death remains an explicit stop. Personal heat must account once per personal tic;
physical activity/firearm heat remains real-step-only. Refuse exact forecasts
when their model omits a state that real execution integrates.

Validate through real bag/bed dialogue, T/Y, effect-duration and integrated-plus-
pending heat accounting, mitigated attacks, concurrent healing, lethal effects,
current/old saves and cleanup paths. A cleared cloud does not imply immediate
ground contact: native flight takeoff can still be falling. Threat scans belong
once per physical batch through local queries, never a whole-Actor census for
every accelerated personal step. These findings do not establish siege FPS gains.

Continuation, ENGINE-VERIFIED, #502/5.8.12,2026-10-25:
pre-sleep calendar cleaning keeps the player awake briefly below the Sleep
threshold. Existing fatigue damage writes health directly, bypassing the native
damage event; isolated queue calls therefore missed a real-clock interruption.
Account that loss through PeriodicLoss only during the approved preparation and
when neither Hunger nor Thirst is critical. Do not suppress the damage or broaden
the exception to attacks. Native ordinary/accelerated clock and critical-Hunger
checks pass; assets/validation_5812/calendar retains the reproduced failure and
final evidence. Observe paused-work progress at the exact calendar completion
boundary: later real-time ticks legitimately resume the original task.

## CA-KP-126 - Native no-wipe does not clear a custom travel overlay

Status/evidence: ENGINE-VERIFIED and CODE-VERIFIED, #334 /5.4.36,2026-10-18.
GZDoom4.14.2 Windows. Evidence: assets/validation_5436;8 native runs/64 checks,
two baseline routes and16,375-member source/package equivalence. CA334-01 accepted
October18. The revised5.4.46 contract is covered by CA-KP-134.

Symptom/cause: real Board/Confirm TCOAST->MAP03 followed by an artificially
early approach to house158 leaves the previous vehicle snapshot covering CAH158.
The journey is already ARRIVED. The first house frame still has VehicleArrival
at frame4 even though ordinary departure reset TravelWipe to0. An engine no-wipe
rule does not clear a custom RenderOverlay owner. GZDoom's same-hub NoWipe counter
and loading icon are separate from this overlay. setTransition(0) is a no-op;
a negative transition selects Melt, not cancellation.

Fix/prevention: send explicit one-use house-door presentation intent, preserve it
through PreTravelled and clear the prior overlay. The original5.4.36 fix
normalized to0; the revised5.4.46 contract explicitly selects Melt. Never
forward the sentinel to the native transition API. Keep native autosaves, loading
icons, global settings and normal vehicle transitions. No saved schema changes.

Validation: capture UI state before portal Used resets it, then inspect the first
destination frame. Native Board/Confirm and portal entry remain real, but moving
the player1,085.888MU immediately to that portal is an explicit fixture operation.
Do not call this a reproduction of ordinary walking or of every native fade.
Final-frame screenshots do not prove the absence of a wipe. Test normal vehicle
arrival separately and reload actual inside/outside autosave files. A long cart
control needs its forecast's258 water rations;200 caused a genuine diagnostic
death, not a door regression. Preserve the failed fixture and correct its stock.

References: GZDoom[g4.14.2](https://github.com/ZDoom/gzdoom/tree/g4.14.2),
g_level.cpp same-hub ChangeLevel and d_main.cpp NoWipe/setTransition; production
CaelumHousePortal, CaelumPlayer.PreTravelled and CaelumMenuAudio.

## CA-KP-125 - Escort poses must not compete with the movement owner

Status/evidence: ENGINE-VERIFIED, #322 / 5.4.35, 2026-10-18. GZDoom 4.14.2
Windows; baseline b74ca613 (runtime unchanged from #324). Focused evidence:
assets/validation_5435. The final 23-run/375-assertion native gate includes the
full rescue/reward itinerary; CA322-01 author acceptance remains separate.

A Tick controller forced EscortFollow and cleared Target, while that state's
action called resident Look near the leader. Friendly SoundAlert could enter
See/A_Chase and native wandering before Tick forced following again. Four
one-tic walking frames also animated stationary conversations. In the matched
140-tic control this produced 504.804498 MU of travel, 53 angle changes and
5,150.890932 accumulated degrees; the single owner/inert idle pose produced zero
for all three. Keep visual states free of steering and enemy acquisition when
another owner controls locomotion. Combat and retreat must receive explicit
ownership; quiet resource-recovery states also need a completion pulse.

Distance2D and one sight ray do not prove a traversable body route. Preserve a
bounded footprint-aware route around corners and require compatible support
levels before declaring arrival. Player input distinguishes intended reversal
from collision recoil; stale direction must not initiate a new sidestep.
Narrow two-way passage can require both bodies to move aside. A diagnostic
driver rigidly following the centerline is not evidence that collision should
be removed. Keep closed-door, reversal, height, crowd and native-step checks.

Breadcrumb arrival precision must agree with body clearance and local sampling.
In MAP02 a Federal stopped 5.89 MU from a breadcrumb beside a chest: farther
than one walking step but nearer than the grid unit. A footprint-aware arrival
threshold fixes that dead zone; also require compatible supporting height so a
point directly above the body is not consumed. Partial routes must continue
from the reached floor instead of selecting the same XY on a lower floor.
An old breadcrumb can also become occupied by a settled companion. Test map
geometry separately when deciding whether to replace the old trail with the
leader's current position. The temporary geometry query ignores all actors,
including solid props; restore its flag immediately and retain complete actor
collision in the local detour and real movement. Do not erase that detour every
four tics once only the leader goal remains. A loose end-distance check can pass
while a body still circles an obsolete waypoint: also sample group stillness
after arrival, including turning, walking poses and restored collision flags.
Two waiting bodies can span a narrow corridor. When the leader is stationary
and the trail contains only that goal, accept the nearest reachable progress
and wait if no route gets closer. An unconditional lateral escape makes rear
followers circle behind the stationary row indefinitely. Preserve lateral escape
for moving intent, older trail points and height changes; retain native collision
and the existing retry cadence. Extending a diagnostic's deadline distinguishes
late arrival from this persistent oscillation; a distance-only pass is insufficient.
Narrow stairs can fall between grid samples. Shift the sampling origin only
when needed, validate its first link from the actual body, and share a single
query budget across all phases. In the 32-MU stair fixture the body reaches the
upper floor by tic 280. The unreachable-height control measured 35 searches at
2.415323 ms mean/2.448400 ms peak, with at most 4,225 native position queries
per search. This is isolated elapsed cost on the test machine, not an FPS claim.

TeleportMove(false) is not a full destination-fit test: its native actor test
omits non-shootable solids, and flags can still permit telefragging. Validate
footprint, all local solid bodies, support, ceiling and separation first.
TestMobjLocation alone can accept a candidate outside the map outline because
the BSP supplies a neighboring sector and no nearby wall intersects that spot.
For the short recovery ring, also require sight from the leader, then perform
the fit/support checks. No valid candidate means no relocation, never a fallback
onto the player. Corridor and blocked/low-ceiling/unsupported/void cases exercise
these distinctions. Local blockmap/TID queries and bounded route memory avoid
adding a per-tic traversal of the map's entire actor population.

The author's October 18 decision replaces the escort pace described in CA-KP-109
with the player's walking formula, individual NPC modifiers and mass-based ramp.
Do not multiply native chase-step Speed into continuous velocity. The ramp must
also respect the player's grounded/water/flight rule; ordinary airtime must not
increase it. No new NPC needs or cloud-riding benefit is implied.

## CA-KP-124 - Later corridor painting can merge a local moving ceiling

Status/evidence: ENGINE-VERIFIED, deterministic comparison and native walking,
cycles/save recovery. #323 / 5.4.33, baseline 6502e4c0, GZDoom 4.14.2 Windows.
Scope: generate_map02_maze.py room/corridor painting and crusher 43921.

The generator initially stamped a unique 128x128-MU panel, then a later refuge
corridor overwrote those cells with west-zone group 2. Sector compaction correctly
merged equal cell signatures; the trap consequently selected 12,709,888 MU2 of
ceiling. A unique trap TID cannot protect sector geometry that was overwritten.
Finalize moving-sector footprints after overlapping static construction, before
layered floors; assert that each exact authored footprint/group/base floor
survives the complete generation. Do not infer correct isolation merely from
the early room() call or from a one-panel runtime array.

The correction changes only 16 cells and keeps all existing panel dimensions.
Current geometry has 85 sectors/11,541 lines versus 84/11,525. Repeated output bytes
match; other trap/gate/loot/lower-network manifest fields remain equal. Evidence:
[focused checks](../assets/validation_5433/RESULTS.md). Native walking, neighbors,
all panels and save/load pass: 108 current, 26 baseline, 10 recovery assertions.
Revision-4 recovery preserves
its original geometry and defect; it is not a migration to corrected sectors.
Author acceptance CA323-01 passed 2026-10-17 for the western walking preview.
Damage/pressure rules are unchanged.

## CA-KP-123 - A reinforcement admission cap is not a resurrection limit

Status/evidence: ENGINE-VERIFIED isolated GZDoom 4.14.2 lifecycle checks,
#327 / 5.4.29, 2026-10-17. See [evidence](../assets/validation_5429/RESULTS.md).

Counting the whole encounter history each tic adds work as the battle progresses;
refusing spawns at 1,000 does not prevent a dead body being revived after its
replacement arrived. The author explicitly retained resurrection. Normal deployment
recounts its owned registered bodies only at eligible 350-tic opportunities. It
checks health and exit state, including offscreen bodies and destroyed references.
One 100-member group needs enough room; failed placements retain budget and partial
identities. Living is a cached opportunity census, not a continuously current HUD count.

Native checks reached the 1,000 cap, rejected a full field and 99 vacancies,
admitted a group after 100 deaths, preserved partial state through reload/hub,
and completed 6,600 cumulative arrivals with at most 100 live in that budget
fixture. A separate native resurrection check reached 1,001 without another
arrival, then blocked new reinforcements as intended. The budget fixture removes
dead test bodies and accelerates deadlines; it is not natural-combat/corpse/FPS
evidence. No 6,000 simultaneous stress run was made or authorized.

Follow-up, CODE-VERIFIED only: Attackers retains up to 6,601 historical records.
ObserveGuards below the high-density threshold, ElectCommands and CannonTarget
still traverse history. A living-body cap does not bound that list length.
Measure the late battle before changing those consumers; no measured cost or
complete registry optimization is claimed by this patch.

## CA-KP-122 - Map lump numbers are not stable world identities

Status/evidence: CODE-VERIFIED selectors and deterministic generation;
ENGINE-VERIFIED travel, map launches and current saves, #327 / 5.4.29.

Assigning a city to the former reservoir's MAP03 can silently enable reservoir
trials or leave travel destinations pointing to the wrong map. Map old/new
selectors simultaneously, including events, quests, physics diagnostics, house
returns, generators, cartography and MAPINFO. Preserve stable location IDs
(port=6, reservoir=3) and content localization keys independently. Check WAD
markers and native numbered transition specials, not just filenames.

Keep old WADs and hashes, but do not advertise a WAD-only swap as save compatibility
after a hub catalogue change. #327 uses the author's old-save waiver; old saves
require the full b9fd71ce package/checkout. Legacy switches fail before output
mutation. MAP02 -> MAP03 -> CAH158 -> MAP03 travel, resident inventories and
pending siege save/hub state passed native checks. TACTORS retains 16,508 placed
things: validate its identity without launching that historical stress population.

## CA-KP-121 - Sky ceilings can defeat an apparently opaque city barrier

Status/evidence: CODE-VERIFIED GZDoom g4.14.2 hw_CheckClip and ENGINE-VERIFIED
matched native renderer samples; #318 / 5.4.28, 2026-10-17. Scope: the isolated
house-height comparison. The author subsequently adopted its low-sky variant
as normal MAP03 in #327 / 5.4.29; the measurements below retain their original scope.
[Evidence](../assets/validation_issue318/RESULTS.md).

Author decision, 2026-10-17: the 6,000-attacker stress scale is retired and must
never be run again. The earlier measurements below are historical evidence,
not a request to repeat that population. The last active run was intentionally
stopped on the author's instruction; its incomplete-run traceback is not an
engine-crash finding. Continue the geometry comparison at 1,000/600 and in peace.

A wall can visibly reach the sky while the renderer still traverses the city
behind it. In [hw_CheckClip](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_fakeflat.cpp),
closed-sector tests return false when both ceiling textures are skyflatnum.
Raising the house floor to the 1,024-MU outdoor ceiling while retaining F_SKY1
therefore does not establish real occlusion. The final diagnostic sets that
closed sector's ceiling to the existing opaque roof material. Valid lower-wall
textures, distinct front/back sectors and the absence of other portal/dither
bypasses also matter. Verify rendered work, not only the geometry or screenshot.

From the same legal `(0,320,0)` camera, the first matched native bench snapshots
drop from 34,297 to 738 wall jobs and 1,127 to 65 flats. These are renderer work
counts, not counts of unique authored walls. CPU-side bench clocks and the HUD
counter are not ETW presentation FPS. Full measurements remain in the audit.
The completed ETW comparison measures peaceful forward means of 36.62-37.03
versus 402.03-405.19 FPS, and ground-facing means of 28.54-29.76 versus
165.66-166.03. The 1,000-attacker central view rises from 6.81-8.33 to
27.97-29.88 FPS, still below 60 with p99 frame intervals of 112-131 ms. Its
front-line view does not improve (24.76-24.89 versus 22.24-22.68 FPS); both
native snapshots contain 1,146 wall jobs. Do not generalize a large gain from
one view to every route or attribute every combat difference to the renderer.
An occluder cannot remove unrelated offscreen actor simulation.

The completed four 6,000-attacker/600-defender runs illustrate that limit:
11.76-11.79 tics/s with ordinary shells and 11.96-12.15 with real occlusion,
against the nominal 35; both remain near 0.7 ETW application FPS. Separate
profiles sample 20 tics per 10-simulated-second
window. AttackerTarget costs 18.72-18.82 exclusive ms/sample tic, including its
uninstrumented shared-target helpers; the CombatActor.Tick remainder costs
12.69-12.75. At 1,000 attackers these scopes cost 3.50-3.56 and 3.00-3.05 ms.
These are selected CPU scopes, not an exhaustive additive engine/GPU budget.
The typed target registry still supplies up to 600 defenders to leader searches:
bounded/typed does not mean free when many leaders repeat the work. Any spatial
optimization must preserve target eligibility, sight/RNG semantics and offscreen
combat rather than silently impose a new range, faction or civilian policy.

The generated city shares its 184-MU roof sector with unrelated structures.
Clone the house sector and redirect only its authored boundary sides; raising
the shared sector would alter other buildings. Check every house footprint,
unchanged street widths and the paired package diff. The tall-wall control also
changes sight, projectiles, flight and thermal geometry, so a total-gameplay
timing difference is not a pure renderer subtraction or automatic design approval.

The variable-height follow-up uses the existing 184-MU house roof as physical
sky over residential/shop lots and keeps the exterior/wall-walk belt at 1,024 MU.
Changing a shared sector directly would lower unrelated exterior areas. Mark
eligible generator cells before compaction, split their shared groups, restore
their original flat and set only those ceilings. The resulting diagnostic adds
two sectors and 55 lines; normal regeneration remains byte-exact and repeated
diagnostic generation is identical. Disable generator runtime-source writes
when building an isolated map: changing the output directory alone is not enough.

Low F_SKY1 streets remain thermally outdoors, but their ceiling is physical:
flight stops below it and a closed floor/ceiling roof has no standing headroom.
Check shop entry/window headroom and wall/tower access, not just house doors.
The successful native follow-up logs 823 geometry assertions, 45 actual portal
assertions and three deployment assertions. Count PASS records across hub
transitions: a reconstructed event handler can reset its local DONE counter.
An unrolled 160-door fixture exceeded the ZScript register limit; a loop passed.
An upward-launch check must observe motion before gravity returns the player to
the floor; its corrected one-tic observation passed. Preserve those failed
fixture attempts with their diagnoses instead of reporting gameplay regressions.

Keep an observation site inside the changed region. The earlier city/front-line
sites both remain under 1,024 MU; the added residential HouseRoad(0) site confirms
184 MU natively. Validate full camera pose, measurement options, population
censuses and identical observer hashes. An ETW file existing is insufficient:
events for that process must bracket the entire trimmed QPC window. Give the
collector enough wall time for slow simulation and wait for its CSV handle to
close. Do not combine historical and fresh runs into an unpaired improvement.

Fresh variable-sky ETW evidence (24 windows, two means per condition):
Fresh paired ETW means (tall opaque walls versus zoned sky): exterior forward 280.79-284.08 versus 330.73-337.53 FPS; exterior ground 103.47-114.89 versus 121.75-123.65.
Within the residential street, forward means are 268.93-272.96 versus 261.85-268.56 FPS; ground-facing means are 205.90-244.94 versus 219.61-252.60.
With 600 defenders, the 1,000-attacker city view measures 3.85-5.05 versus 6.42-7.16 FPS and the front line 3.72-4.44 versus 3.53-4.39. The unchanged opaque control is substantially slower than in the earlier session despite identical package/config/population records; the cause is not established. Compare fresh pairs only, not historical FPS as a new baseline.
Compare these fresh controls with each other; earlier normal-shell results
belong to their own session. The full report preserves frame tails and end
censuses. Neither a lower physical sky nor opaque walls removes offscreen AI.

Do not place a benchmark camera on the old interior/house boundary after making
it solid. Check native placement and actual coordinates at the measurement
boundary. Retain invalid-camera and ineffective-sky-closure attempts as qualified
controls; they must not become evidence against the corrected occluder.
Native bench waits five wall seconds before writing when invoked with an
already-visible FPS counter; a short post-command tic wait may quit too soon.

## CA-KP-120 - House hubs need body ownership, initialization and placement checks

Status/evidence: CODE-VERIFIED native g4.14.2 travel/thinker order and
ENGINE-VERIFIED house transitions, current saves, finite inventory, fresh
birth/travel, blocked placement, burning, bolas and Redemption; #318 / 5.4.28.
Scope: CaelumHouseResidents and the generated CAH000..CAH159 interiors.
Evidence: validation_issue318 house fixtures and RESULTS.md.

Keep exterior footprints separate from interior representation. The generated
MAP06 preserves all four outer boundaries and original height of every house;
the private interiors use ordinary ceilings. Fewer sectors alone does not
certify FPS, nor does a high interior HUD counter certify the city or siege.
Compare city/ground/interior windows, native tics and presented frame intervals.
A startup changemap may be ignored before the initial level finishes loading.
Wait for the first map, then assert the actual loaded map name and its resident
population; a successful measurement callback alone does not prove the scene.

Do not serialize a partial hand-written copy of a complex NPC. Native
Inventory.PreTravelled/Travelled can carry its real body and finite inventory
through STAT_TRAVELLING; remove them from that list before native cleanup.
Use a distinct nonthinking stat for absent residents, not STAT_STATIC or the
corpse archive's stat. A fresh actor moved to a nonthinking list loses
OF_JustSpawned. Keep it in STAT_TRAVELLING until native PostBeginPlay can run,
then park it without executing absent-map combat. Assert real gear/anatomy,
not only one initialized boolean. Rebase absolute clocks and map-bound caches.

Historical resurrection memory does not prove another carrier owns travel.
Delegate only active conversions actually registered with the travelling
effect; retain permanent exclusion from historical siege orders separately.
A bolas binding is an independent actor with its own finite item. Transport
that auxiliary exactly once, including when Redemption owns the victim body;
destroying the binding resolves/drops its piece and is not harmless cleanup.

An occupied saved position must defer placement. Use a solid probe with the
actual body's dimensions; testing the nonsolid parked body misses collisions.
Retain cannon replacement assignments and reserve a pending operator's slot
without counting it as present service. Otherwise a vacancy can be reassigned
and then overwritten when the original body returns. Check the real Use path,
save/reload, deaths, status composition and deployment independently.

Native hub snapshots can copy travelling objects into stored map state. Measure
save size, memory and transition latency after many visits and a grown roster;
one house's FPS does not establish bounded campaign storage. This remains a
measurement requirement, not a demonstrated leak.

## CA-KP-119 - Flat army tests must separate simulation, inventory and drawing

Status/evidence: ENGINE-VERIFIED isolated GZDoom 4.14.2 flat-sector tests,
#318 / 5.4.28, 2026-10-17. [Evidence and full measurements](../assets/validation_issue318/RESULTS.md).
Scope: real Mandinga/PortDefender bodies, native faction targeting, one sector,
four boundary lines, sprites versus the author-approved Domingo model substitute.

A flat floor does not make thousands of full RPG combatants cheap. In the
6,000/1,000 onset, all 7,000 bodies have targets and collisions, yet combat
advances below 35 tics/s and presentation falls to about one frame per second.
Raw callbacks show many simulation tics between presented frames. A high FPS
result with actor thinkers frozen certifies drawing only, not usable combat.
The diagnostic DORMANT_STAT also hides bodies from ordinary thinker iterators,
changing event workloads and producing a zero final ordinary census despite
visible retained bodies. Its FPS difference is not a pure AI-cost subtraction.
The same geometry can therefore have very different costs with active AI.

Count inventory actors separately from combatants and visible bodies. Each
Mandinga has three native inventory stacks; 6,000 Mandingas add 18,000 thinker
objects representing 108,000 potion units. Removing them once after deferred
PostBeginPlay reduces the window census from 25,613 to 7,613 actors. Keep the
supply revision intact and verify inventories stay empty: otherwise a supposedly
empty control can silently replenish. This author-requested ablation does not
authorize removing gameplay inventory. Short-run casualties/health match;
longer battles may diverge once missing potion use matters.
Removal also changes carried weight, effective collision mass and attack air
cost. A full-inventory ablation does not isolate only item Tick overhead, even
when short-run health and casualties match.

For a visual-only comparison, override MODELDEF on the existing classes and
map their existing state frames. Do not substitute lightweight AI, add thousands
of model proxy thinkers, disable collisions or change resources. Report mesh
complexity and animation mapping: this Domingo MD3 has 17,447 triangles per
body and uses sampled poses with native interpolation. Its result cannot be
generalized to every 3D model, an optimized LOD or final Mandinga art.

Record spawn calls and deferred initialization separately. Actor.Spawn can
return before expensive PostBeginPlay work and inventory creation, so its short
duration is not total deployment cost.
The first subsequent WorldTick marker measures wall latency including other
tic/render work, not exclusive initialization CPU time. Keep full-combat,
frozen render controls, inventory ablations and instrumented profiles distinct. Use
matched repeats, raw ETW intervals, simulation tics/s and sustained windows;
do not interpret fewer than 30 intervals as reliable percentile evidence.

The isolated soldiers use native sword/shield AI outside MAP06's controller;
city routes, carbine orders, cannons and reinforcements are absent. The lower
1,000/600 repetition therefore tests population stability on the same flat
fixture, not whole-city or siege acceptance. Reproduce using the owned
flat_army/flat_controls/flat_suite/flat_inventory_suite tooling and retain all
native counts, source hashes and failed attempts.

The completed 40-run battery records sustained 1,000/600 means of 53.54 FPS
(sprites) and 43.76 (Domingo), at about 35 tics/s. Sprite p95/p99 frame intervals
are 22.31/99.76 ms: a final HUD snapshot near 77 FPS does not establish stable
60 FPS. Empty inventories improve onset, but sustained means 49.86/42.74 FPS
do not establish a lasting benefit and have different combat outcomes. The
6,000/1,000 sustained battle remains at 0.86/0.81 FPS (14.68/13.75 tics/s), or
1.14/1.07 FPS after inventory removal (19.29/18.17 tics/s). These figures are
application presents from ETW, not display refresh; all conditions and repeats
remain in the report. Independent review confirmed the methodological limits;
the final verifier checks all 40 populations, model-variant outcomes and cleanup.

## CA-KP-118 - Native PolyObject doors need finite collision and ordered guards

Status/evidence: CODE-VERIFIED GZDoom g4.14.2 `po_man.cpp`, `dthinker.cpp`,
`p_mobj.cpp` and native Use handling; ENGINE-VERIFIED isolated pairs and MAP06,
#318 / 5.4.28, 2026-10-17. Scope: CaelumPolyDoors, native city generator and
the original hinged-door fallback. [Evidence](../assets/validation_issue318/RESULTS.md).

Stock non-crushing Polyobj_DoorSwing still thrusts obstructing actors and ignores
CANNOTPUSH/DONTTHRUST there. An active action also rejects repeated activation
rather than renewing its wait. Replacing eight blockers per leaf therefore
requires a controller that preserves the accepted interaction contract. Native
rotations are guarded locally; always spawn a NEW guard immediately before both
actions. The engine preserves that contiguous order from the fresh thinker list
to STAT_DEFAULT and through save serialization. Reusing an older guard permits
another actor to move between the check and the newly appended actions.

Check the native actor AABB against the swept rectangle, including intermediate
angles and finite-height step margins. Cast angle division to floating point:
assigning an integer quotient to a double does not restore its fractional part.
Exclude the original pose from a sweep so a touching player can open away from
the door. Use a shootable obstructing body: a nonshootable dummy does not expose
the stock thrust behavior. Test a body moving in its own Tick during closure,
not only one placed before a request.

Finite collision uses two-sided 3D midtextures with a valid height, bottom
pegging and compatible front/back planes. Blocking=true makes the line block
above the leaf. Alpha0 preserves collision and allows the retained owned model
to supply the appearance; it is not a BSP visibility closure. A visual proxy
must use NOINTERACTION: NOGRAVITY and NOCLIP do not prevent native Z movement
from raising it onto its own midtexture while paused. That reproduced Z=120
fault also caused later Use rejection. NOINTERACTION removes the proxy from
the blockmap, so native faces must accept Use from both sides; test away from
the proxy's radius to prove the line path. Direct NPC requests still work.

The per-map registry and line/actor references are saved state. Do not re-register
rotated leaves on load, which would duplicate faces and redefine the closed angle.
IDs above360 are valid PolyObject IDs in UDMF thing angles; do not normalize them.
Keep every storage contour's vertices separate. Suppress native sound sequences
when the existing owned actor sound remains. Treat native rays, sight, missiles,
walking and roof flight as separate checks. The author waived previous-save
conversion for this map replacement; this does not waive current save/hub tests.

The replacement removes 7,680 per-tic blocker actors, but native contours still
add renderer work. Measure net frame presentation and active/idle costs; this
change alone does not establish a playable 600-soldier city or full siege.

## CA-KP-117 - Reference cities need matched cameras and separate simulation counts

Status/evidence: CODE-VERIFIED local archives; ENGINE-VERIFIED isolated views,
#318 / 5.4.28, 2026-10-17. Environment: CA-KP-110. External input hashes and
attribution: [audit evidence](../assets/validation_issue318/RESULTS.md#author-supplied-city-examples).

HGC City has 5,596 sectors versus original MAP06's 1,574, yet its measured
views process far fewer walls. It uses 9 special-160 controls, gz_bigcity 83,
and MAP06 752. These counts describe structure, not independent causal costs.
Use native wall/flat/sprite work and matched frame timing; do not blame texture
resolution or total sectors without a controlled ablation. Early HGC views
face nearby structures; a later south-avenue capture shows a clear street.
HGC forbids freelook/jump/crouch. Forced downward
views are diagnostic. gz_bigcity's open streets still fall below 60 on the native
counter, with increased work looking down. Neither runs Caelum's simulation.

StaticCityTree moves 5,784 decorations to STAT_INFO. A default thinker census
therefore omits them; enumerate relevant non-ticking categories separately.
Static decoration can avoid per-tic scripts while retaining render/memory cost.
Both examples retain real sector architecture; decorative models and a parallax
sky camera do not prove that model houses automatically occlude or supply
walkable collision. The miniature SmallCityModel is a monument.

The supplied working door is a native PolyObject using Polyobj_DoorSwing.
This avoids eight scripted blockers per leaf, but stock non-crushing motion
still thrusts obstructing bodies and active DoorSwing does not refresh its wait
on repeated use. Do not copy blocking=true if passage above the leaf matters.
Validate finite height, paired requests, AI use, collision, rays and motion at
production scale. The implemented replacement and its pitfalls are in CA-KP-118.

Record real camera coordinates and inspect captures: early 'aerial' probes fell
to the ground; an auxiliary camera obscured the view. Both failures are retained,
not accepted as aerial or street performance. Native counters, callback cadence
and ETW presentation are distinct evidence. No full-route acceptance is implied.

## CA-KP-116 - Opaque closure and safe boundary reduction are different changes

Status/evidence: CODE-VERIFIED GZDoom g4.14.2 occlusion; ENGINE-VERIFIED isolated
MAP06 controls and geometry/save comparisons, #318 / 5.4.28, 2026-10-17.
Baseline/environment: CA-KP-110. Scope: CoastalMap, compact_open_geometry,
CaelumThermalShelter, native BSP visibility and visited-map compatibility.
[Evidence](../assets/validation_issue318/RESULTS.md).

A raised floor with open sky above and a 3D roof is not a full-height opaque
BSP closure. The hardware renderer's [hw_CheckClip](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_fakeflat.cpp#L50)
uses real front/back sector planes and sky conditions; it does not inspect 3D
floors there. AddLine only adds an occluding angular range for a one-sided line
or a qualifying closure. Blocking flags, actor walls or a transparent middle
texture do not make hidden background free. A transparent wall must retain the
visible background. An invisible wall that discards it creates visual omissions.

The closed-house control changes 160 ceilings and two shared wall sectors.
Its native forward bench falls from 64,565 to 1,737 wall calls and shows about
60 FPS, but the capture reveals facades extended upward and lost overhead/roof
space. This is a non-equivalent experiment, excluded from production. Do not
promise the same gain while preserving every sightline and flight path. Native
counters/callbacks are not ETW application presents; the geometry collector launch
was canceled and produced no ETW frames. Dynamic distance-based closure also
changes collision, shots and AI sight offscreen. Hide transitions behind real
obstructions, use separate open/close thresholds, and account for every player;
no 1,000-MU gameplay threshold or district split is approved by this experiment.

The conservative production pass instead removes 11 duplicate untagged world
sectors and 24,565 redundant/open boundary lines. It preserves every physical
wall endpoint, including the endpoint-sensitive WindBlocked rule, material/light
boundary, 3D control owner, tagged sector and map actor. Fail closed on unknown
plane/portal/tag fields; never discard a future collision/activation flag.
Independent oriented-grid comparison, exact physical-endpoint comparison and
byte-identical regeneration accompany native traces at 3,006 locations. All
35,353 native records match before/after and on each layout's saved reload.

Sector/line indices still change. A script migration cannot bypass native save
geometry rejection. Preserve the exact old furnished WAD and its hash; use
LegacyMap06Furnished with current runtime for visited MAP06, including off-map
hub saves. Do not reuse LegacyMap06SouthCity: it stores an older, different map.
Twelve peaceful-city save/continuation/hub/rollback runs pass 117 new assertions
for controller/counts and selected identities; active siege coverage is pending. This
is old-layout continuation, not conversion to the reduced map. Regenerate dependent
TEXTMAP fingerprints: authored cartography explicitly accepts both layouts because
their POI coordinates/IDs are identical. Future coordinate edits require a legacy
table or explicit eligibility change. New/unvisited
maps use the reduction automatically, without a population-dependent runtime
scan. The later native-door replacement has a specific author waiver for old
saves; the exact-layout continuation above remains checkpoint evidence, not a
new conversion promise. Modest measured gains do not satisfy MAP06 playability;
CA318-02 is pending.

## CA-KP-114 - Repeated emitter-to-world scans multiply thermal cost

Status/evidence: ENGINE-VERIFIED old-runtime cost and isolated contact-only
behavior/persistence, #318 / 5.4.28, 2026-10-17. Baseline/environment: CA-KP-110.
Scope: CaelumDemonBreath.PaidTick/FlushHeat, CaelumElementalStatus and
CaelumThermalRuntime. [Evidence](../assets/validation_issue318/RESULTS.md).

The old breath invoked CaelumElementalStream.Transfer, scanning every actor per
emitter and computing reception for every supported living body. Two transfers
in a full-army sampled tic inspected 6,602 recipients each and consumed
1,653-1,829 ms inclusive. The deeper profile records 26,408 AbsorbedAt calls
per sampled tic; each uses 16 receiver-visibility traces (422,528 derived trace
calls, not separately timed native calls). Only 62 Mandinga streams were active
at the short window's end. Thousands of enemies do not need to emit simultaneously
for this multiplicative cost to make the game appear frozen.

The author's 2026-10-17 correction removes demon-breath radiation. Query local
contact bodies through the blockmap, deduplicate them, retain the existing
absorption calculation/budget/armor once at contact, and store the absorbed
watts on the burning receiver. Queue real-tic joules locally and consume them
through the normal thermal scheduler. Do not force every NPC's full thermal
update per tic or turn health damage into heat. Unknown legacy burn power starts
at zero until contact; already-paid untransferred legacy radiation is discarded
without refunds or replaying applied energy. Both migrations are revisioned and
idempotent. Fire duration remains independent of Toughness's health response.

Regression: local/wall/multiple-contact budget tests, real versus logical time,
armor retention, queue conservation, temperature increase, save/reload/hub and
genuine previous-runtime saves; compare matched 1,000-attacker windows. The
1,000 population is a diagnostic control, not a new production encounter total.
The utility staff retains its separately approved radiation behavior and global
Transfer path: it is an identified remaining scan, not an approved permanent
performance exemption. Existing accelerated-time safety scans also remain to
be measured and redesigned without dropping safety checks. Wider MAP06
playability and author acceptance are pending.

## CA-KP-115 - Global actor scans require a narrow, measured exception

Status/evidence: AUTHOR-REQUIRED engineering policy, #318, 2026-10-17;
ENGINE-VERIFIED motivating example: CA-KP-114. Scope: all future affected code.
Author acceptance: policy explicitly requested; no runtime acceptance implied.

Do not use traversal of every possible actor as the routine implementation of
a per-tic, per-NPC, per-emitter or per-recipient operation. Prefer local spatial
queries, event-maintained typed registries and one shared result for common
questions. Measure the resulting local/registry work too: a registry is not a
license to repeat an equally large scan for each consumer.

A permitted exception must record why correctness requires it, its trigger and
frequency, the maximum measured population, ownership/invalidation, and measured
worst-case cost on a representative large map. Initialization, save migration
and a shared census are possible exceptions, not automatic exemptions. Include
offscreen living combatants in the authoritative >=500 policy; visibility does
not authorize suspending their resources, collision or combat. Review existing
scans in the subsystem being changed and record deferred violations explicitly.

Code review must identify traversal callers and multiplicative nesting, then
test cost and behavior at representative populations. Scan count alone is not
an exact CPU cost: measure recipient work, native calls and frame-time stalls.
The source of this policy is the author's instruction, recorded also in AGENTS.

## CA-KP-110 - Simulation throughput does not establish playable frame presentation

Status/evidence: ENGINE-VERIFIED measurement distinction; AUTHOR-REPORTED
performance requirement, #318, 2026-10-17. Baseline 006a2fff, release 5.4.27;
GZDoom 4.14.2, Windows 11, Vulkan, Ryzen 9 5950X / RTX 3070 Ti, 1280x720.
Evidence: [controlled audit](../assets/validation_issue318/RESULTS.md).

The peaceful 600-soldier MAP06 can maintain about 35 simulation tics/s while
presenting only 8-12 application frames/s. Report simulation rate, application
presentation intervals (mean/p95/p99/worst stall), and renderer/thinker costs
separately. A 60-FPS goal implies a 16.67-ms frame interval; an average above
60 alone does not establish smooth traversal. The author expects at least
60 FPS in the mansion and sewers and requires performance to be considered in
future changes. Fixed entrance tests are references, not whole-map acceptance.

Use an immutable package/configuration, fixed camera and actual population;
repeat matched controls without simultaneous engine/package builds. Follow
CA-KP-041 for background/audio settings and CA-KP-053 for presentation and
population-divergence controls. Disclose changed visuals/gameplay; preserve
raw samples and failures. Native success is not author acceptance.

`profilethinkers -t` is one simulation-tic snapshot. Instrumented inclusive and
exclusive scopes include probe overhead; nested costs cannot be added twice.
Native `bench` is a later renderer CPU snapshot, not GPU duration or a window
mean; leave the console closed and allow at least five wall seconds to write it.
Main/worker CPU scopes overlap. In this audit PresentMon reports `Other` /
`Composed: Copy with GPU GDI`; its application-present cadence agrees with
callbacks, but compositor display-change coverage varies. Neither callbacks nor
`MsGPUTime` establish scene GPU execution or monitor refresh. Preserve that limit
instead of presenting a false exact CPU/GPU split. See the pinned
[native counters](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/rendering/hwrenderer/data/hw_clock.cpp).

Regression: repeat city pitch 0/75 and reference-map runs with the final build.
Production improvement and author acceptance under #318 remain pending.

## CA-KP-111 - A ground-facing view can increase large-map geometry work

Status/evidence: CODE-VERIFIED engine cause and ENGINE-VERIFIED MAP06 symptom,
#318, 2026-10-17; baseline/environment as CA-KP-110. Sources: GZDoom
[FrustumAngle](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_drawinfo.cpp#L386),
[BSP clipping](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_bsp.cpp#L335)
and the [audit](../assets/validation_issue318/RESULTS.md).

At MAP06 (-2048,320), yaw 180, changing pitch from 0 to 75 degrees increases
native wall-processing calls from 64,565 to 83,010. Removing every door leaves
those counts unchanged. `Walls` counts `HWWall.Process` work, not unique walls
visible in the final picture. GZDoom 4.14.2 broadens its ordinary horizontal
frustum with tilt and removes that angular restriction above 46 degrees. The
ordinary camera also lacks the extra vertical subsection clipping used by its
out-of-bounds views. Seeing mainly floor therefore does not imply cheap rendering.
Do not fix this by restricting the player's pitch or blaming the floor texture.
The measured 45-degree view already reaches 83,010 calls: 46 degrees is a code
branch, not a proven first performance-drop angle for every FOV/aspect/map.

Opaque one-sided walls and qualifying closed sector boundaries can stop angular
traversal; a decorative solid actor, masked middle texture or two-sided moving
polyobject is not an equivalent occluder. Open sky and low/3D-floor structures
can leave substantial surrounding geometry to process. A corridor's total wall
count is a poor comparison with an open city's per-frame workload.

Current MAP06 has 2,264 Line_Horizon definitions and 752 3D-floor control lines.
The observed 2/4 portal counts are setup operations, not evidence of 2/4 complete
city redraws: native horizon rendering emits plane strips. See
[horizon rendering](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_portal.cpp).
Measure portal types/depth and a matched `gl_portals false` control before
assigning cost to them. Regression: fixed pitches 0/45/47/75, renderer counts,
application presentation, unchanged camera/population. Geometry fixes and
whole-route author acceptance remain pending; recheck engine-version changes.

Current MAP03 follow-up (#318 /5.4.37,2026-10-18): eight native runs preserve
the adopted district sky/private houses and normal bounded deployment. At
(0,320), pitch0/75 raises wall processing235->4,243, flat vertices41,763->90,492
and native CPU All1.400->4.416ms. These are single later bench snapshots, not
whole-window CPU/GPU averages. Native FPS snapshots546/177 peaceful and48/35
siege city/front do not establish stable60FPS. Ordinary siege windows contain
600 defenders and993-998 living Mandingas, with simulation35.00/34.74tics/s.
Do not compare ratios against older simultaneous-deployment sessions.

Measurement safeguards: the UI callback tic label has a different phase from
WorldTick. Select complete [end_ms-interval,end_ms] intervals within measured
wall-clock bounds, not callback tic labels; this still is not presented FPS.
Some sampled method costs flush before/after WorldTick and need addition into
the same sampled tic. Exclusive time removes instrumented children only; it
retains uninstrumented work/probe overhead and is not a predicted saving.
bench waits5seconds then records native counters/timing, not a5-second mean.
Use one completed benchmark per recorded byte range and reject incomplete logs,
wrong hashes, failed exits or missing/duplicate tic boundaries. Source/launch
records, all method rows and qualifications: assets/validation_5437/RESULTS.md.

## CA-KP-112 - Large-map optimization starts with boundaries and visibility

Status/evidence: CODE-VERIFIED generator structure; research/proposed remedies
explicitly distinguished from native results, #318, 2026-10-17.
Scope: `generate_coastal_trials.py:CoastalMap.write`, MAP06 generation and future
large maps. Baseline 006a2fff; [audit](../assets/validation_issue318/RESULTS.md).

MAP06 has 86,382 linedefs and 81,469 vertices. Its compact generator removes
internal edges between identical cells but retains many collinear 64-MU boundary
segments. Merge only compatible boundaries: preserve topology, sector sides,
flags, specials/IDs, and continuous texture coordinates on both faces. Existing
offset-zero 64-MU pieces often use textures with a 128-MU repeat; naively joining
them changes appearance. The diagnostic merger explicitly permits that change
and is not a production or save-compatible replacement. Longer lines also change
the endpoints used by `CaelumThermalShelter.WindBlocked/Connected`; identical
physical boundaries do not prove identical shelter/thermal behavior.

| Technique to evaluate | Constraint and required evidence |
| --- | --- |
| Merge redundant collinear boundaries | Compare native wall/BSP counts and FPS; preserve texture phase, interactions and collision. |
| Improve real occlusion | Design opaque boundaries and short sightlines where appropriate; retain approved routes, roofs and sight/combat rules. |
| Reduce decorative sector/3D-floor detail | Replace only dispensable detail after a matched test. Sprites/models also have costs; #304's model control was slower. |
| Separate distant districts/interiors | Physical map sections or hub maps can limit work. Portals are not free streaming; preserve saved state and obtain approval for layout/continuous-siege changes. |
| Tune/prebuild GL nodes | Compare identical geometry and node settings. Faster loading or compressed nodes alone is not an FPS improvement. |
| Reduce lights, shadows or resolution | Use controls to distinguish GPU/pixel cost from CPU submission. Do not remove visuals on speculation. |

Primary references: pinned [map-section construction](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/maploader/renderinfo.cpp),
[clipping](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_bsp.cpp)
and [ZDBSP options](https://github.com/rheit/zdbsp#node-tuning-options).
ZDBSP exposes splitter/search tradeoffs, not a universal best preset; REJECT is
not a renderer visibility/streaming solution. Rebuild nodes after geometry edits.
Compact and remap referenced sidedefs: retaining sparse old indices after line
removal can produce native "has no front sector" errors. The
[4.14.2 UDMF loader](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/maploader/udmf.cpp#L2395)
allocates from referenced-side count and rejects original side indices at or
above that count.
Changes to line/vertex indices require an explicit save/hub compatibility plan.
Never substitute a diagnostic map for an existing campaign save. Production
geometry optimization and route/visual/collision acceptance remain pending.

## CA-KP-113 - Invisible door collision helpers can dominate peaceful simulation

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED diagnostic controls, #318,
2026-10-17; baseline/environment as CA-KP-110.
Scope: `CaelumSlidingDoorBlocker.Tick`, `CaelumHingedDoorLeaf.BlockerPosition`,
`CaelumSlidingDoorLeaf`, and city placement. [Evidence](../assets/validation_issue318/RESULTS.md).

The peaceful city contains 960 door leaves, each using eight solid helper actors:
7,680 blockers, within 13,618 actors despite only 600 soldiers. Every blocker
currently computes its location and calls `SetOrigin` each tic, even when its
door is closed and stationary. In instrumented samples the blocker class costs
about 6.27 ms/tic inclusive; the 600 common combat-actor ticks cost about 3.42 ms.
These inclusive scopes contain child calls and probe overhead; do not add them
to their child costs or label them exact uninstrumented costs. Peaceful soldiers
do not execute the siege's normal target/pathfinding
pulse; physiology, statistics, equipment and other shared work remain active.

Removing exactly 960 leaves plus 7,680 blockers, retaining 600 soldiers, increases
application presents from 11.35-11.82 to 19.41-19.44/s forward and from 8.44-8.68
to 12.41-14.27/s downward. This measures the combined door system, not rendering
alone. It remains far below comfortable performance.

Proposed first step: eliminate unchanged-position relinking and update helpers
when their door moves, retaining closed-door collision. Native sector doors and
PolyObject sliding/swing doors are alternative representations, not guaranteed
faster replacements; they require map integration and anti-crush/use/save tests.
See native [sector-door implementation](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/p_doors.cpp)
and [PolyObject movement](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/po_man.cpp).
Do not simply delete production blockers or suspend living combatants. Regression:
matched idle/moving-door timing plus use, reopening, obstruction, collision and
save/hub checks. Production fix/author acceptance remain pending.

## CA-KP-109 - Convert native chase steps before assigning continuous velocity

Status/evidence: ENGINE-VERIFIED, #307 / 5.4.27, 2026-10-16. GZDoom 4.14.2,
Windows Vulkan; validation_5427/RESULTS.md. Baseline 83f79cc1 with the focused
escort change; production package fingerprint is recorded with the native runs.

Actor.Speed is the distance of a native chase step, not automatically a per-tic
velocity. The four prisoner See states call chase every four tics. Assigning
that full Speed to Vel each tic still quadruples effective walking even after
removing an explicit run multiplier. Convert using the existing state cadence
and the resolved Speed, so health/thermal/elemental penalties remain authoritative.
Keep the cadence shared with its state declarations, without changing their order
or durations. The independent attack-free native A_Chase control and ordinary
escort each travel 100 units in 40 tics. Regression: walking.cfg plus motion.cfg,
including low speeds, proximity and restarting. Author acceptance: CA307-01
passed on 2026-10-16 without reported exceptions (origin 5.4.27 / #307).
Limits: this conversion applies to these existing chase states, not arbitrary
velocity-driven actors or a new global movement policy.
On 2026-10-18, #322 explicitly superseded that escort pace with player-formula
walking using each prisoner's own attributes/penalties. The native combat-state
cadence and the warning about step-versus-velocity units remain applicable.

## CA-KP-108 - Register queryable channels before deferred PostBeginPlay

Status/evidence: ENGINE-VERIFIED, #305 / 5.4.26, 2026-10-16. GZDoom 4.14.2,
Windows Vulkan; validation_5426 preserves issue305-01/registry-01 failures and
the corrected issue305-02/registry-01 run.

A channel returned by Actor.Spawn can be configured and queried before its
PostBeginPlay runs. Registering only in PostBeginPlay left immediate climate
queries empty while the original native thinker scan already found the channel.
Register idempotently in ConfigureChannel as well as PostBeginPlay; unregister
without rebuilding during OnDestroy. Reconstruct the transient map index on
WorldLoaded, including old saves, and clear it on unload/unregister.

A typed ThinkerIterator filters results but still walks thinker lists. A query
per NPC can therefore be expensive even with zero matching channels. Index only
channel references, not positions, climate or visibility results; preserve the
original per-query eligibility and path checks. Native equivalence tests cover
empty/overlapping channels, ordering, immediate mutations and save/hub lifecycle.


Follow-up ENGINE-VERIFIED, #410/5.8.11,2026-10-25 (validation_5811): a fixed
fixture must retain identity assigned immediately after Spawn, and use its final
collision size before TestMobjLocation. PostBeginPlay must not overwrite that
identity later. Saved EventHandler readiness is also persistent: a new transient
readiness guard is necessary to revisit legacy maps and install additive actors.
The final legacy load/retry/save tests cover both boundaries. Bathroom lookup
uses one typed controller scan on load/retry (at most once per second while
blocked), never per NPC or per tic; owner is HouseHubEvents. The fixture count
is one controller/three objects. In the recorded57-actor house,1000 ready calls
averaged0.000545ms, observed worst0.010200ms; this bounds that recorded sample,
not arbitrary player populations or render performance. Collection uses a local
blockmap query and water refill performs no periodic household/actor scan.

## CA-KP-107 - Launch only completed, immutable native test packages

Status/evidence: ENGINE-VERIFIED failure and guarded successful rerun, #252 / 5.4.21,
2026-10-15. GZDoom 4.14.2, Windows 11; validation_5421.

The first legacy-save run began while its preparation command was still running.
Its log reported a missing console script and loaded packages that the preparer
had not yet finished replacing. The author's matching crash report records a
native C0000005 read at 0x8 before entering a level. Preserve this as a failed
startup, not a Seal gameplay crash or a successful legacy test.

Wait for preparation to exit successfully before launching dependent processes.
Write the manifest last, use fresh output directories, and require the manifest,
script and matching runtime/fixture hashes before starting the engine. Never
replace an archive while a running engine can still read it. Missing-file startup
output must fail the runner instead of leaving it waiting for a completion marker.
The completed 5.4.20 seed and 5.4.21 upgrade both passed with the guarded launcher.
The local ZIP/dump is retained under build and is not a distributed project asset.

#413 follow-up (5.8.1, ENGINE-VERIFIED, 2026-10-23): refreshing only files
currently in git diff can leave stale archive entries when a changed file is
reverted to baseline. MAPINFO retained a removed handler registration while its
class had become a plain Object, causing the author-observed fatal event-handler
error. The compile helper now remembers previously refreshed paths, including
reverts. A complete build plus byte comparison of every src/archive entry is
the delivery gate; final old-save loading passes after reconstruction. See
assets/validation_581/RESULTS.md. Preserve failed logs as diagnostic evidence.


## CA-KP-106 - Recreate disposable visuals instead of carrying stale world links

- Status: ENGINE-VERIFIED, #251 / 5.4.20, GZDoom 4.14.2 Windows Vulkan,
  2026-10-15. Scope is the cloud presentation actor, not all actor travel.
- Manually UnlinkFromWorld/STAT_TRAVELLING followed by SetOrigin on the cloud
  model reproduced a native MAP98 transition crash: access violation writing
  0xbeefcafe. A cosmetic actor does not need to retain native world links.
- Keep authoritative duration, power and pulse phase in the owner's inventory.
  Destroy the old presentation in PreTravelled and recreate it in Travelled.
  The same failing save then passes hub departure/return and non-hub transfer,
  with one presentation actor and continued flight. Stateful summoned bodies
  still use their separately verified placement/link-flag protocol (CA-KP-102).
- Evidence/reproduction: [validation_5420](../assets/validation_5420/RESULTS.md).
  Original crash report and failed run are retained under build/issue251-gameplay-03.

## CA-KP-105 - Native flight powers share flags without ownership counting

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED native API behavior, #251,
2026-10-15, integrated 5.4.19 baseline c1f1553b / GZDoom 4.14.2 Windows Vulkan.

`PowerFlight.EndEffect` in the engine's `zscript/actors/inventory/powerups.zs`
clears FLY/NOGRAVITY unless the flight cheat is active. It does not check for a
second active flight power. Two separately named native subclasses can coexist
as inventory, but removing either clears those shared flags. The isolated probe
reproduces this in both orders; invoking the survivor's InitEffect restores flight.
That probe call is diagnostic: InitEffect can also repeat the native takeoff thrust.

An ability sharing flight with El Loco must manage its own contribution, preserve
remaining sources on expiry, and avoid restarting timers, charging again or adding
an unintended takeoff impulse. Native coexistence alone is insufficient. The
5.4.20 stateless helper/Tarot integration preserves flags and view-centering state
when another positive-duration PowerFlight remains. Focused component checks use
real Tarot and a fixture-only second source. Full cloud input, movement, expiry, hub travel and save/load are covered
separately in validation_5420. The earlier eight API assertions and ten component
checks retain their narrower scope.

Evidence/reproduction: [flight_evidence.json](../assets/validation_545/flight_evidence.json),
`prepare_flight_probe.py` and `flight_probe.zs` in the same directory. This finding
complements CA-KP-040's separate hub-power removal behavior.

## CA-KP-104 - Translucent cloud meshes need visual inspection from several angles

Integrated as CA-KP-104 on 2026-10-15; the isolated #251 branch originally
used CA-KP-097, now occupied by the accepted #260 movement lesson.

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED asset behavior, #251 / 5.4.5,
2026-10-14; GZDoom 4.14.2 / Windows / Vulkan and OpenGL. Author art acceptance pending.

A closed mesh and successful model load do not make a volume behave like fog.
A transparent, concave cloud shell showed hard bands from overlapping visible
surfaces. Reversing winding or explicitly forcing native culling did not remove
the appearance. Do not report those diagnostic runs as a visual fix.

Use a single closed shell, verify topology independently, and inspect front,
side, back, high and low views against a contrasting background. The #251
material uses SetupMaterial with world normals/view direction to soften grazing
contours and suppress back-facing fragments. This is a surface approximation;
concave bands remain a visual limitation, and no general depth-sorting or
volumetric-rendering fix is claimed. Source observation: GZDoom g4.14.2
src/rendering/hwrenderer/hw_models.cpp:56-67 itself notes incomplete depth sorting.

Evidence/reproduction: [validation_545](../assets/validation_545/RESULTS.md).
Keep art-space dimensions and preview opacity separate from gameplay collision,
size and rider anchors. Do not adopt an unapproved fixture scale as balance.

## CA-KP-103 - Native resurrection preserves identity but needs project restoration

- Status: ENGINE-VERIFIED, GZDoom 4.14.2, #250 / 5.4.19, 2026-10-15.
- Actor.Revive works without a Raise animation, preserves inventory and resets
  native death flags, but does not restore a dead NPC's full height or Caelum
  reserves and increments the native monster total. Use explicit full-body fit,
  height/resources/status restoration and retain the previously recorded count.
  PlayerInfo.Resurrect restores the currently owned dead pawn/control; reject a
  stale corpse whose player already has another pawn. Do not clone a profile.
- Record raised-body identity and original allegiance separately from the aura.
  A persistent latch prevents repeated custom/predefined drops and death rewards;
  per-cast references prevent repeated resurrection during the same cast.
  Death-dependent owner effects must end even if resurrection happens in that tic.
- Probe after PostBeginPlay has initialized the actor. A stationary test target
  that skips Tick also skips periodic damage; native attack/health assertions must
  run that path. A non-monster is not automatically flagged CORPSE by native death.
- Evidence and exact limits: [validation_5419](../assets/validation_5419/RESULTS.md).
  This is focused engine evidence, not broad campaign or multiplayer acceptance.

## CA-KP-102 - Summoned bodies need explicit travel ownership and native JIT checks

- Status: ENGINE-VERIFIED, GZDoom 4.14.2, #249 / 5.4.18, 2026-10-15;
  baseline b87f977b plus the #249 working patch.
- An owned inventory can move its companion and finite inventory to
  STAT_TRAVELLING in PreTravelled. Travelled must restore the companion to
  STAT_DEFAULT and its inventory to STAT_INVENTORY before native travel cleanup.
  Retain identity and reserves; clear old-map targets and geometry references.
  A blocked arrival can keep the body noninteractive while the owner's timer runs.
- Native A_Look does not enter See without an enemy. Merely waking friendly
  A_Chase still permits wandering away; explicit owner following needs its own
  collision-aware step and obstacle fallback. Do not use the caster as a patrol
  point, which can trigger unrelated PatrolSpecials for its TID.
- A scripted `out Vector3` placement result compiled but failed during JIT with
  `REGT_ADDROF not implemented for vectors`. Returning an object with Found/Point
  removes that output parameter. The engine returned zero on that failed run:
  require a completion marker and scan JIT diagnostics, not just the exit code.
- Evidence: [validation_5418](../assets/validation_5418/RESULTS.md), including
  current reload/hub/blocked-arrival and copied-save checks. Prototype failures
  and final hashes remain recorded. Scope is the tested native engine and temporary
  ally lifecycle; campaign/multiplayer and author acceptance are not implied.

## CA-KP-101 - Capture damage factors before resource-changing callbacks

- Status: ENGINE-VERIFIED, GZDoom 4.14.2, #248 / 5.4.17, 2026-10-15.
- Symptom: evaluating a live Adrenaline modifier after shield/pain callbacks
  would let the same hit benefit from the resource it generates. Deriving a
  periodic dose from already-scaled HP would also store that modifier twice.
- Remedy: capture source/receiver factors at damage entry, apply them after
  defenses and restore the prior transient context on nested calls. Exclude
  the factor from stored elemental doses; resolve it again at each real pulse.
  Handle forced damage separately because it bypasses TakeSpecialDamage.
- Evidence: native shield-callback/nested-hit fixture, seal plus burn-dose/pulse,
  forced damage and real in-flight projectile checks in
  [validation_5417](../assets/validation_5417/RESULTS.md). The same production
  runtime passes current reload and copied-save upgrade/rollback/return.
- Limits: this establishes the author's Rally ordering. It does not authorize
  changing other effects' snapshot policies or claim multiplayer acceptance.

## CA-KP-100 - Measure obstruction after movable-body contact

- Status: ENGINE-VERIFIED, GZDoom 4.14.2, #247 / 5.4.16, 2026-10-15.
- Symptom: an empowered traversal stopped on walls but continued driving after
  a moving body impeded it; BlockingMobj was no longer a reliable post-Tick signal.
- Remedy: compare actual forward displacement with the requested native step,
  after collision energy/defenses resolve. End only the scripted traversal and
  preserve native contact velocity; do not clear its defense before both receivers.
- Evidence: issue247-audit04/body failed; issue247-confirmed/body passes termination,
  equal raw collision energy to both bodies and ordinary defenses on the other body.
  Exact logs/hashes: [validation_5416](../assets/validation_5416/RESULTS.md).
- Limits: this is the authored fixed-direction ground traversal, not a replacement
  for general collision detection, ordinary movement or NPC physics.

## CA-KP-099 - Freeze composite appearance at one simulation instant

- Status: ENGINE-VERIFIED and agent visual review, #247 / 5.4.16, 2026-10-15.
- Symptom: body afterimages were captured after physics while the modular head
  still held its preceding Tick position; at high speed the detached offset grew.
- Remedy: synchronize the owned head visual before freezing body/head snapshots.
  Preserve sprite/frame, scale, offset, translation and shared capture position/age.
- Evidence: issue247-boundaries/preview records one-step offsets; reviewed/preview
  records exact paired positions/ages and a visually inspected fading trail.
  [validation_5416](../assets/validation_5416/RESULTS.md) retains hashes.
- Limits: CA247-01 passed author review on 2026-10-15; this verifies the current
  owned composite sprite system, not arbitrary future 3D attachments.

## CA-KP-098 - Bound native console test scripts

- Status: ENGINE-VERIFIED, GZDoom 4.14.2, #260 / 5.4.15.
- Symptom: a 4,188-byte single-line fixture executed only its trailing check and
  completion marker; the preceding setup and scenarios did not run.
- Remedy: split the sequence into short scripts and explicitly chain them with
  `exec` after their waits. Assert the expected case/pass counts as well as DONE.
- Evidence: build/issue260-impulse02/contract02.txt (failed fixture); chained
  contract03 and contract06 in assets/validation_5415/impulse_evidence.json.
- Limits: this establishes the reproduced command-buffer truncation; it does not
  specify a universal limit for every native command or engine version.

## CA-KP-097 - A linear input envelope is not linear native motion

- Status: verified in isolated GZDoom 4.14.2 input tests, #260 / 5.4.15.
- Symptom: changing ForwardMove/SideMove factors alone leaves an additional
  native-friction lag; a displayed 100% factor does not prove full movement speed.
- Cause: each command adds thrust to momentum already reduced by friction.
- Remedy: retain native movement and compensate only that command's thrust
  while its ramp rises; do not clamp total velocity or cancel external impulses.
  With constant friction f and ramp increment d, added thrust is the full-speed
  command thrust times f*d/(1-f). Skip media without applicable native friction.
- Evidence: assets/validation_5415, per-tic native input velocity/displacement
  for 50/100/200 kg, walking/running/lateral/flight/water and copied-save cases.
  The installed engine's player.zs and g4.14.2 p_mobj.cpp establish the boundary.
- Limits: constant mass/target/input establishes linear motion. Direction changes,
  collisions, dynamic modifiers and ordinary airborne control retain native policy.
  These original ramp traces do not establish impulse behavior; same-patch
  impulse evidence is recorded separately in validation_5415.

## CA-KP-096 - Early derived-stat queries can erase a spawn default

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #254 / 5.4.3,
2026-10-14; baseline 3d07bb87, GZDoom 4.14.2 / Windows / Vulkan.

MAP02 rats recognized the player but never pursued: all 192 had zero Speed and
CombatBaseSpeed. A package-only trace observed personality/health calculation
while Speed was still 10 and CombatBaseSpeed was 0, then rat PostBeginPlay entered
with Speed 0 and the shared initializer captured that zero. Seeing the correct
Default property therefore did not establish the value actually captured.

Restore the rat's missing initial Speed from its class default before the shared
capture. Preserve positive custom values. Old saves do not replay PostBeginPlay:
revision-1 Tick migration repairs only absent bases and recalculates current
health effects without replacing the body. A Tick-only trial failed because fresh
spawns had already marked the revision; keep fresh and saved paths covered.

Evidence/reproduction: [validation_543](../assets/validation_543/RESULTS.md).
The final native probe checks all 192 rats and actual pursuit/bites across four
sections. Upgrade, reload, rollback and hub checks preserve corpses, drops, sleep,
resources and a positive custom base. The author passed audio/movement check CA254-01 on
2026-10-14; this finding does not establish the same defect in other actor classes.

Follow-up, #253 / 5.4.14, 2026-10-15, CODE-VERIFIED and ENGINE-VERIFIED:
native MAP01 traces independently
establish the same missing-base capture for all four anchored residents. At the
player's protected floor their own healthy/thermal/elemental factors were one,
but bases and Speed were zero. The repair is scoped to these narrative residents;
it does not broaden the rat fix to every actor. Fresh and copied-save tests retain
positive customization, finite equipment and genuine downing. Evidence:
[validation_5414](../assets/validation_5414/RESULTS.md). Author check CA253-01 pending.

## CA-KP-095 - Native menu command tests need the real dispatch boundary

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #236 / 5.3.9,
2026-10-14; baseline 2f738c39, GZDoom 4.14.2 / Windows 11.

Calling OptionMenuItemCommand.Activate from a diagnostic ConsoleProcess can
abort with "Attempt to execute CCMD ... outside of menu code", even when the
item belongs to the current native menu. Do not remove the engine guard or
mislabel that failure as ordinary player input. Inspect the actual descriptor
and test its route separately through console commands; record physical native
activation as outstanding until exercised through real input. The #236 failed
flow-04 and subsequent selected runs are retained in assets/validation_539.

OptionMenu's exposed descriptor has mFont, but the ListMenu-style Font token
in a 4.14.2 OptionMenu definition causes a fatal menu-parser error. Assign the
descriptor's supported field instead. Keep startup stderr/stdout and detect
the fatal-error process title so a hidden test cannot wait indefinitely behind
an error dialog. Neither these scripted checks nor a successful build imply
author usability acceptance.

## CA-KP-094 - Check disclosure separately from legacy objective writes

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #235 / 5.3.8,
2026-10-14; baseline fc947471, GZDoom 4.14.2 / Windows 11.

The first tracking fixture found the main quest active before Palomo's guidance.
`CaelumMainM00RonnieTrial.Update` calls `CaelumOnboarding.UpdateLessons`, whose
legacy setters activate an undiscovered main slot and mark crafting objectives
known before their authored stage. A tracking adapter that trusts only those
flags can expose unstarted/future content despite performing no progress writes.

Use the documented disclosure evidence and existing stage constants in the
shared read-only catalogue. Preserve stored progress and genuinely later legacy
stages; do not silently reset them or change controllers in a presentation patch.
Native before/after-guidance and later-stage cases verify this boundary. The
initial failed diagnostic remains in assets/validation_538/main-01.txt; final
evidence and limits are in assets/validation_538/RESULTS.md. No author acceptance
is inferred from these scripted cases.

## CA-KP-093 - Wait before validating manually spawned service fixtures

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #232 / 5.3.5,
2026-10-13; runtime 356f20ad, GZDoom 4.14.2 / Windows 11.

`CaelumSiegePreviewWorld.RemoveTrialFurniture` periodically retires beds and
stations in MAP03. An immediate scripted Use can succeed before cleanup even
though a human cannot use the disappearing object. The author exposed this
handoff failure. A native delayed-use run reproduced both missing objects and
missing discoveries; the equivalent MAP04 run retains the objects, menus and
known markers. Keep the existing map contract intact. Validate fixture lifetime
before and after ordinary input, and retain this distinction in acceptance.
Evidence: assets/validation_535/RESULTS.md and author-delay-map04-02.

#234 / 5.3.7 city follow-up, 2026-10-14: short scripted Use pulses intermittently
missed input in the native city harness. Hold the diagnostic button long enough
to observe an actual cmd.buttons transition; the selected 35-tic pulses verify
real gate/workbench/forge use. Separate input checks from map/menu capture changes.
Do not infer a production interaction defect from an unobserved synthetic press.
ENGINE-VERIFIED evidence: assets/validation_537/cityfix_evidence.json. The author
accepted the focused city correction retest on 2026-10-14; ordinary exploration
remains pending. Gameplay control timing was not modified.

#320 / 5.4.32 follow-up (GZDoom 4.14.2, 2026-10-17): assigning a target and
chase state before deferred PostBeginPlay made a two-enemy attack fixture miss
one launch. Wait for native initialization before arming the natural actors.
Frozen same-tic action tests may initialize explicitly, but label them as isolated
and do not silently call PostBeginPlay twice on a natural actor. Compare moving
target aim in the release tic; a next-tic reference can measure different geometry.
ENGINE-VERIFIED evidence: assets/validation_5432/RESULTS.md, release/final02 logs.
Production initialization is unchanged; author check CA320-01 remains pending.

## CA-KP-092 - Automap colors do not provide floor selection or private markers

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #231 / 5.3.4,
2026-10-13. Baseline: 7b90cfde plus the focused #231 patch; GZDoom 4.14.2,
Windows 11, Vulkan, isolated INIs and native engine-created saves.

The g4.14.2 `am_map.cpp` audit (commit 99aa489d09015a95bb78df2b30ede29f328cc874)
and MAP01 captures establish that native linework projects known XY lines;
extra-floor colors and textured floor surfaces do not expose a floor picker.
Bounds include distant control vertices. Retain native discovery/settings and
record this limit instead of silently inventing a height filter or zoom reset.
MAPINFO `Automap` / `Automap_Overlay` palettes respect `am_customcolors`; no
startup CVar writes are needed. Native MapMarker projection checks dormancy
and optional subsector discovery, but does not filter an owner/player. A later
private POI or note registry must not assume it provides private rendering.

#232 / 5.3.5 implements that boundary with character-owned facts and derived
markers that are dormant in multiplayer or with multiple participants. The
native bot fixture in assets/validation_535 verifies distinct discoveries for
two native players and no displayed private markers. This is ENGINE-VERIFIED
ownership/privacy evidence, not a multiplayer gameplay certification.

The native serializer preserves ten numbered marks, scale and map bounds.
The #231 old/current/reload/rollback and hub scenarios compare these objects
and linedefs directly. Native `screenshot` queues its capture: wait before
changing view/map state, or a file named for one state can contain the next.

Large native message scaling can push a project cartouche down over resources.
Reserve the actual top resource label, including its baseline offset, and
bound the cartouche position without rewriting preferences. The final large
ultrawide capture verifies separated labels; transient native console notices
still own their native drawing and lifetime. Regression evidence:
assets/validation_534/RESULTS.md and its final captures/manifest. Ordinary
input and visual acceptance passed CA231-01 on 2026-10-13 after the author
returned. Physical-controller coverage was not separately reported.

#234 / 5.3.7 follow-up, 2026-10-14: correct access text does not prove the native
MapMarker icon matches. Author CA234-01 reported an open grate still showing a
padlock; category-only texture lookup ignored ObservedAccess. Native reproduction
and 43 corrected assertions in assets/validation_537/marker_evidence.json check
the real actor picnum, save/reload and remote-state isolation. Assert rendered
state as well as the persistent fact. ENGINE-VERIFIED; author retest pending.

The author accepted the dedicated sewer open-padlock artwork/save-load on
2026-10-14. Subsequent city feedback exposed a separate coverage omission: city
gates were generic exits without observed access, and factory services were not
bound. City evidence now checks observed exit icons and all 96 real station
identities. The focused city gate/station/save-load retest passed author review
on 2026-10-14. Ordinary city traversal and other unconfirmed cases remain pending.

## CA-KP-091 - Native menu actions need visible feedback inside the menu

Status/evidence: ENGINE-VERIFIED, #227 / 5.2.26, 2026-10-13.
Baseline: 66029634; GZDoom 4.14.2 / Windows 11.

A successful event dispatch does not imply visible feedback. The ordinary
notification renderer suppresses all native menus, so rejected rest actions
looked inert. Render the current inbox result after the native menu's transform
ends, using message scaling once. When a large notice would cover resources,
use the upper information area while preserving controls. Reuse the inbox/history.
Test actual authored furniture: MAP02's standalone chair is not a serving table.
A spawned table fixture cannot establish behavior of that authored scene.

Evidence: assets/validation_5226; key/pointer and physical Windows inputs, finite
reserves, saved session and large Spanish 4:3 message. Scope: tested rest panel;
this does not certify every menu or reproduce the author's exact T blocker.

## CA-KP-090 - Decorate native menu labels without mutating their data

Status/evidence: ENGINE-VERIFIED, #215 / 5.2.22, 2026-10-12.
Baseline: 8fc9bc80; GZDoom 4.14.2 / Windows 11.

Option search shares item objects with source descriptors. Add display hints
only around Drawer and restore labels before search/input; retain specialized
native subclasses. Saved-game titles are persistence data: draw an overlay,
never append hints to SaveTitle. Confirmation text extending past the original
caption also needs a corresponding horizontal mouse bound.

Evidence: assets/validation_5222 covers real render frames, repeated native
search, unchanged stored save titles and clicks on the appended Yes hint.
The test fixture initially shadowed its Result field with a case-insensitive
parameter; self.Result fixes that fixture error. Engine event structs are
read-only and direct native key-binding mutation from ConsoleProcess is
rejected; test menu capture opening/abort separately from physical rebinding.
Scope: the target engine and the tested menu paths; physical input acceptance
remains CA215-01. Do not infer every native submenu was manually exercised.

## CA-KP-089 - Model registration for a gameplay subclass

Status/evidence: ENGINE-VERIFIED, #216 / 5.2.21, 2026-10-12.
Baseline: 7f801d41; GZDoom 4.14.2 / Windows 11.

CaelumTutorialGoldVein inherits CaelumVeinGold states and physics, but its
parent's MODELDEF does not render this subclass. The transparent CAVE F
fallback leaves a solid invisible rock. An explicit MODELDEF registration
reuses the original OBJ and resolves it without changing saved gameplay data.
Verify subclasses visually, not only through actor counts or resource calls.

Evidence: assets/validation_5221 pairs the same basement camera before/after;
the native probe reports exactly one 2 kg actor and its unchanged position.
Scope: this subclass and target engine; do not generalize this into an engine
inheritance guarantee for every model feature.

## CA-KP-088 - Preserve pressure provenance before environmental relabeling

Status/evidence: ENGINE-VERIFIED, #211 / 5.2.19, 2026-10-12.
Baseline: 4549991a; GZDoom 4.14.2 / Windows 11. Scope: biological impact
cushioning, hazard-rock pressure and preweighted work snapshots.

Player and NPC impact receivers relabel hazard-rock sources as environmental.
Testing the kind after that relabel can accidentally give sustained crushing a
new impact-only allowance. Preserve the incoming pressure classification before
relabeling; update both direct delivery and captured per-tic work consumers.
Preweighted energy can hide a faulty fallback because the snapshot overrides
the recomputed energy. Exercise both supplied and absent cushionedJoules and
inspect diagnostics as well as HP. Keep the prior pressure rules explicit.

Evidence: assets/validation_5219/checks.zs compares the old fractional pressure
rules and new 150% impact/fall capacity, including active buckler and bull.
The native baseline still passes pressure expectations while failing the new
impact/fall expectations. Native motion and current/old saves are separate
checks; CA211-01 passed author acceptance on 2026-10-12 without qualifications.

## CA-KP-087 - Triangulate model caps before native OBJ validation

Status/evidence: ENGINE-VERIFIED; first recorded / last checked 2026-10-12.
Issue #209 / 5.2.18, GZDoom 4.14.2/Vulkan, original dining canteen mesh.
The generated flask used eight-vertex front/back faces. Native rendering kept
the quad edges, cap and strap but omitted those faces, producing a hollow frame.
Triangle fans with the same vertices/UVs rendered the solid flask in the next
native run. Export triangles/quads and assert face arity before packaging; a
syntactically valid OBJ is not proof that every polygon is rendered.
Evidence: assets/generators/generate_dining_canteen.py and validation_5218
rest-visual-01/02 captures/logs, check_assets.py and RESULTS.md. This confirms
the tested OBJ path, not general support for arbitrary imported model formats.

## CA-KP-086 - A health floor must precede native death and cover direct losses

Status/evidence: ENGINE-VERIFIED and CODE-VERIFIED; author gameplay check accepted.
First recorded / last checked: 2026-10-12. Issue #207 / 5.2.17.
Baseline: 1bf5087e; GZDoom 4.14.2, Windows 11, isolated Vulkan fixtures.
Scope: CaelumPlayer.ApplyNativeHealthDamage, Die, CaelumTutorialSafety,
survival/thermal direct losses and journey health commit.

Actor Buddha can be bypassed by telefrag/forced damage. Clamping incoming damage
before native armor changes absorption; restoring health after Super.DamageMobj
is too late to prevent native death side effects. The verified approach scopes
CF_BUDDHA2 around final native calls and restores only the introduced bit, so
nested calls and preexisting cheats remain intact. Native p_interaction.cpp at
tag g4.14.2 clears DMG_FORCED after early bypasses but before late native armor/
invulnerability; document that semantic instead of claiming perfect equivalence.
The return value is capped by both the native result and observed HP loss,
avoiding duplicate attribution when WorldThingDamaged triggers nested damage.
Native event payloads themselves still report engine-calculated damage.

This alone misses direct health writes. Survival and thermal accumulators consume
the original integer damage, then clamp actual loss; otherwise blocked damage
can become deferred debt. Die has only a final live-pawn fallback for direct
script calls, and does not revive saved corpses. No protection flag is saved.

Reproduce with assets/validation_5217 fixtures and RESULTS.md: ordinary/forced/
telefrag damage, armor order, nested events, direct losses, identity, saves and
MAP02 mortality. Source audit URL/hash and failed fixture attempts are retained
there. These checks establish the health-floor mechanism, not a general repair
of appearance after death on other maps. CA207-01 passed author acceptance on
2026-10-12 without qualifications; PR208 merge and #207 closure were authorized.

## CA-KP-085 - Fullscreen Vulkan cursor visibility can depend on presentation

Status/evidence: AUTHOR-REPORTED acceptance for physical visibility/clicks; ENGINE-VERIFIED
for native preferences/restart; CODE-VERIFIED for presentation mode selection.
First recorded / last checked: 2026-10-12. Issue #204 / 5.2.16.
Baseline: cd712377; GZDoom 4.14.2, Windows 11, RTX 3070 Ti, NVIDIA 576.88.
Scope: native Windows cursor at fullscreen startup through run_dev.bat.

With Vulkan, vid_vsync=false and vk_exclusivefullscreen=false, the author saw
no cursor in fullscreen; windowed Vulkan and fullscreen OpenGL showed it.
Reassigning vid_cursor, replacing the moon with the Windows arrow, and mode
cycling failed. Exclusive fullscreen also failed initially; Alt+Tab recovered
it in that probe. This focus recovery must not count as successful startup.

Native vid_vsync=true produced two successful fullscreen Vulkan starts before
Alt+Tab. The author verified MainMenu/Options/creator clicks and gameplay/menu
capture transitions, then approved this preference. Keep it in the existing
INI; do not force a backend or overwrite other users' explicit VSync choices.
VSync can add latency. The physical result applies to the recorded installation,
not every GPU/driver. No engine/driver root cause or source-level repair is proven.

g4.14.2 libraries/ZVulkan/src/vulkanswapchain.cpp selects IMMEDIATE presentation
when supported with VSync off, versus FIFO/FIFO_RELAXED with VSync on. This is a
code distinction, not instrumentation proving which driver path lost the cursor.
Recreating the Windows HCURSOR does not itself repair capture/ShowCursor state.
CA-KP-034 still governs the unchanged cursor image and hotspot.

Reproduction: assets/validation_5216/RESULTS.md, probes, logs and hashes. Use
disposable configs and record initial focus separately from later Alt+Tab.
The fullscreen Computer Use capture showed other desktop windows in these runs;
it cannot establish physical cursor visibility. Native engine screenshots omit
the OS cursor. Use explicit physical-display observations for that claim.
The first -window-only probe still reported vid_fullscreen=true and is retained
as invalid windowed evidence; set the copied INI explicitly for that comparison.

## CA-KP-084 - Native crosshair and scale APIs have separate owners

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-12 / 2026-10-12. Issue #150, 5.2.15.
Baseline: b36ef830 plus #150 working changes; GZDoom 4.14.2 Windows/Vulkan.
Scope: CaelumPresentation, CaelumStatusBar, native menu/pointer adapters.

An empty BaseStatusBar.Draw override suppresses the native crosshair: the
crosshair lives inside the base Draw, not a separate engine pass. Calling
Super.Draw(HUD_Fullscreen,ticFraction) restores it without Doom status art.
Retain the HUD_AltHud exclusion and Caelum context guards; viewactive=false
identifies full automap (the doombase.zs comment is misleading; native am_map
behavior is authoritative). crosshairscale=0 means original pixels, not hidden.
Health colors use default actor health, with no exposed maximum-health hook.

StatusBar.GetHUDScale exists; Screen.GetUIScale does not. Copy GetUIScale's
integer formula once if needed and use Screen.GetTextScreenSize for messages.
Its integer dimensions need rounding when recovering the pixel factor; direct
division introduces fractional font stretch. Native hud_scalefactor=0 clamps
to 0.36 and does not hide HUD. Respect old/new HUD scaling as separate modes.

Screen.SetTransform operates after virtual-to-real projection and affects
text, textures, lines and Dim. Compute both X/Y relative factors: the existing
640x360 draw projection is not uniform at every aspect ratio. Invert that same
matrix before mouse hit tests. Clear it before full-screen feedback/PSprites
and after each menu Drawer. Clip rectangles are real pixels and do not inherit
the matrix. Native Save/Load Size Clean uses CleanXfac/Yfac, not uiscale.

Evidence/reproduction: assets/validation_5215/RESULTS.md; native small/large
4:3, 16:9 and ultrawide panels, crosshair contexts, pointer dispatch and combat
comparison. CA150-01 passed author visual/comfort acceptance on 2026-10-12.

## CA-KP-083 - Native bindings, modal priority and automap use different paths

#321 / 5.4.31 follow-up (ENGINE-VERIFIED): look up static UI handlers with
StaticEventHandler.Find, not EventHandler.Find. Wait after screenshot commands
before changing presentation: capture occurs on the subsequent rendered frame.
The Spanish automap LANGUAGE block must include the actual `es` locale, not
only `esp`; test the localized result with the user's configured language.
Evidence: assets/validation_5431, including retained failed/earlier attempts.

Status/evidence: ENGINE-VERIFIED for reset, persistence, hint enumeration,
slot commands and modal cancellation; CODE-VERIFIED for native double-binding
and controller navigation dispatch. #149 / 5.2.14, 2026-10-12, GZDoom 4.14.2.
Baseline: b21e0632. Author verified physical M opens/closes the map.

KEYCONF defaultbind is evaluated repeatedly and can resurrect deliberately
cleared keys. Use DEFBINDS before INI plus an explicit first-start/reset preset
for engine-default conflicts. resetb2defaults restores controls, not KEYCONF;
reset2defaults also changes unrelated CVars. Bindings.SetBind from UiTick is
invalid outside the native menu responder. Preserve the legacy empty key
section for existing normal/double binding import (CA-KP-077).

Enumerate GetAllKeysForCommand and NameAllKeys instead of assuming two keys.
DoubleBindings is not exposed to ZScript 4.14.2; preserve it through the engine.
Do not intercept a physical slot key before C_DoKey: PickWeapon is the native
post-dispatch hook, and SendNetworkEvent safely queues the authoritative change.
Native M_Responder converts Back/controller navigation before menu callbacks;
ambiguous menu keys cannot recover an exact physical binding. Let modal skip
input run before Journal toggling and share the same Journal cleanup path.
Visual buttons/native navigation must bypass physical-binding lookup; a synthetic
Tab for Back must not activate a remapped gameplay action.

Full-screen automap processes AutomapBindings before normal Bindings. The engine
M=am_setmark consumes M, so the accepted M=togglemap preset uses unmapbind M.
Do not add a second map-only toggle binding: it would survive normal remapping.

Reproduction: assets/validation_5214/{contract.zs,contract.cfg,flow.cfg,persist.cfg,
restart.cfg,RESULTS.md}. Engine sources: c_bind.cpp (DEFBINDS/reset/unmapbind),
g_game.cpp (slot/automap responder), am_map.cpp (AutomapBindings), menu.cpp
(M_Responder), and events.cpp (SendNetworkEvent). Keyboard injection that works
in GUI menus does not prove gameplay keyboard input; the physical M result is
explicit author evidence, separate from agent-operated mouse/F5 menu checks.

## CA-KP-082 - Modular sprite actors must share render and hub lifecycles

Status/evidence: ENGINE-VERIFIED for composition, native crouch, save/load,
restart and hub travel; CODE-VERIFIED for mirror/portal visibility. #148 / 5.2.13,
2026-10-11. Baseline: 29823b17 plus the face/hair extension; GZDoom 4.14.2/Vulkan.

A full body/face/hair/color product exceeds the native 16-bit sprite-frame index.
Separate visual heads avoid that product, but must follow the body's native
render behavior. SpriteOffset is already in world units: multiply the shared
pose displacement by scale once. Keep view-specific residuals in TEXTURES offsets.
Copy Prev after SetOrigin so teleport interpolation cannot leave the head behind;
copy FloorClip and reproduce P_CheckPlayerSprite's effective crouch scale without
compressing an authored crouch twice. MASTERNOSEE hides the own-view module while
retaining reflected/portal views according to native renderer code.

Equal-depth sprites use SpawnOrder, reversed by compat_spritesort. The Caelum
MAPINFO AddDefaultMap override forces the normal order without changing the
global CVar. Native captures and effective flags confirm that global true does
not clip the head behind shoulders; the override persists after loading and
hub travel. Finally, a restored hub can rebind an old module's Master to the
travelling pawn. Destroy any module that is no longer body.AppearanceHead.
The failing details-travel-01 and passing details-travel-02 retain this regression.

Reproduction/evidence: assets/validation_5213/details.zs, details-world.cfg,
details-poses.cfg, details-travel.cfg and RESULTS.md. Source references:
g4.14.2 p_user.cpp (P_CheckPlayerSprite), hw_sprites.cpp (Process/visibility),
hw_drawlist.cpp (CompareSprites), g_mapinfo.cpp (MITYPE_COMPATFLAG), g_level.cpp
(GetCompatibility). No physical mirror capture or GPU benchmark is claimed.
Author visual acceptance remains CA148-01.

Follow-up #209 / 5.2.18, 2026-10-12: ENGINE-VERIFIED baseline chair rest leaves
the head at WorldOffset zero while the body moves 16 units. Copy WorldOffset
along with Prev/FloorClip; old and current saved rests pass the same correction
and restore OriginalWorldOffset on exit. Ground body and neck together before
export: body pixels below the floor pivot can trigger player-only native sprite
clipping and separate a generic head module. Do not invert SpriteOffset.Y;
native GetSpriteOffset already converts its screen-down sign. This evidence
does not establish correctness for every gl_spriteclip mode or low ceiling.
Evidence: assets/validation_5218/fixture.zs and RESULTS.md. CA209-01 passed
author visual acceptance on 2026-10-12 without qualifications.

## CA-KP-081 - Validate contact work through native movement and lazy state initialization

Status/evidence: ENGINE-VERIFIED, #194 / 5.2.11, 2026-10-11.
Baseline: e9af2707; GZDoom 4.14.2 / Windows 11. Scope: collision contacts,
crushing pressure inventories and the isolated validation_5211 fixtures.

Calling a solver on a stationary actor verifies arithmetic, not native landing
detection or passive callbacks. Keep production Tick in motion fixtures, use
the native CANPASS flag for body-top support, and test real FastProjectile and
composite-proxy sweeps. Frozen test receivers remain useful for isolated formulas.

GiveInventoryType can return a new pressure inventory before its deferred
PostBeginPlay. Initializing its pulse guard there overwrote the first recorded
native crushing tick, causing a second first-pulse calculation. Initialize the
guard lazily where work is recorded, with a saved bool. Verify same-tic duplicate
callbacks inside DamageMobj; calling again on the next WorldTick tests another
tic and is not a duplicate. Native motion/pressure/save-load results and corrected
failed attempts are retained in assets/validation_5211/RESULTS.md. These tests
are agent evidence; CA194-01 remains pending author acceptance.

Follow-up #339 / 5.4.39, 2026-10-18: ENGINE-VERIFIED voluntary jump origin.
Native CheckJump updates jumpTics/Vel.Z before onground changes on the next
movement pass. Record only the confirmed terrestrial takeoff, then clear after
physics using physical support, not the stale onground flag alone. A held key
or positive velocity cannot distinguish a voluntary jump from a push. Serialize
origin with a conservative idempotent migration; never infer it for old saves.
The ascent/descent/native-input/save/travel controls in validation_5439 verify
this rule. Sample the expected capacity before an impact: lethal trauma can
zero its live getter after damage without invalidating the applied mitigation.

Follow-up #312 / 5.5.3, 2026-10-19: ENGINE-VERIFIED pressure interruption.
Destroy nullifies actor references before a contact's saved geometry/work is
necessarily consumed. Do not require the absent peer to close that saved sample;
consume before delivering and skip missing/dead recipients. A parked resident
also needs its static-load interval closed before leaving the active thinker list.
Keep player prediction guards and discard legacy percentage carry before damage.

Native crusher pulse spacing is not attempted movement. The tagged pause fixture
stops a ceiling for two of four tics: the old calculation charged 1 m instead of
0.5 m. Sample local downward steps with a saved unique-tic guard; call the same
sampler at the first callback to handle inventory/ceiling thinker ordering.
Reconcile the current tic if Actor.Tick resumes motion after Inventory.Tick;
retain source interruption until the pulse, even if the body returns immediately.
Panels belonging to the same trap do not interrupt that source.
Preserve blocked attempts and clearly qualify unrecorded pre-migration tics.
Evidence: validation_553; native checks are separate from CA312-01 acceptance.

## CA-KP-080 - Native projectile preparation must precede custom mitigation

Status/evidence: ENGINE-VERIFIED, #192 / 5.2.9, 2026-10-11.
Baseline: 52e3bd01; GZDoom 4.14.2 / Windows 11. Scope: CaelumActorProjectile,
CaelumPlayer, CaelumCombatActor and the soldier shield hook.

Symptom: custom DamageMobj calculates armor/Toughness correctly, but actual HP
loss ignores that remainder. Cause: Super.DamageMobj subsequently invokes the
inflictor's DoSpecialDamage, which can return the original prepared damage and
apply wear/anatomy again. Testing the defense solver alone misses this path.
See CA-KP-010 for the related gate contact-proxy ordering case.

Fix: after rejected/evasive hits, prepare the Caelum projectile once and retain
a transient per-recipient guard across the existing receiver. Each derived
DoSpecialDamage honors the guard. Restore it in the outer wrapper on every
return. Defer NPC anatomy until after its shield; soldier blocking must be a
hook inside this order, with a double remainder. Explosion damage uses its
supplied regional budget, never the direct projectile payload. Preserve their
separate prepared-weapon wear callback and CADEV02 allied-hit rejection. Preserve native
forced/sentinel and invulnerable/dormant rejection paths.

Verification: assets/validation_529/collision.zs executes native flying
collisions on player/NPC, rejects invulnerable/dormant/evasive hits, checks zero
HP loss, physical/critical and explosive callbacks, repeated blast recipients,
guard restoration and actual soldier shield wear/order. native.zs exercises
every bell projectile separately. The source reference is GZDoom g4.14.2
src/playsim/p_interaction.cpp, P_DamageMobj (DoSpecialDamage before
TakeSpecialDamage). Agent evidence does not constitute author acceptance.

## CA-KP-079 - Split dialogue sources without reordering native nodes

Status/evidence: ENGINE-VERIFIED full-path loading and conversations; STATIC
token/order preservation, #185 / 5.2.5, 2026-10-11. Baseline: 0894d41d.

GZDoom 4.14.2 AddDialogues accepts full paths. Its USDF parser also supports
`include = "path";` with a namespace in each included file. However, grouping
previously interleaved conversations by NPC changes the global node order.
Keep the original order authoritative in index.json and assemble runtime.usdf
deterministically when preserving existing native node offsets is required.
Load one entry point only; the root compatibility alias must not be added beside
the main runtime. Parse comments/quoted strings before checking IDs or links.

Evidence: assets/validation_525 checks all 53 IDs, opens nine representative
NPCs in both languages, loads a #183 MAP02 save and compares every dialogue token
and node order. This does not imply author gameplay acceptance.
Engine references: g4.14.2 src/maploader/strifedialogue.cpp (LoadScriptFile) and
src/maploader/usdf.cpp (USDFParser::Parse).

## CA-KP-078 - Crafted utility identity must survive native inventory copies

Status/evidence: ENGINE-VERIFIED, #183 / 5.2.4, 2026-10-11.
Baseline: d313c227; GZDoom 4.14.2 / Windows 11.

An Inventory pointer identifies the current actor, but CreateTossable/CreateCopy
can create another actor during ordinary drop/pickup. A quest that tracks a
crafted bag or water container must transfer that reference in both native hooks,
while retaining water/Box fields. Do not accept any same-class replacement as
the crafted object. Reject duplicate singleton crafting before consuming inputs.
Equipment's existing copied ItemId solves a different path; it does not protect
raw references to special inventory or consumables automatically.

Evidence: assets/validation_524/journey.zs and its final/reload logs exercise
native toss/pickup, actual hub travel and save/load with the crafted references
and 1.25 L water retained. Agent verification does not imply author acceptance.

## CA-KP-077 - Removing a KEYCONF section can orphan saved key bindings

Status/evidence: ENGINE-VERIFIED, #147 / 5.2.0, 2026-10-11.
Baseline: f7c4a0dd; GZDoom 4.14.2 / Windows 11.

addkeysection loads the mod's Bindings and DoubleBindings INI sections. Native
shutdown archives commands listed by addmenukey into those sections instead of
the general game sections. Removing the entire declaration therefore leaves
old user mappings unread even if all aliases/defaultbinds are unchanged.

For #147, retain an empty declaration with the original INI identifier, remove
its generated heading/spacer in UI before search, and expose ordinary commands
through native menu categories. The declaration imports both legacy sections;
with no registered custom actions, native shutdown writes their assignments to
the general sections and empties the old ones. The next restart reads them
normally. No manual INI rewrite or key reassignment is needed in runtime code.

Evidence: assets/validation_520/bindings-import.txt, bindings-restart.txt and
bindings.json. Eleven customized normal bindings and one double binding remain
active before shutdown and after restart, including gameplay and debug aliases.
Sources: g4.14.2 src/gamedata/keysections.cpp (LoadKeys/DoSaveKeys),
src/gameconfigfile.cpp and src/menu/doommenu.cpp (InitKeySections).

## CA-KP-076 - Protected native player menus need compatible extension points

Status/evidence: ENGINE-VERIFIED, #147 / 5.2.0, 2026-10-11.
Baseline: f7c4a0dd plus #147; GZDoom 4.14.2 / Windows 11.

Replacing protected NewPlayerMenu as a fresh OptionMenu does not reliably
replace its native class. Replacing the old PlayerMenu with a different menu
type produces the native warning "Tried to replace menu ... with a menu of
different type". Use AddOptionMenu to extend NewPlayerMenu and set its compatible
OptionMenu class. The public UI MenuDescriptor.mClass permits a ListMenu redirect
for the legacy entry. Filter conflicting descriptor items before the native
option search indexes them, not only when the setup screen opens.

The final English/Spanish captures show both entries resolving to the same
screen, without the stock class/gender/skin/color selectors or Doom preview.
The fixture checks descriptor entries and native control categories. Evidence:
assets/validation_520/RESULTS.md; compile-01 in its diagnostics retains the
failed replacement warning. Sources: installed gzdoom.pk3 menu definitions and
ZScript declarations, GZDoom g4.14.2 menu parsing. This does not establish
compatibility with unrelated addons that replace the same menus.

## CA-KP-075 - Runtime door placement must wait for PostBeginPlay

Status/evidence: RESOLVED-VERIFIED (agent engine test); author acceptance pending.
First recorded / last checked: 2026-10-10 / 2026-10-10. Issue: #173.
Baseline: 1c620037 plus the #173 working patch; GZDoom 4.14.2 / Windows 11.
Scope: CaelumCityInteriorDoors.Ensure and CaelumHingedDoorLeaf.PlaceAtProgress.

Actor.Spawn returns before the door's deferred PostBeginPlay establishes its
ClosedPosition. Calling PlaceAtProgress immediately after configuring args
moves a fresh door to the still-zero origin. It then saves that wrong origin
when PostBeginPlay runs. The first native test found 640 counted leaves but no
collision at the intended openings; diagnostic positions were (0,0,0).

Configure the spawned leaf's args and let the existing PostBeginPlay initialize
its closed position, angle and blockers. Do not move it through methods that
require those fields first. The corrected check verifies the authored position,
closed collision, Use, hinge completion and passage in both doorway orientations.
See assets/validation_5120 (city-04 reproducer; city-05 passing results). This
lesson concerns the initialization order, not a general ban on runtime Spawn.


Follow-up, #410 /5.8.31 (2026-10-27): immediate furniture placement reproduced
the same deferred-initialization boundary. A fresh wardrobe/cupboard still had
the generic chest's32-MU radius and60-MU height before its first PostBeginPlay.
The acquisition transaction now sets the approved storage tier, calls the
idempotent EnsureStorage and applies documented physical dimensions before
checking placement; it never calls PostBeginPlay manually. Native failed/clear
placement and later save/hub checks are in assets/validation_5831. This preserves
blocked-attempt rollback and the ordinary fixed kitchen installation.

## CA-KP-074 - Native autosave requests are queued before the save is written

Status/evidence: ENGINE-VERIFIED, #164 / 5.1.18, 2026-10-10.
Baseline: 6cae68bd; GZDoom 4.14.2 Windows/Vulkan.

Actor.A_CallSpecial(15) requests the native autosave through DEM_CHECKAUTOSAVE
and DEM_DOAUTOSAVE. It is not a synchronous write. Prepare and serialize the
encounter's party/flags before requesting it, then keep actors inactive through
the established preparation interval. Retain a persisted encounter identity so
loading the checkpoint resumes preparation instead of issuing another save.
Respect native disableautosave/autosavecount and slot rotation; do not invent a
custom protected slot or claim a file exists when native policy disables it.

In the #164 MAP01 run the request occurred at tic 1231, the native file captured
tic 1234 with TrialReleased=false and 67 grace tics remaining, and hostility
began at 1301. Reload retained those values, equipment IDs and wounded resources;
death did not reset the fight. Observe loaded fields through a StaticEventHandler
before simulation, as CA-KP-072 requires. Sources: GZDoom g4.14.2 p_lnspec.cpp,
d_net.cpp and g_game.cpp; evidence assets/validation_5118.

#324 / 5.4.34 follow-up (2026-10-18, ENGINE-VERIFIED, baseline 20857d9c): CHECK and
DO are separate network stages. An ACK immediately after CHECK can mirror its
eligibility, but cannot confirm file writing. DO does not repeat the life check.
ChangeLevel calls WorldUnloaded immediately and can overwrite pending ga_autosave.
Observe the final action in PostUiTick, after delayed commands and simulation;
its subsequent message runs after the native action, even while paused. Record
whether departure interrupted action 10 or followed an already executed write.
Network delivery can lag, so do not reinterpret an already reported completion
as cancellation while waiting for its message. Disk success still needs a real
file/reload check; autosavenum alone cannot detect repeated one-slot saves.

The native arrival Autosaver is created after WorldLoaded and runs on its first
thinker tick. It is not declared as a ZScript type: a typed iterator fails to
compile. Adoption requires one STAT_DEFAULT scan at arrival; this statistic can
include actors. Never turn that exceptional scan into a per-tic census. Preserve
native disableautosave=1 arrival policy and do not suppress a destination save
just because the previous map already wrote a checkpoint. Native/failure logs
and the exact ordering fixtures are in assets/validation_5434 (36 final runs,
138 assertions, successful file reloads). CA324-01 author acceptance is pending.

## CA-KP-073 - Separate front and rear arcs around a billboard actor

Status/evidence: ENGINE-VERIFIED, #163 / 5.1.16 visual follow-up, 2026-10-10.
Baseline: 196a7953; GZDoom 4.14.2 Windows/Vulkan, ordinary perspective views.

A complete rope-loop billboard placed at a victim's origin can draw its rear
arc over the body. Texture transparency alone does not supply the missing depth.
Clip the original art into front and rear fragments without changing its pixel
coordinates, then place their cosmetic WorldOffset on opposite sides of the
body's sprite plane along the local camera yaw. Keep physical origins, collision
and gameplay authority independent of these view-dependent offsets. Preserve
old front references and idempotently add missing rear references on load;
remove both sets on every release path.

Native API source: installed gzdoom.pk3, zscript/actors/actor.zs (WorldOffset);
renderer source: ZDoom/gzdoom tag g4.14.2,
src/rendering/hwrenderer/scene/hw_sprites.cpp, Process applies WorldOffset before
calculating sprite depth. Evidence: assets/validation_5116/visual_followup,
four cardinal views plus separate body/rear-only/combined native captures.
This establishes ordinary-view occlusion, not author visual acceptance.

Follow-up #252 / 5.4.21, 2026-10-15: a translucent floor Seal at the caster's
XY sorted after the body despite a lower Z. hw_drawlist.cpp resolves equal XY
depth using SpawnOrder. A 0.5-unit rearward cosmetic WorldOffset breaks the tie;
do not raise/lower physical ground placement to repair this render ordering.
validation_5421/depth_evidence.json records native presentation/save assertions
and ordinary chase views at four yaw positions and two pitch settings. CA252-01
was accepted by the author. Mirrors, portals and multiplayer cameras were not
verified by these captures.

## CA-KP-072 - Observe loaded input state before the first simulation tick

Status/evidence: ENGINE-VERIFIED, #163 / 5.1.16, 2026-10-10.
Runtime: GZDoom 4.14.2 Windows/Vulkan; native source baseline dc757efe plus #163.

A preparation-reload fixture initially checked the live counter after several
tics, although the engine had released its input. Zero was the correct runtime
cancellation, not a serialization failure: the native save stored 35 tics.
A regular saved EventHandler did not provide the required pre-tick reload
observation. A StaticEventHandler.WorldLoaded observer with IsSaveGame confirmed
35 immediately on load; the ordinary tick then correctly canceled on release.
Use that static observer for load-time assertions, and test subsequent input
handling separately. Do not preserve stale held input merely to satisfy a late
snapshot assertion. Evidence: validation_5116/delivered-prepared-observed.txt
and inputs.zs; the save/package/fixture fingerprints are recorded alongside it.
Author handling acceptance remains separate (CA163-01).

## CA-KP-071 - Never carry map-local damage age into another map

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #165 / 5.1.14, 2026-10-10.
Baseline runtime: 18c1aa90 (5.1.13); GZDoom 4.14.2 Windows/Vulkan.

A traveling pawn kept DamageVFXTic from MAP01 while MAP02 restarted level.time.
The old expression strength*max(0,1-age/18) amplified a negative age instead of
rejecting it. The author's 0.03205 hit strength became alpha 152.55 and obscured
the scene completely. The screenshot alone looked like bad travel geometry;
the save confirmed a valid entry position and expired Fool effect.

Bound the age and strength in one shared evaluator used for both drawing and
new-hit accumulation. Clear transient map-local flash state at actual travel.
An idempotent visual revision repairs older saves; keep gameplay resources intact.
Check future timestamps, overlapping hits, fractional rendering, expiry, cap,
ordinary same-map reload and airborne/grounded hub/non-hub crossings. Do not
remove a paid Tarot effect to hide a screen-feedback bug.

Evidence: validation_5114, before/after native screenshots and 34 passing checks.
The travel fixture seeds paid-effect state and calls native ChangeLevel; it does
not replace author dialogue/input acceptance. Separately, the author accepted
CA165-01 on 2026-10-10 without reported qualifications; HISTORY records the result.

## CA-KP-070 - Release actual custody before an authorized item handoff

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #160 / 5.1.13, 2026-10-10.
Baseline: 6c3a74ea; GZDoom 4.14.2 Windows/Vulkan. Scope: Argento's silver key.

The ordinary pickup guard rejects foreign-owned keys. Calling it before releasing
Argento's key makes a legitimate dialogue handoff fail with the native generic
refusal. Do not weaken the guard or spawn a replacement. RemoveInventory performs
the native unlink; DetachFromOwner is only a virtual notification hook (the base
implementation is empty). Validate the owner before unlinking, then prepare pickup
and attach to the recipient. Failure must restore the same instance to the keeper.

Regression: test the AUTOACTIVATE dialogue action through public CallTryPickup,
not protected TryPickup; check eligibility, false keeper, capacity failure/retry,
identity, unchanged key count, carried weight, native lock access and save/reload.
validation_5113 records six reproduced baseline failures, the rejected hook-only
attempt and 20 passing final checks. No schema migration is necessary. CA160-01
was accepted by the author on 2026-10-10; native invocation remains distinct from a real click.

## CA-KP-069 - Fixed-size products must not overwrite equipment size

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #158 / 5.1.12, 2026-10-10.
Baseline: 18dba350 (runtime equivalent to protected 5.1.11 package); GZDoom 4.14.2.
Scope: crafting size, finite tutorial materials and saved task completion.

The author checkpoint contained the exact XS staff/shield raw inputs while the
menu selected M. Previewing jewelry or ammunition wrote M into the shared choice,
which the next sized recipe inherited. Quota replenishment would hide that defect.
Keep the equipment choice separate from a fixed product's effective display/output
size; only sized task completion may restore its saved size. Legacy fixed task
snapshots must not overwrite a more recent choice. Do not infer that every saved
M is erroneous: preserve it until the player chooses another size.

Regression: preview all five sizes through Seal, amulet and ammunition, then
return to a sized recipe; check actual original-stock reservations/outputs and
unchanged issued counters. Reload an active fixed-size task with a different
current selection, complete it and reload again. validation_5112 records the
12 reproduced baseline failures and 37 final passing native checks. Fixtures
force completion after reservation, not elapsed-duration acceptance. CA158-01
was separately accepted by the author on 2026-10-10.

## CA-KP-068 - Read letter keys from KeyChar in native InputEvent

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #156 / 5.1.11, 2026-10-10.
Baseline: fe5ba743; GZDoom 4.14.2 Windows/Vulkan. Scope: time-skip Q/R.

Native FInputEvent copies ev.data1 to KeyScan and KeyString, but ev.data2 to
KeyChar. On Windows Q is scan 16 / character 113 and R is scan 19 / character
114. Comparing KeyString alone to "q" or "r" therefore misses those letter
presses. Use KeyChar (including uppercase where appropriate); retain scan-code
checks for Enter, arrows, Tab and controllers. UiEvent uses a different mapping.
Do not assume InputEvent.KeyString is the same textual field as UiEvent.KeyString.

The author's craft-tiempo checkpoint had finished its task and selected a past
time. Its Enter warning was valid, independently of broken Q. Physical Tab closed
that baseline panel and logged ca_skip_cancel, confirmed by the author on
2026-10-10. Automated Windows presses delivered no reliable events in this run;
that absence alone was not proof that every panel control was broken.

Regression: native production-dispatch checks with nontextual/empty KeyString
must cover Q/R, completed/pending/active cancellation, progress retention, past
rejection, future execution and key release propagation. See validation_5111 for
21 passing dispatch/state checks, two reload checks, hashes and qualifications.
These in-engine callback tests are not physical-key acceptance. Separately, the
author accepted CA156-01 without reported qualifications on 2026-10-10.
No save schema or balance change is necessary for this UI defect.

## CA-KP-067 - Convert effective gravity once and test native displacement

Status/evidence: ENGINE-VERIFIED, #154 / 5.1.10, 2026-10-09.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, 1280x720, 35 simulation tics/s.
Scope: CaelumPhysicsUnits, CaelumPhysicsWorld, growth migration and ballistic aim.
Baseline: f8addb68 (5.1.9). Implementation: 09f46d33 (curves/migration),
5d3769b2 (SI physics); final tested package/source hashes are in validation_5110.

Level gravity 800 produces 1 MU/tic squared for an ordinary actor, not 800.
At 32 MU/m this is 38.28125 m/s2. Scaling the level value to 205.008979591837
produces 9.81 m/s2 while preserving actor/sector modifiers. Store a per-map
revision and original value; loading or revisiting a hub must not multiply it
again. Keep gravity revisions independent from attribute-growth revisions.
Native old MAP02/MAP03 hub loading and revisits retain one marker and one factor.

Actor integrates position before gravity; FastProjectile does not integrate
gravity itself, so the cannon's manual gravity-before-position path differs by
one discrete step. A continuous low arc alone does not describe both. The launch
solver corrects this difference, retains speed and reapplies dispersion. Native
trigonometry has small rounding errors; normalize the direction before restoring
muzzle speed. Verify actual collisions and launcher controllers, not only formulas.
Unreachable targets keep the existing direct-shot policy, without inventing homing.

ForwardMove is an input multiplier. Verify displacement per tic as well as Vel,
input acceleration and steady speed. At the approved calibration, native forward
travel approaches 4/8 m/s at Agility 0 and 16/32 at 100. Discrete jump apex exceeds
the continuous reference by roughly half one takeoff step; check that bounded
effect rather than forcing a continuous trajectory into native collision.

Resource migration must snapshot old maxima before recalculation. Ordinary gear
changes retain their no-free-heal policy; only a versioned migration preserves
fractions. Test a real old save, a new save reloaded, traveler restoration and an
old visited hub. Migrate cached pending-action costs too, retaining their progress
and charging only when the action completes. Save metadata may require the original package basename: provide
the candidate under that basename in a separate test directory without overwriting
the protected old package. See validation_5110 for commands, hashes and failures
corrected in the fixture (deferred PostBeginPlay, elevator direction, VM preconditions).
Author checks CA154-01/02 were accepted without reported qualifications on
2026-10-10, separately from these engine results; see HISTORY.

## CA-KP-066 - A foreground hand cut can duplicate an existing support hand

Status/evidence: RESOLVED-VERIFIED, #152 / PR #153, 2026-10-09.
Affected baseline: f7bb5c5e; correction 23fda033 remains release 5.1.9.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, 1280x720.
Scope: CaelumShotgunView.Draw and separate hand/weapon TEXTURES registration.

Moving a full pair below the gun while drawing another support-hand cut above
it created two visible left-hand silhouettes. The author rejected the initial
native visual pass and selected the under-gun hand. Clear the extra foreground
overlay for ready/open poses; keep insertion poses foreground and canonical aim
hands separate. Preserve unused old state definitions for serialized overlays.

Regression evidence: validation_519/hands-followup-a records active layers and
fourteen captures, including single/partial reloads and all tiers; the existing
upgraded save loads in hands-followup-save, both exit 0. Inspect the whole native
composite and compare costume with canonical hand sprites, not just each cut in
isolation. The atlas restyle is new artwork, with exact outputs/prompts retained.
CA152-02 accepted by the author on 2026-10-09 without qualifications after correction.

## CA-KP-065 - Inventory linkage does not complete a held-item transition

Status/evidence: ENGINE-VERIFIED, #152 / 5.1.9, 2026-10-09.
Affected path: distinct ammunition creation and already-saved owned actors.

AddInventory assigns ownership but does not run BecomeItem. A newly spawned
ammunition actor can therefore be in the inventory and still render at its old
world position with pickup/collision links active. Use AttachToOwner, which calls
BecomeItem before linking ownership. Do not call GiveInventory recursively from
that ammunition's own TryPickup path. Native counts alone cannot prove removal:
inspect owner, amount, bSpecial, bNoSector/bNoBlockmap and the actual world view.

For existing saves, normalize an owned stack only when its world flags are still
active. BecomeItem preserves quantity and owner and is idempotent; normal held
stacks need no repeated state reset. The author's Prueba save reproduces 1,081
owned but visible shells. The corrected load preserves those and 895 separate
carbine rounds. Capacity/retry checks supplement that old-save proof. See
assets/validation_519/RESULTS.md; CA152-01 accepted by the author on 2026-10-09.

## CA-KP-064 - Inspect atlas seams and source damage before changing offsets

Status/evidence: RESOLVED-VERIFIED for the #137 assets, 5.1.8, 2026-10-09.
Affected path: source atlases and native TEXTURES/model UV registration.

Generated sheets need not form a uniform grid. Equal-row division admitted earth
fragments below the ice and clipped its tip. Use measured transparent/low-alpha
gaps in source data, retain PNG pixels, and inspect complete native frames.
For death art, inspect the original PNG itself: Domingo's missing head and the
rat's neighboring pieces were already baked into old files. An offset change
cannot recover missing pixels. Locate an intact source, or clearly identify a
reconstruction from owned references and retain the damaged originals.

Evidence: elemental_518/DESIGN.json and final gallery-cells-final; initial death
reconstructions in deathframes-before/after. Later recovered source bindings are
in deathframes-original-final, death_repair_518 and animal_recovery_518. Native
subtextures separate Domingo's overlapping corpse outlines without editing PNG
pixels; the rat's original RGB is retained with author-approved mask recovery.
Generators check opaque margins and retain native state timing. Technical frame
integrity does not constitute author aesthetic acceptance.

Inspect alpha as well as RGB: a preview may expose hidden neighbor art or labels
whose alpha is zero. Composite onto a contrasting background and verify in-engine
before calling that a rendering defect. The 166-image rat/bull audit found real
rat silhouette border cuts but no visible neighbor fragments or bull clipping.
For opaque-sheet recovery, preserve valid old alpha as foreground/background
seeds: a rectangle-only segmentation can fill tail holes or remove dark fur.

2026-10-14, #238 / 5.4.4, ENGINE-VERIFIED component follow-up: equal-height male
hand rows included the preceding wrist strip inside the palm cells. Fitting that
combined alpha box also shrank the actual palm. Cast-only outputs now use measured
last-row bounds from the intact owned atlases; accepted weapon modules remain
unchanged. Sources, exact bounds, deterministic outputs and native captures are
recorded in [validation_544](../assets/validation_544/RESULTS.md). The full class
ability and author animation acceptance remain pending.

## CA-KP-063 - Emit cosmetic impacts on native Death entry

Status/evidence: RESOLVED-VERIFIED, #137 / 5.1.8, 2026-10-09.
Affected path: Actor projectile Tick and short native Death states.

Super.Tick can finish a one-tic Death state and destroy its actor. Updating
cosmetics afterward without checking bDestroyed can create effects from an
already removed owner; adding the necessary guard then exposes the missing
impact. Emit once from the native Death action, before destruction, and retain
the idempotent impact flag. Keep state indices/timing intact and avoid generating
an impact on range expiry. Named attached lights follow their owning actor.

Native evidence: checks-final-e in assets/validation_518 verifies both forced
missile impact and an actual wall collision, one effect per impact, bounded
expiry and owner-death cleanup. Earlier checks-final-a is rejected; its three
failures included this issue plus a captive-prisoner fixture and distant LOD
case. The final freed-prisoner test uses the actual rescue/attack path.

## CA-KP-062 - Native model pitch rotates the forward X axis

Status/evidence: RESOLVED-VERIFIED, #137 / 5.1.8, 2026-10-09.
Affected renderer: GZDoom 4.14.2 OBJ models with PitchFromMomentum/UseActorPitch.

For these native model transforms, author the flight axis along OBJ +X and
height along Y. A mesh using +Z as forward can look plausible from one angle
but rotates incorrectly during pitch. This was visible in the rejected early
arrow/javelin views and the breath planes. Convert mesh axes once; do not change
the actor velocity or ballistic physics to correct a rendering convention.

Evidence: generate_projectile_models.py/generate_breath_models.py, native
showcase-after-final side views and rising/falling javelin captures. The 623
baseline/current gameplay traces in validation_518 match exactly. Retain native
frame registrations for dynamically selected sprites (see CA-KP-054), and keep
the model bound to flying frames so impact states retain their own presentation.

## CA-KP-061 - A held activity peak invents heat after a brief action

Status/evidence: RESOLVED-VERIFIED, #136 / 5.1.7 follow-up, 2026-10-08.
Affected baseline: 0dfa718e; GZDoom 4.14.2. Scope: continuous thermal effort.

The old immediate-rise, exponential-decay filter held the greatest recent
activity power, including a short push or swim, for a 120-world-second half-life.
At 1:1 time, one second at 5000 W added 5000 J during effort and could create
approximately 865617 J more afterward. Testing only sustained exercise or the
20:1 exterior clock concealed how strongly this affected brief Limbo actions.
The author's calor-136 checkpoint has a 6393 W peak despite zero input/velocity.
Native replay detects full immersion and water cooling, but excess production
still raises exposure. This does not establish the exact preceding input history.

The final author correction requires effort heat only during actual actions.
Integrate current power with real action seconds, or explicitly supplied logical
travel effort; never use the prior activity peak as another source. Stored body
exposure still dissipates through normal exchange. Revision 7 clears the old
peak once and preserves exposure, HP history, moisture and resources. Keep the
original save/runtime pair for rollback; do not silently heal a damaged save.

Validation: assets/validation_517/FOLLOWUP_RESULTS.md. Include one-tic action,
release, no-input reload, 1:1/20:1 clocks, logical travel and paused/personal steps,
plus native movement, stationary firearms and actual water geometry. Log thermal
damage separately from contact damage and disclose any HP support in flux probes.
Historical #130/#140 recovery-tail assertions describe the superseded contract.

The second author checkpoint, with all attributes at 100, separates another
problem: swimming inherited about 140194 W from a 350485 J enhanced jump reference,
even after the lingering peak was removed. The final approved proxies are 6/10
MET total for normal/fast player swimming and 6 MET for blocked pushing, minus
the 1 MET resting term and scaled by body area. Do not reinstate enhanced jump
energy in these profiles. Other measured locomotion/jumps and discrete action
rules remain unchanged. Normal/high-stat native controls are recorded separately.

Final #136 energy correction: the author then removes the remaining amplified
jump/Air anchors from all runtime physical attacks and blocking. Work is now
explicit data per action/distance, with a human half-metre jump and Q=3W at 25%
efficiency. Fixed firearm cycles pay once/per completed reload progress, never
once per animation tic plus a second event. Swimming converts 75% of the former
net MET power to heat; isometric work retains its separately approved metabolic
rate. Native speed controls must compare both energy per action and action count:
a faster character can still produce more total heat by acting more often.
Do not infer new energy from remaining Air or accumulated ActionJoules. Preserve
already measured pending work across reload migration and do not retroactively
charge the completed fraction. Earlier fixtures for the old velocity/Air or
continuous-firearm contracts remain historical evidence. Current tests:
assets/validation_517/ENERGY_RESULTS.md.

## CA-KP-060 - A distinct Ammo subclass can still merge into its parent

Status/evidence: RESOLVED-VERIFIED, #136 / 5.1.7, 2026-10-08.
Affected baseline: abd4f578 plus the initial shotgun prototype; GZDoom 4.14.2.

Different class names and icons do not guarantee independent native ammunition.
The first CaelumShotgunAmmo subclass of CaelumCarbineAmmo inherited native Ammo
grouping: a shell pickup could increase the bullet stack. Direct AttachToOwner
tests had concealed this because they skipped the real pickup path.

Shotgun TryPickup now uses the same authoritative distinct-stack acquisition
already used by javelins, and its HandlePickup refuses other concrete classes.
The old javelin entry point remains an adapter to that shared service. Reject
zero quantities and already-owned objects; preserve the normal carry check.
Test CallTryPickup in both directions with existing shell and bullet stacks,
then check quantities and classes independently. Final native checks in
assets/validation_517 cover both directions and actual MAP02 death supplies.
This is a targeted Ammo rule, not permission to replace ordinary Inventory
stacking. Author appearance acceptance remains separate.

Follow-up evidence: #313 / 5.5.4, 2026-10-19, validation_554. Changing an ammo
subclass's virtual GetUnitWeight is insufficient: first-stack admission also
uses the shared ammunition-type weight lookup. Keep both bound to the same
authoritative constant. Native capacity/Box/drop tests cover new and existing
stacks. Reload changes the magazine count, not the stack; do not count loaded
rounds twice. The fixture must select the ammunition row and clear any prior
equipment ItemId, as ApplyFormalInventorySelection does, before reading its mass.

## CA-KP-059 - Check sprite rotation order for every animation family

Status/evidence: RESOLVED-VERIFIED, #135 / 5.1.5, 2026-10-08.
Affected baseline: 5f9202ad; GZDoom 4.14.2 Windows/Vulkan.
Scope: Zupay ZUPY D/E/F/M..R native TEXTURES registrations.

The author reported an inverted ground slam. Idle and locomotion directions
were correct, but action PNGs numbered 3 faced right and 7 faced left, opposite
to the idle family. A passing idle-only orbit did not cover the attack poses.
Registration now assigns 2/3/4/6/7/8 to source 8/7/6/4/3/2, retaining front/back
and all original PNGs. Do not globally reverse the actor or unrelated poses.
The deterministic generator derives each assignment from the native sprite
name, so rerunning it cannot swap corrected views back.

Evidence: validation_515/orientation-fixed-a (24 native fixed-angle captures,
three groups of four poses), ART_DETERMINISM.json and the source mapping in
art_source/demon_breath_515/ZUPAY_DIRECTIONS.json. For registration inspection,
freeze the fixture's native actor Tick; merely setting tics=-1 can still allow
resource/AI helpers to select another state. Gameplay attacks retain their
original state timing and angle. Author visual acceptance remains pending.

## CA-KP-058 - Actor destruction must not resume gameplay states

Status/evidence: RESOLVED-VERIFIED, #135 / 5.1.5, GZDoom 4.14.2 Windows 11.
First recorded / last checked: 2026-10-08 / 2026-10-08.
Affected baseline: working demon breath cleanup after 5f9202ad.

The author supplied the crash report from integration-b. Gameplay assertions
passed, then engine shutdown raised C0000005 while reading address 0x10c.
Official matching PDB symbols resolve ClearLevelData -> DestroyAllThinkers ->
SetState -> A_Look -> P_LookForPlayers -> isTargetablePlayer. OnDestroy called
the normal breath-stop helper, which restored Spawn and executed its immediate
look action after player teardown. Destructor cleanup now only detaches and
destroys owned flame/visual objects; it does not resume AI or integrate heat.
Ordinary live interruption/death still settles paid radiation normally.

Evidence: validation_515/CRASH_ANALYSIS.json, integration-art-a and
ability-reload-art-a, both explicit exit code 0, followed by ability-hub-art-a.
The original integration-b and ability-reload-a are rejected as clean runs.
Regression: quit while breath remains active, save/reload that state, change
maps and return. Require clean process exit as well as script assertions.
The runner retains its process handle (Get-Process alone lost ExitCode),
detects native crash dialogs and rejects nonzero exits. A passing log marker
does not override a native crash. Raw minidumps remain local.
Limitations: this diagnoses the supplied shutdown fault, not every engine crash.
Author acceptance of the full patch remains pending.

## CA-KP-057 - Native Powerup expiry can precede the tenth recovery pulse

Status/evidence: RESOLVED-VERIFIED for new potion doses in #135.
First recorded / last checked: 2026-10-08 / 2026-10-08.
Affected baseline: 5f9202ad plus the working 5.1.5 consumable changes.
Environment: Windows 11, GZDoom 4.14.2, isolated native room, real 35-Hz tics.
Scope: CaelumRegenerationPower and all three potion families and sizes.

A 350-tic Powerup and a pulse every 35 owner DoEffect calls delivered only nine
pulses: the engine decrements the power's lifetime and destroys it before the
last owner callback. The three Anima totals were 108.9/245.025/544.5 instead of
121/272.25/605 for a 1210-point bar. This is native ordering, not a dose-table
or floating-point error. New potion metadata records delivered pulses;
natural expiry completes a missing tenth only after nine were delivered.
Early destruction, death and manual refresh do not receive an expiry bonus.
Health keeps a fractional accumulator and loses less than one indivisible HP.
Older saved effects with zero metadata keep their previous behavior.

Evidence: assets/validation_515/potions-save-b.txt (27 passing assertions) and
potions-reload-c.txt (28, including partial-dose/current-save preservation).
The original failing c trial remains local; it is not counted as a pass.
Regression: use each size with empty Anima, observe no instant grant, let ten
real seconds elapse, compare total restoration and repeat across save/load.
Final dose evidence: potions-final-a (37 assertions), potions-reload-final-a
(38, all nine doses and player Air/Sleep), plus consumption-b for early cancel
and finite exhaustion. Author acceptance: pending for the whole issue.

## CA-KP-056 - Cache thermal coefficients, keep flux and physiology live

Status/evidence: ENGINE-VERIFIED. First checked: 2026-10-08.
Issue #140 / 5.1.4; GZDoom 4.14.2. Original CA140-01/02 accepted 2026-10-08;
later firearm/shivering calibration is separately tested.

Cache geometry, dry material/film conductance and anatomical row weights per
actor. Key dependencies explicitly: area/mass, anatomy generation, coverage,
immersion, material, wind and ambient vapor. Exposure, wetness, environmental
temperature, water temperature, fire and effort must still change the current
flux. Do not put primary exposure/water in a disposable cache. Native save/load
discards that cache and rebuilds it without refilling NPC hydration; forecast
copies own separate caches. Preserve an original save/package pair for rollback.

The frozen 5.1.3 oracle agrees across 4,480 intervals and 200 dose comparisons;
disable newly approved respiratory exchange and shivering in the old-model
equivalence comparison, then test each independently with its energy equation.
Dry-solver microtiming (five alternating-order repetitions, 4,000 steps each)
reduces the median from 25.982 ms to 9.225 ms, with one geometry build and 3,999
cache hits. This measures isolated math, not total simulation or presented FPS.
The author deferred mass-load testing; do not generalize this percentage to a
siege. Evidence: [mechanics](../assets/validation_514/mechanics-d.txt),
[migration](../assets/validation_514/migration-upgrade-a.txt),
[hub return](../assets/validation_514/migration-hub-c.txt) and
[results](../assets/validation_514/RESULTS.md).

Use a dedicated native sound channel and transient bookkeeping for panting.
Do not restart the looping recording every Tick or serialize a stale playing
flag. Native audio controls verify four gender/intensity cues, independent
pain voice, recovery/death stop and reload reconstruction; actual 3D water
also stops the sound and respiratory bonus. Perceived mix remains an author
check (CA140-01 accepted for the original scope). An authoritative physiology state can support animal ventilation without
mislabeling a human recording as an animal sound.

### Wet-clothing controls and cold regulation follow-up

Evidence: ENGINE-VERIFIED, #140 / 5.1.4. A heavy-armored 100-kg player died from
cold after one real second in 22 C native 3D water, without sweat or attacks;
the dry comparator retained full HP for 180 seconds. The cloth layer held
421.197 mL, while metal itself is not the moisture reservoir. Reducing the sweat
ceiling alone cannot fix this immersion case. Evaporation continues after
secretion stops and does not replenish the character's Thirst.

The approved 1-to-5-MET shivering response and proportional player food cost
kept the clean repeated wet control at 1780 HP, with minimum E -6.506146 against
threshold -10.180198; native wetness eventually reached zero. Keep this bounded
temperate result separate from cold-water immunity or universal exertion safety.
A 50%-Air-paced greatsword control survived but still accumulated 66 thermal HP
before ordinary regeneration restored full health: final HP alone hides damage.
Do not label such a run "no thermal damage". Preserve initial/final reserve,
energy, moisture and cumulative damage records. Uncommanded input contaminated
pool-wet-b; it was stopped and repeated with isolated unbound test controls.

Follow-up #314 / 5.5.6, 2026-10-19 (ENGINE-VERIFIED): when a thermal
contact transition closes the preceding interval, its coefficients must use
the previous support. Then resample the current support without integrating
again. Otherwise an exiting NPC can expose stale ground contact until its
next staggered update even though the next energy interval is correct. The
native enter/exit fixture reproduced this projection delay; the corrected
fixture verifies immediate clearing and repeated-callback nonduplication.
Evidence: `assets/validation_556/RESULTS.md`; CA314-01 accepted 2026-10-19.

## CA-KP-055 - Sweat must share both the water budget and the thermal solver

Status/evidence: ENGINE-VERIFIED. First checked: 2026-10-08.
Issue #133 / 5.1.3; GZDoom 4.14.2. Author gameplay acceptance pending.

Charge secreted water, not only evaporated water. Add retained sweat to the
existing clothing/base-layer moisture balance and remove latent heat only where
that balance actually evaporates water. Immersion/runoff cost hydration without
evaporative cooling. Do not apply the former abstract heat-related Thirst
multiplier on top of the same sweat loss. Hydration limits production, whereas
humidity/permeability/wind limit evaporation; these are different constraints.

An independent thermal journey pass cannot assume unlimited cooling while a
separate provisions pass omits its water cost. Couple the numerical copies and
retain the player reserve as the sole live authority. Native control sweat-final
checks conservation, weather/clothing effects, migration, isolated forecasts and
water-free Air recovery. Its one-hour walking forecast uses about 244 mL of sweat
and one more water ration than the previous provisions-only model. This is a
specific sampled route, not a universal hourly consumption rate.

Persist new NPC reserves with an idempotent revision gate; never initialize a
player's existing Thirst from the NPC default. Native original-save upgrade,
reload and original-package/original-save rollback pass. For load-time evidence,
use a StaticEventHandler and inspect before the first restored actor Tick;
ordinary EventHandler WorldLoaded did not provide that callback in this probe.

Evidence: [native checks](../assets/validation_513/sweat-final.txt),
[upgrade](../assets/validation_513/sweat-upgrade-a.txt),
[reload](../assets/validation_513/sweat-upgrade-reload-a.txt), and
[rollback](../assets/validation_513/sweat-rollback-a.txt).
Preserve per-run package hashes; later thermal/resource controls must not be
presented as byte-identical to these earlier component runs.

## CA-KP-054 - Native city validation: inventory, scripts and sprite registration

Status/evidence: ENGINE-VERIFIED. First checked: 2026-10-08.
Issue #133 / 5.1.3; GZDoom 4.14.2 on Windows/Vulkan. Author acceptance pending.

Seed tradable equipment using the native pickup subclasses, with fixed authored
size and initialized pickup data. A base inventory instance can disappear on its
first Tick; a spawned item still marked DROPPED can preview zero weight. Verify
after ticking, dropping/repicking, trading, saving and reopening the hub, not only
immediately after Spawn. The final commerce probe checks identity, durability,
wetness, stock, cash and atomic capacity rejection.

ZScript identifiers are case-insensitive. A parameter named `goal` shadows the
field `Goal`: use `self.Goal` for serialized navigation targets. A compiled path
finder with an unchanged zero goal can look like a collision defect. Queue costly
path queries fairly: actors with synchronized state phases can repeatedly consume
a naive global per-tic allowance and starve the rest of the roster.

Reverified in #410 / 5.8.3 (ENGINE-VERIFIED, 2026-10-24): `Kind=kind` in the
food-lot initializer compiled but left the persisted food kind at zero. Distinct
`foodKind` fixes the assignment; a regression initializes all nine food kinds,
rejects cross-kind transfers and checks unchanged state after rejected operations.
Evidence: assets/validation_583/lots-report.json and retained lots-core-01 failure.

Reverified in #195 / 5.2.12 (ENGINE-VERIFIED, 2026-10-11): `Charged=charged`
and `Secondary=secondary` assigned the parameters to themselves. Distinct
`useCharged`/`useSecondary` names fixed persisted resident attack choices.
Check the serialized selection and actual damage, not just the preparation
timer; validation_5212 retains the failing and corrected native runs.

Reverified in #481 / 5.7.7 (ENGINE-VERIFIED, 2026-10-22): a local `distance`
shadowed the target cache's `Distance`, breaking near-line range and occlusion
comparison while compiling successfully. `candidateDistance` fixes the field
update; native regression checks assert both the exact distance and an actor
occluding a crossable transition. Evidence: assets/validation_577/RESULTS.md.

Reverified in #311 / 5.5.2 (ENGINE-VERIFIED, 2026-10-18):
`Initialize(double releaseDistance)` assigned `ReleaseDistance` to the parameter,
leaving the serialized field zero. Native pairs expired after five updates even
with fresh callbacks: geometric separation and callback expiry are independent.
Use `self.ReleaseDistance` and test the stored field, a sustained native contact,
separation/recontact and old saves. Local revision-1 repair preserves the shared
edge and pending work, without replaying damage. Evidence: validation_552;
author acceptance remains separate. Compilation alone cannot detect this error.

Street routes need a floor-height constraint as well as XY reachability; an
otherwise valid local shortcut can climb an artillery stair and strand a guard
above a ground post. Use native floor/step/dropoff checks. Formation entry also
needs temporary access through already occupied front rows, held until the
arriving crew has entered its actual stair route. Test the whole fresh roster;
recovering a collection of saved blockers does not establish a fresh-run pass.

GZDoom exec lines have a bounded parser buffer. A long wait/action chain can be
split, making its tail execute immediately. Keep lines short and chain the next
file with `exec` at the delayed tail; separate physical lines do not preserve the
wait. Check unknown-command diagnostics and the capture order. Hold each pose
after its screenshot command so deferred rendering cannot capture the next
pose under the previous filename; also wait before the final quit.

Native player `PlayAttacking` can replace the world sprite after player Tick.
Apply the held-weapon projection there as well, while choosing the firing frame
from the real successful-shot interval and reload frames from the real reload.
For generated atlases, measure transparent row/column gaps instead of assuming
perfectly uniform cells; TEXTURES can clip the unchanged PNG and anchor each pose
at its measured feet. Keep physical keyboard/visual author acceptance distinct
from native command and network-event probes.

Positive measured control: the occupied new city with 600 housed soldiers runs
at 35.01 tics/s and 59.96 render callbacks/s; the matched legacy staged army gives
34.99/57.82 versus 27.16/1.69 for the full army. The later combined new-city battle
falls to 32.25/14.07. These are engine callbacks, not displayed FPS. Do not average
the pre-sweating firearm control after its soldiers die: the inherited action-heat profile
kills all 600 after fourteen shots each. Native saved thermal state confirms the
cause; the active-fire and post-death phases are separated in PERFORMANCE.json.

Evidence: [commerce log](../assets/validation_513/delivery-trade.txt),
[hub reopen](../assets/validation_513/delivery-trade-hub.txt),
[fresh 600-body route](../assets/validation_513/route-delivery.txt),
[saved final roster](../assets/validation_513/ROUTE_FINAL.json),
[sprite registration](../assets/generators/register_carbine_world.py), and
[validation fixtures](../assets/validation_513/).

## CA-KP-053 - Staging reduces workload; control presentation and natural attrition

Status/evidence: ENGINE-VERIFIED. First checked: 2026-10-07.
Issue #132 / 5.1.2; Windows/GZDoom 4.14.2/Vulkan, 1280x720, RTX 3070 Ti.
Author acceptance: CA132-01 passed on 2026-10-07. This accepts the experiment;
the measurements do not establish permanent balance or full-battle stability.

Positive result: in a short same-camera foreground control, about 2,000 living
Mandingas give 53.11 displayed FPS and 34.84 tics/s, versus 1.94 FPS and 32.58
tics/s with about 6,000. Natural staged arrival also restores near-native tic
throughput. Attribute this to fewer simultaneous native attackers, retaining
collision, resources, combat and the accepted 500-map-combatant optimizations.
It does not establish a per-actor efficiency gain or stable full-battle 35/30.

PresentMon display intervals and engine render callbacks are different evidence.
One background arrival draws 56.58 callbacks/s but presents only 22.43 FPS.
An occluded game and competing desktop activity change compositor presentation;
use a reserved foreground control and keep background/full-route qualifications.
Check pinned PresentMon CSV units: --qpc_time_ms leaves TimeInSeconds as a header
although that field contains relative milliseconds in the default hybrid output.
Verify absolute clock origin and consecutive display intervals before phase joins.
Do not interpret NA display rows as frames or average instantaneous FPS reciprocals.

Retaining corpses is consequential: after 6,000 total spawns, a late captured
window falls to 29.18 tics/s and 2.20 displayed FPS with thousands of corpses.
It includes a labelled save and cannot isolate corpse cost from remaining combat,
target searches or rendering. Sampled late actor Tick/target work remains large;
do not infer that dead bodies are free or remove them to manufacture a result.

Natural physiology also changes the experiment. The baseline's 5,946 cold deaths
among 5,961 post-checkpoint deaths occur before the first forced diagnostic death.
Record cause and living/corpse populations; a later empty battlefield is not a
successful AI optimization. Recheck after #135 self-warming and #133 geometry.

Native bench samples are deferred. Bound a run's actual output by the next run's
starting byte offset, not by the number of requested commands: a final sample can
remain incomplete at quit. Otherwise a later run's first sample is misattributed.
Evidence and reproduction: [RESULTS](../assets/validation_512/RESULTS.md),
[tables](../assets/validation_512/MEASUREMENTS.md), and their raw logs/traces.

## CA-KP-052 - Reject blocked reinforcements without consuming either counter

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED. First checked: 2026-10-07.
Issue #132 / 5.1.2; native GZDoom 4.14.2 on Windows/Vulkan.

A non-null native `Spawn` result does not prove that a monster fits. Test the
actual initialized body's collision/vertical placement before registering it.
When rejecting it, use `ClearCounters()` before `Destroy()`, as the installed
engine's `zscript/actors/attacks.zs` does for blocked monster spawns. Otherwise
an unsuccessful placement can still inflate the native total-monster statistic,
even when the encounter's own successful-spawn counter correctly stays unchanged.
The engine declaration is in `gzdoom.pk3:zscript/actors/actor.zs`.

Keep partial group identity independently of the count of bodies already placed:
a saved slot bitmap and deadline let 50 placed/50 blocked members resume without
repeating the first half. Native checks verify no budget/native-counter increment
for 100 blocked positions, exactly 50 increments after half clear, completion,
99 versus 100 vacancies, no banked burst and terminal cancellation. Actual save
comparisons retain the bitmap, cursor, deadline and original 6,001-entry old army.
The 74 machine operators belong inside the first 100; counting them separately
would break both the total budget and initial cap.

Evidence: [native checks](../assets/validation_512/final-boundaries.txt),
[loaded check](../assets/validation_512/final-pending-reload.txt), and
[save comparison](../assets/validation_512/SAVE_VERIFICATION.json).
This lesson establishes lifecycle correctness, not a frame-rate claim.

## CA-KP-051 - Match native virtual-coordinate projection for HUD fills

Status/evidence: RESOLVED-VERIFIED / ENGINE-VERIFIED. First checked: 2026-10-07.
Issue #131 / 5.1.1; Windows/GZDoom 4.14.2/Vulkan.
Scope: resource and thermal bars in CaelumHUDOverlay.

The old Screen.Dim fills manually centered a uniformly scaled 640x360 canvas,
while the frame/text used DTA_KEEPRATIO with virtual coordinates. At 16:9 they
coincided, hiding the mismatch; actual 1024x768 and 1680x720 captures showed
fills outside the frames. Use the same native Screen.VirtualToRealCoords
projection with handleaspect=false for these DTA_KEEPRATIO draw calls. The
shared ResourceRect now aligns every affected fill without changing resource
values or redesigning the HUD. Multivalue native returns must be unpacked
before forwarding them from a ZScript helper.

Reproduce with validation_511/run_check.ps1, visual.pk3 and the recorded
icon-visual-43 / icon-visual-wide command scripts and configurations.
Inspect actual PNG dimensions, not only -width/-height: on Windows the saved
win_w/win_h can determine the client size instead. Final native captures verify
1024x768, 1280x720 and 1680x720; screenblocks 10/11/12 and hud_scale 0/2/3 retain
the existing resource-overlay policy. Earlier captures remain explicitly
superseded evidence. [Results](../assets/validation_511/RESULTS.json).
Author visual acceptance remains pending (CA131-01); this does not establish
support for every arbitrary viewport or a new HUD visibility policy.

## CA-KP-050 - Adding serialized classes needs an explicit old-runtime bridge

Status/evidence: ENGINE-VERIFIED. First recorded / checked: 2026-10-07.
Issue #130 / 5.1.0; baseline `45f1637`, Windows/GZDoom 4.14.2.
Scope: thermal state, equipment moisture and GZDoom save restoration.

Adding a nullable versioned state is forward-migratable, but plain 5.0.6 cannot
deserialize a later `CaelumThermalState` instance. A tested rollback package
retains the new fields/classes as inert schema in the accepted old gameplay.
It preserves E, acclimatization, activity, water and fractional damage exactly;
derived sampling caches are invalidated before returning to the new runtime.
Original saves remain untouched. Map addons must keep their recorded basename,
even when replacing their implementation during a migration test.

Reproduce with `assets/validation_510/prepare_rollback.py` and the save harness;
the baseline/current/hub/rollback/re-upgrade chain and all prior record fields
are checked in [5.1.0 evidence](../assets/validation_510/RESULTS.json).
The bridge is specific to this schema/baseline, not a universal downgrade tool.
Author acceptance: CA130-03 passed on 2026-10-07, without reported exceptions.
No save or development IWAD is distributed.

Follow-up #238 / 5.4.4, checked 2026-10-15: the same approach retains paid
preparation, racial objects and Sleep hit/power/pose state in a pinned 5.4.3
bridge. Preserve appended actor/weapon state indices as well as class/field
declarations. Old gameplay leaves new controller fields inert while its existing
Sleep/cooldown timers continue; re-upgrade resumes the retained paid ledger.
The native round trip passes 59 assertions in seven runs. This is specific to
the shared #238 schema, excluding later concrete powers. Evidence and commands:
[paid-state bridge](../assets/validation_544/RESULTS.md). Load-time console scripts
must wait for loading and save completion; verify the saved artifact before
launching the next stage, not merely a successful assertion marker.

## CA-KP-049 - A filtered global iterator per NPC can still become quadratic

Status/evidence: RESOLVED-VERIFIED. First recorded / checked: 2026-10-07.
Issue #130 / 5.1.0; dirty implementation over `45f1637`, exact per-run package
hashes in [5.1.0 evidence](../assets/validation_510/RESULTS.json).
Environment: Windows/GZDoom 4.14.2/Vulkan, full normal MAP06 army, 5% audio,
background unpaused. Scope: `CaelumThermalWorld` and shelter/body sampling.

The initial per-body roof query constructed a filtered `ThinkerIterator` for
vehicle ranches. The native search still walked the global thinker population;
doing this for thousands of bodies reduced tics 105â€“700 to 9.05 tics/s.
Caching the small source/ranch lists once per real second restored 28.07.
Reusing the NPC's due time before climate/attribute lookups, caching mass/area,
and removing repeated health recomputation restored 32.76 in that intermediate
build. Matched intermediate logs retain identical exposure aggregates and
populations: this saving did not exempt offscreen actors or drop elapsed time.
Final arrival samples reach 33.62â€“34.15, versus 34.48â€“34.95 in the accepted
baseline; later motion/load corrections slightly change final heat aggregates.

Regression check: deterministic full-roster performance fixture plus the seeded
extreme-cold stress variant. Measure elapsed simulation time, roster, supported
body count and aggregate state, not only a faster isolated helper. These short
arrival samples do not establish late-battle FPS. CA130-03 was author-accepted
on 2026-10-07 without reported exceptions;
the performance limitation is reported rather than described as a speedup.

## CA-KP-048 - Preserve native visibility RNG when pruning cannon candidates

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED; normal-game implementation.
First recorded / last checked: 2026-10-07. Issue #128 / 5.0.6.
Environment: GZDoom 4.14.2, Windows 11/Vulkan, full normal MAP06 combat.

Once a cannon has a target, a farther candidate of the same priority, or a
non-crew candidate behind a crew target, cannot win. Rejecting such candidates
before native sight saves work while preserving priority and strict-distance
ties. This shortcut is gated by the automatic 500-combatant mode.

Native `P_CheckSight` consumes its `CheckSight` random stream for some invisible
targets. The production shortcut therefore applies only to normal render
style, positive alpha and neither invisibility flag. Other candidates retain
the native call even when they cannot win. The isolated 96-case comparison
matches both target identities and the next native sight RNG value exactly,
covering crew changes, deaths, occlusion, invisibility and transparency.
Separate matched 700-tic counters retain the same 33 cannon queries while
reducing native cannon sight calls from 143,979 to 578. This subsystem saving
does not imply a proportional frame-rate increase.
The full-battle oracle separately compares every target-query result against
the original search; its extra work excludes it from speed measurements.
Reproduce with `cannon_study.zs`, `prepare_checks.py` and the #128 runners.
Evidence: [native verification](../assets/validation_506/NATIVE_VERIFICATION.json),
[source boundary](../assets/validation_506/SOURCE_VERIFICATION.json) and raw logs.

## CA-KP-047 - Less duplicated work does not guarantee better frame tails

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED; comparative native experiment.
First recorded / last checked: 2026-10-07. Issue #128 / 5.0.6.

Reusing candidate lists removes repeated eligibility enumeration. A separate
eight-tic background group schedule distributes perception phases but also
queries groups without an active member request. In two normal-combat runs,
the staggered variant's congestion p95 callback gap is 341â€“413 ms versus
267â€“268 ms for shared perception on demand. Late throughput differs by about
one percent; this does not justify shipping the worse congestion tail.

Keep the shared decision and candidate cache on demand. Candidate sharing
alone has no resolved independent throughput gain in these repetitions;
report reduced enumeration separately from speed. Exact cannon pruning adds
a modest improvement: congestion callbacks rise from 7.55â€“7.59/s to
8.17â€“8.20/s, with p95 gaps falling from 267â€“268 to 245â€“265 ms in the isolated
pairs. Desktop load is not exclusive and these are callback observations,
not GPU/presentation timings. The 35-tic/30-FPS goal remains unmet.
The shared-candidate counter builds 700 lists versus 6,412; both perform
6,412 leader decisions in that factor comparison. On-demand scheduling uses
6,026 decisions in the same 700-tic window, while both schedules still peak
at 51 decisions in a tic. Initial/re-elected leaders still create bursts.

Reproduce the pinned experimental commit using `prepare.py --baseline` and
the forward/reverse labels in `run_suite.ps1`. Evidence:
[results](../assets/validation_506/RESULTS.json); work counters and selected
final production measurements are retained separately from the oracles.

## CA-KP-046 - Rebuild the population gate on the simulation clock

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED; normal-game implementation.
First recorded / last checked: 2026-10-07. Issue #128 / 5.0.6.

A per-map native-actor census before thinkers detects spawn, death, removal,
revival and shootability changes without depending on camera visibility or
incomplete lifecycle callbacks. Keep the census stable for the tic and use
one shared threshold source. Native checks cover 499/500/501, death/removal,
revival and both threshold directions. Cold load and hub travel produce
500 â†’ 1 â†’ 500 living combatants; the old full-army save upgrades without
redeployment and the untouched original still loads in the old package.

The blockmap fallback must also cover a NOBLOCKMAP guard registered after the
census in the same tic: registration appends that entry immediately. Keep
the original exact 3D predicate and remembered-death history. Dynamic flag
changes otherwise appear at the next census; existing production combatants
do not toggle this flag within a tic. The full guard oracle checks all
eligible entries against the spatial result on every applicable call.

The regular saved EventHandler did not emit `WorldLoaded` during the cold-load
probe. A static lifecycle observer plus subsequent `WorldTick` checks verifies
actual reconstructed state; do not accept a missing observer callback as a
game-state failure. Hub level time also continues across travel, so checks
must be relative to arrival, not assume `level.time == 2` on every map.
Evidence: [native verification](../assets/validation_506/NATIVE_VERIFICATION.json)
and the adjacent final-check/load/travel/upgrade/rollback logs. Separate author
combat acceptance CA128-01 (5.0.6 / #128) passed on 2026-10-07; see HISTORY.

## CA-KP-045 - Native GPU statistics may expose only selected effects

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-07. Issue #121 / 5.0.5.
Environment: GZDoom 4.14.2, Vulkan, RTX 3070 Ti, 1520-by-825 rendering.

The presence of `stat gpu` does not establish a whole-frame GPU timer. In the
tested default siege configuration its listing remains empty. The inspected
Vulkan `PushGroup` call sites are in postprocess rendering; `PPFXAA::Render`
returns before creating a range when `gl_fxaa` is zero. An isolated control
enabling `gl_fxaa 1` produces `fxaa=0.76 ms` and `fxaa=0.75 ms`, establishing
that this effect's timestamp path works on the hardware. It does not measure
world geometry, actor drawing or total GPU cost.

Native `bench`/`stat rendertimes` report CPU-side stages. Vulkan query retrieval
uses `WAIT_BIT`, so the GPU-control run and changed postprocessing stay separate
from performance comparisons. Keep empty/unsupported scope results explicit,
preserve raw captures and never infer zero GPU load from no displayed range.
Evidence: [visual readings](../assets/validation_505/VISUAL_CHECKS.json) and
[pinned engine sources](../assets/validation_505/ENGINE_CAPABILITIES.json).
Whole-scene GPU time remains unmeasured with these available native scopes.

## CA-KP-044 - Combine measured savings and recheck the frame-time tail

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED; isolated diagnostic success.
First recorded / last checked: 2026-10-07. Issue #121 / 5.0.5.
Baseline: `bc086979`, GZDoom 4.14.2, Windows 11/Vulkan, full MAP06 army.

The grouped march makes repeated negative cannon searches expensive.
Caching only failed searches for the existing eight-tic target-update period
raises its repeated whole-window throughput from 13.115â€“13.330 to
32.644â€“32.825 tics/s. Adding spatial guard queries raises it to 34.865â€“34.989.
These comparisons retain the same sampled scene rows; their final movement
success/error observations also match. This is a positive interaction result,
but the shared march still replaces Mandinga combat and cannot preserve rigid
alignment when native collision blocks individual members.

The final march combination yields only 20.243â€“22.818 overlay callbacks/s,
with p95 gaps of 128.496â€“209.216 ms. Normal combat with shared perception,
spatial guards and cannon retry improves late simulation from 3.057 to
23.686â€“25.209 tics/s, yet has 835.627â€“902.145 ms p95 callback gaps. Neither
meets the author's stable-35-tics/s, at-least-30-FPS target. Cannon retry alone
has no resolved benefit in the normal common window. Do not add independent
percentage gains, assume a saved AI query removes per-body collision/Tick cost,
or substitute average simulation rate for frame pacing.

Reproduce the single factors before their combinations using the #121 suite.
[Results](../assets/validation_505/RESULTS.json) retain raw windows and repeated
pairs. A shipping retry policy must explicitly accept up to seven tics of added
acquisition latency; production policy remains unchanged here.

## CA-KP-043 - A spatial broad phase can preserve remembered machine guards

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED; isolated diagnostic success.
First recorded / last checked: 2026-10-07. Issue #121 / 5.0.5.
Baseline: `bc086979`, GZDoom 4.14.2, Windows 11/Vulkan, full MAP06 army.
Scope: `CaelumHostileMachine.ObserveGuards` in SiegeEncounter.

Scanning all 6,001 attacker records for every armed hostile machine costs
roughly 5.5 ms/tic. A `BlockThingsIterator` broad phase at the existing
`GuardRadius`, followed by the original exact 3D `IsNearby` predicate and
encounter check, reduces the sampled common-window scope to 0.116 ms/tic.
Keep `RememberGuard`, prior `LocalGuards`, confirmed-death and boss-retreat
rules; replacing historical membership with only today's neighbors would
change machine neutralization/victory behavior.

The guard-check fixture runs both searches on every applicable call and
reports any eligible full-scan entry omitted by the iterator. It completed
through tic 2205 with 756 periodic machine verification rows and zero missing
guards. The separate timing fixture reaches 10.442 tics/s versus 9.575 with
ordinary instrumentation; sampled scene rows are identical. The oracle itself
retains the expensive scan and must not be used as the optimization timing.

Reproduce via `guard-check-a` and `guards-a` in the #121 suite. Evidence:
[results](../assets/validation_505/RESULTS.json) and adjacent raw logs. This
validates current eligible bodies in this route, not future NOBLOCKMAP enemies,
all possible vertical geometry, serialized guard order or every victory state.
Production remains unchanged; a shipping follow-up needs those boundary checks.

## CA-KP-042 - Share perception only with explicit gameplay semantics

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED; isolated diagnostic success.
First recorded / last checked: 2026-10-07. Issue #121 / 5.0.5.
Baseline: `bc086979`, GZDoom 4.14.2, Windows 11/Vulkan, seed 116, full MAP06 army.

Command groups of 100 already exist, but `CaelumPortSiege.AttackerTarget` still
does repeated per-member enumeration and sight checks. Sharing one leader's
query per tic, while retaining normal placement, individual attacks and native
movement, raises throughput from 9.373â€“9.575 to 30.130â€“30.415 tics/s over
tics 35â€“2100. Target-selection exclusive cost drops to 0.661 ms/tic in shared-a;
the ordinary later target scope reaches 303.683 ms/tic including its sight calls.
This is positive evidence for reducing repeated perception, not a shipping fix:
followers inherit a different position's visibility and nearest target.

The aligned march prototype confirms the interaction risk. Sixty shared plans
reach nominal 35 tics/s early versus 18.610â€“18.919 with 6,000 independent plans.
Across tics 35â€“1715 it is instead 27.2â€“27.3% slower: its changed trajectories
provoke expensive repeated cannon searches. Native movement still runs for each
body, blocked moves break alignment, and the prototype replaces Mandinga attacks.
Neither percentage is an additive causal share of the original battle.

Reproduce with `assets/validation_505/prepare.py` and the matched/formation
scripts through `run_suite.ps1`. [Results](../assets/validation_505/RESULTS.json)
retain repeated pairs, populations, callback tails, formation displacement and
nested scope costs. The author's target is stable 35 tics/s and at least 30 FPS;
the shared-perception runs do not meet it. On 2026-10-07 the author accepts the
diagnostic/prototype stage as close enough for now and authorizes #121 closure.
The recorded metrics and the need for future production work remain unchanged.

## CA-KP-041 - Background rendering alone does not keep simulation running

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-07. Issue #121 / 5.0.5.
Baseline: `bc086979` diagnostic copies; GZDoom 4.14.2, Windows 11/Vulkan.

`vid_activeinbackground=true` enables rendering but leaves the independent
`i_pauseinbackground` setting in force. Tests appeared stalled after losing
focus until that setting was disabled. The native menu calls it "Pause in
background". For unattended measurements use `i_pauseinbackground=false`,
`vid_lowerinbackground=false` and `vid_activeinbackground=true`; preserve audio
with `i_soundinbackground=true`. The #121 runner uses a separate configuration,
echoes all settings from the engine and sets master volume to 0.05.

The final production-package check advanced from tic 245 to 1015 after clicking
the native title-bar minimize button. [Background evidence](../assets/validation_505/BACKGROUND_CHECK.json)
links the exact log rows and configuration. This proves simulation continuation,
not hidden-window presentation FPS. Do not compare a paused/focus-throttled
sample with a foreground sample. Preliminary focus-setting experiments are
excluded from final performance pairs.

Windows sleep is a separate concern. `keep_awake.ps1` holds a bounded,
thread-scoped `SetThreadExecutionState` request and resets it in `finally` when
the release marker arrives. It changes no power-plan values; process exit also
releases the request. API success is recorded. Listing all system power requests
requires administrator privileges on this machine and was unavailable; no
elevation or persistent power-setting change was used. See the final power
record alongside the run evidence for release and unchanged plan verification.
The request was released successfully on 2026-10-07 at 03:49:53 UTC; both plan
identifiers are `381b4222-f694-41f0-9685-ff5bb260df2e` (Balanced).

## CA-KP-040 - A saved active effect may outlive its native hub power

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-06. Issue #119 / 5.0.3.
Baseline: `135ae0f9` (5.0.2); GZDoom 4.14.2, Windows 11/Vulkan.

Native `PowerFlight` carries `INVENTORY.HUBPOWER`. Leaving the mansion for MAP02
removes the native Tarot flight instance even though the character record keeps
the activated Fool and positive effect/cooldown tics. Baseline logs show flight
1 at departure and 0 at arrival; collection, selected/active arrays and timers
otherwise survive. Saving that state also preserves the missing-instance defect.

`CaelumTarotService.RestoreNativeEffect` reconciles the missing native instance
after travel and personal time. It derives permission only from the already-paid
saved active set, checks the requesting pawn and prediction, and never resets
timers or charges Anima. Existing flight is left alone. Expiry remains owned by
the single personal-time clock; rendering never repairs or advances state.

Regression: cross MAP01/MAP02 with active Fool, return within the MAP02/MAP06
hub, load the original defective 5.0.2 save, and verify recovery with the same
remaining timer and no duplicate instance/payment. Keep the original package
and original save for rollback. Evidence: assets/validation_503/RESULTS.json
and the adjacent before/after, reload and original-pair logs. This establishes
the tested native power lifecycle, not arbitrary historical map compatibility.

## CA-KP-039 - Separate menu-transition failures from corrupt saves

Status/evidence: ENGINE-OBSERVED; cause remains HYPOTHESIS, not a production fix.
First recorded / last checked: 2026-10-05. Issue #82 / 4.37.24.
Baseline: 53dc4410 plus #82; GZDoom 4.14.2, Windows 11/Vulkan.

An automated console `load` after starting MAP01 with a dynamic conversation
open aborted while drawing the transition. The author retained the native
report. Matching symbols locate FString::operator=, DMenu::CallDrawer,
M_Drawer and PerformWipe. These frames establish a menu-drawing failure; they
do not by themselves identify its root cause or prove corrupted save data.

The identical sewer82.zds loads through `-loadgame`, reaches the actual port
through its journey planner, and passes all 27 zero-rescue arrival/reload
assertions. Separate two/four-rescue saves and the preserved 4.37.23 character
also load. Keep the original report/save, close conversations before scripted
load tests, and distinguish startup, console and normal Save/Load-menu paths.
Do not discard a save, waive compatibility, or claim an engine fix from one
passing alternative path. The author passed the separate normal-menu/export
check CA-43724-EXPORT-01 on 2026-10-05 without reported exceptions; this does
not establish a fix for the automated console-load transition.

Regression: retain the failing transition context, load the same save from
startup, and check normal-menu save/load before attributing the failure to
serialization. Evidence and limits: assets/validation_43724/RESULTS.json,
sewer_reload.txt and old_save.txt; full crash dump stays local.

## CA-KP-038 - Separate title credits, quit confirmation and text ENDOOM

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-04. Issue #103 / 4.37.21.
Baseline: 2ec2405c plus #103; GZDoom 4.14.2 Windows/Vulkan.

CreditPage belongs to the title loop. The native menu_quit command creates a
MessageBoxMenu with an affirmative callback that plays QuitSound, waits and
calls M_Quit/ST_Endoom. ENDOOM requires exactly 4000 bytes (80x25 character and
attribute pairs); it cannot display a PNG. Source: tag g4.14.2,
src/menu/doommenu.cpp, src/common/startscreen/endoom.cpp and
src/common/menu/messagebox.cpp. GameInfo supports MessageBoxClass and Endoom.

For #103, keep the native callback in a MessageBoxMenu subclass, recognize only
the unique project quit prompt, preserve negative results, and defer the true
callback until after drawing an in-engine farewell. Endoom="" suppresses the
legacy surface independently of the user's showendoom setting. Forward unrelated
message boxes to the base class. Direct quit, quick exit and Windows Alt+F4 can
bypass this UI; changing CreditPage alone cannot implement the exit requirement.

Regression: cancel menu Quit and F10, confirm and inspect farewell, then finish
through keyboard/mouse and verify process closure even with showendoom=1. Check
another native message box. Validate 4:3, wide and ultrawide letterboxing.
Evidence: assets/validation_43721/RESULTS.json; author acceptance remains separate.

The new-game fixture also exposed StartGameDirect's DMenu::InMenu guard: calling
a menu method from ConsoleProcess is not equivalent to native menu input.
Test the real user-input route; do not weaken the guard or change production
code to satisfy a fixture. Native source: doommenu.cpp / StartGameDirect.

## CA-KP-037 - Match Journal mouse coordinates to its drawing projection

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-04. Issue #91 / 4.37.18.
Baseline: 7c1c2390 plus #91 implementation; GZDoom 4.14.2 Windows/Vulkan.

The Journal draws a 640x360 canvas with DTA_KEEPRATIO. In a 1520x825 native
window, calling Screen.VirtualToRealCoords with its default aspect handling
returned origin (210.2, 0) and size (1099.6, 825). A click at real (1363, 150)
became virtual (671.0, 65.5), outside the visible Tarot icon. A center tab could
still work, concealing the mismatch. The native C moon cursor itself was correct.

For these draw calls, pass explicit vbottom=false and handleaspect=false when
inverting the projection. The same Tarot click then enters the correct page;
subsection/list clicks and scrolling were tested through physical UI input.
Keep the native RequireMouse/IsUiProcessor flags conditional on the Journal,
yielding to its modal panels; share keyboard dispatch with GUI key events.
Store those cursor flags on a StaticEventHandler, not the saved Journal
EventHandler: GZDoom serializes its native flags even when custom browser
state is transient. Persisting them can leave a rollback build requesting GUI
input without the corresponding UI dispatcher. The static input adapter and
transient browser avoid serializing either change.

Regression: click both outer main icons as well as a central subsection at
wide and 4:3 resolutions. Check Escape/Tab and returning keyboard focus, not
only coordinate arithmetic or a static cursor screenshot. Evidence and the
tested package hash: assets/validation_43718/RESULTS.json. Author acceptance
CA-43718-UI-01 passed on 2026-10-04. This projection choice applies to these Journal draw flags;
other overlays may intentionally use aspect correction.

Extension (#184 / 5.2.6): shared CaelumMenuPointer keeps press/release and hover
state in UI scope; the static adapter also owns the live time-skip pointer.
Ignore orphan/stale releases and reset capture on panel changes or dragging
onto Journal navigation. Cursor capture alone does not stop an already-held
turn command: clear cmd yaw/pitch/roll before PlayerThink for crafting/time
skip. Native held-input and save/load regression: validation_526/RESULTS.md.

Extension (#189 / 5.2.7), CODE-VERIFIED / ENGINE-VERIFIED:
Use a native ListMenu with OnNoPause and let its Drawer reuse the existing
640x360 presentation. Do not switch menuactive off temporarily to call old
handlers; expose shared key/action adapters instead. Enforce OnNoPause only
while the live menu is current, preserving nested engine pause. Reset pointer
capture separately from keyboard hold latches. UIEvent letters can be resolved
through native KeyBindings.NameKeys before checking user-rebound rest actions.
GZDoom identifiers are case-insensitive: a Layout(host) parameter shadows a
Host field; use distinct names or explicit member qualification. NPC reply
index zero and negative history IDs are valid semantic values; pair the native
hit result with a FormatReplies revision instead of treating zero as no target.
Evidence: assets/validation_527/RESULTS.md; physical Journal/calendar/NPC checks
and native held-input/load, pause, orbit, creator and card/crafting regression.

Extension (#150 / 5.2.15): undo CaelumPresentation's scale matrix before the
projection inversion above. Drawing and mouse input must use both axes, and
press/release is invalidated by resolution/scale changes. Common Journal
buttons must be hit-tested before dispatching crafting's specialized pointer;
new contextual shortcuts yield to remapped Journal/time actions. Native cases
are retained in validation_5215; see CA-KP-084 for scale ownership.

## CA-KP-036 - Stamp newly constructed equipment durability revisions

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-04. Issue #89 / 4.37.17.
Baseline: 97419a12 plus #89; GZDoom 4.14.2 Windows/Vulkan.

A weapon spawned and attached directly to inventory can reach migration with
new maximum durability but a legacy revision marker. In the #89 native fixture,
the model held 10,000 while the owned item had been multiplied to 100,000;
the next hit copied the larger value back into the model. Setting the current
WeaponDurabilityRevision alongside a newly computed Durability fixes that
path. Do this before attachment/synchronization; do not use it to bypass genuine
old-save migration. The same explicit initialization already exists in other
project gift/test constructors. #89 applies it to its gift and physical crafting.

Regression: wait after granting/crafting, inspect both model and owned item,
then hit a resource and save/reload. Both begin at the same maximum and decrease
together. Evidence: assets/validation_43717, including the reproduced mismatch
and corrected native impact. Author visual/audio acceptance remains separate.

Rechecked #136 / 5.1.7: city merchant constructors also attached freshly
computed durability before deferred PostBeginPlay stamped it. Stamp both
WeaponDurabilityRevision and ShotgunRevision before attachment, including
physical crafting. The final native integration asserts matching model/item
condition after ticks. Legacy-save fixtures must stamp their explicitly
constructed *old-format* values correctly too; fixture setup errors are not
evidence that the production migration changed a correctly formed old save.

## CA-KP-035 - Center visible font ink rather than trailing advance

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-04. Issue #87 / 4.37.16 follow-up.
Baseline: 3a06a55a plus the compass refinement; GZDoom 4.14.2 Windows/Vulkan.

CaelumMono's native StringWidth("N") is 5, whereas GetCharWidth is 9:
StringWidth includes the final -4 kerning. Its 18x28 source PNG also has
asymmetric transparent padding. At Scale 2, the visible N/E/S/O/W ink center
is (5.5,6.5), versus cell center (4.5,7). Centering only StringWidth therefore
visibly shifts the letters from the compass. Subtract the final kerning and
apply the measured ink offset locally; do not change the shared font to fix
one widget. These offsets describe the existing cardinal glyphs, not arbitrary
fonts or lowercase text. If the font changes, remeasure its alpha bounds.

Regression: compare N/S against the needle's vertical axis and E/O/W against
its horizontal axis in ES/EN at automatic and enlarged HUD scales. Native
captures and measured font values: assets/validation_43716/compass_refinement.
Author visual acceptance CA-43716-UI-01 passed on 2026-10-04.

## CA-KP-034 - Native Windows cursor dimensions and hotspot

Status/evidence: CODE-VERIFIED; texture metadata ENGINE-VERIFIED.
First recorded / last checked: 2026-10-04. Issue #87 / 4.37.16.
Baseline: 33dfcc91 plus the #87 patch; GZDoom 4.14.2, Windows 11/Vulkan.

GZDoom g4.14.2's Windows I_SetCursor rejects source bitmaps above 32x32;
TEXTURES display scaling does not reduce that source bitmap. Supply an actual
32x32 transparent PNG. Native GetTexelLeftOffset/TopOffset provide the cursor
hotspot, so the PNG grAb chunk must identify the intended pointing pixel.
The OS then scales the cursor for display DPI. GameInfo.CursorPic is selected
when vid_cursor is None; an explicit user override takes precedence.

Source reference: g4.14.2 src/common/platform/win32/i_system.cpp, I_SetCursor,
and src/d_main.cpp, vid_cursor callback. The final package resolves cursor as
32x32 with offset (31,7), confirmed by native TexMan queries. Its pointing
pixel has alpha 239; the corner is transparent. This establishes resource
metadata, not physical mouse behavior: the user's Escape stopped Computer Use
before click/drag verification. CA-43716-UI-03 passed author acceptance on 2026-10-04. Regression:
inspect actual bitmap dimensions/offset, then test menu clicks and slider
dragging at the intended DPI. Evidence: assets/validation_43716/RESULTS.json.

## CA-KP-033 â€” Refresh dialogue text after successful-open rewards

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-04. Issues #97 / 4.37.14 and #96 / 4.37.19.
Baseline: bbf79f87 plus the #97 working tree; GZDoom 4.14.2, Windows 11/Vulkan.
Scope: OpenPalomoDialogue and CaelumMainM00ConversationMenu.

Native StartConversation initializes the menu before returning success. A
reward granted after that return correctly avoids failed-open rewards, but
initial text can still describe the state before delivery. In the isolated
reproduction, inventory contained the deck while the menu still said to make
room. Refresh the affected root message from current inventory in Ticker,
preserving the parent menu's established pause policy. Keep alternate messages
within the same reserved line count: changing only dialogue lines does not
reposition replies already laid out by the native menu.

Regression: open Palomo upstairs with and without carrying capacity; inspect
the first displayed message and reply positions, then retry and reopen. Final
EN/ES captures and native checks: [4.37.14 evidence](../assets/validation_43714/RESULTS.json).
Author acceptance CA-43714-DECK-01 passed on 2026-10-04. This verifies the
two tested layouts, not arbitrary font overrides or resolutions.

#96 extension (baseline 466a0734 plus the #96 working tree): an old save inside
Caella's amulet preview correctly retained native node 160, but displayed only
"." because its newly added player text snapshot was empty. The resumed paused
menu could open before the periodic WorldTick refresh. In
CaelumConversationResume, refresh the Palomo/Caella loadout text and derived
tokens before StartConversation; never call the gift or a reply from this
presentation hook. The same original 4.37.18 save then displays the Palomo
referral and remains unchosen, with no reward. Before/after native logs and
package hashes: [4.37.19 evidence](../assets/validation_43719/RESULTS.json).
ENGINE-VERIFIED in GZDoom 4.14.2, Windows 11/Vulkan; all #96 author checks
passed 2026-10-04. Regression: save on an old page, load the new build and inspect
both the restored text and unchanged choice, rather than only its node number.

## CA-KP-032 â€” Test ability input through the native ready weapon

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-10-04.
Issue: [#80](https://github.com/damiancurti/Caelum-Argenteum/issues/80).
Baseline: 63f903d3 plus the 4.37.12 patch; GZDoom 4.14.2, Windows/Vulkan.

A successful direct ability-service call does not establish that User3 reaches
it. The unarmed fallback originally lacked both WRF_ALLOWUSER3 and a User3
state, although the weapon selectors already routed their callbacks. Add the
same opt-in and callback to every affected native ready-weapon path. Latch a
held input until PlayerThink observes release; returning to Ready must not
turn one held press into repeated activations or failure notifications.

Reproduction: choose three captured cards through the Journal's network event,
close the Journal, hold native +user3 for 70 tics while unarmed, then release.
Expect one resource payment, one active set and coherent effect/cooldown
remainders. The native input check passes alongside direct service rejection,
save/load and map-travel tests. See [4.37.12 results](../assets/validation_43712/RESULTS.json).
The Journal test invokes its UI helper and real network event; it does not
claim physical keyboard/controller testing. Author acceptance remains pending
under CA-43712-TAROT-02. This lesson does not expand other ability contracts.

Follow-up #363 / 5.5.5, 2026-10-19: native +user2 reproduced the same unarmed
entry gap for equipped Seals. Append the matching state and opt-in, preserving
all existing state indices. The established channel is a toggle, so release
keeps it active and the next press stops it. Baseline/current native controls,
exact per-tic spending and save evidence: `assets/validation_555/RESULTS.md`.
An initially underfunded test exhausted legitimately before its hold assertion;
seed enough existing maximum resource rather than changing production costs.

## CA-KP-031 â€” Clamp projectile travel before native collision

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED on GZDoom 4.14.2.
First recorded / last checked: 2026-10-03. Issue #77 / 4.37.9, from e08487c9.

Expiring a projectile after Super.Tick can allow that tick's native collision
to hit beyond its remaining range. Limit its velocity to the remaining movement
budget before Super.Tick, then accumulate actual displacement and expire it.
Keep explosion radius separate from projectile travel; retain saved distance
when migrating a previously limited flight. Homing and player projectiles need
the same shared check, not only the optimized NPC projectile class.

The #77 native fixture launches six projectile families at 100 MU/tic with
50 MU range. Targets inside are hit; targets beyond the final step are untouched.
Actual player firing assigns catalogue/ability limits, and midflight save/reload
preserves the original total budget. See south/COMBAT_RECOVERY.json under
assets/validation_4379. This evidence does not establish full-battle performance.

## CA-KP-030 â€” Join per-instance evidence by identity, not array position

Status/evidence: CODE-VERIFIED report defect; ENGINE-VERIFIED unchanged budgets.
First recorded / last checked: 2026-10-02. Issue #75 / 4.37.8, baseline a99f266e.

The manifest orders instances by chest; the native budget log orders by
catalogue_index. A positional join assigned another recipe's inputs to 63
instances across five sizes. Aggregate totals still matched because the set
was merely permuted. Compare stable keys, quantities and every per-instance
value; a matching sum does not validate their associations.

Original and current native inputs agree. The corrected MATERIAL_LEDGER.json
in assets/validation_4378 joins by catalogue_index and preserves the original
report as provenance. validate_map02_supplies.py rejects that old report even
with unchanged totals; MUTATIONS.json records the negative case. Native
completion confirms 325 outputs with fixture-provided crafting prerequisites
and skipped elapsed time, separate from ordinary campaign acceptance.

## CA-KP-029 â€” Lowering a base sector changes upper map-thing spawn heights

Status/evidence: CODE-VERIFIED spawn adjustment; ENGINE-VERIFIED layered traversal.
First recorded / last checked: 2026-10-02. Issue: #74 / 4.37.7, implementation
commit 2f932eab (PR #83), from baseline 5c55bb26.

UDMF thing `height` is relative to its base sector floor. Adding a solid upper
3D slab does not make that slab the original map-thing height reference. When
overlaying lower passages onto an existing map, retain each upper thing's world
height with `newHeight = oldHeight + oldBaseFloor - newBaseFloor`. Apply this only
to existing upper things; deliberately lower actors and elevator controllers
need their own authored placement. Runtime spawns with absolute world coordinates
are a separate path and must not receive the same offset blindly.

In `generate_map02_maze.py`, the original upper cells remain available before
the lower overlay. The manifest publishes both layers, and #74 static evidence
compares every retained upper map thing against the preserved revision-3 WAD
manifest. Native Windows 11 / GZDoom 4.14.2 / Vulkan checks confirm upper arrival,
all six traps, maximum-size layered traversal and dry-anchor supply recovery.
Detached 3D controls retain the CA-KP-026 separation rule.

Evidence: [static checks](../assets/validation_4377/STATIC.json) and
[native results](../assets/validation_4377/RESULTS.json). Native traversal does
not individually inspect every upper actor's rendering; that position comparison
is static. The author accepted CA-MAP02-PIT-RETURN-01 on 2026-10-02
without reported exceptions; see HISTORY for the separate acceptance record.

## CA-KP-028 â€” Temporal forecasts must preserve within-tic ordering

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, issue #64, 4.37.4.
First recorded / last checked: 2026-10-02 / 2026-10-02.
Affected baseline: c3ba10b1 plus the initial #64 forecast; final source/package
hashes and selected results: assets/validation_4374/RESULTS.json.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, isolated MAP01 fixture.

The player calculates health performance before that tic's healing and Adrenaline
decay. A forecast using the already-healed health for Air regeneration crossed a
health threshold one tic early. A long sample ending with full Air concealed it;
a 100-tic sample at 50% health exposed a 0.007485 Air difference and corresponding
food/water cost differences. The skip model now samples those inputs before the
step. The existing journey model retains its established default behavior.

Regression: compare native and predicted partial Air, health, Hunger, Thirst and
Sleep at the boundary as well as after a longer interval. The corrected edge and
long samples agree within 0.000001; normal/skip and fast/skip interval comparisons
also cover actual servings and productive work. Do not replace chronological
substeps with a final-date assignment or apply forecast inventory as a reward.
Author acceptance remains separate in pending_test.txt.

## CA-KP-027 â€” Terrain relief can invalidate absolute-height relocation filters

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED, #61 / PR #66.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Affected baseline: 00e4322d; repair: subsequent station-relocation change in
PR #66, exact source/package hashes in assets/validation_4370/STATIONS.json.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, development Doom II IWAD,
fresh MAP01 and isolated native fixture.

Six original stations remained outdoors at Y=1040 while their replacements
appeared inside, yielding 44 stations instead of 38. Their former flat staging
row now sits on hills at Z=1.08..3.30. PlaceStation and PrepareMansionLayout's
spare fallback required Abs(Pos.Z)<1, so both missed the grounded originals.
The map's original thing records were unchanged; that invariant alone could
not verify runtime relocation after a terrain change.

Both filters now compare Pos.Z with native FloorZ, retaining the existing XY
bounds, class and unassigned-group restrictions. Do not simply expand a magic
absolute Z range when the intended condition is standing on the local floor.
The fix reuses original actors and the existing destinations without deleting
stations, introducing recipes or changing saved fields.

Regression: native WorldLoaded captures all eighteen original references.
After preparation there must be 38 stations, none outside, groups 5/7/5/9/12,
and all originals retained. Test each station's network and physical access;
repeat preparation and save/reload to check identity and duplication.
Evidence: [station repair](../assets/validation_4370/STATIONS.json).
Author acceptance: CA-4370-STATIONS-01 confirmed 2026-10-01. Already prepared older worlds
are outside this fix under the author's explicit old-save waiver.

## CA-KP-026 â€” Detached control rooms must remain outside playable geometry

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED, #61 / PR #66.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Affected baseline: fe506a3e; fix: the subsequent control-relocation change in
PR #66, with exact source hashes in assets/validation_4370/CONTROLS.json.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, development Doom II IWAD,
fresh MAP01, no autoload, isolated test fixture.

At (25630.19,29408,0), facing yaw 19.34, the engine selected auxiliary sector
539 and rendered black space with an isolated stone pillar. The author also
reported an invisible boundary. Sixty-nine detached original auxiliary polygons
intersected or touched the playable horizon; 63 were wholly inside it. Their
one-sided untextured walls do not form valid exterior holes with shared sides.
Checking only the outer boundary and sector references missed this topology.

CONTROL_RELOCATION.json identifies those polygons. mansion_control_relocation.py
translates only their vertices into an unused off-map grid, preserving control
lines and complete sector records. For models with explicit world-space planes,
preserve the plane coefficients; moving their coordinates alone must not shift
the target floor. The independent validator checks every 3D-floor model's bounds,
non-overlap and preserved data. Native before/after height samples catch effects
that an offline parser cannot establish.

Evidence: [control repair](../assets/validation_4370/CONTROLS.json), matched
reported views, 750 region samples/3,000 moves, 64 former room centres, actual
player traversal, 840 identical mansion surface samples and 429 door checks.
The black region is absent in the final views. This does not establish the
cause of the earlier oversized-floor defect in CA-KP-024 or cover every camera.
Author accepted this repair as CA-4370-EXTERIOR-01 on 2026-10-01.

## CA-KP-025 â€” Normalize all four coefficients of generated UDMF planes

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #61 / PR #66 / 4.37.0.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Baseline: 3277ab2f plus the decorative-cave working tree; GZDoom 4.14.2,
Windows 11, Vulkan, fresh MAP01 and an isolated native fixture.

In the new cave near (23268,23285), writing an algebraically correct plane
with normal (-gx,-gy,1) produced the wrong native height: an intended Z=-32
ramp point reported about Z=221.31. Normalising A, B, C and D by the normal's
length corrected the same point to -32 and restored the continuous mound.
An offline ZatPoint calculation alone had passed because it evaluated the
raw coefficients, not the engine's loaded representation.

mansion_decorative_cave.py normalises its generated floor and roof planes.
validate_mansion_cave.py checks unit normals and authored vertex heights; the
native fixture independently samples all 1,152 new floor triangle centres.
Keep this native check for distant geometry, where a small coefficient error
can cause a large vertical displacement. This finding does not reinterpret
the already accepted mansion relief; the new cave generator is its scope.

Evidence: assets/validation_4370/CAVE.json and its retained diagnostic/final
logs. Original reports and failed local trials remain available separately.
New cave author acceptance CA-4370-CAVE-01 was confirmed on 2026-10-01.

## CA-KP-024 â€” A valid oversized floor can disappear in the renderer

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED, #61 / PR #66 / 4.37.0.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Baseline: 30caa726 and f69e6f7e; GZDoom 4.14.2, Windows 11, Vulkan,
RTX 3070 Ti, author-installed development Doom II IWAD.

The author reported transparent exterior ground at (17455,7394,0). Native
PointInSector still identified sector 0 with floor Z=0, and its CMGR01A texture
was valid. The same view failed in the preserved baseline. Static texture and
collision checks therefore did not detect the visible defect. Removing the
horizon special, reducing the sky ceiling and splitting only long boundary
lines each failed to repair the rendering; an isolated bounded sector rendered.

The first correction partitioned the 60000-MU-wide exterior into nine bounded regions
with flat, two-sided internal joins. Existing terrain stays in the central
sector and original horizon extent/blocking remains. The reported point now
renders grass. This establishes a geometry-dependent failure and a verified
workaround, not a universal size limit or an identified internal renderer bug.
Retain native before/after captures, inspect distant views in addition to the
mansion, and verify that new joins preserve heights and traversal.

The author accepted that point's repair but later reproduced the defect near
(23268,23285,0). Sampling only region centres had missed it. The follow-up uses
25 regions and checks positions near all four corners and edge midpoints as
well as the reported locations. Do not generalise a few successful views into
a guarantee that the complete oversized exterior renders correctly.

Evidence and exact geometry: assets/validation_4370/FOLLOWUP.json, CAVE.json and
assets/map01_mansion/EXTERIOR.json. Original CA-4370-MANSION-01 is author-accepted;
CA-4370-CAVE-01 was subsequently accepted on 2026-10-01. The later distinct
auxiliary-room defect and its pending repair are covered by CA-KP-026.

## CA-KP-023 â€” OBJ height and map headroom use different vertical scales

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #61 / 4.37.0.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Baseline: accepted MAP01 at 30caa726, Windows 11, GZDoom 4.14.2, Vulkan,
RTX 3070 Ti, development Doom II IWAD. The author accepted the general doorway
checks and subsequent roof-front correction on 2026-10-01.

Symptom: the accepted 120-unit mansion door OBJ leaves a visible upper gap even
when its actor blocker and nominal map opening both reach 120 MU. GZDoom's
model transform divides non-voxel height by the map pixel stretch; at MAP01's
1.2 ratio, the visible leaf ends at 100 MU. Actor collision is independent.

For the fixed #61 tympana, measure from that rendered top to the existing slab
underside. Their MODELDEF Z scale of 1.2 makes newly authored mesh heights match
map units. Fill the complete rectangular backing, including corners outside the
triangular/arched inset. Preserve the accepted leaf, its sweep and blockers.
Group faces into bounded material surfaces as described in CA-KP-020.

Evidence: assets/validation_4370, EXTERIOR.json, generated tympanum meshes and
native closed/open views from both sides. Reference: GZDoom g4.14.2
[models.cpp](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/r_data/models.cpp),
model transform around lines 143-192. This evidence establishes this map/model
combination, not a universal scale for sprites, voxels or other map ratios.

## CA-KP-022 â€” A magic-resource wait can strand an otherwise mobile army

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-09-30 / 2026-09-30.
Issue #16, baseline 2440558f; Windows 11, GZDoom 4.14.2, Vulkan, fresh MAP06.

The author reported mostly stationary enemies inside the port army. A native
probe separated motion over 175 tics from attack state and resource wait:
after 700 tics, 713 attackers waited for Anima despite having Air available.
The accepted #37 AttackResourceWait stops movement until the attempted attack
is affordable. That behavior was unsuitable for the port army's magic/melee
choice; it was not evidence that the mass scheduler disabled those enemies.

Port Pulse now excludes unaffordable spells from A_Chase. Saved magic waits
resume the existing See state when the physical attack is affordable. Physical
exhaustion, sleep/stun, other encounters and resource balance stay unchanged.
The comparable corrected sample moved 968 actors versus 429 before, with no
magic wait. This does not eliminate legitimate collision congestion in a crowd.
The author's subsequent resource trial deliberately permits both attack types
at zero resources for registered hostile port actors. This fallback behavior
remains available when enemy_attack_resource_trial is disabled in the port data.
Evidence: assets/validation_43627/relief, including native before/after movement,
full-roster operation and saved-wait continuation. The author accepted the final
resource trial and all #16 tests on 2026-09-30; see HISTORY for the test IDs.

## CA-KP-021 â€” Cannon target sight must originate at the raised barrel

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #16 / 4.36.27.
First recorded / last checked: 2026-09-30 / 2026-09-30.
Affected baseline: 918775e3 plus the issue-16-port-siege working tree.
Environment: Windows 11, GZDoom 4.14.2, Vulkan, development Doom II IWAD,
fresh MAP06 with twelve defensive guns on raised platforms.

An initial target selector called CheckSight from the non-interacting cannon
controller at platform-floor height. The parapet occluded that point even when
the raised barrel could fire over it. Only the six attacking guns fired in the
first full-scene probe. Use the existing barrel actor for target visibility;
keep the launch sweep from the physical pivot/muzzle and native projectile
collision unchanged. The corrected scene fires all eighteen cannons at the
first completed cycle. Select the aim point when the cannon becomes loaded,
rather than retaining a target position selected at the start of its reload.

Reproduction: start current MAP06 and observe each gun through its first
350 native tics, recording per-gun shot/contact counts and operator presence.
Evidence: [integration results](../assets/validation_43627/RESULTS.json),
integration/issue16_mass1.log (before) and issue16_mass_final.log (after).
The final run records eighteen shots/contacts by tic 385. This verifies the
tested platform geometry and native selector, not unrestricted ballistic
accuracy. Separate author acceptance of the battle was confirmed on 2026-09-30.

## CA-KP-020 â€” Repeated OBJ material declarations create unsafe surface counts

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED, #36 / 4.36.25.
First recorded / last checked: 2026-09-29 / 2026-09-29.
Baseline: 99b399bc, Windows 11, GZDoom 4.14.2, Vulkan, RTX 3070 Ti,
gl_multithread=true and gl_precache=false. Author acceptance remains pending.

Symptom: starting MAP01 could abort with "Trying to create zero size texture"
after character allocation loaded. Some successful runs displayed incorrect
door hardware textures. The mansion OBJ exporter emitted one usemtl per face:
222 surfaces for three materials. GZDoom starts another surface even when the
material name repeats. Its OBJ RenderFrame indexes surfaceskinids[i] without
the i < MD3_MAX_SURFACES check used by AddSkins; the native limit is 32.
Out-of-range texture selection depends on memory layout, so a passing run or
a debugger session does not establish safety.

Correction: group opaque faces by material in the generator. The model now
has three surfaces, retaining all 222 faces, winding, dimensions and UVs.
The read-only model check compares each face with the original siege source
and rejects repeated surfaces or an exceeded engine limit. No engine binary,
graphics preference or gameplay rule is changed. An investigated inherited
state registration did not solve the failure and was removed.

Evidence: assets/validation_43625/layout, including the native error capture,
repeated corrected runs, creator and current-save tests. Source references:
[OBJ loader/renderer](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/models/models_obj.cpp)
and [surface limit](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/models/model.h).
The author still needs to confirm ordinary play and new-character startup in
CA-43625-MANSION-01.

## CA-KP-019 â€” A 3D wall inherits its control texture, not its visible face

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #36 / 4.36.25.
First recorded / last checked: 2026-09-28 / 2026-09-28.
Baseline: 61b3c74e; correction is the linked #36 patch, with native evidence
from its working tree. Environment: GZDoom 4.14.2, Windows 11, Vulkan,
development Doom II IWAD, fresh MAP01.

MAP01 reused CMIN01 on shared solid-wall controls, causing interior wallpaper
to appear outside. Changing ordinary sidedef textures alone does not fix those
3D wall faces. Sector_Set3dFloor argument 2 bits 16/32 select the target upper
or lower texture; the visible/observer side determines interior versus exterior.
Separate slots when one boundary supports different finishes at different levels.
Keep slab undersides, roofs, door controls and cave/water models distinct.

The same inspection found flat upper wall tops below a sloped roof. New solid
gable controls end on the original roof underside; preserve the actual roof
planes and intentional balcony/stair openings. Native before/after traces and
images demonstrate the closure. A guard inferred from an exposed slab edge can
incorrectly fence a narrow construction seam inside a continuous walkway: compare
ordinary-sized native movement against the baseline before accepting it.

Evidence: [#36 results](../assets/validation_43625/RESULTS.json), map generator
and read-only layout validator in assets/generators. Representative native
geometry probes ignore actors; final tutorial/Bull play remains author test
CA-43625-MANSION-01. Visual direction approved 2026-09-28; final playtest pending.

The author's #36 follow-up exposed three related authoring traps. A repeating
window texture inherits 3D-floor pegging and can put windows at ground level:
finite nonblocking panels with explicit sills remove that dependency. A broad
footprint misclassified the middle east-wing interior; use its actual Y=+/-320
wall face, not the older +/-287 estimate. Existing door actors also do not prove
their openings are open: four single leaves overlapped solid stacked wall models.
Rebuild only their authored rectangles and preserve the other vertical layers.
The corrected generator retains existing sidedef slots during subdivision and
keeps every retained sector outlined; static checks reject unused sides/empty
sectors after an intermediate candidate produced native missing-front errors.
For stacked-actor traversal probes, CANPASS is needed to match the player's
vertical actor separation. Evidence: assets/validation_43625/followup; generic
body probes and direct Use calls are not full companion/Bull play acceptance.

## CA-KP-015 â€” Git checkout can invalidate raw document hashes

Status/evidence: RESOLVED-VERIFIED tooling contract, #21 /4.36.19.
Observation: after merge 8e8b5d3f and Windows checkout, validation reported stale
HISTORY/SYSTEMS SHA-256 although Git showed no content changes.
Cause: the index hashes raw bytes; core.autocrlf converted newly edited LF
sources to CRLF. Resolution: .gitattributes pins maintained docs to LF and the
index is regenerated from LF sources. An isolated core.autocrlf=true checkout
matches the source hashes; static validation passes. Keep exact-byte freshness
checks and UTF-8 sources. This is tooling evidence, not gameplay acceptance.

2026-10-01 extension, #17 / 4.36.28: `git archive` at `9323b156` also applied
checkout conversions to runtime text under `core.autocrlf=true`; independently
comparing exported ANIMDEFS to its Git blob detected the mismatch. Repeated
exports on one machine alone did not catch it. RESOLVED-VERIFIED at `fa6fb9bb`:
`build_playtest.py:committed_files` reads `git cat-file --batch` blobs instead.
`assets/validation_43628/verify_export.py` verifies all 6,129 blob identities,
archive metadata and hashes; two subsequent archives matched byte for byte.
See [4.36.28 evidence](../assets/validation_43628/RESULTS.json). This is static
packaging evidence; export author acceptance remains pending.

## CA-KP-016 â€” Register dynamically selected Arcana front sprites

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED correction.
First recorded / last checked: 2026-09-27 / 2026-09-27.
Issue: #33, release 4.36.20; failing baseline c24589ca.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, gl_multithread=true,
author-installed Doom II development IWAD.

Assigning CACU/CAWK only through Actor.GetSpriteIndex, without any actor state
using those frames, left their first rendering on an unsafe initialization
path. The author observed a complete freeze on Ace Use. An isolated baseline
also stopped after the first dialogue frame: a local dump, resolved with the
matching official PDB, showed the renderer worker in FTexture::TrimBorders
and the main thread waiting in HWDrawInfo::RenderBSP. Appending RevealedFront
states to the two essence classes registers their fronts when actors load.
Preserve old state offsets when adding these registrations for saved actors.

The corrected native tests draw at least 20 dialogue frames, submit through
ConversationMenu.MenuEvent, observe nonzero capture tics and ownership, then
continue ticking. Repeated Ace/Knight and a copied autosave pass. This is
scoped to these sprites and this engine; it is not a blanket guarantee about
all dynamic sprites. Checking Used's return value or manually invoking Tick
does not validate the rendered dialogue/capture path. See
[render correction evidence](../assets/validation_43620/capture_render_fix.json).
The author confirmed CA-43620-ARCANA-01 passed after the fix on 2026-09-27.

Reverified under #143 / 5.1.6 on 2026-10-08: CAGC posture assignment lacked a
state registration and froze live/visual rendering. The initial mechanical
comparison against GetSpriteIndex("CAGC") could accept the same invalid index;
assert that the index is nonnegative before testing equality. Appending CAGC
A-D to the registration actor restores native live/render/input completion.
The final direction gallery waits for world updates and records every pose/view;
rapid console captures alone do not prove every requested rotation was rendered.
See assets/validation_516/RESULTS.md. This is engine verification, not CA143-01
author acceptance.

Reverified under #252 / 5.4.21 on 2026-10-15: CMNW/CMNA texture aliases also
lacked actor states. The author saw a face for Water. Append-only registration
corrects these lookups; the revised native test requires each index to be
nonnegative and checks the selected image, then captures all five ground marks.
The earlier flat-flag/scale assertions did not establish image correctness.
See assets/validation_5421/RESULTS.md; CA252-01 was accepted on 2026-10-15.

## CA-KP-017 â€” Unregistered NPC secondary-wind sprite freezes rendering

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED correction, #34 / 4.36.22.
First recorded / last checked: 2026-09-27 / 2026-09-27.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, gl_multithread=true, development IWAD.

CELH existed as twelve PNG frames but had no native actor state. NPC simple and
explosive wind projectiles used GetSpriteIndex("CELH"), which returned -1.
The author's frozen MAP02 process retained C0000005 in FindModelFrameRaw
(RVA 0x397986), sprite -1/frame 9. The engine exception handler redirects the
worker to SleepForever and queues cleanup on the main thread; the latter is
waiting for that worker in RenderBSP. Ordinary post-hang stacks obscure the
original exception: recover CrashPointers/CrashAddress with matching symbols.
Do not mistake raw stack-address scans for an unwound call chain.

Append CELH A-L states after existing states so sprite registration is global
and old saved state offsets stay intact. A baseline secondary-wind discharge
reproduces the hang; corrected simple/explosive rendering and all twelve frames
pass. Recheck both consumers and pre-change saves when altering registrations.
This is related to CA-KP-016 but has a distinct measured invalid-index exception.
Author rescue/rats retest passed 2026-09-27 (CA-43622-NARRATIVE-01). See
[evidence](../assets/validation_43622/wind_render_fix.json).

## CA-KP-018 â€” USDF page insertion shifts saved conversations

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED correction, #34 / 4.36.22.
First recorded / last checked: 2026-09-27 / 2026-09-27.
Environment: GZDoom 4.14.2, Windows 11; pre-#34 save on the new CAPALOMO layout.

Native actor saves persist global conversationroot/conversation node numbers.
An unchanged public dialogue ID does not protect an already open saved page.
Old MAP02 Voice nodes 178/179 became Palomo food/water nodes in #34; death loading
the old save reproducibly restored the wrong menu. Current-release save/load
tests alone cannot validate this compatibility boundary.

Version the transient Voice speaker's layout and rebind its canonical ID before
resume; revision 0 restarts the brief conversation once, revision 1 preserves the
saved page. Snapshot the pre-#34 narrative revision in WorldLoaded before normal
migration. Other open old dialogues close without selecting any reply; normal
interaction supplies their canonical ID. Never migrate by executing Use/replies
automatically: that can replay rewards or actions. Retain original saves for
rollback, and recheck this boundary whenever USDF pages move.

Regression evidence includes old Voice wrong-page reproduction, death/reload,
old mentor/prisoner close/reopen, new exact-page saves and original-save rollback.
Author confirmation: CA-43622-NARRATIVE-01 passed 2026-09-27. See
[evidence](../assets/validation_43622/dialogue_resume_fix.json).

## How to read this register

This is a compact engineering memory, not a second bug tracker or a claim that every historical fix has been independently reproduced. Use the current issue for active scope and HISTORY for release chronology and author acceptance.

Evidence labels:
- CODE-VERIFIED: supported by inspected source at a named baseline; no runtime guarantee.
- AUTHOR-REPORTED: observed by the author; environment/reproduction may still be incomplete.
- ENGINE-VERIFIED: reproduced with retained engine evidence and conditions.
- RESOLVED-VERIFIED: cause and fix supported by before/after evidence, with acceptance stated separately.
- HYPOTHESIS: an unconfirmed explanation, explicitly not a verified lesson.
- SUPERSEDED: retained reference to advice no longer applicable.

CA-KP-003 records the focused 4.36.2 native runtime verification. CA-KP-001
is a resolved tooling contract. Author acceptance remains explicitly separate.

## CA-KP-001 â€” Adding a guide to docs breaks the current exact-file check

Status/evidence: RESOLVED-VERIFIED tooling contract (issue #22, patch 4.36.1b).

Observation: the validator used to require exactly the five canonical plus two working documents under docs/ and current-version headers in those registered documents. Copying these two guides into docs/ therefore failed that exact-set check.

Cause: an explicit exact-set validation contract, not invalid Markdown.

Resolution: issue #22 registers `GZDOOM_DEVELOPMENT.md`, `KNOWN_PITFALLS.md` and the generated `DOCUMENT_INDEX.md` as the explicit allowed docs set. The seven canonical/working documents and AGENTS remain subject to current-version checks; the ancillary guides inherit README's release. The unexpected-doc-file check stays active against the extended allowed set, and the guides' existence, UTF-8 readability and repository-relative links are validated.

Verification: before the patch, a disposable copy with the two guides failed the exact-set check; after the patch, `python validate_project.py` exits 0 with ten docs and an empty error list. Disposable negative cases still fail for a missing guide, a broken guide link, an unexpected docs file and a version mismatch.

Author acceptance: recorded separately for the 4.36.1b documentation patch; this entry describes the tooling fix, not a runtime defect.

## CA-KP-002 â€” Default equipment size is not the character's raw body tier

Status/evidence: ENGINE-VERIFIED in 4.36.4 (#10), GZDoom g4.14.2. Scope: shared recipient-size policy, native equipment acquisition and legacy MAP02 chest migration; author acceptance: CA-4364-T1-LOOT-01 passed on 2026-09-23.

Observation: a shared mapping converts character tiers into equipment-size constants; its current default selection does not select every possible equipment size. Do not infer a linear or one-to-one mapping, or change it as incidental cleanup.

Cause/fix: the former pickup path could initialize size and reserve ItemId before
capacity rejection. Treating those fields as proof of acquisition bound rejected
shared loot to its first viewer. Resolve a nonmutating projection, check capacity
before allocating identity, and commit only on transfer. Preserve genuine owned
or dropped equipment. A container's temporary BecomePickup/bDROPPED flag is not
evidence of previous ownership. Revisioned migration retains unclaimed higher-tier
objects separately without refilling looted slots; RestoreLegacyLootForMigration
reverses that storage change. Explicit CHARACTER_DEFAULT is distinct from legacy
editor argument 0 (M) and resolved size enum 0 (XS).

Prevention: reuse the mapping for the actual recipient, including multiplayer;
inspect fit, weight, durability, value and capacity. Preview and cancellation must
never assign identity or change size, wear, loot counts or stock state.

Verification: 232 native sizing checks passed across all seven body tiers; actual two-client small/large collection and stale confirmation passed. Fresh and baseline-save chest probes cover rejected legacy pickups, preservation of acquired T3 and looted holes, and reversible/idempotent migration. See assets/validation_4364/RESULTS.json for persistence and presentation evidence. These isolated checks do not constitute author acceptance.

## CA-KP-003 â€” Nested bow crop composition stalls on first presentation

Status/evidence: RESOLVED-VERIFIED in 4.36.2 (#8, fix commit `abdae0d`, PR #24).
Author acceptance: CA-4362-BOW-EMPTY-01 passed, explicitly confirmed on
2026-09-23 (America/Buenos_Aires), with no reported exceptions; see HISTORY.
Baseline: merged main `3b75054`.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/8

Native GZDoom g4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti / development Doom II
reproduced a 10,442.647 ms inter-tick gap on first empty standard-bow presentation
and 5,210.706 ms when its loaded pose was first shown. Repeated equips were
responsive; the equip callback itself returned in 0.055 ms. The original
author's exact bow/tier remains unknown.

Cause: TEXTURES nested 167â€“173 row crops per tier through a full recolored
sheet. This is first-use resource work, not evidence of an infinite state loop.
The generator now writes six deterministic crop-only RGBA caches, retaining
native palette operations and the existing sprite declarations. No gameplay,
state table, save schema or original art changes. Do not reintroduce the nested
crop graph or hide the cost by delaying it to another gameplay action.

Evidence: [4.36.2 native results](../assets/validation_4362/RESULTS.json), adjacent
filtered logs and six native original/optimized captures; zero differing RGB
pixels on black, independently verified original crop/alpha equivalence, and
byte-identical repeated generation. HISTORY gives the cause/fix and scope.
Regression: cold and repeated empty/loaded equips for both bows, real one-arrow
reload/fire, arrow overlay visibility, aim and switch-away/back. Callback
automation does not replace physical-binding/normal-route author acceptance
or establish results on untested renderers.

## CA-KP-004 â€” Flail rotation must be judged around the rendered grip

Status/evidence: ENGINE-VERIFIED transform correction in 4.36.3 (#9).
Author acceptance: CA-4360I-VISUAL-01 (origin 4.36.0i) passed after the
4.36.3 correction, explicitly confirmed on 2026-09-23 (America/Buenos_Aires),
with no reported exceptions; see HISTORY.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/9

Baseline: merged 4.36.2 (`772f622`) used `handleAngle=rotation-39.5` in
`src/caelum/equipment/CaelumFirstPersonLayers.zs`. The author requested another
approximately 10 degrees counterclockwise. Native before/after captures verify
that increasing the offset to -29.5 produces this direction. The shared
`FLAIL_HANDLE_ANGLE` is the current source for both references; historical 0i
composition manifests and their generator output retain -39.5 as provenance.

Prevention: preserve the grip reference and connected layers. The handle still
hides half of its exposed shaft under the glove; the chain's position follows
the transformed joint, but its resting angle must not inherit the handle's
angle. Keep layer 46 behind handle 50 and hand 52. A plausible numeric sign or
a rotated screenshot is not proof of native screen-space direction.

Verification: GZDoom g4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti / development
Doom II, fresh isolated MAP03 games. T1â€“T3 native before/after rest captures,
grip/joint checks, 45-degree attack increments through 360 degrees, return and
holster/re-equip passed with zero failures. The chain's 17.424612-degree native
rest offset stayed unchanged. [Evidence and conditions](../assets/validation_4363/RESULTS.json)
include filtered native logs; capture-only HUD suppression reveals the layers.
Automated native callbacks do not replace final author aesthetic approval or
prove untested renderers. No save field/state schema or combat timing changes.

## CA-KP-005 â€” A green validator or a built PK3 is not a gameplay pass

Status/evidence: CODE-VERIFIED tool scope. Baseline validate_project.py and build_dev.ps1.

Observation: Python checks selected project contracts; the builder packages source files and checks archive/PNG properties. Neither tool executes a normal player route or proves that ZScript compiles in GZDoom.

Prevention: report static validation, packaging, engine load, scenario behavior and author acceptance separately. Do not reuse an old engine success as evidence for a changed commit. State limitations of Linux/Freedoom fixtures and preserve target Windows verification.

Resolution: this is a workflow safeguard, not a bug awaiting a code fix. Each PR supplies the levels relevant to its change.

## CA-KP-006 â€” Planned state can drift between issues and canonical documents

Status/evidence: CODE/DOCUMENT-VERIFIED discrepancy plus explicit author clarification.

At the inspected PR #7 commit, its reward clarification still describes size-M prices with tiers pending. The author's later instruction and updated issues #10/#14 specify T1 and the recipient's equipment size. Local edited documents can be newer than their Git HEAD; they must not be cited as committed evidence.

Prevention: compare the exact commit and dirty-tree status, distinguish author-approved design from shipped implementation, and reconcile the current canonical sections during formal integration. Do not silently revert a later author decision because an older document says otherwise.

Acceptance: issue #22 reconciled the then-confirmed T1/recipient-size rule. The later #10/#14 author decision supersedes that reward formula with fixed 25 gold plus 10 own-faction reputation, implemented in future #14. Issue #10 reconciles current references and preserves the displaced formula in HISTORY. Historical fixed-M and price-average discussions remain historical.

## CA-KP-007 â€” New serialized event handlers are absent from older saves

Status/evidence: ENGINE-VERIFIED in 4.36.4 (#10), GZDoom g4.14.2.

Symptom/cause: a pre-4.36.4 MAP02 save restored its saved EventHandler list.
The new chest preview inventory correctly contained five real entries, but the
new map handler was absent (`open=1`, `count=5`, `handler=0`), so neither its
input nor its renderer was available. A fresh game did not expose the problem.

Fix/prevention: the stateless input/network controller is a StaticEventHandler,
independent of the saved map-handler list. Serializable preview state stays on
the recipient's inventory. Static render events precede map render events even
with a larger SetOrder value; draw the modal through the end of the existing HUD
instead, so bars and gameplay notices cannot cover its contents or actions.
Call EventHandler.SendNetworkEvent explicitly from the static controller.
Collection confirmation closes the modal so actual receipts/capacity notices are
visible before they expire; reopening reads the current remaining inventory.

Verification: the same old save, its migrated reload and five-entry 1024x768
native capture; fresh-save and hub-return probes. See validation_4364 evidence.
Author acceptance: CA-4364-T1-LOOT-01 passed on 2026-09-23. Preserve this separation when adding another
UI to an established save schema.

Additional ENGINE-VERIFIED scope in 4.37.13 (#81): a native menu is presentation,
not saved match state. Loading a Trucazo save while another menu was open could
retain the obsolete menu and its nonpaused state. Its static WorldLoaded hook
now sends a one-time interface restore; UiTick reconstructs the match menu and
sets native Menu.On. A paused-menu network probe confirms play-scope actions
still run while level.time stays fixed. Pending-call reload keeps the exact
deck/rows/health, with the ordinary one engine resume tic before menu pause;
closing returns to menuactive=0 with no frozen-control flag. See
[4.37.13 evidence](../assets/validation_43713/RESULTS.json). This does not claim
arbitrary serialized menu objects can be restored or bypass scope separation.

Related #148 evidence (5.2.13, ENGINE-VERIFIED): appearance editor drafts validate
both pawn and profile pointers, life/creation state and the expected edit serial
at confirmation. A serial alone is insufficient when another profile has the
same serial. WorldLoaded discards a visible editor; native save loading can also
clear UI references itself. `retained-03` and `replaced-01` distinguish those
cases in assets/validation_5213. A null retained UI reference after load is not a
failed invalidation. Never infer successful disposal solely from a zero failure
counter when a fixture printed a separate FAIL line.

#413 follow-up (5.8.1, ENGINE-VERIFIED, 2026-10-23): a newly added map
altitude handler was also absent from the genuine pre-feature save. The final
implementation initializes additive altitude fields on the existing saved
CaelumPhysicsMapState through the already-existing WorldClockTicker.WorldLoaded.
The existing one-marker typed lookup is reused once per map load; the ticker
caches the result for body queries. The independent altitude revision does not
convert gravity again. Old-save migration, saved player/NPC adaptation and hub
return pass; the untouched original save still loads with its original runtime.
Evidence: assets/validation_581/RESULTS.md. Author review remains pending.


## CA-KP-008 â€” Changed map geometry prevents old saves from loading

Status/evidence: ENGINE-VERIFIED in 4.36.5 (#11), GZDoom g4.14.2.
Baseline: integrated 4.36.4, `3f3fa0c`; implementation evidence uses the #11
working tree, delivered in `a7b8f95` / PR #28. Author acceptance:
CA-4365-MAZE-01 passed on 2026-09-24 without reported qualifications.

GZDoom checks saved map geometry counts and checksum before restoring ZScript
objects (`p_saveg.cpp`, geometry validation). An inventory revision or a
WorldLoaded migration cannot repair that earlier rejection. A hub save on a
different active map can still contain the old MAP02 snapshot; testing only
fresh games or the active map misses this dependency.

Keep the original WAD and its provenance. The explicit `build_dev.ps1
-LegacyMap02` / `run_dev.bat --legacy-map02` mode packages that exact MAP02
under the established package name, with current code and unchanged map IDs.
The builder verifies SHA-256 before replacing its output. Current runtime
coordinates branch on the new layout marker, so restored old geometry keeps
its original travel/furniture positions. Compatibility is continuation of
the old layout, not conversion to the new layout or permission to reset saves.

Native regression: load a pre-patch save inside MAP02 and another in MAP03
with a saved MAP02 hub, return, and compare keys, chest ownership, identity,
size, wear and position. Both pass (49 and 48 checks respectively). Builder
verification also rejects missing/wrong legacy data without replacing the
previous package. See [validation evidence](../assets/validation_4365/RESULTS.json).
Keep compatibility mode for that campaign; normal builds provide the rebuilt
map for new campaigns. No external save rewriting is required.

Rechecked for #234 / 5.3.7: replacing the old mansion WAD before loading
produced native `Savegame is from a different level` before ZScript ran.
Loading with its exact archived WAD passed and kept the current room catalogue
disabled. Evidence: assets/validation_537/legacy-reload-01.txt (rejection) and
legacy-reload-02.txt (matching geometry); this patch changes no production WAD.

Rechecked for #414 / 5.8.2 on 2026-10-24: explicit LegacyMap01 keeps the
pre-installation mansion and both active-map/hub saves playable with current
code; original packages/saves also remain usable for rollback. Review consumers
of geometry checksums as well as the WAD: the authored room catalogue needed
both old and new checksums because this exterior-only edit preserves all room
IDs and bounds. Do not enable an old catalogue without that coordinate audit.
Native room-discovery/compatibility evidence: assets/validation_582/RESULTS.md.
Author acceptance CA414-01 passed all terminal checks on 2026-10-24.

## CA-KP-009 â€” MODELDEF slots overlay state meshes

Status/evidence: ENGINE-VERIFIED, 2026-09-26; #18 follow-up, 4.36.14a.
Affected baseline: `95d8f111` MODELDEF bindings; reproduced with remeshed
working-tree assets before correcting those bindings. Environment: Windows,
GZDoom 4.14.2, Vulkan, disposable fresh MAP03 and a local development IWAD.

Symptom: intact/damaged/open gate meshes appear together, leaving a visible
closed leaf across an open doorway. Cannon and ram states also overlap.
The actors themselves have no SOLID flag; this is not proof of a collider bug.

Cause: model slots describe simultaneous components. Defining three models in
slots 0/1/2 and assigning a different slot to each sprite frame does not exclude
the other components. Fix: generate a separate single-slot MODELDEF block for
each actor/frame. Preserve actor names and state labels.

Reproduction: fresh MAP03, inspect a gate's Intact and Broken gallery poses.
The old bindings overlay the panels; corrected bindings show one closed pair
or one open pair. Retained [evidence](../assets/validation_43614a/RESULTS.json)
contains the before screenshot, all final native views and the reproducible
QA addon. Native TryMove checks cross each open preview without noclip.
The failed intermediate north-wall placement is recorded separately; a clear
mesh does not imply clear map geometry behind it.

Follow-up #411, 5.8.8, 2026-10-25: the same multi-slot mistake rendered the
legacy 2x2 m tent inside its enlarged replacement. An isolated gallery subclass
with its own MODELDEF passed but could not exercise the production binding.
Use the actual deployed class and both saved geometry states for visual QA.
Separate single-slot blocks resolve the overlay; before/after native evidence is
in assets/validation_588/binding. Final author confirmation is still pending.

Regression: `python assets/validation_43614a/check_siege.py` checks exclusive
state bindings, valid OBJ/material references and two byte-identical generator
runs. Render affected states in the target engine after binding changes.
Author acceptance: `CA-43614A-SIEGE-ART-01` passed on 2026-09-26. This verifies visual
previews, not future breakable-gate physics or historical machinery dimensions.

## CA-KP-010 â€” Damage proxies must preserve native projectile damage callbacks

Status/evidence: RESOLVED-VERIFIED in the #19 working tree (runtime hashes in evidence).
First recorded / last checked: 2026-09-26 / 2026-09-26.
Issue: [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19).
Environment: GZDoom 4.14.2, Windows 11/Vulkan, development Doom II, isolated MAP03.
Scope: CaelumGateBlocker.DamageMobj / TakeSpecialDamage.

A proxy that overrides DamageMobj and forwards its raw damage directly to a
controller can bypass the projectile's native DoSpecialDamage. A test projectile
whose callback returns exactly 100 caused 400 health loss on a 50%-resistant gate
in the failing run, instead of 50. The random native projectile roll had reached
the gate before that callback resolved it.

Keep Super.DamageMobj on the contact proxy and forward from TakeSpecialDamage,
after native projectile preparation. The controller applies resistance once;
the auxiliary proxy keeps enough health not to die independently. In the fixed
native test, the same collision removes 50 health once. Hitscan, explosions,
sweeps and idempotent group destruction also pass. API signatures were checked
in the installed target engine's zscript/actors/actor.zs.

Evidence: [before/after native diagnostics](../assets/validation_43615/engine_evidence.txt)
and [tested source hashes](../assets/validation_43615/manifest.json). The local
test fixture remains development-only; neither it nor the IWAD is distributed.
Regression: fire a fixed-DoSpecialDamage projectile at a multi-block gate and
check one correctly reduced health loss. Recheck callback order if the target
engine changes. Author acceptance: CA-43611-GATES-01 passed on 2026-09-26.

## CA-KP-011 â€” A solid damageable actor is not automatically an Impact Physics body

Status/evidence: RESOLVED-VERIFIED in the #19 correction; author-accepted on 2026-09-26.
First recorded / last checked: 2026-09-26 / 2026-09-26.
Affected baseline: bab1c776, CaelumGateBlocker / CaelumBreakableGate.
Environment: GZDoom 4.14.2, Windows 11/Vulkan, isolated MAP03.

The author reported zero damage to player and gate on a fast bodily collision.
Native TryMove reproduced both zeros. The finite blocks stopped movement and
forwarded weapon damage, but their collision callbacks were not connected to
Impact Physics; testing the siege-impact API alone did not cover that route.

Forward CollidedWith to the owning gate and resolve both bodies through the
shared core. Use whole-gate mass/contact identity and the gate plane, not each
tiny block's position as a separate impact. Reuse the character's receiver and
existing separation/rearm state, including serialization. Keep neutral gate
surface resistance separate from the canonical hardness subtraction.

Regression: actual native movement into a closed gate, health changes on both
sides above threshold, repeated block callbacks, separation, active-contact
save/reload, rotated geometry and open-passage safety. Before/after evidence and
tested hashes: [body collision evidence](../assets/validation_43615/body_collision/engine_evidence.txt).
The 13-check body suite and original 37-check suite pass. The author confirmed
CA-43611-GATES-01 fully passed on 2026-09-26, including the collision retest. Test-only
speed/health reserves are not gameplay tuning. Low-energy collisions can still
correctly cause zero damage under the existing formulas.

## CA-KP-012 â€” A composite mover must query collision with a solid active proxy

Status/evidence: ENGINE-VERIFIED. Recorded/checked 2026-09-26, issue #20,
4.36.16 worktree based on 40ca8919. Environment: Windows GZDoom 4.14.2,
development Doom II IWAD, Vulkan; fixture assets/IWAD are not distributed.
Scope: CaelumBatteringRam.MoveFrame / MoveHead and owned collision proxies.

Disabling all owned proxies avoids self-collision, but leaving the currently
queried proxy non-solid also bypasses actor blocking in the native TryMove
path. The first thin-head probe traversed its gate with zero registered
contacts. Conversely, enabling all overlapping proxies makes a composite
machine collide with itself. Query each proxy with its own SOLID flag enabled
and its siblings disabled; restore the group afterward. On a failed group
move, restore every component to the last committed pose, not only the final
proxy. The ram's head must use the thin visible striking plate: an enclosing
14-MU radius produced contact in front of the rendered plate.

Regression: actual chassis obstruction, rollback, <=0.5-MU plate/gate gap,
one native strike, frame-mass independence and NPC/player contact. The final
ram suite exercises those paths; hashes/results are in
[4.36.16 evidence](../assets/validation_43616/manifest.json). Flat-lane tests
also reject floor-height changes rather than floating over a step or ditch.
This does not establish support for ramps or rotating sectors. Author visual
acceptance CA-43612-RAM-01 remains pending.

## CA-KP-013 â€” Old map saves can retain the pre-feature EventHandler list

Status/evidence: ENGINE-VERIFIED. Recorded/checked 2026-09-26, issue #20,
4.36.16 worktree based on 40ca8919. Windows GZDoom 4.14.2, existing 4.36.15
MAP03 save copied for testing; originals are preserved.

Adding CaelumSiegeEvents to GameInfo worked on fresh maps but did not supply
the death observer to that old saved map. New rams loaded and advanced, then
stopped for missing crew after native `kill monsters`, but remained
neutralized=0 because their confirmed-death records never received an event.
Do not resolve this by interpreting a missing actor or zero nearby count as
a kill: unloading and temporary absence must remain distinct.

CaelumCombatActor.Die now forwards registered siege deaths after Super.Die
to the same idempotent ConfirmDeath receiver used by WorldThingDied. Ordinary
actors with no siege record retain their existing path. On fresh maps, the
second notification is harmless; on pre-feature saved maps, the native Die
bridge supplies the missing notification. No file rewrite or destructive
save migration is required. The same legacy input then neutralized all six
trial machines; subsequent save/reload must retain that result.

Evidence: before/after legacy runs and source hashes in
[4.36.16 evidence](../assets/validation_43616/manifest.json). This finding is
scoped to the tested EventHandler/save lifecycle, not every GZDoom callback.
The author confirmed CA-43612-RAM-01 passed on 2026-09-26 (HISTORY).

#405 reconfirmed this on 2026-10-21 (b425c0aa plus the 5.7.2 dirty patch).
Fresh MAP01 passed, but mapupgrade-01 restored no new resource coordinator or
roster from a real pre-feature save. Making the stateless coordinator a
StaticEventHandler fixed the same input (mapupgrade-02: 8 PASS); subsequent
save/reload also passed. Issued IDs and resource reserves stay in map actors.
Fixtures and before/after logs: assets/validation_572; original saves remain
for rollback. CA405-01 passed author review on 2026-10-22. MAPINFO registration alone cannot prove
that a new ordinary handler works on existing saved maps.

## CA-KP-014 â€” FastProjectile collision does not integrate gravity

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-09-26 / 2026-09-26.
Issue: [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21).
Baseline: 9676ec0d plus the #21 working tree; GZDoom 4.14.2, Windows/Vulkan.

The installed engine's `zscript/actors/shared/fastprojectile.zs` subdivides
movement according to radius and height and checks native actor, line and
plane collisions, but its Tick override never applies gravity. Merely clearing
NOGRAVITY does not produce a ballistic arc. CaelumCannonProjectile applies
native GetGravity() once per physical tic before calling Super.Tick, respecting
native freeze. Calendar acceleration is unrelated. Its 400 m/s converts to
365.714286 MU/tic, not a raw speed of 400 and not a slowed visual surrogate.

Native evidence: [#21 manifest](../assets/validation_43617/manifest.json).
In the isolated default-gravity map, a 10-tic unobstructed flight matched
z=z0+v0z*n-g*n*(n+1)/2 and vz=v0z-g*n; native g was 1 MU/ticÂ². Thin wall,
blocked muzzle, floor/ceiling and actor contacts were tested separately. A
subclass that adds gravity should not also run ordinary Actor movement, which
would advance the projectile twice. Default engine gravity here corresponds
to 38.28125 m/sÂ² at project units, not Earth's 9.80665 m/sÂ².

This finding is scoped to GZDoom 4.14.2 FastProjectile, not all actors. The
game's accepted general collision damage/crushing formulas remain unchanged.
Author acceptance CA-43613-CATAPULT-01 is pending.

## CA-KP-015 â€” Input and multi-frame attacks need one absolute clock

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-09-30 / 2026-09-30.
Issue: [#37](https://github.com/damiancurti/Caelum-Argenteum/issues/37).
Baseline: 29177813 plus the #37 patch; GZDoom 4.14.2, Windows/Vulkan.

In CaelumPlayer, native held-Fire input can observe the previous cooldown
before the player's normal timer update. Checking only that cached value
adds a tic between otherwise correctly timed attacks. RefreshWeaponAttackClock
checks the saved absolute start/deadline before accepting input. Delayed impact
must retain the remaining cycle instead of starting another full cooldown.

For multi-frame enemy casts, rounding every frame separately stretches fast
casts. CaelumCombatActor uses cumulative boundaries from the same start tic;
zero-duration intermediate poses advance immediately. The four tested Eloquence
levels produce complete cycles of 15, 12, 5 and 1 native tics, respectively.

Reproduction: hold Fire with the fixture's sword for 120 tics; compare successive
AttackAnimationStartTic values with Ceil(AttackAnimationDurationTics). Seven
intervals equal 15. Run the Zupay cast at Eloquence 0/33/100/1000 and observe
after the combat actor's Tick. A watcher created before that actor observes
stale state and can falsely report an extra tic. Likewise, test setup must run
after deferred PostBeginPlay initialization.

Evidence and source hashes: [4.36.26 results](../assets/validation_43626/RESULTS.json).
These isolated engine checks do not constitute author gameplay acceptance.

## Rules for adding and updating entries

1. Add an entry only for reusable engineering knowledge: a recurring failure, a non-obvious project constraint, or a verified cause/fix likely to prevent future work. Ordinary progress belongs in the issue.
2. Search for an existing ID/symptom before adding. Keep stable CA-KP identifiers and update the original entry instead of creating duplicates.
3. Record facts, hypotheses and approved requirements separately. A user-observed failure can be recorded immediately as AUTHOR-REPORTED; missing reproduction does not mean it is disproven.
4. Include the engine version, affected commit(s), path/symbol, scope, reproducible steps, evidence and limitations where available. Mark unavailable fields explicitly; never fabricate logs or confirmation.
5. To mark a defect RESOLVED-VERIFIED, retain the reproducer, identified cause, fix commit, before/after results and any residual risk. State whether the author accepted it; engine success alone is not author acceptance.
6. Record failed approaches only when they explain a trap or prevent a likely repeat. Do not paste entire conversations, speculative reasoning or raw session logs.
7. Link to durable repository/PR artifacts. Temporary sandbox paths and expiring downloads are not permanent evidence. Never commit credentials or private installation paths.
8. Recheck an entry when its owning code or engine version changes. Mark obsolete advice SUPERSEDED with a replacement reference; preserve unique history in HISTORY.
9. Keep entries concise (normally 150â€“300 words excluding a necessary small reproducer). Link to canonical formulas rather than copying large tables.
10. Review only the touched entries and connected rules during a patch. Do not add a full historical audit or additional engine run solely to expand this register.

## CA-KP-016 - Dormant map actors must not use STAT_STATIC

Status/evidence: RESOLVED-VERIFIED (native archive, hub, resurrection and exit).
First recorded / last checked: 2026-10-16 / 2026-10-16.
Issue / PR: [#304](https://github.com/damiancurti/Caelum-Argenteum/issues/304).
Affected baseline: 351b949a plus the initial 5.4.25 development archive.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, isolated MAP06/MAP98 hub.
Scope: CaelumCorpseArchive, CaelumRedemption.Pulse, CaelumResurrection.Restore.

STAT_STATIC is not merely a non-ticking queue: native DestroyAllThinkers skips
it, and hub loading skips its saved entries to avoid duplicating global actors.
Using it for map corpses preserved bodies but lost their references to ordinary
map actors on a round trip. Use a map-local non-ticking statistic below
STAT_FIRST_THINKING instead; the archive uses STAT_FIRST_THINKING - 1.
Snapshot eligible bodies before resurrection moves bodies and inventories
between native thinker lists. Do not allocate an archive in death callbacks:
Redemption cleanup can emit deaths while the engine is destroying the map.
Create the holder only during WorldTick; death callbacks only look it up.
Restart the local thermal clock when resurrecting an NPC, archived or visible;
otherwise the first NPCStep integrates the dead interval as if it had been alive.

Evidence: assets/validation_5425 fixtures/runners; local issue304-05 contains
the author's crash report. Its GZDoom PDB resolves the fault to GC::SingleStep
called by GC::FullGC/D_Cleanup. Earlier runs 01-08 preserve failures. Run09
restores all 105 bodies, exits normally, and preserves FIFO after save/hub
travel. Repeat redemption.cfg, save.cfg, load.cfg and travel.cfg to regress.
Author acceptance: CA304-01 passed on 2026-10-16 without reported exceptions
(origin 5.4.25 / #304), separately from the native assertions.
Limitations: dormant corpses retain memory; this is not actor destruction.

## Copyable entry template

```text
## CA-KP-NNN â€” Concrete symptom or constraint
Status/evidence: AUTHOR-REPORTED | CODE-VERIFIED | ENGINE-VERIFIED |
                 RESOLVED-VERIFIED | HYPOTHESIS | SUPERSEDED
First recorded / last checked: YYYY-MM-DD / YYYY-MM-DD
Issue / PR: repository links, or not recorded
Affected baseline: exact commit and dirty-tree qualification
Environment: engine version, OS, IWAD, renderer/config, save state as relevant
Scope: path, symbol, affected consumers
Symptom or constraint:
Reproduction: shortest steps and expected/observed behavior
Cause: verified explanation, or UNCONFIRMED
Fix / prevention: actual change and commit, or PROPOSED/PENDING
Evidence: commands, exit codes, durable artifact links and results
Regression check: smallest test that catches recurrence
Author acceptance: exact confirmed ID/date/qualifications, or PENDING/NOT REQUIRED
Limitations / superseded by:
```

For non-runtime constraints, mark engine reproduction not applicable and provide the static/source evidence. Empty template fields are not executed tests.
