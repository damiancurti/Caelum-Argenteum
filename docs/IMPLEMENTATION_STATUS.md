# Caelum Argenteum 4.0 — Implementation status

## Connected upper rooms and stable 10-call load 4.29.0q

**Implemented and structurally validated; manual MAP01 door acceptance pending**

The supplied V4.29.0p pair validates the reduced scheduler gate. Test A runs
for 368 complete reports with mass attacks disabled; test B immediately reloads
MAP02 in the same process and runs for 548 with full combat. Both acquire all
1,983 field targets, cap native Chase at 10 calls per tic and 350 per simulated
second, and retain exactly 16,500 lightweight actors. Contacts, callbacks and
contact references remain zero throughout.

Test B spawns 40 bounded projectiles and records all 40 impacts/destructions,
never retains more than one live missile and reports no spawn failure. It also
reaches 502 targets within 512 MU, whereas the failed V4.29.0p input run reached
only 175 before stopping at a 20-call gate. Local actor density and projectiles
therefore cannot be sufficient causes of the abrupt freeze. The variable that
still tracks stability is the number of native `A_Chase`/movement queries
admitted in one world tic.

MAP01 keeps the accepted two continuous T rooms. The old extreme-room openings
spanned Y=304..432 and Y=-432..-304; after the T reconstruction only 41 MU of
each opening actually overlapped a shared room wall. V4.29.0q closes those
obsolete portals, then creates four exact 64-MU connections at Y=400..464 and
Y=-464..-400. Each connection crosses both 8-MU wall rings and receives one
finite sliding leaf, groups 906–909, which retracts into the longer rear wall.

The original central dividers remain at X=364..372. Their 64-MU openings and
door groups 902/905 are validated rather than duplicated. All four 119×119-MU
landings, stairs, room footprints and the previous 210 Things remain fixed;
only four connection doors are added. MAP01 now has 460 vertices, 575 linedefs,
1,120 sidedefs, 99 sectors and 214 Things.

### V4.29.0q runtime procedure

In MAP01, open every new door from both sides and wait for it to close. Cross
each threshold while the door is open, stand in it through the close timer and
confirm the anti-crush hold. Walk the formerly open lower portions of all four
extreme-room walls and confirm they are now solid. Test both central divider
doors and all four stair landings without `noclip`.

For the final 10-call endurance gate, use full combat and move the player among
several points of the mass field for at least eight real minutes. This tests
reconvergence and different blockmap paths. Do not increase the Chase budget;
the next architectural step after acceptance is distance-tiered or shared
squad scheduling, not searching for the highest unsafe count.

## Continuous central rooms and lower pursuit gate 4.29.0p

**Implemented and structurally validated; manual GZDoom acceptance pending**

The V4.29.0o endurance file contains 119 complete telemetry intervals before
the abrupt stop. All 1,983 active AI actors had targets; custom contacts,
callbacks and retained references remained zero; the lightweight population
remained exactly 16,500 and live projectiles stayed between zero and one. The
last complete interval admitted 20 native Chase calls per tic and 699 during
the simulated second. No monitored counter grows toward the stop.

This invalidates 20 as a universally stable diagnostic ceiling. More
importantly, it reproduces the exact 119-report duration previously observed at
40 calls with main-field attacks disabled. Attack delivery, guided projectile
logic, custom collision and RPG helper objects are not necessary causes. The
shared active path is native `A_Chase` and spatial convergence. The next gate
therefore uses a hard default of 10 Chase calls per tic (350 per simulated
second at most), while Look remains at 7 phases and 20 calls per tic.

MAP01 is reconstructed from the accepted V4.29.0i/0n hash. The four separate
V4.29.0o blocks are not merged or patched. Instead, the old north and south
central contours are removed completely and rebuilt as two continuous T-shaped
rooms. Each room absorbs both rear wings, uses one tag-510 floor/roof component
and one tag-511 wall component, and has no residual seam at X=192 or X=544 in
the rear bar. The original middle dividers and their 64-MU door openings are
recreated after the continuous rooms.

The internal stairs still end at Y=±272. Their room fronts remain at Y=±391,
so the four reserved landings remain exact independent 119×119-MU squares.
Side rooms, six stair flights, passages and all 210 Things retain their accepted
positions. MAP01 contains 448 vertices, 559 linedefs, 1,088 sidedefs and 99
sectors.

### V4.29.0p runtime procedure

Set all server CVars before loading MAP02. First run Look and Chase with
main-field attacks disabled for five real minutes at Look 7/20, Chase 13/10.
Only if it remains responsive, start a fresh MAP02 load with attacks enabled
and repeat for five real minutes. The first report must literally show
`chase ... cupo/tic=10`; stop any invalid run. Do not increase the budget.

In MAP01, enter both T-shaped rooms with `noclip`, then disable `noclip` and
walk their entire inner floor, both halves and the two central door openings.
Walk all four green-reserved landing areas and verify that no invisible surface,
wall seam or fall-through remains. Existing side rooms and stairs must behave
as in V4.29.0n.

## Four closed upper blocks and stable pursuit boundary 4.29.0o

**Implemented and structurally validated; manual MAP01 acceptance pending**

The two V4.29.0n logs validate the reduced pursuit ceiling under both required
loads. The no-attack session supplies 319 complete telemetry reports and the
full-combat session supplies 506. Both reach all 1,983 target-bearing AI actors,
hold native Look and Chase peaks at 20 per tic and Chase throughput at 700 per
simulated second. Contacts, callbacks and references remain zero. The enabled
run retains at most two bounded projectiles. No counter trends toward a stop,
so 20 is now the accepted diagnostic ceiling; 40 remains rejected.

MAP01 retains the complete V4.29.0i/0n rooms and inserts four new closed blocks
only in the two gaps between rooms on each side of the central passage. Their
outer footprints are 313×153 MU; 8-MU native wall rings leave 297×137-MU
interiors. The north façades begin at Y=391 and the south façades at Y=-391.
Because the internal stairs end at Y=±272, each one retains an exact 119-MU
setback and a separate 119×119-MU landing aligned to its 119-MU flight.

The blocks end at Y=±544 and use the full available rear depth without moving
an accepted room. They are individual tag-510/tag-511 components, not another
continuous-row reconstruction. Existing side openings and door actors are not
repurposed, and every new block remains physically closed until the author
specifies its connections. MAP01 now has 454 vertices, 569 linedefs, 1,108
sidedefs, 107 sectors and 210 Things.

### V4.29.0o runtime procedure

Load MAP01 and inspect all four new blocks from roof level, ground level and
inside with `noclip`. Walk every 119×119 landing and the central passage without
crossing an invisible wall, falling through a surface or entering a new block.
Confirm the six stairs, existing rooms and all prior doors still behave exactly
as in V4.29.0n. Connections are deliberately absent.

For AI endurance, keep the accepted 7/20 Look, 13/20 Chase and 64-phase attack
settings. Run one three-load sequence with full combat: five minutes in MAP02,
reload MAP02, repeat, then reload once more and repeat while changing the
player's position. This tests map cleanup and repeated convergence; do not raise
the Chase budget above 20.

## MAP01 rollback and pursuit isolation 4.29.0n

**Implemented and structurally validated; manual GZDoom acceptance pending**

MAP01 is restored byte-for-byte to V4.29.0i, the accepted state immediately
before the continuous-room expansion. This rejects the complete V4.29.0l and
V4.29.0m geometry passes instead of trying to repair their overlapping walls,
missing landing space and open surfaces. The restored map has 398 vertices,
489 linedefs, 948 sidedefs, 99 sectors and 210 Things. Its valid divider and
rear-door additions remain; none of the later enlarged rows remains.

The four supplied V4.29.0m logs also correct the previous runtime assumption.
The server CVars entered after `map map02` were not live; their effective value
appeared on the next map load. Consequently the runs actually were: all
enabled for 34 reports, all disabled for 249, Look-only for 495, and Look plus
Chase with main-field attacks disabled for 119. Only the last run stopped.
Its final report retained zero contacts and callbacks, 16,500 lightweight
actors and a 40-update Chase peak. The isolated-room actors explain its single
projectile; the main field explicitly reported `ataques_masivos=0`.

This isolates sustained native pursuit/convergence as the next boundary. The
diagnostic Chase ceiling is reduced from 40 to 20 calls per tic. The scheduler
captures server settings once per map, and state actions no longer copy every
setting on every Look, Chase or attack attempt. This is both a stricter test
and a universal hot-path optimization for the diagnostic. Gameplay maps and
the nine isolated MAP02 rooms remain unchanged.

### V4.29.0n runtime procedure

Enter every server CVar before `map map02`. The first report after loading is
the authority; do not continue if its active flags differ from the requested
test. Run Chase without attacks for five real minutes. Only if it remains
responsive, repeat with attacks enabled. Both tests use Look 7/20, Chase 13/20
and attack stagger 64. If the first test freezes, stop there and repeat later
with a Chase budget of 10 instead of enabling attacks.

In MAP01 verify only the rollback: both central pairs, their middle divisions,
rear first-floor doors, balcony strips and stair landings must match V4.29.0i.
Do not extend or connect rooms in this patch.

## Live mass-AI controls and straight landing corridor 4.29.0m

**Implemented and structurally validated; manual GZDoom acceptance pending**

The three V4.29.0l logs stop after different durations but share the same
stable boundary: 16,608 combat actors, 1,983 active AI, zero custom contacts,
zero callbacks, zero to two projectiles and at most 40 admitted Chase updates
in any tic. No monitored value rises toward the abrupt stop. However, the two
intended disabled sessions did not actually disable their systems: the console
changed the CVars after the actors had cached their initial `true` values.
Consequently all three files are enabled-Chase samples, not a valid A/B result.

V4.29.0m moves those settings into `CaelumMassAIScheduler`. It reads CVars once
per world tic and every field actor reads only cached coordinator fields.
Look, Chase and attacks can now be changed while MAP02 is running, and the
telemetry shows the effective state on the next line. Look also receives a
hard default ceiling of 20 native calls per tic; Chase remains capped at 40.

The variable abrupt timing, stable counters and very large fixed ZScript object
graph make a collector/main-thread pause more plausible than contact or missile
growth. The diagnostic-only population is therefore lightweight: 16,500
mass/passive stress actors keep native thinker/state execution but do not own
permanent anatomy, armor or elemental-state objects and do not run the complete
Caelum RPG/contact Tick. The isolated test actors and all normal-map NPCs retain
the full model. Telemetry reports both lightweight and remaining helper counts.

MAP01 replaces the stair-shaped room fronts with straight façades at Y=±368.
Since all six upper landings end at Y=±272, the path between stairs and rooms is
exactly 96 MU and uninterrupted. Front doors move to Y=±372; middle doors move
to Y=±456. The rear balcony keeps its existing 96-MU offset, all stair modules
remain 119 MU wide and lateral room divisions stay closed for the next gate.

The colored HUD resource fills are manually accepted.

### V4.29.0m runtime procedure

Run four fresh MAP02 sessions: all three systems disabled; Look only; Look plus
Chase; then full combat. CVars are live, so a valid report must literally show
`look activo=0/1`, `chase activo=0/1` and `ataques_masivos=0/1` as requested.
The lightweight line should report approximately 16,500 actors and only the
isolated-room population should retain helper objects. Look peak must stay at
or below 20 and Chase peak at or below 40.

In MAP01 walk the full corridor behind every staircase, then inspect both
façades and roofs from above and below. No wall return may point toward a
landing; the front and rear balcony gaps must both measure visually alike.

## Bounded chase, colored HUD fills and continuous room rows 4.29.0l

**Implemented and structurally validated; manual GZDoom acceptance pending**

The supplied V4.29.0i log freezes after approximately 120 reported seconds
with 1,605 target-bearing actors and roughly 1,924 real `A_Chase` executions
per second. Contacts and custom callbacks remain zero, only four projectiles
are alive and no attack is accepted in the final interval. Every family reaches
a similar target saturation; rats dominate only because they are the largest
population. The earlier V4.29.0h run survived more cumulative Chase calls, so
the actionable boundary is concurrent native pursuit work rather than a simple
per-call memory leak.

V4.29.0l keeps dormant perception at seven phases and moves pursuit to an
independent thirteen-phase schedule. One registered `CaelumMassAIScheduler`
also caps the whole field at 40 admitted Chase calls per tic. Each actor caches
the handler and all CVar values once in `PostBeginPlay`. `ca_diag_mass_chase_enabled`
provides a target-retaining, no-movement control. Telemetry now reports the
actual peak per tic, phase/budget/pause deferrals, family updates and target
distance bands.

MAP01 no longer consists of six isolated room rectangles. The two first-floor
rows are clean, disconnected components of one tag-510 interior and one
tag-511 wall sector. Their fronts remain at Y=±192, preserving 96 MU of balcony;
the rooms expand behind the stair landings at Y=±272. Every flight remains
119 MU wide. Closed native dividers yield four rooms per row. Balcony doors
700/716/717/718 and middle doors 902/905 remain; obsolete side leaves
900/901/903/904 are removed until lateral openings are authored.

HUD-01 frames render before 164-MU inset fills, restoring every resource color
without painting over end caps. `CaelumText`, `NewSmallFont`, `SmallFont` and
their alternative small alias use `SpaceWidth 8`; letter kerning and HUD
`CaelumMono` are unchanged.

### V4.29.0l runtime procedure

Run three fresh MAP02 sessions for five simulated minutes each: Chase disabled
and attacks disabled; Chase enabled and attacks disabled; then both enabled.
Use Look 7, Chase 13, budget 40 and attack stagger 64 in all three. A stable
disabled run proves target ownership alone is safe; a stable no-attack Chase
run validates the native pursuit ceiling; the final run restores combat.

In MAP01 inspect all eight rooms, both balcony edges and all six stair modules
from above and below. Lateral dividers are expected to be closed. No room floor,
landing or exterior strip may be missing, collision-solid but invisible, or
crossed by a coincident wall.


## Cached perception scheduling, MAP01 doors and UI foundation 4.29.0i

**Implemented and structurally validated; manual GZDoom acceptance pending**

The stable V4.29.0h run shows that chase/attack phase separation can keep the
1,875 active actors responsive. V4.29.0i moves the remaining dormant cost—the
native `A_Look` scan—behind the same seven-phase schedule. Each main-field
actor captures the three diagnostic CVars and both deterministic phase keys
once at map load. The hot Look, Chase and attack paths therefore contain no
CVar lookup and no coordinate hash. Normal maps and the nine isolated MAP02
rooms execute their original native AI timing.

The monitor now separates Look attempts, updates and deferrals from Chase. At
the default value, a ten-tic Spawn loop admitted once per seven phases yields
one sight check per actor approximately every 70 tics. This is a diagnostic
foundation for the later stealth/group scheduler, not its final alert model:
formations, shared sightings, proximity wake-up and fair group attack tokens
remain future authored behavior.

MAP01 retains the author-accepted central first-floor shells byte-for-byte and
adds only four thin native divider targets around the two existing central
doors. The targets reuse sector 511 and its already working 3D-floor controls.
Four rear-room leaves form two additional double doors without changing room
footprints. Current structure is 398 vertices, 489 linedefs, 948 sidedefs, 99
sectors and 210 Things.

HUD/UI-01 supplies 94 independent runtime PNGs. `CaelumStatusBar` removes the
Doom face/status bar, while the permanent overlay keeps real resource values
and applies modular frames/icons. Tab opens a local six-section Journal and M
preserves the native automap. Inventory ownership and quantities are not
copied into UI storage. Only the existing active weapon/load and twelve
attributes are exposed now; the four not-yet-authored sections state that they
are pending.

### V4.29.0i runtime procedure

Set the diagnostic values before loading MAP02 because actors cache them in
`PostBeginPlay`:

```text
logfile ca_physics_4_29_0i.log
ca_diag_mass_attacks true
ca_diag_mass_ai_stagger 7
ca_diag_mass_attack_stagger 64
map map02
sv_cheats 1
warp 16368 -16 0
```

Run the field for at least three minutes. Do not lower the stagger values in
this candidate. Confirm that `[CA-AI] ... look` and `... chase` each report
attempted/executed/deferred counts, no custom contact graph grows, and input
remains responsive. Separately load MAP01 and validate both new divider walls
and both rear double doors from above, below and on both sides.


## Canonical MAP01 sector ownership and budgeted mass AI 4.29.0h

**Implemented and structurally validated; manual GZDoom acceptance pending**

The V4.29.0g rectangles were topologically closed but twelve of their edges
placed the intended front sector on the geometric left. The lower tag-510
control therefore existed while GZDoom resolved the tagged interior outside
the visible room, producing the photographed hole and ground-floor fall.
V4.29.0h gives both outer and inner contours one clockwise winding: sector 510
is on the right/front inside the room and sector 511 is on the right/front
inside the wall ring. No new surface or control sector was added.

The supplied stagger-3 run froze after its second complete report with 958
target-bearing actors, 16 live projectiles, zero contacts and zero custom
collision callbacks. The last combat interval contained only 57 attempts,
19 projectile spawns and three impacts. The remaining synchronous threshold is
the arrival of 634 rats at melee range and the native chase/collision work
around one player, not projectile retention or the Caelum contact graph.

Only MAP02's main field now uses `THRUACTORS`. Its `A_Chase` invocations are
distributed across seven deterministic phases and its attack deliveries across
64 phases. Rooms 1–9 and all normal maps use the original AI/collision timing.
The monitor reports chase attempts, updates and deferrals separately.

### V4.29.0h runtime procedure

```text
map map02
con_notifytime 10
logfile ca_physics_4_29_0h.log
sv_cheats 1
ca_diag_mass_attacks true
ca_diag_mass_ai_stagger 7
ca_diag_mass_attack_stagger 64
warp 16368 -16 0
```

Run one 60-second session. Do not repeat the rejected stagger values 3, 2 or 1.
For MAP01, load `map map01`, enable `noclip` and verify both central interiors
from below, above, inside and outside before any door or divider is restored.


## Clean MAP01 modules and staggered mass combat 4.29.0g

**Implemented and structurally validated; manual GZDoom acceptance pending**

MAP01's two central first-floor rooms no longer contain any part of the
V4.29.0c–f divider, threshold or door topology. Sixty lines and their 120
sidedefs were removed as one unit. Each replacement now consists of exactly
eight bilateral lines: four around one 336×336-MU interior and four around its
continuous 8-MU wall ring. The working end rooms and the common 3D-floor
controls for tags 510 and 511 were not rebuilt.

MAP02's main field now separates AI stress from island-physics stress. Its
15,000 bodies share a diagnostic species and `THRUSPECIES`; Rooms 7–9 still
retain full collisions for Quintaesencia. When attacks are enabled, the default
`ca_diag_mass_attack_stagger 3` distributes attempts between three deterministic
phases derived from each spawn cell. Straight projectiles and melee actions do
not damage another main-field actor, so one intercepted shot cannot trigger an
infighting cascade. A value of `1` restores the unthrottled V4.29.0f behavior.

The supplied no-attack log reached 1,983 targeted actors and 42,415 collision
callbacks/s without ending at that point. The attack run stopped after the
first second containing 97 projectile spawns and 28 impacts, while only 69
missiles remained live. This makes synchronous attack/impact work and crowd
cross-collision the actionable causes; retained projectiles and contact-list
growth are not required to reproduce the abrupt stop.

The mapping workflow is documented in
`docs/ULTIMATE_DOOM_BUILDER_TUTORIAL.md`. Doors and dividers remain intentionally
absent from the new central shells until visual and traversal acceptance.

### V4.29.0g runtime procedure

```text
map map02
con_notifytime 10
logfile ca_physics_4_29_0g.log
sv_cheats 1
ca_diag_mass_attacks true
ca_diag_mass_attack_stagger 3
warp 16368 -16 0
```

Run for 60 seconds or until a freeze. On a fresh `map map02`, repeat with
stagger values `2` and `1`, in that order, stopping after the first unstable
setting. Do not continue to a more aggressive setting after a freeze.

For MAP01, use `map map01` and inspect both central shells from ground floor,
first floor, exterior and below the slab. Closed walls are expected in this
candidate; doors and the divider are not.


## Continuous MAP01 slabs and isolated mass-AI combat 4.29.0f

**Implemented and load-validated in GZDoom 4.14.2; manual visual/performance acceptance pending**

The V4.29.0e threshold repair still treated the visible room surface and each
door/exterior band as different 3D-floor targets. Their lower and upper
controls could occupy the same height while remaining different render links,
which reproduced the reported solid-but-invisible surface from both the room
and its exterior. V4.29.0f removes that distinction instead of adding another
plane: every former tag-512 target is now tag 510 and therefore uses the same
128–136-MU floor slab and 256–264-MU roof slab as the adjacent room.

The independent 512 control rectangle, its upper duplicate link and an empty
sector inherited from the earlier rebuild are removed. The mansion surface
PNGs are also registered explicitly in flat/texture namespaces rather than
being available only through their sprite aliases. Current MAP01 structure is
510 vertices, 517 linedefs, 1,004 sidedefs, 98 sectors and 206 Things. Every
linedef has a valid front sidedef, bilateral flags agree exactly with back
sides, and there is no target or 3D-floor link 512.

MAP02 keeps all 16,608 combat actors and the exact 1,875-active main-field
stage. One native wall at X=8192 blocks actors, monsters and sight between the
spawn/test-room side and the mass field. GZDoom 4.14.2 runtime loading reports
zero main-field targets at baseline. The new server CVar
`ca_diag_mass_attacks` changes only attack execution inside that field:

