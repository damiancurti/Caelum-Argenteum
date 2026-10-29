# V5.8.31 / #410 - Storage furniture acquisition evidence

Wardrobes and movable cupboards use normal Provisions/library transactions,
learned manufacturing, price margins and restock. Inventory activation places one
real storage owner under the existing full-footprint land/access checks. Later
transport uses the actual chest/cargo, preserving contents, locks, title and dirt.
The existing mansion kitchen cupboard remains fixed. Accepted models and painted
inventory sprites are reused without visual replacement.

The functional `final31a` package is checked in eleven serial native runs.
`report.json` records literal executed PASS lines, not cumulative counters loaded
from a saved handler. All final cases share the same runtime and diagnostic
addon. Visual review then found the legacy selection panel's fallback letter icon;
`final31b` changes only the two selection/crafting icon adapters. Its native Spanish
inventory/preview check was rerun, with separate cupboard and wardrobe captures.
The evidence set contains 107 executed PASS assertions across eleven selected
runs, with no failure; the superseded three-assertion inventory run is not counted.
Static validation and exact final source/package equality are checked separately.

Coverage includes three units per type, ten recipe copies, recipe-based restock,
no stock reset during migration, exact payment, two independent purchases,
contaminated resale/buyback, normal efficiency waste, reversible cancellation,
exact native crafting completion, multiple-item crafting, selected Box transfer,
native drop/pickup, failed and successful actual-mansion placement, full storage
limits, filled-container movement, save/load, hub travel and old-save migration.
Spanish inventory and merchant captures use actual UI rows and stock.

## Findings and qualifications

- `Actor.Spawn` defers `PostBeginPlay`: immediate placement initially tested the
  generic chest's 32-MU radius/60-MU height. The production transaction now applies
  the configured storage tier and physical dimensions before its first placement
  check, using idempotent initialization rather than invoking PostBeginPlay twice.
  See CA-KP-075 and the retained local probe05/probe06 evidence.
- The prior away-map fixture was a narrow corridor, not a flat room. Negative
  station coordinates were outside it; the acquisition checks now build a small
  isolated owned flat map. Actual placement still runs in unmodified MAP01.
- `ApplyCharacterProfile` restores the player's real carrying capacity after a
  transaction. Heavy diagnostic furniture requires reapplying the fixture's
  elevated capacity before a subsequent transaction; production limits are kept.
- The diagnostic bedroom has limited clear floor area. The completed first piece
  is packed through native cargo before testing the second. Both loaded furniture
  objects remain owned; the test does not delete contents to free room.
- One early fixture used a refused `GiveInventoryType` result without a null
  guard. Its replacement explicitly prepares the diagnostic food inventory before
  exercising the production transfer; the VM abort is not hidden as a pass.

The original 5.8.26 save remains byte-identical. Its prior original-runtime
rollback is reused from validation_5826/5829, not counted as new execution. New
recipe knowledge has revision 18 and appended IDs; merchant supply has revision 1.
No old learning, saved item, accepted map or artwork is replaced. The report
separately records any checkout-only LF/CRLF differences in original OBJ files.

No new recurring actor scan, price rule, resource bonus or storage limit is added.
This suite does not claim displayed FPS or multiplayer acceptance. All native
runs are unpaused background GZDoom 4.14.2 at 1280x720/Vulkan with 5% audio/60 cap.

## Reproduction and author status

Run `python assets/validation_5831/prepare.py`, build the complete runtime with
`build_dev.ps1`, and run `run_suite.ps1 -Runtime NAME -Prefix NEW`. Copy the
unchanged original `reading-progress.zds` from validation_5826's local work into
the diagnostic directory for the old-save case. `--probe` creates a temporary
source package for iteration; final evidence uses the official full build.
Saves, diagnostic maps, IWAD and executable are not packaged as game resources.

CA410-STORAGE-ACQUISITION-01 remains pending author corroboration. Other furniture
acquisition and V5.8 work remain unfinished. Manual handoff stays grouped until
the complete V5.8 implementation, as requested; no author acceptance is inferred.
