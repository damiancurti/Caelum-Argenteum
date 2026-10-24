# Caelum Argenteum — Current systems and rules

Documentation version: **5.8.0** — 2026-10-23.

## Connected-water feasibility boundary (#414, 5.8.0)

The private validation_580 fixture uses two horizontal swimmable 3D floors of
equal area. Opening a native blocking line permits a conservative level transfer;
closing it stops both planes. `Sector.MoveCeiling` receives plane-distance
coordinates from `SecPlane.PointToDist`, preserving native attached volumes.
A third unconnected pool and the dry walkway are controls. Its IDs, dimensions,
levels and rate are diagnostic fixture data, not approved campaign balance.
The map-local event handler retains a revision-1 binding, gate state and native
sector references through saves and hub return. Initialization visits the eight
fixture sectors once; ticking touches only the two connected control sectors.

Production water remains #408/#409: source quality currently reads the actor's
sector, so metadata on a 3D-floor control sector is unidentified. The prototype
records this limitation without silently changing quality or claiming mixing.
The author approved reusing the container contamination union and locating the
first connected installation beside the mansion pool. No campaign water-volume
schema, replenishment, drainage, concentration rule,
new map geometry or real-time offline progression is introduced. A generic
production controller needs the author's remaining per-source choices.

## Reusable mates (#472, 5.7.14)

The approved table is `assets/generators/mate_vessels.json`; the deterministic
export is `CaelumMateData`. Three independent native consumable identities
append at 17-19, recipes at 198-200 and dry gourd material at 104. No old ID is
renumbered. Recipe-book revision 14 preserves existing knowledge and adds the
three initially unknown recipes; the new material quota schema is additive.

| Vessel | Nominal / useful water | Yerba | Empty mass with fixed bronze straw | Inputs at 100% efficiency |
| --- | --- | --- | --- | --- |
| Gourd | 100 / 60 mL | 20 g | 25.866 g | 6 g dry gourd + 20 g bronze |
| Silver-clad algarrobo | 250 / 150 mL | 50 g | 118.414 g | 79 g wood + 21 g silver + 20 g bronze |
| Gold-clad algarrobo | 500 / 300 mL | 100 g | 197.482 g | 122 g wood + 57 g gold + 20 g bronze |

Load only an empty mate with no yerba; loading consumes the listed grams and
starts twenty hot uses. Pour potable water from an owned, unboxed, unreserved
bottle/canteen, retaining the source. Water fills only the useful volume and
never resets the counter. Drinking consumes all current water. At 60-85 C it
hydrates and supplies 0.1 times the nominal hydration percentage of maximum
Health, Anima and Air, even at full Thirst. Each such use spends one cebado.
Below 60 C only hydration applies, without spending a use. Above 85 C drinking
is blocked. After twenty hot uses, washed yerba still permits hydration but no
resource recovery. Discarding yerba returns no material; replacing it requires
emptying any remaining water. No optional herbs are implemented.

Every dose schedules ten one-second native pulses, reusing the existing water
recovery duration. A new dose adds its remaining pulses without erasing or
postponing an older dose. All resources cap at their current maximum; fractional
Health accumulates within the recovery effect. Contents, temperature, remaining
uses and pending recovery serialize and travel in native inventory. The existing
single carried item per vessel type convention remains; chests and vendors keep
used mates individually instead of merging their contents into fresh stock.

The open-hemisphere approximation uses 5 mm gourd, 6 mm algarrobo and 0.1 mm
exterior metal. Densities are 124/760/10490/19300 kg/m3 (gourd/wood/silver/gold).
Conductivities are 0.07/0.17/429/318 W/(m K), heat capacities 1500/1500/235/129
J/(kg K). Botanical heat capacities and gourd density/conductivity are approved
design approximations, with sources and qualifications retained in the JSON.
Water and body/coating heat capacity participate in mixing; cooling uses the
existing ambient/wind film at the open mouth and through the wall. It approaches
ambient without overshoot. The fixed 20 g bronze straw is included in mass and
recipe; separate straw heat transfer, evaporation and wall absorption are outside
this simplified model. Clock gaps use the current sampled environment, without
reconstructing historical weather. Cooling is lazy at interactions plus one
bounded lookup per carried mate type per second, with no global actor scan.

Workbench + Fine Tools are required; clad mates also require a Jeweler Bench.
Normal complexity, existing efficiency waste, Dexterity, learning and practice
apply. Provisions stocks three of each mate and 1 kg dry gourd at 2 copper/g;
the library has ten of each recipe. Finished prices and replenishment use the
existing recipe and merchant rules. Revisioned catalogue addition preserves
previous stock, wallets and deadlines. Used loaded mates are never a fresh
restock template. Selecting a mate in Inventory exposes Prepare (R); the panel
lists load, source selection, pour, drink, empty and two-press discard controls.
Quick use drinks a ready mate without destroying the vessel.

## Chemistry batches (#471, 5.7.13)

On 2026-10-23 the author approved shared barrel access: any character may collect
or discard its contents. One batch still occupies each barrel; a new batch
requires the approved Chemistry/Workbench network. Losing that network does not
stop fermentation or prevent finished-product collection.

Approved recipe per litre: 250 g molasses + 800 mL potable water + 5 g yeast yields
1,000 g fermented intermediate, occupying 1 L for 72 world hours. Whole-litre
multiples scale ingredients/output/volume, not duration. Dexterity does not
shorten fermentation. This is a simplified design yield including process losses,
not an empirical fermentation protocol. Inputs are spent on starting, cancellation
discards the mixture, and partial collection retains the remainder and occupancy.
The state model, authoritative transactions and dedicated barrel UI are implemented;
final integration/presentation verification and author acceptance remain pending.

Additional author approvals (2026-10-23), recorded in chemistry_recipes.json:
attended Chemistry converts 1 kg wood to 250 g charcoal in 24 world hours (wood
includes its own fuel), 1 kg cane plus 172 g mineral coal to 100 g molasses in
20 world minutes, and 1 kg fermented intermediate plus 258 g mineral coal to
100 g abstract medicinal alcohol in 30 world minutes. These fixed design yields
and times are not shortened by Dexterity.

Small consumables use: medikit = 5 g cotton + 10 g alcohol + 2 g marcela; energy
drink = 200 mL potable water + 10 g yerba + 20 g honey or sugar; Anima potion =
200 mL potable water + 2 g irupe or lirio. Medium/large multiply active inputs
by 2.25/5, rounded up; water and sweetener stay constant. Preparation takes
10 minutes per unit before the existing Dexterity reduction, without extra fuel.
Effects, doses, masses and abstract containers stay unchanged. Intermediate and
consumable base prices derive from ingredients/fuel plus the existing 25% markup;
ordinary merchant margins apply afterwards, superseding their older fixed prices.

MAP03 Provisions imports saltpeter/sulfur (1 kg each, 500 copper/100 g), sugar
(1 kg, 2 copper/100 g) and yeast (100 g, 5 copper/100 g), using existing margins
and 0.1% target-stock daily recovery. New recipes use existing learning, with ten
copies each in the library. Ammunition uses the abstract table below; these
approvals do not define real propellant formulations.

#The author approved recipe-based renewal of the previously finite kits and nine
consumables on 2026-10-23. Keep existing targets and stock, with future deadlines
only at additive catalogue migration. Merchant quotes convert each operation to
the civil calendar using its own clock; Chemistry uses approved world seconds,
while pre-existing operations retain their original timing. Fixed chemical
processes ignore Dexterity/practice; preparation quotes remove Dexterity only.
Food/water rations remain finite.

## Abstract ammunition supplies and transaction rules

A prepared reagent set (10 g, 20 copper) yields one abstract 10 g charge. One
charge plus a sealed carbine/shotgun component set yields ten compatible kits.
Sealed sets weigh 390/440 g, preserving 40/45 g kits and ten-cartridge assembly.
Each preparation takes 10 world minutes per lot before Dexterity reduction.
Sealed-set anchors equal ten legacy kits; charge cost and the 25% processing
margin establish new kit values, followed by the existing cartridge markup.
Provisions supplies these three inputs using existing kit-stock counts and import
recovery. This is explicitly abstract game accounting, without chemical ratios.
Identical consumables use their cheapest ingredient recipe for a single market
price; each crafting variant still consumes its own approved inputs.

Attended tasks reserve materials and potable water in carried containers, spend
only on successful completion and release reservations on cancellation. The
reservation prevents drinking, refilling, emptying, dropping, storage or sale of
the selected water containers. Output and capacity are revalidated atomically.
Chemical processes are explicit station tasks; direct equipment plans cannot
silently execute a fermentation or a heating step. Existing kits can still be
assembled into cartridges through the accepted shared crafting path.

New materials append at 92..103, recipes at 176..197, with recipe-book revision
13. Earlier knowledge and supplies survive; new recipes begin locked. Imports
and library entries are appended idempotently without replenishing old stock.
The fixed barrel's map/position and a shared serializable batch object identify
its contents. Each participating character retains that same object in its
travelling ledger; absent-map progress needs only an absolute world deadline.
Queries are interaction-local or bounded by players/owned inventories, never a
periodic global actor scan. Existing multiplayer clock restrictions remain;
shared transaction tests do not establish two-client calendar/session support.

## Fermentation Barrel (#487, 5.7.12)

The author approved a separate fixed barrel of wood with metal hoops, connected
to Chemistry in the existing Workbench-backed station network. This is an
operating dependency, not a construction requirement. The infrastructure stage required that network to open. The later #471 stage
opens its dedicated batch panel even while disconnected, so the user can inspect,
collect or discard contents; starting still requires the network. Other stations
retain their rules. Fermentation belongs to this barrel; heating, distillation
and other chemical processes remain at Chemistry. Unattended fermentation and collection at the original barrel are implemented
in the separate #471 stage above; they were not part of the infrastructure patch.

Approved dimensions: 60 x 60 x 72 units, fixed, no construction recipe.
The new barrel explicitly enables solid collision; the inherited station base
does not set SOLID. Existing accepted stations retain their original flags.
Positions: MAP01 (1200,448,0), group 2; MAP03 (-584,1472,0), group 0. Capability 13 and editor
ID 18014 append after Chemistry without changing old IDs. A separate revision-1
map roster installs one barrel in new and old saves, retries locally when blocked
and does not reissue a removed installed barrel. One typed roster lookup per
map load is the bounded initialization exception; there are no periodic global
actor scans. Network traversal reuses local blockmap queries.

Capacity is derived from the visible body, not its collision box: the approved
large tun has 3 cm radial wooden walls and top/bottom lids, with 20% fermentation
headspace. Using CaelumPhysicsUnits (32 map units/metre), the generated rotational
body profile gives 4,252.967 L internally and 3,402 usable whole litres after
rounding down. The faceted model approximates this rotational profile. Its maximum
body diameter is 1.734375 m and body height 2.15625 m, excluding the top bung.
The target panel shows usable capacity. fermentation_station.json is the shared
authority for approved placements, mesh profile and physical assumptions; the
generator reads the existing unit conversion rather than duplicating it.

## #471 approved fermentation lifecycle

Author decisions of 2026-10-23: one batch per Fermentation Barrel, including a
partial fill within its approved working capacity (#487). The barrel stays
occupied until the product is collected or the batch is emptied. Starting the
batch consumes its ingredients. Cancelling after that discards the mixture
without returning ingredients; cancelling before starting consumes nothing.

An already-started batch continues fermenting if the barrel loses its Chemistry
connection. This explicitly supersedes the proposed pause-on-disconnection rule;
it also continues while the player is away or on another map. Starting still
requires the approved station network. Finished product may be collected even
without a Chemistry connection. Partial withdrawals are allowed: the remainder
stays in the barrel, which remains occupied until emptied. These subsequent
author approvals resolve collection access and partial withdrawal; recipe quantities, yields, timings/fuel and economy are now specified above.
The original cartridge acceptance remains separate from this batch implementation.

## #479 support implements and 5.7.8 integration

Quintessence is exclusively support. Offensive Wand/Bell retain their attacks;
Scepter inherits the old offensive Book and Orb the old offensive Statuette,
including charge, costs and tiers, for Fire, Water, Earth and Air. Numeric item
IDs 18/19 remain stable. The author explicitly authorized discarding existing
offensive Quintessence test items; save files are never deleted. Other items
retain ID, tier, element, wear and learned recipe indices. Retired Quintessence
recipe slots remain reserved; new recipes append without reindexing old data.

| Support implement | Scope | T1 Anima | T1/M mass | Body |
| --- | --- | --- | --- | --- |
| Book | Enemy area | 70 | 6 kg | Plant fiber |
| Censer | Allied area / self | 70 | 5 kg | Bronze, Bell manufacturing rules |
| Statuette | Allied single / self | 100 | 8 kg | Carved wood |
| Ritual effigy | Enemy single | 100 | 8 kg | Carved wood |

Support selectors occupy native slot 0. The visible aim point receives the
instantaneous effect after the existing 14-tic preparation cycle and Eloquence
modifiers. Area radius reuses 128 map units and existing ability-range scaling;
local blockmap selection checks distance, teams and sight. Beneficial secondary
attack targets the caster; curse secondary is inert. Support has no charge.
Costs use T2 x1.6/T3 x2.5 and the existing Eloquence reduction.

Each application adds 1% x M2 per second and refreshes duration to 1 s x M2:
Charisma for curses, Empathy for benefits. M2 is 1 at 0 and 4 at 100; effective
levels remain uncapped. Each implement has its own shared, uncapped stack;
different casters add to the same implement, with the most recent caster used
for damage attribution. Book/Effigy health contributions sum, as do
Censer/Statuette. Opposing effects coexist. Only Statuette/Effigy modify speed
and damage: F=1+p/100; benefit multiplies movement/dealt damage and divides
received damage, curse does the inverse. Movement includes jump, swimming,
flight, dash and NPC movement; independent action clocks are unchanged.

Health integration samples the recipient's current maximum, retains fractional
HP and elapsed seconds, and delivers whole HP at second/expiry boundaries.
Support damage factors are integrated before expiry, once, so the last pulse
keeps its effect. Healing caps at current maximum; effects cannot resurrect.
No base attribute or speed is rewritten. Receiver inventory state persists
stacks, duration, fractions and attribution with idempotent revision 1.
Native lethal damage can synchronously remove that inventory; the tick rechecks
its owner after damage and stops before processing further roles. No save fields
or revision numbers change in this lifetime correction.
Existing Quintessence seals retain 85% of curse intensity, including secondary
modifiers; duration and benefits are unaffected. No new resistance distribution
is introduced. Selection is local; no global per-tic actor scan is added.

Fabrication keeps 90% body / 10% essence. Support uses Quintessence; Scepter
(6 kg T1/M) and Orb (8 kg) use wooden bases and the four offensive elements.
Existing XS/S/M/L/XL factors 0.5/0.75/1/1.25/1.5, T2/T3 mass factors 1.5/2,
silver/gold details, learning and production times apply. Workbench and Essence
Altar are required, plus Globe at T2 and Master Bench at T3. MAP03 magic shops
stock one T1 piece per type/size; libraries stock ten recipe copies per tier.
New shop entries append without resetting old money, stock or production.
Prices derive from current recursive manufacturing values and commerce margins:
T1/M purchases cost Book 741,094, Censer 668,335 and Statuette/Effigy 971,250
copper each. New component recipes are 173-175; support recipes are 169-172.

Runtime is integrated; the author's sprite correction restores accepted Book/
Statuette art and paints the four new implements. Native primary dispatch uses the
shared magical classifier; support exposes no projectile spread or critical
chance. The full package passed 176 assertions plus two baseline/rollback checks,
including native input, old item migration and active-effect saves. Arcanist and
Priest keep offensive Scepter/Orb starters. NPC numeric aliases preserve their
existing offensive actions; no new NPC support AI is introduced. CA479-01 is
pending, with manual checks/questions postponed during the author's absence.
Historical offensive Quintessence descriptions below are superseded here.

## Aimed-target panel (#481, 5.7.7)

The permanent panel is centered at the top of gameplay. It names the aimed
world object and lists existing applicable interactions with the current
bindings, including doors, storage/maze chests, furniture, crafting stations,
merchants, pickups and map transitions. Physical actors use the native sight
trace; nearby actionable linedefs use a local blockmap query constrained by
the same occlusion distance. Native player missile range bounds identification;
actions retain their existing Use range and state checks. Looking never calls
Used, opens a menu, spends resources or activates a line. Invisible collision
helpers resolve to their visible owning object; invisible house portals remain
identifiable as map transitions. Non-interactive engine helpers are omitted.

For combatants, Health, Anima, Air and Adrenaline display their authoritative
current/maximum values, including maxima derived from Constitution, Patience
and Resilience respectively. The author explicitly confirmed resources always
remain visible. Each of the twelve effective attributes is displayed only when
strictly less than the viewer's effective Insight (Perspicacia); equal or larger
values display `??`. This does not create a new Perception attribute or change
stealth, detection, combat or resource formulas. Friendly combatants use the
same information rule. Unsupported actor statistics are not fabricated.

Menus/conversations suppress the panel. Target changes and empty aim clear it;
notifications are placed below its occupied area. Bindings resolve in the UI,
so remapping needs no restart. The target cache is transient and reconstructed
after loading; no inventory/save schema changes. The previous separate sewer
hint and its per-frame global gate scan are replaced by this shared selection.

## Chemistry art and regional source decision (#471, 5.7.6)

The author requested ingredient sprites/models on 2026-10-22. This art stage
binds a dedicated icon to existing iodine and prepares the other approved
ingredient families without changing effects, prices, recipes, saves or stock.
Saltpeter means natural niter (potassium nitrate), distinct from sodium nitrate;
charcoal remains distinct from mineral coal. The author selected collectible
saltpeter/sulfur deposits only in appropriate regions, with MAP03 supplied by
trade meanwhile. Regional placement, extraction/reserve values, trade prices,
stock and abstract recipe units still require approval. The art stage installs
neither deposits nor new trade items. Construction at Chemistry remains the
approved acquisition for abstract gunpowder, followed by compatible kits and
ten-cartridge batches. No real propellant proportions or procedures are part
of the data contract. Representation details are documented in ASSETS.

## Marine imports and iodine (#407, 5.7.5)

`assets/generators/marine_resources.json` owns the approved species, form,
quantities, values and processing data. Dried cachiyuyo (Macrocystis pyrifera)
comes from the Patagonian coast through MAP03 provisions shops. Each starts
with 1,000 g and replenishes 0.1% of its maximum per game day (1 g/day), capped
at 1,000 g, through the existing independent merchant calendar. Its base value
is 5 copper/100 g; ordinary buying/selling margins apply. No coastal location,
underwater collection route or TCOAST campaign source has been authorized.

Workbench + Chemistry: 100 g dried cachiyuyo -> theoretical 1 g iodine, 60 seconds
of base work, no additional fuel. Existing fixed batches, 25/50/100% output
efficiency and whole-gram rounding apply. A nominal batch at 25/50% produces
less than a gram and cannot start; the UI asks for a larger batch or efficiency.
A tenfold batch consumes 1,000 g and yields 2/5/10 g. Work scales with input
mass and the existing learning factor and Dexterity; it is not chemical elapsed
time. At full practice and 100% Dexterity, a nominal batch takes 60 seconds.
The abstract recipe contains no real extraction procedure or medical benefit.
Iodine's explicit approved 10 copper/g overrides derived processing valuation.

The library's existing all-recipe policy adds its tier-1 sheet: 10 books in stock,
100 copper base price (ten consumable-unit values), normal merchant margins,
study furniture and learning/practice rules. Owning the sheet does not itself
learn the recipe. No iodine-consuming recipe is authored in this patch.

Material IDs 87/88 and recipe ID 168 append; earlier IDs stay fixed. Marine
material schema revision 1 initializes only the added supply-array slots.
Recipe-book version 12 initializes only appended knowledge/progress slots.
Merchant marine catalogue revision 1 appends the import or library product
without rebuilding old stock, deadlines, purchases or wallets. Normal native
inventory, Box, chest and task authority apply. Validation status: PROJECT.

## Chemistry station infrastructure (#470, 5.7.4)

The author renamed this station Chemistry / Química on 2026-10-23 (#486,
5.7.11). The internal Alchemy class/key/constant names remain compatibility
identifiers. This changes displayed terminology only; #487 owns the separate
Fermentation Barrel, whose approved operation, placement and capacity are above.

Adds the fixed Workbench-backed Chemistry station (#470), represented by an
original 3D fermentation table and still. Approved positions are MAP01
(1128,448,0), workshop group 2, connected through Ronnie's Forge, and MAP03
(-656,1472,0), group 0, beside the Workbench. Collision is 60 x 60 x 72 units.
Station ID 12 and editor ID 18013 append without changing existing IDs.
A revision-1 map roster installs it once in fresh and previous saves, waiting
if blocked; a removed installed station is not reissued. The coordinator is
static so it also runs after loading pre-feature saved maps.
Proximity traversal uses the native local blockmap, retaining 128-unit 3D links,
room groups and transitive networks. No construction recipe or new recipe IDs
are introduced. Concrete recipes and start/completion prerequisites remain
owned by #407/#409/#471 through the existing coordinator; this patch supplies
the shared Workbench-plus-Chemistry capability check.
Validation status: PROJECT; CA470-01 passed author review on 2026-10-22.
Next: #407 marine/iodine, #409 boiling, #471 recipes and #472 mate, with separate
issue branches, commits, tests and PRs.

## Source recovery (#406, 5.7.3)

All renewable natural sources use `min(capacity, remaining + elapsed_days *
capacity * 0.001)`. Elapsed campaign time is applied once; observed time at or
below the saved stamp changes neither stamp nor amount. Only a later timestamp
extends the processed interval. Catch-up uses arithmetic, not iteration over
missed days. This preserves the existing rate and per-source cap.

An old source without a timestamp initializes at its first observed campaign
time without retroactive credit. Existing saved remaining material, extracted
fractional carry and calendar-entry identity stay authoritative; the guard adds
no saved fields and needs no schema migration. Normal source ticks observe time
once per second, including offscreen sources; extraction also synchronizes it.
Reload/hub restoration uses the same saved stamp. Off-map world coordination
remains V5.8. Finite tutorial gold and decorative plants do not renew.

Merchant imports keep their independent #385/#405 stock clock. Source recovery
never writes stock or wallets, and merchant synchronization never credits a
natural node. Repeated scheduling updates the existing source calendar entry.
If its credited source stamp is ahead of observed time, the deadline includes
that waiting interval, converted as a duration into civil calendar time.
Evidence and the prior-runtime regression are in assets/validation_573.

## Regional resource contract (#404, 5.7.1)

This is the reviewed V5.7 data contract. Land/source/merchant integration is
now delivered in #405 below; processing remains in its separate issues. Author decisions were approved on 2026-10-21.
`assets/generators/resource_catalog.json` stores the new authored data and
references the existing authorities; missing values remain explicit, never
silently defaulted. #405 owns land integration/placements; #406 owns renewal
verification; #407 owns marine imports/iodine; #471 owns processing recipes.

### Existing sources and consumers: preserve these values

The unit is 1 g (`MATERIAL_UNIT_WEIGHT = 0.001 kg`). All eleven existing mineral
families have three owned 3D variants. They require piercing damage; the
accepted Pickaxe mining multiplier is 100. Their capacity is the mapper's
positive args[4] in kg, otherwise actor mass times abundance. These are current
game data, not newly inferred geological claims. No numeric depth, regional
rarity or skill gate is implemented for these families; this patch adds none.

| Material ID | Constant suffix | Hardness | Abundance | Copper/g |
| ---: | --- | ---: | ---: | ---: |
| 64 | RAW_IRON | 5.5 | 0.6 | 7 |
| 61 | COAL | 2.5 | 0.6 | 5 |
| 62 | RAW_COPPER | 3.5 | 0.5 | 5 |
| 63 | RAW_TIN | 6.5 | 0.4 | 5 |
| 65 | RAW_SILVER | 3 | 0.2 | 100 |
| 66 | RAW_GOLD | 3 | 0.1 | 1000 |
| 58 | RAW_OPAL | 6 | 0.075 | 500 |
| 57 | RAW_TOPAZ | 8 | 0.05 | 500 |
| 55 | RAW_SAPPHIRE | 9 | 0.04 | 500 |
| 54 | RAW_RUBY | 9 | 0.03 | 500 |
| 56 | RAW_EMERALD | 7.5 | 0.02 | 500 |

Raw metal consumers are existing smelting/alloy/component recipes; raw gems
feed existing gem/component recipes. Coal retains ID 61 and its existing
processing roles. Charcoal is a distinct future wood-derived ingredient.
Mineral data remains authored in `generate_mineral_veins.py`, not copied into
a competing runtime table by #404. Prices remain the economy's accepted
anchors; hardness and abundance do not recalculate them.

Existing resource trees yield wood (ID 42, 2 copper/g), hardness 2.5, abundance
1, slashing damage, Pickaxe chopping multiplier 10. Capacity uses the same
args[4]/mass rule. Their 21 base species retain the generator's desert, jungle,
tundra, mountain, plains, coast and city biome groupings. This is an art/source
catalogue, not authorization to place every species in MAP01 or MAP03.
`CaelumFiberBush` yields plant fiber (ID 74, 3 copper/g), inherits hardness 2.5
and abundance 1, and has 10 kg capacity without a mapper override. It now uses
an owned 3D model (#405), as do existing resource trees and veins. Ordinary
movable rocks are not mineral sources. Mansion scenery trees/shrubs are
decorative Actors, not resource nodes.

Extraction releases `strikePower * (1 - hardness/10) * abundance`, with the
existing Pickaxe factor, bounded by remaining reserve and tutorial allowance.
Fractional grams persist; only whole grams spawn. Failed spawning does not
deduct material. Exhausted renewable sources remain present; explicitly finite
sources do not regenerate. Current saved capacity/remaining fraction/calendar
ownership is reused, not reset by a new catalogue.

Current recovery is 0.1% of capacity per game day, capped at capacity. An
extraction updates one calendar entry; the agenda reports recovery, while the
source owns the material. First observation of an older source initializes its
clock without inventing absent years. #406 must verify equivalent elapsed-time
results and idempotence. Off-map world expansion remains V5.8.

MAP01 currently permits only Ronnie's trial gold extraction. The author
explicitly chose **decoration only for the new MAP01 plants/hives**; collect
their useful resources in MAP03. Existing gold and tutorial quotas, finite
delivery counters, other resource restrictions and scenery stay intact.
Source recovery cannot replenish tutorial issuance or vendor stock. The #385
merchant renewal rules remain a separate authority.

### Approved sources: #405 integration; #406 recovery verification

Reserves below measure useful material, not whole plant/collision mass. Plants
use hardness 2.5, abundance 1 and slashing, with no new skill gate. Hive
interaction takes at most 50 g; no bee combat or wax is included. Every new
source uses the approved 0.1%-per-day recovery. Import-only source profiles
do not authorize local wild plants. Farming is outside this scope.

| Source key | Useful reserve (g) | Region and first-slice access | Action | Consumer |
| --- | ---: | --- | --- | --- |
| `yerba_mate` | 250 | Litoral; MAP03 import | slashing | Energy drink and reusable mate |
| `marcela` | 50 | Pampas; MAP03 harvest, MAP01 decoration | slashing | Existing medikit ingredient; no independent medicinal effect |
| `irupe_flower` | 10 | Litoral; MAP03 import | slashing | Alternative flower for the existing fictional Anima potion |
| `cypella_flower` | 10 | Pampas; MAP03 harvest, MAP01 decoration | slashing | Alternative flower for the existing fictional Anima potion |
| `sugarcane` | 5000 | Northwest; MAP03 import | slashing | Molasses, fermented intermediate, alcohol chain |
| `cotton` | 250 | Northeast; MAP03 import | slashing | Existing fabric processing and new medikit recipe |
| `honey` | 500 | Pampas; MAP03 harvest, MAP01 decoration | interaction; up to 50 g/use | Alternative sweetener for the energy drink; no wax or bee combat |

Cotton reuses material ID 72 (4 copper/g) and existing fabric processing; no
duplicate cotton identity is permitted. Marcela is Achyrocline satureioides;
the alternative Anima flowers are Victoria cruziana (irupé) and Cypella
herbertii (lirio del bajo). Their Anima role is fictional. Botanical selection
references are retained in the JSON; they do not establish gameplay rarity,
yield or medicinal effects. Yerba mate is Ilex paraguariensis. No cultivar or
additional medical effect is implied for sugarcane, cotton or honey.

Exact coordinates and source counts are the approved #405 table below.
Counts control gameplay rarity; the description "rare Anima flowers" does not
create an unapproved probability or a claim of botanical scarcity. Existing
vein coordinates and underground access remain as authored. New plant/hive
profiles are surface sources; no invented numerical depth modifier is added.

### Marine and processing audit: approved chains, unresolved numbers

The #407 marine contract is implemented in 5.7.5 as described above: dried
cachiyuyo imports and abstract iodine processing. No coastal campaign source
is authorized by the old TCOAST test map. Iodine's downstream consumer remains
open; no medical/crafting benefit is inferred. The other chains below remain
author-design gates for their own issues.

| Resource/product | Approved source or chain | Consumer / owner issue | Still unresolved |
| --- | --- | --- | --- |
| Charcoal | Wood processing; distinct from mineral coal | Fuel roles to author; #471 | Amounts, yield, work, fuel role, price |
| Molasses | Sugarcane processing | Fermentation; #471 | Amounts, yield, work, price |
| Fermented intermediate | Molasses + yeast + water + elapsed time | Distillation; #471 | Amounts, duration, yield |
| Alcohol | Fermented intermediate + fuel | Existing medikit; #471 | Amounts, fuel, work, yield, containers |
| Yeast | Acquisition not yet authored | Fermentation; #471 | Acquisition, price/stock, quantity |
| Sugar | Acquisition/processing not yet authored | Alternative energy-drink sweetener; #471 | Acquisition, amount, price/stock |
| Gunpowder | Abstract game ingredient made at Chemistry | Existing compatible kits, then ten cartridges; #471 | Component quantities, other kit inputs, price/stock |
| Dried cachiyuyo | Patagonian import in MAP03 | Abstract iodine recipe; #407 | Implemented in 5.7.5; CA407-01 accepted 2026-10-22 |
| Iodine | Dried cachiyuyo at Workbench + Chemistry | Consumer not yet authored; #407 | Downstream purpose; no inferred benefits |

Existing medikit/energy-drink/Anima identities, dose sizes, effects and prices
remain unchanged. Medikit ingredients are cotton + alcohol + marcela; energy
drink uses potable water + yerba + honey or sugar; Anima potion uses potable
water + either approved flower. #471 must author quantities and work,
efficiency, recipe learning, stock and price implications before implementation.
Existing sealed kits (IDs 79/80) remain compatible; the approved chain is
gunpowder -> compatible kits -> ten cartridges at Chemistry. No real propellant
or primer formulation is requested or recorded.

On 2026-10-23 the author approved fixed Chemistry vessels for these processes:
water is withdrawn from a bottle/canteen without consuming that container, and
finished consumables retain their existing abstract packaging. No empty portable
packaging objects are added. Fermentation continues in world time while the
player is away, including on another map; its output is collected on return to
the same station. Heating and distillation still require attendance. Realistic
hours/days remain the approved timing style, with no exact batch durations yet.
The unattended batch's cancellation/ownership rules, exact quantities, yields,
fuel and acquisition/economic tables remain pending. These are design decisions,
not a claim that the new recipes or unattended fermentation are implemented.

### Related approved boundaries for subsequent issues

#470 is a fixed Workbench-backed Chemistry station with fermentation table/still
at the approved MAP01/MAP03 positions above; no construction recipe. #409
boiling removes biological contamination only; salt and chemicals persist.
The author approved processing the whole selected bottle/canteen in fixed glass
equipment belonging to the station. The useful power is 1,000 W, thermal
efficiency 25%, coal energy 28 MJ/kg, fixed glass mass 1 kg, water specific heat
4,180 J/(kg K), glass specific heat 830 J/(kg K), boiling temperature 100 C and
vaporization energy 2,257,000 J/kg. Warm-up is followed by 60 seconds of boiling:
`Qwarm = (litres * 4180 + 1 * 830) * max(0, 100 - input_C)`;
`seconds = Qwarm / 1000 + 60`; coal is rounded upward to whole grams from
`seconds * 1000 / (0.25 * 28000000)` kg. Evaporation is `60000 / 2257000` L.
For 1 L at 20 C this is 460.8 world seconds, 66 g coal and about 26.584 mL lost.
Tiny volumes that would evaporate entirely cannot start. Portable vessels are
retained and their existing provisional 100 g empty weight is unchanged.

Dexterity and crafting efficiency do not shorten this thermal work. Work and
cooling use the established thermal clock (Limbo 1:1, exterior 20:1); crafting
timers store world seconds for this process, and waiting converts them to its
simulation ticks. Other crafting tasks retain their current timing rules.
Water and coal are reserved until completion. Cancellation releases both,
without spending coal, heating, evaporation or purification. Paused work retains
its input snapshot, including across save/load. Completion removes only the
biological flag and applies evaporation/100 C once. Salt and chemical flags
remain; recontamination by mixing still uses the shared union of quality flags.

Bottles/canteens reject drinking above 85 C, including quick use and automatic
supplies. Reserved water cannot be drunk, filled, emptied, dropped, sold or
moved into a chest/Box. In inventory, H starts boiling at a reachable connected
Chemistry/Workbench network; C cancels in the crafting page and normal waiting
remains available. The inventory shows temperature and estimated work/fuel.

Approved cooling is a closed-vessel, equivalent-capacity sphere with no further
evaporation. Water mixing uses volume-weighted heat balance. Glass conductivity
is 1.1 W/(m K), specific heat 830 J/(kg K); leather wall is 6 mm, conductivity
0.14 and specific heat 1,500. Canteens use the existing provisional empty mass;
glass wall thickness is derived from empty mass and the author-approved ordinary
glass density of 2,500 kg/m3 (2026-10-23). Air convection and linearized radiation reuse the existing
thermal rules. Exponential integration approaches ambient without overshoot;
clock gaps use the current sampled environment, without inventing historical
weather. This model does not add freezing, pressure or evaporation while stored.
Author gameplay acceptance remains outstanding.

#472 mate has 100/250/500 mL nominal capacity, respectively 20/50/100 g yerba
and 60/150/300 mL useful water. Each hot use spends all water and one of twenty
cebados. Water refill never resets the counter; washed yerba is discarded
without recovered materials and replaced by a new load. Potable water can
come from any bottle/canteen; drinking needs no station. At 60-85 C it grants
ordinary hydration plus one tenth of the nominal hydration percentage of
maximum Air, Health and Anima, including when Thirst is full. Below 60 C it
only hydrates and spends no cebado; above 85 C drinking is blocked until cool.
No optional herb effects are yet approved. The completed #472 construction,
thermal, recipe and acquisition contract is in "Reusable mates" above; it does
not revise the separate canteen mass.

The original #404 data-only patch changed no gameplay or save schema. Its evidence is
`assets/validation_571/RESULTS.md`; native tests are required when these rows
are integrated in their owning issues, not claimed here.

## Land source integration (#405, 5.7.2)

Author-approved data lives in assets/generators/land_resources.json and its
referenced resource_catalog.json. Generated runtime data is read-only. IDs
81-86 append yerba, marcela, irupe flower, lirio flower, cane and honey; cotton
remains 72. All use the existing one-gram material unit. Base values per 100 g
are respectively 2, 10, 50, 50, 1 and 2 copper; cotton retains 4 copper/g.
Existing merchant margins, lot selectors and rounding apply.

| Map | Source | Positions (x,y) | Collectible reserve |
| --- | --- | --- | --- |
| MAP03 | Marcela | (-30272,320), (-30144,448), (-30336,1216), (-30144,2112) | 4 x 50 g |
| MAP03 | Lirio del bajo | (-30080,1280), (-30080,1920) | 2 x 10 g |
| MAP03 | Hive | (-30464,1536) | 500 g |
| MAP01 | Marcela | (-1856,832), (-1664,864) | decoration only |
| MAP01 | Lirio del bajo | (-2016,1024) | decoration only |
| MAP01 | Hive | (-1792,1056) | decoration only |

Positions use the native floor plane; campaign WAD geometry is unchanged.
Plants use existing slashing, fractional carry and Pickaxe factors. Aim at a
hive and press Use for up to 50 g as a physical pickup; holding Use collects
once per press. Damage cannot extract honey. Reserve is deducted after a
successful spawn. Honey also obeys tutorial supply limits. Useful reserve is
independent of inherited fiber-bush collision/mass. Source recovery reuses the
shared clock; detailed elapsed-time verification belongs to #406.

Each provisions shop starts with 1000 g yerba, 20 g irupe flowers and 10000 g
cane; each clothing shop with 1000 g cotton. Imports recover 0.1% of their own
maximum per game day, capped at target. Fractional daily production accumulates
until a whole gram is due (irupe: 1 g per 50 days). Local marcela/lirio/honey
can be sold to provisions shops; no local initial stock or production target
is invented. Existing kits remain finite and merchant money never replenishes.
Queues reuse the existing earliest-deadline shop system, without actor scans.

Revision 1 initializes only six new tutorial-array slots. Vendor revision and
cursor seed each import row once, preserving previous stock, money and clocks.
A StaticEventHandler performs one typed roster lookup per MAP01/MAP03 load,
including old saves. The map-owned roster retains issued IDs: loading neither
resets reserves nor reissues a removed position. The lookup is bounded to its
own roster type (one normal instance) and at most eleven authored placements
across both maps. It is required for old-save correctness and runs once per
load, never routinely per actor/tic. Source amounts/carry/calendar IDs remain
their existing saved authority. Native evidence: assets/validation_572.

All source profiles, new material drops and existing fiber/decorative shrubs
use owned 3D models; reused inventory thumbnails are UI-only. New ingredient
consumers/recipes remain #471/#472. Acquiring an ingredient grants no potion,
healing effect or learned recipe. The author passed CA405-01 on 2026-10-22.

## Water quality and native containers (#408, 5.7.0)

The author approved this contract on 2026-10-21. Water carries independent
biological, salt and chemical contamination flags; potable water has none.
Mixing retains the union of all flags even when the added portion is potable.
Non-potable water cannot be drunk, served during rest, counted as journey
provisions or consumed by accelerated time. The container still contributes
its complete water mass and retains normal inventory/Box ownership.

The existing submerged-entry refill remains automatic only for potable sources.
In Inventory, select a bottle/canteen and use **Collect water (R)** to top it up
from the current identified, fully submerged source, or **Empty (V)** to discard
its contents. Both also have native mouse buttons. Filling is all-or-nothing
for the missing volume; personal carrying capacity includes the existing 1 g
margin. Full, unknown-source, over-capacity, foreign-owned or Box operations
cannot change water. Emptying does not return materials. Unknown unmarked water
is not implicitly safe. Collecting does not consume a finite source reservoir;
finite water-source quantities are outside this issue.

Mapper data: `user_ca_water_quality` is a bitmask (1 biological, 2 salt,
4 chemical). Nonzero contamination overrides `user_ca_potable_water`.
With zero quality, the existing potable marker is required. Unsupported flag
values fail closed. This patch preserves campaign map geometry and markers;
the isolated test map exercises every combination without assigning unsupported
geographical properties to existing rivers or seas. Later source placement
must author the appropriate flags.

Existing saves contained only potable water. Additive saved fields
`WaterQuality` (default zero) and `WaterQualityRevision` (revision 1) preserve
their exact volume. Migration is idempotent and never refills a vessel; native
copy/drop, save/load and hub travel retain quality. Rest forecasts use revision
4 and are rebuilt from real inventory when older projections are encountered.
Mansion table replenishment mixes potable additions with the existing contents;
it never purifies a deposited contaminated portion. Empty vessels can be filled
with fresh potable water normally. Original pre-patch saves/packages remain the
rollback path; do not load a contaminated new save in the old unaware runtime.

Sizes (1/2.5/5 L), provisional 0.1 kg empty mass, and the current hydration
contract are unchanged: a full sip uses body mass/400 L, with ten pulses and
total recovery `4000 * liters / bodyMass` Thirst points, capped at 100.
The older 4.33.0ai M/500 discussion below is historical; the later food/water
contract and current shared constants prevail. No thermal or treatment recipe
is implemented here. #409 owns boiling (biological removal only), and #472 owns
the separately approved mate/temperature work.

No global actor scan is introduced. Quality uses the current sector and native
container state; existing inventory/provision traversal is reused. Unchanged
rest-furniture and time-zone queries are outside this patch; no new rendering
performance claim or whole-map stress test is made. Static and native results
are tracked in `assets/validation_570/RESULTS.md`; CA408-01 passed author review on 2026-10-21.

## City replenishment and source policy (#385, 5.6.11)

The author approved full production chains on 2026-10-21: start from raw
materials, include every required component operation and the final operation,
with Technical attributes zero and fully mastered 100% efficiency. Each
operation uses the common 25% time base approved in #378. Native blueprint
quantities, batch rounding, material tiers and equipment sizes remain the sole
source. Merchants know all their recipes and do not consume the player's inputs.
The quote restores the player's crafting selection and does not teach recipes.

| Source | Production / limit | Clock and exclusions |
| --- | --- | --- |
| City consumables/ammunition with a recipe | One unit after full-chain batch duration divided by output count; cap 1,000 per product | Sequential within a product; products run simultaneously |
| City equipment | One fresh matching tier/size/essence/slot variant after its complete chain; cap one | Exact returned equipment counts as existing stock; no cloning of wear, identity or sold non-catalogue variants |
| Library | One book after the entire represented recipe batch; cap ten per recipe/tier | XL equipment reference; no ten-unit study-time multiplier; duplicate-page purchase rejection remains |
| Prepared cartridge kits | Full-chain recipe renewal, approved in #471 / 5.7.13 | Preserve existing target; new deadlines begin without resetting stock |
| Nine medikits/Anima potions/energy drinks | Full-chain recipe renewal, approved in #471 / 5.7.13 | Existing target; cheapest approved variant matches the commercial price |
| Food and water rations | No renewal | No manufacturing recipe is defined |
| City and Palomo wallets; Palomo stock | No new refill rule | Preserve their existing ownership and balances; city production does not apply to Palomo |
| Chest/enemy loot and finite salvage | No renewal | Retain #384 one-time delivery and exact native contents |
| Natural resource nodes | Existing capacity recovery only | Existing world-clock delta, fractional yield, stable per-node calendar entry and first-sync migration; #385 does not retune recovery |
| MAP01 tutorial supplies | Existing issued quotas | No periodic reset or grants from shop renewal |
| MAP01 dining tables | Existing local-midnight #65 policy | Remains independent of city commerce and finite lesson supplies |

Civil game-calendar elapsed time includes ordinary play, rest/travel advances
and time spent away from an initialized shop's map. Limbo uses its separate
local clock, so it does not advance this civil production. Pausing the engine or
closing the game adds no production time. Inactive vendors catch up arithmetically
when opened; only the active trade checks its earliest due date each world tic.
No global actor scan or simulation of historical NPC activity is introduced.
At a deadline exactly one unit is available; excess elapsed time can produce
further sequential units up to the target. Full stock discards idle production
time. A later purchase starts a new period. Padlocks are manufactured with a new
matching key, using the existing paired-item factory.

Restock revision 1 adds product descriptors and serialized fractional deadlines
to each vendor. Actor.Inv remains authoritative for quantities and exact items;
descriptors are not a second inventory. Unopened shops retain lazy initial stock.
The first revised synchronization of an old initialized vendor preserves its
remaining stock/wallet and starts missing products at now + period, awarding no
retroactive output. Repeated opening, save/load and hub return retain that same
deadline. Rollback uses the preserved original package and original save.
SHOP_CATALOGUE.json owns the revision and full-chain policy flag.

## City catalogue extension (#383, 5.6.10)

SHOP_CATALOGUE.json is authoritative for the two replacements: city shop 34 is
the library and shop 35 the clothing shop, on the accessible central commercial
row. All six earlier specializations remain elsewhere. Matching book/coat signs
use the existing sign renderer and generator; generated hub entrances use the
same category source. Existing MAP03 geometry is unchanged.

| Vendor | Approved additions / initial stock | Retained rules |
| --- | --- | --- |
| Library | Every valid recipe/tier, ten books per offer; categories | Book base value is 10% of the XL equipment output, or ten consumable units, using the represented tier |
| Clothing | 25 garments x five sizes, one native T1 instance each | Approved garment price, mass, durability and moisture |
| Ranged | 1,000 of each of the two sealed cartridge kits | 80% finished-ammunition base value, before normal margins |
| Melee/tools | One matched padlock/key pair per tier, one lockpick set and one master key | Pair weight/value includes the key; no separately purchasable half-pair |
| Provisions | 1,000 per food/water/potion product, including medium/large potion variants | Existing eleven product identities and values |
| Existing equipment/ammunition | One ordinary T1 instance per authored variant; 1,000 per ammunition product | Existing specializations, valuation and eligibility |

The existing 150% selling / 50% buying margins and rounding apply once. A library
purchase incorporates final/component sheets into the player's notebook: 100 g
for the first binder plus 5 g per missing page; existing pages add no weight.
It grants no recipe knowledge. The existing notebook stays in its personal/Box
location; a new binder may use available Box capacity. Currency change and page
weight are preflighted together. No spare purchased book remains in inventory.
If all pages are present, reject without charging or reducing stock. Library
Left/Right controls cycle categories; each confirmation buys one book.
Lock/tool recipe books use equipment pricing and their real names, shown under
Utilities in the library, independently of their older crafting-kind adapter.

Native vendor inventory remains authoritative. Catalogue revision 1 adds only
new entries once, with a per-vendor cursor for interrupted allocation. The
existing map controller applies category/sign migration once to a previously
visited city. Existing money, depleted stock and exact player-sold items remain;
converted vendors may sell old goods regardless of their new specialization.
Equipped, reserved and quest items remain excluded. No merchant wallet refill,
automatic stock renewal, raw-node or loot renewal is introduced here (#385).

Initialization uses bounded typed registries: at most 64 city merchants and 64
signs in one revision migration, owned by the existing map controller. No new
global per-tic scan is added. Catalogues remain lazy until a shop is opened;
the library computes prices without spawning a preview object per offer.

## Cartridge assembly (#380, 5.6.9)

Recipes 166/167 append carbine/shotgun assembly; native materials 79/80 are the
prepared kits below. The kit is the indivisible accounting unit: the existing
complex rate is four tics per employed kit, with the 25% common time base and
reading/practice multipliers. At zero Technical attributes, one batch has a
40*4/35-second base, before learning multipliers. Recipe-book revision 11 adds
both recipes locked without changing previous knowledge, pages or progress.
As of 5.7.10/#471, Workbench + Chemistry gates new starts and completion. An
already active cartridge task from an older save retains its original network
until cancellation/completion. The revision-1 compatibility flag is saved and
mirrored to the travelling record; repeated migration does not reset time,
materials, knowledge or practice. The exception cannot start another task.
Arrows/bolts still use Workbench + Ranged Workshop. Native tasks
reserve 40/20/10 kits, consume once, and deliver ten existing cartridges. Inputs
retain their 40/45 g unit mass in capacity and UI calculations; outputs reuse the
existing ammunition stack's personal/Box location and reject stack overflow.
Both material identities have distinct inventory icons and ground sprites.
Commerce and merchant renewal remain separate #383/#385 work.

## Approved cartridge kits and assembly handoff (#379, 5.6.8)

**AUTHOR-APPROVED 2026-10-21.** The author accepted the concrete sealed-kit
proposal and its price. This supersedes the earlier pending separate-component
mass/price table. A kit is one native playable input representing all finished
parts together; no individual charge mass, real loading ratio or component
manufacturing process is defined. The complete 40 g/45 g masses remain the
accepted game approximations from #313.

| Game input | Description of the sealed set | Unit mass | Base value | Output at 100% efficiency |
| --- | --- | ---: | --- | --- |
| Carbine cartridge kit | Prepared bronze case with integrated primer, sealed finished charge and projectile | 0.040 kg | 0.80 times the existing carbine cartridge base value | 10 kits yield 10 existing carbine cartridges |
| Shotgun cartridge kit | Prepared paper case including integrated primer and closures, sealed finished charge and shot | 0.045 kg | 0.80 times the existing shotgun cartridge base value | 10 kits yield 10 existing shotgun cartridges |

Both existing cartridge prices remain four times the arrow's unit base value.
The kit's 80% factor applies before merchant margins; use the existing 150%/50%
buy/sell margins and rounding exactly once. Do not derive the finished cartridge
price recursively from its kit. The separate-components proposal is superseded:
there are two kit products, not separate saleable case/charge/projectile products.

Lower efficiencies use the existing material-loss rule: a ten-cartridge output
requires 40/20/10 indivisible kits at 25%/50%/100% efficiency. The corresponding
input game masses are 1.600/0.800/0.400 kg for carbine or 1.800/0.900/0.450 kg for
shotgun; the difference from completed output is the existing crafting loss.
No fractional kit is consumed. Both types now use Workbench plus Chemistry (#471),
the padlock's existing complex work rate, the common 25%-efficiency time base
and the accepted reading/practice factors. Recipes are consumables: the existing
1,000-output practice cap and ten-unit reading/price reference apply.

#380 appends two recipe/material identities, preserving every existing ID,
arrow/bolt recipe, ammunition count and magazine. The shotgun retains its twelve
gameplay pellets. Recipe books are sold by the library; finished kits by ranged
shops under #383. No kit-manufacturing recipe is approved, so #385 leaves kit
stock unrenewed until such a recipe is separately defined. Assembly renews finished
cartridges using the approved merchant policy; it does not simulate supply chains.

Implementation must use native inventory, reservations and task completion.
Verify both batches and all efficiencies, kit shortages, unknown recipes/wrong
stations, full inventory/Box, pause/cancel/save/reload/travel, duplicate completion,
and preservation of existing firing/reload and arrow/bolt behavior. Preserve actual
5.5.8a/current saves and original package/save recovery pairs; any appended schema
needs an idempotent numbered migration. This design issue introduces no gameplay
or art; native assembly and author playtest evidence belong to #380.

## One-time loot with existing tables (#384, 5.6.4)

The author retained current distributions and requested only their one-time
delivery review. No added pool, randomization, item, quantity, respawn or map
refill is implied. The #384 issue's opening 65-entry baseline is historical:
#183's accepted material quotas remain authoritative for current MAP02 chests.

| Source | Approved/current contract | #384 treatment and evidence |
| --- | --- | --- |
| 39 current MAP02 chests | Frozen initial-equipment repair/replacement material quotas; partial remainder freezes on first successful receipt | Unchanged; #381 covers preview/cancel/capacity, competing requests, partial collection, saves and hub/non-hub item travel |
| Legacy maze catalogue | 65 distinct T1 combinations, recipient sizing on successful receipt, retained looted gaps and migration backup | Preserve provenance and existing migration; do not reseed current/visited maps |
| Mapped creature drops | Existing 38 Mandinga/192 rat assignments; current ammunition/key/ration quantities and dry anchors | No table/generator changes; actual MAP02 deaths, repeats, old/current saves and original-pair rollback rerun |
| Unassigned supported demons | One remaining native potion, weighted by actual remaining supply; no potion when assigned loot or native DropItem has priority | Existing #220 debit/exhaustion rules unchanged; native actual-death tests rerun |
| Native combat-actor death/unblock | No duplicate death event or native entitlement on reentry, repeated callback, resurrection, reload or hub return | New guarded dispatch and revision-1 claim; isolated DropItem carrier proves native route without adding campaign loot |
| MAP01 Bull and tutorial supplies | Bull drops no leather; existing gifts and Ronnie's finite material entitlement remain authoritative | Unchanged; source review and applicable #183/#378 evidence, no new campaign replay claimed |
| Prisoner/side-quest rewards | Existing successful-transfer/receipt and persistent claim flags | Unchanged; source-reviewed, no new reward or chance |
| New recipe/clothing/ammunition loot and new ownership | Additional mappings require their own approved data/access rules | Pending respective issues; not introduced by #384 |

Combat actors serialize NativeDeathLootRevision 1 and NativeDeathLootReleased.
New actors initialize the revision before first death. Old previously raised
or killed/nonblocking bodies import a spent claim; a still-solid dying body
keeps its pending claim. Suspended archive bodies use their saved pre-suspension
solid flag. Initialization is idempotent and local, with no global actor scan.
The claim commits before calling the engine; repeating unblock may clear
collision but cannot create another native drop. A transient guard covers
OwnerDied/WorldThingDied reentry before the engine sets KILLED. Native revival
permits a subsequent real death while preserving the already spent loot claim.

Frozen death keeps native timing/chunk effects. A plain Actor proxy has no
inventory, conversation or DropItems; the original body keeps BossDeath and its
guarded entitlement. Existing native ice phase references are redirected locally
without replaying entry actions or changing remaining tics. New states append
after existing class states. Keep original save/package pairs for rollback;
loading new frozen-state indices with an old runtime is not a promised reversal.

Evidence and limits: assets/validation_564/RESULTS.md. Native tests do not claim
new campaign balance, multiplayer synchronization or author acceptance.
CA384-01 passed author review on 2026-10-20; existing native locks/access rules remain.

## Ordinary clothing: approved native catalogue (#386, 5.6.6)

**APPROVED 2026-10-20; IMPLEMENTED 5.6.6, AUTHOR-ACCEPTED 2026-10-21.** The author requested formal and
warm formal clothing, plus casual, country and poor-quality variants for summer,
autumn/spring and winter, in the setting's nineteenth-century Argentine style.
On 2026-10-20 they approved the complete table, including the garment choices,
quantities, coefficients and migration below. These are authored balance values,
not historical measurements. CA386-01 passed on 2026-10-21; distinct garment art belongs to #387.

### Authorities and native item boundary

Before 5.6.6 base clothing was implicit (`ARMOR_TYPE_BASE_CLOTHING`).
Clothing now has native item identity in the four existing anatomical regions:
head, body, hands and feet. The thermal model includes underclothes in each armor profile; its
light-cloth baseline is 0.5 clo, permeability 0.90 and water capacity
0.192336119324285 kg/m2. Fabric already distinguishes wool T1, cotton T2 and silk
T3; these material grades do not identify seasonal warmth or social status.
Current native equipment identity, size, Box and trade paths remain authorities.

Use a separate ordinary-clothing layer in those same four regions. A body
item is one complete torso/leg ensemble, including its named jacket or poncho;
its parts cannot separately stack, trade or add protection. This avoids adding
unapproved trouser/coat slots. Headwear, pairs of gloves and pairs of shoes are
separate items. One garment per region; an armor piece may coexist above it.
No change to hit regions, armor slots, defense, hitboxes or combat attributes.

All garment recipes have one output and **one clothing tier, T1**, with
their own recipe identity. No T2/T3 garment upgrades are proposed yet. Their
inputs may use existing higher-grade cloth without implying higher armor tier.
Stations are Workbench + Sewing Machine for every garment. Cloth,
leather and rope processing retain their current recipes and station checks.
Buttons, stitching and small ties are abstracted into the listed material mass;
there are no new thread, dye, felt or shoe-component material IDs.

### Garments, recipes, price and work

Weights and inputs below are for size M and 100% material efficiency. W = wool
fabric T1, C = cotton fabric T2, S = silk fabric T3, L = cow leather T1 and
R = plant-fiber rope T1. Their current processed base prices are respectively
2.5, 5, 10, 3.75 and 3.75 copper per gram. Material amounts sum exactly to dry
finished mass. Rate is the existing 2/3/4 tics per material unit for normal,
detailed/complex work. These are approved per-garment assignments.

| ID / region | Garment (one native item) | Dry kg, M | Processed inputs, grams | Dry clo | Rate | Base copper | Base work, seconds |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: |
| F / Body | Formal: shirt, waistcoat, trousers, frock coat | 1.800 | 1200W + 500C + 100S | 0.75 | 4 | 8125 | 822.86 |
| FW / Body | Warm formal: F with wool overcoat | 3.400 | 2800W + 500C + 100S | 1 | 4 | 13125 | 1554.29 |
| CS / Body | Casual summer: cotton shirt and light trousers | 1.000 | 50W + 950C | 0.5 | 3 | 6093.75 | 342.86 |
| CE / Body | Casual mid-season: shirt, trousers and short jacket | 1.750 | 850W + 900C | 0.75 | 3 | 8281.25 | 600.00 |
| CW / Body | Casual winter: shirt, wool trousers, waistcoat and coat | 2.500 | 1900W + 600C | 1 | 3 | 9687.5 | 857.14 |
| RS / Body | Country summer: work shirt, bombachas and sash | 1.250 | 1100C + 150L | 0.5 | 3 | 7578.125 | 428.57 |
| RE / Body | Country mid-season: shirt, bombachas, sash and short wool jacket | 2.000 | 800W + 1000C + 200L | 0.75 | 3 | 9687.5 | 685.71 |
| RW / Body | Country winter: shirt, bombachas, sash and wool poncho | 3.250 | 2200W + 800C + 250L | 1 | 3 | 13046.875 | 1114.29 |
| PS / Body | Poor summer: patched shirt and worn trousers | 0.800 | 600W + 200C | 0.4 | 2 | 3125 | 182.86 |
| PE / Body | Poor mid-season: patched shirt, trousers and jacket | 1.400 | 1200W + 200C | 0.6 | 2 | 5000 | 320.00 |
| PW / Body | Poor winter: patched trousers, shirt and coarse coat | 2.000 | 1800W + 200C | 0.8 | 2 | 6875 | 457.14 |
| HF / Head | Formal felt hat with silk band | 0.150 | 125W + 25S | 0.75 | 4 | 703.125 | 68.57 |
| HC / Head | Urban cotton cap | 0.100 | 100C | 0.5 | 3 | 625 | 34.29 |
| HR / Head | Country felt hat with leather band | 0.180 | 150W + 30L | 0.5 | 3 | 609.375 | 61.71 |
| HW / Head | Winter wool cap | 0.140 | 140W | 1 | 2 | 437.5 | 32.00 |
| HP / Head | Patched cloth cap | 0.080 | 80W | 0.4 | 2 | 250 | 18.29 |
| GF / Hands | Formal cotton gloves with silk trim | 0.080 | 60C + 20S | 0.5 | 4 | 625 | 36.57 |
| GC / Hands | Thin cotton work gloves | 0.060 | 60C | 0.5 | 2 | 375 | 13.71 |
| GW / Hands | Wool gloves | 0.120 | 120W | 1 | 2 | 375 | 27.43 |
| GP / Hands | Patched wool gloves | 0.100 | 100W | 0.8 | 2 | 312.5 | 22.86 |
| BF / Feet | Formal leather shoes | 0.900 | 880L + 20C | 1.2 | 4 | 4250 | 411.43 |
| BC / Feet | Urban leather ankle boots | 1.100 | 1000L + 100C | 1.2 | 3 | 5312.5 | 377.14 |
| BR / Feet | Country leather boots | 1.500 | 1450L + 50C | 1.2 | 3 | 7109.375 | 514.29 |
| BS / Feet | Cotton and rope-soled alpargatas | 0.600 | 200C + 400R | 0.5 | 2 | 3125 | 137.14 |
| BP / Feet | Patched wool and rope-soled alpargatas | 0.500 | 200W + 300R | 0.4 | 2 | 2031.25 | 114.29 |

Base copper = sum(processed input value at 100%) * the existing T1 markup 1.25.
No extra silver/gold decoration or independent luxury discount is proposed.
NPC sale = ceil(base * 1.50); NPC purchase = floor(base * 0.50), once per lot.
For example, the proposed M casual summer ensemble has base 6,093.75 copper,
vendor sale 9,141 and vendor purchase 3,046. These large prices follow the
existing per-gram anchors; lowering those anchors is a separate author decision.

The work column is the common 25% reference with prepared inputs and zero
attributes: ceil-per-input grams at 25% * rate / 35, before time acceleration.
M inputs in this table divide exactly, so this is 4 * dry grams * rate / 35.
For CS it is 342.86 seconds. Use #378's unchanged A/B factors, practice cap and
Dexterity work scaling thereafter; raw-material processing is additional work.
Each clothing recipe is equipment: price reference 10% of XL finished value;
first reading and reread durations use XL/100% efficiency, current recipe
progress and Intelligence M3. The existing source/reading rules teach component
recipes without granting ingredients.

Reuse XS/S/M/L/XL masses 0.50/0.75/1/1.25/1.50 and existing body-tier fit rules.
Round each material through the existing gram-precision quote; derive the final
mass/price/time from those units. Warmth is coverage-based and does not multiply
by size or by number of visual subgarments. Every item keeps its size and ItemId
through equip, drop, pickup, Box, craft and trade.

### Proposed complete combinations and condition

| Requested style | Body | Head | Hands | Feet |
| --- | --- | --- | --- | --- |
| Formal | F | HF | GF | BF |
| Warm formal | FW | HF | GW | BF |
| Casual summer | CS | HC | GC | BS |
| Casual autumn/spring | CE | HC | GC | BC |
| Casual winter | CW | HW | GW | BC |
| Country summer | RS | HR | GC | BS |
| Country autumn/spring | RE | HR | GC | BR |
| Country winter | RW | HW | GW | BR |
| Poor summer | PS | HP | None | BP |
| Poor autumn/spring | PE | HP | None | BP |
| Poor winter | PW | HP | GP | BP |

These are suggested combinations, not compulsory outfits or new loot tables.
Players may mix pieces that fit. Poor-quality pieces have visible repairs,
simpler cuts and lower proposed insulation; they grant no social/faction penalty.
For the initial clothing feature, propose no wear or combat durability: condition
remains 100%, ordinary clothing absorbs zero damage, and repair/dismantling are
unavailable. This deliberately requires approval; armor durability is unchanged.
No bonus to attributes, charisma, movement, carrying capacity or item slots.

### Proposed thermal and wetness contract

The clo column is a local region profile, not a bonus for the whole body from
each garment. The existing anatomy coverage calculation combines regions once.
For cloth, let w=clamp((clo-0.5)/0.5,0,1). Proposed permeability is 0.90-0.15*w
and water capacity is lerp(0.192336119324285,0.332367940848569,w) kg/m2. This
interpolates the two accepted cloth anchors; the intermediate values and the
poor-cloth clo reductions are new proposed game approximations. Leather shoes
reuse the existing 1.2-clo / 0.45 / 0.3469835350-kg/m2 leather profile.
Mixed-fabric trim is included in the row's single profile, not added again.

For a region covered by armor, initially keep that armor's existing complete
thermal profile, including its underclothing, rather than adding garment clo.
Thus warm clothing improves uncovered regions; it does not improve insulation
beneath armor in this first proposal. This limitation needs explicit approval.
The armor's approved combined water capacity also stays fixed: assign up to the
existing light-cloth capacity to its worn undergarment and the remainder to the
outer armor. Transfer any water above a new region capacity to runoff without
evaporative cooling. This must conserve total water on every transition.

Native garments own their moisture; no duplicate character BaseWaterKg remains
after conversion. Stored garments retain moisture without passive drying and
Box contents stay sealed, matching existing equipment. Wet carried mass is
counted once. Keep the accepted Fwet, rain, immersion, evaporation and runoff
rules; no second wet-insulation multiplier. A converted region with no garment
or armor has zero cloth insulation and the existing bare-surface water reference.

### Proposed initial/legacy entitlement and acquisition

Grant one casual summer combination (CS/HC/GC/BS) in the character's existing
default equipment size for a new character and once for each legacy player.
At M it adds 1.760 kg of real carried mass. Each region's profile is 0.5 clo,
preserving the old base-clothing thermal reference. This converts the outfit already represented visually into four native items.

The migration must be separately numbered and idempotent: create four native
instances atomically, keep existing armor/equipped identities, move base water
once, mark completion only after all references resolve, and never repeat the
grant on reload/travel. Preserve original save/package copies for rollback.
Allow this one-time worn conversion even if it puts a legacy save
over carried capacity, showing its actual added mass; do not discard, sell,
resize or silently place items in the Box. This one-time capacity exception is approved.
Existing NPC implicit clothing remains until explicit NPC outfit mapping exists;
no migration grant becomes new corpse loot or vendor stock.

The approved acquisition plan is library recipes for every row and ordinary city clothing stock through
#383, using its approved one-unit equipment rule per garment/size. Actual vendor
selection and shop conversion belong to #383; no new chest/enemy loot is proposed
under #384. Until #383 integrates these sources, the starter outfit is available normally;
additional garments/recipes are reachable through isolated development fixtures.

### Review boundary and handoff to #387

The author approved the 25 garment rows and 11 combinations, one-tier scope,
four-region ensembles, materials/masses/derived prices, station/work rates,
thermal profiles and armor limitation, no-wear rule and migration/capacity grant.
The author already selected the style families, three seasons and period; those
decisions are retained. CA386-01 passed author acceptance on 2026-10-21; HISTORY
records the completed gameplay check separately from #387 visual acceptance.

On 2026-10-21 the author approved the period brief: dark formal clothing,
earth-toned country wool, and faded/patched poor clothing, covering all supported
bodies, sexes, species and sizes in worn/world/preview/first-person views. Preserve
identity and gameplay size/mass; reuse modular poses and fittings. They also
explicitly required each garment to have its own sprites.

5.6.7 delivers 25 distinct inventory/crafting icons and dropped-item sprites,
with original sources and exact prompts retained. These derive from the garment
type; they change no balance, identity or saved entitlement. Worn-character,
preview and first-person appearance were explicitly deferred on 2026-10-21
until 3D character models are available (PROJECT V5.17). The current #387 scope
closes without claiming those views were implemented. CA387-01 passed
author review on 2026-10-21 for the object views. The temporary generic cloth icon/world sprite used in 5.6.6
is superseded only for the implemented object views. No NPC outfit is reassigned.

Implementation uses equipment kind 12, appended recipe IDs 141–165 and recipe-book
revision 10; old recipe IDs and knowledge retain their meaning. ClothingRevision
1 is separate from recipe/thermal revisions. Equipped IDs reside in the traveling
character record; native items own size, dry mass and ThermalWaterKg. BaseWaterKg
is cleared at conversion; uncovered skin uses BareWaterKg. Capacity runoff has its
own counter and never contributes to evaporated mass or latent cooling. The
original save and matching 5.6.5 package remain the reversible recovery pair.

## Lock tools, lawful access and theft witnesses (#382, 5.6.5)

The author approved the complete 5.6.3a proposal on 2026-10-20. The rules and
values below are the implemented design contract. Native evidence is recorded
in validation_565; CA382-01 passed author acceptance on 2026-10-21, including
the chest-push correction. Native evidence and author acceptance remain distinct.

Confirmed: padlocks are 100% steel, weighing 1/3/5 kg for the three chest tiers;
crafting includes a matching key weighing 10% of the lock (0.1/0.3/0.5 kg), so the
combined outputs require 1.1/3.3/5.5 kg at 100% material efficiency. Each tier
doubles height, width and depth relative to the previous. A matching key, master key or lockpicks
opens a lock; tools have no durability/consumption. A single blunt hit breaks a
lock for now; it does not push the chest. Manual player/NPC combat impulses
respect the chest's existing DONTTHRUST protection. A later author instruction
on 2026-10-20 supersedes warning-only:
opening another owner's new padlocked chest also makes living combat-capable
NPCs within 32 meters hostile when they have direct line of sight to the player.
This applies to matching keys, bypass tools and blunt breaking; own/public
chests do not trigger it. No faction-wide propagation, fine or confiscation is
introduced. One local spatial query runs on the committed opening, never per tic.
Story-protected residents and inactive/captive actors retain their protection;
sleep, stun, recovery, active Redemption, conversations, weapon resources and
escort priorities remain authoritative. An active theft target prevents starting
the guard's ordinary dialogue; an already active conversation pauses pursuit.

### Approved tools and sources

Use the existing medium chest as the geometry reference. Its existing locked
mesh supplies the latch and installed padlock; scaling the complete mesh by
0.5/1/2 doubles each chest and installed-lock dimension at successive tiers.
Native carried tools reuse the existing key icon/sprite.

| Item | Finished mass | Recipe at 100% efficiency | Complexity / stations | Availability |
| --- | ---: | --- | --- | --- |
| Lockpick set | 0.100 kg | 0.100 kg steel, one reusable set | Existing complex rate (4 tics/material unit); Workbench + Forge + Anvil | Existing city melee/metal-tool vendors, one copy per vendor; recipe book in the library |
| Master key | 0.500 kg | 0.500 kg steel, one reusable key | Existing complex rate; same stations plus Master Workbench | Existing city melee/metal-tool vendors, one copy per vendor; recipe book in the library |
| Small / medium / large padlock + its key | 1.100 / 3.300 / 5.500 kg total | Exactly the confirmed steel mass; one lock and its paired key | Existing complex rate; Workbench + Forge + Anvil, with specialist/master access matching chest tier | Existing city melee/metal-tool vendors, one matched pair per tier; recipe books in the library |

No extra quest, NPC, rare component, probability or minigame is proposed. Both
bypass tools open the new ordinary padlocks deterministically, without spending
the tool. They do not bypass existing mission/native locks or quest permissions.
A master key's station requirement distinguishes its manufacture from lockpicks;
no unapproved combat bonus or material adornment is introduced.

Approved pricing is fully derived, not a second price table. Let Vsteel be the
current base value of one steel material unit (0.001 kg). Base values are
100*Vsteel*1.25 for lockpicks, 500*Vsteel*2 for the master key, and respectively
1100*Vsteel*1.25, 3300*Vsteel*1.50, 5500*Vsteel*2 for each lock/key pair. Apply the
existing vendor 150% buy / 50% sell margin exactly once with existing rounding.
These approved manufacturing multipliers are the existing T1/T2/T3 margins;
100% steel excludes the usual silver/gold decoration. Split a pair's base value
between lock and key in their 10:1 mass ratio. Recipe books use the author's
10%-of-equipment rule. Other efficiencies consume materials and take time through
#378; neither balance nor replenishment is silently changed by this proposal.

### Approved ownership and alert matrix

| Situation | Entitlement and result |
| --- | --- |
| Existing unmodified chest or item | Preserve current native key, quest, quota and acquisition rules; no retroactive crime inferred |
| New chest explicitly granted to or crafted by a player | Record that character's lawful title separately from native physical possession |
| Public chest | Current permitted access remains public; depositing an item does not privatize it |
| Installing/removing a padlock | Only the recorded lawful chest owner may fit/remove it; tier must match; fitting does not transfer title |
| Owner opens a new padlock with matching key or tool | Open without theft warning |
| Another character opens a new padlock | Allow the confirmed bypass; warn and alert eligible witnesses exactly once on that committed closed-to-open transition |
| Preview, failed access, cancel or repeated held input | No warning, no transferred item and no changed claim |
| Breaking the new padlock with a blunt hit | One committed break opens it and runs the same owner/alert check; it does not damage or destroy chest contents |
| Explicit reward/gift or purchase | Existing authorized delivery transfers lawful title when it transfers the item successfully |
| Quest loan, equipped/reserved or temporary object | Existing exclusions remain; possession alone cannot turn a loan into a saleable gift |
| Existing world/death drops | Preserve current pickup entitlement and quantities; no retrospective title or crime is invented |
| Sell/recover ordinary owned items | Existing trade rules; no new stolen-price penalty, recovery demand or confiscation |

The ownership contract uses an explicit saved character/source identity, not
Inventory.Owner as proof of legal title. Native Actor.Inv/Owner and ItemId remain
physical inventory authority. Unclassified legacy objects retain existing access;
new lock ownership is assigned only by a recorded grant/craft/installation rule.
Old native locks are not converted into the new padlock system automatically.
A numbered, idempotent migration must retain native owners and quest restrictions.

### Household placement and delivery boundaries

Author decision, 2026-10-21: each city house (CAH000 through CAH159) receives one
small locked chest belonging to that household, initially containing ten native
gold coins. It uses the small 10-slot/100-kg storage tier. A matching native key
goes to the first existing household resident. A missing resident is not respawned;
if none remain, the chest still appears without creating an orphan key.
An occupied placement retries once per second without consuming the source.
The traveling household roster records issuance only after placement and native
contents succeed. Carrying away, emptying or destroying the chest never refills it.
Existing unrelated chests keep their prior access and contents. This explicit
household addition belongs to #382; #384's retained loot tables are unchanged.

Vendor/library availability is integrated separately under #383. Ordinary
prices, lock crafting and household availability are implemented here; there is
no new shop/replenishment rule or implicit gift/quest-title conversion.

## Recipe sheets, reading and practice (#378, 5.6.3)

The author's 2026-10-20 decisions supersede historical instant-learning text.
A recipe is a retained 5-g sheet stored in a native recipe book (100 g empty,
capacity for every recipe). The first sheet grants the book. A final recipe
includes the recipes of its recursive components; it grants no materials.
Each valid item tier has separate knowledge, rereadings and practice. Existing
single-tier ammunition, utility and fixed-output processing recipes retain
only their defined tiers. No new crafting catalogue is introduced.

| Source | Authorized contents and behavior | Status |
| --- | --- | --- |
| Ronnie starter lesson | Existing selected weapon, Pickaxe and current component/process routes; T1 source offers | Physical sheets; existing eligibility and gift allocation retained |
| Ronnie bow/crossbow help | Existing arrow/bolt recipe and components | Physical sheets; no added mission requirement |
| Ronnie Seal / Caella amulet | Existing confirmed choice and component recipes | Physical sheets; existing source checks and raw-material quotas retained |
| Retained processing-manual class | Existing processing set | Offers sheets; removed MAP01 manual remains removed |
| Old known recipes | Previously accessible valid tiers and their component sheets | Knowledge retained; new progress starts at zero |
| Library commerce | All final-recipe/tier books with components, grouped by existing categories; replace some repeated city shops | Approved; implemented separately under #383 |
| Other shops, loot and discoveries | No newly approved recipe assignments | Deferred to their own issues |

Source confirmation records pending entitlements once. Preview, back and rejected
source eligibility do not grant pages. Delivery checks the complete added mass,
including the first book, before attaching pages. Capacity failure leaves the
entitlement pending and retries without charging or repeating source rewards.
Duplicate source claims do not duplicate sheets. Pages are native book state;
knowledge/progress remain the existing character record. Moving the exact book
through inventory, Box or a chest preserves its pages and mass. Native unique
key-item rules allow one player-owned recipe book; no second ledger is added.

Use the book from inventory, or use the bookshelf while carrying it. A dining
table or bookshelf within the existing 96-MU interaction range and line of sight
is required. The live menu supports category, row selection, read/resume, cancel
and close. Closing or leaving range pauses; explicit cancellation discards only
partial reading. Losing the book releases the interrupted task. No page is
consumed. First completion teaches the selected tier and component recipes;
only subsequent complete readings increment that recipe/tier's rereading count.
T uses the existing x105 personal advance; Y opens the existing date skip and
its task-duration forecast. Both use actual reading tics and the existing
survival, sleep, provision, threat and thermal-effect guards. Sleeping grants no
reading progress; closing the book stops acceleration. No new time scale or
survival benefit is added.

For each recipe/tier, R = min(rereadings/10, 1), P = min(practice/limit, 1).
The limit is 10 equipment outputs or 1,000 consumable outputs (including native
material units for processing/components). A = 10 - 9*max(R,P), B = 10 - 9*P.
Time multipliers are 1 at 25%, A at 50%, A*B at 100%. Ten rereadings alone leave
100% at x10; full practice alone reaches x1. Caps never overflow. Only successful
manufacturing grants practice; reserved existing components, repair, dismantle,
cancellation, failed output and repeated completion grant none. Direct plans
credit only components actually made, alongside their final output.

The common time base is the same operation's 25% time. Equipment uses its exact
25% inputs; proportional subrecipes recompute each 25% input before rounding.
Fixed processing/component batches retain their original 25% batch duration and
normalize it by actual output units; their different yield is not mistaken for
an efficiency bonus. Material consumption/yield is unchanged. Each operation
applies its own factor once; recursive material loss still changes the number
of required suboperations. Started craft/reading durations and reserved practice
claims are snapshots, so later progress cannot rewrite a paused task.

Reading references the recipe's own tier, largest equipment size, 100% efficiency
and current per-recipe progress. It uses the full component graph with technical
attributes at zero, then divides by Intelligence M3 (I=0: x1; I=100: /8).
Equipment reading lasts one such craft; consumable reading lasts ten unit crafts,
normalizing existing batches by output. Subsequent readings become faster.
Approved library prices are 10% of equipment value or ten consumable unit values,
using that same tier/largest-size reference; actual sale integration is #383.

RecipeLearningRevision 1 maps old known IDs to their formerly accessible valid
tiers, retains the legacy bool, queues sheets and initializes progress to zero.
Reapplying it is idempotent. The reading task/book serialize as native inventory.
Retain the original save and matching package for rollback; revised saves are
not claimed compatible with the old executable package. Focused upgrade, reload,
travel and original-pair rollback evidence: assets/validation_563/RESULTS.md.
No routine global actor scan is added. Nearby reading furniture uses a blockmap
query; a typed bookshelf census runs only at mansion setup/migration.

## Ordinary native containers (#381, 5.6.2)

The author approved these rules on 2026-10-20. Every stash-derived chest,
including tutorial and labyrinth chests, supports deposit and withdrawal of
admitted physical inventory. One space is one native stack or individual item.
The existing chest is medium; each subsequent tier doubles height, length and
width. Existing meshes are scaled, without replacing art or changing maps.

| Tier | Spaces | Contents capacity | Empty mass | Relative linear size | Collision radius / height |
| --- | ---: | ---: | ---: | ---: | ---: |
| Small | 10 | 100 kg | 10 kg | 0.5 | 16 / 30 MU |
| Medium | 25 | 1,000 kg | 100 kg | 1 | 32 / 60 MU |
| Large | 100 | 10,000 kg | 1,000 kg | 2 | 64 / 120 MU |

`CaelumContainerRules` centralizes these data. Editor `args[4]` is 1/2/3 for
small/medium/large; zero preserves the existing medium default. No new campaign
placement, chest recipe, hit points or damage rule is invented.

`CaelumStashChest` remains an Actor. Its native `Inv` owns every stored physical
object. UI rows reference those objects; there is no second item ledger.
Transfers require the requesting pawn's current session, reach, existing lock
access, exact owner/object/amount and sufficient final capacity. Selecting or
previewing an entry never resolves unclaimed equipment size. Only a committed
withdrawal resolves it for that recipient. Acquired equipment retains identity,
size and wear; liquids retain their per-instance contents. A changed displayed
quantity or item invalidates confirmation. The requested quantity moves wholly
or nothing moves; partial stack requests preallocate their split before mutation.

Equipped or crafting-reserved objects, reserved material stacks, temporary quest
materials, protected initial/temporary equipment, Magic Box, Tarot deck and other
chests cannot be deposited. Existing single-instance personal restrictions and
MAP01 raw-material quotas still apply on withdrawal. The processing manual still
teaches its existing recipes when acquired. Arrows/bolts and native keys may
enter ordinary chests; withdrawals use only personal inventory.
A legacy boxed arrow/bolt receiving stack is rejected unchanged;
the inherited city-trade routing discrepancy is recorded, not silently normalized.

Use opens storage on ordinary chests. In tutorial/labyrinth previews, **D** opens
stored objects; their existing explicit collection remains available. Those
authored reward/material quotas are not cloned into a physical inventory or
reseeded during migration. Existing retired `LegacyLoot` remains excluded.
Storage uses Up/Down, Left/Right quantity (all/1/5/10), Space deposit/withdraw,
Enter transfer, C carry/place and Q/Tab close, with equivalent native-menu
buttons, row selection and mouse wheel. The live menu does not pause simulation.
Run+Use can carry a closed chest. The carried inventory entry opens its contents;
the ordinary drop action places it only where collision and sight checks pass.

Carried mass is empty mass plus all physical contents, without Box compression.
`CaelumChestCargo` is a player inventory handle to the same chest Actor, not an
Inventory containing another Inventory list. Chest and contents travel together;
their thinker lists, world links and map-local TID registrations are restored
at arrival. Destruction detaches and drops exact physical contents. Existing
locks retain native keys and unlock state; ownership, new padlocks and theft
consequences belong to #382.

Storage migration revision 1 initializes legacy chests as medium without
replacing bodies, opening/lock fields, contents, looted gaps or visited-map
geometry. Labyrinth storage-loot policy revision 1 captures the source policy:
transporting a cardinal chest outside MAP02 never enables its retired equipment
catalogue. Initialization is idempotent. Preserve an exact original save/package
pair before upgrading; the isolated fixture also removes the new session,
restores the prior open state and loads that save with 5.5.8a, which ignores the
added metadata. New carried-container classes are
a new-runtime feature, not an unrestricted old-runtime save guarantee.

Native and static evidence, exploratory failures, source/package hashes and
rollback boundaries: `assets/validation_562/RESULTS.md`. No routine global actor
scan, measured FPS improvement, network multiplayer or author acceptance is
claimed. Author check CA381-01 remains outstanding.

## Merchant coordination and commit ownership (#377, 5.6.1)

`equipment/CaelumMerchantCoordinator` is a stateless `Object play`, receiving
the requesting pawn and, for city trade, its current `CaelumCityTradeSession`.
Thirteen retained pawn methods and five retained session methods are adapters.

| Boundary | Authoritative owner and lifetime |
| --- | --- |
| Palomo stock/wallet | The existing persistent character record owns product counts, wallet and negotiated discount; pawn arrays are refreshed projections. They are never shared with city vendors. |
| City stock/wallet | Each `CaelumCityMerchant` owns native `Actor.Inv`, initialization/revision flags and WalletCopper. Lazy first-open seeding remains unchanged; #385 subsequently adds elapsed-calendar production without reseeding on open. |
| Session/UI | Pawn fields retain active actor, conditions, selection, quantities and quote. The existing city-session object retains vendor, native row references and display arrays. Closing clears the projection, not inventory; existing travel hooks close it before persisting. |
| Preflight | Coordinator revalidates session, selected product/instance, quote, quantity, stock, money, stack bounds, personal load and Box capacity. City operations require the requesting pawn's actual current session and active vendor. Palomo refresh may not silently substitute a same-price row. |
| Commit | `CaelumInventoryService` prepares missing currency instances and any new product or split stack before attaching, debiting, crediting or transferring. Existing currency plans remain authoritative. Exact equipment retains its state/ItemId, subject to the existing native acquisition collision rule. |

Successful operations refresh UI/derived load and persist through existing
hooks. No new saved ledger, schema revision, price, stock, wallet rule, access
condition or automatic replenishment is introduced. Existing city wallet
overflow rejection and Palomo's saturating wallet behavior remain distinct.
Input routing and crafting close/pause order are preserved; changing merchant
families now clears the old city projection.

No routine actor scan is added. Quotes traverse only the selected owner's
native inventory; the existing city initialization uses its 64-shop preparation
and typed lookup, unchanged by this patch. This extraction claims no measured
FPS improvement or stress-scale acceptance. Static/native/save evidence and
limits are recorded in `assets/validation_561/RESULTS.md`.

## Crafting coordinator and unchanged state ownership (#376, 5.6.0)

`crafting/CaelumCraftingCoordinator` is a stateless `Object play` receiving the
requesting pawn. Forty-eight retained `CaelumPlayer` adapters delegate the
existing blueprint, recursive plan, preview, selection, task start/cancel/time
and station-session policies without changing statements or quoted literals.

| Boundary | Owner and call direction |
| --- | --- |
| Live task | Pawn fields retain kind, stable recipe/target ItemId, tier/size, efficiency, network, reservations/output arrays and remaining time. Coordinator methods operate on that same pawn; no service instance or second task exists. |
| Planning and UI | Station, browser, Journal and time-advance callers retain their pawn adapters. Preview/layer/direct-plan fields remain reconstructible projections. They do not replace a started task's snapshots. |
| Reservations and outputs | Coordinator calls pawn adapters into the accepted `CaelumInventoryService`. Its existing reservation/consumption, capacity and completion authorities remain unchanged, including repair/dismantle exact targeting and tutorial output. |
| Persistence | `StoreCraftingTaskState`/`LoadCraftingTaskState` remain unchanged. PreTravelled closes sessions then persists; Travelled restores the explicit record snapshot. Native save/load retains the original field and class identities. |
| Lifecycle | Input, Tick and personal-time ordering are unchanged. A closed/distant/dead session pauses; combat pauses; explicit cancel releases reservations; completion clears the task. Existing final-capacity rejection is retained. |

Existing per-layer 25/50/100% efficiency and 1/10/100 time factors, recursive
quantities, station requirements, ammunition/utility and knowledge rules stand.
Recipe learning remains with its accepted record owner for #378.
The active station class is `src/caelum/crafting/CaelumCraftingStation.zs`;
the inactive `src/crafting` duplicate is neither activated nor removed.

The existing station graph traversal is reviewed, not altered: the requesting
session rebuilds on interaction and at its existing once-per-second validation
boundary, with the existing shared time-skip guard. Each reached station uses a
typed `CaelumCraftingStation` iterator and the existing player/token cycle guard.
It is bounded by the stations present in the loaded map, not by combatants;
its cost grows with reachable stations times total stations. The isolated
12-added-station fixture measures this inherited path separately. This evidence
does not establish a general maximum for dynamically added networks, display FPS
or a new optimization; no new global scan is introduced.

No migration is needed for this stateless move. Keep original 5.5.8a package/save
copies and upgraded saves separately. Native-created paused-task checkpoints
retain exact worn duplicates, knowledge, input reservations and remaining time
through reload and hub/non-hub travel. Original and upgraded checkpoints were
also tested with the original package; see `assets/validation_560/RESULTS.md`
for actual packages, hashes, commands, fixture limits and author-test status.

## Bull presentation and reversible saves (#369, 5.5.8)

Artwork revisions refresh saved helper render bounds during the existing
typed load census. This changes only the non-colliding visual helper; the
original bull's physical cylinder and save schema remain unchanged.

On 2026-10-19 the author approved a uniform 1.5 visual enlargement for inspection,
retaining the original physical cylinder and combat. The MD3 geometry and
distance-driven visual gait stride share that factor (39/78 map units for
walk/run), without changing native speed or state timing. The visible body
therefore intentionally extends beyond its unchanged physical cylinder.

All ordinary bulls and the existing MAP01 tutorial subclass use the cleaned
animated model by default. This is a visual replacement: attributes, damage,
Air costs, charge acceleration/cap, cushioning, anatomy, health effects,
collision cylinder, AI, native state indices/tics and tutorial grace/fade remain
authoritative. The gore wrapper calls the original melee action exactly once.
Its three-tic visual notification can overlap the next preparation; charge,
pain and death take priority. This does not introduce an attack delay.

Each bull owns at most one non-interacting model actor. Visual revision 1 is
idempotent and initializes lazily in old saves, including tutorial early returns.
Archived corpses retire their helper; Recall recreates it when ticking resumes.
Redemption invisibility and tutorial alpha/fade are mirrored. The shared >=500
living-combatant census is unchanged; model actors are not combatants.

`ca_bull_3d false` restores original sprites and retires helpers. Before opening
a new save in a pre-5.5.8 build, disable the CVar, allow several unpaused tics,
and save a separate copy. Keep the original save/package. Load that copy with
its matching map revision; `ca_bull_3d true` restores models in the current
build. A save made with active helper instances requires the current build.
The visual registry blocks recreation from WorldUnloaded until WorldLoaded,
so inactive hub snapshots contain native bulls without the helper class. Native
old/current/rollback and inactive-hub tests establish this procedure; do not
infer backward compatibility merely from an active-map screenshot.

## Maximum siege adrenaline in production (#361, 5.4.47)

During the active MAP03 siege, only registered NPC/monster attackers (including
Zupay and new reinforcements) and bound defenders retain their existing individual
maximum adrenaline. The player is always excluded, including inside the city,
to preserve seal-channel balance. Peaceful residents and unrelated actors do not
join by proximity. Victory, departure from the city or lost encounter ownership
ends the forced maximum. Dead bodies are not refilled; a living resurrected
participant qualifies again. This gameplay rule remains consistent as population
changes; maintenance caches independently retain their >=500-body threshold.

NPC saturated wound-performance and pain formulas use their exact result of
one. Actual damage, thermal/elemental penalties, immobilization, individual
inventory/resources and combat timers remain. The player's original adrenaline
gain/decay, needs/wound mitigation and seal spending/exhaustion run unchanged.
No tick, damage event, city arrival or channel cost grants a forced player refill.
A save from the earlier player-inclusive preview keeps its current reserve and
then follows ordinary rules; it is neither refilled nor arbitrarily reset.

NPC membership uses existing ownership. No player-port cache, recurring actor
scan or saved schema is added. The author explicitly removed the player from
the initial candidate on2026-10-18. See validation_5447 for revised native
correctness and old/current/earlier-preview save/hub evidence.
FPS evaluation is deferred by the author; no measured gain is claimed.

## Demon breath excludes navigation markers (#357, 5.4.45)

CaelumSewerEscapeTarget is an invisible technical destination used by native
chase, including artillery routes. Its shootable/invulnerable flags do not make
it a combat target. Demon breath must neither start an attack against it nor
aim cold/restraint fire at it. Actual targets retain existing range/visibility
checks. Cold and real bolas independently permit fire with the existing cost,
contact heat and release behavior. An already-running false attack stops through
the ordinary per-body update, including when loading an earlier save. No actor
scan, new target-selection rule or saved schema is added.

## Structural-cache research outcome (#354, 5.4.44)

Normal gameplay retains the conservative #353 armor/personality dependency
guards. A private prototype removed 17 structural reads per health/offense query
and invalidated the owning NPC at current armor/personality mutation sites,
including wear with zero HP damage and Rulo repair. It retained scalar/weight
guards and 100-tic fallback. Correctness checks and matched combat state passed,
but paired FPS gains were inconsistent. This is not an adopted rules change.
Future writer notices cannot replace immediate correctness with a delayed
fallback. The 35-tic thermal cadence remains; #361 separately adopts siege
adrenaline above. Evidence: validation_5444/RESULTS.md and CA-KP-132.

## Production actor maintenance (#353, 5.4.43)

At the existing automatic threshold of at least 500 living shootable combatants
across the map, NPC derived health/offensive statistics and carried weight use
owner-local caches with fallback phases distributed over 100 tics. Scalar and
armor/personality guards still detect changed inputs at the point of use.
Native add/remove/use/stack/split and current direct item writes invalidate the
affected owner's weight. Cache hits restore all assigned outputs, including
Speed; actual health, damage, resource spending and inventory remain individual.
Below the threshold the original calculations run and derived caches invalidate.
Only redundant recovery when health, anima, air and lucidity are already full
is skipped; active recovery and combat/status timers retain their original step.

Only the port attackers' existing command groups adopt phased 100-tic shared
target searches at high density. Other factions keep their existing AI rules.
Death/destruction invalidates subscribed groups locally; native attack LOS/range
checks still apply. This deliberately changes target response from the old
8-tic high-density cadence. Empty searches also expire within 100 tics.
Transient caches/subscriptions rebuild after load and clear on body travel;
maintenance revision 1 and targeting revision 3 are idempotent migrations.
No new recurring actor-wide scan is introduced: population phases are assigned
through the existing census and lazy owner-local initialization.
Temperature remains at its existing 35-tic cadence. The separately approved
maximum-adrenaline rule was outside #353 and is adopted by #361 above.

## Actor-local maintenance experiment and siege focus (#318, 5.4.42)

The author requests actor-local change notifications, with fallback work spread
across 100 tics, first for statistics/inventory/resources and then for target
selection/temperature. The private experiment caches derived values, not actual
health or damage. Active resource recovery, movement, physics, stun and combat
timers retain their existing tic cadence; only already-full resource balances
skip redundant recovery. Cache hits restore assigned outputs such as Speed.
Native inventory ownership/use/stack/split changes notify their owner. Direct
inventory writes require explicit notification; a fallback deadline is not
proof of same-tic correctness. No recurring actor-wide discovery scan is added.

Approved siege design: participants remain at their existing maximum adrenaline.
Ignore injury/pain and hunger/thirst performance penalties while retaining real
injury, consumption, critical-state damage and other thermal/elemental/reload or
immobilization effects. The maximum-adrenaline wound formula may use its exact
simplified result. The player's existing maximum-adrenaline rule already
suppresses hunger/thirst performance penalties; NPCs do not run that player
needs calculation. The later #361 production decision above excludes the player.
Combat timers must continue. This policy was tested only in
the diagnostic runtime at this checkpoint; #361 above completes production
ownership and lifetime handling without adding persistent state.

Target100 changes the existing shared 8-tic search cadence to 100 tics; death
notifications and native attack LOS/range checks remain. Thermal100 changes
an existing 35-tic periodic solver step, retaining forced updates. Neither is
numerically/behaviorally equivalent to its baseline, and no thermal error
tolerance is approved. Maximum adrenaline is itself a gameplay-rule change;
only a comparison against the same rule isolates formula simplification.
See [methods, evidence and limits](../assets/validation_5442/RESULTS.md).
The >=500 living-combatant automatic policy remains authoritative for accepted
production optimizations; this prototype does not complete that delivery.

## Isolated performance controls (#318, 5.4.41)

The nine-family benchmark is a diagnostic, not a gameplay mode. It retains
actor identities/inventories and replays recorded calls over a frozen MAP03
scene while gating other families, attack effects and impact-energy response.
Copied thermal/status states and pose restoration prevent those effects from
turning it into an evolving battle. Caches/navigation are not fully rolled back.
Results include instrumentation and cannot be summed as removable production
costs or converted directly into normal-combat FPS. No resource, targeting,
collision, thermal or inventory rule changes in this delivery. The automatic
500-living-combatant policy and approved siege budget remain authoritative.
See [evidence and exclusions](../assets/validation_5441/RESULTS.md).

## Shared rest and acceleration safety (#325, 5.4.40)

The author requires the same safety policy for lying down, T acceleration and
Y destination advance. Living hostile bodies at an inclusive 1024 MU (32 m)
block them only with line of sight; walls, friendly and dead bodies do not.
An active arcane cloud blocks all three, including in-progress personal batches.
Existing life/profile/solo/combat/siege/ground/water/busy/needs checks remain.
T still needs an actual rest or work session. MAP01 retains its timeless
furniture/workshop exceptions with actual reach/height checks. Safety no longer
requires an authored zone merely because the player accelerates a valid rest.
Reachable/current furniture is available locally; remote support access retains
its existing map/zone rules and excludes threats around that support.

Burning, poison, disease, bleeding and thermal exposure permit rest and both
advances. They consume their existing durations and inflict their actual damage;
burn heat accrues once per personal tic, while physical movement/action heat
continues to use real world steps. Permitted periodic damage reduces session HP
baselines by its actual loss, without interruption. A new accepted attack stops
rest/T/Y even if mitigation or subsequent healing conceals its net HP loss.
Death ends all three. This does not weaken injury, pain or resource rules.

Revision-1 pain provenance keeps separate periodic and nonperiodic timers.
Old unidentified pain migrates as nonperiodic until its own timer expires;
new DOT cannot reclassify an earlier hit. Resurrection/training resets and
journey elapsed time synchronize these clocks. Current saves retain their
individual states, supports, effects and personal clocks. Unsupported task
forecasts explicitly report an active-effect limitation; manually selected
future destinations remain available under the shared execution policy.

Generic unadapted powerups block all three; supported regeneration and Tarot
flight retain their adapters and ordinary physical constraints. Enemy queries
use the native blockmap plus the existing unlinked-guard registry, once per
physical validation batch; sleeping-bag body checks use a bounded blockmap
query. No per-substep whole-Actor census is introduced.

## Voluntary-jump wall cushioning (#339, 5.4.39)

The author extends biological wall cushioning ONLY to an actual voluntary
terrestrial jump, including ascent, apex and descent after releasing jump.
A fall from an edge or a push without takeoff does not establish this state.
This supersedes the earlier ordinary airborne exclusion only for map walls;
airborne contact with actors or props gains no new allowance. The existing
1.5 * jump absorption speed and squared residual-energy fraction remain;
load, health, Agility, elemental modifiers, buckler and immobilization retain
their rules. Excess energy can still cause injury or death.

Only confirmed native CheckJump takeoff arms the pawn's revision-1 state.
Physical support ends it; so do death, hub travel, swimming, flight and being
held by telekinesis. Ordinary immobilization suppresses capacity without
reclassifying the original jump. A push during an already voluntary jump does
not erase its origin or separate impulse components. Current airborne saves
retain the state; old saves migrate idempotently without inferring a jump from
velocity or a held key. The next real jump establishes it normally.

## Complete map-legend collapse (#321, 5.4.38)

The author moved the cartography panel to its existing8-pixel top margin,
without reserving additional space for console notices. Collapse hides its
background, border, location, calendar/orientation, controls, notes/POI labels
and tracked-quest rows. Only "ver leyenda (L)" remains in Spanish with the
default key; English and rebound/unbound-key hints remain supported. This is
presentation only: discovery, notes, quest tracking and native map data persist.

## House doors do not inherit vehicle presentation (#334)

The author's revised October 18 decision supersedes the previous no-animation
request: MAP03/CAH house doors use Melt on both entry and exit. Each accepted Use
captures the current view before committing the travel; the house owns its
source image independently of any unfinished vehicle presentation. The one-use
TRAVEL_WIPE_HOUSE_DOOR intent still survives PreTravelled and is explicitly
resolved to Melt in UI. Native arrival protection is allowed to expire while
the source image remains visible; the destination then appears through Melt.
The possible initial native pass is explicitly Fade between the held source
images: unlike Melt, it does not shift identical columns. Only the final pass
uses Melt. This is a per-transition override, not a global wipetype change.
Native loading icons, arrival autosaves, resident/hub state, global wipetype and
intermission settings remain. Ship/cart and tarot presentation keep their rules.
No saved schema changes: transient capture ownership is cancelled on load, new
game, failed confirmation or an unrelated transition. Old saves remain usable.

## 5.4.35 - Coherent prisoner escort movement (#322)

The author's October 18 decision replaces #307's source-actor walking pace for
ordinary escort with the player's walking formula, using each prisoner's own
effective Agility, carried load/capacity, Air, health, temperature and elemental
penalties. The shared base is 4 m/s; Agility uses the existing Type-2 curve.
Acceleration uses the player's three-second reference at 100 kg, scaled by the
prisoner's body plus carried mass. NPCs acquire no new hunger/thirst/sleep needs
or automatic running policy. Combat and boss escape retain their existing rules.

One Tick owner chooses waiting, following, conversation, recovery, combat,
boss escape and extraction. Escort poses perform no Look/Chase action: they use
the existing four-tic walking cadence during movement and an inert standing pose
while waiting/speaking. Nearby friendly sound cannot switch the escort into native
wandering. The approved 96-MU follow radius and 1,024-MU recovery distance remain.
An approaching player's current movement command can request a traversable
sidestep or retreat; body collision is never disabled to yield the passage.

A bounded trail starts at release; a local footprint-aware grid detours around
corners and bodies. Closed doors and impassable geometry require waiting or an
available route. No global actor scan is added. Recovery validates native body
fit, all solid bodies including non-shootable props, floor support, step/dropoff
limits and separation from the player. No candidate means no relocation; the
old fallback onto the player's position is retired. Physical immobilization
prevents navigation and recovery.

The original actors, identities, rescue/reward records and state offsets remain.
A lazily initialized revision-1 controller migrates old escorts without changing
their health, inventories or progress. New idle states are appended after the
existing states. Native/save verification passes 23 runs/375 assertions,
including full rescue progression and one-time port rewards. CA322-01 author
acceptance remains pending; assets/validation_5435 retains the focused evidence.

## Automatic saves after five minutes of active play (#324)

CaelumSaveRules.ACTIVE_INTERVAL_SECONDS = 300 is authoritative. The local
monotonic timer counts only living, initialized single-player gameplay outside
pause, menus and console. Time spent loading is excluded. Calendar fast-forward
does not multiply this clock. The author's 2026-10-18 clarification starts each
interval after the latest autosave, including map/house entry and checkpoints.
Transition autosaves remain enabled according to native settings. Travel without
an enabled arrival save carries elapsed time and one due request; new games and
loading any save restart the interval and discard stale requests, avoiding
load-save loops. Manual saves do not reset the interval.

CaelumAutosaveEvents is the sole owner for periodic requests and the existing
Rulo checkpoint. It adopts the native arrival request through special 15, once
per map transition, preserving its enable/disable policy. Requests that will
write the same destination coalesce; a completed checkpoint in the previous map
does not suppress the destination's arrival save. Encounter preparation remains.
A temporarily invalid body or
pending native game action retains one due request. Native disableautosave and
autosavecount determine whether a file is written and which rotating slot is
used; no private filenames, manual-slot overwrite or unbounded archive is added.

Autosave (native special 15) is asynchronous. Two ordered network acknowledgements
track native eligibility and dispatch; death before eligibility retains one due
request. Settings-disabled requests wait a fresh interval. Observing native
ga_autosave at PostUiTick and its following network message starts the clock
after the write action,
including external native requests and a single rotating slot. Neither an ACK
nor action observation confirms successful disk IO. After native acceptance,
GZDoom retains its queued-write behavior, including a death or map change before
the write. Actual generated-file loading is separate evidence from request counts.
One STAT_DEFAULT query per map arrival locates native Autosaver, whose class has
no ZScript type. This group can contain actors; it is a single global traversal
at transition, with no recurring global scan during play.
No new persisted character fields or save migration are needed.

## 5.4.31 - Collapsible automap legend (#321)

The full-map legend starts collapsed and shows its current native toggle binding.
The local command ca_map_legend expands/collapses help. Location, clock, focused
POI/notes and tracked objectives remain independent of the legend. Closing the
map, loading a save or entering another map collapses help again. This UI-only
state is not character progress and adds no save schema. The expanded layout
retains the existing font, wrapping, scaling and resource-area bounds.

L is the new-install/reset default, declared in controls_catalog.json; existing
INI assignments/cleared bindings are preserved. Automap Controls exposes the
command. Hints query both native binding tables, including map-only shadowing,
and reflect remapping/unbinding immediately in English and Spanish. No polling
code or repeated KEYCONF defaultbind restores cleared keys. The controls
regenerator now preserves independently maintained aliases after its generated
block. Evidence: assets/validation_5431; manual CA321-01 accepted 2026-10-17.

## 5.4.30 - Sleeping bag in quick items (#319)

The owned sleeping bag now joins consumables in the bottom-center native
previous/next selector. Its existing icon, name and quantity identify the exact
Inventory instance. Native Use opens its existing live rest interaction without
consuming the bag. Deployment, pickup, capacity, ownership and rest guards remain
in force. A boxed bag is excluded until retrieved; stale selection reconciles
on ordinary inventory changes and loading. No inventory/save schema is added.
This extends the #282 eligible categories below; ordinary consumables and water
containers retain their existing behavior. Evidence: assets/validation_5430.
Author check CA319-01 accepted on 2026-10-17; scope in HISTORY.

## 5.4.29 - Current map catalogue and staged city siege (#327)

The author adopted the low-sky city as MAP03 on 2026-10-17 and retained MAP01
and MAP02. assets/map_catalogue/MAPS.json supplies generator map identities;
CaelumWorldCatalogue retains its stable location/connection IDs. In particular,
LOCATION_PORT remains 6 and LOCATION_RESERVOIR remains 3: IDs are not lump numbers.
Historical CA_MAPxx_NAME localization keys remain content identities, not selectors.

| Current lump | Content | Previous lump |
| --- | --- | --- |
| MAP01 | Mansion, campaign | MAP01 |
| MAP02 | Sewers, campaign | MAP02 |
| MAP03 | Barracas al Sud, campaign | MAP06 |
| TRESERV | Reservoir and siege-asset trials | MAP03 |
| TTAROT | Tarot chambers test | MAP04 |
| TMAINT | Maintenance test | MAP05 |
| TCOAST | River coast test | MAP07 |
| THAZARD | Hazard gallery test | MAP08 |
| TACTORS | Historical actor stress fixture | CADEV02 |

CAH000..CAH159 remain private city interiors. Existing ancillary connections
and content remain available, without granting these scenarios campaign status.
TACTORS is retained for provenance, not authorized as a routine stress launch:
it contains 16,508 placed things. No 6,000-simultaneous-attacker run is permitted.

generate_city_ceilings.py applies CEILINGS.json's adopted policy: house/shop lots
plus half the authored road width receive INTERIORS.json's 184-MU roof-height
physical sky. Retained houses use their existing doorstep/road bounds. The outer
wall-walk belt, elevated floors and taller volumes keep their previous ceiling
(1,024 MU outdoors). Marking cells before compaction splits shared sectors; a
roof closed at floor==ceiling uses its opaque flat. Ground geometry, footprints,
shop doors/windows and high wall/tower access are retained. Sky streets remain
thermally outdoors. Flight stops at low ceilings; closed roofs cannot be stood on.

REINFORCEMENTS.json and generated CaelumReinforcementData are authoritative:
revision 2, groups of 100, interval 350 simulation tics, deployment living cap
1,000, total 6,600. The 74 initial attacking operators count within the first
100. Zupay appears at the existing siege start, separate from the Mandinga budget;
600 soldiers, 12 hostile machines and 42 guns retain their rules. Normal MAP03
enables staged deployment automatically, even when ca_test_siege_reinforcements
is false. The old CVar cannot select a full simultaneous army in this city.

The first group enters at siege deployment; later groups follow the inherited
350-tic cadence. A complete new group needs 100 vacancies; partial groups retry
their missing slots before another group. Failed placements consume no budget.
Recount only owned registered bodies at each eligible opportunity, including
offscreen and revived bodies; there is no new map-wide per-tic scan. Living is
therefore the last opportunity census, not an always-current HUD population.
Missed opportunities do not accumulate. Six thousand authored formation positions
are reused cyclically for the 6,600 arrivals; no extra coordinates are invented.

Author clarification: the cap limits reinforcements, not resurrection. A revived
body may temporarily exceed 1,000; new groups wait for sufficient room. Resurrection,
resources, collisions and ordinary corpse retention are unchanged. Existing
victory (all 12 hostile machines plus commander defeat/confirmed retreat) stops
unused reserves before that tic's spawn opportunity. 6,600 is the available
cumulative budget, not a requirement to continue spawning after victory.

Counters, placed bitmap, deadline, crew identities and formation cursor are saved
with the city; hub return does not redeploy them. Revision 1 data updates once,
preserving successful arrivals, pending slots and deadline; enabled remaining
budget becomes max(0,6600-successful). This schema handling does not make old
MAP06 hub saves compatible with renamed maps. Start a fresh campaign under the
author's explicit waiver; retain old saves and full b9fd71ce package/checkout.
Old MAP06 compatibility switches now reject the new catalogue before overwriting
any output. The preceding #132 opt-in/full-army text is historical and superseded
for current gameplay by this section.

## 5.4.28 - Contact-only breath and performance boundaries (#318)

Latest author decision, 2026-10-17: 6,000 simultaneous attackers are ruled out
for the game and must never be stress-tested again. The last active diagnostic
was stopped on request; earlier results remain historical evidence. Current
geometry comparisons use peaceful scenes and 1,000 attackers/600 defenders.
Normal code still contains the rejected full-army deployment until its bounded
replacement is implemented; no new production budget is silently selected.

The author subsequently authorized separate house interiors. Fresh MAP06 keeps
all 160 houses at their original XY bounds, width, depth and roof height (184 MU).
Their solid exterior shells preserve street widths, lots and public routes.
Front-door Use enters the corresponding CAH000..CAH159 hub map; Use inside
returns to that house's original doorstep. Windows in an isolated interior do
not show or connect to the city. Shops/factories remain in MAP06; six original
painted trade signs identify the existing shop categories without changing stock.

The author also requested an isolated comparison with these same interiors and
house walls extended to the existing 1,024-MU sky ceiling. This diagnostic keeps
XY boundaries and street widths; it changes sight, projectile paths, flight and
thermal geometry. Its closed sector uses an opaque roof ceiling material to
avoid GZDoom's both-sky clipping exception. It is not a renderer-only switch
or a production height change. Measured peaceful rendering improves strongly;
the 1,000-attacker siege still misses 60 FPS and 6,000 attackers remain near
0.7 FPS / 12 tics/s. The experiment does not authorize new army counts or walls.

The later author-requested variable-sky diagnostic keeps the same house shells
and separate interiors. House/shop districts use the existing 184-MU roof height
as their physical sky ceiling; the wall-walk belt, towers and nonresidential
exterior retain 1,024 MU. Districts derive from authored lots plus half the road
width, with footprint/door/road bounds for retained houses. Higher floor or
3D-volume cells are excluded. Closed roof sectors use their own opaque material;
open streets retain F_SKY1 and remain thermally outdoors. Shops keep their real
160-MU interiors and existing windows. This geometry preserves XY footprints
and street widths, but limits upward movement and removes standing space on
the closed house roofs. It is a measured test variant, not an adopted flight,
roof-access or production-map rule. Normal MAP06 and army totals are unchanged.

The 600 defenders keep stable individual identities. A first house visit creates
its original three/four residents. The player-owned native travel carrier keeps
each created body, inventory, injury, gear, ammunition and active state; unloaded
residents are suspended, not reconstructed or simulated. Unvisited house bodies
are instantiated on their first visit or deployment. Native hub clock semantics
remain: a siege date reached inside a house starts the city encounter on return.
Each city tic attempts one pending defender at its own door. Occupied exits
retry; dead or previously raised identities do not create replacement soldiers.
Effective cannon assignments survive travel, including replacements and pending
placement. Redemption owns active converted followers; the house registry still
owns their bound auxiliary and preserves bodies after conversion expires.

Registry passes are bounded by 600 identities and run only on initialization,
map transition or deployment start. Ordinary ticks attempt at most one pending
placement and one deployment identity. There is no new global actor census.
This prototype changes defender placement; the existing synchronous 6,000
attacker path is still unresolved. Do not report the defender-only diagnostic
as proof of a playable complete siege. Current saves/hub behavior pass isolated
native checks; author checks remain pending. The previous-save waiver remains
in force.

The author requires a functional normal MAP06 and rejects creating its full
6,000-plus attacking population in one update. This is an outstanding production
requirement: this patch does not yet change attacker deployment or authored counts. The
author-requested 1,000-Mandinga control is a benchmark only, with 600 soldiers
retained. The existing #132 reinforcement CVar is
still an opt-in experiment, not completion of the new normal-play requirement.
Do not silently adopt a new live population/group budget from a benchmark.

The additional flat-map tests compare 6,000 Mandingas/1,000 sword-and-shield
soldiers with 1,000/600, including the author-approved Domingo visual substitute
and author-requested empty Mandinga inventory. These are isolated diagnostics:
normal inventory, army budgets, RPG resources/collision and production art remain
authoritative. Inventory removal changes carried weight, attack air and collision
mass as well as potion use; it is not a gameplay-equivalent optimization.
The recorded 1,000/600 result does not validate MAP06's geometry or controller.

The author removed demon-breath radiation and selected the absorbed contact
power for persistent burning heat. Only accepted local contacts receive it,
including the existing summoned-demon and Redemption restrictions. The previous
four-source geometry, 20 kW source, 35% budget and armor retention determine
contact watts; normalize across simultaneous contacts and apply armor once.
Store watts for the existing base burn duration times emitter power, with the
existing stronger-power/longer-duration nonstacking priority. Toughness still
governs health effects; it does not reverse thermal energy. Generic burns do not
invent or extend contact heat. Fire visuals remain while this heat duration runs.

Each receiver accrues watts times real simulation seconds. The player consumes
queued joules on its real thermal step; NPCs retain them until their normal
scheduled update, without forcing per-tic environmental sampling. Logical
personal steps do not create heat. Save/load and hub state preserve power,
remaining duration and queued energy. Status revision 1 initializes unknown
legacy contact power to zero; breath revision 1 discards already-paid but
untransferred legacy radiation once, preserving resources and applied thermal
history. Resurrection clears active/pending heat. Rest acceleration and journey
forecasts remain blocked while heat is active or queued.

This supersedes only demon-breath radiation. The utility wand retains its
approved heat/cold radiation; its global Transfer scan remains an identified
performance task. Existing cold-triggered breath activation is unchanged, even
though breath no longer warms its emitter. Routine global actor scans now require
a documented correctness need, bounded trigger/frequency and measured large-map
cost; see AGENTS and CA-KP-115.

Door removal, idle-blocker controls, component disabling, scene freezing and
unrestricted collinear merging under validation_issue318 are isolated diagnostics.
Their improved timings do not authorize removing required collision, physiology,
resources or individual combat. In particular, collinear merging may change
texture phase and line-endpoint-based thermal shelter classification, even when
physical boundaries are retained. It needs equivalence and save/hub validation
before any production use. Keep the >=500 automatic policy authoritative.

The subsequent author-requested conservative MAP06 reduction is integrated into
normal generation: 1,574 to 1,563 sectors and 86,382 to 61,817 lines. Only identical
untagged world sectors and physically open boundaries are simplified. Every
physical wall endpoint, texture, light, tagged sector, 3D control and map actor
is preserved. Native probes compare 3,006 positions, including roofs, windows,
interiors and gun routes. This static map reduction applies to fresh/unvisited
MAP06 regardless of population; it adds no per-tic actor scan or hidden barrier.

The author then authorized replacing MAP06's 960 leaves with native PolyObjects
and waived previous-save compatibility (2026-10-17). The original models remain
nonphysical visuals; finite two-sided 3D middle textures provide 64-by-8-MU
collision up to 120 MU. Both sides of each native face accept Use. Six mapped
leaves per home replace runtime interior placement and all 7,680 blocker actors.
The final geometry has 1,565 sectors and 65,661 lines, including disconnected
storage for the native contours; physical city boundaries remain unchanged.

Requests address the registered pair directly, preserving its existing access
checks, swing-away direction, 90-degree travel in 16 movement tics, 105-tic wait,
wait renewal and interrupted-close reopening. One temporary controller guards
each active pair. Moving/blocked pairs inspect only nearby solid bodies, using
the native axis-aligned actor boxes against the swept door rectangle. Fresh
controller/action ordering prevents a body from moving between the check and
native rotation. No thrust or crushing is permitted. Closed pairs have no such
controller. The existing owned opening sound remains; native motion is silent.
Other maps and legacy MAP06 layouts keep their prior actor-door path.

Fresh/unvisited MAP06 uses this geometry automatically. Current saves preserve
native line references, pair registry and active controller/action order; do not
re-register an already rotated leaf on reload. Previous-save conversion is not a
delivery gate under the author's waiver. Exact backups and optional
LegacyMap06Furnished recovery builds remain; these retain rather than convert
old geometry. The earlier geometry-continuation evidence is historical proof
for that checkpoint, not certification of every old save on the native map.

Opaque closure is a separate design control: closing the house walls/interiors
makes the native renderer discard much more geometry, but extends facades upward
and removes overhead/roof space. It is excluded from production. Transparent
walls cannot correctly discard visible background; invisible occluders would
hide visible scenery. A distance trigger can change a real closure, but also
changes collision, shots, AI sight and flight. The suggested 1,000 MU is an
example, not an approved rule. District/map splitting remains a design option.

Performance acceptance must distinguish frame presentation from simulation
throughput. The author expects 60 FPS in mansion/sewers; fixed entrance checks
do not certify every view, route or battle. See
[evidence](../assets/validation_issue318/RESULTS.md) and KNOWN_PITFALLS CA-KP-110
onward for reproducible controls, source-backed causes and measurement limits.

## 5.4.27 - Normal-speed prisoner following (#307)

Ordinary freed-prisoner steering uses the shared resolved Speed: the existing
base movement with health, thermal and elemental modifiers, converted from the
existing four-tic See step to continuous per-tic velocity. The unchanged walking
cadence is shared as PRISONER_WALK_STATE_TICS; it is not a new balance value.
Following grants no extra run multiplier or distance-based acceleration. Followers stop within
PRISONER_FOLLOW_DISTANCE (96 map units) and approach again when the player leaves
that radius. On 2026-10-16 the author explicitly retained recovery teleport
beyond PRISONER_FOLLOW_TELEPORT_DISTANCE (1024), with existing collision-safe
placement. This supersedes the ordinary-follow run ratio recorded in 4.36.8's
third correction; boss escape retains its separate behavior. Rescue, combat,
resource recovery, conversation, extraction and rewards keep their existing rules.
No persistent fields or save schema change. Evidence: validation_5427/RESULTS.md.

## 5.4.26 - Seal-query index (#305)

Climate queries enumerate live channel references in a transient map-scoped
registry, retaining the existing Active, radius, wall/floor, overlapping-effect
and wind-direction checks on every query. The index caches no temperature,
humidity, wind, visibility or actor-position result. It is rebuilt for normal,
legacy and hub loads; creation/destruction updates it immediately and map exit
clears it. Cache revision 1 is reconstructible and adds no persistent actor/save
schema. A missing registry handler falls back to the previous full scan.
ConfigureChannel registers immediately because PostBeginPlay can be deferred;
both paths are idempotent. Teardown unregisters without creating/rebuilding state.
The safe fast path applies in normal play, including the automatic >=500-living
combatant mode, without disabling physiology or changing targeting intervals.

## 5.4.25 - MAP06 corpse archive and diagnostic boundaries (#304)

Author decisions on 2026-10-15: MAP06 retains at most 100 recent visible/active
corpses. The oldest excess bodies and their attached inventories move to the
map-local non-ticking list (STAT_FIRST_THINKING - 1) and leave sector/blockmap links; their
identity, position, profile and inventory stay saved. Dropped loot remains.
Redemption restores the same body to the normal simulation before resurrection.
Its local thermal clock restarts without integrating the time spent dormant.
The current dead player's camera body is retained; older eligible bodies are
archived instead. New deaths use FIFO order. Older saves did not record death
order, so their one-time revision-1 import uses stable thinker order.

The 6,660 total / 1,000 living Mandinga budget, NPC thermal disable, 105-tic
perception interval and soldier model substitution are isolated diagnostics.
Those historical diagnostic settings did not change ordinary encounter rules.
The later #353 adoption below uses 100-tic port group targeting; thermal rules
remain unchanged. High-density targeting remains automatic at 500 living
combatants across the entire map. Thermal-off changes subsequent survival and
combat workload; results must report that divergence. The 3D control reuses the
accepted fixed Domingo prototype, not a completed modular soldier asset.

## 5.4.24 - Demon machete, personality and projectile presentation (#284)

Mandinga keeps all twelve base attributes at 6. Its existing physical machete
component remains; the same successful impact adds magical Fire based on the
same authored machete base damage, scaled once by effective Intelligence,
personality magical power and the normal health performance factor. It shares
the physical accuracy, critical result and evasion; it does not charge another
attack or roll another magical critical.

The author clarified on 2026-10-15: after each component's shield/armor/innate
and Fire-seal defenses, subtract Toughness once from the combined damage.
Weight the normal physical reduction and half-strength magical reduction by
the respective retained components. Zero total damage never counts as a Sleep
hit or applies burn. A surviving impact loses HP once, grants the existing hit
reactions once and counts once toward Sleep. Arenga retains its captured pre-hit
bars. Ordinary burn derives only from the Fire share; stored intensity excludes
Arenga/seal factors that are resolved by each later pulse.

Mandinga's profile is aggressive/calculating/rebellious/liberal (0/2/0/0);
Zupay's is patient/calculating/disciplined/conservative (2/2/2/2). Shared existing
factors apply; no attribute increase is introduced. Demon personality revision 2
migrates the existing profile once, without reconstructing the actor, refilling
resources, resetting states or duplicating supplies. Allied/Redemption/summoning
variants inherit the same profiles and keep their ownership/reward rules.

Zupay's thrown projectile keeps its existing class, state identities, collision,
speed, trajectory, elemental damage, status, explosion and lifetime. Cosmetic
revision 1 captures rock presentation once, including existing flying shots;
other casters keep their existing presentation. No larger collision follows the
visible rock model. CA284-01 passed author review on 2026-10-15.

## 5.4.23 - Opt-in Domingo model presentation (#283, accepted prototype)

The author ended #283 at its accepted prototype scope on 2026-10-15. CA283-02
is accepted. Modular conversion and unimplemented rest/provision transitions
are now future V5.17 roadmap work, preserving the rules below.

The default player remains CaelumPlayer. CaelumDomingoPilotPlayer is selected
only by an explicit test scenario. Its presentation hook reads native states
and their remaining tics; it does not advance attacks, spend resources, move
the pawn or modify collision. The human male sword/shield variant uses an owned
MD3 body with a first-person-hidden visual layer. Other equipment and crouch
fall back to existing appearance. The optional original-sprite comparison is
also presentation only. No armor or weapon statistics come from the mesh.

Native chair/bed/ground rest, occupancy, interruptions and timing remain the
authority. Seated/lying breathing uses the existing 70-tic breathing cadence.
The tested intermediate changes rest pose immediately. The author subsequently
approved 2-second chair entry/exit, 3-second lie/get-up and 4-second eating/drinking
cycles, with movement, attacks and blocking locked until each animation ends.
Provision consumption rates and quantities stay unchanged. Damage must interrupt
these animations immediately and restore ordinary combat rules. These transitions
and control locks remain to be implemented. The pilot reconstructs one local body,
which is released before map travel; base-player saves remain base-player saves.
No campaign appearance schema is changed. CA283-01 provisionally accepts the
preceding head/grip presentation, with fine visual polish deferred.

The author now requires interchangeable weapon, shield, armor, hair and face
parts, demonstrated first on Domingo using existing choices. The fixed runtime
mesh is only an intermediate prototype. Native equipment and saved appearance
remain the authority; modular presentation must neither grant items nor change
combat statistics. The same structure should be reusable by other characters.

Walk and Run remain separate model clips selected by the native player states.
Their revised arm curves change presentation only: speed, acceleration, movement
input, collision, resource costs and attack timing are unchanged. The isolated
manual fixture starts with always-run off and Shift mapped to native speed input.

The pilot now presents actual native shield blocking with matching idle, walk,
run and jump poses. Ten-tic jump preparation flexes the legs and lowers the
body before native takeoff; releasing Jump keeps that queued action. Actual
health loss, incapacity, leaving valid ground or map travel cancels preparation.
One-second landing reverses the flexion on ground contact. Movement, attacks and
blocking retain their ordinary rules during both transitions. Native CheckJump
remains the only takeoff velocity, Air-cost and thermal authority; swimming,
flight and uncrouching retain native Jump behavior. Revision 2 initializes new
transient fields idempotently for older pilot saves and preserves a pending
preparation's elapsed time in current saves. Shield geometry now follows a grip
in the hand; the relaxed shield extends along the character's forward/back plane.
The timing correction retains all existing model frame identities. CA283-02
records acceptance of the corrected prototype; it does not certify the deferred
modular conversion or rest/provision transitions as implemented.



## 5.4.22 - Gameplay quick-use selector (#282)

During live gameplay, a bottom-center carousel reads the player's native
`InvSel` and owned inventory. The selected existing icon is centered; its
localized name and quantity appear above it. Previous/next items have smaller
icons at either side. Zero items show an empty label; a single item has no
neighbors; two items show the other item on both sides because navigation wraps.

Native `invprev`, `invnext` and `invuse` remain authoritative. The first current
binding is shown compactly under each action; all bindings remain in Controls.
The persistent selector replaces the native temporary inventory-bar timeout, so
the first Use after cycling activates the displayed item. Menus and the automap
hide the carousel and retain their normal input ownership. The resource groups
reserve horizontal room for it only when viewport fitting requires shrinking;
weapon status remains above it. Native HUD scaling is preserved.

Eligible entries are positive owned consumable stacks outside the Magic Box.
Ammo, equipment, keys and documents are not new usable categories. Native item
use still applies existing effects and removes one stack unit. Each owned water
container is a distinct entry with its remaining/capacity liters; Use invokes
the existing Drink operation without removing the container. Empty containers
remain visible and unavailable. Availability also respects life/frozen state;
no stock is granted or copied. The full inventory keeps its established rules.

Pickup, depletion, drop, Box storage/retrieval and loading reconcile selection
and inventory-bar eligibility against actual ownership. `InvSel`/`InvFirst`
are existing native saved pointers; no save schema is added. Derived flags are
reconciled idempotently each tick, including older saves containing a boxed
selection or a previously hidden water container. Focused evidence and limits:
`assets/validation_5422/RESULTS.md`. Author check CA282-01 passed on 2026-10-15.

## 5.4.21 - Seal climate extensions (#252, accepted)

The author-approved extension augments existing User2 Channel effects. It does
not replace Fire's accepted direct thermal energy, Water lightning, Air tornado,
Earth poison/penalty, or Quintessence attraction/suspension/expulsion. Exact Seal
equipment identity, Adrenaline payment and cooldown remain authoritative.

Each completed real simulation second adds the current magical power multiplier
to a Seal-owned power ledger. Normal attributes and weapon damage do not grow.
Fire, Air and Water add this ledger to their environmental total each second:
at constant power P, total is P*n*(n+1)/2 after n seconds. Base units are +1 C,
+2 km/h and +3 relative-humidity percentage points respectively. Humidity caps
at 100%. Intelligence 25 gives P=1.7: Fire totals +1.7/+5.1/+10.2 C at 1/2/3 s.
Overlapping environmental changes add. The current radius and clear paths through
walls/floors bound their effect; they disappear when channeling ends. Wind keeps
the ambient direction, using a saved random direction in calm conditions.
Local weather and per-body thermal sampling share this overlay; regional weather,
water/ground temperature and existing heat already exchanged are not rewritten.

Earth uses the power ledger directly: each one-second damage pulse is accumulated
power times the receiver's physical mass in kg, with linear distance falloff from
100% at the center to zero at the radius. Continuous outward force uses 1000 N
times that ledger and the same falloff, converted through the shared SI scale.
For P=1.7 and 80 kg, pulse damage is 136/272/408 and force 1700/3400/5100 N after
1/2/3 s. Ground contact and an unobstructed path are required. Native visual quake
intensity is the ledger times base 1; native quake damage/thrust are disabled.

Quintessence suppresses gravity while channeling. Release snapshots bodies inside
the radius and applies normal gravity times the power ledger for one real second:
x1.7/x3.4/x5.1 after 1/2/3 s at Intelligence 25. Natural and magical flight remain.
Overlapping aftereffects retain the strongest multiplier and longest remaining
duration. Earth and gravity affect all eligible bodies except their caster,
including allies, neutrals and movable objects; fixed infrastructure is protected.

Earth damage ignores armor and retains Toughness. Quintessence uses at least
the initial magical power, including releases before one second. Native geometry,
stacking, lifecycle and old-save migration checks pass in validation_5421;
CA252-01 passed author review on 2026-10-15.
Calendar catch-up never creates extra pulses, resource charges or force.

Channeling enables native chasecam and displays the matching Seal flat on the
ground below the caster, exactly twice the pressure-trap size. A visual elemental
orb of Arcane Sun's size floats above the head. The author explicitly confirmed
that it adds no gameplay effects. Ending, interruption or departure removes both
visuals and restores the prior camera mode. These cosmetics do not become
collision bodies, targets or sources of weather.
Leaving a map stops its Channel without a cross-map release attack; local
gravity ownership is restored. The additive revision-1 ledger in older saves
starts empty without replaying old pulses or resetting the existing pulse phase.
The derived thermal overlay has its own revision and never resets body reserves.


## Arcane Cloud implementation decisions (#251, in progress)

Continue PR281 from the accepted #250 baseline e9c79de8. The original 5.4.5
asset checkpoint is preserved below; it is not a completed gameplay delivery.
On 2026-10-15 the author confirmed Air-seal lightning damage, area and division
among recipients, superseding the earlier staff-damage reference; random visible
enemies within 40 m base scaled by Eloquence,
allowing repeat targets and no shot without an eligible enemy; rain restores
1% of each beneficiary's current maximum Anima per second, scaled by Empathy,
with the first pulse one second after release. The caster is included.
Rain benefits only allies underneath the cloud, rather than a surrounding aura;
the separately approved caster recovery remains included. The cloud has no mass
or solid body. Expiry begins ordinary falling unless another flight source is
still active. The author sets the base cloud width to the covered cart's full
width: 82 map units (2.5625 m at 32 units/m), from the current cart mesh X bounds
[-41, 41]. Rain stops at solid surfaces rather than passing through them. The
rider stays seated throughout the effect and retains ordinary attacks, blocking
and other actions. Eloquence scales cloud width, rain footprint and lightning
range. Overlapping rain uses only the strongest source; recasting snapshots new
power, keeps the longer remaining/new duration and does not advance either pulse.
Lightning fires three evenly spaced strikes per second, starting after the first
third of a second, with normal staff lightning stun scaled by Charisma. The author
then explicitly chose the Air seal's visual, damage, area and damage distribution.
The normal staff-stun rule above remains separate from that revised damage rule.
The base x2 speed factor, increased as a whole by Empathy, applies horizontally
and vertically to the current movement mode and retains the ordinary #260 impulse.
Entering water, sleep, stun or immobilization ends the effect. Lightning damages
and stuns enemies only, protecting the caster, allies and neutrals. The cloud
travels between maps with its remaining duration; elapsed journeys consume that
duration. Explicit author clarification: an already-created cloud continues to
generate new lightning while its caster is intimidated by War Cry. Starting a
new offensive cast still follows the shared intimidation restriction.

5.4.20 enables Investigator activation through the shared User4 lifecycle. The
effect inventory has revision 1 and snapshots power, range, width, lightning
payload, duration and pulse phases. Old saves contain no such inventory and do
not gain a free effect. Native saves serialize these fields without an invasive
player schema/inheritance change. Water rejects a new cast and cancels an ongoing
preparation without refund or reuse. Owner death removes the effect immediately.

Native PowerFlight supplies controls/collision. The shared ownership helper
preserves another active flight's flags and view centering without resetting
duration, charging Anima or applying takeoff thrust. Only the final flight source
ends ordinary flight. World posture uses the existing seated state without
entering rest mechanics. Flight commands retain native land/cheat behavior.
Rain uses the scaled cloud's elliptical footprint and a vertical native trace;
interposed bodies and solid floors/ceilings stop it. Each recipient's current
maximum Anima is read at the pulse. Strongest-only ties use player identity.
Lightning's anchor requires visibility; its secondary area uses the existing Air
seal distance/distribution rule. Staff stun requires actual lost Health. The
35-Hz scheduler gives 12/12/11-tic spacing, without a launch-time strike.

Only gameplay inventory state travels. Recreate the cosmetic cloud at the
destination; do not manually unlink and transfer a sector-linked visual actor.
This repairs the native transition crash reproduced in the first implementation.
Short journeys consume remaining duration without retroactive pulse bursts;
long journeys expire the effect. Focused native evidence: validation_5420.
CA251-01 passed author review on 2026-10-15; PR281 is ready, unmerged.

## Arcane Cloud asset checkpoint (#251 / 5.4.5, historical scope)

The original checkpoint supplied a normalized owned cloud model/material for
Nube arcana and future weather. It had no production actor or gameplay fields.
The 5.4.20 implementation above supplies those consumers. Original generator,
provenance and asset evidence remain in assets/rain_cloud and validation_545.

## Pilgrim Redemption - 5.4.19 / #250

Redencion replaces Amparo. Reuse the approved shared User4 preparation, payment,
cancellation and reuse. The mobile area follows the caster and requires direct
sight, like Rally. Base reach remains 40 m with Eloquence; the shared beneficial
potency/duration rules apply. Resurrection runs immediately on release, then once
per second. Each body can revive only once per cast; recasting is a new cast.

All existing corpses are eligible regardless of species, faction or story role,
including neutrals, players and unique/boss actors. Restore 100% of current maximum
Health, Anima, Air and Lucidity; remove negative statuses. Preserve the original
body/character and finite inventory. If the full body cannot fit, search for nearby
visible fitting ground within the area; do not overlap or telefrag.

Former enemies become allies until the responsible effect ends, even after leaving
the area. They then die again. Original allies and neutrals remain alive. The
caster and living allies not revived by that cast receive x4 final fixed Toughness
reduction, scaled by Empathy as a full factor. This benefit requires current area
membership and sight; use only the strongest overlapping area. Recasting uses new
potency and the greater of remaining/new duration, without stacking factors.

Caster death ends the area and kills its temporary former enemies. Their bodies
accompany the caster between maps with Health, reserves and remaining lifetime;
long journeys consume elapsed duration. Do not duplicate original loot, death
rewards (including Adrenaline) or story/quest progression when revived bodies die.

Former enemies follow the caster while idle; their attacks protect the caster
and allies. Ignore an old player corpse once that player has respawned in another
body; the currently dead pawn can revive. If no valid nearby full-size placement
exists, leave that corpse for the next pulse. Corpses already removed by the engine
are not reconstructed from a new template. Preserve beneficial inverted periodic
doses while clearing harmful ones. Existing effects that end with their caster
still end if that caster is revived in the same tic.

Revision-1 inventories retain per-cast bodies, original allegiance, conversion
ownership, remaining duration and the no-repeat-death-reward latch. Previous saves
start without these inventories; no character reconstruction or payment migration
is needed. Active effects and preparation reload in 5.4.19, including pending
arrival. Neutral copied saves roundtrip with 5.4.18; active Redemption saves are
not claimed to load in unsupported older runtimes. Keep the original snapshot for
rollback. Focused native/static/build evidence: validation_5419. CA250-01 passed
author review on 2026-10-15; broad campaign/network coverage is not implied.

## Battle Mage Summoning - 5.4.18 / #249

Invocacion replaces Deafening Cry. User4 retains the shared three-second paid
preparation, full initial Anima requirement, cancellation without refund and
60-second reuse from successful release. It is an offensive class ability for
Battle Cry's existing restriction. Aim at visible ground when preparation ends;
base reach is 40 m, scaled by Eloquence. If the aimed position is occupied, search
for nearby visible ground within range where the existing Zupay cylinder fits.
Never telefrag or place through walls. If no valid position exists, retain spent
Anima and do not start reuse; an existing summon remains unchanged.

Each caster owns one temporary allied Zupay. Preserve the current creature's
size, mass, artwork, attacks and finite supplies; suppress unique MAP02/port
boss identity, retreat and quest events. Empathy snapshots at release, multiplying
all twelve base attributes (33 at power 1, 66 at power 2) before the existing
derived-stat formulas. Attributes retain integer representation, rounded to the
nearest integer. Its own resulting Strength/Intelligence drive existing attacks;
there is no extra caster-damage multiplier. Empathy also multiplies the base
10-second duration. Successful recasting replaces the old creature with a fresh
one and a new duration, never stacking or renewing its damaged body.

The summon follows its caster when not fighting and independently engages
enemies with its existing combat. Its attacks, ground-launch impulse, projectiles,
breath burning and contact heat protect the caster, allies and neutrals.
Projectile ownership/policy persists after the creature disappears. Normal solid
body collision is retained. Death of the summon or caster, or expiry, removes
the summon without corpse, loot, kill count or nearby ally-death reward.

The revision-1 owned effect carries the body and its finite inventory between
maps rather than recreating them. Preserve Health, reserves and remaining time;
clear previous-map targets and ongoing breath. If no visible space is available
near the arrival point, keep the body pending and noninteractive while duration
continues, retrying placement on the shared one-second cadence. Trips that advance
hours or days subtract their elapsed simulation time from the effect.

Implemented on feat/issue249-summoning. Static validation, normal packaging and
132 qualified assertions in 19 native runs pass, including copied-save upgrade,
optional inert-class rollback and return (validation_5418). CA249-01 passed author
review on 2026-10-15. Earlier accepted issues are not reopened.

## Rally - 5.4.17 / #248

Cleric User4 uses the shared three-second progressive Anima preparation and
60-second reuse from release. The living caster carries a revision-1 area with
40 m base radius, 10 s base duration and 10% maximum Adrenaline recovery per
second. Snapshot Eloquence-scaled range and Empathy-scaled power/duration at
release. Require the same native allegiance and direct sight as Miracle:
caster, cooperative/teammate players and friendly combatants, excluding neutral
or hostile bodies, corpses and ordinary objects. Current three-dimensional
distance, sight and allegiance govern both recovery and damage, immediately.

The first pulse is one second after release; the last complete effect second
also pulses. Restore the recipient's current maximum times the approved rate,
cap at that maximum, and preserve ordinary decay. The player's existing
Survival Instinct multiplies this gain once. Only the strongest eligible Rally
provides either recovery or damage modifiers. Ties use native player number;
each source retains its own clock and suppressed pulses do not queue.
Renewal snapshots new potency/range, keeps max(remaining, new duration), and
does not reset or advance the next pulse.

For each beneficiary, factor = (1 + current Adrenaline / current maximum) times
the area's captured Empathy power. Scale the full factor. At base power, empty,
half and full bars give 1, 1.5 and 2. Both outgoing multiplication and incoming
division apply after the target's defenses, including armor, elemental factors
and Toughness. Include physical/magic attacks, ongoing burns/poisons, falling,
collisions and environmental hazards. Own damage applies only incoming division,
so falling or a self-inflicted explosion does not cancel protection.

Capture both live factors at each damage entry, before that hit grants Adrenaline
for blocking, pain or damage. Already-flying projectiles and existing periodic
effects use the current area/bar at impact/pulse, not launch-time snapshots.
The elemental dose derived from an initial hit excludes Rally's factor; each
subsequent pulse applies it once. Existing native integer HP quantization,
Sleep multiplication, immunities and tutorial Health protection remain.
Snapshot context is transient, nested-call-safe and neutral outside a hit.
Destructible gates and training/physical props receive outgoing scaling through
their own final damage paths, without making them allied beneficiaries.

The area serializes revision, power, range, remaining tics and pulse phase.
Old saves have no Rally inventory and no persistent recipient modifiers.
Death immediately disables the area; expiry removes it. Forecast travel rejects
an affected traveler rather than extending or discarding the temporary benefit.
Static validation, normal packaging and 74 qualified native assertions pass.
Current save/load, preparation reload and hub travel preserve clocks/payment.
The optional copied-save bridge to 5.4.16 removes unsupported Rally areas and
preparation without refund; preserved original saves provide reversal. Upgrade,
bridged rollback and re-upgrade pass. CA248-01 passed author review on 2026-10-15.
Exact commands/hashes and limits are in assets/validation_5417.

## Mercenary Formation Breaker - 5.4.16 / #247

Rompeformaciones / Formation Breaker replaces Killer Instinct. User4 uses the
shared 3-second paid preparation, base 1000 Anima and 60-second cooldown from
release. The base effect window is 10 seconds. While active, a native forward
double tap within the #260 0.4-second interval starts a ground-only traversal:

- Stand upright, using maximum **running** speed even from walking/crouching.
  If the full body cannot fit, consume the gesture without starting, paying or
  changing posture. Swimming/flying retain the ordinary paid #260 impulse.
- Base speed factor **x4** and traversal duration **1 second**. Empathy scales
  the entire speed/defense factors and both the traversal and window durations.
  Capture these factors at release/start; later attribute changes do not rewrite
  a running traversal. The original full movement direction, including an existing
  diagonal, stays fixed in world space while the camera remains freely movable.
- Waive the impulse activation Air fee only. Running Air continues through the
  canonical payment system, including Supernatural Breathing substitution.
- Ignore additional double taps during the traversal. A started traversal finishes
  independently of window expiry. Recasting renews window power and keeps the
  greater remaining/new duration without stacking; an ongoing traversal keeps its
  captured factors. Stop when obstructed by a wall/body, leaving the ground,
  jumping, entering water, immobilized, dead or modal control takes over. Preserve
  native collision/fall motion; cap excess horizontal speed at normal running
  speed when ending and never reaccelerate a stopped body.
- During the traversal only, biological collision cushioning and **final flat
  Toughness reduction** multiply by base x10, then beneficial power. Do not multiply
  the raw Toughness attribute or modify ordinary attack damage. Moving characters
  and objects are eligible for this biological cushioning. Keep the bonus until
  the terminating collision has resolved both receivers independently. Sustained
  pressure/crushing retains its separately approved rule; armor wear, anatomy and
  the other body's defenses remain unchanged.
- Every 0.1 seconds of actual movement, freeze the current owned body/head appearance
  at 50% opacity and fade it over 0.3 seconds. Simulation quantization alternates
  3/4-tic emission intervals and expires a snapshot by tic 11. It has no collision,
  inventory or combat role.

Revision-1 inventory state owns the window, captured traversal and direction per
player. New fields are absent/inactive on older saves; partial gestures stay
transient under #260. Current reload continues the exact traversal and partial
preparation payment. Hub arrival ends an old-map traversal while preserving the
remaining owned class window. For rollback to 5.4.15, the optional copied-save
bridge declares the new classes and cancels unsupported effects without refund;
plain old runtime does not know those classes. Original saves remain untouched.
Native and copied-save evidence is in validation_5416; CA247-01 passed author
review on 2026-10-15 without reported qualifications.

## Player constant acceleration and directional impulse - 5.4.15 / #260

Playable characters reach their current steady movement speed with a linear ramp:
`timeToFullSpeed = 3 seconds * DerivedStats.TotalMass / 100 kg`. TotalMass is the
existing authoritative body-plus-carried-load aggregate, including equipment and
the Box contribution once. At fixed mass and target speed, 50/100/200 kg require
1.5/3/6 simulation seconds. Native input has one initial command-tic startup;
fractional durations clamp at the next simulation tic. Calendar time is irrelevant.

Existing effective speed, directional/run/crouch input, health, survival, load,
Air, elemental, shield, reload and thermal modifiers remain authoritative. The
ramp compensates the native command's own thrust for friction, rather than
clamping total velocity. This produces linear real movement while preserving
external impulses, collisions and native stopping. No input or immobilization
resets progress; ordinary airborne jumps retain the existing frozen progression;
swimming and native flight continue progressing. A changed total mass changes
the next increment; it does not rewrite momentum or elapsed time. Direction and
target-speed changes retain the native response, with no new steering rule.
NPCs, including the bull's 10 m/s and 10 m/s² charge, do not use this player ramp.

Revision 1 preserves an old saved progress fraction, clamps corrupt out-of-range
fractions and adds a serialized next-tic increment. No actor class/state changes
are needed. Native copied-save upgrade, reload and rollback evidence is recorded
in assets/validation_5415; keep original saves as reversible inputs.

The author confirmed the double-tap contract on 2026-10-15: two native
direction presses at most 0.4 simulation seconds apart, with a release between
them. Holding a direction is not another tap. The impulse also works while
moving, reaches the current walk/run/crouch mode's maximum and follows the full
current movement direction (including a held diagonal). It does not stack a
second maximum on existing velocity. Ground, swimming and flight are eligible;
ordinary jumps/falls are not. If the complete cost cannot be paid, spend nothing,
do not activate and continue ordinary movement. Cost remains the actual running
Air rate times the full mass-based acceleration duration, using the common Air
payment authority (including Supernatural Breathing). No cooldown is added.
Native opposite directions cancel through the engine's own command input.
Held directional buttons remain held when their opposite is released; cancellation
of movement is not a new press. Analog-only axes use native command sign edges.
Menu/dialogue/rest/death/immobilization/load must not retain a partial gesture.
The #247 enhanced forward impulse remains a separate issue.

The native command supplies direction, current stance and all speed modifiers.
After payment, the impulse completes velocity toward that command's steady cap,
accounting for existing perpendicular motion instead of stacking another cap.
Already faster external momentum is retained. Native collision and vertical
movement remain active; there is no teleport or ordinary airborne impulse.
The incomplete gesture is transient: load starts disarmed, and UI transitions
clear it through the existing synchronized event handler. Prediction cannot
consume a gesture or pay. No persistent actor or state-list migration is added;
the existing revision-1 ordinary ramp migration remains authoritative.
CA260-01 (ordinary acceleration) and CA260-02 (impulse) passed author review
on 2026-10-15; their recorded scopes remain separate.

## MAP01 resident movement repair - 5.4.14 / #253

The player's protected 1-HP floor does not end the assisted bull encounter or
disable eligible residents. The reproduced stall had a different cause: all four
residents captured zero CombatBaseSpeed during initialization, despite authored
positive class defaults. Their current Health, thermal and elemental multipliers
were all one in the stalled trace. They could attack when the bull approached,
but could not pursue or retrieve their finite bolas.

For anchored MAP01 residents only, restore a missing initial Speed from its class
default before the shared base captures it. Keep positive custom values. Revision-1
Tick migration repairs absent bases in old saved instances and reapplies existing
Health/thermal/elemental modifiers. It preserves actor and equipment identity,
resources, wear, targets, downing, recovery and quest progress. It neither replaces
residents nor grants healing, supplies, damage immunity or victory. Existing own
downing, finite tools, encounter grace and post-victory restoration still apply.
The repair adds no states and no new actor class; copied-save upgrade/reload and
rollback use native serialization, with preserved originals for reversal.
Evidence: assets/validation_5414. CA253-01 passed author review on 2026-10-15.

## Arcane Sun - 5.4.13 / #246

Mage User4 replaces Brainstorm with Sol arcano (Arcane Sun). The accepted shared
105-tic preparation, progressive fixed-cost debit, cancellation without refund and
60-second reuse apply. It is offensive and therefore subject to Battle Cry.
At release, snapshot tier-one uncharged fire-staff damage with the caster's current
Intelligence and offensive modifiers, independently of the equipped weapon. No
weapon wear is charged. Direct impact and explosion use ten times that reference;
each child uses normal reference damage and elemental payload. Intelligence is
not applied twice. Ordinary critical, anatomy, armor, Toughness and Seal consumers
remain authoritative. All components affect native enemies only: never the
caster, allies or neutrals. Existing native allegiance remains authoritative.

The central orb has ten times the normal projectile's visual scale and radial
collision geometry (40 MU radius/height), and travels straight at the normal staff
speed, 20 MU/tic. It crosses characters, delivering one direct impact per enemy per
launch; re-entry cannot repeat it. Scenery (wall, floor or ceiling) or the end of
the 10-second base lifetime triggers exactly one explosion and 25 straight children.
Charisma scales lifetime. The burst uses a near-uniform Fibonacci sphere, including
up/down poles, rather than an unattainable equal pairwise distance for 25 points.
Explosion base radius is ten times the uncharged statuette's 128 MU, then scaled
by Eloquence. Native distance falloff and wall occlusion are retained.

The moving burning area uses the 40-m class base radius scaled by Eloquence, with
direct sight from the orb and live membership. Native burning delivers ten times
reference staff damage per second, further scaled by Charisma. Exposure refreshes
the native burn; after leaving, its 3-second base duration remains, scaled by
Charisma and native resistance. Strength is ten times harmful potency so a weaker
ordinary fire hit cannot replace the Sun's stronger burning. Reapplication keeps
the native fractional damage and pulse phase. No separate artificial periodic
damage or bypass of defenses is introduced.

Starting one second after release, each complete second emits one normal-sized
homing fire shot at the nearest visible enemy in the scaled area. No target means
no shot for that second. Children use normal staff speed and normal travel range
(3200 MU base, scaled by Eloquence); burst children remain straight. A homing child
whose target becomes invalid or invisible reacquires the nearest visible enemy
within its remaining travel budget and the scaled acquisition radius. Released
shots and existing burning continue when the main orb ends or the caster dies;
damage requires the original source actor to remain available.

Revision-1 projectile state serializes offensive snapshots, hit recipients, lifetime,
next shot and finished flag. Old saves have no new projectile state to initialize.
Save/load must not duplicate payment, direct hits, periodic emission or final burst.
Hub projectiles remain in their original map under native inactive-map freezing.
The optional 5.4.12 bridge operates on copied saves, removes unsupported projectiles
and cancels Mage preparation without refund; the preserved original is reversible.
Focused evidence: assets/validation_5413. CA246-01 passed author review on
2026-10-15. No broader campaign or multiplayer acceptance is claimed.

## Miracle - 5.4.12 / #245

Priest User4 uses the shared three-second paid preparation, cancellation without
refund and 60-second reuse from release. At release, snapshot Eloquence-scaled
class radius (40 m base), Empathy-scaled recovery (3% base) and duration (10 s base).
The moving area follows its living caster. It is a benefit, not an attack.
The first pulse occurs after 35 simulation tics; subsequent pulses occur once per
second, including the last complete second of the effect. Each pulse checks
current three-dimensional distance, direct sight and native allegiance. The
caster benefits; other living players in cooperative play or on the same team,
and native friendly monsters recognized as friends, benefit. Neutral and hostile
bodies, corpses and ordinary objects do not. No narrative faction matrix is added.
Entering/leaving, walls and changed allegiance affect the next pulse.

Restore the approved percentage of each recipient's current maximum Health,
Lucidity, Anima and Air. Recovery adds to ordinary recovery and consumables and
caps at legal maxima. Fractional Health carries separately from natural recovery
so small maxima do not gain a fabricated minimum of one HP per pulse; reaching
maximum clears the remainder. No extra food/water payment, Adrenaline, cleansing,
resurrection or survival resource restoration is introduced. Recovery updates
the corresponding Health/Lucidity/Air state services and native player health.

Overlapping areas restore only the most potent eligible Miracle. Equal potency
uses native player-number order. Each source retains its own one-second clock;
suppressed pulses do not queue. Renewal uses the new release's potency/range and
max(remaining, new duration), retaining the next pulse's phase and one area.
Changing a maximum during the effect changes the next recovery amount.

The caster-owned revision-1 inventory serializes potency, radius, remaining time
and pulse phase. Player/NPC recovery revision 1 initializes the separate Health
remainder to zero for old saves, idempotently. Save/load and supported hub travel
must not duplicate payment or pulses. Death disables the area immediately; expiry
removes it. Forecast travel rejects an active area. The optional copied-save
bridge targets 5.4.11, removing unsupported areas/preparations without refund;
preserved original saves provide reversal. It does not alter campaign saves.
CA245-01 passed author review on 2026-10-15; focused evidence is in assets/validation_5412.

## Survival Instinct - 5.4.11 / #244

Explorer User4 uses the shared three-second preparation, fixed progressive debit,
full modified 1000-Anima admission, cancellation without refund and 60-second reuse
from release. It affects the caster only. At release, Empathy's existing beneficial
power snapshots the full factor (3 times that power) and ten-second base duration.
A factor of 2 therefore yields x6 for 20 seconds, not x5. The effect is not an
attack and Battle Cry alone does not prevent its preparation.
Renewal uses the new release's potency and max(remaining, new duration), without
adding factors or durations, as confirmed by the author on 2026-10-15.

Multiply current evasion, physical/magical critical chance and precision, retaining
personality, Tarot, racial, posture, equipment, load and survival-state modifiers.
Precision remains the existing quantity that divides angular dispersion: x3
precision divides the same spread by three. Weapon tiers, sampling, guidance and
attack timing remain unchanged. Critical damage is unchanged. Existing unarmed
and utility-stream consumers acquire no invented critical roll or weapon identity.
The real evasion/critical probability consumers cap at 100%; resource additions
still cap at MaximumAdrenaline. Personage journal values use the shared consumers.

Every gameplay-earned Adrenaline gain, including future ability gains such as
Rally, receives the factor exactly once. Combat still composes its health and
personality factors. Explicit tutorial/development reserve additions bypass the
class factor; they remain exact. AddAdrenaline's applyAbility flag distinguishes
these calls, and AddCombatAdrenaline records the already-scaled final gain before
using the exact addition path. Future abilities use the normal gain path.

The caster-owned inventory effect is revision 1 and stores remaining tics and its
release-time factor. Contributions are queried, never baked into saved attributes
or divided back out. Expiry removes only this contribution; death disables it.
The ability grants neither negative-state immunity nor protection from survival
drain. Existing projectiles retain their firing-time critical chance; no reroll or
retroactive boost is introduced. Saves and supported hub travel retain one effect
without reapplying payment. Forecast travel rejects this unsupported timed effect.
The optional copied-save bridge targets 5.4.10 only, cancelling unsupported effects
and preparations without refund; preserve original saves for reversal.
CA244-01 passed author review on 2026-10-15; exact evidence is in assets/validation_5411.

## Battle Cry - 5.4.10 / #243

Warrior User4 follows the shared #238 contract: exactly three seconds of native
hand preparation, full modified 1000-Anima admission, a fixed cost paid uniformly,
second-press cancellation without refund, and 60-second reuse from release.
At release it snapshots living enemies within 40 metres (1280 MU) times the
Eloquence range factor, with unobstructed sight. Geometric sight ignores visibility
modifiers, matching the existing Sleep query. Allies, neutral actors and the caster
are excluded. Enemies use existing monster/friendly and player team rules; bosses
have no special immunity. No invented resistance roll or damage is involved.

The attack prohibition lasts 10 seconds times the Charisma harmful-effect factor.
Renewal retains max(remaining, new duration), never their sum. Membership does not
change after release: leaving the radius or losing the caster does not end it.
Recipients retain movement and defense. Preparing physical/magical attacks,
offensive class casts, bolas, resident tool attacks, Bull charges, demon breath
and utility-staff streams stop. Harmful Seal channels stop without a final
Quintessence release burst; all Telekinesis stops, including nonliving targets.
Weapon execution paths also reject attacks until expiry. Nonattack reloads,
implemented Tarot benefits/flight and self-benefit racials remain available.
Already launched projectiles and already applied burn/poison/periodic effects
continue normally; this is an attack gate, not a global damage filter.

Intimidated siege operators may move/load. Cannon firing still requires one
eligible nearby operator; the ram still requires its complete eligible crew.
An interrupted ram strike enters recovery even if another crew member is absent.
The prohibition lives in recipient inventory (revision 1), survives save/load and
supported hub travel, and expires on its own clock without caster ownership.
Old saves have no new effect to invent. The optional 5.4.9 rollback bridge operates
on copies, removes unsupported effects/casts and retains spent Anima; preserve
original saves for reversal. Scope and exact evidence: assets/validation_5410.
CA243-01 passed explicit author review on 2026-10-15; HISTORY records the result.

## Hunter's Instinct - 5.4.9 / #239

Beast Man User1 toggles Hunter's Instinct. The shared racial lifecycle charges
10 Anima/second before current Anima-cost modifiers, with no upfront fee, duration
cap or cooldown. It supports sub-second reserves, preserves an unaffordable
remainder and stops on sleep, stun, immobilization, death or identity changes.

Multiply current stealth, including the existing crouch contribution, by three
before the 0..100% cap. Effective stealth feeds the production movement-noise
complement, range and native SoundAlert call. At 100% no movement-noise event is
emitted. Existing running/crouching and mass contributions still apply. The
diagnostic visual observer also reads this value, but is not a completed
production visual-perception system; that remains outside #239.

For physical and magical critical chance, the rear half is the target's rear
180 degrees, measured horizontally from its current facing to the attacker's
current position. Exact side boundaries and coincident positions receive no rear
bonus. Multiply the current eligible chance by three and cap at 100%. Do not
multiply critical damage. Single melee hits and large-weapon sweeps check each
victim at impact. Existing fists have no critical roll: zero remains zero.

The author confirmed on 2026-10-15 that a projectile captures whether the racial
was active **when fired**. Switching it off during flight retains eligibility;
switching it on afterward grants none. Rear geometry still uses both actors'
positions at impact. Preserve the launch's ordinary chance and original random
roll, and compare that same roll against the conditional chance for each receiver.
No reroll occurs. Carbine, shotgun, bow, crossbow, javelin and all four magical
weapons use this metadata, including charged forms, homing and area defense.
Existing per-volley/per-projectile roll ownership is unchanged.

New projectile metadata has revision 1. Older in-flight projectiles have revision
0 and retain their original resolved result without invented chance, eligibility
or randomness. Current saves preserve the effect and each projectile's launch
metadata; native hub travel retains the valid effect. The optional isolated 5.4.8
bridge ends the unsupported effect without refunding Anima. A rollback flight
retains the legacy outcome when returned; keep original saves for full recovery.
Evidence and exact compatibility scope: assets/validation_549. CA239-01 passed
author review on 2026-10-15.

## Socialization - 5.4.8 / #240

Human User1 toggles Socialization. It multiplies current Dialogue skill and
Persuasion capacity by two, then applies the existing thresholds, probability
rounding and caps. Underlying Eloquence/Charisma and saved results are unchanged.
Rulo's Emotion and faction reputation receive no bonus. Palomo's existing
Dialogue-based discount request uses the boosted skill; no separate shop-price
or discount modifier is added. Ronnie's Eloquence-4 Dialogue 0.928 becomes 1.856;
Caella's Charisma-0 difficulty-120 chance becomes 100% instead of 83%.

The shared racial controller charges 10 Anima/second before normal cost reduction,
uniformly per simulation tic, including native unpaused conversation. No upfront
fee, duration cap or cooldown applies. A sub-second reserve may start the effect;
an unaffordable next tic switches it off without spending the remaining fraction.
Sleep, stun, immobilization, death or identity changes end the effect. Native hub
travel retains an otherwise valid effect and does not reset Anima.

During conversation, the rebound User1 key can stop this effect without selecting
a reply or activating another power. Each displayed native node/option page
captures its multiplier in authoritative play state before drawing or accepting
a reply. Already visited pages retain that multiplier until the conversation
ends, including after manual stop or exhaustion. New pages use the current live
effect. No client-supplied skill value is trusted. The existing history/replay
flow, saved roll, probability, automatic-success rules and no-reroll guard remain.

Conversation snapshots have schema revision 1, speaker identity and page keys.
Old saves start with a null session; current saves restore the page multiplier
and active/stopped effect without replaying actions. Closing the conversation
clears its session. The optional isolated 5.4.7 rollback bridge ends an unsupported
effect while retaining spent Anima; preserve original saves. Exact evidence and
limitations: assets/validation_548. CA240-01 passed author review on 2026-10-14.

## Telekinesis - 5.4.7 / #241

Duende User1 captures one aimed, visible living body or movable scenery object
within the Seal's base radius (1,280 MU / 40 m), multiplied by the current
Eloquence-derived AbilityRangePercent. Eligible scenery uses the existing
CaelumMovableProp contract: configured movable props and movable environment
rocks. Rooted trees, static infrastructure, owned inventory and visual effects
are not movable scenery. Living Caelum combatants/players retain their native
identity; inactive/dormant bodies are not captured. Capturing transfers no ownership.

The captured contact follows the aim at its original distance. One target may
have one active holder. Held living bodies cannot voluntarily move or attack;
ongoing breath, charging and player action preparation are interrupted. Native
external velocity, gravity, water and collision remain active. The effect never
teleports the target or overrides collision/gravity flags. User1 again releases
it; loss of sight, excess current range, target death/removal, caster interruption
or inability to pay the next instant also releases it without a throw impulse.
Map travel releases the target before departure.

Base consumption is 1 Anima per actual kilogram per second, followed by the
usual current Anima-cost reduction. Body and carried mass count; virtual shield
collision inertia does not increase real mass. No flat fee, mass cap, duration
cap or cooldown applies. Preserve an unaffordable fractional remainder.

Force is 1,000 N times MagicalPowerMultiplier, including its existing Intelligence
and personality factors. At Intelligence 25 before personality: 1,700 N; a bare
66 kg Mandinga has acceleration 25.76 m/s² before gravity/friction. Its actual
carried load reduces that value. This is a newly approved force baseline, not a
reinterpretation of the 1,000 Anima class cost or old native attack thrust.
The controller converts F/m to MU/tic² and limits the full velocity change to
that budget. Braking uses v²=2ad toward the moving contact, with no additional
authored speed cap. Gravity remains native: insufficient force cannot lift a
heavy body. Ground friction and collisions can further reduce motion.

The effect has hold schema revision 1 and nullable target bindings. Old saves
start without this effect; current saves preserve the same body/contact/payment.
State countdown suspension is local to each NPC tick, so release cannot leave
a saved permanent freeze. The optional tested 5.4.6 bridge deactivates the new
effect without refunding resources; preserve original saves before using it.
Evidence: assets/validation_547. CA241-01 passed author review on 2026-10-14.

## Supernatural Breathing - 5.4.6 / #242

The Caelith User1 power is **Supernatural Breathing / Respiración sobrenatural**.
The shared racial controller supplies toggling, interruption, saved identity and
active/inactive HUD state. There is no fixed Anima drain or cooldown. Existing
forced sleep, stun, immobilization and death rules turn it off.

Every ordinary player Air expenditure is substituted: running, jumping, physical
melee/ranged attacks, fists, javelin/bolas throws, blocking and oxygen deprivation.
First calculate the ordinary Air demand with its existing load, charge, heat and
other modifiers; multiply by 1 Anima per Air point, then apply the current Anima
cost reduction once. A zero Air reserve does not make an effort free or prevent
an otherwise affordable substituted effort. Existing Air-dependent performance,
thermal effects and ordinary resource recovery remain tied to actual reserves.

If the complete effort is unaffordable, turn the power off without consuming the
remaining Anima and run the ordinary Air rule for that entire effort. Attacks
still refuse an unaffordable Air cost; continuous exhaustion/deprivation follows
its existing empty-reserve behavior. Exact payment to zero ends the power after
paying that effort. Admission and personal-time simulation use #238's controller.

Underwater deprivation keeps its existing increasing demand. Paid Anima prevents
that tic's drowning without adding Air recovery debt; on failure only actual Air
loss becomes debt. Once ordinary Air is exhausted, ordinary drowning resumes.
Surfacing therefore cannot turn Anima expenditure into free Air. Native hub
transitions preserve the effect; numerical journey forecasts retain #238's
unsupported-active-effect restriction. Revision-1 racial state remains authoritative;
older saves default inactive and no new resource reserve is introduced.

Native evidence and remaining author checks: assets/validation_546.

## Class preparation and revised Sleep (#238)

Production User4 now starts the shared three-second preparation for the implemented
Arcanist Sleep effect: lower equipped hands/weapon, raise empty closed fists facing
forward, turn the hands and open the palms, then release. Other class effects
remain in their own issues. The caster must have the entire modified cost at
admission. Snapshot that cost once and debit it uniformly over 105 simulation tics.
Base cost is 1,000 Anima; cancellation never refunds paid Anima. Reuse starts at
successful release and lasts 60 seconds. Effects have a 10-second base duration.

A second User4 press cancels. Insufficient Anima for the next payment, death,
sleep, stun or physical immobilization also cancels. Movement and ordinary damage
without those states do not cancel. During preparation, reject attacks, blocking,
weapon switches (including inventory operations), and new Seal/Tarot/racial
activations. The native input latch prevents holding User4 from retriggering.
The revision-1 paid-cast state keeps cost, paid amount, profession and remaining
visual clock; old saves default inactive without converting the old visual clock
into a paid ability. Save/load and native MAP02/MAP03 hub return retain that state.

The left class/racial column shares the existing Tarot/Seal projection and HUD
scaling. At the author's request, both glyphs use centered 64-by-64 logical units
instead of 88-by-88, matching the Tarot frame width and approximating the visible
Seal width. Labels and class countdown sit below the reduced glyphs.
Class readiness uses implemented effect eligibility, with dim unavailable icons,
a preparation label and reuse seconds. Racial state has no timer; the shared
controller owns its active boolean and saved effect. The compass
and notifications reserve the column width. Generic icons reuse owned artwork.

The author confirmed the existing curves: B=(N*N+25*N)/125; M2=1+3B/100.
Eloquence multiplies radius by M2 and divides Anima cost by M2. Charisma multiplies
harmful-effect power and duration; Empathy multiplies beneficial/healing power
and duration. Direct damage retains the existing Intelligence calculation.
Preparation stays exactly three seconds. Scale the complete authored factor:
base x3 with statistical power x2 becomes x6. Cost is frozen at admission; effect
parameters use the release-time derived statistics, as in the previous effect.

Sleep preserves its 1,280-MU base radius before Eloquence scaling, sight check,
caster exclusion and Lucidity behavior. Enemy identity follows existing native
combat classification: hostile monsters are monsters without Friendly; cooperative
players, friendly residents and neutral bodies do not receive the enemy penalty.
The existing deathmatch/team identity handles opposing players; full multiplayer
validation remains outside this issue. Enemies require exactly three separate
HP-losing impacts, including individual pellets/projectiles and DOT applications.
Their final damage after project defenses is multiplied by 3 times harmful power,
including the third waking impact. Fully absorbed/evaded/blocked damage does not
count. Allies and neutrals wake after one HP-losing impact without that multiplier.

Duration expiry also wakes sleepers. Reapplication resets the enemy count to three,
uses the new power, and keeps the greater of remaining and new duration. The saved
Sleep object has schema revision 1, hit count, multiplier and original pose state.
Existing RestLying poses are held without replaying state actions; wake restores
the prior state without replaying an attack action. Rat and Bull now use natural
lying poses; Mandinga and Zupay use supine poses, each with eight views. The states
are appended after existing states, preserving earlier indices. Collision, height,
health and existing death artwork are unchanged. The waking hit may trigger the
ordinary pain reaction after Sleep releases. Existing saves whose active Sleep
object already stored a null lying-state pointer keep that old presentation until
expiry/reapplication; no effect counters or timers are reset by this visual patch.
Old saves with only ForcedSleepTics retain their former one-hit wake behavior until
expiry/reapplication. Voluntary rest is unchanged. Compatibility evidence and
limits are in assets/validation_544; author acceptance is separate.

Continuous racial toggles have no cooldown/duration cap. Hunter's Instinct and
Socialization cost 10 Anima/second before cost modifiers. Continuous racial powers switch off on sleep, stun, immobilization or death. They may start with less than one second of Anima, without an upfront fee: charge uniformly per simulation tic, stop before an unaffordable tic, and leave the small unpaid remainder untouched. No duration cap or cooldown.
Hunter's Instinct uses the target's rear 180-degree half at impact, based on both actors' current positions, for physical and magical critical chance. Multiply current stealth (including crouch) and rear critical chance by three, then apply existing caps.
Socialization multiplies current Dialogue/Persuasion values by two, then applies existing caps. Choices already visible retain their boosted values when the power switches off; resolved checks never reroll.
These are approved contracts; their production effects, the remaining racial
drain policies and nine new class effects stay in #239-251.

The #238 shared racial controller is now integrated with native User1. Its
revision-1 saved effect object carries the selected race; old HUD-only flags
migrate once to inactive. A held press toggles once, and an interface-absorbed
press cannot activate after closing the interface. Admission requires one
affordable simulation tic, with no initial fee; the first paid tic starts the
effect. Current Anima cost reduction applies once to each tic, including personal
time simulation. Forced sleep/stun/immobilization/death, race mismatch or an
invalid effect end it exactly once. Voluntary Seal channeling does not count as
forced immobilization. Activation remains blocked during class preparation and
existing interaction menus/rest/channel controls. Unsupported races report the
unavailable effect rather than displaying a fictitious active power.

Concrete racial effects remain in #239-242. Instrumentation verifies saved
effect identity and debit across native save/load and map hub return. Numerical
journey forecasts reuse the existing unsupported-effect restriction: a pending
class preparation or racial effect must finish/be stopped before that forecast
can run. Preview rejection neither consumes resources nor silently stops a power.
This is distinct from native hub transitions, which retain the saved controller.

Same-version compatibility completion (2026-10-15):
`assets/validation_544/prepare_paid_rollback.py` builds a pinned 5.4.3 runtime
with inert serialization declarations for #238 and appended visual states/assets.
It retains partial payment, preparation clocks, racial identity and Sleep data
without running the new controllers. Existing cooldown/Sleep timers follow old
gameplay. Use copies with the matching runtime and fixture basenames; retain the
original save/runtime pair. Return to 5.4.4 to resume preparation from its paid
ledger. Native repeated re-upgrade verifies one total debit and one release
cooldown. This bridge is specific to 5.4.3/5.4.4 shared schema, not a general
downgrade tool or support for later concrete racial/class effects. Raw 5.4.3
lacks the new classes. Never substitute it for the bridge with a new-state save.
Evidence and preserved fixture failures: validation_544/rollback_evidence.json.

## MAP02 rat movement and sound - 5.4.3 / #254

Rats retain their authored Speed 10, mass, attributes, attack, anatomy, targeting
and the existing MAP02 population (192 rats and 96 Mandingas). An early health
recalculation can zero Speed before PostBeginPlay captures CombatBaseSpeed.
The rat restores only a missing initial speed from its class default before that
capture. RatMovementRevision 1 repairs a missing base speed once in old saved
bodies, then recomputes existing health effects. Positive custom bases, Health,
Air, sleep, targets, corpses and one-time drops are preserved. No map regeneration
or replacement spawn is required.

Rats use original procedural alert, bite, pain and death sounds. Alert follows
the shared newly-recognized-player-target path; bite replaces the sword-hit
sound only for rat melee. Pain and death use their native states. Each alias has
a local three-instance limit within 512 map units and native distance attenuation;
this is not a global cap across distant sectors. Sources and rights: ASSETS;
the author passed CA254-01 movement/listening acceptance on 2026-10-14.

## Equipped-Seal elemental resistance - 5.4.2 / #261

Only the equipped, unboxed Seal contributes. Owning another Seal, recalculating
attributes or channeling does not add another factor; tier does not scale it.
The authoritative factors live in CaelumSealResistance.

| Equipped Seal | Identified incoming elements | HP factor |
| --- | --- | --- |
| Fire | Fire, Light | 0.5 |
| Water | Water, Ice | 0.5 |
| Earth | Earth, Poison | 0.5 |
| Air | Air, Lightning | 0.5 |
| Quintessence | All four families above (both members of each pair) | 0.85 |

The author clarified on 2026-10-14 that only Fire, Water, Earth and Air have
elemental resistance. Quintessence has no resistance of its own: no Seal reduces
Quintessence damage. Existing generic magical armor still follows its own rules.

Physical damage and nonmatching elements retain factor 1. Prepared projectile
payloads identify primary/secondary elements even under generic damage names;
explicit elemental damage names cover nonprojectile sources. Physical impacts
from an elemental projectile remain physical. Generic magic with no authored
identity (including the current magic mine) is not assigned an element from its
appearance. Burn and poison identify their own element after their source dies.
Disease/cut remain outside the listed elemental families; no new source is added.

Direct and area damage retains shield/anatomy/armor wear/Toughness order. Apply
the Seal after those custom defenses, before the final nearest-integer HP round
and native damage handling. Area damage scales once after summing its regions.
The damage factor does not scale push, Lucidity formulas, thermal joules, control
strength or duration. Existing gates requiring actual HP loss still apply.

For harmful burn/poison, scale new dose before the existing fractional-HP
accumulator and deliver through the already-resolved sustained-damage path. The
factor is not applied again at native HP entry. A 1 HP/s burn lasting two seconds
with a matching Seal deals one HP; Quintessence retains 17 of 20 such HP. Changing
Seals affects future accrual, not already-earned fractional HP or remaining time.
Healing is not reduced. No timers, counters or save schemas are added.

This is an explicit exception to #188's damage-derived status dose: remove the
direct Seal contribution when constructing a projectile's source dose, because
each future status pulse receives its own current Seal factor. The calculation
retains observed native damage retention and integer rounding; MAP01's protected
1 HP floor does not inflate a capped dose. This prevents a matching Seal from
turning one intended 50% reduction into 75% across the source dose and its ticks.

Character displays `(1 - averageMagicalArmorRetention * sealFactor) * 100` for
the four elemental pairs, with the existing equal body-slot average and no Toughness or
blocking. Fire's 50% passive factor plus 7.5% innate absorption therefore displays
53.75%, while unrelated rows remain 7.5%. Bilingual item details explain the
passive condition. The 7.5% is the existing Human innate magical armor from #52,
also used by the debug profile; it is not a new Seal bonus. There is no fifth
Quintessence resistance row. Native checks/limits: assets/validation_542/RESULTS.md.

## 5.3.9 - Exploration navigation and owned documents (#236)

The entry-point audit found the seven Journal tabs, formal inventory filters,
native inventory commands, World/travel page, native local map and manual-note
editor already implemented. The delta is an Explore menu connecting those
existing destinations, a read-only owned-document projection and native popup
adapters. No replacement inventory, quest or travel service is introduced.

| Entry | Destination / authority |
| --- | --- |
| Existing Journal binding (default Tab) | Last Journal page; existing filters, selections and detail behavior |
| Journal Explore button / contextual N; pause menu > Explore | Native live navigation menu; Back retains its parent |
| Optional ca_exploration, ca_inventory_open, ca_world_open, ca_missions_open, ca_keys_open controls | Explore, formal Inventory, World, Missions, owned Keys/Documents; no assigned defaults |
| Native showpop 1 / 2 / 3 | Missions / Keys and documents / Character; no stock Strife popup |
| Existing native invprev/invnext/invuse/invdrop/invquery | Existing engine inventory compatibility; not a second formal inventory screen |
| Explore > Local map | Native automap; an already-open map keeps its center/zoom/rotation |
| Explore > World / Map notes | Existing World journal / native map-local note editor |

Direct shortcuts resolve exact current bindings inside live Journal pages;
native menu/navigation keys keep precedence, and conflicting context labels
show Click. Compound aliases/double bindings retain native gameplay dispatch,
not a new panel interpreter. Controls/reset/defaults are unchanged. Map hints
resolve normal/map binding precedence and retain a pause-menu fallback when
Explore is unbound. N is a Journal context action, not a new global binding.

Keys and documents traverses the current pawn's native Inventory, including
owned boxed documents, and shows only positive-amount owned weighted keys,
sealed letters and processing manuals. Native names and quantities are reused;
keys describe their existing automatic lock check. The two implemented document
actors have names but no authored readable body, so the view says no additional
text is available. It does not invent pages, use an item, teach recipes, reveal
unknown material or retain consumed content as an owned object. The broader
Inventory key-item filter still includes bags/decks and keeps its existing meaning.

World remains a read-only projection of visited/known/traversed records. Local
geometry, discoveries, numbered marks, manual notes and tracked objectives retain
their distinct owners. Browsing cannot start a journey; the existing World
travel offer and physical services still own confirmation and revalidation.
Live screens keep natural simulation time running; reading does not apply a
journey/time-skip charge. Rest, card games, active conversations and modal
services cannot be bypassed with a navigation shortcut. Native pause/settings
and save/load remain native. No saved field or migration is added by #236.

Evidence: assets/validation_539. CA236-01 passed full author acceptance on 2026-10-14.
Physical author acceptance is separate from technical checks; scripted menu handlers and
console routes are identified separately in the native evidence.

## 5.3.8 - Multiple tracked missions (#235)

The author chose independent simultaneous mission tracking. Journal > Missions
offers Track/Untrack with T, Backspace or the native clickable action; changing
the selected row or filters does not change tracking. Both filter headings are
clickable and retain C/V and the accepted controller triggers. Detail, history,
side-quest actions, abandonment and Back retain their existing paths.

Tracking is a presentation preference in the traveling character Inventory:
`QuestTrackingRevision=1`, `QuestTracked[QUEST_CAPACITY]`. Revision-zero saves
start with all choices false; migration only advances this additive revision,
is idempotent and infers no past selection. Set events contain the desired bool,
validate ownership, creation/live state, stable quest ID and current eligibility,
and cannot alter quest stages, rewards, discoveries, reputation or travel.

Only active known missions can enter tracking. Terminal records retain their
selection for history but cease to appear on the map; they can be untracked.
Offered/failed/abandoned filters and the completed captain clue retain their
existing semantics. Prisoner rescue still completes at live extraction, before
and independently of payment. Payment is never a new tracked rescue stage.

`CaelumQuestTrackingView` reuses the Journal's current-stage selector, localized
objective text and snapshots. Map rows show each tracked title/objective plus
known location information. Long rows end in an ellipsis; full text remains in
the paginated Journal detail. Available screen height bounds rows above the
resource bars, with an explicit count of additional tracked missions if needed.
The nearest known POI label identifies an applicable tracked objective. At the
author's subsequent request (2026-10-14), its native map marker uses the existing
owned target symbol while that known place is a current tracked destination.
The symbol replaces the ordinary category icon at the recorded position and is
larger using existing presentation dimensions. Stage changes, untracking and
terminal states restore the ordinary icon without changing the recorded fact.
The same stage selector and known-place association drive text and symbols; all
matching known destinations can be shown simultaneously. Unknown or other-map
places never acquire local markers. No enemy/route overlay, camera move, travel
action, new actor class, saved field or migration is added.

| Current objective text | Eligible already-known POI IDs |
| --- | --- |
| Speak/return to Argento | `mansion-room-bedroom-argento` |
| Speak/return to Caella | `mansion-room-bedroom-caella` |
| Caella completed; consult Palomo and Ronnie | `mansion-room-upper-workshop`, `mansion-room-bedroom-ronnie` |
| Report finished lessons to Ronnie | `mansion-room-bedroom-ronnie` |
| Speak to Rulo before his trial | `mansion-room-bedroom-rulo` |
| Rulo's target exercises | `mansion-room-practice` |
| Rulo completed; meet Palomo upstairs | `mansion-room-upper-workshop` |
| Current crafting lessons | Ronnie's observed `mansion-station-2-4`, `mansion-room-upper-workshop` |

These associations come from the existing LANGUAGE objective instructions and
#234 identities. The adapter intersects them with the character's KnownPois;
an active mission never inserts a POI. Map names require a recorded visit or a
known matching place. Other-map objectives identify only that known map/place.
Sewer traversal, rescue refuge, siege targets, mobile companions, runes, the
secret room and the Fool have no invented precise waypoint. Authored spoken
directions remain text. Persisted NPC disclosures with exact positions would
need separately specified information events; no new disclosure schema is
silently inferred from activating a quest.

Audit discrepancy: existing `CaelumOnboarding.UpdateLessons` calls legacy
objective setters before Palomo, which can activate slot 0 and mark future
crafting objectives known. The documented #34 start condition remains Palomo's
guidance. The read-only catalogue therefore hides early stages without the
recorded PALOMO_MET flag, while preserving genuinely later legacy stages and
all stored progress. Objective snapshots also respect the existing authored
stage constants. No underlying quest setter/controller is changed in #235.

Static/build checks and 114 native assertions passed across 13 runs, with
18 save comparisons and 19 inspected captures. Evidence is recorded in
assets/validation_538; native diagnostic state setup is
distinct from ordinary campaign progression and author acceptance. On 2026-10-14
the author accepted CA235-01's four presented tracking/navigation/save-load/history
steps. CA235-01 passed full author acceptance on 2026-10-14.
The spatial-marker follow-up CA235-02 passed author review on 2026-10-14.
#236 remains a separate navigation patch.

## 5.3.7 - Authored local exploration (#234)

Discovery decisions confirmed 2026-10-14: enter rooms/towers, interact with
services even when access is denied, cross MAP06's open east arch, and remember
each of the six south gates separately. Siege-sector warnings are explicitly
deferred until their information sources and visibility rules are authored.
No new warning, quest, route permission, map geometry or gameplay actor is added.

| Map / stable identity | Authoritative source | Knowledge event |
| --- | --- | --- |
| MAP01 `mansion-room-<id>` (ten entries) | `assets/map01_mansion/CARTOGRAPHY.json`, current WAD, REPAIR/PRACTICE data | Feet enter the named room's interior and vertical storey |
| MAP01 `mansion-bed-101..104` | Existing furniture TrialSlot and actual actor position | Bed interaction |
| MAP01 `mansion-station-<group>-<type>` | Existing five workshop groups and station type | Station interaction |
| MAP01 `mansion-palomo` | Existing Palomo merchant actor | Trade interaction |
| MAP02 `maze-grate-<tag>`, `maze-return-<tag>` | Existing gate controller tag and actual position | Native grate use, including denied use |
| MAP02/MAP06 `travel-<connection>` | Existing placed active sewer travel gate | Travel interaction; route rules unchanged |
| MAP06 `port-r<layout>-gate-<index>` | Existing port controller Gates array | Gate use; six south, north and west in current city |
| MAP06 `city-east-exit` | CITY.json east-arch bounds/headroom | Crossing the arch plane inside its passage |
| MAP06 `city-tower-0..3` | CITY.json tower footprints and walk/deck heights | Entry at the tower's physical heights |
| MAP06 `city-shop-<ShopIdentity>`, `city-bed-<house>` | Existing merchant identity or furniture slot | Service interaction |
| MAP06 `city-factory-<building-id>-<station-kind>` (96 stations) | CITY.json building IDs and INTERIORS.json profiles/slots, matched to the actor's original SpawnPoint under the current compact or exact legacy_5427 furnished TEXTMAP checksum | Interaction with that individual station; network membership reveals no other station |
| MAP06 `port-covered-cart`, `port-merchant-ship` | Existing vehicle instance | Boarding interaction, even when route 10 remains unavailable |

Room bounds deliberately omit secret spaces, labels and connections. Entering a
bedroom does not discover its bed; a lower storey does not discover the room
above. Native explored linework remains the sole route geometry source, with
its existing 2D stacked-floor limitation. No keys, containers or enemies are
annotated. Rooms use a separate owned emblem so manual notes retain their paper
symbol. Labels identify mansion storeys and separate south gate numbers.

`KnownPois` remains character-owned. `LocalKnowledgeRevision=2` adds only
`ObservedAccess` (0 unknown, 1 closed, 2 open). Old facts retain their values and
start with unknown access; migration is idempotent and infers no visits. Grates
record the last personally observed state on use, including the successful
opening. A remote change does not silently update another character's record.
The marker uses that saved observation too: observed-open grates use the dedicated
open-padlock icon; other grate states retain their existing category padlock.
The label continues to distinguish closed/open/unknown observations. Rendering
never reads the hidden gate state or changes knowledge, access or saved schema.
City port gates also record their closed/open state on use, including after a
successful opening. These observed exits share the closed/open padlocks; generic
exits, the east arch and manual exit notes retain their existing symbol. Older
city gate facts with unknown access remain unknown until another interaction.
Automatic or remote gate closure does not silently revise a personal observation.
The upper elevator control does not reveal hidden lower return grates, even
though it dispatches through their controller; lower-grate use records them.
Use hooks grant no key, permission, faction standing or quest progress.

Generated room/tower/crossing data is guarded by the loaded level's native
TEXTMAP checksum. MAP06 accepts the compact current map and exact legacy_5427
furnished layout, whose authored coordinates and IDs are identical. Future
coordinate/ID edits must preserve a separate legacy table or remove eligibility
explicitly; a new checksum alone cannot prove catalogue compatibility.
Unsupported older geometry receives no current-layout region
coordinates. Real services keep actor-relative observations and explicit saved
identities; old port gates use their own layout ID and neutral label. Transient
crossing samples reset on load, so loading beside the arch is not a crossing.
Derived marker lookup is cached by owner/knowledge serial; multiplayer marker
suppression and personal records retain #232's privacy contract. The #233 manual
editor still offers exactly its six approved categories.

Static/build checks and 151 native assertions passed across 16 runs, with
16 native-save comparisons and 12 inspected captures. Evidence: assets/validation_537.
CA234-01's mansion exploration/save-load passed author review on 2026-10-14.
The author then reported that an open grate retained its padlock despite its
correct open label. The derived icon now follows ObservedAccess; 43 focused
native assertions passed after reproducing the original visual mismatch.
The author confirmed that the icon changed, but expected an open padlock instead
of the initially reused Use hand. The dedicated artwork passed another 43 native
assertions and two save comparisons. On 2026-10-14 the author accepted the focused
closed/open-padlock test and save/load. CA234-01 passed full author acceptance on 2026-10-14.
Preserve original saves/packages; #235/#236 remain separate patches.
The author's subsequent city test reported hand icons on gates and missing
southwest factory stations. On 2026-10-14 the author accepted the focused gate,
workbench/adjacent-station and save/load retest. CA234-01 passed full author acceptance on 2026-10-14. Further evidence: assets/validation_537/RESULTS.md.

## 5.3.6 - Personal manual map notes (#233)

Author-approved placement (2026-10-13): pan the native automap, then open
Map notes from the main menu or a player-assigned `ca_map_notes` binding.
The editor captures `level.GetAutomapPosition()` once. A new note uses that
center; selection/editing uses the native keyboard/controller menu and clickable
list. Outside the automap the list can edit existing notes, but creation is
disabled rather than guessing a placement. No default key or binding reset is
introduced. The native ten numbered marks and geometry discovery remain intact.

The six presentation categories are Note, Bed, Station, Merchant, Exit and
Transport. Every manual marker uses the owned Journal quests/paper icon to
separate player writing from observed service icons. The list and nearest-center
label show its category and text. A manual Bed or Exit never creates a known
POI, room, route, destination, objective, reward or travel permission. Notes may
record guesses; the UI does not validate them against hidden map content.

`CaelumPersistentCharacterState` owns `ManualNotesRevision=1`, the dynamic
`ManualNotes` array, a monotonic next ID and edit serial. Each note stores ID,
map ID, category, text and XYZ. Old saves migrate to an empty list idempotently;
no automatic facts or numbered marks are imported. Native inventory save/hub
serialization retains this data. The unchanged old save with its original
package remains the recovery source. Same coordinates or labels are not IDs.

A local draft is committed only on Save or confirmed Delete. The native
`TextEnterMenu` owns text input, Unicode keyboard handling and the controller
character grid. Canceling text entry restores its prior draft; canceling the
editor changes no note. Long stored text is retained, wrapped and scrollable;
list rows and the map label abbreviate presentation only. Native append/backspace
editing and the native controller grid remain the supported input capabilities.

Typed network commands validate originating player/map, live character, stable
ID and expected serial; duplicate/stale requests cannot modify a different row.
The native command length field is unsigned 16-bit, so this request's technical
limit is 65,535 bytes minus 42 fixed bytes and the map ID byte length. Oversized
text stays in the draft with feedback; it is never silently truncated or sent
with a wrapped command size. There is no gameplay note-count limit. IDs use the
native signed integer range and are never reused after deletion.

The list and native text child keep the existing live-menu policy; native
Save/Load and other main-menu screens keep their own pause policy. Death,
character/map replacement and exhaustion dismiss an invalid editor. Pointer
press/release guards include layout revision, resolution and UI scale. UI-only
acknowledgments are transient, not knowledge. Native derived note markers use
the same private-renderer restriction as #232: suppress them in multiplayer or
with multiple participants while keeping character records separate.

Native checks passed; evidence: assets/validation_536/RESULTS.md. CA233-01 passed full author acceptance on 2026-10-14. #234 map-specific
registrations, #235 multi-mission tracking and #236 Journal navigation remain
separate patches.

## 5.3.5 - Personal local POI knowledge (#232)

Services become known on valid interaction with a registered bed, station,
merchant, exit or vehicle. Author decision (2026-10-13): an interaction still
records the place when combat, access requirements or a lock blocks the service.
Knowledge grants no permission to use, unlock or travel through it.
In particular, MAP06 coastal connection 10 remains disabled by the existing
world catalogue even when its cart is known. Seeing a
service, revealing its native lines or visiting its map grants no local POI.
The separate approved world-route signage rule remains unchanged: a known
connection is neither a known local service nor a visited destination.

`CaelumPersistentCharacterState` owns `KnownPois` and `LocalKnowledgeRevision=1`.
Each fact stores the exact map ID + authored stable POI ID, category, localization
key and last observed XYZ. The pair, not coordinates, translated text or list
order, identifies it. Revision-zero saves migrate idempotently without inventing
discoveries. Normal inventory serialization carries these facts through native
save/load and hub travel. Recovery uses an unchanged pre-patch save with its
original package; writing a new-schema save does not modify that original.

`CaelumPoiRegistration.Bind` links an existing service to explicit authored
metadata. Repeated equal bindings are harmless; conflicting identities fail
closed. An absent subject may be rebound to the same identity. Registration
alone never writes personal facts. #234 owns actual MAP01/MAP02/MAP06 entries;
this patch supplies the framework and isolated validation registrations only.
No new NPC information, disclosure rule, room detector or reveal radius is added.
The author-approved later room/tower condition is entry, not mere visibility.

`CaelumPoiKnowledge.Find` is a read-only lookup for map/objective integration.
`CaelumPoiView` exposes conditional localized names and nearest-known-center
selection; UI opening, drawing, panning and lookup cannot mutate knowledge,
quests, rewards, routes or geometry. Full map shows the name/category of the
known place nearest the map center, with no selection/discovery radius. Native
icons project through native zoom/pan/rotation in both map modes. Only already
known facts are candidates, including facts on another known storey; unknown
stacked-floor and secret-room registrations remain absent. Native 2D overlap
still applies. This is memory, not a promise that a service remains available:
moving/removed objects leave their last observed location until used again.

Presentation reuses the project's sleep, crafts, gold coin, use and world icons
for bed, station, merchant, exit and transport. Category metadata lives in
`CaelumPoiData`; authored coordinates/names remain outside generic logic.
The native MapMarker renderer ignores ownership and player-visibility flags.
Therefore these derived markers are suppressed in multiplayer or with multiple
participants; personal records and read-only labels remain separate. Full
multiplayer support is not claimed. Markers contain no authority, reveal flags,
target TIDs or live-object tracking; they consult only the current character's
known fact. No renderer or reveal CVar is changed.

Evidence and precise fixture limits: assets/validation_535/RESULTS.md.
CA232-01 passed author acceptance on 2026-10-14; #233 notes, #234 registrations, #235 multiple
mission tracking and #236 Journal navigation remain separate deliveries.

## 5.3.4 - Native local cartography (#231)

The local view uses GZDoom 4.14.2's automap renderer and discovery. A project
MAPINFO palette supplies paper/ink linework and a contrasting overlay palette.
`am_customcolors=false` retains the user's native colors; existing texturing,
line, background and scaling preferences remain authoritative. No startup,
load or opening code resets settings or bindings. The read-only cartouche uses
existing fonts and UI scaling, reserves the measured survival-warning width,
and moves transient messages below it without removing history or resources.
Its vertical position is bounded above the actual resource-label edge; large
native notification preferences cannot push this project panel over the bars.
Native console notices retain their own drawing/lifetime and are not reset.

Location comes from WorldCatalogue. MAP01 shows the authoritative local Limbo
clock; campaign maps use Calendar's normal campaign date/time. The objective
provider is deliberately empty until #235 supplies a known tracked objective;
the current Journal selection is not treated as tracking. No POI registry,
named notes, travel action, secret detector or geometry change belongs to #231.

| Facility | GZDoom 4.14.2 owner and integration |
| --- | --- |
| Discovery | Native `ML_MAPPED`, `ML_REVEALED`, `ML_DONTDRAW` and drawn subsectors. Presentation writes none of them and enables no reveal cheat. |
| Zoom and pan | Native `+am_zoomin/out`, `am_zoom` and `+am_pan*`. Follow must be off for free pan; native follow-on pan-key fallback remains unchanged. |
| Follow and rotation | `am_togglefollow`, `am_followplayer`, `am_rotate` (off / always / overlay only). The cartouche reports the actual orientation. |
| Full screen / overlay | `togglemap`, `am_overlay` (off / overlay-then-full / overlay-only). Existing live simulation and 3D overlay behavior remain; accepted full-map crosshair exclusion stays authoritative. |
| Bindings | Native AutomapBindings and Bindings. Hints read the current tables and omit a normal key shadowed by a different map command; no new marking key is assigned. Double bindings remain engine-owned and are not exposed by ZScript. |
| Numbered marks | Native ring of ten marks (0–9), stored with each map's automap object. They are not named/category notes; #233 is separate. |
| Saved view | Native serializer preserves marks, scale, bounds and big-map state. The header adds no saved owner, schema or migration. |
| Custom point projection | Native MapMarker can project actor icons through zoom/pan/rotation. ZScript exposes the map center, not a complete public projection or floor-picker API; later POI/notes issues own discovery and per-character authority. |

The source audit is pinned to GZDoom commit
`99aa489d09015a95bb78df2b30ede29f328cc874` (tag g4.14.2), especially
`src/am_map.cpp` / `am_map.h`. Native ordinary input and hardware acceptance
remain distinct from isolated console-command checks.

**Mansion limitation:** native linework is a two-dimensional projection of
known lines, without a selectable floor. The 3D-floor border color does not
filter away another storey. Textured mode chooses visible floor surfaces below
the viewer's height, but is not a floor selector. The cartouche states that
storeys can overlap. Native bounds also include distant control vertices, so
the initial overview can be small; zoom/pan remain under user control. This
patch does not invent a floor-selection or automatic-zoom policy. Readability
of the retained projection remains an explicit author check.

Evidence and exact limitations: assets/validation_534/RESULTS.md. CA231-01
passed author acceptance on 2026-10-13. Renderer captures, scripted native
commands and static validation remain separate evidence; no unreported
physical-controller testing is inferred.

## 5.3.3 - Involuntary exhaustion sleep (#258)

Initialized living characters immediately lie down when Sleep reaches 0%, at
their current position. Combat, critical needs, unsafe ground, air and water
do not block this transition. The author explicitly chose immediate lying in
air/water with ordinary falling, flotation or sinking and no relocation.
Input is disabled while lying, but exhaustion alone does not zero physical
momentum or alter collision, gravity, drowning, damage or death handling.

Standing is locked while Sleep is **<=10%**, including exactly 10%. Only a
value strictly above 10% permits voluntary cancellation; passing that value
does not itself wake the character. Movement, actions, Cancel/Back, Journal
and time-skip entry cannot bypass the lock. Damage and spell timer expiry do
not release it. Timed Arcanist sleep remains an independent effect. Live
activities close through their existing interruption paths; conversations
use native Back without selecting a response, and card games retain their
existing context-loss/forfeit policy. Pausing still pauses simulation.

Ground exhaustion has factor 1. A nearby bed or owned bag grants no support.
Only an already occupied valid sleeping support retains its existing factor;
chair conversion drops support without using the relocating furniture exit.
Moving away from a real support drops that support without moving the body.
Critical Hunger/Thirst still reduce effective comfort to 1. The rest panel
shows that effective factor. Recovery uses existing shared sleeping pulses
and location time scale: no instant refill or offline-time catch-up. #257
automatic portions and F/G behavior apply while lying, with real stock and
in-flight guards. Ordinary fast-forward safety remains authoritative; ground
exhaustion grants neither a safe zone nor the MAP02 bag exception.

Hidden InterHub `CaelumRestState` owns `ExhaustionRevision=1`, `Exhaustion`
and the one-per-lock feedback latch. Migration is idempotent and does not
reset resources or sessions. Old initialized zero-Sleep saves reconstruct
the condition on their next live tick. Hub travel keeps the lock, anchors
the new map/current position and discards stale support/camera ownership.
Death terminates the living controller normally. Preserve the original save
as a reversible rollback copy; never overwrite it during migration tests.

These rules supersede the voluntary-rest blockers only for exhaustion.
Evidence: assets/validation_533/RESULTS.md. CA258-01 passed full author acceptance on 2026-10-14.

## 5.3.2 - Automatic food and water (#257)

Hunger and Thirst independently start real portions below 50% outside seated
or lying rest. Exactly 50% does not start a portion. At or above the target,
do not schedule another portion; the current native effect finishes normally,
including natural overshoot. Crossing below 50% re-arms without hysteresis.
Actual occupied chairs, beds, the owned deployed bag, ground sleep and the
existing spell-sleep timer use a 100% target. This patch supplies the common
eligibility needed by #258; it does not implement exhaustion-induced lying.

Author decision of 2026-10-13: F/G and Eat/Drink pause/resume that channel's
100% filling for the current rest. A paused channel still serves below 50%.
The next rest starts with both channels enabled. A toggle never refreshes or
duplicates an in-flight portion, refunds an item, or cancels digestion.
Reaching full does not permanently disable later automatic consumption.
These rules supersede #227's manual start, chair/bag-only and bed exclusions.

Use an eligible table first, then carried provisions, then the owned Box.
Ordinary table access requires the actual reachable seated support; explicit
time skip retains its existing safe-location access rules. Food units, water
rations and containers use their original inventory transaction, body-mass
dose, ten pulses, seated pacing and actual recovered-food Sleep cost. Preserve
container identity, Box location and a partial final sip. MAP01 retains #177's
immediate refill; other maps gain no replenishment. Other consumables are not
automatically used. Empty/blocked channels cache failure until supply, posture,
map, ownership or manual-control changes; they produce no per-frame notices.

One authoritative DiningSession transaction runs from the shared personal tic,
after native effects and resource costs. Time skip no longer has a second
serving loop. Its copied forecast uses the same targets, post-cost scheduling,
seated sub-tic pacing and active effect progress. Forecast ProvisionRevision 2
invalidates older cached forecasts. Existing thermal forecast limitations remain:
the supply model does not project evolving shivering/sweat costs. Native tests
separate exact digestion equivalence from full simulation in a cold location;
thermal rules and acceleration permissions are unchanged.

Saved owner: the existing InterHub CaelumRestState, ProvisionRevision 1. Missing
revision initializes automatic rest flags and clears only failed-supply cache
once. Current pauses and native inventory/power instances remain serialized.
Migration does not consume or refill anything. Retain original save slots for
rollback in 5.3.1; write new slots after migration. Evidence and limitations:
assets/validation_532/RESULTS.md. CA257-01 passed author acceptance on 2026-10-13.

## 5.3.1 - Character resources and combat readouts (#256)

Journal > Character keeps all twelve attributes and the Tarot bonus, adds
live evasion and physical/magical critical percentages, and moves Hunger,
Thirst, Sleep and signed thermal Exposure into its right column. T and the
native Temperature button expose the existing thermal detail; World > T still
works. Viewing either page is read-only. Combat and presentation share the
same capped critical queries: catalogue/tier base, derived bonus, crouch and
personality. A category the active weapon cannot use says Not applicable.
Actual fists have no critical roll and display 0%; the utility stream likewise
has 0% magical critical, and bolas have no damaging critical category.

Author follow-up on 2026-10-13: show elemental resistance as a percentage,
`100*(1-mean(damage factor across the four armor regions))`; factor 0.5 means
50% resistance. Each region uses current additive racial and equipped magical
absorption, including personality and broken/absent armor. All five essences
currently share that defensive rule. Do not invent distinct per-element bonuses.
Exclude Toughness, shield coverage and hypothetical attacker penetration from
this character resistance readout. It is not a prediction of final HP loss.
Evasion is the same capped current chance used for eligible direct attacks;
explosions and other non-evadable damage do not gain a new roll.

The author also changed the retained HUD layout to two lower-edge columns,
each ordered top to bottom: left Load, Lucidity, Health; right Adrenaline,
Anima, Air. The four survival bars now live in Character. Their adverse states
reuse the existing resource/thermal icons and severity palettes immediately
left of Seal/Tarot. Recovery clears each adverse indicator. This supersedes
the former ten-bar arrangement under #131/#213, preserving values and native
scale preferences. No new artwork or gameplay thresholds are introduced.

Hunger, thirst, sleep, heat, cold and recovery notifications use bilingual
text and the existing notification duration/cap. Sample the completed real
tick, not every accelerated simulation substep. One live message per resource
can change text without extending its timer or replaying intermediate states.
No recurring warning cadence is added. NotificationInbox SurvivalRevision 1
imports the current four state codes silently once; saved current state codes
prevent replay on load/hub travel. New fields are additive to existing classes.
Keep original saves and load them in the previous package for rollback; always
write new test slots. Native/save evidence: assets/validation_531/RESULTS.md.
CA256-01 passed author acceptance on 2026-10-13.

## 5.3.0 - Right-edge power indicators (#255)

Seal and Tarot use 88x88 and 64x96 virtual-unit rectangles respectively, twice
their former width and height. Tarot remains above Seal. Both icons and their
existing duration/cooldown captions share one viewport-right transform driven
by the native HUD scale, independently of the centered HUD and the resource
bars' 1.95 enlargement. The group keeps an eight-unit right/top margin.
The complete 232-unit column fits above the retained resource bars; if a large
native scale cannot fit, its uniform fit factor reduces the whole group.
Thus 2x is the uncapped reference target, not a guarantee at every viewport.
Availability, desaturation, selection and timers still read the existing owners.
No power activation, saved state, controls or assets change. #256 owns adjacent
survival debuffs and moving the four resource bars into Character.
Native/static evidence: assets/validation_530/RESULTS.md. CA255-01 passed author acceptance on 2026-10-13.

## 5.2.27 - One-gram empty Magic Box (#229)

The author sets the empty Box mass to **0.001 kg (1 gram)**, replacing 10 kg.
This is its tare, not a fixed total regardless of contents. Capacity and content-weight
divisor remain `20 + floor(10 * Type3Multiplier(Intelligence))`. Aggregate raw
contents are divided by capacity and truncated once to grams, then the tare is
added. An unowned Box contributes zero; ordinary inventory refresh recalculates
existing saves without changing ownership, contents or schema. HUD and total
carried load use the same authoritative constant.

## 5.2.26 - Visible rest action feedback (#227)

Historical accepted behavior; #257 above supersedes its serving controls and eligibility.

The native rest panel displays the newest live notification below its controls,
using the engine message scale and wrapping the full text. This exposes existing
fast-forward/dining rejection reasons previously hidden by the ordinary HUD's
menu guard. The same inbox and Journal history retain the result; paused menus
keep their existing presentation. By the author's follow-up decision, F/G and
Eat/Drink now serve provisions in any occupied chair (Wait) or the owned deployed
sleeping bag (Sleep), including the standalone MAP02 arrival chair. A reachable
table supplies first when seated beside one; otherwise use carried provisions,
then the owned Box. No food/water is created. Existing native portions, pulses
and seated pacing remain; a second activation stops that channel, the current
portion finishes, and unsupported rest/standing cannot start automatic serving.
Beds retain the existing restriction. Fast-forward captions
now say x105, matching the existing simulation; its rate and safety rules do not
change. Meal support participates in pointer revision so a click cannot cross layouts.

## 5.2.22 - Parenthesized menu controls (#215)

Each interactive menu caption identifies its existing keyboard control in
parentheses. Navigation-only lists show arrows/Enter; this does not create
new direct shortcuts. The shared CaelumInputHints formatter covers creator,
appearance, Journal navigation/actions, crafting, time skip, rest, containers,
trade, calendar, notices, cards, conversation replies and story prompts.
Native engine options use Enter, Left/Right or Enter/Backspace according to
the item's existing behavior. Numbered NPC replies show their native number.

Remappable Journal/time-skip actions read the current bindings on each draw.
Keys already consumed by native menu navigation are not advertised as global
menu actions. A contextual letter shadowed by a higher-priority binding shows
Click; an existing Tab fallback is retained where dispatched. No settings,
bindings, pause ownership, gameplay or saved fields change.

Native labels are decorated only during rendering and restored immediately.
Option-search source labels and saved-game names remain original. Native
specialized menu classes retain their behavior; save/load hints are a visual
overlay. Full custom captions fit within their button bounds, and confirmation
click bounds include the appended hint. English/Spanish evidence and limits:
assets/validation_5222. Author acceptance CA215-01 is outstanding.

## 5.2.21 - Visible tutorial gold (#216)

Fresh MAP01 games spawned the finite 2 kg gold actor with collision but no
model registration for its subclass. Register the existing gold-rock OBJ for
CaelumTutorialGoldVein; keep placement, harvesting, quota and depletion intact.
Native before/after captures and extraction/save-load checks are recorded in
assets/validation_5221. Author visual acceptance CA216-01 remains pending.

## 5.2.20 - Edge-anchored resource bars (#213)

Supersedes the shared centered resource frame in the 5.2.15 contract below.
The original #213 arrangement (superseded by #256 above) placed five
bodily-resource bars at the lower left; temperature, load,
hunger, thirst and sleep anchor at the lower right. Frames, fills, icons and
labels share a **1.95 multiplier** over the existing native HUD scale (another 50% over
the initially requested 1.30 multiplier). The
native HUD preference remains authoritative; the game does not rewrite it.

Both groups retain the existing 24-unit row spacing and artwork. Labels move
from 12 virtual units below their fill origin to 12 above; right labels end at
their bar's inner right edge and grow inward. The original group bounds leave
two scaled units between the outer artwork and the screen edge. Groups grow
until their measured localized text/art widths or height fill the viewport;
that cap can reduce the 95% increase on small displays or extreme scales.
Two additional measurement units cover text shadows and separate the groups.
The last row stays anchored when a longer label requires this fit adjustment.

Menus, compass and other HUD indicators retain their scaling. If central
magazine/reload or charge text would cross a resource group horizontally, its
native-scale text moves above the groups; otherwise its position is unchanged.
Resource text renders after first-person weapon/shield art so long labels
stay readable. All resource values, thermal thresholds, colors, actions and
save fields remain.

## 5.2.19 - Landing capacity for horizontal cushioning (#211)

The author's amendment applies a **1.5 multiplier** to each eligible body's
own jump absorption speed. Horizontal eligibility remains player/charging bull;
the later amendment extends 150% to falls for ALL already cushioned biological
bodies. For assigned
energy E and recipient normal delta-speed d, in consistent velocity units:

    a = 1.5 * jumpAbsorptionSpeed = landingAbsorptionSpeed
    residual = max(0, d - a)
    retainedEnergy = E * (residual / d)^2   when d > 0

At zero delta retain E, preserving the existing zero-delta guard. At or below
capacity, retained energy is zero before anatomy, regional armor and final
Toughness. This replaces the horizontal Agility-0 bonus ratio and 50% cap;
Agility 0 now has nonzero capacity when the body can absorb its own landing.

Player ordinary eligibility includes walking/running/crouching into walls or
scenery stationary before contact. The later #339 amendment also permits wall
contacts during a confirmed voluntary jump, including its descent. Moving scenery and incoming bodies have
no ordinary movement allowance. The active buckler retains its broader contact
eligibility and its x2 landing enhancement: horizontal capacity is 3 * JumpZ,
not a sum of ordinary and buckler absorption. Immobilization suppresses both.
Player JumpZ already includes natural/total mass, Agility, health and elemental
jump modifiers; no second copy of those factors is applied.

The bull uses its existing landing helper (natural/loaded mass, Agility and
physical-stun suppression), only while its charge remains eligible and the
contact normal is horizontal. Its former horizontal-only health/partial-element
ratio is superseded by that exact landing capacity. Full elemental interruption,
bolas, death and inactive charge retain their exclusions. Other NPCs receive no
new horizontal allowance. Both recipients keep independent assigned energy;
one body's capacity never reduces the other's damage. No saved fields or
native state timings change. Actual jump physics stays unchanged.

Crushing explicitly retains its previous capacity: ordinary sustained body
pressure uses the unscaled jump helper; hazard-rock pressure retains its old
buckler-only fractional Agility bonus with a 0.5 cap. Static supported weight
and ceiling work also stay unchanged. Capture crushing provenance before a
hazard source is relabeled environmental, so it cannot acquire fall cushioning.
Weighted NPC rock pressure remains uncushioned; the older unweighted/direct
bull fallback retains its original charge fraction, health/elemental modifiers
and 0.5 cap, rather than acquiring the new landing allowance.
An incoming falling rock remains an environmental impact: active buckler gets
the new landing capacity, but ordinary movement grants no incoming allowance.

## 5.2.18 - Rest presentation and contextual input (#209)

Seated F toggles automatic eating and G toggles automatic drinking without
also triggering the generic movement/action cancellation. T retains the
existing rest speed action; Journal/time-skip remaps retain priority. These
keys do not deposit food: table inventory interaction remains the existing
route. Q/stand-up and other intended cancellation actions still leave the seat.

Furniture aligns the drawn seat support with the chair surface using the
current character scale; bed/bag support uses the corresponding model surface.
Only WorldOffset changes, never physical capsule height, reach or resources.
The head copies the body's WorldOffset. Active older rests recompute their
owned offset from OriginalWorldOffset, without accumulating it each tic; an
external offset remains externally owned. Native old/current-save evidence is
recorded in validation_5218. No saved field or state index was added to gameplay.

Appearance now distinguishes female bare skin/fur hands and female equipped
gloves. Actual Hands-slot ownership/equipment still selects gloves; no new
equipment or stats are granted. Running/punch/death/sleep art and the dining
canteen model are presentation changes with unchanged combat clocks and item
identity. The canteen retains its water amount and inventory owner.

## 5.2.17 - MAP01 minimum player health (#207)

Throughout MAP01, damage cannot kill a living current player: health stops at
1 HP, retaining the same pawn, character profile and appearance. Damage above
that floor, armor/shield wear, control/status effects and resource consumption
still apply. This includes combat, collision/pressure, native crush/telefrag,
elemental DOT, drowning, hunger/thirst, environmental temperature and projected
journey health. Blocked integer damage is consumed, never banked for later.
The floor is neither healing nor a retry/reset. NPC behavior is unchanged;
player death is normal outside MAP01. Already-dead saved pawns are not revived.

The shared rule derives from the current map, without a saved flag or schema
revision. Final native damage calls temporarily use GZDoom 4.14.2 CF_BUDDHA2;
only a bit introduced by that call is removed afterward. This includes the
native Buddha2 semantics for forced damage: early bypasses remain, but late
native armor/invulnerability checks apply after the engine clears DMG_FORCED.
Caelum defense calculations precede that call. Returned health loss excludes
the blocked portion and cannot exceed that call's native result; native damage
events retain their engine-calculated damage payload. Direct health consumers
apply the same floor, and direct scripted Die calls return before death cleanup.
Thermal applied-damage accounting counts only HP actually lost.

## 5.2.16 - Native fullscreen cursor preference (#204)

Author decision, 2026-10-12: retain Vulkan and enable native `vid_vsync` for the
tested Windows installation. The native cursor became visible at fullscreen
startup with this preference; main menu, Options, creator clicks and gameplay
capture transitions passed CA204-01. This is an engine-global presentation
preference saved in the launcher's INI, separate from character saves.
`run_dev.bat` continues to respect that INI, without forcing VSync or a backend
on every launch. Native VSync can add presentation latency. The scoped workaround
does not prove the underlying engine/driver fault is repaired on other hardware.
Reproduction and failed alternatives: assets/validation_5216/RESULTS.md.

## 5.2.15 - Readability, native crosshair and comfort (#150)

Options > Readability and comfort groups existing native preferences; it writes
no defaults on startup, new game or load. Presentation belongs to the user's
global engine configuration, while identity/appearance belong to the saved
character. Native Save/Load classes and their Clean scaling are unchanged.

| Presentation | Native preference / integration |
| --- | --- |
| Journal, inventory, crafting, live panels | uiscale in the shared CaelumPresentation adapter; uniform pixels on the authored 640x360 frame, centered and capped to fit the viewport |
| Creator, appearance preview, introduction, cards | uiscale applied to their authored 600-high layouts; fit cap keeps the complete controls reachable |
| Resource bars, including thermal, indicators and compass | StatusBar.GetHUDScale; native hud_oldscale selects hud_scale/uiscale or hud_scalefactor; fit cap preserves the complete resource frame |
| Notifications, extraction, interaction hints and central transient notices | Screen.GetTextScreenSize, including native con_scaletext or its UI-scale fallback; text wraps at the selected message size |
| Crosshair | BaseStatusBar.Draw restores native crosshairon, crosshair, crosshairscale, crosshaircolor, crosshairhealth, crosshairforce and crosshairgrow |
| Camera and weapon motion | Native movebob, stillbob, wbobspeed, wbobfire and r_quakeintensity; modular hands, weapons and shields retain bAddBob |

UI scale is an integer pixel scale, with 0 choosing the engine's adaptive value.
Complete custom panels stop growing when they reach the viewport: this is a
layout fit constraint, not an engine inability to enlarge text. Message scaling
is independent and long messages have a scrollable view. Old HUD scaling and
the newer factor mode remain distinct; the native minimum factor is 0.36.
The adapter transforms both drawing and mouse coordinates, and clears drawing
transforms before first-person art and full-screen damage/Lucidity feedback.
Existing art, colors, outlines, filters, actions and resource thresholds remain.

Author decision, 2026-10-12: show the most recent complete notifications that
fit on the HUD and retain the last 20 complete messages in Journal > Notices.
That unpaused native view supports buttons, wheel, arrows and Page Up/Down.
The contextual L shortcut yields to remapped Journal/time-skip actions; its
hint disappears on conflict. The HUD link resolves the current Journal binding.
Temporary notification duration/count remain unchanged. CaelumNotificationInbox
history revision 1 is per-character, saved and bounded to 20 entries. Its
idempotent additive initialization copies active notices from an older save;
it does not alter their strings or remaining duration. Original saves remain
valid rollback sources. History is newest-first in the view, oldest-first in
storage, with no two-line truncation. Notifications are hidden behind menus.

The crosshair stays hidden in full automap, menus/live panels, conversations,
card games and native dead/chase/weapon-restricted contexts. Overlay automap
keeps the native 3D behavior. Native crosshairscale=0 means original pixel size,
not hidden; crosshairon=false disables it globally. crosshair=0 hides the normal
reticle unless a weapon selects its own; current Caelum weapons do not. Native health color modes
override fixed color and use the actor class's default health, not Caelum's
derived maximum health. GZDoom 4.14.2 exposes no hook for that normalization;
the options explain it. No gameplay health is changed to adjust reticle color.

Native movement/idle bob and weapon bob are cosmetic. Attack swings, thrusts,
charge/block poses, ADS, recoil, spread, costs, cooldowns and animation events
remain unchanged. wbobfire controls walking bob during firing, not the actual
attack animation. Rest retains the accepted right-drag orbit and inversion.
No extra intensity setting or new default is introduced. Accepted #137 flash,
wound and Lucidity feedback, thresholds and palette remain unchanged.

Evidence: assets/validation_5215/RESULTS.md. Technical checks and author comfort
acceptance are separate; the author confirmed CA150-01 passed on 2026-10-12.

## 5.2.14 - Native input ownership, groups and hints (#149)

GZDoom 4.14.2 remains the binding owner. Native Control rows support remapping,
clearing and the supported keyboard/mouse/controller key names. There is no
parallel gameplay input poller. The following inventory supersedes the category
placement recorded under 5.2.0; commands and gameplay meanings are unchanged.

| Native group | Commands / existing actions | Support boundary |
| --- | --- | --- |
| Movement and interaction | +forward, +back, +moveleft, +moveright, turning/strafe/look, +jump, +crouch, +speed, +use, +moveup/+movedown | Native movement/use and existing flight remain available |
| Combat and blocking | +attack, +altattack, +reload, +zoom | Primary, secondary/aim, reload/charge, block/sweep/aim |
| Race, Seal, Tarot and class | +user1, +user2, +user3, +user4 | Racial/class rows are reserved interfaces with pending content; Seal/Tarot retain implemented behavior |
| Weapon selection | slot 1..10, weapnext, weapprev and native weapon rows | Slot 2 cycles exact equipped Caelum items via PickWeapon and the existing authoritative event |
| Journal, inventory and time | ca_journal_toggle, ca_time_skip; invprev/invnext/invuse/invdrop and native inventory rows | Journal handles formal equipment; native inventory remains compatibility access |
| Map controls | togglemap plus native map zoom, pan, follow and mark commands | Existing automap only; exploration icons/travel redesign are outside #149 |
| Other/native groups | menu_save, menu_load, native menu/screenshots and multiplayer/Strife compatibility rows | Native menus retained; no claim that Doom/Strife-specific gameplay exists |

The default catalogue is assets/generators/controls_catalog.json. Generated
DEFBINDS loads before INI, which remains authoritative. The launcher supplies
its generated preset only when build/gzdoom.ini does not yet exist. Direct
external launches with new configs may retain engine conflicting defaults;
use the explicit native **Defaults** action to apply Caelum's full preset.
That action keeps native confirmation, runs resetb2defaults and applies:
Tab Journal, M automap, B Seal, R reload/charge, F block/sweep/aim, T Tarot,
Y time skip. No defaults are assigned to racial/class abilities. It removes
M's map-only mark assignment so M also closes the full-screen automap. Marking
remains remappable, without an invented replacement key. Reset changes controls
only; unrelated preferences remain untouched. Startup/load never reapply reset.
The empty legacy KEYCONF section continues importing old normal/double bindings.

Hints use {bind:command} tokens resolved locally before wrapping/drawing. All
normal keys are listed with native NameAllKeys, or localized Unbound/Sin asignar.
Rebinding updates the next presentation, including introduction, Journal,
crafting, dialogue and notifications. GZDoom's ZScript API exposes Bindings and
AutomapBindings, not DoubleBindings: native double bindings are preserved and
executed by the engine, but are not advertised by this hint API. Exact native
command bindings are supported in live panels; compound console aliases retain
their native gameplay dispatch without being interpreted as panel shortcuts.

Visual buttons and native navigation invoke contextual actions without reinterpreting
synthetic scans as physical bindings. Live panels own input while open. Fixed arrows/Enter/Escape/Q and displayed
panel edit shortcuts remain contextual controls. Journal/time remaps are
recognized when native dispatch delivers their keys, including F-keys and
middle mouse. The modal time-skip panel takes precedence over Journal toggling.
Native Back (Mouse4 and mapped controller navigation buttons) and native menu
navigation retain precedence; physical scans cannot be reconstructed from those
ambiguous menu actions. Untranslated controller buttons such as Pad_Y reach the
existing handler. No new controller UI or hardware coverage is claimed.
Opening/closing Journal retains refresh/crafting/rest cleanup; input releases
remain governed by the existing native menu path. Gameplay slot commands use
native dispatch before queuing a single existing equipment event, so aliases
and double-bind actions are not swallowed by a global key interceptor.

Evidence: assets/validation_5214/RESULTS.md; CA149-01 accepted by the author on 2026-10-12.

## Saved cosmetics and native preview - 5.2.13 / #148

The native creator includes Appearance after Height. It offers three skin/fur
tones per race and wolf, bear, puma or jaguar form for Beast Men. Caelith use
red/green/blue; humans and goblins use natural skin tones; beast tones remain
within the selected animal's natural palette. These are cosmetic choices.
Humans, goblins and Caelith also offer four faces and four hairstyles for each
sex: short/long straight and short/long curly. All three share black, brown,
blonde, redhead, gray and white hair colors.

Options > Player Setup > Appearance edits tone, Beast Man form where applicable,
and humanoid face/hairstyle/hair color in an existing game. Race, sex, height,
professions, personality, allocations, equipment
and resources remain authoritative saved gameplay data. Back/Escape cancels;
Confirm/Enter commits once against the profile revision. Loading or replacing
the pawn invalidates the editor. Global skin/color/new-character defaults never
replace a committed profile. AppearanceRevision 2 initializes missing face,
hairstyle and hair color to option 0 once. Revision-1 saves keep their tone/form;
pre-appearance saves also initialize tone/form 0. Subsequent binds/copies preserve
all selections. The edit serial rejects stale confirmations independently of
the schema revision.

The preview uses native GetSpriteTexture and the same modular world sprite,
rotation and physical-height scale as the saved character. It is a UI object,
not an actor: stepping its visual states executes no gameplay actions or sounds.
Arrow keys and clickable controls select options; PageUp/PageDown rotate;
Backspace switches standing/walking. Sex/height/summary also show the preview.

First-person bare hands follow saved skin/fur. An owned, equipped Hands-slot
armor item selects the existing glove art; broken gloves remain worn, while
boxed/unequipped items do not supply gloves. Giant gauntlets keep their own art.
Modular weapon/shield layers, pivots, timings, ammunition and attack rules remain
unchanged. Corpses snapshot their appearance independently at death. Player
pain/breathing sounds remain automatic by saved sex; no voice selector or new
animal recordings are introduced. Asset coverage and limitations: ASSETS.

This supersedes the appearance deferral in the historical #147 matrix below.
Evidence: assets/validation_5213/RESULTS.md. Author check CA148-01 passed on 2026-10-12.

## Bull charge, resident tools and personality - 5.2.12 / #195

This section supersedes the doubled bull charge mass, old charge speed/burst,
resident melee loadouts and unassigned personalities in historical sections.
All other #194 collision energy and #188 Toughness rules remain authoritative.

The final charge cap is **10 m/s** (9.142857 MU/tic). Acceleration from rest is
linear **10 m/s^2**, reaching the cap after 35 simulation tics. Neither Agility
nor a class multiplier scales that cap again. Native floor friction changes
post-tic velocity; actual displacement is the speed measurement. Health,
temperature and elemental movement impairments may reduce motion below the cap.
The bull starts within its existing acquisition range and sight, keeps following
the moving target, and stops at contact, loss of a valid target/sight, exhausted
Air, Pain, binding or another physical interruption. MAP01 retains its 18-tic
windup and two-second encounter grace. The horn attack remains separate from
the collision and pays its existing natural-attack cost. Running pays its
existing biological-mass Air cost. No blanket invulnerability is added.

Collision mass is natural mass plus actual carried load, with charge multiplier
1. The healthy unloaded bull is 900 kg. The following historical horizontal
formula was replaced by the 5.2.19 / #211 landing-capacity contract above:

    f = clamp(JumpVelocity(natural, total, Agility) / JumpVelocity(natural, total, 0) - 1, 0, 0.5)
    retainedEnergy = receivedEnergy * (1 - f)^2

The former numerator included health and elemental biological impairment. At Agility
20, healthy and unladen, f = 0.2263767773 and retained energy = 0.5984928906 E.
This does not reduce the other body's energy or increase Toughness. Existing
floor/crushing absorption remains separate. The shared pair snapshots cushioning
before either recipient can interrupt the charge through Pain or death.
Natural Toughness is 900 * Type3(20) = **1353.6 physical / 676.8 direct magical**;
sustained burn/poison/disease keep their #188 status-duration rule. The bull has
no cutting or fire tool with which to escape bolas.

Each anchored mansion resident owns one T1 Pickaxe, one T1 utility staff and
exactly one bolas item. Rulo additionally owns a T1 XL War Axe; Ronnie a T1 M
Sword. Argento and Caella use their T1 M Pickaxes in melee. Sizes follow the
resident's existing armor body size. Costs, mass, durability, damage and range
come from the existing item catalogue; nothing is copied from player gifts.

| Resident | Natural kg | New owned tools kg | Initial collision kg, including armor |
| --- | ---: | ---: | ---: |
| Rulo | 200 | 55.527 | 315.527 |
| Ronnie | 140 | 23.018 | 183.018 |
| Argento | 120 | 17.018 | 147.018 |
| Caella | 80 | 17.018 | 102.018 |

Selection prioritizes bolas while the bull is free, then ice while unfrozen,
then damage. Recover the same reachable dropped bolas; there is no replacement
on destruction. Throw preparation, Air, spread, native flight, five-second
binding, repeated-hit behavior, strength expiry, cutting and fire destruction
reuse the player service. Thrown/bound items cease contributing to carried mass.
Ice uses the existing cone, Anima per real tic, contact wear and signed heat;
leaving range/sight ends emission. All resident fire attacks against the bull
are excluded throughout the encounter. Argento's Fire essence secondary remains
Light/Dazzle. This restriction does not change player fire or other NPC fights.

Rulo/Ronnie cycle primary/secondary normal attacks and primary/secondary charged
attacks. Charging takes the existing two-second base scaled by Dexterity, then
the complete normal weapon cycle follows sequentially. A ready charge has its
existing three-second window. Movement is stopped during preparation/cycle;
Pain, control, downing, item loss/breakage and encounter end cancel the action.
Air and thermal work are paid at release, including misses; charged damage and
Air are x2. Anatomy, critical chance, penetration, push, successful-hit adrenaline
and wear use the common combat/item rules. Broken or unavailable weapons cannot
fall back to the old unowned melee action. Preparations, item references, wear
and binding graphs are serialized natively.

| Resident / MAP02 prisoner | Temperament / way of acting / behavior / ideology | Magical power |
| --- | --- | ---: |
| Rulo / Santos Barrera | Aggressive / Instinctive / Rebellious / Liberal [0,0,0,0] | x1 |
| Ronnie / Rufino Acosta | Normal / Calculating / Disciplined / Center [1,2,2,1] | x2.8125 |
| Argento / Leandro Farias | Patient / Normal / Disciplined / Conservative [2,1,2,2] | x2.8125 |
| Caella / Leonor Benitez | Normal / Calculating / Rebellious / Liberal [1,2,0,0] | x1.875 |

All #192 effects are functional: magical damage/push/heat, critical chance,
adrenaline gain, evasion, offensive penetration and magical equipped absorption.
Costs, range, control duration and Box capacity are not magical power. Prisoners
receive these profiles but no new equipment. Unassigned actors keep no profile
and therefore no new bonus. Revision 1 initializes only the approved profiles
and mansion tools on old saves without healing/replenishing initialized objects;
an old active charge loses x2 mass and is capped before gameplay resumes.

Native evidence and limitations: assets/validation_5212/RESULTS.md. The author
accepted CA195-01 on 2026-10-11 without qualifications, separately from agent checks.

## Collision energy and contact area - 5.2.11 / #194

This contract supersedes the historical maximum-Health/EquivalentTics collision
severity, percentage ceiling damage, resting-weight formula and cannon armor
bypass described in earlier release sections. Momentum/restitution, collision
detection and existing defense applicability remain separate from severity.
The historical charge exception is superseded by the #195 section above.

Convert native MU/tic to m/s with 32 MU/m and 35 tics/s. For pre-contact normal
closing speed `v = max(0, dot(v1-v2,n))` and collision masses in kg:

    mu = m1*m2/(m1+m2)
    E = 0.5*mu*v*v
    rawDamageToEachEligibleBody = E joules = E HP

Both bodies receive the SAME raw severity, not half each. This is the author's
damage rule, not a claim of twice the physical energy dissipation. Swapping
initiator or adding a common velocity offset leaves E unchanged. Tangential
motion contributes no normal energy. Against fixed walls/floors, rooted scenery
and anchored gates, use `mu = movingMass`. Gate material mass stays finite for
structural Toughness. Restitution changes velocity response only. No extra x10,
maximum-Health scaling or balance cap applies. Raw fractional values remain
double precision through mitigation; final HP damage rounds once.

Each receiver uses its own contact-area-weighted anatomy and regional armor:
`sum(E_afterCushion * areaFraction * vulnerability * (1-armorFraction))`, followed
by the #188 physical Toughness subtraction ONCE. Armor wear is computed from
the same pre-wear regional defenses and committed after all regions. A shared
piece covering several regions cannot break partway through the event and
change the remaining regions' protection. Existing physical defense, innate
defense, acrobatic buckler and lucidity rules retain their applicability.
**Body contacts ignore offensive ideology. Cannonballs have no armor
penetration**, per the author's final amendment: equipped armor absorbs normally.
Their high energy and ordinary final Toughness mitigation remain unchanged.

The deterministic geometry approximation is the receiver's dominant native
collision-box face, clipped by the source's projected native bounds and actual
height (including crouching). The finite polygon is transformed into the
receiver's local forward/lateral/height coordinates and clipped to authored
anatomical boxes. Physical polygon areas are measured in m², with authored
region priority removing overlap before the next region. Humanoid lateral
bands mirror; directional animals keep front/back orientation. Gate and ram
proxies use the complete logical face, independent of which proxy fires first.
Known floor/top contacts use horizontal faces; unknown/zero-area contacts use
neutral vulnerability x1 and applicable innate defense, without a head critical.
This is a box-face approximation, not a mesh/skin or deformable-body solver.

Eligible biological cushioning reduces the recipient's assigned energy by
`(retainedDeltaSpeed / rawDeltaSpeed)^2`. Landing subtracts the existing
biological absorption speed once. Walking/running/crouching absorption remains
limited to walls and previously stationary scenery; #339 additionally permits
wall cushioning during a confirmed voluntary jump. Incoming cannonballs and
rams receive no ordinary running/landing allowance. Existing active acrobatic
defense stays separate. Collision mass includes existing load/charge modifiers;
#188 biological Toughness continues to use natural body mass.

Player/NPC contacts capture both masses and anatomical patches before damage
to either body. Walls/scenery without health receive no HP damage; the living
participant still does. Rams retain their explicit self-reaction HP exception;
their target receives damage. Cannon disposal remains its spent-projectile
lifecycle. Shared contact latches, gate strike serials and projectile spent
state prevent duplicate passive/proxy/sweep callbacks. Save/load retains
contacts and pending work; separation flushes outstanding work once.

The #311 / 5.5.2 audit corrects a parameter-shadowing defect in that latch:
release distance is the two radii plus one quarter of the smaller reference
body height plus the existing 2-MU margin. Five genuinely separated tics or
five tics without collision callbacks rearm the pair. A zero stored distance
previously expired an otherwise refreshed contact after five updates.
`ReleaseDistanceRevision=1` repairs old zero-distance edges locally, before
either participant updates separation. It preserves the shared object, pending
energy/geometry and timestamps, resets the invalid geometric separation count,
and keeps valid positive legacy distances. Repeated migration is inert. No
global actor scan, new damage formula or anatomy approximation is introduced.
Keep original saves and their package for rollback; validation_552 records the
native upgrade and original-runtime rollback separately from author acceptance.

### Continuous pressure, static load and crushing ceilings

Moving-body pressure accumulates `deltaE = 0.5 * impulseSI * closingSpeedSI`
once per unique tic after the initial strike. Each sample captures recipient
cushioning and contact-area distribution; energy-weighted regional fractions
preserve earlier samples when contact changes. At the existing 35-tic interval
(or separation), apply each receiver's accumulated energy, regional armor and
final Toughness once. Resting contact alone adds no motion work. This is work
from inelastic impulses, not replay of the initial strike each tic.

The author also requires damage under an immobile supported load and delegated
the internal compression parameter. Use slow virtual creep **0.1 mm/s** on
`excessKg = max(0, supportedKg + ownLoadKg - carryingCapacityKg)`:
`workPerSecond = excessKg * 9.81 * 0.0001` J. This explicit simulation
approximation is not a universal empirical tissue constant; it causes no visible
displacement. Preserve existing support/stack sharing, carrying-capacity and
first-contact rules. Accumulate fractional work for 35 tics, or flush on release,
then subtract Toughness once and round. As before, static weight and native
ceiling pressure do not gain regional armor/shield coverage or Adrenaline.

A crusher is a solid stone block spanning its footprint and original ceiling
down to its final floor clearance, at existing density **2700 kg/m³**. Its force
is mass times **9.81 m/s²**, without extra motor force. MAP08's four 64-MU panels
form a 4 × 4 m footprint; 384 MU down to 8 MU gives 11.75 m thickness and
**507600 kg**. The native motion speed and 8-MU clearance remain unchanged.
At actual crushing callbacks, work is force times attempted descent since the
last native pulse, even when GZDoom restores a blocked ceiling plane. First
contact counts one tic, subsequent continuous pulses use elapsed tics; same-tic
panel/callback repeats add zero. The old args[0] damage percentage is reserved
and ignored. Unknown native crushers derive footprint/stroke from their native
sector and ceiling thinker. Special native telefrag sentinels remain separate.

MAP02 revision 5 / #323 retains each authored crusher's 128x128-MU footprint.
Finalizing its sector after corridor construction prevents the western refuge
from merging trap 43921 into the shared district ceiling. Native speed, stroke,
density, pressure and one-shot activation are unchanged. This is a geometry
correction, separate from #312's damage audit. Visited revision-4 snapshots need
the archived geometry via -LegacyMap02Revision4; that reversible recovery mode
keeps the original defect. The corrected geometry requires a fresh MAP02 visit.

Additive saved contact/work fields preserve active state. Weight EnergyRevision
1 discards legacy percentage carry once; it cannot reinterpret it as joules.
No actor class or state sequence is removed. Existing original save/package
pairs remain the rollback baseline; native current-version save/load and a
5.2.10-to-5.2.11 contact/weight migration are tested.

The #312 / 5.5.3 completion closes a saved moving-work sample even when its
other actor has been destroyed; the surviving receiver uses the captured mass
and geometry. The shared balance is consumed before delivery, so the other list
cannot replay it. Static weight closes its current interval when a living body
loses support, becomes non-solid/noclip or is parked as a house resident. A dead
receiver discards that interval; revival cannot charge it later. Legacy
EnergyRevision=0 carry is still discarded, never reinterpreted as joules.

Native ceiling pressure now samples the local ceiling's downward attempted
steps once per tic. A pause contributes zero; blocked-plane restoration still
counts the attempted movement. First contact remains one tic, the existing
four-tic continuity window and same-tic panel guard remain, and a source change
starts a fresh pulse, including a brief visit to another source before returning.
Panels belonging to one authored trap remain the same source. The native callback
reconciles the current tic's sample when Actor.Tick has resumed motion after
Inventory.Tick. SamplingRevision=1, FirstSampleTick, LastSampleTick,
PendingCompressionMeters, LastSampleMeters and SourceInterrupted are additive
saved fields. New saves preserve the
unfinished sample. An older save cannot reconstruct past pauses: only unrecorded
tics before its first sample retain the former current-speed approximation for
that first interval. Migration is idempotent; retain original save/runtime pairs
for rollback. No global actor search is added by the sampler.

### Reference values and evidence

| Pre-defense contact | Raw joules / HP to each eligible body |
| --- | ---: |
| 200 kg vs 70 kg, 8 m/s relative normal | 1659.259259 |
| 200 kg vs 70 kg, 16 m/s | 6637.037037 |
| 200 kg vs 200 kg, 8 m/s | 3200 |
| 70 kg vs 70 kg, 8 m/s | 1120 |
| 200 kg vs anchored wall/gate, 8 m/s | 6400 |
| 4.3 kg cannonball vs free 200 kg, 500 m/s | 526186.979931 |
| Same cannonball vs anchored gate | 537500 |

Common/reinforced/armored gates retain 10/20/30% structural absorption and
finite-mass reductions 935/2015/5720 HP. A frontal 500 m/s cannon strike therefore
causes 482815/427985/370530 final HP, with no armor penetration or new multiplier.
The area fixture 75% at x1 plus 25% at x2 yields x1.25, or 125 before defenses
from 100 J. Numeric, real native-motion, pressure and save/load evidence is in
`assets/validation_5211/RESULTS.md`; the author accepted CA194-01 on 2026-10-11
without qualifications. HISTORY records the confirmation and originating release.

## Personality, magical power and ranged penetration - 5.2.10 / #192

The creator adds four independent choices after attribute allocation, before
confirmation. Each has bilingual descriptions, mouse/keyboard navigation,
summary and session-draft restoration. Existing race/profession/sex/height and
allocation budgets remain authoritative. The legacy in-world creator uses the
same choices. The following factors modify derived effects, not primary stats.

| Layer | Choice (Spanish) | Effect |
| --- | --- | --- |
| Temperament | Aggressive (Agresivo) | Combat adrenaline gain x1.5 |
| Temperament | Normal | Adrenaline gain x1.25; magical power x1.25 |
| Temperament | Patient (Paciente) | Magical power x1.5 |
| Way of acting | Instinctive (Instintiva) | Physical and magical critical chance x1.5 |
| Way of acting | Normal | Both critical chances x1.25; magical power x1.25 |
| Way of acting | Calculating (Calculadora) | Magical power x1.5 |
| Behavior | Rebellious (Rebelde) | Evasion chance x1.5 |
| Behavior | Normal | Evasion chance x1.25; magical power x1.25 |
| Behavior | Disciplined (Disciplinado) | Magical power x1.5 |
| Ideology | Liberal | +25 percentage points armor/shield penetration |
| Ideology | Center (Centro) | +12.5 points penetration; magical equipped absorption x1.125 |
| Ideology | Conservative (Conservador) | Magical equipped absorption x1.25 |

The author's 2026-10-11 clarification replaces the issue's original damage-only
wording: magical POWER scales outgoing damage, push and thermal energy once.
The first three focused choices multiply to 3.375; three Normals to 1.953125.
Intelligence scaling, weapon tier, charge and element remain separate. Utility
stream watts and its total thermal budget receive the same personality factor;
NPC-authored stream budgets are unchanged. Costs, range, duration/control and
Box capacity receive no personality multiplier. Critical factors modify the
complete chance before the existing final cap, never critical damage. Evasion
does not increase speed; adrenaline gain does not increase resource capacity.

For each equipped defense layer separately:
`P=clamp(existingLayerPenetration+ideologyPenetration,0,1)` and
`effectiveAbsorption=clamp(baseAbsorption*defenderFactor*(1-P),0,1)`.
The defensive factor applies only to magical absorption; physical uses 1.
The final cap follows both modifiers: a nominal 100% shield x1.25 against
Liberal retains 93.75% absorption. Innate defense and Toughness are outside
these modifiers. Shield then anatomy/critical, armor/innate and #188 R remain
sequential, retaining fractions until final HP rounding. Equipment wear uses
its actually absorbed portion even when R cancels remaining HP loss.

Longbow, crossbow, carbine and shotgun receive NO offensive ideology
penetration against armor OR shields, at every tier and for all ideologies.
The author's 2026-10-11 amendment defines these equipped-armor-only values:

| Weapon | T1 | T2 | T3 |
| --- | --- | --- | --- |
| Longbow | 20% | 30% | 40% |
| Crossbow | 40% | 50% | 60% |
| Carbine | 70% | 80% | 90% |
| Shotgun | 60% | 70% | 80% |

Multiply equipped absorption by `1-bypass`: 35% armor becomes 28%, 21% and
10.5% against T1 longbow, crossbow and carbine respectively. No Liberal/Center
addition applies. Shields retain their absorption, including normal defensive
magical ideology bonuses. Innate defense, R, base damage/scaling are unchanged.
CA192-02 passed author acceptance on 2026-10-11 without qualifications. Projectile ownership and
ideology are captured at launch, including javelins; changing the held weapon
cannot change a flying attack. Channel attacks retain their own identity.
The soldier's native shield uses the same penetration and fractional remainder.
Existing magical-shield reflection and electrical-channel block bypass remain;
thermal transmission filters/environmental resistance are separate from the
HP absorption modifiers and retain their existing values.

The bell fires **12 independent projectiles**, preserving T1 base damage 50
per projectile, tiers, spread, individual critical/payload data, charge and
100 base Anima per cast. There is no division by 12; each hit separately passes
through defenses and R/2. A native impact prepares projectile damage and wear
once before defenses, suppressing the duplicate DoSpecialDamage preparation
inside the final native damage call. Explosion budgets stay separate; each
recipient restores the transient guard even after a rejected/zero-damage hit.
Explosive callbacks retain their prepared-damage weapon wear independently of
the supplied blast HP budget; CADEV02 allied immunity remains in force.

Personality schema revision 1 resides in the authoritative character profile
and travels/copies with it. On old saves the author explicitly chooses
Normal/Normal/Normal/Center; migration recalculates once without refilling
resources. Repeated equip/recalculation/load does not compound factors. Preserve
an untouched old save and matching package for reversible rollback; newly
written saves are not promised to load on the older executable package.

Native matrices, save upgrade/reload/rollback/travel, bilingual creator captures
and T1/T2/T3 warrior/mage comparisons: assets/validation_529/RESULTS.md. The T2
comparison uses a documented balanced 39-card fixture (+50% general attributes)
and is not an additional balance decision. CA192-01 passed author acceptance on 2026-10-11, without qualifications.

## Mass-based Toughness and sustained resistance - 5.2.8 / #188

This contract supersedes the maximum-Health subtraction, armor-last ordering,
per-region Toughness/HP rounding and NPC DOT asymmetry described under #52 and
the earlier impact/gate examples. Equipment absorption values, anatomical
grades, kinetic severity, thermal environmental resistance and pain/lucidity
curves retain their existing definitions.

For effective Toughness N (including equipment bonuses, without an upper cap):
`B=(N*N+25*N)/125`, `M3=1+7*B/100`, `R=naturalMassKg*M3`.
Use the player's derived biological BaseMass or the NPC's natural actor Mass;
equipment, carried load, charge/artificial collision mass and maximum Health
do not contribute to R. There is no extra damage-unit factor of ten.
Existing shield absorption/coverage precedes anatomical/critical resolution
and additive innate/equipped armor. Subtract R from the resulting physical
damage, or R/2 from direct magical damage, clamp to zero, then round HP once.
Wear is calculated from the absorbed portion before Toughness, including hits
whose final HP damage is zero. Innate absorption does not wear equipment.
Do not round the shield remainder before the armor/Toughness stages.

Explosions retain reached-region sampling and regional armor wear. Sum the
precise post-armor regional components, subtract R or R/2 once for the hit,
then round once. Impacts/falls retain movement amortization, surface and
weighted anatomy/armor; convert severity to HP before subtracting physical R
once. The existing acrobatic buckler/gauntlet bonus doubles effective N.
Native crushing converts ordinary percentage pulses to precise HP before R;
forced native telefrag-level sentinels retain their engine semantics.
Existing bypasses such as drowning/resource depletion are unchanged.

The author applies the same rule to gates using structural mass: common,
reinforced and armored gates retain masses 550/650/1100 kg, N=25/50/75 and
10/20/30% armor. Their physical R values are 935/2015/5720 HP; magical R is
half. Existing structural maximum Health, gate revisions, duplicate-contact
protection and open/broken state are unchanged. Old hit-count tables below
are historical observations, not current #188 thresholds.

| Fixture | Physical R | Direct magical R |
| --- | ---: | ---: |
| 80 kg, N=0 | 80 | 40 |
| 80 kg, N=20 | 120.32 | 60.16 |
| 80 kg, N=100 | 640 | 320 |
| Bull, 900 kg, N=20 | 1353.6 | 676.8 |
| Zupay, 666 kg, N=33 | 1379.84544 | 689.92272 |

Burn, poison and disease use Type-1 response `S=1-B/100`. Positive S shortens
base duration by S without changing the original DPS. At N=100 the harmful
dose is absent from the first tick. Negative S heals at the original absolute
rate for `baseDuration*abs(S)`, capped at maximum Health without resurrection.
Sustained damage bypasses flat R and armor on players and supported NPCs.
Disease has shared processing support; this patch invents no disease source,
contagion, base duration or balance values. Cut/control effects retain their rules.
The environmental hypothermia/hyperthermia system remains separate and unchanged.

Each effect stores remaining unscaled duration, response, fractional HP and
pulse progress. Attribute changes preserve consumed normalized progress and
recompute the remaining duration; they do not restart an effect. Pending dose
adopts the new damage/healing sign; immunity clears it. Pulses remain one
second apart to preserve existing pain processing, with a proportional final
pulse for subsecond effects. Fractional HP survives reapplication; no integer
minimum is imposed per tic. Stronger/equal-longer source replacement remains.
Burn/poison visual clocks are independent from the health dose; thermal energy
remains independent too. Projectile status activation and DPS still derive
from actual direct HP lost, as explicitly requested by the author.

Status schema revision 1 imports only active legacy clocks/durations once.
Repeated save/load cannot scale duration again. Keep an untouched original
save and the previous source/package for rollback; downgrading a newly written
save is not promised. Native migration, repeated loading and rollback evidence,
plus controlled combat/status fixtures, are in assets/validation_528/RESULTS.md.
CA188-01 passed author acceptance on 2026-10-11 on the combined 5.2.9 build.
HISTORY records the confirmation and the #192 native impact correction.


## Native interactive menus - 5.2.7 / #189

All interactive in-game overlays are now native menus. CaelumLiveMenu owns
Journal pages, crafting, time skip, travel confirmation, rest, merchants,
calendar, equipment, chest inspection and the reachable legacy creator. Its
Drawer calls the existing presentation functions, retaining frames, icons,
portraits, cards, fonts and localized content. Passive HUD elements remain HUD.
The old EventHandler GUI capture is disabled, including flags from saved handlers.

The shared menu uses OnNoPause only while it owns input. Escape opens the native
pause menu; returning restores the same live screen. Standard settings, character
creation, introduction, exit and both card games keep their established pause
policy. NPC dialogue already ran without pause; this patch explicitly preserves
that behavior and guards native reply selection against orphan/stale releases.
Wrapped replies, More, Repeat, history return and Ronnie's contextual blocking
continue through the existing virtual MenuEvent and native reply mapping.

Left click activates the same enabled control on release; dragging away cancels.
Tabs, inventory categories/rows, calendar dates/entries and merchant rows are
clickable. Visible controls expose the existing keyboard actions. Mouse wheels
navigate lists/text/months; keyboard/controller shortcuts remain. The normal
creator also supports row selection and allocation/navigation buttons, preserving
edited allocations when the already-selected profile row is clicked.

During rest, free cursor movement selects controls. Hold the right button and
drag to orbit the existing camera; the left button activates controls. Drag distance is normalized
to a full-window-width revolution, then multiplied by native X/Y mouse
sensitivity and turn/look speed; native inversion preferences apply. Existing
pitch limits remain -5 to 60 degrees. Movement/action keys still stand up, and rest release
restores the original camera and furniture ownership. No balance rules change.

Menu/pointer state is transient: panel changes, console, nested-menu return,
actor/map replacement and save/load discard armed gestures. Keyboard hold latches
are separate from pointer reset so a repeated keydown cannot confirm abandonment
or repeat Tarot selection. CA184-01 and CA189-01 passed author acceptance on
2026-10-11 without qualifications; the confirmation is recorded in HISTORY.

## Mouse interaction contract - 5.2.6 / #184

Truco and Trucazo use the native menu pointer. Hover or click an unused visible
card to select it, then click Play; visible calls, responses, rules, save/load,
continue and forfeit/return use the same handlers and serial checks as keyboard.
A forfeit still requires its existing confirmation. Their world pause is unchanged.

Crafting has visible mode, filter, recipe, tier, size, batch and efficiency
controls, previous/next entry, detail scrolling, operation, cancel task, time
skip, x105 and Back buttons. The wheel over the list changes the entry; over
the blueprint it scrolls details. Nonapplicable controls are disabled; final
operations still revalidate real inventory, station, capacity and reservations.
Processing/component availability uses their native material preview rather
than requiring a direct equipment plan. Existing keyboard shortcuts remain.

Time skip exposes day/hour/minute selection, minus/plus, start, task estimate
and cancel/back. Active/confirmation-pending states disable edits. It keeps
its accepted forecast, interruption, resource and time policies and live world.
Keyboard and pointer call the same authoritative handlers.

Pointer actions require a press and release on the same enabled control and
state revision. Orphan releases, drags out and stale selections do not activate.
The Journal retains its 640x360 VirtualToRealCoords(...false,false) projection;
cards retain centered aspect-preserving 800x600 coordinates. Cursor ownership
is transient and never serialized. Native mouse preferences remain respected.

The author requested the separate #189 migration to native menu ownership,
retaining artwork and live simulation. NPC conversations must retain their already configured live world
with verified clickable responses; Truco/Trucazo retain pause. That follow-up
is not part of #184 behavior.

## Dialogue and localization source navigation - 5.2.5 / #185

Start at src/dialogues/INDEX.md and its authoritative index.json. Editable NPC
files live in npc/; shared services live in shared/. The generated runtime.usdf
is loaded by MAPINFO using its full path. Its tokens and global node order match
5.2.4, preserving IDs, conditions, choices, actions and saved conversation
indices. CAPALOMO is only an inactive compatibility include alias; do not load
both entry points or edit the generated runtime. The original is preserved in
archive/dialogues/5.2.4-CAPALOMO.usdf.

Use `python build_dialogue_index.py npc palomo --conversation 43630 --page loadout_root`
to locate one page and its text keys. `find TERM` searches every LANGUAGE key;
`read KEY` prints its English/default and Spanish source ranges. The main
localization index is src/localization/INDEX.md; index.json records hashes and
all definition ranges, including repeated sections. These commands reject stale
indexes. After editing sources, run `python build_dialogue_index.py build`, then
validate_project.py and build_dev.ps1. The history generator also resolves its
reviewed key/page references against the modular sources. No story, translation,
balance or gameplay behavior changes in #185.

## Onboarding and MAP02 initial supplies - 5.2.4 / #183

The author's 2026-10-11 decisions supersede the earlier equipment choices,
mandatory weapon craft, basement chest/mineral allowances, free exit bag,
departure ammunition removal and generic MAP02 material catalogue. Start new
test games: the author explicitly waived migration of pre-5.2.4 saves for this
patch. New-version save/load and native hub persistence remain required.

After race, the creator asks **What would you like to do?** / **¿Qué te gustaría
hacer?**: Fight, Explore, Socialize, Use magic. **Select profession** / **Seleccionar
profesión** then shows the resulting combination, including repeated classes.
The existing +4 family/+30 attribute budgets are recommended automatically and
remain editable. Each point alternates between the two components' dominant
families, determined from actual class contributions. Saturation tries the paired
family (Physical ↔ Technical, Social ↔ Mental), then the remaining pair; individual
points prefer the least-allocated eligible attribute within that family. Existing
caps remain. Structural choice changes recalculate recommendations; ordinary
back/forward and closing/reopening preserve manual edits. Reducing a family
returns any individual points that would exceed its new cap.

| Profession | T1 weapon | Shield | Complete armor |
| --- | --- | --- | --- |
| Warrior | Greatsword | Tower | Heavy |
| Mercenary | Sword | Teardrop | Medium |
| Cleric | Flail | Teardrop | Medium |
| Battle Mage | Giant gauntlets | Teardrop | Medium |
| Explorer | Longbow | Buckler | Light |
| Pilgrim | Fire bell | Buckler | Light |
| Investigator | Crossbow | Magical | Magical |
| Priest | Fire statuette | Buckler | Light |
| Arcanist | Fire book | Magical | Magical |
| Mage | Fire wand | Magical | Magical |

All size-sensitive pieces use the actual initial character size. Argento gives
the shield with the existing physical Tarot deck; Caella gives the necklace
with the utility staff; Ronnie gives the profession weapon with the Pickaxe;
Rulo gives all four armor pieces with the bolas. The necklace maximizes the
actual T1 catalogue bonus to the **first** component's dominant family, so class
order matters. Shared bonus data selects ruby/Physical, emerald/Technical,
topaz/Social or sapphire/Mental. Existing exact item IDs and one-time grants
prevent duplicate gifts or repair on replay. Capacity failures defer only an
unclaimed item. Rulo's first preparation occurs once; reopening cannot repair it.

Palomo offers only the five existing Seals, with bilingual ironic descriptions
of their real attribute/channel effects. The mandatory crafts are the sleeping
bag, selected Seal and large 5 L canteen. Ronnie teaches these recipes and their
dependencies. Bag (2 kg) and empty canteen (0.1 kg) each require **90% leather and
10% rope by empty mass** at a Workbench, using existing material/skill/time rules:
1,800 g leather + 200 g rope; 90 g leather + 10 g rope. A standalone Workbench can
open these recipes; missing component stations still block their processing.
Use Ronnie's workshop for bag/canteen and Caella's jewelry network or the complete
upstairs workshop for the Seal. Tutorial efficiency is 100% at every layer.
Duplicate bag/canteen crafting is rejected before payment. Native drop/pickup
copy hooks transfer the tracked crafted identity without replacing its contents.

The basement has one finite 2 kg gold node at the former supply position and no
supply chest or other mineral nodes. Ordinary Pickaxe extraction creates the
real gold pickups; depletion removes this node permanently. Other-world mineral
recovery is unchanged. Ronnie consumes the 2 kg once and issues only the raw
recipe graph inputs for the three crafts. Partial collection leaves a saved
remainder; replay/load cannot repay gold, restore ore or duplicate the reward.
The MAP01 Bull drops no leather. Completing all three crafts unlocks the next
lesson; a gifted weapon alone does not. Palomo remarks that exchanging 2 kg of
gold for some rope and leather was a swindle. Mansion food/water and established
social/magic/combat practices remain unchanged.

The Box now uses **20 + floor(10 × Type3Multiplier(Intelligence))** slots and that
same number as the content-weight divisor. Type3Multiplier(I) =
**1 + 7 × (I² + 25I) / 12,500**: 30 slots at I=0, 100 at I=100. The Box itself
weighs 0.001 kg empty as of #229. The shared growth function remains authoritative.

Departure requires the actual owned gifts and crafted utilities. It unequips
and stores those same objects, including the physical deck, in the Box. It
preserves IDs, wear, canteen water, captured Tarot, learned recipes and matching
arrows/bolts (including remaining magazine state). Explorer/Investigator use
the existing 24-round starter budget; grants are finite. There is no departure
refill. Four armor pieces, weapon, shield, necklace, Seal, three tools, deck, bag
and canteen occupy 14 slots, or 15 with an ammunition stack. Other expendable
supplies/materials/coins retain the existing removal policy. Capacity is checked
against attributes after unequipping so jewelry cannot overfill the Box.

MAP02's 30 ammunition allocations retain their positions and numeric quantities:
240 arrows + 120 bolts + 120 bullets + 120 cartridges become **360 arrows + 240
bolts**, still **600 rounds**. One cartridge becomes one bolt, independent of its
twelve pellets. This affects campaign supply allocations only; firearm recipes,
merchants and soldiers keep their existing ammunition.

The 39 MAP02 chests share a frozen initial-equipment budget, recorded when each
actual gift is created: one full repair of each armor piece, three of the
profession weapon, five of the Pickaxe and five of the utility staff, all at
100% efficiency and actual initial size. **Author correction:** bolas have no
repairable wear, so their allocation is materials for **five manufactured
replacement bolas**, using the existing recipe; combat behavior is unchanged.
The shared recipe functions provide ready components, avoiding extra recursive
rounding. Divide each material's total by 39 and assign the remainder to the
first chest indices. First successful collection freezes each chest's remainder;
capacity, repeats, revisits and save/load cannot multiply its allocation. The
historical 65-item catalogue is provenance, not the current chest budget.
Refuges include an armor workshop so light/magical T1 armor can actually be
repaired. The native repair selector lists owned armor as well as weapons.

Evidence and reproducible fixtures: assets/validation_524/RESULTS.md. Native and
static checks are agent verification; CA183-01 passed author acceptance on 2026-10-11 without qualifications.
NPC/localization source indexing is the separate follow-up #185.

## Allied Mandinga retaliation - 5.2.3 / #180

Accidental damage, including the existing racial-breath burn pulses, does not
make allied Mandingas retaliate against each other. This changes target
eligibility, not fire contact, damage, thermal energy or resource payment.
A Mandinga recognizes another Mandinga as allied only when native IsHostile
is false, both have the same TIDtoHate, and that order does not explicitly name
the other actor. Opposing native allegiance and distinct/explicit scripted hate
remain governed by the engine. No cross-faction relationship table is invented.

OkayToSwitchTarget rejects only that allied pair before delegating all other
cases to GZDoom. Before its normal Tick, each Mandinga discards allied target
and lastenemy references, including ones restored from earlier saves. This is
an idempotent check on existing references, not a new saved schema or actor
replacement: wounds, resources, burn effects and identities remain. The rule
is identical below and above the automatic 500-combatant threshold. Existing
valid enemies can still provoke retaliation. Evidence: assets/validation_523;
CA180-01 passed author acceptance on 2026-10-11 without qualifications.

## Time-skip processing - 5.2.2 / #178

Technical budgets are 8,192 live personal tics and 262,144 forecast tics per
native frame, previously 4,096 and 32,768. These are processing limits, never
campaign speed, recipe, food/water or recovery multipliers. Each live personal
tic still uses PrepareStep, SimulatePersonalTic and AfterStep; cancellation
returns to the engine between bounded batches, while danger, damage, resource,
task and exact calendar/siege boundaries retain their existing guards.

Before each live batch with an active crafting task, validate its native station
network. Inside that batch actors/geometry do not advance, so reuse the same
capabilities instead of repeatedly rebuilding the network and recipe preview.
Session, reach, combat and task-capability checks remain active. The next batch
forces a fresh scan; ordinary crafting and accelerated rest retain their prior
validation path. No new serialized cache, schema or migration is needed. Native
old active skips resume with their task, station, clock and inventory intact.
Evidence: assets/validation_522; CA178-01 passed author acceptance on 2026-10-11
without qualifications.

## Tutorial equipment, supplies and portable rest - 5.2.1 / #177

Author feedback on 2026-10-11 supersedes the earlier manual tutorial weapon
selection, six-slot supply dialogue, daily-only mansion food/water and fixed
MAP02 beds. Recipes, serving doses, body-mass scaling and combat balance stay
unchanged. The author explicitly distinguished unlimited food/water from the
one-time equipment material allowance.

- A newly granted Caella utility staff, Ronnie Pickaxe, personal tutorial weapon
  crafting output or Rulo bolas selects its exact native instance through the
  ordinary pickup/equipment path. Boxed or incompatible pieces remain subject
  to the existing restrictions. Recognizing an earlier grant does not reselect
  it. Rulo prepares the starter and its ammunition before selecting new bolas.
- During the Bull fight, walls and locked doors bound movement. Crossing the
  former inner rectangle or jumping does not relocate the fighter, Bull or
  helpers or disqualify a living trial opponent. Initial gathering/staging and
  the pre-hostility native autosave remain; this is not a map geometry change.
- Palomo's ranged option and both explanations name the existing double-barrel
  shotgun, using cartridges and twelve pellets, instead of the retired bow.
  Necklace selection follows the primary choices, including the optional plan.
- The basement supply chest uses the maze's inspect/collect/paginate interface.
  All raw materials in the existing 100%-efficiency recipe graph become visible
  as equipment choices are confirmed, before Ronnie's teaching. Later choices
  add only their own allowance. The saved limit/issued ledger remains the sole
  authority; prior withdrawals, consumed materials, gathering and reservations
  are not replenished or reset. Collection revalidates aim, ownership and carrying
  room; excess stays in the chest. Gathering remains optional and shares that
  allowance. Existing owned necklace/Seal exclusions and repair stock remain.
- MAP01 table food/water are unlimited. Empty provision slots refill after
  taking/consuming, and table-owned water containers refill after drinking.
  New water stock uses the existing large 5 L canteen; the established half-food,
  half-water slot targets remain. Existing deposited items and old ration stacks
  keep their identity; old rations become canteens only after their slot empties.
  Dining revision 2 applies this idempotently on old saves without accumulating
  missed-day stock. Other maps retain finite provisions. Forecast revision 1
  uses the same refill/volume rules and refreshes obsolete saved forecasts
  without consuming real inventory. Actual digestion and portion sizes remain.
- Palomo's final Box gift also grants the existing 2 kg sleeping bag once, or
  recognizes an owned bag. Insufficient capacity defers the grant. Gift revision
  2 retries an unclaimed bag, including earlier saves already past Palomo, but
  never replaces a subsequently lost/sold bag. The bag remains ordinary owned
  inventory, subject to its existing deployment, carrying and safe-rest rules;
  the mansion departure transaction preserves that same bag instance.
- MAP02 fixed beds retire at runtime on all layouts, with geometry and safe
  zones unchanged. An occupied saved bed remains until its rest/time-skip
  session releases it; unoccupied beds disappear and arrival preparation no
  longer respawns one. MAP01/MAP06 beds and portable sleeping bags remain.

Save compatibility retains existing inventory IDs, material ledgers and MAP02
map data. Chest preview source revision 1 preserves the original typed MAP02
reference and adds a nullable tutorial endpoint. Original saves/packages remain
the reversible migration path. Native/static evidence: assets/validation_521;
CA177-01 passed author acceptance on 2026-10-11 without qualifications.

## 5.2.0 - Authoritative character identity and native settings (#147)

The creator remains the only ordinary gameplay identity editor. It retains the
four playable races, two-stage profession selection and combined names, sex,
height and existing four-family/thirty-individual-point rules and descriptions.
On 2026-10-11 the author chose to retain an unconfirmed draft for the engine
session. Back, closing and reopening preserve that draft; confirmation consumes
it once. Restart starts a fresh draft. Editing a new draft never edits the
currently loaded character. Changing structural choices retains the existing
allocation-reset rule; merely navigating backward does not reset points.

`CaelumPersistentCharacterState` owns `IdentityProfile` and `IdentityAllocation`.
The player's existing `CharacterProfile`/`CharacterAllocation` references point
to those same objects. Gameplay readers retain their existing interface without
a competing copy. `CaelumCharacterIdentity.Profile(user)` is the shared read
interface for future appearance work; `VoiceSex(user)` resolves the saved voice
mapping. Neither reads a global native identity preference.

| Field / selector | Owner and writes | Reads / persistence |
| --- | --- | --- |
| Race, first/second class, sex, height | Creator draft until confirmation; then the character's identity profile | Attributes, derived size/mass, abilities, equipment fit, HUD/Journal, thermal/sleep systems and voice; saved inventory object |
| Four family and twelve individual bonuses | Creator allocation until confirmation; then identity allocation | Attribute calculations and saved profile; no additional grant on binding/load |
| Creator page, cursor and unconfirmed choices | Local UI `CaelumCreationDraft`, held by `CaelumCharacterSettings` | Creator only, for the current engine session; never a saved-character owner |
| `ca_newchar_*` user CVars | Creator confirmation writes the per-player transfer bridge; first spawn validates/consumes it | New, uncommitted characters only. Loaded/committed records reject it; loading clears readiness per player |
| Flat legacy profile/bonus fields | Compatibility mirror written by `PersistCharacterState` | Migration when only the travelling legacy record exists; not a second current authority |
| Native `PlayerClass` | MAPINFO's sole `CaelumPlayer` and explicit `StartGameDirect` class | Engine pawn type, never the combined profession; redundant selector hidden |
| Native gender | Retained engine preference, no custom gameplay reader | Hidden from stock setup; custom pain/breathing use saved sex |
| Native skin/color/color-set | Global engine preferences, not saved Caelum appearance choices | Selectors hidden; `NOSKIN` protects the existing body and its sound bank; color range remains 0,0 |
| World body / first-person appearance | Existing Domingo body and accepted modular equipment/hand resources | No new appearance catalogue, translations or preview; #148 remains responsible for those assets/options |
| Player sounds | Existing sex-based pain and breathing mapping, via the shared identity interface | Existing cues retained; inherited engine fallback cues are not a new authored voice catalogue |
| Native name/team | Global network preferences, explicitly identified as such in setup | Not a new character-name or narrative-identity field |
| Autoaim, vertical spread, pickup switching, run, bindings, camera/audio/UI settings | Native user preferences | Remain available; loading identity does not reset them |
| Legacy profile/allocation/debug commands | Explicit development console commands only | Existing diagnostic behavior retained at the author's request; no ordinary respec menu or new cosmetic permissions |

The exact source consumer inventory is generated in
`assets/validation_520/identity-audit.json`. The stock setup menu keeps native
name/team and handling preferences while removing class, gender, skin and color
selectors before native option search builds its entries. The old PlayerMenu
entry redirects to that same setup screen. No misleading Doom preview is shown.

Identity revision 1 is additive and idempotent. A native old save adopts its
actual live profile/allocation; a legacy travelling record without those
references reconstructs them from its saved flat fields. It does not recompute
attributes, refill resources, grant items or reset quests/Tarot. Native current
saves serialize shared references directly. Normal travel uses the same record.
Original save/package pairs remain the reversible rollback path; keep copies.
Existing flat fields and all old class/field names remain readable.

The author additionally requested removing the Caelum debug binding section and
placing ordinary actions in native categories. Abilities use the existing four
User1/User2/User3/User4 rows in Weapons, now labelled by their actual purpose;
flight stays in Actions; Journal is in Inventory; time skip is in Other.
Native inventory and automap rows remain available. KEYCONF keeps aliases and
accepted defaults, with no custom debug rows. An empty legacy KEYCONF section
imports old Caelum Bindings/DoubleBindings through GZDoom; its empty heading is
removed before menu search. Native config saving moves those assignments into
the general sections, retaining remaps and double bindings across restart.
Existing bindings are not cleared or reassigned. Full hint synchronization and
input/accessibility work in #149
and later issues remain separate.

Native/static evidence and fixture limits: `assets/validation_520/RESULTS.md`.
CA147-01 passed author acceptance on 2026-10-11 without qualifications.
Single-client evidence does not establish complete multiplayer support.

## 5.1.20 - Interior doors and peaceful city time skipping (#173)

Author request: add interior doors without changing MAP06's distribution; allow
time skip until the siege and stop it automatically when the siege begins.
Each of the 160 existing homes gains a hinged pair in its bedroom doorway and
another in its bathroom doorway (320 openings, 640 leaves). Exterior doors,
room cells, furniture and soldier routes are unchanged. Native door use, swing,
collision and anti-crushing behavior are shared with the existing doors.

INTERIORS.json's existing doorway rectangles determine centers, axes and leaf
positions; the generated CityData provides them to runtime placement. The port's
InteriorDoorRevision 1 is additive. Existing current-city saves gain missing
pairs once, retaining actors and geometry. A solid body occupying a closed-door
line delays that pair until it moves; retries are idempotent. Older MAP06 layouts
without #133 interiors remain unchanged, including active sieges.

Peaceful current MAP06 is an eligible time-skip location. Existing combat,
nearby threats, injury/effects, activity and resource checks still apply. A
home's furniture/table supplies belong to that home for automatic care; this
does not make distant city inventories available. Exterior waiting needs no
furniture and keeps existing carried supplies/sleeping-bag rules.

The siege date remains 15 November 1889 at 13:00. The shared calendar already
interrupts simulated time per tic; native #173 tests verify stopping exactly at
that boundary, rejecting restart and then deploying the ordinary full army.
Siege balance, counts, date and accepted performance policy are unchanged.
Post-siege and legacy locations retain their previous explicit safe zones.
Agent static/native evidence: assets/validation_5120. CA173-01 passed author
acceptance on 2026-10-10; the confirmation is recorded in HISTORY.

## 5.1.19 - Seen NPC information and replay (#172)

Author confirmed hiding informational replies only. The reviewed catalogue in
assets/dialogue_history.json identifies informational answers by source dialogue
and reply localization keys. Gameplay actions and the navigation needed to
reach them remain visible, including practice, supplies and equipment choices.
Information categories that lead to further choices remain navigation.

Selecting an informational answer through the native menu stores a stable key
for that speaker's actor class in the player's persistent record. On reopening,
read topics are hidden. Repeat dialogues at the bottom lists that speaker's
seen topics, also across different quest pages; selecting one reads its localized
answer without invoking USDF replies, grants, payments or mission effects.
Back returns to the ordinary conversation. Menus paginate to preserve access
to all choices and retain original native reply indices. Q/Escape, mouse,
number keys and controller navigation use the same selection mapping; Ronnie's
blocked action stays guarded after filtering/pagination.

History revision 1 is additive and initialized lazily for legacy saves; it never
infers unread history or rewinds quest flags. Existing native exclusions remain
authoritative. All NPC subclasses inherit the shared menu, including guards,
prisoners, Tarot encounters and reputation conversations. Action-only dialogues
have nothing to hide; no replay link appears until that speaker has history.
The 405 USDF page slots remain unchanged. Agent evidence: validation_5119;
CA172-01 passed author acceptance on 2026-10-10, recorded in HISTORY.

## Permanent MAP01 gifts and assisted checkpoint - 5.1.18 / #164

This section supersedes earlier MAP01 loan returns, compulsory non-weapon
selections, mandatory Channel, Palomo's deck delivery and scripted Bull retries.
It does not change the tools' #162/#163 rules, #89 recipe, #158 size selection,
#62 dummy exercises, finite supplies or the established resident support.

- Argento gives the complete physical 78-card Tarot deck when his branch starts.
  Physical possession permits Trucazo practice before the Magic Box; it unlocks
  no captured essence or power. Capture still needs the deck inside the owned Box.
- Caella gives one T1 bronze fire/ice utility staff at character acquisition size.
  Real fire and ice stream contacts on the shared dummy, Anima expenditure and
  natural recovery are the four required practice checks. Dummy contacts use the
  actual cone and wall visibility without wear or harmful status on the prop.
  The four existing runes still follow Earth/Air/Fire/Water, then a Caella turn-in.
  On 2026-10-10 the author chose optional Channel with an owned Seal, with no
  additional Seal gift. Existing Channel practice and its reserve remain optional.
- Ronnie gives the existing owned Pickaxe and unlocks its existing recipe. The
  gift is separate from actually crafting the weapon selected with Palomo.
- Rulo gives one recoverable bolas at character acquisition size when his branch
  starts. It follows the established preparation, throwing and recovery rules.
- Palomo gives the Magic Box only after Argento, Caella, Ronnie, Rulo and the Bull
  are complete. Palomo no longer gives or replaces the Tarot deck at the finale.

Only choosing and crafting the selected weapon is mandatory. Armor, Seal,
necklace and shield crafting remain optional even after confirmation. Explicit
skip/continue choices return to the plan or close it. The existing choices,
explanations, recipes, stations, recorded-size allowances and the #96 necklace
gift remain available. Reopening or skipping grants no extra materials or items.

Each tool's native ItemId records its one-time grant. A missing, sold or broken
piece is not recreated or repaired by reopening a conversation. Capacity can
postpone an unclaimed gift; ordinary personal/owned-Box limits apply. The deck
keeps its existing independent claim marker. Loadout revision 2 promotes actual
legacy wand, Seal and sword loans to permanent ownership without substituting
them. Gift revision 1 grants missing new tools according to existing branch-start
flags, including advanced/completed saves, without replay or a second deck/Box.
Item identity, size, wear, equipped/boxed location, choices, learned recipes,
reservations and issued stock survive. Original saves and the original package
remain the reversible migration path.

The four existing residents still gather and fight with their native attacks,
resources, downed behavior and victory recovery. Entering the prepared arena
records the fighter, party and locked doors, then requests native Autosave special
15. The existing two-second grace keeps the Bull non-hostile and all helpers
inactive; its saved remaining time resumes on manual load. The fighter reference
prevents another checkpoint request after loading or during combat. Native slot
rotation and the user's autosave settings remain authoritative: disabled
manual-trigger autosaves or zero slots prevent a file. No custom save slot or
scripted load/respawn is used. The checkpoint does not heal, refill or repair the
player or reset Bull health. Existing initial practice preparation and combat
ammunition support remain; combat resupply starts only after hostility begins.
As of #207, the MAP01 player remains alive at a minimum of 1 HP, including
the Bull fight. No retry/reset occurs; manual loading remains available. Legacy
pending-retry state is retired without triggering a reset. Other maps retain
normal player death.

Departure preserves all actual gifts and legacy loan instances alongside owned
crafted equipment. The separately approved removal of ammunition, materials,
coins, consumables and tutorial keys remains. A selection never creates its item.
Native/static evidence is maintained in assets/validation_5118. CA164-01 passed
author acceptance on 2026-10-10; the confirmation is recorded in HISTORY.

## Medikit terminology - 5.1.17 / #169

Health consumables display as **medikit**, **medium medikit**, **large medikit**
in English and **botiquín**, **botiquín mediano**, **botiquín grande** in Spanish,
as selected by the author. The default name denotes the existing small size.
Shared labels feed inventory details, trade and pickup notifications. The native
fallback pickup string is also updated. Existing CaelumLifePotion identifiers,
localization keys and saved inventory remain stable; #135 restoration, duration,
weight, prices, supplies and loot rules are unchanged. Anima potions and energy
drinks keep their names. Earlier historical references to health/life potions
refer to these same items.

## Recoverable bolas - 5.1.16 / #163

**Boleadora / Bolas** is a single-tier family-1 utility tool. Hold secondary
(AltFire) to spin; primary throws the actual equipped item. Throwing before one
simulation second is allowed. The author approved linear base spread from 60
to 6 degrees over 35 tics, capped thereafter, using the javelin's physical
accuracy, lucidity/elemental, crouch/running modifiers, velocity and native
gravity. A throw costs the javelin's 6 base Air with shared load/thermal cost
modifiers; it deals no direct damage and causes no per-use durability loss.
Release, switching, a different item, incapacitation and travel cancel preparation.
The author corrected the presentation: all three weights hang below the grip at
rest; held secondary spins at 3 Hz. This frequency does not shorten the
one-second accuracy preparation or change its cap.

A living eligible player/combat actor is restrained for at most 175 simulation
tics. Native invulnerability is respected; no blanket boss immunity is added.
Movement, ordinary attacks and new Tarot activation are blocked. Existing
physical controls remain independent. Native gravity continues; voluntary
flight motion is stopped. Original rope/ball sprites follow arms and legs,
scale with the body and leave the mouth free. Front fragments draw before the
body; the body occludes rear arcs using cosmetic depth offsets that follow the
local viewing direction. Repeated hits recover the incoming
piece without extending the existing timer. Death/removal releases an intact
piece. Misses and immune contacts drop the intact native pickup immediately,
without a five-second delay, auto-return or replacement ammunition.

Only three successful resolutions destroy the item: real fire contact,
completed cutting, or the single natural-expiry Strength roll. Fire projectiles,
classified fire damage, burn pulses, utility flame and demon flame use shared
contact classification without a Health-damage threshold. Light, ambient thermal
energy and ice alone do not burn ropes. The natural roll uses Strength itself,
clamped to 0..100: 0 never breaks, 50 has exactly 50% probability, and 100 or
more always breaks. There is no early Strength roll. An intact expiry drops
one recoverable item; destruction drops nothing and yields no salvage.

Reload starts a dedicated cut when the player possesses a usable slashing
weapon outside the Magic Box, even if another weapon is equipped. Capability
comes from positive primary/secondary slashing damage, not a list of names;
firearms and natural horns/claws do not qualify. The lightest qualifying
possessed weapon supplies weight to the shared physical-duration formula,
including Dexterity, gloves/carry capacity and thermal speed. The author's
confirmed base is 2 seconds for both player and NPC. Pain, sleep, lightning or
lucidity stun cancel progress; the bolas restriction itself does not. Players
must press Reload again after interruption; eligible NPCs retry automatically.
Cutting neither reloads nor consumes ammunition. Mandinga's existing machete
profile is represented by a revision-1 sidearm model; the soldier's existing
sword model remains authoritative even while holding a carbine. Bull and Zupay
have no qualifying sidearm. Broken or removed weapons cannot grant the escape.

A bound Mandinga or Zupay may direct its own fire breath onto the ropes because
the mouth is free. Actual paid breath contact destroys the ropes immediately,
bypassing self-hit filtering only for this escape. Existing #135 Anima cost,
reductions, regeneration, insufficient-resource and unrelated interruption
rules remain; no free escape, burn delay or cutting duration is added. The author
reconfirmed immediate escape after reporting apparently immune Mandingas. Each
actual rope burn now leaves a finite, body-following flame for the existing
12-tic elemental impact animation, independent of continued emission. This
visual adds no damage, burn status, heat or resource cost; repeated fire after
resolution cannot spawn another flash.
Resolution is guarded once, so fire, cut completion and expiry cannot duplicate
items or repeat the Strength roll. Unrelated stuns survive release.

The physical reference is Museo Regional de Magallanes **93.88.5**, a complete
three-piece example measuring **109 cm and 1.018 kg**. Its account also documents
metal fillings. MHNA2508 documents three raw-cowhide branches and wrapped balls.
The author chose bronze rather than the proposed iron: **800 g bronze + 218 g
cow leather at M and 100% efficiency**. This split is an author-approved design
allocation, not a historical measurement. The supported catalogue supplies
bronze ingot and leather; no stone resource/harvesting system is added. One
material unit is 0.001 kg; existing size and efficiency rounding scale both
components. The unified workbench recipe requires the forge, uses the normal
simple physical-tool work calculation, and produces one intact item. Binary
integrity value 1 is an inventory sentinel, not an extra wear/Health budget;
repair/dismantle tasks are excluded because no salvage recipe is authorized.

Sources:
- https://www.museodemagallanes.gob.cl/galeria/arma-de-caza-de-los-aborigenes-de-la-patagonia
- https://patrimonioargentino.cultura.gob.ar/index.php/Detail/objects/75674
- https://buenosaires.gob.ar/gcaba_historico/noticias/rebolear-se-ha-dicho

Type 22, catalogue 18 and recipe 133 append to existing IDs. Recipe-book revision
7 preserves learned recipes and initializes the bolas recipe locked. The same
native item is transferred into the flight/binding actor, then recovered or
destroyed; serialization retains preparation, timer, cut progress and identity.
Released input after a load cancels the saved preparation normally. Binding
visual revision 2 retains the two saved front actors and idempotently creates
two missing rear actors on update, preserving the item, timer and cut progress.
On forced player map departure, its restraint drops intact in the departing
map and releases that player; a hub retains NPC restraints with paused timers.
Keep the original save/package pair and save migration under a new filename
for reversible rollback. Native/static evidence is in assets/validation_5116.
Rulo's permanent grant and tutorial changes remain #164; author visual/handling
acceptance CA163-01 passed on 2026-10-10, distinct from isolated engine evidence.

## Utility staff and wand terminology - 5.1.15 / #162

**Bastón / Utility staff** is a separate family-1 tool beside the Pickaxe, with
one tier and a bronze tip. The author renamed the existing tiered elemental
staffs to **Varitas / Wands** on 2026-10-10. Their internal `STAFF` identifiers,
sixty magical variants and saved instances remain unchanged. Earlier release
entries use the terminology of their time; current controls use Wand.

Hold Fire for flame or AltFire for ice. Both use the approved demon-breath
geometry: 4 m / 128 MU contact range, a 60-degree cone, and 20 kW source power.
The author explicitly approved equal ice geometry/power magnitude. Fire applies
the existing T1 wand burn on contact without an extra direct Health hit; ice
applies the existing Freeze control and actual negative continuous thermal
energy. Duration/control strength and T1 burn/wear damage use the existing
attribute rules. Repeated fire contact retains the burn pulse clock.

Both signs reuse the shared thermal pipeline: four geometric source samples,
distance attenuation, wall visibility, the existing 35% radiative budget and
armor area retention exactly once. Therefore 20 kW is source power, not 20 kW
absorbed by each actor. Radiation extends beyond contact range without an
arbitrary cutoff; cooling/heating affects supported thermal bodies, including
the emitter. No projectile push or direct ice damage is added. Since 5.4.28,
demon breath shares geometry/contact calculations but heats only contact victims;
this wand's independently approved radiation remains unchanged.

Each mode costs 10 Anima per simulation second before existing wand cost
reductions, once per real tic. Natural regeneration continues. Primary wins
when both buttons are held. Release, insufficient Anima, immobilization, rest,
blocking, equipment/crafting/creation overlays, switching and death stop the
source and owned light/visuals. A paid fractional thermal interval settles on
stop; map unload settles it in the departure map. No pending heat travels to
the destination or returns as an orphan source in a hub. Reload does not charge
or change the tool's mode.

Mass, maximum durability, component types/quantities, size and efficiency follow
the Pickaxe: M is 8 kg and 10,000 durability; its recipe uses 5,600 handle units
and 2,400 T1 head units (bronze), with the same forge/workbench requirements.
No essence is required. The author approved the wand wear rule **once per
second of valid contact**, including ice: one point per 1,000 prepared T1 damage
plus the established probability for the remainder. Empty emission causes no
wear; multiple contacted actors do not multiply the cadence. Fractional contact
tics belong to the exact item and survive Box storage, drops and saves.

Type 21, catalogue 17 and recipe 132 are appended; Pickaxe recipe 131 is stable.
Recipe-book revision 6 preserves prior knowledge and initializes the new recipe
locked. Native equipment identity and existing tiered wands are not converted.
Crafting, repair and dismantling use normal equipment transactions. Keep the old
save/package pair; save the migrated game under a new name for reversible rollback.
Caella's permanent grant and the tutorial transition are explicitly owned by
#164; #162 supplies the tool and does not claim that progression is implemented.
Native/static evidence: assets/validation_5115; author visual/handling acceptance
CA162-01 passed on 2026-10-10; the author authorized merge and closure.

## Damage-flash lifetime across maps - 5.1.14 / #165

Damage feedback remains percentage-based, with the approved family colors,
18-tic fade and 0.40 maximum full-screen intensity. Shared evaluation rejects
future or expired map-local timestamps and caps malformed saved strength; new
hits accumulate only the valid remaining flash. Native travel clears the transient
flash rather than carrying a level.time timestamp to another map. Existing visual
revision 2 clears older saved flash state once; no Health, resource, position,
Tarot, damage or wounded-edge balance changes. Save a migrated game under a new
name and retain the original package/save pair for rollback.

## SI physics and attribute growth — 5.1.10 / #154

This section is the current contract. It supersedes the curve, gravity, movement,
jump and efficiency numbers in earlier release notes retained below. Those older
numeric examples describe their original release, not an alternative live rule.
The three new families are shared by player, NPC, gear-derived statistics, Tarot,
crafting, dialogue, Trucazo, the Box, combat, survival and thermal consumers.

For the effective attribute N, `B=(N*N+25*N)/125` percentage points. Types 1/2/3
have bonuses `B/3B/7B`; their multipliers are `1+bonus/100`. At N=100 these are
x2/x4/x8. Old Types 1/2/3/4 map to new Types 3/1/1/2, respectively; old Type 3
keeps its decreasing complement. Historical adapter method names remain for
save/API continuity. Attributes above 100 remain valid; probability caps,
integer truncation, base bonuses and operation order remain consumer-specific.

| N | B, percentage points | Type 2 bonus | Type 3 bonus |
| ---: | ---: | ---: | ---: |
| 0 | 0 | 0 | 0 |
| 1 | 0.208 | 0.624 | 1.456 |
| 10 | 2.8 | 8.4 | 19.6 |
| 25 | 10 | 30 | 70 |
| 50 | 30 | 90 | 210 |
| 75 | 60 | 180 | 420 |
| 100 | 100 | 300 | 700 |
| 150 | 210 | 630 | 1470 |

Health/Anima maxima, damage, push and precision use Type 3. Air/Adrenaline,
capacity, attack/cast speed, regeneration factors and the Constitution needs
divisor use Type 2. Critical/evasion/dialogue bonuses use Type 1. Toughness
now uses mass times Type 3 after defenses, half for direct magic (#188);
thermal resistance clamps B/100 to [0,1], whereas thermal thresholds use 1+B/100.
Resilience adaptation uses 1+B/100: at 100, +/-10 C at 2 C/world day, still five
days from the racial base. The Box uses `2+int((100+7B)/50)`, hence 4/18 slots
at Intelligence 0/100. Tarot modifies attributes before these curves.

Spatial/time constants are centralized in CaelumPhysicsUnits: 32 MU/m, 35 tics/s,
velocity `MU/tic*35/32`, acceleration `MU/tic²*1225/32`. Ordinary effective gravity
is 9.81 m/s², or 0.25626122449 MU/tic². GZDoom's ordinary level gravity 800 becomes
205.008979591837, once per map, through a serialized marker. Actor/sector gravity
modifiers and deliberate no-gravity states remain native. World/calendar time,
map geometry, body dimensions and projectile muzzle-speed data are not rescaled.

Unpenalized steady forward walk/run at Agility 0 is 4/8 m/s, multiplied by Type 2:
16/32 m/s at 100. #260 / 5.4.15 replaces the former exponential envelope with
constant ordinary acceleration: 3 simulation seconds per 100 kg of body plus
load to reach 100%. Native input/friction remain in control, with compensation
limited to the command's own thrust. See the current #260 movement contract above.
Existing load, health, survival, Air, elemental, shield and reload modifiers remain.
Foot journeys use steady walking speed: 14.4 km/h at Agility 0 and 57.6 at 100
before penalties, with the existing 16-hour walking / 8-hour sleeping schedule.
NPC native chase-step schedules and animal base speeds are preserved; a Speed
field is not a promise that an NPC moves that distance every tic. Folklore actors
reuse the shared walk reference, and saved bull charge speed is recalculated.

For biological mass mb, moved mass mt and effective Agility A:
`Ejump=800*(mb/80)^0.75*M3(A)` J;
`v=sqrt(2*Ejump/mt)` m/s; `JumpZ=v*32/35`; ideal rise `Ejump/(mt*g)`.
At 80 kg without load: A0 gives 800 J, JumpZ 4.088810, ideal rise 1.019368 m;
A100 gives 6400 J, JumpZ 11.564901, ideal rise 8.154944 m. Native discrete apex
is slightly higher (observed 1.083425/8.336096 m). Load enters mt once; there is
no second load multiplier on JumpZ. Retained state/elemental velocity factors
square into delivered energy. Immobilization still prevents jumping.
Thermal impulse uses the accepted native increase in vertical kinetic energy
once, not the old fixed 0.5 m reference, and adds no new resource debit.

Only fall damage's reference velocity threshold scales by sqrt(0.25626122449),
equivalently its squared-speed threshold by 0.25626122449. Biological landing
absorption uses the new jump contract. Wall/actor/environmental collision laws,
restitution, anatomy and material factors remain. Real total carried mass is
used in NPC collision inertia, including weapons and supplies; biological mass
still owns health scaling and thermal inertia. Local reduced gravity is not
cancelled by a second per-sector threshold adjustment.

| Projectile | Actual launch MU/tic | m/s | Flight and NPC aiming |
| --- | ---: | ---: | --- |
| Arrow / bolt | 60 | 65.625 | Native Actor gravity; class defaults 35/45 are overridden by the shared firing path |
| Carbine / shotgun pellet | 80 | 87.5 | Native Actor gravity; player aim remains manual |
| Javelin | 15 times sqrt(physical push multiplier) | 16.40625 times that factor | Native Actor gravity; retained Strength/body-mass launch equation |
| Cannon | 457.142857143 | 500 | FastProjectile integrates GetGravity once before movement |
| Elemental | Existing 15/20/40 or authored NPC speed | Converted with the same units | Authored straight/seeking behavior retained |

Soldiers and cannon crews solve a low ballistic arc at launch, toward the current
target center, with no target-motion prediction or homing. Six bounded Newton
corrections account for Actor's move-then-gravity versus FastProjectile's
gravity-then-move order. The existing angular dispersion is applied afterward.
No solution retains the previous direct-shot policy. Collision and range limits
remain native. This is a bounded launch calculation, not an every-tic AI solver;
no mass-siege performance improvement is claimed by this issue.
### Weapon dispersion — 5.4.1 / #259

Dispersion tier k gives a k–10k degree range, capped at k=7. The T1 bases are:

| Weapon family | Base dispersion tier |
| --- | --- |
| Magical staff/wand, book, carbine, longbow, crossbow | 1 |
| Statuette | 2 |
| Melee weapons in the existing physical catalogue | 3 |
| Bell, shotgun | 4 |
| Existing single-tier pickaxe, utility staff and bolas | 6 (unchanged base) |

`k = min(7, base + (weaponTier - 1) + lucidityPenalty)`.
The penalty is 0 at Lucidity >=50%, 1 at >=10% and <50%, and 2 below 10%.
Exactly 50% has no dispersion penalty; exactly 10% has only +1. Other Lucidity
state/stun boundaries retain their existing inclusive comparisons. A single-tier
tool always resolves weaponTier=1. Bolas retain the preparation interpolation
between their effective maximum and minimum; utility fire/ice stream geometry
is unchanged.

Physical/magical Type-3 precision divides the selected angular range afterward.
Crouch, ADS, running, elemental accuracy and each attack's existing sampling stay
in place. Weapon attacks no longer halve precision for low Lucidity. Natural
NPC claws, horns and unarmed attacks have no authored weapon category and retain
their previous probability rule; no new weapon identity is inferred for them.
The player's legacy LucidityAccuracyMultiplier field is recomputed to 1; no
saved attributes, inventory or schema change. Tier and current Lucidity are read
at release, so switching or loading cannot retain an obsolete spread cache.

Player melee, javelin, all four physical ranged weapons and four magical weapons,
resident weapon attacks/bolas, soldier sword/carbine and NPC staff/statuette
launches use the shared rule. NPC weapon projectiles keep their native speed,
target and elemental payload; dispersion changes their initial velocity only.
The book retains acquisition along the original aim and its guided trajectory.
For example, T3 staff at Insight 100 and Lucidity <10% uses 0.625–6.25 degrees;
T3 bell/shotgun at that Lucidity reaches the cap, 7–70 degrees before accuracy.

**#320 / 5.4.32 exception (author decision, 2026-10-17):** Mandinga fire and
Zupay stone projectiles use native direct aim at the current target when released.
They skip weapon dispersion at every Lucidity/precision value. This supersedes
#259 only for those two enemy families, including their existing subclasses;
it adds neither homing nor target-motion prediction. Other weapons, melee,
breath, accuracy-dependent rules, damage, Anima cost, speed and maximum range
remain unchanged. Previously launched projectiles retain their saved velocity;
future launches use the class policy without a save migration.

This supersedes #222's staff/statuette equality and the pre-#259 fixed assignments.
Their historical values remain in HISTORY and the corresponding issue evidence.

Muscular efficiency is `eta=min(0.99,0.25*M1((Agility+Dexterity)/2))`: average the
attributes first. It is 25% at 0/0, 32.5% at 0/100 and 50% at 100/100. Positive
work W costs W/eta metabolic joules and yields `Q=W*(1/eta-1)` heat. Existing
distance/action work budgets remain: 0.5025/1.005 J/kg/m for walking/running,
m*g*h for ascent, fixed weapon work, shot/reload work and swimming work rates.
Greatsword primary 300 J therefore gives 900/300 J heat at 25/50% efficiency;
the 80 kg A100 jump gives 6400 J heat at 50%, versus 2400 J for A0 at 25%.
More actions or metres per second still increase watts. Isometric pushing and
blocking retain their separate metabolic cost; braking never becomes cooling.
Basal heat, sweat, shivering, breathing, external magic and calendar exchange
are separate. Stopping produces no new effort heat and no post-effort tail.

Player balance revision 4 and NPC/gate growth revision 1 preserve each resource's
percentage during the one-time curve migration (author decision 2026-10-09).
Health rounds to the nearest native integer, keeping a living character at least
1 HP. Ordinary equipment recalculation still clamps without free healing. Air
recovery debt preserves its fraction. Legacy traveler records reconstruct old
maxima from the retained profile because they did not store maxima. Ownership,
attributes, quests, Tarot and accrued thermal exposure persist. A saved pending
spell recalculates its new cost once, retaining tier/charge and remaining cast
time without spending Anima during migration. Thermal revision
9 discards only an old in-progress reload's future budget and re-evaluates it;
already measured heat remains. World/projectile gravity revisions are separate
from growth revisions, so future curve changes cannot reapply gravity.
Rollback uses the untouched pre-upgrade save and matching old package; downgrading
a newly written save is not promised. Evidence is in assets/validation_5110;
native checks do not replace the author's outstanding tests in pending_test.txt.

## Shotgun follow-up: ownership, presentation and aim (#152)

A successful distinct-ammunition transfer uses native AttachToOwner (including
BecomeItem), so owned cartridges have no world-sector/blockmap presence or pickup
flag. A carried stack saved with those flags still set is normalized on its next
Tick, without changing amount, owner or Box placement. This is an idempotent
repair of an invalid native state, not a new serialized inventory schema.
Failed capacity checks leave the source available for a later attempt.

Alternate fire on any ranged weapon is edge-triggered like Zoom: holding it
keeps the resulting aim state; release/repress toggles again. Its transient latch
is independent of the Zoom latch and does not change melee/magic secondary actions.
Ready/open shotgun grips use one complete hand pair below the weapon, retaining
the accepted under-gun support hand without a second foreground copy. Loading
hands/cartridges remain foreground; aiming retains the canonical carbine hands.
The pickup atlas now uses the author-approved 6 cm world-height reference from
editable art data, accepted natively by the author on 2026-10-09. Inventory icon size, collision, ammunition
mass/price/count, damage, cadence and reload timing retain their accepted values.

Thermal review boundary: the author's test body is 200 kg plus 285.428 kg carried.
At native gravity 38.28125 m/s2, raising that mass by 8.25 m adds 459,924.068 J
of vertical-work heat before horizontal work/losses; its fixed-reference jump
adds 7,143.073 J. This follows two different approved calibrations and is not an
energy-equivalent comparison. Sweat already starts at positive exposure, inside
the Normal band; exposure is not body temperature and need not settle at zero.
Furred races have a different comfort value but no separate fur-water reservoir.
The author is considering metabolic-power budgets, including zero-net-work effort
and the jump boundary. No new thermal coefficients or changes are approved here.

## Elemental presentation and proportional damage feedback (#137)

This pass changes presentation only. Fire/light, water/ice, earth/poison,
air/lightning and quintessence share four-phase projectile materials between
player and NPC paths. Charged size, homing, multishot, explosion, speed, collision,
range and status rules retain their existing data. The Federal prisoner keeps
his air/electric alternation; the electric shot renders the same travelling ray
as the staff. The ray extends behind its collision origin. Arrows, bolts,
carbine bullets, shotgun pellets and ballistic javelins use original meshes;
MODELDEF momentum pitch does not change their physical velocity or gravity.
Javelin impact still uses its existing breakage/material recovery.
Domingo (including soldiers) and giant-rat deaths use repaired complete poses
under their existing sprite names. Death timing, actions and corpse behavior
are unchanged; the old damaged PNGs remain available for rollback. Original
Domingo art uses eight poses; the rat's seven source poses repeat the last corpse
over its last two timed states. Nine rat movement/pain border repairs preserve
their original source-relative anchors. All bull cuts were audited unchanged.

Attached burn, poison, frost and lightning art follows owner height and width,
keeps the central silhouette open, and ends on real status expiry/death/removal.
Demon breath's animated cone follows the authoritative mouth/direction and four
existing visibility samples. Its visuals emit no damage, contact or thermal
energy; those remain in CaelumDemonBreath. The existing mine burst reuses fire
material without changing its explosion or twenty-tic lifetime.

Fullbright materials remain visible without dynamic lights. Nearby effects use
named native lights. Native trail particles live nine tics; impact actors live
at most twelve. The existing whole-map living-combatant service controls cosmetic
density: below 500, detail distance is 1024 MU and trail interval two tics; at
500 or more, 512 MU and eight tics, with only the first breath segment retaining
its light. The electric ray does not add a separate dot trail. Projectile bodies
and all individual combat/resources/collision remain active. These are visual
settings, not new gameplay ranges or a claimed performance budget.

Player damage feedback measures actual post-defense Health loss / maximum Health.
The approved colors are physical/bleeding red, fire/heat orange, ice/cold cyan,
poison green and electricity violet; other unspecified types retain red.
Successive hits add their remaining visual intensity, with an 18-tic linear fade
and 0.40 alpha cap (alpha gain = 0.80 * Health fraction). A 50-point loss from
2000 maximum produces 0.02 alpha, identical to five from 200. Prevented damage
has no flash. Burn/poison share the existing DOT damage type while carrying only
a temporary presentation context; this does not modify defenses or damage.
The Doom absolute-point damage palette counter is cleared after damage handling.

The existing Health thresholds drive peripheral red gradients: <=50% uses 0.12
outer opacity; <=10% uses 0.30. Lucidity retains its own existing 50%/10%
thresholds and all accuracy/stun rules, with a stronger animated violet gradient
and cyan/magenta peripheral motion. HUD text/bars render afterward; camera angle,
aiming, controls and central visibility are unchanged. Feedback state belongs
to the affected player, including viewed-player HUDs. New cosmetic fields start
at zero in old saves; cosmetic revision 1 is applied idempotently without
resetting saved ages. Serialized classes/state indices and all gameplay fields
remain available, with native old-save/current-save/hub verification.

## Double-barrel shotgun and equipped-armor bypass (#136)

Playable ID 14 and catalogue/recipe ID 12 identify the two-handed side-by-side
shotgun at T1/T2/T3. In 5.2.10 the author requested shotgun terminology throughout
active code/resources: `CaelumShotgunSelectorWeapon`, shotgun frame labels and
retained `shotgun_legacy` art paths. Unused old constant/localization aliases and
the inert legacy magazine field are removed. Numeric IDs are unchanged. Fresh
test saves are authorized; old saves containing the retired selector class
must be reopened with their original package, not this renamed runtime.

One shot spends one cartridge and one carbine-equivalent Air cost, launching
12 independently colliding pellets. Each nominal pellet is one tenth of the
same-tier carbine damage; full pre-mitigation totals are 4320/6912/10800 before
shared modifiers. Differences of rounded cumulative pellet budgets preserve
the nearest integer total, including non-divisible values; zero stays zero.
Misses lose their share, and hits on multiple targets distribute one budget.
Critical, anatomy, Toughness, shields, push and successful-damage wear use the
existing projectile pipeline. Defenses resolve per pellet, so post-defense
damage need not equal 1.2 times a single carbine impact.

Capacity is two cartridges, one per barrel. A two-bit chamber mask persists;
ordinary shots fire right then left. Reload fills available chambers up to
the inventory's total quantity, without spending ammunition again. Empty,
single-cartridge and partial reloads use the same carbine five-second base and
Dexterity/movement modifiers. Interruption grants no cartridge. Fire costs the
same base 2 Air; reload retains the carbine's existing resource rules. Calibrated
firearm muscular heat, rather than the generic melee Air-to-heat conversion,
also applies. Mass (T1 12 kg), durability, critical chance, recipe components,
material quantities and manufacturing complexity copy the corresponding carbine.

Range is 30 m, half the carbine's 60 m. Current spread follows the 5.4.1/#259
weapon-dispersion contract above: shotgun base 4, carbine base 1, plus equipment
tier and Lucidity. The original equal 13–130-degree assignment and later equal
7–70-degree assignment are historical, superseded by #259. Damage, costs, range,
penetration and critical rules are unchanged by this spread revision.

| Weapon | Equipped armor bypass T1 / T2 / T3 |
| --- | --- |
| Longbow (#192 amendment) | 20% / 30% / 40% |
| Crossbow (#192 amendment) | 40% / 50% / 60% |
| Shotgun | 60% / 70% / 80% |
| Carbine | 70% / 80% / 90% |
| Cannon (#194) | 0%; normal armor absorption applies |

Defense is innate racial defense plus equipped defense times the retained
fraction. Toughness, armor reinforcement/vulnerability grades and shields
remain separate. Only the equipped absorption contributes to equipment wear.
Projectile metadata freezes the fired weapon's type/tier; changing equipment
in flight cannot change penetration. Player and NPC damage/contact solvers
share this rule, including armor's contribution to contact lucidity protection.

Shotgun cartridges are independent ammunition ID 6; arrow, bolt, bullet and
javelin IDs are unchanged. The original 0.003 kg placeholder is superseded by
the #313 complete-cartridge contract below: 0.045 kg shotgun and 0.040 kg carbine.
The shotgun base price still equals carbine cartridges. Armories receive 100
once, including an idempotent old-stock upgrade;
reopening does not replenish stock. MAP02 adds six 20-cartridge drops to previously
unassigned living enemy slots: 2/1/2/1 per section. Existing supplies and keys
remain assigned to the same enemies; map geometry is unchanged.

Shotgun revision 1 migrates pre-5.1.7 equipment, current models and persistent
records once. Tier, identity, ownership, Box placement and proportional condition
survive; durability scales 1200/1000. Recipe ID 12 retains knowledge and learns
its replacement dependencies. Shared arrows and known arrow recipes remain for
the longbow; no arrows become cartridges. The migrated shotgun starts empty.
New constructors stamp revisions before inventory synchronization. Native
old-save/current-save/hub tests cover these boundaries. Keep the original
5.1.6 save and matching package for tested checkpoint rollback; direct downgrade
of a newly saved 5.1.7 game is not promised.

First-person presentation uses separate complete weapon and separate hand
layers for ready, aim, recoil and reload. Ready/reload hands have the author's
requested smaller scale and muted colors; aiming reuses the carbine's existing
hand poses, scale and under-stock placement. The three weapon tiers share the
same hand set. Hand-style selection is a future feature; adding
it will not require redrawing the weapon. Equip/holster uses the existing
lowering motion and shot/reload timing remains controlled by gameplay.

## Soldier crouched carbine aim (#143)

Stationary city infantry uses the existing crouch and ranged-aim rules for actual
carbine shots: accuracy x2 from crouch and x2 from aim, critical chance x2 from
crouch with the existing 100% cap. Each factor applies once. NPC aiming affects
its own spread; it never zooms a player's camera. Firing still stops horizontal
velocity and retains individual target, resource, cadence, damage, wear and reload.

Physical crouch is the native player's half-height floor: a 57.6-MU soldier
uses 28.8 MU. `A_SetSize(..., true)` tests clearance before restoring height;
a blocked attempt retains the shorter body and removes aim. Movement, melee
selection, resource recovery, pain, sleep, physical stun and death interrupt
crouched aim. Losing the valid visible target releases it. Reload movement and
progress retain their existing half-speed rule. No crouch walking speed or
new accuracy balance is introduced.

CAGC provides original directional aim/fire/reload poses. Its registered scale
is 1.909090909; the firing barrel is measured 116 source pixels above the foot
pivot. Both player and soldier carbine projectiles use this lowered muzzle
geometry when crouched. Physiology instead uses stored standing height, so
bending the body does not reduce biological surface area or heat exchange.
The player's stationary carbine uses CAGC without a second native sprite
compression; moving crouched retains its existing compressed walking cycle.

`CaelumCityCarbine` revision 2 records holder, standing height and posture.
Revision-1 initialization captures the full height once, without refilling or
resetting magazine, reload, weapon condition, resources or timers. Repeated
initialization is idempotent. Native save/load and hub reopen retain the shorter
collision box and original height. Keep the original 5.1.5 save/runtime pair for
checkpoint rollback; a newer save's direct downgrade is not promised. Legacy
sword-only defenders remain unchanged.

## Demon racial ability and finite supplies (#135)

Approved issue scope: Mandingas carry six small potions of each family; Zupay
carries six large ones. Small/medium/large restore 10%/22.5%/50% of the respective
maximum over ten real seconds. Existing potion classes are small; IDs 11..16
append the six new variants, keeping container and legacy IDs unchanged.
Native inventory stacks own quantities; an idempotent supply revision initializes
old living demons once. Dead bodies do not receive retroactive supplies.

On actual death, an existing map/native predefined drop has priority. Otherwise
one remaining unit is chosen uniformly across all remaining units, retaining
its exact family/size. No remaining units means no potion; a persistent death
latch prevents duplicate callbacks. Scripted retreat remains distinct from death.
The shared regeneration effect records the dose, fractional Health and delivered
pulses. Natural expiry completes the tenth pulse otherwise lost to native
Powerup ordering; cancellation/death/refresh do not grant a completion bonus.
Older active effects with no dose metadata retain their historical behavior.

Automatic use starts strictly below 50%. Each family waits until its own active
ten-second effect ends; Health, Anima and Energy may run concurrently. NPC Energy
restores Air; player Energy retains Air plus Sleep. No NPC Sleep is introduced.
All sizes weigh 0.25 kg. Medium and large prices are 2.25 and 5 times the small
base price, respectively. Carried native stacks contribute their actual weight.
Medium items have silver details, large items silver and gold, including medikits.

The approved sustained breath costs 10 Anima per real simulation second before
the existing Eloquence/armor pipeline, applied once. Natural regeneration remains
active. Cold means negative exposure in an authoritative cold severity state.
Both demons also use it against their current combat target within reach. Normal
sleep, stun, pain, retreat, death and inability to pay interrupt the ability; no
additional activation charge or cooldown is introduced. An already-paid ordinary
attack is allowed to finish before starting the racial ability.

Each demon has its own four-phase exhalation loop in eight directions. Mouth
anchors are measured in the new atlas: Mandinga 160 pixels above the foot pivot
and 60 forward; Zupay 147 above and 70 forward, divided by the registered texture
scale and multiplied by individual actor scale. A native trace prevents a
forward mouth anchor from crossing a wall. These are art geometry, not new
combat balance. Animation advances every three tics without delaying payment
or contact. Interruption restores AI from any phase. Contact extends
4 m (128 MU), within a 60-degree cone, with native wall traces. Contact refreshes
the existing T1 fire burn: shared base duration times Charisma's Type-4 factor,
and the shared DOT ratio of T1 staff damage times that factor. There is no
additional direct-hit damage; refreshing contact preserves the burn pulse clock.
Since the author's 5.4.28 correction, breath emits no heat to noncontact bodies
or its own emitter. Total source power remains 20 kW. Four cone samples retain
the previous projection, attenuation, 35% budget, 0.95 surface absorption and
wall visibility only to calculate watts for local contact victims. Combined
contact absorption is capped before magical armor retention. The victim keeps
that absorbed power while burning, using the real-time queue and migration rules
at the start of this document. Cost/contact still run each real tic; stopping
the stream creates no final radiation scan. Potion units and paid-resource
history remain serialized. Cold/combat activation rules are unchanged.
Native evidence and outstanding acceptance are recorded separately in HISTORY.

## Functional port city contract (#133)

The campaign siege begins **15 November 1889 at 13:00**. New MAP06 starts
with the same 600 soldiers housed; the surviving actors walk through doors to
their assigned formations. Attackers start at the calendar boundary without
waiting for the defenders. Legacy already active sieges are not rewound.
Unloaded hub maps do not simulate movement: on return, the current civil date
triggers the still-unstarted event once. No teleport or offline casualty is implied.

Street deployment follows walkable ground and keeps artillery stair routes as a
separate phase. Soldiers can fight during deployment, wait for blocked doors and
resume after obstacles clear. Assigned positions retain their original identities;
front rows temporarily make an access column for deeper posts and then return.
Local detours use native collision and movement, with a bounded fair query queue;
they do not ignore bodies or reset resources. A retained harbor bed is avoided
by an explicit road-point override, not removed. Deployment and carbine state
remain attached to the individual actor across saves and hub reopen.

Each of 160 homes has a medium table, six native chairs, a native bed and an
empty bathroom. The 64-MU grid gives 123/62/20 usable cells: **60.000% living,
30.244% bedroom, 9.756% bathroom**. Wall cells and raised window sills are
excluded; entrance/internal doorway circulation belongs to the living/bedroom
areas. INTERIORS.json owns geometry, occupants, factory profiles and coordinates.
The west tower reserve formation is translated 256 MU east as a group in the
new revision: the old 14-position grid crossed the wall and exterior. Its
40-MU spacing, identities and formation role are retained; legacy data stay exact.

Shop equipment is **T1 only**, with one unit per matching equipment variant,
20 per food/drink type, 100 per ammunition type, and 200 copper per independent
vendor; **no automatic restocking in that original release**. #383 supersedes
these initial quantities with 1,000 consumables/ammunition and adds library/
clothing; #385 adds the calendar production policy above. The six original specializations are provisions,
melee, ranged/ammunition, jewelry, physical armor, and magic weapons/armor.
Existing purchase/sale margins remain 150%/50%, rounded per lot as before.
Author clarification: medikit/life potion, Anima potion and energy drink each
have base value **3 x food ration = 12 copper**. A carbine cartridge has base
value **4 x one arrow**; arrows/bolts use their existing material recipe and
T1 manufacturing markup, divided by batch size. Prices are not inferred from
Doom assets. Factories grant no inputs, recipe knowledge or efficiency changes.

Vendors are static, non-combat actors for this patch, as chosen by the author.
Their native inventories and 200-copper wallets belong to the individual map
actor, not to Palomo or a visiting player. Initial stock is materialized once
when first opened; sold equipment remains the same instance with its size,
identity, durability and water content. Purchases/sales preflight money, load,
Box slots and all needed native instances before committing. Equipped, reserved
and flagged equipment cannot be sold. Arrows/bolts retain their existing personal
inventory storage; the trade service does not invent Box storage for those stacks.
Catalogue rows per specialization: 5 provision types, 65 melee variants,
20 ranged weapon variants plus 3 ammunition stacks, 9 jewelry variants,
75 physical armor/shield variants, and 125 magical weapon/armor/shield variants.
Sized equipment covers XS through XL; essence weapons cover all five essences.
Magic shields belong to the magical specialization. Native clothing is craftable
in 5.6.6 but is not assigned to city stock until #383. The merchant's explicit
TradesClothing capability defaults off; it does not convert existing shops.
Tiers 2/3, filled water containers and javelin ammunition
outside the three-type ammunition catalogue are not added to shop stock.

New-city soldiers carry their existing sword/shield and a normal T1/M carbine.
`CaelumCityCarbine` (revision 1 in #133, revision 2 posture migration in #143)
owns that weapon's condition, magazine, reload and
shot timing. Only reserve availability is infinite: ten-shot magazines, the
existing Dexterity-scaled five-second base reload, Air/thermal cost, 60-metre
range, spread, critical chance, damage, projectiles and wear remain authoritative.
There is no physical infinite ammo stack or added ammunition loot. Melee selection,
pain, physical stun and death cancel reload without creating rounds. Holding the
carbine does not simultaneously enable the shield. Legacy defenders retain the
accepted sword behavior for matched #132 comparison and compatibility.

## Thermal exposure and energy transfer (#130)

V5.1.0 implements the author's 2026-10-07 contract. These are provisional game
coefficients, not a clinical body-temperature model. The signed personal value
`E` measures accumulated **equivalent exposure degrees**; negative means cold.
`CaelumThermalState` revision 9 belongs to the player's persistent character
record, or to each supported NPC. Shared services under `caelum/survival` own
the calculations; environment caches never own another character's exposure.

Humans and duendes have a 22 C comfort center; Beast Men and Caelith have 17 C.
Furry bulls and giant rats share the 17 C category without another fur bonus,
while retaining their own biological mass, size and attributes. Animal surface
uses a collision-cylinder approximation, not a humanoid height formula.
Mandingas and Zupay use 32 C. In 5.1.1/#131, effective Resilience
`A=max(0,Resilience)` multiplies both the base 1 C/world-day adaptation rate
and the base +/-5 C displacement limit by a Type-1 multiplier (#154):
`M=1+(A*A+25*A)/12500`. At A=100 this is 200% of the base: 2 C/day and +/-10 C.
This supersedes #131's Type-4 factor. Growth remains uncapped above 100.
Reaching either
limit from original racial comfort takes five world days under a sufficiently
distant sustained climate; traversing opposite limits takes ten. Nearby climates
stop at their actual offset. If effective Resilience decreases below an acquired
offset, adaptation returns gradually at the new rate, never by an instant clamp.
Players and supported NPCs use current effective attributes including equipment.
Acclimatization never also shifts stored E. Transient fire, drinks and magic are not acclimatization targets.
Players, anchored residents, folklore combatants, bulls and giant rats are
supported; unrelated actors without an approved physiology remain outside it.

For effective Toughness `D=max(0,D)`, the current Type-1 `R=(D*D+25*D)/125` percentage points and
`s=1+R/100`. Harmful thresholds are `10s`, `20s`, and **past** `30s`: exactly
`30s` remains tier 2. Numerical boundary tolerance is 1e-9. Threshold widening
is uncapped; HP mitigation alone clamps `R/100` to [0,1]. Tier 1/2/3 costs
1/2/3% maximum HP per **real simulation second**, multiplied by `1-R/100`.
Fractions persist. This direct environmental loss bypasses ordinary subtractive
Toughness, equipment, shields, native armor and adrenaline/reward paths.
At D=100, thresholds are 20/40/60 and thermal HP damage is zero.

| Consequence | Tier 1 | Tier 2 | Tier 3 |
| --- | ---: | ---: | ---: |
| Heat: qualifying Air costs | x2 | x3 | x4 |
| Cold: blunt incoming attacks | x1.5 | x2.25 | x3.375 |
| Cold: other incoming attacks | x1.25 | x1.625 | x2.1875 |
| Cold: movement and attack speed | /1.25 | /1.625 | /2.1875 |

Cold vulnerability enters once before existing defensive resolution, including
localized attacks; it does not increase hazard damage or thermal joules. Natural
NPC attack frames use the same slowdown. Weapon charge preparation keeps its
existing contract. Heat affects existing physical Air expenditure; it creates no
resting Air drain and does not multiply Anima or hypoxia into exertion heat.
The author-approved #133 sweat extension replaces the former thermal Thirst
multiplier with actual secreted water. The later #140 recovery rule charges
player Air and Anima the quarter-Health costs defined below.

### Regulated sweating (#133, 2026-10-08)

All supported humanoids, including Mandingas and Zupay, share the initial sweat
profile while retaining their racial comfort. In #140 the author also approved
that same surface-scaled profile provisionally for bulls and giant rats, retaining
their 17 C comfort and individual hydration. This is gameplay calibration, not
a claim that rodent or bovine physiology is identical to human physiology.
The 80 kg / 1.75 m reference produces at most 2 kg (approximately 2 L) per world
hour. Scale by actual surface area / 1.951493905 m², not carried load. Production
is `2*A/Aref*clamp(E/5,0,1)*clamp(Hydration/20,0,1)` kg/world-hour: zero at E<=0,
full thermal response at E>=5, full hydration response at >=20 Thirst points and
linear reduction to zero below 20. These E thresholds and the hydration curve
are explicitly approved game calibration, not clinical core temperatures.
The reference sweat ceiling is consistent with the 1.5-2 L/hour endurance-work
range described by [NIOSH](https://www.cdc.gov/niosh/docs/2016-106/pdfs/2016-106.pdf),
but is not claimed to be a universal human maximum.

Charge all secreted water using the inverse of the existing drinking rule:
`points/kg = 400*10/bodyMassKg`, or 10 Thirst points for 200 mL at 80 kg.
Constitution and rest do not make a measured litre of sweat cost less water.
The player's authoritative reserve remains CurrentThirst; thermal hydration is
a working projection. Each supported NPC owns a finite persistent reserve,
initially 100, without automatic refills or newly invented drinking AI. Zero is
an exhausted gameplay reserve, not absence of all water in the body.

Sweat is distributed by anatomical coverage into the existing worn/base-layer
moisture balance. Only actual evaporation removes the existing 2.45 MJ/kg latent
heat, once; runoff and submerged secretion still cost hydration but do not give
evaporative cooling. Humidity, relative wind, insulation, permeability and exposed
area constrain evaporation. Wet clothing can continue cooling after secretion
stops, including after entry into a cold place. Numerical substeps of at most
two world seconds resolve the coupled response; they add no simulation time.
Metabolic/action heat, signed environmental exchange and evaporation jointly
determine the energy balance. Equilibrium does not mean a living body must equal
air temperature. Since #140, carbine muscular heat has its own approved
action-duration profile below; other physical attacks retain the nominal-Air
and jump-reference conversion.

Revision 3 initializes only the new NPC reserve once, preserving exposure,
acclimatization, damage fractions and clothing moisture. Player migration reads
existing Thirst instead of refilling it. Journey previews advance their own
supplies and sweat together, including consumed water and the reduced cooling
of a depleted reserve; applying the thermal projection does not charge water
again. They retain changing regional weather, passenger shelter and zero invented
real-time thermal damage.

### Breathing and thermal coefficient cache (#140)

Ventilation uses the larger fatigue/heat factor, never their product. Air strictly
below 50% gives 1.5; strictly below 10% gives 2. Exactly 50% remains normal and
exactly 10% remains 1.5. Heat severity 1 gives 1.5 and severity 2 or higher gives 2,
using existing Toughness-scaled thresholds. Player and supported NPC natural Air
recovery is multiplied by that factor, preserving existing recovery exclusions.
Anima has no panting speed bonus. Dead or fully submerged actors receive no
breathing bonus or panting sound; hypoxia and its recovery debt stay separate.

The approved approximation adds only the extra respiratory sensible exchange:
`G_extra = (factor-1)*(6/1000/60)*1.2*1005*(bodyMassKg/80)` W/K. Six L/min is
reference ventilation; density is 1.2 kg/m3 and specific heat 1005 J/kg/K. The
80-kg reference gains 0.0603 W/K at 150% or 0.1206 W/K at 200%. Flow exchanges
against the existing equivalent thermal node, not a newly invented clinical
core temperature: `P_into_body = G_extra*(T_air-T_node)`. It cools only when the
inhaled air is cooler; hotter ambient air warms. Integrate it with the existing
world-time energy equation and retain signed RespirationJoules. No extra latent
respiratory water term is invented, and existing neutral metabolism is not
charged a second time. This small sensible term does not guarantee safe sustained
firearm or heavy-melee use; it does not eliminate wet-clothing cold.

Humanoid moderate/high male/female recordings play on CHAN_BODY. Player sex and
existing NPC voice profiles select the recording. Intensity changes replace the
loop; death, recovery and full submersion stop it. Voice/weapon/heartbeat channels
remain separate; an unrelated brief body sound can finish before panting resumes.
Audio bookkeeping is transient and reconstructed after loading. Animal ventilation
and sweat work physically; no supplied human voice is used as an animal recording.

The per-actor transient CaelumThermalCoefficients caches stable area/mass,
material/coverage/immersion, wind-film, ambient vapor and anatomical row weights.
Temperature, moisture, water temperatures, fire and activity still update energy
flux; wetness never becomes stale constant wattage. Anatomy constructor generation,
material/coverage keys and environmental inputs invalidate affected projections.
Existing bounded environmental sampling still detects shelter/fire changes.
Revision 4 preserves primary state and discards the cache on loading; revision 5
adds only a persistent pending-firearm-energy queue. Both migrations are
idempotent and preserve existing exposure, water and reserves. Independent
journey copies build their own caches and couple recovery costs with sweat/water.
The original issue's proposed core/skin and exact Stefan-Boltzmann replacement
were explicitly declined in favor of preserving the approved equivalent exposure,
linear 4.7 W/m2/K radiation and calibrated inertia. No new contact physics is added.
These safe per-actor coefficient savings apply to normal physiology at all counts;
#128's separate 500-living-combatant AI activation rule remains unchanged.

### Carbine muscular effort (#140, author decision 2026-10-08)

Primary carbine fire costs the same base Air as a dagger: **2**, previously 20.
The shared catalogue governs player and soldier costs; ordinary modifiers,
affordability, magazine consumption and recovery funding still apply.
The #136 energy-budget correction converts the approved 2/2.5-MET reference
profiles into fixed mechanical work. Subtract the resting MET, assign 25% of
the remaining metabolic energy to work, and use reference cycles of 0.4 seconds
for firing and 5 seconds for a complete reload. The authoritative budgets are
5.82 J/m2 per shot and 109.125 J/m2 per complete reload; resulting body heat is
`W*(1/eta-1)`. At 25% efficiency, the 100 kg / 1.80 m body produces 12.745/238.973 J work
and 38.236/716.918 J heat. They are approved equivalent-work calibrations, not
measurements of the gun animation or energy supplied to the projectile.

A successful shot pays once, when fired. Reload pays its fixed budget in
proportion to completed progress; Dexterity and moving while reloading alter
duration, not total energy. Partial-magazine reloads retain the game's complete
reload cycle budget. Interruption pays only completed progress. Idle aim and
failed shots add nothing. Player and NPC paths share the same work data.
NPCs queue completed joules until their bounded thermal update without forcing
the solver every tic. Save/load retains measured work and a reload's budget;
an old in-progress reload adopts the new rate for its remaining progress only.

### Cold regulation by shivering (#140, author decision 2026-10-08)

All supported physiological actors, including bulls and giant rats, provisionally
share `MET_total = 1 + 4*clamp(-E/5,0,1)`: no shivering at E>=0, a gradual
response below neutral, and at most 5 total MET at E<=-5. Extra production is
`surfaceArea*58.2*(MET_total-1)` watts integrated in world seconds alongside
resting metabolism. Recompute within the existing bounded thermal substeps;
there is no invented action-Air cost or post-shivering activity tail. This is
an approved equivalent-exposure calibration, not clinical core temperature.

Player extra Hunger loss equals the existing passive Hunger rate multiplied by
`MET_total-1`, retaining Constitution, body-mass and rest modifiers. Baseline
passive loss is charged separately once, so full shivering costs five times
the baseline overall. The remaining food fraction limits paid additional heat;
zero player Hunger funds no extra heat. NPCs retain the author's exclusion from
Hunger reserves and feeding AI. They receive the provisional shivering response
without a new food resource. No sweat or shivering water is reabsorbed as Thirst.

Travel forecasts use independent food/thermal projections and the same sleeping
comfort factor as journey supplies. Commit does not charge shivering twice.
Revision 6 initializes shivering metadata without resetting prior physiology or
pending firearm work. Accumulated shivering energy survives save/load.

Metal itself does not store absorbed water: the current metal-cloth material
stores moisture in its underlying light fabric (0.192336119 kg per square metre).
The model already evaporates retained water according to surface temperature,
humidity, wind and permeability; excess above capacity runs off. It does not
have a separate free-droplet film or an approved movement-shedding coefficient.
Fire already contributes declared, distance/occlusion-limited absorbed energy;
it can increase evaporation indirectly, not by an arbitrary drying percentage.
There is no independent garment-temperature node in this retained model.

### Clothing, water and shelter

Author-approved thermal mapping does **not** change leather-based recipes:

| Current equipment | Whole-outfit clo | Evaporation accessibility |
| --- | ---: | ---: |
| Base clothing: light cloth | 0.5 | 0.90 |
| Magical armor: thick cloth | 1.0 | 0.75 |
| Light armor: ordinary leather | 1.2 | 0.45 |
| Medium/heavy: metal over light cloth | 0.6 | 0.60 |
| Thick/demon leather calibration, no new assigned item | 1.8 | 0.30 |

One clo is 0.155 m² K/W. These include underclothes and are apportioned by a
16x16 sample of actual anatomical regions. They are parallel regional paths,
not a full outfit bonus per item. Broken equipped pieces retain physical
insulation; their ordinary magical defense remains zero. Wet outer pieces own
their water mass through equipment identity and copy/drop paths. The character
owned implicit base-layer water before 5.6.6. Converted players now keep it on
native garments; uncovered skin has its own bare-surface reserve. The approved
ordinary-clothing catalogue above supplies each uncovered region's profile,
while armor retains this table's complete profile without adding garment clo.
Existing NPC implicit clothing is unchanged. Unequipped pieces retain moisture without passive
drying; Box contents remain sealed. This is an explicit first-model storage
rule, not a new waterproof treatment. Metal's outer moisture capacity is zero;
its included cloth retains water.

Air exchange uses `Fwet=1+0.02*wetnessPercent`; it already includes the approved
wet insulation loss. There is no second loss multiplier. Rain adds 2 percentage
points/minute per mm/hour on uncovered worn surfaces, bounded by capacity, while
evaporation continues. No extra treated-leather coefficient is invented.
Submerged anatomical rows saturate and exchange with water at 100 W/m² K,
replacing their air path without multiplying water exchange by Fwet. Native
height sectors and stacked swimmable 3D floors are sampled separately, including
volumes above dry feet. A volume/model sector may declare
`user_ca_water_temperature_defined=1` and `user_ca_water_temperature_c`, including
zero. Otherwise the explicit fallback is climate **ground** temperature.

Evaporation uses positive vapor-pressure gradient, permeability, a Lewis factor
16.5013576 K/kPa, available water, and 2,450,000 J/kg latent heat once. Runoff
does not cool. Clothing surface temperature follows its coupled resistance and
exposure, rather than staying fixed at 22 C. Saturation capacities derived by
`assets/validation_510/calibrate_drying.py` are 0.1923361193, 0.3323679408,
0.3469835350 and 0.4208696971 kg/m² for light cloth, thick cloth, leather and
thick leather. At 22 C / RH 50% / wind 1 m/s, an initially neutral 80 kg,
1.75 m reference dries from saturation to <=0.0001% in 60/120/180/300 world
minutes. These are calibrated capacities, not measured fabric properties.
The bare-animal surface uses the light-cloth moisture-capacity reference without
adding clo; species-specific water storage remains a refinement.

Air convection is `max(3 approximately,8.6*v^0.53)` W/m² K, with a 0.137 m/s
natural-convection velocity floor and 4.7 W/m² K radiation. Relative motion
contributes to convection. Exchange follows the temperature gradient: wind can
warm a colder body. Eight local traces within 1024 map units identify at least
three connected wall planes, blocking exterior wind; two walls do not. Roof
testing is independent and stops rain. Authored ranch roofs are also supported.
This finite geometry sampler is an approximation for irregular/segmented rooms.

### Solid thermal surfaces (#314, 5.5.6)

Author decisions on 2026-10-19 approve only ice **-40 C** and lava **1,000 C**
in an isolated test room. These are game approximations, not universal Antarctic
or volcanic temperatures. Campaign placement, other materials, remote radiation,
melting/freezing, burning equipment and new elemental statuses are outside scope.
The existing air/water solver lacked solid-floor contact; the author explicitly
approved reusing **100 W/m² K** and the lowest **1/16** anatomical body row.
`CaelumThermalSurfaceData` owns the surface catalog and coefficient reference.

A supporting sector declares `user_ca_thermal_surface`: 0 none, 1 ice, 2 lava.
A solid 3D floor uses its model sector, not a tagged floor underneath it.
Contact requires a living, grounded body with no upward velocity, flight or
noclip. Crouching preserves contact. Native water level or a sampled water row
covering the feet takes priority. The approximation does not simulate submerged
solid conduction in parallel with water. Existing anatomy maps the bottom row
to actual clothing slots, including quadrupeds. For each contact area A and
existing regional clo, G = A / (0.155 × clo + 1/100), in W/K. This area is removed
from air exchange. Wetness does not multiply ground conductance a second time.
Equipped broken clothing retains its existing physical insulation.

G enters the shared world-time thermal balance at the authored surface
temperature. Existing exposure, physiology, Toughness mitigation and real-time
HP loss remain unchanged. There is no additional periodic/direct floor damage
or Fire/Burn bypass. Redemption retains its existing temperature exclusion;
the earlier Amparo wording does not establish another immunity.

Player contact is sampled with existing thermal steps. On tagged maps, a local
support query detects NPC contact transitions; touching NPCs close intervals
each tic. Entry closes the previous interval with its previous surface, avoiding
retroactive heating. After exit the current projection clears immediately.
The current water/environment sample is used at interval boundaries; exact
historical geometry reconstruction is not claimed. Untagged maps retain the
usual staggered NPC cadence. One sector census at WorldLoaded owns the map flag;
no new actor traversal or emitter is introduced. Existing shared fire/ranch
and hub-reset traversals remain; this patch does not broaden them.

Surface projections and schedules are transient, rebuilt on save/hub loading.
Persistent thermal revision stays 9. Abstract journeys clear origin-floor
contact; the destination is sampled on arrival. Repeated sampling carries no
energy and repeated same-tic NPC callbacks consume no additional interval.
Fixture, native evidence and limitations: assets/validation_556/RESULTS.md.
The author accepted CA314-01 on 2026-10-19; testing this private room does not
approve campaign placement.

### Energy, effort and clocks

Humanoid area is `0.202*m^0.425*height^0.725` m². The 80 kg / 1.75 m reference
area is 1.951493905 m². Reference clothed conductance is approximately
9.409829238 W/K and exposure inertia is 11,291.795086 J/equivalent degree,
calibrated to a 1,200-world-second response. Inertia scales with biological
mass alone, not height or carried load. Equal absorbed 100 J gives E changes
0.01771198 / 0.00885599 / 0.00442799 at 40/80/160 kg. At equal height, changing
area gives response times approximately 13.43/20/29.79 world minutes.
Resting 58.2 W/m² is balanced in the neutral reference; it creates no neutral
drift. The constant-coefficient solver integrates exchange and threshold dose
analytically: `C*dE=(B-G*E)*dt_world + P_real*dt_real + Q`.

Author-approved #136 budgets now distinguish positive mechanical work `W`,
metabolic energy `W/eta` and retained muscular heat `Q=W*(1/eta-1)` (#154). No new Hunger or
Air charge is inferred from that energy ledger. Performing the same action
faster does not change its budget; completing more actions or metres per second
still increases the rate of production. These are calibrated gameplay profiles.

Walking/running use 0.5025/1.005 J of equivalent work per kg of moved mass per
metre, derived from 25% of the former flat ACSM metabolic cost. At the 25% baseline, heat is
1.5075/3.015 J/kg/m; current efficiency changes heat, not this work budget. The same path has the same energy regardless of traversal
speed or integration partition. Positive ascent adds `mass*localGravity*height`
of mechanical work once. Descents retain the approved normalized Minetti braking
curve, bounded at -0.45 grade; negative work never becomes cooling. Ground paths
subtract moving-support translation. Teleports, falls, passive impulses and
platform transport create no walking heat. The existing 32 map units/m and
native movement/collision rules remain; mixed propulsion and knockback remain an
approximation. Journey forecasting converts actual distance to the same work.

Every accepted player jump now charges its delivered kinetic energy under the
#154 contract above. The former 0.5 m / fixed-efficiency calibration is historical
(#136) and remains in HISTORY and the old validation records. New jump heat uses
effective Agility, biological versus moved mass, retained velocity penalties and
current muscular efficiency once at takeoff. Jump-derived proxies do not set the
work of other actions.

Physical weapon work is a fixed, independent table, not a runtime Air or jump
conversion. Values are J per successful action, shared across actors and tiers:

| Weapon | Primary work J | Secondary work J |
| --- | ---: | ---: |
| Dagger | 50 | 75 |
| Hatchet | 75 | 100 |
| Machete | 75 | 125 |
| Javelin | 100 | 150 |
| Sword | 125 | 200 |
| Axe / pickaxe | 150 | 225 |
| Flail | 150 | 250 |
| Spear | 175 | No physical secondary |
| Halberd | 250 | 375 |
| Greatsword | 300 | 450 |
| War axe | 350 | 500 |
| Giant gauntlets | 375 | 375 |
| Longbow | 250 | No physical secondary |
| Crossbow | 150 | 150 where applicable |

These preserve the approved old relative attack-cost proportions once as data;
later Air tuning must not change heat. Charged attacks multiply work by 2 and
sweeps by 3, once each. A primary greatsword attack emits 900 J at 25%
efficiency and 300 J at 50% efficiency (#154). NPC natural bites/horns use 25 J, machete-equivalent
attacks 75 J, and Zupay's ground slam 850 J; heat uses each actor's efficiency.
Firearms use their separate fixed budgets above. Magic remains external energy.

Active player swimming uses 72.75/130.95 W of equivalent mechanical work per m2,
normal/fast, derived from the approved 6/10-MET profiles after subtracting rest
and assigning 25% to work. At 100 kg / 1.80 m and 25% efficiency this emits 477.945/860.302 W heat.
The running command selects work intensity; attributes affect efficiency, not the work profile.
Isometric effort retains metabolic heat despite zero external displacement:
pushing uses the approved 6-MET total profile (637.260 extra W for that body),
and blocking uses `0.2943*totalMovedMassKg*heldWeaponOrShieldKg` W (235.869 W at
133.576 kg with a 6 kg shield). Neither reads Air or jump energy. Resting heat,
shivering, sweat, respiration and environmental/magical transfer remain separate.
Since the author's #136 follow-up, continuous effort produces heat only during
the action: `Q=P*(real action seconds + explicit logical travel effort seconds)`.
Stopping, loading a stationary save or advancing personal time without further
work produces no additional activity heat. Exposure already accumulated remains
and exchanges heat through the existing environment/sweat/shivering model.
The earlier 120-world-second peak/recovery tail is removed; there is no 8-met cap.
Actual actions use the work and isometric profiles above. No Air, sweat or
water-transfer values change in the energy-budget correction.

Thermal revision 7 clears only the old saved activity-power peak. It preserves
exposure, damage history/fractions, hydration, acclimatization, gear/base moisture,
and pending measured work. The migration is idempotent. It cannot reconstruct
and undo erroneous historical heat from an old peak, so a previously overheated
save can remain dangerous while cooling. Keep the original save and matching
package for checkpoint rollback; do not interpret the fix as a health refill.
Revision 8 adds only a reload budget. Measured pending joules, prior exposure,
moisture, resources and acclimatization survive unchanged. Refresh recomputes
the Type-2 adaptation factor; offsets above the new limit return gradually,
using the existing approved rule. Original save/package pairs remain rollback
checkpoints; never overwrite the author's saves during testing.

Fire-primary and ice-secondary projectiles carry the existing Type-1 snapshot,
`100+Intelligence*(Intelligence+1)/2` joules. Only actual intercepted shield and
contacted gear magical defenses determine absorption once; final HP damage,
innate defenses, cold vulnerability and subtractive Toughness do not convert
joules. Explosions use weighted contacted coverage once per recipient. Existing
continuous fire-seal recipients receive power per real second. Projectile
recipient latches prevent repeated callbacks from repeating energy.

Optional `CaelumThermalFireSource` map actors require args[0] profile 1..4
(1/5/20/80 kW), args[1] physical flame radius and args[2] height in map units.
Unspecified sources emit no invented thermal power. Flux is `0.35*P/(4*pi*r²)`
times visible projected body area and author-approved provisional absorptivity
0.95; physical source dimensions bound near-field distance. A 4x4 visibility
sample checks obstruction. This is a point-source approximation, not a fire
fluid model. Existing decorative fires receive no guessed profile.
No existing hot/cold consumable had approved metadata: the tested service hook
applies +/-10 C forcing for ten real seconds, refreshing rather than stacking;
it does not invent new items or instantly change E by ten degrees.

Climate response, moisture and acclimatization follow world time. Real HP,
continuous spell energy and drink expiry follow simulation ticks. Extra personal
time steps advance world response with zero extra real damage or action energy.
Paused simulation advances neither. Limbo retains local 1:1 time and a frozen
civil calendar; ordinary maps retain 20:1. Harmful thermal states interrupt
safe accelerated rest/crafting/sleep. Unloaded hub maps do not simulate NPC
physiology; reopening resets local sampling clocks while preserving E, water,
acclimatization and damage fractions. Offscreen actors on a loaded map remain
fully supported, with staggered one-second updates and actual elapsed time.

Journey previews integrate minute-sized weather/activity steps on an isolated
copy. In #131, each step samples both endpoint regions at the same advancing
civil date/hour and seed, then linearly blends air temperature, humidity, wind
speed, rain, regional means, ground temperature and cloud by distance travelled.
Foot/caravan/cart distance stops during the eight-hour sleeping interval; ships
continue sailing through passenger sleep. Climate still evolves with the clock
while stopped. Apply vehicle shelter after blending, and feed the resulting
climate to both exposure and Resilience-scaled acclimatization. Unknown destination
regions fail explicitly. `CaelumWeatherRules.RegionForLocation` is the shared
catalogue for unloaded destinations and default loaded-map weather; current
shipped destinations are all Buenos Aires (region 1). A new regional destination
must define its region there and keep its map marker consistent. Standalone map
markers still define uncatalogued local climates. The route is an approved
endpoint interpolation, not a claim to model intermediate geography. Foot/caravan uses actual speed/load and the existing 16 hours walking /
8 hours sleeping cycle. Cart/ship passengers rest inside four walls and a roof,
using the existing indoor microclimate, zero exterior wind/rain and no invented
heating. Nearby parked vehicles do not confer this journey shelter. Reject any
forecast reaching harmful cold/heat, explain the cause, and consume no provisions.
Successful travel commits exposure/moisture/acclimatization and logical activity
without inventing real HP damage. Active drinks prevent instantaneous travel.

### Persistence, presentation and evidence

Missing state initializes idempotently without resetting old records. Revision 2
adds only a derived acclimatization multiplier and preserves every revision-1
primary thermal value. Effective attributes reconstruct the multiplier after
load and before forecasts. A 5.1.1 save can return directly to accepted 5.1.0
and later reload in 5.1.1; keep original saves and write distinct slots. This
restores the old gameplay rules while away, so ongoing simulation can naturally
change E, water and adaptation. The separate bridge below is still required
when returning further to 5.0.6, which predates thermal classes.
GZDoom cannot load new class instances in an unmodified old executable package:
`python assets/validation_510/prepare_rollback.py` reproducibly builds
`build/issue130/rollback-506.pk3` from accepted commit `45f1637`. Use it in place
of the gameplay PK3 to return to 5.0.6 behavior while retaining inert thermal
serialization for a later 5.1 reload. Keep original saves and the same map-addon
basenames; save to a new slot. This bridge changes no original save file.
Generated packages, development IWADs, engine and saves are not distributed.

Journal > Character or World > **T** displays air, adapted comfort, signed exposure, first
harmful threshold, wetness, humidity, acclimatization and current penalties in
English/Spanish. The 5.1.1/#131 read-only bar, moved into Character by #256,
originally appeared directly above Load:
a grey icon with snowflake upper left and flame lower right, a neutral center, cold/hot bands and
ticks at the actual Toughness-scaled
thresholds, a signed value and localized severity. The #140 follow-up colors
the exposure label with the same cold/hot band palette as its marker position,
including Toughness scaling and overflow; black glyph outlines remain visible.
Its visual span is +/-30*s;
overflow pins the marker and prints < or > with the extreme state, without
clamping stored E. Large numbers use scientific notation. The same 640x360
projection, typography, frame/laurels, aspect handling and visibility policy
as the existing resource bars apply. Shared native coordinate conversion also
corrects the prior frame/fill mismatch at 4:3 and ultrawide (CA-KP-051).
It follows a valid viewed live player,
falling back to the local pawn for non-player cameras; this is not new network
multiplayer support. Draw calls never sample climate/geometry or mutate state.
Air temperature, wetness and comfort remain separate Journal details. This is
not core temperature. #131 gameplay and final revised-icon checks are author-accepted on 2026-10-07.
No #131 author checks remain in pending_test.txt.
Native evidence, exact package/config hashes, migration comparisons, drying fit
and bilingual captures are in [5.1.0 results](../assets/validation_510/RESULTS.json).
The author accepted CA130-01/02/03 on 2026-10-07; HISTORY records the results
separately from native evidence. No author checks remain for this patch.

Physical sources: [EnergyPlus thermal comfort](https://energyplus.readthedocs.io/en/latest/guides/engineering-reference/19.1-occupant-thermal-comfort.html),
[NIOSH heat guidance](https://www.cdc.gov/niosh/docs/2016-106/),
[NIST wet clothing](https://www.nist.gov/publications/thermal-performance-fire-fighters-protective-clothing-1-numerical-study-transient-heat),
[NIST fire radiation SP1169](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1169.pdf),
[ACSM walking](https://pmc.ncbi.nlm.nih.gov/articles/PMC7896743/),
[ACSM running](https://pmc.ncbi.nlm.nih.gov/articles/PMC3743617/),
[Minetti downhill](https://pubmed.ncbi.nlm.nih.gov/12183501/),
[muscle work efficiency](https://pmc.ncbi.nlm.nih.gov/articles/PMC2269891/),
[load carriage](https://pmc.ncbi.nlm.nih.gov/articles/PMC3922835/),
[oxygen conversion](https://pmc.ncbi.nlm.nih.gov/articles/PMC5504009/).
The author's outfit profiles, response times, consequences, racial shifts and
action proxies are game calibration, distinct from those physical sources.

## Staged siege reinforcement test (#132)

The author requests a separate playable MAP06 performance experiment. The
accepted full army remains the default. Set server CVar
`ca_test_siege_reinforcements true` **before a fresh MAP06**; false reproduces the
original deployment. The southern city layout is supported; legacy port layouts
retain their populations. This is not permanent adoption of a new encounter.

`CaelumSiegeReinforcements`, owned and saved by `CaelumPortSiege`, holds revision 1,
successful spawns, living registered Mandingas, unspawned remaining budget, the
pending group's placed-slot bitmap, formation cursor and next opportunity tic.
`CaelumReinforcementData` supplies 100/group, 2,000 living, 6,000 total and 350 tics.
The commander, 600 defenders, 12 hostile machines and all 42 guns retain their
authored populations; none consumes the Mandinga cap. The 74 attacking operators
are part of the first 100, not an extra initial population.

The first opportunity is immediate at deployment. Each later opportunity is
350 simulation tics after the previous one, independent of accelerated calendar
time. Pauses do not advance `level.time`. At most one group starts per opportunity;
99 vacancies do not suffice, 100 do. Missed opportunities are not banked. A partial
group retains its missing members and retries at a later opportunity before any
new group starts. Only registered, successfully placed native bodies consume the
budget. Deaths do not undo cumulative spawns; corpses keep their existing lifecycle.

Initial crews try their authored stations, falling back to the existing infantry
formation if occupied; they walk to their assigned machines normally. Infantry
uses the authored 200-column southern formation positions with a saved rolling
cursor. Native `TestMobjLocation` checks walls, solid actors and vertical fit;
an additional body-overlap check avoids non-solid combatant corpses. A failed
candidate is discarded before registration, leaves its slot pending and consumes
no budget or native total-monster statistic (`ClearCounters` before rejection).
At most one formation position per missing member is tried per
opportunity (plus the original station for an initial crew member). Successful
members of partial groups immediately participate in normal combat. No living
registered attacker is deleted or teleported to free a reinforcement slot.

The current population is refreshed from owned bodies each simulation tic in
staged mode. The separate #128 map-wide 500-living-combatant census remains
unchanged, including offscreen combatants and defenders. Existing dynamic
command membership/leader targets, collision, resources, statuses, individual
attack validation, crew replacement and machine neutralization remain in force.
A group becoming eligible does not force it into one permanent command group.

Victory still requires commander defeat/confirmed retreat and all twelve hostile
machines neutralized. Empty current Mandinga ranks alone never win, even with
reserves pending. A legitimate victory stops reinforcements before that tic's
opportunity; the unspawned budget remains recorded as stopped, not consumed.
Thus a natural battle can finish before all 6,000 enter. A separate complete-budget
diagnostic gives the commander ordinary damage invulnerability and applies
explicit native-damage casualties (thermal health loss still follows its service);
it is never used as evidence of an unmodified natural battle or distributed as AI.

Existing full-army saves initialize a disabled revision-1 controller once,
retaining the complete saved roster, identities, crews, deaths and victory state.
Changing the CVar cannot convert an already deployed encounter. Saved staged
encounters resume the same bitmap, counters and deadline without redeployment,
including hub returns. Rollback means loading the untouched original full-army
save with its original package; preserve both. A staged save requires this schema
and is not promised to open in the old package.

## Automatic high-density AI (#128)

Author decision, 2026-10-07: activate the applicable normal AI optimizations
at **500 living combatants in the entire map**, including those offscreen.
`CaelumPopulationState` counts living, shootable `CaelumCombatActor` NPCs and
active players' living, shootable pawns. Projectiles, props, helpers, corpses
and inactive/non-player pawn copies do not contribute. The existing map event
handler refreshes this derived snapshot before thinkers each simulation tic;
spawn, death, removal, revival and shootability changes appear by the next tic.
Exactly 500 enables it; 499 disables it. Camera movement does not affect it.

The mode is automatic, with no player setting or diagnostic CVar. Existing
siege command groups still contain at most 100 members, use the authored
connectivity/rank rules and retain the full army. In high-density mode each
member **adopts the leader's target**, even if another target is closer to the
member. This explicitly supersedes #77's individual-nearest rule only while
the threshold is met. Leaders select the nearest visible living player or
port defender; absent a visible opponent they retain their lane approach goal.
Actual attack preparation/release still checks each member's own range, line
of sight and resource costs. Sharing an order does not authorize attacks
through a wall or disable recovery, individual movement, collision or status.

As adopted in #353, perception reuses a group decision until its next phase in
the shared 100-tic period. The first active member queries immediately; after
expiry, the next requesting member refreshes it once for the group. Groups with
no requests do no background perception work. Visibility/position changes can
remain cached until that refresh; individual attacks still validate their own
current conditions. Dead or destroyed targets notify their subscribed groups
locally and are reacquired on the next request. The selector also rejects a
dead, destroyed or unshootable cached target directly. This demand-driven phase
distribution is distinct from the earlier rejected background-query experiment.
An inactive leader falls back to the live member until ordinary regrouping.
The roster of living target candidates is reused among leaders in the same
tic; positions, health, shootability and visibility remain live query inputs.

Armed hostile machines use a native blockmap broad phase followed by the same
exact 3D guard predicate. A once-per-tic list covers guards flagged NOBLOCKMAP.
New NOBLOCKMAP guards registered after that census enter the fallback list
immediately, before a machine can observe or neutralize. Other flag changes
are reflected by the next census; current production combatants do not toggle
NOBLOCKMAP during a tic. Previously remembered guards, confirmed deaths, retreat and one-time
neutralization remain authoritative. A loaded cannon with no eligible target
retries after the existing eight-tic perception interval. Its target search
skips sight only when a normal visible candidate cannot beat the already
selected crew-priority/nearest target. Ties retain roster order. Invisible,
zero-alpha and special-render-style candidates retain native sight calls,
including their random-stream effects. Successful shots, crew priority,
ammunition, ballistics and reload timing are unchanged.

Below the threshold, per-member targeting and full guard scans resume and
negative cannon searches have no added retry delay. Mode transitions clear
only derived perception/deadline caches. Targeting revision 3 initializes the
new caches idempotently; population revision 1 is rebuilt from native actors
on load/travel and each tic. Rosters, identities, casualties, crews, resources
and saved inventory/Tarot state are not reconstructed. The population gate is
map-wide; group targeting applies to existing port command groups and spatial
guard queries to siege machines. This does not invent command groups for
unrelated civilian/faction AI or activate CADEV02's reduced actor simulation.

## Siege profiling and group experiment boundary (#121)

Historical boundary of 5.0.5; #128's production policy above supersedes it.

The accepted siege retains 6,000 Mandingas, its commander and 600 defenders.
Production command groups already contain at most 100 members. Membership and
leadership do not replace each member's nearest-visible-target search, native
movement, individual combat, resources, collision or damage.

`assets/validation_505` builds isolated diagnostic copies. Its formation test
places all 6,000 Mandingas into sixty 10-by-10 blocks on the existing 200-column
formation footprint, recalculates their lanes, synchronizes their initial run
animation and issues movement through native `TryMove` every four tics. Mode 1
chooses a target/direction independently for every soldier; mode 100 chooses
once per group and applies that direction to its surviving members. Native
collision can block individual members and break the formation; the probe
records successful moves and deviation from initial relative positions.

This is a march experiment. It relocates machine crews and replaces Mandinga
attack/chase actions. The commander, defenders, machines, body Ticks, health,
resources and native collisions continue. A separate shared-target diagnostic
keeps the original placement and native combat/movement but gives followers
their command leader's cached perception for the current tic. That changes
individual visibility and nearest-target semantics. Both interventions change
the workload; their timing differences cannot be added together or adopted as
accepted combat rules. Production populations, geometry, hierarchy, victory,
balance and save fields retain their existing contract.

The combined diagnostics also test a native spatial broad phase for machine
guards, retaining the existing exact 3D radius, remembered guards and death
predicate. A separate full-scan oracle checks omitted eligible guards. Another
test caches failed cannon target searches for the existing eight-tic target
update period; this can delay acquisition by seven tics and is a deliberate
behavior change. These factors are measured alone and together, including
shared perception plus spatial guards and the three-factor combination.
No diagnostic field, cache, formation controller or altered targeting rule is
included by production ZSCRIPT. The author's comparison target is stable native
35 tics/s with at least 30 displayed frames/s at the current resolution/population.
On 2026-10-07 the author accepts the demonstrated fluency as sufficiently close
for this diagnostic stage and defers further tests. The numeric reference and
production contract remain unchanged; acceptance does not install the prototypes.

## Per-player authority and modular migration boundary (#120)

`player/CaelumPlayerAuthority` defines the common receiver contract without
owning state. Reads require an explicit pawn whose native `player.mo` still
points to that pawn. Commands additionally reject `CF_PREDICTING`. Native play
execution and event transport remain GZDoom's responsibility; this helper is
not a new server or a complete multiplayer authorization layer.

| Boundary | Authoritative state and supported operation |
| --- | --- |
| Player/profile/resources | Existing pawn fields and profile/allocation objects. Character/resource/presentation operations take that pawn explicitly; null, detached and stale receivers cannot mutate them. Read-only inventory lookup remains available during prediction. |
| Inventory/equipment | Native `Inv` chain and item `Owner`. Numeric IDs are scoped to the owner; two players may have the same ID. Mutation rejects foreign owned items. A legitimate native drop releases ownership; pickup by another player applies that player's existing collision/reassignment rules without transferring unrelated wear or selection. |
| Tarot/persistence | The requesting pawn's canonical `CaelumPersistentCharacterState`, found in its inventory, owns cards, selected/paid-active sets and clocks. Record writes require that identity and owner. A foreign record cannot initialize revisions or overwrite the requester's Journal projection. Essence commit also requires its recorded capture user to own the destination record. Pure record queries add no owner or mutation. |
| Crafting projections | A non-null preview must be the exact `user.CraftingBrowser` object. It is a pawn-held projection, not a second inventory. Repair/dismantle targets retain owned-item preconditions. Legacy capacity/recipe queries that refresh state route through mutation guards. |
| UI and requests | Journal page, cursor, scroll and menu selection remain local UI state. Commands cross `SendNetworkEvent`; Journal, Trucazo and Truco handlers resolve the event's player through `FromNetworkPlayer`, checking bounds, participation and current pawn before indexing/mutation. They never fall back to `consoleplayer` or player zero. Menus retain their own match serial/action validation. |
| Shared world | MAP06 siege roster, actors, command groups, gates and physics contacts remain map-local shared state. Per-player records contain personal discovery/reward progress. This patch does not clone world controllers per player or assign one player's inventory authority over another. |
| Campaign time/session | Existing clock/calendar/weather/journey inventories still belong to a pawn; the clock ticker runs only with one participant. There is no supported shared campaign-time, joint rest/travel, reward distribution or networked card-match lifecycle. Join/leave/reconnect/respawn and ownership transfer policies require their own design and native multi-client tests. |

The source manifest records 203 entry guards and their read/command distinction.
All retained statements, serialized fields, signatures, input bindings, selectors,
maps and assets remain. `CaelumTarotPowers.REVISION` aliases the service's revision
instead of duplicating the value. No new schema, migration counter or service
instance is introduced. Existing adapters and migration gates are retained;
completion of #116–#120 is not authorization to delete them.

Validation uses original 5.0.3/current saves for each domain and a preserved
5.0.0 Architecture 1 save. Original-save upgrades, separate re-saves, repeat
loads and original-package/original-save rollback are recorded in
`assets/validation_504/RESULTS.json`. Two native player pawns (human plus bot)
exercise owner isolation in one process. This does not establish two-client
transport, full co-op/PvP or networked Trucazo. Ordinary author acceptance stays
in `pending_test.txt`; unsupported network lifecycle is a development task.

## Tarot service and retained save contract (#119)

`core/CaelumTarotService` is the stateless domain implementation. The travelling
`CaelumPersistentCharacterState` remains the sole saved owner of collection,
selected/activated arrays, revisions and remaining tics. No fields, IDs, array
sizes or native class names move. Existing record, power, essence and rule
methods remain compatible adapters; they do not maintain a second collection.

| Boundary | Contract |
| --- | --- |
| Collection and bonuses | One implementation counts owned cards and derives integer-tenths Minor contributions and collection percentage. Card suit/rank belongs to Tarot; Trucazo retains its separate ranking/scoring rules. Character rebuilds consume these queries without accumulating bonuses. |
| Selection and activation | Player input and Journal requests enter the service with the requesting pawn. Owned/implemented cards, the three-card limit, activity, Anima and cooldown checks precede payment. Selected cards describe the next activation; active cards are the paid snapshot. |
| Time and native effect | Existing personal-time/journey calls advance the saved clock once. HUD, Journal and flight read it without advancing it. Expiry clears only active contributions. A missing native flight instance is restored after travel or the next personal tic only while the saved Fool effect remains active; restoration neither pays nor resets either timer. |
| Capture commit | The service rechecks live context, map/progress, range/sight, animation completion, same Box identity, physical deck in that Box, revelation and absence of the essence. Only then does it write collection/quest progress and refresh/persist projections. Low-level record adapters retain their coordinator preconditions; callers must use the commit entry point for an acquisition transaction. |
| Physical inventory | The existing deck/Box rules and `CaelumInventoryService` retain native ownership and storage authority. A physical deck grants no essence. Activation requires captured essences, not a deck stored in the Box. |
| Presentation and matches | Tarot descriptions, selectors and timers consume domain queries. Existing pawn snapshots remain UI projections. Trucazo copies captured-Minor ownership into its own match-start awakening snapshot; ordinary Truco has separate match state and no new powers. Both match entry points check the physical deck through the inventory contract. |

Native 5.0.2 evidence exposed a retained timer with missing flight after crossing
from MAP01 into the hub: native `PowerFlight` is a hub power. The idempotent
restoration above fixes that existing contract violation without a save-schema
migration. Old saves missing the instance recover from the already-paid record.
Revision 1 initialization and physical-deck recovery retain their existing rules.

Rollback uses the original **5.0.2 package and original save together**, baseline
`135ae0f9`, with matching map geometry. Keep upgraded saves separate. Reproducible
before/after, old/new reload, hub return, original-pair rollback and bilingual
menu evidence is recorded in `assets/validation_503/RESULTS.json`. These isolated
engine fixtures do not replace author acceptance or establish multiplayer support.

## Inventory and equipment service (#118)

`equipment/CaelumInventoryService` is a stateless `Object play` service taking
the requesting `CaelumPlayer`. The pawn's 157 compatible adapters and the Box/deck
entry points delegate to it. All 604 pawn field declarations and 544 signatures
remain; native serialization, lifecycle ordering and class identities are intact.
The service adds no fields, singleton, global player lookup or second inventory.

| Boundary | Authority and operation contract |
| --- | --- |
| Identity and queries | `Actor.Inv` and each item's native `Owner` own instances. `FindNativeEquipmentItemById` searches that pawn only; `EnsureEquipmentItemId` observes/allocates the existing record counter and resolves collisions. Detached incoming items may obtain identity; foreign owned items cannot. Type/tier/size remain catalogue attributes, never substitutes for an instance ID. |
| Equipment and wear | Equip/unequip, exact activation and active-reference repair operate on owned instances. `SyncActiveModelsToNativeInventory` writes working-model wear to the exact IDs. Native weapon selectors, attacks and engine inventory copy/toss callbacks retain their roles. Foreign activation is rejected before changing selectors, models or the pawn. |
| Box and physical deck | Entitlement and migration revisions remain in `CaelumPersistentCharacterState`. `CaelumMagicBox.EnsureOwned` and deck `Owned`/`Grant` forward to the service. `InMagicBox` is location on a native item; weight reduction and slot counts are projections. The deck remains one protected physical item; stored essences and power/capture rules are not moved. |
| Capacity and acquisition | Shared weight-transition, Box-slot and prepared-output checks include existing reservations. Native pickup callbacks still perform the engine transfer/copy after service preflight, then notify the service. New pickups must be detached or owned by the requester; stack growth requires that requester's existing stack. A rejected capacity preflight allocates no equipment ID. |
| UI and previews | Formal rows and selection fields remain compatible cached projections. Play events resolve the selected ID/native entry and call the same service operations. Drawing consumes these projections; it has no independent mutable item collection. Foreign selection entries are ignored. Projection refresh retains its existing identity-reconciliation calls; it is not a pure serialization-free function. |
| Crafting, repair and dismantle | Reservation/count/consume helpers, prepared-output checks and existing output/repair/dismantle commits share the service. Recipe planning, station/session checks, recipe knowledge and time coordination remain with their existing owners and call pawn adapters. Complete reservations are checked before repair consumption. Task completion clears the active task, so repeating completion cannot grant another output. Exact target IDs and per-instance condition survive travel. |
| Commerce and rewards | Currency plans, weight/slot checks and product add/remove commit operations share the service. Merchant sessions/prices/stock and the prisoner's claimed flag remain their existing coordinators' responsibility. They validate before invoking internal commit helpers and mark reward completion only after payment succeeds. Calling a low-level commit without its coordinator's preconditions is not a new public transaction API. |
| Authored loans and native I/O | Quest-specific temporary grants/removal and engine `AttachToOwner`/copy/toss remain specialized existing lifecycle operations, not replacement ownership stores. Their existing inventory refresh/identity/capacity adapters now reach the service. This patch does not rewrite tutorial loan rules, native actor callbacks or recipe/catalogue data. |

Ownership guards precede mutation in ID allocation, exact activation, pickup and
stack preflight, selection and recovered-material merge. The full method/guard
manifest and token-equivalence proof are in `assets/validation_502/EXTRACTION.json`.
Apart from those explicit guards, moved statements, literals and call order are
unchanged. Existing native-equipment/weapon/Box/deck migration gates stay intact;
there is no new migration revision or parallel owner.

Rollback uses the preserved **original 5.0.1 package and original save together**
(source baseline `da7d33b8`), with matching historical map layout. Upgraded saves
are separate files. Native checks load an original save under 5.0.2, reload fresh
and upgraded saves, traverse MAP03/MAP02/MAP06 and return, and replay the original
pair. A newer save's downgrade or conversion of obsolete map layouts is not claimed.
Recorded evidence and limitations are in `assets/validation_502/RESULTS.json`;
ordinary author acceptance remains separate from these isolated fixtures.

## Player character and resource adapters (#117)

The pawn remains the serialized/native identity. `CaelumPlayerCharacter` and
`CaelumPlayerResources` are stateless `Object play` classes with static operations
taking the requesting pawn. They require the same live pawn/preconditions as the
original methods; they neither find `consoleplayer` nor allocate service instances.
The original signatures, defaults and return values remain callable on the pawn.

| Service / operations | State read or written / contract |
| --- | --- |
| Character: `ReadNewCharacter*`, `NewCharacterDraftIsReady`, `ClearNewCharacterDraftReady`, `ValidateLoadedNewCharacterDraft`, `ConsumeNewCharacterDraft`, `InitializeDirectMapCharacter` | Native per-player CVar draft and the pawn's existing profile/allocation objects. Invalid draft is cleared; valid draft is consumed once. Startup alone chooses restore versus creation; service loading never creates a character. Starting equipment uses the existing pawn adapter. |
| Character: `EnsureCurrentAttributeBalance`, `ApplyCharacterProfile` | Existing profile, attributes and derived models; same jewelry/Tarot/inventory calls and balance revision 3. Recalculation clamps reduced capacities without free health/Anima/Air. Native size/mass updates remain at the same point. No new migration revision. |
| Resources: adrenaline gain/decay/combat activity; consumable pulse; localized lucidity loss, accuracy, stun and pain timers | Live pawn fields. Shared constants and existing rest/dining/record operations remain authoritative. Existing events restart the combat timer, and the lucidity stun starts only on crossing its threshold. |
| Resources: survival state/consumption, health penalties, critical damage and natural regeneration | Existing hunger/thirst/sleep and fractional damage/healing accumulators. Rest/sleep, potable water, Constitution costs and native death path retain their ordering. Native health and `player.health` remain synchronized. |
| Resources: air regeneration, underwater cost/debt/recovery, jump cost and air performance | Existing Air and debt/timer fields; the same water-level/exemption checks and lesson callbacks. The pawn's native `CheckAirSupply` override still suppresses the parallel engine breath counter. |

`PostBeginPlay`, `PlayerThink`, `Tick`, `PreTravelled`, `Travelled`, `DamageMobj`,
`CheckAirSupply` and `AdvancePersonalTimeTic` retained their bodies in #117. #119
routes Tarot calls to its service and restores the native effect after travel. In
particular, personal time still orders Tarot/elemental state, resource operations,
combat timers and rest/time pumps once; the extracted methods add no extra tick.
Inventory, Tarot, attack dispatch, input latches and native selectors remain behind
their existing adapters for #118/#119 and later focused work. UI still reads the
existing projections and does not call resource operations while drawing.

All pawn fields, class names, method signatures and array identities are retained.
Native serialization and the explicit live-to-record/record-to-live copies below
continue to own persistence. The #116 old-save waiver is not used as #117 evidence:
the #117 harness creates a save with the accepted 5.0.0 package and loads it with
5.0.1, alongside fresh/reloaded saves and hub travel. Scope and actual outcomes
are recorded in `assets/validation_501/RESULTS.json`; this does not promise every
historical map layout is compatible.

Rollback: preserve the original 5.0.0 package and original save copies together;
restore both (or rebuild commit `6e8f0d66` with the matching map layout). Keep
5.0.1 saves separate. The native original-package/original-save replay is recorded
in the evidence; downgrading a 5.0.1 save is not a supported migration claim.

## V5.0 state ownership and compatibility contract (#116)

The architecture audit starts from #82 / 4.37.24 (`20143c31`). The author expanded
#116 on 2026-10-06 to begin refactoring without requiring compatibility with older
saves. This patch introduces no schema migration: `CaelumPlayerPresentation` is
stateless and the existing pawn fields/classes/method signatures are retained.
Earlier-save compatibility is not an acceptance claim. Fresh saves made by the
current implementation must still save/load correctly; the waiver does not
authorize lost items, duplicated rewards or divergent owners during ordinary play.

### Single-owner state table

Paths use `src/caelum/` unless stated otherwise. All symbols and declared field
identities are indexed by `assets/validation_500/SOURCE_AUDIT.json`. The table
distinguishes live authority from travel copies and presentation, including objects
that the engine serializes even when they are semantically caches.

| State / concrete class and fields | Authoritative owner and lifetime | Readers, copies and mutation boundary |
| --- | --- | --- |
| Player identity: `player/CaelumPlayer.CharacterProfile`, `CharacterAllocation`; `CaelumCharacterProfile.Race/FirstClass/SecondClass/Sex/HeightChoice` | Confirmed pawn's live objects | `CaelumCharacterCreationMenu` is a draft. `ConsumeNewCharacterDraft` consumes new-character CVars; `PersistCharacterState` copies into record `Race`, classes, `LayerBonus`, `AttributeBonus`; restoration is explicit. Never reapply global preferences to a loaded character. |
| `Attributes`, `DerivedStats`, `ArmorModel`, `ShieldModel`, `WeaponModel` | Pawn-owned calculated/equipped working models | Catalogue/rule data computes values. Equipped durability is synchronized with exact native items by `SyncActiveModelsToNativeInventory`; models are not additional item ownership. |
| Physical equipment: `equipment/CaelumEquipmentItem.ItemId`, `EquipmentKind`, `ItemType`, `Tier`, `EquipmentSize`, `Durability`, `Equipped`, `InMagicBox` | Exact native item attached through `Actor.Inv` | `EnsureEquipmentItemId` allocates from record `NextEquipmentItemId`; IDs and `EquippedArmorItemId[]`, `EquippedShieldItemId`, `ActiveWeaponItemId`, amulet/seal IDs identify instances, not catalogue rows. |
| Materials, ammo, currency, consumables, deck: `CaelumSpecialInventoryItem`, `CaelumCurrencyItem`, `CaelumTarotDeck`, `Amount`, `InMagicBox` | Native inventory stacks/items owned by the specific pawn | Weight, counts and HUD money are projections. Box content stays in native inventory with routing flags; it is not a second container database. |
| Box ownership and legacy equipment: `CaelumPersistentCharacterState.MagicBoxOwned`, `MagicBoxItemId`, `NativeEquipmentMigrationComplete`, `SizedOwnedWeaponDurability[]` | Character record owns entitlement, stable ID counter and legacy migration ledger | Pawn `MagicBoxOwned` is a live synchronized value. Historical arrays must not recreate discarded items after native migration completes. Preserve copy direction when moving methods. |
| Resources: `CaelumPlayer.health`, `CurrentAnima`, `CurrentAir`, `CurrentAdrenaline`, `CurrentLucidity`, `CurrentHunger/Thirst/Sleep`, underwater debt fields | Live pawn / native health | Record `StoredHealth`, `StoredAnima`, `StoredAir`, remaining stored resources and debt are travel snapshots. `AdvancePersonalTimeTic` advances the live resources; HUD refresh must not consume time. |
| Crafting: pawn `CraftingTaskActive`, task kind/recipe/tier/size, `CraftingTaskTargetItemId`, reservations/output arrays and remaining seconds | Pawn owns active live task; `CaelumPersistentCharacterState` carries explicit travel snapshot | `StoreCraftingTaskState`/`LoadCraftingTaskState` define the handoff. `transient CraftingBrowser` is reconstructed. Selection/preview does not reserve materials twice. |
| Merchant: record `PalomoMerchantStock[]`, `PalomoMerchantWalletCopper`, `PalomoDiscountGranted` | Persistent character merchant relationship | Pawn session/visible-list/currency-plan fields are mirrors or temporary transaction plans. Relocating Palomo must not reset stock/wallet or negotiations. |
| Quests/factions/prisoners: record `QuestState[]`, `QuestStage[]`, `QuestObjective*[]`, `QuestRewardClaimed[]`, `MainM00Flag[]`, `FactionMember[]`, `FactionReputation[]`, `PrisonerRescueState[]`, `PrisonerRewardClaimed[]` | `CaelumPersistentCharacterState` attached to the requesting character | Controllers and dialogue transitions mutate the record; `CaelumQuestCatalogue` derives status, NPCs/tokens and `Journal*` display it. Rescue/extraction/payment remain distinct and idempotent. |
| Tarot: record `TarotOwned[]`, `TarotSelected[]`, `TarotActive[]`, `TarotEffectTics`, `TarotCooldownTics`, `TarotPowerRevision`, `TarotDeckRevision` | One canonical character record; `CaelumTarotService` implements powers behind retained adapters; physical deck ownership uses `CaelumInventoryService` | `Tarot*Snapshot` and Journal cursor do not own cards or selected powers. Array IDs remain 0–77; Fool 0, Ace 36, Knight 60. Capture, select and activate remain separate operations. |
| World discovery: record `WorldLocationVisited[]`, `WorldConnectionKnown[]`, `WorldConnectionTraversed[]`, `WorldPendingConnection` | Character record | `CaelumWorldProgress` and world catalogue use stable IDs. The Journal world page is a view, not shared campaign authority. |
| Clock/calendar/weather/schedule: `world/CaelumWorldClock.CompletedDays/DayTics`, Limbo counters; `CaelumCalendarState`, `CaelumWeatherState`, `CaelumScheduleState` | Separate inventory states on the character | `CaelumWorldClockTicker` runs only with one participant; accelerated time, travel and schedule synchronization call the same existing operations. Shared time across players is unimplemented. |
| Journey/rest/time skip: `CaelumJourneyState.Sequence/Status/ConnectionId`, `CaelumJourneyPlan`, `CaelumRestState`, `CaelumTimeAdvanceState`, `CaelumTimeSkipState` | Pawn-owned inventory state with map/session references | Begin/confirm/cancel/arrive operations own transitions; UI and temporary camera/freeze state are reconstructed or validated at their existing hooks. |
| Trucazo/Truco: `trucazo/CaelumTrucazoMatch`, `CaelumTrucoMatch`, deck/hands/phase/score and opponent reference | Match inventory attached to the player | Menus dispatch actions; `CaelumTrucoRules`/`CaelumTrucazoRules` define rules. Do not confuse match decks with owned campaign essences. |
| MAP06: `CaelumPortSiege.SetupRevision`, `Attackers`, `Defenders`, `Guns`, `Gates`, `Groups`, `CommandDirty`; `CaelumSiegeCombatant.Body/StableIdentity/CommandLeader/CombatTarget`; gate/ram/cannon instance fields | Map-local controller and actual actor instances | Hub revisit/save retains roster, deployment and casualties. `TargetingRevision` rebuilds derived perception; `SetupRevision` prevents redeployment. Character narrative/rewards remain in character state. |
| Physics contacts: `src/impactphysics/ImpactPhysics.zs: ImpactContactState.FirstActor/SecondActor/LastResolutionTick`; pawn/actor `ImpactContacts` | One shared contact object referenced by both bodies | Impact adapters apply game-specific damage; generic math must not gain dependencies on player, quest or UI classes. Never duplicate a contact's per-tic resolution. |
| Presentation: pawn `HUD*`, `Journal*`, `Tarot*Snapshot`, lesson snapshots; Journal user CVars | Derived play-scope snapshots plus local UI navigation | New `CaelumPlayerPresentation` fills the existing fields. It retains legacy ensure/init calls in the social refresh; no timer advancement, card grant or independent saved service instance is added. |

### Lifecycle and input/selector boundary

`PostBeginPlay` allocates missing pawn models, attempts record restoration, and only
then consumes the new-character draft or initializes the direct-map test profile.
It is not a substitute for save-load handling. `PreTravelled` closes sessions,
persists the live state, then calls the native hook; `Travelled` calls its native
hook and restores the record. Normal save/load is native object serialization;
`WorldLoaded(IsSaveGame/IsReopen)` handlers and per-tic revision guards have their
own roles. Do not rerun new-character initialization on load or deploy a new siege
on hub return. `PlayerThink` handles input/latches before normal movement;
`Tick` retains initialization/migration, native tick, contacts, sessions,
presentation, resources and time-pump ordering. Moving a method must not reorder it.

Input is part of the public contract:

- `KEYCONF` bindings and aliases, existing `ca_*` event names/arguments and
  `CVARINFO` user selectors retain their meaning and player ownership. Defaults
  stay Tab Journal, M automap, B User2/Seal, R Reload, F Zoom, T User3/Tarot;
  remapped controls remain valid. Fire/AltFire, Use and User1/User4 retain behavior.
- `CaelumJournalOverlay`/`CaelumJournalInput` own local navigation and send
  `SendNetworkEvent` requests. `CaelumDebugOverlay.NetworkProcess(ConsoleEvent)`
  resolves the event's current pawn through `CaelumPlayerAuthority.FromNetworkPlayer`;
  domain operations must receive that pawn,
  never substitute `consoleplayer` in authoritative play logic. This routing
  pattern alone does not establish complete multiplayer safety.
- Native `CaelumEquippedWeapon`, family/physical/magic selector classes in
  `CaelumPlayableWeapons.zs` use `invoker.Owner`, then the pawn adapters
  (`ActivateEquippedWeaponFamily`, `PerformFamilyPrimaryAttack`, etc.). Preserve
  their class names, slot numbers, Ready/Select/Fire/AltFire/reload/zoom states,
  action signatures, pending/ready-weapon transitions and exact item references.
- `FormalInventorySelectionIndex` selects a presentation row;
  `FormalInventoryRowItemId[]` and equipment/crafting target IDs identify exact
  instances. Journal cursors and filters select presentation rows. Preserve
  ordering, stable catalogue/faction/quest IDs, page count, English/Spanish keys,
  press/hold/release latches and session-close behavior. The HUD cannot mutate
  authoritative gameplay while rendering.

### Migration, reversibility and rollback

This slice keeps existing class/field identities, array sizes, revision fields and
public signatures; no new migration revision is appropriate for a stateless
method move. Future schema-changing slices must state what is retained, rebuilt
or transformed and whether the author's save waiver applies to that specific work.
Outside that waiver, migrations require a version, idempotent repeat-load tests,
explicit reverse/backup strategy and affected current/legacy map variants.

Keep the original package and save copies. For a future field move, prefer an old
serialized field plus a forwarding adapter until migration is validated; do not
copy ownership into two active registries. For rollback of #116, rebuild commit
`20143c31` or revert the focused runtime extraction and use the matching original
package/save copies. Do not downgrade by overwriting the only current save, and do
not mix regenerated maps with saves that already visited another layout. No
automatic conversion of legacy MAP02/MAP06 geometry is introduced. The current
author waiver removes old-save compatibility as this issue's gate, not the need
to state the rollback boundary honestly.

## 4.37.24 — Export defaults and final integration contract (#82)

The portable export initializes its own user/gzdoom.ini once. Before that file
exists, the launcher executes default_controls.cfg after loading the package:
Tab -> ca_journal_toggle; M -> togglemap; B -> +user2 (equipped Seal); R -> +reload;
F -> +zoom; T -> +user3 (selected captured Tarot essences). T was explicitly
chosen by the author. Later launches preserve the user's INI and customized
bindings. KEYCONF also advertises the same defaults for unassigned keys when
the package is used directly. Native defaultbind does not guarantee overriding
an existing binding; the portable first-start configuration supplies that role.

These are remappable inputs, not new abilities. Reload retains its ranged reload
or melee/magic charge behavior; Zoom retains block, eligible sweep or ranged ADS.
Rest/crafting and Journal contextual input retain their existing dispatch and
ability restrictions. No allocation, balance, cost/cooldown, save schema or
campaign geometry changes are made by the closing delivery.

The scope remains MAP01 -> MAP02 -> MAP06; MAP03 is diagnostic. All 78 physical
cards are distinct from captured essences. The current campaign grants El Loco,
Ace of Cups and Knight of Wands, with the accepted Box-gated capture and shared
activation contract. Physical deck ownership permits NPC Trucazo and grants no
unearned passive bonus, collection percentage or power. Prisoner intelligence
follows successful payment; siege victory requires both original objectives.

The empty Tarot Journal now describes the accepted early upstairs deck handoff
and the later Box requirement in both languages; it no longer claims those
separate handoffs happen together. This corrects help text, not reward timing.

## 4.37.23 - Creation descriptions and authoritative preview (#112)

Creation now explains the highlighted choice before confirmation. Spanish
headings are "¿Qué quieres ser?" and "Tus opciones son"; second-class options
and the final summary show the profession returned by the profile mapping.
Repeated classes retain specialization, and pair order remains irrelevant.

Descriptions follow the implemented attribute audit, current derived-stat
consumers and the abilities catalog. Sleep is the implemented Arcanist ability;
the other profession and racial abilities are explicitly marked planned.
Empathy does not promise a working general healing system, and Insight does
not promise implemented hidden-object detection. No new restrictions or
penalties are invented as weaknesses; smaller contributions are relative.

The issue text mentioned Engineering and Wisdom, but the game's technical
family is Agility, Dexterity and Resilience. These real attributes and the
existing Physical/Technical/Social/Mental order are preserved. There are no
attribute renames or added mechanics.

A pre-existing creator-only copy of distribution pattern 2 used Social 3 /
Mental 5; the actual profile and canonical rules use Social 5 / Mental 3.
The author explicitly authorized the fix on 2026-10-05 after the discrepancy
was reported. Both paths now use CaelumCharacterProfile.DistributionFor.
For a Human/Priest/Priest profile the preview correctly shows Social 15 and
Mental 9, and refuses a family point at the existing cap of 15. This corrects
the preview and its existing cap check; it does not rebalance the actual
profile. Four family points, thirty individual points, refunds, individual
caps and mandatory completion keep their rules. Existing saves are unchanged.

## 4.37.22 - Shield presentation follows the equipped item (#106)

The shared first-person renderer resolves BUCKLER/KITE/TOWER/MAGIC from the
actual native equipped shield. All three tiers and five equipment sizes use the
same art family per type. Existing shield usability, durability and weapon
compatibility determine visibility; giant gauntlets do not display an external
shield. Their dedicated T1-T3 boxer guard follows the existing native block
source, with no new protection or attack rule. The native block toggle still owns entry, continuation and cancellation.
Holding block keeps the frontal pose and left grip fixed until that state ends;
the right-hand/weapon presentation resumes on release. Unarmed compatible
equipment uses the same shield controller, replacing the free left fist.

This patch changes presentation only. Coverage, defense, weight, durability,
Air, damage, attack cadence, recipes and inventory/progression schemas retain
their definitions. New presentation caches are transient and rebuilt from
existing equipped-item state after loading. Existing weapon state indices and
the original shield/hand PNGs are preserved. ASSETS holds registration and
provenance; validation_43722 records static and native evidence separately from
author acceptance.

## 4.37.21 - New-character introduction and exit (#103)

Author decisions, 2026-10-04: show the welcome only after a valid character
creation; one page writes its text gradually, using the native GZDoom text-screen
defaults (10 initial tics, 2 tics per Unicode character). One key or left click
reveals the whole page without starting play; a subsequent press begins MAP01.
Keyboard repeat is ignored. Controller A/B follow the same two-stage action;
repeating controller direction axes do not skip the reading. There is no timed
advance and no replay on save load, hub return or direct development map load.
CA_MUS01 plays during the page; MAPINFO restores CA_MUS02 on MAP01 entry.
A save loaded by console while the page is open discards its pending menu chain
and unconsumed creation draft; other menus are unaffected. This interface-only
cleanup is not a saved-state migration.

The text reads up to two current bindings for each basic action, explicitly
showing unbound actions. Movement, looking, jump, run/walk, Use, weapon actions,
Journal/inventory and time skip are explained alongside hunger, thirst, sleep,
Air and journey provisions. These are descriptions of existing rules, not new
costs or controls. Strings are bilingual; exact author-supplied Spanish opening
and ending remain in LANGUAGE. No text is imported from the narrative slides.

Main-menu Quit and F10 use the native confirmation with a project prompt.
No/Escape cancels normally. Yes opens the approved farewell image; the next
key/left click invokes the retained native callback, QuitSound and shutdown.
ENDOOM is disabled per game because that legacy surface accepts text, not PNG.
Direct console quit, m_quickexit and Windows Alt+F4 bypass the presentation; those native paths
remain available. No global user sound/ENDOOM settings are overwritten.
The requested 15% master volume, with music/effects enabled, is test configuration
only. CreditPage/TitlePage, port completion and saved progression are preserved.

## 4.37.20 - Training target presentation (#98)

The shared Caella/Rulo dummy now renders as a textured 3D model. Its actor
collision remains Radius 21 / Height 72, independent of the visible mesh.
The base actor retains Health 1000000 and its original Spawn/Death frame;
the MAP01 practice subclass still ignores damage, movement and wear.
There are no new hit, recovery, destruction or reward mechanics. Actual valid
impacts still determine practice credit; misses and unrelated targets do not.
Existing quest flags, loan IDs, completion gates and save fields are unchanged.
Old saved actors acquire the model through MODELDEF without respawn, migration
or a new schema revision. Original saves/packages remain the rollback path.

## 4.37.19 - Palomo's necklace and canonical shield names (#96)

Author decision, 2026-10-04: choose and receive the T1 amulet with Palomo;
Caella teaches its existing recipe. This supersedes the amulet role assignment
in #63 and older sections. The other four equipment choices still require
their established crafting flow; the necklace adds no progression gate.

After following Palomo upstairs, his equipment menu offers the four existing
T1 amulets: Ruby, Sapphire, Emerald and Topaz. Review the canonical name,
catalogue weight and equipped attribute bonuses before confirming. Confirmation
fixes MainM00AmuletChoice and delivers the matching actual CaelumAmuletPickup
once, without equipping it or replacing another accessory. No new recipe,
bonus, weight, art or item type is introduced. Later Palomo final/Box/Fool
pages also expose this choice so a still-unchosen MAP01 character can return.

Native capacity checks prefer carried inventory and then an accessible owned
Box with both slot and weight capacity. If neither fits, the choice remains
saved while delivery is pending; the dialogue states that nothing was delivered.
The pending grant retries on confirmation or the periodic migration check once
there is room. The normal acquired-item notification occurs only for a newly
attached item. Selling, dropping, transferring or losing an already settled
gift never creates a replacement. Existing owned equipment survives departure
under #63, including this gift; the first weapon must still be crafted.

Caella's post-trial amulet page teaches only the selected existing recipe and
its component dependencies. Before selection it refers to Palomo; afterward it
reports learned/pending knowledge. She cannot pick or change the amulet. A new
gift already owned when learning requires no extra tutorial raw-material quota.
Already learned recipes, issued supplies and active task reservations retain
their previous state. Repeated teaching is idempotent.

Save migration: MainM00NecklaceRevision defaults to 0 and reaches 1 only after
successful delivery or recognition; MainM00NecklaceItemId stores the settled
native identity. An existing selected T1 owned by the player is recognized in
carried inventory, equipped or in the Box without changing its ID, condition or
placement. A different type, a T2 or a loan does not substitute for it. Old
selected saves without that T1 receive it when capacity allows, including an
already completed tutorial. Unchosen saves remain unchosen. An active task for
that same T1 defers creation until completion (recognize its output) or cancel
(retry the pending grant); no task or reservation is cancelled by migration.
All old USDF page slots remain at their original indices; new conversation
43633 is appended. Legacy Caella preview slots become recipe/referral pages.
The handoff between Palomo menus is transient. Rollback uses the preserved
original save with its original package, not a newly saved file downgraded to
the old build.

Shield options 0-3 use the same localization keys as inventory: buckler / kite
shield / tower shield / magic shield; Spanish: rodela / escudo de lagrima /
escudo de torre / escudo magico (accented in game). Preview, confirmation and
plan summary use FormatShieldName. Type IDs, stats and crafting are unchanged.
Evidence: assets/validation_43719. All three author checks passed 2026-10-04;
HISTORY records their IDs and qualifications.

## 4.37.18 - Craft, Repair, Dismantle and Tarot details (#91)

Oficios / Crafts has three icon subsections: **Craftear / Craft**,
**Reparar / Repair**, **Desarmar / Dismantle**. Craft contains only learned
recipes matching the category filter. Missing ingredients or infrastructure
disable starting, not visibility. It can be browsed outside a station.
An empty category explains that there are no learned matching recipes.

Repair and Dismantle list accessible weapon instances in the player's native
inventory, including equipped weapons and the owned Magic Box. Nearby drops,
NPC inventory and inaccessible Box contents are excluded. Each copy has its
stable item ID, tier, size, wear, location and applicable essence. Equipped,
temporary/protected, undamaged or unknown-recipe items remain visible with
their applicable reason. Repair recognizes the learned Pickaxe recipe.
Armor/shield task APIs remain available to their existing consumers; this
weapon browser does not widen the issue's ownership scope.

The existing material, proportional wear/recovery, rounding, efficiency,
station-network, carrying-capacity and time rules remain authoritative.
Repair previews required components and, when ready, the actual input
reservation after processing. Dismantle previews recovery. A blocked operation
does not promise a completion time. Confirm rechecks mode, exact identity,
ownership and current requirements; a stale row cannot select a different copy.
Browsing never creates reservations or changes an active task's outputs.
Lists refresh after learning, ownership changes and completion. Closing or
leaving the workbench still pauses; cancellation releases the reservation.

Controls: **1/2/3** select the operation; **F/D** also open Repair/Dismantle
without starting it. **Left/Right** or the wheel over the list selects entries;
**Up/Down** or the wheel over details scrolls text. **Enter/E** confirms the
selected operation. **G** filters Craft; **Space/R/B** change its tier, size
and batch. **X** adjusts craft/repair efficiency. **C** cancels a task,
**T** retains x60 and **Y** opens the time-skip selector. **Tab/Q** closes
Oficios; **PgUp/PgDn** changes the main Journal section. Native controller
direction/confirm/back bindings remain. Mouse clicks select main section
icons, operation icons, list rows and the bottom confirmation/status area.

Tarot exposes three labeled fields for the selected card: passive fixed and
collection bonuses; active world power with the existing shared 1000-Anima,
60-second/600-second-from-use rules; and the current Trucazo effect. The latter
explains captured Minor awakening, trick strength, Envido/row contribution or
Major exclusion, independently of world power selection. Traditional Truco
has no essence effects. No undefined power is invented. Uncaptured artwork
previews do not reveal powers or grant ownership. Physical deck possession
and captured essences remain separate. Up/Down or the wheel scrolls all three
fields; selection, remaining effect time and recharge stay visible.

## 4.37.17 - Pickaxe, gathering sounds and success notice (#89)

Author decisions, 2026-10-04: English/code **Pickaxe**, Spanish **Pico**;
weapon family/key **1**, alongside unarmed; **T1 only**. Primary is slashing for
chopping and secondary is piercing for mining. All numeric weapon statistics,
size-scaled weight and maximum durability use the actual T1 **axe**, not the
hatchet. At M, the existing axe weighs 8 kg, primary/secondary base damage is
140/160, and current maximum durability is 10,000. Shield compatibility, costs,
reach and the attack clock follow the axe. The mining pose turns the same
hybrid head while retaining the native grip, recovery and hand rig.
The author's rest-pose refinement tilts the tool 20 degrees clockwise around
that grip, with the native swing continuing from the same resting angle.

One learned recipe reuses the axe's ingredient types, ratios, rounding, size,
efficiency and station rules. At M/T1/100%, it consumes 5,600 Handle and 2,400
Weapon Head units. No T2/T3 recipe, vendor stock or enemy-drop source is added.
The output uses the existing inventory, repair, disassembly, weight and Box
rules. New physical crafting outputs explicitly carry the current durability
revision, preventing a new item from being scaled as an old save.

An eligible hit by the actual equipped Pickaxe multiplies the normal released
quantity by **10 for chopping** or **100 for mining**, once, before the existing
finite source and tutorial allowance caps. Remove only the released amount.
Fractional carry, resource type, renewal, spawn failure and pickup capacity
retain their shared behavior. Owning a Pickaxe while using another tool adds
no bonus; misses, wrong damage type, ordinary non-resource rocks and exhausted
sources yield nothing.

After a successful extraction, **every eligible weapon** plays one positional
material sound: wood/fiber chopping, stone/coal, metal ore, or crystal/gems.
The same confirmed event shows **Material extracted: <material>** / **Material
extraído: <material>** at screen center in **CaelumText**. The latest success
replaces the previous one; duration follows the existing notification setting.
Menus hide the notice. It confirms extraction, not an inventory pickup. Zero
extraction emits neither sound nor message. Mining OGGs remain unchanged; tala
uses an isolated one-shot from the approved long recording.

Ronnie gives the owned tool plus its recipe/component knowledge when the
lesson starts. It replaces the former sword loan. Palomo's four choices remain
intact and the selected weapon must still be crafted and shown to Ronnie;
the gift never completes that objective and no duplicate Pickaxe is required.
Equipping it again neither repairs nor replaces it. Selling, transferring or
breaking the gift does not replay the reward; its recipe remains learned.
The owned Pickaxe survives completion and narrative departure with other owned
equipment. Old temporary sword instances follow their original return rules;
owned swords are never removed by the new grant.

Save contract: playable type 20, catalogue type 16, recipe 131, recipe book
revision 5 and gift revision 1 are additive. Existing recipe indices 0–130 and
ownership indices 0–299 retain their meanings. Started/completed old saves
receive one gift through the normal capacity rules, even outside MAP01; a full
inventory defers delivery. Repeated loads/updates do not replenish quotas,
reset progress or heal the gift. Keep the original save and matching old PK3
for rollback; migration tests never overwrite those originals. Earlier Ronnie
loan/return wording below describes the pre-#89 flow; this section supersedes it.

## 4.37.16 - Compass and menu pointers (#87)

The top-left compass follows the rendered camera angle, including stationary
turning. Strafing and walking backward do not change its heading. World north
is +Y, east +X; this matches MAP02's cardinal blocks and MAP06's city exits.
The needle and 000-359 bearing update continuously; the nearest of eight
directions appears below it. West is O/SO/NO in Spanish and W/SW/NW in English.
The cardinal letters are centered by visible glyph bounds, compensating for
CaelumMono's trailing kerning and padding. The dial shares their center and
uses silver laurels, a dark-metal rim and a subdued Sun of May background.

The compass uses the native hud_scale and hud_scalefactor controls, with
resolution-based bounds. It hides in menus, dialogue, crafting, Journal and
after death. The existing twenty-message feed reserves a left strip whose
width follows the compass; its entry count and right column stay unchanged.
The standard four native console-notification rows are reserved when enabled.
It introduces no saved fields, character migration or gameplay changes.

Both native skull selector frames resolve to the same transparent Sun of May,
with a face and 16 straight/16 wavy alternating rays. Native navigation and
selection behavior are retained. GameInfo selects the 32-pixel silver C moon
cursor, with hotspot (31,7) at its upper horn. An explicit user vid_cursor
override still takes precedence. Physical click/drag passed author acceptance on 2026-10-04.

## 4.37.15 - Traditional Truco ranked mode (#101)

Author decisions, 2026-10-04: alongside the accepted Trucazo practice, Argento
offers traditional Argentine Truco, called ranked. The author confirmed a
30-point match (15 malas / 15 buenas), optional Flor, and no rating service yet.
No health, row damage, character attributes, essences, powers, wagers, prizes
or campaign transactions apply. The physical deck from Argento (#164) is required.
The same 40 equivalent cards already used as playable Minors provide the art:
1-7, Page/Sota = Spanish 10, Knight/Caballero = 11, King = 12, in four suits.
Only those 40 enter the shared shuffle; deal three each, without replenishment.

- Hierarchy: Sword Ace, Wand Ace, Sword 7, Coin 7, 3, 2, other Aces,
  Kings, Knights, Pages, other 7s, 6, 5, 4. Equal strengths are parda.
  A won trick plus a parda wins the hand after two; split wins require the
  third. A tied third favors the first winner; three pardas favor mano.
  A trick winner leads next; a parda preserves the previous lead. Mano
  alternates between hands; the first mano is randomly selected.
- Truco/Retruco/Vale 4 are worth 2/3/4; refusal awards the previous stake,
  initially 1. The accepting side owns the next raise. Irme al mazo folds
  the hand at its current stake; before the player's first card, unsettled
  Envido additionally awards the opponent 1 (explicitly confirmed).
- Envido uses the best same-suit pair +20, figures 0, otherwise the highest
  number. Ties favor mano. Envido adds 2, up to twice; Real Envido adds 3;
  after Real only Falta may raise. Refusal awards the previous call, or 1
  for the first. Calls occur before the caller's first card in the first
  trick; responding Envido suspends a pending Truco and then restores it.
- Falta Envido and Contra Flor al Resto award the leader's distance to 15
  while both are in malas, otherwise to 30. This replaces, rather than adds
  to, the current side-game bid. The author explicitly confirmed this variant.
- When enabled, Flor is mandatory for three same-suit cards, valued as their
  sum +20 (figures 0), with ties to mano. It must be declared before playing
  the first card and cancels Envido. Unopposed Flor gives 3; two declared
  Flors without a raise or accepted Contra Flor give the winner 6. Declining
  with Flor gives the caller 4, also for Contra Flor al Resto; without Flor
  gives 3. These refusal variants were explicitly confirmed by the author.
- Points are awarded immediately; reaching or exceeding 30 ends the match,
  including an Envido/Flor resolved before the hand. Abandoning the match
  requires confirmation and is defeat. Save/load remains available.

The NPC policy receives its own hand and public cards/calls, never the hidden
opposing hand/deck. The traditional inventory starts at revision 1 only when
needed; old saves need no mutation of their existing match or character schema.
Original saves and their original package remain the rollback route. Flor can
change only before beginning; saved live matches keep their option and exact
pending calls. Traditional and practice menus use separate state/event names.

## 4.37.14a - Argento dialogue order (#99)

Argento offers Trucazo practice after the available story/service replies
and before goodbye. This applies to the early, offer, progress and completed
conversation pages; a page with no other reply still has practice and goodbye.
No new page, condition, action or match rule is introduced.

## 4.37.14 - Early physical deck delivery (#97)

Historical timing, superseded by #164: Argento now gives the deck. The ownership
and capacity rules below remain; Palomo no longer delivers or replaces it.

After Palomo completes his existing route upstairs, successfully opening his
conversation grants the protected 78-card physical Tarot deck immediately,
before selecting any reply or equipment plan. His foyer conversation and
interaction during the route grant nothing. The Box keeps its later quest
requirements and acceptance choice; accepting it can still retry a blocked
handoff but never duplicates a granted deck.

The original 780 g/one-slot capacity rules and TarotDeckGranted/revision-1
record remain authoritative. If the deck cannot fit, Palomo explains that the
player must make room and speak again. Closing immediately, revisiting and
save/load retain the grant. A pre-change save with no deck can receive it on
its next eligible conversation; previously granted decks and essences remain
unchanged. Store the carried deck in the owned Box before capturing an essence.
This supersedes #80's original Box-linked delivery timing only.

## 4.37.13a - Crafting time help (#93)

Crafting shows Y (keyboard) for the existing time-skip selector and T for
acceleration in its lower help and active-task status. Recipe/step/family/tier/
batch/size/efficiency navigation shares the first help row; actions, time and
closing share the second. Y on a controller retains its existing filter action.
The #64 time-skip rules and controls below remain authoritative and unchanged.

## 4.37.11 — Guard recognition as a persistent Journal clue (#79)

Use a living local guard in MAP06, within the existing Use reach and line of
sight. The native USDF menu identifies the protagonist as captain and offers an
amnesiac response. The first successfully opened greeting records clue 9,
`QUEST_GUARD_CAPTAIN`, as completed; closing without selecting a response still
preserves the information already heard. Later guards and repeat visits use the
repeat greeting/response. No action grants money, reputation, items, membership,
class changes, command abilities or memories, and no prisoner count gates it.
The Journal lists "They call me captain" under main/completed records: completion
means the clue was heard, not that the protagonist recovered his past.

`CaelumGuardCaptainDialogue` delegates the actual conversation to the existing
faction/dialogue opener with no faction condition. Native fighting, dead,
sleeping/stunned, out-of-range, blocked-sight, already-speaking and unfinished
character creation conditions cannot grant the clue. A stale INCOMBAT flag is
ignored only when there is no living hostile target or the siege is over. The
guard's route pauses during its own non-pausing conversation and resumes afterward;
protection, combat stats, cannon ownership and army control are unchanged.

Persistent quest arrays retain their 32-slot schema. QuestStateVersion 3 clears
only previously unused slot 9 for revision-2 saves, once; it never guesses knowledge
from port visits, rewards or siege completion. Older revision-1 migration remains
intact. The Journal's derived arrays expand from 9 to 10 entries, and rescue
classification remains explicitly bounded to four prisoners. Dialogue IDs 43631/32
and their four pages are appended to CAPALOMO, preserving all existing page indexes.
Original saves/package remain the rollback path; no save rewriting is required.

## 4.37.10 — Prisoner siege intelligence after payment (#78)

The existing port payment confirmation now also gives the siege briefing in
English/Spanish. Each survivor must first be extracted alive and actually deliver
the accepted 25 gold / +10 own-faction reward. Failed capacity checks, captive or
following prisoners and unpaid port conversations do not unlock this information.
The existing claimed flag gates repeat access; re-reading never grants anything.
The paid rescue's Journal detail and the port siege quest share the same text.

`CaelumSiegeIntelligence` reads the existing quest snapshot: stage 0 means no
observed encounter yet, stage 1 active, stage 2 completed. Successful payment
discovers the existing quest at stage 0 if necessary. The ordinary encounter still
discovers/updates it for zero rescues. The controller's sealed twelve-machine
roster and confirmed victory remain authoritative; both stopping the commander
and neutralizing all twelve hostile machines are required. Defender cannons do
not count. No four-prisoner requirement or new siege trigger was introduced.

Location comes from `CaelumWorldCatalogue.LOCATION_PORT`. During/after the assault,
the briefing displays the recorded `port16_siege_start` / `port16_siege_end` date
from the same calendar events created by `CaelumPortSiege.Calendar`. Historical #78 MAP06
deployed on entry; #133 supersedes that timing with the current scheduled siege.
The former pending date/hour decision is resolved in the #133 contract above.
Before an encounter the text explicitly says the date/hour is unconfirmed; a
legacy save without a dated event does not fabricate a historical timestamp.

Native conversation pages and their global indexes are unchanged. `userstring`
tags format existing paid pages and the two existing port voice pages. Text
updates while the non-pausing conversation remains open, including victory.
Delayed start narration also reflects completion instead of describing an ended
siege as still active. Payment and completion events retain their original
pending/delivered bits; the normal queue waits until the prisoner dialogue closes.

No new serialized field, schema or event handler is added. Existing paid saves
recover Journal access idempotently from the accepted claimed flags without
replaying rewards or modifying the narration queue. Existing quest progress is
preserved. Original saves/packages remain the rollback path; use the matching
legacy map option for saves that visited older geometry. #78 changes no maps.
Static/native results are in `assets/validation_43710/RESULTS.json`; author
acceptance remains separate in `pending_test.txt`.

## 4.37.9 — Expanded city, southern siege and campaign route (#77)

The final city footprint is 960 × 960 m at 32 MU/m, with 288 constructions:
160 houses, 64 shops, 24 factories and 40 construction sites. Streets connect
their entrances, the preserved harbor and the fortified perimeter. North/west
and six southern gates retain the accepted 96-MU breakable gate actors in
128-MU-wide masonry passages; arches have 96 MU clear height. The eastern dock
arch is open. Native character collision tiers 1–7 remain supported.

The wall walk stands at 256 MU and tower gun decks at 384 MU; 16-MU risers
provide physical access. The four towers project beyond the wall corners so
their artillery has real exterior firing lines. Movement and projectiles retain
native collision and gravity. The northern tower guns can engage the two
southern flank gun crews without a range or wall-penetration exemption.

The author's sixfold population change means 6,000 Mandingas, one commander
and 600 defenders. Five small rams, one large ram and six attacking cannons
remain the twelve hostile objectives. There are 36 defending cannons: eight
per wall and one on each tower. The eight southern wall guns and four tower
guns are active; 24 staffed guns remain in reserve for this southern assault.
All 72 defensive operators belong to the 600 soldiers, leaving 528 reserves.
Existing defender attributes/equipment, cannon loading/ballistics, ram crews,
and gate materials remain unchanged. The later author direction below retires
the port enemy zero-resource attack trial.

Author follow-up, 2026-10-03: each attacking command group has at most 100
members, including its leader. LAYOUT.json owns command_group_limit. The bounded
neighbor traversal leaves excess actors for subsequent groups instead of joining
an unlimited connected component. Every queued member participates in leader
election: Zupay priority 1, Mandinga priority 2, stable roster identity for ties.
The 1,024-MU visibility links and 35-tic/death-triggered refresh remain. All
6,001 attackers stay simulated. Existing port saves regroup on the next ordinary
refresh; no roster, geometry or save-schema replacement is required.

Further author decisions, 2026-10-03, apply to the shared combat actors:

- Below #128's high-density threshold, Mandingas in the siege choose the nearest visible living player or guard.
  A leader's candidate cannot hide a closer opponent. Perception uses the
  existing eight-tic data cadence, staggered by identity; death or lost sight
  invalidates the cached target. Hidden lane goals remain approach destinations.
- NPC melee attacks require native melee reach; magic checks the actual muzzle
  and target center against the caster's derived range and line of sight. Release
  checks repeat the preparation check, so a target can escape during wind-up.
  Existing natural-melee and T1 staff costs cover legacy NPC attacks without
  an explicit cost. Profiled weapons, slam and bull running keep their own costs.
- An unaffordable attack triggers physical retreat, then idle once beyond the
  current opponent's horizontal attack envelope plus the retreating actor's
  radius. Armed opponents use their weapon/ability range; bulls retain charge
  range. Melee vertical overlap cannot prematurely count as safe distance.
  Native collision can obstruct retreat. Both full Air and full Anima are
  required to resume; neither resource is granted by entering recovery.
- Actual Pain interrupts recovery immediately. The next attempted attack still
  pays its cost and can trigger retreat again. Scripted boss flight, withdrawal
  and prisoner extraction retain priority. All living idle combat actors recover
  health, Air and Anima at twice their normal rates, using the chair factor.
- Seated players now also recover Anima at twice its normal rate, including
  time advancement and its forecast. Leaving the chair restores the normal rate;
  beds' Anima behavior remains unchanged. Existing needs checks still apply.
- Player bows, carbine and crossbow use catalogue range converted from meters
  to map units; player magic uses derived ability range, including charged,
  homing and multi-projectile casts. NPC and player projectiles share a native
  movement-distance budget clamped before collision. Blast radius remains a
  separate authored effect; javelin throwing retains its existing gravity and
  ballistic trajectory because it has no separately authored flight-range cap.

Recovery revision 1 and target-cache revision 1 initialize derived state once,
without replacing actors, restoring resources or resetting deaths/crew identities.
New recovery phases and remaining projectile distance serialize normally. Old
limited NPC flights retain recorded distance/age; old uncapped player shots
already in flight retain their original behavior until they end. Preserve the
original save/package for rollback; loading a newly saved recovery state into
an older executable package is not promised.

In the expanded city, a vacant defensive post selects the nearest eligible
reserve to its stair entrance. That same actor follows saved waypoints using
native TryMove at its existing See-state speed/cadence, with native A_Chase
obstacle avoidance. It climbs every level, approaches beside the carriage and
must be physically near the cannon to operate it. There is no teleport or new
soldier. Reserve positions keep access points free. Saved route progress is
idempotent; layout/setup revision 2 activates this behavior only on the new map.

Victory still requires all twelve hostile machines neutralized AND the commander
defeated, in either order. Half-health flight and survivor withdrawal use real
southern exit zones; withdrawal awards no kills. Knight capture and the endpoint
at (128,1856,0) retain their shared rules. Rescued prisoners still pay independent
25-gold/+10-own-faction rewards once, with no new supplies or shops' trading rules.

Connection 16/network revision 4 provides direct MAP02 → MAP06 without renumbering
old IDs/history. It retains the maze exit, Ace/Zupay prerequisites and 10 km
journey planner, calendar, provisions and caravan confirmation. Connection 2 is
inactive; legacy connection 8 remains for saves already in MAP03. Arrival and
prisoner/resource positions are preserved. No cardinal exit enters a diagnostic map.

Use a fresh/unvisited MAP06 for the expanded southern city. For a previously
visited port, select its exact geometry: --legacy-map06-north-city for the first
4.37.9 northern city, --legacy-map06-siege for 4.36.27–4.37.8, or --legacy-map06
for the pre-siege 4.36.26 port. These three alternatives are mutually exclusive;
each can accompany --legacy-map02. Existing populations, positions, casualties
and rewards stay in those saved layouts. Keep original saves/packages for
rollback; no old MAP06 geometry or army is reset or transplanted.
Current native/static evidence: assets/validation_4379/south. The author confirmed
all three #77 checks passed on 2026-10-03; HISTORY records acceptance separately
from the native results. Performance follow-up remains in #86.

## 4.37.8 — Corrected MAP02 material accounting (#75)

The #73/#75 supply contract below is unchanged. Its current per-instance ledger
is assets/validation_4378/MATERIAL_LEDGER.json, keyed by catalogue_index.
The archived 4.37.6 table accidentally joined recipe output to the chest-ordered
array position. For example, catalogue 39 is an Earth Bell, not the armor whose
hide budget occupied that row. At equipment size 0 its whole-batch reference is
252 raw emerald, 2,036 raw copper and 228 raw tin units. The correction affects
315 item/size rows across 63 instances; aggregate quantities and runtime stock
remain unchanged.

All 65 existing recipes produce one equipment instance at each of five sizes
from their allocated basics in isolated native completion tests. 100% remains
a budget reference. Ordinary crafting retains its selected efficiency, knowledge,
time, station and Box requirements. The fixture supplies those prerequisites
and skips task elapsed time; it does not establish that every crafting route is
available at MAP02's retained workshops. Existing author approval of the workshops
and the old-save waiver remains in force.

## 4.37.7 — Floor traps, flooded return and central lift (#74)

This revision replaces the former six pit stair exits and the #73 elevator
reservation. Upper progression, all other trap types, 100 junctions, 96 Mandingas,
192 rats, 39 material chests, prisoners, extraction and the boss route remain.

The six 128-by-128 apertures join one interconnected lower network. Its floor is
at -160 MU, water surface at -144 and ceiling at -32: 16 MU of native swimmable
water and 128 MU of clear height. These reuse the existing channel depth and
32-MU mapping grid; the maximum supported collision height is 74.67 MU. Water
uses established movement/Air rules, with no added damage, current or drowning
balance. Native tests observe water level 1 for the return route.

Exactly four permanent, keyless grates surround the 512-by-512 central platform:
south 44910, west 44911, east 44912 and north 44913. A closed grate opens only
from its exterior tunnel side. Opening any one calls the elevator to the lower
landing; it does not require opening the other three. Stand near that platform
edge and press Use again from inside to travel up to the original central start
at height 0. Use from a landing calls the lift to that landing; Use from inside
requests the other level. Descending from the start with all grates closed still
allows an upward return, without opening a grate from inside. Calls during an
existing movement do not create another mover; call again after it stops.

On the author's explicit #74 follow-up, a block whose normal entrance is closed
keeps its trapdoor covers solid and inactive, including for enemies. Opening
that entrance restores ordinary trap activation. The initially open south block
needs no additional condition. Native underside collision prevents jumping into
unopened blocks; the continuous upper slab separates every other lower passage.
No new keys, cell access, extraction condition or companion rule is introduced.
Followers retain their existing collision movement and distant catch-up behavior.

Enemy death supplies still appear once at their assigned original dry upper
anchors, including after deaths in water/pits; keys remain recoverable by the
normal surface route. This does not restore preplaced ground loot. Trap/grate
fields and native moving floors persist through current-layout saves and hub
travel. Old-layout save compatibility was explicitly waived by the author;
the preserved revision-3 source is provenance, not an automatic migration mode.

## 4.37.6 — Central hub, cardinal keys and finite supplies (#73/#75)

This revision supersedes the revision-2 coordinates and finished-equipment/ration
counts in the historical #10/#11 sections below. Ordinary arrival is `(0,0,0)`.
The initial open block is south. At the author's follow-up request, all four
entries are 2,208 MU from the center: minimum symmetric separation with one
32-MU wall strip between block footprints, including cells/refuges.
Return to the hub after each block:

`hub -> south [203 + cell 207] -> hub -> west [204 + cell 208] -> hub -> east
[205 + cell 209] -> hub -> north [206 + cell 210] -> extraction -> arena 206
-> Zupay defeat/confirmed retreat -> Ace of Cups -> MAP03 -> MAP06`.

Each progression key opens the next block entrance; 206 opens the northern arena.
Each key has one guaranteed Mandinga carrier inside its own accessible block,
outside the matching locked cell. Native locks, permanent openings, beds,
refuges, escort/extraction and boss/card/campaign rules are retained.
The author's follow-up requires the Zupay to remain inactive until its own
keyed gate opens. Closed native lines block AI sight; the sewer boss also skips
its actor tick, clears target/enemy references and zeroes velocity while that
gate is closed. Sound alerts or retained See states cannot start movement or
attacks early. Opening with key 206 resumes the existing boss/retreat behavior.
There are 100 junctions, 96 Mandingas (24/block), 192 rats (48/block), 45 traps,
39 chests, four prisoners/beds and the separate northern Zupay.

The 65 actual former equipment instances become their existing recipes' basic
inputs at 100% efficiency, including processed materials and component recipes.
Minimum recipe batches round upward at each layer; this is a material budget,
not free crafting or a change to player efficiency. The per-instance ledger
includes all five equipment sizes and summed basic-material quantities.
Preview follows recipient size without reserving stock. The first successful
withdrawal fixes that chest's shared size and budget; partial withdrawal, failed
capacity, other recipients, reload and hub travel cannot resize or refill it.
Material previews paginate with N. No recipe is learned by inspecting/collecting.
The author confirmed retaining existing stations: sewing/leather, jewelry and
shield-anvil routes may require another workshop and known recipes.

Exactly eight Mandingas carry one key each; 30 others carry one same-type
20-unit ammunition stack: 360 arrows and 240 bolts in total, following #183.
The other 58 Mandingas have no assigned object and therefore use the existing
#135 one-remaining-potion death rule. The 5.2.24/#220 generated predicate checks
actual assignments, not the whole mapped Mandinga TID range. Existing corpses
retain their death latches and receive no retroactive loot. Each rat carries one ration:
96 food and 96 water map-wide. These supplies are not preplaced on the floor.
Death releases each assignment once at its original dry, reachable map position,
so pit/crush/companion kills cannot destroy keys or leave them below the map.
The generated manifest publishes each carrier, stack, recovery anchor and lock.

The central `[-256,-256]..[256,256]` footprint is reserved for #74's elevator.
No lower tunnel, return grate or elevator is implemented here; current pit escape
geometry remains until #74. The reservation cannot bypass any surface gate.
The author's 2026-10-02 save waiver means fresh-map testing; no old snapshot
migration is claimed. Existing legacy-4.36.4 build selection remains available
for its original purpose, not as compatibility with the retired 4.37.5 geometry.


## 4.37.5 — Daily mansion provisions (#65)

This policy supersedes the historical one-time all-food allocation below.
Only MAP01 mansion tables receive automatic stock. Each existing provision slot
holds one established ration: small 4 = 2 food / 2 water; normal 18 = 9 / 9;
large 60 = 30 / 30. The six tables have 94 slots, with fresh totals of 47 food
and 47 water. Serving mass, water volume, digestion and recovery are unchanged.

Fresh tables receive their initial targets once. Every Limbo-local midnight,
SyncLocalDay fills only empty slots toward each target, food then water. Normal
play, T and Y use the same boundary. A multi-day skip consumes real portions
between refills; its numeric task forecast applies the same per-slot policy.
The exterior calendar remains frozen, and no wall-clock/offline catch-up occurs.

MansionProvisionRevision 1 and LastMansionRestockDay persist per table. Repeated
or older day notifications do nothing; missing several days supplies only one
current target, never a daily backlog. A full or obstructed table records the
day too, so withdrawing an item cannot claim its missed portion later that day.
Displays follow actual inventory ownership and preserve the existing models.

Deposited items and containers are never replaced to make room. Containers keep
their class and liters and occupy a slot; their water is not a new ration slot.
Consequently an occupied table can remain below a target. Saved all-food tables
have no reliable item provenance: migration keeps every ration and belonging,
retires only the old pending allocation, and fills available holes. Such tables
converge to the new ratio as excess old food is consumed and later days refill
the vacancies. Migration neither discards food nor invents overflow storage.
Keep the original save/package for rollback; upgraded saves are not claimed to
load in an older version. No map geometry or authored return route changes.

Palomo's bilingual food-source explanation now identifies local midnight and
states that removing a serving does not refill it immediately. Tables outside
MAP01 receive no automatic initial or daily supplies.

## 4.37.4 — Explicit time skipping and separate Limbo clock (#64)

Y opens a destination day/hour/minute selector under the shared #325 safety
policy above; valid rest/work contexts no longer need a separate geographic veto. Left/Right select the field,
Up/Down change it, Enter confirms, R recalculates the task default, and Q closes
or interrupts. Escape retains native pause. T remains the existing x105
fast-forward, with 104 extra integrated personal steps per normal engine step.
Neither mode simulates arbitrary world AI or physics. The skip yields between
batches, supports save/reload and retains actual partial progress on interruption.
The technical planning horizon is 30 local days, inherited from the journey
planner; destinations are expressed in whole minutes.

Input repair 5.1.11/#156: Q/R recognize the native character code as well as the
text fallback. Tab/controller B also cancel. During an active skip cancellation
stops it and keeps the result panel; a second cancellation closes it. Idle,
completed or pending-confirmation panels close without discarding completed work.
Enter still rejects a destination that is now in the past; select a future time
or reopen Y for a new default. A completed crafting task is not started again.

Author decisions, 2026-10-01: automatic sleep begins at the existing critical
10% Sleep threshold and wakes at 100%. Recovery remains 100 points per eight
local hours. Sleeping pauses all crafting ticks, including forced sleep;
reservations remain until the native task completes or is explicitly cancelled.
The skip resumes work at its original valid station after waking. On completion
or interruption the automatic session ends with its actual resource values.

Automatic care may use the whole safe location. MAP01 uses its actual available
tables and unoccupied furniture; other maps use the authored safe zone containing
the player and the support. The #325 local visible-enemy guard filters each remote support independently;
a remote threat does not veto the player's entire rest context.
No teleportation or additional travel-time balance is introduced. Work remains
standing. Waiting uses an available chair; sleep prefers the best available real
support, then an accessible owned sleeping bag with room, then existing ground
rest. Existing comfort factors and seated meal duration apply.

Provisions are real inventory transactions: accessible tables first, then carried
items, then the owned Box reserve. Partial water containers preserve their identity,
remaining volume and storage location. Automatic servings reuse the journey
trigger: wait until the whole dose fits, and never refresh an active food/water
effect. No new portion begins while asleep. Critical needs, new attacks, movement,
combat, invalid stations, unsupported effects or hazards interrupt safely.

With an active crafting task, the numeric preview accounts for real stock, food
effects, needs, healing/Air costs and sleep interruptions. Confirmation recalculates
from current state before starting. The preview never mutates inventory or awards
work; the runtime uses the native per-tic effects and task transaction. The final
completion minute rounds forward. Unsustainable needs, an upcoming siege, unsupported
forecast effects or the planning horizon report a blocker rather than a completion
date. A manually chosen destination still stops if its actual conditions become
unsafe. Daily table notifications and matching forecast hooks are provided here;
the 50/50 replenishment policy is the separate dependent issue #65.

CaelumWorldClock revision 1 adds persistent LimboDays/LimboDayTics while retaining
the legacy monotonic CompletedDays/DayTics and LimboSubTics for existing consumers.
126000 active-play personal tics equal one local hour in MAP01 (1:1). Normal play,
T and Y advance this same local clock; its midnight dispatches the daily hook.
The civil calendar anchors advance alongside the legacy counter only in Limbo,
keeping both campaign and diagnostic civil dates frozen. Outside time retains
the existing 20:1 pace and does not advance the Limbo counter. No computer-clock
or offline catch-up is used.

Older MAP01 saves seed local time once from their previously displayed counter;
outside saves start the new unused Limbo counter at zero. Existing civil dates,
quests, inventory, reservations and aggregate timestamps are preserved. Old
versions did not record which elapsed days belonged to Limbo, so the migration
does not guess or undo their already accumulated civil time. Keep the original
save and original package for rollback; new sessions freeze the campaign start
at 03/11/1889 09:00 until departure. This section supersedes contradictory historical
descriptions of the Limbo/global clock below.

## 4.37.3 — Palomo choices, Ronnie crafting and Limbo departure (#63)

This section supersedes older role assignments and the Box-plus-first-weapon
departure restriction recorded below; historical release labels remain evidence.

After his exterior introduction, Palomo explicitly invites the player to follow
him inside. Once he finishes the existing physical route, he offers 36 T1
weapon options, four armor families, five Seals and four shields. Each option
has an actions/effects page, a current stats/costs page and an explicit confirm
or back choice. Confirmations remain fixed per category and survive reopening
and saves. There are no new class restrictions or balance values. Weapon/armor
sizes use the existing character-size policy; previous confirmed sizes remain.
Weight, absorption, coverage, Air and Anima quotes come from native catalogue,
equipment models and derived stats. Charge and other existing multipliers still
apply. Seal Channel keeps its actual Adrenaline cost and cooldown.

The existing persistent weapon, armor and Seal fields remain authoritative;
the shield adds MainM00ShieldChoice and MainM00ShieldCrafted. Palomo only records
these four choices. They grant no equipment, recipes or supplies and do not advance
Caella or Ronnie. As of #164, after Caella's trial and weapon confirmation, Ronnie starts
the existing crafting stage, teaches the selected recipes/dependencies, and
opens the finite raw-material allowance. A legacy already-started tutorial can
continue without filling new choices or repeating its start. Adding a missing
choice to that legacy plan teaches its dependencies without resetting issued
stock, existing tasks or progress. At #63 Caella chose/taught the amulet;
#96 supersedes that assignment: Palomo gives it, Caella teaches its recipe.

Crafting-size correction 5.1.12/#158: the selected equipment size belongs to the
artisan's menu state. Browsing Seals, amulets or ammunition must not replace it
with their fixed size; their size control is a no-op. Sized task completion uses
its snapshotted size, while fixed-size completion preserves the current equipment
size. Fixed-size display/output metadata remains canonical M. This does not
increase Palomo's allowance: the tutorial's recorded size, T1 and 100% efficiency
still determine its finite stock. Existing saves keep their explicit menu size;
if it was changed to M by the old preview, select the planned size once.

Shield materials expand from established plate/strap recipes at the same 100%
layer efficiency and recorded size as the starter plan. All four T1 shields
require existing raw copper, raw tin and tanned leather; no new supply source
or unresolved authored quantity is needed. Shield tasks use the shared recursive
material solver/reservations and selected T1 shields enter personal inventory
before the Box reward. Cancel, pause, payment and save/load retain native rules.
Crafting armor, a Seal or a shield remains optional preparation; the first
weapon remains an actual crafting task. Reopening dialogues does not replenish
allowances or create extra output. Palomo says he replenishes mansion tables,
which always supply food and water; this dialogue coordinates with #65.

On narrative departure, retain every actual owned equipment instance and the
Magic Box: weapons, armor, shields, Seals and amulets, whether equipped, carried
or boxed. Preserve ItemId, type, essence, size, condition, weight and placement.
As of #164, retain the practice staff, legacy wand/Seal/gathering sword, Pickaxe
and bolas as owned instances. Remove all ammunition (including loaded magazines),
materials, currencies, consumables and tutorial keys; this supply cleanup was
explicitly confirmed by the author on 2026-10-01. Never grant a merely selected
piece, replace an item, or reconstruct a destroyed first weapon. The existing
recovery of the actual dropped first-weapon instance remains. No healing or
new equipment is awarded by this change. Active crafting still blocks departure
until the player finishes or cancels it.

Loadout revision 1 cleared temporary flags except explicit loans. Revision 2
(#164) also promotes those actual legacy loan instances, without replacing them. New own crafted pieces are not marked
temporary. Existing choice fields, recipe knowledge, reservations, issued stock
and completed stages are preserved; missing shield state defaults to unchosen.
Old native conversation page indices are retained by appending the new Palomo
conversation and keeping old page slots as referrals. Migration is idempotent.
Rollback uses the preserved original save and original package, not a downgraded
new save. Equipment already removed by an earlier completed exit is not invented.

## 4.37.2 — Magic-weapon Anima bases divided by ten (#68)

Author decision, 2026-10-01: launching with every magical implement costs one
tenth of its former base. Eloquence remains the corresponding attribute, using
the new Type 2 divisor (#154); this is division, not a subtractive percentage.

`F(E) = 1 + 3 * (E*E + 25*E) / 12500`, with E=max(0,E)
`Anima per cast = base * tier multiplier * charge multiplier / F(Eloquence)`

| Implement | Former T1 base | Current T1 base | T1 at Eloquence 100 |
| --- | --- | --- | --- |
| Staff | 500 | 50 | 12.5 |
| Book | 700 | 70 | 17.5 |
| Bell | 1000 | 100 | 25 |
| Statuette | 1000 | 100 | 25 |

Eloquence 0 retains the base; 100 gives F=4 and one quarter of the base. Values
above 100 continue along the same curve. T1/T2/T3 multipliers remain 1/1.6/2.5;
a prepared charge remains x2. Primary/secondary and all five essences use their
implement's cost. A bell volley pays once, not once per projectile. Authored NPC
staff/statuette attacks share the reduced constants and their existing divisor.
Damage, duration, regeneration, Seal Channel, physical costs and the Arcanist
Sleep/class-ability base are unchanged. Runtime resources retain fractional costs.

Attribute-balance revision 3 recalculates saved derived costs and any pending
cast once, before payment, retaining elapsed casting time, current resources,
equipment IDs and quest progress. It uses the existing revision field; no new
saved fields or map conversion. Already paid casts receive no retroactive refund.
For rollback, retain and load the original save with its original 4.37.1 package;
do not treat a newly saved revision-3 state as an original-price rollback save.

## 4.37.0 — MAP01 exterior and door presentation (#61)

The new scenery is decorative only, as requested by the author on 2026-10-01.
Its Actor-only classes have no gathering, renewable resource, inventory, damage
or reward behavior. Tree trunks are stationary solid scenery; shrubs are
nonblocking. Existing resource actors and their reserves remain authoritative:
four tutorial ceibos and twenty fiber bushes, including 200,000 fiber capacity.

Native continuous floor planes supply walkable exterior relief. The terrain
meets the retained flat ground with no steps at its boundaries. Original map
objects, architectural sectors/actions, door groups/keys/swing sides and tutorial
logic remain. The distant flat exterior is partitioned solely to correct a
rendering defect; the original outer limit and blocking horizon are retained.
Fixed opaque tympanum meshes cover the visible gap over each hinged door without
adding passage collision. Existing door blockers and architectural slabs retain
their accepted collision. All supported body tiers remain below the visible
100-MU leaf top; no headroom restriction is added.
The additional top-door roof-front closure begins at Z=400, above the existing
ceiling slab. It has no actor collision and changes no access or combat rule.

The author-requested northeast cave is scenery, separate from the tutorial's
resource cave. Its five gemstone rocks are plain, nonblocking Actors, neither
shootable nor inventory/resource nodes. They cannot be extracted, depleted,
picked up or converted into rewards. The tunnel has a gentle native floor
descent, one bend and a closed end; solid 3D floors provide its roof and the
walkable mound above. No quest, enemy, loot or gathering quota is introduced.

The later invisible-boundary repair relocates detached auxiliary model rooms
outside the playable horizon. Only their polygon positions change; sector
planes, control actions/tags and the mansion's physical floors remain intact.
Paired native height samples and door regressions verify the retained behavior.

The northern-station correction compares original exterior stations with their
native FloorZ, rather than absolute zero, before relocating them. Both station
selection and the spare-station fallback use this condition. Existing room
groups, positions, recipes, dimensions and capabilities remain; eighteen original
actors are reused within 38 total stations. Repeated preparation preserves those
instances and creates no duplicates. This correction applies to fresh MAP01;
already prepared older worlds are not migrated under the existing waiver.

The author accepted all #61 tests, including CA-4370-STATIONS-01, on 2026-10-01
and authorized PR #66 merge/issue #61 closure. This acceptance update changes
no runtime behavior, crafting rule or save state.

The author explicitly waived old-save compatibility work for #61 on 2026-10-01.
Start a fresh MAP01/new campaign; no old-MAP01 migration is claimed. The accepted
baseline is preserved for recovery, and existing MAP02/MAP06 launcher options
remain unchanged. Author acceptance is distinct from the isolated native checks.

## 4.36.27 — Complete port siege (#16)

MAP06 deploys 1,000 Mandingas and one distinct commanding Zupay concurrently,
five small rams (six operators each), one large ram (32), six attacking cannons
and twelve defending cannons. The 74 attacking operators belong to the same
1,000-Mandinga roster; they are not extra enemies. One hundred friendly soldiers
reuse Domingo's appearance: all twelve attributes 18, height 1.8 m, body mass
80 kg, existing campaign T1 sword, kite shield and medium armor. Twenty-four
operate the defensive guns; the remaining 76 defend the ram gates. Their
equipment uses the shared damage, defense, resource, timing and wear models.

Author decisions of 2026-09-30 supersede the former cannon cycle: both sides
fire automatically with unlimited ammunition and prefer eligible visible enemy
siege operators, then other enemies. Two operators complete a cycle in 10 seconds
(350 native tics), one in 20; zero stops progress. Aim is selected when loaded,
with native-gravity elevation compensation. Accepted 500 m/s projectiles and
physical impacts remain. Saved revision 0 work migrates proportionally from
the old 1,050-tic cycle to 350 once. The scenario explicitly enables unlimited
ammunition; old finite-ammunition actors retain their stored rounds and mode.

Connected compatible attackers share command across species. Zupay priority is
1 and every Mandinga priority is 2; saved roster identity breaks equal-priority
ties. The #77 follow-up limits each group to 100 members including its leader.
Local links use sight and the layout's 1,024-MU radius; groups are rebuilt
every 35 tics or upon a confirmed death. Split groups elect their own leader
and reconnect deterministically. Operators follow their moving machine posts;
availability controls operation separately from death-backed neutralization.

Author follow-up, 2026-09-30: a dead crew member is replaced by the nearest
living, unassigned combatant of the same side (stable roster order breaks ties).
Both ram sizes and both cannon sides reuse the vacated slot. A living operator
who temporarily leaves keeps the assignment. Recruits must walk to the moving
post/platform before counting as present; no teleport, extra spawn or remote
operation. Guard death memory remains separate; neutralized machines never
recruit or reactivate. If no eligible reserve remains, the vacancy stays open.
Allied replacements come from the original gate defenders, so their distribution
changes with losses while the original 100-person roster remains fixed.

The author subsequently requested a trial in which port enemies may execute
physical and magical attacks even with insufficient Air/Anima. This trial is
enabled by `enemy_attack_resource_trial: 1` in assets/map06_port/LAYOUT.json.
Only hostile Mandingas and the commander registered to CaelumPortSiege qualify;
the player, defenders, friendly conversions and other encounters keep their
normal costs/limits. Spending still drains available resources, clamped at zero;
it does not refill or increase them. Existing saved resource waits can resume.
Attack cadence, weapon-load limits, damage, range, sleep/stun and half-health
retreat remain. Set the data flag to 0, regenerate generate_map06_port.py and
rebuild to restore the preceding port behavior: suppress unaffordable magic and
continue physical pursuit while Air permits. No serialized field/schema changes
are required. The author accepted this playtest setting on 2026-09-30 along with
all issue #16 tests; the data switch remains available for later balance changes.

The port commander inherits the ordinary Zupay profile: twelve attributes at
33, maximum health 44,022, Anima 6,610, Air approximately 1,222.18, mass 666 kg,
physical height 93.333333 MU (2.9167 m). Its displayed art is about 120 MU tall
(3.75 m); collision height and sprite height are distinct. The half-health
retreat threshold is 22,011. Ground slam uses base damage 66, radius 192 MU
(6 m) and the accepted 80-tic cycle; the earth statuette uses the existing T1
damage/cost formulas. These are existing statistics, not a balance revision.

The port Zupay flees at 50% maximum health, at triple base speed, using the
accepted sewer movement states. Starting flight is not defeat: it must reach
the final authored exit with sight and compatible floor height. Death also
counts; escape does not award a kill or write the sewer/Ace flag. Victory
requires this defeat AND all twelve attacking machines neutralized, in either
order. Each machine remembers its local guards; temporary absence is not death.
An escaped commander no longer blocks remembered guard clearance. Neutralization
is permanent and cancels further operation without deleting released shots.

Victory occurs once, enables the distinct Knight of Wands through shared Box
capture, ends the calendar siege and orders living attackers to withdraw.
Survivors navigate to actual northern exits and are removed only upon arrival,
without awarding kills. Gate passages open for the withdrawal. Zero, some or
all rescued prisoners remain valid outcomes; existing 25-gold/+10-own-faction
payments stay independent and once-only. Use the marked port endpoint after
capturing the Knight to acknowledge the playtest ending and its reserved music.
There is no automatic diagnostic-map exit or arbitrary time-limit failure.

Deployment revision 1, command identity, crews, guard memory, retreat, victory,
card and reward state persist. Additive defeat revision 1 never infers escape
from a missing actor. Saves that already visited the former MAP06 require
`run_dev.bat --legacy-map06` (or `build_dev.ps1 -LegacyMap06`) for the exact old
geometry; this continues that map, not the new siege. Combine with
`--legacy-map02` when needed. Keep the original save and package for rollback.
Old owned cards remain owned; the provisional reward-only Knight rule applies
only to the preserved old port. Fresh/unvisited MAP06 uses the new deployment.

Native integration, both objective orders, persistence, reward/capture and
concurrent population evidence are in assets/validation_43627. Full ordinary
campaign play and visual/balance acceptance remain author checks in pending_test.txt.

## 4.36.26 — Shared attack clock and durability (#37)

All T1–T3 weapon bases are now 14 tics. Effective duration is
`14 / (F(attribute) * (1 - p))`, with `F(A)=1+3*(A*A+25*A)/12500` and
`p=(equipped weapon mass + equipped glove/arm armor mass)/maximum carry capacity`.
Physical/ranged weapons use effective Dexterity; magic uses effective Eloquence.
The denominator is neither remaining capacity nor the overload threshold.
At `p>=1`, an attack cannot start: no cost, impact, projectile or attack animation.
At 50% load, duration doubles for the same attribute state. A gauntlet weapon is
counted once as its weapon item; a separate equipped arm-armor item contributes
its own physical mass. Total inventory load does not enter this speed ratio.

The shared calculation retains fractional tics; native state changes occur at
the next simulation tic, normally `ceil(duration)`. Rendering FPS does not set
cadence. Native held-Fire verification measured seven consecutive 15-tic
intervals for a weapon whose effective duration rounds to 15. NPC magical pose
boundaries round cumulatively, allowing poses to be skipped at extreme speed.
AI decision/chase delays between distinct enemy attacks remain separate.

An accepted player attack records its item, side, starting map/tic and duration.
Its animation reads that same clock throughout the cycle, including recovery.
Ordinary melee/sweeps strike at the existing swing's middle; authored thrusts
strike at 80%. Ranged release and recoil begin together. Magic prepares and
releases at the end of its effective duration; there is no additional eight-tic
animation after release. All paths preserve one actual resource deduction.
Changing equipment, opening Inventory/Crafting, death, immobilization, blocking
or channeling cancels a pending physical impact. Its prepared charge is already
consumed, as for an accepted magic preparation; no new charge starts during a
pending physical impact. Charge preparation remains `2/F(attribute)` seconds,
with the same three-second prepared window; ranged reload rules are unchanged.

The author's 2026-09-30 thrust presentation applies to dagger Fire and machete,
sword, greatsword and halberd AltFire. In the 320×200 weapon plane, the assembly
lowers 30 units, rotates counterclockwise around the grip to aim at screen center,
advances 60 units in a straight line toward that center, then returns to its
original grip pose. The confirmed total-cycle allocation is 16% lower, 16% turn,
48% advance and 20% return. The arm, weapon and supporting hand share the turn.
Other spear/javelin attacks retain their existing presentation.

Weapon maximum durability is ten times its previous value, applied after the
existing tier/size calculation. Armor/shield durability is unchanged. Revision 1
migrates weapon models, native items, persistent ownership/starter snapshots and
encoded damaged world/chest pickups once, multiplying remaining durability by ten
to preserve proportional wear. Native save/reload and original-save rollback
were tested. Keep the original save with its original build for lossless rollback;
the migration helpers also expose revision 0 for controlled diagnostic reversal.
Repair uses the existing missing-durability fraction, so proportional repair
materials/time do not increase. Melee damage-based wear and one durability per
successful javelin throw remain unchanged. Bows, crossbow, carbine and magic
already had durability and damage-based wear; they receive the same increase.

New projectiles retain the exact source item through weapon switching, Box moves,
drop/pickup copies and save/load. Their existing direct/explosive/multiple-projectile
damage callbacks retain the prior wear basis (prepared projectile damage, successful
melee damage); they no longer debit another identical equipped copy. Legacy
in-flight projectiles without a saved source identity cannot safely reconstruct
that identity and do not debit an unrelated current weapon.

Enemy resource changes cover the authored Mandinga, Zupay, giant-rat and bull
profiles. Mandinga melee uses the shared machete base Air (3). Punches, rat bites
and bull gores use dagger minimum minus one (1 base Air). The Zupay slam uses
`2*(greatsword primary Air + jump Air)=34`, with exactly 48 preparation and 32
recovery tics. Its damage/radius/push are preserved. Effective enemy Air reuses
`base*(body mass/100)*CalculateLoadAirMultiplier(actual carried mass/capacity)`;
the existing load curve and its 0.75 threshold are unchanged. Without carried
load the respective costs are 1.98, 226.44, 0.10 and 9.00 for Mandinga, Zupay,
rat and bull. Existing actual armor/inventory mass contributes; no fictitious
extra inventory is assigned. Mandinga/Zupay spells retain shared implement Anima
costs, budgets and regeneration. An unaffordable intended attack enters idle,
continues regenerating and resumes when its effective cost is affordable. The
bull's charge retains its separate per-tic spending; a waiting prepared gore
resumes without paying for another charge. These states survive saving/loading.
Resident/companion legacy combat profiles are not assigned guessed weapon costs.

Evidence: `assets/validation_43626`. Static checks, isolated engine tests and
author acceptance are distinct. The author confirmed CA-43626-COMBAT-01 and
CA-43626-THRUST-01 passed on 2026-09-30 and authorized merge/closure.


## 4.36.25 — Rebuilt MAP01 geometry (#36)

The mansion's roof closure and balcony guards use native solid 3D floors and
3D middle-texture collision. Guards retain the existing 48-MU height. Stairs,
conversations, rewards, Bull rules and travel semantics do not change.
The invisible outer boundary remains impassable; decorative shutter panels
are closed wall surfaces and the two reliefs have no collision or interaction.

MAP01's 48 leaves now inherit the original grouped-door access rules but use
solid 3D wooden leaves and hinged movement. Use normally opens away from the user;
opposing leaves use their outer jambs. The opening angle is 90 degrees for
clearance; the original 16-tic movement, 105-tic hold, keys, faction condition,
group prevalidation and Rulo arena lock remain. Moving blockers follow the
visible leaf. Swept solid-body checks stop opening and reopen an obstructed
closure without pushing/crushing actors. These doors are not breakable siege
gates: no combat statistics or destruction mechanics are added. Other maps
retain CaelumSlidingDoorLeaf. New-game door fields serialize normally; old
MAP01 reconstruction compatibility remains waived below. The central front
entrances at Z=136 are four independent singles (groups 910/922 and 911/923);
the four unwanted side connectors are removed at the author's request.
Groups 906/907/908/909 instead have a fixed swing toward the central rooms,
avoiding the resident beds regardless of the caller's side. Reopening a
partially open leaf retains its current direction until it closes.

The author moved Rulo's target into the empty north-central ground-floor room
on 2026-09-29. PRACTICE.json supplies its position and practice bounds through
generated CaelumMansionPracticeData. The old workshop no longer records the
six practice flags; their requirements and persistent IDs are unchanged.
Rulo's instructions and Journal Detail name the new room in both languages.

Author acceptance, 2026-09-29: all CA-43625-MANSION-01 checks passed, including
the final Caella door adjustment. Merge and issue closure are authorized.

Author decision, 2026-09-28: prioritize reconstruction over old MAP01 saves.
Use a fresh MAP01/new game; this patch does not promise geometry migration or
loading old MAP01 saves. Existing MAP02 compatibility guidance remains separate.

## 4.36.24 — Persistent quest journal (#35)

Author classification confirmed 2026-09-28: the mansion/El Loco quest is main;
the sewers/As de Copas and port/Caballero de Bastos quests are side quests.
Each prisoner rescue is a separate optional side quest, completed on live
extraction before the boss; collection of its existing port reward is separate.
This follows the Major/main and Minor/side rule, without making rescues mandatory.

The single `CaelumQuestCatalogue` identifies presentation records by stable ID:

| ID | Record | Classification and authoritative source |
| --- | --- | --- |
| 0 | Mansion / Where the Lost Awaken | Main; existing `QuestState[0]` and stage/objectives. |
| 1–2 | Development route/wait trials | Side; existing opt-in quest slots; never offered automatically. |
| 3 | The port under siege | Side; existing #34 `QuestState[3]`, driven by the registered #16 encounter. |
| 4 | Through the sewers | Side; recorded sewer visit starts it; confirmed Zupay defeat/escape completes it. An owned Ace is existing #33 legacy evidence of defeat. |
| 5–8 | Leonor, Rufino, Santos, Leandro rescues | Side; following = active, extracted alive = completed. Existing successful payment also proves historical rescue. Captive = hidden. |

IDs 4–8 are read-only catalogue identities over existing world/rescue fields,
not new mutable quest slots. No rewards, mechanics, objectives or map markers
are introduced. The already-recorded death before extraction uses the existing
Failed display under Other, with explanatory text; no new failure rule runs.
A completed rescue states whether its port payment was actually collected.
Optional mentor practices stay in the existing mansion detail, not duplicated
as independently rewarded quests. The provisional Knight capture is not evidence
of siege victory: quest 3 stays hidden until a real registered port encounter.

C/right trigger cycles All/Main/Side. V/left trigger independently cycles
All/Active/Completed/Other. Other preserves existing offered/failed/abandoned
entries. Arrows select only matching records; Left/Right still crosses journal
sections at a boundary, including an empty category. PgUp/PgDn and shoulders
always change sections; F/Y opens detail, Up/Down reads it, Tab/B returns/closes.
The title, classification and actual status remain visible; counters count only
matching records. Filter changes reset detail scrolling and abandonment prompts.
Completed entries stay selectable. No undiscovered title appears in empty views.
The completed mansion summary no longer prompts further Palomo/Fool actions.

Compatibility: the authoritative save schema and all stored IDs remain unchanged.
Existing snapshot refresh reconstructs the larger disposable UI arrays from
recorded facts; the existing saved controller also refreshes changed observations.
No migration writes, new progress flags or revision are necessary. Repeated
refresh, load and travel cannot grant rewards or reset tasks. Old saves without
visit/defeat/card/rescue evidence do not gain invented historical entries; later
maps or the provisional Knight alone do not prove sewer/siege completion.
Native pre-#35 PK3 load, same-version reload and hub travel pass. Keep original
saves as recovery copies. The author confirmed CA-43624-JOURNAL-01 passed
on 2026-09-28; its result is recorded in HISTORY.

## 4.36.23 — Armor last, body absorption and gate defense (#52)

**Historical contract:** Toughness ordering, DOT asymmetry, HP rounding and
gate/impact thresholds in this section are superseded by 5.2.8 / #188 above.
The absorption tables and attribution remain current unless separately revised.

Author-approved design, 2026-09-27. For ordinary physical/magical attacks the
order is (1) existing shield blocking, (2) anatomical vulnerability, reinforcement
and critical, (3) Toughness, (4) additive innate and equipped armor absorption.
Author revisions on 2026-09-28 replace the Type 4 divisor with subtractive
maximum-health damage and restore the historical attribute growth curve.
The earlier direct-level subtraction was superseded: level L is converted to
`R(L)=(L*L+25*L)/125`, with L=max(0,L), percentage points, without a 100% cap.
No minimum-damage floor is added. For an attack after shield and anatomy/critical:

```
P = 100 * postAnatomyDamage / maximumHealth
R = (T*T + 25*T) / 125, where T=max(0,Toughness)
remainingPercent = max(0, P - R)
preArmorDamage = maximumHealth * remainingPercent / 100
finalDamage = round(preArmorDamage * (1 - innateFraction - equippedFraction))
```

The shared helper is `max(0, damage - maximumHealth*R(Toughness)/100)`.
It uses maximum health, never remaining health, and preserves fractional values.
At maximum health 1,000 and Toughness 100, incoming 999 or 1,000 becomes zero;
1,010 (101%) leaves 10 (1%) before armor. Human light T1 absorption of 22.5%
then absorbs 2.25 and leaves 7.75, rounded to 8. Toughness 100 therefore still
negates attacks at or below 100%; larger hits pass their excess. There is no
universal immunity to arbitrary damage. Neither the level nor its derived
reduction is capped at 100. Level 50 subtracts 25.247525%; level 200 subtracts
398.019802%. Historical pain/lucidity curves retain their separate existing caps.
Equipped wear uses only its absorbed share after Toughness (1.5 in this example).
A zero remainder causes neither armor absorption nor armor wear.
The existing shield step can still absorb/wear before that threshold is reached.
Existing durability constants and reinforcement grades are unchanged.

| Recipient | Innate physical | Innate magical |
| --- | ---: | ---: |
| Beast Men and animals (Bull, Giant Rat) | 12.5% | 2.5% |
| Caelith | 10% | 5% |
| Human | 7.5% | 7.5% |
| Duendes and demons (Mandinga, Zupay) | 5% | 10% |
| Palomo (author-specified exception) | 77% | 77% |

The author explicitly confirmed Leonor=duende, Rufino=Caelith,
Santos=Beast Man and Leandro=Human. Their base NPC counterparts are Caella,
Ronnie, Rulo and Argento respectively. The noncanonical quick/debug profile
uses the Human defense fallback. NPCs inherit their class's racial defense;
Palomo overrides only innate absorption. Innate defense survives absent/broken
equipment. Only the contacted region's piece contributes equipped absorption.

| Armor | T1 physical/magical | T2 physical/magical | T3 physical/magical |
| --- | ---: | ---: | ---: |
| Magical | 10% / 30% | 15% / 45% | 20% / 60% |
| Light | 15% / 15% | 22.5% / 22.5% | 30% / 30% |
| Medium | 22.5% / 22.5% | 33.75% / 33.75% | 45% / 45% |
| Heavy | 35% / 35% | 52.5% / 52.5% | 70% / 70% |

T2/T3 multiply T1 by 1.5/2.0. Magical armor grants no Intelligence, Patience
or Insight. Other equipment bonuses, mass, fit, reinforcement and recipes stay
unchanged. `CaelumArmorRules` is authoritative for both gameplay and the
physical/magical equipment display; there is no separate UI balance table.

Classified magical damage includes magical actor projectiles, `CaelumMagicTest`,
the `CaelumTrapMagic` mine, and the channel's `Electric` discharge. The latter
now receives armor defense on players as on NPCs, while keeping its previous
shield bypass. Other shield defenses, coverage and wear are unchanged. Physical
ground slams remain physical even when their source can also cast magic.
Explosions retain region sampling and per-region health rounding: each reached
region applies its anatomy/critical first, then subtracts Toughness using the
whole recipient maximum health. The diagnostic multiplier is the actual
post/pre fraction for this hit (an aggregate for explosions), not a fixed stat.
Historical pre-#188/#194 kinematic impacts used `max(0, severityPercent*surface - R(effectiveToughness))`
after movement amortization, before weighted anatomy and final physical armor.
The buckler/gauntlet acrobatic bonus doubles the effective attribute level before
evaluating R: level 25 becomes level 50, giving 25.247525%, not twice R(25).
Collision diagnostics display the derived reduction percentage, not the level.
No second Toughness or native armor pass is applied.
Survival drains, native crushing and other existing bypasses are not broadened.
The pre-existing elemental-DOT asymmetry remains: player DOT bypasses the
ordinary defense path; NPC DOT enters that path as physical. This patch does
not claim universal DOT parity or redesign that separate rule.

Gate defense is structural, not racial: common/reinforced/armored gates absorb
10/20/30% after Toughness. Final author revision on 2026-09-28 sets Constitution
to 0 for every material and Toughness to 25/50/75. Masses remain 550/650/1100 kg.
Maximum resistance is therefore 5,500/6,500/11,000, using
`H = int(10 * (100 + Constitution*(Constitution+1)/2) * mass/100)`.
The proposed cannon bypass of Toughness was explicitly excluded.
For frontal stationary contacts at existing ram speed 37.780229 m/s and cannon
contact speed 500 m/s, each cell is final damage / hits to break an intact gate:

| Attack | Common | Reinforced | Armored |
| --- | ---: | ---: | ---: |
| Small ram | 4,990 / 2 | 3,951 / 2 | 1,783 / 7 |
| Large ram | 5,500 / 1 | 5,972 / 2 | 5,859 / 2 |
| Cannon (4.3 kg inert round) | 0 / cannot break | 0 / cannot break | 0 / cannot break |

Absorption multiplies the unrounded post-Toughness damage; round once at the
end. The whole-gate impulse model remains, without penetration or explosion.
The large ram calculates 6,704 damage against common gates, but actual health
loss is capped at their remaining 5,500. All other listed first-hit values are
below the intact maximum. Repeated hit counts use the same contact conditions.
Gate levels 25/50/75 now subtract 6.435644/25.247525/56.435644 percentage points.
These values supersede the direct-level #52 tables and historical 4.36.19 damage.
The cannon does not exceed any gate threshold; masses and speeds remain unchanged.
Gate `BalanceRevision=2` migrates remaining-health ratio to the lower maximum,
rounded once with minimum 1 for living gates, without closing opened gates,
reviving broken gates, or resetting timers and duplicate-contact serials.
Repeated refresh/load does not rescale again. Explicit legacy-recovery revision
0 keeps its former attributes; original saves and the previous PK3 permit rollback.
Defense is read from data, not stored in each gate.

Player `AttributeBalanceVersion=2` and NPC `ArmorBalanceRevision=1` recalculate
derived values from preserved base data once on load. Attribute bonuses are
never repeatedly subtracted; equipment IDs, tiers and wear are retained.
Resource maxima may decrease and existing clamping prevents free resources.
Keep original pre-upgrade saves and the prior PK3 for reversible rollback;
do not overwrite the original with a migrated save. Old-save, migrated-reload
and original-save rollback are distinct checks in validation_43623.
This formula revision introduces no new serialized fields or reset: legacy
`DamageResistanceMultiplier` and gate `RetainedDamage` remain for compatibility
but no receiving path reads them. Existing 4.36.22 and initial 4.36.23 saves
use the new rule immediately; the final gate revision separately migrates gate
maximum/remaining health as described above. Character maxima and equipment are
unchanged by the gate revision. Initial evidence is preserved in
DIVISOR_RESULTS.json, TOUGHNESS_RESULTS.json and GATE_RESULTS.json; current
results are in RESULTS.json and curve_revision/. Restoring attribute growth adds
no serialized fields or gate revision: existing levels use R immediately without
rescaling health or resetting saved state.

## 4.36.22 — Quest ownership and persistent narrative events (#34)

Save compatibility for #34's USDF layout: saves store global page indices.
An open legacy Unknown Voice (speaker layout revision 0) rebinds the established
MAP01/MAP02 conversation ID, restarts that brief conversation once, and records
revision 1. New saves preserve the exact page. Other conversations open in a
pre-#34 save close once without executing a reply; interact again to reopen
through the speaker's canonical ID. Quest progress, items and rewards persist.
Loading never invokes Use or a reply as part of this presentation migration.
Keep original saves for rollback to the pre-#34 dialogue layout.

The awakening/Unknown Voice remains the prologue. In new games quest 1 stays
undiscovered until Palomo's existing guidance choice activates it. Its stage,
flags, objective IDs and rewards retain their existing identities; an already
active/completed old quest is not reset. Palomo offers the existing optional
needs, Air, load, swimming and canteen actions after his introductory guidance.
Legacy `MainM00*` fields and action names are retained for compatibility, even
where they contain `Ronnie`. Crafting, gathering-sword loans and repair remain
with Ronnie. He directs material-location questions to Palomo and explains the
calendar through his workshop menu. This supersedes older current-role wording.

Palomo's optional bed practice observes a real active MAP01 bed/rest session.
The mansion's existing untimed rest is preserved: no invented waiting interval,
Sleep drain, reward or main-quest gate. Food/water grants remain individually
idempotent. Air/swimming observations now test `HasActiveConversation()` rather
than a possibly stale `ConversationNPC` pointer after closing USDF.

Each of Rulo, Ronnie, Caella and Argento stores the worst state reached from
Bull damage during the active attempt: normal (0), the existing Herido (1),
Malherido (2), or incapacitated/seated at 1 HP (3). Incapacitation wins over
the others. A retry clears that attempt's peaks; healing and the end-of-fight
restoration do not. Unrelated damage and player health never select the branch.
Existing ordinary closing text and later Tarot reactions remain, with the
character-specific injury reaction when applicable. No reputation/stat changes.

Eleven event slots use native non-pausing USDF: four distinct releases, sewer
Zupay defeat (death or completed escape), four actual successful reward deliveries,
port siege start and port siege completion. Each character's persistent Inventory
owns pending/delivered masks. A failed or capacity-blocked payment does not queue
a completion. Events wait for the current conversation, inventory/crafting/merchant
menu and rest session; a line is acknowledged after its native conversation closes.
Several close events are drained in deterministic slot order, one conversation at
a time. Pending/delivered bits survive saves and travel; opening alone does not
consume a line. Selene remains labelled Unknown Voice.

Port quest ID 3 uses previously unused persistent quest storage. It becomes
visible only for a sealed MAP06 `CaelumSiegeEncounter` with twelve registered
hostile machines and its own commander. Its two objectives mirror the existing
neutralized count and confirmed commander defeat, in either order. Completion
mirrors `Victory`; surviving attackers remain the controller's retreat responsibility.
No all-Mandinga requirement, failure condition, new payout or separate card spawn
is added. The single #33 Knight path switches from provisional rescue-payment
readiness to actual siege victory when that encounter is registered. Existing owned
cards and rewards are never revoked. Zero rescued companions remain valid.

Additive narrative revision 1 baselines historical release/payment/boss events as
already delivered; it never invents past Bull injuries. It leaves existing quest,
survival, item, faction and Tarot state intact. `RestoreLegacyProgress` clears only
the new narrative fields and unused-before-#34 port quest slot; reapplying the
migration is idempotent. A native pre-patch PK3 save, same-version queue save/load
and hub travel have been checked. Keep a recovery copy before rollback.

## 4.36.21 — Environmental collisions and running absorption (#49)

The author's 2026-09-27 instruction supersedes the wall-only and walking-only
limits of 4.36.18. Grounded directional running now shares walking's existing
biological fraction: clamp(max(0, JumpZ /8 -1), 0, 0.5). Crouching retains its
existing eligibility, and immobilization still disables absorption. Active
acrobatic shield defense remains the maximum of its fraction and this movement
fraction; neither stacks. Existing landing/crushing absorption is unchanged.

The author explicitly includes walls, rooted trees and rocks at rest. A movable
rock's complete velocity must be zero before the collision solver transmits
impulse; the newly imparted velocity must not revoke that contact's benefit.
Rocks already rolling or falling do not qualify for this locomotion fraction.
Idle/airborne movement and genuine character/projectile collisions do not
gain the new benefit. Mass, material, contact geometry, energy severity and
the Type 4 damage divisor remain unchanged.

Tree/rock actor collisions now carry environmental provenance, using the
existing environmental damage path without extra native thrust. They grant
neither damage nor pain adrenaline, and do not start or refresh combat time.
Damage, pain, cast interruption and rest interruption still occur. Genuine
combat-body hits retain their adrenaline/activity behavior. No serialized
fields or state indices change; the extra contact classification is ephemeral.

## 4.36.20 — Arcana availability and sewer retreat (#33)

The author on 2026-09-27 specified that the sewer Zupay starts fleeing at
health <= 50% of CombatMaximumHealth (the existing wounded threshold). Only
MAP02's boss, TID 43799, receives this behavior. Its movement Speed becomes
three times its uninjured CombatBaseSpeed, using the normal four-tic chase
cadence and native navigation without attacks. Retreat remains latched if
health later increases. Reaching within one native movement step of the
workshop gate's contact volume, with sight and matching floor height, removes
the boss and confirms defeat. Starting retreat alone does not confirm defeat.
A lethal hit also confirms defeat. Other Zupays and siege rules are unchanged.

The Ace of Cups (persistent ID 36) is invisible, nonblocking and unusable
until confirmed sewer-boss defeat. Defeat makes the apparition available; it
does not grant ownership. Absence of an actor is never sufficient evidence.
The Spanish Fool name is **El loco**; its ID 0, quest flags and effects remain.

The Knight of Wands (**Caballero de basto**, ID 60) appears at MAP06 beside
the survivors after all extracted prisoners' rewards have actually been
delivered. Zero extracted survivors permits immediate appearance on arrival;
dead or unrescued prisoners do not block it. The existing transaction's
PrisonerRewardClaimed flag is the authority: dialogue entry/exit, partial
claims and a failed capacity check do not count as delivery. The existing
25 gold and +10 own-faction reputation rewards remain once-only. **Historical pre-siege condition: 4.36.27 replaces it with siege victory
in current MAP06; preserved legacy MAP06 retains this rule.**

All three cards share the original Fool's Use/Box identity checks, native
confirmation dialogue, 35-tic image-to-player animation, cancellation and
commit. Each supplies its own approved front, localized name and ID. Leaving
range, dying or losing/changing the Box cancels without granting or consuming
the card. Capture and revelation persist; owned cards cannot be captured
again. Existing Minor passives and collection percentages apply; no new power
is introduced.

Additive Arcana revision 1 preserves TarotOwned, MainM00FoolRevealed, quests,
Box IDs and prisoner rewards. An already owned Ace or a retained dead sewer
boss supplies legacy defeat evidence. New serialized fields retain defeat,
Minor revelation and port availability. RestoreLegacyProgress clears only
the added traveler fields for recovery on a copied save; reapplication is
idempotent and never revokes owned cards. Keep the original pre-upgrade save
for full rollback. WAD geometry and original actor state indexes are retained.

## 4.36.19 — Final siege impact balance (#21)

Historical rule: superseded by the 5.2.11 / #194 energy contract above. Retained as provenance.

Author-approved on 2026-09-27 after the numerical comparison: cannon muzzle
speed is 500 m/s (457.142857143 MU/tic), inert projectile mass remains 4.3 kg,
and gate Toughness and Constitution are 50/100/200. All Caelum physical
collision reception (player, combat NPC and gate) now divides severity by
Type 4 rather than subtracting Toughness points:
D(T)=1+T*(T+1)/5050; P=max(0,S*E)/D(T).
Biological absorption precedes E; anatomy and armor follow P on biological
targets. The player preserves the existing active buckler/giant-gauntlet
effective-Toughness bonus. No second Type 4 or native armor pass is added.
Ordinary weapon reduction uses the same divisor. Pain/Lucidity curves,
native crusher damage, restitution, contact normals and momentum stay unchanged.

| Gate | Mass kg | Toughness / Constitution | Maximum resistance | Divisor |
| --- | --- | --- | --- | --- |
| Normal wood | 550 | 50 /50 | 75,625 | 1.504950495 |
| Reinforced | 650 | 100 /100 | 334,750 | 3 |
| Armored | 1,100 | 200 /200 | 2,222,000 | 8.960396040 |

Frontal stationary-target impacts; small/large ram moving masses remain
2,874.990701 /15,333.283739 kg and contact speed remains 37.780229 m/s.
Each cell is damage /percent maximum /hits to break an intact independent gate.
Integer hit counts include the existing nearest-integer damage rounding.

| Attack | Normal | Reinforced | Armored |
| --- | --- | --- | --- |
| Small ram | 53,889 /71.2579% /2 | 112,963 /33.7456% /3 | 197,380 /8.8830% /12 |
| Large ram | 71,288 /94.2647% /2 | 156,321 /46.6977% /3 | 328,626 /14.7897% /7 |
| Cannon 500 m/s | 766 /1.0125% /99 | 1,194 /0.3568% /281 | 800 /0.0360% /2,778 |

This supersedes the original small-ram immunity of armored gates and the
initial cannon zero-gate-damage result. The retained whole-body impulse rule
still makes the cannon weak against heavy gates. No penetration or explosion
is introduced. Kinetic energy at release is 537,500 J; the ideal same-height
vacuum range under default native gravity is 6,530.612 m, not a historical claim.

Gate save balance revision 1 reconciles initialized old gates on Tick or first
use/contact. It retains the fraction of resistance remaining, rounds to the
nearest health point, keeps a positive intact remainder at least 1, and preserves
opened/broken state, components, timers and contact serials. New intact gates
start at their new maximum. SetLegacyBalanceForRecovery(true) is an explicit
recovery hook that restores the old attribute/maximum-health scale proportionally;
its saved flag prevents automatic reapplication. Passing false reapplies revision 1.
It does not revert the global collision formula. Intact/partial/open/broken
old saves, repeated reconciliation, reverse/forward conversion and save/load
are validated. Previously released projectiles retain saved velocity/ownership;
500 m/s applies to new launches.

The 80 kg body plus 20 kg equipment calculation and walking-only wall
amortization remain as documented below. The changes are merged and #21/#43
closed. On 2026-09-27 the author confirmed CA-43619-BALANCE-01 and
CA-43618-WALK-01 passed; HISTORY records acceptance separately from native checks.

## 4.36.18 — Walking wall-impact absorption (#43)

The author explicitly limited the new walking benefit to walls. Grounded,
live, non-immobilized players with directional input and no native BT_RUN flag
now receive the existing careful-movement fraction, just like crouched wall
contacts: clamp(max(0, JumpZ /8 -1), 0, 0.5). Always Run is already folded into
BT_RUN by GZDoom. No input or airborne movement is not walking; existing
crouched eligibility and active buckler/giant-gauntlet behavior are preserved.
This fraction reduces impact delta-speed before energy severity. It does not
extend walking absorption to characters, rams or cannon rounds. Landing and
crushing absorption still use JumpZ, doubled by active acrobatic shield defense,
and zero when physically immobilized. No persistent fields or save schema change.

Requested calculation: 80 kg body, all attributes 20, and equipment weighing
the full medium T1 size M set (head 4 + torso 10 + arms 2 + legs 4 =20 kg).
Collision mass is 100 kg; maximum health is 2,480 because health uses body mass.
Capacity is 86.653465 kg and load ratio 0.230804388. With normal health, air and
survival states, JumpZ =8*sqrt(3.1)*(1-load ratio) =10.834469 MU/tic
(11.850200 m/s at 32 MU/m and 35 tics/s). Ordinary walking-wall absorption is
35.430863% of delta-speed at this load. These weights do not silently replace
the earlier comparison's 20% armor defense/no-reinforcement assumptions.

An isolated native same-height jump reached 64.179159 MU above its floor and
registered 11.165531 MU/tic downward before landing. Subtracting JumpZ leaves
0.331062 MU/tic, below the canonical 0.8 MU/tic severity threshold: zero damage,
with 2,480 health retained. The prediction assumes unchanged load/state through
flight and the same floor height; falling to a lower floor is a different test.
The 500 m/s cannon and Type 4 collision proposal was subsequently approved
and implemented in 4.36.19 above.

## 4.36.17 — Controlled cannon fire (#21; planned label 4.36.13)

Historical delivery baseline: speed, attributes and impact mitigation below
are superseded by 4.36.19; the 30/60-second cycle and scenario targeting
are superseded by 4.36.27 above. Other shared mechanics remain current.

The author confirmed an approximate documented reconstruction, an inert
elongated 75 mm /185 mm /4.3 kg round, two operators (load/fire), and a 30-second
complete cycle with both present, 60 seconds with one, stopped with none.
Loading and recovery accumulate work at the current staffing rate; losing an
operator preserves partial progress. Nearby crew availability is separate from
the accepted death-backed neutralization policy. Attacking operators must come
from the existing registered force; defenders use living friendly combatants.
One actor cannot serve two machines. In the eventual 18-cannon deployment,
#16 allocates 12 attacking operators from the existing 1,000 Mandingas and
24 defensive operators from its authored defending force.

`cannon_physics.json` is the authoritative input to `generate_cannon_runtime.py`.
400 m/s *32 MU/m /35 native tics/s = **365.714285714 MU/tic** for both sides.
Initial kinetic energy is 344,000 J for the approved 4.3 kg round. Calendar
acceleration does not enter ballistics. The projectile changes velocity under
native level/sector/actor gravity. GZDoom's FastProjectile supplies adaptive
collision substeps but no gravity integration; this subclass subtracts native
`GetGravity()` once per tic before native movement. At default native gravity
1 MU/tic², this is 38.28125 m/s², not Earth's standard gravity. Ideal same-height
vacuum maximum range is v²/g = 4,179.592 m at 45 degrees under that default;
actual level gravity, obstacles and firing elevation govern travel. No drag or
historical range claim is implied. The scenario supplies aim points; this is
not an autonomous target selector or automatic ballistic firing solution.

The native collision cylinder has the true 75 mm diameter (radius 1.2 MU,
height 2.4 MU); the 185 mm visual body trails its contact nose. No enlargement
or speed reduction makes the projectile easier to see. A swept bore-to-muzzle
check prevents spawning beyond an obstructing wall. At clear release, one
projectile and one brief muzzle flash appear at the pitched tube's muzzle.
The rigid carriage has a brief recoil presentation, followed by recovery and
an open sliding wedge while loading; there is no modern sliding recoil cradle.

The author initially requested defining penetration, then explicitly directed
using the same implemented collisions as characters and confirmed structural
damage with the projectile stopping. Therefore no new penetration, explosion,
energy-deposition multiplier or damage constant was introduced. Actual contact
velocity and **projectile** mass enter ImpactPhysics.ResolveBodies or the gate's
ApplySiegeImpact; neither the 850 kg approximate machine nor its carriage mass
enters impact damage. The shared solver retains its horizontal contact normal
and existing Toughness/armor/anatomy behavior. Vertical flight is native, while
character damage retains the canonical horizontal impulse semantics; this
patch does not replace the general impact or crushing solver.

For a stationary gate and a frontal 400 m/s shot, the unchanged impulse rule
produces 0.945772/0.655705/0.177173% severity for wood/reinforced/armored,
below their 46.024571/70.565111/108.052215 Toughness. Thus all three receive
**zero damage**, despite a real contact and a consumed round. Characters use
their own effective mass, Toughness, armor and contacted anatomical region.
Native missile damage is suppressed after the shared callback; one spent
flag and the gate's existing impact serial prevent duplicate contact damage.
Allied bodies obstruct a shot without taking friendly damage.

Integration API: spawn CaelumCannon and call InitializeCannon(defending) once;
register only attackers in CaelumSiegeEncounter, assign two existing actors
with AssignOperator, seal the roster, then ActivateCannon(rounds). Ammunition
is explicitly supplied by the scenario, never auto-refilled on load. Queue a
shot with RequestShot(point, intendedActor); reissuing while queued does not
overwrite the accepted aim. CancelShot clears that request before retargeting.
Defenders reject players/friendly bodies/gates as
targets; attackers reject their own combatants. Direct aim points are available
for authored scenarios. Immutable per-shot side and launcher ownership survive
operator death. Defenders cannot register as hostile objectives. Attackers
reuse #20 proximity/death tracking, victory and withdrawal unchanged.

The provisional guard radius is twice the reconstructed trail-to-muzzle span,
182.4 MU = 5.7 m, configurable per gun for playtesting. Initial empty areas,
temporary departure and missing actors do not imply enemy deaths. Neutralized
guns stop permanently without deleting released projectiles. Loaded, launch,
recovery, partial loading, staffing, ammunition, shot serial, references and
spent contacts serialize natively. One live projectile per launcher, four
spent-state tics with no debris and a 120-second abnormal-flight lifetime
bound accumulation. These are implementation bounds, not ammunition grants
or historical range measurements. Pre-feature saves opt in only when a cannon
is explicitly created; no saved actor or map is replaced.

## 4.36.16 — Mobile demonic rams (#20; planned label 4.36.12)

Historical balance: the armored immunity and subtractive mitigation below are
superseded by 4.36.19. Moving masses, contact speed and operation are retained.

The author confirmed on 2026-09-26 that operation requires all 6 small-ram or
32 large-ram operators. Partial staffing stops advance, striking and recovery;
it never awards neutralization. The author also explicitly authorized demonic
strike velocities: small rams damage wood/reinforced wood but not armored gates;
the large ram can damage all three. Historical mechanical velocities would
produce zero damage under the accepted subtractive structural Toughness rule.
No gate, player/NPC impact, crushing or resistance formula has changed.

Physical inputs are generated by `assets/generators/generate_ram_runtime.py`
from the accepted #18 geometry and `ram_physics.json`. ASSETS records sources,
construction assumptions and uncertainty. Frame/transport mass never enters a
strike. The log, solid iron head/plate, bands and wooden handles do.

| Input | Small ram | Large ram |
| --- | --- | --- |
| Operators | 6 | 32 |
| Moving assembly | 2,874.990701 kg | 15,333.283739 kg |
| Approximate machine mass, excluding crew | 5,125.636207 kg | 27,336.726436 kg |
| Geometry scale relative to #18 | 1 | (32/6)^(1/3) = 1.747160929 |
| Powered contact speed | 34.541923779 MU/tic = 37.780229133 m/s | same |
| Local guard radius, provisional | 300 MU = 9.375 m | 524.148279 MU = 16.379634 m |
| Approach speed, provisional | 0.5 m/s = 0.457142857 MU/tic | same |
| Stroke, retracted to extended | 44 MU = 1.375 m | 76.875081 MU = 2.402346 m |
| Recovery | 75 native tics = 2.142857 s | same control interval |

Metres convert at the existing 32 MU/m; physical time is 35 native tics/s,
never accelerated calendar time. The demonic velocity is the midpoint between
the small assembly's reinforced/armored onset thresholds, using the existing
Impact Physics and approved gate masses. It is not a historical measurement.
Recovery rounds up one pendulum period for the small model's 36 MU suspension
span, at standard g = 9.80665 m/s²; using that interval for both powered machines
is a reconstruction/control assumption, not a sourced historical firing rate.
Guard radius is twice each frame's length, follows its current position, and
is configurable for playtesting; it is not an author-approved radius.

The finite chassis uses native collision queries. Authored waypoints lead to
the gate, then the frame aligns to its final angle; operation requires the
full crew. Current transport supports level lanes and rejects floor-height
changes and obstacles rather than teleporting through them. #16 supplies
reachable routes, placement and operator choreography. The visible head and
its thin contact proxies advance in <=0.5 MU native TryMove substeps. Each step
uses dt = distance/contact speed, so a shorter final step does not invent a
slower impact. The front plate, not a large enclosing radius, supplies contact.
The controller serializes READY / APPROACH / STRIKE / CONTACT / RECOVERY,
stroke, component references, monotonically increasing serial and spent flag.
One physical obstruction consumes one strike, even if it causes zero damage;
the recovery stroke cannot cause another strike. Actual Head.Vel at contact
and moving-assembly mass enter the shared physics path. Gate normal components
are resolved against its plane; biological targets receive the canonical
transmitted impulse and retain their existing defenses. Save/load and repeated
initialization do not recreate components.

Observed first-impact damage against fresh stationary gates: small wood
39,800; small reinforced 52,334; small armored 0; large armored 161,271.
These are engine observations under the listed inputs, not fixed damage data.
Changing transport mass to 1,000,000 kg retained the same small-wood result.

### Encounter/control contract for #16 and #21

Create an opt-in `CaelumSiegeEncounter`. Register the existing attacking
Mandingas/Zupay through `RegisterAttacker`, each hostile machine through
`RegisterMachine`, and retain the returned records. Register the boss record
as `Boss`; defenders, player, corpses, projectiles and unrelated actors are
rejected or excluded. #16 must supply the existing 1,000 Mandingas, not spawn
62 additional campaign operators. `AssignCrew` reserves unique Mandinga records
for one machine. Set Large before the first InitializeRam call (false for a small ram), call `SetRoute(gate, finalAngle)`, append
`AddRoutePoint(position)`, then `SealRoster` and `ActivateRam`. Repeat registration
of the same actor is idempotent. Set `Enabled=false` for a reversible command
stop. Target/routing changes are rejected while striking or recovering.

Sealing a smaller roster permits an isolated lane but cannot grant port victory.
Only twelve neutralized hostile machines plus a confirmed dead registered Zupay
set `Victory` once. Cannon mechanics remain #21;
the port contract is six attacking and twelve defending cannons. Only the six
attackers register as objectives. #16 consumes the one-time victory hook and
owns rewards; this patch does not grant campaign rewards or create a director.

An armed machine remembers every registered live attacker entering its local
3D radius, with no line-of-sight condition. Overlapping areas may remember the
same enemy. A native death event is required for every remembered guard;
absence, unloading/destruction of a live actor, distance, missing operators,
or an initially empty area cannot stand in for a kill. Nearby death events
also capture enemies killed between scans. Once neutralized, the machine stops
and cannot reactivate; completed impacts/projectiles are not undone. New enemies
arriving later do not reopen that completed objective. Missing unresolved
records conservatively remain pending. A mapper must register the complete
attacking encounter roster before sealing it.

For withdrawal, assign each combatant record an `ExitNode` chain of
`CaelumSiegeRouteNode` actors, and mark its final node `IsExit=true`. Native
movement, at the actor's existing speed, follows the reachable authored route.
An obstruction stops progress; an absent route leaves the survivor in place
without attacks. Neither condition revokes earned victory. Only reaching the
exit radius at the route's height removes the survivor, without Die, a kill,
loot or kill-dependent reward. Fleeing, exited, dead, neutralized and victory
records use native serialization. Existing saves default to no encounter and
no actor conversion; there is no destructive migration. Pre-feature saves can
retain their old EventHandler list, so registered actors also confirm death
after native Die through the same idempotent receiver. This preserves old-save
neutralization without polling health or treating missing actors as deaths.

## 4.36.15 — Breakable actor gates (#19; planned label 4.36.11)

Historical delivery baseline: speed, attributes and impact mitigation below
are superseded by 4.36.19; the 30/60-second cycle and scenario targeting
are superseded by 4.36.27 above. Other shared mechanics remain current.

The author's 2026-09-26 clarification defines the issue's 0.3/0.5/0.7 as
ordinary weapon damage reductions of 30%/50%/70%. Invert the existing Type 4
curve rather than assigning attributes 30/50/70. Constitution equals the
resulting Toughness, including fractional levels and the armored value above
100. The author approved the proposed moving masses; each health pool covers
both leaves together. The accepted 3 x 3 m visual opening remains 96 x 96 MU,
with an 80 mm wood core (2.56 MU); this is the #18 reference geometry.

| Material | Reduction | Toughness = Constitution (approximate) | Moving mass, both leaves | Maximum health |
| --- | --- | --- | --- | --- |
| Plain wood | 30% | 46.024571081 | 550 kg | 65,017 |
| Reinforced wood | 50% | 70.565110990 | 650 kg | 170,625 |
| Armored wood | 70% | 108.052214779 | 1,100 kg | 659,083 |

The attributes are computed without rounding: D = (sqrt(1 + 20200*r/(1-r))-1)/2.
Health reuses floor(10 * [100 + C*(C+1)/2] * mass/100), with the existing
minimum of 1. Weapon hits round retained damage using the existing minimum
positive damage rule. Native projectile DoSpecialDamage runs before this
reduction. Gate blockers represent one shared health pool; large weapon
sweeps hit that pool once, and one explosion uses its strongest blocker
sample rather than summing samples. Gates have no humanoid anatomical weak
points, armor layers, regeneration, loot or additional material multipliers.

Historical pre-#194 physical siege impacts used the following path (superseded above):
ResolveExternal uses moving-assembly mass, actual contact velocity in MU/tic
and the contact normal. Damage is round(Hmax * max(0, E - D)/100), with neutral
surface/contact factors. Type 4 is not applied again. The caller supplies a
nonnegative monotonically increasing impact serial per moving source; repeated
or older serials cannot deal damage again. Neither frame mass nor a fixed
damage/forced-destruction shortcut replaces that calculation. #20/#21 still
own actual ram/cannon operation and high-speed projectile contact detection.

The author's 2026-09-26 follow-up identified a missing native body-collision
connection. CaelumGateBlocker.CollidedWith now forwards player/NPC contact to
the whole gate. ResolveBodies uses the character's effective mass and actual
velocity, the complete gate mass, and the gate plane normal. The character
receives SourceDeltaSpeed through its existing ReceiveCaelumImpact defenses;
the gate receives TargetEnergyPercent through the same structural conversion
used by siege impacts, including the existing body surface multiplier. The gate
remains anchored. A shared whole-gate ImpactContactState rejects repeated block
callbacks until canonical separation/rearm, and survives save/load. Opening or
destruction disables this route. Low-energy contact can still cause zero damage;
no new damage floor, mass, resistance, speed or threshold was introduced.

CaelumBreakableGate is explicitly opted into by spawning it; no old door is
converted. args[0] is a positive linked group (zero means independent),
args[1] selects material 0/1/2, args[2] enables ordinary Use, and args[3]
selects an existing LOCKDEFS key. AccessCondition reuses faction requirements.
Every group member must allow access. Use opens both visible leaves and all
linked blockers; the existing 105-tic door hold is reused. A solid actor in
any member's passage prevents group closure. The first actual health loss
selects Damaged; zero health selects Broken and clears every linked blocker
once. Repeated damage/death is inert. The open visual is the accepted Broken
pose, reused for temporary opening; closing restores intact/damaged appearance.

Health, group state, counters, blocker references and impact identities use
native actor serialization and hub snapshots. Existing schemas and WADs are
unchanged; an old 4.36.14a save loaded and activated the optional trial without
duplication. Native evidence: assets/validation_43615. The author confirmed all tests passed
on 2026-09-26 (CA-43611-GATES-01), including the corrected body-collision path.
HISTORY records acceptance; the historical test ID is intentionally preserved.

## 4.36.14a — Distinct siege materials and visual states (#18 correction)

Gate material and gate state are independent: wood, reinforced wood and
iron-clad armor each have intact, damaged and open previews. MODELDEF no longer
overlays the closed model on the open pose. Preview actors remain nonblocking
in every state; usable/damageable campaign doors remain #19. The issue already
specifies hardness 0.3/0.5/0.7; this art correction does not assign those values,
infer health or invent mass, damage, reload timing or resistance multipliers.
The author-approved gallery cleanup disables table/chair/bed/station trial
placement only in MAP03 and removes saved instances there. Tables release their
stored consumables as pickups; portable sleeping bags and unrelated travel,
storage and hazard actors are outside this cleanup. MAP02/MAP06 facilities are
preserved. No crafting recipe or siege combat rule changes.

## 4.36.10 — Siege assets are visual-only (#18)

Issue #18 introduces reusable cannon, battering-ram and destructible-gate
models and their MAP03 preview gallery. These are rendering assets only: no
cannon damage, ram strike, gate hardness, mass, reload time, ammunition, recipe,
economy rule or player interaction is added. The preview actors do not block the
player and cannot be used, damaged or opened. The future siege rules remain
owned by issues #19-#21 and will be documented here when their values are
defined.
## 4.36.8 — Prisoner rescue, escort and port rewards (#14)

Each reserved MAP02 cell now offers release through a prisoner conversation; the
freed actor becomes friendly, stops counting as a kill, follows the player and
fights using the source mansion character's exact combat profile. It stays back
from the northern Zupay and is extracted alive only at the pre-boss reservation
before that fight; killing the boss is not required, and a follower that dies
before extraction is not rescued. Persistent per-prisoner state survives save,
load and travel; extracted prisoners appear once at the MAP06 port, where their
own-faction thanks grant +10 reputation and 25 gold coins (1,000,000 copper)
exactly once, independent of character size. A failed coin delivery is retryable
without duplicate money or reputation. The six canonical factions replace the
former provisional domains: Unitarians=0, Federals=1, Free Peoples=2,
Caelith=3, Cult of the Tarot=4 and Sun Warriors=5.

## 4.36.7 — Inert prisoner appearances (#13)

The four reserved MAP02 cells now contain one prisoner actor each. These actors
are visual/identity placeholders for #14: they use the source character's exact
combat profile and recolored poses, but in the cell they are friendly,
invulnerable, do not count as kills, keep the accepted A/B idle breathing
poses without entering the walking/chase animation, and do not chase or
inherit mansion anchoring/quest behavior. Their persistent identity is the map thing/class,
not the provisional display name.

The MAP01 mansion residents and Palomo keep their story anchoring and separate
walk/run states, and their idle alternates the accepted monster idle A and B
poses. Conversations remain unpaused: MAPINFO keeps
`UnFreezeSinglePlayerConversations` and the common menu omits the delayed pause
of `ConversationMenu.Ticker`.

The display names are author-authorized working names: Leonor Benítez
(Caella/Unitarians), Rufino Acosta (Ronnie/Federals), Santos Barrera
(Rulo/Free Peoples) and Leandro Farías (Argento/Cult of the Tarot). These are
fictional names, not historical people; no military rank, army size, combat
bonus, formal alliance, betrayal detail or capture sequence is established here.
Rescue, escort, dialogue and rewards remain #14.

## 4.36.6 — Hostile sewer rats (#12)

Revision-2 MAP02 keeps its four keyed sections and existing contents, and adds
two hostile rats per Mandinga: 192 rats against the retained 96 Mandingas and
one Zupay (a fixed 2:1 ratio, 24 Mandingas / 48 rats per section). Rats reuse
the accepted `CaelumGiantRat` actor (DoomEdNum 18029) and RATG sprites; no new
damage, health, AI, art or balance value is introduced.

Each Mandinga junction gains two fixed dry-walkway placements, written
deterministically by the generator and recorded per section in the manifest.
Rats are initial placements only and never respawn or resurrect, preserving the
ratio throughout the map. The historical 0i `MAP02 and rewards` table below is
unchanged and continues to describe that release.

## 4.36.5 — Sewer gates, refuges and known-recipe repair (#11)

Revision-2 MAP02 uses four 5×5 junction networks. Section keys retain native
locks 203/204/205; the northern arena uses 206. Independent cell keys use
207–210. Keys are not consumed. Barred gates retain native movement, Use,
hitscan and projectile blocking while closed, but permit sight through their
transparent existing texture. Unlocking permanently removes the barrier; there
is no auto-close collision with future followers. Refuge gates need no key.

Each cell contains an existing usable bed and a reserved prisoner marker.
Routes from all cells join the extraction marker before the northern boss
door. This marker grants no rescue, reward or player travel shortcut. #14 owns
live escort/four-companion combat and backtracking tests; width alone is not
evidence that its future AI works.

The minimum T1 repair network comprises workbench, forge, ranged workshop and
essence altar, connected using the existing station-range rules. Four alcoves
contain that network; original entrance infrastructure is preserved/repositioned.
The alcoves contain no placed enemies or traps, but do not grant invulnerability
or suppress normal combat/rest guards. Existing time-advance zones cover the
relocated arrival furniture/workshops, four refuges and four cell beds; all
normal threat, rest and fast-time restrictions remain. Existing materials come from finite
salvage; no new allowance, raw-material spawn or recipe source is introduced.

The author clarified during implementation that only a known final weapon recipe
permits repair. Physical type and magical essence must match the known recipe.
Possessing components alone does not bypass that requirement. Rejection occurs
before reservation, wear or inventory changes; existing paid repair times/costs
and dismantling rules remain. Other weapons can wear out and break normally.

Geometry changes cannot load into an old GZDoom snapshot: the engine verifies
map geometry before restoring ZScript. `-LegacyMap02` selects the checksum-verified
original WAD under the same MAP02 and package names. This revisioned compatibility
mode preserves old progression exactly and is reversible by rebuilding the normal
package; retain it whenever loading a campaign that visited the old maze. It does
not reset/repopulate or silently convert an old map into the new four sections.

### Key dependency graph and ordinary-player route

Start → southern key 203 → western key 204 → eastern key 205 → northern
key 206 → Zupay arena → defeat boss → Ace of Cups → existing player exits.
Cell keys 207–210 are reachable in their own sections, outside the cells.
All four cell branches return to the same pre-boss extraction point; none
requires crossing the boss door. Refuge gates are unkeyed branches.

| Section | Progression key (x,y) | Cell key (x,y) | Cell/bed center |
| --- | --- | --- | --- |
| south | (1280, 1536) | (1792, 2304) | (2560, 3840) / (2464, 3680) |
| west | (1280, 4864) | (1792, 5632) | (2560, 7936) / (2464, 7776) |
| east | (-1792, 12032) | (1792, 11264) | (2560, 12032) / (2464, 11872) |
| north | (-1024, 13824) | (-512, 13056) | (2560, 16128) / (2464, 15968) |

Extraction reservation: `(896, 16896)`; northern boss center: `(1536, 18304)`.
Walk the maze branches to obtain each key, open its corresponding gate with Use,
and return from cells along the opened route. No debug command, jump shortcut
or sewage-damage exception is part of this route. The manifest records every
edge, chest, provision/ammunition bundle, trap and gate; the independent validator
searches actual generated floor cells with maximum-body clearance and closed
barriers, rather than trusting the logical generator graph.

## 4.36.4 — Acquisition and chest contract (issue #10)

MAP02 supplies only Tier 1 equipment: exactly 65 distinct combinations, retaining
all four armor types in all four slots, all 20 weapon families and their existing
essence variants (36 weapon entries), four shields, four amulets and five seals.
Fresh maps distribute 26 two-item and 13 one-item chests over the existing 39
locations. The accepted 120 food/120 water rations, repair rules and other map
contents remain unchanged. The historical 0i table below describes that release.

New natural world equipment and equipment rewards use CHARACTER_DEFAULT for
weapons, armor and shields. The recipient's CharacterProfile is mapped by
GetDefaultSizeForCharacterTier: body tiers 1–2 -> XS, 3–5 -> M, 6 -> L, 7 -> XL.
The existing mapping intentionally has no default S branch. Amulets, seals,
provisions, keys and money retain their existing nonsized rules. The policy is
separate from resolved EquipmentSize: editor size argument zero still defaults
to M; the resolved EquipmentSize enum is unchanged (its zero value means XS).
Weight, maximum durability and economy valuation use the existing rules for
the resolved tier/size; no balance formula or crafting/merchant sizing changes.

Resolution commits only with successful transfer. A preview or capacity failure
cannot reserve a shared item for one character. The actual recipient is checked
again at collection. Once acquired, identity, size and condition persist through
drop/re-pickup, transfer, saves and travel; imported/owned T2/T3 remain intact.
Migration is revisioned and idempotent. Old saved chests retain their original
T1 slots and looted gaps, without replenishment; unclaimed T2/T3 are retained in
a separate migration backup rather than offered as loot. Fresh-map distribution
does not retroactively fill an existing map.

First Use opens a Spanish preview of actual remaining chest entries, including
names/quantities and applicable tier, recipient size and essence. Explicit
collection uses the same inventory references, revalidates current contents and
capacity, and shows what remains; cancel transfers nothing. Empty chests say so.
Concurrent users share one stock and do not receive per-player duplicates.
Confirming collection returns to the HUD so acquisition/capacity notices remain
readable; Use again previews the current remaining contents or explicit empty state.

Successful acquisition notices identify the actual item and received quantity.
Failed transfers announce no success; a chest identifies each successful item.
The top-left gameplay feed holds at most 20 entries in chronological order;
the 21st evicts the oldest. Each expires independently. The initial duration is
eight seconds, configurable through one project CVar for author adjustment.
Debug reports and full NPC conversations remain outside this feed.
Native evidence and the exact authoring API are recorded with this delivery;
The author confirmed CA-4364-T1-LOOT-01 passed on 2026-09-23; HISTORY records
the acceptance separately from native/static verification.

## 4.36.2 — Bow presentation performance

Issue #8 caches the existing crop-only bow-stave composition; native color
effects and A/B/C presentation remain unchanged. This changes no ammunition,
magazine capacity, reload time, damage, controls or persistent schema. Empty
bows still hide the arrow; loaded bows show it. Evidence and the author's
2026-09-23 pass confirmation for CA-4362-BOW-EMPTY-01 are in HISTORY. Environmental scope follows PROJECT: the existing
ceiling/elevator cover moving sectors; avalanches and damaging surfaces are
future work and no longer block 4.36. No new hazard is implemented here.

## 4.36.1 — Documentation scope

Issue [#6](https://github.com/damiancurti/Caelum-Argenteum/issues/6) translates
the maintained specification into English. All rules, formulas, constants,
units and accepted decisions retain their prior meaning. Formula identifiers,
code examples, proper names and literal localized game text retain their
original spelling; game localization and runtime behavior are unchanged.

Release-specific sections preserve the state at their original date. Current
author checks live in [pending_test.txt](../pending_test.txt); recorded results
are in [HISTORY](HISTORY.md). This documentation patch does not constitute a
new engine test or automatic author acceptance of the retained 4.36.0i systems.
Actual author confirmation received on 2026-09-23 is recorded in HISTORY:
maze, save/load and tables passed; flail pose remains partial and an empty-bow
equip stall is reported. Corrections #8/#9 are planned, not implemented here.

## 4.36.0i — active rules and maze

### Resting weight: approved and active formula

Historical rule: superseded by the 5.2.11 / #194 energy contract above. Retained as provenance.

    exceso = max(0, (M_encima + M_carga) / C - 1)
    daño_por_segundo = H_max * 0.10 * exceso

M_encima is the actual mass transmitted by bodies on the victim, including the bodies
stacked above them. For players it includes body mass and inventory; for NPCs, Mass and
their armor. M_carga is the victim’s own load. C is the current capacity (player:
CarryCapacity; NPC: Mass × Tipo4(Fuerza)/100). All masses are expressed in kg. Without
external mass or a positive capacity, the system causes no damage.

Solids without noclip, vertical contact ±0,5 MU, XY overlap, near zero vertical speed
and native bOnMobj are required. A body with NOGRAVITY does not transmit weight. The
search uses the local blockmap and strictly increasing Z. Each level distributes its
weight and that received between its supports; it does not duplicate mass through
stacking. Loads at 150%, 200% and 300% of capacity produce 5%, 10% and 20% of Hmax/s.
The first support tic only records contact to separate the initial impact. From the next
tic, daño/35 accumulates, retaining the fractional remainder. Removing the mass stops
the damage. CaelumWeight passes through DamageMobj with DMG_NO_ARMOR, with environmental
pain/interruptions and without Adrenaline gain. The existing kinematic impact and the
ceiling’s percentage conversion retain their own paths.

### Food, water and tables

The mass used for needs is body mass, excluding load. Each food ration weighs 0,2 kg.
Water: 0,2 L =0,2 kg per ration, also in inventory, the Box and purchases. Per pulse:
food =80/M; water =400×L/M percentage points. There are ten pulses per serving.
Therefore, 2 kg or 2 L produce 100 points for 80 kg; a different body mass requires
2×M/80 kg or liters. This is gross recovery: needs consumed between portions are
calculated separately. The bottles use the same factor; normal sip M/400 L and real
fractions. Digestion preserves Sleep -= hunger effectively recovered/4.

SeedMansionFood uses Capacity, not SeatCount. Six tables, 94 slots: 4×4+18+60.
MansionFullFoodPrepared records a one-time allocation. Existing food is counted and
other belongings are preserved; if there are no free slots, the remaining allocation is
cancelled. Removing food, eating it or returning to the map does not replenish the
allocation. The objects are real CaelumFoodRation instances owned by the table and
represented by plates.

### MAP02 and rewards

Reproducible UDMF geometry: three 7×7 mazes with branches and loops, native doors
203/204/205 and gate/crypt/sanctuary keys. Each key precedes its door; no connection
between sectors bypasses it. Pits 96 MU deep have six 16 MU steps for walking out.

| Initial contents | Count |
| --- | ---: |
| Labyrinth rooms | 147 |
| Mandingas / Zupay | 96 / 1 |
| Mines / teleports / ceilings | 12 / 6 / 9 |
| Rolling rocks / vertical rocks / pits | 6 / 6 / 6 |
| Chests / equipment items | 39 / 195 |
| Armor / weapons / shields / necklaces / seals | 48 / 108 / 12 / 12 / 15 |
| Food/water rations | 120 / 120 |

Equipment: all four pieces of the four armor families, the 20 families of weapons (five
essences for each of the four magical families), four shields, four necklaces and five
seals, in T1/T2/T3. Size M, initial native durability. Each sector contains its tier.
Supplies are in 24 pairs of five-unit stacks. Enemy profiles and equipment balance are
unchanged. Rolling rocks use 32 MU/tic. The historical 10%-Hmax ceiling
severity is superseded by #194 work; native 8 MU/tic speed is retained.

CaelumMazeChest retains five real Inventory instances. First Use opens; second removes
by CallTryPickup. What does not fit remains in the chest. Its pointers, opening state
and allocation are serialized; it does not replenish or regenerate delivered items. Keys
follow the native inventory/weight rules and are not consumed.

Zupay: CaelumZupayColossus, TID 43799. The Ace (1) of Cups is TarotOwned[36]: +1 to
Charisma/Empathy/Eloquence before the +1% collection. It is only captured after beating
the Zupay and a second capture does not accumulate anything. It uses the CTAR back, the
existing reveal/capture audio and the Journal; no frontal art is added. The essence
disappears only after joining the collection.

CanDepart validates Zupay and card for every MAP02 exit. Connection 14 leads to the
MAP07 coast; 15 returns to the final chamber (PlayerStart 1). Arrival from MAP01 uses
PlayerStart 0 in the southern lobby and retains the Voice of the prologue. The journey
reuses the hub without reset of equipment, health or content. Old accesses to
MAP03/04/05 are located in the final chamber, under the same condition.
Furniture/provisions from old tests are not injected into the maze.

### Check

The GZDoom 4.14.2 report validates ZScript, actual opening/withdrawal, keys, door
movement, card, shared masses, dose and 94 rations in MAP01. The harness explicitly
advances food pulses and damage tics; the bOnMobj support was also observed during real
simulation. The animation test recorded 17,424612° →377,424612° in eight steps, complete
turn. The content validator checks 207 catalog conditions, connectivity, keys, pits and
FP layers. It does not replace a human playthrough or validate Windows.

## History 4.36.0h — percentage ceiling, starting meal and weight proposal

### Native ceiling: implemented in source

Historical rule: superseded by the 5.2.11 / #194 energy contract above. Retained as provenance.

P_DoCrunch in GZDoom g4.14.2 calls damage with type Crush and null source/inflictor. It
applies a pulse when (maptime & 3)==0, while crushing exists. CaelumPlayer and
CaelumCombatActor convert that value once:

    D_pulso = redondear(H_max × valor_nativo / 100)

The current value of MAP08 is 10: it is equivalent to 10% maximum health per pulse, not
per second. Examples without native modifiers: Hmax=100 → 10; Hmax=1780 → 178;
Hmax=107060 → 10706. The rhythm of four tics is kept by the engine; no one-second timer
is introduced.

The damage continues by Super.DamageMobj with DMG_NO_ARMOR and retains pain,
interruptions and absence of environmental Adrenaline gain. Native modifiers and immunities
continue to apply. Drowning and CaelumImpact are not scaled; the Crush sources with
explicit actor retain their previous units.

CaelumCrushingDamage.FromNativePercent preserves non-positive values and special
commands >=1000000. Normal pulses are limited to 999999 points so as not to accidentally
activate the GZDoom telefrag semantics when scaling extreme health values. This limit of
interoperability is not reached in the example of the character in the screenshot. The
value of the trap or its map is not changed.

### Supported mass: proposal pending the author's decision

The search recovered an impact formula and a contact formula with sustained impulse. The
latter requires positive closing speed; it does not represent the weight of an already
still body. No approved static formula was found.

Game rule proposal, NOT implemented in 4.36.0h:

    r = max(0, (M_encima + M_carga) / C - 1)
    daño_por_segundo = H_max × k × r
    k propuesto = 0.10

M_encima: mass effectively transmitted by bodies resting on the victim, including those
resting on them. M_carga: own load already calculated by inventory/equipment and the
Box. C: current carrying capacity, using the same units of mass. Hmax: maximum health,
to maintain relative severity across characters with different health. Positive C is
needed.

| Total external mass / capacity | Excess r | Proposed damage / second |
| --- | --- | --- |
| 100% or less | 0 | 0% of Hmax |
| 150% | 0.5 | 5% of Hmax |
| 200% | 1 | 10% of Hmax |
| 300% | 2 | 20% of Hmax |

The proposal requires real support contact: a rock hanging on the head does not count.
Removing it stops the damage. Stacked masses accumulate only once; if a body has
multiple supports, its load is distributed without multiplying. Landing retains its
single impact, separately from subsequent static damage. The application uses simulation
time and retains fractions to prevent truncation of small damage. It is not activated
until the formula/coefficient is approved.

The selection of capacity as a threshold and k=0.10 is a new proposal, not a value
recovered from previous decisions. It is subject to the authorial premise of not
incorporating balance numbers without agreeing on them with the creator.

### Table food: persistent initialization

Each MAP01 CaelumDiningTable calculates SeatCount minus existing rations once and
records MansionFoodPrepared/MansionFoodToSeed. It creates that amount as actual
CaelumFoodRation, Count=1 and Owner=table. RefreshDisplays uses existing dishes. Current
tables add up to 4×2 + 6 + 12 = 26 seats.

The state per actor covers tables already saved, even if the furniture controller is
already prepared. Consuming/removing food does not increase the remaining allocation. A
creation failure tries only the outstanding balance. A full table preserves all its
objects and cancels the assignment that does not fit: it does not wait for a free slot
to replenish it later. It delivers no food outside MAP01.

Inventory/Box deposit, withdrawal, digestion and reservation routes do not change. No
periodic replacement or initial drink is added.

Technical references: official sources g4.14.2 of
[P_DoCrunch](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/p_map.cpp) and
[DamageMobj](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/p_interaction.cpp).
Local test models do not replace actual start-up, inventory and save in GZDoom.

## 4.36.0g — segmented presentation and axe attack

The documented catalog defines the axe with a slashing primary attack and a stronger
blunt secondary attack with shorter range. CaelumAxeSelectorWeapon retains the shared
physical path and the player consults GetSecondaryDamage and GetSecondaryDamageType.
This delta does not alter those callbacks or introduce damage or reach values. The full
catalog source is not among the recovered files; the documentation is not presented as
an executed damage test in GZDoom.

The visual dimensions are independent of the impact range. In CaelumFirstPersonLayers,
the new parts use 48 (handle/shaft), 50 (head), 51 (left hand) and 52 (right). The axe
head scales ×1.5 at its junction (77,118), while the handle retains its scale. In the
halberd:

    g = (85,150); j = (76,104); a = (j-g)/|j-g|; k = 1.8
    delta(p) = (k-1) * dot(p-g,a) * a
    headPosition = weaponGrip + Turn((j-g) * size * k, rotation)

Coord0–Coord3 receive delta in the four corners of the canvas of the handle. This
retains the transverse width and grip position. The blade and its ribbons are moved as a
rigid piece, without the axial stretching. Narrow cuts exclude the straps of the
extended handle. The halberd’s resting rotation remains at −28°; the flail’s changes to
+28°.

Bows: 46/47 string, 49 full hand and index finger, 50 wood, 51 DH12 (thumb +
middle/ring/little finger phalanges), 52 right hand, 53 arrow. DH12 shares canvas,
offset, pivot and scale with DH03; cuts return to their original coordinates. Cleanup is
preserved when changing weapons.

The palettes use two nested native Graphics. Translation Desaturate mixes gray at n/31
(greatsword 20; bows 24). Then Blend without alpha modulates RGB by (205,198,188)/255 in
the greatsword and (194,186,174)/255 in the bows. Two steps prevent Blend from replacing
Translation within the same Patch. The icons of the greatsword are displayed with
Graphics that preserve public routes; identical sources with different names avoid
self-reference.

The implementation and assumptions were checked against the source code of the renderer,
texturemanager, multipatchtexturebuilder and bitmap of GZDoom g4.14.2. The
VALIDATION.json report separates local verifications from the engine tests, which are
still pending.

## 4.36.0f — audit of crushing and impact

There are three different mechanisms. The rock applies kinetic damage when colliding,
including vertical reception by landing. The character contact graph can apply periodic
damage when it continues to transmit momentum. The CaelumCrusherTrap ceiling uses native
GZDoom crushing. There is no continuous damage due to the mere weight of a rock that was
already immobile above a character. This latter limitation is still pending; it is not a
mass failure or instant death rule.

### 1. Rock collision: mass, impulse and speed received

Implementation: src/impactphysics/ImpactPhysics.zs, ResolveBodies and
ResolveVerticalBodies; reception in CaelumPlayer and CaelumCombatActor.

- Horizontal closing speed: v=max(0,(vs−vt)·n), with n unit.
- During a fall: v=max(0,vt.z−vs.z).
- J=(1+e)v/(1/ms+1/mt); e=0 in Caelum.
- Δvt=J/mt=ms/(ms+mt)·v. Δvs=J/ms.

ms is the effective mass of the source; mt that of the receiver. The expanded rock uses
radius 48 MU, height 96 MU and mass 38170 kg, calculated as a granite sphere 3 m in
diameter at 2700 kg/m³ and 32 MU/m. The large mass makes Δvt approach v; does not
multiply damage indefinitely by 38170.

### 2. Damage conversion

u is Δv after applicable damping. In an environmental player collision without active
acrobatic defense, u=Δv. The buckler/gauntlets can reduce it; damping for a fall onto
the ground follows another path. Do not confuse a rock falling onto the head with the
character's own landing.

t=28/u; if u≈0, a very large time is used. E=0 if t≥35. Otherwise:

    E = 100 · ((35/t)² − 1) / (35² − 1)
      = 100 · (u² − 0,64) / 783,36

E is a reference percentage, not physical energy in joules. Its undamaged threshold is
u≤0,8 MU/tic; u=28 produces E=100%. It is not limited to 100%. The height of the
character no longer alters the reference of 28 MU.

    P = S·E
    R = biologicalMassKg * (1 + 7*(T*T+25*T)/12500)  [#188]
    W = suma_i [ wi · Vi · (1−Ai) ]
    Damage = floor(max(0, Hmax * P * W / 100 - R) + 0.5)

S is the surface multiplier (rock: 1); T is the effective Toughness attribute level;
Hmax is maximum health, not remaining health. wi weights anatomical overlap; Vi is
vulnerability after reinforcement and Ai is the defense of the corresponding piece,
between 0 and 1. Vi can be 2, 1,6, 1,3, 1, 0,8, 0,6 or 0,4. The vertical impact of the
rock has contact in relative height 1,0. The final damage uses CaelumImpact and avoids a
second armor application.

Historical pre-#188 calculated example, not current damage values: ms=38170 kg, mt=75 kg, Hmax=1780, T=13, S=1,
W=1, without damping. The receiver is initially stationary.

| Closing speed (MU/tic) | Received Δv | E (%) | Rounded damage |
| --- | --- | --- | --- |
| 8 | 7.984 | 8.06 | 138 |
| 16 | 15.969 | 32.47 | 558 |
| 24 | 23.953 | 73.16 | 1257 |
| 32 | 31.937 | 130.13 | 2236 |

Actual health, armor, anatomy, relative motion, and acrobatic defense can change the
result. It is not guaranteed to kill any character.

### 3. Sustained contact and native ceiling

The graph uses Jp=v/(1/ms+1/mt) to transmit the inelastic impulse and avoid duplicating
it in callbacks of the same pair/tic. RegisterSustainedTransfer triggers reception every
35 tics with a recorded transfer. The pulse uses the last Jp, not a sum of 35 impulses:

    veq=Jp·(1/ms+1/mt)

ResolveBodies retrieves Δv; IMPACT_KIND_CRUSH subtracts biological landing damping and
uses the same curve E, hardness and anatomy. Without positive closing speed, no new
pressure is recorded. This mechanism does not calculate static force mg, contact area or
pressure F/A.

CaelumCrusherTrap calls Level.CreateCeiling with ceilCrushRaiseAndStay and crushDoom. In
MAP08: speed 8 MU/tic, minimum height 8 MU and native damage args[0]=10 per pulse. That
damage is NOT obtained from the previous impulse formulas; it enters as Crush by the
native environmental path.

### 4. MAP08 fast rock in 0f

TID 43602 changes its horizontal initial thrust from 8 to 32 MU/tic: 1120 MU/s,
equivalent to 35 m/s with the 32 MU/m scale of the resource. It is a test value of this
trap, not a global impact modification. It has no motor that replenishes speed, telefrag
or minimal lethal damage.

The WAD and its generator contain 32. GetReleaseSpeed recognizes the 8 value of the
original TID in an old save and uses 32 in the next release. It does not change the
speed of an already released rock. Other explicit maps/TIDs/values are preserved. The
vertical rock TID 43603 keeps falling.

The ca_debug_hazards_report report shows the configured release speed, current speed, mass,
impulse and damage of the player. It allows to distinguish no contact, E cancelled by
Hardness and subsequent reduction from anatomy/armor.

### 5. Presentation of weapons

Turn corrected with 4.14.2 renderer; NoTrim and absolute pivots. The string is drawn by
vertices and the arrow uses 53 layer. Bow order: 46–47 string, fingers 49, limb 50, 51
thumb, right 52 and 53 arrow. The state of ammunition and shooting callbacks continue to
determine the presence of the arrow. See ASSETS.md and PRUEBAS_4_36_0f.txt. GZDoom was
not executed in this session.

## 4.36.0e — corrections requested after testing 0d

[IMPLEMENTED] Fists with continuous forearms and the same glove of the other weapons;
left and right come from the same original PNG, reflected by TEXTURES. The original set
of hands is also used for both bows. The left is in a layer in front of the right. Glove
sizes independent of the size of the weapon.

[IMPLEMENTED] Hatchet, axe, war axe and halberd tilted to the right with the handle
seated on the grip. +20% sword and greatsword +15% relative to 0d. Standard recurve bow
and longbow with continuous limbs, both in T1–T3, with a string between the tips and
hand, and visible arrow only if loaded.

[IMPLEMENTED] MAP01's trimmed chord at the first revelation of the arcane. An original
level-up sound plays on confirming capture and applying the bonus. [CONFIRMED BY THE
AUTHOR] Correct 0d transitions; its logic is preserved.

[IMPLEMENTED] Cart with front axle and two front wheels: four wheels in total. On the
boat, volume of Use not solid in front of the hull, in addition to the sign; the warning
remains centered and retains the requirements of boarding. New parts are added once when
preparing vehicles, also when loading.

[VERIFIED LOCALLY] Structure of changed sources and resources, references, layers, OBJ
geometry and reconstructed weapon/model views. GZDoom was not run for 0e: the complete
baseline had not been recovered and no engine was installed. Changed files start from
their latest recovered versions. [PENDING] Compilation and gameplay/visual testing in
GZDoom 4.14.2 / Windows 11. Instructions: PRUEBAS_4_36_0e.txt. The following sections
are historical.

## Current corrections 4.36.0d

First person: Corrected families use CaelumFirstPersonLayerFrames, new class with
Weapon/Overlay states, and 48–52 layers. TEXTURES reverses the weapon and defines its
grip point without inverting the hands. crossbow/carbine support layers go behind the
weapon; in bows, the dorsal left passes in front. A common transformation holds together
weapon and grips during the attack. Creating a layer initializes its previous position
to prevent interpolation from the source; bow hands are not recreated each tic.

The sword now uses the same view of small hands as the other families. Its old states
remain in the same order to load saves; its visual callbacks remove the old rig and the
HUD uses the common blocking presentation. They do not alter callbacks of damage,
shield, Air, Anima, durability, ammunition or times. Dagger and magic retain their
compositions.

Holstering applies X = -0,85 × native descent, in addition to the Y descent. During the
descent the outgoing family is retained even if the selection of the HUD changes. The
carbine displays B only during real recoil, C during reload and A at rest, also empty.
This supersedes the historical 0c row that assigned B to the empty weapon.

Fists: CaelumUnarmedWeapon derives from Weapon and has its own TNT1 states and layers of
two closed fists. It alternates right/left; retains the previous 22-tic fallback, random
native 2–20 damage, range and PowerStrength factor. It does not use sprites, visible
puffs or Doom sounds; does not add new impact sound. It is not a new piece of RPG
inventory nor does it change its catalog. EnsureUnarmedFallback supplies the fallback
when missing, removes legacy Fist and selects it if there is no usable equipped weapon.
The Limbo narrative cleanup retains its reach and restores the fists upon arrival at
MAP02.

Interaction hints: CaelumInteractionHint calculates a reading label in the world using
reach, orientation and CheckSight. It resolves the auxiliary collider to the actual
vehicle or table and respects CanBoard/CanReach. HUDInteractionHint draws it without
activating Use or opening menus. Tables, chairs/beds and vehicles use 'Use:'; pressure
plates indicate “Step on”. Looking away or moving out of reach hides the hint. Falling
carbine ammunition normalizes its scale to 0,10 in Tick, without changing mass, units or
inventory icons.

| Confirmed travel | Effect | Existing clip |
| --- | --- | --- |
| MODE_CART and MODE_CARAVAN | Native crossfade, 3 | caelum/travel/carriage |
| MODE_SHIP | Native melt, 1 | caelum/travel/ship |
| El Loco | Native burn, 2 | caelum/ui/map_transition |

Hub transitions: NoWipe in g4.14.2 blocks 35 frames after ChangeLevel. CaelumMenuAudio
prepares CAJVIEW near boarding and during the quotation/dialogue, suspends capture on
departure and preserves that view during the first 35 arrival frames. It then requests
the native wipe to blend distinct departure and arrival views. CAJVIEW uses 960×540 with
aspect adjustment for the screen. The camera is invisible and non-interactive. Audio
starts after channel cleanup. Neither wipetype, hub membership, clock, consumption nor
travel confirmation is modified. Saving/loading discards the pending presentation. A
console map change is not equivalent to confirming a trip. Local verification is
single-player; it does not establish additional co-op validation.

MAP08 Gallery: CaelumHazardGallery.Prepare adds a reset lever to (1088,1088,0), TID
43620, and an arrival rune to (1152,1664,0.5). MagicHazardRevision=2 allows you to
incorporate them into previous saves without duplicating actors or automatically
rearming what was already used. Mechanism 4 remains the reusable plate in
(2048,640,0.5), TID 43611; preserves free destination, rejection without telefrag and 35
tics protection. A correct activation confirms the arrival with message and blue flash
of 12 tics.

CaelumHazardResetSwitch first checks occupancy and moving ceilings. If it fails, explain
the cause without partially modifying the gallery. If applicable, closes the pit lid,
restores its cover, stops and repositions the rocks in their initial positions, rearms
the mine/plates/crusher and raises its levers. The lever itself lowers a second and
becomes available again. The lid and the queried mechanism's own rocks are excluded from
the occupancy query to allow repeated cycles. Historical counters are retained and
ResetCount is added. The large mass of 38170 kg and the damage formulas remain
unchanged.

The sections by lower versions retain the previous record; the grips, visual states and
travel described above replace their equivalents.

## Integration and fixes 4.36.0c

Pressure: IsPressedBy demands real support to the level of the plate, living and solid
character, without flight/noclip or ascent. The XY distance is compared to the sum of
the plate and receiver radii, including the part of the feet that treads on the edge.
Before it was compared only to the radius of the plate. A blocked destination does not
consume the trap; it is retried at the existing cadence. The diagnosis numbers
rejections: 1 without marker, 2 insufficient height, 3 solid occupant, 4 35 tics
protection, 5 collision rejected by TeleportMove(false).

Lever: CaelumLeverFace moves from 0,09 to 0,045. Tick also normalizes a previous
serialized scale and retains the up/down frame. The new click is only issued if Use
activated at least one mechanism.

First person: CaelumFirstPersonView receives PSpriteTick from the physical and magical
selectors and occupies exclusively the 50 layer. CaelumFirstPersonFrames contains new
Weapon/Overlay states, avoiding inserting states into classes that are already saved.
The sword retains its previous modular rig. The HUD omits the provisional icon when a
selector controls a native view; the gauntlets show their fists and not a second
blocking icon.

The 93 compositions retain the hand/weapon order of the manifest. Its canvas is 320×200
and its offset (160,32); the percentage pivots are calculated by visible box. The melee
curve moves the complete composition and uses only the approved relative twist, without
adding again the 18° of the ancient sword. The movement only begins when recovery grows
after an accepted attack. Magic observes the conclusion of the real callback. Nothing in
this controller takes resources, applies damage, fires projectiles or modifies combat
times.

| Family | Phases linked to the game |
| --- | --- |
| Short/long bows | A with arrow; B when aiming with ammo; C empty or after firing |
| Crossbow | A loaded; B fired/empty; C while reloading |
| Carbine | A prepared; B recoil/empty; C reloading the chamber |
| Book | A open and casting; B closed when lowering/raising or blocking |
| Gauntlets | A guard; B right punch; C left punch |
| Other new weapons | A with displacement and joint twist when attacking |

Changing equipment, dying, breaking the weapon, opening Inventory/Crafting or resting
clears the corresponding view. Lowering/raising accompanies the native position of the
weapon; changing map restarts presentation. The engine removes layers whose selector is
no longer active. Two-hand sets respect existing shield rules and do not incorporate an
additional hand.

Audio: The rock mono loop starts only when moving in XY with contact and without
falling. IsActorPlayingSound avoids restarting each tic and restores it on loading. It
stops when immobilizing, staying in the air or being destroyed. CHAN_5 is unique to its
friction; it does not add force or damage. Visual rotation follows the rolling path.
Tarot capture sends an interface event only after RecordMainM00FoolCapture; it is
independent of the dialog camera and does not play when inspecting a card or rejecting a
capture. The musical attenuation of the dialog and its restoration is still in charge of
the existing native menu.

| Confirmed crossing | Native transition | Local sound |
| --- | --- | --- |
| Cart, MODE_CART | 3, crossfade | caelum/travel/carriage |
| Ship, MODE_SHIP | 1, melt | caelum/travel/ship |
| El Loco, including MAP01→MAP02 exit | 2, burn | caelum/ui/map_transition |
| Other exits | wipetype preference | caelum/ui/map_transition |

PreTravelled consumes PendingTravelWipe or confirmed travel mode and sends wipe/cue to
CaelumMenuAudio. WorldLoaded selects a transition and reproduces the clip after cleaning
channels from the previous map. Requesting a quote/cancelling does not initiate
departure. Loading a save discards the pending presentation. The El Loco narrative
crossover leaves both scenes visible: its old black fades, which concealed the burn, are
removed. It retains validations, maintenance of the initial weapon, inventory cleaning
and arrival conversation.

Mass/impacts: 4π/3 × (48 MU / 32 MU/m)³ × 2700 kg/m³ = 38170 kg rounded. A_SetSize
enlarges an old block only when it fits; the report shows radius, height and
enlargement, as well as effective mass. The last impact shows origin, closing velocity,
initial percentage, Hardness, resulting percentage, armor and final damage. Damage is
not inferred from tonnage alone.

## Mines, teleport, crushing and presentation (4.36.0b)

CaelumPressureTrap consults the local blockmap. It demands living and solid body, feet
to plate height and real support; excludes noclip, flight, ascent and incomplete
creation. Activations interrupt rest/fast advance.

| Class / editor | Mapper Settings | Behavior |
| --- | --- | --- |
| CaelumMagicMine / 30963 | args[0] base damage; args[1] radius MU | It explodes once when you step on; zero disables. |
| CaelumTeleportTrap / 30964 | args[0] Target TID | Reusable local teleport, no telefrag. |
| CaelumTrapDestination / 30965 | TID, position and Angle | Explicit destination; does not grant objects or modify the clock. |
| CaelumCrusherTrap / 30966 | args[0] damage/pulse; args[1] speed MU/tic; args[2] sampling distance | Native ceiling: descends, crushes, rises again and stops. |

Mine: A_Explode with a real radius, passed through the existing anatomical defense.
CaelumTrapMagic identifies environmental provenance, no combat adrenaline or additional
Doom thrust. It retains vulnerabilities, armor parts and hardness. The XFIR re-uses the
flames. MAP08 is tested in 100 base points and 128 MU; they are not definitive campaign
values. The spent mark remains dim when saved.

Teleport: Validates marker existence, floor/ceiling, solid bodies and objects occupying
the destination before TeleportMove(false). An invalid or busy destination retains the
character in origin and does not count activation. It stops speed, clears interpolation
and tracking fall. An inventory per receiver prevents chaining another plate during 35
tics; then it can be reused. There is no general invulnerability, telefrag, travel
between maps or delivery of resources.

Crusher: Level.CreateCeiling with ceilCrushRaiseAndStay and crushDoom. Each panel
retains its original top height. args[2]=0 selects only its sector; MAP08 uses 32 to
choose four sectors of 64 MU, a square of 128 × 128. Use 8 MU/tic, lower separation of 8
MU and 10 points per native pulse test. Crush damage follows the native environmental
path of pain, without combat adrenaline; it does not replace the calculation of rock
impacts. It can be activated by pressure or by a lever directed at the same TID. Only
one cycle; no moves are superimposed. Moving ceilings block the nearby rapid advance and
keep its movement.

Levers: CaelumHazardReleaseSwitch accepts the TID of a rock or crusher. The transparent
CLVR sprite overlaps with an OBJ column and switches from top to bottom. args[1]=1 omits
the column to place it on a wall; the actor should be placed a little in front of the
face, with Angle facing the wall. The SF_IGNOREVISIBILITY check ignores only the
invisible support, keeping the actual occlusion of the walls. Switches with no activated
target are not consumed.

Native transitions verified in GZDoom g4.14.2:

| wipetype | Effect |
| --- | --- |
| 0 | No transition |
| 1 | Melt |
| 2 | Burn |
| 3 | Crossfade |

PreTravelled announces CaelumMenuAudio mode, which is already StaticEventHandler.
WorldLoaded applies ScreenJobRunner.setTransition(1) only to a pending boat trip and
emits caelum/ui/map_transition after cleaning the previous audio. It is a native
selection of a single crossing, without changing the cvar wipetype. Other trips retain
the user preference; loading a game does not repeat the sound or impose the effect.
Travel logic, resources and clock is preserved. Engine source:
https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/d_main.cpp (System_SetTransition and
D_Display), along with menudef.txt/screenjob.zs of gzdoom.pk3.

MAP08 adds by saved revision: mine (1728,640,0.5), teleport (2048,640,0.5), destination
(1152,1664,0), crusher (2240,1216,0.5) and lever (2240,1088,0). TID
43610/43611/43612/43613 respectively. It does not change the WAD. An immobilization rune
is proposed for revision, without implementation.

## Physical hazards and traps (4.36.0a, updated in 0b)

CaelumTrapdoor (30960 editor) is a native support ACTLIKEBRIDGE of 256 × 256 MU, 8 MU
thick. Its origin is 8 MU below the walkable surface. It requires a pit modeled in UDMF;
it cannot create a hole in a solid floor. CaelumTrapdoorCover reuses CSUF/CMWD01 and
matches the physical cover.

It is activated when the center of a live, already created and supported player is
inside the square, his feet match the lid and is not going up, flying or in noclip. It
also supports CaelumCombatActor actors supported. The query is local to the blockmap.
Stepping on it removes solidity and rendering once; gravity and landing follow the
existing rules. It does not teleport, does not add fixed damage, does not rearm and does
not close on who fell. Opened, ActivationCount and references are saved.

CaelumHazardRock (30961) passes to radius 48 MU, height 96 MU and mass 38170 kg: 4/3 ×
pi × (48/32)^3 × 2700, rounded. When loading an old rock in contact with obstacles it
retains its small dimensions first and only expands when A_SetSize confirms that it
fits. It does not move or re-launch by migration. It starts suspended; args[0] is the
horizontal impulse in MU/tic according to Angle, or zero for a vertical drop. It
releases that impulse only once. The rolling test omits friction; does not apply a
continuous motor. Visible rotation depends on the distance travelled. It does not
support manual thrust while it is retained. The native collision stops movement against
a wall.

CaelumHazardReleaseSwitch (30962): args[0] is the positive TID of rocks or crushers.
Using requires vertical reach, visibility and overlap with a live player. The operation
passes to Spent after releasing a destination; does not create new blocks. There is no
rearmament timer. Without a valid target, the switch is not consumed.

ImpactPhysics.ResolveVerticalBodies adds downward contact without changing
ResolveBodies/ResolveStatic. Use J = (1 + e) × Closing Speed / (1/m1 + 1/m2) and Δv =
J/m. Native geometry confirms landing on the body before applying biological reception,
located at its top end. The same support does not cause damage to each tic. Separating
allows a subsequent physical contact. Hardness, vulnerability, protection, lucidity and
health retain its rules.

IMPACT_KIND_ENVIRONMENT = 5 identifies the origin of these mechanisms. CaelumImpact is
maintained as a route of damage; DMG_THRUSTLESS avoids adding a native thrust alien to
the calculated impulse. There is no combat evasion or combat Adrenaline gain.
Protection is still pending implementation in V5. Fast advance is blocked if there is a
free rock moving in the already inspected safety radius. Opening the trapdoor interrupts
the rest of the character that activated it. Hazards are resolved at normal tic speed.

MAP08: eastern lobby access x=768, y=640–896. Cover centered at (1408, 896, 0), bottom
at -192 MU; twelve steps of 16 MU lead east. Rolling rock at (1280, 1344, 0), test
impulse 8 MU/tic, TID 43602; mechanism at (1152, 1344, 0). Suspended rock at (2048,
1600, 256), TID 43603; mechanism at (2048, 1536, 0). These are test-gallery dimensions
and settings, not new balance values for the whole campaign.

ca_debug_hazards_report identifies 4.36.0b and shows activation, solidity, lid, masses,
speeds, vertical contacts and used mechanisms. MAP05's WAD retains its original
checksum. MAP08 is incorporated as a 8 location, with 12/13 connections; no id is reused
and no records are resized. The MAP05 access appears at (640,704,0), also when loading a
previous save: SewerNetworkRevision moves from 1 to 2 and the placement is idempotent.
The MAP08 return uses lobby access in (0,96,0). Both directions use the existing local
travel service, no fare or supply consumption. Traps belong to the hub and retain their
status when going and returning. For an isolated test you can use map MAP08; that
command restarts the character.

## Animations and sitting consumption (4.35.0q)

SEATED_MEAL_TIC_DIVISOR = 3 is the only divisor of food/water advance while there is a
valid chair session. Full portion: ten pulses, one each 105 tics, duration 1050 tics =
30 s simulation to 35 Hz. Outside the chair 350 tics = 10 s are preserved. Fast advance
uses the same rule. Menu pauses do not count as simulation. Food and water are not
multiplied: the ration, dose per body mass, digestion and caps remain the same.
Inventory, table and Box use the common effect; automatic repetition waits for it to
end. A 3–9 partial counter from 0p continues without restarting the portion or spending
another. Medicines retain its previous rhythm.

Two-phase breathing in eight views; four-phase running and two-step walking where
separate resources exist. AI callbacks retain their intervals and the stunning guards
are repeated every two phases in the actors who already used that interval. Changing the
drawing does not change Speed. New states go to the end of each class, preserving the
indices of attack, death, crouching and rest from previous games. Domingo's old infinite
idle state is reactivated on loading to allow breathing. Palomo uses rest when standing
still, walking while wandering and running when departing or returning; emotions and
conversations retain priority. RestSeated and RestLying expose the new poses to the
controllers, without assigning a sleep routine to their agenda. Sitting/lying down stops
their wandering.

netevent ca_debug_rest_report identifies 4.35.0q and displays the current divisor.

## Reserves, controls and vehicles (4.35.0p)

Seat consumption: table priority → personal inventory → own magic box. Only FoodRation,
WaterRation and container water; does not use medicine. Starting another portion is rejected while its regeneration remains active or the corresponding need is full. Supplies are consumed directly without removing the entire stack or requiring capacity to move it.
Only an accepted use consumes a ration; Drink loses liters, preserves the container
and restores InMagicBox before the final result persists. Access requires sitting and
next to a valid table. Recovery is three times slower while seated from 0q with
identical portion; digestion = hunger actually recovered / 4.

Q/B: cancel trip; detail → month → World; Q in World closes Journal. Escape/Start is
left to the native menu and does not cancel those states. The release of +use is
preserved so the button does not remain held. The console is still accessible.

MODE_FOOT=1 and MODE_CARAVAN=2 preserve saves and the old walking trial. MODE_CART=3 and
MODE_SHIP=4 require a physical vehicle and only connections 10/11 (MAP06↔MAP07, 500 km).
They do not authorize sailing to the sewers. Walking portals remain available. Walking
speed and the 10 km MAP03↔MAP06 remain approved and unchanged.

CaelumJourneyRules.CART_KMH=3; SHIP_KNOTS=5; KM_PER_NAUTICAL_MILE=1.852. Carriage: 1 050
000 travel tics + 504 000 sleeping tics = 10 d 6 h 40 min. Ship: 340 173 sailing tics =
approximately 2 d 5 h 59 min 45 s; 100 800 of those tics are sleep aboard (16 h). The
screen rounds up to the minute: 2 d 6 h. The outside-world clock retains 6 300 tics/h of
campaign time. Sleep aboard is distributed within each 16–24 h interval of the passenger
cycle and allows a final partial rest. The ship also advances during those tics.

The numerical forecast applies hunger, thirst, sleep, digestion, regeneration, lucidity,
stunning and survival damage.The inventory and schedule are only modified when
confirming. Sleep uses the player's sleeping bag if carried; otherwise, the ground/deck.
The trip provisions are those carried outside the Box, as in 0n; the new access to the
Box requested here corresponds to the table.

SourceVehicle links the quote to the specific actor. Confirmation revalidates its presence, map, type, distance, route, action blocks and reserves. If the
forecast is changed materially, it is requested to review it again. Cancel, confirm or
finish removes the link. The transition reuses departure/arrival records, inventory
transaction and AdvanceTics from the existing agenda.

CaelumVehicleWorld installs a rancho shelter and a cart in (-640,192,0) MAP06 and
(-512,384,0) MAP07. The boats remain in (1536,768,-24) and (1280,1440,-24). The new dock
of MAP07 focuses on (1120,1312,0); its cover connects with the sand and uses 4 MU bridge
collisions, with a stop in Z=0. The rancho provides awning-type weather shelter and has
three walls/roof with collision. The boarding sign visible on the dock receives Use at
normal height. Repeated preparation/loading does not duplicate models, colliders or
vehicles.

## Scheduled agenda and events (4.35.0o)

The calendar uses the civil campaign anchor, not the operating system clock or TrialDate
of the debugger. TAB → World → F/RT. Arrow keys/D-pad: day; PgUp/PgDn or LB/RB: month;
H/Home: today; E/R or Y/X: event of that day; Enter/A: detail; Q/B: return; TAB: close.
In detail, P/RT pays debt or withdraw cargo. Navigation is local: it does not re-anchor,
advance or pause the game clock.

CaelumScheduleState is a hidden, persistent Inventory between maps. It contains up to
2048 series, with stable ID/key, type, localizable title, subject, map, initial date,
minute interval, limit, counter and status. Keys prevent duplicate records. Zero
interval is a unique event. Zero limit supports indefinite recurrence, up to the civil
limit and the 2147483646 counter. Intervals accepted: up to 525600 minutes. Gregorian
dates of years 1–9999. Each cell counts series, not a copy of each repetition within the
day.

CaelumWorldClock calls Sync after moving forward. The amount expired arithmetically per
series is calculated and saved once; a cache of the next date avoids reviewing all
series in each tic. Long jumps do not go through all occurrences. For routines/sieges
the phase with last effective date is chosen, regardless of the order of registration;
ties are resolved by the higher ID. The native inventory serializes objects, their
progress and the load. There are no operating system tasks.

0n trips keep your needs forecast and unique clock. The budget does not change the
agenda. Confirmation credits deadlines crossed, and destination consults the final
state. It does not physically execute armies or repeat inactive map routines. No event
retroactively simulates looting, interception of cargoes or damage to the traveler:
those consequences need your explicit contract on future systems.

| Type | Integrated effect |
| --- | --- |
| Siege | Value > 0 activates the subject/map phase; 0 completes it. Interrupts rest and acceleration, closes workshop session while retaining the task. The complete battle is not generated automatically. |
| Routine | CaelumScheduledWorker adopts WorkSpot or RestSpot according to the last phase; native movement, without passing through obstacles. Upon return to the map it does not reproduce the lost turns. |
| Rent | CaelumScheduleContracts.Rent records value in coppers, start and period. Each maturity adds debt. P pays all debt with real coins/change and capacity control, without automatic debit, eviction or forced lock. RentCurrent is available for a future access condition. |
| Shipping | DispatchCargo withdraws actual CaelumMaterialPickup units outside the Box and not linked to a Limbo quest. It retains type/level/quantity/origin/destination. CollectCargo requires time, correct map, capacity and valid inventory; a failure retains cargo, a success sets Claimed before allowing another withdrawal. It does not transport assembled equipment or add freight charges. |
| Resource | When extracting a natural node it records its complete recovery; another extraction recalculates that same input. Capacity and fraction are preserved in the hub actor. It counts the clock passed while its map is absent. |
| Mission | QuestDeadline links a defined active secondary mission. On expiry, it fails only if its objectives remain incomplete; it does not remove a reward pending targets already achieved. |
| Notice | Date and status available without transaction or additional consequence. |

The payment prepares all the change before modifying the previous coins. Collecting a
paid series does not discount again. The shipment cannot be cancelled leaving lost
merchandise; after withdrawing it retains the history, with zero balance. Inventory
transactions require a living player, free of rest, combat, conversation, trade,
manufacture and open budget. The cooperative game does not receive economic contracts
shared in this block.

Regeneration uses capacity × 0,001 per campaign day. An empty node takes 1000 days; one
to 90 % takes 100 days to complete. It is the existing rhythm, not a new value approved
by the author. The first tick of an old save initializes its time mark without granting
retroactive years. Its next extraction adds it to the agenda. One entry per node informs
map/material; there is no minimap or coordinate marker yet. The history of previous
cycles of the same node is replaced when extracting again to not create an input per
hit.

Tests (outside MAP01 at a clear location): - netevent ca_debug_events_trial: one-time
registration, with physical worker. Work +1 min and rest +6 min, repeated each 24 h.
Siege +4 to +10 min. Rent 1 copper to +8, +20 and +32 min (three maturities, no
automatic expense). - netevent ca_debug_cargo_trial: dispatches 100 units of level 1
wood that are carried outside the Box. From MAP06 goes to MAP07; from another outside,
to MAP06. Delays 30 min. Each order is a different shipment and consumes actual stocks.
- netevent ca_debug_events_report: 4.35.0o version and registration of each series.

The trials do not alter the four routines of the mansion or invent canonical contracts.
A copy of the game is recommended to test them. Programmatic cancellation prevents
future repetitions, keeping occurrences and debts already registered. Hidden events are
executed but do not appear in the calendar.

## Travel with duration and provisions (4.35.0n)

| Route | Connections | Distance in each direction |
| --- | --- | ---: |
| MAP03 reservoir ↔ MAP06 port | 8 / 9 | 10 km |
| MAP06 port ↔ MAP07 coast | 10 / 11 | 500 km |

CaelumJourneyRules calculates the native sustained displacement: normal forward input ×
effective multiplier × Speed × ORIG_FRICTION_FACTOR / (1 − ORIG_FRICTION). Includes
inventory speed; uses normal soil and standing body. Run, diagonals, combat posture and
initial acceleration are excluded. 32 MU = 1 m; km/h = MU/tic × 35 × 3,6 / 32. The
calendar's 20:1 scale does not multiply that physical conversion. Test with native
displacement at a steady walking pace.

The speed captured on departure is fixed for the forecast. Weight lost by eating and
reserve fluctuations do not solve the speed again during that same route. The current
state is used for the next trip. Travel hours = km / km/h; is rounded up to the tic of
the outer clock. Number of nights = (travel tics − 1) / (16 × tics per hour), whole
division. Each night adds 8 hours; the last arrival does not add free sleep. Example to
5 km/h: 10 km = 2 hours; 500 km = 100 + 48 = 148 hours.

Using a measured access opens CaelumJourneyPlan. The UI only reads saved data; Enter/A
sends ca_journey_confirm, Q/B ca_journey_cancel. The query does not change needs,
belongings or clock. While reading it follows the ordinary simulation, with
actions/movement blocked as in the other interfaces of the character. Confirm valid
context, map, proximity, profile, inventory and conditions; recalculates and requires
revision if time, expense, inventory or mortal risk changes. It is not charged when
cancelling, updating, re-clicking Enter or loading a save.

CaelumJourneyModel copies numerical values and goes through steps of a tic. The Needed
model uses unlimited rations to calculate what is necessary without container water;
Available uses actual stocks. It accounts for passive consumption by body mass and
Constitution (including Sleep since #131), ten pulses per serving, real digestion /4,
natural Health/Air/Anima recovery with its current #140 costs, critical reserve damage, Adrenaline
and Lucidity. Sleeping drains 10 Lucidity/s, without recovery from it, and recovers
Sleep in 8 hours; stunned by Lucidity does not interrupt camping. Compatible personal
timers advance by the same interval.

A portion begins when it fits its contribution without exceeding 100. During sleep no
other begins; a portion already begun ends its pulses. The ration contribution is
800/masa. Water rations first; then sips up to masa/500 liters of containers, with ten
pulses proportional to the actual volume. The empty container is preserved. Box and
supplies on tables outside the inventory do not participate. A sleeping bag outside the
Box applies comfort 3 during the night; floor applies 1. No beds or seated benefits are
added while travelling.

Apply deducts items/liters, retains incomplete portions as native Powerup, applies
reserves and final timers and adds the interval with CaelumWorldClock.AdvanceTics. The
calendar and weather consult that same date; does not change the seed.
CaelumJourneyState records km, km/h, actual travel/sleep tics and consumed supplies, in
addition to existing departure/arrival data. New fields start at zero in old records,
without inventing past expenses.

If provisions are missing, the expected arrival with its consequences is presented. If
death would occur first, it shows the lethal risk and estimated time; confirm consumes
only until death, uses native Die and leaves the trip interrupted in origin. There is no
arrival or credit of destination. Execution is an atomic transition; you can save the
budget or arrival, not a fictitious position in the middle of a journey. The plan is
revalidated after loading.

The planner supports up to 30 days of walking per route; it explicitly rejects longer
durations. It requires dry ground, a player, without combat, immobilization, work, rest,
conversation, elemental effects or active Powerup. It does not erase an effect by
traveling: it asks to wait for its end. The diagnostic Caravan uses walking speed; there
is no invented vehicle speed. Previous local routes remain without measure. There is no
AI replay, intermediate terrain or incidents. The scheduled narrative events remain open
to definition and explicit integration.

## Food by body mass and riverside expansion (4.35.0m)

Common Reference RATION_REFERENCE_MASS = 80 kg, body M base. Food portion of 0,10 kg:
800/masa Hunger points; water ration of 0,16 L/kg: 800/masa Thirst points. The clothing
size does not replace the actual body mass.

| Body mass | Hunger restored by food | Thirst restored by water | Sleep lost after a full portion |
| ---: | ---: | ---: | ---: |
| 50 kg | 16 points | 16 points | 4 points |
| 80 kg | 10 points | 10 points | 2,5 points |
| 100 kg | 8 points | 8 points | 2 points |
| 200 kg | 4 points | 4 points | 1 point |

The values represent sufficient deficit; Hunger/Thirst are limited to 100 and Sleep to
0. Digestion depends on the actual increase. Passive and regeneration spending continues
to be discounted during the meal, so net HUD can go up less. It does not depend on the
weight of inventory, clothing or having additional rations.

CaelumRegenerationPower serializes FoodRecoveryPerPulse when accepting native use. Each
pulse recovers 80/masa; the dose is fixed until the portion is explicitly finished or
refreshed. A missing/zero field in old effects retains one point per pulse. Loading does
not recalculate an old meal or consume another unit for migration. The partial
accumulator is retained sitting and the ten pulses in 10/30 simulation seconds.
Inventory, table and x105 share the same hunger/digestion behavior; the repetition
expects the current effect.

### Identities and routes

| Connection | Origin → destination | Access at source (MU) |
| ---: | --- | --- |
| 8 | MAP03 → MAP06 | (0, 3424, 0), north end of the reservoir |
| 9 | MAP06 → MAP03 | (0, 96, 0), southern port entrance |
| 10 | MAP06 → MAP07 | (0, 2080, 0), north end of the promenade |
| 11 | MAP07 → MAP06 | (0, 96, 0), south coast entrance |

Locations 6/7 expand the catalog without changing previous IDs or their 32 arrays
positions. The historical name IsSewerConnection includes this entire network.
SewerNetworkRevision=1 prepares new routes once in previous snapshots; PrepareWorld
checks door identity before adding another. The WAD geometry of MAP01–05 is not changed.
New maps belong to the 434 hub.

Travel retains its occupancy, state, inventory, route and single-player checks. The
pedestrian exits use Native Use. 43411/43414/43415 caravan conversations offer the
corresponding destinations with confirmation. No fictitious duration or transfer fee is
still assigned. Arrival and departure are recorded with the common clock; no route to
the mansion is created.

Both maps carry CaelumClimateRegion, arg0=1/arg1=0: Buenos Aires, surface. The catalog
also knows that habitat. Solid roofs of 24 MU and submersible water use native
Sector_Set3dFloor; water does not have user_ca_potable_water. The coast offers 16 MU
rungs to get out of the river. Water materials are static.

Small tables: 601 slot in (-800,800,0), port warehouse; 701 slot in (-256,1280,0),
coastal shelter. Each has two chairs and four belongings. Its safe areas allow T only
during valid rest; standing up stops x105. No free consumer objects or mission NPCs are
added. The caravan remains an optional diagnostic interface, not a new narrative
transport.

The Journal reduces the passage between rows of visits from 12 to 9 when there are more
than five, leaving the seven within y=220..274 and the last trip in y=286.

## Regional climate, shelter, water and chairs (4.35.0l)

Replaces the numeric test profiles of 0k. Author approves 0j/0k. The reported
temperature is air temperature; HR is relative humidity, not humidity of clothing or
thermal sensation. Wind in km/h, direction of origin (0=N/90=E), precipitation in mm/h
of equivalent water. No body damage or adjustment is added.

### Contemporary data and geographical reference

Source: [SMN, Normal Climate Statistics 1991–2020
(2023)](https://repositorio.smn.gob.ar/handle/20.500.12160/2506), 847 pp., CC BY 2.5
Argentina. Wind speed: 2011–2020 subseries of the same publication. The transcription of
numerical data, pages and units is in assets/climate/smn_1991_2020.json;
generate_climate_normals.py produces the included ZScript, without downloading anything
or depending on Python at runtime.

The twelve monthly values of average temperature, mean maximum, mean minimum, mean HR,
monthly precipitation, days with ≥0,1 mm, cloud cover in oktas and average wind speed
are incorporated. The values are modern climate reference, not daily 1889 data nor a
current forecast.

| ID | Reference station | Region represented | Mean temperature January / July | RH January / July |
| ---: | --- | --- | ---: | ---: |
| 1 | Buenos Aires Observatorio | Humid Pampas | 24.9 / 11.0 °C | 64.6 / 77.0% |
| 2 | Córdoba Aero | Central region | 23.5 / 9.8 °C | 68.1 / 63.5% |
| 3 | San Rafael Aero | Cuyo | 23.8 / 6.8 °C | 50.0 / 60.4% |
| 4 | Salta Aero | NOA, valleys | 21.5 / 10.1 °C | 77.2 / 69.3% |
| 5 | Posadas Aero | NEA | 27.2 / 16.3 °C | 68.1 / 73.9% |
| 6 | Trelew Aero | Patagonia, plateau | 21.6 / 5.9 °C | 42.1 / 66.3% |
| 7 | Bariloche Aero | Andean Patagonia | 15.4 / 2.1 °C | 51.9 / 78.0% |
| 8 | La Quiaca Observatorio | Puna | 13.2 / 4.5 °C | 62.6 / 25.7% |
| 9 | Río Gallegos Aero | Southern Patagonia | 13.6 / 1.5 °C | 51.9 / 77.7% |

The stations are local references; not a single average is applied to all of Argentina,
nor is it assumed that a station covers each height of its region. MAP02/MAP04 conserves
sewer habitat; MAP03, reservoir; MAP05, gallery. The location of the four and the
following maps is confirmed by the author in Buenos Aires (0m): use 1 region. MAP06–07
incorporate surface habitat. MAP01 retains 20 °C/55% and absence of wind/precipitation.

CaelumClimateRegion (DoomEdNum 30950) allows a marker per map: arg0 = Region ID 1..9;
arg1 = 0 for surface, 2 sewer, 3 reservoir, 4 gallery. Coverage is resolved in each
position. Limbo prevails over markers. An unknown map without marker, or with invalid
region, shows missing profile; it does not inherit values from the last location. No
published WAD is modified.

### Temporal synthesis

Normals are interpolated between centers of months using real lengths and leap years.
Campaign date/time, region and seed determine each sample. Daily thermal cycle
approaches sunrise by latitude/time of year and solar noon by longitude, using Argentine
civil clock UTC-3; maximum near solar noon+3 h. Minimum and monthly maximums scale the
cycle. It does not change map lighting.

Six-hour fronts interpolated with f²(3−2f) add thermal anomalies of ±6 °C and
humidity/cloud-cover variation. Wet days are chosen deterministically from rainy
days/month length. Each episode lasts 6..12 h, centered between 06..18 h, with a cosine
bell and volume linked to monthly mm/wet days; intensity varies by 0,5..1,5 of the
reference value. It starts/ends without a jump and reaches zero at midnight. It does not
reproduce a specific historical storm.

Cloud cover reduces thermal amplitude; active precipitation cools by up to 2,5 °C and
brings HR toward 95..100%. Initial vapor uses monthly HR and mean temperature, modulated
by the front. HR = 100·e/es(T), limited to 0..100, with es(T)=6,11·10^(7,5·T/(237,3+T))
hPa according to [NWS, Vapor
Pressure](https://www.weather.gov/media/epz/wxcalc/vaporPressure.pdf). Wind speed starts
from its monthly normal; vectors are interpolated to cross north without
discontinuities. Directions are synthetic, with a western component in Patagonian
references 6/7/9; they are not presented as an observed wind rose.

These factors are a playable model anchored to observations, not a validated weather
simulator or guarantee to reproduce exactly every monthly average. It does not model
accumulation of snow, hail, flood or particles yet. The weather phenomena represented
are fronts, cloudiness, wind and precipitation.

### Shelter and local microclimate

A vertical trace from the body ignores actors and skies (TRF_NOSKY), but respects roofs,
slopes, walls and floors 3D. No roof: exterior. In habitats 2..4, a roof implies an
underground location. On the surface four cardinal rays of 1024 MU (32 m) are consulted;
three or four blocked rays indicate an interior; otherwise, open shelter. It is a
geometric approach, not a ventilation simulation.

| Shelter | Air temperature | Wind | Direct precipitation |
| --- | --- | ---: | ---: |
| Outdoors | Full regional sample | 100% | Regional |
| Open shelter | Monthly average + 95% of the external deviation | 65% | 0 |
| Interior | Monthly average + 45% of the external deviation | 10% | 0 |
| Underground | Annual average + 15% monthly anomaly with delay of 30 days + 5% external anomaly | 0 | 0 |
| Limbo | 20 °C | 0 | 0 |

Open shelter/interior retains vapor pressure when changing temperature: HR can go up or
down; the roof does not magically remove vapor from the air. In the subsoil, the
exchange with wet surfaces approaches HR at least to 95%, with 65% mix for sewers, 85%
for reservoir and 25% for maintenance. They are ambient coefficients, not an
energy/material balance of the building. The wind does not subtract degrees from the air
temperature as if it were a thermal sensation.

### Status, saves and consultations

CaelumWeatherState retains Seed, region, habitat, coverage, SourceMap,
SampleDate/Minute, position and two reused samples: Outside and Current. The region is
resolved from catalog or marker; the marker is searched for at most once per native
second, or when changing map/revision. The outside is recalculated per minute of play.
Coverage is updated when moving and at least once per native second while stationary, to
respond to mobile geometry. Each change reapplies the microclimate from Outside, without
accumulating attenuations.

Revision 2 migrates 0k keeping seed, date, objects and progress. The same date/seed
produces the same exterior with normal clock, x105 or return from a journey; no offline
time is used. The 0k clock adapter is retained. Test dates do not alter campaign.
Invalid queries clear values, with Available=false.

    netevent ca_debug_weather_report
    netevent ca_debug_weather_sample PERFIL DIAS_RELATIVOS HORA
    netevent ca_debug_climate_sample REGION DIAS_RELATIVOS HORA

report displays local and external data. weather_sample maintains compatibility with profiles 1..5, with regional reference 1; climate_sample accepts 1..9 and displays
external and three coverages without moving the player or changing campaign. Hour:
0..23; date within years 1..9999. Journal > World reports region and coverage.

### Water by volume and chair repair

Water ration = 0,16 L = 0,16 kg, approximating density as 1 kg/L. Tier 5 base mass is
used: 80 kg, central body size 4 compatible with M clothing. Clothing size M covers
several masses: recovery remains proportional to the body, 800/masa Thirst points per
ration (80 kg → 10; 100 kg → 8). Ten pulses, each 80/masa; while seated they are
distributed over 100 s of simulation, and standing over 10 s. A save with an
already-started serving retains its previous dose. Containers retain actual liters and
tare; food retains 0,10 kg/dose. The shared rule supplies native weight, load, Box and
purchase checks.

102/104 Tables: (1072, ±480, 136), angle 0°. Chairs in X=988 and 1156, Y=±480, Z=136.
Beds continue (944, ±392, 136). The persistent mansion revision retries until occupied
sessions end; moves the same instances and recovers missing chairs. Verification
includes a line of sight unobstructed by walls, native entry into both seats, save/load
and preservation of content.

## Current Time, Consumption, Use and Area Rules (4.35.0j)

This section replaces the previous Limbo clock values, sitting consumption, station size
and Sleep radius. The sections by later version in the document retain the context of
each addition.

### Local time and sleep

SecondsPerGameHour returns 3600 in Limbo and 180 out. The clock retains its previous
unit of 6300 tics per hour; LimboSubTics saves the integer remainder 0..19 between
steps. Thus, 126000 personal steps are one hour of Limbo and 6300 are an outside hour.
Save, load or change map retains the remainder; does not change the campaign anchor of
03/11/1889 09:00 nor reconstruct previously frozen time. It counts only active
simulation, without synchronizing with the system clock or recovering time while the
game was closed. Escape retains native pause.

The cost of hourly needs, recovery while sleeping and daily regeneration of
environmental resources use the local time. Sleep recovers 100 points in 8 hours of
play, confirmed value: 8 real hours in Limbo or 24 real minutes out at normal speed.
Comfort does not multiply this recovery. The effects expressed per second retain their
simulation seconds: sleep drain 10 Lucidity/s without regeneration; the stunning does
not wake up. Costs, reuse of skills, consumables and manufacturing do not become hours.
Tx105 applies the same local scale by subpass and previous guards. MAP01 keeps furniture
without duration; timed ground/sleeping-bag sessions remain outside.

### Food and water while sitting

CaelumRegenerationPower retains its ten pulses and adds SeatedMealSubTics. Only
food/water, during a valid chair session, process an effect tic every three personal
steps (0q revision). It compensates EffectTics in the other two steps. The complete
portion lasts 30 seconds instead of 10. A ration of food recovers 10 points to 80 kg; a
ration of water or a sip retains its performance and volume according to body mass. It
does not increase gross performance or spend extra portions to compensate for slowness.

Standing up processes the remainder at ordinary speed, without restarting the effect.
Sitting back recovers the slow pace; pulses, fraction and duration are saved. Potions
and energy drink retain their duration. F/G continues to satiety, waiting for each
effect; reaching full satiety prevents another ration even if there is passive expense.
Eating continues to discount Sleep = Hunger effectively restored / 4.
Passive/regeneration rates are calculated separately with accepted comfort.

### Interaction and station size

USESPECIAL caused a station to stop Use even when it refused to open because it was out
of reach or on another floor. That indicator is removed and the result of Used is used;
rejection allows to follow the native search. Express routes Activate/Deactivate
maintain compatibility with your calls. CaelumUseGeometry intersects the beam of look
with the physical cylinder of the actor within UseRange. Beds, chairs, table blocks,
residents and stations consult it before opening. Native reach, visibility, walls and
collision are maintained; UseRange is not expanded or the player's body is changed.

DimensionsRevision=2 migrates stations to 0,75 scale, 30 radius and 72 height, also when
loading 0h/0i saves. These are 75% of the three 0i dimensions and 150% of the previous
0h dimensions. The saved USESPECIAL flag is cleared; absolute and idempotent allocation,
without losing networks, capacities, recipes or reserves.

### Approved base radii

Base before AbilityRangePercent; 32 MU development scale per metre.

| Effect | Base radius (MU) | Meters |
| --- | ---: | ---: |
| Channeling of Seals | 1280 | 40 |
| Class skills; currently Sleep and Battle Cry | 1280 | 40 |
| Impact of lightning seal | 256 | 8 |
| Zupay ground slam | 192 | 6 |
| Statuette explosion | 128 | 4 |

SEAL_CHANNEL_BASE_RADIUS maintains 128 × 10. CLASS_ABILITY_BASE_RADIUS reference that
same base; Sleep, Battle Cry and seals multiply by AbilityRangePercent/100. to 150%, both reach 1920
MU. The selection of Sleep by distance and vision is retained: it includes visible
allies, excludes the launcher and targets behind walls. Duration 10 s, wake up by
impact, reuse 60 s and confirmed base cost of 1000 Anima with its usual reduction. The
base is applied to new casts; it does not cast or extend already-saved effects.

Axe/two-handed sword/halberd sweeps use their weapon ranges of 76/80/84 MU; these are
not ability radii. The charged statuette retains radius ×√2, approximately 181,02 MU
base. Other effects do not change and V5 abilities are not implemented. The sleeping
bag's own weight, 2 kg, is confirmed.

## Access and personal advancement corrections in Limbo (4.35.0i)

SurfaceHeight uses 34,1 × Scale.Y / level.pixelstretch: the height of the actor
representing a ration matches the board mesh with CorrectPixelStretch. Each presentation
fixes its Z also after loading; does not change meshes, quantities, liters, digestion or
capabilities 4/18/60.

MoveLayout and Align move the same tables, collision blocks, chairs and figures. The bed
is moved together with the bedroom table. The set is validated and reversed if it does
not fit. An active occupation postpones the operation; the controller tries again. New
access markers migrate the 0h saves even if their previous preparations were marked as
finished.

The height of the bed allows native passage. The eastern tables receive an additional
margin of 16 MU towards the bottom to support the two chairs on the floor. The lateral
branch of three stations of Ronnie passes west of its workshop, without losing
instances, types, net or reserved works. The cave table moves 100 MU to the east,
perpendicular to the plane of its door and towards the false wall.

CaelumMainM00RuloTrial.EnsurePracticeTarget consults the actual existence of the target
in MAP01. It creates it if it is missing and fits; a failed preparation is retryed. The
found actor is retained, without duplication. IsActive/NearPractice continues to limit
the exercise record to the time and place of the test; it does not change its progress.

The rapid advance ceases to reject MAP01. Rest furniture and workshop networks of the
mansion are enabled contexts; combat, dangers and other exclusions continue to apply.
Pump uses AdvanceOnMap, so the clock remains held in Limbo. PersonalStepSerial advances
once by subpass; the durationless rest compares that serial and level.maptime to recover
Sleep/count steps exactly once. The serial is saved and is not restarted when
alternating T. Outside the clock continues to advance along with simulation.
ground/sleeping-bag sessions for duration are still available outside of Limbo; MAP01
uses furniture without duration.

T is processed only as ca_time_fast. The T branch that issued
ca_debug_advance_crafting_time is removed and Crafts help is updated. The debug command
continues to be explicitly accessible from the console.

## Automatic meals and furniture of Limbo (4.35.0h)

Food regeneration deducts Sleep = Hunger actually recovered / 4. Example: 4 recovered
points cost 1 of Sleep; from 99,5 to 100 costs 0,125. With Full Hunger there is no
digestive cost. Sleep is limited to zero and drinking does not apply this rule. The same
route attends inventory, table and fast advance substeps.

F/G toggles AutoEating/AutoDrinking in CaelumRestState and retains a reference to the
table. Each channel waits for the expiration of the native effect before ordering
another real portion. Reaching the maximum turns off the channel in the regenerative
pulse itself, before the passive expense: it cannot restart an already completed meal.
Without stock, when rising, losing reach or sleeping, the repetition ends. Deactivate
does not reverse the pulses of a consumed portion. The state is native and persistent;
no provisions are granted and inventory and table are not mixed.

Capacity is independent of SeatCount: small 4, normal 18, large 60. Items/Displays have
60 references; 0g saves with 24 positions load their existing belongings. A change of
presentation reconstructs old sprites like plates/cups. Each figure refers to the real
object; disappears when consumed or removed. An empty container continues to occupy its
space until removed. The CANPASS collision distinguishes the furniture from overlapping
plants.

On timeless maps, only furniture offers Untimed sessions with zero duration.
CaelumRestTrial uses USDF 43515/43516; LastUntimedTic limits rest to one personal step
per engine tic. The clock/calendar remains motionless. From 0i T accelerates personal
furniture simulation; ground/sleeping-bag rest for duration is kept out of MAP01.
Sleeping recovers Sleep at its usual rate and drains 10 Lucidity/s, even stunned.

CaelumCraftingStation sets 40 radius, 96 height and 1 scale against 20/48/0,5.
EnsureDimensions migrates once to absolute values, without duplicating when loading.
Actors are reused when moving stations; jobs maintain their references and reservations.
The open session is revalidated and paused if you lose reach. The network link moves
from 64 to 128 MU for the new separation of 112 MU; CraftingRoomGroup keeps the five
MAP01 networks independent.

## Fast advance, tables and sleep (4.35.0g)

T alternates an optional advance only during a Sleep/Wait session or a real
manufacturing task with its open and valid station. Standing still is insufficient, open
the menu without task or have a job booked in pause. Closing the station cuts
acceleration and retains the task/reservations according to existing rules. The state is
linked to the current session or station; another activity requires T again. When
completing it is returned to ordinary speed.

### Common time for substeps

CaelumTimeAdvanceState processes up to 104 tics additional after each ordinary tic:
x105, one campaign minute per engine tic and 8 hours in 13,7 s if it maintains 35
tics/s. Each subpass uses AdvanceOneTic of the clock, the shared functions of personal
resources/timers, the effect and expiration of consumables, UpdateCraftingTask and the
rest session. The limits of reservations, states, expirations and terminations are
resolved at the precision of a tic, without accrediting twice the ordinary tic. It does
not directly add a number of hours to the clock. The calendar derives from the same
clock. Between batches it returns control to the engine; T disables, Q/actions cancels
the rest and Escape retains the native pause.

Historical initial scope, superseded by #325 shared safety above: it required
an enabled zone, dry ground, rest and a player. It rejected
combat, projectiles, nearby hostile monsters (1024 MU), burn/poison/cut, water,
incompatible actions and Powerup without adapter. It also rejects a nearby actor with
induced Sleep, so as not to omit the remaining time of that effect. A chair or bag alone
does not convert another place into a safe zone. Initial zones cover arrival
points/furniture/workbench of MAP02–MAP05 and the MAP03 tables. Outside of them the
normal rest remains available. From 0i MAP01 allows personal advancement in
furniture/workshops; it keeps schedule stopped and furniture sessions without duration.

Historical 5.2.23/#219 exception, generalized by #325 shared safety: actual sleep with the owned sleeping bag
on dry, clear MAP02 ground permits T and Y outside marked safe zones. The bag
must remain carried outside the Box; ground waiting, chairs and crafting gain
no permission. Y may start from deployed bag sleep and retains its bag support
after the temporary mat is released. It stops before an awake substep at 100%
Sleep outside a safe zone, or if bag ownership/support is lost. Existing combat,
nearby hostile (1024 MU), hazard, movement, water and resource checks still apply.
This creates no new safe zone or access to remote furniture. Comfort remains 3;
durations and recovery rates are unchanged. MAP02 keeps normal exterior time;
only MAP01 uses the separate Limbo clock. No saved fields are added.

i_timescale is not used. The service accelerates the project systems integrated into it,
not AI, physics, doors, scripts or arbitrary Thinkers. Climate, routes and scheduled
events remain pending: their adapters must be integrated before allowing them to consume
these intervals. The general world state is not invented or claimed to be resolved
during a time jump. 0f comfort rates remain in place. Lucidity/consumables/cooldowns
seconds are simulation, not the minutes of the accelerated calendar 20:1; T advances
them only once with the rest.

### Tables and belongings

| Table | Table dimensions in MU | Chairs |
| --- | --- | --- |
| Small Round | Diameter 80 | 2, facing each other. |
| Rectangular normal | 192 × 96 | 2 per long side and 1 at each end: 6. |
| Large rectangular | 384 × 192 | 4 per long side and 2 at each end: 12. |

CaelumDiningWorld.Place builds and validates together model, collision and chairs. It is
the input to place new sets; invoke only the rectangular actor does not build its
composite collision. The table keeps references to chairs; HasSeatLayout offers the
future base for Trucazo without starting the minigame. MAP03 receives all three sets
also from previous saves. Creation is idempotent and retry if space is occupied. It does
not deliver food.

Use opens USDF 43514. Choosing to place/remove food or drink executes after closing the
dialogue and revalidating range. A personal unit is taken, outside the Box, by
operation. From 0h each table offers 4, 18 or 60 positions, depending on its size.
Objects are real Inventory owned by the table; the figures on the model only represent
them. Containers retain class, liters and weight. Withdrawal uses native pickup and
rolls back if the item does not fit; save/load retains references.

F/G activates repetition from an occupied chair in Wait or the owned deployed
sleeping bag in Sleep (#227). A table is optional: portable serving uses the same
carried/Box reserve fallback. It does not start while standing, in unsupported
rest, without valid furniture support or with full reserve. While there is an active
regeneration effect is expected before another portion. Native consumables are reused:
rations are spent and containers lose drinking water without disappearing. Improvement
occurs in their usual pulses; T also processes those pulses and their expiration. Since
0h there is explicit repetition per channel; never free replacement.

### Lucidity, Sleep Skill and Orientation

Sleeping drains exactly 10 of Lucidity per second simulation, minimum zero, and suspends
all natural recovery of Lucidity. Comfort and attributes do not reduce this drainage.
Stunning caused by low Lucidity does not end sleep; damage and other current
interruptions continue to apply. Upon awakening normal recovery returns, without
restoring Lucidity at a stroke. The usual visual illumination/distortion from low
Lucidity remains visible during rest.

Arcanist user4 (Mage + Priest) implements Sleep: 10 s in area, 60 s reuse since launch,
cost trial base 1000 Anima with existing modifier. It affects Caelum combat actors and
live players with vision, including allies, excluding the launcher. Provisional radius:
magic base area 128 MU by AbilityRangePercent/100. The actor remains motionless until
the effect expires or they receive a hit; uses the same 10/s drainage and does not
regenerate Lucidity. The duration does not depend on the stunning. The other skills of
class/racial are still pending. This radius is documented as trial value, not final
balance.

PoseAngle fixes 180° with respect to the chair/cot/bag model. In addition, TEXTURES
reassigns RSDO A/B 2↔8, 3↔7 and 4↔6: The lateral views of the atlas had the reverse
order to the native. Both corrections are necessary for front, back and sides. PNG and
C–G crouching boxes are not retouched. An old session corrects its orientation once and
retains accumulated duration and recovery.

## Sleep bag and rest factors (4.35.0f)

CaelumSleepingBag derives from CaelumSpecialInventoryItem. Use the added type
KEY_ITEM_SLEEPING_BAG=2; the above maintain its values. Amount/MaxAmount are 1,
InterHubAmount=1 and GetUnitWeight returns 2 kg provisional. The bag uses the existing
routes of weight, capacity, Box, snapshots, released and collected. It does not
duplicate the content in a parallel inventory. Its current category is displayed in the
key Keys/key items filter and in All.

Enter/A on personal bag closes Journal view and sends native inventory activation.
CaelumRestTrial retains Bag/UsesBag and opens conversation 43513. Enter on the stored
bag retains the existing operation of removing it from the Box. The duration response
first closes the conversation and revalidates ownership, status, mode and space. If the
object was removed or passed to the Box, it does not deploy.

HasRoom checks the native volume and eight ground samples around a conservative radius
of 46 MU; checks external solids separately. It does not modify the player’s body. Only
then is CaelumRestBag created, as a temporary nonblocking support, and Sleep begins. The
Inventory bag remains the player’s, with its same weight. Release destroys only the
support and leaves the player where it was. Validation checks ownership/access; loss of
furniture or the item, movement, damage, water, critical reserves or map change
interrupt according to the existing contract. The Tick cleans obsolete supports from
previous hubs.

ComfortFactor is a virtual query of each support. ResourceFactor requires a valid active
session, on the source map, with its occupant and correct references; without support or
out of session returns 1. Critical reserves and death also remove the factor
immediately. Attributes and derived statistics are not modified permanently.

| Support during session | Natural Health/Air | Hunger/Thirst loss over time | Sleep |
| --- | --- | --- | --- |
| Ground | ×1 | ÷1 | Recover only when sleeping, previous rate. |
| Chair (Wait) | ×2 | ÷2 | Continues to decrease; does not recover. |
| Sleeping bag (Sleep) | ×3 | ÷3 | Recovers at the previous rate. |
| Bed/cot (Sleep) | ×4 | ÷4 | Recovers at the previous rate. |

For F = support factor:

    pérdida pasiva nueva = pérdida pasiva anterior / F
    regeneración natural nueva = regeneración natural anterior × F
    coste por punto recuperado nuevo = coste anterior / (F × F)

The last expression applies to the expenses of Hunger/Thirst associated with Health and
Air. By recovering F times more for time and paying each point to 1/F², the expense for
that time remains in 1/F. Divide only the cost per point per F would have left the
regeneration expense for time equal to the previous one, contradicting the requested
reduction. Close to the maximum is paid exclusively the recovered. The available
reserves also limit the whole cure; the accumulators retain fractions and no resource
can exceed their maximum or be negative.

The penalty of fatigue, the lock of healing by Sleep/Hunger/ Thirst critical and the
preconditions of breathing are maintained. The comfort does not apply to Anima/Lucidity,
medicine or hydration by drinking water. The air debt after immersion recovers also at
×F rate: its meter is reduced F tics base by real tic, without exceeding the outstanding
debt or maximum Air. When interrupting it resumes ×1 with what remains; no extra air is
restarted or credited at the last pulse. Outside the rest it retains the three base
seconds. Sleeping keeps 100% of Sleep by 8 hours of play as provisional value, with the
same real duration as in 0e.

Preparation 3 in CaelumRestTrial and ca_debug_rest_bag are optional and only for
MAP02–MAP05. They deliver the object by native collection if it was not in the
inventory; if capacity failure, they destroy the attempt and report. They do not fill in
resources. The ca_debug_rest_report report remains query and displays 4.35.0i/factor.
The panel displays the current multiplier and divider.

## Furniture and rest camera (4.35.0e)

CaelumRestFurniture is a fixed, invulnerable, non-pushable Actor without monster,
projectile, corpse or mobile prop flags. The existing filter of the quintessence seal
excludes it. CaelumRestChair offers Wait; CaelumRestBed offers Sleep. Its native Used
requires the actual pulse of Use, scope and vision. The guide retains the reference to
the furniture; 43511/43512 conversations offer the four durations of 0d. The answer
closes before Begin; the guide validates the context again and never replaces a lost
furniture with a session on the ground.

Begin receives an optional piece of furniture. On the ground it maintains the previous
route. With furniture, it validates mode/range, saves position and entry direction and
lends the collision of the furniture to the player. SetOrigin places the player at its
center; TestMobjLocation checks its actual volume, dry ground and compatible level. If
it fails, it returns to the input and restores the collision. Neither height nor radius
changes, and no telefrag is used.

The posture uses a temporary graphic WorldOffset adjusted to RSDO. It retains the
previous value and is only restored if it is still the one applied by the session.
Occupant identifies the user. Validate interrupts in the event of disappearance,
movement of the furniture or loss of that occupation. Finish returns the player to their
entry position if it is free, or tests eight nearby exits using the actual volume and
line of sight. If none serves, it releases the session and keeps the furniture without
collision until the player can walk out. It does not reverse external displacements,
falls, deaths or trips. The furniture tick clean obsolete occupants and replenishes the
collision only when the volume is free.

CaelumRestCamera derives from SpectatorCamera and uses its native clipping with the
player’s position as a reference. Begin/Advance initializes a single view, also for
previous sessions without camera. It does not take a camera from another system. After
the native PlayerThink, UpdateViewInput applies the twist to the orbit and keeps the
body oriented. The vertical angle is limited between -5 and 60 degrees. When exiting it
normally returns the player’s camera and the previous facing direction; if another
system changed the camera, its view is respected. Neither chasecam nor the user’s
configuration is modified. Death/map change does not restore positions or views from a
previous scenario.

Inventory saves Furniture/UsesFurniture, EntryPosition/Angle/Pitch, HasEntryView,
OriginalWorldOffset/AppliedWorldOffset and camera status. The missing fields of previous
saves start from scratch: no furniture or occupation is invented. The native save/load
test during a session retains progress and references, completes only once and allows to
reuse the cot.

The world controller prepares a pair by MAP02–MAP05. TrialSlot 1/2 identifies chair/cot
and avoids duplicates. A new field initialized as pending in previous saves allows you
to incorporate them without restarting. If the place is occupied it is repeated once per
second. No things are added to MAP01, clocks, inventory weight, resources, recipes,
rewards or dialogue breaks.

0f applies the supporting factors described above to the 0d/0d1. Pending rates in V4.35:
Accelerate simulation consistently and integrate programmed climate and events/routes.

## Rest Compatibility (4.35.0d1)

FindState receives separate literal tags for RestLying and RestSeated, both when
entering the session and when updating its pose. This prevents the String conversion to
StateLabel that GZDoom 4.14.2 rejected in the conditional expression. Full
CaelumWorldCatalogue accompanies the hotfix: IsTimelessMap remains the only common Limbo
classification for clock, calendar, Journal, and rest. It does not change saves fields,
formulas, controls, or time scale. The native compilation passed in 0d1 and the author
approved its playable tests before 0e.

## Rest and wait: normal scale session (4.35.0d)

CaelumRestRules defines two modes (Wait/Sleep) and the states no session, active,
complete, cancelled and interrupted. Supported durations: 5, 60, 240 and 480 minutes of
play, equivalent to 525, 6300, 25200 and 50400 tics. Non-catalogue entries are rejected
before multiplying. The global clock does not receive jumps or a different scale: each
map system follows its normal simulation.

The provisional net recovery for Sleep is:

    Sueño por tic = 100 / (8 × TicsPerHour)

It applies only when sleeping and once per clock-pending pulse; it replaces the passive
loss of Sleep. The result is limited to 100. Waiting retains ordinary consumption.
Hunger/Thirst, healing, anima, lucidity, air and cooldowns maintain their base rules,
with 0f supporting factors for natural regeneration and Hunger/Thirst; no gifts at the
beginning or at the end. The numerical selection of 8 hours is a test value of 0d; it is
not presented as a historical decision of the author nor as a final balance.

While the character sleeps, ApplyCriticalSurvivalDamage excludes only damage by Critical
Sleep. Hunger and Thirst continue to count, and fatigue penalties are not removed and
healing is not enabled if normal conditions block it. By stopping sleeping ordinary
fatigue rules are resumed. Hunger or Thirst <=10% block/interrupt the session; items are
not consumed automatically.

CaelumRestState is Inventory hidden, unique, non-throwable, non-deleteable by
ClearInventory and with InterHubAmount=1. It retains Status, Mode, RequestedTics,
ElapsedTics, OriginMap/Position, LastHealth, ResultKey, InputArmed and
LastClockDays/DayTics. It does not participate in the weight or the Box. The absence of
this Inventory in a previous save is equivalent to no session; only Begin creates it.

Begin validates duration/mode and context, anchors the last pulse and puts the pose.
HandleInput validates before the native logic of movement; first expects to release the
confirmation input, then Q/B, movement or action cancel. PlayerThink blocks commands
while the session is active, following the existing path of activities. Do not modify
usedown or freeze flags. Use continues by the engine when cancelling; the Journal
preserves the actual release. UpdateCrouchVisual keeps RestLying for Sleep and
RestSeated to Wait. Finish restores the standing pose only if there was still a rest
pose, without replacing death or pain. The variant on floor does not move the character;
the occupancy and output of the furniture is detailed in the 0e block.

Validate checks context, position, damage and temporal continuity. Advance, at the end
of the player's Tick, consumes at most a new pulse. A callback repeated with the same
clock does not advance; an external jump greater than a tic or regression interrupt
without granting retroactive recovery. Crossing midnight is normal. The UI shows the
campaign calendar, although the World test view has another anchor. There are no session
mutations during prediction.

Blocks/interruptions: invalid character, multiplayer, Limbo, combat, conversations/shop,
fabrication even paused, equipment, seal, pending launch, charging/reloading/blocking,
immobilization, water, movement, lack of ground, critical reserves or pending journey.
Effective damage and death pass through the player's hooks; they do not depend on
obtaining pain state. A change of map or external displacement stops the rest.
CaelumTravelService refuses to travel with active session. Cancelling/interrupting
retains only what has already happened.

The voluntary pause stops clock and session. The native save retains both inventories
and player fields; when loading they are validated without rebooting. It does not add
loading time or operating-system time. In 0d the field copy was checked off the engine;
0e adds a native save/load test during rest.

World > D/X opens CaelumRestTrial, with invisible guide and conversation 43510 from the
USDF menu without any existing pause. Actions are queued, conversation closes and guide
validated again before Begin. Close or return does not start a session. The explicit
preparations put Hunger/Thirst to 100% and Sleep to 50% or 5%, without healing or granting items. Opening/loading/travelling never applies that preset.
ca_debug_rest_report is consulted; ca_debug_rest_hit, only during one session, requests
DamageMobj from 1 with type CaelumImpact to test the interruption.

Pending items of this V4.35 block: consistent temporal acceleration and integration with
the future climate state and events. Furniture and camera have their first deployable
implementation in 0e. The engine's CVar API restricts its setters to mod variables;
i_timescale is not modified by that API or altered the player's settings. Technical
Reference: [GZDoom CVar](https://zdoom-docs.github.io/staging/Api/Base/CVar.html).Camps,
properties, broader quality factors and automatic eating away from tables remain in V5,
along with skills not yet implemented. Thermal exposure is now implemented in
5.1.0/#130 above. The safe advance was
incorporated into 0g and the repeat on tables in 0h.

## Civil calendar, campaign and Limbo (4.35.0b–0c)

Canonical start: 03/11/1889 to 09:00, fixed by the author the 2026-09-15. The campaign
uses a unique CaelumWorldClock; the calendar projects its value only.
CaelumWorldCatalogue.IsTimelessMap identifies MAP01 as Limbo by its mansion location.
AdvanceOnMap does not add any tic there. All other location, including CADEV02 and
uncategorized maps, uses exactly the common rhythm. There is no reboot when changing
map, hub clocks or time recovery of the operating system. An unexpected input into MAP01
freezes the instant reached, does not reverse it to the start. There is no playable path
back to the Limbo.

The suspension affects the global chronology. The local simulation is still active:
movement, Use, dialogue, capture, waiting and manufacturing missions retain their rules.
Hunger, thirst, sleep, healing, air, damage and cooldowns continue to use accepted
personal timers. An engine pause is not activated. Dialogues continue without pause from
0b; only outside the Limbo advance the date. Voluntary pauses maintain native behavior
on all maps.

CaelumCalendarRules is a stateless resolver. Serial zero = 01/01/0001; serial maximum
3.652.058 = 31/12/9999. The years divisible by four are leap years except those
divisible by one hundred which are not by four hundred. Invalid dates are rejected
before creating/modifying the Inventory. CAMPAIGN_START_YEAR/MONTH/DAY/HOUR centralize
the initial date and time.

CaelumCalendarState preserves Configured, TrialDate, AnchorSerial, AnchorClockDays,
AnchorClockTics and AnchorCivilTics. Since 0c adds CampaignRevision and
TrialAnchorSerial/ClockDays/ClockTics/CivilTics. The main anchor always represents the
campaign; the four TrialAnchor fields are a diagnostic view. Both use the same clock,
without another ticker or duplicate time consumption. It is native Inventory hidden,
unique, non-thrownable, not deleteable by ClearInventory and traveler between hubs. It
is not part of equipment, weight, Box or inventory rows. Cleaning the return does not
remove this state.

    deltaDays = clock.CompletedDays - AnchorClockDays
    localTics = clock.DayTics - AnchorClockTics + AnchorCivilTics
    fecha     = AnchorSerial + deltaDays + acarreo de localTics
    hora      = localTics normalizados dentro del día

The DateSerial(clock), CivilDayTics(clock) and FormatDate(clock) queries return the
campaign. The optional argument trial=true explicitly requests the active test. This
query does not write status. Check limits before adding and does not wrap a date out of
the year 9999. A clock prior to anchoring is invalid. The initial date is also created
in MAP01, before deciding whether the tic should move forward. The individual confirmed
profile requirement is maintained.

CampaignRevision=0 identifies the previous or newly created state. EnsureCampaign
anchors 03/11/1889 09:00 to the current clock and marks 1 revision. Discards the
inherited test date, preserving the clock and character records. It is a migration
without reconstruction of the past: 0a/0b also counted the time of the Limbo and do not
allow to separate that interval. In 0c save/load restores clock and both anchors, and
travel retains the same Inventory. Reinitialize does not modify an already established
revision.

Optional test commands:

    netevent ca_debug_calendar_set AÑO MES DÍA
    netevent ca_debug_calendar_edge
    netevent ca_debug_calendar_report
    netevent ca_debug_calendar_clear

set assigns the date to the test anchor and takes the current campaign time. edge
changes only the test to 23:56, 12 s real simulated before midnight. Both stop at MAP01;
edge warns that the change is checked outside the Limbo. They do not advance clock,
needs, cooldowns, manufacture, missions or travel timestamps. report is read only and
displays the campaign even if World is showing the test. clear disables the diagnostic
view and lets see the campaign date reached, without restarting, removing or anchoring
it. Tests created and saved in 0c are preserved when loading; a new game does not
inherit them. Modify requires individual and unpredicted live character. Future events
should consult the campaign, no trial=true.

World shows southern date and monthly season: summer December–February; autumn
March–May; winter June–August; spring September–November. This convention remains a
test; November 1889 is shown as spring, without determining equinoxes, climate,
temperature, light or thermal exposure. Rest, temporary advancement and environmental
status were added in V4.35; character thermal exposure is implemented in
5.1.0/#130 above.

## Historical ability catalog and focused V5.4 revisions

This preserves the 2026-09-14 catalog and its 4.35.0g Sleep checkpoint. Current
V5.4 sections and issue-specific author revisions supersede historical rules.
Delivered class rows below reflect their focused V5.4 revisions, including #250; pending class replacements retain their
separate issue briefs until their focused delivery.

The decisions from the discussion on 2026-09-14 are recorded here. There are no new
playable User1/User4 effects in 0b or 0c. The roadmap assigns these abilities to V5
after the playtest export. User2 remains dedicated to Seals and User3 to Tarot.
Attributes, existing costs and accepted controls are unchanged.

Class abilities last 10 seconds, with 60 seconds of cooldown. Initial base cost for testing: 1000 Anima per activation; it is not a final balance. Reuse is the wait
until you can activate again, like seals. The application of cost modifiers and the
precise time when that wait begins will be integrated with your activation contract; no
additional formula is invented in this patch. The aura radii remain to be defined.

| Class | Ability | Agreed effect for 10 seconds |
| --- | --- | --- |
| Warrior | Battle Cry | Visible enemies in the release-time area cannot perform any attack, including magic. Movement/defense remain; see the 5.4.10 contract above. |
| Explorer | Survival Instinct | Multiplies current evasion, physical/magical critical chance and precision, and earned Adrenaline by 3; Empathy scales the entire factor and duration. See 5.4.11 above. |
| Priest | Miracle | Restores 3% of current maximum Lucidity, Health, Anima and Air per second to the caster and visible allies in a moving area. Empathy scales recovery/duration; see 5.4.12 above. |
| Mage | Arcane Sun | Large traveling fire orb: tenfold reference impact/burn/explosion, one homing shot per second and 25 straight spherical shots at scenery impact or expiry. Enemies only; see 5.4.13 above. |
| Mercenary | Formation Breaker (Rompeformaciones) | Forward ground double tap: upright running x4 for 1 s, collision cushioning/final Toughness reduction x10; Empathy scales full factors and durations. No impulse Air fee; normal running drain remains. |
| Cleric | Rally | Restores 10% current maximum Adrenaline per second to the caster and visible allies; their current bars multiply outgoing and divide incoming final damage. Empathy scales full factors/recovery/duration. See 5.4.17 above. |
| Battle Mage | Summoning | One allied Zupay at aimed/nearby valid ground. Empathy scales its base attributes and duration; follows across maps, disappears on death/expiry. See the 5.4.18 contract above. |
| Pilgrim | Redemption (Redención) | Moving visible area revives corpses immediately and each second. Former enemies serve until expiry; original allies remain. Living allies not raised by that cast gain x4 final fixed Toughness reduction, scaled by Empathy. See 5.4.19 above. |
| Investigator | Levitation | Allows flight for approximately 10 seconds. |
| Arcanist | Sleep | Targets remain motionless and wake when hit. |

Historical, superseded by #250: Protection replaced Bless Food. It did not grant healing, food, drink or reduction of
combat damage. Classification depends on the origin of the damage: an environmental
flame is reduced; a fire spell in combat retains its damage. The system of dangers must
retain that origin, including persistent effects; it is not enough to deduce
"environment" from a null attacker.

Races: toggles that consume Anima while active, with costs awaiting balance decisions. The
author's initial indication of a minute of cooldown and 10 seconds of duration is
retained; "toggle" does not authorize unlimited duration alone. It must be able to
switch off manually or by exhaustion, releasing interaction. The cost of 1000
corresponds to class skills, not to racial consumption per second.

| Race | Ability | Agreed effect while active |
| --- | --- | --- |
| Beast Man | Hunter’s Instinct | Triples stealth and critical chance from behind. Does not triple critical damage. |
| Human | Socialization | Doubles Dialogue skill and Persuasion. Anima consumption continues during unpaused conversation. |
| Duende | Telekinesis | Moves objects remotely, with Anima cost based on weight. |
| Caelith | Name pending | Consumes Anima instead of Air. |

Mage + Explorer = Investigator; Mage + Priest = Arcanist. Unapproved proposals on new
immunities, food cure or changes of attributes do not replace these definitions.
Cleaning of previous states of Survival Instinct, racial costs, radii and accumulation
between effects need to be concrete when implementing; they are not simulated with false
bonuses.

## Global clock and travel timestamps (4.35.0a)

Authority: CaelumWorldClock, Inventory native hidden, non-throwable, not deleteable by
ClearInventory and with InterHubAmount=1. It is not equipment, material or a second Box;
it does not participate in the weight or rows of the inventory. It retains two int:
CompletedDays and DayTics. It does not copy operating system time or Level.Time.

CaelumWorldClockTicker is StaticEventHandler and does not serialize a copy of the
counter. WorldTick only acts with one participant, Caelum character, confirmed profile,
closed and unpredicted creator. From 0c initializes the calendar and each native tic
adds one to the counter only outside the Limbo. The controller also exists when loading
old saves: create the Inventory if missing. A new game replaces the character and its
record; a hub transports the same Inventory. No persistent global CVar is used.

    TicsPerHour = REAL_SECONDS_PER_GAME_HOUR × TICRATE = 180 × 35 = 6300
    TicsPerDay  = TicsPerHour × GAME_HOURS_PER_DAY = 6300 × 24 = 151200
    Hora       = DayTics / TicsPerHour                       (entero)
    Minuto     = (DayTics % TicsPerHour) × 60 / TicsPerHour    (entero)

When the day is completed, CompletedDays is increased and DayTics is reset to zero. The
integer limit saturates to prevent overflow and time reversal. Three simulated real
seconds represent a minute of play; a full day represents 72 real minutes. These are the
constants already used for survival. No double consumptions or formula changes when the
clock is incorporated.

World consults directly the Inventory. Outside the Limbo shows recorded time; inside
indicates that it is stopped. The bottom line shows the campaign calendar of 0c or its
explicit diagnostic view. The zero of a previous save is the beginning of the new
record, not a statement about how long the previous game lasted. The pause is inherited
from WorldTick. From 0b the Caelum conversations continue to simulate, just like the
Journal. The voluntary engine pause stops the clock; the dialogues themselves no longer
stop it. Death does not impose an additional pause on the world if the engine continues
to simulate.

CaelumJourneyState adds HasDepartureTime, DepartureDays, DepartureDayTics,
HasArrivalTime, ArrivalDays and ArrivalDayTics. Begin records departure after validation
and before ChangeLevel; deletes the marks of the previous journey. Update records the
arrival only once at the expected destination, with compatible pending connection and
timestamped departure. An interruption is not presented as arrival. New fields in 0e
saves start without known timestamps; they are not refilled retroactively upon
consultation of an already resolved arrival.

FormatStamp is a common query. netevent ca_debug_time_report does not create or modify
the clock, and ca_debug_travel_report includes the available timestamps. A time jump per
console is not enabled in 0a: rest, journeys with duration, events and integration of
the affected systems are subsequently implemented on this same temporary authority.

## Activity testing support (4.34.0e)

CaelumSewerTrialSupport installs the native classes CaelumWorkbenchStation,
CaelumSawmillStation and CaelumForgeStation with 43414 network group. Each link measures
56 MU within the current limit of 64. It only acts on MAP02–MAP05. The new
SewerSupportPrepared field of the controller starts false in the 0d; FindStation avoids
recreating nodes that already exist. It does not modify WAD. Forging meets the existing
requirement for the Handle component; it does not alter the catalog to pass the test.
args[0]=0 retains immobility.

The two new actions share the USDF session checks: self-guide, interlocutor player,
current origin, unique action and no prediction. They are queued and executed after
closing the conversation. Prepare to re-check CanDepart and only then grant the help,
without creating JourneyState. The USDF pages and ids of 0d are preserved; responses are
added at the end of the offer, before the native "Cancel". Open, look or cancel does not
grant anything.

Seal: A T1 quintessence possessed instance is sought and the
ApplyFormalInventorySelection/EquipSelectedNativeEquipment. route is used If missing, a
native instance is created with ItemId. Only the explicit option adds adrenaline to the
maximum derivative and sets the cooldown to zero. It does not change
CombatTimeRemaining, attributes, weapons, consumption or the start/cancellation of the
channel. If there was another seal, it is saved without equipping. The channeling uses
the usual seal control of the equipped weapon; use or travel never reload this help.

Crafting: learns Recipe() from the catalog and complete the native wood stack up to
GetComponentInputUnits(BATCH_INDEX=1): 40 units. Keep its personal/Box location and
check your weight. It does not grant Box, finished products or artificial reservations.
FocusRecipe only acts on this network, with a known recipe and no task in progress: T1,
x10 batch, efficiency index 2 (100%). The player starts, pauses, resumes, cancels and
completes by the actual controls. Close Crafts leaves the task reserved pending; that
state blocks the journey. Time and production are calculated with the current functions.

When opening Crafts with Use, the Journal lets the KeyUp event pass to the engine from
the natively linked key to +use. Before it was consumed; the internal button was
retained and the next press after Q could not reopen the station. KeyDown, arrow keys,
Home/End, tabs and PgUp/PgDn. are retained.

## Test caravans and movement cycle (4.34.0d)

TAB > World > C opens a USDF offer in MAP02–MAP05. MAP02 offers MAP03, MAP04 and MAP05;
each module offers MAP02. The existing 2–7 ids are retained. The destination selection
and "Back to Destinations" only change the native page. "Cancel" closes the service
without recording a departure. "Confirm departure" delivers an ephemeral action that
only accepts the interlocutor, player, origin and session itself, with a single queue
connection. The invisible guide is removed when the session is over; it does not occupy
the map or modify narrative NPC.

CaelumCaravanGuide waits for the native closing of the conversation and then calls
CaelumTravelService.Begin. It revalidates the entire departure. CaelumSewerTravel.Begin
retains range/height/visibility/placed-actor checks and uses the same service with foot
mode. Only sewer paths, confirmed profile, live player outside the creator, no
prediction, incompatible session, active channel, active manufacturing, total freezing
or other player are allowed. The destination must exist and cannot be MAP01. One pending
departure prevents another. Failures prior to commit do not create history or charge.

The new CaelumJourneyState is Native Inventory, hidden and non-throwable. It does not
change the fields or capabilities of CaelumPersistentCharacterState. It is created by
starting the first new trip, never by reading World or opening the offer.

| Field | Meaning |
| --- | --- |
| Sequence | Departure number; increases once per Begin accepted. |
| ConnectionId | Points to the existing catalog. |
| TravelMode | 1: on foot; 2: test caravan. |
| Status | 0: no trip; 1: pending departure; 2: arrival; 3: interrupted. |
| Arrivals / Interruptions | Amounts resolved once; saturated in INT_MAX. |

Departure is recorded alongside WorldPendingConnection before ChangeLevel. Update runs
before WorldProgress consumes that brand. It only credits the destination that matches
the ID and pending departure; another location interrupts. A save loaded while still at
the origin interrupts and releases its own marker, without traveling by surprise or
erasing another system’s marker. A resolved departure is not counted again. The existing
load observer performs this reconciliation before reopening, if applicable, the native
conversation saved. 0c saves keep visits and connections; they are not credited with
previous trips without evidence.

The test does not apply tariff, additional consumption or temporary advance. The normal
consumption that already occurs during active play is preserved. It does not fill
resources, heal the player or copy inventory and does not execute the prizes or cleaning
of the prologue. The mode/status/sequence form the base of integration of the clock and
subsequent events; there is not yet a planner or transport simulation. World shows the
last trip on a line. Its history of places/routes and the controls of Inventory/Quests,
arrows and PgUp/PgDn are preserved.

## Sewer and test travel network (4.34.0c)

The current authorization allows new sewer maps for testing. MAP01 is the prologue
without reverse access. MAP02 maintains its WAD and PlayerStart. MAP03–05 are new maps
generated from UDMF modules, without ACS or Doom assets. Native cluster/hub 434 is used
for MAP02, MAP03, MAP04 and MAP05 only.

| Connection ID | Origin | Destination | Activation |
| --- | --- | --- | --- |
| 1 | MAP01 | MAP02 | Existing narrative return, with confirmation and cleanup. |
| 2 | MAP02 | MAP03 | Reservoir gate, Use. |
| 3 | MAP03 | MAP02 | Gate back, Use. |
| 4 | MAP02 | MAP04 | Tarot chamber gate, use. |
| 5 | MAP04 | MAP02 | Gate back, Use. |
| 6 | MAP02 | MAP05 | Maintenance gate, Use. |
| 7 | MAP05 | MAP02 | Gate back, Use. |

1/2 location ids are preserved; 3/4/5 identify new maps. LOCATION_CAPACITY and
CONNECTION_CAPACITY are still in 32 and WorldStateVersion in 1. New array positions are
born false in previous saves. origin/destination of the 1 connection and migration from
0 version remain unchanged. The pending arrival 1 needs proof of return; 2–7 connections
need to reach their respective destination. Another destination discards the attempt.

CaelumSewerTravel prepares reconstructable accesses from the existing controller; its
new preparation flag initializes to false when loading 0b. Before placing an access it
looks for an instance with the same id. It does not modify the MAP02 WAD or add a
missing handler to its save. The gates are fixed, not Shootable, without gravity, with
CANNOTPUSH/DONTTHRUST and its own wall sprite. Its destination is shown by looking at
them at a short distance with a line of view.

Begin requires live and confirmed character, valid map/origin, gate placed, Use range
plus its radius, vertical difference <=64 and direct view. Reject creator, prediction,
conversation, trade, menu/task of crafting, Journal, active channeling, freezing and
other players in session. MapExists is checked before modifying inventory or marking departure. A pending request prevents doubling the trip. Refuse does not cancel tasks or
lift freezes. Accept leaves the combat controls ready, saves the character and requests
ChangeLevel with NOINTERMISSION, without resetting health or inventory.
PreTravelled/Travelled native hooks remain in charge of the same authority; do not
create copies of equipment or cleanings of the Limbo.

Arrival uses PlayerStart 0: (-236,32,0) in MAP02 and (0,320,0) in MAP03–05, looking
north. Reverse gates are in (0,96,0), behind arrival. No contact trip is activated;
Sustained use does not reach the gate from the appearance position. Inactive map states
are serialized by the GZDoom Hub, also inside the session save. No actors are saved in a
second structure of their own nor are the collected objects rebuilt.

World shows five possible visits and up to three departures from the current location.
Discovering requires approaching 256 MU and having valid visibility/height; it does not
mark visited destination until entering. Outbound and return routes are independent. The
UI reads the Inventory; for the label of the gate reads the visibility that your Tick
calculated, avoiding gameplay queries from the UI. Arrows and PgUp/PgDn retain its
functions and do not execute trips.

The generator uses native sectors and collisions. MAP05 has two wide 256 MU stairs,
eight treads of 64 MU and 12 MU risers, up to +96 MU. Visual channels are reduced only
12 MU and do not declare damage, immersion or new water rules. MAP03 does not create
large numbers of actors automatically; MAP04 does not grant cards; MAP05 reserves hazard
tests for its block. Cooperative, costs, caravans or simulated travel duration are not
accredited.

## Grouped doors and accesses (4.34.0b)

CaelumSlidingDoorLeaf preserves ClosedPosition, SlideProgress, HoldTimer, DoorRequested,
LockedSoundCooldown, RuloArenaLocked and AccessCondition. It does not change its
serialized scheme. args[0] > 0 links leaves; zero or negative ids are considered
individual doors. args[1] retains a sense of displacement, args[2] the X/Y axis, and
args[3] the LOCKDEFS lock number.

RequestDoorGroup maintains sight checks and vertical overlap on the used leaf; it
rejects dead or predicting player requests. It accepts NPC requests on free doors, such
as the existing Palomo route. It runs through the group and checks arena lock, native
key and reputational status of all its leaves before activating any. A rejection leaves
requests and timers unchanged. The key does not satisfy membership/reputation nor arena
lock, and an unlocked leaf does not avoid the requirements of its companion.

CheckKeys(lock, false, true) query without issuing feedback. Upon rejection and with the
available timer, CheckKeys(lock, false) presents the native motif and sound; it does not
consume the key. 200/201 and 202 locks solve caelum/world/door_locked, the existing OGG.
Dual manual reproduction is removed and the seven tics timer is retained.

PlayerOccupiesDoorway uses ClosedPosition: half-width 32 MU and half-depth 4 MU of the
leaf/blockers, expanded by the player's real radius, with vertical overlap according to
its height. It measures the doorway even when the leaf has moved aside by 64 MU.
GroupDoorwayOccupied checks the leaves of the same group and HoldOccupiedGroup
holds/reopens the set with 18 tics waiting. It is consulted when the wait is exhausted
or during closing; without occupation it maintains 64 MU route, 4 MU steps by tic and
normal 105 tics wait.

The presence only reopens a door that already has SlideProgress > 0. It does not open a
locked door without a key. If the key is lost during the pass, it allows to leave; once
closed it again demands it. RuloArenaLocked maintains the previous forced closure and
the priority of the Bull test. Occupation protection is for players; do not redefine the
general physics of NPCs/objects.

### Access test

CaelumDoorAccessTrial is an optional Inventory without weight or visible row. It saves
references of two leaves and PresentationMap, using the native save. It does not add
fields to the persistent profile or change the locations/connections record.
CaelumDebugDoorTrial creates it 128 MU in front of the user, with native space checks in
the closed/open positions. If there is no place, it does not install half door. It uses
a free positive id above the existing ones; one leaf has zero lock and the other 202.
Repeating action does not recreate a valid presentation.

CaelumDebugDoorKey delivers CaelumDoorTrialKey only with the test enabled. It is an
independent native Key, reusable, without weight or row of equipment; it does not
replace CaelumSilverKey, it does not count for the mission or enable 200/201.
CaelumDebugDoorTrialOff removes the marker, its leaves and that key; the small blockers
remove its orphan reference in the next tick. It retains the silver key and the other
items/records. On another map, the presentation can be requested again; it is not
automatically reconstructed in the campaign. The narrative cleanup of the Limbo
continues to remove the physical Keys that correspond.

The test requires created/living character, out of prediction, no dialogue, trade,
station/task manufacturing or active channeling. It does not change those states to be
able to open. The three commands are detailed in PRUEBAS_4_34_0b.txt. netevent
ca_debug_door_report reads only the presentation of the applicant and its keys; it does
not evaluate opening actions, grants objects or repairs the save.

## World and persistent journey (4.34.0a)

CaelumWorldCatalogue assigns 1 location to MAP01, 2 to MAP02 and 0 to "unregistered".
The 1 connection goes from MAP01 to MAP02 and represents the existing return. There is
no reverse connection. ids are independent of translated names and visual order; CADEV02
and undefined names return 0, with no usable destination. Reserved capacity: 32
locations and 32 connections; booking slots does not create content or convert those
limits into the final campaign size.

CaelumPersistentCharacterState retains WorldStateVersion (1), the Booleans
WorldLocationVisited, WorldConnectionKnown and WorldConnectionTraversed, and
WorldPendingConnection (0 = none). Previous saves start those fields at zero. Authority
is the native traveller record, without duplicating it in CaelumPlayer, map actors,
CVars or interface.

CaelumWorldProgress.Update runs from the existing controller after updating the
prologue, before scheduling and departure. It only acts with confirmed character, alive,
outside the creator and prediction, and an existing ProfileCommitted record. It marks
the current valid location; it does not create a character record by opening a screen.
The exit’s IsReady reveals the connection, preserving the undiscovered destination until
you visit it.

The first update migrates WorldStateVersion 0. Only if the player is already in MAP02
and MAIN_M00 retains final state/stage, COMPLETE, INVENTORY_SANITIZED and
STARTER_WEAPON_PRESERVED does it reconstruct the mansion visit and return route. Those
facts are read and no commit is executed again. On a direct start of MAP02 without that
closure, only the current visit is recorded.

After satisfactory commit and just before the existing ChangeLevel the pending
connection is marked. The observer does not validate or initiate an alternative trip. If
you arrive at the destination with the closing evidence, the route is recorded and the
mark is consumed. Another arrival or invalid id discards the mark without granting a
tour. As long as it remains in origin, the mark does not count as arrival. Native
controls and checks of the door are maintained.

TAB > World reads FindInventory (native consultation clearscope), without setters or
status copy. Displays current location, known visits and return: status Known/Traversed,
destination by undiscovered/visited and indication of one way. It is not a travel
selector. Left/Right changes to Character/Crafting; PgUp/PgDn or LB/RB retains direct
tab change. Inventory and Missions retain their filters/selection and output to adjacent
tabs at the ends.

`netevent ca_debug_world_report` uses the player’s network request and only consult
existing fields. Repeat it does not discover places, advance a mission, grants a
card/reward nor changes health, reputation or merchandise. The names of maps are reused
from LANGUAGE; Spanish and English aids of World are added. Time, weather, map layouts
and travel services remain pending from its numbered V4 blocks. The inherited and
cross-system pending work are developed in V5 after export testing.

## Integration and consultation contract (4.33.0ao)

The static observer CaelumConversationResume receives the load of saves, including those
prior to 0ao. WorldLoaded marks only IsSaveGame and the first WorldTick consumes that
mark. For a living/created character, out of prediction, only the active native
interlocutor whose ConversationPC is that same player reopens. StartConversation retains
the available tree and uses ConversationFaceTalker with saveAngle=false. It does not
execute Used or replies. An inactive reference remains inactive; the normal map entry
does not reopen. The observer does not serialize references or progress and does not
replace native conversation closures. The need is reproduced with the MAP02 Voice
self-saved: the actor remains active when loading even if his menu has disappeared.

netevent ca_debug_integration_report uses NetworkProcess from the Journal and consults
the player at that event. CaelumIntegrationDiagnostics reads the persistent Inventory
with create=false and travels through only the two diagnostic missions defined. It does
not use setters, Sync, Ensure, Persist or reward actions; it does not create saves
fields. The resume observer described above is independent of this query. The service
classes continue to validate your requests by their existing authoritative routes.

The query shows separate states, objectives, delivery and possession of a receipt:
Losing a receipt after receiving it does not erase delivery. An active mission with full
objective still requires confirmation for complete/claim. Shows faction requirements and
its current result without closing sessions or recomposing a quote. A transitory result
of the diagnosis does not replace validation in the commercial or door operation.

The narrative exit retains its rules: explicit confirmation, own box, El Loco and
identified first weapon; manufacturing task must be resolved. The fade closes trade and
activities; cleaning removes temporary physical equipment/items, including coins and
products purchased in the test. CaelumQuestRouteReceipt, CaelumQuestWaitReceipt and
CaelumReputationTrialState are Inventory markers independent of those physical classes
and survive, along with the quest/faction. registry The first weapon remains in the Box.
membership/reputation is not derived from the equipment being removed.

Wait uses active game tics and its progress save, without delivering a receipt until
confirmed. The narrative arrival takes priority over opening the reputation test; then
its guide is rebuilt for the owner in MAP02. It does not change the travel failure
policy or create missions automatically.

## Reputation and service conditions (4.33.0an)

CaelumFactionCondition is a serializable Object with Configured, FactionId,
MinimumReputation and RequireMembership. Create retains even an invalid configuration
for it to fail closed; does not convert it to null. null means the service does not
declare requirement and maintains previous behavior. Valid ids are Unitarians=0,
Federals=1, Free Peoples=2, Caelith=3, Cult of the Tarot=4 and Sun Warriors=5.
A minimum outside -1000..1000 or an
unconfigured condition is invalid.

Check consults the persistent registration of the applicant player, alive and created,
outside the wizard and prediction. It does not create records or modify values. The
minimum is inclusive; RequireMembership also requires true membership. Requires the
localized motif. It does not derive a narrative rank or apply reputation of another
faction or local player to a foreign request.

OpenDialogue checks interlocutor, health, active conversation, distance from 160 MU,
line of view and condition before starting USDF. The caller can pass view flags; only
the invisible diagnostic guide uses SF_IGNOREVISIBILITY, preserving the geometric
occlusion. The condition protects the input: does not retroactively interrupt a dialog
already displayed.

CaelumSlidingDoorLeaf.AccessCondition is optional. RequestDoorGroup retains keys, arena
lock, height, view and movement above; before changing any leaf, check the conditions of
all leaves with the same args[0]. Using a leaf without condition does not prevent the
requirement of another in the group.

OpenPalomoMerchant receives optional access and discount requirements and a title key.
The above callers are without condition. The session checks access when opening, every
four tics and confirming, before moving goods/money. If you change the price shown,
update the quote and request another confirmation. The existing validation of distance,
stock, funds, capacity and quantity continues in the authoritative transaction.

PalomoMerchantReputationDiscount is a temporary view of the active condition; it is not
written in PalomoDiscountGranted. The persistent negotiated discount is retained. Either
activates once the existing margins: the player buys at 140% and sells at 60%, versus
normal 150% and 50%. No new economic curve is added and no currency is created. Closing the session clears its conditions and temporary view. The test shares the prototype's catalog, inventory and
commercial box; it does not implement separate inventories per merchant.

CaelumReputationTrialState is a hidden Inventory, without weight or reward, enabled only
by giving CaelumDebugReputationTrial. Activation does not change reputation. Journal >
Reputation > F/Y only opens it if it is already enabled. The USDF 43322 menu provides
information (43323), door, trade and five explicit states. Actions are supported only
from the active dialogue of your own guide; they are executed when you close it. Presets
Unitarians: 0/no, 25/no, 25/yes, -25/yes, 0/yes. The other factions are preserved
and the changes are saved by the existing APIs.

Information requires 25; door requires 25 and membership; trade requires 0 plus the
usual own Box; reduction requires 25. They are diagnostic conditions. They are not assigned to residents and do not create ranks, relationships or campaign benefits. The door
reuses a native leaf; it requires free space in front and in its sliding, with its own
group to avoid affecting map doors. It does not create a closed room. The guide
is invisible and exists only after the test is enabled.

The status and its references are saved natively. By changing the map it is kept enabled
and guide/door is recreated when needed again; the presentation is not duplicated when
re-opening. give CaelumDebugReputationTrialOff, with its closed menus, removes the
wizard and its actors, without restoring reputation values or used goods. Previous saves
do not activate this test, and their shops/doors without condition remain the same.

## Seals and interaction (0ak), conversation and navigation (0am)

HasActiveConversation checks that ConversationNPC exists and that that actor has
bInConversation. The reference can survive the closure and must not block by itself. The
essence uses this criterion in Used and in the wait before its animation. BeginCapture
retains the requirement of the correct interlocutor, its active dialogue, its own Box,
phase and revelation. Only CommitCapture with the finished animation records the unique
card and its current bonus.

The return door applies the same criteria when opening, waiting for closing and
confirming the transfer; the MAP02 Voice also expects a real active dialogue. No
conversation references are removed or serialized fields are altered to apply the
arrangement. An inactive referenced save can interact when loading, but loading never
captures or confirms departure.

Adrenaline exhaustion calls StopSealChannel(true); after that closure the cooldown only
prevents restarting the seal and does not block Use. The 0al log indicates another
condition: present conversation reference with inactive NPC. netevent
ca_debug_fool_report retains explicit query of requirements, Box,
menus/channel/conversation and proximity/visibility, without mutating the state.

The channeling selects fighters, corpses and projectiles, excluding Inventory and
CaelumMovableProp, except movable objects explicitly added to Earth and
Quintessence by #252. Trees, resource nodes and stations can be SHOOTABLE due to their
interactions, but they are not targets of the seal: they are not attracted, rotated,
ejected or added to captured mass. The formulas of force, radius, mass, elemental
effects, drain and cooldown are preserved for combat.

A new push of Use during the channeling ends it with StopSealChannel(true), with valid
target ejection and the normal cooldown. That same press continues until the engine
interaction. Keeping Use already pulsed does not generate another interruption. Catching
El Loco uses its existing native path: valid phase, own box, conversation and
confirmation. Interrupting the seal or loading a save never grants a card by itself.

MAP01 serializes ChannelInfrastructureRecovered. If missing in a save, after preparing
the current arrangement the position of the plants is restored only once from SpawnPoint
and from the stations by class/room group. The actors are reused, preserving remaining
resources, fractional yields, tasks and reservations. Undue speed and gravity are
cancelled and the active station is revalidated. Workbenches do not use their old
outdoor SpawnPoint. The garden is not regenerated or geometry modified. Releasing
GravityTargets from a save also clears the unintended suspension of fixed
infrastructure; the rest recovers its previous gravity mark.

| Journal context | Left/Right | Other control |
| --- | --- | --- |
| Inventory | Previous/next filter; at the ends, Tarot/Character tab | F/Y advances filter; Up/Down chooses object; PgUp/PgDn changes tab |
| Missions, List or Detail | Previous/next known quest; at the ends, Crafting/Reputation tab | Up/Down select from list or scroll Detail |
| Crafts with open station | Preserves recipe/contextual option | PgUp/PgDn or LB/RB comes out of the tab and closes the session |
| Rest of tabs | Previous/next tab | PgUp/PgDn or LB/RB does the same |

PgUp/PgDn (PgUp/PgDn) and LB/RB change from tab across all sections, including Missions.
Change mission, hide Detail or change tab cancels a pending abandonment confirmation.
Navigate does not accept missions. With a single registered mission, Left leaves to
Crafts and Right exits to Reputation. With several, undiscovered entries are skipped; it
does not return to the opposite end when the horizontal list is exhausted. Upon return
the selection is retained. Up/Down retains the circular path of the list and the Detail
scroll; F/Y retains the filter cycle of the inventory. The four resident tests are
MAIN_M00 stages, not four independent inputs. Navigate does not discover the optional
diagnostic missions.

## Optional missions — current in 4.33.0aj

Status per character in CaelumPersistentCharacterState, retaining its 32 slots and eight
objectives per mission. Indexes: MAIN_M00=0, test Tour=1, test Wait=2. The Journal only
expands its snapshot to three entries.

| State | Stable value | Transitions allowed |
| --- | ---: | --- |
| Unknown | 0 | Offered by explicitly discovering it |
| Active | 1 | Completed with completed objectives, failed by its controller or abandoned if allowed |
| Completed | 2 | None; outstanding delivery is managed separately |
| Failed | 3 | None |
| Offered | 4 | Activates by accepting and complying with the requirement |
| Abandoned | 5 | None |

The above 0–3 values remain unchanged. MAIN_M00 retains its own activation; legacy
setters are limited to that mission and do not allow for changing an end or its
objectives afterwards. New missions use CaelumSideQuestRules:
requirement/objectives/reward/abandonment metadata and life-cycle operations. An event
cannot progress a offered or completed mission, change the goal or exceed it. Completing
requires all its known and achieved objectives. The base demonstrates a complete mission
dependency; composite conditions, various prerequisites and economic/Tarot rewards are
not added to this block. The MAIN_M00 narrative controller is not migrated to another
architecture.

Each current reward is a unique native Inventory. QuestRewardClaimed[32] records the
delivery, regardless of whether it retains the object. A rejected receipt does not mark the reward as claimed and allows a retry; completion and claiming are separate operations. The
two test receipts are different classes, with MaxAmount/InterHubAmount 1, without
weight, price, attributes or consumption. It is reported to be delivered in the Journal;
they do not appear among the usable equipment. XP, cards, coins, recipes or campaign
materials are not awarded.

Test enabled only by giving CaelumDebugQuestTrial. Repeat only discovers offers that are
still unknown: do not restart orders or rewards. - Tour: Acceptance records
position/map. Moving at least 128 MU in XY, with a Z difference below 32 MU, completes
the objective. Change map before you achieve it, or die before, produces failure. Enter
completes the quest and claims the reward. - Wait: it requires completed Tour. OK starts
five seconds of tics of the game. An observed decrease in health or death before
achieving it produces failure. The counter and its progress persist through saving and
travel; no real clock is used nor global time is accelerated. With the goal ready, Enter
completes the quest and claims the reward. give CaelumDebugFailQuestTrial allows to
cause that end directly for diagnosis, without causing damage.

Both tests allow abandonment and cannot be restarted in the same playthrough. To compare
outcomes, load a save from before acceptance. Times/distances are diagnostic parameters,
not campaign balance. Health observation compares health between tics; it does not yet
represent a universal system of conditions based on all damage events.

Journal → Missions: Left/Right selects; Up/Down also in list. F/Y opens the selected
Detail; Enter/A accepts or completes/claims; G/X requests abandonment and another
separate click confirms it. Keeping the key does not confirm. Close, change
quest/section or hide Detail cancels the confirmation. In detail, Up/Down retains its
pagination. MAIN_M00 cannot be abandoned by these controls. The UI sends the selected
index by event and the authoritative handler validates state/requirement.

The new fields start empty in 0ai: loading does not enable the test or reset the
profile, attributes, previous quests, containers or choices. Persistence uses native
save and the same Traveler Inventory. Automated test modes remain out of delivery.

## Survival consumption and regeneration - current in 5.1.4 (#131/#133/#140)

Constitution controls passive Hunger, Thirst and Sleep consumption, as well as
Hunger and Thirst expense from player health, Air and Anima regeneration.
The #140 quarter-Health rule supersedes #133's water-free Air recovery.
The author reassigned Sleep
from Resilience in #131; the new Type-2 divisor (#154) and original mass rules remain.
Resilience now controls climate adaptation rate/range and retains its existing
combat benefits (maximum Air/Adrenaline and health regeneration).

    A = máximo(0, atributo efectivo)
    divisor D(A) = 1 + 3 * (A*A + 25*A) / 12500
    factor de Hambre/Sed = (masa corporal / 100 kg) / D(Constitución)
    factor de Sueño = 1 / D(Constitución)
    factor de coste de Hambre/Sed al regenerar = 1 / D(Constitución)

| Attribute | Divisor | Consumption with respect to 0 attribute, same mass |
| --- | ---: | ---: |
| 0 | 1 | 100% |
| 50 | 1.9 | 52.631579% |
| 100 | 4 | 25% |

New Type 2 is not linear. Fractional levels and growth above 100 are preserved without zero
consumption. The formula uses effective attributes, with its current bonuses; the weight
of the equipment is not body mass.

Base times to empty a full reserve, without other consumption: Hunger 24 hours of play,
Thirst 12, Sleep 16; one hour of play is 180 real seconds. At 100 kg and attribute 0,
these equal 72/36/48 real minutes. At attribute 100, they become 288/144/192 minutes.
Other masses only modify Hunger/Thirst.

Regeneration cost is calculated from the fraction of maximum health/Air/Anima actually
recovered. Constitution now also divides that cost; the body mass factor of passive
consumption is not applied again.

| Natural recovery | Base cost of Hunger | Thirst base cost | With Constitution 100 |
| --- | ---: | ---: | --- |
| Maximum health 1% | 1 point | 0,5 points | 0,3333 / 0,1667 points |
| Maximum Air 1% | 0.25 points | 0.125 points | 0.08333 / 0.04167 points |
| Maximum Anima 1% | 0.25 points | 0.125 points | 0.08333 / 0.04167 points |

Each cost is divided by D(Constitución), also when calculating how much can be recovered
with the available reserves. Only the recovered amount is charged, with non-negative
reserves. Full Air or Anima recovery therefore costs 25 Hunger / 12.5 Thirst before
modifiers, one quarter of complete Health recovery (100 / 50), regardless of each
bar's maximum. Existing rest divides cost per recovered unit by comfort squared;
its speed bonus remains, and panting adds the specified Air speed factor. These
food/water costs are player-only; NPC recovery gains the breathing factor without
new Hunger, feeding behavior or recovery water charges. Passive Hunger/Thirst
have no abstract cold/heat multiplier; sweat is charged by secreted water mass.
Resilience continues to
accelerate health recovery and increase the maximum Air. The return in three seconds of
the Underwater Air debt keeps its route separate, which no longer consumed
Hunger/Thirst.

This explains the previous observation: the cost of regenerating did not receive the
reduction of Constitution and could hide its effect on passive consumption. The drinking
pool maintains its recovery of Thirst from one point per second; the sips and their
volumes retain the approved rules of 0ag.

When a previous save is resumed, only both factors are recalculated before the next
consumption, without restarting reserves, attributes, missions or inventory. The stored
value is not re-divided: it is reconstructed from the attribute and mass, avoiding
accumulation and correcting old serialized zeros.

Hunger, Thirst and Sleep to 10% or less are critical: each adds health drain at the unmodified base regeneration rate and blocks natural regeneration. The rule prior
to 0ag is restored at the author's request. To regenerate health again, all three
reserves must be above the 10%. Performance penalties and regeneration costs remain in
place.

## Audit of the twelve attributes - 5.4.0 (#237)

The original audit checked accepted main `5208cc92` (5.3.9), starting release
5.4.0. Its completion refresh checks the accepted 5.4.21 ability baseline
`bde4cd96` on 2026-10-15. No gameplay logic, balance, save schema or controls change
in this audit. Current release markers remain 5.4.21; this is completion of #237,
not another gameplay patch. **Implemented** means a normal gameplay consumer;
**partial** distinguishes consumers from stored fields, diagnostic observers and
future systems. Class/racial consumers below were implemented and accepted in
their own issues, not by the audit.

### Source, ownership and order

The player's saved profile/allocation is authoritative. In
[CaelumPlayerCharacter.ApplyCharacterProfile](../src/caelum/player/CaelumPlayerCharacter.zs),
the sequence is creation layer plus individual allocation, intact armor bonuses,
equipped jewelry/Seal bonuses, additive Tarot minor bonuses, then the collection
percentage. Effective values remain doubles; Tarot never overwrites the saved
allocation or compounds on the previous effective value. Debug attribute presets
explicitly replace the creation/equipment subtotal before Tarot; they are not
ordinary character creation. Derived statistics and carried load are refreshed
twice so changed Intelligence immediately updates the Box content divisor.

[CaelumAttributes](../src/caelum/attributes/CaelumAttributes.zs) owns the twelve
effective values; [CaelumDerivedStats](../src/caelum/statistics/CaelumDerivedStats.zs)
derives player fields. NPCs instead own integer `Combat*` attributes and their
own saved `CombatPersonality` in
[CaelumCombatActor](../src/caelum/actors/CaelumCombatActor.zs). Their combat
consumers add applicable armor bonuses individually; they do not inherit the
player's allocation, jewelry or Tarot collection. Current armor grants Dexterity
from light/medium gloves and Agility from light footwear. NPC footwear enters
evasion, while its base movement curve uses authored `CombatAgility`; no general
player/NPC equipment-pipeline equivalence is claimed.

Personality does not rewrite attributes: #192 applies its three independent
magic factors, critical/evasion/Adrenaline alternatives and ideological defense
rules at their consumers. #194's exclusions for bow/crossbow/carbine/shotgun
remain accepted. The audit does not change these operation orders.

### Curves, units and boundaries

For effective level N, B=(N*N+25*N)/125, M2=1+3B/100 and M3=1+7B/100.
`CaelumGrowthRules` is the shared authority. Historical method names are adapters:
`CalculateType1Percent` returns 100*M3, `CalculateType4Percent` returns 100*M2,
and `CalculateType2Percent` returns B. They are not three new curves.

| Effective N | B (percentage points) | M2 | M3 | clamp(1-B/100,0,1) | Box slots |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 0 | 1 | 1 | 1 | 30 |
| 25.5 | 10.302 | 1.30906 | 1.72114 | 0.89698 | 37 |
| 100 | 100 | 4 | 8 | 0 | 100 |
| 150 | 210 | 7.3 | 15.7 | 0 | 177 |

Levels are not globally capped at 100. Probability and harmful-complement
consumers clamp individually. Player derived critical fields clamp the shared
5+B baseline before the weapon-specific base replaces 5; the final attack helper
then applies posture/personality and Survival Instinct and clamps again. Hunter
Instinct multiplies that current chance for rear impacts, with eligibility saved
at projectile release and rear position checked at impact. NPC critical statistics apply
personality before their final clamp. Preserve this real order; do not describe
every critical path as an uncapped B plus a weapon base. Toughness status response
is **not** the clamped harmful complement: 1-B/100 becomes negative above 100 and
the accepted status processor converts the remaining dose to healing.

### Twelve source-to-consumer rows

The source/order above applies to every player row. NPC qualifications are
explicit below. HP and resource quantities are native game units; mass is kg,
durations are simulation seconds unless stated otherwise, and percent fields use
100 for a multiplier of one. Spatial range is MU (32 MU per development metre).

| Attribute / family | Formula and normal gameplay consumers | NPC ownership and status / limitations |
| --- | --- | --- |
| Strength / Physical | M3 times natural body mass /100 supplies physical damage/push through weapon attacks and object thrust/launch. CarryCapacity = body kg * M2; carried mass and Box effective weight are counted once. | **Implemented.** NPC physical push/damage and load checks use its own CombatStrength and mass. There is no separate universal third 'physical power' effect. |
| Toughness / Physical | After shield/armor, CaelumToughnessRules subtracts R = natural body kg * M3; direct magic subtracts R/2. Burn/poison/disease use 1-B/100: immunity at 100, healing above. Pain/Lucidity retain the clamped complement. | **Implemented / partial source coverage.** Shared player/NPC reduction and status processor; disease has a processor but no new gameplay infection source. Thermal exposure remains separate. DamageResistanceMultiplier is retained save data, not the current direct-damage receiver. |
| Constitution / Physical | MaximumHealth = 1000*M3*(body kg/100). Passive Hunger/Thirst/Sleep and natural-health-recovery consumption divide by M2; passive Hunger/Thirst also retain body mass. PlayerResources owns the actual losses and recovery costs. | **Implemented.** NPC maximum HP uses CombatConstitution and mass. Do not infer player survival reserves on every NPC. Constitution does not shorten incoming status durations: #188 assigns the accepted status response to Toughness. |
| Dexterity / Technical | Attack speed M2 and duration /M2 through attack cycles; physical precision 100*M3 through actual accuracy/dispersion; critical B plus the real weapon base subject to the clamp order above. Ammunition reload /M2; crafting material work /M3. | **Implemented.** NPC attack/ranged reload, accuracy and critical consumers add applicable glove bonuses. Crafting is a specific player consumer, not a general accuracy-roll or skill-cooldown system. |
| Resilience / Technical | Maximum Air and Adrenaline = 1000*M2. Natural HP recovery = maxHP/3600*M2 per second. Acclimatization rate/limit use base plus B (#136): at 100, 2 degrees C/world day and +/-10 degrees C, reached in five days. | **Implemented.** NPC capacity and finite-health recovery use its CombatResilience. Sleep depletion belongs to Constitution, not Resilience. |
| Agility / Technical | Movement 100*M2 with existing mass/load/state/medium factors; base evasion B with mass/performance/personality factors; jump work uses M3 and biological mass, native takeoff velocity uses total moved mass. Stealth clamps B*posture*Hunter (3 while active, otherwise 1) to 0..100; movement noise uses its complement and calls native SoundAlert. | **Implemented movement/evasion/jump/noise; partial stealth.** NPC movement/evasion/jump use its combat fields. Visual concealment from EffectiveStealthPercent is consumed by the diagnostic observer, not a finished shared production visual-sensor system. |
| Charisma / Social | 100*M2 supplies the attacker's elemental payload duration/power through projectiles and utility-staff streams; player incoming payload processing and shared stream status application consume it. MAP01 Caella persuasion uses M2, with active/snapshotted Socialization x2 and the existing 0..100 cap. ClassAbilityRules.HarmfulPower=M2 supplies Sleep's final-damage multiplier/duration, Battle Cry duration, Arcane Sun lifespan/burn strength/duration and Arcane Cloud stun. | **Implemented listed class/dialogue consumers; partial generic payload coverage.** NPCs emit payloads using CombatCharisma; this is not the recipient's Charisma. Generic payload support is not universal. Sleep still requires exactly three damaging enemy hits. Channel power/duration do not universally scale with Charisma. |
| Empathy / Social | MAP01 Rulo emotion uses M2 and the existing 0..100 cap. ClassAbilityRules.BeneficialPower=M2 now drives actual Survival Instinct multipliers, Miracle recovery, Formation Breaker speed/collision defense, Rally recovery/final-damage factors, Summoning base attributes, Redemption Toughness, Cloud flight/rain, and their durations. | **Implemented listed support/curative consumers and emotion.** Full multipliers scale (base x3 with power x2 becomes x6). Player/NPC recipients use the actual pulse/damage/resource handlers. Summoned Zupay attributes are round(33*M2), not direct scaling of every final stat. NPC payload storage alone still does not establish an independent NPC support caster. The old illumination timer remains diagnostic, not playable lighting. |
| Eloquence / Social | Ordinary magical attack preparation and Anima cost divide by M2; AbilityRangePercent=100*M2 scales real ranges, class areas/placement, Cloud width/rain/lightning area and Telekinesis range, not muzzle velocity. Class total cost is 1000/M2, fixed on start and paid uniformly across three seconds. Racial recurring/action costs use the same reduction. Dialogue skill B serves Ronnie and Palomo, with Socialization x2 applied before the existing limits. | **Implemented with explicit timing distinction.** NPC magical cost, preparation and range use effective CombatEloquence. Ammunition reload uses Dexterity. Class preparation remains exactly 3 seconds and class/Seal reuse 60 seconds; continuous racials have no reuse. Eloquence does not shorten these fixed class timers. |
| Intelligence / Mental | Magical damage/push M3, then accepted personality factors at actual release/transfer consumers. Actual consumers now include Arcane Sun reference-staff damage, Cloud Air-seal damage, Telekinesis force (1000 N times power), and #252's separate accumulating Seal climate/earth/gravity ledger. The ledger never raises the character's attributes. Box capacity = 20+floor(10*M3); that same integer divides content kg before aggregate gram truncation. Owned empty Box tare is 0.001 kg (#229); an unowned Box adds zero. | **Implemented combat/Box; academic uses planned.** NPC magical consumers use effective CombatIntelligence and NPC personality. The player's Box service is not a generic NPC inventory rule. No separate third universal magic-power effect is implied. |
| Patience / Mental | Maximum Anima=1000*M3; regeneration=maxAnima/480*M2 per second. Interrupt resistance clamps B to 0..100. Clamped complement mitigates injury performance/pain and low/critical-Sleep aggravation of Lucidity loss/stun duration. | **Implemented / partial intended needs role.** NPC Anima and injury consumers use effective CombatPatience. General Hunger/Thirst/Sleep performance penalties use Adrenaline, not a universal Patience mitigation. Constitution owns passive Sleep drain. |
| Insight / Mental | Magical precision 100*M3 and critical B through the current magical attack/weapon-base and clamp paths. | **Implemented combat; senses planned.** NPC precision/critical use effective CombatInsight. No playable hidden-object, sound detection or dark attenuation is connected to this attribute; the perception observer is diagnostic evidence only. |

### Pending decisions and roadmap ownership

1. **Resolved V5.4 ability contract (#238-252):** fixed three-second class
   preparation/60-second reuse, Eloquence cost/range, Charisma harmful effects,
   Empathy benefits/duration, Intelligence direct damage. Full factors scale;
   fixed hit counts remain fixed. Author-confirmed targeting/stacking rules and
   concrete receiver evidence are owned by each completed ability issue. This
   item is resolved, not deferred merely because its fields also remain saved.
2. **V5.4/V5.5 consumer integration:** decide whether the existing player/NPC
   equipment and critical-clamp differences should be standardized in a later
   focused issue. #237 reports them without rebalancing accepted combat.
3. **V5.6 crafting/economy and later content:** Intelligence academic actions
   need actual authored tasks, success rules and rewards. Existing Dexterity
   material work and Intelligence Box rules are already implemented and remain.
4. **V5.8 recovery/survival:** any broader Patience mitigation of need penalties
   requires a separate authored rule. Do not restore the obsolete association
   of Sleep drain with Resilience or duration resistance with Constitution.
5. **V5.10 perception/stealth:** Insight senses, hidden detection and general
   visual concealment need the planned production sensor rules. Existing native
   movement noise is implemented; the diagnostic observer is not their delivery.

The earlier 0ai postponement and the 5.1.10 audit remain historical decisions;
#154, #188, #192, #183 and #229 supersede their corresponding provisional curve,
defense, personality and Box examples. This audit can close with the explicit
pending list; it does not mark those future systems complete.

### Evidence and continuation references

The completion audit reran the same 160 checks on 5.4.21 (`bde4cd96`), all passing;
`assets/validation_540/completion_evidence.json` records the exact runtime and
fixture. No new manual author-input test is needed for a documentation audit.
Actual ability consumers are supported by accepted per-issue evidence, not only
by this derived-stat fixture: validation_544 (Sleep), validation_547/548/549
(Telekinesis/Socialization/Hunter), validation_5410/5411/5412 (Battle Cry/Survival/
Miracle), validation_5413/5416/5417 (Sun/Formation/Rally), and validation_5418/5419/
5420/5421 (Summoning/Redemption/Cloud/Seal climate). Each record retains its own
tested source and limitations; the audit does not relabel them as new reruns.

Concrete support paths: CaelumMiracle.Pulse -> ApplyMiraclePulse; CaelumRally
Factor/ScaleDamage and resource pulse; CaelumRedemption.ToughnessFactor;
CaelumArcaneCloud rain resources/flight multiplier; CaelumSummonedZupay
PostBeginPlay -> InitializeUniformFolkloreProfile. Harmful consumers include
CaelumSleepRules, CaelumBattleCry and CaelumArcaneSun.Release. See those source
files and the current ability contracts above for exclusions and snapshot rules.

5.4.0 ran **160 isolated GZDoom 4.14.2 assertions**, covering the table boundaries,
all twelve derived rows, current Toughness responses, representative NPC consumers,
the real rebuild order with T3 light armor/T1 Seal/full Tarot, removal/idempotence
and a personality change. `assets/validation_540/RESULTS.md` records the exact
scope and package hashes. Derived-field assertions are not evidence of a missing
gameplay consumer. No new physical-input or author gameplay acceptance is claimed.

Inherited acceptance is reused only for its scope: #154 curves/physics
(`validation_5110`, not its superseded Box/Toughness assertions), #188 real
defense/status/persistence (`validation_528`), #192 personality/projectile
receivers (`validation_529`), #183 Box capacity (`validation_524`), #229 tare and
load (`validation_5227`), and #256 real critical display/consumers
(`validation_532`). These are not new campaign reruns.

Source continuation points: `CaelumPlayerCharacter.ApplyCharacterProfile`,
`CaelumDerivedStats.Recalculate`, `CaelumToughnessRules`,
`CaelumPlayerResources`, `CaelumPlayer.GetRangedEffectiveReloadSeconds`,
`GetCraftingDexterityPercent`, `PhysicalCriticalChanceFor`,
`MagicalCriticalChanceFor`, `ApplyIncomingElementalPayload`,
`UpdateMovementNoise`, `CaelumMainM00SocialDialogue.GetChance/GetLabia`,
`CaelumCraftingRules.GetMaterialWorkSeconds`, `CaelumElementalStream`,
`CaelumActorProjectile`, `CaelumCombatActor.RecalculateCombatStatistics`,
`UpdateActorOffensiveStatistics`, `UpdateCombatHealthEffects` and
`CaelumPhysicsDiagnostics` (diagnostic only).


## Water containers and accessories chosen — valid in 4.33.0ai

The author's correction preserves the direct hydration of the pool and allows to
complete partially filled containers. Six models: small 1 L, normal 2,5 L and large 5 L,
both bottle and canteen. They are preserved when emptied.

Each sip uses water to recover ten Thirst points in the ten native seconds (one point
per second). The amount is adjusted to body mass:

    litros para 100% = masa corporal en kg / 50
    litros por sorbo de 10 puntos = masa corporal en kg / 500
    agua usada = mínimo(litros por sorbo, litros restantes)
    recuperación en puntos = 100 * agua usada / (masa corporal / 50)
    por pulso (diez pulsos) = recuperación / 10

BaseMass is the body mass, determined by the character; it does not include equipment.
Examples: 50/100/200 kg use 0,1/0,2/0,4 L per sip. All recover ten points if there is
enough water left. The last smaller sip recovers only its part. The amount of uses per
filling depends on mass and capacity; 10/25/50 Full uses corresponds only to 50 kg. A
100 kg: small bottle = 5 sips, normal = 12 Complete sips and one of 5 points, large = 25
sips.

The reserve is capped at 100. Drinking is rejected when already full or from the Box.
Repeating a dose restarts the effect without stacking it; waiting for ten seconds allows
you to take full advantage of it. The previous water ration preserves its 100 ml and its
mass recovery; it does not change its weight or create extra water.

Each vessel is Inventory native with its own volume. Provisional tare: 0,10 kg, reusing
SPECIAL_ITEM_DEFAULT_WEIGHT (the author did not fix tare weights per model); contents to
1 kg/L. One copy of each model per character in this delivery; liquids are not merged or
duplicated. The inventory shows remaining liters. Weight, Box, drop/pick and save retain
that volume. The Limbo exit retains its item cleanup.

A new entry with WaterLevel >= 3 and user_ca_potable_water fills or tops up containers
outside the Box. Only missing volume adds weight: to top up a 2,5 L canteen containing
1,25 L, capacity for another 1,25 kg plus the 1 g margin is sufficient. If the whole
amount does not fit, current contents remain; free some load, leave and submerge again.
It does not continually refill while drinking underwater. Pool geometry and Air rules do
not change.

Immerse your head in the drinking pool again Thirst recovers directly to one point per
second, replacing passive loss while the dive lasts, even without a container. The
container allows to store water to carry; it is only filled in water marked as potable,
never by stepping on earth.

The critical state of the three reserves and their drainage of health are governed by
the previous section. Thirst's positive exception introduced in 0ag was withdrawn by the
author in 0ah. Drinking recovers the reserve, without giving immunity to damage or free
recovery of health.

Ronnie, after returning the sword, offers an empty normal canteen for its workshop talk.
Confirm delivery only one; insufficient carrying capacity allows a retry. Detail records
filled and actual use, without blocking other missions. The potabilization of
contaminated/salt water is not defined or implemented: the current scope is to collect
water already marked as potable.

Caella offers to choose and confirm a T1 seal (five elements) and a T1 amulet (ruby,
sapphire, emerald or topaz). Each choice is fixed per character; consult or return does
not assign an option. It teaches only the chosen recipe and its components, preserving
any previous knowledge. Recursive native manufacture, reservations, pause/cancellation,
personal output and existing equipment. Detail shows choices and independent preparation
0/1 for each piece.

100% raw materials in each layer, using existing recipes: - Seal: 360 g raw copper + 40
g raw tin + 600 g of the chosen gemstone. - Amulet: 200 g raw silver + 800 g of the
chosen gem. - If the gemstones match, the quota totals 1400 g. No other gemstones are
added. The chest provides raw silver and the chosen equipment leather, limited by the
amount already issued and available carrying capacity. Gems, copper and tin are still on
the veins. Silver reuses the chest’s previously inactive slot 0; its array does not
grow.

0ae Compatibility: No recipes, materials or pre-made Seals are deleted. The Seals
already manufactured keep their expense accounted for; unused quotas for unselected
items are removed. An earlier seal task already initiated maintains its personal output.
New flags/fields use empty initial values and do not restart missions or issued quotas.
A piece already owned when learning does not grant another set of materials for that
piece.

## T1 seals: instruction and supply — 4.33.0ae

After completing the Caella test, you can ask for "Do you teach me how to make Seals?",
directly or through its workshop section. Read/postpone does not teach. Accept shows the
five existing recipes (56–60 indexes) and native dependencies: seal bases, gems/crushed
gems and metal processing. Do not change 131 indexes, the recipe version or its costs.
T1 is the supplied coverage; no physical components or objects are granted when
learning.

| For the five T1 seals to the 100% in each layer | Quota added |
| --- | ---: |
| Raw copper | 1.800  units = 1,8 kg |
| Raw tin | 200  units = 0,2 kg |
| Raw ruby | 600  units = 0,6 kg |
| Raw sapphire | 600  units = 0,6 kg |
| Raw emerald | 600  units = 0,6 kg |
| Raw topaz | 600  units = 0,6 kg |
| Raw opal | 600  units = 0,6 kg |

Each T1 seal weighs 1 kg, of universal size. Its base occupies 40% and its elemental
component 60%; the above amounts arise from native expansion to 100%. Copper/tin
accumulates with the chosen weapon and ammunition. It does not modify leather. The veins
of the cave provide the material; the drawer continues to provide only leather.

The quota is enabled by accepting the teaching and choosing the weapon with Ronnie, in
any order. It retains the 0ad issued counter: accept again, manufacture, change the vein
or save/load do not restart it. If a T1 seal is already in place, one piece per item is
recorded and only the new expansion is deducted; its cost is not charged again to the
previous counter. The CA_LimboMagicSeal borrowed seal is excluded. That initial list is
fixed after learning. The prepared Seals count from 0/5 to 5/5; they do not impose a
mission requirement.

The Seals use the recursive plan, the reserves and the native transaction, as well as
weapons/armor. They can be manufactured from raw materials in the Caella Workbench or
the second floor. Before having Box, the T1 result learned goes to personal inventory.
Equipping changes the unique Seal slot and retains the effects, Adrenaline, blocking and
cooldown current Channel. The narrative exit continues to remove temporary equipment
other than the first weapon.

If the Ronnie sword has already been returned, your workshop section offers "I need to
collect for Seals." It provides the same kind of tool while a useful quota is left for
an unprepared seal; it checks load and does not require a pending repair. It is returned
from the same page. The repair branch retains its conditions and its independent
proportional quota. An active prior task retains recipe, efficiency, time and reserves
even if another seal is learned or selected. It does not cancel or change its result.

## Choice of MAP01 armor and quotas (4.33.0ad)

Ronnie offers magic, light, medium or heavy after the weapon. Read/back does not choose;
confirm fix one family per character. The four existing recipes (head, torso, hands,
feet) and components are taught. The catalog and version of the book do not change. In a
selected weapon save is accessed from your workshop dialogue. Detail shows choice and
0/4–4/4, without new lock.

Armours now share the recursive weapons solver: they can be made from leather without
making straps separately. The chosen T1 parts are delivered to the personal inventory
without a mandatory Box; they are equipped by Inventory. They are temporary equipment of
Limbo. The exit preserves only the Box/first weapon; choosing armor does not replace ItemId of
weapon or complete its target.

Quota = raw materials of a chosen weapon + four pieces of the chosen family + a batch of
ten arrows/bolts if the weapon uses that ammunition. The 100% is calculated in ALL
layers, at the chosen size, using the existing recipe functions. The parameter that
concealed the Efficiency field in the supply solver is corrected. New choices prepare
100% and clean options from previous layers only if there is no active task. The costs
and times 25/50/100% general do not change; lower efficiency can exhaust the quota
before.

| Already-tanned leather, size M | Set | With chosen giant gauntlets |
| --- | ---: | ---: |
| Magic | 5 kg | 11 kg |
| Light | 10 kg | 16 kg |
| Medium | 20 kg | 26 kg |
| Heavy | 40 kg | 46 kg |

The leather includes the necessary straps. Other sizes use the current multiplier and
native roundings. Each unit of material continues to weigh one gram. Armor uses the
leather of the current catalog, also heavy ones; this patch does not change composition,
defense, attributes or mass of any recipe/armor.

MainM00SupplyLimit/MainM00SupplyIssued reside in the traveling Inventory. Quota is
reserved when generating a pickup or withdrawing from the drawer. Another source,
consumption, loading the save again or regeneration of the node does not replace it.
Resources outside the chosen quota are not extracted. The mass/hardness/physical
capacity of trees, bushes and veins remain; the amount delivered before discounting the
node is limited.

The drawer and the Toro share the leather quota. The Toro produces its maximum physical
performance of 12,5 kg in 900 kg mass, limited to the unissued quota. If it is already
removed from the drawer, it does not add leather. If it first generates 12,5 kg for a
heavy set M, the drawer offers 27,5 kg remaining. It is not two reserves. Return leather
without spending removes those units from the player and releases its quota.

New pickups identify the player and the quota already reserved. They are not counted
again when picking up. Old stacks request quota on pickup and do not admit excess. If
the load capacity is missing, a portion is collected and the usable remainder stays on
the ground. A gram of margin is left to not reach the immobility to the 100% load; the
general rules of speed are not altered.

0ac migration: preserve recipes, attributes, tasks, equipment and progress. Count
existing raw materials/components to the 100%, first weapon already manufactured and
initial ammunition present against the quota. Do not erase inventory when loading.
"Leave leftover materials here" in the drawer removes only excess raw materials without
reservation; retains the useful quota. Do not recover what has already been spent.

The accepted optional repair retains access: when you consult Ronnie with the first
damaged weapon, only the cost proportional to the 100% of the damage observed is
enabled. Repeating the query uses the maximum already enabled, does not add it again. It
does not restore durability, does not give materials and does not replace equipment. If
the chosen weapon does not serve to extract those resources, the repair conversation
allows you to ask again the sword and return it to Ronnie. Damage, practice pending and
load space is verified; the same loan is reused. 0ae expands this quota with the learned
Seals, according to the previous section. Bullets and supply T2 remain outside the
initial quota.

## Bolts and ammunition knowledge (4.33.0ac)

CRAFTING_BOLT_RECIPE = 130 is attached; the catalogue has 131 recipes. Arrows retain
index 129; 0..128 maintains its meaning. KnownCraftingRecipe grows in the end to 131
bools. The version of the book is kept in 4 so as not to trigger a migration that erases
old components; the new bool is born false.

Choosing the crossbow with Ronnie teaches the required bolts, shafts, tips and
processing steps. Bow and long bow retain arrows; the other choices do not receive this
recipe. TeachStarterAmmunition also incorporates the knowledge pending to previous
saves, inside or outside MAP01. Repeating does not duplicate anything. Not all recipes
in the catalog are taught nor equipment or ammunition are awarded.

Each batch produces ten CaelumBoltAmmo, 50 g each, fixed tier 1 and fixed size M of the
catalog. Bolts adopt the same T1 structure as arrows: 350 units of shaft and 150 of
bronze tip, incorporating 0,5 kg. The native mass of bolts is unchanged. Assembly inputs
with ready-made components:

| Efficiency | Shaft | Bronze tip | Output |
| --- | ---: | ---: | ---: |
| 25% | 1400  units | 600  units | 10 bolts |
| 50% | 700  units | 300  units | 10 bolts |
| 100% | 350  units | 150  units | 10 bolts |

One unit = 0,001 kg. Each previous transformation applies its own efficiency and time;
the table is not the total raw material in multilayer manufacturing. The shaft comes
from wood; T1 tip, bronze from copper/tin. The Workbench, Sawmill, Ranged Workshop and
Forge from the Ronnie network or second floor cover the process. The Crafts Tree shows
each layer and its efficiency.

Direct plan, reservations, unique task and native time are reused. Closing or moving
away pauses; only cancel free without consuming. Completion consumes the reservations
once and adds the batch to the correct stack. It does not require Box, does not occupy a
slot of it and respects loading capacity and maximum stack size. B,tier and size do not
multiply the lot. Ammunition does not register or replace ItemId from the first weapon.
The arrow recipe uses the same executor and keeps its stack. Bolts are loaded/spent by
the native crossbow, without parallel combat.

Detail guides the one who chose crossbow; does not add a mandatory target. The
ammunition guide is in the Ronnie workshop dialogue, without expanding its seven main
options. The narrative exit retains the rule of removing physical objects except
Box/first weapon; knowing recipes is preserved.

Carbine bullets: current mass 0,003 kg; composition, raw materials and process to
manufacture yet undefined. No inferred recipe for that mass is introduced.

## Breathing: optional Ronnie practice (4.33.0ab)

After returning the sword, “How can I breathe when swimming?” proposes the practice.
Confirm with Ronnie brand MainM00SwimLessonStarted; accept again preserves the phases.
The dialogue indicates swimming pool behind the mansion to the east and wide steps on
the side of the mansion. Prepare Air, cover the head one second next to them and go back
up. It does not require crossing the entire pool or exhaust Air.

UpdateUnderwaterAirForState reports only the amount actually spent. The observer
requires MAP01, live game without prediction/dialogue, acceptance, WaterLevel >=3,
potable pool sector, no underwater exemption and UnderwaterNoBreathTics >=TICRATE (35).
Sets Submerged. No counter added: a dive less than a second does not accumulate separate
dive time. The first interval retains base cost 5 Air/s for the current multiplier;
subsequent increase and drowning damage do not change.

RecoverUnderwaterAirDebt reports positive recovery after updating its debt and tics.
With out-of-water head, Submerged and zero end debt mark Complete. Use existing
three-second return; re-enter pause and resume according to native rule. Do not add
regeneration or spend Hunger/Thirst for this return. Filling Air by another way does not
trigger breathing observation. Underwater Air recovery also does not prove the separate
practice of running.

Three bools in CaelumPersistentCharacterState retain Started/Submerged/Complete;
underwater counters and debt were already saved. In previous games the new bools start
false. Snapshots feed Detail and dialogue. No modifications are made to recipes, rewards
or mission blocks. When you leave you keep the completed and hide the pending practice,
just like the other practices. The lesson does not implement water collection or
potabilization.

## Load: optional Ronnie practice (4.33.0z)

After returning the sword, "How do I organize my load?" shows the current snapshots of
CarriedWeight, CarryCapacity and the CalculateLoadAirMultiplier multiplier. Read does
not start; accept Started brand without giving objects or changing weight. Body mass
participates separately in the final cost of Air; the dialog value represents only the
load factor.

The current rule is preserved: for ratio r <= 0,75, factor = 1 + r; above that, factor =
1,75 + 2 * (r - 0,75). HasOverload activates at r >= 0,75. The entire cost does not
double at the threshold: the slope of the excess increases. Pickup capacity and the
desirability of carrying a load are distinct.

ToggleSelectedMagicBox retains its logic in ToggleSelectedMagicBoxNative and observes
before/after CarriedItemWeight mass. DropSelectedEquipment observes its native drop
call. Only a confirmed action STORED_IN_MAGIC_BOX or DROPPED with a reduction higher
than 0,000001 kg can be credited. The first weapon’s ItemId is excluded.
CarriedItemWeight does not include DebugWeight: attribute changes, removal of debug
load, consumptions or manufacture are not these actions. Retrieving from the Box or
storing without reducing weight does not count either.

MainM00LoadLessonStarted and Complete are serialized with the Persistent Inventory;
their initial values in previous games are false. Dialogue and Detail use snapshots. It
does not add costs, rewards or requirements to Rulo/exit. The surplus can be collected
again: the lesson records the decision made. After exiting, the pending optional
practice is hidden and the completed one is preserved. It does not add testable
materials: reuses excesses typical of the route. Without excess, it is allowed to
continue without doing the practice.

## Air and motion: optional practice (4.33.0y)

After returning the loan, Ronnie offers "How do I manage my Air?" Read does not start.
Confirmation fixes MainM00AirLessonTarget = MaximumAir * 0.01, once. Do not refill or
reduce Air, needs or health. The target is retained even if it changes the maximum; it
is not an additional cost.

ConsumeRunningAir reports the actual difference between Air before and after
consumption. It only credits with active practice, without dialogue, running on ground
and with horizontal speed not null. MainM00AirLessonSpent accumulates and is limited to
the target. Reaching it sets Ran. Short runs count; does not ask for exhaustion.
ApplyAirRegeneration then informs the Air effectively recovered, retains its native
requirements and costs of Hunger/Thirst, and accumulates Recovered. Reaching the target
sets Complete. Recover before finishing the first step does not count. An energy drink,
attack, jump or debug adjustment does not invoke those observers. Regeneration may
require replenishing reserves if they are empty.

Three flags Started/Ran/Complete and three doubles Target/Spent/Recovered live in the
serialized Inventory record. The new fields are zero in previous saves. Dialogue and
Detail use snapshots; when crossing retains the completed and hides the pending optional
practice. There is no reward or new mission requirement. The same native logic of BT_RUN
respects Always Run and the speed key. Mobility is not modified or immobility, rest or
calendar is incorporated.

## Needs: optional Ronnie practice (4.33.0x)

After the Ronnie loan is offered "How do I feed and drink?". Read the proposal does not
start the practice. Confirm it once applies Min(current, 90) to Hunger and Thirst: it
does not reduce already low reserves or cure previous states. One CaelumFoodRation and
one CaelumWaterRation are delivered through the native inventory.
MainM00NeedsFoodGiven/WaterGiven register each successful delivery separately; one
failed delivery per load can be retrieved, without duplicating the other. The rations
weigh 0,10 kg each. They keep stacking/Box rules.

Use from Inventory consumes one unit and activates ten pulses of one point, one per
second. Observer only marks food/water if Use was accepted, practice began and the
corresponding reserve was below 100. Collecting, speaking, refusing use from Box or
consuming 100 does not credit. Accreditation records consumption; recovery remains
gradual. A second unit restarts effect, never adds intensities or durations.
bAlwaysPickup is enabled only during Super.Use to allow that native refresh before
expiry; the flag is restored to avoid alter collection.

MainM00NeedsLessonStarted, FoodUsed, WaterUsed and the two delivery flags travel in the
persistent record; previous saves initialize them to false. Detail reflects the two
consumptions. The complete practice is preserved on exit; a pending optional practice
is hidden outside the Limbo. There is no mission requirement, extra recipe or reward to
return. The remaining rations are removed with the other physical objects on the
approved exit: they are not exported to MAP02.

This delivery teaches consumption. It does not implement collection or potabilization:
the pool is not a water dispenser. It does not alter the rhythms of needs, regeneration,
rest or calendar. It does not expand maps.

## Optional maintenance with Ronnie (4.33.0w)

After returning the loan, "How do I keep my weapon?" records that the lesson was
offered. The steps are in that dialogue and in Quests > Detail (F). Select the first
weapon in Inventory and unequip it; use the Workbench on the second floor and press F in
Crafts. Keep selected piece.

BeginRepairSelectedEquipment/CompleteRepairTask is reused. The observer only credits a
finished native repair that increased the durability of the initial ItemId, owned by the
player, after receiving the lesson and closing Ronnie’s conversation. Speak, repair
another object, use a debug restore or cancel does not credit this practice. The save
stores MainM00RepairLessonOffered and MainM00RepairLessonComplete; two snapshots feed
dialog and Journal.

It does not add recipes, rewards, tutorial damage or a parallel task. It does not change
either Rulo or exit requirements. Completed status travels with character; pending
optional practice ceases to be displayed after leaving the mansion. A real task that
remains active does retain 0v exit restriction: the player must finish it or cancel it
personally before crossing.

## T1 Material Coverage — 4.33.0w Audit

Calculation with engine recipe functions, size M, no previous stock, one piece per slot
and even efficiencies in all layers. Figures are leather already tanned: 1 material unit
= 0,001 kg. These are not new balance costs.

| Complete T1 set | 25% | 50% | 100% |
| --- | ---: | ---: | ---: |
| Magic | 41,6 kg | 13,6 kg | 5 kg |
| Light | 78,4 kg | 26,4 kg | 10 kg |
| Medium | 156,8 kg | 52,8 kg | 20 kg |
| Heavy | 313,6 kg | 105,6 kg | 40 kg |
| The four sets | 590,4 kg | 198,4 kg | 75 kg |

The current code also uses leather and straps for these four types of armor; the table
reflects this catalogue, without replacing it with metals or fabrics. The
appearance/weight/stations of the type do not change their material in recipes.

The historical offer up to 0ac was 96 kg of drawer M plus 12,5 kg of Toro. From 0ad the
quota to 100% of the choice indicated at the beginning; the comparative costs of the
table remain valid, but are not the stock available. The four sets are not supplied
simultaneously nor to 25%.

To manufacture once each of the five T1 seals:

| Raw material | 25% | 50% | 100% |
| --- | ---: | ---: | ---: |
| Total raw copper | 460,8 kg | 28,8 kg | 1,8 kg |
| Total raw tin | 51,2 kg | 3,2 kg | 0,2 kg |
| Each raw gem: ruby, sapphire, emerald, topaz and opal | 9,6 kg | 2,4 kg | 0,6 kg |

The initial veins of the map exceed these requirements: copper 6.470,5 kg, tin 5.176,4
kg; ruby 1.022,34 kg, sapphire 1.363,12 kg, emerald 681,56 kg, topaz 1.703,9 kg and opal
2.555,85 kg. They are capacities calculated from the actors; neither extraction time was
measured here nor guaranteed that an already exploited save retains those reserves. The
nodes maintain their regeneration, but from 0ad the delivery quota is independent: these
physical masses do not allow collection of surplus.

Material availability, infrastructure and knowledge are separate requirements. The
twelve stations on the second floor cover the infrastructure; Ronnie teaches the first
weapon and, from 0ad, a family of armor with its components. From 0ae Caella it teaches
Seals and enables its quota when accepting. Do not use "there are veins" as synonymous
with "everything can be made now".

## Narrative exit, inventory and arrival (4.33.0v)

The rear door of the Bull room requires 90 phase, complete testing, El Loco and the
player's native Box itself. Use checks visibility, distance up to 112 MU and vertical
difference up to 48 MU. The old Direct Exit and its panel are removed in runtime, also
in 0u saves.

USDF 43320 presents the warning and two decisions. Cancel does not change anything.
Accept initiate phase 95 and 18 tics of fade after closing the dialogue. An active task
prevents start; it does not automatically cancel or touch your reservations. Blocking,
aiming, reloading, charging and Channel is interrupted. The temporary input lock is
removed only if this transition added it. Distance, health, property and requirements
are revalidated before cleaning.

The first weapon is resolved by MainM00StarterWeaponId, first in inventory, then as a
dropped instance. Only if it disappeared will the T1 choice be reconstructed, with
original size/essence and last known durability. It does not return materials or replace
a valid instance. Durability is recorded when the character persists; in an old save
without the item or a snapshot the maximum durability of the recipe is used as
exceptional recovery.

Confirmed the crossing, that piece is placed in the Box, without equipping, and the
other personal and stored physical objects are removed. The historical cleaning of
portions of mission does not replace this narrative rule: only the Box and first weapon
travel as physical items. Tarot, knowledge and the character record remain. There is no
additional loadout defined. Health and needs are preserved with the maximum in force
after removing equipment; they are not restarted for travel.

Before ChangeLevel phase 100 is saved, completed quest, exit objective,
cleaning/preservation flags and consistent models without equipment. GZDoom carries the
native inventory, without RESETINVENTORY or RESETHEALTH. MAP02 starts on the dry
gateway; USDF 43321 presents once the Voice and a closing/help page. The weapon can be
recovered from Inventory and used normally. The actors test field is now CADEV02 and its
objects do not appear on arrival.

MainM00ReturnTics, MainM00ReturnOwnsFreeze and MainM00SewerVoiceHeard are saved next to
the traveller log. Previous indexes are preserved. The presentation is reconstructed
when loading and does not re-grant cards or objects. Arrival does not offer normal
return to MAP01. With more than one player the crossing is rejected before mutating the
state; the cooperative variant needs joint design.

## Trucazo — Argento practice (4.37.13 / #81)

The author selected Argento in MAP01 for the first human-versus-NPC match on
2026-10-04. Issue [#81](https://github.com/damiancurti/Caelum-Argenteum/issues/81)
requires explicit rules before implementing the match. The author supplied
`DOCUMENTO 12 - trucazo.docx` (TCG/Trucazo v2.0) from the original project's
Documentation folder and explicitly confirmed traditional Argentine Truco as
the base, with the additions in that document. Source SHA-256:
`a326583696714f4dad6938b1ba85b7e09f60f6096012e413d8353ce0fbc8b4d9`.
The source is preserved in assets/design_sources/trucazo_v2_original.docx.
The author resolved the source contradictions before match implementation.
The following table is the implemented contract; author playtest acceptance
remains separate and pending.

| Area | Confirmed contract | Decision still required |
| --- | --- | --- |
| Opponent/location | One human against Argento in MAP01. | None for the initial opponent/location. |
| Physical source | The complete 78-card physical deck supplied by Argento in #164; separate from captured essences. The 40 playable cards are Minor Aces through 7, Pages, Knights and Kings, in all four suits. | None for identities/playability. |
| Dealing | Author correction: one shared shuffled deck of all 56 Minors. Each player receives five cards; their nonplayable 8/9/10/Queens enter their first row. Draw replacements from the remaining shared deck until each has at least three playable cards; replacement nonplayables enter their second row. Replenish only during the deal, never after playing a card. | None; the author confirmed this exact interpretation on 2026-10-04. |
| Card strength | Sword Ace; Wand Ace; Sword 7; Coin 7; all 3s; all 2s; Cup/Coin Aces; Kings; Knights; Pages; Cup/Wand 7s; all 6s; all 5s; all 4s. The author's current tie rule is mano (the participant who plays first). | None for ordinary strength/ties. The latest tie decision takes precedence over the source's awakened-card tie priority. |
| Turns/hand outcome | Traditional Truco: up to three tricks, first to win two wins the hand; trick winner leads next. The source's damage/health extension determines the complete match. | None for the hand structure. |
| Calls | Ordinary Truco scoring: unraised hand 1; accepted Truco/Retruco/Vale 4 worth 2/3/4; refused raises worth 1/2/3. Envido uses the best same-suit pair, 20 plus numeric values, figures 0; ties go to mano. No same-suit pair uses the highest individual value. Envido adds 2, at most twice; Real Envido adds 3, once. Refusal awards the previous call total, or 1 for an initial call. | None. Traditional scoring/timing, explicitly authorized by the author, supersedes contradictory source terminology about rounds and accepted-call raises. |
| Match ending | Trucazo health is Patience squared. Repeat hands until a participant reaches zero; a double knockout goes to mano. This practice cannot damage world health. | None for the health-based end condition. |
| Major modifiers | Explicitly excluded from this practice by the author on 2026-10-04. World Tarot powers remain separate. | None for this slice. |
| Health/damage | First-row value: (5 + sum of numeric cards) times (1 + Queen count). Second-row value uses the same formula. Damage before Intelligence: max(0, attacker's first-row value times points won minus defender's second-row value). Source's worked match uses the defender's second row. Author confirmed the former Type 1, mapped by #154 to Type 3: multiply by 1 + 7*(I*I+25*I)/12500, then round to the nearest whole health point as in the source example. | None; this supersedes the source's contradictory linear formula. |
| Magic Senses | Explicitly deferred by the author on 2026-10-04. Ordinary decisions/UI must not leak private hands. | None for this slice. |
| Stakes/consequences | Explicitly a practice with no wagers, prizes, item/card transfer or reputation changes. | None for this slice. |
| Leaving/interruption | Voluntary abandonment is an automatic match defeat. Restore ordinary controls; never strand the player seated. The source requires a dedicated screen that pauses the world. | None for voluntary abandonment. Native interruptions must preserve a valid state. |
| Save/load | Native persistence retains the exact dealt cards, used cards, rows, health, pending/suspended calls, result and action revision. Loading restores the menu and pause; it does not begin another hand or replay damage. | None. |
| Furniture | Existing 2/6/12-seat capacities and dining/rest behavior remain authoritative. | No capacity changes proposed. |
| Deferred scope | Human multiplayer, teams, network synchronization, broader ranked/casual services and full Major expansion are outside #81. The author additionally excludes Majors, Magic Senses and wagers from this practice. | None for this slice. |

The initial mano is randomly selected; subsequent hands alternate. Every trick
tie uses that hand's mano, including when the other participant led the trick.
After a trick, Continue exposes the result before the next lead. Completed
hands apply both damage totals simultaneously and offer the next deal if both
participants still have health. Trucazo uses separate health, never world HP.
Attributes and awakened Minor ownership are snapshotted at match start.
The source's casual awakened-Minor rule doubles numeric Envido/row contributions
and Queen counts; an awakened figure copies its same-suit numeric partner for
Envido (two figures remain zero before the suit bonus). Physical ownership
alone never awakens a card. No campaign Major effect runs in this practice.

Envido is available before one's first card in the first trick, including as a
response to a pending Truco; the suspended Truco resumes after Envido resolves.
Calls may be raised while responding. After accepting Truco, only its recipient
may raise it on their turn. No playing a card while a response is pending, no
late Envido, no third Envido, no second Real Envido or raise above Vale 4. The
original hand supplies Envido values; remaining cards supply legal plays.

Argento leads with his strongest available card, responds with his weakest
winning card if possible, otherwise saves strength by discarding his weakest.
He calls/accepts Envido above the source threshold of 25, raises an eligible
Envido response, and uses premium Aces/sevens or a won trick to support Truco.
The policy receives only his own cards and public state, never the player's
hand or future deck. A refused Envido does not reveal either private value.

Challenge choices are added to existing Argento pages without adding/reordering
USDF pages. The physical deck may be inside or outside the owned Box. The
match's revision-1 native Inventory is created on first valid challenge;
repeated interaction cannot reset an active match. The static input/controller
exists on old saves, and only validated play-scope messages mutate state. A
serial rejects stale actions. The view is reconstructed once on native load,
which includes the engine's ordinary one-tic resume before the menu pauses.
Loading original pre-patch saves with their original package is the reversible
rollback path; original saves/packages must be retained. This patch never
claims old engines can load a new save containing the new match class.

Left/Right or 1-5 selects a card, Up/Down chooses a legal action, Enter/A
confirms it. Esc/B returns from rules/rows or opens abandonment confirmation.
Save/Load opens the normal native menus. A finished result has an explicit
return-to-mansion action. Leaving MAP01, death or losing the valid opponent
invalidates an active session as defeat and releases its presentation; there
are no seat, world-freeze flags, resources or stakes to restore. Existing
furniture, dining/rest and Tarot ownership/powers are not modified.

## Tarot: collection and capture of El Loco (4.33.0t)

### Issue #80 approved power contract — author decision, 2026-10-04

Implemented in 4.37.12; both author playtests passed on 2026-10-04. The author
defines a shared activation of up to three selected, captured essences: **1000
Anima total**, **60 seconds** of effect and **600 seconds** of cooldown.
The Fool's flight is additional to its existing authored world transition.

| Contract | The Fool (0) | Ace of Cups (36) | Knight of Wands (60) |
| --- | --- | --- | --- |
| Existing passive | +2% collection | +1 each to Charisma, Empathy and Eloquence; +1% collection | +0.6 Strength; +1% collection |
| Approved active effect | Flight | Double this card's fixed contribution to +2 each | Double this card's fixed contribution to +1.2 Strength |
| Target/context | Self; ordinary live-player ability context | Self; ordinary live-player ability context | Self; ordinary live-player ability context |
| Payment | Shared 1000 Anima for the selected set, once | Same activation | Same activation |
| Duration | 60 seconds | 60 seconds | 60 seconds |
| Cooldown | Shared 600 seconds from activation | Same activation | Same activation |
| Cancellation/refund | No manual cancellation or Anima refund | Same activation | Same activation |
| Feedback | Selected/active/unavailable, remaining time and flight controls | Selected/active/unavailable and actual bonus | Selected/active/unavailable and actual bonus |
| Persistence | Selected set, activated set and remaining timers survive save/load/travel | Same; derive bonuses without accumulation | Same; derive bonuses without accumulation |

Changing a selection must never grant an essence or replay acquisition rewards.
Physical-deck possession is distinct from captured-essence ownership. Argento's
once-only complete deck and capture-commit requirement come from #80; its
weight is 780 grams and it occupies one slot. The author's final clarification
makes it unsellable, undroppable and unbreakable. Essences stay with the
character. No deck-in-Box requirement gates power activation.
The existing MAP01 return-door confirmation, quest/Box checks, 18-tic fade,
inventory preservation and one-way MAP02 transition remain authoritative.

Enter/A toggles cards in the Journal, up to three. User3 activates the complete
selection once. A held input cannot pay again; empty selection, unowned or
unsupported cards, invalid activities, insufficient Anima and cooldown reject
without payment. Selection changes affect the next activation. All 56 Minors
reuse the existing suit/rank contribution; other Major powers remain unavailable.
This patch adds no new acquisition content beyond the existing campaign.

The persistent record owns revisioned selection and activated-card arrays plus
remaining effect/cooldown tics. Personal time advances them, including existing
rest/travel simulation. Loading or map entry never resets them. Flight uses
native PowerFlight with the saved timer as authority, including infinite-flight
maps. Fly/swim up/down are exposed in Controls. Expiry removes flight and only
the temporary Minor contribution, without healing or Anima refund.
The HUD shows remaining effect duration in cyan and shared cooldown in white,
with the Tarot icon above the existing side Seal indicator. The Journal also
shows both timers. The author's follow-up explicitly requests this HUD feedback.
Planned journeys retain the existing temporary-effect restriction for every
active Tarot set; after effects end, journey application advances the remaining
cooldown by its simulated duration, just as it does for Seals and class abilities.

The native physical deck grants no TarotOwned flags. Standard C storage and
capacity rules apply to its one slot and 0.780 kg. Failed delivery can be retried
after reorganizing inventory. Capture revalidates Box identity and deck location
at commit, preserving boss/quest availability on failure. Legacy Box-handoff or
earned-essence evidence enables one deck recovery; capacity failure retries.
Power revision 1 starts unselected; deck revision 1 never grants missing
essences. Preserve the original save/package for rollback. No map is rewritten.


### Existing collection rules

Rule in force since 0aa: each Minor exclusively contributes a base passive, in addition
to its +1% per collection. Major: +2% per card. The 22 Major and 56 Minor add up +100%
collection, in an additive way, before the three current growth families. Do not round the level or alter
creation points. Combat awards no XP. The active rule above supersedes the reservation hook; Trucazo remains #81.
The campaign obtains The Fool, Ace of Cups and Knight of Wands. The other 75
essences still require their acquisition content.

| Suit | Family | First / second / third attribute |
| --- | --- | --- |
| Swords | Mental | Intelligence / Patience / Insight |
| Cups | Social | Charisma / Empathy / Eloquence |
| Wands | Physical | Strength / Hardness / Constitution |
| Coins | Technical | Agility / Dexterity / Resilience |

| Card from each suit | Base bonus per card |
| --- | --- |
| 2, 3, 4 | +0,3 to the first attribute |
| 5, 6, 7 | +0,3 to the second |
| 8, 9, 10 | +0,3 to the third |
| Knight | +0,6 to the first |
| Page | +0,6 to the second |
| Queen | +0,6 to the third |
| King | +0,5 at all three |
| Ace | +1 at all three |

Each full suit gives +3 passive to its three attributes. While a Minor power is
active, its fixed contribution is added once more before collection multiplication. Order: creation + minor passive +
equipment, then multiplication by (1 + collection percentage/100). Armorless example: 20
creation +18 amulet T3 +9 seal T3 +3 minor =50; with 78 cards it turns out 100 in the
attributes that receive those bonuses. It is not a cap imposed on the attribute nor are
passive Majors invented.

TarotOwned[78] lives in CaelumPersistentCharacterState, Inventory traveler. Stable
indexes 0–21: Marseille Major Arcana; El Loco =0. Minor Arcana: Swords 22–35, Cups
36–49, Wands 50–63, Coins 64–77. Within each suit: Ace, 2..10, Knight, Page, Queen,
King. The code adds integer tenths and rejects duplicate delivery. Counter, passives and
percentages are derived from property; they are not accumulators. ApplyCharacterProfile
rebuilds creation/equipment, adds Minors, multiplies collection and recalculates
statistics/load. The debug profiles follow the same order after its forced base.
Re-equipping, loading or travelling does not duplicate bonuses. The Journal separates
Minor Arcana base bonuses and percentage bonuses using attributes in the same order as
Character. Load 0z also reconstructs serialized derivative values and the cost of a
pending spell, maintaining resources/progress.

The controller spawns CaelumM00FoolEssence in (1420,1050,-370), on the floor Z=-384.
Check the 80 phase, the four finished branches and delivery/ownership of the Box. Reuse
the StoryPlaced instance when loading; do not put actors in the WAD. MainM00FoolRevealed
retains individual revelation. The world render shows CTAR reverse and then the CFLF
resource, also used in the Journal.

Using requires player created/live in MAP01, distance <=128, difference Z <=48 and
CheckSight, plus native box with Owner and ItemId matching. The effective scope of Use
also respects the native layout of the player. USDF 43318 lets you confirm or leave it
there. The music drops during dialogue and the native destructor restores
Level.MusicVolume; the selected volume is not changed.

The acceptance starts 35 animation tics after closing the conversation. The original
actor remains still; a non-collisional image approaches the player. Each tic revalidates
distance, health, mission, image and the same Box. An interruption erases only the image
and restores the essence. At the end, RecordMainM00FoolCapture changes 80 -> 90,
registers the card, 40 flag, 6 target to 1/1 and EXIT_READY, which from 0v enables the
final door. It persists before removing the essence. Repeat does not reward again. The
native save also retains the animation and its references.

Tarot is the seventh page of the Journal. Counts cards, shows the illustration obtained
and the percentage; Character shows decimals. Detail distinguishes
search/reveal/capture. Palomo uses USDF 43319 after obtaining it; the four residents
adapt their completion pages. USDF nodes are attached to maintain existing indexes.
There is no map change in this patch.

## Palomo final and single box (4.33.0s)

The final conversation uses USDF 43316; an early visit above uses 43317. Pages are
attached to preserve the indexes of the saves dialogs. DepartureDone enables to speak
with the same instance, without moving it. Delivery requires MAP01, live/created player,
active conversation with Palomo, range/height/visibility and active registration in
phase 75 with the four branches completed.

Only CaelumMainM00AcceptMagicBoxAction confirms the narrative reward.
CanReceiveMainM00MagicBox validates the requirements; RecordMainM00MagicBoxGranted
advances 75 -> 80 and fixes the 39 flag after confirming property and identity. Asking,
going back or closing does not grant anything. A second attempt retains the Box and the
stage. USDF tokens reflect the record, do not replace it.

CaelumMagicBox is a native Inventory without duplicate entry in the list; the existing
interface of the Box is still its presentation. It has ItemId and Owner,
MaxAmount/InterHubAmount 1, UNDROPPABLE and UNCLEARABLE. It does not enter the sales
catalogues or storeable content classes. Weight continues to be added only to
CalculateMagicBoxTotalWeight: 0.001 kg plus the overall reduced weight of the content, with
current divisor/rounding rule. It does not add another slot.

EnsureOwned recovers the instance if missing and assigns identity to the old property
without duplicating contents. Use the existing ID counter and protect the Box identity
against imported equipment with the same number. It does not advance a mission for
possessing an inherited Box: it is necessary to accept to Palomo. The Box travels with
Inventory. 0t added El Loco capture and its attribute bonus. The later mansion
departure and #80 powers are implemented; the current contract appears above.

In Inventory, C saves/withdraws the selected object. Slots/load limits and restrictions
are retained for equipment placed, loans, mission reserves and crafting. Delivery allows
the player to reorganise its content even if the initial 0.001 kg temporarily increases its
load. Text gives instructions and the path of the passage/lift/cave. From 0t indicates
where to examine the appearance.

## Essential residents and post-combat dialogue (4.33.0r)

In MAP01, the four CaelumAnchoredResident with StoryAnchored activate the native BUDDHA
flag before DamageMobj and on loading. The engine limits normal damage to leave 1 health
before entering death. In the test, reach that active minimum CrouchIdle and temporarily
remove collision, attacks and damage reception. Retrying or winning restores resources,
armor, posture and interaction. Die maintains a fallback for forced damage/telefrag,
which ignores native BUDDHA. Unanchored diagnostic instances retain its normal rules.

A_Chase can leave INCOMBAT after a projectile attack. StartConversation rejects that
flag even if the actor is in full health. The flag is cleared out of combat and in the
waiting/house state, along with Target/LastEnemy and attack flags. A conversation that
still belongs to a player is not interrupted. 0q saves recover the interaction without
repeating the test.

A saved narrative instance with health <= 0, CORPSE or KILLED is repaired through Revive
and restoration of size, resources and protection; it retains identity, home
coordinates, references and quest state. If the trial remains active, it stays out of
combat with 1 health until the trial ends. Do not respawn copies, alter loot, advance
stages or increase the monster total during repair. An already-destroyed actor is not a
recoverable instance.

Rulo recognizes leadership and innate strength in victory, repetition and detail. There
is no new statistical bonus or exposure of the Limbo secret. 0t adds El Loco in the
cave, capture and bonus of Major Arcana. That reward belongs to the card, not to the
practice of Rulo.

## Accompanied combat and Bull performance (4.33.0q)

The Bull retains 900 kg and its offensive profile. Upon entering, the four existing
residents are placed in the formation during the two seconds of preparation: Rulo
(-2010,-155,0), Ronnie (-2010,155,0), Argento (-1900,-220,0), Caella (-1900,220,0).
Rulo/Ronnie use melee; Argento/Caella retain melee and its native elemental projectiles.
No statistics or weapons are added. The Bull retains a valid target of the group and
seeks another if it falls.

RuloPartyMode and references to player/Toro live in each resident and are serialized by
the engine. Mode 1 prepares, 2 fights and 3 waits for closure. A lethal gore leaves the
resident with 1 health, crouching, no blocking or attacks. Retrying and victory restore
health, Air, Anima, Lucidity and armor. The group does not inflict damage on the player
or on each other: their projectiles cross allies and the receivers filter the damage.
The player’s defeat also removes the projectiles from the comrades before reboot. The
narrative NPC is not lost. After winning, Rulo receives the return there. When
completing and leaving the view of all, the same instances recover their bedrooms. This
meeting does not add a travel route or change the physical route of Palomo.

Reference yield, not exact weight deductible only from the live mass:

| Concept | Model for the Bull 900 kg |
| --- | ---: |
| Fresh, wet and unprocessed skin | 54 kg: design assumption of 6 % live mass. |
| Usable finished leather | 54 × 255 / 1100 = 12,518 kg. |
| Native loot | 12,5 kg; 12.500 units, five 2,5 kg stacks. |

The 6 % is an explicit estimate for this fictitious animal; it is not a universally
validated measurement or percentage for a known breed/age bull. The tanning approach
with the UNIDO balance of bovine skins: 1100 kg of fresh skin produce 195 kg of grain
leather and 60 kg of split leather. It is a case of manufacturing leather for footwear,
not a constant for all tannings. Source: Buljan, Reich and Ludvik, *Mass Balance in
Leather Processing*, 2000, page 4,
https://leatherpanel.org/sites/default/files/publications-attachments/mass_balance.pdf

The automatic delivery of finished leather maintains the abstraction of loot already
used. It does not modify the overall tanning recipe or apply another decrease when
collecting. GetLeatherYieldUnits uses Mass and rounds to 100 g; the size does not
influence that physical ceiling. From 0ad is delivered Min(physical roof, unissued
leather quota). The old LeatherBudgetUnits is preserved to read saves, but recalculates
when dying; LeatherDropped continues to guarantee a single delivery. Leather
produced/picked in a previous victory is not removed.

Argento uses the same stages of the Journal; the instructions that named it are resolved
to own texts in the first person, in Spanish and English.

## Real Shield and Sword View (4.33.0u)

Ronnie lends exclusively a sword. FindActiveNativeShield demands a native instance
equipped, outside the Box and matching in type/tier/size. RepairActiveShieldReference
recovers its ItemId if applicable; without valid instance cleans the model. It runs
before the View Tick and syncing inventory/save; old migration occurs before repairing
references. HasActiveBlockSource also requires durability and compatibility with the
weapon. Giant gauntlets retain their own Block.

The modular sword view always removes the 10/20 layers without a valid shield, even if
the visual display saves already says that there is no shield. Equipping a real one
restores those layers. The rules of hand, costs and defense do not change.
HUDHasActiveBlockSource is a reading for the instructions of the UI; it does not grant
equipment nor is combat authority.

## Rulo combat test (4.33.0p; updated 0u guide)

Authority: Inventory traveler and existing 30–38 flags; 59–60 for spent/recovered air
without expanding the 64 array or renumbering flags. 60 phase + Argento/Caella/Ronnie
complete enables the start to Rulo (70). The defeat of the bull marks 36; return to Rulo
brand 37/38 and advance to 75.

| Practice | Actual confirmation |
| --- | --- |
| Primary | Impact on the target with Fire, melee or projectile. |
| Secondary | AltFire hit; ranged Aim; for a spear without a secondary attack, strike while moving forward. |
| Defense | Blocking with actual compatible equipment/gauntlets, ranged ADS or 48 MU of lateral movement inside the ground-floor room. Greatsword uses dodge; Zoom does not block. |
| Advanced | Charged hit, magical impact thrown in lateral displacement or completed reload. |
| Air spent | Actual resource decrease inside the practice room. |
| Air recovered | Post-expenditure increase. |

Rulo and Detail choose the indication from the active equipment: aim, block or dodge.
The greatsword receives an explicit explanation. Moving the camera without walking does
not count; lateral scroll controls must be used in front of the target. The brand is
updated when you pass the route and persists when loading. No dodge button or new
defense is added to the greatsword.

The magic in motion avoids demanding a loaded attack whose cost exceeds the maximum
Anima of some characters. No changes are made to costs, damage or attributes. Brands are
not restarted when re-opening the dialogue or charging. The key requires all six
practices. The target gives no experience, adrenaline, loot or wear by impact; it
retains the art and volume of the existing TrainingDummy.

Rulo refurbishes the initial weapon on its same ItemId and lends 24 units of the
necessary native ammunition. The loan is spent first, is replenished if it runs out
inside the enclosure and when preparing a new attempt, and cannot be released by
inventory while the ammunition is borrowed. The return removes only the remainder and
adjusts the magazines; it retains its own units. It checks load capacity before
delivering. The javelin does not produce recovered materials while this test is active:
it cannot convert the reconditioning into raw materials. Its AltFire melee now reuses
the existing main range, correcting the old zero value of the fallback.

The tutorial bull retains profile, mass, anatomy and native damage. Adjustments of this
delivery to check in game: 18 tics of gore anticipation, 2 seconds of initial
preparation. The entry starts the test; the key alone does not wake the bull.
The two leaves of door 806 lock and the bull remains in its room. As of #164,
native autosave is requested with the four helpers gathered during that grace,
before hostility; loading resumes it without another checkpoint request. Player
death uses native Die and manual loading, without resets or healing. The
defeated bull opens the enclosure, delivers once the leather within the current quota
(up to 12,5 kg from 0q) and dissipates. It is spoken with Rulo within the enclosure to
close.

## Knowledge of recipes and manual removal (4.33.0o)

The Ronnie test shows the chosen recipe and its components/processings. The MAP01
External Processing Manual (LORE-0001) is removed; loading a previous game also removes
that copy from the world. Learned recipes are not revoked or objects removed from the
inventory. The manual class remains for compatibility and other uses; learning rules are
not modified. 0n was approved by the author the 2026-09-11.

## Historical cost and supply reference (4.33.0n–0ac)

The stock described in this section was replaced by 0ad quotas. Cost formulas do not
change; only the delivery of raw materials.

Source: GZDoom native blueprint 4.14.2, size M, efficiency 25 % in each layer, empty
inventory. Each set includes head, torso, hands and feet; "seals" comprise all five
elements. Current recipes are not changed.

| T1 family | Cow leather already tanned for set M |
| --- | ---: |
| Magic | 41,6 kg |
| Light | 78,4 kg |
| Medium | 156,8 kg |
| Heavy | 313,6 kg |

They are 590,4 kg for all four sets. If you are split from raw skin and cured to 25 %,
those quantities multiply by four. Do not confuse units of material (0,001 kg) with
whole objects. These values describe the manufacturing cost, not the current bull loot.
Since 0q, its 12,5 kg no longer covers a complete set to 25 % per layer. The drawer
retains 96 kg in M for the first gauntlets. Gun + any complete set is not guaranteed
simultaneously: for example, M gauntlets consume the reserve and an M heavy armor needs
another 313,6 kg; 301,1 kg would be missing after the new loot.

Seals T1: 460,8 kg raw copper, 51,2 kg raw tin and 9,6 kg each gem. The five veins cover
those types and quantities. By decision of the author, the supply of MAP01 is limited to
T1. As a reference outside that range, T2 seals: 256 kg raw iron, 16 kg raw silver and
19,2 kg of each gem; iron/silver sources are missing. T2 armors use predator leather, as
well as cow leather for straps and silver for details. T3 sum monster leather for armor
and gold; T3 seals also require steel (iron/coal), silver and gold. Available
infrastructure does not imply any knowledge or materials.

Giant gauntlets T1/M to 25 %: 96 kg of leather already tanned for your straps. It is the
only initial choice with leather. The drawer retains a reservation for that recipe
before the Toro, calculated on the size chosen. The recipe is not modified. The
migration removes only the stock of gems from the drawer, retains what has already been
collected and discountes the leather removed before updating. It does not replace
consumptions.

This reference consolidates implemented rules. Narrative scope is in
[MAP01.txt](MAP01.txt), acceptance status in [PROJECT.md](PROJECT.md) and historical
variants in [HISTORY.md](HISTORY.md).

## Caella test (4.33.0i–0m; impact checks updated in 4.37.1 / #62)

It is enabled when closing Argento in phase 35. Fire and AltFire each require a
valid player magic projectile impact on the shared mansion training dummy in the
north-central ground-floor room, off the central hall. The projectile's stored
mode determines primary/secondary; casting, missing, hitting another target or
using a physical attack does not satisfy either offensive objective. Staff,
book, bell and statuette retain their native attacks, including actual explosive
damage reaching the dummy. The target stays indestructible and reusable by Rulo.

User2 retains Seal Channel with actual Adrenaline expense and needs no impact.
Anima is spent on completed release, even a miss; recovery is observed in the
actual reserve independently of offensive hits. The old MAP01 Reload/Channel
display remains replaced by User2. Existing combat costs and dispersion remain.
Caella preparation reuses the existing missing-target recovery path without
duplicating a present target. Existing active/completed 4.37.0 save flags, rune
progress and loan IDs are preserved, including offensive flags earned under the
former cast-based rule. There are no new saved fields or conversion/reset steps.

As of #164, four required practice checks precede four runes; the Journal counts
0/8 to 8/8. Channel is optional with an owned Seal. Use with an active staff or
owned magic implement conducts the rune's element: Earth -> Air -> Fire -> Water.
At 4/4, return to Caella; her last instruction advances stage 40 to 45 and opens
the still-visible wall without taking any equipment. An error resets only runes;
hints remain at 2 and 4 errors. Completed saves keep their open passage and stage.
The following loan description is historical and superseded by #164.

The two temporary instances reuse T1 from the catalog. They retain ItemId and the
CA_ITEMFLAG_LIMBO_TEMP brand; they are not sold, released, disarmed or stored in the
Box. There is no duplication when preparing again. To show Channel without attacking
anyone, the first User2 can top up the reserve up to a second of its native cost,
limited by MaximumAdrenaline. The assistance ends when recording actual consumption.
Cooldowns, general combat and attributes do not change.

Persistence adds sequence index, errors, Anima reference and previous equipment IDs;
uses 57–58 free flags. Do not shift accepted fields/indices. Placement, compatibility,
testing and limits are in PROJECT.md.

## Ronnie: choice, materials and first weapon (4.33.0l)

Historical baseline: the 4.37.3 section above supersedes the choice speaker,
shield scope, temporary-equipment classification and final departure restriction.
The existing recipes, task flow and other supply rules continue to apply.

After Caella, Ronnie offers 36 T1 choices: 16 physical weapons and four magic shapes for
five essences. The class does not restrict the choice. It can be read and returned
before confirming; confirming sets the character's choice and size. You learn the final
recipe and all its processing steps/components. The quantities are calculated using
CaelumCraftingRules; there is no other recipe table within the mission. Since 0ad the
reference plan uses 100% on each layer.

| Weapons | T1 catalogue raw materials |
| --- | --- |
| Dagger, hatchet, machete, javelin, sword, axe, spear, greatsword, war axe, halberd | Wood, raw copper and raw tin. |
| Flail and carbine | Raw copper and raw tin. |
| Giant gauntlets | Raw copper, raw tin and already tanned cow leather. |
| Common bow, long bow and crossbow | Wood and vegetable fiber. |
| Staff and statuette | Raw wood and gem of the chosen essence. |
| Bell | Raw copper, raw tin and raw gem. |
| Book | Vegetable fiber and raw gem. |

Gems: ruby/Fire, sapphire/Water, emerald/Earth, topaz/Air and opal/Quintessence. The
five gems are extracted from veins at the bottom of the cave. The drawer contains only
leather T1 already tanned. From 0ad covers the chosen set and, where appropriate, giant
gauntlets, to 100% by transformation: these use 6.000 units in M. Each unit weighs 0,001
kg. Only the unissued quota that fits in the current load is removed; it is not
necessary to carry it all at once.

The stock belongs to the character's record. Reopen/load does not replace it. Return
only amounts removed from that chest that remain unexpended and are not booked for a
task. Cancel releases reservations; closing the station pauses work. Materials can be
processed by stages; the supply of 0ad requires 100% in each layer to cover the entire
set. The Journal’s missing-materials display also accounts for components and processed
materials already owned by the player.

Twenty 2D shrubs surround the entrance along with four ceibos: cutting damage produces
bush fiber and tree wood; piercing/blunt damage does not. The vegetation is removed from
the cave. Each shrub has 10 kg and hardness 2,5, as well as wood, and retains general
regeneration. The borrowed T1 sword uses main cutting and piercing secondary attack for
copper/tin veins. If there is already the old cave sword in stock, your ItemId is
adopted. Requesting it again restores/equips the same piece. Caella removes only her
loaned items.

The first T1 manufacturing within this test delivers a personal instance with
CA_ITEMFLAG_LIMBO_PRESERVABLE. It does not require Magic Box, retains its efficiencies
and moves to 60 phase. The loan is returned when talking to Ronnie. Before leaving the
Limbo the initial weapon is not sold, discarded or disarmed. The weapons manufactured
afterwards are temporary and do not replace your ItemId. Technical cleanup of
development trips removes those instances and amounts of mission, preserving previous
portions of its own. The 0v narrative exit applies the strictest final rule: only Box
and first weapon, including cleaning of the other stored objects. Upon arrival, the
weapon can be recovered and used as ordinary equipment.

The stacks use LimboQuestUnits and LimboSupplyUnits; consumption first deducts the
tutorial portion. The crafting retains that origin in their intermediate results and in
the reservations when saving/loading. Stacks containing a tutorial portion cannot be
sold, dropped or sent to the Box. Narrative exit requires the player to finish or
cancel the task personally; it does not delete active reservations. Technical cleanup
of development trips does not eliminate own stocks by name matching or grant returned
loans again. Narrative confirmation does warn and remove all other physical objects.

0n incorporates arrows and 0w adds optional repair after closing Ronnie. Needs (0x),
Air/Movement (0y), Load (0z) and Pool Breathing (0ab) have optional practices. Bolts and
their teaching are added to 0ac. 0ad incorporates the chosen armor recipes and 0ae
seals. Bullets (composition/process) and water collection/potabilization are still
pending; no expansion is a new requirement to start to Rulo.

### Crafts arrows and controls (4.33.0n)

Choosing the longbow shows the recipe 129 and its dependencies. It also applies to
saves with those choices. Previous 129 recipes retain their indices and knowledge; the
catalog passes to 130 entries. Filter Munitions.

One batch produces ten CaelumArrowAmmo of 50 g each. Built-in composition: 350 units of
shaft and 150 of bronze tip per batch before material loss; to 25 % the assembly
consumes 1.400/600, and each component/processing step adds its own material loss. Use
bench, carpentry/forging and ranged workshop of Ronnie through the native system of
dependencies. The task reserves, pauses, cancels and persists like the others. It does
not require Box and does not record or replace the first weapon. The arrows have fixed
tier 1 and fixed lot of ten; B does not increase that lot.

Tab closes Crafts with or without station. G filters families during the session (the Y
control button retains that function). Q/Escape continues to close the session. Doors
and stations demand vertical overlap, foot difference <=64 MU and CheckSight before
performing the interaction. The station also checks range while maintaining the session;
changing floor closes it and pauses the task.

### Key, Bull and Palomo’s departure (4.33.0n)

Argento has a silver key instance; it is transferred to the player without recreating
another. It requires Argento/Caella/Ronnie complete and the six practices of Rulo (or
its already complete branch). Demanding the defeated Bull would be circular. The lesson
is connected from 0p. The Bull waits inactive until ENTERING the enclosure with the key
and preparation finished. From 0q the group meets before the first attack. Death records
the result and produces the mass-based leather described above. Save does not duplicate
key, actor or loot.

Ownership correction 5.1.13/#160: the authorized handoff must remove the existing
key from Argento's native inventory before asking the ordinary pickup guard to
validate it. If validation fails, restore that same object to Argento. Success
transfers the existing instance and refreshes carried weight/dialogue tokens;
repeated offers do not duplicate it. Ordinary pickup still rejects foreign-owned
items. DetachFromOwner is a notification hook, not an ownership-removal operation.


After the initial dialog is finished, Palomo keeps SOLID on and INVISIBLE disabled. He
runs using XY velocity, vertical physics, stairs and unlocked doors, then waits
upstairs. The path is saved. New states are added at the end to keep sprite indexes in
old saves. The final conversation is connected after Rulo.

## Mass of shrubs and garden migration (4.33.0m)

The shrub represents approximately 1,5 m in height and 2,2 m of crown width; the adopted
mass is **10 kg of fresh above-ground biomass**, an estimate for that specimen, not a
universal species weight or a weighing. Roots and soil are excluded. Foliage contains
air: it is not calculated as a solid wooden cylinder. As an indicative model of that
estimate, 0,012 m³ of stems/branches at an assumed density of 650 kg/m³ totals 7,8 kg,
plus 2,2 kg of leaves/thin stems. These are modeling assumptions, not botanical
measurements; a documented species/size would allow replacing them with a specific
allometric estimate.

The game system converts that mass to capacity with 1 unit = 0,001 kg: 10.000 units per
bush and 200.000 between twenty. It is an accumulated reserve, not the yield per stroke
nor a claim that a real plant will become entirely textile fiber. Each cutting impact
releases power × (1−2,5/10), limited by the remaining reserve, accumulating fractions.
The mass limits the total; hardness and power determine the extraction by impact. The
worst existing T1/XL plan needs 144.000 units of fiber to 25% in each layer, so the
initial garden is sufficient without increasing the mass of each plant.

When loading 0l the remaining proportion of the three old nodes is moved to the twenty
new ones. Its original capacity of 100 kg is used: GZDoom can omit Mass when it matches
the Default and apply the new Default when deserializing. The materials already
collected are not removed. Subsequent loads do not redistribute or refill anything;
native regeneration continues. Veins and chests are not moved.

## MAP01 workshops (4.33.0m–0n)

Each room has its own network; only neighbors to 64 MU or less and with the same
CraftingRoomGroup add up infrastructure. Group zero retains unrestricted networks on
other maps. There are no capacity loans between walls or floors.

| Room | Physical infrastructure | Coverage |
| --- | --- | --- |
| Rulo, north by the entrance, Z136 | Workbench, forge, anvil, armor workshop, sewing machine | T1–T2 heavy weapons and armor, with its components. |
| Ronnie, north by the stairs, Z136 | The previous five, ranged workshop and sawmill | T1–T2 medium weapons/armor and ranged weapons. |
| Argento, south by the stairs, Z136 | Workbench, forge, anvil, armor workshop, sewing machine | Lightweight weapons and armor T1–T2, with its components. |
| Caella, south by the entrance, Z136 | The five commons, altar, globe, jeweler’s bench and fine tools | T1–T2 magic weapons and armors, processing gems/essences/fabrics. |
| Second floor interior room, Z264 | The twelve stations, including the Master Workbench | Complete network; recipes and materials are still needed. |

In 0n the bedrooms use their corners; upstairs the twelve form a row against the back
wall, X=-336. The network of each room is conserved.

They are narrative specializations and infrastructure, not new restrictions by
class/family. Physical families share forging/sewing according to the catalog. There is
no Master Workbench in dormitories. 18 existing instances are retained when moved and 20
are added: total 38. A task that was in a transferred station is paused as it moves
away, preserving progress, materials and reserves; it is resumed from the right
infrastructure. T2 economy is not modified nor T2 materials are given as part of the
first T1 weapon.

## Character Poses (4.33.0m)

Rulo/RSRU, Ronnie/RSRO, Argento/RSAR, Caella/RSCA and Domingo/RSDO share: RestSeated=A,
RestLying=B, CrouchIdle=C, CrouchWalk=D–G (6 tics per phase), eight rotations per frame.
Domingo switches between C and D–G during crouched movement; native physical crouching,
attacks, pain, death and returning to standing are preserved. The renderer receives the
crouched sprite to avoid compressing it twice. New states are appended: they do not
shift saved state indices. In 0m, seated/lying poses were prepared graphical states.
Since 0d, Domingo uses them in the player session: Sleep restores Sleep and Wait
maintains its consumption. Other NPC poses remain available as art, without routine
scheduling. 0e adds player furniture and camera; NPC rest routines are outside that
implementation.

## Social probability

Rulo uses **Emotion**, derived from Empathy. Caella uses **Persuasion**, derived from
Charisma. Both use new Type 2 and 120 difficulty, according to the decision for 0f.
Residents have no assigned faction: reputation modifier is neutral.

```text
Type 2 capacity = 100 + 3 * (attribute*attribute + 25*attribute) / 125
probabilidad (%) = limitar(redondear(capacidad × 100 / dificultad), 0, 100)
```

The rounding is to the nearest integer (`Floor(x + 0.5)`). For 1 to 99 percentages a
uniform integer is thrown from 1 to 100; there is success if roll <= percentage. 0 fails
and 100 succeeds automatically, without consuming the random-number generator. The
difficulty is not a percentage alone: you have to know the attribute.

| Difficulty | Attribute 10 | Attribute 30 | Attribute 50 |
| ---: | ---: | ---: | ---: |
| 50 | 100% | 100% | 100% |
| 100 | 100% | 100% | 100% |
| 120 | 90% | 100% | 100% |
| 150 | 72% | 93% | 100% |
| 200 | 54% | 70% | 95% |
| 300 | 36% | 47% | 63% |

At difficulty 120: attribute 0 -> 83%, 3 -> 85%, 10 -> 90%, 15 -> 95%,
19 -> 100% after rounding. Difficulty <=100 succeeds automatically even at
attribute 0 because Type 2 includes its 100% base. Difficulty and RNG rules
are unchanged; the probabilities follow the newly approved curve.

Ronnie does not roll dice. His direct option requires **Dialogue skill >= 1**, with:

```text
Type 1 dialogue bonus = (Eloquence*Eloquence + 25*Eloquence) / 125
```

Eloquence 4 gives 0.928 and does not reach; Eloquence 5 gives 1.2 and
enables the option. Dialogue skill 1 does not mean Eloquence 1.

Rulo/Caella attempts save the result, probability and die roll. Reopening the dialog
does not reroll. Failure unlocks Argento’s hint and an alternative response without
chance. Rulo also requires a respectful response: reading his emotion does not mean
obtaining his cooperation. The advice also allows you to continue with Ronnie after
visiting it even if you lack Dialogue skill.

## Resources, persistence and physics

Health, Anima, Air, Adrenaline, Lucidity, Hunger, Thirst and Sleep belong to the
character; the calculations live in the modules of attributes, statistics and resources.
The scale **1 game hour = 3 real minutes** is conserved. The states and formulas are not
rebalanced in 0h.

`Actor.Inv` and `CaelumPersistentCharacterState` are authoritative sources. HUD/Journal
uses snapshots, and USDF tokens are derived conditions. Exit/changemap transfer to
character; `map MAP02` initiates another character. Shared cooperative progress is not
yet implemented.

Collisions use the project physics modules and native movement restrictions. Do not
convert impulse formulas into a second weapon damage route. Complete historical
calibrations are preserved in HISTORY.md; crowd testing remains separate in CADEV02.

## Mission detail (4.33.0k–0l)

From 0ak, Left/Right selects a known mission; Up/Down also selects from the list. In
Journal → Missions, F (Y on a controller) alternates summary and Detail of the selected
mission. The description explains what it is about and what it should be done in the
current stage. In Detail, Up/Down crosses the text; TAB returns to the list and another
press closes the Journal. PgUp/PgDn or LB/RB changes tab. Navigation is local, does not
change progress or grants objects. Undiscovered quests do not appear.

During Caella it lists primary, secondary, channeling, anima expense and recovery as
Done/Pending. A 5/5 changes to runes sequence and riddle. A 4/4 requests to return with
Caella; after the 45 phase return indicates to speak with Ronnie. Argento uses that same
selector when asked with whom to follow, including collection and return of Ronnie. The
source is persistent record, not independent menu counters. The same location indication
is used in the Caella conversation and in detail to avoid contradictions.

Path: entrance → central corridor → bottom staircase. Stay on the ground floor, surround
it on the right/south and look at the back wall behind that side, near the floor.
Accepting the test makes the marks appear; 5/5 practice allows you to use them.
Approaching with active staff, aim and press Use. The seal of fire is enough; it is not
fired to activate the runes.

During Ronnie, Detail shows the weapon chosen, the raw material plan to 25%, the missing
quantities and locations of chests, bushes, veins and Workbench. After manufacturing, it
asks to return the sword; then it shows the finished preparation. The list of missions
indicates initial ready weapon.

## Presentation of Seal and Runes (4.33.0j)

The equipped Seal is seen on the right side of the HUD. It retains its colors if User2
can start the channeling or if it is already channeling; it appears on gray scale if
there is cooldown, insufficient Adrenaline or there is another system block. The same
availability query feeds the action and the HUD; observing it does not grant or consume
resources. Caella's initial help counts as available.

The remaining seconds, rounded upwards, are shown below during cooldown until they
disappear at zero. The wait retains the existing 60 s. Without Adrenaline, it is grey
and without a counter: that resource has no guaranteed recovery time. User2 stops
generating the central state text and generic central skill warning. The other controls
retain their behavior.

Caella uses the Spanish section [en], as well as the previous conversations. Practice
requires primary, secondary, channeling, spending and recovery of Anima. Then, with
active magic implement, Use activates each rune. A single Seal and borrowed staff serve
for Earth → Air → Fire → Water. Seal does not determine the element of rune and it is
not required to shoot it. Progress and repayment of the loan continue in the existing
persistent record.

The stations receive 3D models without changing their infrastructure logic.

## Crafting and repair

The station network is cumulative. Workbench and main station enable T1; the specialist
adds T2 and Master Workbench adds T3. Forge uses Anvil, Ranged uses Sawmill, Armor uses
Sewing Machine, Essences uses Earth Globe and Jewellery uses Fine Tools. The particular
requirements of recipes, including the shield anvil, remain valid.

The efficiency is chosen by layer: 25/50/100% with time factors 1/10/100. Material loss
propagates through quantities and each operation applies its factor once. The old rule
"everything takes ten seconds" does not describe the current manufacturing. Complexity,
units, batches, technical attribute and sublayers intervene in time. Trade retains its
time of ten seconds per transaction.

The tasks reserve materials and progress only with active session, within the range of
the station (96 MU) and with available infrastructure. Closing or moving away pauses;
cancel explicitly frees up reserves. Multilayer assembly allows from primary resources.
Proportional repair and disassembly use recipe and durability; elemental equipment
returns its corresponding materials.

## Common controls

### Combat dispatch ownership (#310, 5.5.1)

`player/CaelumCombatDispatch` coordinates the equipped primary attack, secondary
attack and large-weapon sweep. The three existing pawn methods remain compatible
adapters. The service is stateless and takes the requesting pawn explicitly;
`CaelumPlayerAuthority.CanMutate` rejects null, detached, stale and predicted
receivers before refreshing clocks, starting actions or spending resources.
It never resolves a fallback local player or owns a second combat state.

| Boundary | Caller and retained authority |
| --- | --- |
| Input/native states | `CaelumPlayableWeapons` callbacks and retained family/magic adapters resolve the selector's owner. Native Ready/Fire/AltFire/Reload/Zoom states and player input latches keep their ordering. |
| Coordination | The three dispatch adapters delegate to the service. Existing Battle Cry/class cast, bolas/utility staff, cooldown, immobilization, ranged ADS, block cancellation and javelin fallback branches retain their original order and conditions. |
| Physical start/commit | Pawn `BeginPhysicalAttackCycle` and `AdvancePhysicalAttackCycle` own preparation, interruption and release. `PerformCarbineAttack`, `PerformDebugSwordAttack` and `PerformJavelinThrow` retain effects, costs, ammunition and wear. |
| Magic start/commit | Pawn `PerformDebugStaffAttack` and `CompletePendingStaffCast` retain paid snapshots, completion validation, charged-state consumption and one resource payment before projectile release. |
| Equipment/resources | The requesting pawn's native inventory, exact `ItemId`, weapon model and existing inventory/resource services remain authoritative. UI reads projections; NPC combat callers and shared damage/catalogue consumers do not move. |
| Persistence/travel | All 653 pawn field declarations and 562 method signatures remain. Charge/reload/animation/pending fields, native selectors and record handoffs remain owned by the pawn and native engine. No new saved field, class replacement, state-label change or migration is required. |

This is a bounded organization change, not a measured performance improvement or
a claim of complete multiplayer support. Native comparisons and their coverage
limits are recorded in `assets/validation_551/RESULTS.md`.

### Unarmed Seal input (#363, 5.5.5)

Native User2 now reaches the same equipped-Seal authority through the unarmed
fallback, physical selectors and magical selectors. Its accepted toggle rule is
unchanged: first press starts, releasing keeps channeling, next press stops.
Holding does not recreate the channel or multiply its per-tic cost. Eligibility,
resource exhaustion, cooldown and interruptions stay with the shared pawn rules.
Unarmed Fire/User1/User3/User4 states retain their original indices; User2 is
appended. No saved field or migration is introduced. Input/save evidence and
coverage limits: assets/validation_555/RESULTS.md; author CA363-01 accepted on 2026-10-19.

### Input bindings

| Input | Current function |
| --- | --- |
| Fire | Primary attack of the weapon; cancel Block while attacking. |
| AltFire | Secondary weapon attack; for ranged weapons, alternative Aim. |
| Reload | One request per press: reload ranged weapons or charge the next melee/magical attack. |
| Zoom | Sweeping with greatsword/war axe/halberd; Block with compatible equipment (including giant gauntlets); ADS for ranged weapons. |
| User1 | Interface reserved for racial ability; pending content. |
| User2 | Channel the equipped Seal. |
| User3 | Activate up to three selected captured essences under the #80 shared contract. |
| User4 | Class ability interface; pending content. |
| Use | Native interaction with NPC, stations, doors, lift and El Loco appearance. |
| Tab | Journal/Inventory; Tarot displays the collection from 0t. |

Charging has a 2 s base duration adjusted by speed; the prepared window lasts 3 s. The
next attack doubles damage and cost, and explosions double area (radius × sqrt(2)).
Incompatible pain and changes interrupt charging. The sword uses slashing Fire and
piercing AltFire, so it serves for trees and veins of the tutorial. The special hatchet
removed in 0d is not needed.

V5.5.0 / #309: holding Reload neither restarts its timer nor starts another
charge after the prepared window expires. Release and press again for a new
request. Native button edges are used; requests made while the weapon cannot
accept input are not queued. Repeated empty-magazine Fire requests preserve an
already active reload of that weapon. Switching equipment, immobilization and
the existing interruption rules retain their authority. No new saved latch is
introduced.

## Damage and Anima cost: Type 4 divisor (4.33.0aa)

F(A) = 1 + 2 × A × (A + 1) / 10100. Historical general damage used post-vulnerability damage / F(Dureza).
The 2026-09-28 #52 revision supersedes that damage divisor with the subtractive
maximum-health formula above; this historical divisor table still documents
its original release and the unchanged Anima-cost rule. Magical cost = base cost ×tier modifier × charge / F(Elocuencia).
T2 retains ×1,6 and T3 ×2,5; a prepared charge preserves ×2. The bell and statuette
retain their relative bases, reduced tenfold in 4.37.2 / #68 as specified above.
Player and NPC use the same curve, also for explosions; the entire
rounding of Engine Health is preserved.

| Attribute | Divisor | Remaining percentage |
| --- | --- | --- |
| 0 | 1 | 100% |
| 25 | 1,128713 | 88,5965% |
| 50 | 1,504950 | 66,4474% |
| 100 | 4 | 25% |

The reduction percentage showing debugging is the equivalent 100 × (1 − 1/F), not the
old Type 2 curve. 100 hardness no longer cancels the general damage and Eloquence 100 no
longer allows to launch for free. Higher values continue to use the divisor without an
artificial cap at 100. Dialogue skill retains Type 2. Pain and Lucidity loss retain
their previous formulas, both in player and NPC; the actual damage change may indirectly
affect their entry.

Collisions: exactly max(0, impact percentage × surface − hardness), then contact
vulnerability, armor and maximum health. The acrobatic bonus of the buckler and crushing
rules is also maintained. The general damage divisor is not applied again to the
collision result.

## Heavy-weapon sweep (4.33.0aa)

Zoom executes a 360° sweep with greatsword, axe of war and halberd. Primary range: 80,
76 and 84 MU, respectively, to the surface of the target. Use primary damage from the
tier, Strength, vulnerability and critical by enemy; retains armor, thrust and wear on
the damage caused. It is not an explosion. Search is spatial; each nearby enemy receives
at most one hit. A layout checks walls and floors 3D; allies, residents, players and
resources are excluded. Practice targets are an explicit exception.

3 × the actual primary Air cost is paid once per execution, even without targets. It is
not paid for by enemy. Insufficient air or cooldown prevents attack without consuming
it. Recovery is primary. Keep Zoom does not repeat: release and re-press. An already
prepared charge is consumed and retained ×2 damage/cost, so a charged sweep costs 6
uncharged primary attacks. Giant gauntlets keep Zoom/Block; Rulo continues to count the
side dodge as defense of the greatsword. The sweep does not replace that test.

## Future melee energy contract - design only (#315, 5.5.7)

**Author decision, 2026-10-19:** document the design, defer conversion and retain
current damage. The author selected "Documentar el diseño y aplazar la conversión;
conservar el daño actual". This section specifies the boundary and unresolved
inputs; it does not approve an energy-to-HP rule or implement future combat.

### Current authority and proposed replacement boundary

Current physical attacks choose the authored catalogue base, tier multiplier
(1/1.2/1.5), actor physical power, charge and applicable offensive/health effects.
The existing action commits resources and heat once; hit/critical/anatomy,
shield/armor/Toughness and final rounding retain their current owners. Player
dispatch is `CaelumCombatDispatch`; physical action ownership remains on the
pawn. Resident tools reuse `CaelumWeaponUseRules.PhysicalDamage`; other NPC
authored attacks retain their own existing callers. This contract does not
silently assign a weapon to natural attacks or convert their authored bases.

Body collision under #194 separately computes normal-contact energy using
reduced mass and applies the author's 1 J/HP body-contact rule. That rule does
not specify a blade edge, penetration, cutting, stabbing or a held weapon's
effective inertia. Thermal `WeaponWork` is an action-work budget, not measured
delivered impact energy. Neither existing value is an automatic melee conversion.

The deferred candidate would snapshot an approved action at release, derive
relative normal strike speed and effective mass, estimate kinetic energy
`K = 0.5 * m_eff * v_normal²`, then apply an authored transfer/contact model.
`D_raw = Phi(received energy, contact geometry, material, technique)` remains
undefined until the author supplies its rules and units. Energy alone cannot
establish injury, armor penetration or game balance. A future switch must select
exactly one raw-melee authority for an action: catalogue damage OR the approved
replacement. It must never add the candidate result to the current melee hit.
Distinct actual body collisions keep their accepted owner and event identity;
a visual weapon trace must not manufacture a second body-contact damage event.

### Field, source and unit inventory

| Input | Current source / unit | Deferred model status |
| --- | --- | --- |
| Family, tier, size, primary/secondary | `CaelumWeaponCatalogue`, `CaelumWeaponModel`; identifiers | Existing dispatch data; no new categories approved. |
| Base damage and tier | #309 `assets/validation_550/matrix.json`, catalogue/model; HP and dimensionless 1/1.2/1.5 | Authoritative until replacement approval. Matrix weight 0 is an unequipped model observation, not zero physical mass. |
| Carried weapon mass | `CaelumConstants` + `CaelumEquipmentRules.CalculateTieredEquipmentWeight`; kg | Existing size-M dagger 2/3/4, sword 6/9/12, greatsword 18/27/36 kg. These game masses are not effective strike masses or historical measurements. |
| Body mass and Strength | `CaelumDerivedStats`, `CaelumCombatActor`, `CaelumGrowthRules`; kg, attribute, multiplier | Existing raw physical power; mapping to energy/velocity must avoid multiplying the same benefit twice. |
| Cadence and capacity | `CaelumAttackRules.Duration`; tics, kg | Existing `14 * attributeDurationMultiplier / (1 - (weapon+gloves)/capacity)`; weight at/above capacity blocks. Animation duration does not establish tip speed. |
| Strike speed and trajectory | No physical weapon-tip trajectory/velocity contract; m/s, direction, time | Author must choose per action/technique and attribute/tier effects. Do not substitute pawn travel speed for arm/weapon speed. |
| Effective mass/inertia | No authored held-weapon inertia/arm coupling; kg or kg·m² plus lever arm | Requires grip, technique and body coupling model. Inventory mass is only an input. |
| Contact area/edge | Existing anatomy and hit classification; no edge/contact patch data | Author must define m², edge/tip geometry or a deliberate simpler abstraction. #194 box faces cannot stand in for blade edges. |
| Material and penetration | Existing equipment tiers, armor coverage and damage classifications | No approved material hardness/fracture/penetration thresholds for the candidate. No automatic armor bypass. |
| Air, charge, sweep | Catalogue nominal costs and current actor modifiers; resource points | Existing costs remain. Future work-to-Air conversion, if any, needs authored units and calibration. |
| Action heat | `CaelumThermalData.WeaponWork`, `CaelumThermalEffects.RecordWeaponAction`, `CaelumPhysicsUnits`; J, efficiency | Existing `Q = W*(1/eta-1)`; charge ×2, sweep ×3. It is paid once per performed action, including a miss. No second muscular heat payment from impact delivery. |
| Defenses and wear | Current shared damage/anatomy/armor/Toughness services; HP, regional coverage, durability units | Preserve ordering and one rounding/wear commit unless a separately authored replacement explicitly changes it. |
| Event identity/persistence | Existing pawn/NPC action and inventory ItemId owners | No new state now. Any future ledger/snapshot needs a versioned, idempotent and reversible save migration. |

### Worked comparisons and gameplay implications

These comparisons use existing catalogue data and equations. No strike speed,
effective mass, transfer fraction or physical injury coefficient is invented.
The counterfactual column illustrates the rejected shortcut of treating the
thermal work budget as 1 J/HP; it is not a proposed balance table.

| Primary, size M | Current base HP T1/T2/T3 | Nominal Air | Existing work J (all tiers) | Counterfactual HP T1/T2/T3 |
| --- | --- | ---: | ---: | --- |
| Dagger | 60 / 72 / 90 | 2 | 50 | 50 / 50 / 50 |
| Sword | 120 / 144 / 180 | 5 | 125 | 125 / 125 / 125 |
| Greatsword | 200 / 240 / 300 | 12 | 300 | 300 / 300 / 300 |

For the sword, that shortcut changes base damage by +4.17%, -13.19% and -30.56%
across tiers. Base HP per nominal Air changes from 24/28.8/36 to 25/25/25.
The greatsword gains 50% at T1 but 0% at T3; the dagger loses 16.67% at T1 and
44.44% at T3. These ratios exclude actor modifiers, misses and defenses; final
Air cost remains the existing actor calculation. Thus even a superficially
similar T1 number can erase progression and change weapon efficiency.

For a matched player/NPC calculation, reuse Rulo's authored **200 kg, Strength
20** profile, healthy and with neutral additional offensive multipliers. The
existing legacy Type-1 adapter calls growth family 3:
`P = (200/100) * (1 + 7*(20²+25*20)/(125*100)) = 3.008`.
This is a comparison input copied from `CaelumRulo`, not a new player default.
The shared player/resident-tool raw result before target defenses and rounding is:

| Primary | T1 raw HP | T2 raw HP | T3 raw HP |
| --- | ---: | ---: | ---: |
| Dagger | 180.480 | 216.576 | 270.720 |
| Sword | 360.960 | 433.152 | 541.440 |
| Greatsword | 601.600 | 721.920 | 902.400 |

Existing native evidence provides an actual NPC cross-check: Rulo's T1 War Axe
base 220 gives 661.76 raw HP, rounded to **662**, and charged 1323.52, rounded
to **1324** (`assets/validation_5212/tools.zs`, RESULTS). That old fixture forced
extreme Dexterity to secure its hit; it is evidence of raw damage, not ordinary
accuracy, timing or a newly executed test. The authored War Axe work budget is
350 J normal / 700 J charged. Work therefore cannot simply replace either raw
result. A matched player uses the same raw multiplication; final delivery and
rounding retain the actual player/NPC paths rather than assuming full parity.

At unchanged speed, using full carried mass as effective mass would make T3
kinetic energy twice T1 (mass ×2), while current damage rises only ×1.5.
Matching that damage ratio under a linear energy candidate would require a
T3/T1 speed ratio `sqrt(1.5/2) = 0.866025...`, or another explicitly authored
effective-mass/transfer rule. This is a derived ratio, not an approved speed.
Conversely, a fixed work budget with full mass gives lower speed at higher
tiers but the same energy. Neither shortcut reproduces the current progression.

A charged greatsword sweep currently pays **72 nominal Air** (12×3×2) and
records **1,800 J** of action work (300×3×2), once per sweep. It can hit each
eligible target once with charged primary damage. The future model must decide
whether impact energy is a per-target gameplay severity or a finite budget
shared among targets. Assigning the full budget repeatedly and also claiming
physical conservation would be contradictory. Current sweep targeting and costs
remain unchanged while that decision is deferred.

### Required integration and approval gate

Retain current hit eligibility, friendly/resource exclusions, spatial queries,
line-of-sight, armor location, shield applicability, critical metadata and
Toughness order. A candidate must declare where penetration changes a regional
defense, then apply that change once; it cannot bypass shields or apply general
and collision Toughness paths together. Wear uses the existing committed damage
and pre-wear defenses until the author approves another basis. Preserve natural
NPC attacks, tools, charge interruptions and actor-specific behavior; parity
means shared approved physical inputs/rules, not forced identical AI.

Muscular action work and recipient impact heating are different ledgers. Keep
the current action heat once per release, and route any approved impact heat
through the existing receiver authority without charging the attacker again.
Do not derive extra Air from heat or count visual animation callbacks as new
hits. Cosmetic animation and render rate must not own simulation energy.

Before any production conversion, a follow-up must record: action speed and
effective mass/inertia; contact/material/penetration parameters; the HP mapping
and tier/attribute targets; charge/sweep allocation; Air/cadence and heat
calibration; defense/wear ordering; natural attacks and player/NPC scope. The
author must approve both the model and its numbers. Begin with a private
comparison against the accepted catalogue, including misses, blocked attacks,
multiple targets, offscreen NPCs, resources and repeated callbacks. Native
active-attack/charge/sweep saves, old-save upgrade, rollback and hub return must
precede any migration release. Measure simulation and presentation tails at
approved populations. No retired 6,000-attacker scene is authorized.

**Status:** design contract recorded; conversion explicitly deferred. All
physical calibration fields above remain unresolved. Current damage, resources,
durability, controls and saves are unchanged by #315. There is no executable
author test for an unimplemented model and no such entry in pending_test.txt.

## Detailed matrix of weapons

Technical matrix of preserved inputs; the visual enlargement of first person does not
modify these combat routes.

### Physical melee weapons

| Weapon | Fire | AltFire | Reload | Zoom |
| --- | --- | --- | --- | --- |
| Dagger | Piercing primary stab. | Stronger slashing attack with shorter range. | Charge next melee attack. | Shield Block. |
| Hatchet | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Shield Block. |
| Machete | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Shield Block. |
| Javelin | Piercing melee thrust. | Throws the javelin; if a valid melee target is close, automatically uses the melee fallback. A real throw costs Air and one durability. | Charge next melee attack. | Shield Block. |
| Sword | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Shield Block. |
| Axe | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Shield Block. |
| Flail | Blunt primary attack. | Stronger blunt attack at the same range. | Charge next melee attack. | Shield Block. |
| Spear | Piercing primary thrust. | No authored secondary attack in the current catalogue. | Charge next melee attack. | Shield Block. |
| Greatsword | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Sweep 360°: damage, scope and recovery of the primary; triple Air. |
| War Axe | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Sweep 360°: damage, scope and recovery of the primary; triple Air. |
| Halberd | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Sweep 360°: damage, scope and recovery of the primary; triple Air. |
| Giant Gauntlets | Blunt primary punch. | Blunt uppercut: same damage, range and Air cost as Fire, with additional upward push. | Charge next melee attack. | Weapon-based Block using Buckler coverage, defense and special rules. |
| Pickaxe (one tier) | Axe-statistics slashing attack. | Axe-statistics attack with piercing classification. | Charge next melee attack. | Shield Block. |

### Ranged weapons

| Weapon | Fire | AltFire | Reload | Zoom |
| --- | --- | --- | --- | --- |
| Double-barrel shotgun | Fires twelve pellets using one cartridge. | Toggles Aim/ADS. | Loads up to two cartridges with the shared carbine reload pipeline. | Toggles the same Aim/ADS mode, real FOV and doubled physical accuracy. |
| Longbow | Fires its native longbow arrow. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |
| Crossbow | Fires its native bolt. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |
| Carbine | Fires its native carbine projectile. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |

### Ammunition composition and mass contract (#313, 2026-10-19)

The author first requested historical references, then explicitly accepted the
following **design approximations**, because exact complete-cartridge/component
weights were not established. They are not claimed as measured historical data.
The old 3 g value described a complete inventory unit, not a documented bullet
payload, and shotgun cartridges inherited it. The authoritative runtime values
are now CARBINE_AMMO_UNIT_WEIGHT=0.040 kg and SHOTGUN_AMMO_UNIT_WEIGHT=0.045 kg.

| Ammunition / stable ID | Complete inventory unit | Composition contract and status |
| --- | ---: | --- |
| Carbine / 0 | 40 g | Argentine Remington 1879 reference; projectile, metallic case, finished propellant and primer components. Exact alloys, constituent masses and proportions remain unassigned. |
| Shotgun / 6 | 45 g | Late-nineteenth-century paper 12-bore cartridge reference, selected by the author; shot payload, paper-bodied case with metal base, finished propellant and primer components. Wads/closures belong to the prepared case assembly. Exact constituent masses/proportions remain unassigned. |
| Longbow arrow / 1 | 50 g, unchanged | Existing arrow/component recipe remains authoritative. |
| Crossbow bolt / 2 | 50 g, unchanged | Existing bolt/component recipe remains authoritative. |

One shotgun inventory unit still creates twelve gameplay pellets; it does not
weigh twelve cartridges. No 45/12-g ballistic pellet mass is inferred: case,
propellant and primer are not the flying payload, and its exact mass is pending.
No native Actor.Mass, prepared damage, range, spread, velocity or gravity changes.
Carbine/shotgun armor bypass remains 70/80/90% and 60/70/80%; longbow/crossbow
20/30/40% and 40/50/60%. These four families retain the #192 ideology exclusion,
armor-only bypass, shield behavior, innate defense and Toughness ordering.
There is no new ricochet, penetration-through-world, breakage, heat or material
coefficient. Existing wood/metal gate damage and other accepted interactions remain.

V5.6 assembly starts with finished projectile/shot, prepared case, propellant and
primer components. This is a game data contract, not a real manufacturing recipe.
No recipe is activated here. Component quantities and masses must add to the
approved complete unit before recipes are implemented; do not invent a remainder
allocation, metal proportions or powder formula. Recipe IDs, batches, learning,
efficiency/losses, time, stations, prices and sources stay with V5.6/V5.7 and require
authored data. No new gatherable resource or merchant stock is introduced.

The inventory stack already includes loaded rounds; reloading only changes the
magazine counter. Count mass once; firing consumes one unit (40/45 g). The existing
ability to fire a loaded magazine after moving its stack is retained; this patch
does not introduce separate physical magazine storage. NPC infinite reserves
remain nonphysical. Personal/Box summaries, first-stack capacity admission,
existing-stack pickup, selection previews and world drops share the same values.
Old saves retain classes, IDs, amounts, locations and in-flight projectile state;
normal load refresh applies the new mass. No serialized field or schema is added.
Retain original save/runtime pairs for rollback. Heavier ammunition may increase
existing encumbrance penalties without removing items.

Historical context: W. W. Greener, *The Gun and Its Development* (1897), Cornell
copy [Internet Archive](https://archive.org/details/cu31924097286177), discusses
period cartridge construction and twelve-bore shotguns; it does not establish
our complete-unit 40/45-g values. The [.43 Spanish overview](https://en.wikipedia.org/wiki/.43_Spanish)
identifies the Argentine Modelo 1879 family and distinguishes later variants;
its projectile mass is not the full cartridge mass. The [CONICET record for
Landa's 2006 thesis](https://bicyt.conicet.gov.ar/fichas/produccion/9046341) confirms
bibliographic identity only. An earlier secondary-copy 40-g lead was not verified
and is not evidence for the chosen mass. The author decision above is authoritative.

### Utility tools

| Implement (family 1) | Fire | AltFire | Reload | Zoom |
| --- | --- | --- | --- | --- |
| Utility staff / Bastón, one tier | Hold for flame, burn and heat. | Hold for ice, Freeze and cooling. | No charge or reload. | Shield Block; interrupts emission. |
| Bolas, one tier | Throw the exact equipped item; consume Air once. | Hold to prepare the throw and reduce dispersion. | No weapon charge/reload; the separate restraint-cutting action retains its rules. | Contextual shield Block; preparing/throwing retains its own guards. |

Both staff modes use the continuous cost/contact-wear contract in the 5.1.15
section. Bolas use the #163 preparation/restraint contract and binary integrity.

### Magical implements

Every magical variant below exists at T1, T2 and T3 for Fire/Light, Water/Ice,
Earth/Poison, Air/Lightning and Quintessence. `Fire` selects the primary side of the
equipped essence and `AltFire` selects its secondary side.

| Implement | Fire and AltFire delivery | Reload | Zoom |
| --- | --- | --- | --- |
| Wand | One normal-speed direct magical projectile. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Bell | Twelve slow projectiles in a broad cone; every projectile rolls its own critical. Uses the confirmed half-damage/double-Anima baseline; cost is paid once per cast. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Book | One fast homing magical projectile. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Statuette | One explosive magical projectile; charged attacks double explosion area. | Charge next magical attack. | Shield Block when a shield is equipped. |

### Essence function used by every magical implement

| Essence | Fire | AltFire |
| --- | --- | --- |
| Fire / Light | Fire damage with Burn damage-over-time. | Light effect with Dazzle control and player illumination. |
| Water / Ice | Water projectile with extreme physical push. | Ice effect with Freeze control. |
| Earth / Poison | Earth effect that reduces target Lucidity. | Poison damage-over-time. |
| Air / Lightning | Air effect with Cut damage-over-time and moderate push. | Lightning Stun control. |
| Quintessence | Double-damage primary projectile. | Independently rolls the available Fire, Light, Water, Earth, Poison, Air and Lightning secondary effects. |

### Complete magical variant list

The following twenty implement/essence combinations each have T1, T2 and T3 selectors,
totaling sixty magical weapons:

| Essence | Wand | Bell | Book | Statuette |
| --- | --- | --- | --- | --- |
| Fire / Light | Fire Wand T1–T3 | Fire Bell T1–T3 | Fire Book T1–T3 | Fire Statuette T1–T3 |
| Water / Ice | Water Wand T1–T3 | Water Bell T1–T3 | Water Book T1–T3 | Water Statuette T1–T3 |
| Earth / Poison | Earth Wand T1–T3 | Earth Bell T1–T3 | Earth Book T1–T3 | Earth Statuette T1–T3 |
| Air / Lightning | Air Wand T1–T3 | Air Bell T1–T3 | Air Book T1–T3 | Air Statuette T1–T3 |
| Quintessence | Quintessence Wand T1–T3 | Quintessence Bell T1–T3 | Quintessence Book T1–T3 | Quintessence Statuette T1–T3 |

### V5.5.0 audit ownership and evidence (#309)

The catalogue contains 111 supported configurations: 48 tiered physical weapons,
three single-tier tools and 60 magical variants. Each has four recorded input
routes (444 entries); an undefined spear secondary and intentional tool Reload
no-ops are explicit, not unfinished attacks. The Bell row above reconciles the
old seven-projectile text with the later accepted twelve-projectile #192 rule.

`CaelumPlayableWeapons` owns native selector/state entry. The player's family
adapters select the exact equipped item, then dispatch through
`PerformEquippedWeaponPrimaryAttack`, `PerformEquippedWeaponSecondaryAttack`,
`RequestWeaponReloadOrCharge` and contextual Zoom. Physical preparation/release
uses `CaelumAttackRules` and `CaelumWeaponUseRules`; values come from
`CaelumWeaponCatalogue`/`CaelumWeaponModel`. Ranged magazine/ammo/penetration and
pellets remain in `CaelumRangedRules`/`CaelumShotgunRules`. Magic casts retain
their captured item identity, essence, critical and charged state; Bell and
Statuette cost is per cast, not per projectile or victim. Utility staff and
bolas retain their separate continuous/preparation controllers.

Cooldown and attack duration use the existing attribute/weight formulas, not
the selector's one-tic polling interval. Damage-based melee wear is charged to
the captured actual item; a javelin throw costs one durability, bolas transfer
their physical item, and continuous staff contact retains #162 wear. No NPC
gains an attack or equipment from this audit. Resident tools share catalogue
classification; accepted demon profiles/direct projectile aiming remain.

The generated audit matrix and source/evidence mapping live in
`assets/validation_550`; native metadata checks are distinguished from actual
input tests and reused accepted #192/#195/#259/#284 evidence. The only new
production changes are Reload button-edge filtering, idempotent active ranged
reload and the uppercut's corrected blunt classification. User2 on the unarmed
selector is independently tracked in #363, outside this four-input audit.

## Economy

Current values, kept from the accepted base V4.32.0a-r4.

### 1. Monetary unit

The accounting unit is the **monetary copper**. All internal economic amounts are
first expressed in copper equivalents. A silver monetary unit is equivalent to 200
coppers and a gold monetary unit is equivalent to 200 silvers, i.e. 40.000 coppers.

Each metal has coin denominations of 1, 5, 20, 50 and 100:

| Metal | Denomination | Copper value | Weight per coin |
| --- | ---: | ---: | ---: |
| Copper | 1 | 1 | 0,001 kg |
| Copper | 5 | 5 | 0,001 kg |
| Copper | 20 | 20 | 0,001 kg |
| Copper | 50 | 50 | 0,001 kg |
| Copper | 100 | 100 | 0,001 kg |
| Silver | 1 | 200 | 0,001 kg |
| Silver | 5 | 1.000 | 0,001 kg |
| Silver | 20 | 4.000 | 0,001 kg |
| Silver | 50 | 10.000 | 0,001 kg |
| Silver | 100 | 20.000 | 0,001 kg |
| Gold | 1 | 40.000 | 0,001 kg |
| Gold | 5 | 200.000 | 0,001 kg |
| Gold | 20 | 800.000 | 0,001 kg |
| Gold | 50 | 2.000.000 | 0,001 kg |
| Gold | 100 | 4.000.000 | 0,001 kg |

Coins are stackable physical objects of `Actor.Inv`. They persist in saves and travels,
can be collected and released, and obey the same carrying-capacity and Magic Box rules
as all other objects. The Journal's total visible sum up all the coins possessed,
including those stored in the Magic Box. Those that are outside contribute their full
weight; those saved enter the total actual weight that the Box divides by its maximum slots and truncates to 0,001 kg.

They are currency with a nominal value: the player cannot melt or mint them and their face
value is not derived from the value of the silver or gold used as materials.

Native classes:

- Copper: `CaelumCopperCoin`, `CaelumCopperCoin5`, `CaelumCopperCoin20`,
  `CaelumCopperCoin50`, `CaelumCopperCoin100`.
- Silver: `CaelumSilverCoin`, `CaelumSilverCoin5`, `CaelumSilverCoin20`,
  `CaelumSilverCoin50`, `CaelumSilverCoin100`.
- Gold: `CaelumGoldCoin`, `CaelumGoldCoin5`, `CaelumGoldCoin20`, `CaelumGoldCoin50`,
  `CaelumGoldCoin100`.

### 2. Base values of raw materials and consumables

The following prices are authorized design anchors. The hardness and abundance accepted
in V4.31 continue to determine how much it costs to obtain a resource in time and
effort, but no longer automatically recalculate its monetary value.

| Raw material | Coppers per unit of 0,001 kg |
| --- | ---: |
| Common timber | 2 |
| Plant fiber | 3 |
| Cowhide | 3 |
| Mineral coal | 5 |
| Raw copper | 5 |
| Raw tin | 5 |
| Raw iron | 7 |
| Raw silver | 100 |
| Raw opal | 500 |
| Raw topaz | 500 |
| Raw emerald | 500 |
| Raw sapphire | 500 |
| Raw ruby | 500 |
| Raw gold | 1.000 |

Wool, cotton, raw silk, predator hide and monster hide retain their previous temporary
anchors for the time being:

| Family | Grade 1 | Grade 2 | Grade 3 |
| --- | ---: | ---: | ---: |
| Fiber: wool/cotton/raw silk | 2 | 4 | 8 |
| Hide: cow / predator / monster | 3 | 4 | 8 |

Changing those outstanding values will require an explicit design decision; the
abundance of the source will not overwrite them alone.

The following values correspond to a complete consumable item, not to a
gram of content:

| Consumable | Base value in copper |
| --- | ---: |
| Food ration | 4 |
| Water ration | 6 |

### 3. Recursive value of manufacture

The system calculates the value with the actual recipes and always takes as reference
the **material efficiency of 100 %**. The playable efficiencies of 25/50/100 % and its
times 1×/10×/100× remain intact; the material loss resulting from the player’s chosen efficiency does not redefine the
base price of the object.

#### 3.1 Basic processing

For ingots, alloys, fabric, string and leather:

```text
valor unitario de salida =
    suma(valor unitario de cada insumo × unidades requeridas)
    × 1,25
    / unidades de salida al 100 %
```

The surcharge for this stage is always **25 %**.

#### 3.2 Components

Each component takes the value of the material **already processed** it consumes, not
its original raw material. It then applies the surcharge corresponding to the network of
stations in its tier:

| Tier | Cumulative infrastructure | Added value |
| --- | --- | ---: |
| T1 | Workbench + main station | 25 % |
| T2 | Network T1 + specialized station | 50 % |
| T3 | T2 network + Master Workbench | 100 % |

Shields retain their additional anvil requirement; it does not change the tier or double
the surcharge.

#### 3.3 Final items

Physical weapons, essence weapons, armor, shields, amulets and seals add up to the
value of their already manufactured components, including the details of silver and gold
in the recipe. On this sum, the T1/T2/T3 surcharge in the table above applies again.
Therefore, each stage retains its own labor and the value accumulates recursively.

`CaelumEconomyRules` exposes the calculation by material, by object family and by native
inventory instance. Food and water rations already have authorized base value.
The older blanket ammunition/key exclusion is superseded by the functional port
city contract and #383: approved ammunition, eleven provision products, sealed
cartridge kits, matched locks/keys, lock tools, clothing and recipe offers have
explicit values and vendor eligibility. Other key/quest objects remain excluded;
absence of an approved value never authorizes inventing a price. Products without
a manufacturing recipe retain initial stock but await #385's renewal rules.

### 4. Trader Margins

The margin applies only once to the total lot:

```text
NPC compra al jugador = piso(valor base total × 0,50)
NPC vende al jugador  = techo(valor base total × 1,50)
```

The floor when paying and the ceiling when charging avoid creating copper by rounding.
Applying the margin after adding the lot allows, for example, that two units with base value 1 sell together for 1 copper even though a single unit produces an unrepresentable fraction.

Authoritative methods are:

- `CaelumEconomyRules.GetPricePaidByMerchant`
- `CaelumEconomyRules.GetPriceChargedByMerchant`

These are the normal margins of the commercial infrastructure. The subsequent discount test
retains the player's purchase to 140% and sale to 60%; it is not available from Palomo
canonical MAP01. 0an enables it to be activated by a reputational condition in services
that declare it, without making it permanent. Narrative assignments, personalities and
definitive regional prices remain pending.

### 5. Presentation in inventory

The Journal incorporates a coin filter and, together with **Load** and **MagicBox**,
shows:

- total value expressed in coppers;
- total physical number of copper coins, adding their five denominations;
- total physical quantity of silver coins, adding their five denominations;
- total physical number of gold coins, adding up their five denominations.

The Magic Box line also shows your used/maximum slots and their total weight: 0.001 kg
own plus the reduced contribution of all content. The formula, restrictions and cases of
change of Intelligence are documented in `SYSTEMS.md`.

The three RGBA 64×64 icons supplied for Caelum Argenteum are preserved unredrawn in
`graphics/caelum/icons/currency/`. The five denominations of the same metal share image
and are distinguished by their localized name and face value. Copies registered as
`CCOP`, `CSIL` and `CGOL` also allow each coin to exist as a visible pickup in the
world.

### 6. Prisoner coin reward

[IMPLEMENTED, AUTHOR ACCEPTANCE PENDING] Issue #14, 4.36.8. The
latest author decision, explicitly referenced by #10 and verified against #14,
supersedes the former average-weapon-price formula reconciled in #22.

Each successfully rescued prisoner grants **25 gold coins plus +10 reputation
with that prisoner's own faction**, once per entitled character at the port.
The payout is independent of size, weapon tier, prices, margins or discounts.
Use the existing physical currency helpers and denomination rules: 40,000
copper per gold, hence 1,000,000 copper per rescue; four rescues total 100 gold.
Preserve independent claims across saves/travel. Failed coin delivery remains
retryable without duplicate money or reputation. Keep one shared reward
definition; do not implement a price-averaging table for this reward.

The superseded 4.36.1b reference-set/price formula is preserved in HISTORY.
This documentation correction does not implement escort or reward gameplay.

### 1. Nature and Own Weight

The Magic Box has an Inventory instance with owner and ItemId from 0s; its content and
weight remain centralized in the character. It does not add a selectable entry to the
list: it cannot be dropped, sold, destroyed or stored within itself. Before receiving
it does not add weight, it does not offer slots and no pickup, crafting or interface
path can save objects in it. Upon receiving it, its structure contributes **0.001 kg (1 gram)**
to the load even when it is empty.

The maximum number of slots continues to derive from Intelligence. Each individual piece
of equipment and each supported stack occupies one slot, no matter how many units the
stack contains.

### 2. Weight reduction

The content does not lose all its weight. The load is calculated with a single aggregate operation:

```text
peso reducido del contenido =
    piso_a_0,001 kg(peso real total guardado / slots máximos actuales)

peso total de la Caja Mágica =
    0.001 kg + peso reducido del contenido
```

The maximum **slots** are used, not the occupied ones. The weight of all items and stacks is summed
before dividing and rounding. This prevents separating the same weight between multiple
stacks from removing load by individual roundings.

Example: at Intelligence 0, 30 maximum slots and 10 kg stored, the content
contributes 0.333 kg and the complete Box weighs 0.334 kg. At Intelligence 100,
100 slots reduce the same contents to 0.100 kg, for 0.101 kg total.

### 3. Content and restrictions

Existing rules are preserved:

- equipment, consumables, materials, coins, key items admitted and custom ammunition stacks
  can be stored;
- common keys cannot be saved because GZDoom checks their native possession for doors and
  `LOCKDEFS`;
- Native arrows and bolts remain in the personal inventory;
- a complete stack still counts as a single slot, but all its units contribute to the
  actual weight prior to reduction;
- the stored coins retain their full value and share the reduced weight as any other stack.

### 4. Transactions and capacity changes

Collecting, depositing, recovering, equipping, crafting and disassembling evaluate the
complete final load. An operation is rejected if, after removing the weight from its
previous location and adding it to the new one, the load would exceed the character’s
capacity. Moving an item from personal inventory to the box continues to be allowed when
releasing load.

If an Intelligence change reduces maximum slots below the already occupied ones, the
content is retained: it is not removed or expelled. The divisor and load are
recalculated immediately, and new deposits are blocked until occupancy is back within the maximum. Recovering or releasing content remains the way to free slots.

### 5. Interface

The Inventory shows `slots usados/máximos` and the current total weight of the box,
including its own 0.001 kg. The general Load line incorporates exactly the same value.
The selected item’s weight continues to show the actual weight of the object or
stack before reduction. The 64×64 icon provided is displayed next to this line; before
the gift it is dimmed with the `No adquirida` text. Trying to store from Inventory
before the gift returns an explicit cause and does not change the object.

### 6. Acquisition and save compatibility

- A new profile is explicitly marked as a non-owner.
- The first canonical encounter with Palomo does not grant the Box or open commerce.
- Accepting Palomo’s offer, after closing the four branches in phase 75, advances to
  `MAIN_M00_STATE_BOX_RECEIVED`. Questions and closing the conversation deliver nothing.
- The gift adds its 0.001 kg and enables slots once by `MAIN_M00_FLAG_MAGIC_BOX_GRANTED`; an
  inherited Box recalculates its weight under the same current rule.
- `CaelumPersistentCharacterState` is the persistent source of ownership. It is saved to
  `PreTravelled` and restored to `Travelled`; the live field and technical marker are
  synchronized from that record.
- Ownership is independent of the physical location of Palomo.
- Confirmed profiles created before V4.32.0b retain the Box during migration. This avoids
  losing access to content that was already saved.
- A malformed intermediate save that does not have the reward but contains `InMagicBox` flags is repaired by moving those stacks to the personal inventory; no objects are removed.

### 7. Integration with Mission Log

`GrantMagicBoxFromPalomo()` does not alter the mission record on its own. In 0s,
AcceptMagicBox validates the conversation and RecordMainM00MagicBoxGranted confirms
phase/flag after checking property and identity. The canonical mission **Where the lost
awaken** begins on awakening and its first objective is to seek help. Owning a Box from
an earlier game does not skip the Voice, the presentation of Palomo or the orientation
to Argento.

When migrating V4.33.0a, only the discarded commercial quest is restarted. The existing
Box is not duplicated or removed, and retains exactly content, slots, weight and
reduction. This allows testing the new prologue without destroying development inventory
and keeps new characters in canonical progression without Box.

Palomo remains hidden before the Voice and is revealed in the hall. From 0n it visibly
travels the stairs after the initial dialogue; it is retained that same instance above.
The Journal solver indicates it on the second floor from phase 75. In 0s he can speak
there: he guides the player if trials remain incomplete, offers the Box once they are
complete, and helps the player use it after receipt.

The test of the mission is to use the final door after capturing El Loco and confirming
the crossing. `changemap MAP02` tests development journey, but omits narrative
transaction. `map MAP02` starts another character without Box and does not prove that
persistence. `map CADEV02` is used for independent actor testing.

## Native dialogues and audio

From 0b the conversations keep the simulation active. MAPINFO declares
UnFreezeSinglePlayerConversations and the common menu omits the delayed pause of
ConversationMenu.Ticker, also when loading previous snapshots.

`GameInfo.AddDialogues` load CAPALOMO; Thing_SetConversation and StartConversation open
native menus. Q equals Back; Escape and controller buttons retain their engine controls.
Prologue Voice retains its only exit option, Continue. In sewers, Look around opens the final
help and Continue allows closing. Probabilities appear before choosing; Ronnie
requirement remains visible and gray when blocked. Rulo emotion is private information.

The first phrase of Simple Harp Loop (2,571429 s, with 450 ms drop) is the
`GameInfo.ChatSound` of the project. GZDoom emits a single local signal when opening a
conversation and when displaying each next page: Voice, Palomo, Argento, Rulo, Ronnie
and Caella. There is no other manual call when opening. A blocked option does not go
over the page and does not produce another signal. Cursor navigation does not amount to
advancing the text. The singular mark lets the current phrase finish if it is advanced
very quickly; it avoids accumulating overlapping chords. ChatSound is also the native
notification of the engine chat; its local reach and authority are not modified. See
ASSETS.md for source and editing.

The title screen plays once the 6 s War Drums. CaelumMenuAudio requests unlooped
playback when entering; does not change volumes, map music, or personal lists. Pause
menus retain the music of the game. When choosing Exit/Salir in the main menu,
CaelumExitMenu opens native confirmation and plays menu_strings_start while the audio is
still active. Cancel returns to the parent menu. QuitSound and the Exit button of the
map retain the same resource; the singular mark avoids overlapping two instances of
strings.
