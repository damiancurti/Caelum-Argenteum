# Caelum Argenteum — Collision, Momentum and Impact Physics

## V4.29.0ac — Shared-target and perception diagnostics are live

MAP02 now contains six physical perception rooms and retains exactly 15,000
actors in the mass field. The 1,875 active field actors still divide into 126
native-movement leaders and 1,749 followers at group size 16. The first field
actor to acquire the player publishes one shared target; later actors adopt the
reference without repeating native `A_Look`.

`ca_diag_mass_follower_movement false` reproduces the accepted stationary-
follower control. When set to `true` before loading MAP02, every follower uses
a deterministic local formation destination and continuous velocity at 25% of
its actor `Speed`. This route performs no `A_Chase`, `TryMove` or neighbor scan.
It is an unvalidated diagnostic bridge, not final formation navigation.

The six fixed observers sample visual recognition once per second:

`Pbase = 1000 / [1 + 9(distance metres / 20)²]%`

Values below 1% become zero. Native line of sight, current target height/1.8 m,
Perspicacity x1..x2, retained Stealth and a quadratic angular factor then apply.
The default CVar interpretation gives full strength through ±30° and zero at
±60° (60°/120° total aperture). The alternate diagnostic value compares full
strength through ±60° and zero at ±120°. This unresolved convention must be
chosen from the A/B results.

Movement hearing now starts from the 50-dB base `50²/4 = 625 MU`. Each listener
adds `(50 + L) × [1 + 2L(L+1)/10100]` MU, then total mass/100 kg, mode (walk
x1, run x2, crouch x0.5) and `1 - Stealth/100` apply. Crouching does not also
double Stealth, and listener height is excluded. MAP02 observers consume the
player's movement-event serial once; native `SoundAlert` remains the physical
event source. Weapons, magic, Pain, Death and explosions are outside this
concealable movement-noise path.

## V4.29.0v — Final endurance and Quintaessence results are accepted

The final supplied log contains two clean MAP02 sessions. The 1,033-report
group-16 session preserves 16,608 combat actors and 1,983 active AI actors,
with 126 movement leaders and 1,749 followers. It admits 93,211 native Chase
calls, an average of 90.2 per simulated second, a maximum of 146 per second and
a maximum of nine in one tic. Custom contacts, callbacks, retained references
and duplicate callbacks stay at zero. Every one of the 26 spawned projectiles
reaches impact and destruction, with at most one live at a time and no failure.

The short Quintaessence session peaks at 2,086 affected actors. Its nonzero
sequence is 2,086, 2,086, 2,059, 2,006, 2,006, 1,973, 1,936, 1,927, 1,900,
1,898 and 1,889 before returning to zero; seven later reports remain clean.
The slight frame-rate dip observed at black-hole release is therefore a
bounded high-density cost. Nothing in the exposed collision, reference or
projectile counters persists after release, and no freeze occurs.

These results close the V4.29 diagnostic performance gate with group 16 as the
movement-owner baseline. They do not implement the planned production group
controller. That controller will derive faction/species membership, mutual
perception links, lowest-value spawn-order hierarchy, 30-second link tolerance
and network-wide shared target/memory data in a later isolated patch.

The accepted future auditory reach is also design-only. Native `SoundAlert`
will provide robust engine propagation; base event reach is `dB² / 4` MU and
the listener adds `(50 + L) × [1 + 2L(L + 1) / 10100]` MU for effective
Perspicacity level `L`. This allowance ranges from 50 to 450 MU, applies only
to hearing and never expands collision. Listener height is removed from the
calculation. Concealable body emissions may be reduced by Stealth; weapon,
magic, Pain, Death and explosion events retain their physical sound.

## V4.29.0u — Both squad margins remain stable; group 16 is the baseline

The requested group-size comparison completes without an abrupt stop in both
configurations. Group 16 produces 1,087 complete reports and group 8 produces
995 while preserving the same 16,608 actors, 1,983 active AI actors and full
target acquisition. Contacts, callbacks and references stay at zero in every
report, and projectiles remain bounded between zero and two.

The useful distinction is native movement ownership. Group 16 has 126 leaders
and averages 85.8 admitted Chase calls per simulated second after acquisition;
group 8 has 230 leaders and averages 164.7. Their maxima are 121 and 243. The
smaller grouping therefore costs approximately 1.92 times as much admitted
native pursuit without increasing population or perception coverage.

This completes the diagnostic argument at the current scale:

- High raw actor count is viable when most actors are lightweight and do not
  own independent high-frequency movement.
- Custom contacts are not required for the abrupt mass-AI freeze; they remain
  zero in failed and successful pursuit runs alike.
- Projectiles, explosions, guided behavior and infighting can amplify a busy
  encounter but are not required for the zero-contact failures.
- Dense Quintaessence piles are a different proportional collision workload;
  they should be bounded separately rather than used to choose AI cadence.
- The common failing path is sustained independent `A_Chase`/`TryMove` across
  thousands of actors. A single native call can have variable spatial cost, so
  a call budget alone does not bound the worst simulation tic.

Group 16 remains the production-oriented diagnostic default. Final formations
will share perception goals and movement ownership, use distance/sleep tiers
and stagger one-second recognition checks. Followers may still animate, turn
or take local formation offsets without each issuing an independent native
path request. Normal-map collision, pressure and combat formulas are unchanged
by this acceptance.

The accepted perception design is an adjacent future module, not part of this
performance patch. It will phase one visual recognition check per NPC per
second and consume event-driven hearing stimuli, sharing the curve
`1000 / (1 + 9(d / 20 m)^2)%` before height/mass, Perspicacity and Stealth
modifiers. V4.29.0u still runs the legacy movement `SoundAlert` path; therefore
the successful squad tests validate movement ownership, not the unimplemented
recognition formula.

## V4.29.0t — Squad ownership survives the longest controlled endurance run

The V4.29.0s group-of-16 run remains responsive for 1,328 complete reports,
approximately 22 simulated minutes. All 1,983 active AI actors hold targets,
but only 126 deterministic leaders can request native movement. Admitted Chase
averages 96.6 calls per simulated second and peaks at 161 instead of remaining
saturated near 350. Contacts, custom collision callbacks and retained contact
references are zero throughout; live projectiles remain bounded at zero or one.

This separates three performance regimes that previously appeared related:

- Dense Quintaessence piles produce a proportional slowdown through native
  collision candidates plus up to tens of thousands of custom callbacks.
- Explosions, guided projectiles and infighting amplify work but are not
  necessary for the abrupt mass-AI stop.
- Repeated independent `A_Chase`/`TryMove` remains the common controlled path
  of every abrupt zero-contact failure. Its per-call internal spatial work is
  not bounded by the exposed call counter.

The result supports a production architecture with shared squad goals,
distance/sleep tiers and a bounded number of movement owners. It does not yet
prove a specific engine defect or make a fixed leader count universally safe.
V4.29.0t also fixes the report to exclude passive visual bodies from squad
membership; the active field is 126 leaders plus 1,749 followers.

## V4.29.0s — Independent native movers are isolated by diagnostic squads

