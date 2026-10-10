# 5.1.12 / #158 - Crafting equipment-size preservation

GZDoom 4.14.2, Windows 11, Vulkan. Native tests run sequentially, unpaused in
the background, at 5% audio. The temporary keep-awake request was released;
the Windows power plan was not changed. Author acceptance CA158-01 is pending.

## Diagnosis and result

The protected `materiales-palomo` checkpoint has the correct remaining stock
for its recorded XS/T1/100% staff and shield: 1,800 wood, 200 raw sapphire,
1,260 raw copper, 140 raw tin and 600 leather material units. Its menu size is M.
The baseline overwrites the shared equipment size when previewing Seals,
amulets or ammunition, so a later staff/shield incorrectly inherits M.

| Native run | Result | Scope |
| --- | --- | --- |
| baseline-final | 18 pass; 12 expected regression failures | Every non-M size loses its value through all three fixed-size families. M remains M. Both XS products are affordable after explicitly selecting XS. |
| regression-final | 30 pass; 0 fail | Five sizes across three fixed-size families; size-button no-op; unchanged raw stock on preview; actual staff/shield task reservations and output using only the original materials; unchanged issued allowance. |
| reload-final | 6 pass; 0 fail | Active Seal task with legacy M snapshot and current XL choice; canonical M jewelry mass/output; XL remains selected; actual display-size resolver. |
| completed-final | 1 pass; 0 fail | Completed save retains XL, both quest items and no active task. |

No save schema, recipe, allowance, output mass or balance changed. Existing
saves keep the size they contain; select XS once in this checkpoint. Do not
automatically reset every saved M to the character's size. The original and
two protected copies have identical SHA-256 after all runs. No saves, engine,
IWAD or test packages are distributed.

## Boundaries and reproducibility

`checks.zs` repositions only the copied pawn next to the existing upstairs
workbench and opens the production station. It teaches amulet/arrow recipes
for the preview matrix. Staff and shield use only the checkpoint's original
materials; their production reservation and completion methods run in-engine,
with completion called directly to skip the waiting duration. A subsequent,
separate Seal test seeds exactly its immediate inputs and saves an active task.
This is transaction/state evidence, not manual input or elapsed-duration testing.

The initial local `baseline-a` fixture correctly reproduced the size bug but
attempted transactions with the saved menu closed and away from the station.
Those transaction failures were fixture setup failures, not product defects;
the revised fixture opens the existing reachable station. Its complete baseline
and final logs are retained here. `candidate-a`/`reload-a` passed before the
release diagnostic strings changed; the retained final runs use the final build.

1. Keep a copy of the author checkpoint at
   `build/issue158/materiales-palomo-original.zds`, and the previous matching
   package at `build/issue158/baseline/caelum_argenteum_dev.pk3`.
2. Build current source and copy its package to
   `build/issue158/candidate/caelum_argenteum_dev.pk3`.
3. Run `python -X utf8 assets/validation_5112/prepare.py` to produce deterministic
   native add-ons and command scripts. Check that no GZDoom instance is open.
4. Use `run_native.ps1` with fresh labels and the package/add-on/load/script
   arguments recorded in each `*-run.json`. Run the regression, active reload
   and completed reload in that order. Supply local engine/IWAD paths as needed.
5. `finalize.py` validates retained-label runs, fixture determinism, package/source
   identity, original-save hashes and power release. Its original-save path is
   specific to this author's `save05.zds`; do not substitute an unrelated save.

`RESULTS.json` records package/source/checkpoint hashes and counts. Static project
validation and diff checks are recorded separately in `STATIC.json`.
