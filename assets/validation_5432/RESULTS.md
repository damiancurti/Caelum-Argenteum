# 5.4.32 / #320 - Direct demon projectile aim

The author identified Mandinga fire and Zupay stone projectiles, then explicitly
chose direct target aim for both after the #259 dispersion rule was explained.
The previous behavior followed that rule; this patch implements the new exception.
It skips post-launch spread only in those families, including existing subclasses.
Native launch aim uses the target's current position, without lead or homing.

## Native evidence

GZDoom 4.14.2, fixed RNG 282, Vulkan, 1280x720, one engine at a time, unpaused
in the background, 5% master audio. These are functional tests, not FPS benchmarks.
Runtime/fixture hashes, full compressed logs, commands and launch metadata are
in evidence.json and evidence/. Development IWADs, runtimes and saves are excluded.

- Final current-runtime runs: 504 assertions across matrix, native chase,
  high density, old-runtime load, current save and current load.
- Baseline fae45fb6: 486 matrix assertions and 2 save assertions. The same
  matrix implementation uses an explicit baseline expectation, not a modified combat model.
- Matrix: 54 combinations per actor (Mandinga, Zupay and an ordinary combat
  actor retaining spread). Distances 128/512/1500 MU; height offsets -48/0/128;
  three headings; stationary or displaced after facing; Lucidity 100/25/5.
  Frozen fixture actors invoke the actual production release action. A native
  reference projectile supplies the expected direction in the same tic.
- All 108 baseline demon launches deviated; velocity-vector difference ranged
  from 0.731155369 to 12.820037913 MU/tic. All 108 current launches matched the
  reference within 0.00001 MU/tic, reported minimum/maximum zero. The 54 ordinary
  actor launches retained spread. Speed, single Anima charge, damage payload,
  element and maximum travel range passed in every matrix case.
- Actual Mandinga/Zupay classes use normal engine initialization, chase,
  windup and release with a stationary invulnerable target. Both fired directly
  in ordinary and >=500-combatant paths. High density adds 500 frozen fixtures;
  it does not claim natural-battle or population performance coverage.
- A genuine pre-change save and a current save preserve owner/projectile
  identity, prepared payload and moving velocity. New launches after loading
  use direct aim. Existing projectiles are not retroactively redirected.

The frozen matrix explicitly initializes actor profiles and suppresses Tick;
it is isolated action evidence. The natural shooters do not manually invoke
PostBeginPlay. Next-tic reference checks use stationary targets and shooters
still in their attack recovery; they are not measurements of moving AI pursuit.

Early logs are retained: 01 rejected a boolean literal in a ZScript constant;
02 used a reserved fixture method name; 03 had fixture string/field errors.
04 passed the matrix and native attack pilot. The first release fixture started
AI before deferred initialization, so only one enemy fired within its window.
Final02 waits for native initialization before assigning the test target; both
then fire. Final fixtures also retain
real moving projectiles through save/load and normal shooter initialization.

## Reproduction and delivery

Run prepare.py with a fresh --directory; use --ref fae45fb6 for the baseline.
Use assets/validation_5422/run_native.ps1 with that directory and the matrix,
native, dense, save or load cfg. For load pass -LoadGame aim.zds. Copy the
baseline save into the current isolated directory for the migration run.
Each launch requires a new label. manual.cfg opens two real enemies against
an invulnerable player and remains open for the author.

Project validation, normal packaging and archive.py verify the final source
and every normal package member against the tested runtime. Independent source
review found no production defect; its initialization caveat was addressed in
the final native fixture. Author acceptance remains pending as CA320-01.
