# Caelum Argenteum — Collision, Momentum and Impact Physics

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

