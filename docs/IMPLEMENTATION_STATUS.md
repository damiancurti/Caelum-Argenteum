# Caelum Argenteum — Implementation status

Author: Damian Curti  
Current prototype: 0.63.0

This file explains what has actually been programmed. The main design document
describes the intended complete game; this file describes the current GZDoom
prototype and how to verify it.

## Status labels

- Implemented: the feature already performs its intended basic function.
- Test model: calculations and controls work, but they are not yet connected to
  final gameplay or final graphics.
- Planned: documented in the game design, but not programmed yet.

## Project foundation — Implemented

- `run_dev.bat` builds the PK3 and launches GZDoom with the legal local Doom II
  IWAD.
- `build_dev.ps1` packages everything inside `src`.
- ZScript code is separated by system and contains explanatory `//` comments.
- English is the source language and Spanish is fully maintained for every
  current player-facing string.
- No Doom assets are distributed inside the project.

## Character creation — Implemented as a functional prototype

- Four origins, four identities, and four classes.
- The documented 5/3/3/1 layer distributions.
- Four free layer points with a maximum layer base of 15.
- Thirty individual points with the +5 and twice-base limits.
- Six-page creation wizard.
- Back and cancel restore the last confirmed character.
- Character data survives ordinary GZDoom save and load operations.

## Primary and derived statistics — Implemented as calculations

- Twelve primary attributes.
- Type 1 and Type 4 growth functions.
- Maximum health from Constitution.
- Maximum mana from Patience.
- Maximum air from a base of 1000 and Type 4 Resilience growth: 1000 air at
  Resilience 0 and 3000 air at Resilience 100.
- Carry capacity from a base of 100 and Type 1 Strength growth.
- Base mass from identity plus class modifier.

The values are shown in the development panel. Health now replaces Doom's
inherited health limit. Mana and air are separate working Caelum resources.

## Live health resource — Implemented

- Constitution determines maximum health through Type 1 growth from a base of 1000.
- A newly spawned character begins at the calculated maximum.
- GZDoom's normal damage, death, and healing systems change current health.
- The engine's maximum-health query returns the current Caelum maximum, so
  ordinary health pickups can respect the Constitution-derived limit.
- Current and maximum health are stored with the player in ordinary saves.
- Recalculating a profile never grants free healing. If the maximum rises,
  current health stays unchanged. If it falls below current health, the current
  value is reduced only enough to fit the new maximum.
- Natural recovery fills the current maximum over one real hour at 100% speed.
- Resilience Type 4 multiplies this recovery speed.
- Any critical hunger, thirst, or sleep state stops natural recovery completely.
- Each 1% naturally healed consumes 1% hunger and 0.5% thirst; insufficient
  resources proportionally limit healing.
- Above 50% health the player is healthy and receives no health-state penalty.
- At 50% or less the player is wounded: raw pain chance and gameplay-earned
  adrenaline are x2; outgoing sword damage, air recovery, movement, evasion,
  and jump performance retain 75%.
- At 10% or less the player is badly wounded: raw pain chance and earned
  adrenaline are x4; those performance values retain 25%.
- Current adrenaline progressively restores the missing performance and reduces
  the extra x2/x4 intensity toward x1. At 100%, all added health-state penalties
  are ignored. The ordinary pain immunity at full adrenaline still applies.
- Patience Type 3 reduces the detrimental portion of wounded and badly wounded
  states before adrenaline mitigation. It softens pain and performance loss,
  while the beneficial x2/x4 adrenaline gain remains intact.
- The health bar interpolates continuously from green at 100% to gold at 50%
  and red at 10%, while localized text reports the current health state.
- A localized development control cycles full, 50%, and 10% health without
  creating a hit, pain roll, or adrenaline gain.
- The unified resource-restoration control fills health, mana, and air to their
  current calculated maximums in one press.

## Live mana resource — Functional test model

- Patience determines maximum mana through Type 1 growth from a base of 1000.
- Patience also determines mana regeneration through Type 4 growth.
- At 100% regeneration speed, a complete empty-to-full refill takes eight
  minutes. At 200%, it takes four minutes.
- Current mana starts at maximum, regenerates continuously, never falls below
  zero, and is preserved by ordinary saves.
- A provisional debug action spends 100 mana and a separate control refills it.
- Changing character data never grants free mana. A lower maximum only clamps
  a current value that exceeds it.

No final spell consumes mana yet. Individual spell and magical-weapon costs
will be connected when those actions are implemented.

## Live adrenaline resource — Functional prototype

- Maximum adrenaline uses `1000 × Type4Percent(Resilience) / 100`.
- It is 1000 at Resilience 0 and exactly 3000 at Resilience 100.
- A newly spawned character begins with zero adrenaline.
- Losing health through GZDoom's real damage pipeline grants ten adrenaline.
- Damage prevented completely by engine protections grants nothing.
- Each confirmed damage event restarts a thirty-second combat timer.
- When that timer reaches zero, adrenaline falls by ten points per second
  until it reaches zero.
- Current adrenaline and its timer are stored with the player in normal saves.
- Killing a hostile monster grants five adrenaline to the responsible player.
- When an ally dies, each living allied player within ten development meters
  (320 map units) gains ten adrenaline.
- Temporary localized controls add ten adrenaline or clear the resource.

The isolated melee test grants three adrenaline only when its target actually
receives positive damage. Successful evasion grants eight. A positive shield
block grants five base adrenaline. Projectile/magic damage and Tarot-card
consumption are not yet connected; their documented gains and costs will be
implemented with the corresponding combat systems so actions cannot be
misclassified.

The documented future values also return to their initial scale: a successful
shield block grants five and projectile/magic damage grants two.

## Base melee damage and vulnerability — Functional test model

- A localized debug action performs one real short-range line attack.
- Its provisional sword primary attack has 120 base damage and 64 units of range.
- Strength uses Type 1 growth and directly multiplies weapon base damage.
- Before location, the current formula is
  `120 × Type1Percent(Strength) / 100 × EffectiveHealthPerformance`.
- Crosshair pitch selects the vertical impact point on the actor reached.
- Head is 80%-100% of actor height and defaults to critical point, x2.00.
- Torso is 40%-80% and defaults to sensitive point, x1.60.
- Arms overlap 30%-50% vertically and default to weak point, x1.30. Because Doom
  actors use cylinders rather than limb hitboxes, this zone requires the trace
  to pass through the outer half of the target width; central overlap remains torso.
- Legs are 0%-30% and default to neutral point, x1.00.
- The other fixed normal multipliers are strong x0.80, hard x0.60, and armored x0.40.
- Critical-hit location multipliers use `V × (V + 1)`: critical x6.00,
  sensitive x4.16, weak x2.99, neutral x2.00, strong x1.44, hard x0.96,
  and armored x0.56.
- Every sword hit now rolls a physical critical chance equal to `5% +
  Type2Percent(Dexterity)`, capped at 100%. A miss makes no critical roll.
- A successful roll replaces the normal localized multiplier with its
  corresponding `V × (V + 1)` value. It does not apply a second global x2.
- Critical hits only increase damage, regardless of physical, projectile,
  magical, elemental, or other damage type. They add no secondary status effect.
- The combat page reports the current physical chance, last roll, and whether
  the valid hit was normal or critical. At all attributes 75, the physical
  chance is approximately 61.44%, making repeated testing practical.
- At Strength 0 the calculated damage is 120; at Strength 30 it is 678.
- GZDoom applies the rounded base-times-health-times-location damage to the actor reached.
  The panel separately reports calculated damage, real post-engine damage, hit
  or miss, selected zone, multiplier, and relative impact height.
- A hit that produces positive real damage grants three adrenaline and restarts
  the thirty-second combat timer. A miss or fully prevented damage grants none.
- The attack is disabled while the player's physical lucidity stun is active.
- A valid attempt costs five base air multiplied by equipped-load air use.
- The complete cost is paid when the attempt begins even if it misses.
- If current air is below the complete final cost, no trace, damage, or partial
  payment occurs. The panel reports the required cost and insufficient air.
- A triggered player pain state immobilizes movement, jumping, running, and
  the sword test for the exact finite duration of the actor's `Pain` sequence.

Arm precision loss, leg movement loss, survival offensive penalties, weapon
animations, and final art remain outside this isolated test. The latter two
localized effects require Caelum's common actor/status-effect layer rather than
ad-hoc changes to provisional Doom monsters.

Original Caelum actors now own configurable anatomy profiles. A profile accepts
up to sixteen ordered normalized regions; each independently stores a location,
one of the seven vulnerability grades, vertical limits, and lateral limits.
This permits several entries with the same grade, including multiple critical
points. Overlap resolves by authored order, so a narrow weak point can precede
a broader torso region. Argento and Caella currently use the verified humanoid
profile: head critical, torso sensitive, outer arm/hand band weak, and legs
neutral. Sword and staff traces ask this profile to classify the impact, then
apply the multiplier exactly once. Non-Caelum actors retain the same humanoid
fallback used by the training dummy.

This first profile operates on normalized height and lateral position inside
GZDoom's cylindrical hitbox. The data model is ready for several named weak
regions; full independent 3D volumes for unusual bodies, two heads, tails, and
centaur-like anatomy remain a later collision-system extension.

## Argento and Caella animations and ranged attacks — Functional test model

- Both actors now have original eight-direction frames for walking, ranged
  casting, receiving pain, and lying dead in addition to idle and sword attack.
