# Issue #363 - Native equipped-Seal input while unarmed

Release 5.5.5, 2026-10-19. Baseline: main `5dc71f5e` (5.5.4).

The baseline accepts the equipped Water Seal through the sword selector but
never starts it through the native unarmed +user2 input. The revised package
restores that route. Runtime changes are limited to `CaelumUnarmedWeapon.zs`
and two diagnostic release strings required by project validation.

19 required Windows/GZDoom 4.14.2 runs complete 175 assertions without failures.
See `report.json` and frozen logs, launch arguments, configs, scripts, source
hash manifests and probe sources under `evidence/`. Vulkan: RTX 3070 Ti;
Ryzen 9 5950X. Engines run unpaused in the background, audio 5%, one at a time.
No keep-awake request was needed. This is correctness evidence, not FPS evidence.

Coverage:

- Native unarmed, sword and wand press/hold/release/second-press routing. One
  effect survives the hold; ten simulated tics spend exactly ten shared costs.
- Empty resource and missing Seal rejection, depletion termination, and a new
  native press rejected during cooldown.
- Original-runtime ready/punch saves load in the revision and remain usable;
  current ready/active-channel saves reload; a current ready save rolls back to
  the original runtime. Hub transfers retain the observed Seal ItemId and fists.
- Static comparison confirms the entire prior unarmed state sequence is an
  unchanged prefix and no saved field is added. Existing Fire/User1/User3/User4
  preservation is static evidence; their controls are not exercised here.
- Old punch loading is checked after its action may complete. It establishes
  load/usability, not an assertion about the exact restored punch phase.

Independent review found no production defect. Its cooldown coverage finding
was addressed by the additional `cooldown` run. Initial fixture failures are
preserved and explained separately in `report.json`: insufficient seeded
Adrenaline, an absolute loadgame argument, an uncopied checkpoint and invalid
pointer-equality assumptions across hub transfers. None is counted as a pass.

`python validate_project.py` and normal `build_dev.ps1` packaging pass. The
normal builder's package contents match the tested revised runtime. The
generated document index is current. Author acceptance is pending: CA363-01.

Reproduce current input checks in a fresh directory:

```powershell
python assets/validation_555/prepare.py --directory issue363-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_555/run_native.ps1 -Directory issue363-recheck -Label unarmed -Script input--1.cfg
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_555/run_native.ps1 -Directory issue363-recheck -Label cooldown -Script cooldown.cfg
```

For the baseline use a frozen 5dc71f5e runtime with `--baseline --runtime`.
Prepare separate directories so original packages and saves remain available.
Run `save.cfg` before load checks; copy checkpoints into the target savedir and
pass their relative basenames to `-LoadGame`. Use `active-save.cfg` before
`active-load.cfg`, and `hub.cfg` with the ready checkpoint. Frozen executed
commands are preserved for every required case. `collect.py` verifies the
recorded delivery run set and counts actual log assertions, not saved counters.

For the author use `preview.ps1` and the instructions in root `pending_test.txt`.
The fixture grants no campaign progress and its saves remain under `build/`.
