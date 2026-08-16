# Caelum Argenteum 4.0 — Implementation status

This file describes the current executable prototype. The main design document
remains the authority for rules not yet connected to gameplay.

Status legend:

- **Implemented — pending validation:** compiled into the 4.0 source and ready
  for Damian's GZDoom 4.14.2 test pass.
- **Implemented and previously validated:** retained behavior that had already
  passed manual testing before 4.0.
- **Prepared:** a calculated value exists, but no final gameplay consumer exists.

## 4.0 compatibility repair

**Implemented — pending validation**

- Actor state actions now use explicit `action(actor)` scope, removing the
  incompatible/ambiguous `self` diagnostics from GZDoom 4.14.2.
- Effective actor Dexterity and Insight are cached in play scope. The UI overlay
  reads those fields instead of illegally calling play functions.
- The cascading unknown identifiers reported in actor debug page six are
  consequently removed.

## Character creation 4.0

**Implemented — pending validation**

The former Origin + Identity + Class model is replaced by eight pages:

1. Race.
2. First class.
3. Second class and resulting profession.
4. Sex.
5. Height.
6. Four family points.
7. Thirty individual points.
8. Summary and confirmation.

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

- `Resilience` is renamed `Survival` in source, UI, controls, and current docs.
  All existing air, adrenaline, sleep-loss, and natural-recovery effects remain.
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
physical attack power, prepared physical push, air consumption, hunger loss,
and thirst loss. Equipment remains separate and continues to affect load,
movement, evasion, knockback, and additional air use.

## Armor and equipped mass

**Implemented — pending validation**

Every armor piece now exposes its documented weight. Uniform full-set totals
are 5/7/10 unarmored, 10/15/20 light, 20/30/40 medium, and 40/60/80 heavy for
tiers 1/2/3. Broken pieces retain their weight. Existing shield weights are
included automatically, and debug-added mass is shown separately.

Defense percentages, reinforcement, bonuses, durability loss, and shield
behavior remain **Implemented and previously validated**.

## Predefined hostile characters

**Implemented — pending validation**

The final-value table in the 4.0 specification is authoritative:

| Actor | Profile | Attributes F/T/S/M | Mass / size | Armor | Health |
|---|---|---:|---|---|---:|
| Rulo | Beast Man Warrior, male, tall | 20/18/6/2 | 200 kg / 2.40 m | Heavy | 6200 |
| Ronnie | Caelith Mercenary, male, tall | 20/18/4/4 | 140 kg / 2.00 m | Medium | 4340 |
| Argento | Human Battle Mage, male, tall | 9/7/16/18 | 120 kg / 2.00 m | Light | 1740 |
| Caella | Goblin Cleric, female, tall | 9/7/16/18 | 80 kg / 1.60 m | Unarmored | 1160 |

Physical actor attacks apply body mass; magical attacks do not. Caella owns an
independent profile rather than inheriting Argento's combat setup.

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

## Not yet implemented

- Final buffs, debuffs, healing abilities, and dialogue consumers for the new
  Eloquence range/Labia values.
- A generalized physical-push attack consumer; the multiplier is calculated.
- Save migration from prototype profiles that used Origin/Identity/Class.
- Final production equipment inventory and non-debug character-creation menu.
