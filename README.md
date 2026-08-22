# Caelum Argenteum

**Caelum Argenteum** is an independent dark-fantasy FPS-RPG developed in GZDoom/ZScript. The project is designed to become a standalone distributable game rather than remain dependent on Doom content.

**Author and game designer:** Damian Curti

## Project status at a glance

The project is in active implementation. Core player statistics, survival resources, equipment, combat foundations, weapon families, elemental weapons, durability, inventory/crafting foundations, and development tooling already exist in ZScript. Large world systems such as the full calendar/weather simulation, factions, dialogue, travel, sieges, and the complete Tarot/TCG layer are planned but are not yet fully implemented.

This README is the public technical entry point for collaborators. The author's private design documentation remains the authoritative source for detailed balance, lore, formulas, and unresolved design decisions.

## Implementation status

### Implemented and tested

- Character creation foundation with race, dual-class/profession, sex, height, attribute layers, and twelve primary attributes.
- Derived statistics and non-linear attribute scaling.
- Player mass/size model and equipment-weight integration.
- Health, Anima, Air, Adrenaline, Lucidity, Hunger, Thirst, and Sleep resources.
- Air consumption for running and jumping, including load penalties and low-Air performance states.
- Movement speed, jump height, evasion, load effects, crouching, and physical immobilization states.
- Health-state penalties, pain logic, stun behavior, Adrenaline generation/decay, and natural regeneration foundations.
- Physical weapon catalogue and family/slot cycling.
- Melee attacks with accuracy, critical chance, vulnerability grades, physical damage scaling, push force, and Air costs.
- Shields, armor pieces, blocking, defense, weight, durability, and repair/debug support. Block is a persistent native Zoom-mode toggle, consumes Air continuously, suppresses Air regeneration, and supports shield-specific effects.
- Weapon durability using the shared damage-based wear logic.
- Javelin secondary throw: Air cost, fixed `-1` durability per successful throw, physical damage scaling, material recovery after impact, and one-action-per-button-press protection.
- Ranged family (standard bow, longbow, crossbow, carbine) with native ammunition/projectiles, tier-scaled damage and critical chance, normalized spread categories, per-weapon magazines, timed Reload, and AltFire aiming.
- Essence weapons: staff, bell, book, and statuette foundations.
- Primary/secondary elemental attacks, elemental projectile behaviors, homing book projectile, bell spread, and statuette explosion behavior.
- Elemental projectile visuals for Fire, Light, Water, Ice, Earth, Poison, Air/Wind, Lightning, and Quintessence.
- Inventory/equipment development interface, Magic Box foundation, consumables, ammunition, keys, and equipment pickup/drop foundations.
- Crafting and dismantling foundations used by current physical equipment and material recovery systems.
- Physical crafting-station interaction core: Forge and Bow Workshop filter and execute their currently supported physical recipes through the shared crafting transaction.
- Modular item/world sprites for current weapons, shields, armor pieces, consumables, ammunition, crafting materials, the sealed letter, and projectiles. Essence-weapon UI icons are composed from a base weapon icon plus a small elemental badge instead of duplicating one texture for every combination.
- Custom player HUD face replacing the Doomguy face states in the current development HUD. The HUD also uses the equipped weapon art as a provisional first-person weapon representation, so the permanent top-left active-weapon label is no longer required.
- Development/debug overlay and test controls used to validate gameplay formulas.

### Implemented foundation — still expanding

- Crafting content and material catalogue: physical weapons, armor, essence weapons, jewelry, seals, and the connected station network are implemented foundations. Recipe coverage and final material balancing remain active work. The carbine belongs to the Ranged Weapons Workshop together with bows and crossbows.
- Original asset replacement: many original icons and projectile sprites are integrated, but the development build still contains placeholders and inherited engine/game resources that must be removed before release.
- Inventory presentation: functional development UI exists, but final UX and art are not complete.
- Equipment visuals: item icons/world pickups are being replaced with original art; character equipment will use modular visual layers rather than complete sprites for every combination.
- Persistence: character/equipment persistence foundations exist, but the complete final save/profile/world-state design is not yet finished.
- Movable world props: a strength-gated base actor is implemented; individual rocks, fallen trees, furniture, etc. still require their final assets, collision dimensions, masses, and designer-defined physical-power requirements.

### Planned / not yet fully implemented

