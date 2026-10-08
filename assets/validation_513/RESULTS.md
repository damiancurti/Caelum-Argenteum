# #133 / 5.1.3 city, commerce and deployment validation

Implementation and agent validation delivered for review. CA133-01/02 still
require author acceptance. The continuous-fire experiment exposes an inherited
thermal balance limit; it is explicitly not a successful sustained-fire test.

## Scope and reproduction

Windows 11, GZDoom 4.14.2, Vulkan, 1280x720, 60-FPS ceiling, seed 116, skill 2.
Each native runner records engine/IWAD/package/addon hashes, arguments, initial
configuration and UTC start/completion. Runs do not overlap. Audio is 5%, with
simulation and rendering enabled in the background. Thread-scoped keep-awake
requests leave the power plan unchanged and must be released at completion.
No engine, IWAD, PK3 or saved game is distributed with this evidence.
The unchanged #132 performance observer protects the camera player with native
invulnerability; NPC health, collision, resources and combat remain live. Its
scripted-kill mode is disabled in all four #133 performance controls.

`prepare.py` builds deterministic production/probe PK3s under build/issue133.
`prepare_legacy.py` retains the exact accepted b00201098a26582c8820a5424a2a75986b022abf
source package and creates persistence probes. Build the compatible update with
`build_dev.ps1 -LegacyMap06SouthCity -Destination build/issue133/upgrade/baseline.pk3`.
`prepare_visual.py final-visual` writes short chained native command scripts;
`run_final_checks.ps1` executes fresh deployment, components, persistence, visuals
and performance. Its optional `-RecoverySave` is only for a retained exploratory
checkpoint; the fresh route is independent of it. `run_delivery_checks.ps1`
also reproduces original-package seed/reload/hub/rollback controls. Use fresh
labels/directories for repeats; never overwrite an active engine package.

## Established component results

- Static geometry: 1,629 checks; 160 homes, 64 shops, 24 factories and 40 warehouses; two native
  door leaves, one medium table, six chairs, bed and empty bathroom per home.
  Living/bedroom/bathroom usable area is 60.000/30.244/9.756 percent, including
  doorway circulation and excluding walls/window sills. Deterministic MAP06 output.
- Furniture: 1,123 native checks, including all 960 actual chair seats/releases,
  160 bed seats/releases, and native collision traversal of three representative
  full homes. Fixture relocation between houses is not manual traversal acceptance.
- Factories: 132 authoritative recipe/dependency entries plus native workbench collision
  coverage. RECIPE_COVERAGE.json retains labels, recipe kind, coordinates and
  network capabilities. No free inputs, recipe knowledge or changed efficiency.
- Commerce: 34 native checks across all six T1 catalogues, approved prices/stock,
  currency change, capacity rejection, merchant cash, native pickup persistence,
  drop/repickup, resale/repurchase of the same ID/wear/wetness and Palomo isolation.
- Carbine component control: ten-shot magazines and repeated normal reloads,
  native hits/wear, range/resource/cadence checks, melee/pain/death interruption,
  no infinite inventory stack, finite player ammunition. The maximum-attribute
  diagnostic sustains repeated magazines; it does not replace ordinary soldier
  attributes. The earlier default-18 control exhausted Air after 14 shots and
  one completed reload, as normal resources require.
- Initial-city control: eight native assertions cover all clear housing positions,
  furniture counts, peace/date transition and physical exit of all 600 soldiers.
- Obstruction/casualty control: five native checks preserve a dead original actor,
  wait at an actual solid doorway obstruction and resume after it clears.
- Formed-crew replacement: two native artillery casualties are replaced by existing
  infantry identities 217/218. Both climb the stairs without relocation and reach
  their new posts at elapsed tic 1252; all 600 references and both corpses persist.

## Persistence and deployment evidence

The legacy control creates a real save in the exact accepted 5.1.2 package,
loads it in the current compatible-geometry package, saves/reloads, leaves and
reopens MAP06 through MAP03, then reloads the original save in the original
package. All five delivery legacy runs pass; they check roster count and the
recorded original defender's identity, health, position and assigned station.
This policy retains the visited old geometry; it does not import a visited hub
into the new floor plan or prove that an upgraded save can load in old code.

The new-city deployment snapshot separately compares all 600 original references,
health, house identities, station/position, deployment step/completion, magazine
and reload state before the first loaded/reopened tic. Trade snapshots separately
cover actual merchant stock/cash and the purchased native equipment instance.

