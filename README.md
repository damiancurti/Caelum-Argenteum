# Caelum Argenteum

An independent dark fantasy FPS-RPG inspired by nineteenth-century Argentina.
Author and game designer: **Damian Curti**. Development target: **GZDoom 4.14.2**
on Windows 11. The final game is intended to be independent of Doom assets.


**Current release: 4.34.0c.** Apply over the complete **4.34.0b** project.
The author approved 0b and authorized connected sewer maps for upcoming
mass-actor, Tarot and other system tests, with no passage back to MAP01.
MAP02 now connects both ways with MAP03 (reservoir), MAP04 (Tarot chambers)
and MAP05 (maintenance). Approach a gate and press Use. Each new map has a
return gate behind its arrival point; returning to MAP02 uses its existing start.

The native sewer hub retains map actors and dropped items across visits and
saves. Travel preserves the player's actual inventory and progress, without
repeating the Limbo cleanup or refilling resources. Existing MAP02 saves gain
the gates without changing their geometry. The new maps provide test spaces;
they do not automatically spawn crowds, grant Tarot or enable new hazards.
Spanish application and test instructions are in **PRUEBAS_4_34_0c.txt**.

The roadmap remains **V4 through 4.37 → playtest export for other players → V5**.
All inherited and cross-system work is assigned to V5 after that export,
starting with the modular refactor in V5.0 and thermal exposure in V5.1.

## Implemented

- Three new sewer maps generated as native UDMF from reusable room, gallery,
  reservoir and stair modules, using existing Caelum textures only. MAP01,
  MAP02 and the independent CADEV02 diagnostic map keep their original bytes.
- Six directed sewer connections in native hub 434. Physical Use gates name
  their destination and preserve the map and inventory state across travel.
  No route leads back to MAP01. Native narrative return remains separately guarded.
- MAP03 has a broad central test area, side channels and peripheral pillars.
  MAP04 has central, side and rear chambers. MAP05 has two walking stairways,
  each with eight 12-MU risers and 64-MU treads, reaching a gallery at +96 MU.
- Gate reconstruction supports previous MAP02 saves without duplicate actors.
  Discovery, actual arrival and reverse travel remain independent observations.
- World journal columns show visited locations and known exits from the current
  map. The journal remains read-only and retains its accepted navigation.


- Atomic group access checks cover native key requirements, explicit arena
  locks and optional faction conditions on every leaf. Rejection preserves
  group requests and timers. Only positive ids join leaves into a group.
- Occupancy uses the original opening, slide axis and the actual player's
  radius/height. Both leaves wait together; entering during closure reopens
  them. Losing a key cannot trap a player in an already open doorway.
- Native LOCKDEFS key feedback uses the existing Caelum locked-door sound,
  with the existing cooldown and without duplicate manual playback.
- The explicit door trial creates two leaves with a key lock on one only.
  Its separate reusable key, native save/load and removal do not alter the
  silver key or quest/faction/world records. The door report only reads state.

- Stable world location and directed connection ids, recorded in the existing
  persistent character inventory. Native saves and transitions retain visits,
  known connections and completed travel, with a pending departure marker.
- The World journal replaces its placeholder with actual recorded data. It
  reads the authoritative inventory directly; there is no separate player copy.
  Narrative exits still perform all travel validation and confirmation.
- Previous MAP02 saves with a completed, sanitized narrative return recover
  the mansion visit and travelled connection. A console-started MAP02 without
  that history records only its current location. No reverse route is created.
- Existing arrows and PgUp/PgDn journal navigation are retained. World labels
  and guidance are localized in English and Spanish using the existing art.

- Loading a save with an active native conversation reconstructs its menu for
  the same speaker/player, using StartConversation. An inactive reference is
  left inactive. The restore does not select a reply or grant a reward, and
  normal map changes do not trigger it. Existing saves are supported.


- A combined native 0an save exercises completed and active side quests,
  faction standing, membership and a real discounted purchase before capture
  and the existing narrative return to MAP02. Detailed evidence and limits are
  recorded in PROJECT.md; this does not declare the full campaign complete.
- The integration console report presents existing records together and
  distinguishes a recorded reward claim from possession of its receipt.
  It reports current service conditions without changing the live session.


- Optional serializable faction conditions declare a stable faction id, an
  inclusive reputation minimum and an independent membership requirement.
  Missing conditions preserve existing content; invalid configured conditions
  deny access. Checks read the requesting player's persistent record.
- Dialogue entry, grouped sliding doors and merchant sessions share these
  conditions. Every door leaf is checked before a group moves. Trade rechecks
  access before moving coins or goods; a changed quote requires confirmation
  at the refreshed price.