- Their pursuit loop alternates idle and stride poses without changing speed,
  72-unit height, 21-unit radius, mass, or existing melee balance.
- A triggered Caelum pain state displays the hurt pose for eight tics, matching
  the existing brief pain immobilization.
- Death first displays the hurt transition and finishes in a persistent
  direction-aware corpse pose with collision blocking removed.
- At range, Argento casts a blue bolt and Caella a violet bolt. The monster AI
  chooses this state through GZDoom's ordinary melee/missile decision.
- Both projectiles travel at speed 24 and begin from 138 base
  `CaelumMagicTest` damage before live health performance and receiver defenses.
  They can critically increase localized damage but add no secondary effect.
- Compact combat diagnostics report the last Caelum actor's anatomy location,
  vulnerability grade, normalized height, and lateral ratio.

## Four predefined characters — Functional test model

The four predefined profiles from the design document are now represented by
original hostile test actors. Argento and Caella cover the two existing human
variants. Rulo and Ronnie add the two non-human identities with distinct body
scale, attributes, and combat emphasis.

### Rulo — Southern Beast Warrior

- Attributes follow the predefined table exactly: physical 20, technical 18,
  social 7, and mental 5. The defensive actor receives Toughness 20,
  Resilience/Agility 18, and Patience 5.
- Constitution 20 produces 3100 health. His identity/class mass is 85 + 10 = 95.
- His broad bear body uses radius 28 and height 80. Speed 8 makes him visibly
  heavier than the human test actors without changing the movement formula.
- His axe melee begins from 372 physical damage. At range he throws an authored
  axe projectile at speed 20 from the same 372 base physical damage; both use
  his live health factor, accuracy, and physical critical chance.
- Eight rotations exist for idle, walking, axe melee, axe throw, pain, and death.

### Ronnie — Northern Caelith Explorer

- Attributes follow the predefined table exactly: physical 5, technical 18,
  social 7, and mental 20. The defensive actor receives Toughness 5,
  Resilience/Agility 18, and Patience 20.
- Constitution 5 produces 1150 health. His Caelith/Explorer mass is 60 + 0 = 60.
- His lean body uses radius 20 and height 72. Speed 12 distinguishes his
  technical mobility from Rulo and the speed-10 human variants.
- His sword melee begins from 138 physical damage. At range his golden Caelith
  bolt travels at speed 28 and begins from 372 base magical damage from
  Intelligence 20; both use his live health factor and corresponding offensive
  attribute.
- Eight rotations exist for idle, walking, sword melee, tarot-like golden cast,
  pain, and death.

Both actors inherit `CaelumCombatActor`: shared humanoid anatomy classification,
evasion, Toughness mitigation, pain, adrenaline, wounded states, enemy-kill
reward, and post-combat decay are live. Independent localized controls spawn
Rulo 224 units ahead or Ronnie 192 units ahead. Compact page 3/6 identifies all
four predefined actors by name and reports the same anatomy/defensive data.

## Armor, reinforcement, and durability — Functional test model

- Head, body, hands, and feet store independent armor type, tier, and durability.
- Every slot of one type/tier has the same defense: unarmored 5%/10%/15%, light
  10%/20%/30%, medium 20%/40%/60%, and heavy 30%/60%/90% for tiers 1/2/3.
- Humanoid base vulnerability is critical at head, sensitive at body, weak at
  hands, and neutral at feet/legs.
- Reinforcement shifts only that equipped slot one grade per point, clamped at
  armored. Unarmored body gives +1; light head/body +1; medium head/body/feet
  +2; heavy gives +3 in every slot.
- Attribute bonuses are live: unarmored head Intelligence, hands Patience, feet
  Insight; light hands Dexterity and feet Agility; medium hands Dexterity.
  Their tier values are +5/+10/+20. The level-75 development override remains
  exactly 75 so probability testing is not distorted by equipment bonuses.
- Damage order is vulnerability (including reinforcement), then defense.
  Defense N absorbs N% and the remainder becomes post-defense health damage.
- Durability uses absorbed damage. Each complete 1000 absorbed damage removes
  one durability automatically. The remainder gives one additional chance at
  1% per ten absorbed damage: 500 remainder means 50%.
- Durability still scales x1/x3/x9 by tier from bases 20/40/60/100. At zero,
  that piece's defense, reinforcement, and attribute bonus stop functioning.
- A stored x1 durability-damage multiplier is the extension point for future
  mitigation. The shield test now reuses this same absorbed-damage rule.
- The same four-slot model is now live on all four predefined hostile actors.
  Argento, Caella, and Ronnie use light tier 1; Rulo uses heavy tier 1.
- A sword or staff impact uses the actor's authored anatomical region to select
  head, body, hands, or feet. Reinforcement changes effective vulnerability,
  then that exact piece absorbs its defense percentage and alone receives wear.
- Actor durability uses one guaranteed point per complete 1000 absorbed damage,
  plus one percentage chance from the remainder at 1% per ten absorbed damage.
- Armor-derived Agility and Patience contribute to actor evasion and wounded-
  state penalty mitigation, and stop when the relevant piece breaks.
- Attacks that do not yet report an authored contact point use torso as a safe
  fallback until final projectile volumes enter the localized pipeline.
- Directed ordinary attacks against the player now use the complete custom
  defensive order automatically: evasion; real-angle shield coverage and
  shield defense/durability; selected armor region vulnerability,
  reinforcement, defense/durability; Dureza; health; localized lucidity; pain;
  and damage adrenaline.
- Melee, hitscan, bullet, Caelum physical projectiles, and Caelum magical
  projectiles qualify. Explosions and environmental/survival hazards retain
  their existing native route and do not wear equipment.
- Being struck while blocking consumes no extra air. The only shield air cost
  remains its documented continuous weight-based cost per second.
- Until player hit volumes exist, the armor page's selected head/body/hands/
  feet slot is the explicit development hit region for incoming ordinary
  attacks. The shield angle is no longer simulated for these hits: it comes
  from the actual attacker position.
- Localized controls select slot, type, tier, normal/critical test mode, apply a
  confirmed 1000-base-damage hit, and repair the selected piece. The panel shows
  effective grade, multiplier, pre-defense damage, absorbed damage, health loss,
  durability roll/chance, and remaining durability.

Tarot effects are planned as shared effect definitions plus contextual variants.
They may select different magnitude, action, or condition from the holder's
class, origin, identity, species, or faction. The holder interface will be
common to players and original enemies, allowing enemies to own cards and gain
the same global bonuses and compatible active/passive effects. This remains
documented architecture and is not implemented in this prototype.

## Shield blocking — Functional test model

- The test includes rodela, kite, tower, and magic shields with the documented
  weight, physical/magical defense, base durability, and coverage angle.
- The original defense values now belong to tier 2. Tier 1 subtracts ten
  percentage points and tier 3 adds ten percentage points to both defenses.
  Durability still scales x1/x3/x9. Actual absorption is capped at 100%.
- Physical/magical defense by tier is: rodela 50/60/70%, kite 70/80/90%, tower
  80/90/100%, and magic 40/50/60% physical plus 80/90/100% magical.
- Blocking is toggled through a localized development control. While active it
  pauses air regeneration and spends `ShieldWeight × 10% × AirMultiplier` air
  per second. Blocking ends automatically at zero air or zero durability.
- A localized control selects physical or magical damage, and another submits
  one frontal 1000-damage test hit. Shield absorption resolves first. Every
  remaining point then enters the currently selected humanoid armor region.
- After the shield, the existing armor pipeline applies regional vulnerability
  and reinforcement, armor defense and durability, real health loss, localized
  lucidity loss, pain chance, damage adrenaline, and the combat timer.
- Dureza Type 3 is the last damage stage in this shared debug pipeline. It
  multiplies post-armor damage by
  `1 - Dureza × (Dureza + 1) / 10100`, from x1 at level 0 to x0 at level 100.
- Dureza does not change shield or armor durability because those use damage
  absorbed before the final Dureza stage. Its existing lucidity-loss and pain
  multipliers remain separate and still apply to their respective results.
- At 100% shield absorption no armor durability, health, lucidity, or pain is
  produced. With blocking inactive or the shield broken, all 1000 points enter
  the selected armor region.
- Shield durability uses the armor rule: each complete 1000 absorbed damage
  removes one point, and the remainder rolls an additional 1% chance per ten.
  The existing future mitigation multiplier is applied before this calculation.
- Any positive block grants five base adrenaline through the normal combat
  gain pipeline and restarts the combat timer. Health-state adrenaline gain
  modifiers therefore still apply.
- Horizontal coverage is functional. A localized control cycles the incoming
  angle from 0° to 180° in ten-degree steps relative to the player's front.
- Blocking succeeds only inside half the total arc: rodela and magic cover
  ±60° (120° total), kite ±70° (140°), and tower ±80° (160°).
- A hit outside that arc bypasses the shield completely: it causes no shield
  absorption, durability loss, or block adrenaline, and enters the selected
  armor region through the existing armor–Dureza–health pipeline.

Final secondary-hand equipment, held AltFire input, animations, vertical or
overhead coverage, automatic attack-direction metadata, and routing ordinary non-debug attacks
through the complete equipment pipeline remain planned.

## Straight-line magical staff — Functional test model

- A localized control performs one real long-range straight trace representing
  the staff. The trace distance and temporary puff are presentation scaffolding
  because the design table does not yet specify a numerical staff range.
- Its documented base damage is 120 and Intelligence Type 1 multiplies it.
  Existing health and survival offensive penalties apply before location.
