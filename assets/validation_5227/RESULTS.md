# One-gram empty Box - 5.2.27 / #229

Author decision: empty mass is 0.001 kg; contents retain their existing reduction.
Baseline: 5209b4d8. GZDoom 4.14.2, Windows 11, Vulkan/VSync, isolated configs,
5% audio, background simulation unpaused. No schema or contents change.

## Native results

- Baseline: 14 checks passed with the former 10 kg tare; a genuine save retains
  10 kg of ration contents, 0.312 kg reduced content and 10.312 kg total/load.
- Current new game: 14 checks passed. Unowned Box contributes zero; empty owned
  Box contributes 0.001 kg exactly once. With 10 kg stored, Intelligence 0 gives
  30 slots and 0.334 kg total; Intelligence 100 gives 100 slots and 0.101 kg total.
  HUD, shared total helper and carried load agree; aggregate gram truncation remains.
- Final-source reload: 5 checks passed. Normal ticks update the old saved total
  to 0.313 kg, retaining the same 10 kg contents and ownership. A subsequent forced
  refresh leaves the already-correct carried load unchanged; HUD agrees.

All 33 listed checks passed, with zero engine/VM errors and exit code 0.
`evidence.json` records package/fixture/log hashes. Final text corrections only
changed LANGUAGE and its generated index; the final-source reload also compiled
and tested that package. A second intermediate reload passed the same five checks.

The initial draft fixture used 100 rations, incorrectly assuming 0.1 kg each;
this class weighs 0.2 kg, so the fixture now uses 50. No production food rule
changed. A first reload used a different archive basename and GZDoom refused it;
loading final source under the original basename resolved the test setup issue.

## Reproduction

Run `python assets/validation_5227/prepare.py`, then `run_native.ps1` with fresh
labels and `-Fixture probe -Map MAP02`:

- `-Script baseline.cfg -Baseline` saves `c229-baseline.zds` under the former rule.
- `-Script probe.cfg` tests the new mass and unchanged content reduction.
- `-Script load.cfg -LoadGame c229-baseline.zds -RuntimeAlias load-current/baseline.pk3`
  loads that save against current source under GZDoom's required archive basename.

Generated packages, logs, saves, engine and development IWAD remain local under
build/issue229; only reproducible fixtures and results are tracked. These are
isolated agent checks. Separately, the author explicitly confirmed CA229-01
passed on 2026-10-13 without qualifications and authorized PR230 merge/#229
closure. The confirmed check was removed from pending_test.txt.

Static validation and normal build passed. All 16,053 packaged members match
the final native-tested package exactly. The temporary keep-awake request was
released after testing; the Windows power plan is unchanged. Cross-review found
two stale Palomo lines and historical wording; both were corrected before delivery.
