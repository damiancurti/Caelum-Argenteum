# Caelum Argenteum — Implementation Roadmap

This roadmap supersedes the old V4.22–V4.26 sequence. It preserves the original dependency logic, but reconciles it with the systems that are already implemented or partially implemented in the current codebase.

The private design documentation supplied by Damian Curti remains authoritative for lore, balance values and unresolved mechanics. A roadmap entry does not authorize arbitrary design values.

The MAP01 level-construction prototype now also preserves a reusable architectural baseline: finite walkable roofs, aligned six-step access, the `habitación con 1 puerta trampa` mechanism and terrace rows partitioned into three connected rooms. These map iterations validate construction techniques and do not replace the ordered gameplay patches below.

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

**Implementation present; complete matrix validation deferred by author decision until V4.29 crafting is complete.** Native User1–User4 routing, contextual Reload and the magic-weapon Zoom latch are implemented. This deferred QA no longer blocks the start of V4.29.

- Preserve Fire and AltFire weapon behavior.
- Preserve contextual Zoom: shield Block only for compatible weapons and ADS/FOV zoom for ranged weapons.
- Preserve ranged Aim on AltFire as an alternate input and ranged magazines on Reload.
- Validate the melee/magic charged Reload window, speed scaling, Pain/switch cancellation and doubled next-attack cost/damage/area.
- Connect User1 to the racial-ability service hook without inventing race effects.
- Connect Seal Channel to User2 without replacing ranged Reload.
- Keep User3 and User4 connected to explicit Tarot and class-ability interfaces.
- Validate Block compatibility, ranged visual ADS, magazine HUD, ranged Reload and every reserved User input across every weapon family.

### V4.28 — Seal Channeling and Active-Ability Hooks

**Functionally validated and closed in V4.28.0bp.** The author validated every current non-weather Seal effect and its corrected equipment binding, mass response and gravity handling. Weather-dependent Seal tier additions remain deferred to Version 5. MAP01 continues as a parallel architectural track and does not block V4.29.

Current acceptance work:

- Validate burn, poison, freeze and both lightning orientations with the new visual sequences.
- Complete the remaining Quintaesencia mass/expulsion tests.
- Confirm Seal HUD state, exact 105/210/315-per-second drain, interruption paths and 60-second cooldown.
- Confirm the debug Adrenaline action adds 100 and reduces Seal cooldown by 10 seconds.
- Validate the rebuilt first-floor floors, roofs, lateral doors and unobstructed stair landing before adding more mansion content.

First-floor construction is now an explicit four-patch gate after the complete build froze beneath the central span:

1. V4.28.0ag: western north/south pair only; verify corridor safety and native 3D floors.
   - V4.28.0ah corrective gate: restore all ground-floor ceiling slabs, exclude the obsolete central connectors and validate inventory stability beside the rat crowd. This does not count as pair 2.
   - V4.28.0ai diagnostic gate: use a stationary twenty-rat subclass for deterministic area-effect testing while retaining the normal pursuing Giant Rat separately. This does not count as pair 2.
   - V4.28.0aj supersedes the stationary workaround: fix the bilateral multi-contact latch and restore all twenty normal active rats. Stress validation remains required before pair 2.
   - V4.28.0ak isolates the active rat crowd and Bull in separate closed barred enclosures. Validate player/rat and player/Bull contacts independently before changing Impact Physics or beginning pair 2.
   - V4.28.0al removes every MAP01 monster, NPC and dummy plus the temporary barred enclosures after `noclip` also froze. Validate architecture alone; if it freezes, compare against a map without the current upper-room pair.
   - V4.28.0am makes the separation permanent during development: MAP01 is architecture-only and MAP02 is the flat actor/AI/combat arena. Consolidate both independently before recombination.
   - V4.28.0ao supersedes the unapplied 4.28.0an package: MAP02 becomes a large six-room field with twenty instances of each non-rat test actor and no initial sight line; sewer assets follow `src/graphics/caelum/textures`.
   - V4.28.0ap restores twenty rats in a seventh isolated room and adds the official title image. The Bull corridor result prioritizes replacement of the one-reference latch with multi-contact/island state before architectural pair 2.
2. Pair 2: add exactly two rooms after pair 1 passes manual GZDoom validation.
3. Pair 3: add exactly two more rooms after pair 2 passes.
4. Pair 4: add the final two rooms and only then validate inter-room connections as a complete wing system.

No later pair may be added while the current pair has a freeze, missing floor, rotated roof, incorrect door axis or stair-landing obstruction.

- Validate equipped-Seal selection, exact Adrenaline drain, interruption, action lock and cooldown in GZDoom 4.14.2.
- Validate Fire, Earth, Air, Water and Quintessence target filtering, damage, control, attraction and mass-scaled release.
- Add final Channel HUD/UX feedback after the mechanical tests establish which diagnostics must remain visible.
- Add stable Tarot, class-ability and racial-ability service interfaces; content values remain design-controlled.
- Defer all weather-dependent Seal-tier extensions to the Version 5 calendar/weather integration.

