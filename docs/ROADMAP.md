# Caelum Argenteum — Implementation Roadmap

This roadmap supersedes the old V4.22–V4.26 sequence. It preserves the original dependency logic, but reconciles it with the systems that are already implemented or partially implemented in the current codebase.

The private design documentation supplied by Damian Curti remains authoritative for lore, balance values and unresolved mechanics. A roadmap entry does not authorize arbitrary design values.

The MAP01 level-construction prototype now also preserves a reusable architectural baseline: finite walkable roofs, aligned six-step access, the `habitación con 1 puerta trampa` mechanism and terrace rows partitioned into three connected rooms. These map iterations validate construction techniques and do not replace the ordered gameplay patches below.

## 1. Reconciliation with the old roadmap

| Old block | Current status | Remaining work |
| --- | --- | --- |
| V4.22 — Crafting Stations & Crafting Core | Implemented foundation; acceptance pending | All seven current families share the Workbench transaction, cumulative infrastructure requirements and family filters. Complete the permanent Journal interaction layer and the manual station matrix. |
| V4.23 — Recipe Book & Crafting Persistence | Implemented foundation; content pending | Per-recipe knowledge persists with the character and blocks unknown recipes authoritatively. Define new-character starting knowledge and add authored sheets, merchants, NPC and discovery sources without level restrictions. |
| V4.24 — Repair, Disassembly & Durability Loop | Partially implemented | Durability and material-recovery foundations exist. Complete same-station proportional repair and durability-scaled disassembly; elemental equipment returns its corresponding recipe materials rather than an essence/base-implement choice. |
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

V4.29.0t accepts the first leader/follower endurance run after 1,328 complete
reports without a stop, the longest controlled mass-AI result in this series.
The active field uses 126 movement leaders for 1,875 actors and averages 96.6
admitted Chase calls per simulated second while contacts remain zero. Shared
movement ownership, distance tiers and sleeping therefore become the production
direction; restoring independent `A_Chase` for every crowd member is no longer
a target. One group-size-16 repetition and a group-size-8 margin test precede
formation steering. MAP01 restores the four requested side-connection doors
without altering any accepted geometry. The inherited underwater
`Player.AirCapacity` remains separate from Caelum's authoritative action
resource until underwater consumption is explicitly designed.

V4.29.0u accepts both requested margin runs: group 16 completes 1,087 reports
and group 8 completes 995 without a stop, with 16,608 actors, full acquisition,
zero custom contacts and bounded projectiles. Group 16 admits an average 85.8
native Chase calls per simulated second versus 164.7 for group 8, so 16 remains
the mass-AI baseline while formation steering is designed. MAP01 fills and
roofs the complete western entry gap, connects both upper wings with finite
walls, covers all newly enclosed first-floor sectors and preserves an exterior,
uncovered 96-MU eastern balcony. The continuous roof is the base plane for the
second-floor mapping phase.

V4.29.0v closes the diagnostic test gate with the supplied final log. Its
group-16 session contains 1,033 uninterrupted reports, 16,608 actors, full
1,983-actor acquisition, zero custom contact/reference state and a nine-call
per-tic Chase maximum. The separate Quintaessence release peaks at 2,086
affected actors and returns cleanly to zero; the observed frame-rate dip is
brief and does not block acceptance. MAP01 receives the missing independent
two-leaf upper western portón and converts the eight stair joints plus four
landings to complete floor/roof slabs without closing the real stair shafts.
After the focused MAP01 retest, further perception, hierarchy and dynamic-group
work remains planning-only until it receives its own isolated implementation
and validation patch. The next house-construction increment may continue in
parallel under the existing one-variable-at-a-time rule.

V4.29.0w is accepted by the author after the focused MAP01 walk. It closes the
eight actual 96×191-MU stair-side holes, covers the rear landings and supports
the upper western canopy with two solid 8×8-MU columns. No gameplay code or
MAP02 state changed.

V4.29.0x begins the crafting-completion track. The single 61-recipe Workbench
catalogue gains All/Physical/Armor/Essence/Amulet/Seal filters, persistent
per-recipe knowledge and an authoritative unknown-recipe rejection. The Journal
Crafts page reads real known-recipe totals by family. Schema-0 profiles initialize
with all recipes known as a development-compatibility baseline; starting
knowledge for the final new-profile flow remains an author decision. Public `LearnCraftingRecipe` state is
ready for later sheets, merchants, NPC dialogue and discovery hooks, but those
authored sources are not claimed as implemented by this increment.