- `false`: perception and chase remain active, but melee, Bull charge and
  projectile actions are counted and suppressed;
- `true`: the same actors execute their normal attacks using the existing
  bounded straight projectiles;
- all nine small diagnostic rooms ignore the gate and retain their authored
  behavior.

The monitor now prints family target/active counts and a combat line:

```text
[CA-AI] campo objetivos/activos ratas=0/1250 rulo=0/125 argento=0/125 caella=0/125 ronnie=0/125 toros=0/125
[CA-COMBAT] ataques_masivos=1 intentos/s=0 anulados/s=0 proj +0 impacto=0 vencido=0 destruido=0 fallo=0
```

Counters are integer increments on the existing actors/projectiles; no new
per-tic actor search was added. The MAP02-only monitor still performs its one
aggregate Thinker traversal per second.

### V4.29.0f runtime procedure

Start each logged session from the console:

```text
map map02
con_notifytime 10
logfile ca_physics_4_29_0f.log
```

Wait ten seconds at spawn. Every family numerator in `[CA-AI]` must remain
zero, `ia_objetivos=0` and `proyectiles=0`. Then run two fresh-map sessions:

```text
ca_diag_mass_attacks false
map map02
warp 16368 -16 0
```

and:

```text
ca_diag_mass_attacks true
map map02
warp 16368 -16 0
```

Observe each for 30 seconds or until a freeze. The first run should report
attack attempts under `anulados/s` with `proj +0`; the second exposes the
actual projectile creation/completion rate. The final complete line written
before a freeze is diagnostic evidence even if the failing tic never reaches
the next one-second report.

MAP01 acceptance is independent: walk over both central first-floor rooms,
the exterior bands at their lateral doors and the internal divider doorway;
inspect all six doors from both faces and verify every surface from above and
below. A visually absent but collision-solid band still fails acceptance.

## Central threshold closure and valid MAP02 coordinates 4.29.0e

**Implemented — pending GZDoom 4.14.2 runtime validation**

The supplied screenshots expose two independent construction regressions.
MAP01's four exterior leaves used `arg2=0`: their vertical WALLSPRITE faced the
authored opening, but their blocker row and displacement ran along X,
perpendicular to the wall. MAP01's target tag 512 also received only the lower
128–136-MU slab, leaving its six doorway sectors absent from the 256–264-MU
walkable roof. MAP02 failed before gameplay because Room 7 Things reached
approximately X=-50,288 and Room 8 vertices reached X=-32,800, outside the
engine-supported `-32768..32768` coordinate range.

Current corrections:

- door groups `900`, `901`, `903` and `904` now use `arg2=1`, matching the two
  divider groups `902` and `905`; all six slide parallel to their Y-axis wall;
- linedef 325 applies the existing upper 256–264-MU control slab to target tag
  512, while the original 128–136-MU threshold slab remains unchanged;
- Rooms 7–9 move to centers `(-24000,-18000)`, `(-24000,0)` and
  `(-24000,18000)` respectively;
- each room retains exactly 500 actors and remains 18,000 MU from its neighbor;
- MAP02 now ranges only from X=-24,800..24,576 and Y=-18,700..18,900 for
  vertices, and X=-24,288..24,288 and Y=-18,228..18,228 for Things.

The PK3 builder now checks the coordinate range of every UDMF vertex and Thing.
It rejects the V4.29.0d MAP02 at vertex 56 before packaging and accepts both
current maps. MAP01 remains 514 vertices, 521 linedefs, 1,008 sidedefs, 100
sectors and 206 Things. MAP02 remains 80 vertices, 71 linedefs, 134 sidedefs,
one sector and 16,610 Things.

### V4.29.0e runtime procedure

Start logging before each MAP02 session:

```text
map map02
con_notifytime 10
logfile ca_physics_4_29_0e.log
```

Use a fresh `map map02` before each position:

| Test | Command | Expected Seal count |
| --- | --- | ---: |
| Room 7 — native collision | `warp -24000 -18000 0` | 500 |
| Room 8 — complete Caelum contacts | `warp -24000 0 0` | 500 |
| Room 9 — same-species pass-through | `warp -24000 18000 0` | 500 |
| 1,875-AI main field | `warp 16368 -16 0` | Not a Seal-isolation test |

The fresh-map telemetry baseline should still be approximately
`actores=16608 ia=1983 ia_objetivos=0 objetivos=0 proyectiles=0`.

## Canonical MAP01 side table and bilateral-line repair 4.29.0d

**Implemented — pending GZDoom 4.14.2 runtime validation**

The V4.29.0c MAP01 retained 316 unreferenced sidedefs from removed room
iterations. Although every linedef contained a numeric `sidefront`, the live
references after linedef 420 jumped across those dead index ranges. In
addition, linedefs 461–520 carried `sideback` but did not declare
`twosided = true`. An editor or node builder that normalizes the side table can
therefore reject or reinterpret the later references.

V4.29.0d performs one canonical repair over the complete WAD:

- retain only sidedefs referenced by a live linedef;
- remap every `sidefront` and `sideback` to the compact table;
- require exactly one owner for each sidedef;
- add `twosided = true` to every linedef with `sideback`;
- reject `twosided = true` when no `sideback` exists.

Current MAP01 structure: 514 vertices, 521 linedefs, 1,008 sidedefs, 100
sectors and 206 Things. All 1,008 side references are unique and cover the
continuous range `0..1007`; every linedef has an in-range front sidedef; every
sidedef has an in-range sector; every line with a back side is explicitly
two-sided; and no one-sided line carries that flag. The room geometry, sector
heights, six door Things and their TIDs `900–905` remain unchanged from the
V4.29.0c reconstruction.

`tools/build_pk3.py` now applies these UDMF invariants to every embedded
`TEXTMAP`. It rejects the V4.29.0c MAP01 at linedef 461 and accepts current
MAP01/MAP02 before writing the PK3, so the earlier shallow range-only check can
no longer certify this failure mode.

Manual validation remains authoritative: load MAP01 in GZDoom 4.14.2, confirm
that node construction reports no missing front sides, and inspect both
central pairs plus all six doors from both faces.

## Native central-room rebuild and historical mass-AI replay 4.29.0c

**Superseded structurally by V4.29.0d; MAP02 staging remains current**

The V4.29.0b log contains five fresh-map sessions in the declared order:
Rooms 5, 6, 7, 8 and the main-field center. Its results separate three costs
that had previously appeared together.

| Session | Relevant peak/result | Interpretation |
| --- | --- | --- |
| Room 5 — straight projectile | 4 targets, 18 missiles, 1 callback | The mass-safe projectile route is bounded and adds no sustained contact work. |
| Room 6 — explosive projectile | Targets grow 4 → 199; 18 missiles; 0 callbacks | `A_Explode` propagates damage/targets and infighting even without moving bodies. |
| Room 7 — native Rat collision | 1,103 Seal targets; 240 callbacks once | The test was contaminated beyond its authored 500 Rats. |
| Room 8 — complete contacts | 1,755 Seal targets; 33,232 callbacks; 815 edges; max 12/actor | The room and neighboring populations were pulled together; pair duplication is measurable but bounded. |
| Main center | 2,065 Seal targets; 37,144 callback peak | Density, rather than retained historical edges, is the dominant trigger. |

At the end of the main-center session, after Channel release, the log still
shows 4,718 raw callbacks but only 18 retained edges, `max/actor=4`, 503 unique
pair-tic attempts, 28 duplicates and 4,599 resting rejections. This validates
the V4.29.0b cleanup: the former large retained graph and per-callback object
allocation are no longer the principal post-release cost. GZDoom continues to
report thousands of native collisions while solid bodies remain physically
stacked, so low simulated-time FPS can persist without a logical contact leak.

### MAP01 reconstruction

The finite-panel approach is retired for the two central first-floor pairs.
Each north/south pair is rebuilt in this order:

1. one continuous exterior rectangle from `x=192` to `544`, spanning
   `y=192..544` north or `y=-544..-192` south;
2. one 8-MU native outer wall ring;
3. two interiors divided only by the native `x=364..372` wall;
4. one centered 64-MU door sector in that divider;
5. one centered 64-MU exterior door on each lateral wall.

The four former front doors move to `(196, ±368)` and `(540, ±368)` at angle
0. Internal doors remain at `(368, ±368)`. Their TIDs `900–905`, first-floor
height 136 and sliding-door arguments are unchanged.

The V4.29.0c artifact contained 514 vertices, 521 linedefs, 1,324 sidedefs, 100
sectors and 206 Things. Its geometry and removal of `CaelumFiniteWallPanel`
remain current, but the 316 orphaned sidedefs and missing bilateral flags are
corrected by V4.29.0d.

### MAP02 staged AI and isolated Quintessence rooms

The total main-field population remains 15,000, but it now contains the exact
historical 1,875 active-AI stage:

- 125 Rulo;
- 125 Argento;
- 125 Caella;
- 125 Ronnie;
- 125 Bulls;
- 1,250 active Giant Rats;
- 13,125 remaining passive stress actors.

The active actors closest to `(16368, -16)` are selected deterministically;
the farthest is approximately 3,417 MU from that center. Including Rooms 1–6,
the fresh-map telemetry baseline should be approximately:

`actores=16608 ia=1983 ia_objetivos=0 objetivos=0 proyectiles=0`

`ia` counts living classes that execute perception, chase or attacks.
`ia_objetivos` counts only those active classes with a target. `objetivos`
still counts every actor with a target, including passive bodies affected by
damage; the difference exposes the exact contamination observed in Room 6.

The three 500-Rat matrices keep their collision variants and remain separated
by 18,000 MU. V4.29.0e replaces the invalid V4.29.0c positions with these
in-range console positions after every fresh `map map02`:

| Test | Command | Expected Seal count |
| --- | --- | ---: |
| Room 7 — native collision | `warp -24000 -18000 0` | 500 |
| Room 8 — complete Caelum contacts | `warp -24000 0 0` | 500 |
| Room 9 — same-species pass-through | `warp -24000 18000 0` | 500 |
| 1,875-AI main field | `warp 16368 -16 0` | Not a Seal-isolation test |

Manual validation order:

1. Load MAP01 and inspect both central pairs from every room, corridor, ground
   floor and roof. Confirm continuous walls, correct floors/roofs and all six
   doors opening from both sides.
2. Load a fresh MAP02 and record ten seconds of the baseline above.
3. Run Rooms 7, 8 and 9 separately from a fresh map. Channel Quintessence for
   five seconds and observe twenty seconds after release. Each run must report
   exactly 500 affected actors; otherwise the isolation still failed.
4. Load MAP02 again, use `warp 16368 -16 0`, do not Channel, and let the
   1,875-AI population pursue and attack for sixty real seconds. Record FPS,
   input responsiveness and all three telemetry lines until either stabilization
   or the first abrupt freeze.
5. If this exact historical stage remains responsive, increase later patches
   in the prior sequence: 3,750 → 7,500 → 15,000 active AI. Do not combine the
   stages, because the first failing population is diagnostic evidence.

Validated Seal behavior/formulas, crafting and V4.27 input deferral remain
unchanged.

## Simple mass projectiles and collision hot-path reduction 4.29.0b

**Implemented — pending controlled GZDoom 4.14.2 runtime validation**

The V4.29.0a telemetry rejects the retained-contact graph as the sole cause of
the post-Quintessence slowdown. In the 2,000-actor sample, callbacks reached
approximately 30,000 per reported simulated second and remained high while
the bodies stayed physically stacked, but the retained graph stayed much
smaller. Explosive Argento fire also produced a clear callback increase,
especially after radial damage caused infighting. These are real repeated
native collision events, not merely historical contact references.

V4.29.0b therefore reduces the amount of Caelum work performed for every such
event. A shared pair resolves once per tic; later callbacks only refresh its
liveness. Coincident, separating or effectively resting callbacks return
before body construction, normalization and square root. Every player and
combat actor lazily owns three reusable work objects (`ImpactBody` source,
`ImpactBody` target and `ImpactResult`) instead of allocating them in the
collision hot path. Native collision detection still has an unavoidable cost,
but duplicate callbacks no longer multiply the custom impulse calculation or
temporary-object churn.

Rulo, Caella, Ronnie and Argento now use the mass-safe projectile route. It is
straight, finite-range, single-impact and non-explosive. It preserves the
prepared attack result, critical flag, elemental payload, magical push and
Eloquence-derived maximum range. It performs no seeker target lookup, steering
or radial victim search. The old explosive behavior remains as an explicit
class for authored explosive weapons and the controlled Room 6 comparison.

The MAP02 monitor now writes three `[CA-PHYS]` lines per simulated second. In
addition to actors, targets, missiles, contacts and reference churn, it reports:

- `unicos`: contact pairs on which Caelum actually began one resolution tic;
- `duplicados`: later callbacks for a pair already resolved that tic;
- `reposo`: callbacks rejected as coincident, separating or below threshold;
- `sello_afectados`: actors in the current player's Channel target set.

Rooms 7–9 form an equal three-way Quintessence comparison with 500 passive
Rats in each room:

| Room | Collision configuration | Purpose |
| --- | --- | --- |
| 7 | Native solid collision; Caelum contacts disabled | Native-engine baseline |
| 8 | Native solid collision plus complete Caelum contacts | Exact custom-physics increment |
| 9 | Caelum contacts disabled plus same-species pass-through | Channel scan/force cost without pair collisions |

The original 15,000 passive stress actors remain outside these isolated rooms.
All nine rooms share one valid UDMF sector with 71 linedefs, 134 sidedefs and
no missing front sides.

MAP01 retains its finite-wall architecture. The four central first-floor
panels at `x=368` now all cover 72 MU, and each interior reverse face receives
only a 0.25-MU offset along the panel normal. The previous global X/Y shift
moved an angle-90 reverse face partly along its width and exposed its endpoint
from inside; that diagonal displacement is removed.

Manual validation for this candidate:

1. In MAP01, inspect both central first-floor room pairs from inside and from
   the corridor. The four wall endpoints must remain closed with no flicker or
   duplicate collision surface.
2. Reload MAP02 before each test. Compare Rooms 5 and 6 for thirty seconds;
   Room 5 must use straight single-impact shots, while Room 6 retains the
   intentionally expensive explosion/infighting case.
3. Test Rooms 7, 8 and 9 separately with a five-second Quintessence channel,
   then observe twenty seconds after release. Record FPS and all three
   telemetry lines. Room 8 minus Room 7 estimates Caelum contact cost; Room 7
   minus Room 9 estimates native Rat-to-Rat collision cost.
4. Repeat the 2,000-actor pile once. High raw `callbacks/s` may remain because
   the engine is still resolving stacked solid bodies, but `unicos` must be
   bounded to at most one resolution per pair/tic and custom allocations must
   no longer scale with callbacks.

Validated Seal effects/formulas and crafting behavior are unchanged.

## Bounded contact pressure and controlled MAP02 rooms 4.29.0a

**Implemented — pending controlled GZDoom 4.14.2 runtime matrix**

The reported Quintessence cluster exposed two independent conditions. First,
Giant Rats inherited `THRUSPECIES`, so Rat-to-Rat overlap could not generate
the contact graph required for pressure or crushing. Second, every historical
pair remained in both actors' arrays while its centers stayed inside a broad
release distance, even when the engine had stopped reporting actual
collisions. A converging `A_Chase` crowd could therefore retain increasingly
large arrays and linearly search them on later callbacks.

V4.29.0a removes Rat species pass-through and makes collision callbacks the
authoritative liveness signal. A shared edge expires after five complete tics
without another callback; the existing distance test remains as an additional
release condition. Sustained contact records at most one impulse sample per
tic, sums the real transmitted impulse for 35 tics, and converts that sum back
to its two-body equivalent closing speed for the existing mass/anatomy/impact
pipeline. No fixed walking speed is substituted.

This correction deliberately remains a bounded pair graph. Repeated
action/reaction impulses can propagate through adjacent edges, but the code
does not yet solve every connected member and constraint simultaneously as a
single aggregate-mass island. That larger solver remains conditional on the
results below because a full component traversal could itself increase crowd
cost.

MAP02 preserves the original 15,000 passive actors and adds eight rooms. The
north row is numbered 1–4 west to east; the south row is numbered 5–8 west to
east. Every room uses ordinary two-sided blocking walls, an internal
sight-breaking baffle and an invisible player-passable/monster-blocking
threshold. All 64 linedefs have valid front sides.

| Room | Population | Isolated variable |
| --- | ---: | --- |
| 1 | 25 Rats | `A_Look`/target acquisition only; no chase or attack |
| 2 | 25 Rats | `A_Chase`, native solid collision, no Caelum contacts/attack |
| 3 | 25 Rats | Same chase as Room 2 plus bounded Caelum contacts |
| 4 | 25 Rats | Complete current Rat AI, melee and Caelum contacts |
| 5 | 4 Argento | Stationary shooting; projectile Death omits `A_Explode` |
| 6 | 4 Argento | Identical stationary shooting with normal `A_Explode` |
| 7 | 100 passive Rats | Controlled Quintessence pressure |
| 8 | 500 passive Rats | Larger Quintessence pressure and cancellation load |

The MAP02 monitor writes two `[CA-PHYS]` console lines each second: actor and
target totals, live projectile count, approximate shared contact edges,
maximum contacts held by one actor, collision callbacks per second, and
created/removed contact references. The original passive field is expected to
keep `objetivos=0` and contribute no contacts until physically disturbed.

Manual validation must run each room from a fresh `map map02` load:

1. Record the untouched baseline for ten seconds; contacts and projectiles
   should remain zero and controls must be responsive.
2. Enter Room 1 and wait thirty seconds. If this alone freezes, investigate
   target acquisition/base actor Tick rather than movement or collisions.
3. Repeat separately in Rooms 2 and 3. Room 2 must report zero Caelum contacts;
   any large regression appearing only in Room 3 identifies the custom graph.
4. In Room 4, let all Rats converge, then run directly into the cluster from
   several angles. Verify mass-dependent displacement, pressure damage along
   contacted neighbors, and bounded `max/actor` rather than historical growth.
5. Compare Rooms 5 and 6 for thirty seconds each. A regression unique to Room
   6 isolates explosion/status/area-contact churn from perception and firing.
6. In Rooms 7 and 8, channel Quintessence for five seconds while centered,
   cancel it manually, and record affected count, cancellation response,
   contact peak, `max/actor`, deaths and recovery. Rat-to-Rat contacts and
   some pressure damage are now expected; complete overlap without contact is
   not.
7. Repeat the worst room three times from a fresh map and compare the same
   baseline. If performance degrades while live contacts/projectiles return to
   baseline, inspect allocation/GC or engine caches; if the counters remain
   elevated, inspect the corresponding logical subsystem first.

MAP01, all author-validated Seal effects and crafting behavior are unchanged.
The V4.29 crafting roadmap remains authorized but receives no recipe-content
change in this diagnostic patch.

## MAP01 safe rollback and V4.29 authorization 4.28.0bp

**Seal track validated; MAP01 parallel; V4.29 authorized**

- The author validated Fire, Earth, Air, Water and Quintessence Seal behavior,
  including the corrected element binding, mass response and gravity handling.
- V4.28 Seal mechanics are accepted. Weather extensions remain deferred to
  the Version 5 calendar/weather module as planned.
- The V4.28.0bo MAP01 geometry is rejected because GZDoom's node builder
  reported linedefs 569–590 without usable front sides.
- MAP01 is restored byte-for-byte to the loadable V4.28.0bn version and no
  longer blocks major-version progression. Its large-room reconstruction is a
  parallel architecture task.
- Material and special-item HUD isolation is retained and awaits a short
  pickup regression test.
- The complete V4.27 input matrix is deferred by author decision until the
  crafting system is complete.
- V4.29 Crafting Completion and Persistent Recipe Book may now begin.

## Geometry-native first-floor rooms and material HUD isolation 4.28.0bo

**Rejected — invalid GZDoom node-builder result; superseded by 4.28.0bp**

- Both mirrored central first-floor modules in MAP01 are now large rectangular
  rooms built from UDMF geometry, without finite wall actors.
- Each room has one centered door in its left wall, one in its right wall and
  one in the central dividing wall.
- The two former front entrances are closed with the standard wall sector.
- Coincident internal linedefs were removed during consolidation to prevent
  duplicated faces and z-fighting.
- `CaelumSpecialInventoryItem` is excluded from the native inventory bar, so
  materials and key/special items cannot replace the player face.
- Consumables and ammunition remain available through their independent
  native-bar definitions.
- Bull sprites, Seal effects and MAP02 are unchanged.

Pending runtime validation: inspect all wall faces and three doors from both
sides, confirm correct door collision/opening, and collect several material
types while watching the player face.

## MAP01 wall orientation, equipment HUD isolation and Bull sprites 4.28.0bn

**Implemented — pending manual GZDoom 4.14.2 validation**

- MAP01 contains the four valid finite wall panels at `x=368`, angle 90, and
  no angle-0 perpendicular finite wall panels.
- `CaelumEquipmentItem` is excluded from the native inventory bar, covering
  weapons, armor, shields, amulets and Seals through their common base class.
- Consumables remain available through their independent native inventory
  class and `INVBAR` flag.
- Bull rear Charge frames `BULLF5` and `BULLG5` now show the authored rear
  views.
