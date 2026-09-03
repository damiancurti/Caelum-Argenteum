# Version 5 Thermal Exposure and Thermoregulation

**Status:** Author-approved design; implementation and numeric balance pending.

**Scheduled target:** V5.1.0, after the V4.35 calendar/weather provider and
the V5.0.0 modular-source transition are stable.

## 1. Design goal

The player experiences heat and cold from the combined effect of climate,
location, physical activity, wetness, wind, equipment and temporary food or
drink effects. The system models accumulated thermal exposure rather than
turning a single instantaneous temperature reading directly into penalties.

GZDoom does not provide a complete native thermoregulation system. Caelum will
implement it in ZScript on top of native actor, sector, inventory, persistence
and HUD facilities.

## 2. Authoritative data flow

```text
game clock/calendar/season
    -> weather snapshot
    -> tagged environmental zone
    -> player thermal inputs
    -> accumulated exposure state
    -> survival/combat modifiers and HUD feedback
```

The weather module owns ambient temperature, wind, precipitation and humidity.
The thermal module consumes one immutable snapshot and must not duplicate or
mutate weather state.

## 3. Approved thermal inputs

- Ambient temperature from the active weather and location/biome.
- Tagged map-zone modifiers for interior, exterior, underground, shade,
  shelter, water and authored heat sources.
- Physical heat derived from real Air expenditure, including movement,
  running, jumping, combat and carried load; raw key presses are not a heat
  source by themselves.
- Wind-driven heat loss, reduced by shelter and intensified by wetness.
- Persistent player wetness in the range 0–100, with authored wetting and
  drying rates.
- Equipment insulation, ventilation and waterproofing, aggregated from the
  exact equipped item instances.
- Equipment condition: deterioration reduces authored insulation and/or
  waterproofing, while repair restores those properties with the item.
- Temporary warming or cooling effects from food and drink.
- Elemental environmental influences: Fire warms and dries, Water wets and
  cools, Ice applies intense cooling, and Air accelerates evaporation and wind
  chill. Quintaessence and other elements receive no thermal rule until
  separately authored.

Tagged sectors or explicit environmental volumes are authoritative for indoor
and sheltered spaces. Sky checks and geometry traces may be secondary hints,
but are not sufficient on their own in maps with balconies and 3D floors.

## 4. Comfort range and Resilience

The character has an author-defined comfort centre and a base tolerance band
measured in degrees. **Resilience** widens this comfortable band. Toughness
remains a physical damage/resistance attribute and does not duplicate the
general environmental-tolerance role.

A conceptual model is:

```text
perceived temperature = ambient temperature
                      + zone and heat-source effects
                      + physical-activity heat
                      + consumable effect
                      + equipment net effect
                      - wind/wetness heat loss

thermal excess = max(0, abs(perceived - comfort centre) - tolerance band)
```

This is an architectural contract, not the final balance formula. Exact curves
and values remain author-controlled.

## 5. Exposure state

Thermal excess accumulates over time. Recovery also takes time, and hysteresis
prevents rapid state changes around a threshold. The planned state ladder is:

1. Comfortable.
2. Mild heat or cold.
3. Intense heat or cold.
4. Extreme heat or cold.

State thresholds, accumulation rates and recovery rates are pending numeric
design. Briefly crossing a doorway or heat boundary must not immediately
apply or remove the full condition.

## 6. Approved consequences

### Heat

- Increased Thirst loss.
- Lucidity loss.
- Reduced Air regeneration.

### Cold

- Increased Hunger loss.
- Anima loss.
- Increased Health loss when the character is damaged.

Hunger and Thirst effects modify their authoritative existing rates rather
than creating independent duplicate drains. The cold damage modifier requires
an explicit ordering and cap so it cannot multiply uncontrollably with armor,
localized anatomy, critical hits or vulnerability tiers.

## 7. Equipment and consumables