Incremental obstruction recovery reached all 600 posts in route-native-edge.
The final independent fresh run, **route-delivery**, retains all 600 alive and
at their posts through tic 35000, with all 72 crew routes complete and no temporary
yields pending. ROUTE_FINAL.json reads the real final save and records its hash.
The separate route-crew-final-b checkpoint control recovers a late obstructed
artillery approach and returns its yielding guards. The routing control ends combat after the scheduled
first attack group, retaining all bodies, collision, resources and physiology.
It never teleports defenders, replenishes their resources or removes blockers.

## Visual verification and source binding

final-visual captures 48 directional/action poses and 12 UI/home/player views.
The pose is held both before and after screenshot requests so deferred rendering
cannot change its label. Representative unedited native captures are retained in
captures/; MANIFEST.json records all 60 original hashes. The player burst includes
normal short gaps between shot poses; final-player-shot separately captures a
single real discharge. Native logs also verify shot/reload frame changes, finite
magazines, crouching and restoration of the existing sword appearance.

MANIFEST.json compares production.pk3 and the normal build against every src byte;
the compatible build differs only by the exact archived MAP06. Final production
is bound to the source in implementation commit f4c2bdfe. Each retained run has
its own package/addon hash; earlier exploratory records are not relabelled as
final-source results or author acceptance. No test fixture is packaged in src.

## Performance and thermal limit

PERFORMANCE.md/JSON separate matched old-geometry full/staged armies, occupied
peaceful city, scheduled exit, combined deployment/combat and the firearm control.
The old full/staged pair gives **27.16/34.99 tics/s** and **1.69/57.82 render
callbacks/s**. The new peaceful city gives 35.01 tics/s and 59.96 callbacks/s;
the later combined workload drops to **32.25 tics/s and 14.07 callbacks/s**.
These are background engine measurements, not Windows presented FPS or proof
of the author's 35-tic/30-FPS target. New geometry, calendar and carbine behavior
are measured together; this is not an isolated map-geometry delta.

The combined run ends at tic 10500 with 579 surviving defenders, 200 completed
ground deployments, 266 shots, 19 reloads, 1,636 living Mandingas and 2,500 spawned
of the 6,000 budget. There are 885 corpses and zero scripted deaths. The 28
placement retries remain visible; no pending group member remains at the endpoint.
Natural casualties and resource constraints are retained and affect workload.

The separate 600-body firearm component records 8,400 shots and 600 completed
reloads. During the live fire/reload phase it gives 35.02 tics/s and 51.61 render
callbacks/s, with most actors offscreen. It **cannot sustain that workload**:
every soldier stops at 14 shots and then dies from accumulated thermal damage
by tic 1400. HEAT_LIMIT.json reads two native snapshots: 836,062.5 J of action
heat and eventually 2,202 HP of thermal damage per actor. The #130 conversion
is exactly 14 shots x four jump references; there is no second heat surcharge
in RecordAction. This existing approved profile needs an explicit calibration
decision. No soldier exemption, health refill or thermal balance change is made.
Post-death rendering is reported separately and is not a positive live-AI result.

## Exploratory failures retained locally

Early routes exposed shared-waypoint contention, indefinite native Chase turns,
unfair per-tic path-query admission, a case-insensitive goal parameter shadowing
the serialized field, occupied formation entry cells, the retained harbor bed,
and a native step/dropoff query difference. They are not passing evidence.
The completed approach uses generated street routes, real native movement,
fair bounded local path queries, occupied transit tolerance, precise destination
approach and temporary access-column yielding. Failed route checkpoints/logs
remain in build/issue133; completed counters alone never mean all posts passed.

Visual sweep A was invalid: an oversized native exec line split commands out of
order. Sweep B exposed native state/Tick replacement of the forced diagnostic
pose and player attack sprite. Sweep C verified that fix but revealed uneven
atlas boundaries and a missing deferred last screenshot. Final registration
clips measured transparent gaps in the unchanged PNG; final captures follow
short chained scripts with a wait after every screenshot. Synthetic desktop keystrokes
did not reliably reach raw game input; native use/network events were tested,
while physical keyboard and visual author acceptance remain distinct.

## Outstanding author work

CA133-01 covers physical interior/trade controls and bilingual readability;
CA133-02 covers ordinary deployment/combat and visual carbine acceptance. Both
remain in the root pending_test.txt. Thermal sustained-fire calibration is a
design follow-up in TASKS, not a claimed passed author test. Build/static checks
pass; temporary keep-awake requests are released with matching before/after
power plans in power-request.json and power-request-2.json.