V4.29.0y appends four shield recipes, bringing the unified catalogue to 65
without changing any existing recipe index. The named plate supplies 70% of
each shield's final weight and the generic strap 30%; all tiers require Forge
and Anvil, while tier 3 also requires the cumulative Master Bench. Recipe-book
schema 2 gives new characters an empty book and preserves the exact 61 knowledge
flags of 4.29.0x saves. A stable physical-weapon unlock method prepares the
MAP01 tutorial choice, but the NPC tasks, dialogue and reward handoff remain
authored content. This increment also upgrades bitmap fonts to physical 2x and
extends the existing roof control across the twelve eastern stair sectors.

V4.29.0z turns the native front door into a character-first flow: New Character
starts the full-screen creation wizard in MAP01, Load/Save Character reuse the
native save lineage, and one neutral Caelum skill removes Doom's obsolete
difficulty page. Compatible weapon pickups auto-equip. Numeric equipment tiers
remain internal but all player-facing names use base, silver and gold finishes.
The eastern stair pair receives its three U-shaped enclosing walls. The next
raw-material crafting layer is intentionally blocked until original silver and
gold raw/ingot sprites are supplied; every other requested raw sprite is ready.

V4.29.0aa integrates the supplied raw-material art and appends 14 processing
recipes without renumbering the 65 equipment entries. Base refinement is 2→1
(50%), bronze is 9 copper + 1 tin → 10 and steel is 497 iron + 3 coal → 500;
all recipes support ×1/×10/×100/×1000 batches. Forge handles ores/alloys and
Sewing Machine handles fibers/hides. A MAP01 manual unlocks this complete
tutorial family. Silver-finish equipment additionally consumes 10% of final
weight in silver; gold finish consumes 20% silver plus 10% gold, without
changing final equipment weight.

V4.29.0ab completed the full personal-document audit and established the
following thirteen-case closing gate. Its recipe/manual result is accepted,
but its house expansion is not: the author found two rear-room wall sections
removed, one stair-origin slab still open, an incomplete lower enclosure and
no usable side balcony.

1. Traverse the new ground and first floors; verify the wall join, open internal
   passage and absence of invisible/internal cuts.
2. Inspect the new floor from below and roof from above; verify solid perimeter
   walls, continuous cover and a fully uncovered balcony.
3. Traverse eastern stairs, bridge, landings, balcony and both existing
   portones; verify continued access to the manual and station network.
4. Create a character: one neutral skill, wizard once in MAP01 and 0/79 recipes.
5. Save/load creation, resources, materials, recipes, equipment, active weapon,
   durability and Magic Box state.
6. Load a V4.29.0x save: preserve 61 legacy flags and append locked shield and
   processing entries according to the current schema.
7. Validate every recipe filter/total and hidden data for unknown recipes.
8. Pick up the processing manual twice: the first changes 0/79 to 14/79 and
   the second is idempotent.
9. Exercise all 14 processing recipes at ×1 and representative ×10/×100/×1000
   batches; verify 2→1, bronze 9:1, steel 497:3 and atomic failure.
10. Validate cumulative station requirements and all shields with Workbench,
    Forge and Anvil; gold additionally requires Master Bench.
11. Craft representative base/silver/gold equipment in every family; verify
    precious-metal rounding and unchanged final weight.
12. Regress compatible-weapon autoequip and incompatible/Magic-Box/capacity
    non-replacement behavior.
13. Build a clean PK3, start GZDoom 4.14.2 without ZScript errors and load MAP01.

The author accepted cases 5–13 on the preceding candidate. Cases 1–4 remain
open because the visual inspection rejected the house result. Case 13 must also
receive a short parse/load regression after 4.29.0ac because this candidate
does change ZScript and MAP02.

V4.29.0ac supersedes only that geometry and begins the next isolated AI gate.
MAP01 restores the two unintended openings, fills the stair-origin slab,
retracts the enclosure to a 96-MU side balcony and adds paired external flights
converging on a second-floor landing and group-913 door. MAP02 preserves the
15,000-actor field but replaces its local rooms with six physical perception
tests. One shared diagnostic target removes redundant Look acquisition;
optional cheap follower steering moves 1,749 followers without native Chase or
neighbor searches. The accepted group-16/no-follower-movement run remains the
mandatory control. This patch does not claim 15,000 independently thinking or
pathfinding actors, and no later active-population stage begins before its A/B
logs pass.

- **4.29.0ac house gate:** repeat cases 1–4 on MAP01, including the restored
  rear rooms, filled stair-origin slab, complete lower extension, side balcony,
  both new stair flights, landing and group-913 door.
