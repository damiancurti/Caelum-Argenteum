# V5.6.0 / #376 — crafting coordination

The stateless `CaelumCraftingCoordinator` receives the requesting pawn through
48 retained adapters. `EXTRACTION.json` proves all 653 pawn field declarations,
562 signatures, 514 unmoved bodies and every moved body/quoted literal remain
equivalent after removing only explicit pawn qualification. Inventory commits,
save snapshots, browser state ownership and lifecycle ordering remain unchanged.

## Native evidence

GZDoom 4.14.2 / Windows 11: **11 required runs, 305 new
PASS checks, zero FAIL**. `report.json` records commands, hashes, configuration,
hardware and raw logs. Tests run individually, unpaused in the background, with
5% audio. No keep-awake request is installed.

| Required run | New checks | Result |
| --- | ---: | --- |
| baseline-suite-04 | 91 | Pass |
| current-suite-final | 91 | Pass |
| baseline-save-01 | 9 | Pass |
| current-save-final | 9 | Pass |
| upgrade-final | 7 | Pass |
| current-reload-final | 7 | Pass |
| upgraded-reload-final | 7 | Pass |
| original-rollback-01 | 7 | Pass |
| revised-rollback-01 | 7 | Pass |
| baseline-travel-01 | 35 | Pass |
| current-travel-final | 35 | Pass |

The identical baseline/final suite covers nine recipe families, recursive
25/50/100% choices, utility items, preview/selection/knowledge invariance,
repeat start, pause/resume/combat/distance/death, explicit cancellation,
exact-target repair/dismantle, repeated completion, reserved-material drop,
unknown recipes, missing sessions/materials and final Box/load rejection.
All twelve printed family/layer plans have identical quantities and durations.
Existing recipes/data are the oracle; fixture stock values are synthetic.

Real native saves created with the original 5.5.8a package contain a partially
progressed, paused repair, same-type worn objects with distinct ItemIds, learned
recipes and reserved native material stacks. Upgrade, fresh/upgraded reload,
TMAINT→THAZARD→TMAINT→MAP02→MAP01 travel, original-pair rollback and an upgraded
save opened by the original package retain the asserted state. The original
and revised package/save copies stay under `build/issue376`; no user save is
overwritten and no schema migration is introduced.

## Package and performance boundary

Original runtime SHA-256: `24bd261b40fff56311815d4b203c4dee9b16f80b7dbc1f34960cdc759889ad8a`.
Final runtime SHA-256: `a048d86a8a4eb5a7daa42ebec830050523989f94f66436a7b82f9d0438746e73`.
One source is added; only the player adapters, ZSCRIPT include and two release
diagnostic strings otherwise differ after normalizing checkout CRLF.
Recipes, station implementation, inventory service and map bytes are unchanged.

The existing typed station graph scan is triggered by interaction and the
existing session validation cadence, with token/player cycle guards and the
shared time-skip guard. Its population is the current map's stations, with
cost proportional to reachable × total stations. The fixture adds twelve
stations and reports 100 native graph traversals in the raw logs. This is
inherited behavior, not an optimization or a measured dynamic-network maximum.
No presented-frame/FPS or broad performance-acceptance claim is made.

## Fixture corrections and evidence limits

Exploratory baseline-suite-01 failed compilation because its fixture reused a
retired longbow constant and old material field names; current native accessors
and the accepted longbow constant corrected the fixture. Baseline-suite-02
underfunded 25% recursive crafting with only 20,000 raw units, causing four
dependent failures. Only its synthetic raw-input setup was raised to 100,000.
Those logs remain recorded and are excluded from passing gate totals.
The final additional rejection checks do not change saved fixture field layout;
each run records the actual addon hash it used.

These are isolated checks, distinct from ordinary play and author confirmation.
Each family uses a representative recipe; efficiency cases use uniform settings,
not independently mixed layer settings. The death/session check sets health to
zero, rather than exercising an entire death/respawn cycle. An independent
review found no blocking source, ownership or lifecycle defect, independently
restored the full pawn token stream, and verified no local-name shadowing.
CA376-01 remains in `pending_test.txt`. No new recipe, balance, artwork, save
schema, full multiplayer support, merge or issue closure is claimed.

## Reproduction

Run `python assets/validation_560/extract_crafting.py` for source equivalence.
Run `python assets/validation_560/prepare.py` for deterministic addon/scripts,
then `run_native.ps1` with the recorded label/runtime/script/load arguments.
Use new labels to preserve evidence. `collect.py` rejects absent/failed gates
and mismatched baseline/final plans. Test fixtures and private packages are
never included in the production PK3.
