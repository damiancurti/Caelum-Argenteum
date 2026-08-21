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

## 7. Current mitigation rule

V4.25.1 treats `CaelumImpact` as global kinetic trauma:

- it cannot be evaded;
- it is not intercepted by shield Block;
- it does not use localized armor pieces;
- it bypasses ordinary armor mitigation.

This is deliberate for the first validation pass so the measured damage corresponds directly to the documented `Δv -> equivalent tics -> % max HP` relation.

Pain and ordinary "received damage" combat consequences still occur after real health loss.

This rule can be revisited after the physical scale is validated.

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

For blocking map geometry, Caelum compares velocity immediately before and after the engine movement step when a blocking line is reported.

Horizontal forced change:

`Δv_wall = |v_xy,after - v_xy,before|`

This is fed into the same height-normalized impact function.

Wall-impact detection is marked **experimental** in V4.25.1 because player acceleration, sliding and Doom movement resolution occur inside the native movement step. The debug telemetry exists specifically to validate that the measured `Δv` represents real impacts rather than ordinary steering/friction.

## 10. Falling and floor impacts

Caelum does not need a separate arbitrary fall-height damage table.

Immediately before landing the actor has a downward vertical velocity. After floor contact that component is strongly reduced or becomes zero:

`Δv_floor = |v_z,after - v_z,before|`

The same formula then applies:

`T_eq = (H/2) / Δv_floor`

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

