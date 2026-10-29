# V5.8.32 / #410 - Luxury rest furniture acquisition

The luxury chair and bed now use ordinary Provisions/library supply, learned
fabrication, manufacturing restock and approved material-derived prices. They
reuse their existing physical bills and world models. Two original painted
inventory sprites follow SPRITE_ART_DIRECTION; sources and prompts are retained
in assets/art_source/rest_furniture_items, with exact byte-copy runtime exports.

The inventory token retains the actual furniture actor while packed. Placement
uses existing land/full-footprint/access validation. Pickup checks title, reach,
capacity and occupation; retrieval remains possible after a lease expires.
The parked actor has no collision, ticking or separate world exposure. The same
contamination state follows the body/token instead of resetting on placement.
No new comfort bonus or routine global actor scan is introduced.

## Evidence

Static validation reports zero errors. The selected native cases contain 107
executed PASS assertions and no failure, all on the immutable final32a runtime.
Both Spanish inventory captures were visually reviewed. Twelve runs
exercise catalogue stock/revision/restock, exact purchases and dirty buyback,
all three material reservations and efficiency levels, cancellation/completion,
Box/drop/pickup, blocked/clear actual-mansion placement, occupied/owner/capacity
protection, same-body movement, save/load, hub travel, the original reading save,
Spanish inventory/crafting icons and actual crouch + Use input.

The report counts literal executed PASS lines, not cumulative counters restored
from a saved handler. The final input-only run adds diagnostic methods without
changing runtime or earlier test methods. Full source/package equality, original
save identity, original map/art preservation and PNG source identity are checked
independently. Original-runtime rollback of the untouched 5.8.26 save is reused
explicitly from validation_5826/5829, not counted as new execution.

Early fixture corrections are retained in local probe logs: a copied test cast
a wardrobe to the rest-item subclass and dereferenced null; the replacement uses
the correct luxury chair. The mansion intro conversation also left the fixture
busy. The fixture closes that conversation without selecting a response and uses
the existing untimed Limbo furniture rest; production busy/safety rules remain.

Native runs use GZDoom 4.14.2, Windows 11, 1280x720 Vulkan, 5% audio, background
unpaused and a 60-FPS cap. These functional checks do not establish display FPS.
Multiplayer acceptance remains deferred to its dedicated version.

## Reproduction and pending author review

Run `python assets/validation_5832/prepare.py`, build with `build_dev.ps1`, then
`run_suite.ps1 -Runtime NAME -Prefix NEW`. The original reading-progress.zds from
the 5.8.26 worktree is required for the legacy case. `prepare.py --probe` is only
an iteration package; delivered evidence uses the official complete build.
Test saves/maps, the engine and the development IWAD are not game resources.

CA410-REST-ACQUISITION-01 remains pending author corroboration. Other furniture
and V5.8 scopes remain open. Manual handoff stays grouped until the complete
V5.8 implementation; neither native success nor a draft PR means acceptance.