- **Calendar-driven weather system.** Weather must react to the game calendar/season and eventually also to location/biome. The final calendar structure, seasonal boundaries, starting date, and weather distributions are author-defined design data and must not be invented by contributors.
- Full day/night/world calendar presentation and world-state integration beyond the current gameplay time scale.
- Complete world/biome implementation, travel routes, terrestrial/maritime/aerial/submarine travel, Hell and Moon regions.
- Factions, reputation, diplomacy, and political world-state systems.
- Dialogue and NPC interaction system.
- Quest/journal system and authored quest content.
- Siege and dynamic world-event systems.
- Complete Tarot collection/progression system and Tarot-based TCG.
- Final stealth/AI systems and full NPC/enemy roster.
- Final modular third-person character/equipment sprite pipeline.
- Final independent asset pass for sprites, sounds, music, textures, fonts, HUD, menus, and maps.
- Final standalone packaging and licensing audit.



## Ranged weapon rules (V4.25.0)

The current ranged family uses the authoritative spread ladder: Minimum 10°, Very Low 30°, Low 50°, Medium 70°, High 90°, Very High 110°, Maximum 130°. Minimum spread is always 10% of maximum spread.

Current assignments are Standard Bow = Very High (11°–110°), Longbow = Medium (7°–70°), Crossbow = High (9°–90°), and Carbine = Maximum (13°–130°).

Ranged damage uses its own tier scale: T1 = 100%, T2 = 160%, T3 = 250%. The definitive T1 bases are 1200 / 1800 / 1400 / 3600 for Standard Bow / Longbow / Crossbow / Carbine. Ranged base critical chance uses the same tier scale: 10% / 12% / 8% / 6% at T1 respectively.

Magazine capacities do not change by tier: bows 50, crossbow 20, carbine 10. Base reload times are 3 / 3 / 5 / 5 seconds and are divided by the Dexterity Type-4 attack-speed modifier. AltFire toggles aiming and multiplies physical accuracy ×2; crouching also multiplies it ×2, so both effects stack.

## Collision and impact physics (V4.25.1)

Characters now use a momentum/impulse collision foundation. Actor-to-actor contact resolves an action/reaction impulse along the collision normal with coefficient of restitution `e = 0`, using effective combat mass. The resulting forced velocity change (`Delta-v`) is converted into an equivalent time to traverse half the receiver's height. More than 35 equivalent tics causes no impact damage; each step below that threshold adds 3% of maximum health, capped at 105%.

The same `Delta-v` severity model is used experimentally for wall impacts and landings, allowing future ramming, movable-object impacts and falling damage to share one physical rule. See `docs/PHYSICS_COLLISION_SYSTEM.md` for the complete formulas and design rationale.

## Impact mitigation and calibration (V4.25.2)

Collision damage now applies Toughness and global armor defense after raw kinetic severity. Global impact armor defense is the mean of the four functional armor slots; collision trauma remains non-localized and cannot be evaded or shield-blocked.

Player wall impacts are normalized against `EffectiveMovementPercent` rather than treating raw Doom velocity as physical meters. A full frontal stop at 100% movement corresponds to the 35-tic damage threshold, while load and movement modifiers alter severity naturally. Wall contact is latched so holding movement against a wall does not cause repeated impacts.

Landing detection stores the last downward vertical velocity across tics and uses the stable body-height reference. The training dummy is now movable with mass 10000 and participates in momentum collision tests.

## Acceleration, contact latch and biological landing damping (V4.25.3)

Player locomotion no longer reaches the current movement limit immediately. Continuous grounded movement follows an exponential approach to maximum speed and reaches exactly 95% after 3.0 seconds. The current factor is multiplied into the already-calculated Caelum movement percentage, so Agility, load, health/Air/survival states and shield mobility remain the source of the final maximum speed.

Actor-to-actor impact now uses a real contact latch. Once a Caelum collision pair has resolved one action/reaction impulse, maintaining contact does not create new impacts. The pair rearms only after physical separation beyond the combined collision radii plus a small engine tolerance.

Living actors now receive biological landing damping before Toughness and armor. For the player, the safe landing absorption speed equals the current normal `JumpZ`; an ordinary self-generated jump therefore does not become traumatic merely because the engine reports a large raw vertical velocity. If the player is physically stunned/immobilized, this absorption becomes zero, representing a rigid uncontrolled fall. Caelum NPCs use a geometrically scaled biological landing speed based on their body height and lose it while lucidity-stunned.

The debug overlay now exposes acceleration percentage/time, contact-latch state, raw landing delta-v and the biological delta-v absorption.