The V4.29.0r endurance run still stops after 148 complete reports even though
13,125 passive fillers are absent from the blockmap. All 1,983 AI actors have
targets, custom contacts and callbacks remain zero, and live projectiles stay
between zero and two. Passive blockmap residency is therefore rejected as a
sufficient cause; the common remaining operation is native pursuit.

The abrupt final report remains normal. This is consistent with an occasional
pathological `A_Chase`/`TryMove` query rather than a monitored counter growing
toward exhaustion. The ten-call global ceiling bounds calls, not the number of
blockmap cells, collision candidates or engine branches traversed by each call.

V4.29.0s assigns one deterministic movement leader per 16 main-field actors.
Only leaders can enter the existing Chase phase and global budget. Followers
keep their target and periodically face it without movement, range checks or
attack-state selection. Group size 1 restores V4.29.0r behavior. This is a
diagnostic precursor to real formation ownership, not the final formation AI.
Normal-map collision, pressure and combat formulas are unchanged.

## V4.29.0r — Passive blockmap residency is the next isolated variable

The moving-target V4.29.0q run stops after 193 complete reports at the same
10-call/350-per-second Chase ceiling that previously survived 548 reports.
The final interval has zero contacts, callbacks, retained references and live
projectiles. This confirms that a fixed number of admitted `A_Chase` calls does
not bound the actual native spatial work performed by those calls.

The main field contains 13,125 passive fillers in addition to 1,875 active
actors. `THRUACTORS` prevents the active actors from treating those fillers as
gameplay obstacles, but the fillers were still registered in the engine's
blockmap. A native movement query may therefore enumerate cell residents before
discarding them. This is the leading new inference from the complete A/B/C
history; V4.29.0r tests it rather than declaring it proven.

Only the main-field passive fillers now use `NOBLOCKMAP`. They remain visible,
retain their actor states and count toward the 16,500 lightweight population.
The active 1,875 actors and the 1,500 Quintaessence rats remain blockmap-linked.
Expected telemetry is `blockmap=3375 visuales=13125`. Collision and pressure
formulas, normal gameplay actors and the three Quintaessence A/B rooms are
unchanged.

If this configuration survives repeated ten-minute convergence, production AI
will formalize distance/squad representation so dormant crowds do not occupy
the high-frequency collision structure. If it still stops, the next isolation
must reduce the number of independent native movement agents through leaders
and formation followers rather than lowering a global numeric gate again.

## V4.29.0q — Per-tic native pursuit load is the leading cause

The 10-call comparison remains responsive for 368 reports without mass attacks
and 548 with full combat. Both runs reach all 1,983 field targets and keep
contacts, callbacks and retained references at zero. The enabled run completes
40 projectile lifecycles with at most one live missile and no failure.

The full-combat run reaches 502 actors within 512 MU. The failed 20-call run
had reached only 175 at that distance, so local density alone cannot explain
the stop. Likewise, attacks and projectiles are neither necessary nor
sufficient: a prior attack-disabled run stopped, while this enabled run remains
stable and destroys every missile it creates. Two consecutive MAP02 loads in
one process also weaken the retained-object or cleanup-leak hypothesis.

The strongest remaining explanation is worst-case native movement cost within
one simulation tic. `A_Chase` ultimately performs collision/blockmap movement
queries whose cost varies by actor and position. A fixed call count does not
measure that cost; admitting 20 or 40 expensive updates together can produce a
single pathological tic with no preceding counter ramp. Ten calls per tic is
the validated diagnostic mitigation, not proof of a specific engine defect.

The final confirmation is moving-target reconvergence at 10. The production
direction remains a shared squad/distance-tier coordinator so dormant, distant
and formation-linked actors do not all request independent native movement.
Collision and pressure formulas remain unchanged.

## V4.29.0p — Twenty Chase calls are not a robust boundary

The repeated-convergence run stops after 119 complete reports despite the
20-call ceiling previously surviving 319 and 506 reports. At the final complete
interval all 1,983 AI actors have targets, native Chase is saturated at 20
calls per tic and about 699 per simulated second, but contacts, callbacks and
retained references remain zero. Only one bounded projectile is alive.

The same 119-report duration occurred earlier with a 40-call ceiling and
main-field attacks disabled. This makes attacks, guided missiles, custom
contacts and retained projectiles unnecessary causes. It also shows that one
long successful run cannot certify a native pursuit budget: actor positions
can eventually produce a pathological simulation tic without a preceding
telemetry ramp.

V4.29.0p lowers the diagnostic Chase ceiling to 10 calls per tic, at most 350
per simulated second, and retains the independent seven-phase Look and
thirteen-phase Chase schedules. This is the next controlled gate before adding
distance tiers or a shared squad controller. Collision and pressure formulas
remain unchanged.

## V4.29.0o — The 20-call pursuit boundary is stable

The corrected V4.29.0n A/B pair validates the lower scheduler ceiling. With
main-field attacks disabled, MAP02 remained responsive for 319 telemetry
intervals. With full combat enabled it remained responsive for 506. Both runs
reached all 1,983 target-bearing AI actors, admitted at most 20 native Look and
20 native Chase calls per tic and sustained at most 700 Chase calls per
simulated second. Contacts, callbacks and retained references stayed at zero;
the enabled run held at most two live bounded projectiles.

This confirms that the earlier abrupt stop was a concurrency/density boundary
of native pursuit rather than a rat-specific script, custom-contact leak or
projectile accumulation. It does not establish that any number below 40 is
universally safe on every map, so 20 remains a conservative stress limit. The
next useful test is repeated map loading and moving-target convergence at 20,
not increasing the ceiling. Collision and pressure formulas are unchanged.

## V4.29.0n — Native pursuit is the remaining active boundary

The four V4.29.0m files form a valid comparison only after shifting each set
of console commands to the following map load. The Look-only configuration ran
for 495 telemetry intervals without stopping. The final configuration stopped
after 119 intervals with Look and Chase enabled, but main-field attacks still
disabled. Contacts, custom collision callbacks and retained contact references
were zero; the lightweight object counts remained exact.

This excludes the Caelum contact graph, mass projectiles and attack delivery as
necessary causes of that stop. The remaining mechanism is native `A_Chase`
moving many pass-through actors toward the same target. Even when actors ignore
one another for gameplay collision, convergence can concentrate native spatial
queries and blockmap updates until one simulation tic becomes pathological.
That is consistent with an abrupt stop after a long stable interval.

V4.29.0n lowers the diagnostic coordinator ceiling from 40 to 20 native Chase
calls per tic and removes per-attempt setting synchronization. This does not
claim a final formation controller: it tests whether bounding convergence work
is sufficient before adding distance tiers, shared squad movement or a density
cap. Collision and pressure formulas are unchanged.

## V4.29.0m — The supplied A/B runs were all enabled

The three V4.29.0l files do not implicate contact physics: every final report
contains zero retained contacts and zero collision callbacks, while live
projectiles remain between zero and two. The global Chase limiter also holds
at its requested 40 updates per tic. Freeze timing varies substantially and no
telemetry counter grows before the abrupt stop.