- A separate reputation discount uses the existing 140% buy / 60% sell margins
  instead of normal 150% / 50%. It is recalculated from the active service's
  condition, never becomes the saved negotiated discount, and does not stack.
- The explicitly enabled trial uses Gendarmeria only: information needs 25,
  the door needs membership and 25, trade needs 0, and its discount needs 25.
  These are test settings, not narrative ranks or global faction thresholds.
  Existing Limbo residents retain their neutral, unassigned faction behavior.


- The Fool interaction and capture animation check whether the referenced NPC
  is actually in conversation. A retained reference to an inactive NPC no longer
  blocks them. Active dialogue remains protected; the owned Box, explicit
  capture choice, animation, unique card and existing +2% bonus remain required.
  The return door and transition use the same active-conversation check.
  Loading a save does not grant a card or erase native conversation references.
- In Inventory, Left/Right selects the previous/next filter. Left at the first
  filter changes to Tarot; Right at the last changes to Character. The filter
  remains selected when returning. F/Y retains its existing next-filter cycle.
- In Quests, Left/Right selects known quests, including from Detail. Left at
  the first changes to Crafts; Right at the last changes to Reputation. With
  one known quest, either arrow changes to its adjacent section. Undiscovered
  entries are skipped. Up/Down retains list selection and detail scrolling.
- PgUp/PgDn or LB/RB always changes sections directly. Leaving an active
  crafting station closes its native session. Navigation cancels pending
  abandonment confirmation and does not accept, complete or create quests.
- Seal channeling excludes environmental props and crafting stations from
  targeting, attraction, expulsion and trapped mass. MAP01 retains the existing
  one-time repair of displaced garden nodes and room stations using the same
  actors, preserving depletion, reservations and task ownership.
- A fresh Use press stops an active seal channel with its normal cooldown
  and reaches native interaction in the same press. Adrenaline exhaustion
  also releases Use; the remaining cooldown only prevents restarting the seal.
- Console `netevent ca_debug_fool_report` remains an explicit read-only report
  of capture conditions, Box identity, channel/menu state and essence proximity.

- Optional quests have explicit offers, prerequisite completion, acceptance,
  capped objective progress, completion, failure and confirmed abandonment.
  Terminal records cannot restart or change ending. MAIN_M00 keeps its stable
  index, story and progression; its legacy setters now reject terminal changes.
- Each test quest grants one native Inventory receipt. A persistent per-quest
  claim flag prevents duplicates after reopening, item removal or travel. A
  refused receipt remains claimable after the receiving condition is resolved.
- Journal Left/Right selects known quests; Up/Down also selects in the list.
  F/Y opens the selected detail, Enter/A
  accepts or completes/claims, and two separate G/X presses confirm abandonment.
  Cancel/close/navigation clears confirmation; holding the key cannot confirm.
  The server validates the quest id and state for each action.
- Console `give CaelumDebugQuestTrial` reveals two optional diagnostic offers.
  Route requires moving 128 map units from its acceptance point on the same
  floor; changing maps before that objective fails it. Wait requires Route
  completed and five active seconds without an observed decrease in health.
  The timer and quest records survive saves/travel. Receipts have no weight,
  price or bonuses; the campaign gains no extra quest requirement or rewards.


- Hunger/Thirst depletion uses Constitution; Sleep depletion uses Resilience.
  Each is divided by Type 4: 1 at attribute 0, 3 at 100. Consumption stays
  positive; passive Hunger/Thirst retain their body-mass factor. Constitution
  also divides the Hunger/Thirst cost per point of natural Health/Air recovery,
  without applying body mass twice or changing the recovery rate.
- Hunger, Thirst or Sleep at 10% or less again drains health and blocks natural
  healing, restoring the original critical rule. Loading older saves refreshes
  only the passive-depletion factors, preserving reserves and progression.

- A source audit of all twelve attributes is recorded in SYSTEMS.md. It
  separates active effects, different attribute assignments/scales and pending
  mechanics. The audit does not implement the missing effects. Ranged reload
  currently uses Dexterity; general support buffs/healing, academic tasks and
  the player's magical/hidden senses remain incomplete or pending.

- Six reusable bottles/canteens: small 1 L, normal 2.5 L and large 5 L,
  each with its original 0af sprite. Empty or partially filled containers outside
  the Box top up on entering potable water with the head submerged. Only the
  missing water must fit the remaining carrying capacity.