- Bull Death frames `BULLI0` through `BULLN0` use transparent 96x64 PNGs; the
  final frame has a complete head and no duplicated or clipped face.
- MAP02 remains unchanged with 15,000 passive stress actors.

Pending runtime validation: confirm the intended walls from both sides in
MAP01, verify that no custom equipment pickup replaces the player face, and
check Bull rear Charge rotation and Death offsets in motion.

## Mass-resisted Seals and elevated Quintessence epicenter 4.28.0bm

**Implemented — pending manual GZDoom 4.14.2 validation**

Quintessence now centers its sphere 160 map units above the player: exactly
five meters at the established 32-units-per-meter development scale. Targets
therefore converge overhead instead of through the owner's collision volume.
Continuous attraction and Air's clockwise tangential/vertical acceleration
divide the applied force by each target's authoritative mass. The existing
Quintessence release formula remains `10 × trapped mass / expelled mass`.

Earth channeling no longer calls either Freeze or Dazzle. Poison remains its
only elemental status and visual, while a new presentation-independent Earth
penalty preserves the radial reduction of movement and accuracy: 100% at the
center, 50% at half radius and 0% at the boundary. Actual Ice attacks continue
to own Freeze and its visual exclusively.

Seal pickups no longer participate in GZDoom's native inventory bar. Caelum's
own inventory and equipment system remains authoritative, and collecting a
Seal cannot replace the native HUD face with that Seal's icon.

Validation focus:

1. Channel Quintessence among a crowd and confirm targets gather overhead
   without crossing and collision-killing the player.
2. Compare a Giant Rat and Bull under Air and Quintessence; the Bull must
   accelerate substantially less because of its greater mass.
3. Channel Earth and confirm Poison plus radial statistic reduction with no
   Freeze state, frozen visual or Ice presentation.
4. Collect all five Seals and confirm the player face remains unchanged.

## MAP01 panel rollback and authoritative Seal binding 4.28.0bl

**Implemented — pending manual GZDoom 4.14.2 validation**

The bilateral visual reconstruction from `4.28.0bk` is reverted. MAP01 no
longer places any of its eight `CaelumFiniteWallPanel` actors, including the
interior wall indicated in the supplied screenshot and the panels adjoining
the entrances. They are deliberately open rather than covered by another
actor-wall experiment. Sliding doors again have one visual leaf, eliminating
the second coincident-looking texture introduced in the previous patch.

Seal channel actors now retain the exact Seal inventory object that created
them. Every tic validates that this object is still the equipped Seal and
reads the effect type from it; unequipping or replacing it destroys the old
channel. The HUD selection and the applied element can therefore no longer
diverge through a surviving Fire channel actor.

MAP02 is unchanged from `4.28.0bk`: 15,000 passive, solid and damageable stress
actors with no target acquisition, chase, facing or attack calls.

Validation focus:

1. View and operate MAP01 doors from both sides; each leaf must show one
   texture, with no doubled rear leaf.
2. Inspect the eight removed panel positions; they must be empty and must not
   retain an invisible collision wall.
3. Channel Fire, stop, equip each other Seal and channel again. The applied
   mechanic must always match the equipped element shown by the HUD.
4. Confirm MAP02 retains 15,000 passive actors and its validated responsiveness.

## Rebuilt bilateral walls/doors and passive stress population 4.28.0bk

**Implemented — pending manual GZDoom 4.14.2 validation**

The first-floor actor walls no longer place their reverse visuals at a fixed
diagonal offset. Each back panel is reconstructed from its master's actual
orientation, positioned 0.5 MU along the local normal and rotated 180 degrees.
Sliding doors now use the same two-visual representation: one master front
leaf owns the existing collision/blockers and a synchronized non-solid rear
leaf follows every opening and closing movement.

MAP02 now uses six passive stress subclasses. All 15,000 actors retain their
normal profiles, mass, radius, height, solidity, anatomy, elemental response,
Pain and Death states, but Spawn/See/Melee/Missile contain no `A_Look`,
`A_Chase`, target facing, charge or projectile/melee call. This isolates actor
count, rendering, collision and Seal processing from AI and combat decisions.

Validation focus:

1. Inspect every rebuilt upper wall and door from both sides, particularly the
   room shown in the supplied screenshot and the entrance-facing doors.
2. Open and close each rebuilt door from either side and confirm both faces
   move together without doubled collision.
3. Start MAP02 and approach the entire population: no actor may acquire,
   pursue, turn toward or attack the player or another actor.
4. Damage representatives of all six passive types and confirm Pain, Death,
   solidity, physics and Seal effects still operate.
5. Compare responsiveness while viewing and entering the passive 15,000-actor
   crowd against the previous active-AI result.

## Southern tornado Seal and first-floor seam closure 4.28.0bj

**Implemented — pending manual GZDoom 4.14.2 validation**

The Air Seal now adds clockwise horizontal tangent velocity and positive
vertical velocity instead of radial expulsion. Its direction is viewed from
above and follows the project's southern-hemisphere convention. Air and
Quintessence record each target's original `NOGRAVITY` flag, suspend gravity
only while that target remains affected, and restore the original value when
the target leaves, the owner is interrupted or channeling ends normally.

The Earth Seal computes Freeze and Dazzle power from distance to the channel
center. A continuous piecewise squared curve produces exactly 100% at the
center, 50% at half radius and 0% at the boundary. The existing 1.1-second
refresh, poison damage, channel radius, tier costs and cooldown are unchanged.

The remaining MAP01 slit shown from inside the central first-floor room was a
terminal render seam behind the nominal 64-MU closure. The mirrored terminal
panels at `x=368`, `y=±540`, height 136 now span 72 MU. Their 4-MU overlap at
each endpoint closes the visible joint while retaining finite upper-floor-only
collision and the existing first-floor topology.

Validation focus:

1. View the indicated central-room wall from the supplied firing position and
   confirm no black vertical seam remains.
2. Inspect both mirrored closures from either side and from the ground floor.
3. Channel Air beside several masses and confirm clockwise orbit plus lift.
4. Walk or throw a target outside Air and verify gravity resumes immediately.
5. Repeat with Quintessence, including normal release and Pain interruption.
6. Compare Earth targets at center, half radius and boundary for approximately
   100%, 50% and 0% movement/accuracy penalties.
7. Confirm MAP02 still contains and can awaken all 15,000 combatants.

## Full post-island stress population 4.28.0bi

**Implemented — pending manual GZDoom 4.14.2 validation**

MAP02 now contains exactly 15,000 combatants: 1,000 each of Rulo, Caella,
Ronnie, Argento and Bull, plus 10,000 Giant Rats. Every actor occupies a unique
position on the existing 96 MU grid, and the enclosure, entrance and geometry
remain unchanged. Contact islands, once-per-second crushing, straight explosive
projectiles, Eloquence-derived range and the 350-tic absolute projectile
safeguard remain unchanged.

Validation focus:

1. Confirm the initial chamber remains responsive before acquisition.
2. Wake all 15,000 combatants and record the first sustained frame drop.
3. Distinguish stable low frame rate from progressive loss of responsiveness.
4. Continue after projectiles expire and verify whether performance recovers.
5. Enter the central contact pile and monitor active contact count.

## Range-bounded projectiles and UI-safe contact telemetry 4.28.0bf

**Implemented — pending manual GZDoom 4.14.2 validation**

MAP02 returns to the previously validated population of 937 combatants: 63
Rulo, 63 Caella, 62 Ronnie, 62 Argento, 62 Bulls and 625 Giant Rats. Its
16,384×16,384 MU enclosure, dogleg entrance and actor positions are unchanged.

Player and combat actors now store an array of shared `ImpactContactState`
objects rather than one replaceable actor reference. Each state is the edge
between two bodies; connected edges therefore form an implicit contact island.
The state remains active until its bodies exceed the established release
distance for five consecutive tics.

An initial collision still uses `ImpactPhysics.ResolveBodies` and may apply
ordinary collision trauma. Later collision callbacks for the same pair perform
an allocation-free inelastic momentum transfer and cannot apply a second
impact while contact persists. Every 35 sustained-contact tics, crushing
resolves a synthetic collision at the pusher's current walking speed. It uses
the existing source and receiver effective masses, contact-height interval,
anatomy, Toughness and armor pipeline; the receiver's biological landing
absorption is subtracted before the damage curve. There is no independent
crushing base damage or arbitrary multiplier.

Rulo, Caella, Argento and Ronnie now fire straight explosive elemental
projectiles instead of calling `A_SeekerMissile` every tic. Their explosion
uses the same base radius and direct-damage ratio as the player's Statuette.
Their magical attack decision and projectile distance now share the player's
authoritative range rule: 3,200 MU multiplied by Eloquence Type 4
`AbilityRangePercent`. Unimpacted projectiles self-destruct as soon as they
exhaust that distance, while 350 tics remains an absolute safeguard.

The debug UI no longer calls the play-scope `GetImpactContactCount` function.
Player `Tick` caches `ImpactContactCountForUI`, and the overlay only reads that
numeric field, preserving GZDoom's play/UI context boundary.

Validation focus:

1. Confirm MAP02 loads with exactly 937 combatants and remains quiet at spawn.
2. Wake all populations and let them collide and exchange projectiles.
3. Run through the central pile and confirm the game remains responsive.
4. Observe `Contacts` on the physics debug page while touching several bodies.
5. Confirm one collision causes at most one trauma event until true separation.
6. Confirm sustained pushing can propagate through several touching actors.
7. Hold a heavy actor against a lighter body for several seconds and compare
   the once-per-second Crush result with a walking-speed collision.
8. Confirm NPC projectiles fly straight, explode on impact and disappear after
   ten seconds when they miss.

## Wall reverse rendering and texture-package validation 4.28.0az

**Implemented — pending manual GZDoom 4.14.2 validation**

The repeated first-floor slit persisted because `CaelumFiniteWallBackPanel` used `NOINTERACTION`. The reverse actor therefore failed to remain available to the sector renderer. It now remains render-linked while `NOBLOCKMAP`, absence of `SOLID`, `CANNOTPUSH` and `DONTTHRUST` keep it outside collision and Impact Physics. Front and rear visuals remain separated by 0.25 MU to avoid coplanar depth rejection.

Font directories use kerning `-4` and one additional pixel of `SpaceWidth`. One transparent right column was also removed from every glyph, so template fonts created by `FONTDEFS` receive the same one-pixel tightening even when they do not consume `font.inf`. `FONTDEFS` now carries the matching larger word spaces. The five classic main-menu actions are patch graphics rather than live text, so `M_NGAME`, `M_OPTION`, `M_LOADG`, `M_SAVEG` and `M_QUITG` are replaced by CaelumText-rendered Spanish labels.

The supplied startup log identifies `sprites/caelum/weapons/` as invalid texture data. The existing development archives contain explicit zero-byte ZIP directory records in texture namespaces, while all 3,166 PNG files decode successfully and have positive dimensions. `tools/build_pk3.py` packages files only, validates PNG headers and dimensions, rejects every empty source file, verifies the ZIP and atomically replaces the output. This directly removes the only invalid texture resource exposed by the log and addresses the later `Trying to create zero size texture` fatal at its concrete package-level source.

Manual validation:

1. Build exclusively with `python tools/build_pk3.py src build/caelum_argenteum_dev.pk3`.
2. Confirm startup no longer prints `Invalid data encountered for texture`.
3. Inspect the central first-floor wall from both directions.
4. Verify spacing in HUD, options and the main-menu labels.
5. Repeat the 937-actor projectile test. If the fatal recurs, preserve the new log and crash stack because no zero-sized package entry should remain.

## Closed connector ends and 937-actor stress step 4.28.0ay

**Implemented — pending manual GZDoom 4.14.2 validation**

The black vertical strip visible through the central first-floor rooms belongs to the old 64-MU connector band between the two equal rooms. Its front and rear ends remained visually open. Four new 64-MU finite panels now close those ends at coordinates `x=368`, `y=±196/±540`, height 136. Each is a single smooth wall section using the existing finite-wall renderer and collision, so the closure does not extend infinitely through the ground floor.

Letter kerning remains `-3`. Only `SpaceWidth` increases by two pixels in every family, making word boundaries clearer without reopening the spacing between individual letters. The Debug profile remains unchanged at twelve attributes of 90.

MAP02 retains its 17 vertices, 17 linedefs, 17 sidedefs, one sector and original enclosure. Its new total is exactly 937 stress actors: 63 Rulo, 63 Caella, 62 Ronnie, 62 Argento, 62 Bulls and 625 Giant Rats, plus the player start. The two equal fractional remainders were assigned deterministically to Rulo and Caella.

Manual validation:

1. Stand at the position shown in the supplied screenshot and verify that neither end of the obsolete connector reveals the map background.
2. Inspect the same four closures from the opposite side and from the ground floor.
3. Confirm menu and HUD word spacing while individual letter spacing remains unchanged.
4. Wake all 937 MAP02 actors and note whether projectile activity still causes a freeze.

## Exact wall spans and 1,875-actor stress step 4.28.0ax

**Implemented — pending manual GZDoom 4.14.2 validation**

The four central first-floor finite wall panels previously covered 136 MU each, leaving 4-MU slits at the exterior endpoints. They now use exact 140-MU spans. Their centers move from ±268/±468 to ±266/±470, producing continuous ranges 196–336 and 400–540 on both wings while preserving the 64-MU central doorway from 336 to 400. No extra overlapping panel or collision layer is introduced.

Every bitmap family now uses kerning `-3`; `SpaceWidth` remains unchanged. The Debug creation profile's central attribute constant is 90, so all twelve attributes are reset to exactly 90 after equipment bonuses whenever the Debug profile is applied or recalculated.

MAP02 retains the 17 vertices, 17 linedefs, 17 sidedefs, one sector and original 16,384×16,384 MU stress enclosure. Its population is now 125 Rulo, 125 Caella, 125 Ronnie, 125 Argento, 125 Bulls and 1,250 Giant Rats: 1,875 test actors plus the player start.

Manual validation:

1. Inspect the four endpoints of both central wall dividers from inside and outside.
2. Verify both 64-MU internal door openings remain unobstructed.
3. Check menu, options, console and HUD letter spacing without losing word separation.
4. Create a Debug character and confirm all twelve attributes read 90.
5. Wake all 1,875 MAP02 actors and record whether the engine freezes or remains responsive.

## Direct transition and 3,750-actor stress step 4.28.0aw

**Implemented — pending manual GZDoom 4.14.2 validation**

MAP01 now uses `nointermission`, bypassing Doom's inherited completion statistics and moving directly to MAP02. This is provisional: a future Caelum intermission may report project-specific information such as elapsed time, exploration, objectives, casualties and resource use.

Typography keeps the validated size and contrast from 4.28.0av, but all letter pairs use kerning `-2` instead of `-1`; `SpaceWidth` remains unchanged so word separation stays visibly greater than letter separation. The native main menu remains intact and its title uses the higher-resolution `CAMLOGO` through `hires/M_DOOM.png`, retaining the original 132×65 logical footprint so it cannot overlap the options.

The central-room reverse wall face no longer occupies exactly the same rendering plane as its forward face. It is offset by 0.25 MU in X and Y, which is visually negligible but prevents coplanar depth rejection. Collision remains exclusively on the master panel and its blockers.

MAP02 preserves its entire enclosure and reduces each population exactly by half: 250 Rulo, 250 Caella, 250 Ronnie, 250 Argento, 250 Bulls and 2,500 Giant Rats. The result contains 3,750 stress actors plus the player start.

Manual validation:

1. Confirm MAP01 Exit reaches MAP02 without showing Doom statistics.
2. Check that letters are tighter while spaces between words remain clear.
3. Inspect every central finite wall from both sides and confirm one collision surface.
4. Verify the larger menu logo does not overlap selectable items.
5. Wake all 3,750 MAP02 actors and record whether the engine freezes or remains responsive.

## Native-menu recovery and legibility pass 4.28.0av

**Implemented — pending manual GZDoom 4.14.2 validation**

The 4.28.0au `ListMenu "MainMenu"` declaration contained a logo but no selectable items. In MENUDEF, that declaration replaces the inherited menu definition rather than decorating it, so the game displayed only the logo and directional input produced sounds without a usable selection. The override has been removed. `M_DOOM` continues to provide the Caelum logo, while GZDoom supplies the complete native menu structure and actions.

The bitmap families retain their fixed cell height and shared baseline. Ordinary serif and monospaced roles increase by one point and gain a dark one-pixel outline behind a bright translated foreground. Large/intermission roles decrease from 15 to 12 points to correct the oversized MAP01 completion presentation.

Manual validation:

1. Start the game and confirm that every main-menu entry is visible, selectable and functional.
2. Check main, options, controls, video, audio and console screens for the Caelum family and adequate contrast.
3. Verify HUD and dialogue text at the normal gameplay resolution.
4. Finish MAP01 and confirm the intermission typography is smaller than in 4.28.0au.

## Explicit menus, complete central pairs and 7,500-actor field 4.28.0au

**Implemented — pending manual GZDoom 4.14.2 validation**

The main menu now has a project-owned `MENUDEF`: it draws the transparent `CAMLOGO` emblem and requests `CaelumText` directly. `FONTDEFS` explicitly rebinds `NewSmallFont`, `NewConsoleFont`, `SmallFont`, `ConsoleFont` and `BigFont`, covering the modern option menus as well as classic list menus. `GameInfo.CreditPage` points to `TITLEPIC`, so Doom II's inherited credit image no longer alternates with the project title screen.

MAP01 activates the previously reserved sectors 93-95 for the south-central pair using control tags 510-512. It mirrors the validated north topology: one continuous exterior volume, two equal rooms, two independent exterior sliding doors and one door through the midpoint divider. Geometry near coordinate ±30,000 remains deliberately remote because it supplies the stacked-sector control planes used by GZDoom's 3D floors.

MAP02 keeps exactly the same room, start chamber, dogleg and unique-position distribution from 4.28.0at. Only population counts change: 500 Rulo, 500 Caella, 500 Ronnie, 500 Argento, 500 Bulls and 5,000 Giant Rats. The 7,500 actors remain deaf/ambush until acquiring sight.

Manual validation:

1. Confirm the main menu shows `CAMLOGO`, never `M_DOOM`, and the title loop never shows Doom II credits.
2. Open the main, settings, controls, video and audio menus and verify the Caelum typeface in every one.
3. Inspect both central MAP01 pairs: equal floor areas, continuous exterior walls, two exterior entrances and one midpoint door per pair.
4. Confirm the distant control geometry remains inaccessible during normal play and all first-floor surfaces remain present.
5. Wake the 7,500 MAP02 combatants and record whether the engine remains responsive. No push/contact-island code changed in this revision.

## Titanic isolated stress field and finite-wall reverse faces 4.28.0at

**Implemented — pending manual GZDoom 4.14.2 stress validation**

The narrow first-floor section that was visible externally but transparent internally was the reverse side of a one-sided `WALLSPRITE`. Every finite wall panel now creates one synchronized visual reverse face. The reverse actor has no interaction and creates no collision blockers, so physical behavior remains owned solely by the original panel.

Typography retains the shared-baseline cells introduced in 4.28.0as but increases each role moderately. Compact interface and monospaced families use bold faces, and all gameplay HUD labels request the engine's standard text shadow to remain readable against bright or detailed surfaces.

MAP02 now contains one remote 16,384×16,384 MU enclosure with 15,000 mixed combatants: 1,000 each of Rulo, Caella, Ronnie, Argento and Bull, plus 10,000 Giant Rats. A two-turn corridor blocks every initial line of sight, and `ambush` prevents remote sounds from waking them. Initial positions are unique, reproducibly shuffled and spaced 96 MU apart.

The earlier freeze has not been reproduced since remote awakening was isolated and NPC homing projectiles gained a ten-second lifetime. Infinite lost projectiles remain the leading causal candidate, but the two corrections were introduced together and therefore do not constitute a single-variable proof. An unbounded projectile population adds permanent thinkers whose seeking, movement and collision work executes every tic; a saturation freeze may leave no script error because the main loop is overloaded rather than throwing an exception.

Manual validation:

1. Inspect the corrected MAP01 wall from inside and outside; both faces must be opaque while collision remains single and finite.
2. Review HUD, menus, character creation and console for baseline, size and contrast.
3. Start MAP02 and remain in the initial chamber; no combatant may see, hear or attack the player.
4. Traverse the dogleg and enter the single enclosure; verify all six populations are interspersed rather than stacked.
5. Record frame rate, responsiveness, actor activation time and whether finite-lifetime projectiles disappear. With 15,000 active AI actors, severe slowdown may represent an engine capacity limit rather than the former unbounded-growth defect.

## Corrected north-pair entrances and font metrics 4.28.0as

**Implemented — pending manual GZDoom 4.14.2 validation**

The first 4.28.0ar room placement incorrectly aligned the midpoint divider with the only newly closed exterior gap. V4.28.0as closes that central opening as wall and restores both original 64-MU entrance positions. Each of the two equal rooms now has one exterior single-leaf sliding door, while the midpoint wall retains a third single-leaf door for internal communication.

The original supplied glyph PNGs were tightly cropped to different heights. GZDoom draws Unicode glyph patches from a common top origin, so lowercase, capitals, accents and descenders did not share a baseline. Every family is now regenerated on fixed-height transparent cells with one baseline. The classic HUD/console family is reduced to 10 pixels, `CaelumMono` is requested explicitly by both project overlays, and the modern engine aliases are supplied for menus and the console.

