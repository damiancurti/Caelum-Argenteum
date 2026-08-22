# Caelum Argenteum 4.0 — Implementation status

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

MAP01 now has seven roofed structures: six equal test rooms plus the west NPC room. Outdoor vertical space is 512 MU.

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
