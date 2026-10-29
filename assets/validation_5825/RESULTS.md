# Garden water furniture -5.8.25 / #410

Fixed mansion fountain and cistern, with original iron meshes and painted icons.
Fountain200 L potable/+1 L per world minute; cistern1000 L, empty initially,
manual transfers and no automatic replenishment. Native container inventories
retain quantity, water-quality flags, temperature and owner identity.

The final package is final25c, SHA256
`57236c377f35ddee65aa7f66dc133daa64f7c47e6a2ee022a715cb3cb2f4200f`.
96 native assertions passed across 13 selected runs; static validation has zero
errors. All 16,978 packaged members match source, and 14,030 existing map/art
members remain byte-identical. Detailed per-run evidence is in report.json. Only selected successful native
runs are counted; result-counter totals serialized in saves are not added again.
No author acceptance is claimed; CA410-WATER-FURNITURE-01 remains pending.

Coverage: actual normal source lookup/refill and network inventory actions;
full/partial/empty transfer conservation; Box/ownership/reach/carry rejection;
all existing water-quality bits, dilution and temperature mixing; independent
household reserve; source-specific bathing and wait-forecast capacity/refill;
partial bath cancellation and rejection when a source becomes contaminated;
original household bathing regression; current save/load and hub absence;
old5.8.24 save migration and original-version rollback using the untouched save;
idempotent placement, all accepted bedroom beds/tables/bathrooms and clear access.

Visual inspection covers both native models, source hints and the actual Spanish
inventory controls. Shift+Use opens the bath selector directly; ordinary H still
retains its pre-existing context-sensitive boiling/bathing meaning. The three
water buttons share one row, leaving load/Box/currency/item information readable.
Only the applicable bottom action row is drawn, preventing the pre-existing
boiling controls from overprinting bath/clean labels. The private author fixture
supplies ordinary controls, bottle/pot, a1-L biologically contaminated salty
canteen,100g soap and contamination30. No F-key macros or author terminal were
opened while the author was away.

The generator was run twice with byte-identical manifest and output bytes.
Sources, prompt, physical inputs and hashes are retained in art_source/water_furniture.
The initial sites were rejected because the garden has sloped terrain; complete
native footprints now fit the selected flat positions. The early overlay harness
also attempted to include root ZSCRIPT twice; that diagnostic-only packaging was
corrected before delivery. Failed exploratory logs remain local and are not
counted as passing evidence. Delivery runs use the complete official package,
with a diagnostic-only addon and unchanged production mansion geometry.

The paired peaceful-garden measurement records renderer callback tails and a
700-tic simulation interval at1280x720 Vulkan,60 cap,5% audio,unpaused background.
Baseline/final callback P95 is 17.9366/17.9311 ms and P99 is
18.9998/19.1631 ms. The 700-tic interval is 19.9629/20.0586 seconds with
100-ms observation uncertainty. Callback cadence is not GPU/display presentation; PresentMon access was already
unavailable in this environment. No campaign60-FPS, sewer or siege performance
acceptance is inferred. Only two new source inventories use existing1Hz cooling;
initialization is revision-gated, and there is no new periodic global actor scan.

This focused patch does not complete #410 or V5.8. Remaining furniture variants,
stored-book desk access and fabrication/placement/acquisition retain their own
scope and pending definitions. No shop stock or unapproved station recipe was
invented. All older outstanding author checks remain in pending_test.txt.
