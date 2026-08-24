# Caelum Argenteum — Implementation Roadmap

This roadmap supersedes the old V4.22–V4.26 sequence. It preserves the original dependency logic, but reconciles it with the systems that are already implemented or partially implemented in the current codebase.

The private design documentation supplied by Damian Curti remains authoritative for lore, balance values and unresolved mechanics. A roadmap entry does not authorize arbitrary design values.

The MAP01 level-construction prototype now also preserves a reusable architectural baseline: finite walkable roofs, aligned six-step access, independent 119×119-MU square top landings, the `habitación con 1 puerta trampa` mechanism and terrace rows partitioned into three connected rooms. These map iterations validate construction techniques and do not replace the ordered gameplay patches below.

The next architectural block is the first mansion floor: eight smaller rooms distributed across the six validated lateral support volumes. In each north/south row, the two outer supports carry one room each and the central support carries two, producing the approved `1 | 2 | 1` distribution and eight rooms total. Every room has two trap doors and a walkable setback/balcony; the existing staircase-gap width is the balcony reference. Descending panels terminate inside the closed lower volumes rather than occupied ground-floor rooms. The wider remaining terrace areas are reserved for later staircases. Construction begins in the patch after V4.27.0q, while the validated ground-floor geometry remains frozen as the regression baseline.

## 1. Reconciliation with the old roadmap

| Old block | Current status | Remaining work |
| --- | --- | --- |
| V4.22 — Crafting Stations & Crafting Core | Partially implemented | The shared station/transaction foundation exists. Forge and Ranged Weapon Workshop support current physical recipes; Workbench and the wider station network exist in partial form. Complete station filters, infrastructure requirements and the missing Armor/Essence/Workbench workflows. |
| V4.23 — Recipe Book & Crafting Persistence | Partially implemented | The recipe catalogue and unified crafting interface exist, but permanent recipe knowledge and unlock sources are not complete. Add persistent unlocks from sheets, merchants, NPCs and discovery, without level restrictions. |
| V4.24 — Repair, Disassembly & Durability Loop | Partially implemented | Durability, several repairs and material recovery foundations exist. Complete the authoritative craft → use → deteriorate → repair/disassemble loop, preserving tier and essence/base-item recovery choices. |
| V4.25 — Loot, Materials & Economy Foundation | Partially implemented | Material actors and many pickups exist. Add systematic loot tables, containers, formal basic-material sources and transaction-ready buy/sell data. Replace remaining copyrighted development placeholders before release. |
| V4.26 — NPC Interaction, Quests and Factions | Not implemented as a complete system | Build interaction and dialogue first, then merchants, quests, reputation and factions. Do not begin large social content before the shared infrastructure is stable. |

## 2. Authoritative combat input contract

The target combat layout is:

| Input | Target function |
| --- | --- |
| `Fire` | Weapon primary attack. |
| `AltFire` | Weapon-specific secondary attack; ranged weapons retain it as an alternate Aim input. |
| `Reload` | Ranged magazine reload; melee/magic next-attack charge. |
| `Zoom` | Contextual action: persistent shield Block for compatible weapons; real ADS/FOV zoom for ranged weapons. |
| `User1` | Racial ability. |
| `User2` | Seal Channel mode. |
| `User3` | Active Tarot card activation. |
| `User4` | Class ability. |

The current implementation uses native Zoom contextually. It enters persistent Block only when the active weapon supports one-handed shield rules; ranged weapons instead enter Aim and apply a real FOV zoom. Ranged AltFire remains an alternate Aim path. Independent magazines and the magazine/reserve HUD are implemented. Reload preserves ranged magazine behavior and charges the next melee/magical attack, including movement slowdown, interruption and empowered cost/damage/area rules. User1–User4 are connected to explicit racial, Seal Channel, Tarot and class reservation hooks across every weapon family. Their authored gameplay effects remain pending.

User1 is the remaining native User input and is reserved for the racial ability. Its gameplay behavior remains pending the authored race-by-race designs; no arbitrary effects or values may be introduced.

## 3. Ordered major patches

### V4.27 — Combat Input Completion and Validation

**Implementation substantially complete; validation gate remains open.** Native User1–User4 routing, contextual Reload/charge, ranged ADS, shield/Giant-Gauntlets Block and the charged Block dash are implemented. The author has confirmed Reload/charge, ranged Zoom, magic-weapon Block, charged shield impulse, Giant Gauntlets uppercut, charged double cost/damage and automatic empty-magazine Reload. The remaining validation gate is listed below.

