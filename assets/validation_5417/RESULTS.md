# 5.4.17 / #248 — Rally

Cleric Rally is implemented on its own branch above accepted #247. **74 qualified
assertions in 15 native runs pass** on GZDoom 4.14.2 / Windows / Vulkan. Static
validation passes with zero errors. The normal package is compared member by
member with src and the frozen tested production package by `record_evidence.py`.
Author acceptance **CA248-01 remains pending** in root pending_test.txt.

The native fixture verifies mobile range/sight/allegiance, current maxima, recovery
caps, first and last pulse, strongest overlap, renewal phase, full Empathy factors,
Survival Instinct recovery, pre-hit bars, physical/magic/periodic/environmental
damage, self-protection, forced native damage, seal/native defense ordering, Sleep,
elemental dose normalization, nested hits, destructible structures and a real
missile receiving Rally after launch. Native User4 preparation, payment,
cancellation, release/reuse, current reload, partial-preparation reload, expiry,
caster death and hub travel pass separately from the author check.

Reproduce using a fresh directory (never overwrite preserved logs):

```powershell
python assets/validation_5417/prepare.py --directory issue248-reproduction
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5417/run_native.ps1 -Directory issue248-reproduction -Label contract -Script contract.cfg
```

Other script names are `damage`, `advanced`, `flight`, `casting`, `cadence`, `save`,
`load`, `save_prep`, `load_prep`, and `preview`, each with `.cfg`. Run one engine
at a time. Load `rally.zds` for `load.cfg`, and `preparing.zds` for `load_prep.cfg`,
using the runner's `-LoadGame` argument. Relative names resolve inside its savedir.
All tests run unpaused in the background at 5% audio with isolated configs/saves.

The current runtime's SHA-256 is
`cd4791a75aec5fd45574de2d2eb43d7cdb7c982258cf5f7a61116a0011f0ae25`.
`evidence.json` retains exact commands, engine/runtime/addon/log hashes, qualified
reuse and diagnostic iterations. Advanced/flight use this identical production
runtime; only later manual overlay/controls differ in their addon. Duplicate
preview checks are not counted. No failed diagnostic run is counted as passing.

`prepare_compat.py` creates separate copied-save upgrade/rollback/return scenarios.
Use 5.4.16 as the seed/rollback runtime, this release for upgrade/return, and the
current test addon for map lumps. The optional rollback bridge declares the
unsupported Rally inventory as inert schema, removes it and cancels preparation
without refund. Original saves remain intact. This proves the documented bridge,
not loading a later save in an unmodified earlier runtime.

`launch.ps1` opens the manual scene. F prepares/cancels; F6 resets; F7 moves the ally
inside/outside range; F10 places it behind the wall. F8 receives a controlled hit,
F9 deals one, and F11 sets the bar to 50%. The overlay reports the factor captured
for the last hit and actual HP loss; the displayed factor is rounded to two decimals.
Agent visual review confirms a readable overlay and the native class HUD, including
300 damage becoming 200 at a 50% bar. Campaign saves are not loaded.

No broad campaign, multiplayer, performance, merge/closure or other class-issue
acceptance is claimed. #249–252 remain separately scoped; #282 follows the batch.