- Every accepted cast spends 500 mana immediately. This is the table's former
  50 cost converted to the established x10 mana scale. Insufficient mana causes
  no trace, damage, partial payment, or cooldown.
- A cast starts an 18-tic interval (about 0.514 seconds) during which another
  staff test cannot begin.
- Insight Type 1 supplies magical accuracy. Lucidity modifies it and crouching
  doubles the available magical accuracy, producing a small provisional
  horizontal/vertical trace error like the sword test.
- Staff critical chance is its documented 8% weapon base plus Insight Type 2.
  Crouching doubles the chance, capped at 100%. A successful critical only
  selects the localized critical damage multiplier and adds no status effect.
- The humanoid impact region uses the existing seven-grade vulnerability model.
  Positive real damage grants two adrenaline and restarts combat time.
- The fifth compact debug page reports calculated/actual damage, 500 mana cost,
  magical accuracy and offsets, critical chance/roll/result, location
  multiplier, insufficient mana, and remaining casting interval.

The staff remains a player debug trace. Argento and Caella now provide the
first real straight magical projectile actors; final player weapon projectiles,
elemental sounds, secondary element, elemental status effects, authored range,
and final first-person weapon animation remain planned.

## Original hostile test characters — Functional test model

- Separate localized controls spawn Argento, Caella, or Ronnie 192 map units in
  front of the player; Rulo uses 224 units for his wider body.
- Both are real hostile monsters: they detect and pursue the player, attack
  in melee, receive damage, enter pain, die, and qualify for the existing
  enemy-kill adrenaline reward.
- His profile is one legal newly-created Southern Federal Warrior. The four
  layer bases are physical 15, technical 11, social 9, and mental 5.
- The thirty individual points specialize combat: Strength, Toughness, and
  Constitution are 20; Dexterity, Resilience, and Agility are 16; Charisma,
  Empathy, and Eloquence remain 9; Intelligence, Patience, and Insight remain 5.
- Constitution 20 gives 3100 health. Strength 20 makes the 120-base sword deal
  372 damage before the defender's vulnerability and mitigation stages.
- The visual test supplies eight transparent rotations each for idle, melee,
  stride, ranged cast, pain, and death at a humanoid 21-radius/72-height scale.
- Caella deliberately inherits the same complete profile and behavior as
  Argento, making them mechanically equivalent visual test variants.

## Common defensive combat actor — Functional original-actor prototype

- `CaelumCombatActor` is now the common base for Argento, Caella, and future
  original non-player combatants.
- Argento and Caella initialize the same legal Southern Federal Warrior
  defensive values: Toughness 20, Resilience 16, Agility 16, and Patience 5.
- Their directed melee, hitscan, and missile damage first rolls evasion from
  Agility Type 2 and the existing total-mass multiplier. A success prevents all
  damage, grants eight base adrenaline, and restarts combat time.
- On a failed evasion, Toughness Type 3 reduces retained health damage before
  the actor's actual percentage of health lost is measured.
- Real post-mitigation health loss produces one Caelum pain roll: ten times the
  percentage of maximum health lost, reduced by Toughness Type 3 and current
  adrenaline. Native Doom pain chance is disabled to avoid a second roll.
- At 50% and 10% health, the same wounded and badly-wounded intensity rules
  multiply pain and earned adrenaline x2/x4. Patience mitigates harmful
  intensity and current adrenaline suppresses it progressively.
- Each actor owns Type-4 maximum adrenaline from Resilience. Damage grants ten,
  pain grants twenty, and evasion grants eight before the health-state gain
  multiplier. Combat lasts thirty seconds and decay remains ten per second.
- Combat debug page 3 displays the last damaged original actor's name, health,
  adrenaline, evasion roll/chance, lost-health percentage, pain chance, and
  result. Striking any of the four predefined actors selects it automatically.

This common actor now also owns its ordered humanoid anatomy profile, localized
equipment, offensive attributes, and live health-state penalties. Actor air,
hunger, thirst, and sleep have deliberately not been invented ahead of their
resource designs.

## Shared actor offense and health performance — Functional prototype

- Argento and Caella use Dexterity 16 and Insight 5. Rulo uses Dexterity 18 and
  Insight 5. Ronnie uses Dexterity 18 and Insight 20.
- Living armor bonuses are included. Argento, Caella, and Ronnie therefore gain
  the light-glove Dexterity bonus while that piece remains functional.
- Physical and magical accuracy each use Type 1 from their corresponding
  attribute. Critical chance is `5% + Type2` from Dexterity for physical
  attacks or Insight for magical attacks.
- Every valid offensive execution rolls accuracy first and critical only after
  accuracy succeeds. A failed accuracy roll deals no damage and cannot be
  critical.
- Healthy actors retain x1 damage and movement. At 50% or less they retain raw
  x0.75; at 10% or less they retain raw x0.25. Patience mitigates the harmful
  share first and current adrenaline then restores the same share progressively.
- The health factor scales actual movement `Speed` and the authored base damage
  of both melee and projectiles. It does not change collision dimensions.
- Pain chance and gameplay-earned adrenaline retain the existing x2/x4 health
  intensity. Patience and adrenaline mitigate harmful pain intensity; the
  beneficial adrenaline multiplier remains x2/x4.
- Real actor criticals have no secondary effect. They only replace the selected
  region's normal multiplier with `V × (V + 1)` for every damage type.
- Against the player, actor damage resolves shield coverage and defense first,
  then the selected temporary body region, armor defense, Dureza, health,
  localized lucidity, pain, adrenaline, and equipment durability.
- Melee critical metadata is consumed once during its synchronous hit.
  Projectiles carry an independent copy, so overlapping missiles cannot reuse
  or overwrite another attack's result.
- Compact page 6/6 displays the inspected actor's effective attributes,
  physical/magical accuracy and critical chances, current/base speed, health
  factor, evasion, last base/final damage, accuracy roll, critical roll, and
  the last actor critical received by the player.
- Two localized actor controls cycle the last inspected actor through
  healthy/herido/malherido and lúcido/mareado/aturdido for repeatable tests.

## Shared actor lucidity — Functional original-actor prototype

- Argento, Caella, Rulo, and Ronnie each own 100 lucidity and recover the full
  resource over one real minute while alive.
- Only a damaging hit in a naturally critical anatomy region removes lucidity.
  Armor reinforcement does not remove that eligibility.
- The loss is `25 × critical factor × (1 − defense%) × Toughness Type 3`.
- A normal hit uses critical factor x1. A critical sword or staff hit derives
  its factor from the region's effective vulnerability after reinforcement,
  exactly like the player rule.
- At 50% or less the actor is Mareado and retains x0.50 offensive accuracy.
  Until final actor aim cones exist, the test AI realizes this as half of melee
  and ranged attack executions missing.
- At 10% or less the actor is Aturdido. Crossing the threshold from above
  prevents pursuit and attacks for two seconds. The timer does not restart
  while lucidity remains at or below 10%; the actor must recover above the
  threshold and cross it again.
- Actor sleep has not been invented ahead of its resource system. Cansado,
  Exhausto, and Patience sleep-duration modifiers remain active for the player
  and will be reused when actors gain sleep.
- Compact combat page 3/6 shows actor lucidity, state, accuracy multiplier,
  latest loss, and remaining physical-stun time.

## Passive evasion — Functional player prototype

- Effective chance starts with Agility Type 2.
- Total mass applies the same `100 / (TotalMass / 2 + 50)` factor as movement.
- Tired air retains 75% of the mass-adjusted chance and breathless retains 25%.
- Directed melee, hitscan, and missile attacks roll evasion before damage.
- A successful roll returns zero damage before armor, pain, health-loss
  adrenaline, or other post-hit systems can run.
- Success grants eight adrenaline and restarts the combat timer.
- Failure continues through GZDoom's ordinary mitigation and Caelum pain logic.
- Explosions, floor hazards, environmental damage, telefrags, and unclassified
  damage never roll evasion.
- A localized debug control generates a directed 1%-maximum-health test attack.
  The panel shows whether evasion applied, its chance, the roll, and the result.

Final dodge animation and sound remain pending until original presentation
assets exist. Attack classification will migrate from damage-type conventions
to explicit Caelum attack metadata when the common combat actor layer exists.

For development probability tests, one localized toggle temporarily sets all
twelve attributes to level 75. It bypasses creation limits only while active,
recalculates derived statistics immediately, and restores the untouched normal
profile and allocation when disabled.

## Pain state — Functional player prototype

- CaelumPlayer replaces DoomPlayer's native pain probability with one custom roll.
- The roll occurs only after engine armor, invulnerability, and other mitigation;
  impacts causing no real health loss cause neither pain nor adrenaline.
- Health loss percent is `ActualHealthLost / MaximumHealth × 100`.
- Base pain chance is ten times that percentage.
- Dureza applies its Type 3 retained multiplier:
  `1 - Dureza × (Dureza + 1) / 10100`.
- The adrenaline percentage present immediately before the hit multiplies the
  remaining chance by `1 - AdrenalineRatio`.
- Final chance is clamped between 0% and 100%.
- The complete formula is
  `Clamp(10 × HealthLossPercent × DurezaMultiplier × (1 - AdrenalineRatio), 0, 100)`.
- At 100% pre-hit adrenaline, pain chance is zero. Adrenaline earned from the
  current hit is added only afterward and cannot alter that hit retroactively.
- Confirmed health loss grants 10 adrenaline. If pain triggers, it grants 20
  more, for 30 total from a damaging hit that also enters pain state.