- Preserve Fire and AltFire weapon behavior.
- Preserve contextual Zoom: shield Block only for compatible weapons and ADS/FOV zoom for ranged weapons.
- Preserve ranged Aim on AltFire as an alternate input and ranged magazines on Reload.
- Validate the melee/magic charged Reload window, speed scaling, Pain/switch cancellation and doubled next-attack cost/damage/area.
- Connect User1 to the racial-ability service hook without inventing race effects.
- Connect Seal Channel to User2 without replacing ranged Reload.
- Keep User3 and User4 connected to explicit Tarot and class-ability interfaces.
- Validate Block compatibility, ranged visual ADS, magazine HUD, ranged Reload and every reserved User input across every weapon family.

Pain cancellation of active Block, active charge and the stored charged window is manually confirmed. Giant Gauntlets weapon-based Block, the charged magical `sqrt(2)` radius increase and the visible HUD acknowledgement for User1–User4 are also confirmed. The bull horn contract is now authored as a physical Charge-only attack: no direct melee damage or melee knockback remains. Before closing V4.27, manually confirm the complete Fire/AltFire/Zoom/Reload/User1–User4 routing matrix across every weapon family, the corrected gate platform contour and the bull's single-contact Charge result. User1–User4 currently acknowledge successful routing only; final racial, Seal, Tarot and class effects belong to their authored content patches. Exhaustive crafting validation belongs to V4.29 and is not a V4.27 blocker.

V4.27.0u narrows that gate to a final smoke test rather than another implementation block: traverse the corrected two-square rear passages, verify the attribute-derived bull Health/speeds/Air/mass and single-contact Charge, then sample the complete input contract on representative melee, ranged and magical weapons. If those checks pass, development advances to V4.28.

The second passage squares from V4.27.0u are rejected and removed in V4.27.0v because they altered rear-room wall rendering. Bull and NPC validation gates are confirmed. The only remaining closure gates are the restored rear-room architecture check and the authoritative matrix in `WEAPON_INPUT_MATRIX.md`.

### V4.28 — Seal Channeling and Active-Ability Hooks

- Complete Seal selection/equipment state.
- Implement interruptible Channel timing and Anima-per-second consumption through User2.
- Store one empowered next attack and apply the seal element through the existing damage/element systems.
- Distinguish physical-weapon elemental augmentation from same-element magical amplification.
- Add stable Tarot, class-ability and racial-ability service interfaces; content values remain design-controlled.

### V4.29 — Crafting Completion and Persistent Recipe Book

- Complete the shared interface for Forge, Ranged Weapon Workshop, Armor Workshop, Essence Altar and Workbench.
- Preserve the expanded station-network requirements already documented for higher tiers.
- Complete recipe filtering instead of creating five independent crafting systems.
- Add permanent recipe knowledge and save/load persistence.
- Support unlock sources from found sheets, merchants, NPCs and discovery, without level restrictions.

### V4.30 — Repair, Disassembly and Durability Loop

- Close the craft → use → deteriorate → repair/disassemble → recover-materials loop.
- Preserve item tier during authorized recovery.
- Implement the authored essence-weapon choice between recovering the essence or the base implement.
- Audit armor, shields, physical weapons, ranged weapons and essence weapons under one transaction model.

### V4.31 — Loot, Materials and Economy Foundation

- Add systematic material loot tables and container actors.
- Formalize basic wood and iron-ingot acquisition.
- Add transaction-ready item values and buy/sell foundations without prematurely balancing a complete economy.
- Continue replacing Doom-derived test placeholders with original or license-compatible assets.

### V4.32 — NPC Interaction, Dialogue and Merchants

- Build dialogue and faction behavior on the complete non-survival NPC stat archetype delivered in V4.26.5q. Constitution, Charisma, Empathy, Eloquence and Anima now coexist with the previous combat fields; Hunger, Thirst, Sleep, Carry Load and Air remain player-only.
- Connect Charisma, Empathy and Eloquence to authored dialogue, disposition and persuasion consequences instead of treating their stored values as passive metadata.
- Add a shared Use-based NPC interaction layer.
- Add data-driven dialogue foundations.
- Add merchant inventories and buy/sell transactions using V4.31 economy data.
- Preserve multiplayer ownership and interaction authority.

