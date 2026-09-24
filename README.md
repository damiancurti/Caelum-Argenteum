# Caelum Argenteum

An independent dark fantasy FPS-RPG inspired by nineteenth-century Argentina.
Author and game designer: **Damian Curti**. Development target: **GZDoom 4.14.2**
on Windows 11. The final game is intended to be independent of Doom assets.

**Current release: 4.36.3.** Obtain and update the complete repository, validate
it, then rebuild with `run_dev.bat` as described below. Issue
[#9](https://github.com/damiancurti/Caelum-Argenteum/issues/9) adds 10 degrees
of counterclockwise flail-handle rotation across T1–T3, preserving the grip and
independent chain animation. Native comparisons are in
[4.36.3 evidence](assets/validation_4363/RESULTS.json); the author confirmed the final pose
passed on 2026-09-23. Issue
[#8](https://github.com/damiancurti/Caelum-Argenteum/issues/8) caches the existing
bow-stave crops to remove first-use texture-composition stalls, preserving
native palette effects, geometry, controls, ammunition and saves. Issue
[#22](https://github.com/damiancurti/Caelum-Argenteum/issues/22) integrates the
engineering guides and the long-document index; issue
[#6](https://github.com/damiancurti/Caelum-Argenteum/issues/6) standardized English
documentation, numeric patch versions and the author-test workflow.
Gameplay rules retain the accepted 4.36.0i baseline. When upgrading from a version before
4.36.0i, start a new game or use `map MAP02`: that earlier release replaced
MAP02 with the author's authorization.

Outstanding author checks are in [pending_test.txt](pending_test.txt); changes,
performed validation and confirmed results are in [HISTORY.md](docs/HISTORY.md).
The following gameplay details retain the 4.36.0i baseline with the #9 pose adjustment.

The flail handle rotates another 10 degrees counterclockwise from 0i (32.5
degrees total from 0h), and half of its
previously exposed shaft moves into the glove. Its chain and ball are a
separate rear layer, hanging vertically at rest and making a full counterclockwise
revolution during an accepted attack. Both bows have twice their former stave
thickness in first person only, retaining their curvature, muted palette and
accepted hand/arrow layering. Ground sprites and inventory icons are unchanged.

Food rations weigh 200 g; water rations contain 200 ml and weigh 200 g.
For an 80 kg body, ten completed servings (2 kg or 2 L) restore 100 percentage
points of Hunger or Thirst. Serving size remains scaled by body mass; carried
load is excluded. MAP01's six dining tables start with their full capacity:
94 real rations, allocated once without replenishment after consumption.

The approved resting-weight damage is active:
`Hmax * 0.10 * max(0, (supported mass + carried load) / capacity - 1)` per second.
Native resting support is required; suspended objects do not count. Stacks
transmit their real mass and share it among supports. Fractional damage is
preserved. Native ceiling damage remains a percentage per engine pulse.

MAP02 is a three-section maze with 147 rooms, 96 Mandingas, 45 traps, three
keys, 39 chests and 195 distinct equipment pieces spanning all three tiers.
It contains 120 food and 120 water rations. The final chamber holds a Zupay,
the Ace of Cups and the coast exit. The Ace uses the existing Tarot back
artwork and its own name/reward: +1 to the three social attributes and +1%
collection bonus. No new Major Arcana passive is assigned in this patch.

The full 0h base was recovered from commit
`1ed8e8d543ab19dbc1ca38dc438e61df5363681e`. ZScript compilation, map loading,
inventory transactions, key-controlled doors, resource arithmetic and the
flail rotation were exercised in **GZDoom g4.14.2 on Linux**, using Freedoom
0.13.0 solely as a development IWAD. Native screenshots are in
`assets/first_person_v7/`; validation records are in `assets/validation_0i/`.
On 2026-09-23 the author accepted the 4.36.0i maze, save/load and table checks.
Bow appearance is accepted. The additional 10-degree counterclockwise flail
rotation is implemented and engine-verified in 4.36.3
([#9](https://github.com/damiancurti/Caelum-Argenteum/issues/9)); the author confirmed
CA-4360I-VISUAL-01 passed on 2026-09-23.
The empty-bow stall is corrected in 4.36.2 (#8); focused native Windows evidence
and the author's 2026-09-23 pass confirmation for CA-4362-BOW-EMPTY-01 are
recorded in HISTORY.
Engine binaries, IWADs and development automation are not included.

`netevent ca_debug_hazards_report` and `netevent ca_debug_maze_report` identify
**4.36.3**. Use the repository instructions below and the root pending-test queue
for focused checks; no external patch-test upload is required.
The author's acceptance of the carriage, transitions and other 0h tests is
preserved. The broader unfinished 4.36 physics roadmap remains in PROJECT.md.

## Implemented

- Revised first-person grips, two-handed heavy weapons and shared holstering.
- Original fallback fists, a dorsal left bow grip and smaller ground bullets.
- Aimed Use hints and a repeatable, occupancy-checked gallery reset lever.
- Visible native hub travel transitions with captured departure views.

- Original two-state column/wall lever, larger bull and spherical hazard rocks.
- Single-use explosive mines, safe local teleport traps and native ceiling crushers.
- Carriage crossfade, Fool burn, ship melt, and supplied event audio.
- First-person composites for 19 additional weapon families in three tiers.
- Pressure-triggered trapdoor, persistent open pit, native falling and stairs.
- Single-use rock releases, horizontal/vertical impacts and environmental origin.

- Monthly campaign calendar, event details and persistent recurring schedules.
- Calendar transactions for real currency and material cargo, quest deadlines,
  routine/siege phase adapters and off-map resource recovery.


- Measured coastal routes, native walking-speed conversion and 16/8 travel days.
- Read-only quotations, explicit confirmation, real provision consumption and
  saved records; unfinished servings continue after arrival.
- Camp needs/lucidity, carried sleeping bag, shortage/death projection, common
  clock advancement and arrival weather without reseeding.


- Mass-scaled food with saved serving doses, actual digestion and automatic meals.
- Native port/shore test maps with four directed routes, covered dining refuges,
  swimmable river volumes and the author's texture expansion.
- Buenos Aires confirmed for the sewer/coastal network; seven-location Journal.

- Persistent regional weather and position-dependent shelter, using the same
  campaign clock at normal speed and x105; saved seeds prevent rerolling.
- Nine attributed SMN station datasets, reusable offline generator, map region
  marker and read-only regional queries. Unknown maps remain explicitly undefined.
- Two visible native seats in each eastern bedroom, with safe saved-layout repair.
- Unified volume-based water ration weight for inventory, Box and purchases.

- Table serving height accounts for CorrectPixelStretch; saved displays adjust
  without recreating their real inventory items or changing the accepted designs.
- Revised mansion furniture and northeast workshop placement, with native door
  passage checks. Save migration preserves actor identity and table contents.
- A real Rulo practice target is present and recovered if missing. Quest flags,
  progress, ammunition, rewards and the bull encounter retain their rules.
- Limbo uses saved fractional clock steps for its 1:1 calendar. T accelerates
  the local clock and personal simulation only during valid rest or crafting.
- The journal no longer maps T to the old +10-minute debug operation.

- Food digestion: actual Hunger recovery / 4 is deducted from Sleep, clamped
  at zero. This applies to inventory and table food through their shared pulses.
- Independent saved food/water serving sequences while seated, compatible with
  ordinary and accelerated rest. No extra serving is spent while one is active.
- Storage expanded to 4/18/60 real objects; original procedural plates and cups
  replace the previous pickup sprites. Older 0g table contents load correctly.
- Four furnished bedrooms, a cave-room dining set and an upstairs banquet table.
  Untimed Limbo furniture sessions use local time and can fast-forward
  together with the local campaign clock.
- All crafting stations use 150% of their pre-0h dimensions; 26 mansion
  stations relocated downstairs, all 12 upstairs retained and all five networks
  connected. Existing actors migrate once; their references are preserved.

- Optional, saved x105 time advancement: at most 104 extra one-tic steps after
  each ordinary tick. It is bound to the current rest or crafting station/task,
  stops on completion or invalid conditions, and returns control between batches.
- Shared personal rates, known regeneration powers and crafting timers; no
  `i_timescale` dependency. Unsupported powers, hazards, nearby projectiles,
  hostiles and induced sleeping actors prevent the accelerated path.
- Three original table models with complete 2/6/12-chair layouts in MAP03,
  native collision, item ownership and seated consumption. They grant no supplies.
- Furniture pose facing plus TEXTURES rotation aliases fix front/back and
  side views without changing the original PNGs or crouch locomotion frames.
- Sleeping, including class-induced sleep, drains 10 Lucidity/s, clamps at zero
  and suspends recovery. Lucidity stun alone cannot end voluntary sleep.
- Arcanist User4 now casts the authored area Sleep: 10 seconds, hit wakes,
  60-second reuse and confirmed base cost 1000 Anima with the existing modifier.
  Its 1280-MU base radius is shared with seal channels and uses ability range;
  nearby allies are affected too, while the caster and unseen targets are excluded.


- One reusable native Inventory sleeping bag, shown in All and Keys/key items.
  It can move through personal inventory, the Magic Box and the world pickup
  path. Enter withdraws a stored bag first; a second activation opens rest.
- Choosing a duration deploys a temporary original cloth model. The owned bag
  is neither consumed nor recreated. Completion, cancellation and interruption
  remove the model and restore the player's view without moving their position.
- Native volume and perimeter checks require free, level space. They preserve
  the player's collision dimensions. A failed deployment keeps the bag.
- Chair x2, sleeping bag x3 and bed/cot x4 affect natural Health/Air regeneration
  and Hunger/Thirst drain while the matching rest session is active. Existing
  critical-resource healing restrictions and resource maximums still apply.
- Regeneration-related food/water expenses also honor the drain reduction per
  time. Boosting recovery by F while reducing its expense by F requires a cost
  per recovered point of base cost / F²; passive drain is simply base drain / F.
- No comfort multiplier applies to Sleep, Anima, Lucidity or medicine pulses.
  Pending breathing recovery after immersion also uses the active factor; its
  normal three-second timing remains the baseline outside comfort rest.
- Read-only rest diagnostics identify 4.35.0j and report the active factor.

- One original wooden chair and one cot per sewer map, placed on first entry
  or when loading an older save. Repeated preparation keeps one pair.
- Native Use opens the existing conversation menu with explicit durations.
  Starting checks reach and collision again after the reply closes the menu.
- Furniture temporarily yields collision to its occupant; exit checks the
  entry point and nearby alternatives. Fully blocked exits allow walking out
  before solid collision is restored. Player height/radius remain unchanged.
- A native SpectatorCamera follows and clips against the environment. Looking
  rotates the view while the body keeps its seated/lying orientation. Previous
  view direction is restored on normal exit; another system's camera is kept.
- Saved rest data includes furniture, entry, visual offset and camera state.
  Removing/moving the furniture interrupts; quintessence does not move it.
- Original procedural OBJ furniture reuses existing project textures. The
  rest panel leaves the central scene visible and shows its camera controls.

- Literal state-label lookups for both the initial rest pose and its subsequent
  visual update; the selected lying/seated poses are unchanged.
- The catalogue identifies MAP01 as Limbo with a 1:1 local clock; every other
  map keeps the accepted rate of one game hour per 180 simulation seconds.
- Historical validation accepted hotfix labels such as 4.35.0d1. Current headers
  require MAJOR.MINOR.PATCH with an optional lowercase letter for author-requested
  documentation/hotfix patches (for example 4.36.1b); historical labels remain valid.
  Resource, documentation and localization checks are retained.

- Hidden native Inventory stores the rest mode, duration, elapsed tics, origin,
  input-release latch and last observed world-clock pulse. Repeated callbacks
  cannot credit the same tic twice; completed/interrupted sessions are terminal.
- Sleep gradually restores Sleep instead of passive depletion. Wait retains
  ordinary depletion. Hunger/Thirst and existing regeneration continue. Only
  critical fatigue damage is suspended while sleeping; other damage remains.
- Dry ground, a confirmed single-player character and compatible activity are
  required. Damage, combat, movement, immersion, map changes, low reserves or
  incompatible activity interrupt the session. Travel rejects active rest.
- Existing lying/seated world poses and a translucent progress panel are reused.
  Q/Pad B gets up; movement or action cancels; TAB gets up and opens the journal.
  Escape preserves native pause. Use release remains native and is not latched.
- Native USDF offers Sleep/Wait with explicit durations, plus optional reserve
  presets. Opening, loading or travelling grants no resources. Limbo rejects
  these timed ground/bag sessions; its furniture offers untimed sessions while
  the campaign clock advances at 1:1.
- Read-only `netevent ca_debug_rest_report`; explicit `ca_debug_rest_hit` asks
  for one point of native impact damage to check interruption in empty sewers.


- Civil calendar rules for years 1–9999, with month lengths and Gregorian leap
  years. A native hidden Inventory stores a date/time anchor to the existing
  clock; no duplicate ticker or operating-system time is used.
- Campaign epoch: 1889-11-03 09:00. MAP01 uses one stored world-clock unit per
  twenty personal steps, retaining its fractional remainder. Every other map,
  including uncatalogued test maps, uses one clock unit per simulated tick.
- One-time migration anchors previous saves to the campaign epoch at their
  existing clock value. Old trial dates are discarded; elapsed counters and
  journey stamps are preserved. Previous time spent outside Limbo is unknown.
- Separate saved campaign and diagnostic anchors share the same clock. World
  labels tests explicitly; normal calendar queries always return the campaign.
  The monthly southern seasonal labels remain a test convention. Local climate
  uses regional monthly observations and synthesized fronts; body exposure and light changes
  remain future work.
- `netevent ca_debug_calendar_set YEAR MONTH DAY` assigns a test date;
  `ca_debug_calendar_edge` prepares midnight after 12 simulated real seconds
  at either local rate. Neither changes the campaign, clock, resources or travel stamps.
  `ca_debug_calendar_report` reads the campaign and optional preview;
  `ca_debug_calendar_clear` returns World to the continuing campaign date.
- MAPINFO enables non-pausing conversations in every project map. The shared
  conversation menu also omits the native delayed pause for older saved maps.
  Existing replies, Q/Back, capture presentation and ordinary menus are retained.

- Native Inventory stores completed days and the current day's simulation tics.
  A stateless StaticEventHandler advances it once per simulated tic after the
  single-player character is confirmed, applying the local map rate. Previous saves also
  receive the clock and one-time campaign initialization when needed.
- Integer counters preserve hour/day boundaries without accumulated fractional
  error. The scale comes from the same accepted constants used by survival.
- World displays elapsed recorded days and HH:MM, including a 1:1 rate notice
  inside Limbo. Its next line displays the civil date and season.
  Player needs, regeneration, damage and cooldowns retain their personal timers.
- Voluntary native pause stops the clock. Caelum conversations and the journal
  allow simulation to continue; crafting retains its existing activity rules.
- New sewer departures and arrivals have saved timestamps. Previous journeys
  keep their sequence/status without invented timestamps; arrival reconciliation
  does not overwrite an already resolved arrival's time.
- Read-only reports: `netevent ca_debug_time_report` and the extended existing
  `netevent ca_debug_travel_report`. Neither command creates or advances time.


- The journal forwards the release of the key bound to +use to the engine,
  so closing the station with Q allows the next Use press to reopen it.
- Optional seal preparation reuses or grants one T1 quintessence seal, equips it,
  refills adrenaline to the character's existing maximum and explicitly resets
  the test cooldown. It neither activates the seal nor starts combat.
- Optional crafting preparation teaches the existing handle component recipe
  and tops up wood to one x10 batch (40 material units). Repeating preparation
  does not add more when that quantity is already owned. Carry limits apply.
- Native stations use existing models and form a separate proximity network.
  Real Use selects Handle T1, x10 and 100% efficiency after recipe preparation,
  leaving enough time to exit the station with a real task pending.
- Existing saves acquire the stations once. Loading, travelling and hub return
  do not grant supplies, refill adrenaline or duplicate the station network.


- Native USDF caravan selection and explicit confirmation for the six existing
  directed sewer connections. The menu is optional and names itself as a trial.
- A shared departure service validates the character, route, current activity,
  destination availability and pending trip before calling native ChangeLevel.
- Native Inventory records the latest journey, mode, sequence, arrival and
  interruption counts. An arrival resolves once at the expected destination;
  an interrupted departure never retries automatically or credits another route.
- World displays the latest journey. The read-only console report is available
  through `netevent ca_debug_travel_report`. Original arrows and PgUp/PgDn remain.
- Native saves preserve the new record and the selected conversation page.
  Old saves acquire no fabricated journey history; their next real trip starts it.

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
  map. Its recorded-data display retains the accepted navigation; C opens the
  separate caravan trial in sewer maps.


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
  the minor base separately. The Fool and the Ace of Cups are obtainable in
  current content; the remaining cards need their planned acquisition content.
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
  seven maintained documents and issue-based patches delivered through linked PRs.

## Planned

V4.35 now includes the accepted world clock/calendar, rest furniture/camera,
sleeping bag, comfort factors and the initial safe-area accelerated path.
The regional climate and shelter service builds on the accepted 0k adapter.
V4.35 is accepted and closed through 0q. V4.36 includes the trapdoor, rocks,
approved magical traps and ceiling crusher. Per the author's 2026-09-23
clarification in #8, the existing crushing ceiling and native elevator cover
moving sectors. Avalanches are deferred until additional maps; damaging
surfaces until environmental temperature effects (no acid/lava requested).
These three items no longer block 4.36. Rams, catapults and remaining
integration/save/reset checks still do; the Tarot and demo gates remain.
Coastal timed journeys are implemented in 0n, event timing and the calendar in 0o. Buenos Aires is confirmed for MAP02–07 and
subsequent maps; future regions can use the existing explicit map marker.
The fast path does not simulate arbitrary AI, physics, doors or third-party
Thinkers. Extending it outside designated safe areas requires those systems'
explicit timing contracts. The 8-game-hour full Sleep recovery rate is confirmed.
Fares, freely drivable/additional vehicles, route incidents and a travel minimap remain future content.
The author now requires a complete three-map campaign slice before the V4
playtest export. Further campaign content and inherited expansion remain V5.
Of the authored class abilities, only Arcanist Sleep is added here; the remaining
class abilities and racial toggles stay in the V5 abilities block.
Peregrino uses Amparo: 50% less environmental damage for the player and nearby
allies for 10 seconds, with 60 seconds of reuse and a trial base cost of 1000 anima.
Future class area abilities use the shared 1280-MU seal-channel base radius.
Automatic conversation cancellation on damage was suggested and remains pending.
Four new prisoner affiliations, +10 own-faction reputation and coins worth twice
the mean normal purchase price of T1 weapons at the rewarded character's
equipment size per successful rescue are defined in the roadmap. SYSTEMS records
the purchase-price formula; rank thresholds and cross-faction relations still
require authored design.
The attribute audit is deferred by the author; the current rules stay accepted.
Follow PROJECT.md for the remaining scope. Potable-water collection is implemented. Treatment of unsafe water remains undefined. Bullet crafting still needs its material composition and process
defined; the existing 3 g bullet mass is unchanged. Bolt crafting is implemented. Food/water, Air/movement, load management and pool breathing are now
implemented. The author now authorizes additional sewer maps for system
testing. MAP02 now contains the authorized maze and encounters; MAP03–05
retain their test spaces. The new three-map playtest slice is planned in
[#16](https://github.com/damiancurti/Caelum-Argenteum/issues/16); test spaces do
not count as completed campaign maps. The existing port is MAP06.
Material coverage uses finite 100% allowances for the chosen loadout and learned seals.
Additional equipment by class and special post-awakening resource values await
author design. The accepted exit still preserves current resources and the first
crafted weapon only, inside the Box.

The established sequence continues through V4.34 world/travel foundations,
V4.35 calendar/weather/events, V4.36 physical hazards and V4.37 Tarot/Trucazo.
New issues #10–#15 plan T1-only loot, a four-section sewer with cells/beds and
repair refuges, 192 rats alongside 96 Mandingas, four recolored prisoners,
persistent escorts/port rewards and Tarot fronts. Issues #18–#21 add siege
assets, breakable actor gates, rams and catapults. See [TASKS](docs/TASKS.md)
and the current author-roadmap section of [PROJECT](docs/PROJECT.md). These
features are not included in the current 4.36.1b release (same 4.36.1 gameplay baseline).

After V4.37, complete and accept three campaign maps covering the prologue,
El Loco and two distinct Minors, then verify the exported
playtest for other players (#17), including installation, controls, the full
route, saves and issue reporting. The mansion -> maze -> port route is
confirmed: the third map is a demon siege, whose commanding Zupay holds
the second Minor (exact card pending). Freed prisoners use source-character
combat stats and follow/fight until their living extraction before the MAP02
boss; they leave for the port and do not participate in that boss fight. Then
**V5.0 reorganizes programming modules**; V5.1 adds thermal exposure and later
V5 work expands persistent resources and marine biomes. Remaining weapon
art, loot, faction consequences, perception/formations, general world sieges, co-op/PvP,
world persistence and the complete campaign are assigned to V5 in PROJECT.md.
The playtest export is a separate milestone from the final independent release.

## Pending validation

The author confirmed CA-4360I-VISUAL-01 passed after the 4.36.3 correction on
2026-09-23. [pending_test.txt](pending_test.txt) is now empty. The 4.36.2 bow
check also passed on the author's confirmation. On 2026-09-23 the
author confirmed zero validator errors, successful rebuild/launch and both
4.36.1 diagnostic headers. That completed
test and the accepted maze/save-load/table tests are recorded in HISTORY.
The #8 bow correction is engine-verified and author-accepted (CA-4362-BOW-EMPTY-01).
Long-term encounter/provision balance and unfinished 4.36 systems are development
work in PROJECT/TASKS, not additional author checks for this patch.

## Build and run

GitHub is the primary working source. To obtain a complete checkout:

```powershell
git clone https://github.com/damiancurti/Caelum-Argenteum.git
cd Caelum-Argenteum
```

For an existing checkout, close GZDoom, run `git status`, and preserve any local
work before updating the intended branch with `git pull --ff-only`. A release
under review is obtained from its linked PR branch; check README's current
version after switching. Do not merge an old patch ZIP into this checkout.

From the repository root, using the author's installed Python:

```powershell
python validate_project.py
```

Success prints JSON with `"version": "4.36.1b"`, `"documents": 10`, and
`"errors": []`, returning exit code 0 (`$LASTEXITCODE` in PowerShell or
`echo %ERRORLEVEL%` in Command Prompt). On failure, report the full output,
command, Python version (`python --version`) and current commit (`git rev-parse
HEAD`) in the issue. If `python` is not recognized, make the installed interpreter
available on PATH or invoke its full path; do not regenerate assets to fix a
documentation error. The validator is read-only and uses Python's standard library.
For maintained docs longer than 5,000 words, query
[DOCUMENT_INDEX.md](docs/DOCUMENT_INDEX.md) first (see
[GZDOOM_DEVELOPMENT.md](docs/GZDOOM_DEVELOPMENT.md)); regenerate it with
`python build_document_index.py` after an indexed source changes.

Rebuild the PK3 after updating; launching an old PK3 keeps old code. The commands
`netevent ca_debug_hazards_report` and `netevent ca_debug_maze_report` must identify
**4.36.1b**. The 4.36.1b documentation patch requires no new campaign or save migration.

Double-click **run_dev.bat** to build and play with the supplied machine's
existing engine/IWAD paths. Check `GZDOOM_EXE` and `DOOM2_IWAD` in that file on
another machine; supply your own development dependencies. To build independently,
from any working directory:

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
| [GZDOOM_DEVELOPMENT.md](docs/GZDOOM_DEVELOPMENT.md) | Engineering orientation, build/launch, reusable patterns and verification discipline. |
| [KNOWN_PITFALLS.md](docs/KNOWN_PITFALLS.md) | Compact register of verified lessons and unresolved defects with stable IDs. |
| [DOCUMENT_INDEX.md](docs/DOCUMENT_INDEX.md) | Generated section/line locator for docs over 5,000 words; search before reading long files. |

Use English code, identifiers and maintained documentation. Gameplay explanatory
comments remain Spanish; modified tooling uses English help, diagnostics,
comments and docstrings. Preserve bilingual game localization. Prefer native
engine features and shared authoritative systems; protect accepted gameplay
and author-owned lore/balance. Keep useful source assets and required license
notices. Plan a concrete issue in Work; implement and test in desktop Codex on a
focused branch; review the linked PR and evidence; record author acceptance when
required. One issue defines one patch, with several focused commits if needed.
ZIPs are optional exports. V5 source refactoring
must preserve save/input compatibility through incremental changes.

Run `python validate_project.py` before preparing a release to check version,
documentation, structure, Caella translations, station models and audio references. Development engine/IWAD files,
test observers and archives are not part of the playable PK3 or source delivery.

Patch versions use MAJOR.MINOR.PATCH with an optional lowercase letter for
author-requested documentation/hotfix patches: 4.36.0i -> 4.36.1 -> 4.36.1b -> 4.36.2 -> 4.36.3.
Implementation commits and later acceptance do not each create a new patch.
Historical labels stay intact; PROJECT records the current roadmap and the
author-approved three-map playtest requirement. All seven docs and AGENTS declare
a current version; the two engineering guides and the generated index inherit
this README's release.

Carry author checks forward in `pending_test.txt`. After explicit author pass
confirmation, record the stable test ID, originating version/issue, result,
confirmation date and qualifications in that release's HISTORY entry, then
remove only that pending entry in the same update. Partial, failed and unconfirmed
checks remain. Static success, engine success, merging and issue closure are
distinct from author acceptance. Keep the queue tracked and empty when all tests
are confirmed; it contains no completed results or general backlog.
