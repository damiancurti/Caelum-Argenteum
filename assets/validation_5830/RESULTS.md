# V5.8.30 / #410 - Luxury furniture catalogue evidence

Three original period-inspired models use the existing chair, bed and dining
systems. Luxury changes the construction and appearance, not recovery benefits.
The table owns eighteen real item slots and six matching chairs; it creates no
food or water. Its serving scale fits the narrower historical envelope without
changing inventory quantities or progressively shrinking refreshed displays.

The final immutable `final30c` runtime passed **96 executed native assertions**
across fourteen serial GZDoom 4.14.2 runs, with zero failures and zero static
validation errors. `report.json` records package/addon hashes and literal PASS
lines; restored cumulative handler counters are not counted twice. All final
assertions use the same package and unchanged diagnostic addon.

Coverage includes ordinary comfort, full player collision, blocked and clear
seating, five-minute chair/bed rest, native Use, eighteen real table slots,
six-seat layout, moving/rotating the assembly, exact food split/withdrawal and
water-container identity/volume, saved dirt, current save/load, hub return and
the unchanged original 5.8.26 partial-reading save. That save retains 321.75
seconds of reading and its existing mansion table; luxury furniture does not
replace accepted map furnishings. Its original-runtime rollback evidence is
reused from validation_5826/5829, not counted as a new execution here.

The ordinary dining table retains its layout and the initialized large-canteen
scale. Revision 1 initializes the new table's collision blocks idempotently.
No new recurring global actor scan is introduced: initialization touches at
most six blocks and six seats; steady ticks check the saved layout revision.
This suite makes no frame-presentation, display-FPS or multiplayer claim.

## Visual and source review

The close armchair/bed views, occupied chair/bed, full eighteen-plate table and
Spanish target title were captured from the final runtime and inspected. The
owned wood/metal/cloth textures and original geometry remain attributable under
`assets/art_source/luxury_furniture`. Museum references supply dimensional
envelopes and period context; no museum image or mesh was imported. Delegated
physical bills record polygonal solid volumes and separately rounded material
grams. Decorative details still await author visual corroboration.

The collector verifies every packaged file against `src`, preserves prior
map/art bytes except two existing sofa OBJ files whose checkout changed only
LF/CRLF line endings (identical geometry after newline normalization), repeats
the generator for byte-identical output, checks the old
save hash and rejects missing or failed native assertions. Early fixture-only
failures (reserved identifier, typed ternary, vector member expression,
unsupported one-minute rest and an unlinked blocker) remain local evidence.
The final fixture uses supported five-minute rest and a linked blocking actor.

## Reproduction and remaining work

Build the full runtime with `build_dev.ps1`, then run
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5830/run_suite.ps1 -Runtime NAME -Prefix NEW`.
Copy the unchanged `reading-progress.zds` recorded by validation_5826 into the
local diagnostic directory before the migration case. Saves, IWADs, executables
and diagnostic maps are not packaged with the game. `collect.py` targets the
recorded final30c/release evidence; use a new collector configuration when
recording a different final build, preserving these logs.

This is a catalogue stage. Campaign purchase/fabrication, portable inventory
sprites and broader furniture placement remain separate #410 integration work.
CA410-LUXURY-01 remains outstanding. The author requested the manual handoff only
after the complete V5.8 implementation; no new terminal is left open while away.
Neither #410 nor V5.8 is complete and no author acceptance is inferred.
