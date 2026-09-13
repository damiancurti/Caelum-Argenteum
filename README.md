# Caelum Argenteum

An independent dark fantasy FPS-RPG inspired by nineteenth-century Argentina.
Author and game designer: **Damian Curti**. Development target: **GZDoom 4.14.2**
on Windows 11. The final game is intended to be independent of Doom assets.


**Current release: 4.33.0ae.** Apply over the complete **4.33.0ad** project.
The author approved all 0ad tests. Caella now teaches the five T1 seals and
components, with finite raw-material allowances at 100% in every layer.
MAP01 remains the systems test environment.

## Implemented

- After completing Caella's trial, ask her to teach the five T1 seals. Reading
  or declining changes nothing; accepting teaches existing recipes/dependencies.
  Quest Detail tracks preparation from 0/5 to 5/5. This is optional and keeps
  completed trials, rune access and the first crafted weapon unchanged.
- At 100% in every layer, all five need 1.8 kg raw copper, 0.2 kg raw tin and
  0.6 kg each of ruby, sapphire, emerald, topaz and opal. This allowance extends
  the chosen loadout's existing pool once, without replenishing issued stock.
  A previously owned T1 seal reduces only the new allowance for its element.
- Use Caella's Workbench or the complete upstairs workshop, Crafts > Seals.
  T1 seals support recursive raw-material crafting, native task reservations,
  pause/cancel and personal output without the Box. Equip one through Inventory;
  the existing Channel, Adrenaline, HUD and cooldown rules apply.
- When more seal materials are needed after returning the sword, Ronnie's
  workshop dialogue can lend it again and accept its return. No repair lesson
  or damaged first weapon is required for this gathering loan. Existing carry
  capacity, finite extraction and loan identity rules remain in force.

- After the weapon choice, Ronnie offers magic, light, medium or heavy armor
  with descriptions and confirmation. He teaches the chosen family's four T1
  pieces and component recipes. Existing choices can ask under his workshop
  dialogue. Armor preparation is optional; its 0/4–4/4 count appears in Detail.
- Armor now uses the same recursive native crafting path as weapons. Chosen
  T1 pieces go to personal inventory before the Box reward and can be equipped.
  Native tasks, reservations, pause/cancel, weight and saves remain authoritative.
- MAP01 grants only the raw-material allowance for one chosen weapon, one
  chosen armor set and one ten-arrow/bolt batch when appropriate, plus the
  optional seal allowance after learning from Caella, at 100% in
  every layer and the chosen equipment size. New choices default to 100%.
  At size M, armor leather is 5/10/20/40 kg; giant gauntlets add 6 kg.
- Sources share a per-character allowance, charged when materials are generated
  or withdrawn. Another node, consumption, save/load or node regeneration cannot
  refill it. The chest and Bull share the leather allowance; the Bull's physical
  12.5 kg yield is a ceiling. Unneeded material cannot be harvested or collected.
- Large floor stacks allow partial pickup within the allowance and free carry
  capacity, with a one-gram movement margin. Old inventory is retained and
  counted; the chest can accept its unreserved surplus. Unused chest leather
  remains returnable. Pending tasks retain their saved costs and reservations.
- The accepted optional repair lesson reserves only the first weapon's current
  damage at 100% when requested; repeating the request does not add stock.
  Ronnie can lend the gathering sword again for this repair; return it through
  the same conversation. General crafting efficiencies and work times are unchanged. The narrative
  exit still carries only the Box and first weapon; armor remains Limbo equipment.

- Choosing Ronnie's crossbow also teaches the 10-bolt recipe and its component
  dependencies. Previous crossbow choices receive that knowledge on load,
  including saves outside MAP01. No ammunition or materials are granted.
- Bolts use the native 50 g item and the T1 shaft/bronze-point structure used
  for arrows: 350/150 material units per batch before assembly losses. All
  three efficiencies, layer choices and raw-material crafting use native tasks.
- Batches deliver exactly ten bolts to personal inventory without requiring
  the Box. Reservations, pause/resume, cancellation and saves remain native.
  Bolts load and fire through the existing crossbow. Crafting ammunition cannot
  replace the first crafted weapon. Arrows retain their separate recipe/output.