- A successful pain roll enters the actor's `Pain` state and immobilizes the
  player for the summed duration of that animation. DoomPlayer has two four-tic
  frames, so its current lock lasts 8/35 seconds (about 0.229 s). Custom Caelum
  actors automatically use their own finite `Pain` sequence duration.
- The development panel shows the latest health-loss percent, Dureza multiplier,
  final chance, and whether the roll triggered or was resisted.
- A localized pain-test action directly removes 5% of maximum health, rounded
  to an integer and limited to leave at least one health point. It bypasses
  provisional Doom armor but uses the exact same Caelum pain and adrenaline
  calculation as real post-mitigation damage.

The reusable formula now applies to Argento and Caella through their common
combat actor class. Provisional Doom monsters keep their native pain behavior
because they do not use Caelum maximum health, attributes, or adrenaline.

## Live lucidity resource — Functional test model

- Lucidity has a fixed maximum of 100 and begins full.
- A complete recovery from zero takes one minute.
- Above 50%, the stored state is normal.
- At 50% or less, the stored state is dizzy.
- At 10% or less, the stored state is stunned.
- Dizzy and stunned states retain 50% of physical and magical accuracy.
- Physical accuracy is Dexterity Type 1 and magical accuracy is Insight Type 1.
  The factor is shared so final melee cones, ranged weapons, and spells can use
  the same state rule.
- The provisional sword already uses effective physical accuracy: its small
  horizontal and vertical angular error is `6 degrees × 100 / accuracy%`.
  Therefore losing half accuracy doubles the possible error without changing
  sword damage or critical chance.
- Attacking with the provisional sword while running retains 25% of the
  physical accuracy available after attributes and lucidity. Standing and
  walking retain 100%. The factors multiply, so running while dizzy retains
  `0.25 × 0.50 = 0.125`, or 12.5% of attribute-derived accuracy.
- Crouching multiplies post-lucidity physical accuracy by x2, physical critical
  chance by x2 (capped at 100%), and the stored stealth factor by x2. Crouching
  takes precedence over running because GZDoom cannot run and crouch as one
  effective stance.
- The stealth factor is stored and visible for testing. Original enemies do not
  yet use it because their final perception/detection system is still planned.
- Dizzy and stunned states render a restrained violet full-screen tint with
  opposed cyan/red edge bands. The HUD is drawn afterward and remains sharp.
- Crossing from above 10% to 10% or less triggers one two-second physical stun.
- Movement and jumping are disabled during those two seconds, horizontal
  sliding stops, and the remaining time is shown in both HUDs.
- Remaining at or below 10% does not restart the timer. After two seconds the
  character can move again even if lucidity is still critical; lucidity must
  first rise above the threshold and cross it again to cause another stun.
- The active stun timer survives ordinary save/load operations.
- A temporary control removes ten points and another restores the resource.
- Current lucidity and its state survive ordinary save/load operations.
- Dureza's Type 3 multiplier is calculated and visible in the panel.
- A confirmed hit on an anatomically natural critical point removes localized
  lucidity even when reinforcement lowers its effective vulnerability.
- The formula is `25 × critical factor × (1 − defense%) × Toughness Type 3 ×
  sleep factor`.
- A normal hit has critical factor x1. A critical hit uses effective critical
  multiplier divided by effective normal multiplier: unreinforced critical is
  `6 / 2 = x3`; reinforced sensitive is `4.16 / 1.6 = x2.6`.
- Armor defense mitigates exactly the same percentage of localized lucidity as
  damage. For example, 40% defense changes 25 into 15 before other modifiers.
- Low sleep has raw x2 and critical sleep raw x4 for localized lucidity loss
  and physical lucidity-stun duration. Patience Type 3 reduces only the harmful
  part above x1: `1 + (raw − 1) × PatiencePenaltyMultiplier`.
- Future anatomy modifiers may turn another region, such as hands, into a
  natural critical point; the shared rule then applies there regardless of type.

The debug loss remains a flat ten points so resource timing and thresholds are
easy to verify. Dureza will modify classified losses from head impacts,
neurotoxins, and similar sources when localized damage and status effects exist.
One additional localized control cycles directly through 100%, 50%, and 10%
lucidity so clear, dizzy, and stunned behavior can be compared immediately.
Final weapon-specific minimum/maximum dispersion cones remain planned. The
current sword error is a functional bridge for testing shared accuracy,
running, and crouching rules.

## Combat training dummy — Functional development tool

- A localized control spawns one original wooden-and-brass training dummy 128
  map units directly ahead of the player, facing the player.
- It has 1,000,000 health, a humanoid 21-radius/72-height collision body, zero
  pain chance, maximum actor mass, no damage thrust, and no pushing.
- Its velocity is cleared every tic as a second safeguard against displacement.
- It is shootable and receives real engine damage, so the sword's location,
  critical, accuracy, adrenaline, and survival/health damage factors can be
  tested repeatedly without a hostile monster moving or dying quickly.
- If the requested position is obstructed, the provisional spawn is removed
  instead of being left inside another actor or wall.
- The original development sprite uses a 48×72 canvas whose full visual height
  matches the 72-unit actor hitbox. Its 42-pixel opaque silhouette matches the
  42-unit collision diameter, so the visible knees, torso, and head correspond
  to the same vertical location thresholds used by the sword. Final animation
  and multiple viewing angles remain presentation work rather than combat-system work.

## Hunger, thirst, and sleep — Functional test model

- One game hour equals three real minutes; one game day equals 72 real minutes.
- Hunger empties in 24 game hours: 72 real minutes before attribute modification.
- Thirst empties in 12 game hours: 36 real minutes before attribute modification.
- Sleep empties in 16 game hours: 48 real minutes before attribute modification.
- Constitution Type 3 slows hunger and thirst loss.
- Resilience Type 3 slows sleep loss.
- Each resource begins at 100%, is stored in saves, and never falls below zero.
- At 50% or less it enters its low state; at 10% or less its critical state.
- Temporary controls remove ten points from each resource or refill all three.

The documented movement and jump-height penalties are cumulative. Each low
state retains 75%; each critical state retains 50%. For example, two low states
produce `0.75 × 0.75 = 0.5625`, retaining 56.25% before mass and air factors.
The same cumulative factor now multiplies real outgoing sword damage. It is
stored as a shared survival performance value so later physical, projectile,
magical, and elemental attacks can reuse it rather than implementing separate
survival rules.
Adrenaline progressively restores the missing performance according to its
current percentage of maximum. The formula is `Raw + (1 - Raw) × AdrenalineRatio`.
Thus raw x0.50 with 50% adrenaline becomes effective x0.75; 100% adrenaline
becomes x1.00 regardless of its absolute point maximum.

Health-state and survival damage penalties are independent and therefore
multiply: `EffectiveOffensiveDamage = HealthPerformance × SurvivalPerformance`.
The provisional sword applies that combined factor after Strength and localized
vulnerability. Damage never changes critical probability or location selection.

Every critical resource also inflicts health loss at the negative base natural
health-regeneration rate. Base regeneration fills maximum health over one real
hour, so one critical state removes a full maximum over that period. Two or
three critical states multiply the rate. Armor does not
absorb it, it grants no adrenaline, and it can kill the player normally.

Sleeping behavior, food, and drink remain planned.

## Equipment load and mass — Test model

- Temporary controls add equipment weight in steps of five units or reset it.
- Total mass equals base mass plus equipped weight.
- Load percentage equals equipped weight divided by carry capacity.
- The panel identifies normal load, overload above 75%, and exceeded capacity
  above 100%.
- Push resistance, knockback, movement, evasion, and air-use multipliers are
  calculated and displayed.

Movement, knockback, and evasion remain visible calculations only. The air
multiplier now affects a provisional live resource test.

### Confirmed air-consumption formula

Let `L` be equipped weight divided by carry capacity.

- If `L <= 0.75`: `AirMultiplier = 1 + L`.
- If `L > 0.75`: `AirMultiplier = 1.75 + 2 × (L - 0.75)`.

Reference values:

| Equipped load | Air-use multiplier |
| --- | --- |
| 0% | x1.00 |
| 50% | x1.50 |
| 75% | x1.75 |
| 80% | x1.85 |
| 100% | x2.25 |

Only the amount above 75% is doubled. Natural body mass does not increase this
air-use multiplier.

## Live air resource — Functional test model

- Current air begins at maximum air.
- The value is stored on the player and is preserved by ordinary saves.
- One debug action has a base cost of 10 air units.
- Its final cost is `10 × AirMultiplier`.
- A separate control refills current air to its maximum.
- Current air never falls below zero.
- Air regenerates automatically and a complete refill takes eight minutes.
- Regeneration per second scales with maximum air.
- Recovering 100% air consumes 10% hunger and 20% thirst; equivalently, every
  1% recovered costs 0.1% hunger and 0.2% thirst.
- If hunger or thirst cannot fund the next recovery amount, air regeneration
  is limited proportionally and never pushes either survival resource negative.
- Above 50% air the state is normal.
- At 50% or less the state is tired.
- At 10% or less the state is breathless.

Running spends two base air units per second and a successful jump spends five
base units. Both costs use the equipped-load multiplier. The shield test spends
10% of shield weight per second while blocking and uses the same multiplier.
Walking, standing, swimming, flying, ordinary attacks, and weapon reloading do
not yet consume air automatically. Tired and breathless are detected; their
exact evasion multipliers are included in the calculated effective chance.