The intended disabled controls were not active. The first two console logs set
their CVars after the MAP02 actors had already copied the initial values, and
their reports explicitly say `chase activo=1` and `ataques_masivos=1`. This
patch makes the single scheduler own live settings and adds a 20-call per-tic
Look ceiling. A disabled report can no longer silently exercise enabled AI.

V4.29.0m also removes the diagnostic population's unnecessary object graph and
per-tic custom combat recomputation. This optimization is confined to MAP02
stress/passive actors; it does not weaken collision, anatomy, armor or status
rules for gameplay actors or the isolated Quintessence rooms. The next logs
will distinguish a collector/object-graph pause from native perception/chase.

## V4.29.0l — Per-tic ceiling for native pursuit

V4.29.0i reaches 1,605 simultaneous targets and approximately 1,924 admitted
`A_Chase` calls per second immediately before its abrupt stop. Contact edges,
custom callbacks and accepted attacks are all zero in that final interval; four
bounded projectiles remain alive. The freeze is therefore reproducible without
the custom pair solver, projectile accumulation or active attack delivery.

Look and Chase no longer share one interval. Look remains seven-phase, while
Chase uses thirteen coprime phases so the 4/5/8/10-tic actor loops eventually
visit every phase. A single deterministic EventHandler resets one counter per
world tic and admits at most 40 native Chase calls. Actors cache its reference
at spawn, so enforcing the ceiling adds neither a Thinker traversal nor a CVar
lookup to the state action.

The diagnostic can disable Chase while retaining acquired targets. Its monitor
separates phase, global-budget and disabled deferrals and records peak admitted
updates per tic. This is the first reusable foundation for later formation and
stealth scheduling; it is not yet the final group-command model.


## V4.29.0i — Perception joins the cached mass-AI schedule

The accepted V4.29.0h run no longer froze under the seven-phase Chase and
64-phase attack diagnostic. V4.29.0i keeps those boundaries and adds dormant
`A_Look` to the same seven-phase budget. Each mass-field actor captures attack
enablement, phase intervals and deterministic phase keys once when the map
loads. This removes repeated CVar lookups and coordinate hashes from Look,
Chase and attack state actions.

The monitor reports Look and Chase independently. No physics formula, contact
edge, pressure history or Quintessence-room collision rule changes. The main
field remains intentionally pass-through so this run measures AI scheduling,
not a 15,000-body native collision pile. The design can later serve stealth
and formation coordinators, but shared group perception and group command
objects are not yet implemented.


## V4.29.0f — Combat-boundary telemetry after contact cleanup

The supplied V4.29.0e runs confirm that raw callbacks scale with the number of
solid actors physically piled together. A post-Quintessence stack can retain
approximately 30,000 callbacks per simulated second even after Channel ends,
while simulated seconds themselves slow down. This is consistent with native
collision work on a dense solid pile; it is not evidence that the bounded
Caelum contact-edge graph regrew.

The abrupt freeze associated with active NPCs therefore needs a separate
boundary between chase/collision and attack/projectile execution. V4.29.0f
adds that boundary without changing physics formulas:

- a sight-blocking wall keeps the 1,875-active main field dormant at MAP02
  spawn;
- `ca_diag_mass_attacks false` records and suppresses attacks only in that
  field while leaving perception, chase and collisions active;
- `true` restores the same actors' melee, Bull charge and bounded straight
  projectile actions;
- projectile spawn, impact, range expiry, destruction and failure counters
  make a synchronous combat avalanche visible without scanning every missile
  a second time.

If chase with attacks suppressed freezes, native crowd movement/collision is
still sufficient. If only the enabled run freezes, the final family, attack
and projectile rates identify combat synchronization as the next hot path.
This diagnostic does not restore guided projectiles to mass NPCs and does not
add a connected-component/island solver.

## V4.29.0e — Valid diagnostic placement

V4.29.0c's intended 18,000-MU isolation was correct, but its Room-7 X
coordinate exceeded GZDoom's UDMF range and Room 8's western geometry crossed
the same limit by 32 MU. V4.29.0e preserves the separation along Y at the
in-range centers `(-24000,-18000)`, `(-24000,0)` and `(-24000,18000)`.

This changes no physics formula, actor class, contact rule or Seal radius. It
only makes the three 500-actor native/full/pass-through tests loadable and
mutually isolated. The build now rejects out-of-range vertex and Thing
coordinates before packaging.

## V4.29.0c — Runtime evidence and staged AI boundary

The sequential V4.29.0b log validates the distinction introduced by the new
telemetry. Straight projectiles in Room 5 sustained up to 18 live missiles with
no physical-contact workload. Explosive Room 6 instead increased target-bearing
actors from four to 199 while reporting zero contact callbacks. Its observed
cost is therefore radial damage, target propagation and infighting, not the
pair solver.

The Quintessence sessions were spatially contaminated: the nominal 500-Rat
rooms reported 1,103 and 1,755 affected actors. In the complete-contact run,
raw callbacks peaked at 33,232 with 21,493 unique pair-tic attempts, 7,763
duplicates, 9,167 resting rejections, 815 retained edges and at most 12 edges
on one actor. The main field peaked at 37,144 callbacks for 2,065 affected
actors.

After release in the main field, the final report was approximately:

`callbacks=4718, unicos=503, duplicados=28, reposo=4599, contactos=18, max=4`

The exact counters overlap by design: a pair can be admitted once for a tic
and then classified as resting, while an unlatched resting callback has no
persistent pair yet. They should not be summed as mutually exclusive buckets.
Nevertheless, the small edge/duplicate counts beside 4,599 resting rejections
show that the remaining post-release load is repeated native collision among
stacked solids, not growth of the historical contact graph.

V4.29.0c therefore does not add a connected-component/island traversal. It
first replays the exact historical 1,875-active-actor population with straight
projectiles and isolates the three Quintessence matrices by 18,000 MU. Only a
failure that remains after this controlled replay justifies another physics
algorithm change.

## V4.29.0b — Once-per-pair resolution and allocation-free repeated contact

The engine may report the same solid pair several times during one tic and may
continue reporting physically stacked bodies after an external force ends.
V4.29.0b preserves those callbacks as the authoritative edge-liveness signal,
but a shared `ImpactContactState` admits only one custom resolution per tic:

`custom pair resolutions per tic <= live contact pairs`

Later callbacks for that pair increment diagnostic duplicate counts and return
without applying a second impulse. For a pair entering or maintaining contact,
the cheap squared-distance and closing projection are evaluated first:

`closing projection = (v_A - v_B) dot (p_B - p_A)`

If the centers coincide, the projection is non-positive, or the normalized
closing speed is below the universal minimum, the callback is classified as
resting and returns. The square root, contact normal, effective bodies and
solver run only for a genuinely closing pair.

`CaelumPlayer` and `CaelumCombatActor` each lazily allocate one source
`ImpactBody`, one target `ImpactBody` and one `ImpactResult`, then overwrite and
reuse them. Pair edges themselves remain persistent shared objects because
they carry the bounded 35-tic pressure history. Thus ordinary repeated contact
does not allocate bodies/results per callback, while edge creation and expiry
remain visible through reference-churn telemetry.