- Crafts shows the bolt icon/name in Ammunition. Ronnie explains the process
  under his workshop dialogue; Quest Detail guides crossbow characters.
  The catalogue appends recipe 130 and preserves all previous recipe indices.

- After returning Ronnie's sword, ask how to breathe while swimming and accept
  the optional practice. The pool behind the mansion has wide steps on the
  mansion-facing side. With Air replenished, submerge your head near the steps
  for one second, then come back up and breathe for three seconds.
- Native underwater Air spending and debt recovery drive the two steps. Wading,
  reading the proposal or a debug refill cannot complete them. Quest Detail and
  Ronnie show progress; partial saves and completion persist. No return visit
  or new requirement for Rulo/the exit is added. Pool geometry is unchanged.

- Each Minor Arcana grants only the specified base attribute passive, before
  collection percentage: Swords = Mental, Cups = Social, Wands = Physical,
  Coins = Technical. All fourteen cards in a suit add +3 to each of its three
  attributes; all 78 cards still add +100% through collection. Journal shows
  the minor base separately. Only the Fool is obtainable in current content;
  the remaining cards need their planned acquisition content.
- Greatsword, war axe and halberd use Zoom for a 360-degree sweep: primary
  damage, reach and recovery, with triple primary Air per execution. Nearby
  enemies can all be hit once; walls, solid 3D floors and allies are respected.
  Giant gauntlets retain Block. Charged sweeps consume the existing charge.
- General incoming damage after armor divides by Type 4 Toughness; magical
  Anima cost divides by Type 4 Eloquence. At 100 the divisor is 3. Physical
  collisions keep their subtractive Toughness rule; pain and Lucidity retain
  their previous curves. Existing saved character statistics are refreshed.

- Ronnie now shows current carried kilograms, capacity and the load-only Air
  multiplier. He explains why carrying less can help even below full capacity.
- An optional practice records an actual carried-item weight reduction through
  Inventory D (drop) or C (Box storage, when owned). The first crafted weapon
  is excluded. Reading, consuming, crafting, increasing attributes or failed
  inventory actions cannot complete it. No extra burden or supplies are given.
- Quest Detail and Ronnie recognize completion; saved games and actual map
  travel retain it. Loans, reserved materials and native inventory limits keep
  their restrictions. The practice never blocks the main quest.

- After returning Ronnie's sword, ask how to manage Air. Reading the proposal
  changes nothing; accepting starts an optional two-step practice. Running must
  spend 1% of maximum Air at acceptance, then natural recovery must restore that
  amount. Short running stretches accumulate; exhaustion is unnecessary.
- Quest Detail tracks running and recovery. Real native costs and recovery are
  observed without free Air, extra costs, a new timer or a quest requirement.
  Energy drinks cannot complete natural recovery. Reopening does not reset
  progress; saves preserve partial progress and completion travels with you.

- After returning Ronnie's sword, ask how to eat and drink. Reading the proposal
  changes nothing. Explicitly accepting starts an optional practice, lowers only
  reserves above 90% once, and offers one food ration plus one water ration.
- Consume them through Inventory. Each successful use below full reserves is
  recorded separately in Quest Detail; the native ten-second recovery remains.
  Talking, collecting, using a boxed item or consuming at full reserves does
  not count. Reopening never duplicates delivered supplies or resets reserves.
- If weight blocks a ration delivery, free space and ask Ronnie to check it.
  Each delivery has its own persistent flag. Completion survives saving and
  travel; no quest gate, mandatory return visit or new recipe reward is added.
- Native consumable use now permits refreshing an active effect before its
  blinking phase, as the existing non-stacking ten-second rule requires.

- After returning Ronnie's sword, ask him how to maintain your weapon. He
  explains condition, selecting/unequipping the piece, the upstairs Workbench,
  F in Crafts, material reservations, pauses and cancellation.
- The optional practice completes only when native Repair actually restores
  the first crafted ItemId. Talking, starting, pausing or cancelling cannot
  complete it. No free repair, forced damage, extra equipment or recipe reward.