Manual validation:

1. Confirm each north-central room has its own exterior sliding entrance.
2. Confirm the central exterior face is solid and the midpoint divider does not intersect either entrance.
3. Open and close both exterior doors and the internal door from both sides.
4. Check that capitals, lowercase letters, accents and descenders share one baseline in HUD and character creation.
5. Confirm the HUD fits around every bar and that menus and console visibly use the new family.

## North-central room prototype and typography 4.28.0ar

**Implemented — pending manual GZDoom 4.14.2 architectural/font validation**

The 4.28.0aq interpretation of the central rooms is superseded. The north-central pair is now one continuous 336×336 MU exterior body. A finite wall at its exact midpoint divides it into two equal 168×336 MU rooms and contains one 64-MU single-leaf lateral door. There is no connector room or narrow passage between them. Only this pair is active; the mirrored south pair and lateral rooms remain neutral until the prototype passes manual validation.

The supplied font package is merged into the main PK3. Standard GZDoom font names are replaced globally, while the named Caelum variants remain available for later role-specific ZScript and MENUDEF use. Coverage includes printable ASCII, Latin-1 and Spanish punctuation. The supplied guide is stored as `docs/TYPOGRAPHY.md`, and the DejaVu redistribution notice is included under `licenses/DejaVu-copyright.txt`.

The complete MAP02 stress sequence passed: sound did not wake unopened rooms; Bulls crowded and collided; Caella, Argento, Rulo and Ronnie were introduced sequentially; Giant Rats were killed through impacts; and the surviving actors fought centrally without freezing. The 4.28.0aq containment is therefore validated. Contact-island physics remains a planned robustness improvement rather than the current reproduced cause of the freeze.

Manual validation:

1. Inspect the north-central pair from every exterior side: it must read as one large rectangular room volume.
2. Confirm the interior consists of exactly two equal rooms separated by one wall and one sliding door, with no intermediate passage.
3. Check floor, ceiling and outer walls from both floors and verify the stair landing remains clear.
4. Review main menu, character creation, HUD, inventory, console and debug overlay at 640×360 and 320×200 for missing accented glyphs or unreadable sizes.
5. After approval, reflect this exact room topology into the south-central pair.

## Central rooms, authored music and bounded MAP02 projectiles 4.28.0aq

**Implemented — pending manual GZDoom 4.14.2 validation**

The four central first-floor rooms in MAP01 again target the existing native 3D-floor controls: the two 64×64 links use floor/roof tag 510, their walls use tag 511 and their door/threshold regions use tag 512. This repairs the reported holes, irregular floor and absent walls without placing actor panels over the stair landing.

The title screen and MAP01 use `CA_MUS01`; MAP02 uses `CA_MUS02`. The embedded files identify the work as `The Argentine Omen` and the artist as `marjaja197` (metadata also notes creation with Suno).

The latest freeze sequence exposed two test-contamination risks. Because all MAP02 populations share a connected sound region, one pistol shot could alert actors outside the room being tested. Every test actor is now marked ambush/deaf and therefore ignores remote sound until it sees the player. NPC homing elemental projectiles also had an unbounded one-tic `Spawn` loop; each now self-destructs after 350 tics (ten seconds) if it has not impacted first. This patch does not yet replace the one-reference contact latch with contact islands.

Manual validation:

1. Inspect all four central MAP01 rooms from above and below: continuous floor, regular roof, complete walls and a clear stair landing.
2. Confirm `01` plays on the title screen and MAP01, while `02` plays on MAP02.
3. Fire inside one MAP02 room and confirm actors in unopened rooms remain asleep.
4. Wake Caella, Argento, Rulo and Ronnie populations individually and verify lost projectiles disappear within ten seconds.
5. Repeat the previous multi-group sequence; if it still freezes, record which populations are simultaneously visible/contacting so the contact-island implementation can be scoped.

## Rat room restoration, title screen and freeze diagnosis 4.28.0ap

**Implemented — pending manual GZDoom 4.14.2 validation**

MAP02 now has a seventh isolated room containing twenty Giant Rats. Its dedicated zigzag corridor blocks every initial sight line, as do the six previous rooms. Total population is 140 test actors: twenty each of Training Dummy, Rulo, Argento, Caella, Ronnie, Bull and Giant Rat, plus one player start.

The author-supplied 1920×1080 presentation image is registered explicitly as `TITLEPIC` through MAPINFO and stored in the graphics namespace.

The inventory is no longer a supported freeze hypothesis because the failure reproduced without opening it. Actor count alone is also insufficient: ranged NPC crowds and the initial Bull pile remained responsive. The strongest code-level hypothesis is the single-reference contact latch. Every body stores only one `ImpactContactActor`; in a dense moving pile, new contacts overwrite older references. Once both members of an older pair point elsewhere, that still-touching pair is treated as new and allocates two `ImpactBody` objects plus one `ImpactResult`, resolves another impulse and may overwrite more links. Bull pursuit, charge mass and a narrow corridor continuously rearrange neighbors, creating a feedback loop capable of producing allocation and impulse churn.

No physics change is included in 4.28.0ap. The next physics correction should replace the one-contact pointer with bounded multi-contact or island state, retain separation-based rearming and avoid per-contact heap allocation during collision callbacks.

Manual validation:

1. Confirm the new title screen appears before starting a game.
2. Enter only the Giant Rat room and repeat the prior twenty-rat tests.
3. Reproduce the Bull sequence: enter, allow crowding, leave, then approach the corridor again.
4. Do not mix groups during the reproduction; record whether the freeze occurs while Bulls contact one another, a wall or the player.
5. Confirm the other six rooms remain initially unaware of the player.

## Compartmentalized large-scale MAP02 4.28.0ao

**Implemented — pending manual GZDoom 4.14.2 validation**

The unapplied 4.28.0an package is superseded. Sewer source assets now follow the Windows-safe project order `src/graphics/caelum/textures/sewer`; the patch does not create a directory beside the root `TEXTURES` file.

MAP02 is now a large connected field with a central empty start and six distant rooms connected through two-turn corridors. It contains no Giant Rats. Each room contains twenty instances of exactly one test type: Training Dummy, Rulo, Argento, Caella, Ronnie or Bull. All 120 test actors begin behind native sight-blocking walls and have no direct line of sight to the player start.

MAP01.wad remains byte-identical to 4.28.0al/4.28.0am. MAPINFO assigns MAP02 as its next map so the existing normal Exit advances to the separate actor field.

The loose `CAF*` and `STF*` graphics are native status-face lumps selected by name. Files in the graphics namespace do not become inventory actors, and no face file is referenced by the equipment catalogue. The reported appearance of faces as equipable items therefore remains open for reproduction and must not be treated as a folder-placement fix.

Manual validation:

1. Start MAP02 and remain in the central chamber; confirm no actor attacks or acquires the player immediately.
2. Enter one room at a time and verify its population remains isolated from the other five groups.
3. Stress-test twenty actors of one type before opening a second room or using area effects.
4. Confirm there are no Giant Rats anywhere in MAP02.
5. Test MAP01's existing Exit and confirm it changes to MAP02.
6. If a face appears as equipment, record its inventory category, displayed name and icon before changing face assets.

## Separate architecture and actor maps 4.28.0am

**Implemented — pending manual GZDoom 4.14.2 validation**

MAP01 is now the architecture-only mansion test and remains byte-identical to its stable 4.28.0al state. MAP02 is a new independent actor arena built from one flat sector, four ordinary outer boundaries and no mansion or actor-based architecture.

MAP02 contains one player start, four Training Dummies, the four elemental NPCs, one Bull and twenty active Giant Rats. The groups begin separated so AI acquisition, collisions, inventory behavior, Seal effects and mass attacks can be observed without 3D-floor or sliding-door interactions.

Manual validation:

1. Load MAP01 and confirm its architecture-only stability remains unchanged.
2. Enter `map map02` in the console and remain stationary while the active actors acquire targets.
3. Test `noclip`, inventory, rat contacts, the Bull and area attacks independently.
4. Do not recombine actors with MAP01 until both maps remain stable separately.

## Actor-free architecture diagnostic 4.28.0al

**Implemented — pending manual GZDoom 4.14.2 validation**

The freeze also occurred while native `noclip` was active, so physical contact is no longer the primary hypothesis. MAP01 temporarily contains no monster, NPC or Training Dummy. The twenty Giant Rats, Bull, Rulo, Argento, Caella, Ronnie and four dummies are absent. The barred enclosures introduced only for 4.28.0ak are also removed.

The current first-floor room pair, ground-floor ceiling slabs, stairs, landing, doors, pickups and crafting infrastructure remain unchanged. This isolates the map architecture and non-combat world actors without modifying Impact Physics or gameplay code.

Manual validation:

1. Remain at the player start for several minutes.
2. Traverse the ground floor, stairs, landing and both implemented upper rooms with and without `noclip`.
3. Open the inventory in several areas.
4. If the freeze remains, remove the current upper-room pair for a direct architectural comparison.

## Isolated collision test enclosures 4.28.0ak

**Implemented — pending manual GZDoom 4.14.2 validation**

The Bull previously stood inside the approximately twenty-rat group and could push many bodies simultaneously, preventing a clean distinction between player/rat crowd contacts and Bull-driven displacement. MAP01 now has two closed, non-adjacent barred enclosures. All twenty normal active Giant Rats remain together in the western enclosure; the Bull is centered in a separate eastern enclosure. The bars block players and monsters while preserving visibility.

No collision formula or latch behavior changes in this diagnostic patch. The observed `noclip` result points to physical contact, but remains provisional until the two groups are tested independently.

Manual validation:

1. Remain outside both enclosures and confirm the Bull cannot touch or push any rat.
2. Enter only the rat enclosure with `noclip`, disable it inside and test the complete crowd without Bull interference.
3. Enter the Bull enclosure separately and test one Bull/player collision.
4. Confirm both barred contours remain closed and neither actor group escapes.

## Bilateral multi-contact latch for actor crowds 4.28.0aj

**Implemented — pending manual GZDoom 4.14.2 stress validation**

The stationary-rat test still froze after physical contact, disproving both AI load and ordinary actor count as the root cause. Impact Physics stored only one `ImpactContactActor` on each body. When a player contacted several rats, the player's pointer moved to the newest rat while earlier rats still pointed to the player. The player-side test then treated those older pairs as new every tic and repeatedly allocated `ImpactBody`, `ImpactBody` and `ImpactResult` objects.

Player and combat actors now treat a pair as latched when either side still references the other. This preserves the existing separation/rearm rule while preventing repeated allocation and impulse delivery for simultaneous crowd contacts. The twenty MAP01 actors are restored to the normal pursuing `CaelumGiantRat`; the diagnostic stationary subclass and DoomEdNum 18030 are removed.

Manual validation:

1. Remain near the complete active rat group for at least two minutes.
2. Let the group surround and physically push against the player.
3. Walk through the group repeatedly and open inventory while surrounded.
4. Confirm each rat still pursues and bites for base damage 60.
5. Confirm a separated rat can collide again after the established contact-rearm interval.

## Stable twenty-target Giant Rat area test 4.28.0ai

**Implemented — pending manual GZDoom 4.14.2 validation**

The freeze is confirmed to occur without opening inventory when the complete rat group enters its simultaneous `A_Look`/`A_Chase` range. MAP01 now uses `CaelumGiantRatAreaTest` for its twenty-target cluster. This subclass retains the Giant Rat body, mass 10, combat profile, quadruped anatomy, elemental statuses, Pain and Death, but deliberately has no target acquisition, chase or melee state.

The normal `CaelumGiantRat` remains available as the actual enemy with chase and base bite damage 60. The stationary test subclass exists only to make Fire, Earth, Air, Water, Quintessence and other mass attacks reproducible without mixing the measurement with twenty concurrent AI routes.

Manual validation:

1. Approach and circle the complete group without a freeze.
2. Open inventory beside the group.
3. Apply each Seal effect and confirm all authorized targets respond.
4. Confirm Pain and Death function and Quintaesencia still uses each rat's mass 10.
5. Spawn a normal `CaelumGiantRat` separately and confirm it still chases and bites for base 60.

## Ground-floor ceiling restoration and Giant Rat crowd fix 4.28.0ah

**Implemented — pending manual GZDoom 4.14.2 validation**

Native 3D-floor slabs again cover the eight actual room footprints, restoring the ground-floor ceilings and reserving the future first-floor walking surfaces. The two obsolete 64×64 central connectors remain untagged, so no slab or collision crosses the central corridor. Upper walls and doors remain limited to the manually accepted western pair from 4.28.0ag.

Opening the custom inventory does not enumerate nearby actors, but it immobilizes the player while the simulation continues. The approximately twenty test rats could therefore converge into one same-species collision pile. Giant Rats now use `THRUSPECIES`: they continue colliding with and attacking the player while passing through other Giant Rats. Mass, bite damage, targeting and elemental-area eligibility are unchanged.

Manual validation:

1. Inspect every ground-floor room ceiling and confirm its footprint matches the room above it.
2. Cross beneath the central corridor; confirm both former 64×64 connector slabs are absent.
3. Approach the full rat group and open/close inventory repeatedly while they converge.
4. Confirm rats still attack and collide with the player but no longer block one another.

## Incremental first-floor rebuild: pair 1 4.28.0ag

**Implemented — pending manual GZDoom 4.14.2 validation**

The complete actor-surface first floor from 4.28.0ae is rejected after a runtime freeze while the player crossed beneath its central elevated span. All upper finite floor, roof and wall panels are removed. Native 3D-floor controls now target only the two western rooms, one per wing; every other former upper polygon is assigned to an untagged neutral sector and therefore creates no upper volume.

Only four upper sliding leaves remain: the two exterior doors of the western north/south pair. The central corridor contains no upper actor bridge or blocker grid. Ground-floor geometry, doors, lintel, Seal systems and the approximately twenty Giant Rats are unchanged.

Manual validation:

1. Cross the entire central corridor and the stair landing repeatedly without a freeze or pause.
2. Inspect both western upper rooms from below, inside and above.
3. Confirm each room has a continuous floor and correctly oriented roof.
4. Open both double doors from each side and confirm both leaves slide laterally.
5. Confirm no wall, collision or invisible floor belonging to the other six rooms remains.

## GZDoom 4.14.2 elemental-visual compatibility 4.28.0af

**Implemented — pending parser and manual gameplay validation**

The elemental-status visual helper now receives a typed `class<Actor>` and calls the native static factory as `Actor.Spawn`. This replaces the object-scope call that GZDoom 4.14.2 rejected at `CaelumElementalStatus.zs:192`. No elemental damage, duration, target filtering or balance value changes in this compatibility patch.

Manual validation:

1. Confirm the PK3 parses and MAP01 starts in GZDoom 4.14.2.
2. Apply burn, poison, freeze and lightning and confirm the attached effects follow their owner and disappear with the status.
3. Confirm horizontal lightning projectiles and vertical Water-channel strikes retain their correct orientation.

## Seal Channel, Giant Rat tests and first-floor rebuild 4.28.0ae

**Implemented — parser correction supplied in 4.28.0af; manual GZDoom 4.14.2 validation pending**

User2 now starts the area effect defined by the equipped Seal and a second press interrupts it. Channeling spends exactly 3/6/9 Adrenaline each 35-Hz tic for T1/T2/T3, cannot begin without the first tic's cost, and starts a 60-second cooldown whenever it ends. Pain, death, losing/changing the Seal or reaching insufficient Adrenaline also ends it.

The player is stationary and cannot attack, Block, Aim, Reload, charge, cast, use consumables, Tarot, racial or class abilities while channeling. Fire, Earth, Air, Water and Quintessence have their authored non-weather effects. The area selector accepts living combatants of every allegiance, neutral NPCs, corpses and missiles; it does not accept inventory, pickups, stations, doors or map architecture.

Manual validation:

1. Equip each Seal tier and confirm exact consumption of 105/210/315 Adrenaline over one second.
2. Confirm User2 starts/stops the effect and every termination path starts a 60-second cooldown.
3. Confirm movement, attacks, Reload/charge, Zoom/Block, AltFire, User1, User3, User4, Use and consumables are suppressed.
4. Confirm Pain, death, zero Adrenaline, unequipping or changing the Seal interrupts immediately.
5. Test each elemental effect against enemies, allies, neutral NPCs, corpses and projectiles; verify pickups, doors and stations remain untouched.
6. For Water, place 1/2/4 actors inside the impact area and confirm the modified 10,000 pool is divided once across them.
7. For Quintaesencia, compare actors of different mass and verify release follows `10 × total trapped mass / individual mass`.

Climate modifiers by Seal tier are intentionally pending the Version 5 calendar/weather module.

The Seal HUD identifies the equipped element/tier, active channel and remaining cooldown. The development Adrenaline control adds 100 Adrenaline and removes 10 seconds from the Seal cooldown. MAP01 contains approximately twenty Giant Rats for mass-area testing; each rat uses quadruped anatomy, mass 10, approximately 40 cm height, all twelve attributes at 1 and base bite damage 60.

The first floor is an experimental full-wing rebuild with four similarly sized rooms per wing, one internal connection per adjacent pair and a clear stair-landing corridor. Original 3D-floor room-floor/roof controls were restored, finite bridge surfaces remain only where a real span is required, and door leaves choose their lateral axis from doorway orientation. Manual validation of floor continuity, roof orientation, lateral door travel and landing clearance remains mandatory.

## Stair-back closures, contextual Block dash and Giant Gauntlets AltFire 4.27.0g

**Implemented — pending manual GZDoom 4.14.2 validation**

The two north and two south gaps behind the intermediate staircase pairs are each closed by an independent conventional sector. Every strip is eight map units deep, has a 136-MU walkable floor and is aligned with the established room-back plane at `y=±640`; no free-standing middle texture or self-referencing sector is used. The four arena perimeter walls now display the large weathered cobblestone atlas crop `CMWV01`.

Mansion PNGs now live under `graphics/caelum/textures/mansion`. This avoids the case-insensitive Windows collision between the root `TEXTURES` lump file and a sibling `textures` directory while retaining engine-visible eight-character resource names.

The jewelry failure was a presentation-state reset: crafting instantiated `CaelumSealPickup` or `CaelumAmuletPickup`, but opening the equipment menu immediately replaced the selection with Armor/head. The menu now synchronizes armor fields only when Armor is the selected family, so a newly crafted Seal or Amulet remains visible and selectable.

Giant Gauntlets AltFire uses the same catalogue damage, reach and Air cost as Fire. A successful damaging uppercut applies the normal horizontal physical push and adds that calculated push force to vertical velocity; it therefore continues to respect the attacker's push multiplier and the target's effective mass instead of introducing an unrelated launch constant.

When Zoom begins a valid shield Block while the next attack is charged, horizontal velocity is set forward to 150% of the character's live maximum run speed. Attribute and elemental movement multipliers are read at activation; Pain/immobilization prevents the dash. The charged state is not consumed, because it remains attached to the next attack.

Manual validation:

1. Inspect and cross all four intermediate stair-back strips from ground, stair and roof level; confirm no side or upper plane escapes.
2. Confirm all four outer perimeter walls use the large cobblestone and room interiors retain their current material.
3. Craft a Seal and an Amulet separately, reopen equipment and verify the proper family/icon instead of Armor/head.
4. Compare Giant Gauntlets Fire/AltFire range, Air and damage, then confirm only AltFire launches a living target upward.
5. Charge a compatible melee or magic weapon, press Zoom with a shield equipped and confirm Block plus one forward 150%-maximum-speed impulse; confirm the next attack still consumes the charge.

MAP01 structure: 198 vertices, 264 linedefs, 520 sidedefs, 76 sectors and 186 things.

## Charge HUD, jewelry selection, rear-wall faces and mansion textures 4.27.0f

**Implemented — pending manual GZDoom 4.14.2 validation**

The combat HUD now displays `Charging: N.Ns` during the speed-scaled preparation and `Charged/Potenciador: N.Ns` during the three-second empowered window. The value reads the authoritative state timer rather than estimating it from animation frames.

Amulet and Seal crafting already spawned the correct native subclasses. The apparent helmet result came from the equipment menu always reopening on its default armor/head selection. Successful jewelry crafting now selects the created kind, type and tier before refreshing the inventory preview.

The two rear structural strips retain their closed 8-MU geometry and lower `STARTAN3` faces. Their new closure sidedefs no longer carry middle textures, removing the duplicate patches rendered above the intended wall height.

The author-supplied 1536×1024 mansion atlas was separated into 81 engine-ready PNG resources, subsequently relocated in 4.27.0g to `graphics/caelum/textures/mansion` for Windows compatibility. Every filename is an eight-character map-texture identifier.

Manual validation:

1. Inspect both restored rear walls from ground and roof level; confirm no wall patch floats above them.
2. Charge a melee and magical weapon while stationary and moving; confirm the countdown follows actual progress.
3. Let the charge complete and confirm the potentiator countdown begins at three seconds and disappears on attack, Pain, switch or expiry.
4. Craft one amulet and one seal; open inventory and confirm each created item is selected instead of a helmet.
5. Inspect the `CMEX`, `CMIN`, `CMST`, `CMWD`, `CMRF`, `CMGR`, `CMPW`, `CMPF` and `CMWA` families in SLADE or the map editor before assigning them to production geometry.

## Static charged-projectile classes 4.27.0e

