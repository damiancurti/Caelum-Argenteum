# #472 / 5.7.14 verification

Original functional package: `a21611f8d57bcc0098a89193f68c019860c0c200a0e3b3861524e691dbcd8a49` (SHA-256), 16,806 entries,
byte-for-byte identical to src. Native target: GZDoom 4.14.2, Windows 11,
Ryzen 9 5950X, RTX 3070 Ti, Vulkan, 1280x720. Launch records retain engine/IWAD
hashes and private configuration: unpaused background operation, 5% audio,
60 FPS presentation limit. This is functional verification, not a performance benchmark.

## Original functional native checks

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

On 2026-10-23 the author explicitly passed the functional tests and rejected the
mate artwork. CA472-01 now retains only visual acceptance. The old screenshots
remain evidence of that rejected appearance, not the current delivery.

## Historical sprite correction, 2026-10-23

Current complete package SHA-256:
`c20a786e6eb0f7aa318df3a76ff566fefe187a3b20830081d858913cee599686`.
All 16,806 entries match src. Only the three mate icons, their TEXTURES scale
and MODELDEF bindings change in production. No gameplay logic/data changed.
The original package remains locally preserved as pre-sprite-correction.

Five GZDoom 4.14.2 runs of this package pass **21 assertions**: visual0/1/2
(five each), workshop (one), and loading the existing pre-correction save
(five new PASS lines; the RESULT includes the serialized seed counter).
The same recorded Windows/Vulkan environment and background/audio rules apply.
Retained logs/launch records and eight inspected captures are in sprite-correction/.
The captures verify all preparation panels, all inventory selections, crafting,
world billboards and quick-use icons. The world gallery uses eightfold inspection
scale; the production height remains approximately 5.3 world units. The complete
package is essential: an overlay cannot unregister prior MODELDEF bindings.

The painted exporter and its compatibility entry point produce the same six
outputs and manifest on repeat. Generated alpha is retained. Project validation,
document-index freshness and whitespace checks pass. Historical references,
exact built-in image_gen prompts and asset hashes are under
assets/art_source/mate_sprites. Museum photos are not distributed.

The updated terminal adds option 7 for world sprite review. Options 2-4 inspect
each mate and option 6 shows crafting. Corrected artwork is **pending author
acceptance**. Original functional evidence is reused for unchanged mechanics;
no full suite, multiplayer or performance benchmark is claimed for this art edit.