- Quest Detail records the lesson and completion. It survives saving/loading
  and the narrative exit; leaving without doing it is allowed. The normal
  Rulo/Palomo/Fool/exit progression stays unchanged.
- T1 recipe costs remain quantified in SYSTEMS.md. Tutorial supply now covers
  the selected armor set and accepted seal preparation at 100%, as specified
  above. The existence of veins alone does not grant unrestricted access
  to every T1 recipe.

- After capturing The Fool, Quest Detail points to the marked door at the back
  of the Bull room on the ground floor. Palomo, Ronnie and Rulo also give
  directions. The door requires the owned Box, completed trials and the card.
- Crossing requires explicit confirmation. Declining keeps the inventory and
  quest unchanged. An unfinished crafting task must be finished or cancelled
  by the player before crossing. The transition can resume from a saved game.
- Only the Box and the first crafted weapon cross; all other carried and stored
  physical items stay behind. The same weapon retains its ItemId and condition
  inside the Box. Tarot, learned recipes, character progression and current
  resources are retained, with no extra class loadout or automatic refill.
- The quest completes at phase 100. MAP02 opens on a dry sewer walkway, with a
  brief Unknown Voice conversation and instructions to retrieve/equip the weapon.
  This is the arrival area; the full sewer route and encounters are still planned.
- The unchanged diagnostic map content is now available through `map CADEV02`.
  Its 16,508 things are separate from the narrative arrival. That console command
  starts a new test character and is not a substitute for the quest transition.

- Ronnie lends only the sword. A shield appears and blocks only when an actual,
  usable, compatible shield is equipped. Stale shield state and left-hand layers
  are cleared automatically, including on load; real items retain their identity.
- Rulo's dialogue and Quest Detail describe defense for the current equipment:
  shield/giant-gauntlet blocking, ranged aiming, or lateral evasion. A greatsword
  uses evasion: walk sideways in the ground-floor target room until the defense
  check is complete. Zoom is not required and the greatsword does not gain Block.

- After receiving the Magic Box, an apparition appears in the centre of the
  underground cave, in front of the back-wall veins. Use reveals the original
  Fool of the Pampas artwork; the player explicitly confirms capture.
  Leaving or losing the Box during the animation interrupts safely and allows
  a retry. The essence disappears only after the persistent reward is recorded.
- The Journal has a Tarot page with the card, collection count and bonus.
  Each Major adds 2%, each Minor 1%, additively, to all twelve primary attribute
  levels before derived formulas. Fractions are retained: 15 becomes 15.30.
  Recalculation starts from creation/equipment; loading cannot compound bonuses.
- Quest Detail tracks finding, revealing and capturing the essence. Palomo and
  the four residents react to the capture. Phase 90 now leads to the marked
  door, phase 95 to the crossing and phase 100 to the completed quest.

- Palomo's original actor speaks on the second floor after all four trials.
  His final dialogue keeps the author's mysterious tone, optional questions,
  and explicit acceptance of the Magic Box. Leaving before acceptance gives
  no reward; reopening after acceptance offers storage help and cave directions.
- The Box now has one native Inventory instance, an owner and a stable ItemId.
  Existing storage/weight rules remain authoritative: 10 kg for the Box plus
  reduced content weight. It cannot be dropped, sold or stored inside itself.
  Old owned Boxes migrate without a second weight charge or lost contents.
- Quest Detail and Argento's guidance reflect phase 80. Palomo remains upstairs,
  and its location is correctly listed already at phase 75. An early upstairs
  visit gives current-stage guidance and cannot award the Box.

- The Bull party uses the four original residents. Lethal damage leaves them
  resting at 1 Health until the attempt ends. Victory/retry restores them.
  The native combat flag that blocked Argento/Caella dialogue is cleared after
  combat, including existing saves. A surviving corpse instance from an old
  save is repaired in place; progress and loot are preserved.
- Rulo's victory, repeat dialogue and Quest Detail recognize innate strength
  and the ability to unite and lead the group.

- The obsolete processing manual outside MAP01 is retired. Ronnie continues
  to teach the selected weapon and its recipe dependencies.