This optimization does not suppress or replace GZDoom's native collision
checks. A pile of thousands of solid actors can still generate high raw
callback volume and severe engine-side cost. The MAP02 `unicos`, `duplicados`
and `reposo` counters separate that native volume from work actually executed
by the Caelum solver.

The NPC mass path is now physically simpler as well: Rulo, Caella, Ronnie and
Argento fire a bounded straight single-impact projectile. It has no seeker
update and no radial explosion; the explosive class remains available only by
explicit request. This is a combat/AI cost policy rather than a change to the
two-body formulas below.

## V4.29.0a — Bounded contact graph and accumulated pressure

The multi-contact implementation remains a shared graph of pair edges, not a
simultaneous rigid-body island solver. V4.29.0a bounds that graph and makes its
pressure output depend on measured impulse.

Each valid `CollidedWith` callback refreshes `LastCollisionTick`. A contact
edge is released when either existing geometric separation remains valid for
five tics or five complete tics pass without a new collision callback. This
prevents an actor's linear contact lookup from retaining every historical
neighbor merely because a crowd remains within the generous rearm radius.

For a sustained edge, the inelastic pair impulse remains:

`J_tic = v_close / (1/m_A + 1/m_B)`

At most one sample is counted per edge per tic; if the engine reports the edge
more than once in that tic, only the largest sample contributes. Over the
existing one-second interval:

`J_pressure = sum(J_tic, 35 tics)`

The pressure pulse reconstructs the closing speed that would produce that
measured aggregate impulse for the same two effective masses:

`v_equivalent = J_pressure × (1/m_A + 1/m_B)`

That value enters the existing universal impact/anatomy/armor pipeline as
`IMPACT_KIND_CRUSH`. The former synthetic walking-speed collision is removed.
Consequently a gentle or intermittent contact remains low, while persistent
force transmitted through successive neighboring edges can damage bodies in
the compressed direction.

Giant Rats no longer use `THRUSPECIES`. This is required for Rat-to-Rat
pressure: species pass-through prevented a Quintessence cluster or player-led
Rat pile from creating collision edges at all.

Repeated edge impulses can propagate movement and pressure across a cluster,
but the solver still does not collect a connected component, compute one total
island mass or resolve all constraints simultaneously. That expansion remains
conditional on the controlled MAP02 results because it would add traversal
cost to the exact crowd case under investigation.

## V4.26.5d — Environmental Pain does not grant Adrenaline

Wall and floor impacts already bypass the direct received-damage Adrenaline event. V4.26.5d closes the remaining shared-path leak: if environmental impact damage triggers the Pain state, that Pain may still immobilize/stun the body but does not grant Pain Adrenaline. Actor-to-actor impacts and ordinary combat damage retain their authored Pain Adrenaline behavior. No kinematic, energy, Toughness, armor, anatomy or damping formula changes in this correction.

## Status

**V4.25.1 — implemented, pending manual validation**

This system gives physical contact a gameplay meaning independent of weapon attacks. Actor-to-actor collisions use a simplified momentum/impulse model; impacts against the floor and blocking map geometry use the forced change in velocity measured by the engine.

The design intentionally separates **real-world physics concepts** from **gameplay conventions**.

## 1. Physical concepts used

### Linear momentum

For a body of mass `m` and velocity `v`:

`p = m v`

Momentum is directional. In actor-to-actor collisions Caelum resolves only the component along the collision normal; tangential motion is preserved as much as possible.

### Impulse

An impulse changes momentum:

`J = Δp = m Δv`

This is the central quantity behind action/reaction. A collision does not only push the receiver: both participants receive an opposite velocity change.

### Relative velocity and collision normal

For actor A colliding with actor B, the normalized contact direction is:

`n = (x_B - x_A) / |x_B - x_A|`

The closing speed along that direction is:

`v_close = (v_A - v_B) · n`

Only `v_close > 0` is treated as an approaching collision.

### Two-body impulse

The normal impulse magnitude is:

`J = (1 + e) v_close / (1/m_A + 1/m_B)`

where `e` is the coefficient of restitution.

V4.25.1 uses:

`e = 0`

This is a **perfectly inelastic normal collision**. The bodies do not behave like rubber balls; their normal velocities tend toward a common value after impact. Tangential velocity is not deliberately cancelled.

The resulting normal velocity changes are:

`Δv_A = J / m_A`

`Δv_B = J / m_B`

and are applied in opposite directions, satisfying the action/reaction interpretation.

## 2. Effective combat mass

Caelum distinguishes physical carried load from **effective combat mass**.

Normal:

`m_eff = m`

Buckler while blocking:

`m_eff = 0.5 m`

Tower shield while blocking:

`m_eff = 2 m`

These factors do **not** modify carry capacity or current carried weight. They represent how well the character braces against forced movement.

This makes ramming strategically asymmetric:

- A buckler user loses more velocity in a collision and is a poor rammer.
- A tower-shield user loses less velocity and transfers more velocity to the other body.
- The tower shield therefore reduces collision self-trauma naturally through a smaller `Δv`; it does not need a separate collision-damage reduction rule.

## 3. Impact severity from forced velocity change

Collision damage is not based on distance actually traveled after the impact.

For each actor Caelum measures the magnitude of the **forced velocity change**:

`|Δv| = |v_after - v_before|`

This allows the same severity model to describe:

- actor versus actor;
- actor versus wall;
- landing after a fall;
- future movable-object impacts;
- future explosions or abilities that launch bodies.

## 4. Height-normalized equivalent time

Each body uses half its own actor height as a reference distance:

`d_ref = H / 2`

GZDoom actor velocity is used in map units per game tic for this calculation. Therefore the number of equivalent tics required to cover half the actor's height at the measured `|Δv|` is:

`T_eq = (H / 2) / |Δv|`

This does **not** mean the actor must actually travel that distance. It is a normalization question:

> At the velocity change suffered by this body, how many tics would it take to traverse half its own height?

A short equivalent time means an abrupt, violent change in motion.

## 5. Universal damage threshold

The universal threshold is:

`T_eq > 35 tics -> no impact damage`

At or below the threshold, each damage step represents 3% of maximum health.

V4.25.1 uses discrete conservative steps:

`T_step = ceil(max(1, T_eq))`

`N_steps = clamp(36 - T_step, 0, 35)`

`DamagePercent = 3% × N_steps`

This gives the intended reference values:

| Equivalent time | Base impact damage |
| ---: | ---: |
| > 35 tics | 0% max HP |
| 35 tics | 3% max HP |
| 30 tics | 18% max HP |
| 20 tics | 48% max HP |
| 10 tics | 78% max HP |
| 5 tics | 93% max HP |
| 2 tics | 102% max HP |
| 1 tic or less | 105% max HP |

The maximum is intentionally capped at 105% of maximum health.

## 6. Base impact damage

The current base formula is:

`D_base = HP_max × DamagePercent × SurfaceMultiplier`

`SurfaceMultiplier` defaults to `1.0`.

The field exists now so later equipment and anatomy can modify contact trauma. Examples planned for future content include spikes, horns, reinforced surfaces, padding, or other collision-specific equipment.