### V4.29 — Crafting Completion and Persistent Recipe Book

**Authorized to begin after V4.28.0bp.** MAP01 reconstruction continues in
parallel, and the deferred V4.27 combat-input matrix will be revisited after
this crafting block is complete.

V4.29.0a is a parallel physics-diagnostic gate requested before new crafting
content: bounded contact cleanup, real accumulated-pressure damage and eight
controlled MAP02 A/B rooms. It does not reopen the validated V4.28 Seal track,
does not modify MAP01 and does not count as completion of any crafting item
below. Its runtime results determine whether the later collision work needs a
true connected-component island solver or only targeted AI/projectile
optimization.

V4.29.0b applies the first telemetry-directed robustness pass without adding a
connected-component solver. Mass-test NPCs use bounded straight projectiles
without homing or explosion; repeated contact resolves each shared pair at
most once per tic; non-closing callbacks leave before expensive work; and
physics bodies/results are reused. MAP02 adds an equal native/full/pass-through
Quintessence comparison. MAP01 independently closes the visible endpoints of
the four existing central finite panels. These changes do not reopen validated
Seal behavior and do not count as crafting completion.

V4.29.0c replaces the rejected central finite-panel accumulation with two clean
native exterior volumes and one divider per mirrored pair. Its MAP02 gate
replays the former 1,875-AI failure population with the straight-projectile
route, adds active-AI telemetry and physically isolates the three Quintessence
matrices. If 1,875 passes, later diagnostic patches advance through 3,750,
7,500 and 15,000 active AI without mixing stages. This remains a parallel
robustness/architecture gate and does not count as crafting completion.

V4.29.0d canonically compacts MAP01's complete sidedef table after the native
room replacement and restores the required `twosided` flag on every bilateral
line. The PK3 build now rejects orphaned or shared sidedefs, missing front
sides, invalid vertex/sector references and any disagreement between
`sideback` and `twosided`. It changes no MAP02 test stage and does not count as
crafting completion.

V4.29.0e closes the upper slabs of MAP01's six rebuilt doorway sectors and
aligns all door movement with the wall plane. It also moves MAP02 Rooms 7–9 to
three valid Y-separated centers after the former Room-7 X coordinate exceeded
GZDoom's UDMF range. Coordinate-range validation is now part of every PK3
build. The 1,875-AI stage and later 3,750 → 7,500 → 15,000 progression remain
unchanged; this repair does not count as crafting completion.

V4.29.0f supersedes the remaining overlapping slab repair: the central-room
interiors and exterior door bands share one 3D-floor target and the redundant
threshold control is removed. MAP02 gains a spawn sight barrier, a main-field
attack A/B gate and family/projectile lifecycle telemetry so the 1,875-AI stage
can distinguish chase/collision from synchronous combat work. Guided and
explosive projectiles remain excluded from mass NPCs. This robustness and
architecture gate does not count as crafting completion; the next AI stage is
authorized only after the enabled/disabled 1,875 comparison completes.

V4.29.0i extends the accepted seven-phase mass-AI budget to dormant perception
and caches all diagnostic scheduling data once per actor. It also begins the
permanent interface as a transverse V4.29 track: HUD-01 replaces the inherited
Doom status bar/face, Tab opens the shared Journal shell and M retains the
native automap. Inventory and Character expose only existing authoritative
data; World, Crafts, Quests and Reputation receive their final navigation
slots but no fabricated state. MAP01 continues independently with native
divider geometry and rear first-floor doors. These robustness, architecture
and UI foundations do not complete the crafting requirements below.

V4.29.0l responds to the later 1,605-target freeze by separating Look and Chase,
using thirteen coprime Chase phases and enforcing a global 40-update ceiling
per tic. It also restores visible HUD resource colors and clearer Journal word
spacing. MAP01 replaces the isolated first-floor rectangles with two continuous
native rows that preserve the 96-MU balcony setback and every 119-MU stair;
lateral room openings remain the next manual-acceptance gate. This remains a
parallel robustness/architecture/UI increment and does not complete crafting.

V4.29.0m corrects the invalid disabled comparison discovered in the supplied
logs: mass Look, Chase and attack controls become live coordinator state and
Look gains its own 20-call per-tic ceiling. MAP02 stress-only actors use a
lightweight representation so the extreme 16,500-body diagnostic does not
allocate or tick unused full RPG submodels; gameplay NPCs remain complete.
MAP01 moves both continuous façades behind the upper stair landings, producing
an uninterrupted 96-MU corridor while keeping 119-MU flights and closed lateral
divisions. The colored HUD bars are accepted. This remains a robustness/map/UI
acceptance increment and does not complete crafting.