## Energy impact curve and robust contact rearm (V4.25.4)

Impact damage is now continuous and energy-shaped rather than a discrete 3%-per-tic staircase. Equivalent time still defines the kinematic severity, but damage follows specific kinetic energy (`E/m ∝ Delta-v²`). Because `Delta-v ∝ 1/T_eq`, the damage curve is proportional to `1/T_eq²`.

The curve is normalized so 35 equivalent tics = 0% raw max-HP damage and 1 equivalent tic = 100%. It continues above 100% below one tic instead of clamping, allowing genuinely extreme impacts to remain catastrophic before biological damping, Toughness and armor mitigation.

Sustained actor contact also uses a stronger rearm rule. A previously collided pair must separate by the combined radii plus 25% of the smaller body's reference height, and remain beyond that distance for 5 consecutive tics, before another collision impact is eligible. Small engine recoil/separation oscillations no longer count as a new charge.

## Impact Physics Core API (V4.26.0)

The collision mathematics are now isolated in `impactphysics/ImpactPhysics.zs`. This core is intentionally project-agnostic: it knows mass, height, velocity, collision normal, restitution, equivalent impact time and energy severity, but it does not know Caelum attributes, armor, biology, HP, classes or Tarot.

Public data structures are `ImpactBody` and `ImpactResult`. Public solver entry points are `ImpactPhysics.ResolveBodies(...)`, `ImpactPhysics.ResolveStatic(...)`, and `ImpactPhysics.ResolveExternal(...)`. `ResolveStatic` is the infinite-mass limit for walls/doors/static geometry; `ResolveExternal` is the adapter point for future non-Actor moving hazards such as avalanches or moving sectors.

CaelumPlayer and CaelumCombatActor now act as integration adapters: they build generic bodies, call the core, apply returned velocity changes, then interpret energy severity through biological damping, Toughness, armor and health.

Wall/door collision no longer uses the provisional EffectiveMovementPercent calibration from V4.25.2. The engine-observed lost velocity supplies an effective impact normal and the static solver uses the same `Delta-v -> equivalent tics -> v² energy` path as body collisions. A very massive movable body should therefore converge toward static-geometry behavior as its mass approaches infinity.

The core is structured so it can later be packaged as a standalone `ImpactPhysics.pk3` for another GZDoom project without importing Caelum-specific systems.

## Impact response refinement (V4.26.1)

Kinetic impact Toughness is now subtractive in **percentage points of maximum health**, not a multiplicative damage-resistance factor. After the energy curve and source-surface multiplier:

`PostToughness% = max(0, RawImpact% - Toughness)`

Only the remaining percentage is converted to HP, then global armor defense remains multiplicative. Toughness 100 therefore ignores impacts up to 100% raw max-HP severity but does not make the body immune to extreme 200%+ collisions.

Static geometry now rejects grazing contact when the engine removes less than 25% of the actor's pre-impact horizontal speed. Static collision also requires five consecutive clear tics before rearming, preventing narrow corridors and contact flicker from repeatedly generating wall impacts.

Wall/floor environmental impact damage no longer grants the generic received-damage Adrenaline gain. Actor-to-actor impact retains that response.

## Universal impact scale and weighted anatomical response (V4.26.2)

Impact Physics Core now uses a universal **28 map-unit reference distance** for equivalent-time severity:

`T_impact = 28 / |Delta-v|`

28 MU is half the standard 56-MU / 1.8-m Caelum humanoid reference height. Individual body height no longer changes kinetic severity, preventing size from being counted both through inertial mass and through the energy conversion. `ImpactBody.Height` remains available for neutral contact geometry and integration-specific biomechanics.

The generic API now also returns normalized vertical contact intervals for both finite bodies. These values contain no Caelum anatomy semantics. For two cylindrical actors they are derived from their actual vertical overlap. Static vertical geometry defaults to a full-height contact interval. Floor integration supplies a bottom point contact.

Caelum maps the neutral interval onto its authored anatomy regions. Region overlap lengths are normalized into weights, so vulnerability and armor are applied proportionally rather than selecting one arbitrary body part. If an impact is 80% torso, 10% head and 10% legs, torso vulnerability/armor contributes eight times as much as each 10% region.

Impact Lucidity loss uses the same normalized anatomical weights. Only naturally critical/head regions contribute the existing critical-point Lucidity loss, multiplied by their contact share and their localized armor protection. A 50% head / 50% torso impact therefore produces half the head-contact Lucidity contribution of a 100% head impact.

