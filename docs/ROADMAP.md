# Caelum Argenteum — Implementation Roadmap

This roadmap supersedes the old V4.22–V4.26 sequence. It preserves the original dependency logic, but reconciles it with the systems that are already implemented or partially implemented in the current codebase.

The private design documentation supplied by Damian Curti remains authoritative for lore, balance values and unresolved mechanics. A roadmap entry does not authorize arbitrary design values.

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
| `Reload` | Ranged-weapon reload only. |
| `Zoom` | Contextual action: persistent shield Block for compatible weapons; real ADS/FOV zoom for ranged weapons. |
| `User1` | Racial ability. |
| `User2` | Seal Channel mode. |
| `User3` | Active Tarot card activation. |
| `User4` | Class ability. |

The current implementation uses native Zoom contextually. It enters persistent Block only when the active weapon supports one-handed shield rules; ranged weapons instead enter Aim and apply a real FOV zoom. Ranged AltFire remains an alternate Aim path. Independent magazines, Reload and the magazine/reserve HUD are implemented. These foundations require broader manual validation. Channel remains pending; User3 and User4 are connected reservation hooks without finished Tarot/class mechanics.

User1 is the remaining native User input and is reserved for the racial ability. Its gameplay behavior remains pending the authored race-by-race designs; no arbitrary effects or values may be introduced.

## 3. Ordered major patches

### V4.27 — Combat Input Completion and Validation

- Preserve Fire and AltFire weapon behavior.
- Preserve contextual Zoom: shield Block only for compatible weapons and ADS/FOV zoom for ranged weapons.
- Preserve ranged Aim on AltFire as an alternate input and ranged magazines on Reload.
- Connect User1 to the racial-ability service hook without inventing race effects.
- Connect Seal Channel to User2 without replacing ranged Reload.
- Keep User3 and User4 connected to explicit Tarot and class-ability interfaces.
- Validate Block compatibility, ranged visual ADS, magazine HUD, ranged Reload and every reserved User input across every weapon family.

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

- Promote `CaelumCombatActor` into the complete non-survival NPC stat archetype by adding Constitution, Charisma, Empathy, Eloquence and Anima; preserve Hunger, Thirst, Sleep, Carry Load and Air as player-only systems.
- Define authored values for those missing fields per NPC instead of deriving or silently defaulting their personalities.
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

The validated reusable template is now named **`habitación con puerta trampa`** / **trap-door room**. Its definitive 4.26.5p configuration includes the corrected solid sight-blocking jamb frame, finite retracting panel, continuous traversable roof and clear upper access boundaries. All eight MAP01 rooms use it, including the silver-key NPC variant. Future level work should instantiate or rotate this pattern instead of recreating wall, roof, jamb and door topology independently.
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

## 4. Parallel validation tracks

These tracks continue without displacing the ordered major patches:

1. **Architecture:** MAP01 must load, the template door must open/close, stairs must be climbable and the 136-MU platform must be walkable before replication.
2. **Impact physics:** validate actor, wall and floor impacts; Toughness; localized armor/anatomy response; buckler/crouch damping; contact rearm; and the mass-10000 convergence test.
3. **Combat controls:** the existing Zoom/Block, ranged AltFire Aim and ranged Reload behavior remains subject to V4.27 completion and full weapon-family testing.
4. **Release independence:** Doom assets may remain temporary test dependencies but cannot become final standalone-game dependencies.

## 5. Deferred design gates

- Concrete class abilities require authored class-by-class definitions.
- Concrete racial abilities require authored race-by-race definitions and use User1.
- Melee physics remains deferred until swing velocity, effective striking mass, contact area/edge geometry, material penetration, sharpness and technique are designed.
- Full economy balance, quest content, factions, calendar data and Tarot card values remain author-controlled.