A spiked surface can therefore increase injury without changing momentum:

`D_spiked = D_base × SpikeMultiplier`

Momentum determines **how violently velocities changed**. Surface properties determine **how dangerous the contact surface is**.

## 7. Impact mitigation (V4.25.2)

`CaelumImpact` remains global kinetic trauma, but raw collision severity is no longer final health damage.

The raw impact result is:

`D_raw = HP_max × DamagePercent × SurfaceMultiplier`

Then Toughness applies the same body-resistance curve already used by Caelum combat:

`M_toughness = clamp(1 - T(T+1)/10100, 0, 1)`

Global impact armor defense is the arithmetic mean of the four currently functional armor slots:

`A_impact = (A_head + A_body + A_hands + A_feet) / 4`

Broken/base-clothing pieces contribute zero because the normal `GetDefense(slot)` rule already returns zero.

Final health damage is:

`D_final = D_raw × M_toughness × (1 - A_impact/100)`

Impact still cannot be evaded and is not intercepted by shield Block. It also does not choose one localized hit region because wall/ground/body trauma is treated as distributed kinetic load.

Armor durability is **not yet consumed by global impact absorption**. This is deliberate: a later balance decision is needed for how a distributed collision should divide durability loss among the four pieces.

## 8. Actor-to-actor collision flow

GZDoom calls `CollidedWith(Actor other, bool passive)` after two solid actors actually collide. Caelum processes the pair only from the active side so the action/reaction impulse is not applied twice.

Flow:

1. Confirm both bodies belong to the Caelum character/NPC physics system.
2. Calculate collision normal.
3. Calculate relative closing speed.
4. Resolve effective masses.
5. Calculate the shared impulse.
6. Change both velocities in opposite directions.
7. Measure `Δv_A` and `Δv_B`.
8. Independently calculate impact damage for A and B.

Equal masses moving toward each other at equal and opposite speeds tend to cancel their normal motion rather than bounce.

Different masses produce different velocity changes. The heavier/effectively braced actor suffers less `Δv`; the lighter actor suffers more.

## 9. Walls and map geometry

Raw GZDoom horizontal velocity is intentionally **not** interpreted directly as physical meters per tic. The first V4.25.1 test produced values such as 0.53 equivalent tics from an ordinary short run into a wall, demonstrating that the engine movement scale is unsuitable as a direct physical scale for self-propelled wall impacts.

V4.25.2 therefore normalizes wall severity against the character's already calculated effective movement percentage.

The fraction of horizontal velocity actually lost is:

`F_lost = clamp(Δv_wall / |v_xy,before|, 0, 1)`

Movement severity is:

`S_wall = (EffectiveMovementPercent / 100) × F_lost`

and:

`T_eq,wall = 35 / S_wall`

Therefore a complete frontal stop at exactly 100% effective movement lands at the 35-tic threshold. Load, Agility and health/Air/survival movement modifiers already change `EffectiveMovementPercent`, so a heavily encumbered slow character generates a less severe self-powered wall collision while superhuman movement can move far below the threshold.

Wall damage is only registered on the transition from unblocked to blocked movement. Holding forward against a wall does not reapply collision damage every tic.

## 10. Falling and floor impacts

Caelum does not need a separate arbitrary fall-height damage table.

V4.25.2 stores the latest downward `v_z` while the actor is airborne and detects the transition from airborne on the previous tic to grounded on the current tic. This avoids relying on an intra-`Tick()` ground-state transition that V4.25.1 failed to observe reliably.

At landing:

`Δv_floor ≈ |v_z,last_falling|`

and:

`T_eq = (H_ref/2) / Δv_floor`

Player `H_ref` is the stable body height from `DerivedStats.ActorHeight`, not the transient actor cylinder height. NPC Caelum actors use their class-defined base `Height`.

This means fall damage depends on **landing speed**, not directly on fall distance.

That matches the real physical interpretation better than a pure height table: once a body reaches a terminal velocity, additional fall distance does not increase impact speed, so the model naturally reaches a maximum falling severity determined by the engine's terminal velocity.

Short falls have a smaller `Δv`; long falls approach the terminal-speed limit.

## 11. Engine relationship

The implementation uses GZDoom's collision and movement state rather than replacing the engine physics:

- `CollidedWith()` identifies confirmed actor collisions.
- actor velocity (`Vel`) supplies the velocity state;
- `MovementBlockingLine` / `BlockingLine` identify blocked horizontal world movement;
- ground state and vertical velocity identify landings.

The impulse layer changes velocity after confirmed actor contact, while the impact layer interprets the resulting forced `Δv`.

## 12. Debug telemetry

The player debug overlay exposes the last impact:

- impact kind: none / actor / wall / floor;
- `Δv`;
- equivalent tics;
- predicted/base damage percentage;
- calculated base damage.

Internally the system also stores:

- effective self mass;
- effective other mass;
- closing speed;
- impulse magnitude.

These values are intended for MAP01 calibration before the system is considered fully validated.

## 13. Current ranged correction

V4.25.1 also corrects the Carbine base Reload time from 10 seconds to **5 seconds**.

Current ranged base Reload times:

- Standard Bow: 3 s
- Longbow: 3 s
- Crossbow: 5 s
- Carbine: 5 s

All are divided by the Dexterity Type-4 attack-speed modifier.

## 14. Planned extensions

The same infrastructure is intended to support:

- movable rocks and logs;
- heavy creatures and charging attacks;
- spiked armor/shields;
- horned or armored monsters;
- objects launched into characters;
- wall slams caused by knockback;
- collision-specific damage types;
- configurable coefficients of restitution for genuinely bouncy objects;
- surface materials that alter damage without altering momentum.


## 15. Current Caelum test-actor physical/defensive profiles

| Actor | HP | Mass | Height | Toughness | Resilience | Agility | Patience | Dexterity | Insight | Strength | Intelligence | Armor | Impact armor | Toughness multiplier |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | ---: | ---: |
| Rulo | 6200 | 200 | 74.7 | 20 | 18 | 18 | 3 | 18 | 3 | 20 | 3 | Heavy T1 | 30% | 0.9584 |
| Caella | 1160 | 80 | 49.8 | 9 | 7 | 7 | 18 | 7 | 18 | 9 | 18 | Magic T1 | 5% | 0.9911 |
| Ronnie | 4340 | 140 | 62.2 | 20 | 18 | 18 | 7 | 18 | 7 | 20 | 7 | Medium T1 | 20% | 0.9584 |
| Argento | 1740 | 120 | 62.2 | 9 | 7 | 7 | 18 | 7 | 18 | 9 | 18 | Light T1 | 10% | 0.9911 |

These four actors are **not full player character sheets**. `CaelumCombatActor` stores the eight combat-relevant attributes listed above. Their health, native mass, height and speed are explicitly authored in their actor classes rather than reconstructed from a complete race/class/Constitution profile.

Ordinary Doom actors such as `Demon` do not yet enter this Caelum collision pipeline because they lack `CaelumPlayer`, `CaelumCombatActor`, or the explicit training-dummy adapter. They continue to use native GZDoom collision behavior.

