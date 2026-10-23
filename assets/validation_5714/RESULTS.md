# #472 / 5.7.14 verification

Final production package: `a21611f8d57bcc0098a89193f68c019860c0c200a0e3b3861524e691dbcd8a49` (SHA-256), 16,806 entries,
byte-for-byte identical to src. Native target: GZDoom 4.14.2, Windows 11,
Ryzen 9 5950X, RTX 3070 Ti, Vulkan, 1280x720. Launch records retain engine/IWAD
hashes and private configuration: unpaused background operation, 5% audio,
60 FPS presentation limit. This is functional verification, not a performance benchmark.

## Final native checks

16 isolated final-package runs, 163 passing assertions, no failures.
Counts use PASS lines emitted during each run, excluding serialized seed counters.

| Case | Passing assertions |
| --- | ---: |
| basics | 18 |
| transactions | 48 |
| crafting | 30 |
| catalogue | 9 |
| recovery | 5 |
| transfer | 7 |
| keys | 6 |
| seed | 1 |
| resume | 5 |
| travel | 6 |
| old-load | 5 |
| visual0 | 5 |
| visual1 | 5 |
| visual2 | 5 |
| workshop | 1 |
| map | 7 |

Coverage includes all three masses/yerba amounts, water transfer and source
identity, temperature bounds and twenty uses, full-Thirst benefits, washed/cold
hydration, stale-source rejection, quick use, three crafting efficiencies,
missing stations, cancel/complete/duplicate guards, recipe migration, partial
catalogue retry, live purchase/sale/box/chest transfers, real ten-second recovery
and overlapping doses, held-discard keys, native save/load and cross-cluster travel.
MAP03 checks use authored merchants and actual ambient climate: exactly three
mates per type and ten recipe copies, without duplicate seeding.

Original 5.7.13 seed and rollback supply three additional passing assertions in
two baseline runs. The final package also loads that old save, retaining Chemistry,
support recipe knowledge, water and ingredients while adding locked mate recipes.
The preserved original save remains loadable with its original runtime.
Baseline package hash and preserved save hash are in report.json. Test PK3s,
saves, engine/IWAD binaries and private INIs remain generated local artifacts.

## Static and visual evidence

Project/dialogue/index validation and git diff whitespace checks pass. Two data/
art generator reruns preserve all 59 tracked outputs byte-for-byte (determinism.json).
Eight retained native captures cover the three preparation panels and inventories,
a world-model view and crafting preview. Inventory icons, fixed bronze bombillas,
materials, text and controls were visually inspected at native screen size.
World gallery objects are explicitly enlarged eightfold for inspection; production
scale follows the physical geometry. The private room supplies a controlled 20 C
initial environment; MAP03 separately exercises production climate.

The first compiler probe exposed case-insensitive local/member name shadowing in
the recovery queue. The corrected native build compiles cleanly. Early fixtures
also needed an explicit climate sample, the correct efficiency index, source
selection after inventory refresh and the native merchant mode. These failures
remain in build/issue472 and are excluded from the final counts. Production fixes
include dedicated mate stock seeding, individual used-item commerce, stale-source
rejection, inventory icons/layout and persistent recovery across cluster changes.
The failed cross-cluster run is retained in diagnostics for CA-KP-156; the final
travel run verifies the fix. A missing legacy add-on basename in an early load
probe was corrected by preserving the saved basename in the migrated fixture.

## Author handoff

CA472-01 is pending in the single pending_test.txt. author_terminal.ps1 offers
all three mates, a supplied crafting workshop, MAP03 commerce and the native suite.
No author acceptance is inferred from agent checks. #471 was accepted separately.
No cooperative multiplayer claim or unrelated system retest is made.
