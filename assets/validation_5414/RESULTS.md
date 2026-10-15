# 5.4.14 / #253 - Mansion resident participation

Focused patch based on #246 commit 659a7aa4. CA246-01 remains pending; this patch
does not claim its acceptance. The author is away and requested keep-awake while
deferring questions and manual tests. CA253-01 remains pending too.

## Verified cause and scope

The baseline original MAP01 assisted encounter was started through its existing
controller. Native forward input moved the vulnerable player into the bull; actual
native damage reached the protected floor on tic 131. Player state remained live,
the bull retained TrialFighter and the same four residents retained their encounter
references. Healthy resident Speed and CombatBaseSpeed were both zero while their
Health, thermal and elemental multipliers were all one. They could attack a nearby
bull but could not pursue or recover their thrown bolas. Observation without moving
the player also showed stationary healthy residents, so 1 HP was not the gate.

This is the same early derived-stat/capture hazard verified for rats in CA-KP-096,
now independently established for the four anchored MAP01 residents. Their class
defaults remain Rulo 8, Ronnie 12, Argento 10 and Caella 10. The fix restores only
missing initial Speed before shared PostBeginPlay capture. Revision-1 Tick migration
repairs missing saved bases and reapplies normal status effects. Positive customized
bases are retained. The change is scoped to anchored MAP01 residents; no general
NPC movement, bull charge, damage, tool cost, healing or protection rule changes.

No states are inserted/reordered and no production class is added. The same saved
actors/equipment remain authoritative. Original test saves are preserved; upgrade,
reload and rollback operate on copies. Native post-victory restoration still occurs
at victory, not when the player touches 1 HP.

## Native evidence

Prepare with `python assets/validation_5414/prepare.py --directory issue253-final-v2`.
Run one engine at a time using `powershell -NoProfile -ExecutionPolicy Bypass -File
assets/validation_5414/run_native.ps1 -Directory <directory> -Label <fresh-label>
-Script <case>.cfg`. load.cfg uses `-LoadGame encounter.zds`; migration.cfg uses
`-LoadGame input.zds`. Names are relative to savedir. The runner preserves exact
arguments, hashes, logs, stdout/stderr, timestamps and exits. Hidden automatic runs
remain unpaused in the background with 5% audio. evidence.json is the final ledger.

Final result: 144 checks across eight native runs passed. Static validation reports
no errors; all 16,163 normal-package members match the frozen runtime. Runtime SHA256:
`796fbf41156383ff953f4e16a4bf1454ae38edc476724cdc20b5aca3c15345ca`.

- baseline observe/walk/trace/speed: diagnostic traces, not passing acceptance
  assertions. The first observer did not reach player 1 HP; forward native input
  reproduced it and exposed zero bases. Original logs remain in build.
- corrected observation: all four traveled after the floor (about 1711, 1246, 1423,
  1280 MU in that seeded run), and used finite tools. A genuinely downed resident
  remained excluded. These are preliminary measurements, not balance targets.
- final walk: fresh captured bases, native protected damage, same encounter/NPCs,
  continued real movement, genuine own downing and victory/dialogue-phase ownership.
- save/load: actual native assisted combat saved after the floor and resumed with
  the same bodies/resources. It does not restart the encounter or its checkpoint.
- migration: old-runtime save with three missing bases and one positive custom base,
  depleted resources, worn finite tools, saved impairment and one downed resident;
  native load repairs movement without replacing, healing, refilling or advancing
  quests. Reload/rollback/re-upgrade retain the same identities and positive base.

The final encounter checks deliberately finish any surviving bull with diagnostic
lethal damage after the participation checks. That establishes existing victory
transitions, not an unaided resident victory or a combat balance result. Migration
seeding makes the bodies dormant to isolate serialization; no campaign file is used.
Native resource recovery and downing remain active in the ordinary encounter run.
The existing #195 finite-tool and #207 player-floor foundations are reused; their
unchanged full suites are not claimed as rerun. No network multiplayer acceptance.

## Static and packaging

Regenerate `python build_document_index.py`, run `python validate_project.py` and
`powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1`. Compare all
normal-package members to the frozen final gameplay package. Only src is packaged;
the fixture, executable and development IWAD are not distributed.

## Preserved fixture iterations

The first observer used a nonexistent PainState field; it now uses FindState.
An early migration fixture incorrectly invoked GetDefaultByType as an instance
method; the native global form fixed compilation. Its failed seed produced no
save; an attempted dependent preparation therefore failed and its engine also
rejected that fixture. The generator now validates required input paths before
creating a directory. These failures are not counted as successful evidence.
The repaired preliminary upgrade passed. No production balance was changed to
satisfy the fixture. Final runs use the final documented runtime and repaired
fixture, including actual saved impairment.

## Deferred author check

launch.ps1 opens the original MAP01 scene for CA253-01 after the author returns.
Move toward the bull and allow protected floor damage; watch eligible residents
continue, respecting their own downing and finite resources. Optional F7 is clearly
marked as a diagnostic finish for checking existing victory interaction. No manual
game is left running while the author is away. The earlier persistent-terminal
approval rejection remains; the direct reviewed launcher opens the game.
No author acceptance, merge or issue closure is inferred.