Running detection uses GZDoom's effective run state. With Always Run disabled,
holding the run key consumes air. With Always Run enabled, ordinary movement
consumes air and holding the run key switches to walking without consumption.

## Gameplay HUD — Functional prototype

- Hunger, thirst, and sleep appear as a lower-right survival stack.
- Lucidity appears in cyan, changing to gold when dizzy and red when stunned.
- Current and maximum adrenaline appear in gold with the combat timer.
- Current and maximum mana appear in violet with a proportional bar.
- Current and maximum health appear in red with a proportional bar.
- Current and maximum air are always visible while the player is alive.
- A proportional bar shows the remaining share of the resource.
- The localized state appears beside the numbers.
- Normal air is light blue, tired is gold, and breathless is red.
- The HUD is independent from the optional development panel.
- It uses a temporary built-in GZDoom font and contains no distributed Doom
  artwork. The bar itself is drawn through code. Original interface assets
  remain planned.

## Evasion pipeline — Functional calculation

- Agility produces base evasion through Type 2 growth.
- Total mass applies the documented mass multiplier.
- Normal air retains 100% of mass-adjusted evasion.
- Tired retains 75%.
- Breathless retains 25%.
- The panel shows all three calculation stages.

Equipment weight already forms part of total mass, so it benefits or penalizes
evasion through the same formula as movement: `100 / (TotalMass / 2 + 50)`.
There is no second overload-only evasion multiplier. Effective player evasion
already cancels directed incoming damage. Original Caelum combat actors now use
the same Agility-and-mass calculation through their common defensive base;
final explicit attack metadata remains planned.

## Unified movement and jump model — Functional calculation

- One Agility movement statistic covers ground, swimming, and flight.
- Jump height replaces the redundant separate swim/flight statistic.
- Movement uses Type 4 Agility growth.
- JumpZ uses `100% + Type2Percent(Agility)`: level 0 is 100% and level 100
  is exactly 200% before the shared temporary factors.
- Both apply the same total-mass factor used by evasion.
- Both retain 75% while tired and 25% while breathless.
- A successful jump costs five base air units, adjusted by equipped load.
- The prototype scales GZDoom's vertical launch velocity, not geometric height:
  `JumpZ = 8 × EffectiveJumpPercent / 100`. Effective jump percent is
  `100 + Agility Type 2`, multiplied by mass, air, survival, and health factors.
  Under constant gravity, approximate geometric height varies with `JumpZ²`;
  therefore 200% JumpZ at Agility 100 gives approximately 400% base height.

The calculations now change GZDoom's physical forward, backward, sideways,
swimming, and flight movement. They also change physical jump height through
`JumpZ`. A successful grounded jump now spends air once when the character
begins rising. The jump-cost test control remains available as a development
aid, but is no longer required for ordinary jumping.

## How to test version 0.63.0

1. Replace the previous project folder with version 0.63.0.
2. Double-click `run_dev.bat`.
3. Open GZDoom's Customize Controls menu.
4. Assign keys to the attribute panel, both mass-test controls, and both
   air-test controls.
5. Open the panel and add equipment weight.
6. Compare the load percentage with the displayed air-use multiplier.
7. Press the air-consumption control and confirm that current air falls by the
   displayed test-action cost.
8. Add enough weight to exceed 75%; the state must change to overload.
9. Press the air-consumption control again and confirm that the cost is higher.
10. Use the refill control and confirm that current air returns to maximum.
11. Consume air below 50% and confirm that the state changes to tired.
12. Consume air to 10% or less and confirm that it changes to breathless.
13. Stop consuming air and confirm that the value slowly regenerates.
14. Compare effective evasion while normal, tired, and breathless. It should
    respectively equal 100%, 75%, and 25% of the mass-adjusted value.
15. Assign the jump-test control and confirm that it spends five air units at
    zero equipped load.
16. Add equipment weight and confirm that the displayed jump cost increases.
17. Compare movement and jump values across normal, tired, and breathless; both
    should use the same state factor.
18. Walk in several directions and jump while each state is active. Physical
    speed and jump height should follow the effective percentages.
19. Confirm that applied movement and `JumpZ` change with mass and air state.
20. Refill air, note its exact value, and perform one ordinary jump.
21. Confirm that takeoff spends five air at zero equipped load.
22. Hold the jump key and confirm that one takeoff is charged only once.
23. Walk off a ledge and ride a lift; neither action should spend jump air.
24. Add equipment weight and confirm that a real jump spends the displayed
    load-adjusted cost.
25. Refill air, run on the ground for ten seconds, and confirm that about 20
    units are spent at zero equipped load.
26. Walk without running and confirm that no air is spent.
27. Stand still while holding the run key and confirm that no air is spent.
28. Add equipment weight and confirm that the running cost per second rises by
    the displayed load multiplier.
29. Confirm that the panel says running only while grounded movement and the
    active run command occur together.
30. Disable Always Run, move normally, and confirm that walking spends no air.
31. Keep Always Run disabled, hold the run key while moving, and confirm that
    running spends air.
32. Enable Always Run, move normally, and confirm that running spends air.
33. Keep Always Run enabled, hold the run key while moving, and confirm that
    the character walks without spending air.
34. Close the development panel and confirm that the air display remains in the
    lower-left corner.
35. Run and jump, confirming that the HUD updates immediately.
36. Reduce air to 50% and then 10%; confirm that its state and color change.
37. Confirm that the bar becomes shorter as air is spent and grows during
    regeneration.
38. Change the game window size or resolution and confirm that the bar and text
    remain aligned in the lower-left corner.
39. Start a new game and compare the HUD maximum health with `Maximum health`
    in the development panel; both values must match.
40. Let an enemy damage the player and confirm that both the number and red bar
    decrease immediately.
41. Pick up a stimpack or medikit and confirm that normal Doom healing works
    without exceeding the calculated maximum.
42. Save while injured, load that save, and confirm that current health is
    preserved.
43. While injured, change a debug profile so maximum health increases. Confirm
    that current health does not increase for free.
44. Change to a profile with a lower maximum. Current health must remain the
    same unless it exceeds that maximum, in which case it must be clamped.
45. Allow health to reach zero and confirm that GZDoom's ordinary death and
    restart behavior still works.
46. In Customize Controls, assign keys to `DEBUG: consume 10 mana` and
    `Mana test: refill resource` (or their Spanish translations).
47. Press the consume control once and confirm that current mana and the violet
    bar fall by exactly one hundred units.
48. Wait without pressing it and confirm that mana regenerates gradually.
49. Open the development panel and compare its regeneration-per-second value
    with the visible recovery.
50. Press the refill control and confirm that mana returns exactly to maximum.
51. Spend mana, save, load, and confirm that the current amount is preserved.
52. Change to a profile with more Patience while below maximum and confirm that
    maximum and regeneration increase without granting free current mana.
53. Change to a lower maximum and confirm that current mana is only clamped if
    it exceeds the new limit.
54. Switch the game language between English and Spanish and confirm that the
    HUD and both new control names are localized.
55. Assign keys to the two adrenaline test controls in Customize Controls.
56. Begin a new game and confirm that the gold adrenaline bar starts at zero.
57. Press the add control once; adrenaline must rise by ten and the combat
    timer must restart at thirty seconds.
58. Press it again before the timer ends and confirm that the timer restarts.
59. Stop pressing it. Adrenaline must remain unchanged for thirty seconds.
60. When the timer reaches zero, confirm that adrenaline falls by ten points
    per second until reaching zero.
61. Let an enemy inflict real health damage. Confirm a ten-point gain and a new
    thirty-second timer regardless of how much health that single hit removed.
62. Use God mode or another complete engine protection and confirm that an
    impact causing no health loss grants no adrenaline.
63. Gain adrenaline, save, load, and confirm that its value and timer remain.
64. Use the clear control and confirm that both adrenaline and timer reach zero.
65. Assign keys to the two lucidity test controls in Customize Controls.
66. Begin a new game and confirm that lucidity starts at 100 in its cyan bar.
67. Lose ten lucidity once and confirm that the value becomes 90.
68. Wait without using the control and confirm gradual recovery to 100.
69. Reduce lucidity to 50 and confirm the state becomes dizzy and turns gold.
70. Reduce it to 10 and confirm the state becomes stunned and turns red.
71. Cross from 20 to 10 lucidity while moving. Movement and jumping must stop
    for two seconds and the remaining physical-stun time must appear in the HUD.
72. Refill lucidity and confirm that value, state, and color return to normal.
73. Save below a threshold, load, and confirm that the value is preserved.
74. Open the development panel and confirm that Dureza changes the displayed
    lucidity-loss multiplier even though the flat debug loss remains ten.
75. Assign keys to the three survival-loss controls and the shared refill control.
76. Begin a new game and confirm hunger, thirst, and sleep begin at 100%.
77. Use each loss control and confirm only its matching resource falls by ten.
78. Reduce each to 50% and verify hungry/thirsty/sleepy localized states.
79. Reduce each to 10% and verify starving/dehydrated/exhausted states.
80. Confirm no speed, damage, or progressive-health effect is applied yet.
81. Refill all three and confirm their values and states return to normal.
82. Save with different values, load, and confirm all three are preserved.
83. Lower only hunger to 50% and confirm movement and jump retain 75%.
84. Lower hunger to 10% and confirm they retain 50%.
85. Put hunger and thirst at 50%; the survival factor must be x0.5625.
86. Put all three at 10%; the factor must be x0.125.
87. With raw factor x0.50, reach 50% of maximum adrenaline; effective factor
    must become x0.75 even if the actual adrenaline value is not 50 points.
