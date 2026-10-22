# 5.7.6 / #471 — Alchemy ingredient artwork

Visual stage only. Eleven matching RGBA icons and ten new original meshes;
the accepted iodine mesh is unchanged. Its icon/fallback binding is integrated.
Other assets are prepared for later gameplay data, with private gallery classes.
No new material ID, recipe, economy value, reserve, placement or save schema.

## Static evidence

`generation.json` verifies two byte-identical regenerations, all source/texture
hashes, distinct 128x128 icons, genuine transparent alpha, complete silhouettes,
OBJ face/vertex counts and unchanged iodine geometry. The generator uses Python
3.12 and Pillow 12.0.0 in an optional local environment. It renders the same
textured geometry with a depth buffer; it does not require an external art model.
`ingredient-sheet.png` is the reviewed contact sheet, excluded from runtime.

## Native evidence

Native review first revealed flat sector lighting on the new meshes; deterministic
per-face texture shading now preserves their volume. The real inventory previously
drew clothing icons only: material rows now use their existing authoritative icon
lookup at the same size and position. This presentation change alters no inventory
transaction. Automated gallery commands are chained in bounded scripts after an
overlong initial command line skipped the setup.
Native compilation also caught the actor's icon lookup being play-scoped;
the actor lookup and generated marine icon lookup are now `clearscope`, so UI
and gameplay share them without a duplicate icon table.

The author then reported `Trying to create zero size texture` after passing
setup assertions. This invalidated that run. The failure survived removal of
the gallery overlay, disappeared with models hidden and reproduced when the
isolated saltpeter model was first rendered. Its 182 `usemtl` runs created 182
OBJ surfaces. GZDoom 4.14.2 has a 32-entry surface-skin array, and its OBJ render
path indexes it without the bound used by its precache path. Grouping faces by
material reduces the new models to 8–20 surfaces without reducing geometry or
removing shading. Generation and static verification now reject more than 32.
See CA-KP-152 and `failure-diagnosis.json`; setup PASS lines alone are never
treated as a completed native test.

The standalone `prepare.py` generates a private gallery from original geometry
and project textures. It does not distribute an IWAD, engine, save or fixture
package. `run_native.ps1` refuses overlapping engines, records environment and
input/package hashes, uses GZDoom 4.14.2, runs unpaused at 5% audio and preserves
each log. Final visual evidence and package comparison are recorded in report.json.
The selected final runs contain 24 PASS / 0 FAIL and 33 native model views,
plus the real inventory capture. Every one of 16,593 packaged members matches
its final source bytes. The project validator passes with no errors.
The crops in native-views-1/2 preserve 1:1 pixels and cover every model from
three directions; full selected captures and all original capture hashes remain.
Computer-use capture was unreliable with an occluding foreground application;
visual evidence therefore uses the engine's own screenshots.

Preparation corrections: the initial shell Python lacked Pillow; generation
used an isolated local virtual environment. The first runner invocation occurred
before packaging completed. A copied runner initially replaced the gallery smoke
script with its generic compile-only script; that override was removed. The launch/script corrections were tooling issues; the UI scope error was a
production presentation defect caught and fixed before delivery.

## Author review and remaining work

CA471-ART-01 is pending. `manual.ps1` opens the gallery and prints Spanish
controls; leave the terminal open with PowerShell `-NoExit`. F1/F3 select all
11 models, F2 shows four sides, F4 opens the real iodine inventory, Q closes it.
Artwork acceptance does not approve unfinished #471 recipes, new prices/stock,
material IDs, extraction values, regional positions or cartridge migration.
No natural saltpeter/sulfur deposit was placed in Barracas; MAP03 trade remains
the approved future supply route. #409 and #472 remain separate patches.

Reproduce: install Pillow 12.0.0 in an optional local generator environment,
run `verify.py`, the normal project validator and `build_dev.ps1` targeting
`build/issue471/current/caelum_argenteum_dev.pk3`; run `prepare.py`, then
`run_native.ps1 -Label <unique> -Checks -Script gallery -Visible`.
