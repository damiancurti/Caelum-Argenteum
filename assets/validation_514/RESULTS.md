# Issue #140 / 5.1.4 validation

Date: 2026-10-08. GZDoom 4.14.2 / Windows 11 / Vulkan, 1280x720,
60-frame cap, seed 116, skill 2, master audio 5%, background simulation and
rendering enabled. Per-run JSON records retain engine/IWAD/package/addon hashes,
arguments and initial settings. Development binaries, IWADs, PK3s and saves
remain local. Original code reference: `dd8e18bdf12f91648b6d982991c9fda10b787627`.

## Original component native results (before later firearm/shivering decisions)

| Control | Result and scope |
| --- | --- |
| mechanics-d | 64 assertions, zero failures: 4 player races x Constitution 0/50/100; finite quarter-bar recovery costs; 8 native NPC profiles including bull/rat sweat; 5 armor types, equipment moisture authority, anatomy invalidation, breathing thresholds, signed analytic respiratory energy, player/NPC recovery, native chair modifiers and coupled protected travel. |
| Frozen reference inside mechanics-d | 140 cases / 4,480 intervals across body sizes, material, humidity, wind, immersion, rain, activity, fire and magic. Exposure, water and dose differences print zero to 12 decimals; water bound <1e-9 kg, exposure 1e-8, dose 1e-7 seconds. Separate 200 analytic dose comparisons pass at 1e-8. New breathing is disabled only for this old-model equivalence comparison. |
| effects-a | 39 existing native integration assertions: actual walking/jump input, nominal action heat, heat Air costs, armor moisture, shields, fire/ice and continuous energy, cold timing/damage, safe/unsafe journey behavior. The obsolete #130 abstract Thirst expectation is explicitly changed to its approved removal. |
| immersion-a | 20 unchanged #130 geometry assertions plus 6 new actual-water assertions: walls/roof, layered 3D water temperatures, anatomical immersion and fire occlusion; full submersion stops panting/bonus and ordinary Air regeneration; surfacing resumes fatigue ventilation. |
| audio-a / audio-reload-a | 12 native channel assertions across male/female moderate/high clips, independent pain voice, recovery, heat-only activation and death; loading reconstructs the loop. Playing-channel queries establish engine integration, not subjective acoustic quality. |
| migration-seed-a / migration-upgrade-a | Save under original 5.1.3 revision 3, load under revision 4; exact exposure, acclimation, damage remainder, clothing water, sweat, NPC hydration and player reserves preserved; initialization idempotent. |
| migration-reload-a / migration-rollback-a | Revision-4 reload discards/rebuilds the derived cache; original 5.1.3 save still loads with the original 5.1.3 package. This proves original-pair rollback, not arbitrary old-package loading of a newer save. |
| migration-hub-c | Native hub leave/return preserves NPC primary values, rebuilds cache and preserves player reserves with the expected source-map passive consumption. The fixture accounts for the engine's final personal tic after WorldUnloaded. |
| manual-smoke-a | All nine author-inspection setup commands execute under Spanish localization. The fixture applies each setup once, then normal simulation continues. |
| heavy-b | Real input: 20 seconds running with 10 jump requests, 9 actual launches; then 40 seconds standing, no immersion. Human 100 kg + 40 kg T1 heavy armor, Constitution 12, Toughness 13. Full 1780 HP retained; thermal damage zero. Peak E +1.725808 versus harmful threshold +10.180198; final E -1.436636. Sweat 67.032539 mL; final Thirst 93.528320 includes passive and recovery expenditure as well as sweat. Actual ambient approximately 19.39-20.19 C, RH 67.61-70.16%, relative wind approximately 10.35 m/s running and 1.53-1.57 m/s resting. This confirms one moderate-climate case, not unrestricted exertion or hotter weather. |

The compiler/setup failures retained locally were corrected before the passing
runs: reserved ZScript identifiers, read-only WaterLevel, inspecting newly spawned
NPCs before initialization, an expression swizzle, and a chair assertion that
ignored maximum-Anima clamping. Initial hub assertions incorrectly compared
player reserves against the departure snapshot before normal travel consumption;
native NPC values were exact, and the final fixture measures the actual boundary.
These are not hidden passing runs or author acceptance.

## Isolated calculation cost

mechanics-d alternates old/new order across five repetitions of 4,000 dry solver
steps, with identical initial state and breathing disabled for equivalence.
Reference median: **25.9816 ms**; cached median: **9.2246 ms**, about **64.5% less
time for this solver workload**. Every cached repetition reports one geometry
build and 3,999 hits. This excludes actor Tick, environment queries, rendering,
audio and other game systems; it is not a siege/FPS improvement measurement.

The baseline-city-a run finished before the author suspended mass testing.
The owned cached-city-a process was explicitly stopped at that request; its
partial local evidence is not a pass and is not used as a paired comparison.
No further mass runs were made. MAP01/MAP03/MAP06 throughput remains deferred;
subsequent small sustained-effort calibration is reported separately below. The new sensible respiratory term is deliberately small
(0.0603/0.1206 W/K at 80 kg); it cannot be presented as a guarantee against overheating.