- **4.29.0ac load regression:** build and load both MAP01 and MAP02 without a
  parser/node-builder failure. The accepted crafting/persistence cases 5–12 do
  not need repetition because this patch does not touch those systems.
- **Perception gate:** in rooms 1–6 compare standing/crouched and
  walking/running results at Insight 0/50/100; verify occluders force visual
  chance to zero while hearing remains listener-specific. Run both angular CVar
  conventions and choose the authoritative interpretation from their logs.
- **Mass-AI A/B gate:** first replay group 16 with follower movement false;
  then reload MAP02 with follower movement true and keep the player moving for
  at least 20 real minutes. Require 15,000 field actors, 126 leaders, 1,749
  followers, native Chase peak ≤10/tic, bounded projectiles, zero retained
  custom contacts and no accumulating frame degradation.
- After that A/B passes, expand active simulation in separate 3,750 → 7,500 →
  15,000 stages. Do not label the current 15,000 loaded actors as 15,000 full
  AI: 13,125 remain passive visual bodies in 4.29.0ac.
- Complete the permanent Journal interaction layer for inventory and the
  shared station interface in its own reversible increment; the read-only
  recipe book and authoritative crafting transactions are already accepted.
- Add authored efficiency bonuses on top of the explicit 50% processing base; no bonus value or progression source is assigned yet.
- Author the MAP01 NPC task sequence that unlocks one chosen starter weapon recipe and grants its exact materials.
- Add authored unlock sources from found sheets, merchants, NPCs and discovery, without level restrictions.

V4.29.0ad supersedes the rejected 4.29.0ac house result and closes the first
analysis pass on its logs. MAP01 moves the eastern group-913 door into the
first-floor tunnel, removes the solid landing block/floating facade, restores
the rear rooms, adds two real room dividers and replaces inherited ground-floor
materials. MAP02 receives mansion materials only. A real pre-game eight-page
creator replaces the repeatedly opened in-map wizard.

The 4.29.0ac moving-follower candidate is rejected: it froze after 1,024
simulated seconds while all leak indicators remained bounded and nearly every
active actor had converged into a 512-MU crowd. Do not enable it for the next
baseline or advance to 3,750/7,500/15,000 active IA. The next movement design
must budget follower updates too, use many more spatial destinations, limit
local density and test non-converging routes before any combat convergence.

V4.29.0ae supersedes the rejected group-914/915 dividers and side-wing
interpretation from 4.29.0ad. It keeps the accepted creator, group-913 tunnel,
landing and exterior stairs; turns the complete lower extension into one
continuous rear room; restores two symmetric uncovered balconies; adds one
centered rectangular second-floor room; and restores MAP02's sewer materials.
It changes no gameplay or diagnostic actor code.

The author's visual pass rejected that construction: one return remained open,
the opposite wall blocked a balcony, the upper room was short and displaced to
the east, two fins remained instead of a lower divider and MAP02 kept mansion
materials on its interior faces.

V4.29.0af rebuilds those surfaces directly from the clean 4.29.0ad WAD. It
closes both lower wings, opens both 96-MU balconies, replaces the fins with one
ground-floor divider and group-914 double door, and places a 1426×782-MU room
near the main building's true center. MAP02 applies sewer materials to all
nine floors and every non-empty sidedef texture. The accepted group-913
stairs/tunnel and all gameplay source remain unchanged.

The author accepted the first-floor rooms but found four upper-level defects:
one remaining open wall, an eastward unsupported room overhang, floating
platform strips/floor gaps and an uncovered balcony corner. V4.29.0ag again
starts from 4.29.0ad, shifts the same-size room 104 MU toward the main entrance,
closes its complete perimeter and assigns a z=256–264 slab to every corrected
eastern platform sector. The balcony returns close below z=128 but remain open
at the walkable balcony level. MAP02 is byte-identical to 4.29.0af.

The 0ag runtime pass proved that interpretation inverted the needed vertical
layers: the returns remained open on the first floor, their ground-floor walls
cut the rooms, exterior corners did not close and the completed upper slab read
as a floating awning. The upper room also needed to move back and receive an
actual entrance door.

V4.29.0ah reconstructs those layers from 4.29.0ad. Exterior walls occupy
z=0–256; balcony returns occupy only z=128–256; the room moves 64 MU east and
receives group-915 double leaves. The obsolete upper platform is removed except
for a 128-MU corridor between that door and the accepted stair landing.