- Ronnie offers all 16 physical and 20 magical T1 weapons, with explanations
  before confirmation. He teaches the chosen recipe and its component recipes.
- Twenty 2D shrubs and four ceibos surround the entrance. Each shrub represents
  an estimated 10 kg of aboveground biomass, with the same hardness as wood.
  Slashing yields fiber; the cave contains copper, tin, five gemstone veins
  and a finite leather chest.
  Ronnie lends the gathering sword and takes it back after the first craft.
- Each resident's room supports its equipment family through T2, including
  components. The indoor second-floor room contains all twelve stations;
  all twelve form one row against the back wall. Bedroom stations occupy
  corners. Use checks height and visibility; saved tasks/reservations persist.
- Argento shares the journal's current-stage guidance. All residents can
  explain the new resource and workshop locations.
- The five characters have 280 supplied pose sprites and native states.
  Domingo uses crouch idle/walk art; seated/lying states prepare future furniture
  interactions. They do not implement rest or calendar simulation yet.
- The basement chest holds cow leather for the chosen armor and, when chosen,
  giant gauntlets, at 100% in every layer. It shares its allowance with the Bull.
  Withdrawals respect carry capacity; unused leather can be returned.
  Reopening/loading does not refill it. Needed gems come from the cave veins.
- Bow and longbow choices also teach a native recipe for ten arrows and all
  its dependencies. Arrows enter personal inventory and do not replace the
  first crafted weapon. Tab closes Crafts; G changes its recipe filter.
- Argento holds the silver key; the Bull is placed in the locked starting room.
  Delivery requires Caella/Ronnie completion and Rulo's combat practices.
  Rulo now offers six tracked exercises with native actions for all 36 starter
  options, including movement alternatives for unsupported actions. His target
  is in the ground-floor north room directly below his bedroom. The silver key
  requires all six checks. Entry starts the Bull fight and locks the room.
  A defeat restores Health/Air/Anima and restarts the same Bull, preserving
  progress and the first weapon. Victory opens the room and drops the finite
  leather budget once; speaking with Rulo completes phase 75.
  The 900 kg Bull can yield up to 12.5 kg of usable leather, following the
  documented hide/processing estimate, limited by the unissued leather allowance.
  The chest supplies the rest of the chosen set. T2 infrastructure stays.
- Ranged trainees receive 24 borrowed rounds, replenished when exhausted in
  the arena. Unused rounds return at turn-in; pre-existing ammunition remains.
  Rulo restores the first weapon for practice. Javelin practice cannot yield
  materials from that restoration; its close-range AltFire fallback now uses
  its existing primary reach instead of zero.
- Palomo remains visible and solid during his fifteen-waypoint departure to
  the second floor, using stairs, doors and normal movement. Save/load resumes
  the route. His final conversation and unique Magic Box reward are now playable.
- The first crafted weapon goes to personal inventory without requiring the
  Magic Box. Its ItemId is preserved; extra crafted weapons and mission
  material quantities are removed on leaving MAP01. Quest Detail tracks
  requirements, missing materials, directions and returning the loan.

- Character creation, attributes, survival resources, inventory/equipment,
  crafting, repair/disassembly, physical currency and merchant infrastructure.
- Physical/ranged/magical combat, contextual Block/ADS/sweep, charged attacks and
  equipped-Seal Channel. Sword/hand/shield framing 4.32.0o remains accepted.
- MAP01 mansion, secret facade, native moving lift and resource cave.
- Prologue, Unknown Voice, Palomo and Argento's social task: recruit the three
  residents, persist results/failure alternatives, return at 3/3 to phase 35.
- Caella's magic trial: real primary/secondary casts, Seal Channel, Anima
  spending/recovery, four elemental runes, hints after mistakes and a persistent
  turn-in at phase 45. The fourth rune keeps the staff and wall intact; return
  to Caella, hand back her loan, then walk through the still-visible wall.
- Correct Spanish localization for Caella. The magic implement and one Seal
  suffice: complete practice, then press Use on Earth, Air, Fire and Water.
- Side HUD Seal icon: normal colors when available, grayscale when blocked,
  with remaining cooldown seconds below. No central Seal status message.