## 16. Training dummy

The training dummy is now movable and uses native `Mass 10000`. It no longer clears horizontal velocity every tic and no longer carries `CANNOTPUSH`. It is accepted as a valid Caelum collision body for momentum calculations.

The dummy intentionally remains a diagnostic native actor rather than a full `CaelumCombatActor`; its role is to behave as an extremely massive movable object so action/reaction against near-immovable mass can be observed cleanly.

## 17. V4.25.3 — Acceleration and biological damping

### Horizontal acceleration

The character's maximum movement speed is still produced by the existing Caelum stat/load/status pipeline. V4.25.3 adds a dimensionless acceleration state `A` between 0 and 1.

For each grounded tic with directional input:

`A_(n+1) = A_n + (1 - A_n) alpha`

with:

`alpha = 0.028127624`

Therefore:

`A_n = 1 - (1 - alpha)^n`

and after 105 tics (3 seconds):

`A_105 = 0.95`

The movement multiplier applied to GZDoom is:

`Movement_final = Movement_existing × A`

This is an exponential approach to the existing maximum, not a replacement for Agility or load rules.

When movement input is released or the actor becomes physically immobilized, the active acceleration state is reset. While airborne, the reached acceleration state is preserved but does not continue to build.

### Run-up and wall impacts

The V4.25.2 wall severity formula now includes `A`:

`S_wall = (EffectiveMovementPercent × A / 100) × F_lost`

`T_eq,wall = 35 / S_wall`

Consequently, taking a half-step into a wall and running into it after a long acceleration period are physically different events even if both ultimately become blocked by the same map line.

### Contact latching

A sustained push is not a sequence of fresh impacts.

When actor A and actor B resolve a valid closing collision, both store the other actor as their current impact contact. Further `CollidedWith()` callbacks for that same pair are ignored.

The contact rearms only once center distance exceeds:

`R_A + R_B + technical_margin`

The margin is 2 map units and exists only to avoid contact-state flicker caused by collision precision.

This preserves continuous pushing while eliminating repeated collision trauma from simply holding movement against another body.

### Biological landing damping

Living tissue is not modeled as a perfectly rigid body. Controlled landings extend the effective stopping process through muscles, tendons and joints.

V4.25.3 therefore separates:

`raw floor Delta-v`

from:

`effective traumatic Delta-v`

For the player:

`Delta-v_bio = current normal JumpZ`

unless the player is physically immobilized/stunned, in which case:

`Delta-v_bio = 0`

The traumatic vertical change becomes:

`Delta-v_effective = max(0, Delta-v_raw - Delta-v_bio)`

Only `Delta-v_effective` enters the equivalent-tic damage equation.

Using current `JumpZ` makes a normal self-generated jump the natural reference for a controlled safe landing while automatically respecting the already-defined jump scaling.

### Stunned falls

A stunned body cannot deliberately flex the legs or coordinate posture. Therefore biological landing absorption is removed while physical stun/immobilization is active.

The same fall can consequently produce very different trauma:

- conscious/controlled landing -> biological absorption -> remaining Delta-v -> Toughness -> armor;
- stunned/uncontrolled landing -> no biological absorption -> full Delta-v -> Toughness -> armor.

### Caelum NPC biological scale

`CaelumCombatActor` does not use PlayerPawn `JumpZ`, so its living-body landing absorption uses geometric scaling:

`Delta-v_bio,NPC = 8 × sqrt(H / 56)`

where 8 is the standard Caelum/GZDoom jump-velocity reference and 56 is the standard actor-height reference already used by the player size conversion.

This square-root length scaling follows the characteristic velocity scale `v ~ sqrt(g L)` for geometrically similar bodies under the same gravity.

Lucidity-stunned NPCs receive zero biological landing absorption.

### Damage pipeline after V4.25.3

For a floor impact:

`raw Delta-v`
-> `biological absorption`
-> `effective Delta-v`
-> `equivalent tics`
-> `raw % max HP`
-> `Toughness`
-> `global armor`
-> `final health damage`

For actor-to-actor collisions the existing impulse/action-reaction calculation is unchanged.


## 18. V4.25.4 — Specific kinetic energy damage curve

### Why the previous linear staircase was replaced

The former rule mapped each equivalent-tic step directly to another 3% maximum-health damage. This made moderate actor collisions too destructive and introduced abrupt discontinuities between adjacent speeds.

Kinetic energy does not scale linearly with speed:

`E_k = 1/2 m v²`

For injury severity Caelum uses **specific kinetic energy**:

`E_k / m = 1/2 v²`

Mass is deliberately omitted from this second stage because it has already participated in the two-body impulse equation and therefore already determines each actor's resulting `Delta-v`. Reintroducing `m` in injury would count the mass advantage twice.

### Relationship with equivalent tics

The existing size-normalized relation is:

`T_eq = (H/2) / |Delta-v|`

Therefore:

`|Delta-v| ∝ 1 / T_eq`

and specific kinetic energy scales as:

`E_specific ∝ 1 / T_eq²`

### Continuous normalized damage function

The reference points are:

`T_eq = 35 -> 0% raw max-HP damage`

`T_eq = 1 -> 100% raw max-HP damage`

For `T_eq < 35`:

`R_v = 35 / T_eq`

`R_E = R_v²`

`DamagePercent = 100 × (R_E - 1) / (35² - 1)`

For `T_eq >= 35`:

`DamagePercent = 0`

There is no upper clamp at one tic. The same energy law continues below one tic.

Reference values:

| Equivalent tics | Raw max-HP damage |
| ---: | ---: |
| 35 | 0% |
| 30 | 0.03% |
| 25 | 0.08% |
| 20 | 0.17% |
| 15 | 0.36% |
| 10 | 0.92% |
| 5 | 3.92% |
| 3 | 11.04% |
| 2 | 24.94% |
| 1 | 100% |
| 0.8 | 156.30% |
| 0.5 | 400.25% |
| 0.25 | 1601.23% |

These are **raw** values. Biological landing damping, Toughness, global armor defense and surface multipliers remain later stages of the pipeline.

### Robust contact rearm

A temporary gap caused by the inelastic impulse is no longer enough to define a new charge.

After a valid actor collision, the pair remains latched until:

`distance > Radius_A + Radius_B + 0.25 × min(H_A, H_B) + 2`

and this condition remains true for:

`5 consecutive tics`

Only then is the pair eligible to generate a fresh impact.

This creates a physical distinction between:

- continuing to push after one collision;
- tiny recoil/engine oscillation while still engaged;
- actually disengaging, taking space, and charging again.

The 25% body-height term is gameplay geometry tied to character scale. The two-unit margin and five-tic persistence are technical anti-flicker parameters rather than physical constants.

## 19. V4.26.0 — Impact Physics Core API

### Architectural separation

The physics solver is now independent of Caelum gameplay systems.

`impactphysics/ImpactPhysics.zs` contains only generic mechanics:

- inertial mass;
- body height;
- velocity;
- collision normal;
- coefficient of restitution;
- impulse;
- forced velocity change;
- equivalent impact tics;
- specific kinetic-energy severity.

