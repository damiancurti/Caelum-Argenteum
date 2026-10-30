# Caelum Argenteum — Project, status and roadmap

Documentation version: **5.11.8** - 2026-10-30.

## 5.11.8 - Mandinga and Zupay disease immunity (#586)

The author extends the rat damage rule to these two species. No exposure,
ordinary combat or save-data changes. Native policy and save verification
passed (26 upgrade,6 reload,3 original-save rollback assertions). The author
accepted CA586-01 and the remaining CA430-01 load comparison on 2026-10-30,
confirming all V5.11 checks and authorizing integration and closure. HISTORY
records acceptance by originating release; pending_test.txt is empty.

Author clarification: the comparison is Leonor versus Caella. Caella carries
22.0184kg (armor plus pickaxe, utility staff and bolas); Leonor carries5kg.
Native mansion speeds are6.26658 versus7.93925m/s respectively, a26.69%
difference explained by the approved load penalty. Their base profile matches;
no duplicated motion was found. Seven focused native assertions pass.

Companion speed review (#430): equal-condition native displacement confirms
the existing mass-dependent acceleration, without duplicate movement. Twelve
comparison and four reload assertions pass; no balance adjustment is applied.

## 5.11.7 - Household placement correction (#581)

The four outdoor arrival workshop/rest objects move into the protagonist central house, retaining native instances and batches without changing map geometry. Target-room fit, travel, duplication prevention and save checks passed; the author accepted CA581-01 on2026-10-30. #580/PR583 and #582/PR584 remain focused companion corrections.

## 5.11.6 - Rat disease correction (#582)

Species-specific immunity prevents contamination damage to rats without changing exposure or other combat rules. Native verification passed; the author accepted CA582-01 on2026-10-30. #580 has PR583; #429/#430 movement and #581 placement remain separate corrections.

## 5.11.5 - Rental dialogue refresh (#580)

Returning to the rental agent re-evaluates current guard recognition instead of reusing stale native dialogue. This is a correction to accepted #422; no narrative, ownership or reward calibration changes. CA580-01 was accepted2026-10-30.

Earlier V5.11 review2026-10-30 accepted the other tests with explicit exceptions
for companion motion, corridor formation, rental progression, household
placement and rat contamination damage. Those exceptions are now accepted;
#580-582 retain the unrelated corrections as focused patches.
Companion navigation reuses authored stair nodes and bounded local collision.

## V5.11 implementation - 5.11.4 (#430, 2026-10-30)

#429 formations, #431 profiling and #432 derived caches have PRs576/575/577.
#433/PR578 records the conditional distant-search evaluation without adoption.
#430 completes the authored companion roster, native equipment administration,
private trust/consent, following/waiting, cross-map ownership, persistent death
and the existing paid revival ability. Full-package and accepted-save checks
pass. All final author checks are accepted on 2026-10-30 and integration is
authorized through PRs #575-579, #583-585 and #587-588, with commit ancestry
preserved. V5.11 is complete at 5.11.8; the conditional distant-search candidate
is not adopted and the measured siege presentation limits remain explicit.

## V5.10 complete and author-accepted - 5.10.3 (2026-10-30, #403)

Vision (#425), anonymous action noise (#426), private memory/search (#427)
and audible reports/leader orders (#428) are integrated through focused PRs
#570-573. All four issues are closed; branch-tip ancestry is preserved.
Native evidence is in validation_5100-5103; approved data are in SYSTEMS.
Full-package communication/save/migration/rollback: 53 PASS; combined #425-427
regression: 91 PASS. Representative campaign measurements are complete, with
the large siege's existing stalls and modest additional cost explicitly retained
as limitations, not a 60-FPS claim. See HISTORY and validation_5103/summary.json.
The author confirmed all final tests and explicitly requested integration and
closure. CA425-01..CA428-01 are recorded under their originating releases in
HISTORY; pending_test.txt is empty. This acceptance record changes no runtime,
assets or balance and does not increase 5.10.3. The existing V5.11 roadmap is
next; its implementation is outside this acceptance-only request.

## V5.9 completion - 5.9.7 (2026-10-30, #403)

The author confirmed all numbered manual tests and requested integration and
closure. Issues #418-424 are complete and closed; focused PRs #561-568 are merged
into main with their original commit ancestry. The integrated tree matches the
accepted 2d20943ec delivery before this documentation-only acceptance update.
CA418-01 through CA424-01 retain their original versions and confirmation date
in HISTORY. pending_test.txt is empty. Evidence remains in validation_590-597.
No gameplay or art changes accompany acceptance; existing measurement limits
remain in force. Next: the existing V5.10 roadmap. Earlier delivery checkpoints
below are historical and do not reopen completed V5.8/V5.9 work.

## V5.8 completion - 2026-10-29 (#403)

V5.8 is complete at **5.8.56**. The author confirmed every remaining correction
test and explicitly authorized integration and issue closure. Issues #410-417,
#496 and #502 are completed; their focused commits and PR ancestry are retained
in main. Stable acceptance IDs, original versions and dates are recorded in
HISTORY; the tracked pending_test.txt is empty.

Cooperative rest authority, shared-clock integration and multi-client verification
remain deferred by the author to V5.12 (#435-437). They are not claimed as tested
or delivered by this single-player release. The documented long-absence loading
cost and unavailable ETW presentation measurements remain limitations; author
acceptance of the corrected city slowdown is not a claim of 60 displayed FPS.

Earlier delivery checkpoints below are historical. Their pending statements are
superseded by this completion record and the per-test confirmations in HISTORY.
Next implementation follows the existing V5.9 roadmap; no new scope is opened
by this release consolidation.

Author acceptance 2026-10-29 / #416: all remaining correction checks passed; stable IDs and original releases are recorded in HISTORY. Merge and issue closure are authorized.

Author acceptance 2026-10-29 / #415: all remaining correction checks passed; stable IDs and original releases are recorded in HISTORY. Merge and issue closure are authorized.

Author acceptance 2026-10-29 / #410: all remaining correction checks passed; stable IDs and original releases are recorded in HISTORY. Merge and issue closure are authorized.

## 5.8.56 / #416 - Original Ciudad theme for Buenos Aires

The author selected the original **Ciudad**, retained since the first music collection, for CABAIRES. The complete 188.8-second stereo master is encoded as `music/CA_MUS_CIUDAD.ogg` with Vorbis quality 6, no filters, trimming or normalization. Two encodes produced identical bytes and full decode preserved duration. Credits retain Damián Curti/Suno and the original embedded ID. `Campo de Buenos Aires` retains its countryside assignment. See `assets/validation_5856/PROVENANCE.json`; native playback and author listening are tracked separately.


## 5.8.55 / #415 - Remove repeated global Rally lookups

Rally damage queries now inspect active player inventories; recovery pulses use local blockmap recipients and the existing unlinked-guard registry. Combat/illness rules and the shared population census are unchanged. Native effect/save tests passed; city render callbacks improved from 1125.93ms to 28.34ms mean in the final comparison window. ETW capture was denied; 60 displayed FPS is not claimed. Author corroboration passed on 2026-10-29. Evidence: `assets/validation_5855/RESULTS.md`.


Current review: author passed the grouped5.8.53 checks except bed appearance, the missing statue in the decoration fixture, city rendering fluency and Buenos Aires music; requested water-use shortcut and large paintings. #410 corrections are5.8.54; #415/#416 follow separately. Multiplayer rest remains deferred to5.12.

## 5.8.53 / #417 - Final V5.8 implementation handoff - 2026-10-29

Saved interval rolls, actual-weather holds and two-hour crew repairs are connected
to paid travel. Rural ambushes preserve three real human combatants, their T1 gear,
twenty actual carbine rounds, wear, contamination and remaining loot. Flee/revisit
does not reroll or duplicate them. Surviving thieves can access actual rural camp
containers through #415; native away/return tests preserve the stolen stack,
discover the loss and recover it from the dead thief.

Earlier checkpoint pending notes below are superseded by this delivery and the
5.8.51/52 entries. Implementation of #410-417 and #502 is ready for the grouped
author checks retained in pending_test.txt. Accepted checks are not reopened;
multiplayer rest verification stays in V5.12. No issue is closed or PR merged on
the basis of agent-only tests. Long-absence loading remains the documented
performance limitation; individual simulation and resources are preserved.

## 5.8.52 / #416 - Network implementation ready - 2026-10-29

The four vehicle types, documented/estimated route catalogue, six-block Buenos
Aires, native services, paid travel and persistent stops are complete. Earlier
checkpoint notes below are historical and superseded. Existing map geometry
remains compatible; newly added destinations have their own maps. The final #415
bounded arrival work is integrated without modifying #416 route or fare data.
Native trip, resource, service, arrival and save evidence remains under
assets/validation_5852. #417 incidents and final grouped author corroboration
are separate; multiplayer remains deferred to V5.12 as requested.

## 5.8.51 / #415 - Unloaded calendar resolution

The approved absent siege and explicit-theft infrastructure is implemented:
simultaneous mean-damage rounds, native resources/ownership, scheduled admission,
physical access proofs, chronological theft and return discovery. Existing
unlimited defender/cannon ammunition remains unchanged. #417 supplies the
explicit surviving bandits; no ordinary resident acquires theft behavior.

Final loading verification preserves previous results and partial saves. A
city-day resolves in 77.45 s versus 124.07 s in the preceding checkpoint. The
paused loading screen has longer callback tails; active gameplay is unchanged.
Evidence: assets/validation_5851/loading-results.json. This completes the #415
implementation scope, not author acceptance or all V5.8: #416/#417 and the final
grouped handoff continue separately. Older checkpoint notes below are historical.

The separate unreleased #416 branch now connects the four approved transports,
Buenos Aires services, scheduled paid trips, persistent stops and real personal
resource costs. Native evidence is in validation_5852; historical estimates and
limits are documented in SYSTEMS. Author checks remain grouped; #415 regional
survivor/theft integration and #417 incidents continue separately.

## 5.8.50 / #502 - Contact completion pass

Implementation now covers remaining common inventory, carried furniture,
deployment boundaries, NPC map surfaces and unlinked local contact candidates.
Native validation passes 136 current checks and 2 original-runtime checks, with
clean static validation and all 17,040 package members matching source. Evidence:
assets/validation_5850. No new art or balance calibration. Manual corroboration
stays grouped until all V5.8 work is ready; #415-417 remain unfinished.

The unreleased #415 branch has 335 distinct native scenario assertions. Quiet
physiology, spatial area queries, shared weather and pipelined loading requests
reduce catch-up work while preserving native clocks. Real city-day loading still
takes about 132 seconds including startup; theft integration and final
performance validation remain open. See TASKS and validation_5851.

## 5.8.49 / #502 - Physical materials and food integration

Documented surfaces cover the physical material catalogue and prepared food.
Native quantity operations, shared food ageing/exposure, source-climate NPC
absence, non-solid ground contact and independent record migration pass1190
current native assertions plus2 original-runtime checks. Evidence is retained
in assets/validation_5849. Author checks stay grouped.
This does not close V5.8: audit the remaining generic physical-item adapters,
then complete #415 absent encounters/theft and #416/#417 transport/incidents.

## 5.8.48 / #502 - Vessel exposure and interrupted test recovery

Implemented bottle/canteen/mate/pot exterior areas and persistent exposure,
including packed dining ownership and mounted pots. Evidence is recorded in
assets/validation_5848. The reported native crash came from an incompletely
parked private table fixture; corrected fixtures use the existing production
parking path and the launcher checks save existence before starting the engine.
Native validation: 674 current and 2 original-runtime checks pass;
zero failures/static errors.
Remaining V5.8: physical-material/food contact adapters (#502), absent combat
and theft (#415), documented routes/Buenos Aires (#416), travel encounters
(#417). Co-op rest is deferred to V5.12. Author checks stay grouped.

## 5.8.47 / #502 - Abstract stack contamination

Implemented the approved equivalent-unit sphere reference and native lot
persistence/exposure for essences and abstract preparations. Evidence is in
assets/validation_5847; author corroboration stays grouped.
Native/static verification passes: 168 current and two original-runtime checks,
zero failures. The package is source-identical, with previous art/maps unchanged.
Remaining work:
other physical-material/food/container exposure and contact adapters (#502),
absent combat/theft (#415), historical routes and Buenos Aires (#416), travel
encounters (#417). Multiplayer rest stays deferred to V5.12. V5.8 is not complete.

## 5.8.46 / #502 - Native NPC absence physiology

Implemented source-map contamination/exposure and Life recovery for native hub
bodies and the existing travelling resident roster. Departures capture the last
recovery gate, body and real equipment; loading resolves the elapsed source
clock before ordinary NPC ticks. No movement, battle decisions or replacements
are simulated here. Remaining work includes #502 stackable/contact adapters,
#415 combat/theft, #416 documented routes/urban map and #417 encounters. #412
multiplayer rest remains deferred to V5.12. Evidence: assets/validation_5846,
155 current/4 original native PASS and clean static validation. Author tests
stay grouped; no issue or whole-version completion is inferred.

## 5.8.45 / #502 - Canonical dining-table contamination

Corrected the ownership gap between visible tables and their physical collision
cells, including duplicate contacts, environmental area and additive migration.
Evidence: assets/validation_5845. No new art, maps or balance rates. Author tests
remain reserved for the final grouped V5.8 handoff. Remaining implementation:
unloaded NPC physiology/other contact adapters (#502), actual unloaded combat
and theft (#415), documented transport/Buenos Aires (#416), encounters (#417).

## 5.8.44 / #410 - Decorative catalogue completion

Original wall landscapes and freestanding botanical wood sculpture complete
the requested furniture types, with painted inventory sprites, learned
manufacture, approved commerce and real-body movement/persistence. Evidence:
assets/validation_5844. Final author checks remain grouped for the completeV5.8
handoff; this does not mark the version accepted or close remaining issues.
#502 unloaded NPC physiology/contact adapters, #415 combat/theft, #416 routes
and Buenos Aires, and #417 travel encounters remain in implementation.

## 5.8.43 / #502 - Household cleaning during absence

Visited homes now use captured physical access, shared daily quotas, actual
resources and chronologically ordered purchases while unloaded. Exterior home
histories respect the civil-calendar freeze during Limbo stays. Native evidence:
assets/validation_5843. CA502-HOME-AWAY-01 joins the final grouped author handoff.
Remaining V5.8 work: #410 paintings/statues and final integration, #502 unloaded
NPC physiology/contact coverage, #415 combat/theft, #416 historical routes and
Buenos Aires, #417 travel events. Multiplayer rest remains deferred to V5.12.

## 5.8.42 / #502 - Furnishing history across map absence

Visited household furniture retains contamination and natural exposure history
when fixed installations are recreated after Limbo travel. Additive migration
keeps old-save values; restoration is idempotent. Evidence: assets/validation_5842.
CA502-HOME-FURNISHINGS-01 remains pending the grouped V5.8 handoff. Automatic
absent-home work, remaining #502 adapters and the other unfinished V5.8 issues
are not completed by this persistence patch.

## 5.8.41 / #502 - Household storage across map absence

The actual visited-house coffer now travels as hidden, inaccessible household
state rather than a copy of its stock or player cargo. Supplies, funds, food
lots, water and partial cleaning effort survive native hub and Limbo crossings.
A prior-runtime save is retained for additive migration and original-runtime
rollback checks. Evidence: assets/validation_5841; 164 current native assertions
plus 40 original-runtime checks, zero final failures/static errors. This prepares
unloaded household work, not its automatic scheduling or full V5.8 completion.
Author corroboration remains grouped with the final version handoff.

## 5.8.40 / #410 - Complete dining sets

Portable small, ordinary, long and luxury table sets now carry actual chairs,
food and containers through the existing inventory, commerce and hub systems.
Period dimensions, material calculations, painted icons and native evidence
are retained in assets/art_source/dining_sets and assets/validation_5840.
Validation passes1,201 current native assertions and22 original-runtime checks,
with zero failures/static errors. Author corroboration stays pending until the
complete V5.8 handoff. Outstanding
furniture integration, #502 absence/contact adapters and #415-417 remain open.

## 5.8.39 / #415 - Mean-hit prerequisite

Shared current aim parameters and a stateless angular hit-probability estimator
are implemented;194 current native assertions plus16 original-runtime checks pass
(assets/validation_5839), with zero failures/static errors.
This does not yet advance unloaded battles. Round/resource/death integration,
#415 theft, #416 routes, #417 events and outstanding furniture/contamination
adapters remain open. All author checks stay grouped for the final V5.8 handoff.

## 5.8.38 / #502 - Loaded NPC illness

NPC illness damage and natural recovery depuration are implemented using the
existing shared formulas and NPC recovery rules. Validation:71 current native PASS
plus two original-runtime checks, zero failures/static errors; assets/validation_5838.
NPC absence history, household absence routines,
remaining contact adapters, table supply and #415-417 remain open. No full V5.8
completion or author acceptance is inferred.

## 5.8.37 / #502 - Temporary climate history

Temporary seal exposure and natural-weather handoff on departure are implemented
and pass 53 current native assertions plus four original-runtime checks, with
zero failures/static errors in assets/validation_5837. This preserves current
rates and save concentrations, including rain washing. Remaining table supply,
#415-417 and broader #502 adapters/housekeeping remain open. Author checks are
grouped for completion of all V5.8 implementation.

## 5.8.36 / #410 - Portable study furniture

Writing-desk/bookcase fabrication, supply, sprites and complete native transport
pass 468 current native assertions plus 19 original-runtime checks, with zero
failures/static errors; assets/validation_5836. Native visual review passes.
The original mansion fixtures and stored-reading rules remain intact. Table acquisition,
#415-417 and remaining#502 adapters/history are still open. Manual handoff stays
grouped after allV5.8 implementation; no author acceptance is inferred.

## 5.8.35 / #410 - Sofa supply and transport

Both existing sofa designs gain learned fabrication, normal merchandise and
painted item views. Their complete physical seat assemblies travel together;
no new rest bonus or multiplayer policy is introduced. Evidence:
assets/validation_5835;357 current native PASS plus17 original-runtime checks,
zero failures/static errors. Table/study acquisition and #415-417/#502 remain
unfinished. CA410-SOFA-ACQUISITION-01 stays in the grouped author queue.

## 5.8.34 / #410 - Ordinary rest furniture acquisition

The corrected ordinary chair/cot gain normal fabrication, supply and physical
transport, with appended recipe/merchant migrations and painted inventory sprites.
Evidence: assets/validation_5834; 206 final native assertions plus 12 original-runtime checks and static validation pass. This does
not complete remaining table/sofa/study acquisition, #415-417 or #502, and does
not extend author acceptance. Manual checks remain grouped for completed V5.8.

## 5.8.33 / #410 - Ordinary rest furniture correction

The author-requested chair/cot rescaling preserves owned artwork while raising
the cot on legs to the chair-seat height. Physical collision, active-rest pose,
construction bill and idempotent old-actor migration follow the same source.
Evidence: assets/validation_5833. CA410-BASIC-REST-01 remains author-pending.
Other furniture acquisition, #415-417 and remaining #502 integration are unfinished;
this delivery does not complete V5.8.

## 5.8.32 - Luxury rest furniture acquisition (#410)

Two existing catalogue pieces gain normal purchase/fabrication, manufacturing
restock, original painted icons and reversible placement/carrying. Revision 19
appends recipes without changing previous learning; merchant supply revision 1
does not refill sold stock on migration. Static validation and 107 native assertions passed under
assets/validation_5832, with Spanish icon review and actual crouch + Use input. No author acceptance or complete V5.8 claim.

## 5.8.31 - Storage furniture acquisition (#410)

The approved wardrobe/cupboard supply is integrated with normal learned recipes,
Provisions, manufacturing restock and native placement/storage. No map, model or
inventory-icon replacement. New recipe IDs append after meals; revision18 keeps
old learning and starts these recipes unknown. Movable cupboards reuse the
accepted ten-stack/100kg construction separately from the fixed kitchen fixture.
Static validation and 107 selected native checks passed, including final icon
review. Other furniture acquisition and #415/#416/#417/#502 remain open. Evidence:
assets/validation_5831; CA410-STORAGE-ACQUISITION-01 author corroboration pending.

## 5.8.30 - Luxury furniture catalogue (#410, integration in progress)

Three original models bind to ordinary rest/dining behavior. The six-seat table
retains eighteen real item slots and adapts its serving presentation to its
narrower historical envelope; it does not seed food or water. Existing furniture,
map geometry and authored layouts remain unchanged. Exact physical bills and
references: SYSTEMS/ASSETS and assets/art_source/luxury_furniture.
This stage supplies native-testable catalogue classes, not campaign acquisition.
Three-per-type Provisions stock, ten recipe copies and manufacturing restock were
approved on 2026-10-27 for all movable furniture; that integration is pending.
Evidence: assets/validation_5830; CA410-LUXURY-01 author corroboration pending.
The V5.8 release and #410/#415/#416/#417/#502 remaining scopes are not complete.

Validation:96 executed native PASS across fourteen runs against one immutable
final30c runtime/addon; zero native failures and zero static errors. Current
save/load, hub return, the original5.8.26 save, actual item transfers, ordinary
furniture regressions and English/Spanish presentation pass. No author
acceptance is inferred; exact hashes and line-ending qualifications are recorded
in assets/validation_5830/RESULTS.md and report.json.

## 5.8.29 - Usable sofas (#410)

The authored mansion now has two- and three-seat sofas, reusing ordinary chair
comfort and native rest sessions. Their new actors install idempotently in old
saves without replacing maps or accepted furniture. Original models and physical
calculations have independent provenance. Acquisition/movable-sofa integration,
the rest of the furniture catalogue and other V5.8 issues remain open.
CA410-SOFAS-01 is pending; isolated engine success is not author acceptance.

Validation:113 executed native PASS, zero static errors; current/old saves, hub,
all five seats, shared contamination, native Use and bilingual aim text. The
101-assertion seating suite is reused after target normalization and a Spanish
encoding correction;12 further assertions cover those changes. Package hashes
and reuse boundaries are recorded in assets/validation_5829/RESULTS.md.

## 5.8.28 - Regional weather history for objects (#502)

Exposed physical objects now reconstruct natural temperature, humidity and rain
for elapsed civil minutes after save/hub restoration or a loaded clock jump.
Their recorded region, weather seed, shelter, environmental category and surface
area drive the existing exposure/washing rules. Cleaning settles prior exposure
before replacing dirt. Revision-2 exterior saves retain their concentration and
begin history now; their existing constant Limbo intervals remain valid.

A transient shared cache holds at most32 date/location weather pages. Eviction
only recomputes deterministic samples; it never truncates elapsed time or merges
object concentrations. No recurring actor scan, new balance, map or artwork.
Temporary climate-seal history, NPC physiology, unloaded household routines and
remaining stackable/contact adapters are still open in #502; V5.8 is unfinished.

Validation in assets/validation_5828 records71 executed native PASS, zero
failures/static errors, current/prior saves and hub return, preserved storage
ownership, and a matched1,000-object callback comparison. Shared weather reduces
the measured1,000-receiver/day replay from9,868.688 to86.9435ms with identical
results; this is not a displayed-frame/GPU FPS claim.
CA502-WEATHER-HISTORY-01 awaits author corroboration. The author requested that
manual checks and questions wait until the entire V5.8 implementation is ready.

## 5.8.27 - Indoor furniture placement (#411)

Movable storage furniture can now be rearranged inside the mansion, under the
approved land permission. Wardrobes and ordinary carried chests use the same
land checks; city streets and expired/unacquired property do not grant placement.
Campfire/tent permissions remain separate. All placements still require the
complete dry, stable, clear footprint, preserving doors, stairs and passages.
Moving a filled object preserves its native contents, title and physical mass;
existing fixed kitchen/water installations remain fixed. No new saved fields,
map geometry, artwork, recipe or economic values are introduced.

Validation in assets/validation_5827 records96 executed native PASS,
zero failures/static errors, and16,980 source-matching package members. CA411-INTERIOR-01
awaits author corroboration; all earlier outstanding checks remain pending.
This permission patch does not finish the wider furniture catalogue or V5.8.

## 5.8.26 - Stored-book reading (#410)

The mansion library now stores actual objects in 25 stacks / 100 kg. Its adjacent
reading desk opens the stored recipe books without transferring or copying them.
Reading requires the approved 96-unit desk/shelf distance, line of sight and
actual access. Existing recipe learning and personal-book reading remain shared.
Closing the menu pauses; saving or returning from hub travel preserves progress.
Existing owned shelf/table artwork and all map geometry are retained.

Validation in assets/validation_5826 records113 executed native PASS, zero failures,
zero static errors, and16,980 source-matching package members. Author corroboration
is pending; manual tests remain deferred until the whole V5.8 implementation is
ready. Remaining furniture/acquisition and other V5.8 issues stay open.

## 5.8.25 - Garden water furniture (#410)

Implemented fixed fountain/cistern actors, original period-reference models and
painted icons, independent200/1000-L reserves, actual-volume inventory transfers,
quality/temperature conservation, and the existing bath/forecast adapters.
Initial cistern water is zero; only the fountain replenishes at1 L/world-minute.
Revision1 installation leaves existing mansion geometry and furniture intact.
Validation in assets/validation_5825: 96 native assertions pass; static checks
report zero errors; all 16,978 packaged files match source. Save migration,
original-version rollback, hub persistence and native visuals were checked.
CA410-WATER-FURNITURE-01 is pending author review. Keep #410 and V5.8 open:
reading desks/bookcase access, remaining furnishing variants and acquisition/
player placement still require implementation; other issues remain separate.

## 5.8.24 - Native wardrobe storage (#410)

The northwest first-floor mansion bedroom now contains a period wardrobe,
with original closed/open/locked models and a painted inventory icon. Native
storage preserves the approved 25 stacks/1,000 kg of contents, food lots,
locks, ownership and carried contents. Empty mass is153.8955961 kg, calculated
from the delegated historical construction, rather than from storage capacity.

Revision1 installs one actor without changing map geometry or replacing the
accepted beds, tables and bathroom fixtures. Moving it does not spawn a duplicate.
Placement reuses the approved camp/property land permissions and complete dry,
stable, clear footprint checks. The current mansion permission covers gardens;
it does not yet authorize rearrangement inside bedrooms. Ordinary chest placement
and capacity remain unchanged. Acquisition/crafting and other furniture are still
open work; this patch does not close #410 or V5.8.

Agent evidence:145 executed native PASS,zero static errors. Original artwork provenance and scoped evidence are in assets/validation_5824
and assets/art_source/wardrobe. CA410-WARDROBE-01 awaits author corroboration.

## 5.8.23 - Constant Limbo exposure across absence (#502)

Physical objects now preserve their constant mansion exposure interval across
save/load and hub absence. The first query or cleaning operation settles it
before reading or replacing contamination. Previous saves retain their dirt
and start history at migration, without retroactive exposure. Existing geometry,
art, transmission rates and normal loaded-world behavior remain unchanged.

This delivery handles the established constant Limbo climate only. Variable
exterior weather, temporary climate seals, NPC physiology and unloaded household
cleaning still require their own historical adapters. Evidence is recorded in
assets/validation_5823: 78 executed native PASS, zero static errors, current/prior
save and hub checks, and a matched 1,000-object callback-timing comparison.
CA502-LIMBO-HISTORY-01 awaits author corroboration.

## 5.8.22 - Shared-water mansion bathroom fixtures (#410)

Each existing first-floor mansion bedroom now contains a washstand, bathtub
and toilet. All twelve fixtures share the kitchen sink's existing 200-L reserve,
replenished at 1 L per world minute. Native filling, bathing, toilet use and
seated/lying poses reuse the accepted systems. There are no new map walls,
room identities, artwork or hygiene costs.

The installation follows the existing beds/tables, retries occupied positions,
and retains its actors across save/hub return. Native evidence, visual captures
and the matched render-callback comparison are in assets/validation_5822.
CA410-MANSION-BATH-01 awaits author corroboration, separately from the previous
kitchen and camp-cooking checks. Other furniture/acquisition and V5.8 issues
remain open; multiplayer rest corroboration stays deferred to V5.12.

## 5.8.21 - Attended camp cooking and fuel interruption (#411)

Campfires now cook the learned roast beef, roast fish and puchero recipes.
Food receives only actual attended burning time; the fire spends wood, not coal.
Fuel exhaustion preserves progress. Refuel and relight for one world minute to
resume the same batch. Cancellation keeps ingredients and their accumulated age,
but does not refund burned wood. Puchero requires the empty mounted pot and
500 mL potable water from carried containers. Additional pot water is not heated
while the useful power is assigned to food.

Focused native checks and live menu review are in assets/validation_5821.
CA411-COOKING-01 and the earlier two #410 checks await author corroboration.
This patch does not complete #411 or V5.8. Remaining furniture/placement,
off-map simulation, transport, encounters and contamination work stay separate;
#412 multiplayer corroboration remains deferred to V5.12.

## 5.8.20 - Mansion kitchen sink and wall cupboard (#410)

The kitchen now has a usable sink and an overhead cupboard. The potable
200-L mansion reserve replenishes 1 L per world minute and persists across
saves and travel. The cupboard uses native storage, ten stacks / 100 kg,
real food lots and existing padlocks/keys. These fixed actors preserve map
geometry and the kitchen approach. Portable furniture acquisition remains open.

Evidence: assets/validation_5820. Static validation, deterministic exports and
selected native storage/water/save/hub/previous-save checks pass. Author checks
CA410-FIXTURES-01 and the inherited CA410-COOKING-01 remain pending. This is a
focused #410 delivery; neither #410 nor V5.8 is complete.

## 5.8.19 - Attended cooking and shared bread proofing (#410)

The mansion kitchen now supplies a stove, oven and shared proofing counter.
The four learned recipes make ten 100-g portions using the approved ingredients,
fuel and world time. Bread first proofs unattended for two hours; the collected
1.141-kg dough retains its age when carried to the oven. Cancelling attended
cooking releases reserved supplies without rejuvenating them.

Native engine evidence, save migration/rollback and export checks are recorded
in assets/validation_5819. CA410-COOKING-01 awaits author corroboration; no prior
acceptance is extended to this new workflow or artwork. Remaining #410 work
includes the broader furnishing catalogue, remaining kitchen fixtures and
acquisition. The #411 campfire adapter and #412 furniture/rest integration stay
in separate patches. V5.8 also retains #415, #416, #417 and #502 work; multiplayer
corroboration remains deferred to V5.12.

## 5.8.18 - Prepared meal items and consumption (#410)

Bread, roast beef, roast white fish and puchero now have distinct 100-g native
portions, painted inventory/world sprites, approved nutrition and food-lot
ageing. Inventory use, dining tables, waiting and travel preserve the selected
meal's dose; travel water intake retains its independent existing calculation.
The four items retain their identity and contamination through transfers,
saves and hub travel. Their prices use approved ingredients and fuel plus 25%.

This is the consumable integration slice: kitchen stations, attended cooking,
proofing and campaign acquisition remain unfinished. No prepared-meal stock or
recipe access was invented. Evidence: assets/validation_5818. Author visual and
interaction check CA410-MEALS-01 passed on 2026-10-26, without qualifications. Native evidence: 291 executed PASS / zero FAIL in 21 selected runs; four
matched-control nutrition comparisons also pass. Static validation passes.
Engine checks remain separate from author acceptance; #410 and V5.8 stay open.

## 5.8.17 - Kitchen ingredients (#410)

The approved flour, raw beef, raw white fish, vegetable mix and culinary salt
are integrated into Provisions as gram-based materials. Raw meat, fish
and vegetables use full 100-g portions and the approved distinct nutrition.
Food lots retain age through storage and native transfers; flour remains a
preparation ingredient and salt does not acquire biological spoilage.
Painted inventory/world sprites follow SPRITE_ART_DIRECTION, with original
sources and exact built-in imagegen prompts retained. Technical packing only
crops/masks/resizes the retained sources; no existing art is replaced.
Native checks: 174 executed PASS / zero FAIL in 21 selected runs; paired
digestion, old-save rollback and 500-stack timing also pass within their recorded
limits. Evidence: assets/validation_5817. CA410-INGREDIENTS-01 passed author
acceptance on 2026-10-26, without qualifications. Cooking/proofing, finished
dishes and remaining furniture were
still unfinished #410 work.

## 5.8.16 - Non-solid physical scenery exposure (#502)

Mansion shrubs, decorative cave gems and shop signs now use an explicit physical
scenery type. They receive the existing ambient exposure and rain washing without
new collision, art or balance rules; cameras and transient effects stay excluded.
The fieldless base preserves native actors and saved contamination. Registration
uses existing spawn events and one load census; there is no recurring global scan.

Validation: 232 executed native PASS / zero FAIL in ten selected runs, including
old-save migration, rollback, original solid-object regression and MAP03 census.
All 16,919 current03 package members match source. With 1,000 peaceful non-solid
objects, callback p99 was 17.2022 ms before and 18.1962 ms after; 700 simulation
tics completed in about 20 s. These callbacks are not measured displayed frames;
PresentMon capture was unavailable. See assets/validation_5816/RESULTS.md.
CA502-SCENERY-01 passed author acceptance on 2026-10-26, without qualifications.
Other adapters, stackable items and unloaded history remain open in #502.
This patch does not complete V5.8.

## 5.8.15 - Usable sleeping bag inside the tent (#412, in progress)

Using the owned deployed tent from outside opens Rest / Pack actions. Rest
uses the existing duration menu and places the character's original unboxed
sleeping bag in a clear berth. Native crouching fits the approved roof; body
radius, full height, tent art and recovery rules are unchanged. Waking returns
to the recorded entrance, with native collision checks and safe fallbacks.
Pre-sleep cleaning reserves the same berth and cannot be bypassed by packing.

The corrected flow passes 73 executed assertions in 11 native runs, including
actual Use/menu reply routing, normal and solo accelerated rest, Limbo untimed
rest, cancellation, blocked exit, exact cleaning costs and old/new save loads.
Static checks and the package/source comparison pass. Evidence and limits:
assets/validation_5815/RESULTS.md. CA412-BAG-01 passed author review on2026-10-26, including the outside
interaction correction. The retained launcher starts outside the tent.
The existing cooperative admission/shared-clock implementation and author test
are deferred to V5.12. Remaining #410 furniture integration is still open.


## 5.8.14 - Native ration lots (#410, in progress)

Existing 200 g rations now retain separate contamination lots in native
inventories, the Box, dropped items, tables and coffers. World time ages them
with storage temperature/humidity, including unloaded-storage climate replay;
eating consumes the oldest lot and applies the approved body-mass dose.
Commercial stock stays fresh and shops reject contaminated resale. Journey
and wait previews use independent lots; confirming a journey installs the
aged remainder once. Inventory details show the next portion and lot count.

Evidence: assets/validation_5814; 57 native PASS, no failures, clean static checks.
CA410-FOOD-01 awaits author corroboration.
New food catalogue/recipes, cooking and the remaining furniture are still open;
this delivery does not complete #410 or V5.8. No art or map geometry changed.

## 5.8.13 - Campfire and mounted pot (#411, in progress)

Carried wood opens campfire assembly on permitted clear ground. The fire stores
10 kg, burns 1.92 kg per world hour, supplies the approved thermal power and
extinguishes on map departure while retaining fuel. A mounted original pot
heats, boils and cools without losing its identity, water quality or volume.
Only biological contamination is removed by a completed boil. Camp cooking
recipes still depend on the unfinished #410 food/cooking integration.

Native checks, persistence and rendering evidence: assets/validation_5813.
CA411-FIRE-01 is pending author review; this does not complete #411 or V5.8.

## 5.8.12 - Metabolic toilet sessions (#502, in progress)

Domestic-cleaning continuation (2026-10-25, #502): available residents clean
accessible floors and furniture in the loaded home, sharing one world hour per
household/day. Household coffers buy a reusable cloth and up to300g soap from
real Provisions stock with their own coins; player supplies are not used.
Cleaning spends the approved water/soap per area and preserves partial soap,
daily quota and actual merchant stock through saves and hub travel. Native
walking and calendar acceleration are integrated. Evidence:
assets/validation_5812/domestic; CA502-HOUSEKEEPING-01 passed author review on2026-10-25.
Unloaded-house history and the remaining #502 adapters are still unfinished.

Object-exposure continuation (2026-10-25, #502): physical scenery and loose
native equipment now receive ambient contamination and repeating rain washing.
Objects retain their concentration through pickup, storage, saves and hub travel;
occupied chairs remain exposed when temporarily lending their collision. Spawn
registration and staggered per-object clocks replace any routine world scan.
Evidence: assets/validation_5812/objects; CA502-OBJECTS-01 passed author review on2026-10-25.
Unloaded-map history and non-solid/stackable object coverage
remain unfinished; this continuation does not complete #502 or V5.8.

Solid-contact continuation (2026-10-25, #502): native player/NPC collisions
now create one shared, saved contact per touching pair. Brushing exposes the
outer garment/armor or bare body, using the approved contact areas and world
clock. Separation stops transfer; repeated active/passive callbacks cannot
charge twice. Generic solid objects retain received contamination. Evidence:
assets/validation_5812/contact; CA502-CONTACT-01 passed author review on2026-10-25.
Object ambient exposure and loaded-home housekeeping are delivered above;
unloaded-map history remains unfinished. This is not completion of #502 or V5.8.

NPC-exposure continuation (2026-10-25, #502): living NPCs supported by the
thermal system now share the player's environmental/equipment/immersion balance.
The existing staggered thermal clock drives exposure, including accelerated
world time, without global actor scans. Modeled armor, sidearms, shields and
native carried equipment retain their existing identities; boxed gear is protected.
Native-backed resident weapons are counted once. Evidence: assets/validation_5812/npc.
CA502-NPC-01 passed author review on2026-10-25. Generic solid-object/loose-equipment exposure is delivered above;
loaded-home housekeeping is delivered above; unloaded-map exposure remains
unfinished; this continuation does not complete #502 or V5.8.

Combat-contact continuation (2026-10-25, #502): native melee now transfers
contamination between the actual weapon/natural attacker and the struck exterior
piece or blocking shield, after evasion. Body dose follows mass; non-contact
attacks do not transmit. NPC modeled gear saves its own clean-start states.
Evidence: assets/validation_5812/combat. CA502-CALENDAR-01 is author-accepted;
CA502-COMBAT-01 passed author review on2026-10-25. Actor ambient/solid contact and loaded-home cleaning are delivered above;
unloaded-house history remains unfinished; this does not complete #502 or V5.8.

Live demonstration (2026-10-25): the diagnostic menu now handles its F keys and
shows work/supplies/contamination above the live panel.31 native rechecks pass;
agent-operated craft/read/existing-wash/no-soap demonstrations pass. The production
package is unchanged; CA502-CALENDAR-01 passed author review on2026-10-25.

Calendar-sleep continuation (2026-10-25, #502): approved pause/clean/sleep/resume
sequence implemented with saved progress and no duplicate charge for an existing
wash. Rules and compatibility: SYSTEMS; evidence: assets/validation_5812/calendar.
160 native assertions across22 serial runs pass, including save migration/rollback
and previous cleaning regressions; static validation passes.
CA502-CALENDAR-01 passed author review on2026-10-25. Exact-date forecasts explicitly reject
pre-sleep queues. Contacts and loaded-home housekeeping are delivered above.

Author-reported wake-laboratory water shortage corrected (2026-10-25): the
manual fixture pauses the existing rest food/water top-up to100, retaining the
ordinary50 threshold. Waiting before F2 therefore preserves the test water instead
of automatically drinking it. Seven focused native assertions pass after a
30-second real-time delay, including supplied cleanup and the no-soap case.
Evidence: assets/validation_5812/wake/water. Production code/package is unchanged;
CA502-WAKE-01 passed author review on2026-10-25 with the corrected laboratory.

Exhaustion-wake continuation (2026-10-25): the author approved cleaning after
waking from involuntary exhaustion sleep. Collapse and the existing wake lock
remain immediate. Once awake and safe, clean the selected weapon followed by
equipped armor/clothing, using the accepted progressive costs and queue. Missing
supplies skip pieces without blocking awakening; external damage/combat awakening
does not begin a new cleanup. Completion leaves the character awake. Cancelling
or travelling keeps paid progress and discards the remaining queue.

Cleaning task revision2 preserves old targets, remaining work, soap and water;
old exhaustion saves start no cleanup until waking. Forecast revision17 invalidates
cached predictions and retains the explicit unsupported exact-date guard for
multi-piece wake/sleep queues. Ordinary world-clock completion remains available.
Evidence: assets/validation_5812/wake; 97 native assertions, genuine
old-save migration/rollback and static validation pass. All169 maps and13,826 art
members remain unchanged. CA502-WAKE-01 passed author review on2026-10-25.
Calendar sleep is now integrated above. Contacts and loaded-home housekeeping are delivered above; unloaded-house
history remains unfinished; this continuation does not complete#502 or V5.8.

Surface-contamination continuation (2026-10-25): player contact now uses saved
one-square-metre floor and wall zones. Feet touch0.04m2; torso brushing touches
0.10m2. Armor/clothing receives contact before the uncovered body; the cleaner
side gains contamination, preserving the dirtier source. Adjacent zones, wall
faces and stacked supports retain separate identities. Slopes use plane distance.

Exposed zones lose the approved10/20 degrees per30 world minutes of light/heavy
rain, repeatedly while rain persists; temperature/humidity exposure continues.
Roofed interiors are excluded. Washing survives dry weather, saves and travel;
regional weather during absence is evaluated lazily by civil minute. Active
contact uses the actual local microclimate. The sparse revision1 registry starts
new maps at zero when first observed, with no retroactive old-save dirt. Existing
body/equipment contamination remains untouched. Waiting copies zone state and
matches real execution; forecast revision16 invalidates older predictions.

Evidence: assets/validation_5812/surfaces. 157 executed native checks
and static validation pass. All169 maps and13,826 art members are unchanged.
CA502-SURFACE-01 passed author review on2026-10-25, including the corrected F2/F4/F5 laboratory. Other-actor
and combat contact, resident housekeeping and calendar-triggered pre-sleep
cleaning remain follow-up; this does not complete#502 or V5.8.

Equipment-cleaning continuation (2026-10-25): select an owned weapon, shield,
garment or armor piece and choose **Clean (J)** in the inventory. Cleaning uses
potable water carried outside the Box, soap and a reusable cloth, without a station:
1L and5g per square metre, over60 world seconds/m2. The approved fixed surface
by type/size determines cost, independent of tier and current wearer. Costs and
cleansing progress together; cancelling retains both. A full piece's budget is
required to start; a later shortage retains only the affordable progress.

The shared H shortcut preserves boiling for selected water; other selections
retain bathing. Native UI dispatch is tested.

Successful repair starts cleaning the repaired piece when supplied. Voluntary
sleep first cleans the selected weapon, then equipped armor/clothing in slot order;
unaffordable pieces are skipped with notice and do not prevent sleep or repair.
Sleeping-bag support survives the queue. Explicit cancellation discards queued
sleep; partial work saves/loads and map departure cancels without refund. Existing
soap fractions retain their mass and identity. The independent wait forecast
matches single-piece execution; its revision15 invalidates older cached forecasts.
The multi-piece queue followed by sleep keeps the unsupported exact-date guard,
while ordinary/accelerated live time remains available. Calendar-triggered sleep remains follow-up; exhaustion cleanup is now covered
by the separate post-wake continuation above.

Evidence: assets/validation_5812/cleaning;134 executed native assertions and static
validation pass. The final package has16,892 source-identical members;169 maps
and13,826 art members remain unchanged. CA502-CLEAN-01 passed author review on2026-10-25 without qualifications. Bath/posture acceptance stands;
this continuation does not close#502 or complete V5.8.

Soap bathing continuation (2026-10-25): use soap or the inventory's **Bathe (H)**
action while reclining in a bathtub, facing an accessible potable fixture, or
immersed in potable water. Select the desired contamination reduction; the menu
shows the current resource limit and actual mass-scaled costs. Each degree takes
10 world seconds and uses0.5L at80kg, scaled by body mass, with5g soap/L.
Consumption and cleansing are progressive. Cancellation, loss of access or source
quality, external damage and map departure retain completed work and spent
resources. Disease damage continues; a bathtub bath retains the accepted lying
pose and releases it on completion/cancellation. Merely reclining still does not wash.

The opened gram's unused fraction persists with its mass and is spent first next
time, including when no whole soap grams remain. It follows the carrier separately
from unopened integer material stacks. Household bathing draws the shared reserve;
connected reservoirs lose actual volume. The independent waiting model snapshots
soap/water and matches accelerated execution without consuming live resources.
Existing dynamic-water and unsupported-effect forecast guards remain in force.
Evidence: assets/validation_5812/bathing;121 native assertions and static validation pass.
CA502-BATH-01 passed author review on2026-10-25 without qualifications.

Author-requested posture continuation (2026-10-25): using a toilet seats the
character; using a bathtub reclines them. Reuse the existing RestSeated/RestLying
artwork and clipped orbit-camera pattern without starting a rest or sleep session.
Use/movement/external damage releases the pose; disease damage continues. Toilet
completion stands up automatically. Safe entry/exit retains the player's actual
collision volume; blocked exits leave the fixture nonblocking until clear.
Save/load preserves occupancy and camera; a pre-pose toilet save adopts the seat
without restarting its timer. Bathtub reclining alone does not wash, charge water
or consume soap. Progressive soap bathing is supplied by the continuation above.
Evidence and separate author check: assets/validation_5812/postures, CA502-POSE-01.
74 native checks pass; static validation passes. CA502-POSE-01 was accepted by the author on2026-10-25 without qualifications.

Household toilets now perform the approved one-world-minute hygiene action.
Completion removes up to20 contamination, bounded by current contamination and
metabolic capacity, and spends10L from that house's shared potable reserve.
Starting spends nothing. Use again, leave reach/map, or take external damage to
cancel without spending or cleansing. Recheck access, water and capacity at
completion; insufficient or no-longer-needed cleansing spends nothing.
Disease damage continues without cancelling the action, as approved2026-10-25.

The action uses ordinary world time and the existing accelerated/wait controls.
Save/load retains partial progress; map departure cancels it. Independent wait
forecasts include completion and same-tic nutrition credit without changing live
resources. Existing unsupported-effect forecast guards remain in force.
Static validation and55 native checks pass;16,885 package members match src.
Evidence: assets/validation_5812. CA502-TOILET-01 is pending author review.
Calendar-triggered sleep cleaning, supported contacts and loaded-house cleaning
are delivered by the continuations above; remaining #502 scope stays in TASKS. V5.8 remains incomplete.

## 5.8.11 - Domestic bathrooms (#410, in progress)

The160 existing house interiors now install one sink, bathtub and toilet each.
Sink and bathtub share a saved200-L potable household reserve; different houses
remain independent. Refill is1L/world-minute, evaluated lazily across absence.
Use shows available water; collect into the selected inventory container while
facing the fixture. Capacity, carried weight, Box placement, boiling locks,
contamination mixing and residence permission retain their existing guards.

Revision1 state and a transient load check install missing fixtures in old saves
without resetting water or duplicating objects. All169 map files, including160
houses, remain byte-identical. Static validation and repeated art generation
pass;220 executed native checks cover selected houses, shared/partial collection,
blocked placement, save/hub, old-save migration and rollback. Final package has
16,884 source-matched members; evidence: assets/validation_5811.

CA410-BATH-01 passed author review on 2026-10-25 without qualifications. The toilet is installed visually; its
metabolic action, soap bathing and resident cleaning remain#502. Mansion kitchen,
remaining furniture/crafting and food integration remain unfinished#410 work.
V5.8 is not complete.

## 5.8.10 - Protect resting tent occupants (#412, in progress)

Tent packing now rejects a resting occupant and rechecks occupancy throughout
packing and at completion. A late rest pauses work without losing progress or
the deployed inventory item; packing can resume once the rest ends. The check
uses bounded player slots and preserves existing recovery, shelter and clock
restrictions. 30 native assertions cover the guard and old-save/rollback
continuity; see assets/validation_5810/RESULTS.md. Full sleeping-bag/two-occupant
rest integration and #410 furniture remain pending. No author acceptance is claimed.


Approved on 2026-10-25: the two occupants are two players, each with their
own sleeping bag. Normal rest may run while another player remains active.
World-time acceleration requires every living player to rest and accept the
same duration; waking, cancellation or loss of safety stops acceleration for
everyone. Costs/recovery remain individual. This cooperative policy is pending
implementation; the packing guard does not provide two-player admission.


## 5.8.9 - Severe contamination (#502, in progress)

Metabolic capacity now accrues from actual Hunger/Hydration restored by
rations, water, mate and direct potable-source drinking:20 restored percentage
points earn1 degree, fractional contributions combine, stored capacity caps at20.
Full bars earn no excess credit. Save migration initializes capacity at0 without
changing existing contamination or pending damage. Forecasts copy capacity and
journeys commit their independent result; current waiting schema12 invalidates
earlier projections. Native waiting now includes the existing direct potable-water
hydration, so its recovered needs and metabolic credit match actual immersion.
Thirty-six native assertions pass, including full bars, overflow, copies, native
pulses, prediction parity, save/hub and prior-save migration. All16,870 metabolism01
members match src; evidence: assets/validation_589/metabolism. The toilet action,
its60-second session and10-L domestic withdrawal still need furniture integration.
No new author test is queued for an unfinished toilet interaction.

Clean-water immersion now removes one body-contamination degree per world
minute per submerged square metre, multiplied by80kg/body mass. The existing
anatomical water samples distinguish potable, salty, biological, chemical and
unknown water. Only potable rows cleanse; leaving the water stops cleansing.
Gear retains its contamination and can transmit it again; this does not replace
the separate approved soap bath or equipment-cleaning actions. Independent
waiting forecasts include the same washing; journey departure clears origin
water coverage. Waiting schema11 invalidates earlier cached projections.
Sixty native assertions pass across rules, real geometry, mass/partial contact,
native waiting parity, water-exposure regression, saves, hub return and a prior
save. All16,869 wash01 members match src. Evidence:
assets/validation_589/immersion_wash. CA502-WASH-01 passed author acceptance on2026-10-25, without qualifications.

At contamination 90 or above, the existing disease damage doubles and the
survival HUD reports Sick. Toughness immunity still prevents damage without
turning it into healing; natural depuration below 90 removes the multiplier.
Travel/wait forecasts share the same rule. Existing saved body contamination
and fractional damage survive updating; wait forecast schema12 invalidates old
cached models after adding immersion washing.

Native checks cover exact boundaries, actual Life loss versus prediction,
depuration, immunity, saves, hub return and original-package rollback. See
assets/validation_589/RESULTS.md. CA502-SEVERE-01 was accepted on 2026-10-25.
Actor and equipment contamination now persists through pickup, storage, saves
and hub return. Thirty further native checks cover that state, protected storage,
explicit contact and old-save migration/rollback. Weapon/shield areas use the
approved size conversion. Player/carried-equipment environmental exposure now
uses thermal coverage, local temperature/humidity and protected Box storage.
The World journal displays the local index. Sixty-six further native assertions
cover independent forecasts, actual waiting, travel commit and save/hub continuity
(`assets/validation_589/exposure`). CA502-EXPOSURE-01 was accepted on 2026-10-25. NPC/furniture exposure, surface/combat contact and washing/bathing remain pending. The issue and V5.8 remain open.

Immersion now exposes the player's submerged skin, outer garments and carried
equipment according to known water quality. The Box remains protected; clean or
salt-only water does not cause this contact disease or wash existing contamination.
71 further native assertions cover real water, wait parity, travel, save/hub and
legacy rollback (assets/validation_589/immersion). CA502-IMMERSION-01 passed author
acceptance on 2026-10-25. Dynamic reservoir levels retain an explicit exact-wait
forecast limitation; manual/native waiting remains available.

Hygiene acquisition continuation, 2026-10-25: Provisions now sells animal fat,
caustic soda, soap and reusable cotton cloth; the library sells both recipes.
Soap uses the approved attended two-world-hour Chemistry process and reserves
300 mL potable water without consuming its container. Cloth uses normal Workbench
fabrication, cotton tier 2 and existing waste/time rules. Prices and replenishment
derive from the approved inputs. Recipe-book migration 16 appends locked IDs
203/204 while preserving existing knowledge; catalogue revision 1 adds only
missing supplies without refilling depleted stock or resetting existing deadlines.
92 executed native assertions cover fabrication, cancellation, trading, Box/chest,
current saves/hub, an unfinished soap task, prior saves/rollback and immersion
smoke checks. See assets/validation_589/supplies/RESULTS.md. Manual
CA502-SUPPLIES-01 and CA502-IMMERSION-01 passed author acceptance on 2026-10-25. Washing/bathing,
NPC/furniture exposure and solid/combat contact remain unfinished.

Medkits and hot, active-yerba mate now remove one contamination degree per
10% maximum Life of potential healing, including at full Life. The reduction
follows recovery pulses and preserves fractional doses; washed/cold mate and
Anima/energy items do not cleanse. Natural regeneration retains its own rate.
Native treatment checks: 31 executed PASS; save/hub and prior-save
coverage in assets/validation_589/treatment. CA502-TREATMENT-01 awaits author
acceptance.

The ambient rain reduction is integrated into actual player/equipment exposure,
the World journal and independent waiting forecasts. It subtracts the approved
0/10/20 points at0/2/10mm per hour after temperature/humidity, only on uncovered
urban ground, clamped at zero. Roofs/tents, natural and industrial references
retain their prior rules. Waiting schema10 invalidates old cached projections.
This does not yet implement persistent floor washing or resident cleaning.
Native evidence:22 assertions in assets/validation_589/rain, including an
actual rainy-hour wait and prior-save loading. Author acceptance is not implied.


## 5.8.8 - Safe placement and persistent tents (#411, in progress)

Carried chests now require dry, stable support and a free complete collision
volume. Placement preserves door/transition access and rejects narrow liquid
strips, with atomic failure that keeps the actual chest and contents carried.
46 native assertions cover geometry, real storage, save/hub and original-save
rollback; see [validation_588](../assets/validation_588/RESULTS.md).
Tent deployment now uses the approved ten/five game minutes, including native
waiting and accelerated attended work. It preserves the original inventory
instance across mounting, packing, save/load and hub return. Complete footprint
checks require mansion garden ground, a held current home contract or the
authored countryside rectangles; unknown land grants no permission. Existing
chest placement keeps its separately tested geometry policy. The entrance faces
the nearest cardinal direction towards the placing character, preserving the
approved rectangular footprint. Local solid roof/back pieces leave crouched access.

Rain is excluded and ambient wind is multiplied by 0.1 inside; existing air
temperature and humidity are retained. An event-maintained shelter registry
skips blockmap queries when no tents exist. Its only typed census runs on
map/save/hub load; normal updates use spawn/destruction bookkeeping and local
queries. This adds no rest recovery bonus or two-occupant sleeping arrangement.
Fire deployment, cooking and the remaining furniture work are still pending.
The original tent stage passed 112 native assertions; the enlarged correction
passes 125 assertions across 13 selected runs;
see assets/validation_588/deploy/RESULTS.md. CA411-TENT-01 passed behavior except the original narrow shape. The author
approved an enlarged 4 x 3 x 1.8 m tent, 18.8 kg and revised materials;
CA411-TENT-01 is fully accepted as of 2026-10-25, including the final model binding correction.

CA411-PLACEMENT-01 was accepted by the author on 2026-10-24.


Author follow-up, 2026-10-25: the enlarged dimensions and other terminal checks
passed; a miniature old tent rendered inside the new one. This was the known
CA-KP-009 MODELDEF multi-slot overlay, not a second deployed actor. Separate
single-slot blocks now bind legacy frame A and enlarged frame B. Meshes, size,
collision, costs and saved state are unchanged. Native before/after captures use
the production actor and its actual MODELDEF, including the legacy state; the
earlier substitute gallery did not exercise that binding. Evidence is in
assets/validation_588/binding. The author accepted the corrected visual on 2026-10-25.

## 5.8.7 - Food illness in travel and waiting forecasts (#410, in progress)

Forecasts now preserve contamination, fractional damage and natural depuration,
including its existing costs at full Life. Confirmed travel commits the same
independent state. Native parity, save/hub and original-save rollback checks
pass: 68 assertions in eight runs, documented in
[validation_587](../assets/validation_587/RESULTS.md). Actual food ageing, cooking
and furniture integration remain pending. Author checks are deferred during the
requested absence; V5.8 is not complete.

## 5.8.6 - Central property access (#411, in progress)

Implements one central dwelling purchase/rental and resident/chest relocation using the approved economy. Save migration and native validation are recorded in `assets/validation_586`; CA411-PROPERTY-01 was fully accepted by the author on 2026-10-24. Camps/player furniture placement and the rest of V5.8 remain open.

Camp acquisition continuation adds individually owned canvas tents and 20 L iron pots, learned fabrication recipes, Provisions/library catalogues, recipe-based replenishment, painted inventory icons and pot-specific cooling. Recipe schema 15 appends IDs 201/202; prior knowledge and stock migrate idempotently. Pot volume, contamination and temperature survive pickup, trade, Box/chest transfers, native saves and hub travel. Validation: 72 native PASS in 12 selected runs, 16,850 final package members verified byte-for-byte, original-save migration and rollback, clean static checks, and a native Spanish inventory capture. Housing remains accepted. Camp deployment, fire/cooking integration and author equipment/art acceptance remain pending; questions and manual tests are held until the author returns.

## 5.8.5 - Regional event discovery (#415, in progress)

Production schedule/quest presentation now separates remote outcomes from regional discovery; CA415-DISCOVERY-01 was fully accepted on 2026-10-24. This is one focused step of #415, not completion of unloaded combat/theft/calendar integration. #410 food/furniture, #411 property, #412 rest and #416-417 travel remain open; #413 altitude and #414 production water retain their accepted status. No V5.8 merges have been authorized.

## 5.8.4 - Second map soundtrack (#496)

Nineteen author-supplied tracks are packaged and catalogued for their named destinations, with intact masters and provenance. Existing maps retain accepted music. Reserved soundtrack destinations are not new playable maps. Native playback evidence is separate from author listening CA496-MUSIC-01, fully accepted on 2026-10-24. Continue #410 food/furniture and the remaining V5.8 property/calendar/travel work on focused branches.

## 5.8.3 - Food/furniture work in progress (#410)

The first slice implements the character's contamination state, approved numeric
food/illness rules, full-Life natural depuration and survival HUD. Isolated core
and save/load/migration/hub checks pass: 40 assertions in nine focused runs.
CA410-CORE-01 passed all author visual/interaction checks on 2026-10-24.
Food lots, ingestion, cooking/acquisition and the approved furniture catalogue
remain in progress. The complete approved food contract is in SYSTEMS;
validation_583 records current evidence and the bounded manual check.
This does not complete #410 or V5.8 and does not authorize merges.
The subsequent lot metadata model passes 38 additional isolated native checks,
including native serialization and hub travel; gameplay adapters remain open.

## 5.8.2 - Mansion connected water (#414)

Implements the approved two deposits east of the pool, Torricelli head-dependent
flow, native gate/level geometry, service steps, automatic supply/drainage,
contaminant union and finite bottle/direct-drinking withdrawals. Persisted
revision 1 state resumes game-calendar elapsed time on hub return. Existing
pool geometry and behavior remain unchanged. Explicit `-LegacyMap01` retains
the byte-identical 5.8.1 mansion for visited-map saves; new geometry is for new
campaigns. Static/native evidence and limits: assets/validation_582/RESULTS.md.
CA414-01 passed all author checks on 2026-10-24. The earlier isolated
CA414-PROTOTYPE-01 was accepted on 2026-10-24; no merge or completed V5.8 is claimed.
#413 remains accepted. Other issues keep their independent scope.

## 5.8.1 - Altitude and acclimatization (#413)

Implements the approved pressure/Air model, racial tolerance and persistent
Resilience-scaled adaptation. Players, NPCs and wait/travel projections share
the same rules; underwater deprivation remains separate. Coastal references
start at zero and Limbo is neutral. Additive revision-1 state avoids geometry or
inventory migration. 67 native assertions and static/package checks pass; player/NPC saves, hub
return and pre-feature rollback are verified. CA413-01 passed author acceptance
on 2026-10-23. Evidence: assets/validation_581/RESULTS.md. This does not complete V5.8.

## 5.8.0 - Connected-water feasibility (#414)

The first V5.8 patch implements the issue's required private native prototype.
Moving two swimmable 3D-floor control ceilings changes native immersion and
thermal sampling, conserves the pair's volume and leaves an isolated third
volume unchanged. Gates stop/resume transfer; map-local state and native planes
survive save/load and hub return. No campaign map or gameplay rule changes; two diagnostic release labels are synchronized.

This establishes feasibility for the tested horizontal, equal-area, closed
pair only. It does not establish arbitrary terrain, realistic flow rates,
concentration mixing, unattended calendar evolution or campaign completeness.
The existing source-quality reader does not read the control-sector metadata
in this fixture; that integration remains explicit #414 work. Authored geometry
is approved beside the mansion pool. The author approved two 32,000 L deposits,
a 20 cm connecting opening with discharge coefficient 0.62, potable left inflow
at 1 L/s to 1.75 m and right drainage at 1 L/s down to 0.25 m, including absence
at Limbo's 1:1 game-clock rate. Placement, controller and save-safe geometry
integration remain unimplemented. The author approved the existing container rule:
mixtures retain every contaminant present, without dilution-based purification. CA414-PROTOTYPE-01 passed on 2026-10-24; the earlier stage awaited
author acceptance. Evidence: assets/validation_580/RESULTS.md.

## 5.7.14 - Reusable mates (#472)

The approved first mate implementation supplies three native vessels, individual
contents/temperature, inventory and quick-use actions, twenty hot cebados,
washed/cold hydration, additive ten-second resource recovery, learned recipes
and purchase. Owned inventory sprites match the painted world billboards and include
the fixed bronze bombilla. No optional herbs or new herb effects are included.
Physical, crafting and acquisition data are documented in SYSTEMS and the
approved generator table. Evidence: assets/validation_5714/RESULTS.md.
The author passed all CA472-01 checks, including corrected historical artwork,
on 2026-10-23. The approved V5.7 author test queue is empty; V5.8 is next in order.
#471 has passed CA471-BATCH-01; the issues
retain independent branches, commits, evidence and PRs.

## 5.7.13 - Chemistry batches (#471)

The shared barrel now consumes the approved whole-litre ingredients at start,
continues by world deadline and permits partial collection without Chemistry.
Twenty-one attended recipes use protected ingredient/water reservations, fixed
yields and approved timings. Additive material/recipe/catalogue migrations preserve
old entries. Prices use approved ingredient costs and imports; identical consumables
use the cheapest recipe. Approved full-chain renewal replaces finite stock for
kits and nine consumables without resetting quantities. The final package passes
267 native assertions and byte-level comparison of all 16,746 entries; five
captures were inspected. Evidence is in validation_5713. CA471-BATCH-01 passed author acceptance on 2026-10-23; the historical 53-check foundation remains separate evidence.
The independent mate implementation remains #472.

## 5.7.12 - Fermentation Barrel infrastructure (#487)

Adds the approved fixed barrel beside Chemistry in MAP01/MAP03, with independent
revision-1 save installation, local station-network dependency and matching
wood/metal model and fallback sprite. Author-approved physical calibration yields
3,402 L useful capacity, displayed on the target panel. The old Chemistry station
and accepted recipes are retained. #471 still owns new fermentation batches and
recipe values. Evidence: assets/validation_5712. Static/package identity and 93
native assertions pass, plus one original-runtime rollback assertion. Six final
captures and deterministic assets were inspected. The author passed CA487-01 in
full on 2026-10-23, without qualifications; acceptance is recorded in HISTORY.

## 5.7.11 - Chemistry station terminology (#486)

The existing station is now named Chemistry / Química throughout the shared
station label and boiling failure feedback. Actor class, capability 12, editor
ID 18013, roster revision, artwork, placement and recipe requirements remain
unchanged. Old saves and tasks retain their identities. #487 owns the separate
Fermentation Barrel request; no barrel or new fermentation recipe is delivered
by this naming patch. Validation and author acceptance are recorded separately
in assets/validation_5711 and HISTORY.md. Static checks, full package/source
identity, two real Use assertions, old-save loading and four inspected native
captures pass. The author passed CA486-01 in full on 2026-10-23, without qualifications.

## 5.7.10 - Cartridge assembly at Alchemy (#471)

New carbine/shotgun cartridge tasks require Workbench + Alchemy. The two
accepted kit inputs, recipes, quantities, efficiency, work, learning and economy
remain unchanged. Arrows and bolts keep the Ranged Workshop requirement.
Revision-1 task migration preserves the original station for an already active
cartridge task, clears that exception on cancellation/completion, and mirrors it
to the travelling record. No new recipe or material IDs are introduced.

Validation: static checks and 186 native assertions pass; source/package bytes
match across all 16,724 entries. Two UI captures were inspected. Evidence:
assets/validation_5710. The author passed CA471-AMMO-01 in full on 2026-10-23,
without qualifications. This is only the station-migration
part of #471; new consumable/intermediate recipe values remain unresolved.
#409 is implemented separately; CA409-01 passed author acceptance on 2026-10-23.
Its completed dependency is integrated here: 31 focused native checks pass on
the combined full package, which matches src. See validation_5710/integration.
The author subsequently approved one fermentation batch per barrel, ingredient
consumption at start, discard without refunds on cancellation, and continued
fermentation after Chemistry disconnection. SYSTEMS records this pending design;
finished product may also be collected without Chemistry and in partial amounts,
keeping the remainder in the occupied barrel. Recipe values and batch
implementation remain outstanding.

## 5.7.9 - Water boiling and temperature (#409)

The approved thermal process is integrated with station reservations, ordinary
waiting and persistent inventory. All six capacities use the fixed glass
station vessel; portable canteens are never directly heated. Atomic completion
retains salt/chemicals, removes biological contamination, evaporates the approved
amount and returns 100 C water. Separate temperature guards cover direct and
automatic consumption; cancellation spends nothing.

The author approved the remaining glass-density datum (2,500 kg/m3) on
2026-10-23. Both bottle and canteen cooling now use the approved model; 117
native assertions pass on the completed package, including saved hot glass,
dropped bottles and dated waiting. The author passed CA409-01 on 2026-10-23
without qualifications. Other issues retain their
existing acceptance state and separate PRs.

Static validation passes. The preserved initial draft contains 91 native assertions,
including actual waiting, pause/save/load and original-save rollback. All 16,724
entries of that package match src; presentation-only corrections reuse
server checks after a byte comparison and have fresh visible UI captures.
The completed package also matches all 16,724 source entries; its exact hashes,
117 assertions and two inspected final UI captures are in completion_report.json.

## 5.7.8 - Support implements (#479, author accepted)

The approved support roles now connect to native selectors, local targeting,
health/damage/movement, recipes, merchant catalogues and item migration.
Quintessence is support only; Scepter/Orb inherit the old offensive roles for
the four elements with stable item IDs. SYSTEMS records the complete approved
stack, mitigation, fabrication and acquisition contract. Isolated integration
checks pass: 176 full-package assertions and two baseline/rollback checks.
The author rejected the initial low-poly art. Book/Statuette keep their accepted
sprites; four new painted designs cover the other implements and all three tiers.
Old elemental identities/learning survive; active effects resume after saves.
The correction passes 75 native checks on the 16,721-entry full package;
18 world/held views, 18 actual inventory rows and six T1 input/return sequences
were inspected. See assets/validation_578/RESULTS.md and HISTORY for CA479-01. The author accepted the other five designs and requested only that
the Orb lose its pedestal and float over the Book's open palm. That correction
passes 23 focused native checks on the 16,722-entry package. The author accepted
the Orb retest on 2026-10-22, completing visual approval. The remaining CA479-01
gameplay, acquisition and save/load checks passed author review on 2026-10-23.
The 2026-10-23 author run exposed a null-owner read when a curse killed its
recipient. The support tick now handles native inventory removal during damage.
Focused regression evidence is in validation_578/owner_death_report.json. The
author passed the lethal-curse/F2 retest and subsequently all remaining CA479-01
checks on 2026-10-23, without qualifications. Review/integration remains separate.

## 5.7.7 - Centered target information (#481)

The author requested a permanent version of the gallery information box at
the top center. The panel now identifies aimed actors and nearby native line
interactions, lists contextual keys and displays combatant resources/attributes.
Resources remain visible; each attribute requires strictly greater viewer
Insight. Native tracing and a local Use-range line query preserve occlusion;
no routine global actor scan is added. Saves reconstruct the transient cache.
Evidence: assets/validation_577/RESULTS.md. Author check CA481-01 passed on 2026-10-22.
#479 weapon/support migration remains a separate branch, test set and PR.

## 5.7.6 - Alchemy art stage (#471)

Prepared 11 matching transparent icons and 10 new original 3D models, reusing
the accepted iodine model. Its dedicated inventory/fallback icon is integrated;
other ingredients and regional deposit candidates await gameplay data. MAP03
will trade the regional minerals; no fictional Barracas deposit is installed.
This is a visual delivery within #471, not completion of its recipe, economy,
learning or station-migration scope. #409 boiling and #472 mate remain separate.
Static validation and 24 native checks pass; 33 model views were inspected.
Native and static evidence: `assets/validation_576/RESULTS.md`.
Author visual check CA471-ART-01 passed in full on 2026-10-22.

## 5.7.5 - Marine imports and iodine (#407)

Approved dried cachiyuyo (Macrocystis pyrifera) from the Patagonian coast is
available in MAP03 provisions shops: 1 kg initially, 0.1% of the maximum per
game day, base value 5 copper per 100 g. Alchemy with a connected Workbench
processes 100 g into a theoretical 1 g of iodine with 60 seconds of base work
and no extra fuel. Existing efficiency, learning and Dexterity apply; iodine
has the approved explicit base value of 10 copper/g and no new medical effect.
The ordinary library supplies its recipe sheet under the existing catalogue,
stock and price rules. No coastal map or natural marine node is introduced.
Two owned 3D material models accompany append-only material IDs 87/88 and
recipe ID 168. Revisioned migration preserves purchases, old recipes and tasks.
Evidence and author acceptance: assets/validation_575/RESULTS.md.
Static validation and two deterministic generations pass. Native checks:
263 PASS in 22 selected current runs, plus 19 PASS in three baseline/rollback
runs; zero FAIL. CA407-01 passed author review on 2026-10-22.
Next: #409 boiling, #471 consumables and #472 mate; remaining design decisions
are tracked in their respective issues. Each retains a separate patch/PR.

## 5.7.4 - Fixed Alchemy station (#470)

Adds the fixed Workbench-backed Alchemy station (#470), represented by an
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
the shared Workbench-plus-Alchemy capability check.
Static validation passes, including thirteen station bindings and two
deterministic generations. Final native evidence: 216 PASS / zero FAIL in
fifteen selected runs (assets/validation_574), including old/current saves,
blocked installation, travel, real Use and the existing task lifecycle with
Alchemy connected. Author check CA470-01 passed author review on 2026-10-22.
Next: #407 marine/iodine, #409 boiling, #471 recipes and #472 mate, with separate
issue branches, commits, tests and PRs.

## 5.7.3 - Monotonic source recovery (#406)

Natural sources retain the approved 0.1% of capacity per game day, capped at
capacity. A backward calendar observation no longer rewinds a source's credited
timestamp: returning to that time cannot apply the same recovery twice.
Catch-up remains constant-time and independent of merchant replenishment.
Recovery deadlines include the delay until a future credited stamp is reached.
Existing saved amounts, fractional carry and calendar IDs retain their authority;
no schema or balance change is introduced. Finite tutorial quotas remain finite.
Native regression and save compatibility: 100 PASS / zero FAIL in fourteen
selected runs, assets/validation_573. The author passed CA406-01 on 2026-10-22.
Next: #470 Alchemy, #407 marine/iodine, #409 boiling, #471 recipes and #472 mate,
with separate issue branches, commits, tests and PRs.

## 5.7.2 - Land resources and owned 3D objects (#405)

Approved MAP03 sources and MAP01 decorations now use original 3D models.
Six material IDs append to the catalogue; cotton retains ID 72. Plants use
existing slashing; each hive Use releases up to 50 g. MAP03 provisions import
yerba, irupe and cane; clothing shops import cotton with approved stock/recovery.
Existing merchant margins apply. No new processing/potion recipe is included.
Revisioned material/vendor migration preserves prior saves; map-owned issued
IDs prevent reload duplication, including real pre-feature MAP01 saves.
Evidence: assets/validation_572/RESULTS.md. The author passed CA405-01 on 2026-10-22.
Next: #406 recovery, #407 marine/iodine, #470 Alchemy, #409 boiling, #471 recipes,
#472 mate. Each retains separate scope, commits, tests and PR.

## 5.7.1 - Reviewed regional resource data (#404)

The existing-source audit and author-approved first MAP01/MAP03 resource
contract are recorded in SYSTEMS and assets/generators/resource_catalog.json.
Seven useful-source reserves/actions, regions and 0.1%-daily recovery are
approved; new MAP01 plants/hives are decorative, with collection in MAP03.
Remote plants and Patagonian brown algae use MAP03 imports. Algae -> iodine
is approved as abstract Alchemy processing. Exact placements and remaining
recipe/economy values stay explicit gates in #405/#407/#471/#472.
No gameplay or save-schema change; assets/validation_571 records the audit.

## 5.7.0 - Water quality foundation (#408)

The first independent V5.7 patch adds persistent biological/salt/chemical water
identity, conservative mixing, explicit collection/emptying, bilingual status
and unsafe-water rejection across drinking, rest and travel. Existing hydration,
container mass/capacity, potable refill and campaign placements remain intact.
Evidence: `assets/validation_570/RESULTS.md`; CA408-01 accepted by the author on 2026-10-21.
Boiling, Alchemy, land/marine sources, recipes and mate remain separate issues
#404-#407/#409/#470-#472. This is not completion of the V5.7 batch.

## 5.6.11a status — accepted batch and 3D clothing handoff (#387)

The author postponed clothing appearance until 3D character models are available
on 2026-10-21 and instructed merging/closing the current batch. PRs #397–401 are
merged separately; #379/#380/#383/#385 are closed. #387 closes its accepted
V5.6 object-art scope, while the unimplemented worn/preview/first-person coverage
and its visual/performance checks move to the V5.17 modular 3D migration below.
No current author tests remain. No wardrobe assignments or new model work are
authorized by this documentation patch. Earlier release snapshots below retain
the status at their delivery; this section supersedes their open-issue lists.

## 5.6.11 status — calendar replenishment (#385)

City shops now produce missing stock from complete recipe/component chains,
sequentially per product and concurrently across products. Civil calendar
catch-up is bounded by native stock targets; wallets, finite loot, tutorial
quotas and recipe-less products are excluded. Revision 1 preserves depleted old
shops without retroactive grants. Validation is recorded in assets/validation_5611
(14 native runs / 2,278 PASS / zero FAIL, static pass);
CA385-01 passed on 2026-10-21. #387 worn/preview/first-person art remains open.

## 5.6.10 status — city catalogues (#383)

Library/clothing replacements, signs, complete valid recipe/tier offers,
cartridge kits and paired lock/key commerce are implemented. Notebook purchases
preserve study, page weight, duplicate rejection and atomic payment. Numbered
catalogue migration preserves old merchandise and wallets. Static/native evidence
is kept in assets/validation_5610 (13 runs / 576 PASS / zero FAIL, static pass);
CA383-01 passed on 2026-10-21. #385
replenishment and #387 worn/preview/first-person coverage remain separate.

## 5.6.9 - Native cartridge assembly (#380)

Both approved prepared-kit recipes now use the existing crafting transaction,
learning and ammunition paths. Appended IDs and recipe-book revision 11 preserve
existing identities. Distinct kit sprites cover inventory and world pickups.
Evidence is maintained in assets/validation_569; CA380-01 passed on 2026-10-21.
#383 commerce, #385 renewal and #387 worn/preview/first-person clothing remain open.

## 5.6.8 - Approved sealed cartridge kits (#379)

The author approved one complete prepared kit per cartridge, 40 g carbine / 45 g
shotgun, priced at 80% of the existing finished cartridge base value. The final
table and implementation handoff are in SYSTEMS. This supersedes the pending
separate-component allocation. #380 owns assembly; #383 owns ranged-shop/library
availability; #385 owns finished-product restocking. No gameplay or art changed.

## 5.6.7 - Individual clothing object sprites (#387)

The 25 native garments now use distinct original inventory/crafting icons and
dropped-item sprites. Item identity and accepted #386 gameplay are preserved;
only local derived presentation is refreshed. Source prompts/hashes and a
reproducible technical exporter are retained under assets/art_source/clothing.
Validation: 12 native runs / 293 passing assertions, static/package checks.
Evidence and limits: assets/validation_567/RESULTS.md. CA387-01 passed on 2026-10-21.
Worn-character, preview and first-person coverage remain unfinished under #387.
#386 was accepted on 2026-10-21, merged through PR #396 and closed; #379, #380,
#383, #385 and #387 remain open with separate delivery scopes.

## 5.6.6 - Native ordinary clothing (#386)

The author-approved 25 garments are native items with one T1 recipe each, five
sizes and a separate head/body/hands/feet clothing layer. Armor retains its full
thermal profile. Clothes own their moisture, contribute real wet carried mass,
and retain identity through crafting, drops, Box, chest storage and travel.
ClothingRevision 1 converts the implicit outfit once, including legacy moisture
and the approved one-time capacity exception. Existing NPC outfit/loot stays
unchanged. Existing cloth art is a temporary inventory/world representation;
the #387 model brief and #383 vendor/library integration are separate work.
Validation: assets/validation_566/RESULTS.md. CA386-01 passed author acceptance
on 2026-10-21; #386 is ready for integration under the standing merge instruction.
The accepted PR batch #388–395 was merged on 2026-10-21, closing #376, #377,
#378, #381, #382 and #384. #379/#380/#383/#385/#387 remain outstanding.

## 5.6.4 - One-time death loot, existing tables (#384)

The author retained existing tables and narrowed #384 to one-time delivery.
Native death callbacks now reject reentry/repetition, and a revision-1 native
drop claim survives saves and resurrection. Frozen deaths reuse native effects
through the same guarded claim; old ice phases retain their remaining timer.
No new loot, quantity, chance, refill, ownership rule or map geometry is added.
Current MAP02 material quotas supersede the issue's historical 65-item baseline;
the legacy catalogue and already looted gaps remain intact.

Validation: 16 native runs / 113 passing assertions, plus separate old-code
regressions, static validation, normal packaging and independent review in
assets/validation_564. CA384-01 passed author review on 2026-10-20 and the batch merged on 2026-10-21. The #382/#386 proposals were approved on 2026-10-20; #387 art remains pending.

## 5.6.3b - Ordinary-clothing catalogue proposal (#386)

The requested review table is in SYSTEMS: 25 proposed native garments, 11 style/
season combinations, recipes and derived prices/work, thermal/armor layering,
and explicit initial/legacy entitlement. The author approved this table on
2026-10-20; gameplay follows in 5.6.6. The proposal itself changed no garments,
stock, saves or artwork. Its static evidence remains assets/validation_563b.

## 5.6.3a - Lock-tool proposal requested by the author (#382)

SYSTEMS records the proposal approved on 2026-10-20 covering acquisition,
steel recipes/masses, existing-margin prices, station access and lawful-title
rules. Confirmed padlock/key masses, geometry scaling and warning-only theft
remain separate. This delivery changes documentation and required diagnostic
release labels; #382 was implemented and accepted in 5.6.5. The frozen
5.6.3 CA378-01 package remains available; that author check passed on 2026-10-20.

## 5.6.3 - Physical recipe learning (#378)

Implemented the authored per-tier paper/book model, first learning, capped
rereading/practice and normalized 25% time base. Intelligence M3 controls reading;
existing source eligibility/material gifts remain. The new original bookshelf
stands opposite the MAP01 dummy. RecipeLearningRevision 1 retains old knowledge
and grants corresponding sheets. Native storage/save/travel use existing owners.
See SYSTEMS for the approved source table/formula and
`assets/validation_563/RESULTS.md` for validation and limits. CA378-01 passed author review on 2026-10-20. #383 owns approved library commerce/replacement of repeated shops;
#379-380/#382-387 remain separate issues. No merge is implied by that acceptance.

## 5.6.2 - Ordinary native storage (#381)

All stash-derived chests support native physical storage with the author's
10/25/100 slots, 100/1,000/10,000 kg capacity and 10% empty mass. Tier dimensions
double; the existing chest stays medium. Transport, placement, destruction,
reservation/temporary protection and exact transfer are integrated with the
inventory service and live menu. Native keys and existing reward quotas remain.
Revision-1 initialization and source-bound labyrinth policy preserve old gaps;
carried owners/contents and TIDs survive travel. Evidence and compatibility
limits: `assets/validation_562/RESULTS.md`. CA381-01 passed author review on 2026-10-20.
The issue has its own branch/PR above #377; #378 and other design-dependent
deliveries remain separate. No merge or author acceptance is implied.

## 5.6.1 - Merchant coordination (#377)

Thirteen pawn and five city-session policies delegate through compatible
adapters to `CaelumMerchantCoordinator`. Palomo's character record, the city
vendor's native inventory/wallet and session projection fields retain their
owners and serialized identities. `CaelumInventoryService` now prepares all
needed instances before either merchant family commits payment and products.
The city path rejects foreign sessions/items; Palomo rejects changed product,
quantity, mode or price rather than selling an equal-price replacement row.
Changing from city trade to Palomo clears the prior projection.

Scope is coordination and transaction correctness, with unchanged prices,
access, stock, wallets, recipe knowledge and replenishment policy. Evidence:
`assets/validation_561/RESULTS.md`; author check CA377-01 passed on 2026-10-20.
#378-387 remain separate dependent deliveries with the author's design inputs.

## 5.6.0 - Crafting planning and session extraction (#376)

The author's 2026-10-20 implementation request advances the first V5.6 issue
from planning to a focused runtime delivery. Forty-eight remaining planning,
preview, task and station-session methods now delegate to the stateless
`CaelumCraftingCoordinator`. The live pawn, explicit travel snapshots and
accepted inventory reservation/completion commits retain their owners.
All 653 pawn fields, 562 signatures and 514 other method bodies are preserved.
Native comparison, old/current save/reload, hub/non-hub travel and rollback
evidence are in `assets/validation_560/RESULTS.md`; author check CA376-01 passed
on 2026-10-20. No recipe, balance, station or save-schema revision is introduced.

The twelve-issue V5.6 batch retains separate scope, commits, tests and linked
PRs. #377 follows the crafting boundary. #378-387 retain their issue-specific
author decisions and dependencies; an implementation request does not supply
missing catalogue, component, ownership, capacity, renewal or artwork values.

## 5.5.8a - Close the deferred avalanche issue (#316)

On 2026-10-20 the author explicitly requested closure of the deferred issue.
#316 is closed as not planned; no avalanche feature or suitable map/encounter
has been implemented. This status supersedes older open/deferred issue notes,
while preserving the authored-map and design prerequisites. Any revival needs
a new focused issue and author-approved encounter/physical data.
PRs #370-373 integrated #363, #314, #315 and #369 with separate commits and
evidence. Their author decisions stand; the manual-test queue is empty.
This documentation patch only updates release diagnostic strings at runtime.

## 5.5.8 - Cleaned animated bull presentation (#369)

The author's GLB is cleaned, reduced, rigged and exported to native MD3 for all
bulls, including MAP01. Forehead/horn reconstruction follows the explicit
2026-10-19 decision. The author's inspection prompted centered facial geometry,
defined eyes and a bovine muzzle in the same pending delivery. The next review
adds matching body/head fur, brow/forehead locks and an explicitly approved
50% visual enlargement. Existing combat and physical dimensions remain unchanged.
Source provenance, editable art, deterministic export and isolated native
evidence are retained under `assets/source/art/bull_3d` and `assets/validation_558`.
The author accepted CA369-01 on 2026-10-20 and authorized merge/issue closure.
Performance callback
measurements do not establish display presentation/FPS acceptance. #363 and
#314 are accepted; #315's design-only delivery retains current damage; #316
remains deferred until a suitable authored map/encounter exists.

## 5.5.7 - Future melee energy contract; conversion deferred (#315)

The author decided on 2026-10-19: "Documentar el diseño y aplazar la conversión;
conservar el daño actual". SYSTEMS now separates the current damage pipeline
from a future energy candidate, inventories existing/missing data, and compares
T1-T3 weapon damage, nominal Air and thermal work. Worked matched player/NPC
calculations reuse Rulo's authored mass/Strength; they are not new character
defaults. Body-collision 1 J/HP and muscular work do not define blade damage.
No future impact coefficients or production conversion are approved. Required
speed, effective-mass, contact/material, penetration and resource calibration
remain author decisions for a focused follow-up. Current combat and saves remain
unchanged; only release diagnostics change at runtime. No manual test is queued
for a deferred design. Static validation and normal build pass; a final native
MAP01 compile/startup smoke passes. Packaged gameplay bytes match 5.5.6; only
release diagnostics differ. Independent review verified the nine comparisons
and their sources. Evidence: assets/validation_557/RESULTS.md.
#369 remains separate; #316 retains its authored-map
prerequisite and deferral.

## 5.5.6 - Ice and lava ground contact (#314)

The author approved a private test room with ice at -40 C and lava at 1,000 C,
using existing temperature exposure and damage. The approved first approximation
uses 100 W/m² K and the lowest anatomical row (1/16 of body area); the current
clothing path insulates it. Ground contact replaces that area's air exchange;
water takes priority. Jumping, flight and unsupported floors stop contact.
Native supporting floors and solid 3D platforms are distinguished. Current
temperature defenses and real-time damage remain authoritative; no direct lava
damage, elemental fire status or new immunity is added. The obsolete Pilgrim
Amparo reference is superseded by the existing Redemption rules (#250).
No campaign placement is authorized. Transient projections require no save
schema migration. Native evidence: assets/validation_556/RESULTS.md.
Static validation and normal packaging pass. Sixteen native runs contain 93
passing checks, including old/current saves, rollback and hub return. Independent
review found no blocker. Five performance windows retain simulation and render
callback tails; ETW access was denied, so no presentation/FPS acceptance is claimed.
The author accepted CA314-01 (origin 5.5.6 / #314) on 2026-10-19:
"La prueba dio correcto", without qualifications. Its pending entry is removed.
This confirmation reuses native evidence; it does not establish ETW presentation
or campaign placement acceptance. #315/#369 stay separate; #316 is deferred.

## 5.5.5 - Equipped-Seal input while unarmed (#363)

The unarmed fallback now opts into native User2 and delegates to the existing
equipped-Seal channel authority. Press starts, release keeps the channel active,
and a second press stops it; holding never creates repeated effects or payments.
Resource exhaustion, missing seals and cooldown retain their existing rules.
The new states are appended; previous state indices and saved fields are unchanged.
Native baseline/revised input, exact spending, rejection, old/current saves,
rollback and hub evidence are recorded in assets/validation_555/RESULTS.md.
Static validation and normal packaging pass. Independent review found no
production defect. The author accepted CA363-01 (origin 5.5.5 / #363) on
2026-10-19: "La prueba dio correcta", without qualifications. Its pending entry
is removed. Existing native evidence is reused; no new engine test or FPS claim.

## 5.5.4 - Ammunition mass and finished-component contract (#313)

The author selected Argentine Remington 1879 and late-nineteenth-century paper
12-bore shotgun references. Complete cartridge masses are explicitly approved
design approximations: 40 g carbine and 45 g shotgun, replacing the shared 3 g
placeholder. Historical exact component weights were not established. V5.6
receives a finished-component assembly contract; no playable recipe or new
material interaction is introduced. Count/type identities, magazines, damage,
armor penetration, shields and projectile physics retain their accepted rules.
Native validation_554: 12 required runs / 1,323 checks pass, including old-save
upgrade/rollback and unchanged defense rules. Build/static checks pass.
CA313-01 (origin 5.5.4 / #313) passed on 2026-10-19: the author confirmed
"La prueba dio bien", without qualifications. The confirmed pending entry is
removed. This acceptance reuses native evidence; no new engine test is claimed.
The author also authorized merging PRs #364-368 and closing #309-313.
#314, #315 and #363 remain open for a later session; #316 and campaign FPS
stay deferred.

## 5.5.3 - Sustained pressure lifecycle and native descent (#312)

Pending moving work now reaches the surviving receiver after its peer is
destroyed. Static pressure closes on support loss, non-solid/noclip interruption
and resident suspension; dead receivers discard the old interval before revival.
Existing energy, armor/cushioning, Toughness, capacity, creep and cadence remain.
Native ceiling pressure records local per-tic attempted descent, excluding pauses
instead of multiplying the whole pulse gap by the latest speed. Sampling revision
1 preserves saved samples; only pre-sampling tics in an old save's first pulse
retain the former approximation. No map geometry or native telefrag change.
Evidence: validation_553; 20 required native runs with 306 completed-phase checks,
including old/current saves and rollback. The visual smoke contributes no numeric
assertions. Project validation and normal packaging pass. The author accepted CA312-01 on 2026-10-19.
Campaign FPS remains deferred; #313–315 stay separate and #316 stays deferred.

## 5.5.2 - Persistent multiple-contact audit (#311)

A case-insensitive parameter shadow left ImpactContactState.ReleaseDistance at
zero, expiring pairs after five geometric separation checks even while callbacks
continued. Explicit field assignment and local revision-1 migration restore the
existing radius/height/margin rule. Contact identity, pending work and accepted
energy, anatomy and armor rules remain. Evidence: validation_552; all 24 required
native runs pass; author check CA311-01 was accepted on 2026-10-18. #312–315 remain separate;
#316 remains deferred and campaign FPS work is postponed.

## 5.5.1 - Bounded combat dispatch extraction (#310)

The combat portion of F2 now delegates equipped primary/secondary and sweep
coordination to stateless `CaelumCombatDispatch`. Compatible pawn adapters,
native weapon states, movement, start/commit functions and saved fields remain.
The sole added precondition is the established current, non-predicted pawn
authority check before any clock refresh or mutation. Source equivalence and
native comparison evidence: assets/validation_551. All 31 required native runs
pass; the 20 paired scenarios retain 1,793 identical observations. No FPS claim or new save
migration. CA310-01 passed author acceptance on 2026-10-18. Narrative F2 remains V5.9;
crafting/merchant coordination remains
V5.6. #311–315 and deferred #316 remain separate issues.

## 5.5.0 - Weapon/input audit (#309)

First V5.5 delivery: audit all 111 weapon/tool configurations and four input
routes, retaining authored gaps and accepted combat rules. Correct held Reload,
repeated empty-magazine reload requests and gauntlet uppercut classification.
Evidence and coverage: assets/validation_550. CA309-01 accepted 2026-10-18.
Combat extraction, impact/pressure audits, ammunition composition, thermal
surfaces and melee-physics design remain separate #310–315 deliveries.
#316 stays deferred until a suitable authored map exists. FPS remains deferred.

## 5.4.47 - Maximum siege adrenaline (#361)

The revised siege focus applies only to registered MAP03 NPC/monster attackers
and defenders. The player is always excluded to preserve seal-channel balance.
NPC wound calculations use their saturated result; real injury, inventory,
thermal/elemental effects and combat timers remain. Player adrenaline, needs,
wounds and seal spending/exhaustion retain their original rules. Existing
encounter ownership handles lifetime without new serialized state or scans.
Correctness evidence is in validation_5447; FPS evaluation is deferred. All
older CA318-01..05/CA327-01 functional checks were explicitly accepted Oct18.
The author also accepted revised NPC-only CA361-01 on 2026-10-18; the author
test queue is empty.

## 5.4.46 - Symmetric house-door Melt (#334)

The author now requests the existing exit Melt on entry too. House portals
capture their own view, retain it through native hub arrival protection, then
request Melt without changing global video settings. Cancellation and native
save/hub controls pass13 runs/82 checks in validation_5446. No map geometry or combat
rules change. The author accepted the other preview checks but reported a double
exit Melt. Its initial native pass now uses Fade on the held source; only the
final pass melts to the destination. CA334-02 passed on2026-10-18.

## 5.4.45 - Navigation markers are not breath targets (#357)

A real author autosave exposes 20 artillery Mandingas breathing continuously
at their own invisible route points. The shared breath reach/aim predicate now
rejects that technical class, retaining native chase flags and legitimate fire.
Native replay frees all 20 bodies; 41 isolated checks pass. No FPS gain is
inferred. CA353-01 and this group behavior were accepted on2026-10-18;
house presentation is separate #334 work. Evidence: validation_5445.

## 5.4.44 - Structural-cache research completed (#354)

A private candidate replaces 17 armor/personality guard reads per health/offense
query with owner-local notices at the inspected writers. Its 3,958 native checks
and two cached-read audits pass; all nine battle checkpoints match in 18 runs.
The paired FPS change is +0.20% city / +2.95% front, with a negative pair in each
view and substantial variation. This does not establish a consistent benefit
or stable 50 FPS. Retain the conservative production #353 guards; research remains
private. Evidence: validation_5444. CA353-01 remains pending. Next: localize
remaining update/render stalls; siege-adrenaline adoption remains separate.

## 5.4.43 - Production actor maintenance (#353)

The author adopted statistics/carried-weight caches, saturated-resource skips
and phased port attacker targeting from #318. They now activate automatically
at the existing map-wide threshold of 500 living shootable combatants. Movement,
physics, active recovery, combat timers and thermal cadence are retained.
Owner-local changes invalidate inventory caches; subscribed command groups are
notified when a target dies, is destroyed or travels. Save and hub checks cover
derived-state reconstruction. Native evidence passes 3,705 assertions, save/reload,
both hub legs and two combat cached-read audits without mismatches. Presented-frame
evidence is in validation_5443; author acceptance remains CA353-01.
Eighteen matched runs yield city34.40->46.80 and front20.58->32.20 median FPS.
All six paired comparisons improve, but broad control variation and high p99
times preclude a stable50FPS claim. These are this session's observations.
Further structural-guard reduction is a separate investigation, #354.

## 5.4.42 - Distributed actor maintenance experiment (#318)

The current diagnostic compares owner-local statistics/inventory caches,
saturated-resource skipping, grouped target100, thermal100 and author-approved
maximum siege adrenaline with explicit wound-formula simplification. Hunger/
thirst consumption and damage remain. Normal src gameplay is not replaced by
the prototype. The final native fixture passes 1,068 checks and three 700-tic
cache audits. Across 72 matched ETW windows, combined caches/resources yield
44.70/38.93 city/front FPS versus 43.52/37.55 baseline; target100 yields
51.26/46.50 but changes combat. Extra wound simplification has no consistent
FPS gain. Normal build/loading and static validation pass. Thermal100 is
not equivalent, and target100 changes combat response. The normal >=500 policy,
existing pending author checks and production integration requirement remain.
Evidence: [validation_5442](../assets/validation_5442/RESULTS.md).

## 5.4.41 - Isolated siege update costs (#318)

The author requested each measured family alone against all nine disabled.
66 native windows cover three repeats at two MAP03 cameras, retaining 600
soldiers, 998 Mandingas and all 8,910 actors. Target selection adds about 3.15
ms/tic; the residual combatant update adds 2.94-2.99 ms/tic in these instrumented
controls. Calls, population, poses and provenance pass their guards. This
prioritizes investigation, not removal of gameplay rules or an FPS guarantee.
Native bench snapshots remain distinct from unavailable ETW presentation data.
Evidence: [validation_5441](../assets/validation_5441/RESULTS.md). #318/#327
manual checks and production performance work remain open.

## 5.4.40 - Shared rest safety (#325)

Rest/T/Y share inclusive 32-m visible-enemy and cloud blocks. Existing periodic
injury/thermal damage continues; new attacks/death stop all modes. Local native
queries replace global Actor scans. Native 28 runs/278 assertions, review, validation/build and package equality
pass. CA325-01 was accepted by the author on 2026-10-18; validation_5440.

## 5.4.39 - Voluntary-jump wall cushioning (#339)

Native voluntary takeoff now retains the existing wall absorption through
descent. Falls/pushes without jumping do not arm it; immobilization still gives
zero capacity. Saves carry a revisioned, conservatively migrated pawn state.
Native 135 current/41 baseline assertions, validation/build and package equality
pass. CA339-01 was accepted by the author on 2026-10-18; validation_5439.

## 5.4.38 - Complete top-aligned map legend (#321)

The collapsed cartography panel now leaves only the localized show hint with
the actual bound key. Expanded content starts at the existing top margin.
Discovery/notes/tracking preferences are preserved. Five native runs/28 assertions, validation and normal packaging pass
in validation_5438; CA321-02 was accepted by the author on 2026-10-18.

## 5.4.37 - Current MAP03 attribution supplement (#318)

Eight native runs measure the accepted low-sky/private-house MAP03 and normal
100-per-350-tic deployment, with its 1,000-living admission cap and 600 defenders.
No production optimization or gameplay rule changes here. Peaceful city contains
2,203 actors and no active city defenders; residents occupy private interiors.
Both siege windows retain 600 defenders and 993-998 living Mandingas. Native
simulation stays near35tics/s, while unprofiled bench FPS snapshots are48 city/
35 front line. This does not establish stable60FPS or author acceptance.
The sampled combat-update and targeting scopes justify further measurement;
none is declared dispensable. Evidence: validation_5437; pending checks remain.

## 5.4.36 - House-door presentation isolation (#334)

The author requested no full-screen fade/wipe when entering or leaving a house,
while retaining loading icons and arrival autosaves. GZDoom already suppresses
the ordinary same-hub wipe. A real ship journey followed by an artificially
early approach to a real house portal reproduces a retained vehicle snapshot
inside that house. It does not prove the cause of the author's ordinary entry.
House portals now carry explicit presentation intent and discard that leftover
overlay. Native verification passes 8 runs/64 assertions, including normal
cart/ship presentation and both actual door-arrival autosave reloads. Independent
review, project validation/build and all16,375 source/tested/package members
agree. The author approved house transitions (CA334-01) on 2026-10-18; the
diagnostic attribution limit above remains unchanged.

## 5.4.35 - Replace competing prisoner escort movement (#322)

The same friendly sound reproduced 53 turns/504.804 MU of unwanted travel in
four seconds with the player stationary. Native Look/Chase fought the escort
owner; one-tic walking frames also continued during rest. One owner now controls
following and inert/moving poses; navigation/recovery retain native collision.
The author explicitly adopted player-formula walking with each prisoner's own
attributes and penalties on October 18. Native validation passes 23 runs/375
assertions: corners, doors, group stillness/resumption, floor levels, saves and
the full four-prisoner rescue/port-reward itinerary. All 16,375 normal package
members equal tested source. SYSTEMS owns the contract; validation_5435 holds
evidence. The author accepted CA322-01 on 2026-10-18. This approval does not
claim a new fix for the documented packed-row obstruction.

## 5.4.34 - Active-play autosaving (#324)

A single owner requests the native autosave after 300 real active seconds,
independent of accelerated calendar ticks. Pause, menus, console, dead/unready
players and loading time are excluded. Native slots/settings and manual saves
remain authoritative; Rulo's existing checkpoint shares the request owner.
Loading starts a fresh interval. The author's October 18 clarification preserves
map-transition autosaves and restarts five active minutes after the latest
autosave, including native arrivals. Native validation passes 36 runs/138 checks,
the full real interval and generated-file reloads. Build/validation and all
16,373 package members match the tested sources. CA324-01 was fully
accepted by the author on 2026-10-18, following the earlier bag/follower check.

## 5.4.33 - Isolate the western sewer crusher (#323)

The refuge corridor overwrote crusher 43921's local sector at (-5280,-1536),
linking it to 12,709,888 MU2 of western ceiling instead of 16,384 MU2. The
revision-5 generator finalizes the nine authored panels after upper corridors
and asserts their exact footprints survive the lower-network overlay. Only
sixteen existing 32-MU cells change group; other content remains identical.
Static/deterministic checks and native walking, all nine crusher cycles and
save/load verification pass; CA323-01 passed on 2026-10-17.
Revision-4 saves remain recoverable with the exact archived map via
-LegacyMap02Revision4; that mode deliberately retains the old geometry/defect.

## 5.4.32 - Direct demon projectile aim (#320)

The author's 2026-10-17 decision supersedes #259 dispersion for Mandinga fire
and Zupay stone projectiles only. Launches retain native target aim at release,
without homing or prediction; damage, resources, speed, range and other weapons
retain their rules. Evidence: assets/validation_5432; CA320-01 passed on
2026-10-17 for the direct-aim preview. Other coverage remains agent evidence.

## 5.4.31 - Collapsible automap help (#321)

The map legend is hidden on entry, with a live binding hint and a localized
Automap Controls entry. New/reset controls use L; existing controls remain.
Closing/loading/travel resets only this presentation. Native/UI evidence:
assets/validation_5431; author check CA321-01 accepted 2026-10-17.

## 5.4.30 - Sleeping bag quick-item access (#319)

The sleeping bag uses the native quick-item selector and opens the existing
rest interaction for the same owned object. Box storage excludes it. No map,
balance or save schema changes. Native input/ownership/persistence evidence is
in assets/validation_5430; author accepted CA319-01 on 2026-10-17.

## 5.4.29 - Adopt low-sky MAP03 and normal bounded reinforcements (#327)

Author decision, 2026-10-17: keep MAP01 (mansion) and MAP02 (sewers); make the
tested low-sky city MAP03. Other standalone scenarios are named test maps,
not numbered campaign chapters. The three-map campaign is MAP01 -> MAP02 ->
MAP03. Private CAH000..CAH159 interiors retain their identities and residents.
This adopts #318's tested geometry; it does not confirm all pending manual tests.

Normal city generation now uses 184-MU physical sky over residential/shop
districts, with the existing 1,024-MU exterior/wall/tower sky. House footprints,
street widths, roof elevations, signs and separate interiors stay unchanged.
Closed roofs use their opaque material; low districts restrict flight and roof
standing. The exact tested TEXTMAP is retained, with only its map marker renamed.

The author set a 6,600-Mandinga reserve, admitted at no more than 1,000 living
registered Mandingas before a new group, plus the existing Zupay and 600 soldiers.
Resurrection is explicitly preserved and can exceed that deployment cap; further
reinforcements wait. Existing victory still cancels unused reserves. See SYSTEMS
for authoritative cadence, save scope and map names. No 6,000-simultaneous test
is authorized. Existing #318 performance limitations remain; this is no 60-FPS claim.

Delivery evidence: assets/validation_5429; native/manual status in HISTORY and
pending_test.txt. Previous catalogue recovery: complete commit b9fd71ce, not an
old MAP06 WAD inserted into the new runtime. The author's old-save waiver applies.

## 5.4.28 - MAP06 audit, contact-only breath and scan policy (#318)

Variable-height sky follow-up (#318): the isolated city uses 184-MU physical sky over house/shop districts and retains 1,024 MU around walls, towers and the nonresidential exterior. Original house footprints, roof heights and street widths remain. Normal source MAP06, gameplay code and the normal package are unchanged.

Fresh paired ETW means (tall opaque walls versus zoned sky): exterior forward 280.79-284.08 versus 330.73-337.53 FPS; exterior ground 103.47-114.89 versus 121.75-123.65.
Within the residential street, forward means are 268.93-272.96 versus 261.85-268.56 FPS; ground-facing means are 205.90-244.94 versus 219.61-252.60.
With 600 defenders, the 1,000-attacker city view measures 3.85-5.05 versus 6.42-7.16 FPS and the front line 3.72-4.44 versus 3.53-4.39. The unchanged opaque control is substantially slower than in the earlier session despite identical package/config/population records; the cause is not established. Compare fresh pairs only, not historical FPS as a new baseline.

All 24 current matched measurement windows complete with ETW events bracketing their trimmed QPC intervals. The same observer is used across variants; full poses/options/populations are verified. Three successful native runs log 871 passing assertions. Two earlier fixture failures are retained and qualified. Deterministic map generation and exact package comparisons pass: only MAP06 and its cartography checksum differ from the corresponding house baseline.

During this batch the author permanently retired the 6,000-simultaneous-attacker scale. The final active test was stopped immediately; three already-completed runs and the interrupted fourth remain archived outside the current comparison. Never rerun that scale. Continue with peace and 1,000/600 controls; do not invent a new production budget.

The low sky limits flight and removes standing room on closed house roofs. Streets remain thermally outdoors; shops retain their real roof and windows. These are diagnostic geometry choices pending author review (CA318-05), not adopted production restrictions. No new army budget or playable full-siege guarantee follows.

Current follow-up: the author-approved house-hub prototype preserves all 160
exterior footprints/roof heights and the surrounding streets. Each front door
enters its own five-sector interior. Residents preserve individual bodies and
inventory across travel and emerge through their own doors at siege deployment.
MAP06 is reduced to 765 sectors / 42,945 lines; shops receive six trade signs.
Native portal, state, save/reload, status/death/blocked placement and 600-defender
deployment checks pass. Matched FPS measurements include an author-requested
diagnostic with the same interiors and house walls extended to the sky ceiling.
All 28 valid windows have ETW data. Peaceful forward/ground means are
36.62-37.03 / 28.54-29.76 FPS with ordinary shells and 402.03-405.19 /
165.66-166.03 with opaque closure. The 1,000-attacker central view improves
from 6.81-8.33 to 27.97-29.88 FPS; the front-line view does not improve
(24.76-24.89 versus 22.24-22.68). At 6,000 attackers both remain near 0.7 FPS
and 12 tics/s. CAH158 exceeds 1,000 FPS with three residents; this is not a
whole-city guarantee. The 13 functional runs and exact 16,370-member normal/
native/source check pass. Tall walls remain diagnostic. Normal attacker
deployment and author acceptance remain open.

The author-requested flat-map comparison is complete: 40 native measurements
cover 6,000/1,000 and 1,000/600 combatants, sprites/Domingo MODELDEF, inventory
removal, frozen render controls and sampled profiles. The 1,600-body battle
maintains about 35 tics/s; its 30-simulated-second windows average 53.54 FPS
with sprites and 43.76 with Domingo, versus 0.86/0.81 FPS at 7,000 bodies.
This is not stable 60 FPS: the 1,600-body sprite window has empirical p95/p99
frame intervals of 22.31/99.76 ms. Its final HUD snapshot near 77 FPS is a point
sample, not the window mean. Inventory removal improves onset, but sustained
1,600-body measurements (49.86/42.74 FPS) do not establish a lasting benefit;
weight, attack air, collision mass and longer combat outcomes also change.
Fixtures preserve individual bodies/resources/collision and omit MAP06's city
routes, carbine orders, cannons and reinforcement controller. No army total,
inventory rule or production art changes follow from these diagnostic results.
FLAT_VERIFICATION.json checks all populations, matching visual-variant end
states, empty inventories and process cleanup. CA-KP-119 records the limits.


The author reports an unresponsive November siege transition, a slow peaceful
600-soldier city, and further slowdown when looking down after one or two streets.
The audit reproduces poor city frame presentation independently of demons:
35 simulation tics/s can coexist with 8-12 application presents/s. Repeated
door removal improves presentation without making the city comfortably playable.
Native renderer counts and pinned GZDoom 4.14.2 source explain additional
ground-facing geometry work. Matched mansion/sewer entrance references exceed
60 application presents/s on the recorded PC; they are not full-route acceptance.

Evidence and qualifications: [validation_issue318](../assets/validation_issue318/RESULTS.md).
The author requires performance to be treated as an ongoing engineering priority;
KNOWN_PITFALLS records measured causes, candidate large-map techniques and test
requirements. The author additionally removed demon-breath radiation and chose
to retain absorbed contact power while a victim burns. This production change
uses local contact queries and normal thermal scheduling, with revisioned,
idempotent migration. Routine whole-world actor scans require a narrow measured
exception. A 1,000-attacker benchmark does not alter the normal encounter total.
#318 remains open: normal deployment still creates the full army together;
further geometry work, sustained-combat fluency and acceptance remain.
The authorized conservative map pass removes 11 redundant sectors and 24,565
open/redundant boundaries without changing physical walls, materials or actors.
Native probes at 3,006 positions match before/after and reload. Existing furnished
MAP06 campaigns had an exact `LegacyMap06Furnished` continuation checkpoint.
The author subsequently authorized native city doors and waived previous-save
compatibility. MAP06 now retains 960 visual leaves with finite native collision,
removing 7,680 scripted blockers; a local active-pair controller prevents thrust
and preserves normal paired operation. Other maps keep their accepted doors.
Fresh gameplay, current saves/hub return and measured performance are the gates;
the exact old map and recovery option remain available. CA-KP-118 records the
native collision, visual-physics and activation lessons.
The much faster closed-house experiment changes upper space and stays diagnostic.
Prior #304/#305 acceptance does not resolve this defect.

## 5.4.27 - Prisoner escort speed (#307)

At the author's request, ordinary prisoner following retains each actor's normal
resolved speed and shared movement penalties while seeking the existing nearby
radius. The author confirmed retaining recovery teleport. No new balance value
or persistent schema is introduced. Native checks pass 334 current-runtime and
14 legacy-control assertions, including movement, collision and save/hub identity.
Validation/build and all 16,193 packaged source members pass verification.
Evidence: validation_5427/RESULTS.md; delivery PR317, stacked on #305/PR308.
CA307-01 (origin 5.4.27/#307) passed author review on 2026-10-16 without reported
exceptions. The author confirmed all tests passed and authorized merge/closure
of #304, #305 and #307. pending_test.txt is empty; release 5.4.27 is unchanged.

## 5.4.26 - Active seal registry (#305)

Requested on 2026-10-16 after #304 identified repeated empty climate-channel
lookups. A transient per-map index tracks channel creation/destruction and is
rebuilt on load and map changes. Production physiology, seal formulas and AI
cadence remain unchanged. Native equivalence, current/previous-version saves
and hub checks pass (212 current-runtime assertions plus two legacy seed checks).
Repeated controls improve approach simulation from 18.0-18.3 to 28.7-29.3 tics/s,
and saved combat from 5.2-5.3 to 9.7 tics/s, retaining NPC thermal states and
matching sampled populations/projectiles. These are not displayed FPS and combat
still falls below 35 tics/s. See validation_5426 for methods, failed-attempt
retention, prior-profile reuse and qualifications. The author accepted #305 on
2026-10-16; delivery PR308 remains separate from #304/PR306.

## 5.4.25 - MAP06 performance diagnosis and corpse retention (#304)

The author requests 6,660 Mandingas in the finite diagnostic encounter budget,
at most 1,000 living simultaneously, NPC thermal on/off comparison, a 3-second
perception experiment, and soldier sprites versus the accepted Domingo 3D
prototype as a cosmetic substitute. Ordinary actor statistics and AI remain.
The production request is separate: keep only 100 recent corpses visible/active
in MAP06; retain older bodies hidden without simulation so Redemption can still
recover them, preserving dropped loot. This is not full memory reclamation.
Archive/save/hub/previous-version migration and 105-body Redemption native
checks pass, including restarting thermal scheduling without simulating dead
time. The study identifies repeated climate-seal lookups as a major cost and
measures 8/105-tic targeting and the prototype soldier model separately. Results,
raw evidence and qualifications are in validation_5425. CA304-01 (origin
5.4.25/#304) passed author review on 2026-10-16 without reported exceptions;
delivery PR306. Production physiology and target cadence remain unchanged.

## V5.4 accepted batch delivery - PR303

The 21 original issues (#237-254 and #259-261) plus #282-284 are complete within
their accepted scopes. All 24 focused PRs are merged and preserved in the final
integration history. The author confirmed the last check, CA284-01, and authorized
merge/closure on 2026-10-15. PR303 delivers this batch to main; no author checks
remain. Main's #276 roadmap additions and #283's modular 3D handoff are both
retained. Earlier version sections below are delivery checkpoints; their former
queues or merge restrictions are superseded by this current status.

## 5.4.24 - Demon combat and cosmetic rock (#284, accepted)

The separately scoped follow-up to accepted #283 preserves Mandinga's base
attributes, adds the approved Fire component and burn to its physical machete
impact, assigns the approved shared demon personalities and renders Zupay's
existing projectile as a 3D rock. The author requires one weighted Toughness
reduction after both components' defenses. PR302 contains the focused delivery. Combat/action, compatibility, rollback,
deterministic art and front/side rendering checks pass: 62 assertions across eight
scoped native runs, with source/build qualifications in validation_5424. Normal
packaging matches 16,192 source members. CA284-01 passed author review on 2026-10-15; batch merge/closure is authorized.

## 5.4.23 - Domingo native 3D prototype (#283, accepted)

The author accepted the corrected prototype and ended #283 on 2026-10-15.
CA283-02 is accepted; PR301 is ready. Editable Blender source and deterministic
MD3 export demonstrate native movement, attacks, rest poses, shield blocking,
ten-tic jump preparation and one-second landing through an opt-in player.
Default gameplay retains its existing sprites. validation_5423 separates native,
geometry, rendering, save and author-acceptance evidence.

The author clarified that later sprite work belongs to the roadmap rather than
an existing GitHub issue. The V5.17 presentation block below now owns migration
to mandatory modular 3D characters, remaining timed rest/provision animations,
finer polish and representative combat performance checks. The prototype's
fixed runtime surface does not satisfy that future modular contract. #284 keeps
its separately approved scope, branch and delivery.

## 5.4.22 - Quick-use inventory HUD (#282)

The author selected a carousel at the bottom center, with name/count above the
selected icon and smaller neighboring icons. It reuses native inventory input,
owned artwork, existing consumption and water-container identity. No inventory
schema or item balance changes. Evidence: validation_5422; CA282-01 passed
author review on 2026-10-15; PR300 is ready. Keep #283's editable Domingo model pilot and #284's
revised combat/personality/rock work in separate branches, commits and PRs.

## 5.4.21 - Local Seal climate and channel presentation (#252)

The authored five-Seal extensions now share the existing local weather/thermal
authority. Fire/Air/Water use growing cumulative contributions; Earth and released
Quintessence use a linear power ledger. The exact formulas and boundaries are in
SYSTEMS. Channeling adds native chasecam and a double-trap-size emblem at the feet.
Implementation starts at integration/v54-accepted-251-238 (a3b305b6); no unrelated
issue is included. Static validation, packaging and 233 assertions across 20
qualified native runs pass, including old-save migration and map travel. Evidence
and limitations: validation_5421. CA252-01 passed author review on 2026-10-15;
PR299 is ready. No merge/closure is claimed.

CA252-01 visual feedback requires the emblem on the ground and reports a face
instead of Water's image. The correction explicitly registers Water/Air sprites,
projects the mark onto ground and adds the requested cosmetic elemental sphere
above the head, using Arcane Sun's size. Focused revision evidence is recorded
in validation_5421: 142 assertions in nine native runs and ten inspected captures;
the subsequent sprite-depth correction adds 88 assertions and four qualified
runs. The author approved the corrected floor layering and the complete check.
The completed #237 audit precedes #282, then newly authorized #283 (Domingo 3D
pilot) and revised #284 (extra Mandinga Fire damage, demon personalities and
a cosmetic Zupay rock), each separately scoped. The author withdrew the Mandinga
attribute increase before implementation; retain its existing base attributes.


## 5.4.20 - Investigator Arcane Cloud (#251, accepted)

The original cloud asset now supports the complete shared User4 lifecycle,
seated native flight, attribute-scaled movement, downward restorative rain and
enemy-only Air-seal lightning. Existing clouds keep generating strikes under
War Cry. Inventory state preserves paid duration and pulse phases across saves
and travel; the cosmetic model is rebuilt at each destination. This fixes the
reproduced native crash from manually moving an unlinked visual between maps.
Focused evidence and limitations: validation_5420. CA251-01 passed author
review on 2026-10-15. PR281 is ready, separate from accepted #250 and pending #252.

## 5.4.19 - Pilgrim Redemption (#250)

The author approved a moving visible resurrection area, immediate/one-second
pulses, one revival per body/cast, full Health/Anima/Air/Lucidity and negative-status
removal. Former enemies are temporary allies; the caster and non-raised living
allies gain scaled x4 fixed Toughness reduction. Preserve loot/progression and
body identity, with travel and elapsed-journey lifetime. Implementation, static
checks, normal packaging and qualified native evidence are in validation_5419.
CA250-01 passed author review on 2026-10-15; PR298 is ready. No merge/closure.
Keep #251-252 and later #282 separately scoped.

## 5.4.18 - Battle Mage Summoning (#249)

The author confirmed aimed-ground placement, nearest visible fitting fallback,
automatic following/combat, replacement on recast, Empathy-scaled base attributes,
ally protection and disappearance without rewards. The same body follows between
maps with its saved state; elapsed long journeys consume its duration. Isolated
native validation passes in validation_5418: 132 assertions in 19 runs, including
copied-save upgrade/rollback/return. Static checks and normal packaging pass.
CA249-01 passed author review on 2026-10-15; PR297 is ready. #250-252 and #282
remain separate; no merge or issue closure is claimed.

## 5.4.17 - Cleric Rally (#248)

Arenga restores 10% current maximum Adrenaline per second to its caster and
visible allies in a moving area. Their current bars scale outgoing/incoming
damage after defenses; the strongest area applies. Empathy scales full factors,
recovery and duration. Shared preparation and cancellation remain authoritative.
Static checks, normal packaging and 74 qualified assertions in 15 native runs
pass on the focused branch above #247. CA248-01 passed author review on
2026-10-15; PR296 is ready. No merge is claimed. See SYSTEMS and validation_5417 for exact evidence and limits.

## 5.4.16 - Mercenary Formation Breaker (#247)

Rompeformaciones replaces the superseded Killer Instinct design. Its shared paid
User4 release enables forward double-tap ground traversals at four times running
speed, upright and with fixed direction, with tenfold biological cushioning and
final flat collision Toughness reduction. Empathy scales full factors and both
durations. Ordinary running Air consumption remains; only the impulse fee is
waived. Native input, collision, appearance and copied-save validation passes: 124
qualified assertions in 30 runs (hashes/reuse limits: assets/validation_5416).
Static validation and normal packaging pass. CA247-01 passed author review on 2026-10-15;
PR295 is ready for review. This focused
branch stacks on accepted #260; other classes/climate and #282 retain their scope.

## 5.4.15 - Player acceleration and directional impulse (#260)

Ordinary movement reaches full current speed linearly in 3 seconds per 100 kg of
body plus carried load. The authored 0.4-second double tap bypasses the ramp to
the current walk/run/crouch and full-direction cap, paying the running-equivalent
cost once. Native velocity/displacement, direction/stance, medium, payment,
interruption and copied-save checks are recorded in assets/validation_5415.
NPC movement is unchanged. CA260-01/02 passed on 2026-10-15; PR294 is ready
for review. #246/#253 passed separately. Remaining class and
climate issues, then #282, retain their own branches, tests and PRs.

## 5.4.14 - Mansion residents keep participating (#253)

The native assisted encounter reproduced the player's protected 1-HP floor and
stationary eligible residents. Their stored movement bases were zero; the repair
recovers missing authored bases on fresh spawn and old saves, preserving positive
custom values and finite resources. It is limited to anchored MAP01 residents.
Evidence: assets/validation_5414. CA253-01 and #246/CA246-01 passed author
review on 2026-10-15. This focused patch stacks on accepted #246.
The author has returned; remaining class/climate/impulse decisions are pending;
#282 remains after the batch.

## 5.4.13 - Mage Arcane Sun (#246)

Mage User4 now launches the revised large fire orb instead of Brainstorm discounts.
It crosses characters, burns visible nearby enemies, emits one homing shot each
second and ends with a native radial explosion plus 25 spherical straight shots.
The approved reference, social scaling, enemy-only policy and shared paid casting
are documented in SYSTEMS. This patch stacks on accepted #245. Focused automated
evidence is in assets/validation_5413; CA246-01 passed author review on 2026-10-15.
Remaining abilities and then #282 retain their separate scope and delivery.

## 5.4.12 - Priest Miracle (#245)

Priest User4 now restores Health, Lucidity, Anima and Air every second in a moving
area, including the caster and visible native allies. Each recipient contributes
its current resource maxima; base recovery is 3%, scaled by Empathy with duration.
Eloquence scales range and cost. The strongest overlapping area wins. This replaces
the historical 1% design. Shared paid preparation, cancellation and reuse remain.
Focused evidence: assets/validation_5412. CA245-01 passed author review on 2026-10-15;
PR291 stacks on accepted #244. Other abilities and #282 retain separate delivery.

## 5.4.11 - Explorer Survival Instinct (#244)

Explorer User4 now applies a temporary self benefit through the shared paid class
lifecycle. Current evasion, physical/magical accuracy and critical chance, and
Adrenaline earned in combat or from abilities receive the full 3x Empathy factor.
Existing probability/resource caps remain; tutorial/debug reserves do not gain
the bonus. Duration is the common ten-second base times Empathy. No negative-state
or survival-drain immunity remains from the superseded design. Native consumers,
combination and saved-effect evidence: assets/validation_5411. CA244-01 passed
author review on 2026-10-15; PR290 stacks on accepted #243.

## 5.4.10 - Warrior Battle Cry (#243)

Warrior User4 uses the accepted progressive-cost preparation and release cooldown.
It prohibits attacks by visible enemies in the release-time area, including bosses,
without preventing movement or defense. Attack preparations, continuous attacks,
offensive Seal channels and all Telekinesis stop; existing projectiles and applied
periodic damage remain. Siege operators can still move/load but only eligible
operators count toward each machine's existing attack requirement. Saved status
is recipient-owned and revisioned. Native evidence: assets/validation_5410.
CA243-01 passed author review on 2026-10-15; PR289 stacks on accepted #239.

## 5.4.9 - Beast Man Hunter's Instinct (#239)

The Beast Man User1 effect triples current stealth and physical/magical critical
chance from behind, then retains existing caps. Production movement-noise range
uses the effective stealth value; visual sensing remains outside this patch.
Projectile eligibility is captured at firing, while the rear 180-degree test uses
both actors' current positions at impact. Original chance/roll, critical damage,
attributes and existing spread/volley rules remain. The shared racial lifecycle
pays 10 Anima/second before modifiers. Native weapons, damage, noise, saved
effects/projectiles and compatibility evidence: assets/validation_549.
CA239-01 passed author review on 2026-10-15; PR288 stacks on accepted #240.

## 5.4.8 - Human Socialization (#240)

The Human User1 toggle doubles current Dialogue skill and Persuasion before
their existing limits, without changing saved attributes. Native dialogue keeps
paying 10 Anima/second before modifiers. Manual stop and exhaustion preserve
the multiplier of already displayed choices; new pages use the current effect.
Saved results cannot reroll. The shared racial controller handles interruption,
identity, payment and HUD state. Native input/checks, dialogue, persistence and
specific rollback evidence are in assets/validation_548. CA240-01 passed author
review on 2026-10-14. Its focused PR stacks on #241; other powers remain separate.

## 5.4.7 - Duende Telekinesis (#241)

User1 now captures one living body or movable scenery object and drives it with
the approved 1,000 N times magical-power force. Actual mass sets acceleration
and the 1 Anima/kg/s base cost; the target follows the capture-distance anchor.
Held bodies cannot act. Sight/range loss, interruption, exhaustion and map travel
release the body while native gravity, collision and ownership remain intact.
SYSTEMS records the exact scope, units and persistence contract. Native input,
real actors, save/load, hub and reversible 5.4.6 rollback checks are recorded in
assets/validation_547; CA241-01 passed author review on 2026-10-14. The focused PR stacks on #242.

## 5.4.6 - Caelith Supernatural Breathing (#242)

The Caelith User1 toggle routes all actual player Air demands through a common
payment service. Anima pays 1:1 after ordinary Air modifiers and then its own cost
reduction. There is no fixed drain. Insufficient Anima switches back to ordinary
Air for the complete effort without consuming the remainder. Native immersion
uses the same demand and does not create Air-recovery debt for Anima payments.
The creator describes the implemented bilingual power; the shared HUD/controller
and saved identity remain authoritative. Evidence: assets/validation_546.
CA242-01 passed author review on 2026-10-14. The focused branch stacks on #238; release 5.4.5
remains allocated to the separate #251 cloud artwork branch.

## 5.4.5 - Reusable rain-cloud asset (#251, in progress)

Added an original normalized 3D cloud, palette and soft-edge material, with
editable density-lobe source and deterministic generator. Native Vulkan and
OpenGL previews inspect volume/transparency from six orientations. This is an
asset checkpoint only: no production actor or ability activation is added.
Seated identity presentation, mounting/flight, rain, lightning and all associated
lifecycle/ownership rules remain pending. No weather system is implemented.
The author has returned; #251 stays open and PR281 stays draft while the
remaining gameplay decisions are collected. Evidence: assets/validation_545. The #238 checkpoint remains WIP.

## 5.4.4 - Shared class casting, ability HUD and Sleep (#238)

Production User4 prepares Arcanist Sleep over 105 tics: lower the current weapon,
raise empty fists, turn/open the palms, then release. The controller freezes the
admitted cost, spends it uniformly, retains cancelled spending and starts reuse
only at release. It blocks attacks, blocking, weapon changes and new power
activations while preserving movement. SYSTEMS records approved interruption and
attribute rules. The left class/racial HUD retains the existing power-column scale.
The author requested smaller class/racial glyphs; centered 64-unit icons now
approximate the visible Tarot/Seal size, with labels and countdown below.

Revised Sleep counts HP-losing impacts, multiplies final enemy damage through the
third waking hit, preserves ally/neutral exceptions and expires normally. Renewed
Sleep resets hits/power and retains the longer duration. Saved cast/debit and Sleep
state pass reload and native hub-return checks. Four missing creature bodies now
have eight living sleep views; their native pose/wake/save checks pass. The author
passed CA238-02 on 2026-10-14. The racial controller now serializes an optional
effect, handles native User1, pays each simulation tic and cleans up on forced
control, death or exhaustion. Native instrumentation/save/hub checks pass; real
effects stay in #239-242. A pinned 5.4.3 bridge now retains the new serialized
preparation/payment, racial and Sleep fields as inert data; native re-upgrade
resumes the paid cast and existing cooldown without duplication. CA238-01
(preparation/HUD) and CA238-02 (creature poses/wake) passed on 2026-10-14.
Evidence: validation_544. PR280 is ready for review; separate effects retain their
own issues and PRs. No additional author test, merge or closure is inferred.

## 5.4.3 - MAP02 rat movement and audio (#254)

Repaired a zero base-speed initialization and added revision-1 migration for
existing rats without replacing bodies or resetting their resources/drops.
All 192 rats initialize with positive speed; native pursuit and bites pass in
all four sections. Four original procedural cues have reproducible sources and
provenance. Evidence: assets/validation_543. The author passed CA254-01 movement
and listening checks on 2026-10-14, after returning. #238 continues separately;
no merge or closure is inferred from this acceptance.

## 5.4.2 - Equipped-Seal resistances (#261)

Implemented the approved passive factors, shared by player/NPC damage entry
points without new NPC equipment grants. Elemental metadata owns identification;
unknown magic is not inferred from colors or source actors. Existing equipment
state survives saves/travel with no new schema. Native checks, captures and
reproduction: assets/validation_542/RESULTS.md. The author clarified four
resistance families only: Quintessence protects them without a fifth resistance
of its own. CA261-01 passed on 2026-10-14 after the corrected manual recheck.
PR274 is ready for review; no merge or issue closure is inferred.

## 5.4.1 - Weapon dispersion tiers (#259)

The shared dispersion rule now combines authored family base, equipment tier and
Lucidity, with a tier-7 cap. Player and applicable NPC weapon consumers use it;
Type-3 precision, posture, book guidance and utility stream geometry remain.
No class/racial ability or saved schema change is part of this patch. Evidence:
assets/validation_541. CA259-01 passed on 2026-10-14; PR273 is ready for review.
No merge or closure is inferred. Next is #238.


## 5.4.0 - Attribute implementation audit (#237)

The 5.4 series begins with the refreshed twelve-attribute audit in SYSTEMS.
It traces saved identity, equipment and Tarot to derived values and real player/
NPC consumers, distinguishing partial/planned mechanics and assigning pending
decisions to V5.4 abilities, V5.6 content, V5.8 survival and V5.10 perception.
No runtime balance or save schema changed. The focused native audit passed 160
assertions; assets/validation_540 records evidence separately from inherited
author acceptance. Completion on 2026-10-15 refreshes the matrix against the
accepted 5.4.21 class/racial consumers and again passes 160 native assertions.
PR272 is ready; no extra gameplay test is assigned for this documentation audit.
Academic actions, broader need penalties, production senses and optional
player/NPC parity remain explicitly bounded future work. Next: #282, #283, #284.

## 5.3.9 - Connected exploration screens (#236)

Explore connects the existing Journal, formal Inventory, World, local automap
and note editor. Native mission/key/status commands route to the corresponding
Caelum views; owned keys/documents read native instances without new ownership
or quest state. Current documents have no authored readable body; the view
states that limitation. Control defaults and existing travel rules are unchanged.
Evidence: assets/validation_539; CA236-01 passed full author acceptance on 2026-10-14. Commit/PR delivery is separate
from author acceptance. Do not merge or close the batch without authorization.

## 5.3.8 - Saved independent mission tracking (#235)

Author-requested follow-up (2026-10-14): mark the current tracked destination
directly on the native map, restricted to known places. The existing target
symbol updates with the stage. CA235-02 passed author acceptance on 2026-10-14,
separately from the previously accepted CA235-01.

The author selected simultaneous tracking of several missions. Implemented a
Journal action, shared objective projection, bounded local-map summary and links
to already-known authored places. Active/completed/Other and main/side filters,
optional rescue/payment distinctions and captain history retain their contracts.
Additive revision-one preferences start unselected in older saves; presentation
does not grant progress or information. Exact NPC-disclosed coordinates without
a persisted disclosure event remain a documented design gap, with existing
spoken directions available as text.

The audit found legacy lesson updates activating slot 0 before Palomo and exposing
future objective flags. #235 corrects only the read-only visibility adapter to
follow the documented start/stage contract; original progress remains stored.
Evidence: assets/validation_538. CA235-01 passed full author acceptance on 2026-10-14.
#233/#234/#258 author checks are accepted. Next separate patch: #236.

## 5.3.7 - Existing-map exploration catalogue (#234)

Implemented discovery registrations for ten ordinary mansion rooms, its existing
beds/workshops/merchant, sewer grates and the fortified city's gates, towers and
services. Native map geometry and accepted access rules remain authoritative.
The author approved east-arch crossing and one marker per used south gate, and
deferred sector warnings until their knowledge rules are defined (2026-10-14).
Loaded-layout guards avoid applying current region coordinates to older maps;
revision-two knowledge preserves old facts with unknown access state.
Static/build checks and the focused native matrix passed. The author accepted
the mansion and sewer-padlock checks, then reported city gate icons and missing
factory stations. The city corrections add observed gate padlocks and individual
bindings for all 96 existing factory stations; 92 native assertions and five save
comparisons pass. The author accepted the focused city retest and save/load on
2026-10-14; CA234-01 passed full author acceptance on 2026-10-14.
Evidence: assets/validation_537. Next: #235 multi-mission tracking and
#236 Journal navigation, with separate commits, branches, tests and linked PRs.
Manual-note effects/predefined notes discussed on 2026-10-14 are possibilities,
not an authorized change to #233's player-authored annotations.

## 5.3.6 - Named manual map notes (#233)

Implemented center placement approved by the author, a native list/text editor,
six manual categories and independent revisioned per-character/map storage.
Stable identities and serial checks protect edit/delete/cancel and repeated
input. Native numbered marks, discoveries, quests and travel remain independent.
GZDoom compilation and native editing, persistence and presentation checks
passed. CA233-01 passed full author acceptance on 2026-10-14. Evidence: assets/validation_536.
Next: #234 authored registrations, #235 simultaneous tracked missions, #236
Journal navigation; separate branches, commits, validation and linked PRs.

## 5.3.5 - Known local services (#232)

Implemented per-character, revisioned local POI facts and conditional native
icons/names for beds, stations, merchants, exits and transport. Discovery uses
valid service interactions, including blocked services; old unrecorded discoveries remain unknown.
World/quest owners, native geometry and route permissions are preserved.
Evidence: assets/validation_535/RESULTS.md. CA232-01 accepted on 2026-10-14
after the corrected MAP04 handoff.
Authored map registrations remain #234, named notes #233, simultaneous mission
tracking #235 and Journal navigation #236, with separate commits/tests/PRs.

## 5.3.4 - Local cartography (#231)

Native exploration now has a paper/ink palette, location/local-time cartouche,
late-bound native control hints and a conditional objective integration point.
Discovery, navigation, marks, saves and user preferences stay engine-owned.
Mansion linework still projects overlapping storeys: no floor picker or new
auto-zoom policy is claimed. Evidence: assets/validation_534/RESULTS.md.
CA231-01 passed author acceptance on 2026-10-13. CA258-01 passed full author acceptance on 2026-10-14. #232–#236 remain separate issues, branches, tests and PRs.

## 5.3.3 - Exhaustion sleep (#258)

Zero Sleep now produces immediate lying at the current location, including
air/water, with ordinary physics and hazards. Standing remains unavailable
until Sleep exceeds 10%. Real support, shared recovery/provisions and
revisioned save/hub state preserve existing resources and acceleration rules.
Evidence: assets/validation_533/RESULTS.md. CA258-01 passed full author acceptance on 2026-10-14. #231-#236 remain separate.

## 5.3.2 - Automatic provisions (#257)

Food/water start independently below 50%, or toward 100% when seated/lying.
F/G pause only the rest filling; below 50% always re-arms. Native doses,
finite ownership, Box access and MAP01 refill remain authoritative. Shared
normal/accelerated/time-skip consumption prevents duplicate portions.
Evidence: assets/validation_532/RESULTS.md; CA257-01 passed author acceptance on 2026-10-13.
#258 exhaustion and #231-#236 remain separate patches. The existing time-skip
forecast omits evolving thermal resource costs; this is recorded for follow-up.

## 5.3.1 - Character survival, chances and resistances (#256)

Character owns Hunger/Thirst/Sleep/Exposure, all attributes, Tarot bonus and
live combat chances. Author-requested elemental resistance is the four-region
mean, expressed as 100% minus retained damage; Toughness is excluded.
HUD columns are Load/Lucidity/Health and Adrenaline/Anima/Air. Compact adverse
states remain beside powers, with bounded bilingual transition notices.
Evidence: assets/validation_531/RESULTS.md; CA256-01 passed author acceptance on 2026-10-13.
The remaining requested issues retain separate branches, commits and PRs.

## 5.3.0 - Power HUD layout (#255)

Seal/Tarot indicators double their reference dimensions and follow the actual
right viewport edge, with captions and a shared fit cap above retained bars.
Evidence: assets/validation_530. CA255-01 passed author acceptance on 2026-10-13. #256-#258 and
#231-#236 are separate requested deliveries, including #233 by author confirmation.
For #232/#234 the author chose interaction/use discovery on 2026-10-13.

## 5.2.27 - Magic Box empty mass (#229)

Author decision: the empty Box weighs 1 gram; contents retain their reduction.
The shared tare changes to 0.001 kg, with bilingual Palomo text and current rules
synchronized. Slots, transactions, rounding and saved inventory remain unchanged.
Evidence: assets/validation_5227. CA229-01 passed author acceptance on
2026-10-13 without qualifications; PR230 merge and #229 closure authorized.

## 5.2.26 - Rest controls feedback (#227)

T/F/G appeared inert to the author on new and loaded characters, by keyboard and
mouse, including a stocked chair. Isolated menu dispatch works; a verified UI
bug hid all rejection notices while the native menu was open. The rest panel now
shows its latest notification and labels existing acceleration x105. The reported
MAP02 chair has no table; the author approved serving carried/Box provisions
from both chairs and sleeping bags. Existing portions, native recovery, time
safety and table priority remain.
Evidence: assets/validation_5226. CA227-01 passed explicit author acceptance
on 2026-10-13 without qualifications, separately from the isolated checks.
PR228 is merged and #227 closed.

## 5.2.25 - Magical staff precision (#222)

The author selected the statuette's dispersion for the magical staff and kept
book homing. Staff base spread becomes 2-20 degrees per axis instead of 4-40,
across T1-T3. Type-3 Insight, crouching and impairment still modify accuracy.
Other weapon categories, damage, costs and saves remain. Native evidence:
assets/validation_5225. CA222-01 passed author acceptance on 2026-10-13.

## 5.2.24 - Mandinga potion fallback (#220)

The generated predefined-loot predicate incorrectly included all 96 mapped
Mandingas. It now derives from actual assignments: 38 Mandingas and 192 rats.
The other 58 Mandingas use the existing remaining-potion death rule. No loot
amounts, anchors, native supplies, death latches or save fields change. Existing
corpses are not retroactively populated. Native evidence: assets/validation_5224;
author check CA220-01 passed author acceptance on 2026-10-13. The subsequent #222 staff
adjustment was accepted in the same confirmation.

## 5.2.23 - Sleeping-bag acceleration in MAP02 (#219)

The author approved T/Y acceleration while sleeping with the existing owned bag
on dry, clear sewer ground outside authored safe zones. Existing combat, nearby
enemy, hazard and resource checks remain. The exception ends on waking or loss
of bag support; it grants no crafting or ordinary waiting permission. MAP02
already uses the exterior clock; no clock, comfort or save schema changes.
Native evidence: assets/validation_5223. CA219-01 passed author acceptance on 2026-10-13.
The reported missing Mandinga loot is tracked separately in #220.

## 5.2.22 - Current controls beside menu options (#215)

The author requested parenthesized controls throughout the game and explicitly
included native engine options. Existing arrows/Enter and contextual keys are
shown; no per-option shortcuts are introduced. Current bindings are resolved
at display time, including conflicts with native navigation and global actions.
Native subclasses preserve search, key capture, save/load and specialized options.
Evidence: assets/validation_5222. CA215-01 passed author acceptance on 2026-10-13; #213/PR214 and
#216/PR217 are earlier, separate patches accepted in the same confirmation.

## 5.2.21 - Visible tutorial gold (#216)

Fresh MAP01 games spawned the finite 2 kg gold actor with collision but no
model registration for its subclass. Register the existing gold-rock OBJ for
CaelumTutorialGoldVein; keep placement, harvesting, quota and depletion intact.
Native before/after captures and extraction/save-load checks are recorded in
assets/validation_5221. Author visual acceptance CA216-01 passed author acceptance on 2026-10-13.

## 5.2.20 - Resource bars at screen edges (#213)

The author requested the two resource groups at the lower left/right edges,
95% larger, with descriptions above each bar. Native HUD preferences still
control their base size; a measured viewport limit keeps the complete localized
labels inside the display. Frames, fills, icons and labels share each transform.
Long central reload/charge text moves above the groups only if it would overlap.
No resource rules, saves or menu preferences change. Native visual evidence:
assets/validation_5220. Author visual acceptance CA213-01 passed author acceptance on 2026-10-13.

Static validation and normal packaging pass. Final native render checks cover
1280x720/960x720 Spanish, 1600x675 English and 1920x1080 fullscreen with copied
user preferences. All 16,052 official runtime members match the tested package;
the user's INI is unchanged. Selected captures/logs and scope: validation_5220.

## 5.2.19 - Horizontal landing capacity (#211)

Replace the horizontal fractional Agility bonus with the recipient's landing
speed capacity times 1.5, explicitly approved for both player and charging
bull. Keep contact eligibility, active-buckler enhancement once, bilateral
energy and defenses. A later author amendment also applies 150% to falls for
all biologically cushioned bodies; actual jumping and crushing remain unchanged.
No save schema or art changes. Evidence: assets/validation_5219; CA211-01 passed
author gameplay acceptance on 2026-10-12 without qualifications. The author
authorized PR212 merge and #211 closure; no author checks remain pending.
350 native checks, static validation and normal packaging pass. Release 5.2.19
and the tested runtime remain unchanged.

## 5.2.18 - Modular pose, furniture and hand repairs (#209)

Repairs the author's post-acceptance visual report: authored four-phase running
and punch, buckling/kneeling/fallen death, supine sleep, shared head/body offsets,
clean alpha edges, scaled seat contact, sex-specific first-person hands and a
solid table canteen. Domingo supplies pose/anatomy references except the rear
attack; Revenant is a motion reference only, with no Doom artwork copied.
The author requested distinct female hands, including animal forms and worn
gloves. Combat, item identity, existing animation timing and saved structural
identity remain unchanged. Evidence: assets/validation_5218/RESULTS.md;
CA209-01 and CA209-02 passed author acceptance on 2026-10-12 without
qualifications. The author authorized PR210 merge and #209 closure; no checks
remain pending for this issue. Release 5.2.18 is unchanged.

## 5.2.17 - MAP01 player health floor (#207)

The author reported appearance reverting after death in MAP01 and requested
that the tutorial player remain alive at 1 HP. Damage now preserves the living
pawn/profile throughout MAP01, including the Bull fight; NPC rules and player
mortality on other maps remain unchanged. No automatic retry, regeneration,
save schema change or general respawn-appearance repair is introduced.
Native checks cover damage paths, identity, old/current saves and travel;
evidence: assets/validation_5217/RESULTS.md. CA207-01 passed author acceptance on
2026-10-12 without qualifications; the author authorized PR208 merge and #207
closure. No author checks remain for this patch.

## 5.2.16 - Fullscreen native cursor workaround (#204)

The author accepted Vulkan with native VSync enabled after two successful
fullscreen starts, MainMenu/Options/creator clicks and menu/gameplay capture
transitions. The existing launcher config receives only that approved preference;
no global default, renderer switch, gameplay or save change is introduced.
CA204-01 passed on 2026-10-12. Evidence and reproduction:
assets/validation_5216/RESULTS.md. Delivery includes the support documentation;
the author requested commit, push, PR205 merge and issue closure.

## 5.2.15 - Native readability and comfort (#150)

Shared presentation scaling now covers the custom HUD (including thermal),
messages, Journal/inventory/live panels, creator/preview and card menus.
The native crosshair is restored with its context rules and preferences.
A bilingual options group exposes existing scale, crosshair and motion options.
Author-approved notification overflow uses recent complete HUD messages plus a
saved, scrollable last-20 history in the Journal. Camera/weapon bob remains
native; accepted combat and #137 feedback are unchanged. Global presentation
preferences remain separate from saved identity. Native evidence and limits:
assets/validation_5215/RESULTS.md. CA150-01 passed author acceptance on
2026-10-12 without qualifications; the author requested PR203 merge and #150
closure. No author checks remain. #149/PR202 are closed/merged.

## 5.2.14 - Grouped native controls and current hints (#149)

Existing commands now appear under movement/interaction, combat/blocking,
abilities, weapon selection, Journal/inventory/time and map controls. Native
remapping, clearing, controller bindings, save/load menus and settings remain
owned by GZDoom. Actual normal bindings resolve in bilingual UI text.
Explicit native reset applies the seven approved Caelum defaults, including M
for automap; first-launch setup uses the same catalogue. Startup/load preserves
custom and cleared bindings. No powers, balance or exploration features added.
Evidence: assets/validation_5214/RESULTS.md. CA149-01 passed author acceptance on 2026-10-12; PR202 merged b36ef830 and #149 closed. #148 is complete: PR201 merged b21e0632 and issue closed.

## 5.2.13 - Native saved cosmetics and character preview (#148)

Implemented a rotating/animated native creator preview and an in-game cosmetic
editor using the single saved profile. Author-approved modular race/sex bodies,
finite skin/fur tones and four Beast Man forms share body/head/hand components.
Humans, goblins and Caelith also have four faces/four hairstyles per sex and six
hair colors, editable during play. A separate visual head uses native eight-view
registration with reusable anchors; it shares the saved profile and corpse snapshot.
First-person skin/fur follows the profile; actual equipped gloves select covered
hands. Voices remain automatic by saved sex. No gameplay balance or respec is
introduced. Existing saves initialize default appearance once and retain it
across reload/restart/travel. Sources, limitations and supported matrix: ASSETS.

Static, deterministic-generator and isolated GZDoom evidence is recorded in
assets/validation_5213/RESULTS.md. CA148-01 passed author acceptance on
2026-10-12, including the face/hair extension (c713e720 / 4aeddb8b).
The author authorized PR201 merge and #148 closure; no author checks remain.
The preceding PR200 is merged as 74c31ca5 and #195 is closed; its acceptance holds.

## 5.2.12 - Bull balance and finite resident tools (#195)

Implemented the approved 10 m/s cap, one-second linear acceleration, target
tracking and biological cushioning with normal collision mass. Mansion residents
activate their finite tools and approved combat weapons, with real sequential
charge timing and fire avoidance. Eight resident/prisoner personalities now use
shared #192 rules; prisoners receive no additional equipment. Versioned old-save
initialization and current item/charge persistence are tested. Evidence and
limitations: assets/validation_5212/RESULTS.md. CA195-01 accepted 2026-10-11 without qualifications.
Delivery: PR200 on `issue195-bull-balance`, committed and pushed; merge/closure authorized.
The previous accepted PR198/PR199 are merged; issues #192/#194 are closed.

## 5.2.11 - Bilateral collision energy (#194)

Implemented the author's 1 J = 1 raw HP rule from reduced mass and relative
normal speed. Each body receives independent area/armor/cushioning mitigation,
then final mass-based Toughness once. Anchored gates, walls, landings, moving
scenery, cannonballs and rams share the energy contract; the ram self-damage
exception remains. Cannon armor penetration is removed at the author's request.
Sustained moving pressure, static load and stone crushing ceilings use work,
including the approved immobile-load approximation. Native tests and limitations
are recorded in assets/validation_5211/RESULTS.md. The author accepted CA194-01
on 2026-10-11 without qualifications; the author test queue is empty.
#195 bull balance is separate. The accepted #192 amendment is merged into main
through PR198. Accepted delivery: PR199 on `issue194-collision-energy`, now
targeting main; the author explicitly authorized merge and #194 closure.

## 5.2.10 - Ranged penetration and shotgun naming (#192 amendment)

Implemented the author's reopened scope: longbow 20/30/40% and crossbow
40/50/60% equipped-armor bypass; all four ranged families exclude offensive
ideology against armor and shields. Firearm values, defensive ideology,
innate defense, Toughness and base damage/scaling are preserved. Active names
for the replaced weapon now identify the shotgun. Historical art bytes and
release records retain their provenance. Fresh test saves are author-authorized.
Evidence: assets/validation_5210/RESULTS.md. CA192-02 passed author acceptance on
2026-10-11 without qualifications; HISTORY preserves the originating evidence. Commit/push are complete;
#192 is closed again at the author's request. PR198 merged into main on 2026-10-11.

## 5.2.9 - Four personality layers and twelve-projectile bell (#192)

Implemented native/legacy creator choices, authoritative revisioned persistence,
shared magical power (damage, push, heat), chance/adrenaline modifiers and
layer-specific armor/shield penetration/absorption. The bell has twelve
individually mitigated projectiles. Native impact ordering now prevents a
projectile's prepared damage from replacing its already-mitigated remainder;
soldier shields participate in the same order. Existing saves receive the
author-approved Normal/Normal/Normal/Center defaults.
Evidence: assets/validation_529/RESULTS.md. The author accepted CA192-01 and
CA188-01 on 2026-10-11 without qualifications and authorized PR193 followed by
PR196 and #188/#192 closure. HISTORY records this acceptance separately from
agent checks. At that acceptance the author queue was empty; the separate #148 roadmap remains.

## 5.2.8 - Mass-based Toughness and status resistance (#188)

Physical damage now subtracts biological mass times Type 3 after defenses;
direct magic subtracts half. Gates use structural mass. Armor/shield wear can
occur even when the final HP loss is zero. Explosions/impacts subtract once
after regional defenses. Burn/poison/disease use Type-1 duration resistance,
immunity at 100 and healing above 100, recalculating active effects when
Toughness changes. Thermal environmental rules and projectile status scaling
from actual HP lost are preserved. Revisioned legacy status import is idempotent.
Static and isolated GZDoom evidence: assets/validation_528/RESULTS.md.
CA188-01 passed author acceptance on 2026-10-11 using the combined 5.2.9 build,
including #192's native projectile correction. PR193 merge/#188 closure are
authorized; #192 is delivered separately through PR196.

## 5.2.7 - Native ownership for all interactive screens (#189)

Journal pages, calendar, equipment, chests, merchant, journey, rest, crafting,
time skip and the reachable legacy creator now use a shared native ListMenu.
Artwork and gameplay handlers remain authoritative. The normal creator gains
mouse controls; NPC replies use native wrapped hit regions with guarded release.
NPC dialogue retains its already-live simulation. Cards and Escape/settings
retain native pause. Rest uses right-button dragging to orbit and left clicks
for controls. Static/native/physical evidence: assets/validation_527/RESULTS.md.
CA184-01 and CA189-01 passed author acceptance on 2026-10-11 without
qualifications. The author authorized PR190/PR191 merges and #184/#189 closure;
the pending author queue is empty. Release 5.2.7 is unchanged by acceptance.

## 5.2.6 - Mouse interaction in game menus (#184)

Truco/Trucazo, crafting and time skip now share press/release pointer guards
and expose their existing actions through visible mouse controls. Card menus
retain native pause; Journal panels remain live. Static and isolated GZDoom
4.14.2 evidence is recorded in assets/validation_526/RESULTS.md; CA184-01 passed
author acceptance on 2026-10-11. The author requested native-menu migration next in #189,
including clickable, unpaused NPC conversations; cards must retain their pause.

## 5.2.5 - Indexed NPC dialogue sources (#185)

Delivered after #183/PR186 on a separate branch. Each named NPC/archetype now
owns one source under src/dialogues/npc; non-NPC services live under shared.
The main index.json selects sources and preserves all 53 conversations/422
pages in their prior runtime order. Deterministic assembly avoids shifting
native saved node offsets. LANGUAGE remains authoritative and unchanged;
its generated index covers 2,369 keys, including shared UI. Build/validation
reject stale artifacts. Evidence: assets/validation_525/RESULTS.md. The author
accepted #185 and CA183-01 on 2026-10-11 without qualifications; PR187
merge/closure authorized, PR186 merged/#183 closed. The author queue is empty.

## 5.2.4 - Simplified onboarding and MAP02 supplies (#183)

Implemented editable creator recommendations, fixed profession kits distributed
through the four residents, Seal-only Palomo choice, a finite 2 kg gold exchange
and three mandatory utility crafts. The shared Box capacity/content divisor is
20 + floor(10 × Type3 multiplier). Actual gifts, crafted bag/canteen/Seal, matching
ammunition and physical Tarot deck travel inside it with their state preserved.
MAP02 retains 600 allocated rounds as 360 arrows/240 bolts. Its 39 chests share
the initial kit's exact repair budget, with five manufactured replacement bolas
as explicitly corrected by the author. Existing assets and native transactions
are reused. SYSTEMS is the design contract; assets/validation_524 records evidence.

The author waived pre-release save migration for this test environment; begin a
new game. Agent/native verification is separate from author acceptance.
CA183-01 passed on 2026-10-11 without qualifications; merge/closure authorized. The requested next change is #185: per-NPC sources in a dedicated
src directory, a main index, and localization indexing. #148 remains separate.

## 5.2.3 - Allied Mandinga retaliation (#180)

The author's live fire-breath report is reproduced and corrected through native
target eligibility. Allied Mandingas keep their legitimate opponent after burn
damage; existing accidental target/lastenemy references are cleared in place.
Damage, thermal transfer, resources and opposite/scripted hostility remain.
Evidence: assets/validation_523. CA180-01 passed author acceptance on 2026-10-11
without qualifications; PR182 merge/#180 closure authorized. CA178-01, CA177-01
and CA147-01 also passed. The author test queue is empty; next roadmap is #148.

## 5.2.2 - Faster time skipping (#178)

The author's multi-day wait report led to a larger forecast budget and a shared
crafting-network validation for each stationary simulation batch. Personal tics,
inventory consumption, sleep and interruptions still execute normally. Native
timings, cancellation/network and siege checks: assets/validation_522. CA178-01
passed author acceptance on 2026-10-11 without qualifications; PR181 is merged
and #178 closed. The separate Mandinga correction is accepted under #180.

## 5.2.1 - Tutorial usability and portable rest (#177)

Follow-up to the author's #147 testing: received tutorial weapons autoequip,
Bull room movement uses physical boundaries, and Palomo's shotgun text and
necklace ordering match the current choices. The basement chest exposes the
existing one-time material plan through the maze loot interface as choices are
confirmed. Mansion food/water are explicitly unlimited, with replenished large
5 L canteens and matching task forecasts. Palomo supplies a sleeping bag at the
final gift; MAP02 fixed beds retire safely from both fresh and saved maps.

Evidence: assets/validation_521. CA177-01 passed author acceptance on 2026-10-11
without qualifications; PR179 is merged and #177 closed.
Next planned roadmap block remains #148; #149/#150 stay separate.

## 5.2.0 - Unified character identity (#147)

The first V5.2 block makes the travelling character record own the shared
profile/allocation. Revision 1 adopts existing saves without changing their
progress, equipment or resource values. The creator remains authoritative;
native player type and network preferences cannot replace race or profession.
The author requested retaining unconfirmed drafts during the engine session.

Redundant native class/gender/skin/color selectors and the misleading stock
preview are hidden. Existing name/team and handling preferences remain native.
The additional author request removes debug binding rows and places abilities,
flight, Journal and time skip in their native categories, retaining console
commands and existing mappings. This does not complete the remaining #149 work.

Evidence: assets/validation_520. CA147-01 passed author acceptance on 2026-10-11
without qualifications; PR176 is merged and #147 closed. Next planned block:
#148 appearance/preview using the shared identity interface. #164/#172/#173
were accepted, closed and merged through PR171/PR174/PR175; their historical
baseline is f7c4a0dd. #137's earlier acceptance remains intact.

## 5.1.20 - MAP06 doors and peaceful time skip (#173)

Current MAP06 gains native hinged doors in each existing bedroom/bathroom
opening. Runtime revision 1 preserves the exact map geometry and old city saves;
occupied openings wait until clear. Before the established siege date the city
allows time skip under ordinary safety rules. The existing calendar interruption
stops it at the siege boundary. Evidence: validation_5120; CA173-01 passed author
acceptance on 2026-10-10, with PR175 merge/#173 closure authorized.

## 5.1.19 - NPC dialogue history (#172)

Read informational answers disappear from ordinary NPC choices. A bottom
Repeat dialogues option opens the same speaker's saved information without
executing actions again. Navigation to gameplay, purchases, crafting, quest
acceptance/turn-in and departure remain available. Shared native-menu behavior
covers all NPC menu subclasses. History uses stable per-speaker text keys in
the persistent character record; old saves start empty. CA172-01 passed author
acceptance on 2026-10-10; PR174 merged and #172 closed.

## 5.1.18 - MAP01 permanent gifts and checkpoint (#164)

Argento's physical deck, Caella's utility staff, Ronnie's existing Pickaxe and
Rulo's bolas are permanent one-time gifts. Only the chosen weapon must be crafted;
other crafting and Seal Channel are optional. Palomo grants the Box after the
mandatory route and assisted Bull victory. The existing party prepares before
a native pre-fight autosave, without a new heal/refill; death requires manual
loading. Save migration preserves old equipment and recorded progress.
Details: SYSTEMS and MAP01; native evidence: assets/validation_5118. Author check
CA164-01 passed on 2026-10-10; PR171 merged and #164 closed. No author checks
remain pending. #162/#163/#169 were accepted, closed and merged through
PR167/PR168/PR170 on 2026-10-10.

## 5.1.17 - Medikit names (#169)

The author reported that existing health kits still displayed as life potions
and selected Spanish botiquín. Shared English/Spanish labels now identify all
three sizes and pickup text as medikit/botiquín. Native UI evidence is in
assets/validation_5117; this localization-only patch preserves saved identities
and all #135 consumable behavior. Author accepted #169 and CA162-01/CA163-01
on 2026-10-10; all three are merged/closed. The dependent #164 is also accepted.

## 5.1.16 - Recoverable bolas (#163)

Implemented the single-tier family-1 Boleadora / Bolas, approved bronze/leather
recipe and physical reference, one-second accuracy preparation, real recoverable
flight and five-second movement/attack restraint. Fire, shared-speed cutting
and one Strength roll govern destruction. Paid own demon breath can burn ropes.
Native equipment identity and previous saves are preserved. The author-requested
visual correction adds hanging rest weights, 3 Hz spin and body-occluded rear
rope arcs, including migration of previously bound saves. Follow-up feedback
extends the bolas forearm and makes immediate paid demon escape visibly burn. Evidence and exact
validation scope: assets/validation_5116/RESULTS.md. Author visual/handling
acceptance CA163-01 passed on 2026-10-10; Rulo's permanent grant belongs to #164.
The author authorized PR168 merge and #163 closure.

## 5.1.15 - Bronze utility staff and wand names (#162)

Implemented a single-tier family-1 fire/ice tool using the Pickaxe recipe and
durability, shared demon-breath thermal geometry, continuous Anima payment and
per-second contact wear. Existing magic staffs are now displayed as Wands /
Varitas, retaining IDs and saves. Original bronze-tip poses, pickup/icon and
native elemental effects are integrated. Isolated native checks cover mechanics,
crafting/repair/dismantling, real controls, sustained heat/cooling, item lifecycle,
hub travel and migration from 5.1.14. Evidence: assets/validation_5115/RESULTS.md.
Author handling/art check CA162-01 passed on 2026-10-10; merge/closure authorized. Caella's permanent gift and the
corresponding full tutorial test belong to dependent issue #164; no completion
of that progression is claimed here.

## 5.1.14 - Damage flash across map travel (#165)

The protected loco-map02 checkpoint kept an old MAP01 damage timestamp, producing
a negative flash age and a fully opaque red view after the level clock reset.
It was near the authored MAP02 entry; flight had expired normally by the save.
Shared bounded flash evaluation rejects future/expired timestamps, actual travel
clears the transient flash, and visual revision 2 clears older saved flash state
once. No Health, position, inventory, Tarot or damage-balance change. Native
render comparisons and 34 checks pass, including airborne departure/arrival,
active flight/cooldown retention, grounded hub return and save/reload. CA165-01
was accepted by the author on 2026-10-10, with #165 closure/PR166 merge requested.
Evidence: assets/validation_5114; acceptance: HISTORY. #158 and #160 are
accepted/closed, with PR159 and PR161 merged on 2026-10-10.

## 5.1.13 - Argento silver-key handoff (#160)

The inventory ownership guard correctly rejected a key still owned by Argento;
the dialogue therefore failed with a generic native refusal. The handoff now
removes his existing key from his native inventory before checking pickup weight,
restoring that same instance on failure. No replacement key, quest bypass or save
migration. Twenty native action/ownership/lock/reload checks passed against the
protected llave-plata checkpoint; CA160-01 accepted 2026-10-10. Evidence:
assets/validation_5113. The author authorized #158/PR159 then #160/PR161 closure/merge.

## 5.1.12 - Preserve crafting equipment size (#158)

Fixed-size recipe previews and completions retain the artisan's equipment size;
fixed-size output metadata remains canonical M. The protected materiales-palomo
checkpoint has enough raw stock for its recorded XS/T1/100% staff and shield.
Its saved M menu choice explains the apparent shortage; choose XS once in that
save. No allowance, recipe, save-schema or balance change. Native regression,
original-stock transactions and save/reload passed; CA158-01 accepted by the author on 2026-10-10. Evidence: assets/validation_5112. #154/PR155 and #156/PR157 are
accepted, closed and merged.

## 5.1.11 - Time-skip letter controls (#156)

Q and R now recognize the native character code, matching the other Journal
panels. The author's protected craft-tiempo checkpoint retains completed work;
Enter requires a future destination and does not repeat completed crafting.
No clock policy, balance, save schema or migration changes. Native callback/state
checks and save/reload passed; the author accepted CA156-01 on 2026-10-10.
Evidence: assets/validation_5111. PR157 follows #154 / PR155; the author requested
both merges and issue closures. All author checks are accepted; the queue is empty.

## 5.1.10 — SI physics and growth migration (#154)

Three shared growth families replace the old curves, with per-consumer operations
preserved. Mechanical units stay 32 MU/m and 35 tics/s; ordinary gravity is 9.81
m/s2. Unpenalized player walk/run is 4/8 m/s at Agility 0 and 16/32 at 100.
Jump uses biological-mass/Agility energy and total moved mass. Muscular efficiency
is 25–99%, reaching 50% at Agility/Dexterity 100. Physical projectiles fall and NPC
shots compensate drop once at launch; elemental flight stays authored.

One-time migration preserves resource percentages, attributes, inventory and
accrued thermal state. Map geometry is unchanged. Detailed rules: SYSTEMS;
reproducible native/static evidence: assets/validation_5110. The author accepted
CA154-01/02 without reported qualifications on 2026-10-10 and requested issue
closure and PR155 merge. HISTORY records the confirmed test IDs.

## 5.1.9 - Shotgun pickup, grip and alternate aim follow-up (#152)

The author's `Prueba` checkpoint reproduced a carried cartridge stack still
rendering as a world pickup. Distinct-ammunition acquisition now completes the
native held-item transition; an idempotent flag-based repair also fixes already
owned stacks when an old save runs, retaining quantities and Box placement.
Ranged alternate aim toggles once per press, independently of the Zoom key.
Shotgun ready/open grips now use one complete pair below the weapon; the duplicate
foreground support hand is removed. Revised brown gloves, red cuffs and dark
bracers match Domingo's existing costume. Loading stays foreground. Cartridge
world art uses the author-approved 6 cm reference; mass and quantity are unchanged.
Native evidence and limitations: assets/validation_519/RESULTS.md. The author
accepted CA152-01/02/03 on 2026-10-09 and requested PR #153 merge and #152 closure.
Thermal observations are diagnosed, not recalibrated: full-height
native-gravity stairs and the approved fixed human jump use different budgets;
beastfolk fur water/insulation and a metabolic-power redesign await author design.

## 5.1.8 - Elemental presentation and proportional screen feedback (#137)

The author selected more intense elemental visuals, luminous projectiles and
3D arrows, bolts, bullets, pellets and javelins. One shared presentation layer
covers every existing magical weapon family/tier and player/NPC projectile
variant. The Federal prisoner's electric shot uses the staff ray. Existing
spells, targeting, damage, resource costs and thermal rules remain authoritative.
Approved additions normalize damage feedback by maximum Health, color selected
damage families, mark <=50% / <=10% Health at the screen edges and strengthen
Lucidity presentation. Sources and deterministic model/atlas tools are retained.
Native comparison and persistence evidence: assets/validation_518/RESULTS.md.
The reported Domingo/giant-rat death cuts now use recovered original art; nine
rat movement/pain borders are also repaired. All 118 bull sprites were audited.
Previous assets and native state timing remain unchanged.
The author accepted CA137-01/02/03 on 2026-10-09 and requested PR #151 merge
and #137 closure. HISTORY records acceptance separately from technical evidence.

## 5.1.7 - Shortbow replacement and firearm armor bypass (#136)

The author's final correction replaces the shortbow with a two-cartridge,
12-pellet shotgun and preserves the longbow/crossbow. Approved carbine-derived
costs, recipe, condition, weight, spread and half range are integrated throughout
equipment, tutorial choices, shops and localization. Player/NPC equipped-armor
bypass preserves innate defense and Toughness. Six eligible MAP02 enemies add
120 independent cartridges without moving prior supplies or changing geometry.

Original first-person weapon/hand layers are independent, including reload;
world, inventory and pickup artwork accompanies them. Versioned migration,
save/hub/rollback and focused native checks are recorded in validation_517.
The author's inspection follow-up aligns hand size/palette/aim with the carbine
and removes lingering effort-heat production. Thermal revision 7 retains existing
exposure/resources while discarding the old peak; FOLLOWUP_RESULTS records the
copied-save investigation and current action-only heat checks.
The later high-stat report adds approved 6/10 MET swimming and 6 MET pushing,
replacing their amplified-jump proxies without changing Air or movement rules.
The final author-approved energy correction converts active work at 25% efficiency,
uses a fixed half-metre human jump and independent action/distance budgets, and
changes Resilience adaptation to base plus Type 2 (+/-10 C and 2 C/day at 100).
Toughness thresholds already use Type 2. ENERGY_RESULTS records the final native
controls and migration; earlier energy reports retain their original contracts.
Author acceptance on 2026-10-08: CA136-01/02 and carried CA143-01 passed without
reported qualifications; #136 closure and PR #146 integration are authorized.
No author checks remain pending. #143 already merged through PR #145 (abd4f578);
its manual acceptance is now recorded separately in HISTORY.

## 5.1.6 - Crouched and aimed soldiers (#143)

#135 is author-accepted and closed; PR #144 merged as 5e550484 on 2026-10-08.
The separate #143 follow-up implements the author's crouched carbine request.
Stationary shots use half-height collision, an artwork-aligned muzzle and the
existing crouch/aim multipliers once. Movement, melee, recovery and interruptions
release the pose with native clearance. Physiological height remains invariant.
Original Domingo aim/fire/reload artwork also serves stationary crouched players.

Native checks cover physical posture, projectile origin, accuracy/critical and
spread factors, reload rates, obstructions, interrupts, independent player camera,
ordinary siege AI and actual player inputs. Save/hub and revision-1 migration
retain magazines, reload progress, condition and resources; rollback restores
the original save/runtime checkpoint. Evidence and exact bounds: validation_516.
PR #145 is merged. The author separately confirmed CA143-01 (5.1.6/#143) passed
on 2026-10-08 while accepting the full outstanding queue after #136. HISTORY
records that visual/gameplay confirmation independently of integration.

## 5.1.5 - Demon supplies and fire breath (#135)

PR #142 merged as 5f9202ad and #140 closed on 2026-10-08, including thermal
label colors. The #135 branch adds owned finite potion supplies, all nine
size/family combinations, automatic use and weighted single-unit death loot.
Mandingas use small doses and Zupay large; active families wait ten seconds.
The approved racial breath serves cold regulation and close combat, spending
Anima concurrently with regeneration. SYSTEMS holds its approved profile.

Native evidence covers exact doses, resource thresholds, contact versus heat,
wall occlusion, ordinary cold regulation, retreat, persistence and migration.
A reported native shutdown crash was traced with official engine symbols to
state restoration during destruction; teardown now releases effects without
executing state actions. Passing gameplay markers alone are not clean-exit
proof. On 2026-10-08 the author explicitly confirmed CA135-01/02 passed and
authorized PR #144 merge and #135 closure. HISTORY records acceptance separately
from the native evidence; no #135 author checks remain pending.
The author's additional crouched/aimed soldier request is tracked separately
as #143, with its own code, artwork, tests and delivery.

## 5.1.4 - Thermal coefficients, breathing and recovery (#140)

The author approved retaining the equivalent-exposure physics and linearized
radiation, adding animal sweat and increased ventilation, and charging player
Air/Anima recovery one quarter of complete Health-bar Hunger/Thirst costs.
Stable body/material/air coefficients and anatomical rows are now disposable
per-actor caches; changing temperatures and moisture still change flux.
Bull/rat sweat keeps their 17 C comfort and finite individual hydration. Heat
and fatigue choose the larger 150%/200% breathing level, accelerating Air recovery
and adding signed sensible respiratory exchange. Human male/female recordings
are integrated with provenance; animal recordings have not been supplied.

Expanded native validation includes firearm and shivering checks alongside a frozen-baseline comparison
of 4,480 intervals, 39 effort checks, 26 shelter/water checks, audio channels,
revision-3 migration, current save/load, native hub return and original-pair
rollback. No manual author acceptance is inferred. A small dry-solver timing
shows a lower calculation cost, not measured game FPS. The author suspended
mass-performance tests; no large-load fluency result is claimed. Later author
decisions add separate 2/2.5-MET carbine effort, dagger-scale Air and 1-to-5-MET
shivering with proportional player Hunger. Original CA140-01/02 are accepted;
follow-up calibration has its own evidence. A 100-kg human with 40-kg T1 heavy armor also survived 20 seconds of running/
nine actual jumps and 40 seconds of rest without water or thermal damage in
a 19-20 C climate (peak E +1.73; damage threshold +10.18). This is a bounded
exertion result, not immunity to overheating. Exact conditions and limitations: assets/validation_514/RESULTS.md.
#133 is closed and PR #141 merged as dd8e18bd; CA133-01/02/03 are author-accepted.

## 5.1.3 - Functional port city (#133, closure and merge authorized)

#132 was accepted on 2026-10-07, closed, and merged through PR #139
(b00201098a26582c8820a5424a2a75986b022abf). #133 now integrates usable
homes, T1 factory networks, specialized merchants, housed soldier deployment,
and shared world carbine artwork. On 2026-10-08 the author authorizes #133 closure
and PR #141 merge, deferring the thermal findings to #140. This authorization does
not independently confirm the manual tests at that stage. The later explicit
confirmation on 2026-10-08 accepts CA133-01/02/03, as recorded in HISTORY.
Fresh MAP06 geometry uses revision 3; already visited revision-2 ports require
`build_dev.ps1 -LegacyMap06SouthCity` and retain their active siege behavior.
The exact authored 5.1.2 geometry and provenance are in assets/map06_port/legacy_512.
Keep the original save and package together for rollback.

160 homes contain usable doors, rooms, tables/chairs and beds; 24 factories cover
the existing T1 production catalogue. The 64 vendors retain independent native
stock and cash. At the authored 15 November 1889 13:00 boundary, surviving housed
soldiers deploy physically while the attack begins. Shared carbine services retain
normal magazines, combat resources, projectiles and wear; only NPC reserve is
infinite. Original directional world art also follows the player's actual weapon.
Validation and performance limits: [native evidence](../assets/validation_513/RESULTS.md).
CA133-01/02/03 passed by explicit author confirmation on 2026-10-08. Their
acceptance does not turn earlier failed thermal or performance controls into passes.
The pre-sweating firearm control exposes a balance limit in the retained #130
action-heat profile: 14 shots per soldier lead to fatal accumulated heat
(HEAT_LIMIT.json). The author then approved regulated humanoid sweat, finite
hydration and coupled travel-water forecasts. Wet-clothing cold remains possible;
the extension does not itself establish accepted sustained-fire balance.

## 5.1.2 - Staged siege performance experiment (#132)

An opt-in MAP06 controller stages 100 Mandingas every 350 simulation tics,
with a 2,000-living cap and 6,000 successful-spawn budget. Existing saves retain
their armies; the accepted full deployment remains reproducible and default.
The author accepted this scenario on 2026-10-07. The #131 predecessor is fully
accepted, issue closed and PR #138 merged as 72eba5fb.
Canonical scope: [SYSTEMS](SYSTEMS.md#staged-siege-reinforcement-test-132).
Native evidence: [validation_512](../assets/validation_512/RESULTS.md), including
22 lifecycle assertions, 52 save comparisons and actual presentation captures.
The arrival workload improves; a short foreground cap control reaches 53.1 FPS
and 34.8 tics/s, while long-run stability remains unproven. Complete-budget diagnostics retain all corpses and record
natural/scripted casualties separately. CA132-01 passed author acceptance on 2026-10-07; closure and merge authorized.
Geometry/defender combinations await #133; demon survival behavior belongs to #135.
An isolated death audit confirms 5,946 cold deaths among 5,961 post-checkpoint
baseline deaths; this pre-existing physiology changes the late comparison load.

## 5.1.1 - Thermal HUD and climate adaptation (#131)

The author expands #131 with Constitution-based Sleep depletion, Type-4
Resilience adaptation rate/range, gradual return after an attribute decrease,
and distance-based climate transitions during long journeys. The thermal bar
reads the viewed character's authoritative state directly above Load.
Canonical rules: [SYSTEMS](SYSTEMS.md#thermal-exposure-and-energy-transfer-130).
Native evidence: [validation_511](../assets/validation_511/RESULTS.json).
Agent evidence: 47 unique native assertions plus a native second-player camera
check; six actual save/load/hub/rollback stages, all 18 equipment fields and 220
stable character fields; bilingual status/overflow/Journal captures at verified
4:3, 16:9 and ultrawide sizes; standard build parity and deterministic fixtures.
The aspect matrix exposed and corrected the previous frame/fill mismatch.
A short full-roster arrival pair gives 31.00 tics/s in 5.1.0 and 33.44 in this
patch before the final static icon/threshold-helper extraction. This is a smoke
comparison, not a speedup claim or late-battle FPS validation.
On 2026-10-07 the author confirmed all tests passed, including CA131-01 with
the snowflake upper left and flame lower right. CA131-01/02 are accepted without
reported exceptions; PR #138 merge and #131 closure are authorized.
The existing V5.2+ roadmap and accepted #130 calibration limits remain.

## 5.1.0 — Thermal exposure and energy transfer (#130)

Implemented with native GZDoom 4.14.2 evidence; **author-accepted on 2026-10-07**
(CA130-01/02/03), with PR #134 merge and #130 closure authorized.
The canonical [thermal contract](SYSTEMS.md#thermal-exposure-and-energy-transfer-130)
records every mapping, coefficient, time domain and approximation. Players and
approved humanoid/furry NPC profiles have independent exposure, water,
acclimatization, effort heat and fractional damage. Weather, anatomy, actual
equipment, water volumes, shelter, combat and journey authority remain shared
with existing systems. Recipes, campaign maps and army AI policies are unchanged.

Author decisions include demon comfort at 32 C, furry animal comfort at 17 C,
thermal materials by armor type, ground-temperature fallback for water,
four-wall/roof protection during cart/ship travel, unsafe departure rejection,
Minetti descent braking, jump-referenced nominal action profiles and provisional
0.95 fire absorption. Unsupported decorative fire ratings and hot/cold item
assignments are not invented. Species-specific moisture capacities, irregular
shelter geometry and exceptional-speed activity remain calibration limits.

Isolated native checks cover formulas and exact boundaries, coupled drying at
60/120/180/300 world minutes, body/animal ratios, layered water volumes,
shelter/fire obstruction, actual resource and magic routes, native walking/jump,
voluntary/passive motion and real-time damage. Limbo verifies 1:1 simulation
and frozen civil time; extra personal time produces no extra real HP damage.
English and Spanish Journal captures were visually inspected. Save tests cover
5.0.6 migration, inventory/quest preservation, current reload, hub return and
an explicit reversible schema bridge. All preexisting persistent-record fields
match an old-runtime control; thermal state survives old-runtime rollback
without being simulated there. Evidence and qualifications:
[RESULTS.json](../assets/validation_510/RESULTS.json).

**Demon sewer consequence:** a fixed native-model projection at 1889-11-03
09:00, seed 1, sewer air 17.899416 C / RH 89.842612%, dry base clothing and
initial E/acclimatization zero reaches first cold for a 66 kg / D6 Mandinga
after 24 world minutes and a 666 kg / D33 Zupay after 73. At four world hours,
E is -13.947/-13.883, both tier 1. Thus these conditions can cause cold damage
once real simulation continues. This is a controlled projection, not four
hours of observed gameplay; movement, equipment, weather and acclimatization
can change the result. No offline HP damage is invented.

**Incremental performance:** same Windows/Vulkan machine, 1280x720, 60 FPS cap,
background unpaused, 5% audio, RNG seed 116, full MAP06 roster 6,001 attackers
and 600 defenders. Tics 105–700 give 34.48/34.95 tics/s in accepted 5.0.6 and
33.62/34.15 with thermal simulation. These are short arrival samples, not late
battle or sustained 30-FPS proof. The current observer also reads one thermal
aggregate per second, so the comparison includes that small diagnostic cost.
An initial implementation achieved only 9.05 tics/s; removing per-body global
ranch searches and avoiding redundant attribute/environment work restored the
reported throughput. NPC updates are staggered, not disabled offscreen.
A separate seeded extreme-cold army stress run exercises harmful updates on
6,597 surviving NPCs; it is not a baseline-matched gameplay trajectory.

The author confirmed all three checks passed without reported exceptions.
The recorded calibration and performance limits remain; acceptance does not
establish sustained 35-tic/30-FPS performance or full multiplayer. Next thermal
UI and attribute work continues in #131 above; preserve the numbered V5 roadmap.

## 5.0.6 — Automatic high-density AI and shared work (#128)

Implementation and agent validation are complete on the focused #128 branch.
The author authorizes normal gameplay optimizations at 500 living map
combatants and explicitly chooses the leader's target for group members.
This is a production follow-up to #121's accepted diagnostic evidence.
The population count includes offscreen combatants; the full army, individual
combat, collision, resource recovery and status updates remain simulated.
The current contract and save boundary are in SYSTEMS, with native evidence
and reproducible fixtures under `assets/validation_506`.

The selected implementation uses shared leader decisions and candidate lists
on demand, exact spatial guard queries including NOBLOCKMAP registration, and
bounded negative cannon retries plus safe priority/distance pruning before
sight. It retains native attacks, individual collision, resources and status.
Background group staggering is rejected: its congestion p95 callback gaps are
341–413 ms versus 267–268 ms on demand. Candidate sharing alone has no resolved
independent speed gain, although it avoids repeated list construction.

All comparisons use ordinary combat with 6,001 attackers plus 600 defenders,
seed 116, skill 2, the fixed initial MAP06 camera/conversation, GZDoom 4.14.2,
Vulkan, native 1520-by-825 rendering, background simulation enabled and 5%
audio. The first 35 tics are warmup. `production-c/d` are the final-source
repetitions; earlier `current-a/b` are the rejected staggered experiment.

| Window | 5.0.5 production baseline | #121 combined algorithm, repeated | Final 5.0.6, repeated |
| --- | ---: | ---: | ---: |
| Early, 35–700: tics/s | 14.146 | 34.916–34.924 | 34.917–34.954 |
| Congestion, 700–1750: tics/s | 10.196 | 34.188–34.229 | 34.776–34.798 |
| Later, 1750–3500: tics/s | 3.266 | 26.174–26.309 | 26.639–27.035 |
| Common, 35–2100: tics/s | 9.336 | 33.469–33.574 | 33.999–34.157 |
| Common: frame callbacks/s | 0.552 | 7.407–7.850 | 8.089–8.658 |
| Common: p95 callback gap, ms | 3657.771 | 489.922–506.019 | 296.239–316.428 |
| Later: frame callbacks/s | 0.192 | 1.542–1.554 | 1.575–1.601 |

The direct #121-algorithm controls use the same normal population service and
observation overhead. Matched-order final pairs improve common simulation by
1.58–1.74%, callback rate by 9.20–10.29%, and p95 gaps by 37.47–39.53%.
These are modest additional improvements; the much larger baseline delta
mostly comes from promoting the previously tested shared targeting/spatial
queries/retries. Target sharing changes trajectories and later combat, so the
baseline delta is not a same-behavior causal breakdown. Desktop load is not
exclusive. Callback intervals are not GPU/presentation time. **Stable 35 tics/s
and 30 FPS are not achieved**; the final late native screenshot reports 1 FPS.

Separate 700-tic work counters measure 6,412 candidate-list constructions
without sharing versus 700 with it. On-demand groups need 6,026 decisions
versus 6,412 background-scheduled decisions. Cannon pruning reduces 143,979
sight calls to 578 for the same 33 queries in the matched counter route.
These large work reductions are not equivalent whole-game speed percentages.

Native verification: 38 functional checks; 499/500/501, offscreen counting,
death/removal/revival and mode transitions; individual versus leader targets;
attack range/visibility; crew priority and ties; remembered/vertical/unlinked
guards and one-time neutralization. The before-fix negative control fails
only the same-tic NOBLOCKMAP registration case. The full guard oracle retains
1,212 periodic rows across all 12 machines through tic 3535 with no omissions;
160 cannon queries match the original selector through tic 3510, with no skips.
All 96 special visibility cases also match the native sight RNG stream.

Cold load and hub return retain 500 → 1 → 500 combatants. The old full-army
save upgrades, reloads and rolls back using its unchanged original copy,
without redeployment. The final observation records 88 damage events, 41
deaths and 160 cannon shots; every living attacker retains full RPG objects
and the ordinary simulation path. Source verification checks 3,789 unaffected
method bodies, exact low-density targeting, unchanged maps/assets and all
6,188 final package members against source. A separate relocated-player control
retains ordinary NPC placement/combat and measures 34.874 tics/s and 27.925
callbacks/s over tics 70–1050; a native screenshot reads 31 FPS. The initially
elevated invulnerable observer falls under normal player physics and reaches
the ground among attacking Mandingas. This shorter, different camera/target
trajectory is excluded from matched comparisons and does not establish stable
30 FPS across the longer siege. Images and positions are in VISUAL_CHECKS.

Reproduction, hashes and raw evidence are in `assets/validation_506`; positive
findings and limitations are integrated in KNOWN_PITFALLS CA-KP-046–048.
The bounded Windows execution-state request is released after testing without
changing the power plan. The author confirmed CA128-01 passed on 2026-10-07
and authorized PR #129 merge / #128 closure. The measured fluency limits remain.
Further fluency work must preserve the
standing normal-game/500-combatant policy and profile the remaining perception,
individual actor work and rendering costs separately.

## 5.0.5 — Siege subsystem diagnosis and shared-group experiments (#121)

Accepted by the author on 2026-10-07 as sufficiently close for this stage,
with #121 closure and PR #127 merge authorized. Further fluency tests remain
future work. The measured results and original 35-tic/30-FPS reference are
retained; acceptance does not promote diagnostic interventions into production.

The complete accepted MAP06 army is measured on baseline `bc086979` / 5.0.4:
6,000 Mandingas, one commander and 600 defenders. The original 4.37.24 baseline
and earlier migration measurements remain evidence. This detailed diagnosis
follows the completed architecture series; it is not retroactively presented
as a pre-extraction investigation. CombatActor, PortSiege, SiegeEncounter and
Cannon source bodies are unchanged since the original architecture baseline.

GZDoom 4.14.2 runs on the Ryzen 9 5950X / RTX 3070 Ti, Vulkan, native reported
1520-by-825 rendering, seed 116 and skill 2. Each main run starts fresh on MAP06,
with the player fixed at (0, 320, 0), angle 90, no movement input and the same
initial siege conversation. The first 35 simulation tics are warmup. Pausing
and priority reduction in the background are disabled; audio stays active at
5%. Desktop load is not exclusively controlled. Package/engine/IWAD hashes,
commands, configurations, populations and raw logs accompany each run in
`assets/validation_505`. Test packages and saves remain in ignored `build/`.

The first matched full-length pair shows progressive simulation slowdown:

| Simulation window | Accepted baseline, tics/s | Instrumented copy, tics/s |
| --- | ---: | ---: |
| Initial approach, tics 35–700 | 16.043 | 16.513 |
| Congested approach, 700–1750 | 10.286 | 10.466 |
| Later battle, 1750–3500 | 3.014 | 3.057 |

Nominal simulation is 35 tics/s. These are throughput measurements, not display
FPS. The first full pair has identical sampled scene rows. The two main pairs
reverse run order and separately measure the effect of instrumentation.
Callback intervals, 35-tic wall-time windows, native thinker samples and
synthetic UI/play/UI/next-overlay timing retain their own medians and tails.
The synthetic route does not measure physical input-to-photon latency.

On the common 35–2100 window, baseline/instrumented throughput is
9.421/9.575 in the first pair and 9.594/9.373 in reversed order. The resulting
+1.63% and -2.31% differences establish a few-percent noise/overhead envelope,
not an instrumentation speedup. Both ordinary pairs have identical sampled
scene rows. The ordinary later overlay-callback median is 5,859.93 ms and p95
7,483.98 ms (0.177 callbacks/s); 35-tic wall windows have median 347.12 and
p95 447.95 ms/tic. Simulation catch-up batches about 17 tics before drawing.
These stalls already preclude the author's stable-35-tics/s, at-least-30-FPS
target without needing to equate callbacks to physical display presentation.

Every 37th tic samples nested elapsed method scopes. Representative exclusive
means from the full instrumented run are below; the denominator for the final
column is the **329.86 ms sum of measured exclusive scopes per sampled late
tic**, not total process CPU, wall time or GPU time. Scopes contain probe
overhead and possible OS preemption. Uninstrumented work remains in parents.

| Scope | Initial ms/tic | Congested ms/tic | Later ms/tic | Later measured share |
| --- | ---: | ---: | ---: | ---: |
| Port-script native `CheckSight` queries | 1.432 | 35.368 | 268.000 | 81.25% |
| `AttackerTarget`, excluding timed sight children | 32.362 | 29.888 | 35.702 | 10.82% |
| Hostile-machine `ObserveGuards` | 5.373 | 5.523 | 5.865 | 1.78% |
| Port native `A_Chase`, excluding timed children | 2.005 | 3.342 | 5.104 | 1.55% |
| Remaining CombatActor Tick scope | 4.614 | 4.815 | 5.058 | 1.53% |
| Remaining native Actor Tick scope | 1.987 | 2.041 | 2.179 | 0.66% |

The target scope includes its sight children: its inclusive late mean is
303.683 ms/tic. Do not add that to the 268.000 ms sight row. Port sight calls
grow from about 3,386 to 68,649 per sampled tic; recorded target/lane/group
candidate visits remain roughly 487,200 and 445,710 respectively. Those
candidate counters exclude artillery and machine loops. The late native
sight time attributed through target scope nesting is 267.981 ms/tic.
The code repeatedly scans eligible defenders and validates visibility as
members move into occluded/congested approaches; sharing command membership
alone does not remove that per-member work.

Collision callbacks/contact maintenance, resource/status/statistic methods,
magic/cannon projectiles, crew/group/lane coordination and player Tick are
separately represented in the category manifest and raw costs. Sparse controller
and cannon-target bursts require the additional every-call probe; a short
coprime sampling interval can miss them. Player/inventory/Tarot work is not a
leading measured cost in this route. The profile is not an exhaustive trace of
all engine, sound, GC, menu/event or global work; no residual is forced to zero.

For scale, the late sample records 6,601 CombatActor Ticks per tic; their
exclusive remainder is about 0.000766 ms per call. Native `A_Chase` averages
1,591 calls/tic and 0.003367 inclusive ms/call. The 68,649 sight calls average
0.003904 ms each; target queries average 2,139 calls/tic and 0.141955 inclusive
ms/call. Contact callbacks cost 0.253 ms/tic, contact-latch maintenance 0.183,
health/status updates 1.442, offensive statistics 0.937, recovery pulse 0.399,
recovery-active predicates 0.772, recognition sound 0.437 and elemental status
0.532. Their denominators/call frequencies are in RESULTS, including nested
resource predicates. Player Tick is 0.050 inclusive ms/tic on this fixed route;
inventory, Tarot and card menus are not separately exercised by the siege.

The independent every-call run catches operations missed by sparse sampling.
Over tics 35–2100, command election averages 7.703 ms/call (p95 9.316), lane
refresh 2.737 (p95 3.067), crew refill 0.203 (p95 1.674), and cannon selection
14.057 (p95 78.903). Their inclusive amortized costs are respectively 0.246,
0.087, 0.006 and 0.572 ms/tic. This run agrees with the normal sampled scene
rows; logging overhead is separate and its nested totals are not added to the
main profile. In changed formation workloads, cannon selection is much larger.

Native `bench` reports CPU-side renderer stages separately. Six baseline
samples span 21.356–32.629 ms for its All value, median 26.615 ms per rendered
frame. Worker/render/setup stages overlap and must not be summed. Separate
native captures show 347.5 and 443.0 ms on the global sight counter, confirming
the large visibility cost without equating different samples/query subsets.
`stat gpu` is available but publishes no range in the original configuration:
the inspected Vulkan call sites time selected postprocess effects, not the
whole scene. An isolated FXAA control publishes 0.76 and 0.75 ms for **FXAA
only**. Retrieving timestamp results can wait on the GPU, and enabling the
effect changes rendering; these captures are excluded from main comparisons.
Whole-scene GPU execution remains **unmeasured by the available native scopes**.
Overlay intervals include batches of simulation tics and cannot be renamed GPU
frame time. VISUAL_CHECKS and ENGINE_CAPABILITIES retain the source boundaries.

Native bench scene counters show 18,528 walls, 597 flat primitives and roughly
7,600–7,800 sprite submissions in the early normal view. Its wall/flat/sprite
CPU stages help locate submission work, but do not identify one model, effect,
material or individual actor's GPU contribution. Native range queries cannot
supply those missing per-object causal costs; selective render suppression
would be another changed-workload experiment. Rendering, collision internals,
OS scheduling and work outside the instrumented scopes are not assigned a
fabricated residual percentage.

The author's additional experiment compares 6,000 individual formation decisions
with sixty decisions for groups of 100, using the same initial placement and
four-tic movement cadence. SYSTEMS defines its altered march behavior. Another
diagnostic shares only leader perception while preserving normal placement,
combat and native movement. These are isolated interventions, not accepted
gameplay or additive causal percentages. Results, variability, formation error,
failed native moves and changed populations remain in the evidence.

Repeated formation controls measure 18.303/18.041 tics/s for independent
decisions and 13.330/13.115 for shared groups over tics 35–1715. The early
shared phase reaches nominal 35, versus 18.919/18.610, but later repeated cannon
sight searches reverse the advantage. In formation100-e, cannon-selection
children account for 48.856 ms/tic of sight work, versus 0.494 under attacker
targeting. The final mean relative formation error is 922.947 map units;
17,824 of 47,952 movement attempts succeed in the last logged 35-tic window.
Its error denominator excludes blocks whose original first member died, so it
cannot serve as an unbiased cohesion score across variants. The actual aerial
capture is `assets/validation_505/formation100-early.png`.

Sharing only leader perception in the normal placement/combat route instead
measures 30.130/30.415 tics/s over tics 35–2100, versus 9.575/9.373 with ordinary
instrumentation. The observed 1.858/2.150 overlay callbacks/s still fail the
author's visual fluency target. Guard spatial queries and failed-cannon-query
caching are additional isolated factors; combined results are assessed without
adding separate percentage gains or treating changed combat outcomes as equal.

The spatial-guard factor alone measures 10.442 tics/s, with the same sampled
scene rows as the normal instrumented run. `ObserveGuards` falls to 0.116 ms/tic
over the common window. A separate oracle run checks every applicable query
against the original population scan, with 756 periodic machine records and no
omitted eligible guard through tic 2205. This positive result is scoped to the
tested actors/route; future NOBLOCKMAP bodies and broader victory/save cases
still require a shipping implementation's boundary tests.

In the normal battle, perception plus spatial guards measures 33.033 tics/s
and 5.432 callbacks/s over tics 35–2100. Adding cannon retry gives repeated
32.368/32.985 tics/s and 4.764/5.111 callbacks/s; there is no measured extra
benefit from that factor in this window. Cannon retry alone gives 9.416 tics/s
with unchanged sampled scene rows, within the ordinary noise envelope.
The three-factor later window improves to 23.686/25.209 tics/s compared with
the ordinary 3.057, but only 1.395/1.488 callbacks/s. Its p95 callback gaps are
902.145/835.627 ms. A large relative simulation gain still fails both the
stable-rate and visual-frame target. The baseline synthetic request/play/ack/
frame probes take 1,727/6,034/9,078 ms at the three scheduled points; combined-a
reduces these to 459/1,040/1,597 ms without establishing physical input latency.

The march combinations isolate the interaction and preserve matching sampled
scene/movement observations within that synthetic workload:

| March variant, tics 35–1715 | Repeated tics/s | Overlay callbacks/s | Limitation |
| --- | ---: | ---: | --- |
| Groups of 100 only | 13.115–13.330 | About 3 | Cannon searches dominate after approach |
| Groups + failed-cannon-query retry | 32.644–32.825 | 12.430–12.586 | Up to seven tics of acquisition delay |
| Groups + retry + spatial guards | 34.865–34.989 | 20.243–22.818 | p95 frame-callback gaps 128.496–209.216 ms |

The final combination approaches nominal simulation rate but fails the
at-least-30-FPS target. Per-body movement, contact checks and status/combat
Ticks remain; formation alignment still breaks around blocked bodies. No
population suppression or offscreen simulation cut is used to claim a gain.

The next optimization should first address `CaelumPortSiege.AttackerTarget`
and its sight-query workload while preserving each member's nearest-visible
target semantics. Shared candidate-position data or an exact spatial query
can reduce repeated enumeration; caching visibility needs explicit invalidation
for movement, death, geometry and player changes. Blindly inheriting a leader's
vision changes awareness/target choice. Machine guard scans are a separate,
smaller candidate: a bounded spatial query must retain guard history and the
existing neutralization/victory rules. Formation navigation, cohesion and
cannon retry behavior require their own focused design/optimization issues.

Production changes are limited to two release-label diagnostics. All test
instrumentation stays outside the shipping include tree. Static verification
checks 3,799 original method bodies after removing known probes and 1,979 field
declarations; current source differs only in release text and checkout line
endings. The author accepts #121's measured diagnosis and prototype delivery;
production optimization and further fluency validation remain future work.
Final validation includes 21 completed comparison runs, two separate GPU/visual
runs and a production-package smoke/background check. All 15 diagnostic packages
reconstruct byte-identically in two passes from pinned Git content. The final
6,187-member production package matches `src/` exactly. The temporary Windows
keep-awake request is released and the Balanced power plan remains unchanged.

## 5.0.4 — Per-player authority and bounded V5.0 closure (#120)

The five-issue architecture series now has compatible player coordination,
one inventory/equipment implementation, one Tarot implementation and explicit
receiver/owner boundaries. A stateless authority helper checks the current native
pawn, rejects prediction-time commands and resolves event player slots without
fallback. Canonical records, owned equipment and pawn-held crafting previews
cannot be supplied from another player. GZDoom retains native state and execution
authority. No fields, schemas, controls, maps, balance or actor counts change.

The author accepted all #119/#120 tests on 2026-10-06 and authorized merge/closure.
This closes the implemented scope of #116–#120. It does not mean all remaining pawn policy has been extracted or that
the broader V5 roadmap is complete. The older audit's speculative A5–A8 follow-ups
are renamed F1–F4 below to avoid confusing them with Architecture 5 / #120.
Crafting/session coordination, combat/narrative dispatch and measured siege work
need separate issues. Thermal exposure, native UI/creation redesign, campaign
expansion and multiplayer design remain separate milestones.

The SYSTEMS contract distinguishes player state, local presentation and shared
map state. Shared campaign time and network lifecycle remain unsupported. Native
owner tests use two actual player slots with a local human and a native bot; they
do not claim two-client transport or networked card play. Integrated domain,
save/hub/rollback and matched original-Architecture-1 measurements are retained in
`assets/validation_504/RESULTS.json`. Earlier #117/#118 measured regressions remain
historical evidence; organization alone does not establish a speed improvement.

PR #125 delivers #119; PR #126 delivers #120. Both received author acceptance
on 2026-10-06 and are merged, with both issues closed.
The existing save adapters are retained. Their later removal requires an explicit
retirement/migration issue, tested saves and the original-pair recovery path.

Integrated MAP06 results versus the original 4.37.24 reference are 11.113/11.567
tics/s (+4.09%) and, in reversed order, 11.790/10.762 (-8.72%). Each uses the same
1,680-tic window and 49 matching scene rows. This variability establishes no
stable gain; frame callbacks, synthetic input-event routes and native thinker
samples are reported separately in HISTORY and the evidence. A complete repeat
replaces one run that exited before the required window. F3 remains a measured
follow-up, preserving army counts and accepted rules.

## 5.0.3 — Authoritative Tarot service (#119)

The author accepted all #118 tests on 2026-10-06; acceptance commit `06a062fa`
was merged through PR #124 as `135ae0f9`, closing #118. Tarot now has one
stateless implementation for collection, bonuses, selection/activation, clocks,
capture checks and projections. Twenty-four existing methods remain adapters;
serialized state and separate Trucazo/Truco inventories retain their identities.
The physical deck remains under the inventory contract. No acquisition content,
power balance, UI layout, map, art or audio changes are introduced.

The comparison exposed an existing missing native flight instance after leaving
MAP01 despite an active saved Fool timer. Travel/personal-time reconciliation
now restores that instance idempotently without payment or renewed duration.
This bounded persistence fix is distinguished from the mechanical extraction.
The SYSTEMS contract and `assets/validation_503/RESULTS.json` record evidence,
rollback and limitations. Author acceptance passed on 2026-10-06. The author also
requested continuing with #120 after this delivery; its owner/integration work
and the unresolved #117/#118 performance attribution stay separate.

## 5.0.2 — Authoritative inventory/equipment service (#118)

The accepted #117 delivery was merged as PR #123 (`da7d33b8`) on 2026-10-06.
This next slice implements the inventory ownership contracts through a stateless
`CaelumInventoryService`. The pawn forwards 157 existing methods; physical Box
identity and physical-deck query/grant add three compatible forwarding methods.
The player loses 5,363 implementation lines while retaining every field/signature.

Native inventory instances and their `Owner` remain authoritative. The service
consolidates identity, equipment, Box routing, capacity, projections, reservations,
currency/product operations and inventory commits of crafting/repair/dismantle.
Twelve explicit guards reject foreign owned references before mutation. All other
moved statements/literals preserve their order and meaning; 387 other pawn method
bodies are unchanged. Native callbacks/input, travel copies, recipe planning,
merchant/quest sessions and Tarot powers keep their existing responsibilities.
SYSTEMS specifies callers, preconditions and which specialized native/quest
operations remain outside this extraction. No balance, assets or map changes.

No save schema or migration revision changes. Existing migration gates and
original-package/original-save rollback are exercised with native GZDoom 4.14.2.
Source equivalence, package boundaries, contract checks, ownership rejection,
save/travel tests and before/after measurements are recorded in
`assets/validation_502/RESULTS.json`. These are agent checks, with ordinary author
acceptance tracked separately. All game launches keep enabled audio at 5%.

This implements A3 below, including the existing inventory commit operations
needed by its consumers; future transaction work concerns their remaining session,
planning and orchestration policies. It does not create a competing crafting or
economy implementation. #119 owns the next Tarot slice. #117's measured MAP06
4.9–6.0% slowdown remains unresolved evidence for #120; organization is not a
performance improvement claim.

The #118 comparison also observes a regression against 5.0.1: MAP06 measures
12.632 -> 12.160 tics/s (-3.74%), then 12.967 -> 12.170 (-6.15%) when repeated
in reverse order. Each run spans 1,680 tics and all 49 scene observations agree.
Mean single-tic player samples rise 0.0417 -> 0.0445 ms and 0.0441 -> 0.0487 ms;
these sparse microsecond differences do not attribute the whole-scene slowdown.
Input-drift/overlapping attempts are discarded. Current cause and desktop/driver
variation remain unresolved; carry this measured evidence into #120.

## 5.0.1 — Player character/resource adapters (#117)

Accepted baseline: #116 / 5.0.0, merged as `6e8f0d66` after the author's
2026-10-06 confirmation that all tests passed. PR #122 is merged and #116 closed.

This focused stage moves ten draft/profile operations to
`player/CaelumPlayerCharacter.zs` and 29 resource operations to
`player/CaelumPlayerResources.zs`. Both are stateless play-scope services taking
an explicit `CaelumPlayer`. Existing entry points forward parameters and return
values; the pawn retains all 604 field declarations and 544 method signatures.
The 505 other method bodies, including native callbacks, input, travel persistence,
equipment, attack dispatch and the personal-time coordinator, remain unchanged.
The pawn implementation shrinks by 939 lines; this is not full modularization.

The helpers reuse `CaelumCharacterProfile`, `CaelumCharacterAllocation`,
`CaelumAttributes`, `CaelumDerivedStats`, and existing rest/sleep/catalogue rules.
They add no owner, constructor, migration, initialization call or timer step.
Profile recomputation still calls existing inventory/jewelry/Tarot adapters in
the original order; resource operations still mutate live pawn values, with
the existing explicit record snapshots at persistence boundaries. SYSTEMS
defines the contracts; the exact method list and static proof are in
`assets/validation_501/EXTRACTION.json`. Native evidence and its limits are in
`assets/validation_501/RESULTS.json`. No balance, map, asset or UI change is made.

The #116 proposed A2 inventory slice conflicted with #117's explicit requirement
to leave inventory and Tarot to following issues. The issue dependency chain
takes precedence: A2 below now names this player stage, A3 maps to #118 and A4
to #119. This records the discrepancy instead of silently broadening #117.
Further transaction/combat/siege/session work remains separate. The author
confirmed all #117 tests passed on 2026-10-06 and authorized PR #123 merge
and issue closure; measured performance limitations below remain.

Native equivalence: 249 assertions on each implementation, 93 identical output
rows and 592 equivalent serialized pawn fields (object references resolved by
value), plus old/new/re-saved loads and original-package rollback. Scripted native
menu checks confirm the 4+30-point draft and its consumption at MAP01 startup in
both languages; the final introduction keypress remains an ordinary author check.

Performance is a reported regression, not a passing optimization claim. Each
MAP06 sample measures the same 1,680 tics; all 49 scene/population observations
match across four runs. Base/current: 12.546/11.794 tics/s (-5.99%); reversed-order
repeat: 12.633/12.017 (-4.88%). Three native single-tic player samples average
0.0381 ms before and 0.0489 ms after (+0.0108 ms). These sparse pawn samples do
not account for the complete scene delta or isolate its cause. Desktop load,
renderer/driver and profiling noise are not controlled; no whole-scene causal
attribution or speedup is claimed. Carry this evidence into #120's integrated
comparison and any measured performance follow-up; army counts and accepted rules
remain unchanged.

## 5.0.0 — Architecture audit and first presentation extraction (#116)

Baseline: accepted #82 / 4.37.24, commit `20143c3154617309912a493fa2a7be3c7c2c9ff4`.
On 2026-10-06 the author explicitly expanded #116 beyond its original audit-only
acceptance criterion: begin refactoring as well, without requiring compatibility
with earlier saves. This is a scoped waiver for this work, not a repeal of the
permanent save policy. The implementation happens to retain all existing player
field declarations and method signatures; it does not claim old-save acceptance.

The first slice moves `RefreshSocialJournalSnapshot`, `SyncHUDActiveWeaponState`
and `SyncHUDLoadState` from `CaelumPlayer` to the stateless play-scope
`CaelumPlayerPresentation` in `src/caelum/player/`. The original methods are thin
delegating adapters and remain at the same lifecycle call sites. This reduces the
player implementation by 199 lines, without a second inventory, Tarot system,
resource owner or HUD state object. No gameplay rule, balance, localization,
selector, map or runtime asset is changed. Two diagnostic release labels are
updated to 5.0.0 as required by the validator. This begins V5.0; it does not complete
the player refactor or claim any performance improvement.

### Responsibility and dependency map

The source inventory is reproducible through
`assets/validation_500/audit_sources.py`; `SOURCE_AUDIT.json` records concrete
class/field/method declarations, hashes, include reachability and lexical file
dependencies. It is a locator, not a compiler-derived call graph. The baseline
player has 19,731 lines, 544 method definitions and 604 field declarations
(declarations can contain multiple fields). The semantic boundaries below were
reviewed separately against callers and lifecycle code.

| Current responsibility and concrete symbols | Callers and dependencies | Target contract / owner |
| --- | --- | --- |
| `CaelumPlayer.PostBeginPlay`, `PlayerThink`, `Tick`, `PreTravelled`, `Travelled`, `DamageMobj`, `CollidedWith` | Engine callbacks; profile/allocation/stats, inventory, quests, time, equipment and physics | Pawn remains the engine coordinator; preserve callback ordering while moving one policy at a time. |
| `CaelumPlayerPresentation.RefreshSocialJournalSnapshot`, `SyncHUDActiveWeaponState`, `SyncHUDLoadState` | Player adapters; `PersistCharacterState`, `Tick`, `CaelumTarotPowers.Select/Activate`, `CaelumDebugOverlay.NetworkProcess`; record, native inventory and equipment models | Implemented first slice: one play-scope projection service writing only existing presentation fields, while preserving inherited initialization calls. Render code reads those fields. |
| `FindNativeEquipmentItemById`, `EnsureEquipmentItemId`, `RepairActiveEquipmentItemReferences`, `SyncActiveModelsToNativeInventory`, formal inventory methods in `CaelumPlayer` | `CaelumEquipmentItem`, `CaelumSpecialInventoryItem`, pickups, crafting, merchant transactions, Journal events | Implemented in #118: the stateless inventory service takes an explicit pawn; native `Actor.Inv` is the item collection. IDs select exact items; never replace them with type/tier/size keys. |
| `CaelumPlayer.PersistCharacterState`, `RestorePersistentCharacterState`, `StoreCraftingTaskState`, `LoadCraftingTaskState` | Travel hooks and mutations; `CaelumPersistentCharacterState` plus live profile/resources/models | Future persistence adapter documents copy direction per field; do not create an independently authoritative registry. |
| `UpdateCraftingTask`, `BuildPalomoCurrencyPaymentPlan`, `ApplyPalomoCurrencyPlan`, `EquipSelectedNativeEquipment` | Crafting station/browser, `CaelumCraftingRules`, `CaelumEconomyRules`, equipment IDs and reservations | #118 centralizes their inventory commits. Future extraction concerns remaining crafting/trade planning and sessions; preserve validation-before-mutation and reservations. |
| `AdvancePersonalTimeTic`, `ApplyPhysicalMovement`, `RequestCombatChannelInput`, weapon attack/reload methods | `Tick`, `PlayerThink`, native selectors; shared `CaelumAttackRules`, catalogue, profile and derived stats | Future resource/combat services act on one pawn; native weapon actors keep dispatch and animation state. Do not add another damage route. |
| `CaelumTarotService`, compatible `CaelumTarotPowers`/record/essence adapters, `CaelumTarotDeckRules`, `CaelumArcanaProgress` | Journal `ca_tarot_select`, User3, personal-time tick, quest capture and match queries | #119 centralizes Tarot operations; the saved character record retains ownership/powers and native inventory retains the physical deck. Campaign availability observes world/quest progress; match state stays separate. |
| `CaelumMainM00QuestController`, persistent `MainM00*` methods, `CaelumQuestCatalogue`, `CaelumPrisonerRescue` | World events, dialogue tokens/USDF, player snapshots | Narrative services own transitions against the character record; NPC recreation and display refresh must not grant rewards. |
| `CaelumWorldClockTicker`, `CaelumWorldClock`, `CaelumCalendarState`, `CaelumScheduleState`, `CaelumJourneyState` | WorldTick, travel, rest/time-skip and weather | Preserve the current single-participant clock guard. Shared multiplayer world authority is a separate design/implementation gate. |
| `CaelumCombatActor.Tick/CollidedWith`, `ImpactPhysics`, `ImpactContactState` | Native movement, projectiles, environment, player and actor impact adapters | Generic physics mathematics remains below gameplay adapters. Shared contact objects and once-per-tic resolution must survive any later extraction. |
| `CaelumPortSiege.Tick/AttackerTarget/ElectCommands/RefreshTargets`, `CaelumPortDefender`, `CaelumSiegeEncounter` | Actor AI states, roster, gates, rams/cannons, command and perception refresh | Map-local siege owns roster/deployment/targets. Profile before optimization; preserve accepted targeting, combat and group rules. |
| `CaelumJournalOverlay`, `CaelumJournalInput`, `CaelumDebugOverlay`, native weapon selector classes | UI input -> events -> requesting pawn; HUD/first-person views read projections/models | UI never becomes the owner of inventory/progress. Preserve event names, player routing, input latches and native slots. |

Target dependency direction: data/catalogues and pure rules -> domain operations
over explicit existing state owners -> pawn/event adapters -> UI projections and
rendering. This is a target, not a claim that the current graph is acyclic:
rules such as Tarot still call player methods, and the new projection service
reads the pawn. Break those dependencies in later bounded slices, without adding
parallel stores. `src/ZSCRIPT` remains the sole runtime include entry point.

### Ordered extraction plan and gates

These are scope identifiers, not speculative release numbers. Each subsequent
implementation needs its own focused issue and evidence; do not combine them into
a rewrite or silently expand #116 further.

| Slice / prerequisite | Bounded change and adapter | Required acceptance before the next slice |
| --- | --- | --- |
| A1 — this issue | Audit ownership/dependencies and MAP06 baseline; extract only the three presentation routines above, retaining pawn fields | Static declaration/body equivalence, native projection checks, current save/reload and bilingual UI observations; record performance limits separately. |
| A2 — #117, after A1 | Delegate draft/profile and resource policies to stateless services; retain fields, native callbacks, input and personal-time ordering | Exact body/declaration equivalence; native profile/resource matrix, old/new save/reload and hub return; selectors/creation retain behavior. |
| A3 — #118, after A2 | Implemented: exact-item lookup, IDs, queries, mutation, projections and equipment reconciliation in one service; native pickup/selector adapters retained | Two identical items retain IDs/wear; Box capacity, reservations, rejected transactions, equip/drop/break/repair and save/travel neither lose nor duplicate items. |
| A4 — #119, after A3 | Implemented: one stateless Tarot service with saved record and compatible adapters; separate Trucazo/Truco state and physical inventory contract | Capture/select/activate/expire, physical deck/Box gate, bonuses and reward idempotence; no UI refresh grants or timer reset. Restore the missing native flight instance across non-hub travel. |
| A5 — #120, after A4 | Implemented: explicit per-player receiver/record/item/preview contracts, guarded native event routing and integrated validation; retain all adapters | Native two-pawn owner isolation, current/old/re-saved loads and original-pair rollback; integrated MAP01/MAP02/MAP06 path; original Architecture 1 performance comparison with separate simulation/overlay/input evidence. |
| F1 — #376 / #377 | Crafting planning/task coordination is extracted in #376; merchant session/transaction coordination follows in #377. Reuse #118 inventory commits and retain record/live handoff | Reservations, cancellation, completion and payment/reward exactly once; pause/session loss, travel and reload; no free duplication or lost stock. |
| F2 — future focused issues | Further isolate combat dispatch and narrative transitions individually; keep resource adapters and native movement/weapon states | Press/hold/release, ammunition/resource spending, interruption and exact item wear; attack cadence/physics and quest reward idempotence unchanged. |
| F3 — measured performance follow-up | Isolate measured map-local targeting, command rebuild and siege costs individually; no actor replacement or AI cadence change in an organization patch | Same roster/losses/targets/crew and group limits; scene-matched native profiling and responsiveness evidence; each optimization needs its own measured purpose. |
| F4 — explicit multiplayer design | Define shared-session authority and supported participant model | Author decisions for shared time/progress/rewards precede implementation; native multi-client join/leave/reconnect/respawn/transfer tests are mandatory before claiming network support. |

Persistence adapters are checked alongside each slice rather than postponed to a
final bulk migration. Thermal exposure (V5.1), CA-V5-NATIVE-UI, broader Tarot powers,
campaign content and team/network play remain outside the implemented scope.

### Audit findings and measurement boundary

- `src/crafting/CaelumCraftingStation.zs` is packaged but not included; the live
  class is in `src/caelum/crafting/CaelumCraftingStation.zs`. The inactive copy has
  divergent defaults. Record this discrepancy; do not include both or delete the
  inactive source without a separate authorized retirement/provenance check.
- The general description of a persistent global clock does not establish a
  shared-session clock: `CaelumWorldClock` is pawn-owned inventory and
  `CaelumWorldClockTicker.WorldTick` returns unless there is exactly one participant.
- `RefreshSocialJournalSnapshot` is not a pure read: it can obtain/create the
  character record and run quest/faction/Tarot initialization. The extraction
  preserves those calls and their ordering; separating initialization is future work.
- Old ownership arrays, equipped models, persistent snapshots and native items
  coexist. `NativeEquipmentMigrationComplete` and exact item IDs are essential
  when interpreting them; they are not four independent inventories.
- `CaelumMassAIScheduler` describes CADEV02 diagnostic mass AI. Its settings are
  not evidence that production MAP06 perception and command work are budgeted by
  that scheduler. Trace `CaelumPortSiege` and the real actor paths instead.

Native current-build measurements, actual settings/hardware, source/package
hashes and reproducible commands are in `assets/validation_500/RESULTS.json`.
The pre-refactor primary observation uses Windows 11 Pro 10.0.26200, Ryzen 9
5950X (16 cores / 32 logical processors), RTX 3070 Ti, Vulkan, development Doom II,
seed 116, skill 2, reported 1520 × 825, VSync off, 60 FPS cap, background activity
enabled, mouse disabled and 5% master audio. Only the unchanged accepted runtime
plus the observation addon is loaded, in an isolated INI/save directory. Native
support resources loaded by the engine are listed in the raw log. It observes
direct-map arrival at `(0, 320, 0)`, angle 90, with the briefing open and the full
siege running; it is not a measurement of every battlefield camera or a campaign save.

| Current pre-refactor measurement | Result and interpretation |
| --- | --- |
| Simulation: tics 35–1715, wall time 7,125.776–138,550.541 ms | 1,680 tics in 131.424765 s: **12.783 simulation tics/s** against the engine's nominal 35. This is a new observation, not the old #86 sample. |
| Population across that interval | Registered attackers 6,001 throughout; live attackers 6,001 -> 5,989, defenders 600 -> 599, groups 64 -> 82. Combat remains active. |
| 99 render-overlay intervals inside the sampled interval | Median **1,097.204 ms**, p95 **2,452.775 ms**, maximum **2,685.843 ms**. These are callback-spacing observations, not GPU frame times. |
| Separate native thinker profiles, three individual tics | `CaelumMandinga`: 89.617 / 22.315 / 21.753 ms over 6,000 calls per sample. `CaelumPlayer`: 0.035 / 0.050 / 0.039 ms. Profiling predates the requested audio reduction; its isolated settings are recorded separately. |
| Separate final-build event-route probe, three requests | UI request -> play handler: **564.728 / 233.452 / 1,009.939 ms**; request -> next overlay after acknowledgement: **1,717.120 / 1,190.295 / 2,102.394 ms**. This measures a scheduled diagnostic event route, not a physical key or device-to-photon delay. |

Measured actor-class costs identify where to investigate, not which internal
operation is responsible. Candidate measurement boundaries are
`CaelumPortSiege.AttackerTarget` / `RefreshTargets` for perception,
`CaelumCombatActor.CollidedWith` / `UpdateImpactContactLatch` and native `A_Chase`
for movement/contact, actor `Tick` and projectile updates for aggregate simulation,
`CaelumPortSiege.ElectCommands/RefreshTargets/RefillCrews` for periodic siege work,
and native renderer CPU/GPU timing for visible models, sprites, lights and HUD.
The current profiles do not isolate those function costs. Source loops suggest
possible repeated work; they are hypotheses until individually instrumented.

The sampling distinguishes simulated tics per wall second, intervals between
render-overlay callbacks, native thinker profiling and input observations.
Overlay cadence is not GPU frame time or end-to-end input latency. Instrumentation,
desktop activity, arrival briefing, scene and population changes limit comparisons.
No speedup is attributed to moving these methods. Final-build native verification
passed 35 projection assertions, three explicit load assertions plus three resumed
state assertions, and English/Spanish Journal/Tarot captures. The original runtime
also passed the same 35 projection assertions. Static validation and package build
pass; `EXTRACTION.json` distinguishes the method move from two diagnostic-version
string updates. No external AI review is claimed. The author confirmed all
delivery tests passed and authorized merge/closure on 2026-10-06.

#86 is closed. `assets/validation_4379/south/COMBAT_RECOVERY.json` remains historical
evidence only, including its old 13.5-tic/s sample; it is not this patch's benchmark.
The concrete ownership/compatibility contract is in SYSTEMS; tests and outstanding
work are in TASKS and the evidence record. Agent checks do not imply author acceptance.

## 4.37.24 — Final V4.37 integration and export (#82)

The author designates #82 as the closing V4.37 delivery on 2026-10-05, after
all feature dependencies were implemented and merged. The executable scope is
MAP01 -> MAP02 -> MAP06, the requested flooded returns/key progression and city
connections, captain recognition, payment-gated prisoner intelligence, both
siege objectives and the accepted forces, the physical 78-card deck, three
campaign essences and their powers, and a complete Trucazo match against Argento.
The later accepted character creation, first-person art and ordinary ranked
Truco slice remain integrated. #75 and #86 are closed; neither an old issue label
nor an obsolete roadmap sentence reopens their accepted work.

This delivery exports a new reproducible single-player test package. It does
not republish or modify the accepted #17 / 4.36.28 archive. Initial portable
controls are Tab Journal, M automap, B Seal Channel, R Reload, F Zoom and,
following the author's explicit choice, T selected Tarot powers. Subsequent
launches preserve player changes and do not touch the installed engine profile.
Final-source static/native results and export identity are recorded under
assets/validation_43724. On 2026-10-05 the author passed CA-43724-EXPORT-01
and explicitly approved this delivery, PR #115 merge and #82 closure. HISTORY
records the manual result separately from controlled native evidence.

V5.0 remains the next modular-architecture stage, with save-preserving adapters
and one authoritative inventory/player/Tarot implementation. Remaining essence
acquisition, Major powers, broader awakening, full campaign expansion, Trucazo
teams/network play and cross-player authority stay in V5. V5.1 thermal exposure
and CA-V5-NATIVE-UI retain their approved scope. No V4.38 milestone, external
GitHub Release, tag or public upload is introduced by this local export.

## 4.37.23 - Contextual character creation (#112)

The native creation menu displays four race/class choices or allocation rows
on the left and immediate descriptions on the right. Both languages cover
all playable races, four base classes, ten professions, four families and the
twelve implemented attributes. Second-class labels and the summary use the
profile's authoritative, order-independent profession combination.

The author authorized concise wording grounded in current gameplay, then
explicitly authorized correcting the creator's duplicated Human/Priest family
distribution. Shared profile data now keeps Social/Mental preview and actual
character formation consistent. No new traits, penalties or balance values.
Static/native evidence and qualification: assets/validation_43723/RESULTS.json.
All 1,236 assertions passed across the six layout/language runs and interactive
creation/save/reload run. Keyboard confirmation starts MAP01 through the accepted
introduction; loading the saved character preserves its profile and allocation.
The author's merge/closure authorization on 2026-10-05 applies after this issue
is implemented and verified; the earlier confirmation of passed #106 tests
does not claim blanket manual acceptance of #112. The author assisted the final
save/reload check and confirmed its completion separately.

## 4.37.22 - Distinct playable first-person shields (#106)

Kite, tower and magic shields have original inward-facing idle/block artwork
in the shared native view; the round shield keeps its accepted PNGs and framing.
The actual equipped inventory item selects the set across T1-T3 and XS-XL.
Compatible physical/magical weapons and unarmed equipment share the accessory;
existing disallowed combinations and giant-gauntlet blocking stay distinct.
At the author's request, T1-T3 giant gauntlets also receive a closed boxer-guard
sprite, preserving their existing blocking rules.
No gameplay/save schema or map changes. Sources: assets/first_person_shields;
test results: assets/validation_43722/RESULTS.json.

The author accepted the designs and positions on 2026-10-05, requesting more
muted colors. The three new sheets now use the existing greatsword palette.
The author then explicitly accepted the final palette (CA-43722-SHIELD-ART-01).
The author later confirmed all tests passed on 2026-10-05 and authorized
merge/closure. CA-43722-SHIELD-PLAY-01 and the revised gauntlet visual check
are complete; HISTORY records their explicit acceptance. Earlier #103/#98/#96 acceptance remains unchanged.

## 4.37.21 - Approved narrative artwork and introduction (#103)

The author's title-bearing PNG is the README banner; the exact two illustrations
embedded in the supplied narrative deck are preserved separately with hashes.
No slide text establishes canon. After initially reserving the story background,
the author requested an opening only after confirming a new character, then
specified one Doom-style typewriter page and the former MAP01 music, CA_MUS01.
This explicitly supersedes the earlier no-opening scope in #31 and #103.
The page contains the exact requested Spanish welcome/awakening, bilingual
controls from current bindings and existing survival rules. First key reveals;
next key starts the original MAP01 sequence and its current CA_MUS02 music.

The native quit confirmation/cancellation remains in use. Confirmation shows
the same image as an in-engine farewell, then a key/click invokes the original
shutdown callback. GameInfo disables inherited text ENDOOM; unrelated credits,
audio, port completion and maps are unchanged. No save fields or migration.
Evidence: assets/validation_43721. The author accepted all three checks on
2026-10-04 without reported qualifications and authorized issue #103 closure
and PR #111 merge. No author checks remain outstanding; HISTORY records the IDs.
#98's three author checks passed, issue closed and PR #110 merged 2ec2405c.

## 4.37.20 - Training dummy model (#98)

The existing practice dummy is now an original textured OBJ mannequin derived
from CDMYA0: wooden limbs, oxblood padding, brass joints, painted concentric
targets and a round plinth. Both actor classes retain their original identity,
states, collision, health and placement. No quest, damage or save logic changes.
Sources and provenance are retained under assets/training_dummy and the model
generator. Evidence: assets/validation_43720. Static and isolated engine
checks are distinct from author acceptance: all three checks passed 2026-10-04.
The author's #96 acceptance is complete: issue closed, PR #109 merged 76757fd7.

## 4.37.19 - Palomo necklace reward and shield names (#96)

Palomo now offers and gives one of the four existing T1 amulets after the player
follows him upstairs; Caella teaches that same item's recipe. The author's
choice/recipe split was confirmed on 2026-10-04. The gift is actual owned
equipment, capacity-aware and never auto-equipped. Old selections, owned
copies, active crafting and completed progress have an idempotent revision-1
path; no new balance or recipe is introduced. Original dialogue node indices
are preserved. Shield dialogue uses the same bilingual names as inventory.
The other equipment categories keep their accepted crafting and trial rules.

Static/native verification and save evidence: assets/validation_43719.
All three author checks passed on 2026-10-04; #96 is closed and PR #109 merged
(76757fd7). #91 was accepted, closed and merged as PR #108
on 2026-10-04 (merge 466a0734).

## 4.37.18 - Crafting sections and complete Tarot descriptions (#91)

The Journal now has distinct Craft, Repair and Dismantle views using the
existing inventory visual language. Learned recipes remain browsable when
materials or a station are missing. Repair and Dismantle identify real owned
weapon instances, preserve their wear/variants and revalidate the target on
confirmation. The Pickaxe's learned recipe now authorizes its existing repair
path; no repair, recovery, station, efficiency or timing formula changes.

Tarot separates passive attributes/collection, world activation and Trucazo
awakening. Its fixed-bonus text shares the stat contribution source. Uncaptured
essences remain unrevealed; unimplemented Major powers and their exclusion
from practice are explicit. Scrolling keeps long text within the panel.

Keyboard/controller navigation is retained; native mouse input uses the
existing C moon pointer and the same coordinate projection as Journal drawing.
Browser revision 1 is transient and reconstructible; saved equipment, task
reservations, recipes and Tarot state remain authoritative. Native verification
includes old-save load and rollback. Evidence: assets/validation_43718.
All three author checks passed on 2026-10-04; closure/merge were requested.
#89 was accepted, closed and merged as PR #107.

## 4.37.17 - Owned Pickaxe and resource feedback (#89)

Ronnie now gives an owned Pickaxe and its recipe when the gathering lesson
starts. The author confirmed primary slashing, secondary piercing, family 1,
and preservation of the chosen-weapon crafting lesson. The single T1 tool
shares axe numbers/recipe and multiplies chopping/mining yield by 10/100 before
existing source, carry and Limbo quota limits. Sounds and centered CaelumText
success messages apply to every weapon that actually extracts material.

Recipe book revision 5 appends recipe 131; weapon IDs and ownership indices are
appended. Tutorial gift revision 1 adds one owned instance for started/completed
old saves, preserving swords, choices, damage, quotas and progress. Full storage
defers the gift until ordinary capacity permits it. There are no new vendors,
enemy drops or higher tiers. Evidence: assets/validation_43717. Static/native
verification and author acceptance are separate. All three author checks
passed on 2026-10-04. Earlier release descriptions of Ronnie's sword loan are
historical and are superseded by this section.
Native verification passed 117 assertions, including crafting, both attack
inputs and old-save reload/travel/rollback; visual captures confirm the author's
20-degree clockwise rest pose. Asset generators reproduced identical bytes.

## 4.37.16 - Navigation HUD and project menu identity (#87)

Implemented the view-driven top-left compass, bilingual cardinal/intermediate
directions, Sun of May selector and logo-derived C moon pointer. The author's
compass correction centers the visible letters and adds silver laurels with
a subdued Sun of May background. Presentation
only: maps, balance, controls and persistent schemas are unchanged. North +Y
matches both the cardinal maze and fortified city's exits. Static/native
evidence is in assets/validation_43716; CA-43716-UI-01/02/03 passed author acceptance on 2026-10-04.
The author confirmed physical pointer click/drag and all visual checks.
The earlier agent-side Computer Use interruption remains historical evidence.

## 4.37.15 - Traditional Truco ranked mode (#101)

The author's ranked mode is ordinary Argentine Truco against Argento, with
30-point matches and optional Flor selected before the deal. It does not yet
include a rating, ranks, wagers or rewards. A separate revision-1 match inventory
preserves the accepted Trucazo practice and its existing saves. Its own pause,
menu, calls, points and native save/load are validated separately. Existing
physical deck ownership permits either mode; no new campaign item is added.
Evidence: assets/validation_43715. Author checks passed 2026-10-04.

## 4.37.14a - Argento practice choice near the end (#99)

The existing practice choice is now the last ordinary reply before goodbye
in all four Argento pages that offer it. Other replies retain their order,
conditions and actions. Evidence: assets/validation_43714a; author check
CA-43714A-ARGENTO-01 passed author acceptance on 2026-10-04. Match rules and saved page indexes are intact.

## 4.37.14 - Palomo gives the deck upstairs (#97)

Palomo hands over the physical Tarot deck as soon as his first top-floor
conversation opens after the player follows him. This is the equipment-plan
conversation, before completing the resident trials or receiving the Box.
Repeated dialogue preserves the same deck; capacity failure permits another
attempt. Existing saves receive it on the next eligible conversation if it
has never been granted. No new save fields or migration revision are needed.
Evidence: assets/validation_43714; CA-43714-DECK-01 passed author acceptance on 2026-10-04.

## 4.37.13a - Visible crafting time shortcut (#93)

The author reported that Y worked but was missing from the bottom crafting
help. The EN/ES footer now lists keyboard Y for time skipping beside T for
acceleration; the active-task status repeats both. Input, work/skip mechanics
and save schema are unchanged. Evidence: assets/validation_43713a. Author
check CA-43713A-CRAFT-01 passed author acceptance on 2026-10-04; #81 acceptance remains separate.

## 4.37.13 — Trucazo practice against Argento (#81)

The first complete human-versus-NPC match starts through Argento's normal MAP01
dialogue, using the physical deck from #80. The author's original Trucazo v2.0
source and 2026-10-04 corrections are consolidated in SYSTEMS: one shared deck
of 56 Minors, five-card initial hands, two nonplayable rows, traditional calls,
ties to mano, Patience-squared health and Type 1 Intelligence damage. The match
repeats hands until a knockout; abandoning is defeat. No Majors, Magic Senses,
wagers, campaign rewards, item transfer or world damage apply to this practice.

The native menu pauses the world, shows existing card art and bilingual legal
actions, and permits native save/load. A revision-1 traveling Inventory owns
the match. Older saves create no match until challenged; current saves preserve
the exact deal, calls and settled outcome. A static controller restores the
menu after load, including when an unrelated old menu was still present.
NPC decisions consume only their own hand and public cards/calls. Existing
furniture capacities, dining/rest and world Tarot powers remain unchanged.

Evidence is in assets/validation_43713. Static checks, target-engine checks and
author acceptance are separate. CA-43713-TRUCAZO-01/02 passed on 2026-10-04,
and the author authorized #81 closure/PR #94 merge. The #99 choice-order change
remains separate. Human multiplayer, teams, broader ranked/
casual services and full Major-card expansion remain outside this slice.

## 4.37.12 — Campaign Tarot powers and physical deck (#80)

The author approved a shared activation of up to three captured essences for
1000 Anima, 60-second effects and a 600-second cooldown from activation, without
manual cancellation or refund. The Fool grants native flight. Minor Arcana
double their own fixed contributions: the campaign Ace gives +2 each to its
three social attributes and the Knight gives +1.2 Strength. Permanent collection
percentages remain unchanged. The shared rule covers the existing 56-Minor
passive catalogue without adding acquisition content or granting essences.

Enter/A selects cards in the Tarot Journal; User3 activates the whole selection,
including while unarmed. The Journal reports actual effects, timers and physical
deck location. The HUD places duration/cooldown above the side Seal indicator.
Selected and activated sets are separate; changes affect the next
activation. Native flight controls are exposed in Caelum's Controls section.
The authored world transition, User1, User2 and User4 remain unchanged.

Palomo gives one complete physical deck with the Box: 78 cards, 780 grams and
one slot. Final author policy makes it unsellable, undroppable and unbreakable.
Capture requires it inside the player's own Box at start and commit; powers
remain personal and independent of deck location. Limbo departure preserves it.

Additive revisions preserve existing essences, initialize an empty selection and
recover a missing legacy deck once from recorded Box delivery or essence
ownership. Insufficient capacity retries after space is freed. Preserve original
saves/packages for rollback. Personal time, including rest/travel simulation,
advances saved timers without granting free resources. Evidence:
assets/validation_43712/RESULTS.json. The author confirmed both Tarot checks
passed on 2026-10-04 and authorized #80 closure and PR #92 merge; HISTORY
records their IDs and results.
Remaining Major powers, acquisition content and awakening stay V5 work. Trucazo
is #81 and full-city performance remains #86.


## 4.37.11 — The amnesiac captain of Barracas al Sud (#79)

The protagonist is the captain of the guard of fortified Barracas al Sud. Local
guards recognize him after his return from Limbo, but his past remains missing.
This replaces the active unaffiliated-wanderer premise; HISTORY preserves its
original wording. The prologue retains the Unknown Voice and Limbo mystery.
Chosen character profile, class, attributes, abilities, equipment and factions
remain unchanged. The captaincy grants no gameplay authority or reward.

Local living guards use native dialogue to recognize him, with an amnesiac
response and a repeat branch. Opening recognition records one completed main
Journal clue; it does not restore memories or complete any other quest. Neither
recognition nor its repeat branch depends on prisoner rescues or siege victory.
Active fighters retain native conversation restrictions; calm guards and surviving
guards after the assault provide the interaction. Existing combat resumes afterward.

Quest revision 3 initializes only the previously reserved clue slot for old
version-2 saves, without inferring that earlier port visits revealed it. Existing
conversation pages retain their indexes; new pages are appended. Native validation
and author acceptance are reported in HISTORY and `assets/validation_43711`.
The author confirmed both CA-43711-CAPTAIN checks passed on 2026-10-04 without
reported exceptions and authorized PR #90 merge / #79 closure. HISTORY records
acceptance; `pending_test.txt` has no remaining #79 checks. #86 retains performance work; future
siege scheduling and unspecified biography remain pending author decisions.

## 4.37.10 — Post-payment prisoner siege intelligence (#78)

Implemented on `issue-78-prisoner-siege-intelligence`: all four rescued prisoners
brief the player after successful port payment, with shared bilingual Journal
information for upcoming/unconfirmed, active and completed siege states. Location
and recorded dates use the existing world/calendar data. No future deadline is
invented; that author decision remains PENDING. Current siege entry/deployment,
both victory requirements, zero/partial/all-rescue completion and rewards remain.

MAP01 records the authorized concealed Selene service, anti-demon motivation,
implanted-soul/body identities and Chapter II death boundary. Player-facing lines
preserve the mystery and amnesia. #79 owns guard-captain recognition; #86 continues
the separately recorded performance work. No map, asset, combat or balance change.

Evidence: `assets/validation_43710/RESULTS.json`, native GZDoom 4.14.2 Windows
dialogue/queue, payment, calendar, save and hub checks. The original USDF page
indexes and persistent schemas are preserved. On 2026-10-04 the author confirmed
both CA-43710-BRIEFING checks passed without reported exceptions and authorized
PR #88 merge / #78 closure. HISTORY records the results; no #78 author checks
remain. This confirmation is separate from native test evidence.

## 4.37.9 — Expanded southern Barracas al Sud (#77)

The author's final 2026-10-03 direction supersedes the first 96 m northern layout.
MAP06 now contains a 960 × 960 m city: 160 houses (including the two retained port
buildings), 64 shops, 24 factories and 40 construction sites. The 288 constructions
have connected streets and avenues; different façades, counters/awnings, industrial
halls/chimneys and incomplete masonry/timber works distinguish their uses.
The existing harbor arrival, prisoners, bed, workbench and both piers remain.

Six breakable gates integrate the attacking front into the city south wall.
North and west also have fortified gates; the eastern arch reaches the docks.
These exits remain local MAP06 passages. A raised walk connects the perimeter,
with physical stairs to every gun position and four traversable corner towers.
The author increased the forces to 6,000 Mandingas plus one commander and 600
soldiers. Attacking machines remain five small rams, one large ram and six guns.
Defenders have 36 guns: eight per wall plus four tower guns. Only the eight south
wall guns and four tower guns fire during this siege; the other 24 are staffed
reserve emplacements. Two hostile gun positions on the southern flanks give
the northern towers real visible targets without changing cannon physics.
Each attacking command group is now capped at 100 members including its leader,
as requested by the author after the live freeze check. Excess neighbors form
additional groups; rank priority, stable ties and the full population remain.

Normal progression remains MAP01 → MAP02 → MAP06, using stable connection 16
and network revision 4. It retains Ace/Zupay prerequisites and the accepted
10 km provision/time transaction. Saves already in the former MAP03 workshop
retain their legacy onward route. City exits introduce no diagnostic travel.

Use a fresh/unvisited MAP06 for the expanded southern city. For a previously
visited port, select its exact geometry: --legacy-map06-north-city for the first
4.37.9 northern city, --legacy-map06-siege for 4.36.27–4.37.8, or --legacy-map06
for the pre-siege 4.36.26 port. These three alternatives are mutually exclusive;
each can accompany --legacy-map02. Existing populations, positions, casualties
and rewards stay in those saved layouts. Keep original saves/packages for
rollback; no old MAP06 geometry or army is reset or transplanted.

Current evidence is assets/validation_4379/south. The original validation_4379
files describe the superseded first iteration. Static generation/connectivity,
native collision and actual-tic traversal, all 36 physical crew replacements,
both victory orders, persistence and measured full-scene throughput are distinct
checks; their available evidence remains scoped to each run. Display FPS is not inferred.
CA-4379-CITY-01 and CA-4379-ROUTE-01 passed author acceptance on 2026-10-03. Narrative
intelligence/captain identity and later V4.37 work remain separate issues.

The author subsequently requested nearest-visible player/guard targeting,
shared attack range/cost enforcement, retreat/idle recovery, Pain interruption
and double chair/idle Anima. Player ranged projectiles also obey their authored
limits. SYSTEMS records the contract; COMBAT_RECOVERY.json under
assets/validation_4379/south records 90 native checks, save persistence and the
live comparison. CA-4379-COMBAT-01 also passed author verification on 2026-10-03.

The full-army live check still **fails performance**: late throughput is about
13.5 tics/s versus the normal 35, despite Windows responding in all 248 samples
of the 300.5-second run. The preceding comparison measured 3.9 before targeting
changes and 14.3 with targeting alone. These unseeded runs do not isolate causes
or measure display FPS. GROUP100.json and LIVE_FREEZE.json preserve earlier
failures. No permanent deadlock was proven. On 2026-10-03 the author approved
PR #85 merge and #77 closure, deferring performance work to #86. A subsequent
explicit confirmation approved all three manual checks; HISTORY records them.
This author acceptance does not rewrite the prior measured performance failure.

## 4.37.8 — MAP02 material ledger and finite-supply audit (#75)

Gameplay was implemented and author-accepted with #73, then retained by #74.
This delivery corrects an audit artifact: 63 equipment instances (315 item/size
rows) were joined to native recipe output by array position instead of
catalogue_index. Original and current native inputs agree; all aggregate
quantities are unchanged. The old report remains historical evidence.
assets/validation_4378/MATERIAL_LEDGER.json supersedes its per-instance associations.

The new auditor checks the WAD/manifest, carriers, identities and native inputs:
866 checks pass; 11 invalid variants are rejected, including the old positional
join. Two isolated generator runs reproduce all four outputs byte for byte.
GZDoom 4.14.2 completes 325 recipes with exact per-instance budgets and passes
the keyed route, finite drops, partial/capacity collection and save/hub persistence.
Recipe fixtures supply known recipes, station capabilities and Box ownership;
product station, knowledge, efficiency and time requirements remain unchanged.

CA-MAP02-MATERIALS-DROPS-01 was accepted on 2026-10-02 (4.37.6 / #73 and #75).
No unchanged author check is requeued or new manual campaign pass inferred.
The previous-save waiver and retained stations remain approved. On 2026-10-02,
the author accepted the corrected report and #75 delivery without reported
exceptions and explicitly requested PR #84 merge and #75 closure.
Tarot/Trucazo remains later work.

## 4.37.7 — Flooded MAP02 return (#74)

The six floor traps now drop into a connected lower water network with no stair
or ladder exits. Four independent, exterior-operated grates surround a native
moving-floor elevator returning to the central start. One grate is sufficient.
The author approved keeping a closed block's trap covers shut until its normal
entrance opens; this prevents enemies or upward jumps creating a progression
bypass. Existing locks, cells, extraction, population and #75 supplies remain.

The author explicitly waived compatibility with previous saves for this patch.
Start fresh; new-layout saves and MAP03 hub returns are tested. Static and native
evidence is in assets/validation_4377. On 2026-10-02 the author confirmed all
CA-MAP02-PIT-RETURN-01 checks passed without reported exceptions and authorized
PR #83 merge and #74 closure. The author-test queue is empty; HISTORY records
acceptance separately from agent evidence. Tarot/Trucazo remains later work.

## 4.37.6 — Cardinal MAP02 (#73, coordinated #75 loot)

Fresh MAP02 now starts at the central hub. The four blocks occupy south, west,
east and north, retaining that logical progression and the northern Zupay.
The #75 supplies explicitly included in #73 are material equivalents in 39
chests and guaranteed finite enemy drops. The #74 flooded return is not part
of this patch: the central elevator footprint is reserved and opens no bypass.
The author waived compatibility work for existing saves on 2026-10-02;
start a new campaign for this geometry. New-map save/load and hub state are tested.
The author also confirmed keeping current stations; unavailable crafting branches
require another workshop. Native evidence and author acceptance remain separate.
The author accepted both CA-MAP02 checks on 2026-10-02 and authorized merge
and closure of #73. See SYSTEMS for the contract and assets/validation_4376
for evidence; #74 remains separate.


## 4.37.5 — Daily food and water on mansion tables (#65)

Implemented on issue-65-daily-tables, based on #64 / PR #71 and delivered through
a separate dependent PR. Fresh mansion tables use the authored 50/50 ration-slot
targets; local midnight restores missing portions once. Normal time, fast-forward
and explicit skips share the event, including chronological multi-day consumption.
Palomo explains the daily timing. Player belongings and old food remain intact;
revision-1 migration fills only free slots. No other map receives provisions.

Evidence: assets/validation_4375/RESULTS.json, with static/build and isolated native
checks separated from author acceptance. The author confirmed all five #64/#65
checks on 2026-10-02 without reported exceptions and authorized both merges and
closures. PR #71 is merged and #64 closed; PR #72 delivers the dependent #65.
HISTORY records each accepted ID and originating release. No author checks remain
pending; runtime and release 4.37.5 are unchanged by this acceptance update.

## 4.37.4 — Time skipping with automatic care (#64)

Implemented on issue-64-time-skip: Y selects a local/civil destination independently
of the existing T fast-forward. Actual provisions and available furniture sustain
needs; sleep at 10% to 100% pauses productive work. The task default includes sleep
and reports unavailable completion forecasts. Clock revision 1 preserves old
records and separates Limbo-local time from the frozen exterior calendar.

Native checks cover normal/skip and fast/skip equality, eight hours asleep with
zero work, actual consumption, forecast costs, cancellations, saved sessions and
old-package rollback. Reproducible evidence is in assets/validation_4374/RESULTS.json.
Static/build results are recorded there separately from native execution.
The author accepted all three CA-4374 checks on 2026-10-02 without reported
exceptions and authorized PR #71 merge / #64 closure. HISTORY records the
confirmation; no #64 author checks remain pending. The tested runtime is unchanged.
Daily mansion food/water replenishment is the separate #65 / PR #72 patch.

## 4.37.3 — Palomo's equipment plan and owned equipment departure (#63)

Palomo invites the player to follow his existing physical route inside and
records weapon, armor, Seal and shield choices. Review and backtracking precede
each confirmation; explanations use the existing catalogue and current derived
costs. Ronnie teaches and supplies that same persistent plan after Caella's
trial. Caella retained the amulet choice at #63; #96 moves it and a one-time
gift to Palomo, retaining her recipe lesson. The selected shield uses established
bronze/strap recipes and existing copper, tin and leather sources.

All actual owned equipment and the Magic Box now survive the narrative exit,
including equipped, carried and boxed pieces. Author clarification, 2026-10-01:
remove ammunition (including magazines), materials, coins and consumables.
Borrowed trial props follow their existing return rules. A choice never grants
an uncrafted item or reconstructs a destroyed first weapon. Equipment identity,
size, condition and placement remain native inventory state.

Loadout revision 1 migrates legacy owned equipment classification once; old
choices, issued allowances and completed tutorials remain. No map conversion.
Keep original saves and their original package for rollback. Static/build and
isolated native evidence: assets/validation_4373/RESULTS.json. The author accepted
all three CA-4373 checks on 2026-10-01 without reported exceptions and authorized
PR #70 merge and #63 closure. HISTORY records the IDs and results; no author
checks remain pending. The tested runtime is unchanged.

## 4.37.2 — Reduced magic-weapon Anima costs (#68)

After accepting #62 / PR #67, the author requested tenfold lower magic-weapon
bases on 2026-10-01. T1 staff/book/bell/statuette now cost 50/70/100/100 before
the existing Eloquence Type 4 divisor. Eloquence 100 costs one third; tier and
charge multipliers retain their accepted values. Player and authored NPC magic
share the reduced constants. Other costs, damage and resource recovery remain.

Existing saved derived costs and pending casts update once through attribute
revision 3, preserving resources, elapsed cast state, inventory identity and
quest progress. Original saves/packages provide tested rollback. Evidence and
scope: assets/validation_4372/RESULTS.json. The author accepted all listed
CA-4372-ANIMA-01 checks on 2026-10-01 without reported exceptions and authorized
PR #69 merge and #68 closure. The tested runtime remains unchanged.
Deferred Tarot/Trucazo remains separate.

## 4.37.1 — Caella's practical exercises on the shared dummy (#62)

Caella's primary and secondary spell exercises now require a valid impact on the
existing training dummy in the north-central ground-floor room. Empty casts,
other targets and physical attacks do not satisfy those two objectives. Anima
expenditure/recovery and actual Seal Channel consumption remain separate checks.
Dialogue, Journal directions and completion feedback explain this in English
and Spanish. Rulo keeps the same recoverable, indestructible practice target.

The five practices, four-rune order, return to Caella, loan ownership and passage
rules are preserved. No map, equipment balance or persistent schema changes.
Existing active/completed 4.37.0 saves retain earned progress, including offensive
flags earned under the former cast-based rule. No reset or conversion is needed.
Static and isolated GZDoom checks pass, including forty spell combinations and
active/completed save continuity; evidence is in assets/validation_4371/RESULTS.json.
The author confirmed all tests passed on 2026-10-01: CA-4371-CAELLA-01 is
ACCEPTED without reported exceptions (#62 / PR #67). The tested runtime is
unchanged. Next: the separately requested Anima-cost balance patch; deferred
Tarot/Trucazo remains separate.

## 4.37.0 — MAP01 rolling grounds and filled tympana (#61)

The author requested implementation on 2026-10-01 after the accepted export,
selected mixed gentle/marked hills and decorative-only new vegetation, and
explicitly waived old-save work for this reconstruction. This starts the 4.37
line; deferred Tarot/Trucazo remains separate final V4 work before V5.

MAP01 gains continuous native sloped ground around the mansion, sixteen scattered
ceibos and twenty-four decorative shrubs. The accepted four harvestable ceibos,
twenty fiber shrubs, gathering quantities, entrance, cave/pool, NPC placements
and tutorial logic remain unchanged. Every one of the 32 door groups has an
opaque tympanum: triangular singles, arched doubles, with solid visual backing
across the complete upper opening. Hinged leaves and their access rules remain.

Static continuity/preservation and dry-placement checks, native terrain/resource/
Palomo checks and 429 door regressions pass. Evidence, 128 door-view hashes and
representative captures are recorded under assets/validation_4370. The pool is
kept free of vegetation, including underwater. On 2026-10-01 the author accepted
the other checks and reported transparent distant ground plus a roof-front gap
above the top door. This same patch bounds the exterior floor and closes that
gap against the native roof slopes. The author then accepted both repairs and
the rest of CA-4370-MANSION-01 on 2026-10-01.

The next Prueba save identified another transparent-ground site near
(23268,23285,0). The author requested a small cave there, choosing a mouth in a
mound, gentle descent, a roughly 10–15-metre bent tunnel with a closed end, and
decorative rocks of all five existing gems. This same landscape patch adds that
native cave and refines the distant floor partition. No resources or progression
are added. The author accepted CA-4370-CAVE-01 on 2026-10-01, reporting a separate
invisible boundary and dark region near (25630,29408,0). Sixty-nine detached
auxiliary rooms intersected or touched the playable exterior. Their polygons
are now outside the horizon; all sector planes, actions and targets remain.
CA-4370-EXTERIOR-01 was accepted on 2026-10-01. Native checks cover the repaired area,
unchanged mansion surfaces and doors; evidence is in CONTROLS.json under the
same validation directory. Use a fresh MAP01/new campaign.
The author then reported workstations left among the northern hills. Six old
station actors at Y=1040 escaped relocation because the code required absolute
Z=0, while the relief places them at Z=1.08..3.30. Comparing against their native
floor height restores the intended 38 interior stations and preserves all
original actors. The author confirmed all remaining tests, including
CA-4370-STATIONS-01, on 2026-10-01 and authorized PR #66 merge/issue #61 closure.
No #61 author checks remain. Evidence: STATIONS.json; acceptance is recorded in
HISTORY. The acceptance update preserves the tested runtime and release 4.37.0.
Next: deferred Tarot/Trucazo.

## 4.36.28 — Reproducible three-map playtest export (#17)

Author decision, 2026-10-01: export the accepted 4.36.27 content now and postpone
4.37 Tarot activation/Trucazo until after this playtest. This explicitly replaces
the former 4.37-before-export gate; it does not implement or cancel that work.
Baseline: merged #16 / PR #59, commit 0a584960eaeecfac31db82adadb7426347c50964.
The three campaign maps are MAP01, MAP02 and MAP06; MAP03 remains their workshop
connector. Existing auxiliary hub maps and the separate console-only CADEV02
remain intact; they are not additional completed campaign chapters.

The commit-based exporter writes fixed-metadata, uncompressed ZIP/PK3 archives,
per-file SHA-256 inventory, package checksums, portable launchers, installation,
controls, route/report guidance and license notices. It includes only committed
runtime resources plus those delivery files; no engine, IWAD, QA overlay,
development saves, stock sources or repository archive is distributed.
Gameplay, balance, visuals and save schemas retain the accepted baseline.
The 2026-10-01 launcher correction automatically finds gzdoom.exe and DOOM2.WAD
beside the package, supports quoted paths/folders and resolves relative paths
against that directory. Six isolated launcher-process checks pass. On 2026-10-01
the author confirmed all tests passed after the correction and authorized
PR #60 merge and #17 closure. CA-43628-EXPORT-01 is recorded as PASS in HISTORY;
the author queue was empty at that acceptance. This explicitly accepts the exported-package route,
separately from the earlier component and isolated engine evidence.

Evidence and exact accepted source commit: assets/validation_43628/RESULTS.json.
The acceptance update preserves the tested ZIP from 8415f225, gameplay and saves.
GitHub Release/tag publication was not requested. Next: deferred 4.37 work.
Current dependencies remain GZDoom 4.14.2 and a separately supplied Doom II IWAD.
This is a single-player playtest, not the final independent distribution.

## 4.36.27 — Third campaign map: port siege (#16)

Implemented the complete bounded MAP06 encounter and the author's latest cannon,
defender and commander decisions. SYSTEMS is the current rule contract; MAP01
documents the campaign route, ASSETS the geometry/provenance. Native evidence
includes the concurrent 1,001-attacker, 100-defender, 24-machine scene, both
objective orders, shared capture/rewards and save migration/rollback. Evidence:
assets/validation_43627. The author confirmed all campaign, visual/balance and
save-continuity checks passed on 2026-09-30 and authorized PR #59 merge and #16
closure. This patch does not close #17's export or the separate 4.37 gates.

The author then reported no relief for lost operators and widespread stationary
attackers. Crew slots now recruit existing free combatants. After the initial
physical-pursuit fallback, the author requested a reversible trial permitting
port enemies to use both attack types despite Air/Anima exhaustion. Counts,
cadence and player/allied limits remain. See assets/validation_43627/relief and
resource_trial; the author accepted these follow-ups in the same confirmation.

## 4.36.26 — Attack cadence and thrust presentation (#37)

Implemented: the author-approved 14-tic weapon/hand-load formula with effective
Dexterity/Eloquence; weight rejection; shared full-duration first-person attack
presentation and the five explicitly requested thrust variants; weapon durability
×10 with proportional revision-1 migration and exact originating-item projectile
wear; authored hostile Air costs and idle recovery; the 80-tic Zupay slam.
SYSTEMS holds the contract and ASSETS the presentation/provenance. Native rules,
twenty-family cycles, held input, interruption, enemy recovery, save/load and
rollback checks pass; evidence is in assets/validation_43626. The author confirmed
both combat and visual checks passed on 2026-09-30 and authorized PR #58 merge
and issue closure. #16/#17 integration/export are separate.


## 4.36.25 — Mansion architecture and enclosure (#36)

MAP01 now closes the upper-storey gables against the existing pitched roof,
completes balcony guards, separates interior wall finishes from exterior
render and adds closed wooden shutter panels and two wall-mounted reliefs.
The four outer boundaries retain collision but render the Limbo horizon.
Stairs, tutorial mechanics and the cave remain. The author's follow-up adds
the flat upper ceiling, raised shutters, corrected east-wing walls and hinged
wooden doors. The 2026-09-29 clarification removes four side connectors at
Z=136 and separates the front entrances into four independent singles centred
on their rooms. Other placements and storeys remain unchanged.
The door model now uses three material surfaces instead of 222, fixing the
reproduced intermittent zero-size-texture startup failure (CA-KP-020).

The author approved the restrained aged-render/wood/iron/relief visual proposal
on 2026-09-28. The historical assessment and official heritage reference are in
ASSETS; this remains a stylized Limbo mansion, not a reconstruction of a named
nineteenth-century residence. The author explicitly prioritized rebuilding over
old MAP01 save compatibility: start a fresh MAP01/new game for this revision.
The original map is preserved as the generator baseline, not packaged at runtime.

Static, deterministic regeneration and isolated GZDoom evidence are recorded in
assets/validation_43625/layout (earlier iterations retain their evidence).
The author accepted the remaining prior work on 2026-09-29, requesting only
fixed central-room swings for Rulo/Ronnie/Argento's side doors and moving the
practice target to the empty north-central ground-floor room. Both are
implemented, including target detection and bilingual directions. Latest
checks are in assets/validation_43625/furnishing. The author confirmed those
tests passed and requested the same fixed corridor-side swing for Caella's
bedside door (908). Implemented and checked in assets/validation_43625/caella.
The author confirmed CA-43625-MANSION-01 fully passed on 2026-09-29 and
authorized #36 closure and PR #57 merge. No #36 author checks remain; #17
export remains a separate task.

## 4.36.24a — Proprietary rights notice (#55)

The author requested an explicit all-rights-reserved notice. Root
[LICENSE.md](../LICENSE.md) covers only rights owned by Damián Curti, preserves
third-party terms and statutory/platform exceptions, and grants no general
reuse license. README links the notice. This documentation-only patch leaves
runtime behavior and existing acceptance unchanged.

## 4.36.24 — Quest journal categories and history (#35)

The Journal now filters main/side and active/completed independently, retains
completed records and projects the demo's existing sewer and four rescue records.
The author confirmed mansion = main; sewers and port siege = side; each rescue
is optional, completed by live extraction with payment recorded separately.
SYSTEMS documents stable IDs, controls, discovery and legacy evidence limits.
No reward, balance, narrative gate, map or authoritative save schema changes.

Static validator/build and focused Windows GZDoom 4.14.2 evidence are recorded
in `assets/validation_43624/RESULTS.json`. Old-save load, new-save reload, hub
travel, actual quest APIs, port encounter/payment checks and English/Spanish
journal navigation/layout are covered. This is isolated engine evidence, not
an ordinary campaign acceptance. Separately, the author confirmed all
CA-43624-JOURNAL-01 checks passed on 2026-09-28 and authorized PR #54 merge
and #35 closure. Full port deployment (#16) and playtest export (#17) remain
separate gates.

## 4.36.23 — Final armor absorption (#52)

Author revision, 2026-09-28: attacks and collisions now subtract Toughness
through its historical growth R(L)=L(L+1)/101 as percentage points of maximum
health, uncapped and with no minimum-damage floor. This supersedes the initial
direct-level subtraction. An
incoming 101% at Toughness 100 leaves 1% before armor; <=100% is still negated.
Final gate revision, also approved on 2026-09-28: Constitution 0 for all gates;
Toughness 25/50/75 and maximum resistance 5,500/6,500/11,000. Armor remains
10/20/30%. Small rams break common/reinforced/armored gates in 2/2/7 hits;
large rams in 1/2/2. Cannons retain Toughness reduction and deal zero gate damage.
Gate balance revision 2 preserves remaining-health ratio, open/broken states
and contact serials; repeated loads are idempotent. See SYSTEMS.
Current native evidence supersedes the previous matrices, retained as
DIVISOR_RESULTS.json, TOUGHNESS_RESULTS.json and GATE_RESULTS.json in
assets/validation_43623. The curve revision changes no saved levels or maxima. Release remains 4.36.23 because
all author revisions and acceptance belong to the same issue/PR patch.

Ordinary damage now resolves shield, anatomy/critical, Toughness, then armor.
Innate body defense adds to the struck piece's physical/magical percentage.
New equipment values and the removed magical-armor attribute bonuses share one
data source; shields and anatomical reinforcement retain their existing rules.
Common/reinforced/armored gates absorb 10/20/30% after Toughness, including siege
impacts. Native checks reproduce all nine calculated siege damage/hit counts.
Palomo's author-specified innate absorption is 77% physical and magical.
Player attribute revision 2 and NPC armor revision 1 rebuild derived values
once on old-save load, without subtracting bonuses from base attributes.
Evidence: `assets/validation_43623/RESULTS.json`. Static and isolated native
checks are separate from author acceptance. On 2026-09-28 the author confirmed
CA-43623-ARMOR-01, CA-43623-SAVE-01 and CA-43623-TOUGHNESS-01 passed and
authorized PR #53 merge. No author checks remain pending; details are in HISTORY.

## 4.36.22 — Demo quest narrative (#34)

Palomo starts quest 1 and owns optional eating/drinking, bed, Air, load,
swimming and water-container practice, plus material-acquisition directions.
Ronnie retains weapon/armor/component crafting, loans, repair and calendar
explanation. Existing progress, allowances and one-time supplies remain valid.
The author authorized original dialogue consistent with established personalities
on 2026-09-27 and explicitly included the sewer Zupay's confirmed escape.

The four mansion companions retain their own peak Bull-encounter state, using
the authoritative Herido/Malherido thresholds and seated-at-1-HP incapacitation.
The Unknown Voice's release, boss and paid-reward events persist in a queue.
The port quest observes the existing twelve-machine-plus-commander contract;
it does not create a battle. MAP06 still needs #16's deployment/routes. Until a
real sealed port encounter exists, #33's provisional Knight availability remains
in force; a registered siege gates that same card on victory, with no extra reward.

Static validation/build, isolated native behavior, real old-save migration,
queue save/load/travel and rendered USDF checks pass. See
assets/validation_43622/RESULTS.json. Separately, the author confirmed all
CA-43622-NARRATIVE-01 tests passed on 2026-09-27 and authorized merge/closure.
Next: #16/#17 integration and export gates.

The author subsequently reported a MAP02 freeze during the second rescue.
Its invalid secondary-wind sprite was reproduced and corrected through native
CELH A-L registration; isolated rendering and older-save checks pass. The author
confirmed the Federal/prisoner/rats retest passed on 2026-09-27.
Evidence: assets/validation_43622/wind_render_fix.json.

Pre-#34 open conversations also receive a compatibility correction: the old
sewer Voice restores its established ID instead of a shifted Palomo page; other
old conversations close safely and reopen through normal interaction. New saves
retain exact pages. Native load/death/reload and original-save rollback pass;
the author confirmed the retest passed 2026-09-27. Evidence: dialogue_resume_fix.json in
assets/validation_43622.

## 4.36.21 — Scenery impact correction (#49)

Trees and rocks no longer turn collision damage/pain into combat adrenaline.
The author extended the existing wall absorption to grounded running and
explicitly included stationary scenery. Moving rocks, combat contacts,
landings and existing shield behavior retain their prior rules.
This focused patch is based on the accepted #33 implementation in PR #48;
PR #48 merged on 2026-09-27, and separate PR #50 now targets main. Evidence is in
assets/validation_43621; CA-43621-IMPACT-01 passed, author-confirmed 2026-09-27.

## 4.36.20 — Shared Arcana capture and the playable route (#33)

Implemented the author's #33 instruction and 2026-09-27 clarification:
MAP01/Fool -> MAP02/Ace of Cups -> existing MAP03 workshop/test room -> MAP06/
Knight of Wands. The sewer Zupay retreats at 50% health with triple base speed,
then disappears and counts as defeated. Both Minors now use the Fool's common
Box capture procedure; availability never silently grants a card.

At the port, the Knight appears beside the survivors once every extracted
survivor's actual reward delivery is complete, or on arrival if none were
extracted. This pre-siege condition is provisional. #16/#17 must replace it
with an authored siege condition when the full encounter is implemented;
this patch does not activate that future requirement. The second Minor's
identity is now Knight of Wands, ID 60. Accepted prisoner rewards, extraction,
siege assets and table cleanup remain in force.

Static and isolated native evidence belongs in assets/validation_43620.
Author campaign/presentation acceptance passed on 2026-09-27; see HISTORY.
PR #48 merged on 2026-09-27 after explicit author acceptance and merge authorization.

## 4.36.19 — Approved final cannon/gate balance (#21)

The author approved the final calculation and requested commit/push, PR,
merge and issue closure. New cannon shots use 500 m/s; gate Toughness and
Constitution are 50/100/200. Collision damage uses the weapon Type 4 divisor
for players, combat NPCs and gates, preserving biological absorption and
anatomy/armor order. Small rams now damage armored gates in 12 frontal strikes.
SYSTEMS contains the complete approved matrix.

Gate balance revision 1 preserves remaining resistance proportion and all
passage/contact state, with tested explicit rollback/reapply support. Saved
projectiles keep their velocity. Evidence is in assets/validation_43619;
native/static checks are separate from CA-43619-BALANCE-01, confirmed passed
by the author on 2026-09-27. Merged and #21 closed; pending_test.txt is empty.
Full port deployment remains #16/#17.

## 4.36.18 — Walking wall-impact absorption (issue #43)

Extends careful wall-contact absorption to actual grounded walking. The author
confirmed walls only; running/idle/airborne movement and actor/projectile
contacts do not gain the walking benefit. Existing crouch and acrobatic defense
remain. Native eligibility/traversal and a loaded self-jump pass; evidence is
in assets/validation_43618. The author confirmed CA-43618-WALK-01 passed on
2026-09-27; merged and #43 closed.
Based on accepted #21 /PR #42; this focused follow-up does not implement the
then-proposed 500 m/s cannon speed or Type 4 collision-damage divisor;
those changes were subsequently approved and implemented in 4.36.19.

## 4.36.17 — Controlled cannon firing (issue #21)

Implements #21 on merged #20 (9676ec0d), retaining the planned [4.36.13] PR label.
Cannons load, discharge one native physical round, recover and reload through
explicit scenario hooks. The author approved the approximate reconstruction,
inert 4.3 kg /75 x 185 mm ammunition, 400 m/s speed and 30/60-second cycles for
two/one operators. No operators pauses work. Shared collisions remain unchanged;
the real gate contact causes zero damage at these inputs, while characters
retain their mass, Toughness, armor and anatomy responses.

Six attacking and twelve defending cannons are supported with persistent
ownership; only attackers count toward the twelve-machine objective inherited
from #20. Neutralization never deletes an already released round. Campaign
placement, operator allocation, ammunition and aiming remain #16, with complete
encounter acceptance in #17. CA-436-04 now has isolated implementation evidence;
CA-43613-CATAPULT-01 retains its historical ID but tests cannons, not catapults.
Evidence is in assets/validation_43617: 41 cannon and 53 ram/shared-siege
regression checks passed, along with save/hub/legacy persistence checks.
The author confirmed CA-43613-CATAPULT-01 passed on 2026-09-27.

## 4.36.16 — Usable battering rams (issue #20)

Implements #20 on merged 4.36.15, retaining its planned [4.36.12] PR label.
Mobile rams approach authored targets, align, strike through native collision,
recover and repeat. Moving-assembly mass and actual contact speed reuse the
accepted physics/gate response. The author confirmed full staffing (6/32) and
demonic velocities so small rams affect wood/reinforced gates and the large
ram also affects armored gates. SYSTEMS and ASSETS separate decisions,
reference-based estimates and provisional playtest controls.

An opt-in encounter API remembers local attackers and confirmed deaths,
neutralizes each machine once, and starts actual route-based withdrawal only
after twelve hostile machines and the Zupay are defeated. Final port routes,
1,000-Mandinga allocation, rewards and placement remain #16; cannon mechanics
remain #21. Six operational ram lanes can be created explicitly in disposable
MAP03 with `give CaelumDebugRamTrial`; repeat activation is idempotent.

Evidence is in assets/validation_43616: static validation/build passed, along
with 53 native ram checks, 50 gate/body regression checks and save/hub/legacy
persistence checks. The author confirmed CA-43612-RAM-01 passed on 2026-09-26
and requested merge/closure. CA-436-03 now has functional ram evidence and
author acceptance; complete-port integration remains #16/#17.

## 4.36.15 — Breakable actor gates (issue #19)

Implements the issue retaining its planned [4.36.11] PR label, on top of the
merged 4.36.14a baseline. Opt-in gates reuse #18 visuals, finite collision
blocks, group/key/faction access, canonical health/impact rules and persistent
destruction. The author approved the Type 4 interpretation and Constitution
matching Toughness, plus 550/650/1,100 kg moving masses on 2026-09-26; SYSTEMS
contains the authoritative formulas and resulting values.

Native GZDoom 4.14.2 checks passed: fresh gate collision/combat, group access,
real partial/broken save-load, MAP03-MAP06-MAP03 hub return and an existing
4.36.14a save. The optional MAP03 trial is executable with
`give CaelumDebugGateTrial`; normal galleries and existing progression doors
remain unchanged. This is the reusable port-gate foundation, not the complete
MAP06 encounter or authored port placements. #20/#21 own ram/cannon operation;
#16/#17 own encounter integration. Author test CA-43611-GATES-01 passed on 2026-09-26.
Evidence and tested source hashes: assets/validation_43615. The author confirmed
the other checks on 2026-09-26 but found that body collisions did no damage. The
same-patch correction connects native player/NPC contacts to reciprocal Impact
Physics with whole-gate identity and canonical rearm; 13 focused assertions and
37 gate regression checks pass. The author subsequently confirmed all tests
passed on 2026-09-26; the collision retest is accepted and #19 is complete.

## 4.36.14a — Author-requested siege asset correction (#18)

The closed #18 receives a focused visual follow-up: continuous two-leaf gates
in wood, reinforced wood and iron-clad armor; clearer cannon and ram geometry;
and independent per-state rendering. MAP03 displays nine gate previews plus
the four cannon and three ram states. No balance, campaign geometry or save
schema changes. The original author acceptance remains historical; the revised
appearance passed `CA-43614A-SIEGE-ART-01` on 2026-09-26. MAP03 now retires
remaining furniture and crafting stations and suppresses their automatic
placement, including cleanup when loading an existing save. Other maps retain
their facilities. Exact historical cannon dimensions
remain unverified. See ASSETS for reference geometry and evidence limits.

## 4.36.10 — Reusable siege preview assets (issue #18)

Issue #18 is a visual-assets delivery, not a gameplay change. A deterministic
generator produces the reusable cannon, battering ram and destructible gate
meshes plus their per-state sprite frames and `MODELDEF` bindings. The MAP03
workshop/tank shows a visual-only preview gallery: its trial chairs, dining
tables and cots are retired, and every cannon/ram/gate state is laid out in the
open reservoir for the author to check appearance, orientation, attachment
points, collision envelopes and clearances before the siege mechanics land in
#19-#21. Mass, damage, reload time and gate hardness remain unverified and are
not invented here.

The preview does not alter MAP01/MAP02, recipes, economy, save schema or the
accepted station/rest systems. The only persistent addition is the static
gallery actor data in `src/caelum/world/CaelumSiegeAssets.zs` and its
`src/ZSCRIPT` include, plus the generated `src/models/caelum/siege` and sprite
files.
## 4.36.8 — Prisoner rescue, escort and port rewards (issue #14)

The four MAP02 prisoners become optional live companions: a cell dialogue
releases each captive, and a freed prisoner follows and fights with the source
character's accepted combat statistics while staying back from the northern
Zupay. A follower is extracted only by reaching the pre-boss reservation alive
before that boss fight; killing the boss is not required, and a follower that
dies earlier is not rescued. Zero, one or four rescues are valid. Each outcome
persists across save/load/travel, and each rescued prisoner appears once at the
MAP06 port, granting +10 reputation with that prisoner's own faction and 25 gold
coins (1,000,000 copper) once, independent of character size, with retryable
coin delivery and no duplicate payout. Six canonical factions (Unitarians,
Federals, Free Peoples, Caelith, Cult of the Tarot and Sun Warriors) replace
the provisional social domains without relabeling accepted IDs 0-3; broad
companion formations remain out of scope.

The author confirmed CA-4368-RESCUE-01 passed on 2026-09-25, covering release,
follow, combat, extraction, persistence, the one-time port rewards and the six
canonical factions, and requested closure of issue #14.

## 4.36.7 — Recolored prisoner appearances (issue #13)

MAP02 places one inert, friendly, invulnerable prisoner in each of its four
reserved endpoint cells. The appearances reuse the accepted mansion actor
sprites and combat profiles, recolored deterministically per material
(hair/fur/cloak/cloth) with muted per-faction ramps; skin and metallic
accessories keep the accepted RGB, and no new character model or replacement illustration is created.

| Visual/profile source | Gameplay faction | Provisional display name | Recolor |
| --- | --- | --- | --- |
| Caella | Unitarians | Leonor Benítez | Celeste |
| Ronnie | Federals | Rufino Acosta | Punzó red |
| Rulo | Free Peoples | Santos Barrera | Black/brown/green |
| Argento | Cult of the Tarot | Leandro Farías | Gold/silver over black |

Each prisoner is a distinct identity: persistent map IDs and class names do not
depend on the provisional display names. Appearance reuse does not inherit
mansion anchoring, prologue quest identity, trade inventory, faction assignment
or story-protection behavior. The cells keep their stable lock/route geometry;
rescue, escort, combat and rewards remain #14. Original mansion NPC art is
unchanged; in the same release their MAP01 idle cycle alternates the accepted
monster idle A and B breathing poses. While inert, each prisoner keeps the
accepted A/B idle breathing poses and never enters the walking/chase animation.
The author visual check CA-4367-PRISONER-ART-01 passed on 2026-09-24.

## 4.36.6 — Hostile sewer rats (issue #12)

MAP02 keeps its four keyed sections and all accepted #10/#11 contents, and adds
two hostile sewer rats per Mandinga: 192 rats against the retained 96 Mandingas
and one Zupay (a fixed 2:1 ratio, 24 Mandingas / 48 rats per section). Rats
reuse the existing accepted `CaelumGiantRat` actor (DoomEdNum 18029) and RATG
sprite/combat profile. No new art, damage, health, AI or balance value is
introduced.

Placement is deterministic: the MAP02 generator writes two fixed dry-walkway
positions per Mandinga junction and records each rat in the per-section
manifest. Rats are initial placements only and never respawn or resurrect, so
the exact ratio holds for the whole map. Static layout validation records are
in `assets/validation_4366/`; native combat and save/load evidence are separate
from author acceptance. The author check CA-4366-RATS-01 passed on 2026-09-24.
## 4.36.5a — Selective file reading for agents (#29)

Issue [#29](https://github.com/damiancurti/Caelum-Argenteum/issues/29) is a
documentation patch that extends `AGENTS.md` and the engineering guide with an
explicit selective-reading workflow: search names, symbols and indexed
headings before opening large files, read relevant ranges and their required
dependencies, treat `build/` as targeted test evidence, and review PRs from
the diff outward. The practical examples live in `GZDOOM_DEVELOPMENT.md`. No
gameplay, balance, map, asset, localization or save change is introduced.

## 4.36.5 — Four-section sewer layout (issue #11)

MAP02 now contains four identifiable sections, each ending in a separately
keyed prisoner cell and usable bed. The northern section leads to the keyed
Zupay arena; the Ace of Cups and existing boss/card exit checks remain. A
reachable prisoner extraction reservation lies outside that arena; escort
actors, extraction state and rewards remain #14. The player still uses the
existing MAP07 connection; #16 owns the later MAP06 route reconciliation.

Passages provide two 160-MU dry walkways beside a harmless 64-MU channel,
384-MU level crossings/open gates and 128-MU gate headroom. Existing maximum
player/prisoner collision diameters are 42.6667/42.6 MU and maximum height
74.7 MU. Cell exits, bends and refuge accesses use the same clear dimensions.
Existing barred-gate and iron artwork is reused; no Doom asset or MAP01 change.

The retained counts are 96 Mandingas, one Zupay, 45 traps, 39 chests/65 unique
recipient-sized T1 items and 120 food/120 water. Ammunition totals are 240 arrows,
120 bolts and 120 bullets, counted as units rather than bundles. Four maintenance
alcoves provide connected T1 stations without placed enemies/traps. Existing
rest/combat, finite salvage, crafting costs and times still apply.

Author clarification during #11: repair only weapons whose final recipe is
known; other weapons may wear out and break. No extra recipes or materials are
authorized. The implementation now checks knowledge before reserving components.
The former all-family repair-supply expectation is superseded by this decision.

Compatibility continuation is explicit: a previously visited MAP02 requires
`run_dev.bat --legacy-map02`, retaining its original WAD and every saved state.
New layouts do not overwrite existing maze progress. HISTORY records static,
native and compatibility evidence separately from the author-confirmed PASS of
CA-4365-MAZE-01 on 2026-09-24 (PR #28). Next implementation: #12 / 4.36.6.

## 4.36.4 — T1 acquisition, recipient sizes and feedback

Issue [#10](https://github.com/damiancurti/Caelum-Argenteum/issues/10) replaces
the former all-tier MAP02 acquisition catalogue with 65 unique T1 combinations:
16 armor pieces/types, 36 weapon/essence variants, four shields, four amulets
and five seals. Fresh maps distribute these across the existing 39 chests.
The three-section geometry, enemies, traps and 120 rations of each kind remain.

Natural world/reward weapons, armor and shields use an explicit reusable
character-default size policy; actual acquisition resolves the recipient's
existing body-to-equipment mapping before capacity checks. Fixed-size authoring
remains possible, and already acquired equipment retains its size and condition.
Opening a chest previews its actual remaining contents in Spanish without
transferring or binding them; collection is explicit and revalidates the recipient.
A bounded feed retains up to 20 recent gameplay/acquisition entries with separate
expiry, initially eight seconds through one configurable project parameter.

SYSTEMS defines the contract and migration details; HISTORY records actual
verification separately from author check CA-4364-T1-LOOT-01, confirmed passed
on 2026-09-23. The next implementation is #11 / 4.36.5.
The updated #10/#14 author decisions also supersede the former price-average
rescue reward with a fixed 25 gold; #14 still owns its future implementation.

## 4.36.3 — Additional first-person flail rotation

Issue [#9](https://github.com/damiancurti/Caelum-Argenteum/issues/9) adds the
author-requested 10 degrees counterclockwise to the 0i handle pose through the
shared T1–T3 transform. Grip insertion, rear chain/ball, vertical rest and the
full attack revolution remain intact. No gameplay rule, source artwork or save
schema changes. Native before/after evidence is recorded in HISTORY and
`assets/validation_4363/`; CA-4360I-VISUAL-01 retains its original provenance
and passed on the author's explicit confirmation on 2026-09-23. Its pending
entry is removed; no new release number or gameplay change accompanies this
acceptance. PR #26 was integrated before the 4.36.4 implementation above.

## 4.36.2 — Bow first-use stall and environmental scope

Issue [#8](https://github.com/damiancurti/Caelum-Argenteum/issues/8) replaces
runtime reconstruction of bow crop strips with six deterministic PNG caches
derived from the original images. Native palette effects, all 18 sprite names,
scales/offsets, presentation logic, ammunition and save schemas remain intact.
Native evidence and the author's 2026-09-23 pass confirmation for
CA-4362-BOW-EMPTY-01 are recorded in HISTORY.

The author's 2026-09-23 scope clarification in #8 covers moving sectors with
the existing crushing ceiling and native elevator. Avalanches are deferred
until additional maps are developed; damaging surfaces until environmental
temperature effects, with no acid/lava requested now. These three items are
not 4.36 release blockers. Rams/catapults, remaining integration/save/reset
checks, 4.37 Tarot/Trucazo and the three-map demo requirements remain pending.
This decision introduces no new environmental gameplay or engine claim.

## 4.36.1 — Documentation and contribution workflow

Issue [#6](https://github.com/damiancurti/Caelum-Argenteum/issues/6) establishes
English maintained documentation, numeric patch versions, repository-first
delivery and one persistent [author-test queue](../pending_test.txt).
The gameplay baseline remains 4.36.0i. This patch changes no game rule, balance,
asset, map geometry, localization or save schema; only the two current-version
diagnostic labels change in gameplay sources.

The release-specific sections below preserve their original scope, accepted
decisions, evidence and then-pending work. Older ZIP/application guides are
historical records. Current installation is in [README](../README.md), and
only the root queue defines outstanding actionable author checks. Old test
references do not reopen already accepted work. Implementation evidence and
remaining acceptance are recorded in [HISTORY](HISTORY.md).

Current releases use MAJOR.MINOR.PATCH: 4.36.0i -> 4.36.1 -> 4.36.1b -> 4.36.2 -> 4.36.3 -> 4.36.4.
Intermediate commits and later acceptance retain the originating patch version.
The larger roadmap remains in force. Proper names, identifiers, literal game
dialogue, formulas and original external source material retain their spelling;
English explanatory text does not change the bilingual game localization.

## 4.36.1b — Engineering guides and long-document index

Issue [#22](https://github.com/damiancurti/Caelum-Argenteum/issues/22) integrates
the development handoff into the maintained documentation, adds a deterministic
[document index](DOCUMENT_INDEX.md) for every maintained document over 5,000
words, and extends the validator to keep guide/index metadata, hashes, links and
word counts in sync. It also reconciles the prisoner coin reward in SYSTEMS to
the confirmed T1/recipient-size rule. This is documentation and tooling only:
no game rule, balance, asset, map geometry, localization or save schema changes.

## Author roadmap update — 2026-09-23

The author requires **three complete campaign maps**, covering the prologue,
El Loco / the Fool (0) and two Minor Arcana, before the external V4 playtest.
This small campaign slice is now an explicit exception to deferring new
campaign content to V5. It retained the existing system gates. The later 2026-10-01 author decision
explicitly moves 4.37 Tarot/Trucazo after the current-content playtest. Test arenas and travel stubs do not count as complete maps.

The release sections above record completed implementations; later stages remain planned.

| Patch / stage | Issue | Scope |
| --- | --- | --- |
| 4.36.2 | [#8](https://github.com/damiancurti/Caelum-Argenteum/issues/8) | Empty-bow equip stall. |
| 4.36.3 | [#9](https://github.com/damiancurti/Caelum-Argenteum/issues/9) | Additional flail rotation. |
| 4.36.4 | [#10](https://github.com/damiancurti/Caelum-Argenteum/issues/10) | MAP02 equipment is Tier 1 only; retain every starter weapon/essence and armor/accessory combination. |
| 4.36.5 | [#11](https://github.com/damiancurti/Caelum-Argenteum/issues/11) | Four keyed sewer sections, endpoint cells with beds, repair refuges, channels/decor and the northern locked Zupay chamber. |
| 4.36.6 | [#12](https://github.com/damiancurti/Caelum-Argenteum/issues/12) | Two hostile rats per Mandinga in each section: preserve 96 Mandingas, add 192 rats. |
| 4.36.7 | [#13](https://github.com/damiancurti/Caelum-Argenteum/issues/13) | Four prisoner palette variants reusing the mansion characters. |
| 4.36.8 | [#14](https://github.com/damiancurti/Caelum-Argenteum/issues/14) | Following/fighting prisoners, living extraction before the MAP02 boss, port arrivals, one-time +10 own-faction reputation and a fixed 25 gold coins independent of character size per rescue. |
| 4.36.9 | [#15](https://github.com/damiancurti/Caelum-Argenteum/issues/15) | Integrate approved Tarot fronts, including the Ace of Cups; no new powers. |
| 4.36.14 | [#31](https://github.com/damiancurti/Caelum-Argenteum/issues/31) | Integrate selected pain sounds, the supplied dialogue-opening cue, local sewer/port/coast music and the reserved chapter-end story intermission. |
| 4.36.10 | [#18](https://github.com/damiancurti/Caelum-Argenteum/issues/18) | Catapult, ram and breakable-gate assets with documented states/attachments. |
| 4.36.11 | [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19) | Damageable actor gates and persistent passage opening on destruction. |
| 4.36.12 | [#20](https://github.com/damiancurti/Caelum-Argenteum/issues/20) | Ram strikes using the approved physical-impact foundation. |
| 4.36.13 | [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21) | Native catapult trajectories/projectiles and physical impacts. |
| V4 playtest content | [#16](https://github.com/damiancurti/Caelum-Argenteum/issues/16) | Stop the demon siege at MAP06 port; its commanding Zupay holds the second Minor. |
| V4 playtest delivery | [#17](https://github.com/damiancurti/Caelum-Argenteum/issues/17) | End-to-end acceptance and reproducible export after the retained system gates. |

Issue #10 supersedes the earlier all-tier MAP02 loot request for future
implementation. The current accepted 0i map remains three sections with T1–T3
until these patches land. Preserve 120 food and 120 water rations, existing
repair costs/durability and the 45-trap set when rebuilding; provide actual
repair stations and audit existing recipes/material access rather than making
repairs free. Keys must admit a complete route without circular locks.

The prisoner appearances/factions are author-defined: Caella -> Unitarians;
Ronnie -> Federals; Rulo -> Free Peoples; Argento -> Cult of the Tarot.
These are new identities, not changes to the mansion residents. The six
canonical factions replace the former provisional IDs: Unitarians=0, Federals=1,
Free Peoples=2, Caelith=3, Cult of the Tarot=4 and Sun Warriors=5. Each prisoner
has the same initialized combat statistics as the source mansion character,
with separate identity and no inherited mansion-only anchoring/quest logic.
Freed prisoners follow and fight alongside the player. They must reach a
physical exit alive, before the northern MAP02 Zupay fight, to be extracted
to the port; they do not participate in that boss encounter. This NPC exit
must not bypass the player's boss/card progression. Persist each outcome.
At the port, thanks grant **+10 reputation with that prisoner's own faction
and 25 gold coins, once per successful rescue**, independent of character size.
The latest #10/#14 author decision replaces the old weapon-price average;
SYSTEMS, Economy, "Prisoner coin reward" records the fixed payout. Implementation
remains in #14, not this loot-policy patch.
Unrescued NPCs must not appear there; benefits cannot duplicate on retry,
save/load or travel. Broad companion formations remain outside this patch.

Confirmed route, updated by #33: MAP01 mansion/Fool -> MAP02 sewer/Ace of
Cups -> existing MAP03 workshop/test room -> MAP06 port/Knight of Wands.
Map IDs are preserved. Current MAP06 stops the demon siege under the 4.36.27
contract above; actual victory replaces the provisional reward-delivery condition.
The second Minor's identity is Knight of Wands (60).
Catapults, rams and damageable actor gates are required, with separate
asset/mechanic issues #18–#21. This bounded port encounter is now part of
the playtest; a general world-siege director remains V5. The authored encounter counts,
machine/gate rules and objective conditions are recorded in SYSTEMS.
The Tarot source ZIP was verified locally; its definitive manifest is committed
as `assets/manifests/tarot_78_v4369.json` while the oversized archive is not
stored in normal Git. Do not regenerate approved art.

Rams and cannons (#20/#21) are accepted; #16 adds native integration/save
evidence. Full campaign author acceptance precedes the playtest export. The
author's #8 clarification covers moving sectors and defers avalanches and
damaging surfaces as described above; none of those three blocks 4.36. For
ram/catapult scope,
assets alone do not close those bases. Missing numerical criteria still
need approval. Later campaign expansion remains V5.

### Usage measurement for this batch

On 2026-10-01, the author discontinued further weekly-allowance measurement:
no additional quota-consumption tests or final weekly-balance collection are
required. This supersedes that part of the original #8/#17 batch protocol.
Preserve the existing evidence; do not create estimates to fill its gaps.

Historical author-confirmed baseline on 2026-09-23: **75% of weekly allowance
remaining**, with reset time unknown. It is not a directly observed account
counter or a token count. Existing evidence separates Work planning/review from
desktop implementation and records missing coverage, correction rounds, resets
and concurrent unrelated work where available. Never infer tokens from changed
lines or quota percentages, or compare dissimilar workloads as equivalent.
The #8–#21 batch report is retained in #17 and assets/validation_43628/RESULTS.json;
unavailable token categories and final allowance remain unmeasured, not pending
author tests or a closure blocker.

## 4.36.0i — maze, flail, rations and approved weight

[ACCEPTED BY THE AUTHOR] Proposed static-weight formula, bows except thickness,
carriage and other 0h tests. It is authorized to rebuild MAP02 without preserving previous saves. This delivery is incremental on the complete 0h project.

[IMPLEMENTED AND COMPILED IN GZDoom g4.14.2]

- Flail: +22,5° anti-clockwise from 0h, half of the exposed handle sunk into the hand; chain/ball in
  independent back layer, vertical at rest and complete counterclockwise turn when
  attacking. Damage and attack rate are preserved.
- Normal/long bows T1–T3: double transverse thickness only in the first person. Curvature,
  palette, hands, string and arrow maintain the accepted rules.
- Food ration 200 g; water 200 ml/200 g. At 80 kg, 2 kg or 2 L restore 100 percentage
  points after completing its ten portions.
- MAP01 tables filled once: four small ×4, one normal ×18 and one large ×60 =94 rations.
  No periodic replenishment.
- Static weight due to excess capacity, percentage of maximum health, native support, split between
  supports and retained fractional remainder. Formula in SYSTEMS.
- MAP02: three 49 room sectors, 96 Mandingas, 45 traps, three keys, 39 chests with 195
  different T1–T3 equipment pieces; 120 rations of each provision.
- End with Zupay, Ace (1) of Cups and exit to MAP07. The other test accesses are left in the
  final chamber. The hub retains the objects and the loot removed.

[VERIFIED] Compilation and native tests in Linux with GZDoom 4.14.2 and development Freedoom. Real inventory of chests, locks, card, food, water, tables, weight and spin
of the flail; coverage and static routes of the map. Reports separate those checks from a complete human playthrough. On 2026-09-23 the author accepted the maze, save/load, table and bow-art checks. Final flail pose remains partial: approximately 10 degrees more counterclockwise is requested (#9). A new report of a multi-second stall when equipping an empty bow is tracked in #8. The original guide was PRUEBAS_4_36_0i.txt; current outstanding checks are carried in [pending_test.txt](../pending_test.txt), with confirmations in HISTORY.

### Major Arcana and block closure

It was not possible to confirm another Major Arcana passive besides El Loco, La Estrella
and El Sol. Old ideas for other Majors are not converted into approved assignments. The Ace (1) of Cups applies the current Minor rule. There is only front art of El Loco on this base;
the Ace of Cups uses the shared reverse and its textual identification, without inventing a
front.

The flail pose remains in #9; the author accepted the 4.36.2 empty-bow
correction (#8) on 2026-09-23. The other reported 0i tests remain accepted. Rams, catapults
and remaining integration/save/reset validation still precede Impact Physics
extraction; the three environmental items follow the current #8 scope above.
The following sections record previous deliveries and then-pending plans.


## Historical 4.36.0h — bow reference, clockwise rotation and served tables

[ACCEPTED BY THE AUTHOR] The rest of the 0g tests were good. The accepted shapes,
proportions and palettes are preserved. The new visual review is limited to the flail and
grip marked on the attached screenshot.

[IMPLEMENTED IN SOURCES] Flail: 90° clockwise relative to 0g (+28° → −62° native), with the grip shifted to keep it in frame. Bows: upper index finger behind; section marked in blue behind the thumb and the other phalanges.

[IMPLEMENTED IN SOURCES] Real initial food at all MAP01 tables: one ration per seat,
discounting food already present. Six tables, 26 seats. Persistent initialization for new
games and tables from previous saves; does not replenish what is consumed or replace objects from
a full table.

[IMPLEMENTED IN SOURCES] Native ceiling: pulse damage expressed in percentage of maximum health
for player and NPC Caelum. Current value 10 → 10% per pulse. Maintains timing and native
immunities; does not convert impacts again.

[PROPOSED, NOT ACTIVATED] Damage from stationary mass resting on the character. The formula of sustained
impulse was found, but not an approved static formula. Damage proportional to the overload
of the actual capacity is proposed; k=10% maximum health per second for each additional
capacity. Formula and examples in SYSTEMS. The premise of not inventing balance requires
the author's decision on this rule.

[VERIFIED LOCALLY] Resources, rotation/masks, percentage arithmetic and food conservation
model. GZDoom was not executed nor was native save verified. Increment tests in PRUEBAS_4_36_0h.txt.

### What is needed to close 4.36

Historical 0h checklist. Later 0i acceptance and the 2026-09-23 author
clarification in #8 supersede its then-pending requirements; use the current
4.36.2 scope and TASKS for active gates.

1. Accept these corrections and verify boot, tables, damage and saves.
2. Agree and implement the static weight: stacked masses, split between supports, victim
   release and absence of double damage with landing.
3. Complete the planned bases for surfaces with their own damage, avalanches, rams, catapults and
   mobile sectors using the physics core.
4. Validate the integration of those mechanisms into the gallery, persistence and restart.
   Extract Impact Physics only after validating its use in Caelum.

0g tests accepted are not reopened except for regressions of this delta. After 4.36
corresponds 4.37 (Tarot/Trucazo), and then export V4.

## 4.36.0g — proportions, flail and palette

[IMPLEMENTED IN SOURCES] Flail T1–T3: +28° rotation to the left at rest, more marked than +14° of 0f. It was found that kind 8
reaches CaelumFirstPersonLayers; the observed failure is not attributed to a cache or run
path that could not be replicated in the engine.

Axe with a 50% larger head and separate handle. Halberd with its shaft lengthened along its axis, without enlarging blade, ribbons or hands. Greatsword with the same shape and
less saturated/darker colors in view, inventory and ground sprite. Bows: index finger behind the wood; thumb and phalanges of the other three fingers in front. Arrow continues on
top layer.

[PRESERVED RULE] The axe secondary is documented as blunt, stronger and shorter-ranged than the slashing primary. Combat, actual reach, resources and physics were not modified with this presentation review.

[VERIFIED LOCALLY] Texture dependencies, order of states, pivots, clips, palettes, preservation of silhouettes and sources. Reconstructions of the three tiers and three phases of both bows
were inspected. [PENDING] Start, saves and visual acceptance in GZDoom 4.14.2 on Windows
11: the engine was not executed. The recovered base is partial. Application on 0f;
PRUEBAS_4_36_0g.txt guide.

The above sections are history. The author's test indicated that the 0f flail was
still without the correction expected and that the palettes were vivid.

## 4.36.0f — corrections after the author's test

[CORRECTED IN SOURCES] Rotation sign of hatchet, machete, axe, war axe and halberd: its
upper ends lean to the right. Flail incorporated to the modular layers, with inclination
to the left. Hatchet 24 MU lower than the grip; NoTrim canvases and absolute pivots.

[INTEGRATED ART] Greatsword blade enlarged in T1–T3, also in inventory and ground sprite. Bows with muted palettes, fingers behind, thumb in front and arrow in the top layer. String
built with native vertices.

[REQUESTED ADJUSTMENT] MAP08 Rolling Rock: 8 → 32 MU/tic, without forced death or change of the
damage curve. Compatibility on the next activation of saves with the old value. A released rock is not re-launched.

[AUDITED] Rock impacts use mass/speed. The ceiling uses native Crush at 10 points per
pulse. The motionless rock supported on a victim does not apply continuous pressure due to
its weight. Formulas and limits in SYSTEMS.md.

[VERIFIED LOCALLY] Structure, data, resources and views reconstructed with the order of
4.14.2 renderer transformations. They are not game screenshots. [PENDING] Compile and test in
GZDoom 4.14.2 / Windows 11. The engine download failed and the recovered base is partial.
Guide: PRUEBAS_4_36_0f.txt.

The sections prior to 0f are history; 0e's orientation and string statements were refuted
by the author's subsequent test.


## 4.36.0e — corrections requested after testing 0d

[PROGRAMMED] Fists with continuous forearms and the same glove of the other weapons; left
and right come from the same original PNG, reflected by TEXTURES. The original set of
hands is also used for both bows. The left hand is in a layer before the right. Glove
sizes independent of the size of the weapon.

[PROGRAMMED] Hatchet, axe, war axe and halberd tilted to the right with the handle seated
on the grip. +20% sword and greatsword +15% relative to 0d. Normal recurve bow and longbow with continuous limbs, both in T1–T3, with a string between the tips and hand, and visible
arrow only if loaded.

[PROGRAMMED] Trimmed MAP01 chord at the first revelation of the Arcanum. Original level up
sound by confirming its capture and applying the bonus. [CONFIRMED BY THE AUTHOR] Correct
0d transitions; its logic is preserved.

[PROGRAMMED] Carriage with front axle and two front wheels: four wheels in total. On the
boat, non-solid Use volume in front of the hull, in addition to the sign; the warning
remains centered and retains the requirements of boarding. New parts are added once when
preparing vehicles, also when loading.

[VERIFIED LOCALLY] Structure of changed sources and resources, references, layers, OBJ
geometry and reconstructed weapon/model views. GZDoom was not run for 0e: the complete
baseline had not been recovered and no engine was installed. Changed files start from
their latest recovered versions. [PENDING] Compilation and gameplay/visual testing in
GZDoom 4.14.2 / Windows 11. Instructions: PRUEBAS_4_36_0e.txt. The following sections are
historical.

## Previous base: 4.36.0d — grips, fists and visible mechanisms

Delta on the complete project 4.36.0c. The author’s observations and his four attached
references are taken care of. Dagger and magic weapons retain the approved art. Only the
weapon is inverted into hatchet, machete, axe, war axe and halberd; the hands retain
their laterality. The hatchet is held lower on its handle. Axe, greatsword, war axe and
halberd increase in size; the last three show two hands. The sword adopts the small hands
of the new package. All families move down and to the left when put away.

Crossbow and carbine are presented below, with the hands below and the left support
centered. The empty carbine uses rest, without permanent flash. Both bows lower and show
the back of the left hand on the grip, following the photograph. This grip and a pair of
closed fists are generated; the other corrections use native transformations of existing
art. Bullets on the ground reduce their scale from 0,25 to 0,10, including those saved.

CaelumUnarmedWeapon replaces the Fist fallback. It is equipped when left without a usable weapon and after cleaning objects of MAP01→MAP02. It retains the range, damage and cadence
of the previous fallback, with its own presentation; does not add a family of equipment or
modify the balance of the weapons of the catalog.

Looking at a caravan/carriage, boat, table or chair within reach shows "Use:" and its name.
Mechanism 4 is identified as local teleport and confirms arrival by message, flash and
target rune. A MAP08 side lever rearms the gallery, also in 0c saves; it rejects restart
if the crusher moves or there are bodies in the areas to be restored.

It reproduces the visual absence of hub trips: GZDoom g4.14.2 suppresses the wipes during
the first 35 rendered frames. The patch retains the departure view during that lock and then
executes the native carriage/caravan crossfade or the melt of the boat. Screenshots from the renderer confirm both effects. The accepted El Loco burn, provisions, travel time, sound
clips and global wipetype preference are retained.

Validation: GZDoom g4.14.2/Linux, 60 family/tier selections, real actions and reloads,
narrative return with fists, two trap resets, uses, confirmed trips and loading an
authentic 0c save. Native rendering was reviewed in 4:3 and 16:9. The eight WADs and
previous state blocks are preserved. Final visual/gameplay acceptance on Windows 11
belongs to the author; PRUEBAS_4_36_0d.txt accompanies that release. 4.36 remains open and
the immobilization rune remains under review only. The following sections are historical
and do not supersede these corrections.

## History: 4.36.0c — first person, audio and corrections

Delta on the complete 4.36.0b project. The author accepts the lever design and asks for
half size, reports that mechanism 4 was not activated and asks about the rock mass. He provides the packages Primera Persona v1 and Audio Events v1 (1.4 revision) and requests
crossfade for the carriage and burn for El Loco.

The lever uses 0,045 scale, also on serialized actors. It reproduces a pressure failure on
the edge of the teleport plate: 0b required the character's center to enter the radius. It
now counts the support of his feet. It maintains the guards of height, free destination
and absence of telefrag; the report explains rejections of the latest attempt. The exact
case of the author's save is not available; a occupied destination continues to be
deliberately rejected.

19 new first-person families, T1/T2/T3, are connected to the inventory and the real
selectors. The already accepted sword rig remains active; the three variants of sword
provided are available as resources. The 101 PNG and 93 compositions come from the
author's package, without regenerating art. Visual phases follow ammunition, reload,
aim, blocking and effective callbacks.

The six supplied OGGs are incorporated and the five main uses are connected: lever,
carriage, boat, tarot capture and rolling rock. The main ship clip (3–9 s) is chosen.
The tarot clip preserves revision 1.4 exactly. El Loco MAP01→MAP02 uses burn; carriage, crossfade; ship, melt. The request is created only when confirming a crossing and
does not modify wipetype.

The large granite sphere weighs 38170 kg (38,17 t). The native fall test with Toughness 13 and
without armor caused 1343/1780 points of health damage. The actual mass, speed and defenses are
printed in the diagnostic report. An old boulder that does not fit still retain its size and mass of
0a; its expansion within occupied geometry is not forced. The new patch does not rebalance
the impact core.

MAP01–08 and previous states of weapons/actors retain their bytes/indices. Tests run in
GZDoom g4.14.2/Linux; playable, visual and mixing acceptance in Windows 11 corresponds to
the author. Guide: PRUEBAS_4_36_0c.txt. The 4.36 stage remains open; the immobilization
rune remains only under review.

## History: 4.36.0b — traps, levers and presentation

Delta on the complete project 4.36.0a. The author confirms the other tests of 0a correctly
and asks to correct the size of the bull and rocks. Approves explosive magic mines,
teleport and crushing; asks for a lever on column, audible transitions and a melt effect for boat trips.

These three traps are implemented in MAP08. The MAP01–08 maps retain their WADs byte for byte. MagicHazardRevision of the existing controller incorporates the new actors once,
also in old saves. The trap and the already used mechanisms retain their status. The used levers are shown down.

Bull: general visual increase of the 25% and normalization of each running view relative to rest; its anatomy, mass, collision or attack is not changed. The PNGs provided
by the author retain their bytes. 0a rocks were small test granite; the hazard ones
receive an irregular sphere of 96 MU of diameter, central pivot and spherical granite mass
(38170 kg). The damage follows the current physics core and depends on the conditions
of impact, without automatic death.

The three traps, dimensions and values of MAP08 are test configurations; they do not set
narrative locations or definitive balance. The rest of 4.36 continues with special
surfaces, avalanches, rams, catapults and other mechanisms. 4.37 is not advanced nor is
Impact Physics yet extracted as an external package.

Proposal for revision only: a temporary immobilization rune. Duration, endurance, cost or
damage is not implemented or assigned without the author's decision. gameplay/visual
revision of 0b in Windows 11 remains pending; follow PRUEBAS_4_36_0b.txt. The above
sections are history.

## Approved base: 4.36.0a — trapdoor and first physical hazards

The author confirms "All correct" for 4.35.0q: 4.35 is approved and closed. Authorizes to
start 4.36 and adds ground traps that open when you step on them. This delta applies to
the complete 4.35.0q project.

Implemented: Reusable trapdoor on a real pit, gravity drop, rolling rock and suspended rock
released with Use. MAP08 incorporates a gallery with pit and exit ladder, connected to
MAP05 by a native access. MAP01–07 WAD retains its bytes and allows to load its saves. The
support is only removed when stepping on the lid; passing above or below does not fire it.
It remains open once activated and its state belongs to the map/hub.

The rocks reuse granite, mass and existing models. The impacts use the current formulas,
with an additional vertical adaptor and explicit environmental origin; they do not grant
combat adrenaline or add Doom thrust to the already resolved core. Saves, diagnostic report and TXT allow you to review the mechanisms. The configuration of the gallery is
trial; it does not fix narrative locations or a definitive new balance.

The author approves the remaining tests of this increment; the requested visual
corrections are addressed in 0b. 4.36 is still in development: surfaces with own damage,
avalanches, rams, catapults and large moving sectors. 4.37 is not advanced nor yet
extracted Impact Physics as an external package. The subsequent sequence remains 4.37 →
test export → V5.0 → V5.1.

The sections by version that follow retain the history; their old pending checks do not reopen
the blocks that the author has already approved.

## Approved base: 4.35.0q — sprites v4 and seated consumption

Delta on the complete project 4.35.0p, tested and approved by the author. The author
provides Caelum_Argenteum_Sprites_Iconos_v4(1).zip and modifies only the rate of seated eating/drinking: changes from 1/10 to 1/3 of the ordinary rate. Each complete
portion takes 30 seconds of simulation, retains its ten pulses and consumes the same
units/liters. Standing up resumes the normal rate.

The visual package is integrated into the current states of nine characters: breathing, running, Domingo/Palomo/Mandinga/Zupay walks, Palomo resting poses, Bull/Ronnie replacements
and icons, including the bag. The new states are attached to preserve 0p's save indexes.
Palomo retains its dialogues and exit route; its pose responds to the real movement. The
player retains priority of crouching, attack and rest.

The 0p travel, reserves, calendar, vehicle and map systems are approved. The author also
approved the visual integration and rhythm of 0q. 4.35 is closed; 4.36 begins with the
increment described above.

## Approved base: 4.35.0p — reserves and first vehicles

Delta over 4.35.0o. The author approves 0n/0o except for the corrected points here:
consumption sitting from inventory/Box and escape conflict. Authorizes a covered carriage
and a small merchant ship with sails and oars, with its facilities on both coastal maps. The
author approved these changes by requesting 0q.

The table first uses its own rations, then carried rations and finally those in the player's own Box. It retains the approved seated rhythm, the volume of the portions, digestion and
both independent toggles. It stops when satiating, exhausting the reserve or getting up.
Empty containers and remaining stacks are not extracted. Q/B cancels the estimate and
returns from the calendar/detail; Escape opens the native pause and allows to return to
the same screen.

MAP06 and MAP07 have a cargo carriage covered inside a ranch. MAP06 retains its port and
adds the merchant ship; MAP07 adds a wooden dock and another merchant ship. Using the carriage or
boarding sign opens the estimate of the 500 km route. They are testing services with
driver/draft team and guards, no fee for now; they are not free driving vehicles.

Carriage: 3 km/h while moving, 16 h traveling / 8 h camping. Merchant ship: 5 knots (9,26 km/h),
continuous navigation with favorable wind; the passenger sleeps during the crossing. The
calendar includes only time actually elapsed; sleeping on board does not add a second time
those hours. Speeds and dimensions are nominal values representative of design, not
measurements of a carriage or Argentine ship historical individual.

Structures and vehicles are installed once on entry/load, also on save maps
with 0o, and are kept in the hub. Confirmation requires to remain near the same vehicle and
recalculate the provisions before leaving.

### Historical closure of 4.35 (completed)

Manual 0p testing remains: table/Box, Q and Escape reservations, ranch entrance, boarding,
visual proportions and travel for each vehicle. If no faults arise, you can close 4.35 and
continue with 4.36 (physical dangers). No need to repeat the 0n/0o tests already approved
or add more maps or sieges.

## Base delivered: 4.35.0o — agenda and persistent events

Delta on the complete project 4.35.0n. The author defines the events: sieges, secondary
NPC/side-quest routines, rentals, shipments of goods, vein growth and future categories. Ask
for a calendar with its dates. 0n and 0o were tested by the author; 0p resolves the
comments received.

TAB → World → F/RT opens the monthly campaign calendar. It points out today, the selection
and how many known series fall in each day; shows time, type and occurrence
recorded/scheduled. Detail offers series status, first and next date, interval and
counter. Unknown events are not revealed. The date of climate debugging does not displace
this agenda.

The persistent record calculates the expired occurrences without reproducing thousands of
AI tics. It connects to the ordinary clock, Limbo 1:1, rest, x105 and confirmed trips; an estimate query does not trigger future events. Saving and loading retain dates, counters,
cancellation, debt and charges withdrawn.

Specific adapters: siege phases interrupting rest/acceleration; NPC testing that
changes its destination according to its routine; expiration of incomplete mission
targets; rental with debt/payment manual in real coins; loading of materials removed upon
dispatch and recoverable once in destination; recovery of resources that also accounts for
the absence of its map. Resources maintain 0,1 % capacity per campaign day, without
rebalancing them.

The trials are opt-in console tests. No campaign rentals, prices, schedules for the four
residents or canonical commercial shipments are invented. The infrastructure supports such
contracts when registered by a map/quest. The siege trial tests phases and temporary
blocking; the battle director, armies and political consequences retain their agreed V5
scope.

### 4.35 closure

The time-system implementation of this block remains a candidate for closure. The author's
manual acceptance of the 0q changes and resolution of any bugs that arise are still pending. No
new campaign content is required or repeated tests already approved. Then follow 4.36
(physical dangers), 4.37 (Tarot/Trucazo), V4 export, V5.0 reorganization and V5.1 thermal
exposure.

## Base delivered: 4.35.0n — measured travel and provisions

Delta on the complete project 4.35.0m. The author approves the food rations tests and
maps. Define 10 km between sewer reservoir and port, and 500 km between port and beach, with
days of 16 walking hours and 8 sleeping, current character speed and consumption of its
supplies.

The access shows an estimate before departure: real speed converted to km/h, walking/sleeping duration, rations required/carried/to be consumed, additional water in containers and
expected reserves/health upon arrival. Enter confirms; Q/B cancels without deducting rations or advancing the clock along the way. The world continues at its normal pace while
reading. If you change speed, consumption, stock or mortal risk, the view is updated
before a new confirmation.

The speed is measured as sustained walking on normal ground, 32 MU/m. It is fixed at
departure, without adding animation pauses or reducing the distance by the 20:1 factor of
the calendar. No night is added once the destination has been reached. The
diagnostic caravan is still walking, without vehicle or new fare. MAP02–05 interior
accesses retain their local treatment without assigned distance. Only the four connections
directed 8–11 have a travel-time estimate.

The numerical simulation of a tic applies needs, digestion, regeneration, lucidity and
sleep. It uses the character's own sleeping bag if carried, otherwise the ground; it does not create
rations, containers, furniture or comfort. It drinks first portions of water and then
liters of containers; it does not spend belongings of the Box. It does not start eating/drinking while asleep. Portions already started continue their pulses upon arrival. A mortal
forecast requires visible confirmation and ends with native death at origin without proof
of arrival; it does not require buying supplies to leave.

The route is applied atomically: one deduction, one clock interval, persistent registration,
weather to the date of arrival and change of map. The estimate is retained when saving; it
is always revalidated before charging. No AI, physics or encounters in the departure map are
simulated during those hours. Active effects and combat must end before the trip. Visible
technical limit: 30 days of travel per estimate; longer routes are not truncated.

## Base delivered: 4.35.0m — food by mass and coast

Food/water provide 800 / (body mass in kg) points per ration. 18 materials of the author,
MAP06 port and MAP07 coast were integrated, their native connections, shelters with two chairs,
physical coverage, non-potable river and climate of Buenos Aires confirmed in MAP02–07.
Their food tests and maps are approved.

## Base delivered: 4.35.0l — chairs, water and regional climate

The author approves 0j and 0k; of 0i only observes the second chair of Ronnie and Argento.
This delta is applied to the complete 4.35.0k project.

The chair existed, but was behind a wall on another sector with the same floor height.
Tables 102/104 move to (1072, ±480, 136), 0° orientation, with two visible and usable
chairs. Beds, accesses, original actors, content and references are preserved. A save with a seated character waits for them to stand before moving the furniture group. The preparation recovers an absent chair.

The water ration represents 0,16 liters and weighs 0,16 kg. It restores ten Thirst points
in the body M base of 80 kg; it retains the scale by body mass: 800/mass points per ration
(8 points at 100 kg). Clothing size M supports several masses and does not convert all
its users into identical bodies. Load, Box, trade and consumption are updated from a
common weight rule. Sitting preserves ten pulses during 100 s simulation, compared with 10 s standing. Containers continue to use their effective litres. An already active effect on a
save preserves the dose with which it began.

The climate uses contemporary monthly normals of the SMN, 1991–2020 period (published in
2023; 2011–2020 wind), for nine stations. The historical campaign date selects time of year
and time on that modern reference. 1889 observations are not reconstructed, and no forecast is queried during each game. Concrete episodes of rain, cloudiness and fronts are
reproducible synthesis; coverage factors are explicit approximations, not measurements of
the SMN.

Later confirmation in 0m: MAP02–05 and the following are in Buenos Aires. Buenos Aires Observatorio is their shared reference; a marker allows you to choose other regions in
future content. MAP01 maintains its Limbo exception: 20 °C, 55% RH, without wind or
precipitation, with 1:1 clock approved.

The ceilings are detected by geometrical traces, including 3D floors. The local sample
distinguishes exterior, open shelter, interior and underground; it responds to motion without
waiting for the next weather minute. The sky surfaces do not count as ceiling. Direct
precipitation is cancelled under cover; the relative humidity is recalculated according to
temperature/vapor pressure and underground humidity. Wind changes with region/fronts
and decreases under shelter.

The Journal reports region of reference and coverage. Seeds, calendar, pause and the same
result are preserved at normal/x105. See SYSTEMS.md for sources, formulas, limits and
commands; PRUEBAS_4_35_0l.txt for manual acceptance. Body exposure, wet clothing and
thermal damage continue at V5.1.

Closing 4.35 still requires events and trips with duration, joint integration and acceptance of
those increments. Then follow 4.36, 4.37, export testing and V5.0/V5.1 in the agreed
order.

## Base delivered: 4.35.0j — local rhythm, interaction and class areas

Delta over the complete 4.35.0i project. The author confirms the recovery of 100 Sleep points over 8 game hours, the 2 kg bag and the 1000 Anima base cost of Arcanist Sleep. He requests to match the radius of class skills with the base radius of
channeling seals: 1280 MU (40 m at the development scale). Sleep, the only class skill
implemented, uses that common base and the existing range modifier. Other skills remain
pending in V5; their future area follows the same rule.

Seated eating/drinking distributes the same effect and consumption during 30 simulation
seconds instead of 10 (0q adjustment of the divisor of 10 introduced in 0j). Do not change
the total for ration or liters per sip. Automatic repetition waits to finish each portion;
rising returns the remaining pulses to the ordinary rhythm. Digestion, limits and comfort retain its rules. The bag, 0i positions and accepted design are maintained.

The Limbo passes from time-stopped calendar to time 1:1 during active play at normal pace.
Clock and date advance; hourly needs and recovery of Sleep use local hours. Outside follows 1 game hour per 180 seconds. T speeds up local rhythm and compatible systems only
during valid rest/crafting. Native pause stops time; no reconstruction of previous
session time or time with the game closed. Palomo compares it to another place he knows.

Use checks the direction of the look for furniture, tables, residents and stations. A
rejected station, even on another floor, no longer cuts the Native Use route. Stations are reduced to 75% of their 0i size, i.e. 150% of before 0h: 30 radius, 72 height and 0,75 scale. The
migration is absolute, retains the actors, their networks, reserves and tasks; it does not
multiply again.

Verified in GZDoom 4.14.2/Linux: slow and automatic meals, liters/digestion, save/load,
local clock and parity with x105, accelerated sleep save of 0i, manufacturing,
dialogues/doors/furniture using Native Use, 38 Migrated Stations, Area Limits and Modifier.
Screenshots of Palomo and the workshops reviewed. Manual acceptance in Windows, including the 0i patch,
is missing; not taken for granted. PRUEBAS_4_35_0j.txt collects pending check.

To move to 4.36 you have to complete the 4.35 block: local weather (temperature, wind,
precipitation and humidity), scheduled events/travel with duration, clock adapters and
integration. Then: 4.36 physical hazards, 4.37 Tarot/Trucazo, test export, V5.0
reorganization and V5.1 thermal exposure. There is no fixed number of remaining patches.
The sections per version below describe their historical deliveries; this section sets the
current status.

## Base delivered: 4.35.0i — accesses, plates and advancement in Limbo

The author retains the design of food/water and reports six incidences of 0h. This delta
over 0h corrects the height of the dishes, exchanges bed/table zones of Ronnie and
Argento, moves the table of the back room 100 MU east, releases the eastern
gate from the northeast workshop and secures the Rulo practice dummy.

T is dedicated to advance during rest/crafting; the old +10 minutes of debugging is
maintained only by console. The Limbo allows to accelerate resources, rest, consumables
and manufacture without advancing clock or calendar. It retains the furniture sessions
without duration and the activity and danger guards.

The migration reuses furniture, chairs, objects and stations. If an affected bedroom is
occupied, wait to get up; try again if the destination is blocked. Saves with the old marker of the dummy but without actor recover one, without restarting the mission or
granting exercises or rewards.

Native tests in GZDoom 4.14.2/Linux: 26 seats/4 beds, 38 stations, real passage through
affected doors, target and practice record, exact comparison of 105 tics normal/accelerated
in Limbo, crafting and loading an occupied 0h bedroom. Revised screenshots. Full
Windows/playthrough controls in TXT.

## Base delivered: 4.35.0h — meals and furniture of the mansion

The author approves 0g, including guidance. This delta is applied on that basis. Eating consumes Sleep equivalent to Hunger actually restored / 4; the cost is bounded by the actual maximum and does not apply to drinking. F/G activates or separately stops the food/water
repetition at the table until it is satisfied. The current portion ends normally; rising
cancels the next ones. It does not restart for subsequent passive loss. Status and
belongings are saved.

Capacity: 4 servings on the 2-seat table, 18 on the 6-seat table and 60 on the 12-seat table. Original dishes with food and cups
represent the real belongings. Each bedroom of Rulo/Ronnie/Caella/Argento receives bed and
table of 2 chairs. There is a table of 6 in the false-wall/cave room and one of 12 on the
second floor.

All stations double their visual and physical dimensions. 26 stations from the bedrooms are moved to the ground floor workshops under each room; the 12 of the second floor are
preserved. Networks and specialties remain connected and separated by room; dialogues and
addresses are updated.

To use those furniture in MAP01 sessions are offered without duration, until rise.
Personal simulation continues; the Limbo clock is not moved nor is T allowed. The external
durations, comfort, Lucidity and orientation of 0g are preserved. Trucazo is not
implemented and WAD geometry is not modified.

Checked with GZDoom 4.14.2 in Linux: digestion and limits, food sequences, capabilities,
persistence, use of 26 seats and 4 mansion beds, volume of stations and networks, USDF
menus and clocks stopped. Revised captures. TXT 0h includes controls and route for Windows
acceptance.

## Base accepted: 4.35.0g — safe advance, tables and sleep

The author approves the 0f tests and authorizes the following patch. Optional advance with
T is implemented only while resting/sleeping or actively crafting, in safe testing
zones. Shares clock steps, resources, effects and manufacturing; does not depend on
i_timescale. Completion, cancellation or loss of validity stops the advance. Limbo retains stopped time. The overall range of weather, routes and events is still pending adapters
to the same time service.

MAP03 receives round table for 2, rectangular 192×96 for 6 and large 384×192 for 12; the
large doubles both dimensions. All chairs allow Wait. Use places/removes real possessions and F/G eats/drinks while seated at the table. Partial containers and contents are preserved
when saving. References table/chairs prepare the future Trucazo requirement, without yet
implementing the game.

Sleeping reduces Lucidity by 10/s and blocks its recovery. Lucidity stun does not interrupt sleep.
Arcanist User4 applies Area Sleep with the same logic, 10 s duration, waking on impact, 60 s cooldown and provisional base cost 1000 Anima. The test radius reuses 128 MU and the existing
area modifier. Other skills continue in V5. It does not change the approved attribute
block.

Fixed furniture orientation and reverse order of the lateral views of the unretouched PNG
atlas. GZDoom 4.14.2 in Linux compiles and verifies native rates versus accelerated, 20
chairs, consumables, USDF, manufacturing, skill and active saves. Captures verify sides
and back. PRUEBAS_4_35_0g.txt collects installation, controls, critical reserves and
Windows check.

## Base accepted: 4.35.0f — sleeping bag and comfort

The author approves all 0e tests. He requests a sleeping bag that can be taken in the
inventory and defines three rest factors: chair ×2, bag ×3 and bed/cot ×4 to recover
Health/Air, with loss of Hunger/Thirst divided by the same factor. They are implemented in
this delta over 0e. Resting on the floor retains ×1. Sitting does not recover Sleep;
sleeping retains the previous provisional rate, without multiplying it by the support.

The bag is a reusable native Inventory of provisional weight 2 kg. It appears in All and Keys/key items; Enter/A opens the durations, C stores it in/removes it from the Box and D
releases it, with existing controls. If it was in the Box, Enter first removes it.
Choosing a duration deploys its model on dry, clear and level ground; closing displays
nothing. The same object remains in the inventory during the session and is collected
visually when standing up, completing or interrupting, without copies or consumption.

An optional World > D/X preparation delivers a test bag in MAP02–MAP05; ca_debug_rest_bag
offers the same operation. It is not granted when loading, traveling or entering the map.
Having it prevents receiving another one for this preparation. Collection respects
capacity and space in the Box. No recipes, prices, permanent loot or new navigation
categories are added.

The comfort applies to natural regeneration and time expense. The consumption of
Hunger/Thirst includes both its passive loss and the costs of curing and recovering air.
Maximums, the fractional healing accumulator and blocks caused by critical reserves are preserved.
Anima, Lucidity and pulses of consumables do not earn bonuses. Recovery of pending Air
after immersion also accelerates by the active factor; outside the rest it retains its
three seconds of base.

Within GZDoom 4.14.2 on Linux, checks covered ×1/×2/×3/×4 rates, inventory activation and USDF responses, pickup/dropping/Box, blocked ground, cancellation, damage, maximums and critical reserves. A sleeping-bag session and a previous 0e save resting on a cot were loaded, which received ×4 preserving its progress. The sleeping-bag test and its
continuation after loading ended without failure; part of the check counter is preserved
from before the save. Native screenshots show bag, posture and factor. TXT covers the physical
controls and route of the hub to be checked by the author in Windows.

### 0f time-advance proposal adopted in 0g

The self-advance substep contract is now implemented with secure initial scope. SYSTEMS
describes exactly its adapters and limits.

## Base accepted: 4.35.0e — chairs, cots and rest camera

The author confirms that all 0d1 tests were correct and authorizes the following patch. 0d
rest base repaired by 0d1 is considered accepted. This delta adds a usable chair and cot
in each MAP02–MAP05 sewer. They also appear when loading a previous save; a repeated
preparation retains the existing pair. WADs are not modified or a return route to MAP01 is
created.

Using the chair opens Wait; using the cot opens Sleep. Choose between 5 minutes, 1, 4 or 8 game hours. The start occurs after closing the answer and validating reach, floor and
space. Close without choosing leaves the character standing. TAB > World > D/X retains
rest on the ground and its voluntary preparations. No resources are granted when
approaching, opening, loading or traveling.

The third person camera allows you to observe the existing poses and orbit with the look
controls. It uses native engine clipping against the environment. Q/B, movement or action
lifts the character; TAB lifts it up and opens the Journal; Escape keeps the pause.
completion/interruption releases the furniture and camera and recovers the input direction.
It seeks a free exit without telefrag; if the outputs are occupied, the furniture allows walking before recovering its collision. The player's physical height/radius are
retained.

Sleeping retains the provisional Sleep recovery of 100% over 8 game hours. Wait, Hunger,
Thirst and regeneration retain their approved rates. The initial date remains 03/11/1889
09:00; MAP01 stops the clock and the other maps progress to the common pace of 1 game hour per 180 real seconds. This increase does not accelerate the time. Agreed skills
continue to be recorded for your later block, without adding them to the rest system.

Verification: compilation with GZDoom 4.14.2 and automatic native tests in Linux for
Use/USDF interaction, repeated use, termination, damage, furniture loss, occupied outputs
and placement/use in the four sewers. An active session was saved and loaded and captures
of both positions were inspected. PRUEBAS_4_35_0e.txt instructions include pending check
in Windows, real controls, previous saves and hub travel.

## Base accepted: 4.35.0d1 — compilation correction

The author communicates nine parse errors when loading 0d into GZDoom 4.14.2: two pose
searches receive String instead of StateLabel, restPose remains undeclared for that first
error and six calls do not find IsTimelessMap. The catalog delivered in 0c contains that
function; it is included again complete to resolve the dependency when a previous copy was
left in the project.

CaelumPlayer.UpdateCrouchVisual and CaelumRestState.Begin now search for each pose with
their literal label. The states, formulas, persistent fields, duration, controls and
roadmap maintain the 0d contract. In that delivery playable tests were expected; the
author confirms them before 0e.

The three pose errors were reproduced with GZDoom 4.14.2 native and the correct catalog. After
applying the correction, the same engine compiled the 4621 script files of the reconstructed project. Check environment: Linux, SDL without physical screen, software rendering and
Freedoom 2 as IWAD test. This verifies ZScript parsing/compilation, not a Windows playthrough, interaction, presentation or saves. The engine and IWAD are not included in the
patch.

PRUEBAS_4_35_0d1.txt indicates how to combine all the files, rebuild the PK3, check the
0d1 report and retest Sleep/Wait, Use and Limbo time. The validator recognizes the
hotfix numeric suffix without removing checks.

## Functional base accepted with 0d1: 4.35.0d — rest and wait

The author approves all 4.35.0c tests and authorizes continuation. This 0c delta
incorporates Sleep and Wait sessions on the normal scale of the world, accessible from TAB
> World > D (X of the controller). The approved USDF dialog is used, with explicit
selection of duration: 5 game minutes, 1, 4 or 8 hours. The first lasts 15 real seconds
and allows a short check. Choosing the mode does not start the session; choosing the duration does. Closing grants no recovery and queues no pending action.

Sleep gradually recovers Sleep instead of its passive consumption. Provisional test value,
not finalized author-approved balance: 100% in 8 game hours, without exceeding 100%. Consumption of
Hunger/Thirst and usual regenerations are preserved; there is no additional healing,
automatic food or replacement of Anima or Adrenaline when starting/finishing. Waiting retains
the loss of Sleep. Critical fatigue does not cause damage while sleeping, allowing to
recover from exhausted Sleep; its remaining penalties are not canceled or damage by
Hunger/Thirst. Critical Hunger or Thirst prevent it from continuing.

The session uses a hidden Inventory and pulses of the existing clock. The character
remains still and adopts his world pose lying or sitting. You can look around; Q/B,
movement or an action lifts it. TAB raises it and opens the Journal; Escape keeps the
pause voluntary. Confirmation of the dialogue must be released before setting up the
input cancellation, and Use returns to the native path when rising without rewriting
usedown. No global freeze flags are used nor a new camera or physical furniture is added.

Effective damage, combat, displacement, water, loss of ground support, other activity, change of map or
external modification of the clock interrupt. A seal, crafting, reloading/charging, conversation or pending journey prevents start. Traveling during rest is refused. No
minutes are returned or the rest of a recovery is granted when cancelled. Terminations are
unique. The saved session preserves mode, duration, progress, position and last pulse;
loading continues if the context remains valid. Debugging dates of 0c does not modify that
clock or accelerate rest.

Limbo retains its date and rejects these timed sessions. They do not change the
pool or previous regeneration of MAP01. The menu offers voluntary preparations, without
objects: Hunger/Thirst 100%, Sleep 50% or 5%. They do not apply when opening, loading or
traveling. ca_debug_rest_report only consults; ca_debug_rest_hit requests a native impact
of 1 to check the interruption in the empty sewers. It does not represent a native test
already done here.

### Previous verification of 0d

317 assertions on rules, session methods and critical damage extracted from the ZScript
and compiled as C++, with undefined-behavior sanitizer. 33 conditions are checked at
the start and during the session. Duration, unique clock pulses, recovery, terminal
closing, input and release, prediction, fatigue and logical field restoration are checked.
Engine functions are replaced by test doubles: this does not verify ZScript compilation,
physics, native serialization or visual aspect of GZDoom.

In addition, sources, new USDF routes, translations, text width, resources and five
documents are reviewed. When preparing 0d the engine was not available; 0d1 incorporates
native build check. PRUEBAS_4_35_0d.txt retains playable tests pending. ZIP includes only
new/modified files. Maps, audio-visual, attributes, rates, recipes and 0c approved
chronology are preserved.

### Pending work to move from 4.35 to 4.36

1. Complete the rest block: accelerated advance with consistent application of time and
   interruptions. 0d/0d1 provide the session to normal scale and 0e incorporates
   chairs/cots and camera; 0f adds bag and comfort factors. 0g adds secure acceleration,
   tables/food and the Lucidity sleep rule. 0h incorporates automatic table meals,
   digestion and furniture from MAP01. 0i fixes accesses/presentation and allows personal
   advancement in Limbo without calendar. It is missing to integrate the future timed
   systems of the world.
2. Common local climate status implemented in 0k: temperature, wind, precipitation and
   humidity by calendar/location, with test profiles. Pending acceptance of this block and
   definitive regional values.
3. Plan events and trips with the same clock: schedules, duration of routes and resolution
   of events during waiting/rest or transfers.
4. Check the integration of those blocks with saves, trips and the Limbo exception, and
   close the native tests of the increments.

Then continues 4.36, mobile environment and physical hazards; then 4.37, Tarot and
Trucazo. The test is exported for other players before V5. The legacy/cross-system work,
weather over the body, class/racial skills except Sleep already implemented,
shelters/properties, automatic eating away from tables and the broader rest-quality system remain in
V5. A fixed number of patches to close 4.35 is not invented.

## Base accepted: 4.35.0c — campaign start and Limbo time

The author approves all 4.35.0b tests. Sets the start of events to 3 November 1889 at 09:00 and states that inside the Limbo time does not pass. This delta over 0b
incorporates that time rule before the next increase of rest; V4.35 continues with rest,
interruptible time advance, weather status and events/travel programmed.

The date is automatically initialized when the character is confirmed. MAP01, the Limbo
mansion, stops the global clock. On exiting the narrative route to MAP02, the same date
begins to move forward. MAP02–MAP05, CADEV02 and future maps without an explicit exception
use a clock tick per simulated tick: 1 game hour = 180 real seconds. There are no
independent clocks per map. A debug entry to Limbo stops the date reached, without
restarting it. A return connection to MAP01 is not enabled.

The suspension corresponds to the chronology of the world, not to the simulation of the
character. You can walk, talk without pause, use, capture, manufacture and complete the
tests of Limbo. Needs, regeneration, damage and recharges retain their timers and balance.
Outside Limbo the dialogues continue consuming campaign time; Escape retains the native
voluntary pause.

A previous save did not separate outside time from the Limbo. When updated, 03/11/1889
09:00 is fixed once over its current counter; CompletedDays/DayTics and all travel markers
already registered are retained. A civil date is not retrospectively assigned to those
trips. 0b inherited test calendars are replaced by this canonical start. 0c’s new saves
retain their moment when loading and browsing the hub maps.

The campaign and test view use separate anchors from the same clock.
DateSerial/CivilDayTics consult the default campaign; only the diagnostic UI asks for the
test. Changing or removing a test date does not restart the campaign: when the test is
removed, the actual date that continued to progress is shown again. Both anchors are
stopped in the Limbo. World explicitly states “Time is stopped in the Limbo”. 0b’s
southern monthly seasonal convention remains as proof: November appears as spring; no
weather is simulated.

### 0c Verification

8.849 automatic assertions on methods extracted from ZScript and compiled as C++, with
undefined-behavior sanitizer: 27 cases of migration, 4.320 projections of
campaign/test, initial date contrasted with std::chrono, rhythm per map, first midnight,
limits and isolation of debugging. The proven restoration copies the state fields: it is
not native serialization of GZDoom. The documentation/resource validator and source
review complement those calculations. There is no engine available in this environment;
ZScript compilation, real migration, save/load, travel and presentation of 0c require
PRUEBAS_4_35_0c.txt checks. The author subsequently confirmed all 0c tests; it is the
accepted basis of 0d.

The delivery contains only new or modified sources/documents and the root test guide.
MAPINFO, maps, conversation menus, input controls, audio-visual resources, attributes and
formulas of the character are preserved. V4 reaches 4.37 and then the test is exported for
other players; the legacy and cross-sectional work, including agreed skills, continues on
V5.

## Base accepted: 4.35.0b — calendar and unpaused conversations

The author approves all tests of 4.35.0a and authorizes to continue, incorporating recent
decisions on conversations and skills. This delivery is delta on 0a. Skills are still in
the already planned V5 block; here are recorded their concrete effects on SYSTEMS.md,
without presenting them as playable.

CaelumCalendarRules converts civil dates between the years 1 and 9999, with months of real
length and Gregorian leap-year rules. CaelumCalendarState saves an anchor with respect to
CaelumWorldClock. It does not have a second ticker. New and previous games start without
campaign date, as the author has not yet set it. Test commands allow to assign an explicit
date, prepare a midnight 12 simulated seconds away and remove that date without touching the
clock, resources, tasks, missions or travel marks already registered.

World shows date and season when there is anchor. The monthly austral test cycle uses
December–February, March–May, June–August and September–November. It is a technical
convention identified as evidence, not a simulation of equinoxes, light, temperature, or
weather. The historical date and its initial season remain for the author to define. Changes in the
test calendar do not trigger rewards or events and do not amount to resting or traveling
over time. The next increase of V4.35 will address rest and time advance with its
interruptions, followed by weather status and scheduled events.

MAPINFO uses UnFreezeSinglePlayerConversations on all six project maps. The common menu
CaelumPalomoConversationMenu omits the action of Ticker that pauses native conversations
at 20 tics. Derivative menus retain formatting, responses, Q/Back, sounds and capture
presentation. This path also covers conversations reopened from previous snapshots; it
does not write read-only level flags or force the global pause. The voluntary Escape menu
retains its native behavior.

The additional proposal to automatically close a dialogue for any damage is not
implemented in 0b. Its interaction with native cancellation must be checked and
completed; the change authorized here is to keep the world active. Socialization must
consume anima during the conversation when its toggle is implemented. No special cost is
added for reading a dialogue.

### 0b verification and delivery limit

The baseline was reconstructed from the author's sources, with all 4.33.0af deltas to
4.35.0a. The existing validator passed before editing. The GZDoom executable is not
available in this environment and its download could not be completed. Therefore, no
ZScript compilation, native execution, save/load or visual test within the 0b engine is
stated. These checks are described in PRUEBAS_4_35_0b.txt. The author subsequently
confirmed all of his tests; 0b is accepted as 0c base.

The arithmetic is extracted from the ZScript functions and compiled as C++ for comparison
with std::chrono: 3.652.059 civil dates, 7.840 valid/invalid input combinations and 1.728
anchor projections. Monthly seasons and integer limits are also reviewed. This test checks
the calculations; it does not replace the GZDoom compiler or virtual machine. The
documentation/resource validator finishes without errors. Review confirms five USDF
classes under the shared menu, eight new keys in both languages and 494 MU as a
conservative maximum date width within the available 544 MU. MAP01–MAP05, CADEV02, fonts,
sounds, sprites and models retain their bytes.

## Accepted base: 4.35.0a — persistent global clock

The author confirms "All right now yes" for 4.34.0e. The seal tests, crafting, use
recovery and travel are accepted. The global clock, the first increase of 4.35, is
continued; the calendar, rest, climate and events keep their place within the block.

CaelumWorldClock records full days and tics of the day in an Inventory native to the
character. CaelumWorldClockTicker is a static observer without its own time state:
consult that Inventory and advance once by simulation tic, after confirming the profile.
It is also recorded when loading a save that did not include this system. The current base
is individual.

The approved scale is retained: 1 game hour = 180 real seconds simulation, 24 hours per
day. At 35 tics/s, the hour has 6300 tics and the day
151200. Integer counters avoid accumulating roundings. TAB > World shows "Recorded time",
        expressed in past days and HH:MM, next to the scale. It does not amount to a
        narrative date or attribute seasons or changes of light.

The engine determines what time it is simulated. Pause, native menu and conversations that
pause the game stop the clock. The Journal does not pause the simulation; working in a
station continues to consume normal time. Save/load retains the counter; traveling and
returning to a map of the hub retains the traveling clock, without restoring the time of
the old snapshot of the place. It does not add up the time that GZDoom was closed nor that
of a load. Returning to a saved game restores its instant save. A new game has another
record.

A previous save starts to record from scratch when installing 0a; it does not infer past
duration from the map or missions. New sewer departures/arrivals keep markings from the same
clock. No historical 0e trips are dated or duration added to routes yet with no defined
time. The ca_debug_time_report report only consults. The travel report shows the marks
when they exist. The accepted costs or timers of needs, combat, seals and manufacturing
are not altered.

Delta delivery on 4.34.0e, with English README, five canonical documents and
PRUEBAS_4_35_0a.txt in the root. V4 continues to 4.37; then export is prepared for other
players. All legacy and cross-sectional work continues on V5, starting with code
reorganisation in V5.0.

### Native 0a Verification

GZDoom 4.14.2/Linux, with Freedoom 0.13.0 and llvmpipe: 35 correct observations, no script errors or execution aborts in the final six cases. Nine check creation, scale, unique hidden Inventory, integer hour/day boundaries, saturation, unchanged query and accurate advance
by tick. The extreme limits are prepared in an isolated counter; they do not represent
complete days spent during a manual test.

Seven observations use real keyboards: native pause, Esc menu, USDF conversation, their
respective resumptions and Journal open with active simulation. World is inspected in a
native screenshot in Spanish with five visits and three exits prepared to verify the
available space. The new line fits without overlapping with existing records or
controls.

Seven observations travel through MAP02 → MAP03 in caravan and the return for a gate with
Real Use. The clock accompanies the character, retains the inventory and date both routes;
returning to the hub does not recover the old time of MAP02. Reconciling again a resolved
arrival retains its marks and counters. Three observations load the native save of that
route and verify the save instant, the unique arrival and the exact continuation by tic.

A save is also created by running the original 4.34.0e sources, after a real arrival at
MAP03. 0a sources are superimposed on the same route before loading. Six observations check
the new clock from scratch, the previous history with no invented dates, the key and
preserved reserves, the available caravan and the marks of the first trip after the
update, including the return to the previous MAP02 snapshot.

The remaining three observations cross a prepared end of the day using real tics and start
another game using the engine: the new character has only one clock and starts from
scratch. It does not repeat the entire MAP01 story or all of the already accepted
manufacture. Fixtures, engine, IWAD and saves are left out of delivery. The project
validator checks the five updated documents and ends without errors. The author later
confirmed all tests of 0a on Windows.


## Base accepted: 4.34.0e — means to check activities and travel

The author approves what he could test of 0d, but could not check seals or crafting
because the sewers were empty. Those two tests are not taken for granted. 0e completes its
means before advancing to the 4.35 clock.

In each MAP02–MAP05 sewer there is a native workbench, sawmill and forge near arrival.
The existing TAB > World > C/Y adds “Prepare seal” and “Prepare crafting”. They are
voluntary diagnostic aids: they do not start a transfer, a channeling or a task by
themselves. The first reuses or grants Quintessence T1, equips it through the normal route and refills Adrenaline to its current maximum; its text warns that it also removes waiting
for the seal. It does not cause a fictitious combat. The second teaches Handle and
tops up to 40 wood units for the x10 batch. Deliveries respect carrying capacity. Repeat
does not duplicate the owned Seal or add wood beyond that batch. Load or travel do not
replenish resources.

Using a station in this network after preparing the recipe preselects Handle T1, batch x10 and
efficiency 100%. These are existing values; working time is calculated with the actual
Dexterity. Enter starts normal manufacturing, Q leaves the task pending and TAB > World >
C must reject the trip. Back with Use allows canceling with C or ending. For the seal your
usual control is used with a weapon equipped, and both cancellation and exhaustion is tested.

The stations are rebuilt once in previous saves and maintain their group and status within
the hub. Maps, arrival points and six routes are existing. There is no return to MAP01 or
mission changes, attributes, recipe, cost, consumption or quintessence effect. Delivery is
delta over 0d with PRUEBAS_4_34_0e.txt out of docs. After accepting these tests follow V4
to 4.37, export for other players and work inherited and cross-sectional in V5 (first V5.0
refactor).


The actual starting/closing/resuming test revealed that the Journal consumed the +use KeyUp event when
opening Crafts. 0e lets that release reach the engine so that the next Use works after Q;
it does not change the approved navigation clicks. The sequence is checked without
releasing the button by debugging commands or assigning
CraftingTaskActive/CombatChannelModeActive.

### Native 0e Verification

GZDoom 4.14.2/Linux, with Freedoom 0.13.0 and llvmpipe: 50 observations of the playable
route verify the World/C offer, native equipment, real User2 input, blocking with an
active Channel, cancellation, natural depletion, Use recovery, available recipe and batch,
Enter, Q, blocking by a pending task, resumption, cancellation and production with the
existing T acceleration. All six caravan directions are traversed; the four maps allow
using their stations, and the hub preserves groups, materials, product and the Seal
ItemId. The aids do not create a trip or repeat upon loading or changing maps. The
console-started diagnostic profile equips a native dagger to represent the weapon brought
from MAP01. Channel and crafting booleans are not assigned to simulate starting an
activity.

Seven additional observations load a native save with the actual production pending:
preserve reserves and pause, continue rejecting the journey, resume with Use and allow to
cancel without consuming or duplicating. Then a real caravan is confirmed and a single
arrival is recorded. Fixtures and saves remain outside src and are not part of the ZIP of
sources.

Compatibility is checked with a save created by running the original 0d sources, within a
caravan confirmation. 0e sources are superimposed on that same path before loading. Four
observations verify the automatically restored dialogue page without departure, three stations after closing
the dialogue, inventory/needs preserved and new preparation available without
inventing travel history. This check is not replaced by a new game. Author validation
on Windows is still pending.

Three additional checks reject actions of supplies outside of your conversation and
invalid identifiers, without granting objects or creating travel. Total: 64 correct native
observations in this verification. The Spanish offer and the physical station area of MAP02 are
inspected in native screenshots: the six responses and the three stations are visible. The
project validator ends without errors; the five documents have version 0e. They are
preserved by comparison of maps, assets, rules, attributes and the player. Only the
Journal changes the release of Use, and the presentation of stations is explicitly limited
to the test sewers.

## Previous increase: 4.34.0d — caravans and travel registration

The author confirms "All tests proved correct" for 4.34.0c and authorizes the following
patch. The MAP02–MAP05 network, its six directions and hub, is accepted, with the prohibition
to return to MAP01. Continues the V4 order to 4.37, export test for other players and then
everything inherited and transverse in V5, starting with the V5.0 refactor.

0d incorporates the caravan service base by means of an explicit test in TAB > World > C
(Y of the controller). It offers only the connections of the current sewer. The native
dialog separates selection, return to destinations, cancellation and confirmation. It is not a campaign NPC and assigns no faction; the test does not charge, create vehicles or simulate a duration.

The physical accesses and the caravan share CaelumTravelService. Before leaving, the
profile, health, origin, available destination, activity, prediction, single-player session
and absence of another pending transfer are checked. The accesses also retain their
placement, scope and vision checks. The engine moves the actual inventory and retains the
hub. The MAP01 narrative return → MAP02 continues with its exclusive confirmation and
cleanup.

CaelumJourneyState, a new and hidden Inventory, records last path, mode, sequence and
quantities of arrivals/interruptions. An arrival is counted only at the expected
destination and with its pending connection. Repeating the query or loading a resolved
arrival does not duplicate counters. Another arrival, an incompatible mark or loading an
output still in origin interrupts it without retrying. The query of a save 0c does not
invent history; it begins when traveling. World shows the last trip and offers the test.
The ca_debug_travel_report console report is read only.

The 4.34 service and registration base is implemented; the schedules, durations and
time integration of events continue in 4.35 with the clock. Transports, mini travel
map, incidents and deviations of the broad design are still planned and are not presented
as playable content of this trial. The next expected increase is the overall 4.35 clock,
subject to validation by the author of 0d. The code refactor remains in V5.0.

Delta delivery on 0c with English README, five canonical documents and PRUEBAS_4_34_0d.txt
out of docs. It does not include engine, IWAD, saves or fixtures.


### Verification of 0d and limits

In GZDoom 4.14.2 native, with Freedoom 0.13.0 and llvmpipe/Linux, 57 behavioral
observations are completed: 27 of safeguards and reconciliation, 21 for selection/cancellation/six directions and real Use, two for saved conversations, five migrations from original sources 0c and
two reloads in destination. Reconciliation cases prepare exit marks to test rejection,
interruption and resolution without attributing real paths.

The keyboard test comes from World with C, uses explicit responses from USDF and retains a
sealed card, silver key, reputation and needs during transfers. The saved conversation was
in MAP04 confirmation; loading continues there without leaving alone and a confirmation
produces an arrival. The save 0c was created by running its original sources and was
loaded after superimposing 0d on the same test path. The Box retains ItemId 1, next to
key, sealed card, 47 reputation and needs, before and after the trip. The subsequent save
contains MAP02/MAP03 snapshots and arrival log; loading does not count it again. It does not
simulate a new game as if it were a previous save. It does not repeat the whole story or
manufacturing.

World is inspected in Spanish and English with five visits and three exits prepared to
verify its complete layout; the confirmation page is captured during the native
conversation. Maps, assets, attributes, narrative inventory and accepted entries are
preserved; the new key only acts in Sewer World. Author validation in Windows pending.

## Base accepted: 4.34.0c — Test sewer network

The author confirms "All correct" for 4.34.0b. Authorizes to connect MAP02 to other sewer
maps, intended for mass testing, Tarot and the following systems. Leaves the connections
to implementation criteria, except to return to MAP01. This authorization extends the
testing space of V4; the complete campaign and legacy/cross-system work retain their
place in V5.

A star network is incorporated: MAP02 connects with MAP03, MAP04 and MAP05; each branch
returns to MAP02. There is no normal access back to MAP01. All six directions have
independent records. The narrative return retains its 1 identity, confirmation, limbo
cleaning and arrival with the Voice.

| Map | Space and purpose | Access from MAP02 |
| --- | --- | --- |
| MAP02 | Existing arrival and distribution of tests | The arrival of the prologue is preserved. |
| MAP03 | 4096 × 3072 MU reservoir, wide center, side channels and peripheral pillars; base for future massive testing | Left gate at the far north end, in (-236, 1104, 0). |
| MAP04 | Central chamber with side and rear chambers; base for future Tarot | Right gate at the far north end, in (236, 1104, 0). |
| MAP05 | Maintenance: ground floor, two stairs with eight steps of 12 MU and upper gallery at +96 MU | Wall gate right/east, in (344, 448, 0). |

Approaching the gate shows your destination and the use indication. The journey is
requested with the usual Use key. When entering MAP03–05 you look inwards; the return gate
is left behind. On returning to MAP02 you use the existing PlayerStart (-236, 32, 0),
separate from the gates. Holding Use during loading does not produce a bounce trip. There are
no costs, dummy travel time, automatic loading of enemies or gift cards.

The four sewer maps belong to the native 434 hub. GZDoom saves its actors, left objects
and modified geometry for the return and for session saves. The character inventory
travels as its own instances. Switching between sewers does not run the cleaning of the
Limbo again, does not cure or replenish needs. Traveling with active activities or menus,
freezing of others, invalid character, wrong origin, missing destination or several
players is refused; exit of the rest is not forced.

MAP01, MAP02 and CADEV02 are preserved. The gates are rebuilt from the existing
controller, so they also appear when MAP02 load from 0b. Prepare again does not duplicate
accesses. The persistent Inventory scheme is not changed: 32 slots and 1 World
version; content identities are added only in the reserved catalog positions.

TAB > World presents visits in one column and known exits of the current map in another.
Approaching an access discovers it; the visit and the tour are credited upon arrival.
Knowing or walking the way does not invent the return. The Journal is still of
consultation. The arrows and Page Up/Page Down keep their accepted actions. The completed return to the body is reported in the footer as a journey without step back to the mansion.

### Verification and 0c limits

- 23 catalog checks, reconstruction, origin/distance/height, prediction, death, character creation, activities, menus, freezing, discovery and query without altering missions, Tarot or
  attributes.
- 42 checks during the six native routes and a review: key Use real, independent
  addresses, keys/quantities/reputation, unfilled needs, absence of automatic mass
  population, conserved actors and soil objects and walking up the real stairs.
- Eight new checks when loading the network save: current map, visits/directions,
  inventory, inactive MAP02, resources and snapshots, followed by native return journey
  without duplicating gates.
- Ten checks when updating a save created with original 0b sources: adoption of the hub,
  reconstruction of three accesses, Box/weapon identities, backpack location and original
  durability, card/assignment/unique reward/reputation, travel to MAP03 and return keeping
  an actor who was already in the 0b save. Fixture prepares that data in 0b; it does not
  substitute for a complete repetition of the prologue.
- The actual narrative output is also verified from its prepared requirements: native Use/confirmation, pending mark, original cleaning, Box/first weapon in the Box, card,
  arrival at MAP02 and coexistence of Voice with accesses.
- Native visual review of gate, reservoir, chambers, stairs and full Journal in
  Spanish/English. For the capture of the Journal layout the five visits and six tours are
  prepared in a private fixture.

Environment: GZDoom 4.14.2, Freedoom and llvmpipe/SDL on Linux. Test fixtures prepare
positions, some objects and states; they are not distributed. The 0c check by the author
on Windows remains pending. The ability of MAP03 for a particular population has yet to be
measured: no approved massive test is declared. MAP04 does not advance new Tarot and MAP05
activations do not yet apply hazards, environmental damage or deep immersion.

Delivery: delta over 4.34.0b, reproducible UDMF generator in assets/generators, English
README, five canonical documents and PRUEBAS_4_34_0c.txt out of docs. Modular architecture
here is map. The transverse refactor of the code remains in V5.0. 4.34 remains the caravan
bases and travel integration; its durations/events will be supported by the 4.35 clock.
Then continue 4.36, 4.37 and export test for other players before V5.

## Base accepted: 4.34.0b — doors and accesses by group

The author confirms "All right" for 4.34.0a and authorizes the following patch. World,
places visited, return registered and save compatibility are accepted. The decision
remains: finish V4 to 4.37, export a test for other players and then board in V5 all
inherited and cross-sectional.

0b continues the architecture bases with closed doors and access requirements. The review
finds three unwanted opening routes: a free door leaf could bypass another leaf's key or arena lock; moreover, all doors with zero id were treated as a group. The behavior with the
0a sources is checked before correcting it. Now they validate key, arena and reputation
condition of each door leaf before altering requests or timers. Only positive ids link door leaves;
without id each door works alone.

The closure checks the original opening and the character's radius/height, even when the
leaves are removed. It keeps the whole group open while the player occupies the pass and
reopens it if it enters during the closing. Loss of the key does not lock it in an already
open door; once closed, the next request requires the key again. Express arena lock retains its previous priority. Normal speeds, travel and waiting are preserved.

LOCKDEFS remains the key authority and does not consume them. Its silent query precedes
the message/sound limited by the existing timer. 200/201 locks and the new 202 use its
own locked door sound, without superimposing manual playback to native sound.

### Optional test accessible

In a clear area of MAP01 or MAP02, close dialogue/trade and use: `give
CaelumDebugDoorTrial`. Place a two-leaf door in front of the character; only one declares
the 202 lock. Use anyone without the key must reject both. `give CaelumDebugDoorKey`
delivers a single reusable native key, independent of the silver key. Use opens the group;
remaining in the middle keeps the step open and removing allows normal closure.

`give CaelumDebugDoorTrialOff` removes those door leaves and their key. Blockers are removed in
their next ticks. Repeat activation retains the same instances. The test does not deliver
the Argento key, modify reputation, activate missions or record new trips. It does not add
a campaign obstacle: its isolated presentation only appears upon request. The key is a Key
marker without weight or row of equipment. It can be saved and loaded with the test.

`netevent ca_debug_door_report` consults rating, separate keys, map, group, lock and
progress/waiting/occupancy of each door leaf. It does not open doors or create the test. World,
Integration and El Loco diagnostics continue to work and update its header to 4.34.0b.

### Evidence and limits

- Twenty native requirements checks, rejection without partial changes, zero/negative id,
  different groups, reusable key, social conditions, arena, prediction, unevenness,
  occupation on both axes and NPC requests.
- Seventeen native use checks: test commands, instances preservation, key Use on both door leaves, incorrect/correct key, collision on entry, stay beyond normal waiting, key
  loss, closing and reopening when entering during movement. Repeating them in English
  checks the texts and does not increase the number of different cases.
- Eight new checks when reloading a partially closed 0b door: references, configuration,
  position/progress, keys, check without effect, continuation, withdrawal of the test and
  absence of orphan blockers.
- Seven new checks when loading a save produced with original 0a sources and a partially
  open door: actors/configuration, movement, World, key/reputation, opening/closing and
  restored door-leaf protection. Serialized preparation check is not counted again.
- Placing the test from the existing start of MAP02 and preserving your visits/Tarot
  without inventing a return. Revised native screenshots in MAP01/MAP02; messages in English
  and Spanish.

Environment: GZDoom 4.14.2, Freedoom, llvmpipe and SDL keyboard on Linux. The test
prepares positions and an extra silver key only in private fixtures to verify that it does
not substitute for key 202 and that withdrawal does not delete it. It does not repeat the
entire campaign or establish co-op support. Automatic occupancy checks protect players;
the forced arena closure retains its previous contract. The author subsequently confirms
"All correct" for 0b and authorizes 0c.

Delta over 4.34.0a with README, five canonical documents and PRUEBAS_4_34_0b.txt. 52
original door actors from MAP01 already use positive groups; their numbers, positions and
maps do not change. Attributes, navigation, missions, narrative inventory or the
persistent World scheme are not modified. The next increase continues architecture,
modules and access between floors in 4.34; calendar, hazards, Tarot/Trucazo and export
retain their order.

## Base accepted: 4.34.0a — locations and connections

The author will complete the current V4 roadmap, then prepare a test export for other
players and move all the work inherited and transverse to V5 after that export. Authorizes
to continue with the next patch; this decision allows progress from the 0ao technical
closure. No additional confirmation of all 0ao tests is recorded.

4.34.0a starts the world catalog and replaces the TAB > World provisional screen by
current location, visited places, and known connections. It uses the existing names of
MAP01 and MAP02. The "Back to Body" connection is known when the narrative output is
ready; its destination remains "To be discovered" until it arrives. In MAP02 it is
"Roamed" and it is indicated that it is a one-way trip. The Journal reports; confirmation
remains at the threshold.

The record resides in the character's persistent Inventory, with stable ids, visits,
knowledge, route and a pending connection. After the validated commit the pending
output is recorded; only the corresponding arrival converts it to travel. Save, view the
Journal or consult the console does not travel or award rewards. The cleaning of the
Limbo, the Box, the first weapon, El Loco and quests/reputation contracts of 4.33 are
retained.

The above saves record the current place. A full MAP02 save with MAIN_M00, first preserved
weapon and documented final cleaning also recovers the visit to the mansion and the return
made. Entering MAP02 using "map map02" without those facts records only the sewers.
CADEV02 and unchecked maps do not acquire a campaign id. No reverse path is inferred.

Explicit query: `netevent ca_debug_world_report`. Read registry version, current map/id,
visits, known/traveled connection and pending state, without creating records or touching
missions, inventory or attributes. Previous diagnoses remain available and update their
header to 4.34.0a.

### 4.34.0a Verification

- Eighteen boot checks, ids and saves, query and native Journal navigation: valid
  character, character creation/death/prediction, unconfirmed output rejection, invalid pending id
  and left/right/Page Up/Page Down.
- Four specific checks of the route: previous save of MAP01, transition confirmed still without
  destination visited, pending departure before ChangeLevel and actual arrival with the
  two visits and the connection traveled. The scenario also reuses capture, cancellation,
  +2%, cleaning, trade, missions, rewards and native arrival verified in 0ao.
- Six checks when loading a native 0ao MAP02 save: world migration, Box/first
  weapon/Tarot, unique endings and certificate, preserved reputation and trade, without
  repeating the finished arrival dialog.
- Four checks of a new session initiated directly at MAP02: current location without
  inventing the mansion or its return; a pending attempt without evidence of departure
  does not get tour either.
- New registration is saved and reloaded in MAP01 and MAP02. Native fields persist;
  arrival autosave also contains visits and tour. Serialized preparation checks are not
  counted as new.
- World native render before return and after arrival; texts of the known connection
  reviewed in English and Spanish. The visual scene prepares only the knowledge of the
  connection to check that it hides the name of the destination.

Technical environment: GZDoom 4.14.2, Freedoom, SDL keyboard and llvmpipe on Linux. The
integration scenarios start from QA saves and prepare the record of first weapon; they do
not repeat all resident tests or all manufacturing. The author subsequently confirms "All
correct" and authorizes 4.34.0b. Engine, IWAD, saves, fixtures and private captures are not
part of the delta.

Delivery on 4.33.0ao: README, five canonical documents and PRUEBAS_4_34_0a.txt.
Maps, assets, attribute formulas and Inventory/Quests controls remain unchanged. There
are no new destinations or fast travel, prices/durations travel, calendar or campaign
content on this patch. The following increments of 4.34 will continue its architecture,
connections and travel bases; 4.35–4.37 and export continue on the lower roadmap.

## Technical base: 4.33.0ao — integration closure

The author confirms that all 0an tests were correct and authorizes the following patch,
first requesting the complete V4 roadmap. reputation/membership requirements,
dialogue, access, trade, save and test controls are accepted. 0ao verifies its coexistence
with missions, capture and narrative output, retaining approved rules.

`netevent ca_debug_integration_report` is added: query the existing records of the player
requesting it. Shows MAIN_M00, objectives and endings of the two assignments, registered
delivery and certificate presented separately, the four reputations/memberships, Box,
first weapon, Tarot, commercial conditions, enabled testing and status of departure/arrival.
Do not create or repair records, award rewards, change reputation or activate
demonstrations. The detailed report of El Loco remains available, with 4.33.0ao header.

### Active conversation when loading

The arrival-autosave reload reproduces a specific discrepancy: ConversationNPC and
bInConversation are still active, but there is no USDF menu. Voice is marked as initiated
and the reputation test waits for that invisible dialogue. The native StartConversation function
shows the dialogue of the same interlocutor again without choosing answers or granting rewards.

CaelumConversationResume is a StaticEventHandler registered in MAPINFO. It receives
WorldLoaded with IsSaveGame and defers reopening to the first WorldTick. It checks
alive/created character, active conversational interlocutor and ConversationPC equal to the
player. It uses the saved orientation and saveAngle=false; it does not call Used, reassign a tree, delete references or modify records. It does not run on a normal map entry or on inactive references. Its marker is static and does not add data to the save.
It also fixes the reloading of the autosave created before this fix.

### Joint verification and limits

A native save is created with the original 0an sources: Box received in the Palomo dialog,
a real purchase of five wood units for 14 copper coins, trade with active condition/discount,
reputations and different memberships, completed Tour certificate and active Wait with passed
time. Loading it with 0ao checks preservation and non-repetition of the transaction. Trade
with Q is closed and the revelation, cancellation and explicit capture of El Loco, its
unique animation and bonus is traversed with native keyboard.

The exit is confirmed by the existing door and dialogue. The transition and cleanup of the
Limbo precede the journey: Box, first weapon in it, card, social records and certificate are
preserved; the physical objects of test subject to that cleaning, including coins and
purchased wood, are removed. The trade is closed and its temporary reduction does not
become a negotiated discount. The reputation test cannot interrupt the Voice of arrival;
it is then reopened in MAP02. Wait retains its state until completion/reward collection, and
the endings/rewards remain unique. Removing the test retains the records.

The final MAP02 save is also reloaded: both assignments and the certificate, reputations,
Box/weapon/card, commercial stocks and withdrawal of the test are preserved. The already
closed dialogue does not reopen. The integration query leaves intact inventory, health,
clock and records examined.

39 integration checks pass: 17 new when you continue the 0an save in MAP01, 16 from
arrival/assignments and six final reload. The four saves preparation controls with 0an do not
add up again. The six repeated checks when you reopen different pages do not duplicate
either; the recovery of both saved pages is checked by the native menu.

The private scenes start after the resident tests and prepare the Tour objective and the
first weapon record to test contracts. They do not repeat the entire campaign or its
manufacture. The engine, IWAD, SDL inputs and QA saves are left out of the patch.
Environment: GZDoom 4.14.2, Freedoom and llvmpipe on Linux; the author's Windows
verification of 0ao remains pending. The evidence of previous blocks already approved is
preserved and is not counted as new evidence. The author then authorizes to continue with
4.34.0a.

Delta delivery on 0an with README, five canonical documents and PRUEBAS_4_33_0ao.txt.
Maps, assets, attribute formulas, serialized states, reputation conditions and mission
logic are preserved. The author authorizes to continue with 4.34.0a: locations and
connections.

## Base accepted: 4.33.0an — Reputation conditions

The author confirms that 0am works and validates the two optional assignments: completing them
delivers the certificates, abandoning Tour prevents accepting Wait, and traveling to MAP02 before completing the route objective causes failure. Corrections of capture, seals and navigation are
accepted. The current attributes and Journal boundary controls are preserved.

0an connects the existing registry with reusable conditions for opening dialogues, sliding
doors and trade. Each condition declares faction, minimum reputation and optional
membership. Membership does not replace the minimum. Doors validate the entire group
before moving it; transactions revalidate before exchanging coins or objects. Reputation
discount is temporary and separate from persistent negotiated discount.

### Accessible test and scope

Save before and run `give CaelumDebugReputationTrial`. The test opens immediately; then
TAB > Reputation > F/Y reopens it. It offers five selectable states and three real
services. Use Unitarians as technical id:

| Test service | Requirement |
| --- | --- |
| Information | Reputation >= 25 |
| Physical door | Member and reputation >= 25 |
| Trade | Reputation >= 0 and own Box |
| Trade discount | Reputation >= 25; existing margins 140%/60% |

The five states are 0 without membership, 25 without membership, 25 member, -25 member and 0
member. They modify the actual register of Unitarians; they retain the other factions.
The test uses inventory, coins and actual stocks, without delivering Box, resources or
rewards. Close trade with Q/B; Esc retains the engine pause menu. To remove the test,
close your menus and use `give CaelumDebugReputationTrialOff`: removes guide and door,
without reversing reputation. Loading the previous save restores the pre-test status.

The six ids and -1000..1000 scale are preserved. At this historical checkpoint,
rank thresholds and the author matrix were pending; approved V5.9 data now
supersedes that pending status. The values of this test do not set that design. Maps,
missions, campaign reputation gains, regional price formulas or attribute bonuses are not
added.

### Evidence and validation of 0an

Thirty-seven native checks cover invalid limits and ids, independent membership, correct
faction, rejection of actions outside the dialogue, conditions of groups of doors, real
purchases/sales, exchange rate and closure due to loss of access. The separation between
temporary and negotiated reduction, coins/stock conservation is verified when refusing
and absence of duplication or alteration of missions, Tarot and attributes.

Nineteen interface checks use keyboard SDL events: activation, re-opening with F, native
menu states, dialogue and door permission, prices and purchases with Enter, Q-closure,
Reputation controls and withdrawal of the test. Spanish and English texts are reviewed
with the native render; repeating the same cases by language does not add different cases.

A native save created by the original 0am sources retains when loading with 0an the four
reputations/memberships, Box, coins, attributes, water, completed mission, certificate and
successor offer. An already open trade retains its negotiated discount without receiving
new requirements or activating the test. Then it saves and reloads a session with 0an
conditions: its fields, discount and owner/guide references are preserved. Withdrawing the
required membership blocks the transaction without expense; the native journey to MAP02
retains the records and allows rebuilding the presentation of the test there.

Environment: GZDoom 4.14.2, Freedoom and llvmpipe on Linux; controlled scenarios, not a
complete repeat of the campaign or a save of the author. The author later confirms that
all 0an tests were correct. QA helpers, saves and engine are out of the delta.
Application and instructions in PRUEBAS_4_33_0an.txt.

Delivery on the complete 0am project with README and five canonical documents. Its acceptance enables final 0ao integration before starting locations/connections/travel
4.34 bases.

## Base accepted: 4.33.0am — inactive conversation and Journal boundaries

The capture of the 0al log shows 80 phase, a valid owned Box, requirements met and essence
accessible at 32,6 MU. There is no channeling or reloading. ConversationNPC retains an
actor, but its bInConversation is false. Capture rejected any reference, even if there was
no active dialogue.

0am checks the real activity of the interlocutor when opening the essence and waiting for closure before animating it. It applies the same rule to the door, to the exit transition
and to the Arrival Voice. It does not erase native references or repair progress: an owned Box and explicit capture choice are still required; opening or canceling the dialogue does not grant the card. It retains the unique delivery and existing bonus of El Loco.

Left/Right runs through the known filters and missions. From the first element,
Left passes to the previous tab; from the last, Right passes to the next tab. Inventory: Tarot/Character. Missions: Crafts/Reputation. With a single mission, both arrows go out to
their adjacent tab. Upon returning the selection is retained. Page Up/Page Down or LB/RB
changes tabs directly; Up/Down and F/Y maintain their other functions. Spanish and
English aids explain the ends in a second line.

### Evidence and validation of 0am

The log status is reproduced in a controlled manner: reference of an NPC whose dialogue is
already closed. In the original 0al sources, Use does not open the essence. With 0am, the
same native input opens El Loco and Enter completes the capture, also after exhausting
Quintessence. The Box is received by the actual Palomo dialog, without giving it
directly. The scenario starts after the four resident tests; it is not a complete
execution of the mission nor does it use an author's save.

Twenty-eight Journal checks go through keyboard SDL events and the native dispatcher:
filters, both ends, one and three missions, gaps for unknown entries, Detail, retained
selection, Page Up/Page Down and absence of automatic acceptance. Language repetitions do not
add up to different cases. Twelve Palomo/Box/depletion/capture section checks confirm the fix on the reproduced state, identity and unique delivery with +2%.

Seventeen additional checks pass when loading with 0am a native save created by 0al with
inactive reference, in the coordinates communicated: Box and preserved attributes, absence
of capture while loading, protection of an active interlocutor, Use, cancellation with Esc
and new confirmation. The animation ends even if another inactive reference to the essence
is retained. The door opens and the transition arrives at MAP02 even with an inactive reference
to the threshold; surviving card, Box and first weapon and opening the Arrival Voice. The
weapon and its registration are prepared only to verify the departure contract; this test
does not repeat the crafting. The save files are not modified.

The engine compiles the sources without errors and passes validate_project.py: five
documents, 74 audio files and 12 station models. The delta contains 12 new/modified files. Environment: GZDoom 4.14.2, Freedoom and llvmpipe on Linux. The author's check on
Windows remains pending. Test aids, engine and IWAD are not part of the patch.

Delta delivery on 0al with README, five canonical documents and PRUEBAS_4_33_0am.txt.
Maps, assets, attributes and infrastructure protection/restoration are preserved. Author
accepts these settings before 0an.

## Base 4.33.0ak — Observed capture; revised controls in 0al

The author reports trees and stations displaced by Quintessence, blocking by capturing
the essence and controls of the Journal that change filter/tab instead of the intended
destination. 0aj is not approved. The base of optional missions is retained and these
corrections are prioritized before reputation.

The seal selection accepted infrastructure because it is also SHOOTABLE. 0ak excludes
CaelumMovableProp from the seal area, including captured mass and ejection. MAP01 relocates
the same plants and stations once: origin of the garden and current layout of the rooms.
It does not recreate the nodes or their stocks; it retains its references, tasks and
reserves. It also cleans unwanted velocity and suspension of targets in saves.

The normal capture was reproduced successfully on the original 0aj sources. The reproduced lock
appears when channeling: PlayerThink discarded Use. A fresh Use press now stops the Channel,
applies its normal cooldown and arrives at native interaction on that same press. El
Loco retains its own Box requirement and confirmation of the single delivery dialog.

Journal: Left/Right changes mission in Missions; in Inventory changes tabs
directly. F/Y retains the inventory filter. Page Up/Page Down or LB/RB changes tabs in any
section. The arrows of an open station retain their recipes; leaving Crafts closes the
native session and pauses work at the station. Help text is updated in Spanish and English.

### 0ak Technical Validation

GZDoom 4.14.2 with Freedoom and llvmpipe on Linux. Isolated scenarios on patch sources;
engine auxiliaries and resources are not delivered.

- 78 Target Checks: Actual infrastructure of MAP01 excluded, trees and stationary stations
  with Air/Quintessence, restored gravity and attraction/mass/expulsion continuity for
  combat targets.
- 34 Journal checks: ten filters, circular navigation between missions, Detail and
  cancellation of abandonment, tab keys and native closing of a real station. The same
  path of key codes used by InputProcess and its native events is invoked; keyboard/controller
  physical pending.
- 19 when loading a game saved by original 0aj sources with active Quintessence and
  displaced plants/stations: position, identity, gravity, partial stock, fractional yield, attributes, choices, 1,25 liters, Box, completed mission and reward
  preserved. Use interrupts the Channel and opens El Loco; confirm grants one card and only its current +2%. Repeated capture or reward is rejected.

131 different checks pass without failure. The interface is reviewed in both languages,
without adding up the repetitions of the same controls. The author's save has not been
received: the compatibility uses a native save prepared to reproduce its symptoms. It does
not represent a complete game. Application and acceptance in Windows:
PRUEBAS_4_33_0ak.txt. Maps, art, audio, models and attribute formulas are preserved with
respect to 0aj. The project validator passes without errors: five documents, 74 audio
files, 12 station models and references. The delta contains 12 files: five runtime files,
README, five documents and one application/test TXT.

## Base 4.33.0aj — comments corrected by 0ak

0ai is approved by the author. All attributes are preserved, including Resilience for
Sleep and consumption/regeneration divisors of Constitution. The previous audit is recorded
for future review.

0aj implements the optional mission base: offer, requirement for another completed
mission, explicit acceptance, objectives with bounded progress, complete, fail and abandon with
confirmation. An end is not overwritten or restarted. The reward uses native Inventory and
a mission delivery record; failed receipt allows retry, and the object is not replenished.

The Journal selects between known missions and shows Detail of the chosen one. The
diagnostic chain is enabled with give CaelumDebugQuestTrial: Tour followed by Wait. It
is separated from narrative content: certificate without weight, price or attributes,
without altering the main mission, Tarot or T1 resources. SYSTEMS.md defines rules and
limits; PRUEBAS_4_33_0aj.txt explains the route.

After resolving the capture and accepting the controls, the next block connects reputation
with reusable conditions. The integration will then be reviewed before V4.34. Bullets and
water treatment are still pending definition for later enlargements. V4.35 calendar
precedes Rest; V5.0 retains the refactor programming.

### 0aj Technical Validation

119 passed checks, zero failures, in GZDoom 4.14.2 with Freedoom and llvmpipe on Linux. The
evidence of the recovered work is preserved and the flow and interface is re-run over the
final sources; repetitions of the same scenario are not added as additional checks.

- 70 of the life cycle: discovery without acceptance, chain requirement, invalid indexes
  and targets, limits of progress, explicit completion, failure, abandonment, permanent
  endings and unique native reward. Removing the certificate does not reopen reward collection;
  a rejected reception admits retry. MAIN_M00 retains its status and its setters refuse
  to alter an end.
- 13 of the Journal in Spanish and 13 in English: circular selection, detail of the chosen
  mission, blocked offer, native acceptance/abandonment events, cancellation of confirmation
  and update of the screen. List captures, details and revised endings. The scenarios
  invoke the navigation and network events of the engine; the physical keyboard/controller is
  verified in Windows.
- Eight when loading a game created with original 0ai sources: log and main stage, Journal
  snapshot expansion, attributes, 1,25 liters of canteen and seal/amulets choices
  preserved. New offers do not appear until the test is explicitly enabled.
- Eight when reloading a 0aj save with partial wait: time, target, previous reward and
  main mission preserved, continuation and unique delivery of the second assignment.
- Seven in a ChangeLevel real MAP01 -> MAP02: travel the certificate, collection record and
  active counter; complete and collect the reward at destination without duplicating the previous
  reward.

The scenarios prepare profiles and objectives to isolate each condition; they do not
represent a complete game, the narrative crossover of Limbo or a cooperative validation.
The limits of the health observation described in SYSTEMS.md are maintained. The author's
acceptance on Windows remains by PRUEBAS_4_33_0aj.txt.

The project validator passes: five documents, 74 audio files, 12 station models and
preserved references. The delta is checked against the 0ai base recovered and matched with
its saved ZIP. All three WAD, audio resources and attribute calculations retain their
bytes. Delivery: 15 new/modified files and an application/test TXT. ZIP CRC and exact reconstruction of its contents verified.

## Base 4.33.0ai — approved by the author

The author corrected his previous indication: Sleep belongs to Resilience. 0ai restores
that association by retaining the Type 4 divisor (1 at attribute 0; 3 at 100).
Constitution controls Hunger/Thirst and now also divides their cost during health/Air regeneration, without repeating the passive consumption mass factor. Speeds remain
unchanged. The <=10% critical threshold restored in 0ah and the approved 0ag pool, partial refill and sips are preserved.

The audit of the twelve attributes is in SYSTEMS.md: matching families, active effects,
scale/assignment differences and pending functions. The author table remains as design
intent; the audited matrix does not treat fields that are only calculated as completed features. Its
differences in this patch are not automatically implemented. Ronnie is updated in both
languages, README and five docs, without creating more canonical documents.

A previous game updates the factors without restarting reserves, choices or progress.
Delta delivery over 0ah plus a TXT test. After accepting 0ai, close the review of the
tutorial and continue world/travel fundamentals, without expanding maps. Remains the
discrepancies of attributes recorded below, unsafe water treatment and bullet composition/processing. Calendar precedes Rest; V5 maintains the refactor of programming
architecture.

### 0ai Technical Validation

95 native checks approved in GZDoom 4.14.2, Freedoom and llvmpipe in Linux: independence
of Constitution/Resilience/Patience, 0/50/100 curve, 50/100/200 masses, fractional
attributes and limits, real passive consumption and factor update. Actual quantities and
costs of both regenerations, maximum, insufficient reserve, absence of double mass and
critical rule for all three reserves to 1/10/10,1 points are checked.

Another eight passed checks load a save created with the original 0ah files and a normal
profile with Patience other than Resilience. They verify new factor and cost,
attributes/reserves/liters preservation and choices and absence of accumulated division.
Total: 103 native checks, without faults. The preparation of the save was also verified
with the original formula; the save file was not edited to simulate compatibility. The
documentation/resource validator ends without errors, with five canonical documents.
Delivery of ten files, without binary resources or test code. The author confirmed that
all 0ai tests were correct. The attributes remain as they are; the differences of his
audit are postponed.

### 0ah Technical Validation

96 checks passed in GZDoom 4.14.2, Freedoom and llvmpipe on Linux. 88 check the curve at
0/50/100 with independent Constitution and Patience, masses of 50/100/200, fractional
attributes and limits, one second of native consumption, refresh of old factors,
thresholds 0/1/2/9,9/10/10,1/50 for all three reserves, combined damage and regeneration
blocking. The pool, partial refill and approved 0ag sip also pass their regression checks.

A save was created with original 0ag code, 100 attributes and zero factors; another eight
checks load it with 0ah and verify positive consumption without restarting reserves,
attributes, liters or choices. The divisor does not accumulate. The documentary and
resource validator ended without errors. The attribution to Patience and regeneration
costs are now replaced by 0ai; these previous tests are historical evidence, not
acceptance by the author of 0ah.

### 0ag Technical Validation

161 passed native checks in GZDoom 4.14.2 with Freedoom and llvmpipe, Linux. The water block adds
153: the six models to 50/100/200 kg, volume per sip and remainder, ten real pulses for
ten seconds, MAP01 with/without container, partial refill and load/Box limits, damage at zero Thirst, regeneration to 1 and 2 points and previous Hunger/Sleep rules.

Eight other checks load a save created with 0af delivered code: liters, pending drink
effect, progress and choices/allowance of preserved silver; new mass-adjusted sip and real
refill/hydration in the pool. The test isolates the prologue so that its automatic dialogue does not pause time. The documentation and resource validator ended
without errors. The author approved all tests of 0ag; the positive-Thirst rule is reverted
in 0ah at the author's request.

### 0af Technical Validation

GZDoom 4.14.2 with Freedoom, rendered by software in Linux: they pass the combinations of
the five seal choices by four amulets, the six containers, formula by mass, Ronnie
delivery, limited silver, personal manufacturing and persistence. A save generated with
the original 0ae code was also loaded and their pending seal was finished before choosing
the accessories. Native menus were toured in English and Spanish. RGBA Sprites reviewed as
images; the author's subsequent tests approved these resources. The documentary and
resource validator ends without errors.

## Base 4.33.0ae — approved by the author

The author confirmed that all 0ae tests passed. 0ae's full base was recovered
from the author's attachments.

The author approved all 0ad tests. Caella offers to show the five T1 Seals and their
components after completing their test. Read or postpone does not change the character;
accept enables optional knowledge and quota for one of each item. Use existing recipes,
without changing Channel costs or effects.

The set at 100% in each layer requires 1,8 kg gross copper, 0,2 kg gross tin and 0,6
kg of each gem. The quota is added to the chosen equipment without restarting what has
already been issued. If there is an owned T1 Seal when learning, only the missing
ones are budgeted; the Caella loan does not count. That initial existence is recorded:
manufacturing or losing a piece after it does not replenish the quota.

Native recursive crafting from raw materials, personal result without Box, one equipment slot and Detail 0/5–5/5. Caella's Workbench and the complete workshop on the
second floor have the infrastructure. Ronnie can lend the sword again for the outstanding
seal materials, even with its mission and repair completed, and accepts the return for its
workshop talk.

It does not add mission requirements or change runes, exit narrative or what comes out of
Limbo. Maps and audiovisuals retain their bytes. It is applied on 0ad by copying files
plus PRUEBAS_4_33_0ae.txt. Validation at the end of this document. Next block of systems:
water collection/treatment; composition and bullet processing still need author
definition. Calendar/rest and V5 architecture retain their place on the roadmap.

## Base 4.33.0ad — approved by the author

The author approved all tests of 0ac. Ronnie asks which armor family is desired after
choosing weapon: magical, light, medium or heavy, with description and confirmation. It
teaches the four pieces T1 and components; who already chose weapon can access by his
conversation about workshops. It does not force repeat missions or add a requirement to
the Bull or to the exit.

The supply to the 25% is replaced by a finite quota to the 100% in each layer: one weapon
chosen, one set chosen and ten arrows/bolts when applicable, at the chosen size. Leather
M: 5/10/20/40 kg sets, plus 6 kg if the weapon is the giant gauntlets. Each source
discounts the same quota per character. The Bull retains its maximum physical yield,
but shares a quota with the drawer. Previous stacks also respect the limit when
collecting; the new ones do not generate surplus. Partial collection and the drawer leave a
gram free of capacity.

Previous inventories are not deleted when updating: they count toward the 100% together with
components and first weapon already made. The drawer accepts unreserved surplus. The
above tasks maintain efficiency, time and reserves. The optional repair practice enables
only the missing amount proportional to the observed damage; it does not replenish a complete
batch. You can order and return the gathering sword for that practice. Native manufacturing,
equipment and progression.

Apply to 0ac: new/modified and PRUEBAS_4_33_0ad.txt files, without applicators or
PK3. README and five updated documents. Next block: teaching T1 seals and their quotas;
bullets need composition/process and water needs collection/treatment rules. Deferred new
maps; V5 maintains refactor.

## Base 4.33.0ac — approved by the author

The author approved all tests of 0ab. Bolt crafting is incorporated: Ronnie teaches the
recipe and dependencies when choosing crossbow. It also incorporates the knowledge of
saves with that choice, inside and outside MAP01. It does not give ammunition, materials
or another loan, and does not change the first weapon chosen.

Recipe 130, appended to the previous 130 recipes. Ten native 50 g bolts per batch; adopts the same
T1 structure of arrows: 70% shaft and 30% bronze tip. Waste and time of each layer are
calculated by the current rules, without other materials. Ronnie Workbench or second
floor, Ammunition filter. Personal output without mandatory Box, reservations and native
tasks. Guide in the Ronnie workshop section and in Detail for who chose crossbow.

Apply to 0ab with src, docs and README.md. Only new/modified files plus
PRUEBAS_4_33_0ac.txt. Maps and audiovisual resources are preserved. Next coverage:
acquisition of recipes from armor/Seals T1. Bullets need to define composition and
processing before defining their recipe; a complete recipe is not inferred from their current 3 g mass. Water requires collection/treatment rules. Calendar/rest mechanics and
architecture remain at its milestones.

## Base 4.33.0ab — approved by the author

The author approved all tests of 0aa. The following pending section of Ronnie is
implemented: breathing in the existing pool, behind the mansion to the east. Read the
proposal does not start; accepting enables an optional practice. Submerging the head for one second near the steps records actual Air expenditure. Raising the head again and completing the native three-second Air recovery after immersion records recovery. Detail and Ronnie recognize each phase.

Registration persists during immersion, recovery and after completion. Wet without
covering the head, swim before accepting or filling Air by debug do not replace events.
There is no requirement to cross the pool or return to Ronnie. It does not modify
resources, costs, geometry, Rulo requirements or output. MAP01 continues as testing
environment; new maps remain deferred.

Apply to 0aa by combining folders. Only new/modified and PRUEBAS_4_33_0ab.txt files.
Validation evidence below.

## Base 4.33.0aa — approved by the author

Minors add only base attributes by suit/rank before the collection percentage. A complete
suit gives +3 to its three attributes. Swords: mental; Cups: social; Wands: physical; Coins: technical. 78-index record retains property; Journal separates passive and
collection. El Loco remains the only card obtainable in the current content; no other
missions are advanced.

Zoom adds 360° sweep to greatsword, war axe and halberd at triple the primary Air cost, preserving
damage, reach and recovery. One hit per enemy, with respected geometry and allies; gauntlets retain blocking. General damage received and Anima cost are divided by the Type 4 factor from Toughness/Eloquence; at 100, the divisor is 3. Collisions, Pain and Lucidity retain the above rules.
Old statistics are reconstructed when loading without duplicating bonuses/progress.

Apply over 0z by combining folders. Deliver only modified files plus PRUEBAS_4_33_0aa.txt;
the validator now accepts multiple letter suffixes.

## 4.33.0z base — included in approved 0aa base

0y-based approved: The author confirmed that all tests were correct and that the
reported disagreement was an interpretation error. No mission state repair is applied and
no attribute mode at 100 is changed.

Ronnie Stage D: Load. Dialogue with real weight, capacity and Air factor. Optional
practice: lighten by releasing a surplus or save it in the Box if it reduces the weight.
Excludes the first weapon. It does not deliver objects, impose overload, alter costs or
add a lock. It uses the same inventory interface; loans and reserves maintain its
rules. Saves and travel preserve the result. MAP01 remains the system testing environment.

Apply src, docs and README.md to 0y, combining folders, and reconstructing with
run_dev.bat. PRUEBAS_4_33_0z.txt contains only new checks.

## Base 4.33.0y — approved by the author


Base: 0x complete, all tests approved by the author. Continues the C section of the
survival tutorial: Air and motion. Map construction and sewer expansion are still delayed;
MAP01 is the testing environment.

Ronnie offers the practice after returning the sword. Acceptance records a target equivalent to
the 1% of the current maximum Air, without modifying resources. The native expenditure
when running and moving accumulates the first part. The subsequent natural recovery
accumulates the second part. It does not require exhaustion, a concrete route, return with
Ronnie or complete to follow the mission. The partial state and results are preserved in
the Persistent Inventory. Detail shows what is missing. Drinks, attacks, jumps, immersion
and debug restorations do not replace the two points observed. It does not change
costs, rhythms or resources of the world.

Apply src, docs, and README.md to 0x, combining folders, and rebuilding with run_dev.bat.
PRUEBAS_4_33_0y.txt contains new tests.

## Base 4.33.0x — approved by the author


Base: 0w complete, including the cumulative from 0u. The author downloaded and approved
ALL these changes. The previous delivery rectification is resolved. Confirmed priority:
systems and roadmap mechanics, using MAP01 for testing. Build maps and expand sewers is
deferred.

Ronnie teaches food/water after the player returns his sword. The proposal requires
confirmation; only then lowers reserves above 90% to that level once and delivers a portion of each
type. Record native uses under the 100%, without requiring return or adding blockages.
Detail shows food and water separately. If you cannot deliver due to carrying capacity, try only the
pending ration when ordering it. Native consumables refresh respects ten seconds without stacking, even just before the effect expires. Maps, art and audio do not change.

Apply src, docs and README.md to 0w, combining folders, and reconstructing with
run_dev.bat. PRUEBAS_4_33_0x.txt contains only new checks.

## Base 4.33.0w — approved by the author


**Historical base of the cumulative 0w:** complete 0u folder. The 0w version was approved
by the author. The cumulative included 0v and 0w; the author subsequently approved both.
0w expands the tutorial with an optional Ronnie repair practice, available after returning
its sword. It does not require repeating branches or adding a lock to the implemented
closure. The actual first weapon is used, by its ItemId.

Ronnie explains how to inspect the wear, selecting/unequipping the part, use the Workbench on the second floor and press F on Crafts. Native repair retains costs, materials,
efficiencies, times and reserves. Practice is recorded only when actually restoring that
part; talking does not fix it, does not artificially damage it and does not credit a started/canceled/paused task. Detail shows the optional status. Saving and traveling
retain its result. If you leave the mansion without making it, no impossible pending objective is shown.

The T1 material inventory was audited using the current catalog in GZDoom. Leather is the
bottleneck, not the presence of the five gems. Quantities and limits are in SYSTEMS.md.
Neither the Bull loot nor the drawer authorized for the gauntlets is increased; no new
recipes are granted. Armor/Seal recipe distribution was still missing at that milestone.
0ad resolves armor choice and 0ae adds Seal teaching/allowances.

The three WADs, sounds, models and textures maintain their 0v hashes. Those who have
already left can continue in MAP02; to test this expansion a pre-crossing save is used. An
artificial return to the mansion is not opened.

### 4.33.0v changes included and approved by the author: exit and return to body

**Base:** complete 0u folder, with all tests approved by the author. The sword without
ghost shield, the contextual defense of Rulo and the previous blocks are preserved. 0v
implements MAP01 closure: phases 90 -> 95 -> 100.

After capturing El Loco, the exit responds at the back of the Bull room, on the ground
floor. Missions > Detail (F), Palomo, Ronnie and Rulo guide towards it. Only the Box
carrier, with card and completed tests, can activate it. The notice lists what is
preserved and allows to say "No. Not yet" unchanged. An outstanding manufacture requires
completion or cancellation personally.

Confirm starts a short saveable transition. At the end, the first weapon is saved by its
ItemId within the same Box; it retains type, size, essence and condition. The other
physical objects, including those stored, are removed. Tarot, recipes, character and
current resources are maintained; when removing equipment only the applicable maximums are enforced. The catalog of additional equipment by class and special values on awakening are
still undefined: no additional pieces or a free cure are granted.

The mission is completed before the native trip. MAP02 presents a short arrival to the
sewers, with a dry platform, central channel, footbridges and the Voice that warns the
protagonist. Inventory allows to recover and equip the weapon. It does not yet include the
complete route, encounters or exit of sewers. MAP01 does not have a normal return path
since this arrival.

The above test field is conserved as CADEV02, with the same TEXTMAP and its 16.508 things.
Its diagnostic filters now use that name. MAP01.wad remains identical to 0u: the
controller removes the provisional Exit and presents the door when starting or loading.
This avoids invalidating the saves by changing the map checksum. V5 programming
architecture is not reorganized.

The Tarot collection retains the +2% fractional El Loco bonus, on the twelve attributes and
without accumulation when loading. Recipes and objects still have a unique authoritative
source; neither the Box nor the weapon is duplicated when retrying. The current crossing is single-player: other players present are informed and the global transfer is not
initiated. The cooperative exit is left on the roadmap.

The approved 0n base includes:

- The 38 stations retain their instances: corners in bedrooms and a row of twelve against
  the wall of the bottom of the second floor. Doors and stations reject activations from
  another level or without a line of vision.
- Tab closes Crafts, also during a task; G filters. Close pauses the task.
- Bow and long bow teach ten arrows per lot and its components, using native crafting and
  inventory. They do not consume the place of the first weapon.
- Five veins of gemstones at the bottom of the cave. The drawer retains only T1 leather.
  The historical supply of 96 kg M for gauntlets to 25% is replaced in 0ad by the quota of
  the chosen equipment at 100%.
- Bull placed behind the silver door and Argento as guardian of the key. Delivery requires
  preparations with all four: Rulo practices precede the Bull. The leather budget for 0n
  recipes is replaced by the mass-based yield of 0q.
- Palomo runs visibly through fifteen waypoints, opens the necessary free doors and climbs up
  both stairs to the second floor room. It does not teleport or disappear; it continues
  from its current point when loading.
- Neutral shared display on the marked wall and updated resource dialogues. Caella 0m staff return is retained.

Repair, food/water, Air/movement, load and pool breathing are implemented as
optional practices. Bolts and their knowledge are approved in 0ac. Choice of armor and
quotas to 100% approved in 0ad. 0ae adds Seal recipes/allowances. Composition and
recipe of bullets and water collection/treatment remain; they do not block accepted
branches.

The MAP01 WAD, audio, models, garden and accepted poses are preserved. Stations continue
to offer T2 infrastructure; that scope does not require supplying T2. Format:
new/modified files to copy, plus a TXT test. The accepted 0h migration is preserved;
V5 will rearrange the programming code.

## Permanent premises

1. Code, identifiers, README, and all documentation in English. Explanatory
   comments inside code remain in Spanish, so the author and Spanish-speaking
   collaborators understand the intent of each block. Modified tooling uses
   English comments, docstrings, help and diagnostics.
2. Prefer stable native GZDoom 4.14.2 functions. Keep a single authoritative
   source for data and a shared architecture between weapons and actors.
3. The final product must be independent: do not distribute Doom assets.
   Preserve provenance, attribution, and modifications for owned or external
   resources. Development dependencies do not equal authorization to distribute.
4. Do not invent balance values, recipes, story, or pending decisions. The
   author's design and later corrections set those data.
5. Protect what is already accepted and validate only what a revision affects.
   Distinguish static analysis, an isolated engine test, and author acceptance.
6. GitHub is the primary working source: one issue defines one patch, implemented
   on a focused branch and delivered through a linked PR. Several focused commits
   may implement that issue. ZIPs are optional exports, not the source of truth.
   Do not distribute development IWADs, executables or test fixtures.
7. **Consolidated documentation updated in every patch.** `README.md` is the
   general entry point and is reviewed with each delivery. Keep these five
   `docs/` files; integrate new topics into their chapters before creating
   another file. A new permanent document is justified only if the author
   requires it.
8. Every delivery updates version, real status, decisions, next steps, and test
   results in the same change. Use numeric MAJOR.MINOR.PATCH releases, with an
   optional lowercase letter suffix where the author specifies one:
   4.36.0i -> 4.36.1 -> 4.36.1b -> 4.36.2 -> 4.36.3. Intermediate commits and later
   acceptance of the same patch do not increment its version. Keep historical
   labels unchanged. The larger-version roadmap remains in force. Do not duplicate
   state between a per-patch README and thematic reports. Keep temporary export
   instructions out of current installation guidance; preserve older ones in history.
9. Preserve history and unique content. Before retiring a document, integrate
   its current information and preserve the original. Do not silently delete
   local files or keep obsolete requirements as current instructions.
10. **Folders with a clear responsibility.** Before removing files, check
    consumers and provenance. Keep useful sources in assets, package only src,
    and back up known retirements. Keep outstanding author tests in the single
    root `pending_test.txt`, with confirmed results in `docs/HISTORY.md`.
    V5.0 reorganizes code through small changes
    with save compatibility.
11. Every change must be traceable to an issue or task.
12. No agent deletes files without explicit authorization.
13. Generators must be deterministic (same input, same byte-for-byte output).
14. One model per task. Routine tasks → economical model (DeepSeek).
    Architecture, narrative, or complex review → advanced model
    (ChatGPT Pro). Document in AGENTS.md which model is expected for each
    task type.
15. Saves always migratable. No change may invalidate an existing save
    without explicit, tested, and reversible migration. Schema changes
    carry a revision number and idempotent migration logic.
16. Data outside logic. Balance values, recipes, coordinates, names, and
    texts live in data or documents, never hardcoded in logic. If an agent
    needs a number that is not in the documents, it must ask, not invent it.
17. One change, one reason. Each commit or PR addresses a single purpose.
    Visual changes, balance changes, and code changes are not mixed, so
    that only what failed can be reverted.
18. Cross-verification between AIs. When possible, one AI reviews another's
    work. DeepSeek reviews ChatGPT's code; ChatGPT reviews DeepSeek's
    design. Reduces errors without the author having to review every line.
19. Documentation is the contract. If code and documentation differ, the
    documentation prevails until updated. An agent that finds a discrepancy
    must report it, not silently "fix" the code to match.
20. Issues are the unit of work. Every significant change (code, balance,
    document, map) originates in an issue describing the problem or
    objective, reference documents, explicit scope, and acceptance criteria.
    A PR without a linked issue is not reviewed.

## Document map

| File | Responsibility |
| --- | --- |
| [README.md](../README.md) | English entry, installation and summary status. |
| [PROJECT.md](PROJECT.md) | Premises, status, plan and current validation. |
| [SYSTEMS.md](SYSTEMS.md) | Rules, controls, crafting, economy, Box and dialogues. |
| [MAP01.txt](MAP01.txt) | History and full specification, preceded by the scope implemented. |
| [ASSETS.md](ASSETS.md) | Audio, art, first person and attribution references. |
| [HISTORY.md](HISTORY.md) | Registration of previous decisions and documents. |

The `src/licenses/` redistributive notices remain next to the assets. They are not
administrative duplicates and the reorganization does not eliminate them.


## Immediate Roadmap: Close systems and tests on MAP01

Each block ends with focused testing and acceptance by the author before expanding the
next one. The numbering of intermediate corrections depends on what these tests yield;
they are not delivery times.

| Order | Block | Remaining scope / closure criterion |
| --- | --- | --- |
| 0 | Base to 4.33.0n | All tests approved by the author the 2026-09-11. 0h migration is preserved. |
| 1 | 4.33.0o: removal of the external manual | Delivered; author asked to continue with Rulo. Keep cleaning and recipes learned. |
| 2 | 4.33.0p–0r: Rulo/Bull | 0q remaining tests approved. 0r corrects post-combat dialogue and protects residents; expresses leadership and innate strength. All 0r tests approved by the author. |
| 3 | 4.33.0s: Palomo final, phase 80 | Final Dialogue and Single Box. All tests approved by the author. |
| 4 | 4.33.0t: El Loco in the cave, phase 90 | Capture, collection and fractional +2% implemented; remaining tests approved by the author. Your two observations are corrected in 0u. |
| 5 | 4.33.0u: real shield and Rulo guide | All evidence approved by the author. |
| 6 | **4.33.0v: exit and return to body, phase 100** | Implemented: confirmation, weapon by ItemId in the Box, final cleaning and narrative arrival. Approved by the author as part of the cumulative 0w. Current retained resources; additional equipment and special values require further definition. |
| 7 | **4.33.0w: optional maintenance and audit T1** | Real repair of the first weapon with Ronnie, saveable and without a new mission lock. Materials audited; quantities in SYSTEMS.md. Approved by the author. |
| 8 | Remaining Extensions of the Tutorial | Food/water, Air/movement and 0aa load, 0ab breathing and 0ac bolts approved. Choice/recipes armor and quotas 100% 0ad approved. Teaching/allowances 0ae seals approved by the author. 0af incorporates containers and drinking collection; the rest was approved and 0ag tests also. 0ai restores Resilience for Sleep and applies Constitution to the expense of regenerating health/Air, preserving the divisors and critical thresholds of 0ah; all 0ai tests approved. composition/process bullets and non-potable water treatment remain. It is not promised to manufacture all sets nor to do so to 25%. Do not block accepted branches. |
| 8a | Authorized balance 0aa | Minor Arcana passives, sweeping heavy weapons and 4 type dividers approved by the author. |
| 8b | Audit of attributes 0ai — postponed by author | Maintain the current attributes. For a future review, specify reload/cooldown by Eloquence (munition today with Dexterity; 60 s fixed channel) and jump scale; complete duration of states by Constitution, debuffs/buffs scope, Empathy cures, overall mitigation of needs by Patience, academic tasks and hidden senses of Insight. Include Box by Intelligence and cost of Anima by Eloquence in the current table. The actual status in SYSTEMS.md is documented; these pending effects do not block 0aj nor the passage to V4.34. |
| 8c | 4.33.0aj: optional mission base | Offers, requirement between assignments, acceptance, limited progress, permanent endings and unique native reward per mission. Two expressly activated diagnostic orders, selection/Detail and abandonment confirmed in Journal. Approved by the author: delivery of rewards, lock after abandonment and failure to leave before goal. |
| 8d | 4.33.0ak–0am: seal corrections, capture and Journal | Infrastructure protected/restored. The 0al log identifies the inactive conversation reference; 0am corrects its lock and tab changes at the boundaries. Page Up/Page Down preserved. Approved by the author in 0am. |
| 8d.1 | 4.33.0an: reputation and conditions | Reusable dialogue, access and trade conditions implemented, with optional test accessible from Reputation. All tests approved by the author. Relationships, ranges and narrative assignments remain uninvented. |
| 8e | 4.33.0ao: integration closure | Combined save 0an, capture and exit narrative to tested MAP02; resumption of active conversations when loading, explicit report and updated roadmap. Author authorizes to continue with 4.34.0a. Bullets, water treatment and other legacy pending work pass to V5; no further repetition of all 0ao tests is presupposed. |
| 8f | 4.34.0a: locations and connections | Journal of the world, places visited and registration of the existing return MAP01 → MAP02; previous saves and preservation when traveling. First patch of 4.34, approved by the author. |
| 8g | 4.34.0b: doors and accesses by group | Native requirements of all door leaves, independent groups without id, passage occupancy and reopening during closing. Optional test with own key and previous saves. Approved by the author. |
| 8h | 4.34.0c: Sewers connected | MAP02 links with MAP03–05 for future massive testing, Tarot and environment. Six directions, native hub, stairs, Journal and saves; no return to MAP01. |
| 9 | Map construction and sewers | The 2026-09-23 author update requires a complete three-map V4 playtest slice (#10–#21); remaining campaign expansion stays in V5. Existing port/coast and sewer test spaces are reusable foundations, not completed campaign maps. Preserve map IDs and implement the confirmed mansion/maze/port route, including the port siege. |

The author-only truth and future revelations must not leak into the opening NPCs' knowledge.
MAP01.txt contains the full specification and corrections that prevail over its first
version.

## General roadmap by version

This is the sequence already planned, reconciled with what has been implemented. The original records are still complete in HISTORY.md. “Basis implemented” does not mean that
all the content of that system are finished.

The #17 / 4.36.28 export was accepted before the subsequent Tarot/Trucazo work.
The author now designates #82 / 4.37.24 as the closing integrated export.
V5 follows this limited V4 scope; the historical archive remains unchanged. All
inherited and cross-system pending work explicitly moves to V5, except for the
three-map playtest slice explicitly authorized above on 2026-09-23. No 4.38 block is added,
and completing the entire campaign is not required to export the playtest.

The current authorization allows to continue from the 4.33.0ao technical closure to
4.34.0a; it is not recorded as a new claim that the author has repeated all 0ao tests.
Each patch keeps its checks focused. The bases included in 4.34–4.37 retain its scope: its
content extensions and the pending previous versions are returned to V5.

| Milestone | Status and work to be done |
| --- | --- |
| V4.27: combat controls | Implemented native routes: Fire/AltFire, Context Reload, Zoom Block/ADS/sweep and User1–4. Pending matrix per family transferred to V5; keep what is accepted. |
| V4.28: Seals Channel | Current effects independent of weather accepted in 0bp. Climate-dependent extensions pass to V5; do not reopen closed effects. |
| V4.29–V4.31: crafting and equipment cycle | Basis of recipes, reserves, lots, independent efficiencies, repair and disassembly accepted. Narrative distribution of knowledge, rewards/sheets/shops/discoveries and efficiency bonuses without authorized values pass to V5. |
| V4.31: resources, loot and containers | Physical sources and caches are based; in V5, complete loot tables by plant/animal/monster, contents/capacity/ownership/theft/replenishment containers and systematic acquisition of materials. Persistent expansion of biomes goes in V5. |
| V4.32: NPC, trade and first person | Use/USDF, transactions, coins and Box accepted. Later canonical merchant, store content and first person of the other weapons with own art pass to V5. |
| V4.33: missions, reputation and factions | MAP01, assignment base and reusable conditions approved up to 0an. 0ao checks the final integration and recovers the menu from active conversations when loading. Broad narrative chains and rewards, composite conditions, ranges and concrete relationships pass to V5; the six canonical ids define the narrative factions, while ranks and relationships remain pending. |
| V4.34: world architecture and travel | 0a–0c approved: catalog, Journal, return, group doors and connected sewers. 0d implements caravans and shared registry; 0e adds test stations and supplies. The author now approves all 0e tests, including seals/crafting blocking and recovery of Use. MAP01 does not support return. Timetables, durations and events are integrated with the 4.35 clock. Code refactor is still in V5.0. |
| V4.35: calendar, weather and events | 0a–0g approved: clock/calendar, Limbo, rest, furniture/camera, sleeping bag and comfort. 0g implements safe acceleration, tables/seated meals and sleep Lucidity. 0h adds digestion, repeated servings and MAP01 furniture/workshops; native tests performed. 0i–0j correct access/Use, adjust stations/meals and establish Limbo 1:1; 0j and 0k approved by the author. 0l corrects chairs/water and adds regional SMN weather and geometric shelter. 0m scales food by mass, confirms Buenos Aires and adds author-approved port/coast test maps. 0n adds measured travel with provisions; 0o integrates the monthly agenda and persistent author-defined events. 0n/0o approved except for observations resolved in 0p, which adds reservations, Q and coastal vehicles. 0p and 0q approved; visual pack v4 and 1/3 eating rate accepted. 4.35 closed. Body thermal model in V5.1. |
| V4.36: mobile environment and physical hazards | The 0i weight formula, maze, tables, saves and bow art are accepted; #8 is corrected and author-accepted; #9 retains the flail correction. Author-requested #10–#15 add the T1 four-section sewer, rats, prisoner escorts/port rewards and Tarot artwork; #18–#21 supply siege assets, breakable actor gates, rams and cannons (historical catapult task CA-436-04). Rams now have native #20 evidence (4.36.16), with CA-43612-RAM-01 author acceptance confirmed on 2026-09-26; cannon operation now has #21 evidence (4.36.17), with CA-43613-CATAPULT-01 author acceptance confirmed on 2026-09-27. Per the author's #8 clarification, the existing ceiling/elevator cover moving sectors; avalanches are deferred until additional maps and damaging surfaces until temperature effects, so those three are not release blockers. Validate integration/save/reset before extracting Impact Physics; neither assets nor a closed issue substitutes for acceptance. |
| V4.37: Tarot and Trucazo | Implemented and feature-accepted: physical 78-card deck, three campaign essences with selection/activation, and a complete NPC Trucazo slice. #82 / 4.37.24 owns final integration and export. Remaining acquisition, Major powers, broader awakening and team/network modes stay in V5. |
| **V4 test export** | #17 / 4.36.28 is accepted historical evidence. #82 / 4.37.24 exports the current integrated MAP01 -> MAP02 -> MAP06 slice with initial controls and final validation. It does not claim full campaign or standalone completion. |
| **V5.0: modular code architecture** | The bounded #116–#120 series is implemented: player services/adapters, authoritative inventory and Tarot operations, explicit per-player contracts and integrated native validation. #119/#120 author acceptance passed on 2026-10-06. Compatible inputs/selectors/save adapters remain; further F1–F4 coordination/performance/network work is separate and full multiplayer is not claimed. |
| V5.1: thermal exposure and HUD | Author-approved 2026-10-07 rules and initial coefficients are specified in [#130](https://github.com/damiancurti/Caelum-Argenteum/issues/130): racial comfort, proportional Toughness resistance, heat/cold penalties, wetness, insulation, activity, magic and distinct clocks. [#131](https://github.com/damiancurti/Caelum-Argenteum/issues/131) adds the thermal bar directly above the load bar. #130 / 5.1.0 is implemented and author-accepted on 2026-10-07; #131 / 5.1.1 is implemented and fully author-accepted on 2026-10-07. The thermal contract records the implemented integration and remaining calibration limits. |
| V5.7: resources and biomes | Persistent 3D sources, melee extraction slashing/piercing, toughness/rarity/depth/region/skill, exhaustion and regeneration. Marine biomes, algae/iodine and non-potable waters; stores maintain access to remote materials. Detailed sequencing is below. |

### Numbered V5 delivery sequence — author request 2026-10-07

Planning task: CA-V5-SEQUENCE. The author requests approximate version numbers
for all remaining V5 roadmap areas, ordered by dependencies. These are minor
version targets, not GitHub issue numbers, deadlines or a promise that each block
fits into one patch. Each block may contain multiple focused issues and numeric
patches. Only the separately requested thermal HUD issue is opened in this
roadmap update; the other future areas remain planning entries.

V5.0's bounded architecture work is accepted; #121 diagnosis and #128 normal
high-density AI extend that accepted line through 5.0.6. Its fluency target and
full multiplayer remain unproven, not retroactively completed. V5.1 retains its
existing position. Preserve accepted work and historical numbering.

| Target | Delivery block | Scope and dependency order |
| --- | --- | --- |
| **V5.0** | Architecture and initial measured performance | Accepted #116–#120 services/authority, #121 diagnosis and #128 production high-density coordination. Remaining F1–F4 work is assigned below, not silently added as a new V5.0 closure gate. |
| **V5.1** | Thermal exposure and its HUD | #130 thermal systems and #131 exposure bar directly above load. Includes the approved weather/equipment/wetness/heat model and explicit integration checkpoints. |
| **V5.2** | Character identity, native menus and accessibility | Unified race/sex/appearance/profession setup, compatible native options/preview, remappable grouped controls, UI/messages/crosshair scaling and camera/weapon comfort. Reuse accepted creation descriptions and single saved identity. |
| **V5.3** | Local exploration, automap and Journal access | Discovered geometry/POIs/manual markers, readable local cartography, known objectives, separate world-travel view, and consistent Journal/Inventory/Keys-Documents access. Preserve existing quest filters and secrecy; later content consumes these interfaces. |
| **V5.4** | Attributes, racial/class abilities and Seals | Audit implemented versus planned attribute effects, complete authored User1/User4 powers, and climate-dependent Seal extensions on V5.1. Retain the approved input mapping and ask for still-missing ability/balance decisions. |
| **V5.5** | Combat integration and physical interactions | Remaining weapon-family matrix, combat dispatch portion of F2, impacts/contacts/thrust/crushing/anatomy, bullet composition and defined material interactions. Thermal/damaging-surface integration builds on V5.1; future melee-energy rules require authored numbers. Avalanches require suitable maps. |
| **V5.6** | Crafting, economy, loot and ownership | Remaining crafting/task and merchant/session coordination (F1), recipe acquisition/learning/bonuses, authored shops, loot tables, containers/capacity/ownership/theft/replenishment and resource acquisition rules. Preserve accepted inventory transaction authority. Add models for equippable, craftable and tradeable clothing. |
| **V5.7** | Resource sources, water and biomes | Persistent 3D land/marine resources, extraction/rarity/depth/region/skill, exhaustion/regeneration, algae/iodine and water potability/treatment. Uses V5.5 interactions and V5.6 economy; no automatic authorization of missing harvest values. |
| **V5.8** | Survival, world persistence and travel | Camps/properties/shelters/rest quality, remaining oxygen/altitude rules, connected water volumes, calendar compensation for unloaded areas, vehicle types/routes/schedules and travel encounters/storms/failures. Builds on thermal/resource foundations and exposes later narrative/siege hooks. Expand usable furniture, storage and home/shelter furnishings, preserving accepted seating, meals and rest. Decorative furniture may accompany its map. |
| **V5.9** | Quests, social dialogue, factions and secrecy | Authored main/side chains, rewards/failure/abandonment/composite conditions, reputation ranks/relationships, private emotions and faction outcomes; narrative-transition portion of F2. Reuse Strife-derived dialogue/transactions and V5.3 Journal instead of a second quest system. Expand third-map Barracas al Sud (runtime MAP06) social/story content: captain recognition, rescued prisoners, rumors, siege preparation and aftermath conversations, preserving secrecy/canon. Add character sprite models and NPC clothing for inhabitants, professions and factions using V5.2 modular identity and reusable animations. |
| **V5.10** | Perception and stealth | Visual/acoustic sensing, detection/loss/reacquisition/memory, noise and shared communication. Establish authored parameters before broader group and siege behavior. |
| **V5.11** | Groups, companions and measured mass-AI work | Formations/leaders/offsets/dynamic membership/shared memory, NPC companions and measured targeting/movement/contact/controller/renderer work (F3). Preserve #128's accepted policy; retain staged active-population evidence and avoid claiming passive spawns prove active AI performance. Measure individual NPC subsystem costs in comparable active siege scenarios; evaluate dispensable simulation work, including thermal simulation (a candidate, not a proven bottleneck). Compare full, reduced-frequency and simplified thermal models. Diagnostic disabling does not authorize permanent removal or changes to fire/cold responses or demon behavior. Record performance and gameplay consequences; preserve individual combat/resources/collision unless explicitly changed by the author. |
| **V5.12** | Persistent profiles and cooperative/PvP foundation | Native saves plus external profiles, narrative autosaves and shared-world/session authority (F4); authored clock/progress/reward policy and real multi-client join/leave/reconnect/respawn/transfer tests for the 2–8-player target. Network ownership contracts must inform earlier modules even before this dedicated delivery. |
| **V5.13** | Remaining Tarot powers and awakening | Remaining authored Major powers, collection/acquisition hooks and essence-weapon awakening; reuse accepted deck, Minor passives and activation. Campaign placement continues in V5.16 rather than claiming all 78 acquisitions already exist. |
| **V5.14** | Expanded Trucazo and network teams | Remaining Major modifiers, Magic Senses, wagers/consequences and casual/ranked/team modes up to 4v4, on Tarot and multiplayer authority. Preserve the accepted NPC slice. |
| **V5.15** | Dynamic sieges and world consequences | Battle director, reinforcements/tactics/commanders, machines/barricades/sabotage, alternative routes and permanent city/faction/travel consequences. Depends on physics, calendar/world, quests/factions and group AI; network behavior uses V5.12 contracts. |
| **V5.16** | Campaign and world expansion | Authored chapters, maps, encounters, memories/revelations and complete card-acquisition content toward the existing 78-card/at-least-78-map target. Integrate geographic/biome/travel/faction systems without rewriting canon or making that target a condition for every earlier playtest. |
| **V5.17** | Art, audio and presentation completion | Sprite-to-model character migration with interchangeable weapon, shield, armor, hair and face modules, using the accepted #283 prototype as a reference. Remaining first-person views, map/character/effect assets, regional/hour/weather emitters, typography/icons/credits and replacement of temporary stock resources. Assets required by earlier blocks are delivered with those blocks; this is the completion pass, not a ban on earlier art work. Complete and polish furniture, character sprite and NPC clothing models introduced in V5.6/V5.8/V5.9; initial assets accompany their corresponding content. |
| **V5.18** | Independent distribution and release validation | Complete removal of distributable Doom dependencies, provenance/licenses/own packaging, clean installation/startup and integrated campaign/save/game-mode checks. Version numbering alone does not certify standalone readiness or complete content. |

### Modular 3D character migration - author handoff from #283

On 2026-10-15 the author completed the Domingo prototype and assigned the actual
sprite-to-model conversion to the later presentation roadmap. This is future
work under V5.17, not a new current issue or a claim of completed conversion.

- On 2026-10-21 the author deferred #387's worn/equipped, character-preview and
  first-person clothing appearance until these 3D character models are available.
  Carry the 25 approved garments and body/sex/species/size coverage into this
  stage, with fit/animation, save continuity, native rendering measurements and
  separate author visual review. Existing inventory/crafting and dropped sprites
  are accepted and remain in use. This deferral is not completed model work.
- Models must be modular: interchangeable weapon, shield, armor, hair and face,
  with compatible attachment landmarks and reusable rigs/animations. Native
  equipment and saved appearance remain authoritative; changing presentation
  cannot grant items or alter attributes. Do not bake all combinations into
  complete character meshes.
- Reuse #283's editable sources and measured evidence, retaining original sprites
  and resource provenance. Complete unsupported appearances/actions and finer
  proportions/materials during the migration, with focused author review.
- Carry forward unimplemented chair sit/stand transitions (2 seconds each),
  floor/bed lie/get-up (3 seconds each), and eating/drinking cycles (4 seconds).
  Lock movement, attacks and blocking during those animations; damage interrupts
  immediately and restores normal combat rules. Keep progressive provision rates
  and quantities unchanged. Existing candidate transition clips are not finished
  gameplay implementations.
- Preserve the accepted hand-held shield, ten-tic jump preparation and 35-tic
  landing. Jump keeps normal movement/attack/block controls, survives key release
  and cancels on damage/incapacity. Keep native collision, jump cost and furniture
  authority, versioned/idempotent save migration, deterministic exports and
  representative rendering/combat tests before broader conversion.

Cross-cutting work (save migration, bilingual UI, performance checks, required
assets and ownership contracts) accompanies every relevant block. A prerequisite
slice may be implemented earlier through a focused issue without moving an entire
milestone or reopening accepted releases. Unapproved balance/canon remains an
author decision; this numbering assigns sequence, not new mechanics.

Author additions and clarification (2026-10-14, #276): furniture, character
sprites, NPC clothing, third-map social/story content and the NPC subsystem
audit are integrated in their version rows above. All blocks retain their
existing order and importance; no V5.11 work is advanced into V5.3.x. Dynamic
siege expansion remains V5.15. These are planning targets, not completed
features or a beta-readiness claim; implementation follows focused issues.

### V5 native menus, character setup and exploration — approved 2026-10-05

Planning task: CA-V5-NATIVE-UI. The author approved this scope for version 5
on 2026-10-05, explicitly requesting a roadmap update only and no GitHub
issues while 4.37 is being closed. This is planned work, not an implemented
feature or a new 4.37 release/blocker. Preserve the V5.0 architecture and
V5.1 thermal milestones. Under the 2026-10-07 sequence, character/menu work is
V5.2, exploration/Journal access V5.3, broader social dialogue V5.9 and narrative
autosaves/shared persistence V5.12; implementation issues and patch numbers follow
when each bounded task is authorized.

- **Unified character creation:** make the game's creator authoritative for
  race, sex/gender and profession. Integrate compatible native appearance,
  clothing/accessory colors, player sounds and a character preview using
  authored resources. Native PlayerClass is an engine player type, not an
  automatic equivalent of the game's combined profession. Hide or reconcile
  redundant stock selectors. Global preferences may initialize a new character;
  loading a save must restore that character without overwriting identity from
  global settings. Limit in-game editing to permitted cosmetic changes.
- **Local exploration automap:** reuse native discovery, zoom, pan, follow,
  rotation, overlay and numbered marks. Add discovered beds, stations,
  merchants, exits and transport, plus mission locations only after discovery
  or information from an NPC. Named/category marks and conditional icons need
  project integration. Use a nineteenth-century paper/cartographic style,
  readable symbols, location name and integrated game time/current objective.
  Keep local exploration separate from the world travel map. Check overlapping
  floors in the mansion; do not assume a ready-made floor selector.
- **Map-specific presentation:** mansion rooms/stations without exposing its
  secret room; explored sewer routes and reminders of locked grates; fortified
  Barracas al Sud's four exits, towers and services. Siege-sector warnings
  require authored event integration. Do not automatically reveal undiscovered
  enemies, chests, keys or secrets. Ability/card/NPC-based discovery is a future
  extension whose exact rules and powers still require authored definitions.
- **Strife-derived dialogue and Journal integration:** extend existing Use/USDF,
  transactions, quest conditions and Journal rather than introducing a second
  implementation. Reuse native response/item checks, rewards, actions, voice
  and readable text; connect attribute/reputation/progress conditions through
  the shared game systems. Adapt relevant mission/inventory/key-screen controls
  into clear Journal, Inventory and Keys/Documents access. Preserve existing
  main/side and active/completed filters and clues; extend history and tracking
  as needed. Native menu options alone do not supply a complete quest journal.
- **Controls, readability and comfort:** group remappable interaction, block,
  Tarot, class ability, Journal, inventory and automap controls; make the custom
  interface respect relevant UI/message scaling and crosshair size/color/
  visibility preferences. Expose appropriate camera/weapon-motion settings
  and respect them in custom animations. Retain native save/load screens and
  integrate narrative autosaves with progression under the existing saving plan.
- **Implementation and acceptance boundaries:** first audit actual GZDoom
  4.14.2 support and current project integrations. Distinguish native settings
  from custom logic and missing art/sound assets. Prioritize character identity
  consistency, then automap/Journal usability. Preserve accepted systems,
  bilingual UI and save compatibility; verify persistence across save/load and
  hub travel and multiplayer authority when the relevant mode is implemented.
  This roadmap edit needs no new author gameplay test and claims no runtime
  validation.

### Inherited and cross-cutting work: V5, after export

Except for the narrowly authorized three-map playtest slice above, commitments
in this table remain assigned to V5 by decision of the author. They also pass
to V5 the pending combat matrix, learning and recipe bonuses,
loot/containers/ownership, merchant and later stores, remaining first person,
quests/factions enlargement, postponing attributes audit, bullet composition and
water treatment. Their minor-version targets are now assigned in the 2026-10-07 sequence above;
focused patch numbers and missing balance values remain unassigned.

When an area shares name with 4.34–4.37, V4 completes its intended base and V5 develops
the following broad scope. The code architecture is reorganized into V5.0; the thermal
exposure maintains V5.1. The exported test is an earlier milestone, other than completing
the independent distribution.

| Target | Area (V5) | Planned scope and current boundaries |
| --- | --- | --- |
| V5.16 | Campaign and World | Target: 78 cards (22 Major and 56 Minor Arcana) and at least 78 maps; geography inspired by Argentina, coasts/Antarctica/deep sea, aerial cities and supernatural regions. Chapters, encounters, political outcomes and revelations follow canon. The first release remains focused on MAP01. |
| V5.9 | Quests | Main/side, requirements, objectives, chains/dependencies, failure and abandonment; item/money/reputation/unlock rewards The record has 32 slots and eight objectives per mission; 0aj adds offer and abandonment to the four original states, with unique requirements and rewards. The broad content, composite conditions and other types of rewards require development. Majors for main quests, Minors for side quests; assignments/events/rumors/contracts are not automatically another card. Do not introduce combat XP: Canonic progression depends on the Tarot. |
| V5.9 | Factions and secrecy | Unitarians, Federals, Free Peoples, Caelith, Cult of the Tarot and Sun Warriors. Seven ranks of reputation, changing relationships and consequences in prices, access, missions, hostility and sieges; membership/secrecy of Cult as future content. |
| V5.9 | Social dialogue | Reputation applied to rolls and thresholds, private emotions, combat/events interruption and conversations with multiple NPCs in sequence. MAP01 only uses the approved values for your tutorial; do not assign new factions or difficulties by default. |
| V5.8 | Travel | Carriage, ship, archaic submarine, aircraft, magic ship and portals; encounters, attacks, storms and mechanical failures. Global time, locations, routes and permanent changes of the world are dependencies. |
| V5.1 / V5.8 | Survival and rest | Action Rest with food/drink and time advance; camps/properties/shelters, recovery and quality of rest. Integrate thermal exposure; oxygen limits, height, water and future breathing capabilities according to cards. |
| V5.7 / V5.8 | Water and simulation off-map | Extend potability markers to marine/contaminated waters; network of volumes to different levels is technical capacity not yet built. Define resources/weather/events compensation when returning to unloaded maps by global calendar. |
| V5.10 | Perception and stealth | PerceptionCore, visual/acoustic sensors, stealth, detection/loss/reacquisition/memory and shared communication. The diagnosis of groups/perception is not the final AI; solve fields of vision, angular formulas, states/times, action/surface/cadence noise and stealth drift before assigning values. |
| V5.11 | Groups and companions | Playable formations, dynamic belonging, movement leaders, local offsets, distance sleep and shared memory. NPC fill-ins for incomplete party: accompanying/fighting without deciding dialogues. The diagnostic group baseline of 16 does not impose fixed size on visual formations. |
| V5.11 (cross-cutting) | Massive AI and performance | Maintain perception/targets step budget and space filters; resolve shared locomotion, contacts and step-by-step 1.875 testing → 3.750 → 7.500 → 15.000 active according to the latest approved gate. Load 15.000 passive actors does not test 15.000 fully active AIs. |
| V5.15 | Sieges | Director of battle, reinforcements, tactics, commanders, allies, machines/artillery/barricades, sabotage and alternative routes; time limit and permanent consequences on cities, routes and factions. It depends on AI, physics, world and stable calendar. |
| V5.5 | Physics | Complete multiple impacts/contacts validation, sustained thrust, crushing and anatomy/armor. Future melee impact physics requires speed, effective mass, area/edge, defined material, penetration and technique; do not replace accepted combat without that design. |
| V5.4 | Abilities | Racial User1 and class User4 effects were defined on 2026-09-14 and recorded in SYSTEMS.md; Arcanist Sleep implemented in 0g, the rest pending. The Pilgrim uses Amparo (50% less environmental damage), not Bless Food. User2 retains Seals; User3 retains Tarot. Do not invent powers or values to fill existing hooks. |
| V5.13 | Tarot | Persistent collection/global percentage and all Minor passives remain. #80 adds up to three selected essences, shared User3 activation, Fool flight and doubled fixed Minor bonuses under the authored 1000-Anima/60-second/600-second rule. Remaining Major powers, acquisition of the other cards and essence-weapon awakening need authored content and later issues. |
| V5.14 | Trucazo | Truco with Tarot: Major modifiers, playable Minors/rows, Envido/Truco/Retruco/Vale 4, damage and health, Magic Senses, bets and consequences; casual/ranked and teams from 1v1 to 4v4. Implement layered after Tarot base rules and multiplayer authority. |
| V5.12 | Cooperative and PvP | Target 2–8 players, host authority, ownership/validation/synchronization, shared missions and world, travel, connection/disconnection and peers. Current individual persistence does not credit these modes. |
| V5.12 (cross-cutting) | Saving |  Keep native save and traveling Inventory. Independent external profile, narrative autosaves and world-shared state remain pending; test compatibility before removing V5 adapters. |
| V5.2 / V5.3 / V5.17 | Art, audio and interface | Remaining first-person views, visual content of maps, effects/emitters by region/hour/weather and adaptation of stock assets to scenes. Store accepted typography, icons and rigs; update inventory and credits with each resource. |
| V5.18 | Independent distribution | Replace any final art/audio/fonts/maps dependency from Doom, complete attributions and own packaging, validate startup/saves/maps and game modes. The IWAD development does not enter patches. |

### Decisions that still require author design

Complete balance of cards, racial/class abilities, economy and resources; tables/rules
harvesting and loot; container content and ownership; definitive sources of
recipes/components; final sensors and stealth; regional climate, encounters and
consequences of factions; future thermal calibration refinements and melee-physics values. #130 is
implemented and accepted; thermal rules and initial coefficients were approved on
2026-10-07; do not treat that approved table as undecided. Historical documents
contain proposals: they are checked before implementation. The progress already accepted
is not reopened.

## 4.33.0h Folder Audit

Baseline: full ZIP provided by the author, 16.626 entries. CRC, routes, inventory and
consumers were verified. Cleaning uses an explicit list with SHA-256 per file; “does not
appear as text” is not enough to remove a sprite, source, model or resource that the engine resolves by convention.

| Folder / entry | Baseline files | Decision and resource rationale |
| --- | ---: | --- |
| Root | 4 | Updated README; build_dev.ps1 becomes the only Windows builder; run_dev points to it; the project configuration is retained. validate_project.py moves here. |
| docs | 5 | Keep the five canonical documents, integrate roadmap/audit and correct the actual status of 0g. |
| tools | 74 | Remove the active folder: keep builder/validator in root and three generators in assets. The other 69 files are utilities for previous revisions or redundant builders, preserved in backup. |
| art_source | 20 | Transfer all originals and records to assets/source/art with the same fingerprints. |
| assets | 13 | Store 05 source and package atlas with README/checksums; add source art and generators. Do not pack in runtime. |
| src | 4.276 | Maintain useful resources and modules; only audio and credit corrections are applied, plus the tab observer. Code architecture is reorganized into V5. |
| build | 1 | Regenerable PK3: rebuild it when applying. Preserved until atomic replacement is completed; do not accumulate 77 MB copies as source files. |
| archive | 1 | Keep 0g back-up and add a single verified backup prior to 0h. Historical records have recovery utility. |
| Git history | 11.803 | Keep it whole: it contains version history, not temporary delivery files. |

Detail of all immediate src directories, before the patch:

| Src input | Files | Proven utility/decision |
| --- | ---: | --- |
| Root lumps | 13 | ZSCRIPT, MAPINFO, SNDINFO, menus, USDF, native texts and records: preserve and adjust audio references. |
| caelum | 59 | Gameplay and UI modules linked from ZSCRIPT; add a UI observer, without splitting/relocating existing modules. |
| impactphysics | 1 | Physical core included by ZSCRIPT; store. |
| crafting | 1 | Catalogue of recipes loaded by the system; preserve. |
| maps | 3 | MAP01 invariable; MAP02 narrative arrival and field of evidence preserved as CADEV02 from 0v. |
| graphics | 556 | UI, icons/textures and graphics registrations; keep engine content and conventions. |
| hires | 1 | High resolution graphic resource of the project; preserve. |
| sprites | 1.129 | actors/weapons States and model base sprites; preserve, including necessary transparent markers. |
| models | 155 | Geometry/textures/models linked by MODELDEF; store. |
| fonts | 2.280 | Glyphs and typographical sets; their resolution is native, not a textual reference by character. |
| sounds | 72 | Used audio and registered reservation; replace only the derivative phrase. |
| music | 2 | MAP01/MAP02's own music; preserve. |
| licenses | 5 | Necessary redistribution notices, other than administrative documentation; update the modification of the harp and routes of the visual generators. |

No additional unambiguous temporary trash was found within src. Resources reserved for
future content are not declared useless. The installer manifest specifies each
removal/relocation; unknown local files are preserved. An audited file that changed from the
ZIP stops the application before writing and is reported with its path.

## Historical implementation and maintenance — 4.33.0ao

The following describes the original delivery. Current installation and
updates follow the repository workflow in [README](../README.md).

With GZDoom closed, copy src, docs and README.md over the full 0an folder and accept
replacements. Combine folders; do not replace src with a folder containing only the delta.
Start run_dev.bat to rebuild and play. ZIP only contains new/modified and
PRUEBAS_4_33_0ao.txt files.

Existing build_dev.ps1 and run_dev.bat are preserved: they build the game, they do not
install patches. 0h migration accepted and engine/IWAD paths of the author are maintained.
No more applicators are delivered or executed per version. TXT testing is next to the ZIP;
its results are integrated into these five documents.

## 4.33.0ae Validation

162 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 62 in Spanish, 62 in
English, 16 when updating an authentic 0ad save and 22 when reloading a paused Seal task. Only
new checks after each reload are counted, without adding the save counters back through the
scenes.

Use and choice in native USDF conversations: reading, rejection, acceptance, guides,
teaching before choosing weapon and consultation after completing Ronnie. The five recipes
and dependencies are learned without free items; recipes from other families are not
granted. The sum of quotas retains weapon, armor and ammunition. Real sources emit the
remaining amount and do not reissue when they exhaust it. For each seal, their quota to
100% matches the leaves reserved by the native manufacturing plan, without mandatory Box.

The five elements were manufactured and equipped one by one in the single slot. Detail
reached 5/5. The native beginning of Channel was verified with a crafted Seal, real
expense of Adrenaline and cooldown. The entire matrix of elementary effects previously
accepted was not revalidated. Pause, cancellation, resumption and save kept materials,
quotas and single output. Then the first crossbow and ten bolts could be made with their
preserved materials.

The old save was created with 0ad sources, then superimposing 0ae on the same route. It
includes first weapon, medium helmet, pending torso task, issued leather, completed lessons and a
player-owned Seal prepared at the scene. Learn recognizes that seal and only adds the
quota of the remaining four; it does not discount its cost from the previous counter
again. The old task retains time and 10.000 reserved units. Even if the view changes to
seals, it still gives the correct torso. The four missing seals are completed and the
loan/return of the sword uses the real pages of the Ronnie workshop, with repair
already done.

Visual review of the Caella guide and the Fire Seal tree in 819×614 screenshots: text, icon,
materials, infrastructure and readable controls.

The validator checks five documents, 74 audios, 12 station models and 24 Spanish Caella
keys, without errors; the new 13 keys have English and Spanish. The delta contains 14
modified files and the new TXT. CRC and overlap are verified against the entire tree used
by the engine; maps, art, models, music, sounds and assets retain their 0ad bytes.

Private scenes prepare stages, attributes, materials, and equipment, and advance time with
the existing diagnostic helper. They do not replace the complete path, real-time
manufacturing wait, or the author's test on Windows. 0ad is approved by the author; 0ae
is pending such acceptance.

## Validation of 4.33.0ad — approved by the author

394 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 62 in Spanish, 62 in English, 217 in families/allowances, 15 when updating an authentic 0ac save and 38 when reloading a paused armor crafting task. Only new checks after reloading, not their saved counters,
are counted.

Native USDF talks: choice of weapon, reading of the four families, confirmation of armor,
drawer and workshops. The four pieces of each family were manufactured and equipped. The
weapon quotas were compared with the reserves of the native plan for the 36 options and
five sizes (180 cases); the leather of the set was contrasted with the four native masses
in the 20 family/size combinations. Crossbow, ten bolts and medium set consumed their
exact raw materials.

Limited extraction before exhausting the source or generating objects, shared allowance across shrubs, old stacks, partial collection of new/old stacks with a free
gram, drawer withdrawal/return and shared Bull/drawer allowance The repair practice reserved and
consumed the missing proportional to the damage; ordering it again did not add another
batch. Loan and return of the sword retain the first weapon.

The migration was tested by creating the save with authentic 0ac sources and superimposing
0ad on the same route. It retained recipes, first weapon, practices, El Loco and an arrow
task to the 25% with its reserves and time. It retained the previous 96 kg of leather
until voluntarily leaving the surplus in the drawer; it left the leather useful for the
armor and did not touch any reserved components. The old task produced only once its
ammunition before making armor. Pause, save, restart and cancellation of armor maintain
quotas and reserves.

Visual review of the Ronnie guide and the manufacturing tree in 819×614 captures: text and
readable controls. The validator checks five documents, 74 audios, 12 station models and
24 Spanish Caella keys, no errors. The delta contains 18 modified files and a new TXT; CRC
and overlay verified against the entire tree used by the engine. It does not change maps,
models, sprites, music or sounds.

The private scenes prepare stages, materials and attributes and advance time through the
existing diagnostic helper. They check the native process and its persistence; they do not
substitute a complete route or wait for real-time manufacturing. The author later
confirmed that all 0ad tests proved correct; that basis is approved to continue with 0ae.

## Validation of 4.33.0ac — approved by the author

129 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 47 in Spanish, 47 in English, 17 in reloading a pending task, 2 after saving its result, 9 in updating an arrow task
of 0ab and 7 in updating a save 0ab that was already in MAP02. Reloads count only new checks, without adding back the counter persisted by the scene.

Real choice of crossbow for the USDF pages of Ronnie, query of ammunition and detail in
both languages. Teaching of recipe and dependencies without objects for free. In the Real
Workbench lots of ten were tested to 25%, 50% and 100%, from components and from raw
materials, with consumption of plan leaves and personal output without Box. Reservations
prevent discarding materials; closing pauses, saving preserves time/reserves and canceling releases them without consumption. Insufficient materials, unknown recipe and insufficient stack capacity do not produce ammunition or consume materials. Limit test reduces the stack maximum only in the private scene; the value of the game does not change.

Native crossbow crafting, reloading and firing: one bolt is consumed and
CaelumBoltProjectile is created; the stack of arrows is preserved. The ammunition does not
accredit or replace the first weapon. The development trip to MAP02 retains recipes and
traveling equipment; it does not replace the narrative output, whose physical object
cleaning remains in force.

The old saves were created with authentic 0ab sources, then superimposed 0ac on the same
route. The 130 previous knowledge, stages, lessons, El Loco and the identity of the first
weapon were retained. The 130 recipe was incorporated both in MAP01 and in MAP02. The old
task remained of arrows, with intact reserves and time: even by selecting bolts after
loading, it produced ten arrows once. Repeating the teaching does not duplicate anything.

Private scenes prepare stages, materials and equipment; advance manufacturing time by
means of the existing diagnostic helper. They verify the native process and its
persistence, not the author's complete playthrough or real-time wait. Visual review to 1280×720:
Ronnie guide and bolt recipe with its icon, tree and readable stations. Validator
approved: five documents, 74 audios, twelve station models and 24 Spanish texts of Caella.

Maps and audio-visual resources retain 0ab bytes. The delta passes CRC and exact
reconstruction on that basis: fifteen modified files plus PRUEBAS_4_33_0ac.txt, without
executors, private scenes or PK3. The author confirmed that all 0ac tests were correct.

## Validation of 4.33.0ab — approved by the author

109 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 33 in Spanish, 33 in
English, 15 when reloading during immersion, 11 in return and 8 after completion; 9 in
updating an authentic 0aa save, practice, climb the ladder and travel to MAP02. Reload figures count only checks executed after loading, without adding again the counter that
saved the scene.

Ronnie was opened with Use and toured the real USDF pages. Reading and rejection do not
start; confirm record; Detail and dialogue use the result. The real pool credited
WaterLevel 3 and native expense. Wet without covering the head, run the diagnostic helper
in dry, exemptions without expense and fill Air through debugging did not complete. Less than
a second remains pending; partial return also did not complete. It was not confused with
recovery of Air while running. Reopening keeps the practice and travel retains the
lessons.

Old save created with 0aa sources before superimposing the delta on the same route: three
new false booleans, stages, equipment, lessons and 78 cards preserved. Practice was accepted,
immersion was recorded and steps were climbed through movement with native collisions to
x2190/z8, WaterLevel 0, without losing health. Recovery completed the practice. Private
scenes prepare stages, attributes and equipment to cover cases; they do not add content or
replace the author's manual journey with his character.

Visual review of 1280×720: the seven options of Ronnie and the instructions of the pool
are read complete. Dialogue and Detail texts tested in both languages. Validator approved:
five documents, 74 audios, twelve station models and 24 Spanish texts of Caella. The three
WADs and all audio resources retain 0aa bytes. The code review confirms that observers do
not modify costs, regeneration or mission requirements. The delta passes CRC and exact
reconstruction on 0aa: thirteen modified files and PRUEBAS_4_33_0ab.txt, without
executors, private scenes or PK3. The author confirmed that all tests of 0ab proved
correct.

## Validation of 4.33.0aa — approved by the author

1271 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 1259
rules/actions, 10 when updating a real 0z save and traveling, and 2 when reloading the
resulting 0aa save and returning to travel.

Scope: 78 cards individually over the twelve attributes, complete collection, base before
percentage, decimals, recalculation without accumulation and snapshots of the Journal.
Divisors with attribute 0, 0,3, 1, 10, 25, 50, 100 and 150; real damage of player/NPC
and preservation of the Pain/Lucidity curve. Native collisions were compared with its
subtractive expression; in addition, the bodies of ReceiveCaelumImpact in player and NPC
are identical to 0z.

Sweeping: four directions, damage equal to the primary under controlled critical and
precision conditions, triple single cost, recovery, insufficient air, solid obstacles and
3D floor, allies and range. Zoom states of the native selectors of the three weapons and
gauntlets were executed; maintaining the button does not repeat. A charged sweep consumes the charge and costs six uncharged primaries. Magic: real costs of the four implements,
T1/T2/T3, normal/charged and rejection by insufficient Anima at Eloquence 100. Own bases
are preserved.

The 0z save was generated with its authentic sources before overlaying the delta. It
preserved cards/equipment/stage/lessons and rebuilt attributes and a pending charged spell
that previously cost zero. It was saved with 0aa, reloaded and tested with real travel to
MAP02 without duplicating bases or losing the weapon. The scenes prepare cards and
equipment for these tests: they add no content to the delivered game. Visual review of the
Journal at 1280×720: full collection and a Minor Arcana without El Loco, with separate
base and percentage tables. Acquisition of the remaining cards is still planned, not
declared complete.

Validator of the approved project: five documents, 74 audio definitions, 12 station models
and 24 Spanish texts of Caella. The three maps and all audiovisual resources maintain 0z
bytes. The ZIP passes CRC and exact reconstruction of the delta on that basis; includes
only 16 modified files and PRUEBAS_4_33_0aa.txt. It does not contain executors, private
maps or PK3. The author confirmed that all tests of 0aa gave correct.

## 4.33.0z Validation

75 checks passed, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 25 in Spanish, 25 in
English, 13 when loading the pending practice, 5 when loading the completed practice and 7
when updating a real save generated with 0y sources. Ronnie was opened with Use, dialogue
traversed and native Inventory D/C actions performed on real objects. Checks covered
rejection of reserved material and an unowned Box, exclusion of consumables and the first
weapon, effective mass reduction, persistence and a real transition to MAP02. The scenes
prepare the stage and leftovers to check these paths; they do not replace the author's
playthrough. Load-value screenshot reviewed at 1280×720. Validator passed; all three WADs
and audiovisual resources retain their 0y bytes. ZIP passes CRC and exact delta
reconstruction over that baseline. 0z was integrated into the complete 0aa baseline whose
test the author approved.

## Validation of 4.33.0y — approved by the author

80 checks passed, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 27 in Spanish, 27 in
English, 15 when loading partial progress, 4 when loading the completed practice and 7
when updating a real save generated with 0x sources. The original Ronnie was opened with
Use and native dialogue traversed. Scenarios inject movement conditions and call the real
expenditure/recovery functions in accelerated cycles: they verify accounting, not the pace
of a manual walk. Checks covered exclusion of the energy drink, no movement and empty
reserves; recovery costs; partial and completed saves; real travel to MAP02 and
preservation of the first weapon. Spanish screenshot reviewed at 1280×720. All three WADs
and audiovisual resources are identical to 0x. Validator passed; ZIP CRC and delta
reconstruction checked. The author approved controls and manual playthrough on Windows for
0y. No new map or obstacle route is claimed as tested.

## Validation of 4.33.0x — approved by the author

108 checks passed, zero failures, in native GZDoom 4.14.2 Linux/Freedoom: 32 in Spanish,
32 in English, 17 from a partial save, 4 from a completed save, 15 for
capacity/retries/low states/refresh of the five consumables and 8 when loading a real save
generated with 0w sources. Native Inventory was used for consumption; the ten real seconds
of pulses were allowed to elapse. The MAP02 transition was native and preserved progress
and the first weapon. Dialogue screenshot reviewed at 1280×720. Isolated scenarios prepare
stages, load and reserves to exercise these conditions; they do not replace the author
tests on Windows.

The validator passes. All three WADs and all audio-visual resources are identical to the
approved base. The ZIP is checked by CRC and by exact reconstruction of modified files on
0w. All 0x tests were approved by the author.

## Validation of 4.33.0w — approved by the author

Stages focused on GZDoom 4.14.2 native, Linux/Freedoom. Stages are prepared, first weapon
with wear and components; items/tasks production are the real ones. Only time is
advanced by debugging function to not wait for the full cycle. The game rhythm is not
declared in Windows.

- Use opens to the original Ronnie. The optional question, steps, pauses and back answer
  are checked in English and Spanish. Detail recognizes the completion.
- Selection and unequipping using Native Inventory; selection persists in Crafts. The
  real network on the second floor opens with Use and reserves materials.
- Start, cancel and pause do not prove the practice. Cancel releases reserves without
  consuming materials; closing pauses the counter of the same task.
- Finish repair consumes materials and restores the same ItemId, without objects, recipes
  or stage changes added as a reward.
- Real saves with paused task and finished practice; continue from them and cross
  preserves the record and the first weapon. Compatibility from 0v.
- Audit of four sets of armor and five T1 seals, size M, with 25/50/100% in all layers.
  Vein capacities read from the map on the engine. These calculations do not simulate
  extraction time, previous decreases or used stock.

Results: 83 passed checks, zero failures: 27 in Spanish, 27 in English, 11 in loading the
paused task, 5 in loading the completed practice and 13 in compatibility from a 0v save.
Capture of the revised Spanish dialogue to 1280×720. Validator of the approved project;
nine new keys in both languages. The three maps and audio-visual resources retain their 0v
bytes. The package is verified by CRC and by rebuilding the cumulative on 0u. The author
confirmed the download, application and approval of all 0w changes.

## 4.33.0v Validation — Approved within Cumulative 0w

GZDoom 4.14.2 native, Linux, Freedoom 0.13, with isolated scenarios that prepare the
stages and inventories. The actual journey is verified; it is not simulated by changing
the name of the map nor is it claimed to have repeated the full tutorial.

- Confirmation and cancellation using native Use/USDF; pending manufacture,
  distance/height, property, no cleaning before completion of the transition.
- Real ChangeLevel: mission completed, same Box/ItemId/Owner, weapon saved with its
  condition, removal of personal and stored extras, Tarot and recipes. No ghost
  shield/layers or full replenishment of resources. Recovery and equipment of the weapon
  from native inventory after arrival.
- Saved during the transition and loaded to continue the same transfer; save after equipping in
  sewers and load without repeating the Voice.
- Saved generated with 0u source and loaded on the same path with 0v. The check detected
  incompatibility when modifying TEXTMAP; MAP01.wad was kept accurate and the modification
  was moved to the controller. The final version must keep that hash to support existing
  games.
- Presentation and localization Spanish/English; native screenshots of doors and sewers.
  TEXTMAP preserved diagnosis and references moved to CADEV02.

Final results: 89 passed checks, zero failures: 38 native-route checks, 22 transition-resumption checks, 2 arrival-load checks, 12 for 0u -> 0v migration and 15 safeguards. The serialized counter of a game includes previous checks; they are not counted again
    when loading. The original save was created with real 0u source. Safeguards also cover
    fallen piece, piece destroyed without gift repair, four magic families, Box/card/Rulo
    requirement and interruption.

CADEV02 opened in GZDoom with mass AI disabled to check the rename; the crowd performance
test was not repeated. Validator passed: five documents, 74 audio files, 12 station models
and references preserved. All 17 return keys occur once in each language. MAP01.wad
retains SHA-256 c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c. Record
correction: the author confirmed that the last version received was 0u. The cumulative
release was then delivered and the author approved all its changes, including 0v and 0w.

## Validation of 4.33.0u — approved by the author

- GZDoom 4.14.2 native, Linux, Freedoom 0.13: 42 equipment checks, zero failures. Loan
  without shield; repair of obsolete model; real shield, lock, unequipped, missing
  reference, two-handed sword, sword return, storage, breakage, repair, removal and
  residual layers; giant gauntlets retain their own defense. Real identities are
  maintained.
- Dodge and UI: 13 checks in Spanish and 13 in English, zero failures. Native side
  motion input, Zoom and twist. Move into another room or floor and turn the camera do not
  grant the mark. Walking sideways 48 MU in the room does grant and update the Journal.
  Use opens to the original Rulo; start, review and equivalences show the indication of
  the two-handed sword.
- A truly created save with 0t source and obsolete shield status is loaded with 0u on the
  same route: 9 checks, zero failures. Layers and ghost blocking disappear; the loan preserves Owner, ItemId and mission stage. Traveler log stores repaired status without creating
  another object.
- Reproduction limits: 0t clean start the loan did not give a shield. The symptom was
  reproduced by preparing the incoherent state in the engine; the concrete save was not
  received from the author. The correction also covers residual layers without active
  logical status.
- Visual review of the Journal and error-free compilation of the delivered code. Version
  and five synchronized documents, translations of both languages, existing resources and
  proven ZIP CRC. MAP01.wad does not change.

They are focused scenarios that prepare inventory and stages; not all the already accepted
tutorial is repeated. The author confirmed all 0u checks successfully; the output
expansion is implemented in 0v.

## 4.33.0t Validation — remaining tests approved by author

- GZDoom 4.14.2, native Linux execution with Freedoom 0.13 as IWAD test: 65 flow and
  conversation checks, zero failures. Use opens the real USDF; closing leaves the essence, an
  interrupted capture allows you to retry, the complete gives a card and changes 80 -> 90.
- The twelve attributes retain exactly ×1,02 base. Five consecutive recalculations do not
  accumulate the factor, no health is given, and the Box retains Owner/ItemId. Two Major
  plus one Minor give 5%; the 78 cards give 100%, no compound interest. These latter
  combinations are registry tests, no content obtained during the tutorial. After checking
  them, only El Loco is restored.
- Save during animation and load resume capture: 24 approved later checks. A completed
  save retains collection, stage, Box and attributes; visual inspection part of that save.
- Real migration from 0s source to 0t on the same route: 14 passed checks. The Box, 500
  units of stored material, total mass and first weapon (ItemId 2) are preserved. The
  integer attributes of 0s load as double without loss. The essence appears and can be
  captured without starting new game.
- The original five actors open their subsequent conversations using Native Use. Palomo's
  collection and storage questions are also covered; the pages show their correct
  localized texts.
- Inspection of the appearance in the cave and the Journal in Spanish to 1280×720 and in
  English to 1024×768. The card retains proportions in 16:9 and 4:3. Character shows
  decimals; Missions and F/Detail reflect capture.
- Validator: version/README and five synchronized docs; 74 audios, 12 station models,
  preserved Caella keys and 25 new keys in both languages. MAP01.wad identical to 0s,
  SHA256: c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

The scenarios prepare already approved stages and conditions, and place Palomo at its
destination to check the conversation. They do not replace a complete game or listening on the author's Windows system. The author approved the other tests of 0t; the ghost shield and
defense guide were addressed in 0u. The output and active powers are not tested as
implemented functions.

## Validation of 4.33.0s — approved by the author

These historical checks used the former 10 kg tare. Issue #229 changes the
current empty mass to 0.001 kg; the original measured results remain below.

- 130 passed checks, zero failures, in GZDoom 4.14.2: 61 for dialogue/reward/storage, 17 when reloading a 0s save and 26 for each 0r save variant (without Box and with previous property).
- Use and USDF natives cover the thirteen new pages: early visit, optional questions, go
  back, close before accepting, accepting, and reopening later. Each missing mission
  requirement rejects the reward; it is also refused to open from another floor or out of
  reach.
- Acceptance advances 75 to 80, grants a single instance with Owner/ItemId and adds 10 kg
  once. Repeated action retains identity, stage and weight. Storage and removal of a
  personal stack of 5 kg retains quantity, slots and weight reduction. Box does not
  consume a slot of its contents.
- Native saves are created with 0r sources and loaded with 0s sources at the same path.
  The original Palomo, first weapon (ItemId 1), its contents and stage are preserved. The
  Box receives ItemId 2 only once. In the already-owned variant, loading and accepting
  preserve the 12,2 kg load; in the unowned variant, delivery changes it from 6,2 to 16,2
  kg.
- Reloading the save 0s retains Box, content, owner and phase 80; Palomo opens
  post-delivery support. Capture and output remain unrewarded and the mission remains
  active.
- The project validator passes: version/README, five docs, 74 audio files, 12 station
  models and 24 key Caella in Spanish. New 27 keys have Spanish and English versions.
  MAP01.wad retains SHA256
  c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

The scenarios prepare the stages and place the original instance of Palomo in its
destination, with the route completed. Use, USDF pages, storage and saves do run on the
engine. The route of stairs already accepted is not repeated nor a complete game. The
author confirmed after that all tests of 0s were correct and authorized to continue with
0t.

## Validation of 4.33.0r — approved by the author

- GZDoom 4.14.2 reproduces 0q block: Argento and Caella preserve all their health, but
  INCOMBAT=1 fails StartConversation. Rulo/Ronnie respond.
- 57 protection/recovery/USDF checks: normal and forced lethal damage for all four, 1 health, zero death events, body/height repair without altering totals, eight openings
  with real use and Rulo closure from native menu to 75 phase.
- 32 checks when loading a native 0q save on the same game path: Argento locked by combat
  and Caella as a real corpse (-898840 health, CORPSE/KILLED). Both are repaired; four
  instances remain, with correct height, protection, eight openings/closings dialog and 75
  phase preserved.
- 32 checks when loading the 0r save after closing: protection, health, four residents, 75
  stage and opening/reopening of your dialogs.
- The project validator passes: README/version, five docs, 74 audio files, 12 station
  models and 24 Caella keys in Spanish. The delta changes only LANGUAGE,
  CaelumAnchoredResident and documentation. MAP01.wad maintains SHA256
  c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

They are controlled scenarios with preconditions of mission and prepared damage; Use, USDF
and saves do pass through the engine. They do not replace the user's playthrough nor a
visual inspection of the encounter. The author confirmed correct all the tests of 0r and
asked to continue with the next block. An actor already destroyed cannot be repaired from
a non-existent instance; base residents leave persistent bodies and the proven variant is
recovered.

## 4.33.0q Validation — remaining tests approved by author

- 146 passed checks in GZDoom 4.14.2: 36 of branch/retry, 37 of the group, 7 of
  USDF/Use and 66 of migration/saves.
- The four inflict native damage on the Bull; it attacks fellows and can leave them down.
  The retry restores the four and a loss caused by a companion credits victory to the
  player. Friendly fire is rejected.
- Use real: first-person Argento orientation, key delivery and return to Rulo within the
  enclosure. Captures inspected in Spanish.
- Native 0p save in combat: preserves Bull damage, practices, owned/borrowed ammunition,
  ItemId, drawer consumption and 38 stations; incorporates group.
- 0q Saved: retains a fallen ally and group references; allows you to retry, beat, close
  and reload with 12.500 leather units.
- Saved 0p completed: retains its previous leather and the four instances at home. Also
  tested is the precondition of victory pending without Bull.
- The tests use a private copy, prepared mission preconditions and damage/timers
  controlled for the limits; the participation test allows the AI to act and records real
  impacts. It does not replace the author's balance assessment or claim to have completed a
  normal game from start to finish.

Previous saves already completed retain the spoils they had produced: the new amount
applies to still pending wins, without removing own leather or filling the drawer. The WAD
maintains the same 0p footprint. The author approved the other 0q tests. The post-combat
opening with Argento and Caella was not covered: 0r reproduces and corrects that omission.

## 4.33.0p Validation — remaining tests approved by author

- GZDoom 4.14.2: full load, 36 branch/enclosure/retry checks; 116 checks with the 36
  initial options and native actions. The ammunition replacement is checked without
  spending your own reserve or curing.
- Real Use/USDF: start of Rulo, practice pages, Argento key and final return. Detail is
  verified with F and engine captures.
- Native 0n save: preserves stage, paused manufacturing, drawer expense and 38 stations.
  On that game the link to the new branch is tested.
- Saved in combat: retains damage to the Bull, six practices, owner of the match, ItemId
  and spent ammunition. Defeat and restart work after loading.
- Saved in phase 75: retains only own ammunition, initial weapon and a single amount of
  leather. Dissipated Bull does not reappear.
- The WAD retains SHA-256
  `c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c`. No engine, IWAD, PK3,
  saves or fixtures are redistributed.

The trials prepare preconditions and accelerate timers in private copies; validate
transitions and engine actions, do not replace the author's playthrough. The author
confirmed the rest of his tests; the three observations are dealt with in 0q. That block
left the epilogue pending; 0s–0v incorporate its closure. The final audit of the tutorial
continues on the roadmap.

## 4.33.0o Validation

- GZDoom 4.14.2 compiles and loads new MAP01 and a real 0n save without script or load
  errors. The already approved game matrix is not repeated.
- The WAD contains a single manual type 18106, in (-364,800,0); the save retains the same
  origin. Removal targets only to that specimen of the world, with an independent
  marker to migrate saves already prepared by 0n.
- WAD and other runtime files retain their contents; only change the MAP01 controller. README
  and all five documents remain in 0o version. ZIP checked against 0n: seven modified
  files and one TXT test.

Verification requested in 0o: disappearance of the external manual and preservation of
recipes. The author continued with Rulo and then approved the other evidence of the base;
the observations of 0u were already approved by the author.

## Validation of 4.33.0n — accepted on 2026-09-11

- Full Runtime on GZDoom 4.14.2: load error-free. 281 checks of the 38 stations, collision/height,
  doors, single drawer and five veins.
- 48 checks quantities per size, withdrawal/return and leather migration,
  recipes/crafting/cancellation arrows, real raw material consumption, first weapon,
  custody/transfer key and unique bull loot.
- Native entry: 11 checks. Tab closes Crafts without station and with it; G filters; Use
  opens workbench/drawer/Argento and answers change inventory. Revised drawer captures, arrow
  recipe, key and row of stations.
- Palomo runs both flights of stairs with real motion and collision, reaches (500,120,264)
  visible/solid and without teleport. The route took about 21 seconds in the trial
  without obstructions; the player can block it.
- Three tours of save/load, 138 checks: load 0m keeping Caella and residents; save a
  paused arrow task and to Palomo running; resume and complete both; transfer key, defeat
  Bull, save/load again. 128/129 recipes, ammunition, spent stock, key and loot persist.
  Do not duplicate the Bull or return the key to the custodian.
- All previous trials ended without failure. Recipe tests inject raw materials and advance
  the manufacturing clock; the key ones prepare the future Rulo flags. They do not credit
  that playable chapter.
- README and five documents consistent with 0n. WAD, 74 audio files, twelve station models
  and unchanged art. Exact Delta over 0m; additional TXT with application/tests. No test
  tools included.

The author confirmed all 0n tests successfully. The acceptance covers the scope
implemented; it does not make the remaining branches playable. Isolated trials use GZDoom
4.14.2/OpenGL with private instrumentation. They do not credit duration of a game or
cooperative. Engine, IWAD, fixtures, captures and saves are left out of patch; 0m
validation in HISTORY.md.