### V4.33 — Quests, Reputation and Factions

- Add persistent quest state and objective tracking.
- Add faction membership/standing and reputation changes.
- Prepare Gendarmeria, settlements, caravans and political actors without hard-coding unfinished narrative content.

### V4.34 — Architectural Modules and World/Travel Foundation

- Replicate only the MAP01 architectural template that has passed manual validation.
- Add locked/keyed door variants, roofed rooms and later multi-floor modules.

The validated reusable template is now named **`habitación con puerta trampa`** / **trap-door room**. Its definitive door/roof configuration includes the corrected solid sight-blocking jamb frame, finite retracting panel and continuous traversable roof. V4.26.5r adds a validated 119-MU staircase companion module whose finite lower side faces stop at each tread height. All eight MAP01 rooms use the room template, including the silver-key NPC variant. Future level work should instantiate or rotate these patterns instead of recreating their topology independently.

V4.27.0b restores V4.26.5r as the sole accepted MAP01 baseline. The standalone/integrated main gates, rear terrace connectors and internal terrace divisions from V4.26.5s through V4.27.0a are rejected modules and must not be replicated. Future construction adds one isolated module at a time and requires both static topology checks and manual GZDoom traversal before the next module begins.

Closed-boundary degree validation remains a required check, but it is not sufficient by itself: the V4.27.0a crash demonstrated that a statically closed UDMF structure can still be unsafe for the runtime renderer or 3D-floor system.
- Establish world locations, travel links and caravan/event integration points.

### V4.35 — Calendar, Weather and Dynamic Events

- Expand the existing time scale into the authored calendar.
- Add weather state and environmental modifiers.
- Add travel and world-event scheduling on top of the stable location/faction layer.

### V4.36 — Movable Environment and Physical Hazards

- Integrate movable environmental bodies with Impact Physics Core.
- Add rolling rocks, falling objects and authored hazard surfaces first.
- Prepare avalanches, rams, catapults and moving-sector hazards through `ResolveExternal`.
- Package Impact Physics Core independently only after its Caelum validation track is complete.

### V4.37 — Tarot Activation and TCG Expansion

- Connect User3 to owned/selected active Tarot cards.
- Implement card activation costs, cooldowns and persistence before broad content.
- Expand toward the occasional Tarot-based Truco TCG only after inventory, NPC and world-event dependencies are stable.

## 4. Version 5 transition

### V5.0.0 — Modular Source Architecture

**Scheduled as the first Version 5 patch, after every pending Version 4 block above is completed and validated.**

- Reorganize the source tree into explicit `core`, `character`, `attributes`, `statistics`, `player`, `equipment`, `combat`, `anatomy`, `actors`, `survival`, `crafting`, `tarot`, `dialogue`, `factions`, `world`, `events`, `multiplayer`, `hud` and `debug` modules.
- Reduce `CaelumPlayer.zs` to player-state coordination instead of retaining complete combat, survival, crafting and inventory implementations in one class.
- Move formulas and state machines through incremental compatibility wrappers; do not perform an untestable all-at-once rewrite.
- Preserve one authoritative inventory, player and Tarot implementation. The multiplayer module handles authority, ownership, validation and synchronization rather than duplicating those systems.
- Keep save compatibility and native selector/input behavior across the transition.
- Require parser, single-player, multiplayer and persistence regression tests before removing compatibility wrappers.

## 5. Parallel validation tracks

These tracks continue without displacing the ordered major patches:

1. **Architecture:** MAP01 must load, the template door must open/close, stairs must be climbable and the 136-MU platform must be walkable before replication.
2. **Impact physics:** validate actor, wall and floor impacts; Toughness; localized armor/anatomy response; buckler/crouch damping; contact rearm; and the mass-10000 convergence test.
3. **Combat controls:** the existing Zoom/Block, ranged AltFire Aim and ranged Reload behavior remains subject to V4.27 completion and full weapon-family testing.
4. **Release independence:** Doom assets may remain temporary test dependencies but cannot become final standalone-game dependencies.

## 6. Deferred design gates

- Concrete class abilities require authored class-by-class definitions.
- Concrete racial abilities require authored race-by-race definitions and use User1.
- Melee physics remains deferred until swing velocity, effective striking mass, contact area/edge geometry, material penetration, sharpness and technique are designed.
- Full economy balance, quest content, factions, calendar data and Tarot card values remain author-controlled.