It contains no references to CaelumPlayer, CaelumCombatActor, attributes, armor, biology, HP, Tarot or equipment.

### ImpactBody

A generic body describes the physical input:

- `Mass`
- `Height`
- `Velocity`
- `Restitution`
- `SurfaceMultiplier`

The core does not decide what SurfaceMultiplier means to a game's damage system; it is metadata available to integrations.

### ImpactResult

A resolved impact returns:

- validity;
- static/finite target flag;
- collision normal;
- closing speed;
- impulse magnitude;
- source Delta-v;
- target Delta-v;
- equivalent tics for each body;
- energy severity percentage for each body.

The result is descriptive. The core does not remove HP or apply armor.

### ResolveBodies

Two finite masses use the normal impulse equation:

`J = (1+e) v_close / (1/m_A + 1/m_B)`

`Delta-v_A = J/m_A`

`Delta-v_B = J/m_B`

The resulting Delta-v values are converted to equivalent tics and the V4.25.4 energy curve.

### ResolveStatic

Static geometry is defined as the limit:

`m_target -> infinity`

The target does not change velocity. The source loses the velocity component normal to the surface.

`Delta-v_source = |v_source dot n|`

`J_static = m_source × Delta-v_source`

The same equivalent-tic and energy functions then apply. There is no special wall damage curve.

### Engine-derived effective wall normal

GZDoom map-line geometry is not reimplemented by the core. The Caelum adapter compares horizontal velocity before and after the native movement step:

`v_lost = v_before - v_after`

The normalized lost-velocity direction becomes the effective collision normal passed to `ResolveStatic`.

This naturally ignores preserved tangential/sliding velocity and evaluates only the motion the engine actually removed.

### Convergence property

A required validation property is:

`lim(m_B -> infinity) ResolveBodies(A,B) = ResolveStatic(A)`

The mass-10000 training dummy is therefore not only a gameplay object but a convergence test. Its effect on the player should be close to, but not exactly equal to, static geometry.

### ResolveExternal

`ResolveExternal` accepts a target body plus an externally supplied source mass, source velocity, normal and restitution.

This is the intended bridge for systems that may not be ordinary Actor-to-Actor collisions:

- avalanches;
- moving sectors;
- scripted machinery;
- collapsing structures;
- rams;
- catapult payload systems;
- other project-specific hazards.

The external system supplies physical state rather than arbitrary attack damage.

### Standalone export target

After validation, `/impactphysics/ImpactPhysics.zs` can become the basis of a standalone `ImpactPhysics.pk3`.

A consuming project should be able to:

1. include the core;
2. construct `ImpactBody` values from its own actors/objects;
3. call a solver;
4. interpret `ImpactResult` using its own health, armor, structural-integrity or breakage rules.

Caelum is therefore an adapter/client of the API rather than the owner of the underlying mathematics.

### Melee boundary

Melee is deliberately outside V4.26.0.

A physical melee model would need more than player and weapon mass. At minimum it requires:

- swing/strike velocity rather than locomotion velocity;
- effective weapon mass at the contact point;
- lever arm and rotational contribution;
- contact area;
- edge sharpness or point geometry;
- target material/armor response;
- penetration/cutting versus blunt energy transfer;
- attack technique.

Therefore current melee damage remains the authoritative combat model. A future melee-physics layer can consume Impact Physics Core outputs once these additional variables are explicitly designed.

## 20. V4.26.1 — Toughness tolerance and static-contact filtering

### Toughness as kinetic-trauma tolerance

For collision damage, Toughness is no longer interpreted as a multiplicative percentage reduction.

After energy severity and the impacting surface modifier:

`S_surface = S_energy × SurfaceMultiplier`

Toughness removes percentage points directly:

`S_postToughness = max(0, S_surface - Toughness)`

The remaining severity is converted to health:

`D_preArmor = HP_max × S_postToughness / 100`

and armor remains proportional:

`D_final = D_preArmor × (1 - A_impact/100)`

Examples:

- raw 10%, Toughness 5 -> 5% remains;
- raw 10%, Toughness 50 -> 0%;
- raw 100%, Toughness 100 -> 0%;
- raw 200%, Toughness 100 -> 100% remains before armor.

This models Toughness as a structural/biological trauma threshold rather than conventional damage resistance.

### Static grazing filter

Static geometry is still solved through the infinite-mass Impact Physics Core path, but the Caelum adapter distinguishes impact from ordinary sliding.

`F_lost = |Delta-v_horizontal| / |v_horizontal,before|`

If:

`F_lost < 0.25`

the event is treated as grazing contact and does not enter the damage solver.

The 25% threshold is a gameplay contact classifier, not a physical constant. It prevents narrow corridors and shallow wall contact from becoming a source of constant trauma.

### Static contact rearm

After a wall/static collision state begins, another static impact is not eligible until the actor has been unblocked for five consecutive tics.

This protects against one-tic gaps in GZDoom's blocking-line state while sliding along irregular geometry.

### Adrenaline

Environmental kinetic trauma is separated from combat damage response:

- actor collision -> normal received-damage Adrenaline remains;
- wall/static geometry -> no received-damage Adrenaline;
- floor/fall impact -> no received-damage Adrenaline.

Pain and health-state consequences still occur when environmental impact actually removes HP.

## 21. V4.26.2 — Universal 28-MU scale and weighted contact anatomy

### Universal severity distance

Equivalent impact time no longer uses half of the individual body's height.

The fixed reference is:

`L_ref = 28 map units`

This originates from half the standard 56-MU Caelum humanoid height (the 1.8 m reference character), but it is an engine-space calibration constant, not a claim that Doom map units universally equal real-world meters.

For every body:

`T_impact = 28 / |Delta-v|`

The V4.25.4 specific-energy curve remains unchanged after this conversion.

This prevents body size from entering severity twice. Mass already affects impulse and therefore the Delta-v received by each body. Toughness and biological damping then describe resistance/controlled absorption separately.

### Generic contact geometry

Impact Physics Core remains independent of anatomy.

`ImpactBody` now includes world `Position` in addition to Height. `ImpactResult` exposes:

- `SourceContactMinimumHeightRatio`
- `SourceContactMaximumHeightRatio`
- `TargetContactMinimumHeightRatio`
- `TargetContactMaximumHeightRatio`

All are neutral normalized values from 0.0 (bottom) to 1.0 (top).

For two finite cylindrical bodies, the core intersects their vertical spans and reports the overlap relative to each body independently.

No result field is named head, torso, arm, leg, armor or vulnerability.

### Caelum anatomy adapter

Caelum takes the neutral contact interval and intersects it with every authored `CaelumAnatomyProfile` region.

For region `i`:

`overlap_i = length(ContactBand intersect Region_i)`

Because authored regions may overlap (for example arms and torso bands), the overlaps are normalized:

`w_i = overlap_i / sum(overlap_j)`

Therefore:

`sum(w_i) = 1`

These weights are then used for both vulnerability and armor.

After surface severity and subtractive Toughness:

`S_post = max(0, S_surface - Toughness)`

Each region contributes:

`S_i = S_post × w_i × M_vulnerability,i × (1 - Defense_i/100)`