88. Reach 100% adrenaline and confirm the factor becomes x1.00; then let it
    decay and confirm the penalty returns progressively.
89. Refill survival resources and confirm ordinary movement returns.
90. Keep one resource critical and observe slow health loss that bypasses armor
    and does not grant adrenaline.
91. Make two resources critical and confirm the health-loss rate doubles.
92. Confirm survival bar colors retain distinct green, blue, and violet identity
    while mixing toward gold at low and red at critical states.
93. Start a new character and confirm health and mana use the new 1000-point base.
94. Use the mana test control and confirm it spends 100 points.
95. Take damage while all survival resources exceed 10%; health must regenerate
    slowly, with the panel showing the Resilience-derived rate.
96. Observe hunger and thirst decrease in proportion to naturally healed health.
97. Make any survival resource critical and confirm natural healing stops.
98. Confirm one critical resource removes one full maximum over one real hour
    at its unmodified base rate; two or three resources multiply that rate.
99. Note hunger and thirst, spend a measurable amount of air, and let it recover.
100. Confirm that recovering 10% air consumes about 1% hunger and 2% thirst,
    in addition to their ordinary time-based depletion during the same interval.
101. Reduce hunger or thirst close to zero, spend air, and confirm recovery stops
    at the affordable amount without making either survival resource negative.
102. Stay at 10 lucidity after the first two seconds and confirm movement returns
    without the timer restarting continuously.
103. Raise lucidity above 10, cross to 10 again, and confirm a new two-second stun.
104. Save during an active stun, load, and confirm the remaining time continues.
105. Refill lucidity during an active stun and confirm the current two-second
    physical effect finishes instead of being cancelled early.
106. Receive a damaging hit and compare the panel's health-loss percentage with
    the actual loss divided by maximum health.
107. With zero adrenaline and Dureza zero, confirm final pain chance equals ten
    times the displayed health-loss percentage, capped at 100%.
108. Repeat with higher Dureza and confirm the Type 3 multiplier reduces chance.
109. Reach about 50% adrenaline before a hit and confirm it halves the chance
    remaining after Dureza.
110. Reach 100% adrenaline before a hit and confirm pain chance is 0%.
111. When pain triggers, confirm the hit grants 30 adrenaline total: 10 for
    confirmed health loss plus 20 for entering pain state.
112. Use God mode and confirm an impact with zero health loss causes no roll and
    grants no adrenaline.
113. Assign a key to `Pain test: lose 5% maximum health`.
114. Empty adrenaline, use the control once, and confirm the panel reports about
    5% health loss and the Dureza-modified pain chance.
115. At Dureza zero and zero adrenaline, the test chance must be approximately
    50%; any small difference comes only from integer health rounding.
116. Fill adrenaline to about 50% and confirm the same test halves the chance
    remaining after Dureza; at 100%, it must display 0%.
117. Confirm the control bypasses Doom armor, cannot reduce health below one,
    grants 10 adrenaline for its damage, and grants 20 more if pain triggers.
118. Assign a key to `Combat test: localized sword attack` and stand within 64
    units of a provisional Doom monster.
119. With Strength 30, confirm the panel reports 678 calculated sword damage.
120. Attack the monster and confirm the panel reports a hit and positive real
    damage. Adrenaline must rise by three and the combat timer must restart.
121. Attack empty space and confirm the panel reports a miss, grants no
    adrenaline, and does not restart the timer.
122. Enable a protection that prevents all target damage and confirm a reached
    target that receives zero real damage grants no adrenaline.
123. Trigger the physical lucidity stun and confirm the sword test cannot attack
    during its two-second duration.
124. Aim near the top of a monster and confirm a head/critical-point hit, x2.00, and a relative
    height of at least 80% in the panel.
125. Aim centrally between 40% and 80% and confirm torso/sensitive at x1.60.
126. Aim through the outer side of the monster between 30% and 50% and confirm
    arms/weak at x1.30; aim centrally at the same height and confirm sensitive torso.
127. Aim below 30% and confirm legs/neutral at x1.00.
128. Compare actual damage between zones on identical fresh targets, remembering
    that GZDoom reports only the target's remaining health when a hit is lethal.
129. Assign a key to `Evasion test: receive directed attack` and repeat it while
    watching the last chance, roll, and result in the panel.
130. Confirm a roll below the displayed chance reports evaded, causes no health
    loss or pain roll, grants eight adrenaline, and restarts combat time.
131. Confirm a failed roll causes the 1%-maximum-health test hit and then follows
    ordinary armor, pain, and damage-adrenaline behavior.
132. Add equipment weight and confirm the effective chance falls with total mass.
133. Lower air to tired and breathless and confirm chance retains respectively
    75% and 25% of the mass-adjusted value.
134. Take explosion or environmental damage and confirm the panel reports that
    evasion was not applicable and damage proceeds normally.
135. Assign `DEBUG: toggle all attributes at 75`, activate it, and confirm all
    twelve attributes and their derived values update immediately.
136. Repeat the directed-attack test and confirm the much higher Agility-derived
    evasion chance produces frequent successes.
137. Toggle the override off and confirm the original creation values return.
138. Refill air, attack once at zero equipped weight, and confirm exactly five
    air is spent whether the sword hits a target or empty space.
139. Add equipment weight and confirm the displayed and spent sword cost rises
    using the same load multiplier shown elsewhere in the panel.
140. Reduce current air below the complete displayed sword cost and confirm the
    result says insufficient air, no attack occurs, and no partial air is spent.
141. Assign `Health test: cycle healthy/wounded/badly wounded` and use it to
    reach exactly 50% health. Confirm the state changes to wounded, the raw
    health factor is x0.75, and pain/adrenaline intensity is x2 at zero adrenaline.
142. Confirm sword damage, air recovery, movement, evasion, and jump retain 75%.
143. Use the control again to reach 10% and confirm badly wounded, raw x0.25 performance, and
    x4 pain/adrenaline intensity.
144. Raise adrenaline and confirm performance approaches x1 while the added
    pain/adrenaline intensity approaches x1 according to its percentage.
145. Heal or take damage and confirm the health bar transitions continuously
    through green at 100%, gold at 50%, and red at 10%.
146. Assign the six armor-test controls: select slot, cycle type, cycle tier,
    toggle normal/critical, receive 1000 base damage, and repair selected piece.
147. Select each slot and confirm it stores its own type, tier, and durability.
148. Cycle armor type/tier and confirm defense follows exactly 5%/10%/15%,
    10%/20%/30%, 20%/40%/60%, or 30%/60%/90% for every selected body slot.
149. Confirm head/body/hands/feet begin as critical/sensitive/weak/neutral and
    each reinforcement point advances only the selected part by one grade.
150. With a normal hit and no reinforcement, confirm displayed multipliers are
    x2.00, x1.60, x1.30, and x1.00 for those four humanoid regions.
151. Toggle critical mode and confirm those values become x6.00, x4.16, x2.99,
    and x2.00. Reinforced strong/hard/armored grades use x1.44/x0.96/x0.56.
152. Apply a 1000-base-damage hit and confirm defense N absorbs N% after the
    grade multiplier; only the remainder is removed from health and enters pain.
153. Confirm every complete 1000 absorbed damage removes one durability and
    the leftover portion rolls one extra point at 1% per ten damage.
154. Repair the piece and confirm its maximum is base durability times x1/x3/x9.
155. Break a piece and confirm its defense, reinforcement, and attribute bonus
    become inactive until repaired.
156. Assign the panel-page control and confirm the overlay cycles through four
    short pages without covering the whole screen.
157. Assign the heal control, lose health, press it, and confirm current health
    returns to maximum and the state becomes healthy.
158. Kill a hostile monster and confirm the combat page reports enemy kill and
    a base gain of 5, multiplied only by the current health-state gain factor.
159. In cooperative testing, have an ally die within 320 map units and confirm
    each nearby living ally gains 10; repeat outside that range and confirm no gain.
160. Compare wounded/badly-wounded penalties at low and high Patience. Confirm
    Patience reduces harmful performance/pain penalties while x2/x4 adrenaline
    gains remain unchanged.
161. Trigger the pain test until pain succeeds. Confirm movement, jumping,
    running, and the sword test remain disabled for about 0.229 seconds, matching
    DoomPlayer's eight-tic pain animation, then recover automatically.
162. On the combat page, confirm the pain-lock diagnostic counts down from the
    animation duration to zero.
163. Attack a valid monster with the sword and confirm the combat page shows
    physical critical chance, the last roll, and a normal or critical result.
164. Confirm empty-space misses say the critical roll is not applicable.
165. With ordinary attributes, repeat valid hits and confirm only rolls below
    `5% + Type2Percent(Dexterity)` become critical.
166. Enable all attributes at 75 and confirm physical critical chance is about
    61.44%, then verify critical results occur frequently across repeated hits.
167. On an identical region, compare normal and critical localized multipliers:
    head x2.00/x6.00, torso x1.60/x4.16, arms x1.30/x2.99, and legs x1.00/x2.00.
168. Confirm a critical hit still grants only the ordinary three adrenaline for
    dealing melee damage and applies no secondary critical effect.
169. With zero equipment weight and no temporary penalties, compare the debug
    panel's JumpZ scale with `100% + Type2Percent(Agility)`.
