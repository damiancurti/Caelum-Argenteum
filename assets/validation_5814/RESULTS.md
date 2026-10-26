# #410 native ration integration — 5.8.14

Status: implementation and agent validation complete for existing rations;
author corroboration **CA410-FOOD-01 pending**. New dishes, cooking and remaining
furniture are outside this slice. No artwork or map geometry was changed.

- Runtime: `build/issue410-lots/final01/caelum_argenteum_dev.pk3`.
- SHA256: `327a6ea1ee243c23dedefd3ea591224d31e6509ccd8a111d72c58c0cf4df51fb`.
- All 16,917 archive members match `src` byte for byte; no extra members.
- Static validation: no errors, context 2,498 words. Dialogue/localization and
  document indexes are current. Source/test whitespace checks pass.
- GZDoom 4.14.2: **57 executed PASS / 0 FAIL in 11 selected native runs**.
  Count literal executed assertions, not the accumulated counters saved in hubs.

Coverage: native pickup, capped self-copy, partial toss, oldest-first merging,
Box-use rejection, full 200 g intake/body mass, contaminated resale filters,
native quantity reconciliation, actual coffer split/merge/overdraw, source and
destination climate, Box ageing, fresh shop stock, frame-independent calendar
integration, independent journey/wait forecasts, actual JourneyPlan.Apply,
save/load, unloaded coffer return and prior-package migration/rollback.
The saved old package is the accepted #411 final05 package; the original save
is loaded again under that package for rollback. No user save is overwritten.

`captures/food-lots-es.png` and `food-lots-en.png` were visually inspected:
the two detail lines fit above the hygiene buttons and retain the ration art.
The author terminal is prepared but intentionally not opened while the author
is away. F4 advances only food exposure and is explicitly labelled diagnostic.

## Performance evidence and limits

Same peaceful room, 500 native ration stacks with identical invisible sprites,
1280×720 Vulkan, 60 FPS cap, unpaused background, 5% audio, Ryzen 5950X/RTX3070Ti.
Each sample records 700 simulation tics, about 20 seconds, and 1,199 callbacks.

| Package | p95 callback ms | p99 ms | Worst ms |
| --- | ---: | ---: | ---: |
| Previous #411 final05 | 16.9479 | 17.2368 | 17.9859 |
| #410 final01 | 17.0070 | 17.2587 | 17.7563 |

These are frame-callback intervals, not GPU/display presentation measurements.
They do not establish city, sewer, full-mansion or army performance. The typed
load census is only for migration/rebinding, over current ration actors, with
spawn-event registration afterward; the normal clock has no global scan.
One clock belongs to each real stack, independent of its native unit count.
Constant Limbo replay and saturation avoid repeated identical work. Seasonal
replay remains linear in sampled climate minutes until saturation; arbitrarily
large refrigerated/off-map inventories have not been performance-certified.
Local magical temperature/humidity modifiers are sampled, and their last
observed values remain in the unloaded storage context; their complete future
activation/expiration history is a remaining unloaded-world integration gap.

## Resolved development findings

Earlier probes are retained under `build/issue410-lots`, outside the selected
passing evidence. The first compile fixed an Actor ternary cast and removed an
unsupported iterator constant. A native capped-copy mismatch was fixed in
production. Save-fixture failures came from automatic eating at Hunger50 and
an unpersisted Box ownership flag; fixtures now start satiated and grant the
real ownership state. A nested-exec UI capture stalled before setup; explicit
ordered capture commands work. The first long UI detail overlapped buttons;
the final bilingual two-line version was inspected and fits.

Reproduce with `prepare.py`, `run_native.ps1` and `collect.py`. Run native
sessions serially and never rewrite an open fixture PK3. Runtime/fixtures,
engine and IWAD hashes, commands, machine and configuration are in `native/`.

## Author-launch correction, 2026-10-26

The corrected manual script queries all six intended bindings, seeds six portions in two lots, consumes the oldest portion (six to five; 48-point reference dose at the fixture mass) and advances oldest food contamination from 30 to 45.

Native startup evidence: `native/bindings-fixed-smoke-01.txt` and
`native/bindings-ready-live-02.txt`, with separate command/environment records.
The exact interactive entry reaches the readiness marker; the launcher now
waits for it and reports failure instead of silently handing off an unseeded
scene. The frozen gameplay package is unchanged. This startup evidence is
separate from the original gameplay assertion counts.

Remote desktop key injection did not reach GZDoom. Native binding queries and
scripted commands are agent evidence; physical-key author check CA410-FOOD-01
remains pending. No author pass is inferred from fixing the launcher.