The 0ah runtime capture proved that the room still stopped 40 MU short of the
intended rear structural line and that removing the platform wholesale was too
broad. V4.29.0ai therefore preserves the accepted 0ah lower shell, moves the
same room to x=-121..1305 and moves group 915 to x=1301. It restores the full
z=256–264 eastern platform while continuing to omit the obsolete room strip
west of x=-121. The central 128-MU corridor remains the direct access route but
is no longer the only upper-floor surface.

The 0ai runtime pass then established two final author corrections: move the
upper room exactly 100 MU west and recover the intended uncovered state of the
two 96-MU first-floor balconies. V4.29.0aj moves the room to x=-221..1205,
moves group 915 to x=1201 and lengthens only the central access corridor. It
removes z=256–264 solely from the two balcony strips, preserving their wood
floor and the rest of the upper platform. The MAP01 world sector also adopts
the existing project-owned `CMGR01` grass terrain instead of Doom `FLOOR0_1`.

The 0aj visual pass found that six inherited wall/return pieces still narrowed
the balconies, both 8×8-MU links between the old shell and the lower extension
remained open, and the upper room needed another 150-MU westward correction.
V4.29.0ak moves the complete room to x=-371..1055 and group 915 to x=1051,
extends the direct corridor, gives all six balcony-transition pieces the open
z=128–136-only profile and closes the two lower corner cells with the adjacent
z=0–256 exterior-wall profile. MAP02 and gameplay code remain unchanged.

The 0ak visual pass approved the complete second floor but exposed two remaining
8×96-MU terminal walls at x=1689..1697 across the ends of the side balconies.
V4.29.0al keeps their z=0–128 ground-floor facade and z=128–136 wood floor,
while removing only the z=136–256 obstruction and z=256–264 cover. The side
balconies now join the eastern exterior platform without changing the approved
upper room, door, corridor, lower corners or grass.

The 0al visual pass confirmed that those terminal walls were not the complete
blocker: the long north/east/south wall around the outside of the balcony
remained. V4.29.0am applies the same lower-facade/open-upper profile to all
seven sectors in that outer U while preserving the western joins and lower
corner closures. It also replaces the accepted room's flat roof with the
author-selected two-slope form: an east-west ridge perpendicular to the
eastern balcony and a 64-MU rise. The separately supplied grass files enter as
`CMGR01A/B/C`, with A replacing the three-band composite on MAP01. The selected
audio package and Freesound #332629 are connected to their intended runtime
events and carry in-package license records. This audiovisual integration does
not authorize later sound mixing values or new terrain placement beyond the
explicit assignments above.

V4.29.0an cleared the eastern flat roof and added the first requested wall at
the stair base. V4.29.0ao replaced that provisional result with two reflected
488×8-MU solid transverse walls. V4.29.0ap completes the symmetric U with two
8-MU stair-side walls and replaces fragmented inherited roof profiles with an
exact z=256..264 rectangle over x=1209..1697, y=-328..328. The central landing,
final steps, side balconies and accepted upper gabled room remain unchanged.

The author has accepted the new-character case, focused menu/world sound mix
and event mapping, and the non-house MAP01/MAP02 smoke. The latest 0ap house
geometry remains a parallel focused visual/traversal review and does not
reopen those accepted cases.

Controlled perception-angle work and a replacement mass-AI movement
experiment remain valuable isolated diagnostics. They are not prerequisites
for defining V4.30, but V4.30 implementation waits until the unresolved rules
listed in its section are authored.

### V4.30 — Repair, Disassembly and Durability Loop

- Close the craft → use → deteriorate → repair/disassemble → recover-materials loop.
- Refinement and equipment-material fabrication offer 50%/75%/100% material
  yield with elapsed-time factors ×1/×3/×9. Duration is reduced by Dexterity
  Type-1 physical-precision task speed; the initial test baseline uses no
  Dexterity acceleration.
- Fabricate every equipment component from exactly one base-material type;
  component recipes never mix multiple base materials.
- Repair through the same station infrastructure as crafting. Consume the
  complete recipe proportionally to missing durability:
  `(MaximumDurability - CurrentDurability) / MaximumDurability`.
- Scale disassembly output by remaining durability:
  `CurrentDurability / MaximumDurability`, preserving corresponding material
  identity and tier.
- Elemental weapons disassemble into their corresponding recipe materials;
  remove the former essence-versus-intact-base-implement branch.
- Audit armor, shields, physical weapons, ranged weapons and essence weapons under one transaction model.
- Before implementation, author base durations, 0.001-unit rounding, batch and
  interruption rules, the base disassembly-recovery factor and the complete
  one-material component mapping.

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