Final collision severity is:

`S_final = sum(S_i)`

This means an 80/10/10 contact distribution makes the 80% region's vulnerability and armor eight times as influential as either 10% region.

### Lucidity

Collision Lucidity uses the same contact weights rather than selecting a single arbitrary region.

Only regions whose **natural** vulnerability is Critical contribute the existing critical-point Lucidity loss. For each such region:

`Lucidity_i = BaseCriticalLucidityLoss × w_i × (1 - localArmorDefense_i)`

The contributions are summed, then the player's existing Lucidity-loss and sleep modifiers apply.

Thus a 50% head / 50% torso collision produces approximately half the critical-point Lucidity contribution of an otherwise identical 100% head collision, before armor and player-specific Lucidity modifiers.

### Floor and static geometry

A controlled floor landing is supplied to the anatomy adapter as a point contact at normalized height `0.0`, mapping naturally to the lowest authored body region (humanoid legs/feet).

GZDoom vertical wall/door collision does not provide an exact Z contact point for the cylindrical actor. Therefore static vertical geometry currently reports the full 0.0-1.0 band. Caelum weights all anatomy regions intersecting that band rather than inventing a torso-only hit.

Future geometry systems that know a real contact Z may supply a narrower neutral band without changing the anatomy adapter.

### Biological landing damping

Player controlled landing absorption remains:

`Delta-v_bio = current JumpZ`

which already derives from the player's Agility jump scaling.

CaelumCombatActor now mirrors the same principle:

`Type1Agility% = 100 + Agility(Agility+1)/2`

`Delta-v_bio,NPC = 8 × sqrt(Type1Agility% / 100)`

Physical/Lucidity stun still sets controlled biological damping to zero.

### Final floor-impact order

`raw vertical Delta-v`
-> `Agility/JumpZ biological damping`
-> `effective Delta-v`
-> `28-MU equivalent time`
-> `specific-energy severity`
-> `surface modifier`
-> `subtract Toughness`
-> `weighted anatomy vulnerability`
-> `weighted localized armor`
-> `HP`

The same contact weights separately feed Lucidity response.


## 22. V4.26.3 — Buckler acrobatic impact response

The buckler preserves its 0.5 effective-combat-mass rule, making its user easier to displace. While actively blocking, Caelum then applies two defensive responses after the physical impulse has already been solved:

`ImpactToughness = 2 × Toughness`

`AgilityAbsorption = 2 × JumpZ`

The doubled Agility absorption applies to floor, actor and wall traumatic Delta-v. It does **not** change impulse, momentum, resulting velocity or displacement; it represents rolling, yielding and acrobatic body control after being launched.

If physical/Lucidity stun is active:

`AgilityAbsorption = 0`

Thus the rodela rewards an agile conscious defender but does not protect an incapacitated body from uncontrolled impact.


## 23. V4.26.3b — Horizontal acrobatic damping calibration

The first horizontal buckler implementation reused `2 × JumpZ` as a direct subtraction from collision Delta-v. Although both values are engine velocities, their practical gameplay scales differ: a normal high-Agility JumpZ can exceed the entire Delta-v of a full-speed horizontal collision. The result was artificial complete cancellation and the no-impact sentinel:

`TraumaticDeltaV = 0 -> EquivalentTics ≈ infinity`

Horizontal buckler damping now uses only the **relative Agility jump bonus above the base jump**:

`B_agility = max(0, JumpZ / BaseJumpZ - 1)`

The requested buckler doubling becomes:

`F_acrobatic = clamp(2 × B_agility, 0, 0.50)`

and horizontal trauma becomes:

`DeltaV_traumatic = DeltaV_raw × (1 - F_acrobatic)`

The 50% cap is deliberately a response-layer limit: it never modifies the impulse, momentum, physical post-collision velocity or displacement produced by Impact Physics Core.

Vertical landing remains different because JumpZ is already the validated reference for controlled landing velocity:

`DeltaV_traumatic,floor = max(0, DeltaV_raw - JumpZ)` normally

and with active buckler:

`DeltaV_traumatic,floor = max(0, DeltaV_raw - 2 JumpZ)`

Stun removes both active forms of Agility damping.

The rodela's doubled subtractive Toughness is unchanged and is applied later. Therefore a character can still receive zero **final** damage because `2 × Toughness` exceeds the remaining energy severity, but equivalent tics should remain finite whenever a real horizontal Delta-v occurred.


## 24. V4.26.4 — Crouched wall damping and careful movement

Crouching now has a physical defensive meaning in addition to accuracy and Stealth.

A conscious crouching character can yield, brace, roll the shoulder and move cautiously against static geometry. This does **not** change the physical collision impulse. It changes only the traumatic response to a wall Delta-v.

The same normalized Agility bonus used by the calibrated buckler response is reused:

`B_agility = max(0, JumpZ/BaseJumpZ - 1)`

For crouched wall contact:

`F_crouch = clamp(B_agility, 0, 0.50)`

For active buckler block:

`F_buckler = clamp(2 B_agility, 0, 0.50)`

If both apply:

`F_horizontal = max(F_crouch, F_buckler)`

They do not add together.

`DeltaV_traumatic = DeltaV_raw × (1 - F_horizontal)`

Actor-to-actor horizontal damping remains a buckler specialty; crouching alone only adds the careful-movement response to walls/static geometry.

Physical/Lucidity stun sets active Agility damping to zero.

### Movement noise and Sigilo

The documented Sigilo rule is now materialized:

`Stealth = Type2(Agility) = Agility(Agility+1)/101`

and clamped to 0–100%.

Crouching no longer multiplies the Stealth stat:

`EffectiveStealth = clamp(Stealth, 0, 100)`

Movement noise heard by AI uses:

`NoiseMultiplier = 1 - EffectiveStealth/100`

The base movement event is 50 dB:

`BaseNoiseRange = 50²/4 = 625 MU`

For listener Perspicacity `L`, add:

`HearingAllowance = (50+L) × [1 + 2L(L+1)/10100] MU`

Movement-mode factors:

- walking: 1.0
- running: 2.0
- crouching: 0.5

Thus:

`NoiseRange = (625 + HearingAllowance) × (TotalMass/100 kg) × ModeFactor × NoiseMultiplier`

At EffectiveStealth = 100%, movement emits no SoundAlert.

This listener-specific formula is implemented in the MAP02 diagnostic observer.
The native global NPC hearing and final faction/alert controller remain pending.


## 25. V4.26.5 — Architectural validation module

MAP architecture testing is now isolated from the physics core.

The first validated building module uses only conventional sector/linedef/sidedef concepts:

- one ordinary room sector;
- an opening framed by the wall geometry;
- one thin door sector;
- a manually activated `Door_Raise` linedef using the standard player USE input;
- ordinary raised sectors for stairs and a roof-height access platform.

This is deliberately simpler than the earlier generated 3D-floor building attempts. The purpose is to establish a topology that GZDoom's node builder accepts reliably before reintroducing walkable roofs over occupied interiors.

A locked door will later use the same geometry but a locked-door action/key requirement. The physical layout does not need to change.