V4.29.0n supersedes the V4.29.0m map and live-CVar conclusions. MAP01 returns
byte-for-byte to the accepted V4.29.0i pre-expansion layout; continuous first-
floor enlargement will be redesigned from that clean boundary. MAP02 server
diagnostic settings are map-load configuration, not live state. The corrected
four-run sequence isolates the abrupt stop to sustained native pursuit with
main-field attacks disabled, so the global Chase ceiling falls from 40 to 20
and repeated hot-path setting synchronization is removed. A stable 20-call
run is required before enabling attacks or beginning squad/formation AI.

V4.29.0o accepts the 20-call diagnostic pursuit ceiling after stable 319-report
and 506-report runs without and with main-field attacks. The next AI gate is a
three-load endurance/reconvergence test at the same ceiling; no higher budget
is required. MAP01 adds four closed 313×153-MU upper blocks to the clean 0i/0n
base. Each preserves a separate 119×119-MU stair landing, existing architecture
and central passage. Their door and room connections await explicit author
direction and must not be inferred from the rejected continuous-row maps.

V4.29.0p records that the first repeated-convergence run at 20 calls stopped
after 119 reports, with zero custom contacts and at most one projectile. Twenty
is therefore rejected as a robust boundary and the next gate uses 10 native
Chase calls per tic. MAP01 again starts from the clean 0i/0n WAD: each central
upper room becomes one continuous T-shaped component containing both new rear
wings, then receives its original middle divider and 64-MU door opening. The
four 119×119-MU stair landings and all accepted side architecture remain fixed.

V4.29.0q accepts the initial 10-call A/B pair after 368 and 548 reports. The
second run follows a MAP02 reload in the same process, completes 40 projectile
lifecycles and reaches greater local density than the failed 20-call run. The
next and final stress gate at this stage is moving-target reconvergence at 10;
after that, mass gameplay AI advances through distance tiers and shared squad
updates instead of raising the per-tic ceiling. MAP01 closes the four obsolete
extreme-room gaps, inserts four 64-MU sliding connections wholly inside shared
walls and preserves the accepted central divider doors and 119-MU landings.

V4.29.0r records that the moving-target run still stops after 193 reports at
the 10-call gate, so no fixed Chase count is considered universally safe. Its
single diagnostic change removes the 13,125 passive visual fillers from the
native blockmap while retaining the same 1,875 active field actors and full
combat. A stable result advances directly to distance-tiered squad perception;
a failed result advances to leader/follower movement isolation. The patch also
adds the two missing central front entrances and integrates the 353 approved
runtime replacements —137 icons and 216 actor frames— without adding previews,
unused future art or Doom-derived assets.

V4.29.0s records that the blockmap-isolated run still stops after 148 reports:
passive spatial residency is not sufficient. MAP02 now performs the first
leader/follower isolation with one native movement leader per configurable
group of 16 and slow phased orientation for followers. This is the bridge to
the planned perception/squad architecture; it does not yet implement shared
formation steering. The same patch removes the four redundant side-door actors
from MAP01, makes the recomposed icon masters authoritative for UI and world
pickups, and adopts Domingo as the player's world appearance.

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

V4.28.0au mirrors the validated central-room topology into the second central pair, explicitly owns the main/options font mappings and presentation logo, and reduces the unchanged MAP02 field to 7,500 actors after the 15,000-actor test saturated the engine. The next patch is reserved for contact-island state, continuous post-contact pushing and the future crushing-damage input; those physics changes must not be mixed into this architectural/UI revision.

V4.28.0at preserves the validated north-central layout, adds a visual reverse face to finite walls, and moves actor validation to one remote mixed population of 15,000 combatants. This is a deliberate ceiling test for bounded projectiles, AI and dense collision; it does not replace the planned contact-island redesign. Typography validation continues with moderately larger bold metrics and HUD contrast shadows.

V4.28.0as corrects the first north-central prototype: two independent exterior doors replace the divider-aligned opening, while the midpoint keeps a separate internal door. The typography validation restarts with fixed baseline cells, reduced HUD metrics and the modern GZDoom font aliases.

V4.28.0ar supersedes the 4.28.0aq central-room shape. The north-central two-room prototype uses one continuous exterior footprint, equal interior areas and one internal dividing wall/door. Once manually approved it will be mirrored south, then the lateral pairs will be connected so each complete wing reads as one exterior architectural volume. The global Caelum font family also enters visual validation at 640×360 and 320×200.

V4.28.0aq introduced the acoustically isolated MAP02 rooms and ten-second NPC-projectile lifetime that passed the later combined stress test. Its four-room MAP01 interpretation is rejected and replaced incrementally by the V4.28.0ar two-room template. These diagnostic containment measures do not complete the planned multi-contact/contact-island physics redesign.

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