## Reproduction and delivery boundary

Run `python -X utf8 assets/validation_514/prepare.py --baseline`, then
`python -X utf8 assets/validation_514/prepare_integration.py` with no engine open.
Pure map constructors reuse #130 geometry; the old thermal oracle is read directly
from the recorded Git commit. All diagnostic addons remain outside src.
`run_check.ps1` accepts the recorded Package/Addon/Map/Script/LoadGame arguments;
use a new label for every run. Scripts/configuration are recorded in run JSON.
`prepare.py` also builds manual.pk3 and heavy.pk3. The latter's heavy.cfg supplies
real native movement/jump commands; no artificial heat/health immunity is applied.

Migration uses the same production.pk3/persistence.pk3 basenames in old/new
directories and distinct save slots. Preserve original saves. Tests cover the
thermal revision; #133's existing legacy-city geometry selector still applies to
saves that visited the 5.1.2 city. No map is changed in this patch.

The final source manifest compares every runtime member against the package used
for final mechanic tests; older component runs retain their own hashes and
qualifications. Standard and legacy-city builds share runtime code. Audio source
hashes, filters and two-run determinism remain in PROVENANCE.json and
AUDIO_DETERMINISM.json. The temporary thread-scoped power request is released
after native testing; no power-plan values are changed.

CA140-01/02 were explicitly accepted on 2026-10-08 before later firearm/shivering
work. The cancelled running-to-empty-Thirst trial did not reach water exhaustion;
see ENDURANCE_CANCELLED.json. Unconfirmed CA133 author checks remain outstanding.

## Expanded native regulation controls

The author subsequently approved dagger-scale carbine Air (2 rather than 20),
2/2.5 total MET for firing/reload, and shivering from 1 to 5 total MET between
E=0 and -5, paying extra player Hunger proportionally to the baseline rate.
NPC Hunger remains excluded. These are provisional game physiological profiles,
not a core/skin temperature simulation. Water is never reabsorbed into Thirst.

| Control | Observed outcome |
| --- | --- |
| carbine-heat-a, before recalibration | Default 80-kg soldier +50-kg carried load: 14 shots, 1 reload, 59,718.75 J per shot, peak E +44.125223, minimum -15.375364. Died at 113.6 s after heat followed by wet-clothing cold; 340.800 mL sweat. This is a reproduced lethal balance defect, not a survival pass. |
| greatsword-heat-b, before shivering | 100-kg human +40-kg T1 heavy armor +18-kg greatsword, normal cycles and finite reserves. 67 swings, first impulse 14,006.712 J, peak E +12.058072, minimum -15.673333; died at 148.286 s. Sweat 311.961 mL. |
| pool-wet-a, before shivering | Same heavy profile, one real second fully submerged in actual 22 C 3D water, then stationary. Exited at E -0.301739 and full HP; no attacks/sweat. Cloth capacity 421.197 mL. Died at 117.771 s, minimum E -15.956778. |
| pool-dry-a, before shivering | Identical dry comparator, no exertion: full 1780 HP at 180 s, zero thermal damage, minimum E -4.558524. |
| pool-wet-c, with shivering | Clean repeated native immersion: full 1780 HP at 180 s, zero attacks/sweat/thermal damage, minimum E -6.506146. Cloth dried completely. Hunger funded the additional metabolic heat; no supplies were restored during the run. |
| greatsword-regulated-a | 120 s normal attack requests then 60 s rest, heavy armor: 69 swings, 312.047 mL sweat, peak E +12.061531, minimum -4.113606. Survived at 1743 HP, cumulative thermal damage 122 HP. Shivering prevents the previous cold death; the initial burst still overheats. |
| greatsword-paced-a | Same profile, stop requests at/below 50% Air, resume strictly above: 43 swings, 261.796 mL sweat, peak E +12.061531, minimum -3.523161. Survived at full 1780 HP after ordinary healing, but cumulative thermal damage was 66 HP. Pacing reduces hot exposure duration; it does not erase the first hot burst. |
| mechanics-i | 87 passing assertions on the final runtime: original regression matrix plus shared firearm Air, real/partial action clocks, interrupted reloads, no overlap/double heat, independent energy queues, shivering limits, food affordability, NPC scope and side-effect-free food/thermal forecasts. |
| immersion-drying-a | 20 geometry +6 immersion +4 drying assertions. Declared 20,000 W source: 7.350389 W absorbed at the unobstructed sample, 1.820848 W farther away, zero behind a wall. Across 1200 world seconds, evaporation rises from 189.319291 to 190.246839 mL; added source energy 8820.467317 J also reduces required shivering. Water conservation and 2.45 MJ/kg latent accounting pass. This tests the retained indirect surface-temperature approximation, not an independent garment-temperature node. |

