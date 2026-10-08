# Known pitfalls and verified lessons — Caelum Argenteum

Status: integrated engineering register (issue #22, patch 4.36.1b).
Prepared: 2026-09-23. Inherits the project's release after integration.
Inspected baseline: `1dc390576fa330d37ff543526fc7e69a397fc28f` (PR #7).

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

## CA-KP-049 - A filtered global iterator per NPC can still become quadratic

Status/evidence: RESOLVED-VERIFIED. First recorded / checked: 2026-10-07.
Issue #130 / 5.1.0; dirty implementation over `45f1637`, exact per-run package
hashes in [5.1.0 evidence](../assets/validation_510/RESULTS.json).
Environment: Windows/GZDoom 4.14.2/Vulkan, full normal MAP06 army, 5% audio,
background unpaused. Scope: `CaelumThermalWorld` and shelter/body sampling.

The initial per-body roof query constructed a filtered `ThinkerIterator` for
vehicle ranches. The native search still walked the global thinker population;
doing this for thousands of bodies reduced tics 105–700 to 9.05 tics/s.
Caching the small source/ranch lists once per real second restored 28.07.
Reusing the NPC's due time before climate/attribute lookups, caching mass/area,
and removing repeated health recomputation restored 32.76 in that intermediate
build. Matched intermediate logs retain identical exposure aggregates and
populations: this saving did not exempt offscreen actors or drop elapsed time.
Final arrival samples reach 33.62–34.15, versus 34.48–34.95 in the accepted
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
the staggered variant's congestion p95 callback gap is 341–413 ms versus
267–268 ms for shared perception on demand. Late throughput differs by about
one percent; this does not justify shipping the worse congestion tail.

Keep the shared decision and candidate cache on demand. Candidate sharing
alone has no resolved independent throughput gain in these repetitions;
report reduced enumeration separately from speed. Exact cannon pruning adds
a modest improvement: congestion callbacks rise from 7.55–7.59/s to
8.17–8.20/s, with p95 gaps falling from 267–268 to 245–265 ms in the isolated
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
500 → 1 → 500 living combatants; the old full-army save upgrades without
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
raises its repeated whole-window throughput from 13.115–13.330 to
32.644–32.825 tics/s. Adding spatial guard queries raises it to 34.865–34.989.
These comparisons retain the same sampled scene rows; their final movement
success/error observations also match. This is a positive interaction result,
but the shared march still replaces Mandinga combat and cannot preserve rigid
alignment when native collision blocks individual members.

The final march combination yields only 20.243–22.818 overlay callbacks/s,
with p95 gaps of 128.496–209.216 ms. Normal combat with shared perception,
spatial guards and cannon retry improves late simulation from 3.057 to
23.686–25.209 tics/s, yet has 835.627–902.145 ms p95 callback gaps. Neither
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
movement, raises throughput from 9.373–9.575 to 30.130–30.415 tics/s over
tics 35–2100. Target-selection exclusive cost drops to 0.661 ms/tic in shared-a;
the ordinary later target scope reaches 303.683 ms/tic including its sight calls.
This is positive evidence for reducing repeated perception, not a shipping fix:
followers inherit a different position's visibility and nearest target.

The aligned march prototype confirms the interaction risk. Sixty shared plans
reach nominal 35 tics/s early versus 18.610–18.919 with 6,000 independent plans.
Across tics 35–1715 it is instead 27.2–27.3% slower: its changed trajectories
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

## CA-KP-033 — Refresh dialogue text after successful-open rewards

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

## CA-KP-032 — Test ability input through the native ready weapon

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

## CA-KP-031 — Clamp projectile travel before native collision

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

## CA-KP-030 — Join per-instance evidence by identity, not array position

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

## CA-KP-029 — Lowering a base sector changes upper map-thing spawn heights

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

## CA-KP-028 — Temporal forecasts must preserve within-tic ordering

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

## CA-KP-027 — Terrain relief can invalidate absolute-height relocation filters

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

## CA-KP-026 — Detached control rooms must remain outside playable geometry

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

## CA-KP-025 — Normalize all four coefficients of generated UDMF planes

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

## CA-KP-024 — A valid oversized floor can disappear in the renderer

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

## CA-KP-023 — OBJ height and map headroom use different vertical scales

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

## CA-KP-022 — A magic-resource wait can strand an otherwise mobile army

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

## CA-KP-021 — Cannon target sight must originate at the raised barrel

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

## CA-KP-020 — Repeated OBJ material declarations create unsafe surface counts

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

## CA-KP-019 — A 3D wall inherits its control texture, not its visible face

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

## CA-KP-015 — Git checkout can invalidate raw document hashes

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

## CA-KP-016 — Register dynamically selected Arcana front sprites

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

## CA-KP-017 — Unregistered NPC secondary-wind sprite freezes rendering

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

## CA-KP-018 — USDF page insertion shifts saved conversations

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

## CA-KP-001 — Adding a guide to docs breaks the current exact-file check

Status/evidence: RESOLVED-VERIFIED tooling contract (issue #22, patch 4.36.1b).

Observation: the validator used to require exactly the five canonical plus two working documents under docs/ and current-version headers in those registered documents. Copying these two guides into docs/ therefore failed that exact-set check.

Cause: an explicit exact-set validation contract, not invalid Markdown.

Resolution: issue #22 registers `GZDOOM_DEVELOPMENT.md`, `KNOWN_PITFALLS.md` and the generated `DOCUMENT_INDEX.md` as the explicit allowed docs set. The seven canonical/working documents and AGENTS remain subject to current-version checks; the ancillary guides inherit README's release. The unexpected-doc-file check stays active against the extended allowed set, and the guides' existence, UTF-8 readability and repository-relative links are validated.

Verification: before the patch, a disposable copy with the two guides failed the exact-set check; after the patch, `python validate_project.py` exits 0 with ten docs and an empty error list. Disposable negative cases still fail for a missing guide, a broken guide link, an unexpected docs file and a version mismatch.

Author acceptance: recorded separately for the 4.36.1b documentation patch; this entry describes the tooling fix, not a runtime defect.

## CA-KP-002 — Default equipment size is not the character's raw body tier

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

## CA-KP-003 — Nested bow crop composition stalls on first presentation

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

Cause: TEXTURES nested 167–173 row crops per tier through a full recolored
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

## CA-KP-004 — Flail rotation must be judged around the rendered grip

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
Doom II, fresh isolated MAP03 games. T1–T3 native before/after rest captures,
grip/joint checks, 45-degree attack increments through 360 degrees, return and
holster/re-equip passed with zero failures. The chain's 17.424612-degree native
rest offset stayed unchanged. [Evidence and conditions](../assets/validation_4363/RESULTS.json)
include filtered native logs; capture-only HUD suppression reveals the layers.
Automated native callbacks do not replace final author aesthetic approval or
prove untested renderers. No save field/state schema or combat timing changes.

## CA-KP-005 — A green validator or a built PK3 is not a gameplay pass

Status/evidence: CODE-VERIFIED tool scope. Baseline validate_project.py and build_dev.ps1.

Observation: Python checks selected project contracts; the builder packages source files and checks archive/PNG properties. Neither tool executes a normal player route or proves that ZScript compiles in GZDoom.

Prevention: report static validation, packaging, engine load, scenario behavior and author acceptance separately. Do not reuse an old engine success as evidence for a changed commit. State limitations of Linux/Freedoom fixtures and preserve target Windows verification.

Resolution: this is a workflow safeguard, not a bug awaiting a code fix. Each PR supplies the levels relevant to its change.

## CA-KP-006 — Planned state can drift between issues and canonical documents

Status/evidence: CODE/DOCUMENT-VERIFIED discrepancy plus explicit author clarification.

At the inspected PR #7 commit, its reward clarification still describes size-M prices with tiers pending. The author's later instruction and updated issues #10/#14 specify T1 and the recipient's equipment size. Local edited documents can be newer than their Git HEAD; they must not be cited as committed evidence.

Prevention: compare the exact commit and dirty-tree status, distinguish author-approved design from shipped implementation, and reconcile the current canonical sections during formal integration. Do not silently revert a later author decision because an older document says otherwise.

Acceptance: issue #22 reconciled the then-confirmed T1/recipient-size rule. The later #10/#14 author decision supersedes that reward formula with fixed 25 gold plus 10 own-faction reputation, implemented in future #14. Issue #10 reconciles current references and preserves the displaced formula in HISTORY. Historical fixed-M and price-average discussions remain historical.

## CA-KP-007 — New serialized event handlers are absent from older saves

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

## CA-KP-008 — Changed map geometry prevents old saves from loading

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

## CA-KP-009 — MODELDEF slots overlay state meshes

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

Regression: `python assets/validation_43614a/check_siege.py` checks exclusive
state bindings, valid OBJ/material references and two byte-identical generator
runs. Render affected states in the target engine after binding changes.
Author acceptance: `CA-43614A-SIEGE-ART-01` passed on 2026-09-26. This verifies visual
previews, not future breakable-gate physics or historical machinery dimensions.

## CA-KP-010 — Damage proxies must preserve native projectile damage callbacks

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

## CA-KP-011 — A solid damageable actor is not automatically an Impact Physics body

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

## CA-KP-012 — A composite mover must query collision with a solid active proxy

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

## CA-KP-013 — Old map saves can retain the pre-feature EventHandler list

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

## CA-KP-014 — FastProjectile collision does not integrate gravity

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
z=z0+v0z*n-g*n*(n+1)/2 and vz=v0z-g*n; native g was 1 MU/tic². Thin wall,
blocked muzzle, floor/ceiling and actor contacts were tested separately. A
subclass that adds gravity should not also run ordinary Actor movement, which
would advance the projectile twice. Default engine gravity here corresponds
to 38.28125 m/s² at project units, not Earth's 9.80665 m/s².

This finding is scoped to GZDoom 4.14.2 FastProjectile, not all actors. The
game's accepted general collision damage/crushing formulas remain unchanged.
Author acceptance CA-43613-CATAPULT-01 is pending.

## CA-KP-015 — Input and multi-frame attacks need one absolute clock

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
9. Keep entries concise (normally 150–300 words excluding a necessary small reproducer). Link to canonical formulas rather than copying large tables.
10. Review only the touched entries and connected rules during a patch. Do not add a full historical audit or additional engine run solely to expand this register.

## Copyable entry template

```text
## CA-KP-NNN — Concrete symptom or constraint
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