170. Set all attributes to 75 and confirm the base JumpZ scale is approximately
    156.44%, while movement continues using its separate Type 4 value.
171. At Agility 100, confirm the base JumpZ scale would be exactly 200% and the
    applied `JumpZ` exactly twice its level-zero value under identical factors.
172. Refill lucidity, select the natural head critical point and use normal hit
    mode. Confirm loss is `25 × (1 − defense%) × Toughness × sleep factor`.
173. With no defense, Toughness zero, and normal sleep, confirm the normal loss
    is 25. With 40% defense, confirm it is 15.
174. Toggle critical mode. Without reinforcement confirm the critical factor is
    x3; with reinforcement to sensitive confirm it falls to x2.6 rather than zero.
175. Confirm armor defense still removes its percentage after that critical factor.
176. Lower sleep to 50% and 10%. At Patience zero, confirm the displayed sleep
    factor and localized lucidity loss use x2 and x4 respectively.
177. Raise Patience and confirm it reduces only the excess sleep debuff above x1.
178. Cross into stunned lucidity at normal, low, and critical sleep. At Patience
    zero, physical stun duration should be 2, 4, and 8 seconds respectively.
179. Confirm every armor defense value in diagnostics includes the `%` symbol.
180. Refill lucidity and confirm the resources page reports accuracy factor x1.
181. Lower lucidity to exactly 50% and confirm the state becomes dizzy, the
    accuracy factor becomes x0.50, and effective physical accuracy halves.
182. While dizzy, confirm the view receives a restrained violet tint plus
    cyan/red edge separation while HUD bars and text remain readable.
183. Repeat sword attacks while clear and dizzy. Confirm the combat page shows
    the latest horizontal/vertical offset and that the possible angular error
    doubles at half accuracy.
184. Confirm becoming dizzy changes neither sword damage nor critical chance.
185. Lower lucidity to 10% and confirm the same x0.50 accuracy factor remains
    while the already-implemented threshold stun activates once.
186. Refill lucidity and confirm the visual distortion disappears immediately,
    accuracy returns to x1, and the sword again uses the clear-state error.
187. Assign `Lucidity test: cycle clear/dizzy/stunned`. Press it once from clear
    and confirm lucidity becomes exactly 50%, distortion appears, and the
    resources page reports physical accuracy with factor x0.50.
188. Press it again and confirm 10% lucidity plus the threshold stun; press a
    third time and confirm immediate restoration to 100% and factor x1.
189. On the compact combat page, perform sword attacks and confirm the lower
    line reports physical accuracy plus the latest horizontal/vertical offset.
190. Refill survival resources and attack an identical target region. Record
    the sword's calculated damage and confirm survival factor x1.
191. Lower exactly one survival resource to 50%. Confirm its low state, survival
    factor x0.75, and sword damage retaining 75% under otherwise equal conditions.
192. Lower a second resource to 50%. Confirm the factor becomes x0.5625 and the
    sword retains 56.25% of its clear-state damage.
193. Lower one resource to 10%. Confirm its critical state produces factor x0.50
    when the other two resources are normal.
194. Add adrenaline and confirm the survival factor and sword damage approach x1
    according to adrenaline percentage; at full adrenaline this penalty vanishes.
195. Combine wounded health x0.75 with one low survival state x0.75 and zero
    adrenaline. Confirm the displayed combined damage factor is x0.5625.
196. Confirm these penalties change neither the sword's critical chance nor the
    vulnerability multiplier selected for the struck region.
197. Refill lucidity, stand still, use the sword, and confirm its movement
    accuracy factor is x1.00.
198. Walk without the effective run command and attack; the factor must remain
    x1.00.
199. Attack while moving with the effective run command. The factor must become
    x0.25 and the reported physical accuracy must be one quarter of its
    post-lucidity value.
200. Become dizzy and attack while running. Confirm lucidity x0.50 and running
    x0.25 combine to retain 12.5% of attribute-derived physical accuracy.
201. Compare repeated sword attempts while standing and running. Running must
    widen the reported horizontal and vertical offsets without changing damage,
    critical chance, or the selected vulnerability formula.
202. Bind `Combat test: spawn training dummy`, stand in open space, and invoke
    it. Confirm the original target appears 128 map units ahead facing you.
203. Strike it repeatedly and confirm it neither walks nor moves from damage.
204. Confirm it survives ordinary repeated testing because it begins with
    1,000,000 health and still receives real reported damage.
205. Stand normally and confirm crouching factors report x1 for accuracy,
    critical chance, and stealth.
206. Crouch and confirm all three factors report x2. The sword's displayed
    physical accuracy and critical chance must double, with chance capped at 100%.
207. While crouched and dizzy, confirm the lucidity x0.50 and crouch x2 accuracy
    factors cancel, returning to the attribute-derived physical accuracy.
208. Lower only hunger, thirst, or sleep to 50% or less without attacking.
    Confirm `Sword calculated damage` immediately reflects the current survival
    factor; it must no longer wait for a successful target hit.
209. Miss with the sword while a survival penalty is active. Confirm the
    calculated-damage line stays reduced and does not reset to unpenalized base.
210. Spawn the corrected dummy and confirm it is approximately humanoid-sized,
    fully opaque, and has no visible rectangular background.
211. Aim progressively from its feet to its head. Confirm the reported region
    rises through legs, torso/arms, and head across the visible body rather than
    ending near the thighs.
212. Strike the visible knee and confirm it is no longer classified as torso;
    strike the visible head and confirm the trace reaches its critical region.
213. Bind all six shield-test controls and open the compact armor page.
214. Cycle the four shield types at tier 2 and confirm their physical/magical
    defenses are 60/60, 80/80, 90/90, and 50/90 respectively.
215. Cycle tiers and confirm tier 1 subtracts ten percentage points, tier 3
    adds ten, and maximum durability continues to use x1/x3/x9.
216. Toggle blocking and confirm air regeneration pauses and current air falls
    at the displayed per-second cost. Add test equipment weight and confirm the
    cost rises through the existing load multiplier.
217. Select physical damage, enable blocking, and apply a frontal hit. Confirm
    shield absorbed plus passed equals 1000 and absorption never exceeds 1000.
218. Repeat with magical damage. Confirm the magic shield differs at tier 1
    (50% physical, 90% magical) while the other shields use equal values.
219. Confirm every positive block grants five base adrenaline before active
    health-state gain modifiers and restarts the combat timer.
220. Confirm durability loss follows absorbed damage, repair restores maximum,
    and a broken shield disables blocking.
221. Disable blocking and apply the hit. Confirm shield absorption remains zero,
    all 1000 points enter the selected armor region, and shield durability plus
    shield-block adrenaline remain unchanged.
222. Equip a shield below 100% defense and apply a hit. Confirm the shield's
    passed value becomes the armor pipeline's incoming base: regional
    vulnerability resolves next, followed by armor defense and real health loss.
223. Repeat with a 100%-defense tower tier 3. Confirm shield-passed damage is
    zero and armor durability, health, lucidity, and pain remain unchanged.
224. Use a partially absorbing shield against the selected head region. Confirm
    positive post-armor health loss can reduce lucidity and roll pain normally.
225. At Dureza 0, apply an otherwise identical shield/armor hit and record the
    post-defense and final health-damage values; the Dureza factor must be x1.
226. Repeat with higher Dureza. Confirm final health damage equals rounded
    post-defense damage times the displayed Type-3 multiplier, while shield and
    armor absorbed damage—and therefore their durability rolls—stay unchanged.
227. Enable the level-75 attribute override and confirm Dureza retains about
    43.56% of post-armor damage (`1 - 75 × 76 / 10100`).
228. Use a profile with Dureza 100 and confirm the test reaches zero health
    damage after armor without producing pain, damage adrenaline, or lucidity loss.
229. Bind the shield-angle control. At 0°, enable blocking and confirm every
    shield reports the hit as covered.
230. With a rodela or magic shield, test 60° and 70°. Confirm 60° is covered
    but 70° bypasses the shield and enters armor.
231. With a kite shield, confirm 70° is covered and 80° bypasses. With a tower,
    confirm 80° is covered and 90° bypasses.
232. On a bypassed hit, confirm shield absorption and durability loss are zero,
    no shield-block adrenaline is granted, and the complete 1000-point impact
    continues through the selected armor region and Dureza.
233. Continue cycling beyond 180° and confirm the test angle wraps back to 0°.
234. Bind `Magic test: straight staff cast`, spawn the training dummy, and open
    compact page five. Confirm one accepted cast spends exactly 500 mana.
235. Cast at the dummy and confirm calculated damage begins from 120 multiplied
    by Intelligence Type 1, health/survival factors, and the selected location.
236. Press the control repeatedly. Confirm a second cast cannot begin until the
    displayed 18-tic interval (about 0.514 seconds) reaches zero.
237. Lower mana below 500 and attempt a cast. Confirm no mana is spent, no trace
    occurs, no cooldown starts, and the page reports insufficient mana.
238. Compare clear and dizzy lucidity. Confirm magical accuracy halves while
    dizzy and the reported horizontal/vertical offsets widen.
239. Crouch and confirm magical accuracy and critical chance double, with the
    latter capped at 100%.
240. Repeat attacks and confirm staff critical chance is `8% + Insight Type 2`
    before crouching, and critical hits only increase localized damage.
241. Confirm a positive real staff hit grants two adrenaline and restarts the
    combat timer; a miss or fully prevented hit grants neither.
