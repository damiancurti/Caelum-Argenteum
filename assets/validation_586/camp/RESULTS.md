# Camp acquisition evidence - #411 / 5.8.6

Camp acquisition continuation adds individually owned canvas tents and 20 L iron pots, learned fabrication recipes, Provisions/library catalogues, recipe-based replenishment, painted inventory icons and pot-specific cooling. Recipe schema 15 appends IDs 201/202; prior knowledge and stock migrate idempotently. Pot volume, contamination and temperature survive pickup, trade, Box/chest transfers, native saves and hub travel. Validation: 72 native PASS in 12 selected runs, 16,850 final package members verified byte-for-byte, original-save migration and rollback, clean static checks, and a native Spanish inventory capture. Housing remains accepted. Camp deployment, fire/cooking integration and author equipment/art acceptance remain pending; questions and manual tests are held until the author returns.

The unchanged accepted property package is retained in build/issue411/current.
The camp package lives in build/issue411-camp/current. Neither diagnostic maps,
engine, IWAD, private saves nor PK3 are distributed. Original save hash, exact
packages and per-run hardware/arguments are in report.json and native/.

Reproduce with prepare.py, build_dev.ps1 -Destination
build/issue411-camp/current/caelum_argenteum_dev.pk3, then run_native.ps1 with
-Checks and Script physics/items/craft/shop/transfer/save/load/hub. Load/hub
use -LoadGame ca411-camp.zds. Migration uses legacy-old.pk3 with the retained
property package, then legacy-bridge.pk3 with the camp package; rollback loads
the untouched original with the retained package and old addon.

Retained unsuccessful probes: compile02 exposed protected TryPickup access in
the private fixture, corrected to native CallTryPickup. craft03/craft04 correctly
rejected the fixture's oversized material load; tests now explicitly raise the
private test carrier capacity before each fabricated unit. No production carry
rule was relaxed. Selected later runs pass. No errors are suppressed.

The complete final package matches probe02 byte-for-byte except the added art
license notice. Final-native transfer07 and preview08 therefore supplement the
reused physics, crafting, save/hub and migration checks. The screenshot was
visually inspected; author approval remains outstanding. No frame-presentation,
frame-time-tail, FPS or complete deployed-camp acceptance is claimed.
