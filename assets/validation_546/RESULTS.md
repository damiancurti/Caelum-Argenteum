# 5.4.6 / #242 - Supernatural Breathing

The Caelith User1 effect substitutes all ordinary Air demands at 1 Anima per Air
point, then applies the current Anima cost reduction. There is no flat drain or
cooldown. It uses #238's saved controller. Insufficient Anima ends it, preserves
the remainder and routes the whole effort to ordinary Air handling. Existing
Air-based performance and thermal rules remain in effect.

Actual consumers cover primary/secondary melee, firearms, bow/crossbow, javelin,
bolas, fists, running, jumping, blocking and underwater deprivation. Eligibility
checks accept affordable Anima even with zero Air. Substituted breathing prevents
that tic's drowning without accruing Air debt; ordinary Air loss still accrues
its normal debt and is recovered normally on surfacing.

## Native evidence

Windows 11 / GZDoom 4.14.2 / Vulkan, isolated configuration, unpaused in background,
5% audio. Behavior-tested runtime SHA-256:
`f6f95fcdc2976a66ecad927af23190d494ba0e9d5ce55758719a05412660ecfa`.
Final release SHA-256:
`256e0e6b2ac80b35257ae626f0986208eccf4e6d9d5173903bf4b6c5aa42dbc2`.
The only changed members are two diagnostic version strings (5.4.4 to 5.4.6).
All gameplay bytes are identical. Final native preview and active-save reload
pass; all 16,156 normal-build members match that final runtime. Static validation
has no errors and CONTEXT has 2,479 words. The native handoff capture was inspected.
Exact fixture hashes, run times, logs and results are in evidence.json.

- `issue242-v2/contract-01`: 48 assertions. Controlled ordinary/live-modified
  payment, complete-effort refusal/fallback, exact exhaustion, no flat drain,
  interruption, actual underwater service and native User1 input. Native active
  and inactive attacks cover sword, carbine, shotgun, bow, crossbow, javelin,
  bolas and fists, followed by running, jumping and giant-gauntlet blocking.
- `issue242-v3/water-01`: 30 assertions, including actual immersion in a native
  swimmable 3D floor. At zero Air, paid Anima prevents drowning. An unaffordable
  remainder switches off the power, spends the remaining 3 Air, then resumes
  ordinary drowning. Surfacing refunds exactly those 3 Air points. The isolated
  observer holds the body on the pool floor; it does not alter payment/gravity.
- Same runtime save (27), reload (3) and hub return (29) pass with the real
  Caelith effect and unchanged idle reserves. No instrumented racial subclass
  substitutes for the production effect in these checks.
- `issue242-upgrade/upgrade-01`: an original neutral 5.4.3 save loads through the
  existing #238 compatibility observer with inactive new fields and no new effect.
- `issue242-rollback/rollback-01`: the optional 5.4.4 bridge deactivates the
  unsupported power while preserving 777 Anima and 333 Air. The original save
  remains untouched. `issue242-handoff/rollback-return-01` passes two checks for
  inactive state and the same reserves after loading that copy back into 5.4.6.

The first fixture used invulnerability, which legitimately exempts underwater
costs, and attempted to block with a sword without owning a shield. Those four
failed checks are preserved in `build/issue242-v1/contract-01.txt`. The corrected
fixture uses ordinary vulnerability and a real block source. Production did not
need a change to satisfy those corrected tests.

## Reproduction and rollback

Run `python assets/validation_546/prepare.py --directory <fresh-name>`, then
`run_native.ps1` with `-Directory <fresh-name> -Label <fresh-label>
-Fixture breathing.pk3 -Script contract.cfg -Map MAP99`. Other scripts are
`water.cfg`, `save.cfg`, `load.cfg -LoadGame breathing.zds` and `hub.cfg`.
Use one engine process at a time and distinct labels to retain evidence.

For the explicit return to the #238/5.4.4 baseline only, `prepare_rollback.py`
copies the current isolated save and supplies `rollback_bridge.zs`. The bridge
declares the serialized effect type and deactivates it without refund/payment;
do not load it alongside the current production runtime, which owns that class.
Keep original saves and runtimes. This is a tested compatibility route to the
specific preceding baseline, not a promise that arbitrary old versions understand
new powers without a bridge.

## Author check

CA242-01 is pending in the root pending_test.txt. The handoff uses the real player
and Caelith effect with reusable resource/reset controls. Its observer disables
resource regeneration to expose spending and gives real giant gauntlets for
blocking. There is no invulnerability. Manual acceptance, campaign-wide play and
multiplayer acceptance are not inferred from agent tests. No merge/closure is claimed.