**Implemented — pending parser confirmation in GZDoom 4.14.2**

GZDoom 4.14.2 does not expose Actor `SetSize` to ZScript. Charged standard, homing and explosive magical projectiles therefore use dedicated subclasses with `Radius`, `Height` and `Scale` fixed in each `Default` block. Attack routing selects the corresponding charged class before spawning it, retaining all parent homing, elemental, damage, durability and explosion behavior without runtime geometry mutation.

## GZDoom 4.14.2 charged-projectile compatibility 4.27.0d

**Implemented — pending parser confirmation in GZDoom 4.14.2**

The charged magical projectile now changes collision dimensions through Actor `SetSize` and replaces the complete visual `Scale` vector. ZScript does not permit direct compound assignment to the exposed `Radius`, `Height`, `Scale.X` or `Scale.Y` values. This revision fixes the parser error at `CaelumPlayer.zs:9057` without changing the intended `sqrt(2)` linear multiplier or any 4.27.0c gameplay value.

## Rear-wall restoration and contextual charged Reload 4.27.0c

**Implemented — pending manual GZDoom 4.14.2 validation**

MAP01 remains on the V4.26.5r pre-gate baseline. This patch adds only two closed, 8-MU-deep structural strips beside the rear-room door so the missing wall faces return on the stair and room sides. The four training dummies are moved laterally to `y=-900`. No main gate, connector corridor or terrace partition has been restored.

Reload is now contextual. Ranged weapons retain their existing magazine reload. Melee and essence weapons begin a 2-second base charge multiplied by the current physical attack-duration or casting-duration multiplier. Moving during either reload or charge applies a 50% movement multiplier and a 50% progress multiplier. On completion, the charged state lasts 3 seconds.

The next valid charged attack consumes 200% Air or Anima and inflicts 200% damage. Magical projectile collision/visual dimensions and explosion radius use a `sqrt(2)` linear multiplier, which doubles planar area. Pain, charge expiry and weapon switching remove the state. Fire/AltFire cancel an active shield Block before attacking. Empty ranged Fire automatically requests Reload if compatible inventory ammunition remains.

Manual validation:

1. Inspect both sides of the restored rear-room wall strips and cross the room roof without obstruction.
2. Confirm all four training dummies stand on the lateral line and no main entrance gate exists.
3. Time melee and magical charge at baseline attributes, then compare high physical attack speed and high casting speed.
4. Move during ranged Reload and both charge types; confirm movement and progress are each halved only while directional input is present.
5. Confirm Pain, weapon switching and the 3-second timeout remove the charge.
6. Compare normal/charged Air or Anima cost, damage, projectile size and statuette explosion radius.
7. Activate Block, press Fire and confirm Block drops while the attack continues.
8. Empty a ranged magazine while retaining reserve ammunition and confirm Fire begins Reload automatically.

MAP01 structure: 190 vertices, 248 linedefs, 488 sidedefs, 72 sectors and 186 things.

## MAP01 rollback to the pre-gate baseline 4.27.0b

**Implemented — pending confirmation that the crash is gone in GZDoom 4.14.2**

The supplied crash report shows that GZDoom completed actor parsing, initialized MAP01 and entered gameplay before raising access violation `C0000005`. The recorded position (`x=-14.09`, `y=536.57`) lies inside the new western/northern terrace connector introduced after the stable staircase layout. This is treated as an engine-level failure triggered by the experimental map geometry rather than a ZScript compile error.

MAP01 is therefore restored byte-for-byte from V4.26.5r. It contains no main corridor gate, no rear terrace connector fill and no internal terrace-partition doors. The rollback also removes every map experiment from V4.26.5s through V4.27.0a instead of attempting another local repair. Construction will resume incrementally from the aligned-room/stair baseline.

Restored structure: 186 vertices, 242 linedefs, 476 sidedefs, 70 sectors and 186 things. Static validation confirms valid references and closed degree-2 boundaries for all 69 non-exterior sectors.

V4.27 input work is not rolled back. The user has manually confirmed that held Zoom behaves correctly with a magic weapon and shield. Ranged-only Reload and User1–User4 reservation routing remain pending broader manual validation.

Manual validation:

1. Start MAP01 and revisit the former crash coordinates around the first north connector/stair pair.
2. Confirm there is no main entrance gate or associated frame near the Player Start.
3. Confirm the later terrace fills, internal divider doors and lateral black strips are absent.
4. Verify the original eight room doors, silver-key NPC room and three aligned staircase pairs still work.
5. Retest ranged Reload and the four User bindings separately from map construction.

## Native input contract and conventional terrace partitions 4.27.0a

**Superseded for MAP01 by 4.27.0b; input changes remain active**

V4.27 has begun without assigning unauthored ability effects. Every physical, ranged and magic selector now exposes the complete native input contract: User1 reaches the racial-ability service hook, User2 reaches Seal Channel, User3 reaches the equipped-Tarot hook and User4 reaches the class-ability hook. Reload exclusively requests a magazine reload for ranged weapons. The four abilities remain reservation interfaces until their authored content patches; the control menu now names all four bindings in English and Spanish.

Magic weapons now share the same release latch used by physical/ranged contextual Zoom. Holding Zoom therefore produces only one Block toggle until the key is released. Ranged Zoom/ADS and its physical accuracy multiplier are unchanged.

The failed 4.26.5w internal-wall technique has been removed completely. Each of the four terrace connectors is now a set of seven ordinary sectors: west/east floor spaces at height 0, wall spans at 136, jambs and moving panel at 128. No self-referencing middle texture participates in the room division. This preserves three connected rooms per north/south row while preventing a wall face or 3D-floor plane from escaping laterally. The main western entrance similarly uses two continuous closed jamb polygons rather than a jamb/extension seam.

Updated MAP01 structure: 252 vertices, 350 linedefs, 692 sidedefs, 103 sectors and 186 things. Static validation confirms 102 closed non-exterior sector contours, valid references, no duplicated/overlapping segment and no non-vertex crossing.

Manual validation:

1. Inspect both terrace rows from below and above; confirm the left roof is complete and no black or textured strip escapes laterally.
2. Inspect the four internal doors from both rooms, including their floor edges and all jamb faces.
3. Cycle every internal panel at least four times from both sides and cross above every partition on the terrace.
4. Inspect and cycle the western entrance from both directions; confirm both jambs are complete and opaque.
5. Bind User1–User4 through Customize Controls and confirm each weapon family accepts the proper native state without attacking or reloading unexpectedly.
6. Hold Zoom with a shield-compatible magic weapon and confirm Block toggles only once until release.
7. Confirm Reload affects ranged magazines only and User2 does not consume Anima yet.

## Three-room terrace divisions and sealed entrance frame 4.26.5w

**Implemented — pending visual confirmation in GZDoom 4.14.2**

The two roofed areas behind the intermediate staircases are no longer continuous hall-like spaces. Each north/south row is divided at the centers of its two connector modules, producing three similarly sized rooms connected in sequence. Every new partition contains a centered 128-MU retracting panel with bilateral repeatable USE. The remaining partition spans are self-referencing finite 3D middle walls from floor 0 to the underside of the 128-MU roof, so they close sight and movement at room level without creating another ceiling/control strip or obstructing terrace traversal above.

The western corridor gate retains its established position and dimensions. Its two outer frame extensions now use floor 128 and roof-control ID 100 like the adjacent jambs. This makes the complete jamb/extension assembly opaque and finite while preserving the open roof route above the panel.

Updated structure: 256 vertices, 340 linedefs, 672 sidedefs, 93 sectors and 186 things. Static validation confirms valid references, 26 platform-door activators, 53 roof targets, closed boundaries for every conventional sector, no duplicate or overlapping segments, no non-vertex crossing and deterministic regeneration.

Manual validation:

1. Enter each north/south terrace interior and confirm it is now a sequence of three rooms rather than one large hall.
2. Cycle all four new internal doors repeatedly from both sides and confirm they block sight while closed.
3. Inspect every partition from floor level and then cross the uninterrupted terrace above it.
4. View the western entrance frame obliquely from both sides and confirm there are no transparent triangles, black extensions or infinite faces.
5. Confirm the central corridor remains uncovered and all six staircase routes still reach the terrace.

## Closed terrace topology and opaque entrance frame 4.26.5v

**Implemented — pending visual confirmation in GZDoom 4.14.2**

The screenshot from 4.26.5u exposed a topology leak rather than an intentionally authored corridor: the two 136-MU rear structural-wall strips each inherited one extra jamb edge, leaving an open contour. Their floor surface could consequently extend as a long black strip toward the spawn and make the left/right terrace fill appear asymmetric. Those connections now return to the correct low stair sectors; wall strips, stairs, connectors, rooms and gate components all form independent closed polygons.

The western entrance retains the same location and 128-MU panel. Its frame is now structurally identical to the room pattern: 16-MU north/south jamb sectors at floor 128, followed by separate 16-MU wall-extension sectors at floor 136 to reach y=±96. Every exposed edge carries a finite lower face, removing the transparent section without enlarging the door or covering the corridor.

Updated structure: 208 vertices, 284 linedefs, 560 sidedefs, 81 sectors and 186 things. Static validation confirms all 80 non-exterior sectors have closed degree-2 boundaries, plus no collinear overlap or non-vertex crossing.

Manual validation:

1. Return to the screenshot viewpoint and confirm no black roof strip extends toward the Player Start.
2. Compare the northern/southern and western/eastern terrace connectors for symmetric fill and roof continuity.
3. Inspect all four faces of both entrance jambs and wall extensions for transparency.
4. Cycle the entrance panel repeatedly from both sides and confirm the corrected frame remains finite.

## Integrated corridor entrance and continuous rear terrace 4.26.5u

**Implemented — pending manual GZDoom 4.14.2 validation**

The standalone gate at x≈-1556 is removed completely. Its mechanism now occupies the actual western entrance between the nearest north/south rooms: west threshold x=-593, east threshold x=-569, panel width 128 MU and solid frame spanning the remaining corridor width to y=±96. No separate gate sector remains near the Player Start.

Four new connector sectors fill only the areas behind the first two north/south staircase pairs. Northern connectors cover y=272…640; southern connectors cover y=-640…-272. Their 128–136 MU solid roof target joins the neighboring room roofs into one terrace. Existing room-side linedefs are split and shared with the connector sectors, while the 136-MU final steps provide their front boundary. The central y=-272…272 corridor/stair zone remains open to the sky.

Updated structure: 204 vertices, 278 linedefs, 548 sidedefs, 79 sectors and 186 things. Static validation confirms deterministic regeneration, 18 platform-door activators, 39 roof-target sectors, no collinear overlap and no non-vertex crossing.

Manual validation:

1. Confirm there is no gate, jamb, roof strip or collision remnant near the Player Start.
2. Approach the western room pair and verify a single framed trap door closes the real corridor entrance.
3. Complete at least four opening cycles from both sides and inspect the frame obliquely.
4. Climb the first two northern and southern stair pairs and cross their final steps onto the new connector roofs.
5. Walk the joined terrace across all six paired rooms and confirm no 1-MU holes remain behind the stairs.
6. Look upward throughout the central corridor and confirm it remains completely unroofed.

## Structural rear walls, compact entry gate and debug creation 4.26.5t

**Implemented — pending manual GZDoom 4.14.2 validation**

The rear staircases no longer own wall middle textures. Two 8-MU structural strips now belong to the rear room itself. Their conventional floor is 136 MU, producing visible lower wall faces from the room floor and from every adjacent tread while aligning their walkable top with the roof. This restores the interior wall and prevents stair textures from projecting above the building.

The entry trap gate moves from x=-1496…-1472 to x=-1568…-1544. Its west face is 32 MU ahead of the Player Start and its total depth remains 24 MU; panel, jambs, roof target and bilateral activation are unchanged. The four training dummies retain x=-1216/-704/320/1344 but move together to y=-900, clearing the central corridor.

Character creation now exposes `Depuración` / `Debug` as a fifth option on the race page. Confirming it jumps directly to the summary. The resulting profile overrides all twelve post-equipment primary attributes to exactly 30 and forces mass tier 6 / size tier 4: 100 kg base body mass and 1.8 m body height. A second confirmation completes creation and initializes resources normally. Carried equipment weight remains additional to the documented 100-kg body mass.

Updated MAP01 structure: 198 vertices, 258 linedefs, 508 sidedefs, 75 sectors and 186 things. Static validation confirms deterministic regeneration, no scaled stair middle textures, no collinear overlap and no non-vertex crossing.

Manual validation:

1. Inspect both faces of the rear-room walls from inside, from every tread and from the roof.
2. Confirm the stairs themselves have no wall texture and their final steps transition onto the wall/roof top.
3. Spawn facing east and verify the compact gate is immediately ahead without overlapping the player; complete four bilateral cycles.
4. Confirm all four dummies form a usable row south of the buildings and no longer obstruct the corridor.
5. Select `Depuración`, confirm twice, and verify twelve attributes at 30, 1.8 m height and 100 kg base mass.

## Visible stepped rear walls and corridor trap door 4.26.5s

**Implemented — pending manual visual/activation validation in GZDoom 4.14.2**

The ten rear-room wall sections beside treads below roof level now use individually scaled `STARTAN3` 3D middle textures. Each section begins at its adjacent stair floor and ends at the 128-MU roof underside; it therefore closes the room above the tread without becoming invisible below it or projecting through the roof. The two boundaries adjacent to the 136-MU final steps remain open for traversal.

A standalone trap-door gate now crosses the beginning of the test corridor at x=-1496…-1472, 104 MU ahead of the Player Start at x=-1600. It combines a 128-MU-wide retracting panel, two 16-MU solid jambs, bilateral repeatable special 62 activation and the same finite 128–136 MU roof target as the room template. It is unlocked and independent of the silver-key NPC door.

Updated structure: 194 vertices, 252 linedefs, 496 sidedefs, 73 sectors and 186 things. Static validation confirms 18 platform-door activators, 35 roof-target sectors, deterministic regeneration, no collinear overlap and no non-vertex crossing.

Manual validation:

1. Climb both rear staircases and confirm every wall is visible above its tread and terminates at the roof underside.
2. Cross from both 136-MU final steps onto the roof without invisible collision.
3. Open the new corridor door from the Player Start side, cross it, wait for closure and reopen it from the opposite side for at least four cycles.
4. Inspect its jambs obliquely and confirm the panel and frame do not extend above the roof slab.

## Aligned staircase modules and restored rear walls 4.26.5r

**Implemented — pending manual visual/collision validation in GZDoom 4.14.2**

The three complete north/south staircase pairs now share one exact module: 119 MU width, 665 MU start-to-start horizontal spacing, low corridor boundary at y=±80 and high roof boundary at y=±272. No flight protrudes farther into the central passage than another.

The western rooms move 71 MU east and the eastern rooms move one additional MU east, with all contained pickups translated identically. Conventional modules retain a 1-MU anti-overlap clearance. The rear room moves one additional MU east and is centered on y=0; its y=±272 corners coincide with the two high steps.

All six boundaries between the rear room and its stairs again carry `STARTAN3` lower faces. These close the room only across the local floor-height difference and stop at each corresponding step height, replacing both the missing walls from 4.26.5q and the projecting 128-MU middle textures from 4.26.5o.

MAP01 remains at 186 vertices, 242 linedefs, 476 sidedefs, 70 sectors and 186 things. Static validation confirms valid references, deterministic regeneration, no collinear overlap and no non-vertex crossing.

Manual validation:

1. Walk the central corridor and confirm all six first steps begin on the same north/south line.
2. Compare all three staircase widths and verify none projects into the passage.
3. Climb both rear flights and confirm the final steps meet the room corners and roof without a gap or obstruction.
4. Look into the rear room from every step and confirm its side walls are restored without rising above the current tread.
5. Verify pickups in the western and eastern rooms retained their internal arrangements.

## Complete NPC attributes and uniform corridor stairs 4.26.5q

**Implemented — pending manual gameplay validation in GZDoom 4.14.2**

`CaelumCombatActor` now stores Constitution, Charisma, Empathy and Eloquence alongside its previous eight attributes, completing the same twelve-field primary model used by `CaelumAttributes`. It also stores current and maximum Anima. Maximum Anima uses the player rule `HEALTH_ANIMA_DAMAGE_SCALE × Type1(Patience)` and every predefined NPC initializes at maximum.

The resulting equipped test values are: Rulo 1060 Anima (Patience 3), Ronnie 1280 (Patience 7), Argento 2710 (Patience 18), and Caella 3760 (effective Patience 23). Caella's tier-1 magic helmet raises effective Intelligence by five but does not directly alter Anima; her separate magic-glove +5 Patience bonus is what increases the reserve. NPC statistics now recalculate after armor initialization, matching the player's equipment order.

MAP01 now contains three complete mirrored staircase pairs in the intermediate vertical corridors. Their centers are separated by approximately 664 MU on the integer map grid. The eastern north/south rooms and rear room move 24 MU east; pickups inside the eastern rooms move with them. All six shared rear-stair boundaries are textureless two-sided partitions, eliminating the protruding wall along the full climb.

Updated structure: 186 vertices, 242 linedefs, 476 sidedefs, 70 sectors and 186 things. Static validation confirms valid references, no collinear overlap, no non-vertex crossing and deterministic regeneration.

Manual validation:

1. Climb every north and south staircase and confirm all six steps are free of projecting wall strips.
2. Cross onto the roofs from each staircase pair and check the 1-MU safety clearances beside conventional room walls.
3. Confirm eastern-room pickups retained their relative positions after the 24-MU move.
4. Inspect Rulo, Ronnie, Argento and Caella diagnostics for all twelve attributes and full Anima.

## Clear roof landings and NPC-archetype audit 4.26.5p

**Map fix implemented — pending manual collision validation in GZDoom 4.14.2**

The two boundaries shared by the rear room and the 136-MU top stair sectors remain valid two-sided partitions but no longer render or collide as finite wall faces. Both lateral routes can now reach the roof; the five lower boundaries on each staircase retain their closed wall faces.

The definitive **`habitación con puerta trampa`** configuration is the complete 4.26.5p form: finite 128-MU room walls, solid walkable 128–136 MU roof, independent retracting floor panel, bilateral repeatable USE, solid jamb pillars that block lateral sight, and an unobstructed upper traversal plane. The keyed NPC room is the locked variant of the same template.

The 4.26.5p audit identified `CaelumCombatActor` as a combat-capable subset rather than a complete general NPC archetype. Constitution, Charisma, Empathy, Eloquence and Anima were its five missing fields; 4.26.5q implements them. Survival-only Hunger, Thirst, Sleep, Carry Load and Air remain intentionally player-only.

No missing attribute values are assigned in this patch: Rulo, Ronnie, Argento and Caella retain their existing balance exactly.

Manual validation:

1. Climb both rear stairs and walk onto the roof without catching on a narrow wall fragment.
2. Confirm the lower outer sides of both staircases remain closed.
3. Recheck the rear door, jamb sight blocking and roof traversal after the boundary change.

## Solid door frames, flush stairs and mounted exit 4.26.5o

**Implemented — pending manual visibility and collision validation in GZDoom 4.14.2**

The invisible 16×24-MU jamb partitions from 4.26.5n left a lateral sight slit beside each closed floor panel. Their sectors now begin at floor height 128 MU and carry finite `STARTAN3` lower textures on every exposed boundary. Each doorway therefore has a real two-pillar frame whose closed volume blocks sight and projectile targeting below the roof while retaining the 512-MU base ceiling and shared 128–136 MU roof slab above it.

The rear staircases now reach x=1400 and use the rear-room wall as their shared eastern boundary; no duplicate line is authored. Their western edge moves from x=1288 to x=1281, leaving only 1 MU before the pre-existing eastern-room wall at x=1280. Zero clearance would require splitting and sharing that older wall across the individual step sectors; 1 MU is the closest conventional integer-grid placement that avoids overlaps while making the gap visually negligible.

The freestanding NPC exit line at x=-2448 is removed. `SW1EXIT` and special 243 now occupy the central 128-MU segment of the actual western room wall at x=-2464, y=-64…64. It inherits the same finite wall collision and cannot float inside the room.

Updated MAP01 structure: 130 vertices, 166 linedefs, 324 sidedefs, 46 sectors and 186 things. Static validation confirms valid references, balanced sector boundaries, no collinear overlap and no intersection outside shared vertices.

Manual validation:

1. Stand at oblique angles beside several closed doors and confirm the interior cannot be seen through either jamb.
2. Confirm NPCs do not acquire or attack the player through a closed doorway, then acquire normally after opening it.
3. Open every door and confirm both frame pillars remain finite and do not obstruct the central passage.
4. Climb both rear staircases and inspect the 1-MU western clearance and flush shared eastern wall.
5. Use the exit switch on the NPC room's western wall and confirm it no longer floats.

## Reusable one-trap-door room replication 4.26.5n

**Implemented — pending complete manual validation in GZDoom 4.14.2**

The architecture validated through 4.26.5m is now named **`habitación con 1 puerta trampa`** in the project vocabulary. One instance consists of an interior sector, a 128–136 MU solid 3D-floor roof, a finite floor panel that retracts through `Plat_DownWaitUpStay`, and two invisible jamb partitions. Its base ceiling remains at 512 MU, so wall and door geometry never extends into the upper playable space and the roof remains traversable in every door state.