Thermal properties belong to exact formal-inventory item instances and are
aggregated only when equipped. Insulation can protect against cold while poor
ventilation can worsen heat; waterproofing reduces wetting but does not erase
existing wetness. Consumables modify the character temporarily and never
rewrite the ambient weather temperature.

## 8. Persistence and HUD

- Thermal exposure, wetness and active consumable effects persist in saves and
  across map travel.
- Ambient conditions are recalculated from the current world and zone after
  loading.
- The normal HUD shows thermal information only outside the comfortable band.
- A debug view exposes ambient temperature, perceived temperature, comfort
  band, Resilience contribution, wetness, exposure state and a per-factor
  breakdown.

## 9. Performance and scope

The initial implementation affects the player only and updates at a bounded
low frequency, initially once per second unless testing proves another cadence
necessary. It must never perform a global actor search each tick.

If thermal simulation later affects followers, monsters or large crowds, they
will use simplified species profiles and staggered scheduler updates rather
than running the complete player calculation simultaneously.

## 10. Required test support

Development controls must be able to set ambient temperature, wind, wetness,
activity heat and each exposure severity independently. Acceptance covers
doorway hysteresis, rain and immersion, wet clothing, wind shelter, heavy
activity, equipment swaps, consumables, save/load and map travel.

## 11. Numeric decisions deliberately deferred

- Comfort centre and base tolerance in degrees.
- Resilience-to-tolerance curve.
- State thresholds and exposure/recovery rates.
- Heat and cold drain multipliers and maximum penalties.
- Cold damage ordering and cap.
- Equipment thermal values and coverage rules.
- Durability-to-thermal-protection curves.
- Consumable strength and duration.
- Wetting, drying, shelter and heat-source values.
- Acclimatization rate, cap, decay and whether heat/cold adaptation use one
  signed axis or two constrained values.
- Species/racial comfort, tolerance and adaptation profiles.
- Rest-efficiency and interruption curves under thermal stress.
- Elemental temperature, wetting, drying and lifetime values.

## 12. Approved systemic extensions

### Sweat and delayed cooling

Heavy activity and poorly ventilated equipment can produce sweat, increasing
the same authoritative 0–100 wetness value used by rain and immersion. Sweat
must not create a second independent Thirst drain: its hydration consequence
is represented by the approved heat/Thirst modifier. Wet clothing can create
a delayed cold risk after the player stops moving or enters wind.

### Refuge, property and rest

Camps, owned houses, mines, inns, churches, taverns and other authored
properties can expose shelter, heating and drying quality. This gives property
ownership a survival function in addition to production and resource income.
Thermal comfort modifies rest quality and recovery; the exact penalties,
benefits and interruption rules remain numeric design gates.

### Gradual acclimatization

Sustained time in a climate slowly produces a bounded, persistent adaptation.
It changes gradually across the calendar so normal seasonal transitions do
not remain permanently punitive. It cannot replace Resilience or eliminate
extreme-weather danger, and it cannot reverse immediately when weather changes.

### Species and race profiles

Species and races define data-driven base comfort, tolerance and adaptation
factors appropriate to their biology. The player profile participates in the
complete system; future NPC profiles use the simplified staggered simulation
described above.

### Elemental interactions

Fire, Water, Ice and Air effects feed the same environmental-influence API as
weather and map heat sources. They must never alter the global weather record.
Their influence may belong to an actor, temporary area or tagged volume and
expires with that authoritative source.

### Equipment condition

Thermal protection derives from material, construction, coverage and current
durability of each exact equipped item. Deterioration may reduce insulation or
waterproofing according to authored curves; repair restores the corresponding
protection. Damage does not gain an arbitrary ventilation bonus unless a later
equipment rule explicitly defines one.

## 13. Extension still pending author approval

Persistent medical conditions from extreme exposure, including hypothermia,
frost injury, heat exhaustion and heat stroke, remain unapproved and outside
the implementation contract.