Fall biological damping is Agility/jump based. Player damping remains the current normal `JumpZ`; Caelum NPC damping now uses `8 × sqrt(Type1(Agility)/100)`. Physical stun removes this controlled-landing damping.

## Buckler acrobatics and fall-test map (V4.26.3)

While actively blocking with the buckler, collision Toughness is doubled and Agility/JumpZ impact absorption is doubled. Buckler acrobatic absorption also applies to horizontal wall/actor trauma. It reduces traumatic Delta-v only, never the momentum/displacement already resolved by Impact Physics. Physical/Lucidity stun disables this Agility absorption.

MAP01 adds two test rooms matching the four central rooms. The four original rooms, two new rooms and west NPC room are roofed at 128 MU. Outdoor ceiling height is raised from 256 to 512 MU, doubling vertical fall-test space and exterior wall height.

## V4.26.3b — Buckler calibration, grounded jewelry drops and MAP01 room rebuild

Buckler horizontal acrobatic damping no longer subtracts `2 × JumpZ` directly from horizontal Delta-v. That mixed two numerical scales and could force traumatic Delta-v to zero, producing the debug sentinel of effectively infinite equivalent tics. Horizontal buckler damping now derives from the **Agility jump bonus above the base GZDoom jump**, doubles that bonus as requested, and converts it to a damping fraction capped at 50% of the physical horizontal Delta-v. Floor damping remains the already-validated direct JumpZ-based rule.

The debug overlay now shows `RawDV`, `TraumaDV` and absorbed `Bio` separately so physical displacement and post-acrobatic trauma can be distinguished.

Jewelry drops preserve TossItem horizontal movement but seals and amulets have their upward Z toss removed and begin falling immediately.

MAP01 rooms were rebuilt from the clean pre-roof layout. Their walls use finite 3D middle textures instead of infinitely wrapped blocking textures, while a shared solid `Sector_Set3DFloor` slab provides a true walkable roof at 136 MU with an underside at 128 MU. A six-step exterior stair reaches the east test-room roof. All seven rooms use the same roof system, the two new rooms face the central corridor, the exterior remains 512 MU tall, and pickups are redistributed by family inside the six test rooms. Excess magic-shield duplicates are removed.

## Development test map

`MAP01` is currently a purpose-built combat/crafting test range rather than production level content. It contains a large flat field, a central cluster of open-roof test rooms, four training dummies placed along the main firing axis, and the five crafting-station actors. This map exists to make distance, projectile, combat, inventory, actor-spawn, and crafting tests reproducible. Its inherited Doom textures are development placeholders and are not release assets.

The four central rooms are also a visual pickup gallery: they expose all current weapon types, every essence combination for the four essence weapons, all shield types, all sixteen equipable armor pieces, current ammunition and consumables, the complete material catalogue, the Silver Key, and the sealed letter. This is intentionally redundant development content so a collaborator can perform a fast visual sweep for incorrect sprites or pickup behavior.

A Silver-Key-locked room is placed behind the player start. It contains the current Rulo, Argento, Caella, and Ronnie test actors plus the level-exit switch. The Silver Key required to enter is displayed in the central gallery.

The training dummies on the main east-west axis are placed approximately 512, 1024, 2048, and 3072 map units from the player start so projectile-range changes are easier to compare.

## World time, calendar, and weather

The current gameplay time scale is already defined as:

- **1 game hour = 3 real minutes.**

This timing is already used by survival systems. A complete calendar/weather simulation is planned but is intentionally not hard-coded yet because its design data is still author-controlled.

The intended architecture is:

`game clock -> calendar/date -> season -> biome/location -> allowed weather -> gameplay/visual effects`

Contributors should not choose month lengths, season dates, weather probabilities, biome distributions, or gameplay penalties without approval from the author.

## Movable world props

`CaelumMovableProp` is the common ZScript foundation for strength-gated scenery interaction.

The system intentionally uses the existing player **PhysicalPushMultiplier** rather than creating a second strength statistic. The player interacts with a movable prop through the normal `+use` control and the native `Player.UseRange`. A prop only moves if the player's physical power reaches the requirement configured for that placed actor.

### Map argument

- `arg0`: required physical power encoded as `PhysicalPushMultiplier × 100`.
- `arg0 <= 0`: unconfigured; the prop cannot be moved.