- Twelve simple 3D crafting stations, based on the original sprites, with
  characteristic tools and unchanged collision/crafting behavior.
- One native harp phrase on dialogue opening and every next page. War Drums
  plays once on the title screen; menu strings start with Quit confirmation
  and still accompany the map Exit.
- Quest Detail opens with F in Quests: current instructions, the five magic
  practice checks, rune directions and a description of the quest.
- The 250 old test items in the six first ground-floor rooms are retired on
  map load, including existing saves. Carried items and player drops remain.
- A single root Windows builder, source art and reusable generators in assets,
  five active documents and source patches installed by copying files.

## Planned

Next: finish the remaining mechanics and tutorial coverage in MAP01, following
PROJECT.md. Safe-water collection/processing remains planned. Bullet crafting still needs its material composition and process
defined; the existing 3 g bullet mass is unchanged. Bolt crafting is implemented. Food/water, Air/movement, load management and pool breathing are now
implemented. New maps, sewer encounters and campaign layout are deferred while
systems testing is the priority; MAP02 keeps its accepted arrival.
Material coverage uses finite 100% allowances for the chosen loadout and learned seals.
Additional equipment by class and special post-awakening resource values await
author design. The accepted exit still preserves current resources and the first
crafted weapon only, inside the Box.

The established sequence continues through V4.34 world/travel foundations,
V4.35 calendar/weather/events, V4.36 physical hazards and V4.37 Tarot/Trucazo.
**V5.0 reorganizes programming modules**; V5.1 adds thermal exposure and later
V5 work expands persistent resources and marine biomes. Remaining weapon
art, loot, faction consequences, perception/formations, sieges, co-op/PvP,
world persistence and the complete campaign are tracked in PROJECT.md.

## Pending validation

0ad is author-approved. Focused 0ae checks are in PRUEBAS_4_33_0ae.txt;
native engine evidence and limits are in PROJECT.md.
All maps and audiovisual resources remain byte-identical to 0ad.

## Build and run

Close GZDoom. Copy **src**, **docs** and **README.md** from the 0ae patch
into the complete **4.33.0ad** project, merging folders and replacing matching
files. Keep **PRUEBAS_4_33_0ae.txt** outside docs.
Existing MAP01 and MAP02 saves can continue; keep a backup before testing.

Double-click **run_dev.bat** to build and play with the supplied machine's
existing engine/IWAD paths. To build independently, from any working directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\path\CaelumArgenteum\build_dev.ps1"
```

Only src enters build/caelum_argenteum_dev.pk3. The builder writes files-only
ZIP entries and replaces the previous build atomically after verification.
Python is not needed to build or play. Source generators in assets/generators
are optional editing utilities; their dependencies are listed in ASSETS.md.

## Documentation and project rules

**Update this README and the five canonical documents with every release.**
Keep implemented, planned and pending-validation status distinct. Integrate
new subjects into existing chapters; preserve superseded information in the
history and keep patch-specific utilities out of the active project.

| File | Purpose |
| --- | --- |
| [PROJECT.md](docs/PROJECT.md) | Principles, complete roadmap, folder audit and current validation. |
| [SYSTEMS.md](docs/SYSTEMS.md) | Controls, social odds, crafting, economy, storage and dialogue rules. |
| [MAP01.txt](docs/MAP01.txt) | Full authorial story/specification and implementation boundaries. |
| [ASSETS.md](docs/ASSETS.md) | Audio/art inventory, provenance, source generators and accepted framing. |
| [HISTORY.md](docs/HISTORY.md) | Consolidated previous records and superseded decisions. |

Use English code/identifiers and Spanish explanatory comments. Prefer native
engine features and shared authoritative systems; protect accepted gameplay
and author-owned lore/balance. Deliver changed files and report actual tests.
Keep useful source assets and required license notices. Deliver patches as
changed files to copy plus one test TXT; no patch installers. V5 source refactoring
must preserve save/input compatibility through incremental changes.

Run `python validate_project.py` before preparing a release to check version,
documentation, structure, Caella translations, station models and audio references. Development engine/IWAD files,
test observers and archives are not part of the playable PK3 or source delta.