242. Lower hunger, thirst, sleep, or health and confirm calculated staff damage
    uses the same effective offensive-damage multiplier as the sword.
243. Spend health, mana, and air, then press `Resource test: restore health,
    mana, and air`. Confirm all three return to their current maximums.
244. Bind `Combat test: spawn Argento` and invoke it in an open space. Confirm
    Argento appears in front of the player, turns through eight directions,
    pursues, and attacks in melee.
245. Damage Argento and confirm he has substantially starting-character-scale
    health rather than the training dummy's one million points.
246. Let Argento attack an unarmored fresh character and confirm each connected
    melee hit begins from 372 damage before the player's later mitigation.
247. Kill Argento and confirm he dies and grants the existing five base
    adrenaline for killing a hostile enemy.
248. Bind `Combat test: spawn Caella` and invoke it in an open space. Confirm
    her eight directional views, pursuit, melee pose, pain response, and death.
249. Compare Caella with Argento and confirm they share the same 3100 health,
    372 base melee damage, physical size, speed, mass, and hostile behavior.
250. Open compact debug page 3/5, spawn Argento or Caella, and strike the
    enemy. Confirm the bottom four lines identify the actor and report health,
    actor adrenaline, anatomy, Dureza mitigation, evasion, lost-health
    percentage, and pain chance.
251. Repeat directed sword or staff attacks. Confirm an occasional actor
    evasion reports `evaded`, causes zero health loss, and adds eight base
    adrenaline to that actor.
252. Land a damaging hit and confirm actor adrenaline gains ten base points;
    when pain triggers, confirm the same event also adds twenty base points.
253. Reduce the actor below 50% and then 10% health. Confirm the diagnostics
    show larger pain probability and x2/x4 adrenaline gains respectively.
254. Stop attacking for thirty seconds and confirm the actor's adrenaline then
    falls at ten points per second.
255. Spawn Argento and Caella separately. Confirm that pursuit alternates a
    stride frame with the standing frame in all eight viewing directions.
256. Stand beyond melee range with a clear line of sight. Confirm Argento uses
    the blue cast pose and bolt, while Caella uses the violet equivalents.
257. Let one bolt hit a fresh target and confirm it begins from 138 magical
    damage before the receiver's defenses and adds no secondary status.
258. Trigger pain on either actor and confirm the distinct hurt pose lasts the
    complete eight-tic pain interval instead of reverting immediately to idle.
259. Kill each actor from several viewing directions. Confirm the hurt
    transition ends in a persistent direction-aware corpse that no longer
    blocks movement.
260. Strike head, central torso, outer hand/arm band, and legs. On compact page
    3/5 confirm the anatomy line respectively reports critical, sensitive,
    weak, and neutral with the expected relative height/lateral coordinates.
261. Repeat the same sword and staff impacts and confirm location damage has not
    doubled: the profile selects the same single multiplier previously shown.
262. Bind and use `Combat test: spawn Rulo`. Confirm his bear-warrior body is
    wider and taller than Argento, all eight views remain inside the hitbox,
    and his slower pursuit uses the authored stride.
263. Let Rulo reach melee range and confirm his axe begins from 372 damage. Move
    away and confirm he can throw an axe at speed 20 for the same 372 base
    physical damage without secondary effects.
264. Damage and kill Rulo from several angles. Confirm the eight-tic hurt pose,
    directional corpse, shared pain/evasion/adrenaline diagnostics, and five
    adrenaline enemy-kill reward.
265. Bind and use `Combat test: spawn Ronnie`. Confirm his Caelith body remains
    72 units tall, is narrower than the humans, and pursues faster than them.
266. Let Ronnie use his sword and confirm 138 base melee damage. At distance,
    confirm his authored golden projectile travels at speed 28 and begins from
    372 magical damage without secondary effects.
267. Damage and kill Ronnie from several angles. Confirm all six directional
    state groups, shared anatomy/defensive mechanics, and enemy-kill reward.
268. On compact page 3/5, strike each of Argento, Caella, Rulo, and Ronnie in
    turn. Confirm the displayed name changes correctly and never falls back to
    Argento for the two new actors.
269. Spawn Argento or Caella and strike head, body, hands, and feet. Confirm
    compact page 3/5 reports the corresponding armor slot with 10% defense.
270. Repeat with Ronnie and confirm the same light tier-1 defense. Repeat with
    Rulo and confirm every region has heavy tier-1 defense of 30%.
271. Compare natural and effective vulnerability on page 3/5. Light armor must
    reinforce head/body by one grade; Rulo's heavy armor reinforces every
    region by three grades, capped at armored.
272. Land repeated high-damage hits on one region and confirm only that piece's
    durability falls: one point per complete 1000 absorbed damage plus the
    displayed remainder chance.
273. Confirm an evaded localized attack causes neither health damage nor armor
    durability loss.
274. Select an armor region, spawn one predefined enemy, and let an ordinary
    melee or projectile attack connect. Confirm compact page 4/5 shows the
    complete shield/armor calculation without pressing either diagnostic-hit
    control.
275. Block while facing the enemy and confirm the shield uses its physical or
    magical defense, loses durability from absorbed damage, and grants the
    existing block adrenaline. Confirm being hit adds no air cost beyond the
    continuous weight-based drain.
276. Keep blocking and turn until the enemy is outside the shield's real
    coverage arc. Confirm shield absorption and durability loss remain zero and
    the attack continues through the selected armor region.
277. Force a successful evasion and confirm neither shield nor armor loses
    durability. Repeat while invulnerable and confirm no custom equipment wear
    or block reward occurs.
278. Receive explosion or survival damage and confirm it retains the previous
    native route and does not change shield or armor durability.
279. Spawn any predefined actor and strike its naturally critical head with
    normal sword or staff hits. On compact page 3/5 confirm lucidity decreases
    from 100 by the displayed defense- and Toughness-mitigated amount.
280. Repeat on body, hands, and feet. Confirm health can fall but actor lucidity
    remains unchanged because those regions are not naturally critical.
281. Enable critical attacks and hit the head. Confirm the displayed lucidity
    loss is larger according to the effective vulnerability after the helmet's
    reinforcement; removing natural critical eligibility is never part of the
    calculation.
282. Reduce actor lucidity to 50% or less. Confirm the panel reports Mareado,
    x0.50 accuracy, and that roughly half of later melee and ranged executions
    miss while lucidity recovers.
283. Cross from above 10% to 10% or less. Confirm the actor stops pursuing and
    cannot execute attacks for two seconds, then resumes even if still marked
    Aturdido.
284. Keep lucidity at or below 10% and confirm the timer does not restart.
    Allow it to recover above 10%, cross again, and confirm a new two-second
    immobilization.
285. Damage one predefined actor so it becomes the last inspected actor, then
    open compact page 6/6. Confirm its name, base/current speed, health factor,
    evasion, attributes, accuracy, and critical chances are visible without
    exceeding the right edge of the panel.
286. Bind `Prueba de actor: alternar saludable/herido/malherido`. Cycle the
    inspected actor to 50% and 10% health. Confirm actual pursuit speed and
    melee/projectile damage follow the displayed Patience- and
    adrenaline-adjusted health factor.
287. Give the wounded actor adrenaline through ordinary combat. Confirm its
    speed and damage approach their healthy values progressively while pain
    intensity falls; earned adrenaline still keeps its x2/x4 multiplier.
288. Bind `Prueba de actor: alternar lúcido/mareado/aturdido`. At Mareado,
    confirm page 6/6 multiplies the actor's own physical or magical accuracy by
    x0.50 rather than replacing every actor with one fixed chance.
289. Enter Aturdido and confirm horizontal movement and offensive executions
    stop for two seconds. Confirm the attack diagnostic shows a failed
    zero-chance attempt if an execution was already scheduled by the AI.
290. Let each actor attack repeatedly and inspect its last base/final damage,
    accuracy roll, and critical roll. A missed attack must not roll a critical.
291. Select the player's head armor region and let an actor land a critical.
    Confirm page 4/6 labels the real hit critical and applies the reinforced
    head critical multiplier, percentage defense, Dureza, health, durability,
    and localized lucidity loss in that order.
292. Repeat with a body, hands, or feet region. Confirm critical damage still
    increases according to that region but lucidity is lost only when the
    region is naturally critical.
293. Block a critical projectile with a shield. Confirm the shield absorbs its
    normal pre-region share first, then only the remaining damage enters the
    critical armor-region calculation. No extra status or hit-based air cost
    may appear.
294. Launch overlapping actor projectiles if practical. Confirm each projectile
    retains its own critical result and a normal missile never reuses the
    critical result of a previous melee or projectile attack.

Because weight is added in five-unit steps and carry capacity varies with
Strength, the test may not land on every reference percentage exactly.

## Major systems still planned

- Remaining player resources and the complete final HUD design.
- Final equipment UI, inventory, and magical box integration for the armor model.
- Air consumption connected to additional real player actions beyond running,
  jumping, the sword test, and debug shield blocking.
- Remaining combat stages: final player anatomy volumes, remaining weapons,
  production shield input/equipment/vertical coverage, final actor aim cones,
  animation, and staff projectile/element effects.
- Tarot progression and Trucazo.
- Crafting, missions, factions, travel, sieges, and final campaign maps.

## Documentation rule from this version onward

Every delivered programming version must update both files:

- `CHANGELOG.md`: short list of changes by version.
- `IMPLEMENTATION_STATUS.md`: beginner-friendly description of the current
  working prototype, its test procedure, and its remaining limitations.
