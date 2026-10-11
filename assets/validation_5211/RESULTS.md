# 5.2.11 / #194 collision energy and contact area

Baseline: `e9af2707`, the accepted #192 amendment (PR198 was open during testing
and subsequently merged into main on 2026-10-11).
Target: GZDoom 4.14.2 / Windows 11, Vulkan, 1280x720. Runs are isolated,
unpaused in the background, at 5% audio, one engine at a time. Fixtures use
production ZScript and actual native actors. No development IWAD, executable,
save or generated test PK3 is distributed. See STATIC.json and AUDIT.json for
package fingerprints, source-byte checks and run records.

## Final native results

| Run | Checks passed | Scope |
| --- | ---: | --- |
| release-energy | 68 | SI fixtures, initiator/frame invariance, zero/tangent motion, area x1.25, directional/rotated anatomy, crouch bounds |
| release-combat | 47 | 100/1000/10000 J independent of Hmax, bilateral/passive deduplication, death snapshots, regional armor/wear, mixed pressure samples, healthless scenery |
| release-player | 11 | Actual player reception, landing energy squared, hazard-rock landing, incoming source exclusions, ideology isolation, cannon full armor absorption |
| release-motion | 15 | Production Tick, actual body/floor/gate/rock landings, native FastProjectile flight, real pressure accumulation and discharge |
| release-siege | 63 | Three gate materials, anchoring, proxy order, two ram sizes, warrior/mage armor, cannon oblique/vertical hits, native muzzle/ram sweeps |
| release-pressure | 23 | Actual MAP08 four-panel crusher, 507600 kg, measured native pulses, same-tic dedup, stationary load work and legacy carry reset |
| release-contacts-save / reload | 2 + 11 | Shared graph, normalized work distribution and pending joules persist; no impact replay; work consumed once |
| legacy-baseline-save / production-reload | 1 + 6 | Real 5.2.10 save loads in 5.2.11; old contact graph preserved, percentage carry resets idempotently without HP conversion |

The current-version matrix passes **240 assertions**; the baseline save setup
and six migration checks also pass. The official package is separately compiled
and byte-compared with the tested runtime: the only difference is the required
MAP02 diagnostic version label (5.2.10 to 5.2.11), with no gameplay change.
Native numeric fixtures are isolated
engine tests, not author acceptance or a complete campaign playthrough.

The motion fixture gives actors their normal production Tick and native CANPASS
behavior. It observes equal 2780.299010 J on a falling body and its support,
7404.618449 J on the corresponding floor landing, one rock vertical event, and
one cannon contact at 526186.979931 J. Forced repeated approach velocities probe
contact pressure; separation can flush a partial interval. The pressure fixture
independently observes real 35-tic static-load accumulation and real native
crusher pulses. Formula-only fixtures deliberately freeze their recipients so
unrelated AI, regeneration or movement cannot alter expected HP.

## Recorded comparison

Warrior/mage fixtures have natural masses 200/70 kg, Toughness 20, uniform heavy
T1/magical T1 armor and neutral base anatomy. Their collision masses include
40/5 kg of armor. Fixture HP is raised to observe the uncapped computed loss.
These controlled examples do not replace a complete character build comparison.

| Strike / receiver | Raw energy = raw HP | Final HP loss |
| --- | ---: | ---: |
| Small ram / warrior | 158084.798839 | 36059 |
| Small ram / mage | 52164.643073 | 34323 |
| Large ram / warrior | 168641.865258 | 38487 |
| Large ram / mage | 53264.928431 | 35050 |
| Cannon / warrior | 528039.295948 | 121148 |
| Cannon / mage | 508354.350567 | 335409 |
| Cannon / common gate | 537500 | 482815 |
| Cannon / reinforced gate | 537500 | 427985 |
| Cannon / armored gate | 537500 | 370530 |

Cannon armor penetration is zero, following the author's latest instruction.
Gate damage uses 10/20/30% structural absorption followed by 935/2015/5720 HP
Toughness reduction. Actual gate HP remains 5500/6500/11000; high fixture HP only
allows inspection of the computed result before death removes the object.

## Corrections and retained evidence

All intermediate text logs/run manifests are retained under evidence/; failed
attempts are not counted as passes. Initial compiler failures exposed a reserved
identifier, unsupported Array<Vector3> storage and play-scope requirements.
They were corrected with parallel coordinate arrays and explicit play methods.
The first combat fixture initialized actors before deferred PostBeginPlay;
explicit fixture mass multipliers corrected the setup. Pressure tests exposed
lazy inventory initialization and an invalid next-tic duplicate test; both were
corrected. The first reload passed an absolute path alongside savedir, producing
a doubled path; using the saved basename fixed it. Initial motion fixtures lacked
CANPASS and dereferenced a disposed projectile; production movement now runs with
the proper native flag and records the contact before disposal. Two expected
armor results were corrected to include reinforcement and the canonical Type-3
curve, rather than changing production to satisfy an incorrect expectation.

Independent static review found shared-region boundary clipping, mid-event
shared-slot armor wear, crouch/source bounds, whole gate/ram proxy geometry,
anchored gate landing, and last-sample pressure reassignment. Corrections retain
pre-impact snapshots and each sample's cushioned energy/region distribution.
Final review also caught the distinct incoming-rock versus landing-on-rock
cushion rules; targeted tests cover both. No bull rebalance is included (#195).

## Reproduction and limits

Run `python assets/validation_5211/prepare.py`, then the local `run_native.ps1`
with a fresh label, fixture name, matching config and MAPQA (MAP08 for pressure).
Example: `-Label check-energy -Fixture energy -Script energy.cfg -Map MAPQA`.
For migration, run legacy with `-Baseline -Script legacy.cfg -Map MAPQA`, then
the production runtime with `-Script legacy_reload.cfg -LoadGame ca194-legacy-5210.zds`.
Do not distribute the resulting build/ packages, maps or saves. Old save/runtime
copies remain intact for rollback; no campaign-wide compatibility claim is made.

Contact area is a documented native-box face approximation, not a deformable
mesh solver. Static-load 0.1 mm/s internal creep is the author-delegated simulation
parameter, not a universal tissue constant. Existing invulnerability and faction
eligibility remain. Multiplayer and large-army performance are not newly certified.
The author accepted CA194-01 (origin 5.2.11 / #194) on 2026-10-11 without
qualifications and requested merge/closure; HISTORY records the confirmation.
The author test queue is empty. This acceptance does not extend to #195.
Keep-awake uses a temporary thread request and is released after
native testing, without a power-plan change; its record is retained in evidence/.