- Each sip spends body mass / 500 liters to restore 10 Thirst points over ten
  seconds: 0.1 / 0.2 / 0.4 L at 50 / 100 / 200 kg. A smaller remaining amount
  restores proportionally less. Inventory displays liters; empty containers
  remain reusable, and Box storage, dropping and saves preserve their contents.
  The separate 100 ml water ration retains its mass-dependent recovery.
- Potable immersion again restores one Thirst point per second, including
  without a container. Low-reserve performance penalties remain in effect.
- After returning the sword, Ronnie's workshop dialogue offers one empty normal
  canteen. Retry if carrying capacity blocked delivery. Quest Detail records
  filling and drinking; this optional practice adds no main-quest requirement.
- Caella offers a confirmed choice of one T1 seal and one T1 amulet, teaching
  the selected recipes and components. At 100% per layer, the seal requires
  360 g raw copper, 40 g raw tin and 600 g of its gem; the amulet needs 200 g
  raw silver and 800 g of its gem. Matching gems share the summed allowance.
  The basement chest supplies needed silver and leather; cave veins supply gems.
- Native recursive crafting, reservations, pause/cancel and personal output
  support the chosen accessories. Detail tracks both pieces. Previous 0ae items,
  knowledge and issued stock are retained; unused allowances for other seals
  are removed. A previously started seal task retains its personal output.

- After the weapon choice, Ronnie offers magic, light, medium or heavy armor
  with descriptions and confirmation. He teaches the chosen family's four T1
  pieces and component recipes. Existing choices can ask under his workshop
  dialogue. Armor preparation is optional; its 0/4–4/4 count appears in Detail.
- Armor now uses the same recursive native crafting path as weapons. Chosen
  T1 pieces go to personal inventory before the Box reward and can be equipped.
  Native tasks, reservations, pause/cancel, weight and saves remain authoritative.
- MAP01 grants only the raw-material allowance for one chosen weapon, one
  chosen armor set and one ten-arrow/bolt batch when appropriate, plus the
  chosen seal and amulet allowances after learning from Caella, at 100% in
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

Continue the V4.34 world, architecture, connection and travel foundations
after accepted locations and door access, now with connected sewer test maps.
Caravan foundations and travel/event integration remain; simulated durations
will depend on the global clock in V4.35. New campaign content and all inherited
and cross-system expansion are assigned to V5, after the V4 playtest export.
Narrative faction assignments, rank thresholds and cross-faction relations
still require authored design.
The attribute audit is deferred by the author; the current rules stay accepted.
Follow PROJECT.md for the remaining scope. Potable-water collection is implemented. Treatment of unsafe water remains undefined. Bullet crafting still needs its material composition and process
defined; the existing 3 g bullet mass is unchanged. Bolt crafting is implemented. Food/water, Air/movement, load management and pool breathing are now
implemented. The author now authorizes additional sewer maps for system
testing. MAP02 keeps its accepted arrival; MAP03–05 supply test spaces.
Sewer encounters and the full campaign layout remain deferred to V5.
Material coverage uses finite 100% allowances for the chosen loadout and learned seals.
Additional equipment by class and special post-awakening resource values await
author design. The accepted exit still preserves current resources and the first
crafted weapon only, inside the Box.

The established sequence continues through V4.34 world/travel foundations,
V4.35 calendar/weather/events, V4.36 physical hazards and V4.37 Tarot/Trucazo.
After V4.37, prepare and verify an exported playtest build for other players,
with installation, controls, a test route and a way to record issues. Then
**V5.0 reorganizes programming modules**; V5.1 adds thermal exposure and later
V5 work expands persistent resources and marine biomes. Remaining weapon
art, loot, faction consequences, perception/formations, sieges, co-op/PvP,
world persistence and the complete campaign are assigned to V5 in PROJECT.md.
The playtest export is a separate milestone from the final independent release.

## Pending validation

4.34.0c compiles and runs in native GZDoom 4.14.2 with Freedoom and llvmpipe
on Linux. Focused checks cover travel guards, all six native Use directions,
stateful revisits, physical stair climbing, saved hub snapshots and an original
0b MAP02 save upgraded through a roundtrip. Original narrative return into the
new hub is checked from prepared prerequisites. Visual checks cover all new
spaces and Spanish/English World labels. PROJECT.md records fixtures and limits.
Author validation on Windows is pending. No mass population benchmark, full
campaign replay or multiplayer session is claimed. 0b is the accepted base.

## Build and run

Close GZDoom. Copy the supplied **src**, **assets**, **docs** and **README.md** from the 4.34.0c
patch into the complete **4.34.0b** project, merging folders and replacing matching
files. Keep **PRUEBAS_4_34_0c.txt** outside docs.
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