MAP01 now contains eight instances: four central rooms, two eastern rooms, the NPC room and the rear room. Every door faces the corridor serving that room. The rear-room entrance has rotated from south to west. The NPC room retains silver lock 200 using the native UDMF `locknumber` field on both special-62 thresholds; the underlying trap-door motion is identical to the unlocked instances.

The provisional staircase and 136-MU raised block east of the rear room are removed. Two staircases flank its new west-facing entrance. Each contains six 32-MU-deep steps and reuses the established floor heights 24, 48, 72, 96, 120 and 136 MU. They occupy the passage between the eastern rooms and the exterior face of the rear door, and their upper steps provide the roof-access jump across the existing 24-MU door depth.

All 186 things remain present. Item coordinates are unchanged. The four `CaelumTrainingDummy` instances move 128 MU west, toward the player start, leaving the rear room empty without changing their common firing axis.

Updated MAP01 structure: 132 vertices, 167 linedefs, 326 sidedefs, 46 sectors and 186 things. Static validation confirms valid references, balanced boundaries, no overlapping collinear linedefs and no intersections outside authored vertices.

Manual validation:

1. Open every unlocked room from outside and inside, then complete at least two full cycles per door.
2. Confirm all seven unlocked doors face their corridors and none produces suspended or infinitely tall textures.
3. Approach the NPC door without and with `CaelumSilverKey`; verify the localized lock response and successful opening only with the key.
4. Enter every room and walk across representative roof areas, including all eight doorway roofs.
5. Climb both new side staircases and cross from each 136-MU upper step onto the rear-room roof.
6. Confirm the old eastern staircase and raised block are absent.
7. Verify all pickups remain in their prior positions and all four training dummies are outside rooms on the shifted firing axis.

## Door partition texture cleanup 4.26.5m

**Implemented — pending visual validation in GZDoom 4.14.2**

The 4.26.5l geometry and motion behaved correctly, but the auxiliary sectors introduced around the jambs still carried `STARTAN3` middle textures. After their base ceilings were raised to 512 MU for continuous roof traversal, those partition textures rendered as narrow suspended strips above the door.

All sixteen middle-texture assignments belonging to the auxiliary partition boundaries and the moving-door side partitions are removed. The two side lines no longer use `midtex3d` or bottom-pegged middle-texture flags. Their finite `BIGDOOR2` lower textures remain, appearing only across the actual 128-MU floor-height difference while the panel is closed.

MAP01 remains at 94 vertices, 93 linedefs, 178 sidedefs, 16 sectors and 186 things. Reference and closed-boundary validation pass; door motion and roof targets are unchanged.

Manual validation:

1. Inspect the doorway from outside and inside and confirm no narrow strips float above it.
2. Open and close the door and confirm its finite front and side faces remain visible while closed.
3. Walk over the complete roof and confirm the entrance remains traversable above.

## Independent finite door and continuous roof 4.26.5l

**Implemented — pending manual validation in GZDoom 4.14.2**

The 4.26.5k limiter shortened the vertical ceiling motion but did not solve the underlying coupling: door sector 5 was still both the moving closure and a target for the solid roof 3D floor. Lowering its base ceiling to the 128-MU roof underside removed the playable upper volume over the doorway, while the ceiling-based panel could still render against the complete vertical sector.

The closure is now independent of the ceiling. Door sector 5 has a fixed 512-MU sky ceiling and a closed floor at 128 MU. Both USE thresholds call native `Plat_DownWaitUpStay` (special 62): the floor panel lowers to the surrounding 0-MU floor, waits 150 tics and returns to its authored 128-MU closed position. The existing speed remains 16. `BIGDOOR2` is assigned as a lower texture, so only the finite floor-height difference renders as the door face.

Room sector 4, door sector 5 and jamb sectors 14–15 all retain the 512-MU base ceiling and target ID 100. The solid 3D-floor slab from 128 to 136 MU therefore remains valid and walkable above the complete entrance regardless of door position. The map structure remains 94 vertices, 93 linedefs, 178 sidedefs, 16 sectors and 186 things; static topology and reference validation pass.

Manual validation:

1. Confirm the closed panel ends at the 128-MU lintel and has no continuation toward the sky.
2. Open from outside, cross, wait for closure and reopen from inside.
3. Complete at least four alternating cycles and confirm the panel returns to the same closed height.
4. Walk continuously across the roof above the door while it is closed and while it is open.
5. Stand clear during closure and confirm the passage does not remain visually or physically blocked after reopening.

## Finite framed template door 4.26.5k

**Implemented — pending manual validation in GZDoom 4.14.2**

**Superseded by 4.26.5l.** The limiter corrected the target height but kept the moving ceiling coupled to the roof target, so the upper doorway remained non-traversable.

The template door previously opened against sectors whose base ceilings were at the 512-MU outdoor sky. Because the standard vertical `Door_Raise` action stops four map units below the lowest adjacent ceiling, the moving door sector rose far above the visible 128-MU doorway and appeared infinitely tall.

Two 16×24-MU structural jamb sectors now flank the existing 128-MU-wide door recess. Their ceilings are 132 MU, providing a deterministic 128-MU open position after the native four-unit clearance. The door remains a conventional vertical stone door rather than a polyobject: this preserves finite collision beneath the walkable 3D-floor roof and avoids an infinitely tall rotating polyobject blocking traversal above the doorway.

The room, roof, door width, activation lines, speed and 150-tic delay are unchanged. Both thresholds retain front/back player USE and `repeatspecial = true`. Updated MAP01 structure: 94 vertices, 93 linedefs, 178 sidedefs, 16 sectors and 186 things. Static validation confirms valid references and balanced sector boundaries.

Manual validation:

1. Open the door from outside and confirm its visible panel disappears at the 128-MU lintel instead of rising toward the sky.
2. Cross the threshold, wait for closure and reopen it from inside.
3. Complete at least four full cycles while alternating sides.
4. Walk over the roof above the doorway and confirm there is no new invisible obstruction.
5. Confirm the two narrow jamb extensions render as part of the doorway rather than as gaps.

## Unified shield framing and true walkable room roof 4.26.5j

**Implemented — pending manual validation in GZDoom 4.14.2**

All four equipped-shield Block layers now use the same medium framing previously validated for the Kite Shield: virtual position `(90, 125)` and rendered size `210×230`. This keeps every shield left of center without the Buckler becoming too central or the Tower becoming excessively large. The Magic Shield retains only its larger translucent halo pass as a type-specific visual distinction.

The room is no longer a sector capped at 136 MU. Room sector 4 now has a 512-MU sky ceiling and shares target ID 100 with door sector 5. A closed control sector outside the playable field defines a solid opaque 3D-floor slab with underside at 128 MU and walkable top at 136 MU. Its initialization line uses `Sector_3DFloor` (special 160) for target 100. The existing finite 3D middle-texture walls end below the slab, so the player can cross their upper edge onto the roof rather than colliding with an infinitely tall boundary.

The adjacent raised platform and final stair remain at 136 MU. They provide the current access/calibration point for crossing onto the new roof at the same elevation. The door recess receives the same slab, avoiding an uncovered strip above the doorway. `Door_Raise` remains front/back usable and uses the valid `repeatspecial` field.

Updated MAP01 structure: 90 vertices, 87 linedefs, 166 sidedefs and 14 sectors. The added control geometry is a conventional closed four-line sector and is outside the playable field.

Manual validation:

1. Enter the room and confirm the ceiling underside remains at 128 MU.
2. Use the six steps to reach 136 MU and cross/jump from the adjacent platform onto the room roof.
3. Walk across the complete roof, including above the doorway, without falling through or meeting an invisible wall.
4. Drop from the roof into the field and confirm collision/landing physics still operate.
5. Complete at least four door cycles from alternating sides.
6. Test all four shields and confirm they share the same medium left-offset framing.

## Equipped shield first-person Block layer 4.26.5i

**Implemented — pending visual calibration in GZDoom 4.14.2**

Persistent Block now exposes the equipped shield as a modular first-person HUD layer. The layer is driven by a play-scope snapshot of `CombatBlockModeActive` and the live equipped shield type, and disappears immediately when Block ends, the shield breaks or the shield is unequipped.

The four provisional compositions preserve the authored visual distinction:

- Buckler: near the center and lower in the frame.
- Kite Shield: shifted left and covering a broader part of the screen.
- Tower Shield: far left and substantially larger.
- Magic Shield: more centered, with a second translucent sprite pass acting as a temporary magical halo.

The existing original 64×64 project shield sprites are reused and enlarged at render time. Exact HUD coordinates and sizes are provisional visual calibration values, not combat coverage or balance values. Mechanical coverage remains 120° / 140° / 160° / 120° according to shield type.

User-validated in the preceding test pass: native Fly lateral movement, ranged visual Zoom/ADS, ADS physical-accuracy behavior and Dexterity-scaled ranged Reload.

Manual validation:

1. Enter/leave Block once with each shield and confirm the layer follows the equipped type.
2. Confirm ranged ADS never displays a shield layer.
3. Confirm large/two-handed physical weapons still cannot enter Block.
4. Check that Buckler, Kite, Tower and Magic Shield remain readable at 1920×1080 without hiding critical HUD resources.
5. Break or unequip the shield and confirm the layer disappears.

## Zoom input latch, Fly lateral movement and roof diagnosis 4.26.5h

**Input/movement fixes implemented — roof rebuild pending**

Contextual Zoom now accepts exactly one transition per physical key press. GZDoom may revisit a weapon's native Zoom state while the button remains held; `CombatZoomInputLatched` ignores those repeated pulses and is cleared only when `BT_ZOOM` is released. This applies equally to ranged ADS and shield Block.

Native Fly sets the player to a no-gravity movement state. The Caelum acceleration layer previously required ground contact before increasing its movement factor, leaving Fly at factor zero if it began while stationary. `NOGRAVITY` movement is now treated as continuously supported for lateral acceleration, while ordinary jumping retains its existing no-air-acceleration rule.

The block beside the stairs is sector 6: its floor is physically raised to 136 MU and its ceiling remains at 512 MU. The player stands on that raised floor, so its top is a native walkable plane. The room is sector 4: its floor is 0 and its ceiling is 136 MU. A Doom-sector ceiling renders the underside, but its opposite side is not a second walkable plane. Consequently the room can have an interior ceiling without providing a roof surface above it.

A room with both usable interior space and a walkable roof requires a solid 3D-floor slab (planned from 128 to 136 MU) controlled by separate geometry. Simply raising the room floor would reproduce the stair block but destroy the interior; simply retaining the low ceiling cannot create a walkable upper surface. The next architectural pass must replace the current ceiling with that control-sector 3D floor and revalidate the door's target height.

Manual validation:

1. Hold Zoom for several seconds: ADS/Block changes only once.
2. Release and press Zoom again: the state toggles once in the opposite direction.
3. Enable native Fly while stationary and verify forward, backward and lateral movement.
4. Verify ordinary airborne movement still preserves momentum without ground-style acceleration.

## Upper-wall removal, true repeatable door and live Dexterity reload 4.26.5g

**Implemented — pending manual validation in GZDoom 4.14.2**

The finite middle textures introduced in 4.26.5f ended at roof height, but both sidedefs still carried upper `STARTAN3` textures. Those upper textures filled the room/outdoor ceiling difference and visually recreated the wall above the roof. They are now removed from both sides of all five room walls and both jambs.

The door-cycle limit was caused by using `repeatable`, which is not the valid UDMF repeat-special field. Both door thresholds now use `repeatspecial = true`, retain front/back player USE activation and operate the same door sector with the existing speed and 150-tic delay.

Ranged Aim is verified in the attack path: `RangedAimModeActive` multiplies `EffectivePhysicalAccuracyPercent` by ×2. Crouching supplies its own ×2 multiplier, so Aim + crouch still produces ×4 before the weapon spread calculation.

Reload now derives its effective duration from the player's current effective Dexterity at the moment Reload starts. The formula remains the authored Type-4 rule:

`effective seconds = base seconds × 100 / Type4(Dexterity)%`

The base durations remain Standard Bow 3 s, Longbow 3 s, Crossbow 5 s and Carbine 5 s.

Manual validation:

1. Verify that no wall texture reappears above the roof cut.
2. Complete at least four full door open/close cycles, alternating approaches.
3. Compare Reload at ordinary Dexterity and debug Dexterity 75 while observing the HUD countdown.
4. Verify that Zoom ADS remains visual and that ranged shots become more accurate.

## Finite room walls, repeatable door and contextual ranged Zoom 4.26.5f

**Implemented — pending manual validation in GZDoom 4.14.2**

The template room no longer uses infinitely wrapped blocking middle textures. Its five wall lines and two jambs now use bottom-pegged finite 3D middle textures, allowing their visible and physical height to follow the authored texture instead of extending to the outdoor 512-MU ceiling.

Both door thresholds retain repeatable tag-0 `Door_Raise` and now accept USE from their back side as well as their front side. This pass specifically targets the reported failure to begin a second open/close cycle.

Zoom is now contextual. Standard Bow, Longbow, Crossbow and Carbine toggle Aim with a real native ×2 FOV zoom. For non-ranged weapons, Zoom enters persistent Block only when the equipped weapon uses one-handed shield rules. Large and ranged two-handed physical weapons therefore cannot block through a shield that remains equipped. Ranged AltFire remains an alternate Aim input.

The normal HUD now displays `Magazine: loaded / capacity | Reserve: amount` while a ranged weapon is active, plus the remaining Reload time while reloading. Reserve excludes the rounds already represented by the loaded magazine.

Manual validation:

1. Room walls stop at their finite authored height instead of reaching the outdoor sky.
2. Complete at least three door open/close cycles, testing USE from both sides.
3. Equip a shield with a large or ranged weapon and verify that Zoom does not enter Block.
4. Equip a one-handed shield-compatible weapon and verify that Zoom still toggles Block.
5. Equip each ranged weapon and verify that Zoom changes FOV and the HUD reports magazine, capacity and reserve.
6. Fire and Reload while watching the HUD counts and Reload countdown.

## Bilateral wall rendering, dual-use door and ranged ammunition 4.26.5e

**Implemented — pending manual validation in GZDoom 4.14.2**

The room/exterior sector split from V4.26.5d was structurally valid, but an upper texture only fills the height difference above the lower ceiling; it does not draw the required wall from floor level. The five room walls and two jambs now retain bilateral sector ownership while also using explicit wrapped `STARTAN3` middle textures on both sides, matching MAP01's already visible test-wall vocabulary.

The inner room/door threshold now carries the same tag-0 manual `Door_Raise` special, speed and delay as the exterior-facing line. The exterior line remains non-blocking and the door sector remains the physical closure, so USE is available from both approaches.

Ranged ammo actors now declare `Inventory.Amount 20`. Firing checks the loaded magazine rather than requiring both a loaded magazine and a simultaneously accessible reserve stack. Reserve ammo remains the Reload source and is decremented when a shot consumes a physical round, but moving/exhausting the reserve cannot cancel a round already loaded in the magazine.

Manual validation:

1. All room walls and jambs render from exterior and interior.
2. USE opens the door from both approaches and the raised opening is passable.
3. Pickups provide 20 bullets/arrows/bolts.
4. Press Reload and wait for the weapon's 3/3/5/5-second base time.
5. Standard Bow, Longbow, Crossbow and Carbine each spawn the correct projectile and reduce the loaded magazine by one.
6. Empty magazines still require Reload; reserve ammunition alone is not a loaded shot.

## Bilateral room shell, usable door and environmental Adrenaline 4.26.5d

**Implemented — pending manual validation in GZDoom 4.14.2**

The isolated room's one-sided walls faced inward, leaving no exterior sidedefs to render from the field. The five room perimeter lines and two door jambs now separate their authored interior sectors from exterior sector 0 and use finite upper textures. They remain blocking walls, but both sides have valid sector ownership and visibility.

The outer manual door line is reversed so sector 0 is its front and door sector 5 is its back. `Door_Raise` therefore receives USE from the exterior-facing side and operates on the door sector behind the line. The permanent linedef blocking flag has been removed from this opening; the closed door sector supplies collision until its ceiling rises.

Environmental impact damage already skipped the direct received-damage Adrenaline event, but its shared Pain calculation could still grant Pain Adrenaline. Pain resolution now receives an explicit permission flag. Wall/floor impacts pass `false`; actor impacts and ordinary combat damage pass `true`. Environmental impacts may still cause Pain/stun, but neither their damage nor their Pain grants Adrenaline.

Manual validation:

1. The isolated room is visible from the exterior on every wall and jamb.
2. USE from outside raises the door, which becomes passable, waits and closes.
3. Walls remain solid and the room interior renders normally.
4. A damaging wall collision may reduce HP/cause Pain but never increases Adrenaline.
5. Actor-to-actor damage and Pain still grant their intended Adrenaline.

## Final stair front-side correction and input-roadmap audit 4.26.5c

**Implemented — pending manual validation in GZDoom 4.14.2**

After V4.26.5b, the engine accepted the door repair and reported only linedef 82 as lacking a front. That line closes the sixth 136-MU stair sector.

MAP01 now removes the two unreferenced door sidedefs left at indices 94 and 96 and remaps all subsequent live references. Linedef 82 is reversed together with its front/back assignment, preserving the same physical sector adjacency while making exterior sector 0 its explicit front and stair sector 12 its back. The map now contains 86 vertices, 83 linedefs, 154 sidedefs and 13 sectors; every sidedef is referenced exactly once and every sector boundary remains balanced.

Manual validation:

1. MAP01 loads without a line-82/front-sidedef error.
2. The sixth stair remains visible, solid and climbable.
3. The 136-MU platform remains walkable.
4. The template door retains its V4.26.5b behavior.

The roadmap input audit preserves the already implemented architecture: Zoom = Block, ranged AltFire = Aim and ranged Reload = magazine reload. User1 is the remaining slot for the future racial ability; User2 remains Seal Channel; User3 Tarot; User4 class ability.

## Canonical MAP01 topology correction and roadmap reconciliation 4.26.5b

**Implemented — pending manual validation in GZDoom 4.14.2**

The V4.26.5a diagnostic pass left four provisional appended sidedefs and explicit `sideback = -1` placeholders in the UDMF map. Although local index/boundary validation could parse them, the engine node builder still rejected lines 53, 54 and 82 and reported line 52's right edge as disconnected.

MAP01 now uses the canonical 156-sidedef set. Door jambs and the outer manual door line are true one-sided boundaries with no synthetic back-side field. The outer door uses its original sector-5 sidedef; the inner threshold uses the original room-front/door-back pair. All three one-sided door edges are consistently oriented around the sector.

Static validation confirms 86 vertices, 83 linedefs, 156 sidedefs and 13 sectors, with valid references and balanced sector boundaries. Manual engine validation remains authoritative:

1. MAP01 loads without the reported front-sector/front-sidedef errors.
2. No disconnected edge is reported for the template doorway.
3. USE raises the door; it waits and closes normally.
4. The last stair sector and 136-MU platform remain valid and walkable.

The former V4.22–V4.26 roadmap has been reconciled with current implementation status in `docs/ROADMAP.md`. The next major implementation block is V4.27 Combat Input Architecture and Mode Separation.

## Architectural template topology correction 4.26.5a

**Implemented — pending manual validation in GZDoom 4.14.2**

The isolated template door had been converted to branching two-sided geometry: both jamb lines incorrectly continued into the room sector and the outer manual door line exposed an unnecessary exterior back side. Although all referenced sidedefs existed, those branches broke the closed boundaries expected by the node builder; it consequently reported human-facing line 54 as lacking a valid front side.

The jambs and outer door line are now consistently oriented one-sided front boundaries of door sector 5. The inner threshold is a two-sided transition facing room sector 4, with door sector 5 on its back. Static validation confirms that every linedef has an existing front sidedef, every referenced sector exists, and every sector boundary has balanced incoming/outgoing endpoints.

Manual validation remains:

1. MAP01 loads without node/front-sidedef errors.
2. Facing the unlocked template door and pressing USE raises it.
3. The door waits and closes normally.
4. The room, jambs, six stair sectors and 136-MU platform remain physically valid.

## Architectural template room 4.26.5

**Implemented — pending manual validation**

A single MAP01 template room is used to validate architecture before replication.

Validation sequence:

1. MAP01 loads without node/front-sidedef errors.
2. The room walls render and block normally.
3. The doorway has visible jambs/opening.
4. Facing the door and pressing USE triggers the manual `Door_Raise`.
5. The door opens, waits, then closes.
6. The six stair sectors can be climbed from 24 to 136 MU.
7. The 136-MU platform is walkable.

No attempt is made in this patch to retrofit all existing rooms with the template. Replication is deferred until this exact module works correctly in GZDoom 4.14.2.

## Crouch physics, movement noise and MAP01 building rebuild 4.26.4

**Implemented — pending manual validation**

For wall impacts while crouching:

`AgilityBonusRatio = max(0, JumpZ/BaseJumpZ - 1)`

`CrouchWallFraction = clamp(AgilityBonusRatio, 0, 0.50)`

The physical collision and displacement remain unchanged. Only traumatic Delta-v is reduced. If buckler block is also active, its doubled fraction is compared against the crouch fraction and the maximum is used; the two effects do not stack.

Sigilo is now explicitly calculated from Agility Type 2:

`Stealth% = clamp(Agility(Agility+1)/101, 0, 100)`

Crouch x2 remains authoritative and is capped at 100%. Movement hearing:

`NoiseRange = BaseRange × MovementMode × (1 - EffectiveStealth/100)`