Example: a designer requirement of `1.50` is stored as `150` in `arg0`. The gameplay value itself must be chosen by the author/map designer; the base class does not invent a default threshold.

Concrete subclasses should define their own original sprite, radius, height, mass, sounds, and other presentation data. Good candidates include rocks, fallen trees/logs, crates, furniture, rubble, and other grounded objects. Upright rooted trees should normally remain static unless a specific gameplay interaction requires otherwise.

## Development principles

- **Independent final product.** The release version must not depend on Doom sprites, textures, sounds, music, fonts, maps, or other copyrighted assets that cannot legally ship with the game.
- **Development placeholders are temporary.** Temporary Doom/inherited assets may exist during implementation, but systems must not be architecturally dependent on them.
- **Native engine features first.** Prefer stable GZDoom/ZScript facilities over custom parallel systems when the engine already provides the required behavior.
- **Robustness before spectacle.** Prefer simple, testable, maintainable implementations over visually elaborate but fragile solutions.
- **Scalable architecture.** Shared behavior belongs in reusable classes/functions/data instead of near-identical copies for each weapon, item, actor, or element.
- **Modular graphics.** Character bodies and visible equipment should use independent layers where practical. UI icons may also be composed from a base icon plus overlays when the custom UI supports it.
- **Separate balance from logic.** Damage, costs, durability, weight, ranges, and other design values should remain easy to rebalance without rewriting system logic.
- **Do not invent design values.** Missing gameplay values, content decisions, calendar rules, recipes, requirements, or balance choices must be brought to the author. Contributors may propose alternatives and explain trade-offs, but must not silently make them canonical.
- **Protect tested systems.** Once a feature has been validated, later work should avoid modifying it unless required and should include regression tests when it is touched.
- **Incremental but meaningful patches.** Prefer coherent implementation packages with explicit test cases rather than many tiny unrelated edits.

## Code conventions

- Classes, functions, variables, identifiers, filenames, and implementation-facing terminology are written in **English**.
- Explanatory comments inside code are written in **Spanish**, so the author can quickly understand the purpose and boundaries of each system.
- Comments should explain systems, decisions, assumptions, and extension points rather than narrate every line.
- Code should remain readable for a developer who is still learning ZScript.
- Avoid local absolute paths, machine-specific assumptions, and undocumented dependencies.

## Asset and licensing policy

Every asset intended for the public repository/release must have a known origin and a license compatible with redistribution. Before any public alpha/release, the repository must receive an independence/licensing audit classifying assets as:

- original/project-owned;
- externally licensed and redistributable;
- development placeholder requiring replacement.

The final product must not require Doom-owned assets or other incompatible copyrighted material.

## Current development dependency note

The current development player class still inherits from `DoomPlayer`, and the test environment may load Doom II/resources while systems are being built. This is a **development convenience only**, not the intended final dependency structure. The standalone asset/player-class replacement remains part of the planned independence pass.

## Suggested contributor workflow

1. Read this README and identify the feature's current status.
2. Check whether the change affects a system already marked as tested.
3. Reuse existing base classes, constants, catalogue data, and native engine functionality whenever possible.
4. Ask the author about any undefined gameplay value or design choice before implementing it.
5. Keep code in English and explanatory comments in Spanish.
6. Provide a focused regression-test list with gameplay changes.
7. Do not mark a feature as tested merely because it compiles; runtime validation is required.

## Public repository goal

The repository is intended to be public on GitHub. Code and project structure should therefore remain understandable, reproducible, reviewable, and suitable for collaboration without access to the author's private design document.

## Asset directory layout

The development source keeps game sprites grouped by function. GZDoom supports deeper folders inside `/sprites/`, while sprite basenames must remain unique across the namespace.

- `sprites/caelum/weapons/physical/` — physical melee/thrown weapon pickups.
- `sprites/caelum/weapons/ranged/` — bows, crossbows and firearms.
- `sprites/caelum/weapons/magic/` — staff, bell, book and statuette.
- `sprites/caelum/armor/{body,head,hands,feet}/` — armor pieces by slot.
- `sprites/caelum/shields/` — shield pickups.
- `sprites/caelum/ammunition/` — ammunition pickups.
- `sprites/caelum/consumables/` — consumable world sprites.
- `sprites/caelum/items/` — keys, Tarot and quest/special items.
- `sprites/caelum/materials/` — crafting materials.
- `sprites/caelum/projectiles/elemental/` — elemental projectile rotations/static references.
- character-specific folders remain separated by character name.
