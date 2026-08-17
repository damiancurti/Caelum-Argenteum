# Caelum Argenteum 4.0 — Implementation status

This file describes the current executable prototype. The main design document
remains the authority for rules not yet connected to gameplay.

## Compatibility and equipment HUD 4.6.1

**Implemented — pending validation**

GZDoom 4.14.2 does not accept the two `GetMaximumDurabilityFor` signatures as
overloads. The unused two-argument wrappers were removed; every active caller
uses the size-aware three-argument function.

The right-side HUD now includes equipped weight, carry capacity, and percentage
in a dedicated bar. Its fill changes from green to yellow at 50%, orange at the
75% overload threshold, and red at 100% or more.

Removing armor now equips a non-item baseline according to slot: nothing on
head and torso, shirt on hands, and pants on feet. Baseline entries have zero
defense, weight, reinforcement, and durability, are never damaged, and do not
occupy the Magic Box. The existing equippable unarmored set remains separate.

The short bow catalogue entry is replaced by the tier-one carbine. Its prepared
values are 360 damage, 48 tics, 60 m, 30°/200° spread, 0% base critical chance,
-20 air, and size-M weight 24. The final ranged-weapon actor and inventory
consumer remain part of the future complete weapon implementation.

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
physical attack power, physical push, air consumption, hunger loss,
and thirst loss. Equipment remains separate and continues to affect load,
movement, evasion, knockback, and additional air use.

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

Every armor piece now exposes its documented weight. At size M, uniform
full-set totals are 2 unarmored, 8 light, 19 medium, and 35 heavy. Armor tier
does not alter those weights; equipment size does. Broken pieces retain their
weight. Shield and provisional-weapon weights are included automatically, and
debug-added mass is shown separately.

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
unowned previews, equips selected compatible objects, removes armor to
unarmored tier 1, and can fully unequip shields. Every change immediately
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
| Caella | Goblin Cleric, female, tall | 9/7/16/18 | 80 kg / 1.60 m | Unarmored | 1160 |

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
is centralized for weapons; the provisional sword contributes base weight 6.
Armor retains its documented per-piece weights and applies size only.

The compact equipment interface now acts as the first functional Magic Box
view: armor/shield filters, current and maximum slots, size compatibility,
three-decimal item weight, equip/remove, development break, and drop. Pickups
remain on the ground if the box has no free slot. Dropped objects preserve
their current size and durability. The box formula remains
`2 + floor(Type1Percent(Intelligence) / 50)`; Tarot bonuses remain reserved.

Strength carry capacity now uses Type 4. Agility jump scaling is Type 1.

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
5. Compare armor type/tier changes with the armor, shield, debug, and total
   equipped weights shown on character page one.
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
15. Fill the Magic Box, confirm a new pickup remains on the ground, then drop
    and recollect a damaged item and verify size/durability persistence.

## Not yet implemented

- Final buffs, debuffs, healing abilities, and dialogue consumers for the new
  Eloquence range/Labia values.
- Save migration from profiles created with the legacy three-layer format.
- Weapon-family, consumable, material, Tarot, and final visual inventory tabs;
  armor/shield Magic Box capacity, filters, and core item actions are functional.