with BaseRange = 20 m reference (622.22 MU), walking = 1.0, running = 1.5, crouching = 0.5. At EffectiveStealth = 100%, no movement alert is emitted.

MAP01 uses finite wall sectors with floor 136 MU and sky ceiling 512 MU. Interior sectors remain floor 0 and receive the shared 3D roof slab 128–136 MU. Two staircases reach roof level. All generated sectors pass closed-loop endpoint validation and every linedef has valid front/back sidedef and sector references.

## Buckler/map corrective pass 4.26.3b

**Implemented — pending manual validation**

The rodela no longer mixes direct JumpZ units with horizontal collision Delta-v. For horizontal impacts:

`AgilityBonusRatio = max(0, JumpZ / BaseJumpZ - 1)`

`BucklerHorizontalFraction = clamp(2 × AgilityBonusRatio, 0, 0.50)`

`TraumaticDeltaV = RawDeltaV × (1 - BucklerHorizontalFraction)`

This means the buckler can at most halve horizontal traumatic Delta-v; it can no longer manufacture `Delta-v = 0` / infinite equivalent tics. Its `2 × Toughness` rule remains unchanged, so a sufficiently tough buckler user may still end with zero final HP damage after the kinematic calculation. Stun continues to disable Agility damping.

MAP01 validation focus: finite room-wall height, real walkable 3D roofs, east-room door orientation, roof staircase, NPC-room roof bounds, item placement and absence of invisible room barriers.

## Buckler acrobatics and fall-test map 4.26.3

**Implemented — pending manual validation**

Active buckler block uses `2 × Toughness` for CaelumImpact tolerance and `2 × JumpZ` as Agility absorption. The latter applies to floor, actor and wall trauma. Stun sets active Agility absorption to zero. The buckler still uses 0.5× effective combat mass, so it remains easier to launch while making that displacement defensively survivable.

At V4.26.3, MAP01 had seven roofed structures: six equal test rooms plus the west NPC room. V4.26.5n supersedes that count with eight one-trap-door room instances. Outdoor vertical space remains 512 MU.

## Universal impact scale and anatomy response 4.26.2

**Implemented — pending manual validation**

The kinetic reference distance is now fixed at 28 MU for every body:

`T_impact = 28 / |Delta-v|`

This removes the previous double size effect in which large actors benefited both from greater mass during impulse resolution and from a larger height numerator during severity conversion.

Impact Physics Core remains anatomy-agnostic. It exposes only normalized contact-height intervals. Caelum interprets those intervals using `CaelumAnatomyProfile`, normalizes all overlapping region spans, and applies vulnerability and armor proportionally.

For each contacted region `i`:

`w_i = overlap_i / sum(overlap)`

After the V4.26.1 subtractive Toughness threshold:

`S_i = S_postToughness × w_i × Vulnerability_i × (1 - ArmorDefense_i)`

`S_final = sum(S_i)`

Critical/head Lucidity contribution uses the same `w_i`; non-critical regions contribute zero critical-point Lucidity loss. Local armor defense reduces the corresponding contribution.

Floor contact is represented as normalized height 0.0 and therefore maps to the lowest authored anatomy region. Actor-to-actor contact uses actual vertical cylinder overlap. Static vertical geometry currently uses 0.0-1.0 because native GZDoom line collision does not provide an anatomical Z contact point.

NPC controlled-landing absorption now follows Agility Type-1 jump scaling, matching the player design concept instead of scaling by actor height.

## Impact response refinement 4.26.1

**Implemented — pending manual validation**

Impact Toughness is now a threshold/tolerance measured in percentage points of maximum health. If the energy curve produces `S%` after the source-surface modifier:

`S_post = max(0, S - Toughness)`

`D_preArmor = HP_max × S_post / 100`

`D_final = D_preArmor × (1 - GlobalImpactArmor/100)`

This deliberately makes high Toughness completely ignore ordinary kinetic trauma while preserving vulnerability to sufficiently extreme impacts.

Static geometry requires at least 25% of pre-impact horizontal speed to be lost before the contact is considered an impact. Once static contact occurs, it remains latched until five consecutive unblocked tics have passed.

Environmental wall/floor impacts do not generate received-damage Adrenaline. Actor-to-actor impacts continue to do so.

## Impact Physics Core API 4.26.0

**Implemented — pending manual validation**

Generic physics is now separated from Caelum damage interpretation. `ImpactPhysics` resolves finite-body, static and external-source impacts and returns a neutral `ImpactResult`. Caelum adapters remain responsible for effective shield mass, biological landing damping, Toughness, armor and HP.

Static geometry is now modeled as the infinite-mass limit of the same physical model. The player-wall exception introduced during early calibration has been removed. The velocity component actually lost by native GZDoom movement defines the effective static collision normal.

**Convergence validation:** a character hitting increasingly massive movable bodies should approach the result of hitting static geometry. The existing mass-10000 training dummy is the primary MAP01 comparison against walls/doors.

**Export status:** the core source is isolated under `/impactphysics/` and contains no Caelum-specific class references. Packaging/licensing/versioning it as a standalone PK3 is planned after the API survives this validation pass.

**Melee integration:** intentionally deferred. Weapon mass can eventually feed an impact model, but melee also needs swing velocity, effective striking mass, contact area/edge geometry, material penetration, sharpness and attack technique. Existing melee damage remains authoritative until those variables are designed.

## Energy impact curve and contact rearm 4.25.4

**Implemented — pending manual validation**

Impact severity no longer uses discrete 3% damage steps. For `T_eq < 35`:

`R_v = 35 / T_eq`

`R_E = R_v²`

`Damage% = 100 × (R_E - 1) / (35² - 1)`

At or above 35 tics the result is zero. This normalization produces exactly 100% raw max-HP damage at one equivalent tic. Below one tic the same continuous quadratic curve remains active and may exceed 100%.

This is intentionally based on **specific kinetic energy** rather than total `1/2 m v²`. Mass already determines the action/reaction impulse and each body's resulting `Delta-v`; multiplying injury by mass again would double-count mass.

Contact rearm now requires true disengagement. A collision pair stays latched until center separation exceeds `RadiusA + RadiusB + 0.25 × min(HeightA, HeightB) + 2` for five consecutive tics. This is designed to reject tiny recoil gaps produced while holding movement against another body.

Existing V4.25.3 acceleration, biological landing damping, Toughness, armor mitigation and actor-to-actor momentum equations are unchanged.

## Acceleration and biological impact response 4.25.3

**Implemented — pending manual validation**

Player horizontal locomotion now uses an exponential acceleration state. With uninterrupted grounded directional input:

`A(n) = 1 - (1 - 0.028127624)^n`

At 105 tics (3 seconds) the factor is exactly 0.95. `A` multiplies the existing movement result, so the final maximum remains determined by Agility, LoadRatio, health/Air/survival state and shield mobility.

Self-powered wall impact severity also multiplies by this acceleration state. This makes run-up distance physically meaningful without changing the already validated actor-to-actor impulse equation.

Actor collisions now latch by contact pair. A collision is not eligible to resolve again while the same bodies remain touching; separation beyond their combined radii plus a small technical margin rearms the next impact.

Floor impacts now have a biological-damping layer before Toughness and armor. Player controlled landing absorption equals current `JumpZ`. Stun/physical immobilization sets that absorption to zero. CaelumCombatActor NPCs use height-scaled biological absorption and likewise lose it while lucidity-stunned.

**Validation focus:** acceleration feel and 95%-at-3s timing; short-run vs long-run wall impacts; sustained push against the 10000-mass dummy; ordinary jump landing; stunned landing; high falls that exceed biological absorption.

## Impact mitigation and calibration 4.25.2

**Implemented — pending manual validation**

Raw impact severity now passes through Toughness and global armor defense before health loss. The armor term is the simple arithmetic mean of all four armor-slot defenses; this avoids inventing location weights before a separate impact-location design exists.

Player wall-impact severity is normalized against effective movement percentage rather than raw GZDoom velocity. A 100% full frontal stop maps to 35 equivalent tics; load and movement-state penalties therefore reduce self-powered wall severity. A contact latch prevents repeated damage while continuously pressing against the same blocking geometry.

Landing detection now stores falling vertical velocity from prior tics and resolves damage on the next grounded state. Player impact reference height is the stable derived actor height.

Training dummy: movable, mass 10000, valid collision body.

Rulo/Caella/Ronnie/Argento already carry `CaelumCombatActor` profiles and T1 armor; V4.25.2 now allows these statistics to mitigate impact damage too. Generic Doom actors do not yet have a Caelum profile adapter.

## Momentum collision and impact physics 4.25.1

**Implemented — pending manual validation**

The collision foundation now resolves Caelum character/NPC contacts through a two-body impulse model. Effective combat mass participates in the impulse, so Buckler (`x0.5`) and Tower Shield (`x2`) naturally change both outgoing and self collision response. The normal coefficient of restitution is currently `e = 0`, producing an inelastic character collision rather than a bounce.

Each body independently converts its forced `Delta-v` into an equivalent time to cover half of its own height. More than 35 equivalent tics is non-damaging. From 35 down to 1 tic, each discrete threshold adds 3% maximum-health base damage, reaching 105% at one tic or less.

The same impact evaluator is connected experimentally to blocked horizontal world movement and floor landings. Impact damage currently bypasses evasion, shield Block and localized armor so the test build exposes the raw physical scale without hidden mitigation.

The debug overlay displays last impact kind, Delta-v, equivalent tics, damage percent and base damage. Internal fields also preserve effective masses, closing speed and impulse for calibration.

Carbine Reload base time is corrected to 5 seconds. Ranged Reload bases are now 3/3/5/5 seconds.

Detailed design: `docs/PHYSICS_COLLISION_SYSTEM.md`.

## Ranged weapon architecture 4.25.0

**Implemented — pending manual validation**

The four definitive ranged weapons now have independent magazine state and Reload behavior. Standard Bow and Longbow each hold 50 shots, Crossbow 20, and Carbine 10. Magazine capacity does not scale with tier. Reload base durations are 3 seconds for both bows, 5 seconds for Crossbow, and 10 seconds for Carbine; effective duration is divided by the Dexterity Type-4 attack-speed multiplier.

AltFire now toggles Aim for ranged weapons rather than trying to reuse the shield input. Aim multiplies physical accuracy by 2.0 and stacks with the existing crouch accuracy multiplier of 2.0. Native Zoom remains the independent persistent Block toggle.

Ranged damage is intentionally attribute-independent at the base-damage layer and therefore has been raised substantially. T1 bases are Standard Bow 1200, Longbow 1800, Crossbow 1400, and Carbine 3600. Ranged tiers use 100% / 160% / 250%, producing T2/T3 damage of 1920/3000, 2880/4500, 2240/3500, and 5760/9000 respectively.

Base critical chance scales with the same 100% / 160% / 250% tier multipliers before the Dexterity critical bonus is added. T1 bases are Standard Bow 10%, Longbow 12%, Crossbow 8%, and Carbine 6%.

The authoritative spread ladder is Minimum 10°, Very Low 30°, Low 50°, Medium 70°, High 90°, Very High 110°, Maximum 130°. Minimum spread is always 10% of maximum. Current ranged assignments are Standard Bow Very High (11°–110°), Longbow Medium (7°–70°), Crossbow High (9°–90°), and Carbine Maximum (13°–130°).

### Equipment-data audit

The executable remains the source checked for equipment values. Shield T1 weights are Magic 4, Buckler 8, Kite 12, Tower 16; documentation entries using older 14/18 values for Kite/Tower are obsolete. Physical-weapon T1 weights and catalogue combat values have been rechecked against `CaelumWeaponModel` and `CaelumWeaponCatalogue`.

## Connected crafting infrastructure 4.23.3a

**Implemented — pending validation**

The world-sprite alignment table has been restored from the validated 4.22.4c
configuration while retaining the twelve crafting-station sprites. The
training dummy and floor gallery therefore again use their corrected paths and
offsets.

Crafting close input now has a dedicated UI processor. This is necessary
because GZDoom routes input through `UiProcess` instead of `InputProcess` while
its GUI owns keyboard focus; `Q` is forwarded to the existing networked
crafting toggle in either input mode.

All twelve infrastructure actors now use dedicated project-local station
sprites rather than temporary weapon/equipment placeholders. Their source
cards were normalized for the sprite namespace and registered in
`ASSET_REGISTER.md`.

The crafting overlay now accepts its close command while GZDoom retains
`menuactive`, removing the previous requirement to press Escape before `Q`.

### Input regression note

The experimental global crafting UI processor has been removed because it
interfered with character creation at map start. Crafting input is temporarily
back on the stable 4.23.2 path; the requirement to close residual native menu
focus before `Q` may still occur and remains pending a safer implementation.


Crafting infrastructure forms a graph at interaction time. Two
`CaelumCraftingStation` actors are directly linked when their three-dimensional
distance is at most 64 map units, equal to exactly two development metres.
Connectivity is transitive, so a station can belong to the same workshop even
when it is farther than two metres from the Workbench if connected stations
bridge the distance.

The Workbench is the logical root of the interface. Using any station scans
its complete connected component and opens the same Workbench menu. A
component without a Workbench is rejected with a localized message. The scan
runs only on interaction and uses a per-player token to avoid recursion cycles
and cross-player scan collisions.

The twelve planned infrastructure actors currently exist: Workbench, Forge,
Anvil, Ranged Weapons Workshop, Sawmill, Armor Workshop, Sewing Machine,
Essence Altar, Globe, Jeweler Bench, Fine-tools Bench, and Master Bench. All
inherit `CaelumMovableProp`; their push requirement remains unset, so they
cannot yet be moved. Final station mass and physical-power requirements remain
deliberately pending for the later environment pass.

Tier requirements are cumulative. Forge recipes require Workbench + Forge at
tier 1, additionally Anvil at tier 2, and additionally Master Bench at tier 3.
Ranged-weapon recipes require Workbench + Ranged Weapons Workshop at tier 1,
additionally Sawmill at tier 2, and additionally Master Bench at tier 3. The
same architecture is reserved for Armor Workshop/Sewing Machine, Essence
Altar/Globe, and Jeweler Bench/Fine-tools Bench once those recipe families are
authored.

The Workbench menu currently exposes sixteen physical recipes: twelve Forge
recipes plus standard bow, carbine, longbow, and crossbow from the Ranged
Weapons Workshop. The interface reports whether the selected recipe's
infrastructure is ready and names the first missing station. Material
requirements, ownership checks, Magic Box routing, and the existing crafting
transaction remain unchanged.

MAP01 contains four infrastructure tests: a full twelve-station network, a
Workbench+Forge tier-1 network, a Workbench+Forge+Anvil tier-2 network, and an
isolated Forge that must reject interaction because no Workbench is connected.


### Armor and essence recipes

The unified Workbench currently exposes 52 recipes. Recipes 1–16 are the
physical weapon catalogue. The next 16 cover all four armor types across all
four body slots. The final 20 cover the four essence weapons with each of the
five elemental essences.

Armor material logic is weight-based and uses the existing material-unit
rounding system. Strap is always the base component. Fabric, Leather,
Chainmail, and Plate are the tier components for Magic, Light, Medium, and
Heavy armor respectively. Head/Body use 20% Strap and 80% tier material;
Hands/Feet use 60% Strap and 40% tier material.

Magic and Light armor require Workbench + Armor Workshop at tier 1, add Sewing
Machine at tier 2, and add Master Bench at tier 3. Medium and Heavy armor use
Workbench + Forge, add Anvil at tier 2, and add Master Bench at tier 3.

Essence weapons use 90% of their corresponding base material and 10% elemental
essence by final weapon weight. Tier 1 requires Workbench + Essence Altar,
tier 2 additionally requires Globe, and tier 3 additionally requires Master
Bench. The resulting weapon stores the selected essence on the native
equipment item.



This file describes the current executable prototype. The main design document
remains the authority for rules not yet connected to gameplay.

## Definitive physical weapon and recipe catalogue 4.12.0

**Implemented as authoritative data — pending playable crafting**

The code now defines all sixteen physical weapons in families 2 through 5:
dagger, hatchet, machete, javelin, sword, axe, flail, spear, greatsword, war
axe, halberd, giant gauntlets, standard bow, carbine, longbow, and crossbow.
Each entry centralizes primary/secondary damage, damage type or special action,
attack cadence, range, spread, critical chance, air cost, family, and shield
interaction. The carbine retains 360 damage/48 tics/60 m/30°–200°/0%/-20;
the longbow retains 180 damage/24 tics/30 m/10°–120°/12%/-10.

Every physical recipe now names one main component, one secondary component,
and the exact component that supplies its tier. Spear and javelin use shaft +
point and take the point's tier. Flail replaces the discarded one-handed mace
and uses round head + generic chain. Giant gauntlets remain the fourth large
weapon; the two-handed mace, saber, and their unused unique parts are absent.

Small weapon head and chain complete the active material catalogue. All 41
active material types are referenced by at least one physical, armor, shield,
or essence recipe. The old iron-ingot prototype is hidden from new selections
but its class and identifier remain available for save compatibility. Exact
component quantities and actual inventory consumption remain pending until the
global material-requirement formula is defined.

The console command `ca_debug_audit_crafting_catalogue` performs a read-only
runtime audit. Its expected result is 16 weapon recipes, 41 active materials,
and 0 unused materials.

## Native material catalogue and lock test 4.11.0

**Implemented — pending validation**

The Materials filter now exposes a data-driven catalogue of weapon parts,
shield plates, armor resources, elemental essences, secondary components, and
magical-item bases. Metal, wood, essence, leather, and fabric use three
localized grades; generic secondary components remain tier-independent.

Every material is a native `Inventory` instance. Type and tier together define
stack identity, so identical units merge while different grades remain
separate. Each unit weighs 0.1 by default, participates in automatic overweight
routing, and a complete stack occupies one Magic Box slot and weighs zero while
stored there.

`ca_debug_test_silver_lock` invokes `CheckKeys(200, true, false)`. This follows
the same native `LOCKDEFS` path used by locked map specials: without the silver
key it prints the configured remote failure message; with the key it confirms
access. A real door still declares lock number 200 in its map-line special.

## Categorized special inventory and native locks 4.10.0

**Implemented and manually validated**

The authoritative `Actor.Inv` chain now includes three additional categories:
Materials, Keys, and Key Items. The compact inventory cycles through eight
separate filters: armor, shields, weapons, ammunition, consumables, materials,
keys, and key items. Equipment retains its equipped/unequipped state and every
eligible object can still expose its Magic Box location.

The first test catalogue contains a stackable iron ingot, a native silver key,
and a unique sealed letter. Their default unit weight is 0.1. Materials use
their `Amount` as the load multiplier and a complete stack occupies one Magic
Box slot. Key items are non-stackable and can also enter the box.

The silver key derives from GZDoom's native `Key`, so the engine itself prevents
duplicates and recognizes it through `LOCKDEFS`. Lock number 200 can be passed
to locked door specials or ACS locked actions. Keys deliberately remain in
personal inventory: GZDoom's lock check only tests ownership and cannot see
Caelum's `InMagicBox` field, so boxing the same native key would otherwise leave
the lock usable. Its 0.1 weight always contributes to carried load.

GZDoom also provides `PuzzleItem`, Strife quest/dialogue infrastructure, HUD
messages, and programmable ZScript UI. These are reusable foundations for the
future mission pass, while Caelum will still own the general objective tracker
and presentation layer.

## Native consumables and timed regeneration 4.9.0

**Implemented and manually validated**

Life potion, Anima potion, energy drink, food ration, and water ration are now
stackable native GZDoom inventory objects. Their respective unit weights are
0.25, 0.25, 0.25, 0.10, and 0.10. Personal-inventory stacks contribute
`Amount × unit weight`; a complete stack occupies one Magic Box slot and weighs
zero while boxed. An overweight pickup follows the already validated native
overflow rule, and a full Magic Box leaves it in the world.

Using an item consumes one unit through GZDoom's native inventory path and
creates a ten-second Powerup. It applies one pulse per second: life restores 1%
of maximum health, Anima restores 1% of maximum Anima, the energy drink restores
1% of maximum air plus one sleep point, and each ration restores one hunger or
thirst point. Reusing the same item refreshes its remaining duration to ten
seconds instead of adding a second simultaneous intensity.

The compact inventory interface includes a Consumables filter. Left/Right
selects the item, `P` creates a five-unit test stack on the floor, Enter/E uses
one unit, `C` moves the complete stack between personal inventory and the Magic
Box, and `D` drops it. Native previous/next/use inventory commands are also
available under Customize Controls.

## Native inventory shadowing correction 4.8.1

**Implemented and previously validated**

The 4.8.0 native objects were collected correctly, as confirmed by `printinv`,
but ZScript's case-insensitive identifiers caused two parameter/field name
collisions. The equipment matcher compared its tier/type/slot/size parameters
against themselves, and the carried-load setter wrote calculated weights back
into its temporary parameters. Both interfaces now use unambiguous parameter
names, so ownership selection and weight propagation retain the values stored
in each native inventory instance.

## Native inventory and Magic Box object state 4.8.0

**Implemented and previously validated**

Armor pieces, shields, weapons, and carbine bullets are now real GZDoom
inventory objects. The player's native `Actor.Inv` chain is the single source
of ownership, quantity, and carried weight; collecting equipment no longer
deletes the pickup and replaces it with a parallel boolean record. Every
non-stackable instance stores its own slot/type, tier, size, durability,
equipped flag, Magic Box flag, and unit weight.

