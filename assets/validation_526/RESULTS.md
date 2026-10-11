# 5.2.6 / issue #184 — mouse interaction validation

Author acceptance, 2026-10-11: CA184-01 passed without qualifications; the author
authorized PR190 merge/#184 closure. Delivery-time pending statements below
describe the original agent evidence, not the current author acceptance state.

Implementation: native MouseEvent handling for Truco/Trucazo and a shared,
transient press/release pointer for live crafting/time-skip panels. Controls
reuse existing UI/network action handlers; no recipe, reward or time rules change.

## Evidence levels

- Static: project validator, generated dialogue/localization/document indexes,
  production packaging and git diff --check. Exact command results are recorded
  below after the final checks.
- Isolated GZDoom 4.14.2: matrix runs in English at 1280x720 and 2560x1080,
  Spanish at 1024x768, and a final Spanish 1280x720 run. The fixture injects
  native Menu.MouseEvent or the production pointer dispatcher, then checks real
  gameplay state; these are engine tests, not physical-device emulation.
- Physical Windows mouse via the computer-use skill: Spanish 1280x720 crafting
  filter, size, efficiency, drag-to-tab cancellation, Back; time-skip field,
  increment, keyboard decrement, start/result/Back; Truco Flor, begin, card
  selection/play and forfeit/return. A single Play click did not also activate
  the Continue action that replaced it. These observations are separate from
  the automated matrix assertions. Trucazo physical-device usability remains in
  author check CA184-01; its native MouseEvent path is covered by the matrix.
- Author acceptance: pending CA184-01. No passed manual test is inferred.

## Native coverage

The matrix verifies orphan/double/stale/dragged releases; disabled hit regions;
real-to-virtual round trips for every enabled crafting control; panel-switch
capture reset; actual crafting and cancellation, repair, dismantling, processing
and component batches; time-skip field/value/forecast/cancel; both card games'
start/play/rules/forfeit/return; native pause in cards and live panel simulation.
Fixtures seed known recipes, boxed materials and a test character with attributes
at 100. Task completion is accelerated explicitly only in the fixture; real
reservation, output and transaction handlers run. No production rules are bypassed
by UI code. Native keyboard shortcuts remain available.

`lifecycle-02` verifies held turn/attack/use/movement do not act behind a panel,
open time-skip save/load discards an armed pointer but restores the cursor,
and closing both panels releases the native cursor request. The initial
`lifecycle-01` exposed held turn leakage, fixed by clearing yaw/pitch/roll before
PlayerThink. Its raw UserCmd assertion was replaced with actual position and
attack/use latches because UI sampling can observe the next unprocessed command.

The first physical fixture deliberately exercised the native full-Box rejection:
80 material types exceeded that character's capacity. The final fixture increases
attributes through the existing debug profile to provide 100 slots, then verifies
successful transactions. This is fixture setup, not a change to Box rules.

## Reproduction and provenance

Run `python assets/validation_526/prepare.py`, then `run_native.ps1 -Label NEW_LABEL
-Fixture native -Script matrix.cfg` (or lifecycle.cfg, with desired Language,
Width and Height). Use a unique label to preserve prior logs. The default engine
and IWAD paths are local development dependencies; neither is redistributed.
The fixture and packages stay outside src. `archive.py` preserves logs and hashes
in runs.json. Captures use resolution/language filenames.

Preparatory compile failures (reserved ZScript identifier, unsupported vector
array and UI/play scope call) and initial lifecycle failures remain in logs.
Only completed zero-failure matrix/lifecycle runs are passing evidence.
Interactive sessions were terminated after observations and are not represented
as completed automated runs. All launches use isolated configuration, live
background simulation and 5% audio; no keep-awake request was acquired.

The later #189 migration is separate: retain artwork, audit all interactive
screens and native ownership, and verify existing unpaused NPC dialogue with
mouse response selection. Truco and Trucazo must retain pause.

## Final results

- `matrix-final`: 116 native checks, zero failures; Spanish 1280x720.
- `matrix-43-es` and `matrix-wide-en`: 116 native checks each, zero failures;
  identical UI geometry at 1024x768 Spanish and 2560x1080 English.
- `lifecycle-final`: 14 native checks, zero failures on the final production
  source including current diagnostic release labels. Earlier aspect runs
  predate only the held-turn correction and final help text; those changes
  were covered by the final matrix/lifecycle runs and image inspection.
- `python validate_project.py`: version 5.2.6, zero errors.
- `python build_dialogue_index.py build` and `python build_document_index.py`:
  generated indexes current; production packaging freshness gate passed.
- `build_dev.ps1`: 6,343 files, zero directory entries, current MAP02/MAP06.
- `git diff --check`: passed (Git only reports expected LF normalization notices).

CA184-01 remains the only outstanding author test. #189 follows on a separate
focused branch/PR; no #184 merge or acceptance is implied by starting it.
