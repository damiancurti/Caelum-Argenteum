# #410 prepared meal items ? 5.8.18

Four native 100-g meals have their approved nutrition, prices, spoilage,
contamination, painted sprites and distinct inventory identities. They work
through the journal, quick use, dining-table placement/withdrawal, ordinary
food service, calendar-wait prediction and journey consumption/commit.
Cooking stations, proofing and campaign acquisition remain unfinished #410 work.
No recipe is advertised as usable and no unapproved dish shop stock was added.

Final runtime: `build/issue410-cooking/current05/caelum_argenteum_dev.pk3`.
SHA256: `9a243426e2647b7573e593766a862004ccf3b7683254cfe07dbb028f5cc0cf2f`.
All 16,934 members match src exactly. Static validation: zero errors; current
localization/document indexes; CONTEXT 2,498 words. **291 literal newly executed
PASS / zero FAIL across 21 selected native runs**, plus four matched-control
nutrition comparisons. `report.json` lists package hashes and per-run counts;
serialized cumulative counters are not summed. **CA410-MEALS-01 passed
author corroboration on 2026-10-26**, including controls, painted sprites and
table interactions, without qualifications. The pending entry is retired;
no new native run is claimed for this acceptance-only update. Cooking, proofing
and campaign acquisition were outside this check and remain unfinished.

Coverage includes full 100-g doses at full Hunger, native Box rejection,
independent oldest/fresh lots, real coffer transfers, saved items/clocks, hub
absence ageing, mixed meal/ration journey consumption, unchanged water dosing,
independent waiting previews, exact journey commit, real journal activation,
real table placement/withdrawal and explicit visible Spawn aliases. The original
ration core/travel and raw ingredient core pass. A real prior-5.8.17 save is
loaded with the new package and again with its original package; no author save
is modified. This is forward migration plus reversible original-save rollback,
not a promise that an older executable can understand newly added meal classes.

## Native nutrition

At the fixture's 100 kg body mass, the matched no-food control loses 0.30048254
Hunger through unchanged survival/regeneration costs. After subtracting that
control, bread/beef/fish/puchero deliver 8.93333334 / 7.66666667 / 3.66666667 /
2.66666667 Hunger, matching the approved calorie formula within 0.000001.
Each native power expires after ten pulses. Seated timing uses the existing
shared Hunger power; this change does not add a new timing mechanism.

## Package/evidence applicability

Current01 exercised meal consumption and forecasts. Current02 added dining-table
integration and prevented the enlarged consumable enum from seeding unapproved
shop stock. Current03 added the actual journal icons. Current04 exposed an
invalid Name argument to GetDefaultByType; it is not a release candidate.
Current05 fixes the typed lookup and gives each table display a declared Spawn
state. The final native table-service assertions and visual capture use
current05. Earlier food/storage/forecast/save checks exercise unchanged final
code paths. The same inventory/gallery pixels from current03 apply to current05.

The exporter preserves all original generated sources and exact prompts. Its
--meals output repeats byte-for-byte and default ingredient exports are unchanged.
Native Spanish gallery/inventory/table captures were visually inspected. Table
sprites remain billboards at the existing native consumable scale; visual
acceptance is separate from successful quantity assertions. The private test
table suppresses automatic restocking and aliases the existing small-table model.

## Resolved findings and limits

- Initial private menu declared a nonexistent base; the correct base is the
  existing CaelumLiveMenu. Native F-key commands and journal routing are prepared.
- A persistence probe started at Hunger 50, triggering existing automatic food
  service and legitimately spending one puchero. Storage probes now start full.
- Hub return reacquires carried meals from the current player inventory; map-local
  test references to the previous player inventory are not authoritative.
- Carried/default Inventory Sprite values are 0. Copying them made the table
  artwork invisible despite valid quantities. Explicit FBRD/FRBF/FRFS/FPCH states
  resolve this; CA-KP-175 records the native diagnostic and visual regression.
- Failed probes remain in the private build directory. Selected raw logs/config
  metadata and captures are retained here; test PK3s, saves, engine and IWAD are
  not distributed. No new recurring global actor scan or food timer was added.
  Existing one-clock-per-stack scheduling remains unchanged. This slice does not
  establish campaign frame-presentation performance or complete unloaded climate
  simulation; the earlier measured boundaries still apply.

Remaining production work: attended oven/stove cooking, unattended one-batch
bread proofing and transfer, ingredient-age inheritance and reversible cooking
cancellation, recipe learning/acquisition, campfire food adapter and remaining
furniture. The author-approved recipe data is centralized, but data alone is
not reported as an implemented cooking action.