Equipping and removing only changes the equipped flag. Moving an object to the
Magic Box changes its carried contribution to zero while retaining the same
native object. A non-stackable instance uses one box slot. Carbine ammunition
uses its native `Amount`: any quantity remains one stack and therefore uses one
box slot. Outside the box its weight is `Amount × 0.003`; inside it weighs zero.

Immediately after the first character-creation confirmation, the four armor
pieces, profession shield, sword, staff, carbine, and 100-bullet stack appear
as nine pickups on the floor in front of the character. The character owns
nothing until those pickups are collected. If a pickup would exceed capacity,
it enters the Magic Box when a slot exists; otherwise it stays in the world.

The compact equipment menu can inspect the native objects, equip or remove
them, move them to or from the Magic Box, break them, and drop them. Its load
breakdown and the permanent HUD are rebuilt directly from native inventory on
every refresh. Legacy persistent equipment can be migrated once into native
instances for save compatibility.

## Authoritative persistent carried load 4.7.8

**Implemented — pending validation**

Every owned armor piece, shield, weapon, and bullet outside the Magic Box is
now summed exactly once from the persistent object registry. Equipped state is
used only to divide that authoritative value into equipped and personal
inventory subtotals; it can no longer decide whether an object contributes to
total carried weight. The complete breakdown is written atomically before mass,
movement, jump, evasion, air consumption, and HUD values are recalculated.

The permanent load display now prints its localized state next to the
percentage: normal below 75%, overload from 75%, and capacity exceeded from
100%. Its thresholds match the bar colors and gameplay state helpers.

## Atomic carried load and multi-weapon equipment 4.7.6

**Implemented — pending validation**

Inventory weight, equipped weight, ammunition weight, and development weight
now refresh `EquippedWeight`, `CarriedWeight`, `TotalMass`, and `LoadRatio`
atomically. This removes the stale-value route where opening the equipment menu
updated the inventory subtotal before the next gameplay tick and prevented that
tick from recognizing that a complete recalculation was still required.

Equipped and active weapons are now separate states. Any owned weapon can be
equipped without removing weapons from other families. Every equipped weapon
contributes its weight, but only one is active in the player's hands. Native
weapon-family buttons select the active test weapon: `3` sword, `5` carbine,
and `6` staff. Unequipping the active weapon automatically selects another
equipped family when one exists.

The equipped flags persist independently for every weapon/type/tier/size
combination. Saves from the single-weapon implementation migrate their previous
active weapon as equipped. Moving a weapon between personal inventory and an
equipment slot does not change total carried weight; moving it from the Magic
Box does.

## Post-creation starting equipment and ammunition weight 4.7.5

**Implemented — pending validation**

A new player owns no armor, shield, weapon, or carbine ammunition while the
character creator is open. Confirming the final page grants the development
loadout exactly once, using tier 1 and the default compatible size calculated
from the completed character.

Sword, staff, and carbine are always granted for testing. Sword begins equipped;
staff and carbine begin in personal inventory. The carbine begins with 100
bullets. Each bullet weighs 0.003, and current ammunition now contributes to
personal-inventory and carried weight, so firing reduces load by 0.003.

Starting armor and shield depend on the resulting profession:

- Warrior: heavy armor and tower shield.
- Mercenary, cleric, and battle mage: medium armor and kite shield.
- Explorer, pilgrim, and investigator: light armor and buckler.
- Pure priest, mage, and arcanist: magic armor and magic shield.

Armor uses its authoritative per-piece tier table in both equipped and
personal-inventory calculations, followed only by the established size
multiplier. This keeps previewed item weight and actual carried load identical.

## Personal inventory and overflow Magic Box 4.7.4

**Implemented — pending validation**

The personal inventory now exists independently from equipment and the Magic
Box. It has no item-slot limit: every unequipped object stored there contributes
its complete tier/size weight to carried load. Equipped weight, personal-
inventory weight, and development test weight form the load used by the HUD,
movement, evasion, air consumption, total mass, and push resistance.

When collecting or creating an object, the system first checks whether its
weight fits without exceeding carry capacity. If it fits, it enters personal
inventory. Otherwise it is redirected to the Magic Box; only this overflow
storage consumes its Intelligence-derived slots. If overflow is required while
the box is full, the pickup remains in the world.

Equipping an inventory object only changes its location and therefore does not
change carried weight. Equipping directly from the Magic Box adds its weight
and is rejected when capacity is insufficient. Unequipping returns the object
to personal inventory. The compact menu reports location, inventory count,
equipped slots, box usage, and the complete weight breakdown. Saves from 4.7.3
migrate their previously unequipped objects to the Magic Box.

## Persistent playable weapons 4.7

**Implemented — pending validation**

Sword, staff, and carbine are now real main-hand equipment records rather than
an isolated weight placeholder. Every weapon/type/tier/size combination owns
independent durability, uses XS–XL compatibility, records its current storage
location, and survives save/load and map travel. Existing 4.6 profiles
migrate their provisional weapon weight to a size-aware sword, staff, or
carbine without invalidating the earlier equipment data.

The compact equipment menu has a third Weapons filter. It previews damage,
attack time, base air/Anima cost, weight, compatibility, durability, and
carbine bullets. `P`, `Enter`, `Backspace`, `B`, and `D` use the same spawn,
equip, remove, break, and drop flow already used by armor and shields.

Every owned weapon may be equipped independently. Numeric family slots choose
only the active weapon: sword uses 3, carbine uses 5, and staff uses 6. Sword
retains physical Strength/mass damage and its 14-tic cadence; staff retains
Intelligence damage, Insight accuracy/critical, adjusted Anima cost, and
Eloquence casting speed. Carbine uses 360 tier-one damage without an attribute
damage multiplier, 48 tics, 60 m, 30°/200° accuracy-scaled spread, 0% weapon
critical base, 20 air per reload, physical push, and one bullet per shot.
The confirmed starting loadout grants 100 test bullets. AltFire toggles the
equipped secondary-hand shield; weapon secondary attacks remain reserved.

Tier damage uses the documented 1.00/1.20/1.50 material progression. Weapon
weight uses 1.00/1.50/2.00 and size 0.50/0.75/1.00/1.25/1.50. Test durability
bases are sword 100, staff 80, and carbine 120, followed by the existing
×1/×3/×9 tier rule and size multiplier.

Carry capacity is written directly as
`BaseMass × Type4Percent(Strength) / 100`. Therefore a 200-mass character has
200 capacity at Strength 0 and 600 at Strength 100.

## Carry capacity, magic armor, and equipment testing 4.6.2

**Implemented — pending validation**

Carry capacity is now `Strength Type 4 × (BaseMass / 100)`. Equipment weight
remains excluded from that multiplier and continues to form the numerator of
the load percentage. The tier-one, size-M carbine weight is now 12.

The basic equippable category is now named “magic armor” in
source, UI, tables, and documentation. This is a terminology-only migration:
its stored numeric value remains zero, so existing saves and owned equipment
records stay compatible. It remains separate from the zero-stat base clothing
used when a slot is genuinely empty.

The equipment menu accepts `P` to create its selected object through the pickup
rules. It enters personal inventory when its weight fits or the Magic Box when
it does not; `E`/`Enter` equips, `U`/`Backspace` removes, and `D` drops it.

## Compatibility and equipment HUD 4.6.1

**Implemented — pending validation**

GZDoom 4.14.2 does not accept the two `GetMaximumDurabilityFor` signatures as
overloads. The unused two-argument wrappers were removed; every active caller
uses the size-aware three-argument function.

The right-side HUD now includes carried weight, carry capacity, and percentage
in a dedicated bar. Its fill changes from green to yellow at 50%, orange at the
75% overload threshold, and red at 100% or more.

Removing armor now equips a non-item baseline according to slot: nothing on
head and torso, shirt on hands, and pants on feet. Baseline entries have zero
defense, weight, reinforcement, and durability, are never damaged, and do not
occupy the Magic Box. The existing equippable magic-armor set remains separate.

The short bow catalogue entry is replaced by the tier-one carbine. Its
values are 360 damage, 48 tics, 60 m, 30°/200° spread, 0% base critical chance,
-20 air, and size-M weight 12. Version 4.7 connects this record to its playable
projectile, bullets, inventory ownership, and persistent equipment model.

Status legend:

- **Implemented — pending validation:** compiled into the 4.0 source and ready
  for Damian's GZDoom 4.14.2 test pass.
- **Implemented and previously validated:** retained behavior that had already
  passed manual testing before 4.0.
- **Prepared:** a calculated value exists, but no final gameplay consumer exists.

## 4.0 compatibility repair

**Implemented — pending validation**

- Actor states use unscoped actions compatible with monster state chains. Each
  action casts `self` to `CaelumCombatActor` before accessing custom members.
- Player collision dimensions use GZDoom's `A_SetSize`; `Radius` itself is a
  readonly ZScript field and cannot be assigned directly.
- Effective actor Dexterity and Insight are cached in play scope. The UI overlay
  reads those fields instead of illegally calling play functions.
- The cascading unknown identifiers reported in actor debug page six are
  consequently removed.

## Character creation 4.1

**Implemented — pending validation**

The legacy three-layer creation model is replaced by eight pages. The only
structural character categories are Race and two Class selections; the second
class resolves the resulting profession:

1. Race.
2. First class.
3. Second class and resulting profession.
4. Sex.
5. Height.
6. Four family points.
7. Thirty individual points.
8. Summary and confirmation.

New characters now open this flow automatically. Until confirmation, ordinary
movement and attacks are blocked, resource simulation is paused, and the
unfinished character cannot receive damage. Keyboard controls are Right/Down,
Enter, Space, and Backspace/Left; gamepads use D-pad, A, X, and B. The confirmed
profile and completion flag persist in saves and in an inventory-backed travel
record. Changing maps therefore restores the confirmed character instead of
opening the creator again.

Races contribute Physical / Technical / Social / Mental values:

| Race | Values | Mass tier | Size tier |
|---|---:|---:|---:|
| Beast Man | 5/3/3/1 | +2 | +1 |
| Caelith | 3/5/1/3 | +1 | 0 |
| Human | 3/1/5/3 | 0 | 0 |
| Goblin | 1/3/3/5 | -1 | -1 |

Classes use Warrior 5/3/3/1, Explorer 3/5/1/3, Priest 3/1/5/3 and Mage
1/3/3/5. The two selections are order-independent and resolve to Warrior,
Explorer, Priest, Mage, Mercenary, Cleric, Battle Mage, Pilgrim, Investigator,
or Arcanist.

The family allocation keeps four points and a base limit of 15. Individual
allocation keeps thirty points, at most +5 per attribute and never above twice
the attribute's family base.

## Attributes, Anima, and Eloquence

**Implemented — pending validation**

- The attribute retains its definitive `Resilience` name in source and UI.
  Internal “survival resources” still refer collectively to hunger, thirst,
  and sleep and are not the attribute name.
- `Mana` is renamed `Anima` throughout the executable prototype.
- Eloquence Type 4 increases casting speed. The test staff duration is
  `18 tics × 100 / Type4Percent(Eloquence)`.
- Eloquence Type 2 reduces Anima cost by `n(n+1)/101%`; cost reaches zero at
  level 100 and cannot become negative.
- Eloquence Type 4 ability range and Type 2 dialogue skill are calculated and
  visible on the magic debug page. They are **Prepared** for later abilities
  and dialogue consumers.

## Mass and size tiers

**Implemented — pending validation**

Mass tier is clamped from 1 to 10 and maps to 50, 55, 60, 70, 80, 100, 120,
140, 170, or 200 kg. Size tier is clamped from 1 to 7 and maps to:

| Tier | Height in metres | Actor Height | Actor Radius |
|---:|---:|---:|---:|
| 1 | 1.20 | 37.3 | 10.7 |
| 2 | 1.40 | 43.6 | 12.4 |
| 3 | 1.60 | 49.8 | 14.2 |
| 4 | 1.80 | 56.0 | 16.0 |
| 5 | 2.00 | 62.2 | 17.8 |
| 6 | 2.20 | 68.4 | 19.6 |
| 7 | 2.40 | 74.7 | 21.3 |

The body-mass multiplier is `BaseMassKg / 100`. It affects maximum health,
physical attack power, physical push, carry capacity, air consumption, hunger
loss, and thirst loss. Equipment remains separate and continues to affect
load, movement, evasion, knockback, and additional air use.

Push is live for the player's sword and staff, Caelum actor melee attacks, and
physical or magical Caelum projectiles. Physical attacks use
`Strength Type 1 × body mass`; magical attacks use `Intelligence Type 1`.
The final force is `8 × attack push multiplier × receiver knockback multiplier`.
It only occurs after positive health damage; misses, evasion, and fully
prevented damage do not push. The training dummy's exceptional native mass keeps
it stationary. The combat page displays the last player-attack push force.

The development controls provide separate level-75 and level-100 attribute
overrides. Enabling one disables the other; toggling the active option again
restores the character's ordinary profile.

## Armor and equipped mass

**Implemented — pending validation**

Every armor piece now exposes its documented weight. At size M, full-set totals
for tiers 1/2/3 are 5/7/10 magic armor, 10/15/20 light, 20/30/40 medium, and
40/60/80 heavy. The exact per-piece tier table is applied before the equipment-
size multiplier. Broken pieces retain their weight. Shield and equipped-weapon
weights are included automatically, and debug-added mass is shown separately.

The current loadout is mirrored into an invisible, undroppable GZDoom inventory
record. It preserves profile, allocations, resources, equipped items, ownership,
and the individual durability of every armor/shield type, tier, and size
combination across saves and map travel. Existing pre-size ownership records
migrate automatically to size M.

`CaelumArmorPickup` and `CaelumShieldPickup` are functional world pickups. Map
authors configure armor with args `slot/type/tier/size/durability` and shields
with `type/tier/size/durability`; size zero remains a backwards-compatible M
default. Duplicate pickups retain ownership and repair that stored copy up to
maximum durability. A separate compact equipment interface cycles owned or
unowned previews, equips selected compatible objects, removes armor to its
zero-stat base clothing, and can fully unequip shields. Every change immediately
recalculates attribute bonuses, defense, reinforcement, mass, movement,
evasion, air cost, and shield blocking. A development control spawns the
currently previewed pickup.

## Area damage

**Implemented — pending validation**

Damage carrying `DMG_EXPLOSION` cannot be evaded. GZDoom first supplies the
distance-adjusted radial damage for the actor; Caelum then intersects the
explosion sphere with that actor's authored anatomy volumes. The supplied base
damage is applied once per touched region, and each application independently
resolves natural vulnerability, armor reinforcement, defense, Toughness, and
durability. The resulting health damage is summed into one final hit.

For the humanoid profile this produces at most four applications: head, torso,
arms, and legs. Both arms are one logical region: touching either or both counts
only once. A low explosion may therefore affect only legs, a larger wave from
below may affect legs and torso, and a full-body intersection resolves all four.
Separate authored non-arm regions remain independent, allowing future actors to
define multiple heads, tails, or weak points without changing this pipeline.

Pain and damage-based adrenaline are evaluated once from the total health loss.
A naturally critical region touched by the explosion can reduce lucidity, with
its own armor absorption mitigating that loss. Shields do not currently block
radial damage.

Defense percentages, reinforcement, bonuses, durability loss, and shield
behavior remain **Implemented and previously validated**.

## Predefined hostile characters

**Implemented — pending validation**

The final-value table in the 4.0 specification is authoritative:

| Actor | Profile | Attributes F/T/S/M | Mass / size | Armor | Health |
|---|---|---:|---|---|---:|
| Rulo | Beast Man Warrior, male, tall | 20/18/9/3 | 200 kg / 2.40 m | Heavy | 6200 |
| Ronnie | Caelith Mercenary, male, tall | 20/18/5/7 | 140 kg / 2.00 m | Medium | 4340 |
| Argento | Human Battle Mage, male, tall | 9/7/16/18 | 120 kg / 2.00 m | Light | 1740 |
| Caella | Goblin Cleric, female, tall | 9/7/16/18 | 80 kg / 1.60 m | Magic armor | 1160 |

Physical actor attacks apply body mass; magical attacks do not. Caella owns an
independent profile rather than inheriting Argento's combat setup.

## Equipment sizes and Magic Box 4.6

**Implemented — pending validation**

Equipment now records XS, S, M, L, or XL independently for every owned armor
piece and shield. Weight and maximum durability use the size factors 0.50,
0.75, 1.00, 1.25, and 1.50. Compatibility is exact: XS accepts character size
tiers 1–2, S accepts 2–3, M accepts 3–5, L accepts 5–6, and XL accepts 6–7.
Older ownership records and equipped objects migrate to M once.

Shield tier-one weights are magic 4, buckler 8, kite 12, and tower 16. Shields
then use tier factors 1.00/1.50/2.00 before size. The same tier/size weight rule
is centralized for weapons; the sword contributes base weight 6.
Armor retains its documented per-piece weights and applies size only.

The compact equipment interface is the first functional catalogue view:
armor/shield filters, storage location, current and maximum box slots, size
compatibility, three-decimal item weight, equip/remove, development break, and
drop. Pickups remain on the ground only when their weight exceeds capacity and
the box has no free slot. Dropped objects preserve size and durability. The box formula remains
`2 + floor(Type1Percent(Intelligence) / 50)`; Tarot bonuses remain reserved.

Strength carry capacity uses Type 4 multiplied by `BaseMass / 100`. Agility
jump scaling is Type 1.

## Retained validated systems

**Implemented and previously validated**

- Seven vulnerability grades, localized armor, reinforcement, durability, and
  critical damage-only behavior.
- Natural critical-region lucidity loss, armor absorption mitigation, sleep
  multipliers, dizzy accuracy, stun, and pain-animation immobilization.
- Health-state penalties, Patience mitigation, survival penalties, progressive
  health-bar color, evasion, crouch bonuses, jump scaling, and air costs.
- Adrenaline events, enemy-kill and nearby-ally-death gains, and unchanged
  out-of-combat decay.
- Training dummy, sword, staff, shields, ranged actor attacks, four actor sprite
  sets, and six compact debug pages.

## Required 4.0 test pass

1. Build and start GZDoom 4.14.2; confirm ZScript parses without errors.
2. Open creation and traverse all eight pages in both orders for mixed classes.
3. Confirm four family points and thirty individual points remain mandatory.
4. Cycle race, sex, and height; verify mass/size tiers and player collision size.
5. Compare armor type/tier changes with equipped, inventory, debug, and total
   carried weights shown on character page one.
6. Spend and refill Anima; verify HUD, staff cost reduction, and faster casting
   at higher Eloquence.
7. Spawn all four actors and verify dimensions, health, armor, physical damage,
   magical damage, pain, death, and actor debug page values.
8. Re-run the previously validated shield, armor, lucidity, pain, adrenaline,
   movement, jump, survival, and resource controls to catch regressions.
9. Change maps after confirming a character; verify the creator stays closed
   and profile, resources, armor, shield, durability, and owned counts persist.
10. Compare sword/staff push and Rulo/Ronnie projectiles. Both physical and
    magical confirmed hits should push; misses and evasion should not.
11. Assign the equipment and equipment-pickup test controls. Spawn several
    armor/shield combinations, collect them, equip and remove them, then verify
    individual durability and ownership survive save/load and map travel.
12. Trigger explosions at low, middle, lateral, and full-body positions. Verify
    the armor page's touched-region count and independent piece durability.
13. In equipment, cycle XS through XL and verify incompatible sizes cannot be
    equipped for the current character size tier.
14. Check shield weights at M: magic 4/6/8, buckler 8/12/16, kite 12/18/24,
    and tower 16/24/32 for tiers 1/2/3; then verify size multipliers.
15. Collect objects below capacity and confirm they enter personal inventory
    and increase carried weight without consuming box slots.
    Fire the carbine and confirm that each bullet lowers load by 0.003.
16. Exceed capacity and confirm the next object enters the Magic Box without
    increasing load; fill the box and confirm another overweight pickup stays
    on the ground.
17. Cycle to Weapons, spawn sword/staff/carbine variants, collect them, and
    confirm incompatible sizes cannot be equipped.
18. Equip sword, staff, and carbine simultaneously. Confirm that equipping one
    does not unequip the others; use 3/5/6 to activate sword/carbine/staff and
    Fire to confirm their respective air, bullet, and adjusted Anima costs.
19. Compare carbine fire while standing, running, crouching, and Mareado;
    inspect its visible spread and verify the 48-tic firing limit.
20. Break an equipped weapon and confirm it retains weight but cannot attack;
    then drop/recollect an unequipped weapon and verify durability and size.
21. Save/load and change maps with objects equipped, in personal inventory, and
    in the Magic Box; verify location, load, durability, bullets, and counts.

## Not yet implemented

- Final buffs, debuffs, healing abilities, and dialogue consumers for the new
  Eloquence range/Labia values.
- Save migration from profiles created with the legacy three-layer format.
- Remaining weapon families, material catalogue, Tarot, and final visual
  inventory tabs; armor/shield/weapon Magic Box capacity, filters, and core
  item actions are functional.

## Jewelry crafting — 4.23.4

Implemented universal amulets and elemental seals with tier-based weight, attribute bonuses, Jeweler Bench infrastructure, and MAP01 test placement. Raw gems, copper, tin, and coal are registered for future systems and intentionally have no current recipe function.
