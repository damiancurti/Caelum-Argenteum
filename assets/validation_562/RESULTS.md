# Issue #381 validation — release 5.6.2

The final storage runtime passes **15 required native runs,
175 assertions and zero failures**, including a normal
package-only startup. **CA381-01 remains pending author acceptance.**

| Run | Runtime | Passing assertions |
| --- | --- | ---: |
| legacy-save-02 | baseline | 10 |
| release-suite | current | 51 |
| release-save | current | 2 |
| release-reload | current | 7 |
| release-travel | current | 30 |
| release-upgrade | current | 12 |
| release-upgraded-reload | current | 13 |
| release-reverse | current | 1 |
| release-reversed-rollback | baseline | 10 |
| original-rollback-01 | baseline | 10 |
| release-cardinal | current | 17 |
| release-cardinal-reload | current | 5 |
| release-supply | current | 5 |
| release-ui | current | 2 |
| release-smoke | current | 0 |

## Evidence and coverage

GZDoom 4.14.2, Windows 11, Vulkan, 1280x720; sequential native sessions, unpaused
background simulation and 5% master audio. Per-run JSON records CPU/GPU/driver,
engine/IWAD/package/addon hashes, command and configuration. No executable, IWAD,
fixture PK3 or save is distributed. The 5.5.8a baseline package is retained
locally with its original synthetic save. The issue-only package comparison
against 5.6.1 permits exactly fifteen changed/new members and no removal
(PhysicalHazards changes only its required release label);
all packaged bytes match source after newline normalization.

The 51-assertion suite covers authored capacity/dimensions/mass, exact equipment
identity/wear, no repeat deposit, recipient-dependent unclaimed equipment,
nonbinding preview/capacity failure, equipped/reserved/temporary/Tarot rejection,
individual water volume and duplicate-personal restrictions, manual learning,
arrow/bolt Box restrictions, partial stacks/provenance, slot and weight bounds,
missing quantities, stale rows/counts, wrong/closed session, unbound pawn, carried
mass/no nesting, placement, destruction and existing native lock state.
Two distinct requesting pawns claim the same entry sequentially by temporarily
rebinding one test PlayerInfo slot; the second authoritative request fails.
This is a local ownership check, not a network multiplayer test.

The actual 5.5.8a fixture contains an open/unlocked prototype and a partly emptied
maze chest with exact native remaining references. Upgrade/reload preserves
those states and repeats revision-1 initialization without reseeding. The revised
filled, carried chest saves/reloads with its storage session open. Equipment,
materials, exact load and nonzero TID survive TMAINT -> THAZARD -> TMAINT ->
MAP02 -> MAP01. A partial cardinal allocation survives MAP02 -> THAZARD ->
MAP02 and a separate reload without materializing retired equipment.
Five MAP01 checks preserve raw-material quota/prepayment and temporary cleanup.

For reversal, the fixture removes the new storage session, restores the prior
open state and saves the original chest/item classes. Actual 5.5.8a loads that
save and the untouched original save successfully. Added metadata is ignored
by the old runtime; this is not a promise that new carried-container classes
can be loaded with the old package. Keep the original save/package pair for
full rollback before adopting new content.

The English and Spanish screenshots were inspected after integrating storage
with CaelumLiveMenu. Keyboard, mouse rows/buttons and wheel share PanelKey/
network commands. Real focus/hold/release interaction remains CA381-01; image
inspection and scripted commands are not author acceptance.
Independent static AI review covered transfer safeguards and final menu routing.

## Exploratory findings

Failed logs are retained separately and excluded from passing counts. The first
travel probe had a fixture compile error, then confirmed native owner survival.
A nonzero TID later exposed a real map-local registration loss, corrected by
unregistering before travel and reinserting on arrival. Placement initially
tested sight against an intentionally invisible carried body; visibility is
now ignored while geometry is still checked. The first screenshot exposed a
missing native menu context, corrected before final UI inspection.

Other failures were fixture defects: small-tier assignment before storage
initialization, zero-weight equipment setup, nullable legacy catalogue slots,
and an initial changemap before the game had loaded. A short cardinal-reload
script ended without executing its assertion; the collector rejects empty
assertion runs and the longer corrected reload passes. Test additions changed
addon hashes; each run records its exact addon. Production source/package drift
is rejected, and only applicable final-package evidence enters the required set.
The retained pre-release-labels records preceded two required diagnostic version
label corrections. The release-* reruns are the final-package gates above.

## Reproduction and limits

Run `python assets/validation_562/prepare.py`, then
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_562/run_native.ps1`
with a fresh `-Label`, `-Checks`, and the desired `-Script` from prepare.py.
Use `-Runtime baseline -LegacyChecks` for actual 5.5.8a. LoadGame accepts a filename
relative to build/issue381; keep exact packages beside the synthetic saves.
`collect.py` validates/logs final gates; `validate_project.py` and normal packaging
are separate checks. Fixtures are synthetic, not ordinary campaign saves.

No new chest damage threshold, recipe, campaign placement, padlock/title/theft
rule or reward stock is approved here. Existing archived LegacyLoot is excluded
by its native reference; ordinary destruction is tested with acquired equipment,
not every historical archive variation. Native allocation exhaustion, full
network multiplayer, frame presentation/FPS and author acceptance are not claimed.
