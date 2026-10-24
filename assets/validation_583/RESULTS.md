# 5.8.3 / #410 - Character contamination foundation

This is the first slice of the ongoing food/furniture issue. Character illness,
numeric food rules, natural depuration and HUD are integrated. Actual food
ingestion, per-lot ageing, cooking, commerce and furniture are not implemented
by this slice. CA410-CORE-01 remains pending author acceptance.

## Native evidence

Windows 11, GZDoom 4.14.2, Ryzen 9 5950X, RTX 3070 Ti, Vulkan, 1280x720;
unpaused background runs, audio 5%, fixed seed 410. Complete commands, source
package hashes, configurations, engine/IWAD hashes and raw logs are retained in
report.json and native/. Private packages, saves and fixture WADs are excluded.

Final focused checks:

| Run | Assertions | Scope |
| --- | ---: | --- |
| final-core-02 | 22 | Dose/body mass, ageing formula, resistance, native damage, costs, healing/depuration, no above-maximum Life reduction |
| final-live-02 | 3 | Real simulation damage, immunity and full-Life depuration |
| final-visual-02 | 1 | Icon resolves; captured Character screen inspected |
| final-illness-save-01 | 1 | Saved contamination and accrued damage seed |
| final-illness-load-01 | 2 | Restored revision, exact contamination/fraction |
| final-illness-hub-01 | 6 | State retained before travel, on second map and on return |
| final-old-save-01 | 1 | Original pre-feature character saved by 5.8.2 |
| final-old-load-02 | 3 | Old character survives; illness initializes clean; repeat migration preserves new state |
| final-old-rollback-01 | 1 | Original save still loads with original 5.8.2 package |

Total: 40 passing assertions in nine selected runs. The first core experiment
exposed a binary-rounding delay (19 instead of 20 Life over two seconds). The
existing status-pulse epsilon fixes it; retained core-01/core-02 failures show
the diagnosis. final-old-load-01 was rejected because its diagnostic PK3 had a
different basename. The bridge now preserves legacy-checks.pk3; the successful
load and original-save rollback are retained, with no save-file alteration.

The save/hub/migration checks precede the final isolated over-maximum Life
guard. That later change affects only healing's clamped positive delta; the
final core/live runs exercise it. Each run records its actual package hash.
No claim is made that every historical run used the final package.

## Static and visual evidence

collect.py verifies every packaged filename and byte against src/ and records
the final package SHA-256. Project validation and regenerated document/dialogue
indexes are recorded separately in static-validation.json. The deterministic
prepare.py builds the private addon; regeneration must produce identical bytes.

food-contamination-hud.png shows the survival column with the new contamination
bar and icon; Hunger, Hydration, Sleep and thermal exposure remain separate.
The unchanged generated source and complete prompt/provenance are recorded in
../manifests/food_contamination_icon_583.json. Author visual acceptance is pending.

The illness path is constant work on the current player's persistent record;
it adds no actor census or recurring inventory scan. No rendering performance
or final campaign food-loop acceptance is inferred from these numeric tests.
Food-lot migration, transferred ageing, travel forecasts, recipes and furniture
need their own subsequent integration evidence within #410.

## Reproduce / author handoff

Run prepare.py, build_dev.ps1 with destination
build/issue410/current/caelum_argenteum_dev.pk3, then run_native.ps1 with the
named cfg script and a fresh label. The bridge baseline is the preserved
5.8.2 full package under build/issue410/baseline; use bridge/legacy-checks.pk3
for its migration check and keep the original save for rollback.

Open author_terminal.ps1 in an interactive PowerShell using process-local
ExecutionPolicy Bypass and select 1. It documents F1 damage, F2 immunity,
F3 full-Life depuration, F4 numeric state and F5 Character. Option 2 resumes a
private save without reseeding it. The terminal stays open for author review.
