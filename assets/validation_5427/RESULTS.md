# Normal prisoner following — issue #307 / 5.4.27

Requested by the author on 2026-10-16, with explicit confirmation that the existing
recovery teleport should remain. Branch: fix/issue307-prisoner-follow-speed,
stacked on #305/PR308 (83f79cc1). CA307-01 (origin 5.4.27 / #307) passed author
review on 2026-10-16 without reported exceptions; PR317 merge/closure is authorized.

## Production boundary

The old ordinary escort assigned CombatBaseSpeed times the run/walk ratio as a
velocity every tic. This both bypassed health/thermal/elemental modifiers and
applied a native walking step much more frequently than the normal See states.
The four prisoner types walk through native chase actions every four tics.

Ordinary escort now uses resolved Speed / PRISONER_WALK_STATE_TICS. The shared
constant retains the existing value 4 and replaces that same literal in all four
See states. State order, actions and durations remain unchanged. Following still
stops at 96 map units, resumes outside that distance, and uses the existing
recovery teleport beyond 1024. Boss escape, combat, rescue/extraction, rewards,
profile values and resource rules are unchanged. No persistent field or save
schema is added or removed.

## Native validation

GZDoom 4.14.2, Windows, Vulkan, one unpaused background engine at a time, 5% audio.
Full runtime SHA-256:
`eae4716035b849bdf22183d53d1cf695974b99ac6654f5a8cbd392e23ae8e894`.
The legacy control uses exact 5.4.26 runtime
`7c27a0f1d81ed0b146bd04b3d759f9028d76e3ab5ad9f4660d51c5d592255a85`.

The final issue307-08 suite passes 334 assertions in 11 current-runtime runs,
with zero failures and normal exits. The two issue307-08-legacy runs add 14
passing assertions. RESULTS.json counts actual PASS lines, excluding the earlier
development attempts below. All final fixtures match the maintained probe source.

Static validation reports no errors. The normal development PK3 and the tested
runtime contain all 16,193 source members byte for byte. Comparing with 5.4.26
finds only the resident steering, prisoner state cadence, shared constant and two
version diagnostics changed; all thermal/seal/archive members remain identical.
No test engine or keep-awake request remains active. Automatic evidence is not
author acceptance.

- Independent native walking control: the original four-tic A_Chase cadence
  traverses 100 units in 40 tics. Continuous following traverses exactly the same
  100 units in 40 tics. This catches the remaining fourfold boost that merely
  removing the run multiplier would leave behind.
- Motion covers all four original prisoner classes, then wounded, cold, frozen,
  and combined impairment. Each observed displacement and commanded velocity is
  bounded by the normal effective pace. The test checks physical approach,
  settling at the existing radius and restarting when the leader moves away.
  For the two cold controls only, fixture health is pinned to its initial value
  so lethal exposure cannot kill the subject before the second movement window.
  Thermal simulation and its movement modifier still execute. This is a walking
  experiment, not evidence of survival under that cold exposure.
- Contracts cover captive immobility, conversation/dead/missing-leader stops,
  exact/near follow boundaries, zero/negative/custom speed, native wall collision,
  recovery teleport with a shootable occupied candidate and ordinary hostile
  interruption. Teleport uses the existing native placement semantics.
- Normal save, repeated load, hub return, previous-version migration, repeated
  migration load and migrated hub return check all four original identities,
  base speeds, wounded health, individual inventory and rescue progression.
  The map-local diagnostic snapshot observes the native hub actor graph.
- A previous-runtime motion control reproduces the original speed excess, using
  the same fixture and configuration: the healthy Unitarian reaches 20 map units
  per tic versus its normal 2.5. The run ratio and four-tic cadence together made
  that ordinary escort eight times its native walking pace.

## Preserved development attempts

All attempts remain available; they are excluded from final passing totals.

- issue307-01 used the intermediate Speed-only implementation. Its repeat-case
  captivity check incorrectly assumed that rescue progression could be reset
  backwards, and its combined-cold subject died before finishing. Source review
  additionally identified the four-tic movement conversion that this early cap
  assertion did not test. Final code and the independent A_Chase control address
  that omission.
- issue307-02 and issue307-05/combined-01 use the final production runtime.
  Their combined subject dies from unchanged thermal physiology; telemetry shows
  health reaching zero rather than a live follower exceeding or abandoning its
  normal pace. Final motion isolates the speed experiment by pinning fixture health.
- issue307-04/contracts-01 used a non-shootable obstacle to assert teleport body
  exclusion. Native TeleportMove does not give that prop the tested shootable-body
  semantics. The corrected shootable-body control passes in issue307-05; wall
  collision also passes. Production teleport code is unchanged.
- issue307-06/travel-01 stored references to map actors in a traveling player
  inventory. Native hub travel clears those cross-map references; the diagnostic
  then dereferenced null. The production actors remained in the restored map.
  The final fixture uses a map-owned snapshot and guards missing references.
  Preserve the VM-abort log; it is not a passing save test or a native engine crash.
- issue307-07/motion-01 pinned the combined-control health exactly on a health
  band boundary. Regeneration crossed that boundary inside actor Tick, making
  intermediate movement coefficients differ from the observer's endpoint samples.
  The final fixture pins that control two HP inside the same authored band.
  issue307-08/combined-01 passes all nine checks with unchanged production code.

## Reproduction and limits

Run `python assets/validation_5427/prepare.py --directory <fresh-name>`, then
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5427/run_checks.ps1 -Directory <fresh-name>`.
Preparation refuses existing directories and pins the local previous-runtime
package by hash. No engine, IWAD, runtime package, generated map or save is
distributed. The test map reuses #252 geometry, including its native blocking wall.
`collect.py` preserves logs/configurations/manifests, reports actual PASS lines
(saved event-handler totals may carry earlier checks), and compares all final
runtime members against src/. Failed evidence is retained separately.

The change has no new art or companion navigation algorithm. The existing native
wall handling and distant recovery teleport remain. Ordinary MAP02 movement feel
and campaign save confirmation were accepted through CA307-01 on 2026-10-16.
The author also confirmed CA304-01; both results are recorded in HISTORY and
removed from the pending queue. This acceptance update changes no tested runtime.
