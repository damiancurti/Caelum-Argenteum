# Native menu migration - 5.2.7 / issue #189

Baseline: 4a2ea045 (#184 / PR190). Target: GZDoom 4.14.2 on Windows 11.
The fixtures are development-only and are not included in src or the PK3.
Only source, bounded logs, run metadata/hashes and screenshots are redistributed.

## Reproduction

Run `python assets/validation_527/prepare.py`, then `run_native.ps1` with a new
label and `-Fixture native -Script menus.cfg`, `regression.cfg`, `actions.cfg`,
`dialogue-matrix.cfg`, `input-edges.cfg` or `lifecycle.cfg`. Configs isolate the engine, enable
background simulation and use 5% audio. Fixture inventory/characters are seeded;
craft completion acceleration and the journey display model are explicitly
isolated from production. The journey test does not claim end-to-end travel.

## Validation

Selected successful run results and their actual runtime hashes are recorded in
[RUNS.json](RUNS.json) and logs/. Only the long Vulkan capability line is omitted;
original log hashes are retained. [CAPTURES.json](CAPTURES.json) records actual
PNG dimensions, source run and hashes. `archive.py` rebuilds these records.

| Run | Passing checks | Result |
| --- | ---: | --- |
| menus-final-es | 286 | Spanish, 1024x768 |
| menus-final-wide | 286 | English; requested 2560x1080 was clamped by Windows to 1924x1061 |
| menus-final-ultrawide | 286 | English, verified 1600x675 ultrawide capture dimensions |
| actions-final | 36 | Box transfers, filters, equipment, merchant quantity/selection, rest cancellation |
| dialogue-final | 37 | Rest orbit/sensitivity/inversion, NPC replies/history, creator |
| previous-save-02 | 6 | Actual previous 5.2.6 save loads without reseeding |
| regression-final | 116 | Crafting, time skip, Truco and Trucazo |
| lifecycle-final | 14 | Held world inputs, current save/load and native ownership |
| input-edges-final | 17 | Journey held inputs, rest opening Use repeat/release/fresh press |
| physical-01 / physical-dialogue-01 | 2 / 3 | Fixture setup passed, then physical Windows interaction below |

- Static: project validator, generated dialogue/localization/document indexes,
  clean patch whitespace and production build.
- Native menus: all Journal pages and modal contexts, projected hit regions,
  live world tics, nested Escape pause/return, GUI key mapping and held latches.
- Native regression: craft/cancel, repair, disassemble, processing/components,
  time skip and both paused card games through their production dispatchers.
- Native dialogue/rest/creator: orphan/dragged/stale replies, semantic index zero,
  real reply dispatch/history, creator profile/navigation and preservation of
  edited allocations; right-button orbit dispatch and existing pitch limits.
- Native lifecycle: held movement/aim/attack/use, save/load an open live panel,
  restored ownership, discarded armed pointer and return to normal gameplay.

The final source package hash is in manifest.json. The ultrawide and input-edge
runs use that final source package. Other evidence precedes only the final
journey held-turn guard and rest opening-key guard; those changes are covered by
input-edges-final. Earlier menu/action runs also precede mouse sensitivity and
inversion calibration, covered by dialogue-final. Physical runs precede the
subsequent documented footer/hold fixes; their exercised Journal/calendar and
NPC response actions remain unchanged. The old clamped-window run is retained
as additional evidence, not as ultrawide acceptance; its captures and mistakenly
copied card captures remain in local build scratch, outside this delivery.

Physical Windows input (computer-use skill): Spanish Journal tabs, calendar
open/date selection, Escape pause/return, Palomo response and Repeat/history
were clicked and observed live. Resources advanced during NPC conversation.
The engine was stopped deliberately by its recorded owned PID after the checks.
Sky's drag API supports only its default button: right-drag is exercised in the
running engine through the same production OrbitInput dispatcher, with physical
right-button/controller acceptance remaining in CA189-01.

## Qualifications

Agent checks are not author acceptance. CA184-01 and CA189-01 remain pending.
The map/save/gameplay authorities and existing art are preserved; no balance or
narrative values were changed. New UI state is transient and requires no save
migration. Wider multiplayer acceptance is outside this single-player UI patch.