All these are bounded temperate controls, approximately 19-22 C. The calendar
runs at 20 world seconds per real second in this fixture; HP dose uses real
seconds. The exposure value is not clinical core temperature. Clothing capacity
belongs to the light fabric beneath metal, not absorption into steel.

The pool-wet-b repeat was explicitly cancelled after uncommanded attacks;
pool-wet-c uses isolated unbound controls. The pool-wet-a runner reached the
native completion marker but hit a final log-reader race after Stop-Process;
finalization was recovered after verifying process exit, and the runner was
corrected to wait for exit before reading. Original failed/setup evidence stays
local; no failed or cancelled trial is counted as a passing gameplay result.

## Magic, armor coverage and final persistence

The author authorized commit/push/merge/closure if the focused controls were
stable, reiterated after the observed outcomes. This is integration authorization
based on agent evidence, not a fabricated new manual-test confirmation.

| Control | Observed outcome |
| --- | --- |
| mage-fire-cloth-a | Native double-Mage profile: 70 kg, T1 magic cloth +staff, 951 maximum HP, 2360 maximum Anima. Full HP and zero thermal damage after 120 s casting requests +60 s rest; E [-0.157415,+0.018087], sweat 0.768 mL. The original cast-completed flag was reset by repeated action requests; its zero counter is invalid. Resource depletion demonstrates activity; later controls count individual Anima debits and include actual target hits. |
| mage-ice-leather-a | Same mage with T1 leather: 62 completed casts by observed Anima debit, full 951 HP, zero thermal damage, E [-0.008959,+0.066906], sweat 11.855 mL. Finite Anima limits firing and its normal recovery spends supplies. |
| mage-fire-base-a | Base clothing, T1 fire staff: 62 casts, 27 target hits, full 951 HP, zero thermal damage, minimum E -0.813484, no sweat. Final Hunger 85.828055, Thirst 89.357777. |
| mage-ice-medium-a | Medium metal-over-cloth, T1 ice staff: 62 casts, 27 target hits, full 951 HP, zero thermal damage, minimum E -0.635770, no sweat. Final Hunger 86.210248, Thirst 89.357777. |
| carbine-heat-b | Revised default soldier: 130 shots /12 reloads at 120 s, full 2168 HP, zero thermal damage; E [-0.570801,+1.428958], sweat 34.416 mL. Its native state progression eventually also closed to melee, so its total ActionJoules is not attributed solely to firing. The subsequent c control isolates the firearm while retaining normal resources/reload. |
| carbine-heat-c | Firearm-only repeat: 130 shots /12 reloads at 120 s, full 2168 HP, zero thermal damage and sweat; E [-0.570801,0]. Total firearm work 16,765.780337 J. State progression is held while normal actor Tick, finite resources and reload clocks continue. |
| effects-b / immersion-drying-a | Final-runtime 39 effort/magic/forecast assertions plus 30 geometry/water/drying assertions pass. Incoming fire/ice and continuous magic retain their separately tested energy path. |
| migration-upgrade-b / migration-reload-b | Original revision-3 save loads under revision 6, exact primary state retained, idempotent initialization and disposable cache reconstruction pass. |
| energy-seed-a / energy-reload-a | Actual native save preserves exactly 97.125 pending firearm joules and 54321.25 accumulated shivering joules, alongside original primary state. |

Together these native controls cover all five armor categories: base clothing,
magic cloth, leather, medium and heavy. They are not an exhaustive cross product
of every race/weapon/armor/climate. The 87-assertion mechanics-i run retains the
broader four-player-race/eight-NPC/material matrix; its old-model comparison
disables both new ventilation and shivering, then tests them separately.
Final dry-solver median is 25.3562 ms reference versus 9.0678 ms cached (64.24%
less local solver time); this remains separate from game or siege throughput.

A caster does not automatically receive its own outgoing fire/ice energy.
Casting, being hit, and standing near a declared flame are distinct paths.
No new magical self-heating or movement-shedding percentage was introduced.
The remaining limits are finite player food/water, bounded metabolic/sweat
capacity, wet-clothing evaporation, climate, and sufficiently concentrated
physical or received elemental energy. Heavy-melee bursts can cross a harmful
threshold before recovery; this is recorded rather than hidden by later healing.

## Final author-requested exposure colors

Only CaelumHUDOverlay and CaelumThermalHUD change after mechanics-i: one shared
six-band RGB palette now drives both the bar and its numeric/state label.
Native hud-color-d captures cover all six bands, neutral, Toughness-scaled
boundaries and extreme overflow in Spanish. Color modulation retains black
glyph outlines. Earlier HUD captures were exploratory: a had overwritten
screenshot names, b flattened outlines, c omitted alpha. They are not visual
acceptance evidence; the final d captures were inspected successfully.
The package manifest explicitly permits only those two post-mechanic HUD files
and binds the final source to hud-color-d and both standard/legacy builds.

