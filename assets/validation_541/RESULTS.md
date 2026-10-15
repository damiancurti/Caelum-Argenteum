# 5.4.1 / #259 - Weapon dispersion tiers

Baseline: `df98f4d2ef3bdb276aba5f4966c7e2e16084ac88` (5.4.0 / #237).
This focused patch applies the approved weapon-family, equipment-tier and strict
Lucidity categories. It preserves natural NPC attack rules, single-tier tool
identities, book homing, utility streams and existing damage/resource rules.
No saved fields or schema changed; the legacy accuracy field remains present.

## Author acceptance (2026-10-14)

CA259-01 passed: the author confirmed "Esa prueba dio corrrecto" after the
isolated manual handoff. No exceptions were reported for dispersion, weapon tiers,
attacks or switching. acceptance.json records the frozen runtime/session hashes.
The completed check was removed from pending_test.txt. This documentation-only
acceptance reuses the unchanged native evidence below; no merge is inferred.

## Native evidence

Windows 11, GZDoom 4.14.2, Vulkan, isolated configurations, background simulation
unpaused, master audio 5%. Final runtime SHA-256:
`df669fdf02813ab3ee7f13cc9a70f55ca932c3671ae662d9a4497b2bf148b137`.
`build/issue259-verified/release-02` passed **677 assertions**, engine exit 0,
without script/VM errors. Probe SHA-256:
`a76c042fe7526d1f59f1ad5ed84ef6d12ee793d4ee628d2c300c627661d8a33b`.

- All 19 physical catalogue entries and four magical families, T1/T2/T3, at
  50.001/50/49.999/10.001/10/9.999 Lucidity. The seventh category is capped.
- Actual player magical primary/secondary releases, sword primary/secondary,
  carbine/shotgun/bow/crossbow launches and retained Type-3 precision.
- Actual NPC staff launch and trajectory, Mandinga machete damage/misses at
  T1/T3, and soldier carbine T1/T2/T3 with existing crouch/ADS modifiers.
- Actual book target acquisition/homing; bolas preparation and its retained
  single-tier base. Utility-stream geometry is unchanged by source inspection.

The fixture freezes AI to isolate attacks and explicitly completes native actor
initialization. It does not represent a full siege, every actor identity or a
physical-input acceptance test. No production behavior was changed to satisfy
fixture initialization assumptions.

## Persistence and interactive fixture

An old 5.4.0 save contains a real equipped T3 staff and low Lucidity. Final-runtime
`old-to-new-05` loads it successfully; `save-current-04` reloads the new save;
`rollback-01` loads the new save using the old package and restores the old
accuracy/spread rules. Inventory ownership, equipped flag and model tier agree.
No player's campaign save was touched. Native save references require the same
map archive basename, so both versions are named `baseline.pk3` in separate
directories; hashes identify their real contents.

`preview-01` equips the real T1 staff and creates a target in MAP02. Its screenshot
was inspected: first-person weapon, target and test instructions are visible.
`cycles-01` exercises all nine fixture weapons, three tiers and five Lucidity
settings through the same equipment/network actions as the handoff. The fixture
holds resources/ammo and suppresses low-Lucidity stun only to compare trajectories.
It is excluded from the production PK3. At that checkpoint the author was away;
the subsequent handoff and passed CA259-01 acceptance are recorded above.

## Earlier failures and their disposition

Original packages and logs remain under the local `build/issue259-*` directories.
The initial contract passed 671 checks; adding homing exposed a ZScript expression
syntax error, fixed with an explicit vector local. An expanded 675-check pass
preceded the additional native melee checks. Those initially failed because a
frozen test actor skipped PostBeginPlay and had zero physical-power initialization;
the fully initialized soldier then exposed inherited armor attribute bonuses in
the neutral-precision fixture. Explicit initialization and base clothing fixed
these fixtures; final 677 checks pass on the same production runtime.

Early session tests confused character-size and equipment-size IDs; the fixture
now uses the authoritative conversion. Save launch trials also exposed the engine's
relative-load-path and map-archive-name requirements. An initial migration check
used an overly strict Lucidity tolerance: native regeneration occurs once between
the fixture's WorldTick and verification, now bounded by exactly one recovery tic.
Failed/intermediate runs are not counted as completed evidence.

## Reproduction

Use a fresh directory to preserve evidence. Engine and development IWAD paths are
configurable launcher parameters; neither they nor packages/saves are distributed.

```powershell
python assets/validation_541/prepare.py --directory issue259-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_541/run_native.ps1 -Directory issue259-recheck -Label contract
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_541/run_native.ps1 -Directory issue259-recheck -Fixture session.pk3 -Script cycles.cfg -Label cycles
```

For the author, use `-Fixture session.pk3 -Script manual.cfg -Interactive` with a
fresh label. It runs until the author closes the game. F6 cycles Lucidity, F7 tiers,
F8 weapons; normal attack controls remain. `pending_test.txt` owns acceptance steps.
`evidence.json` records exact native commands, hashes and results, independently of
manual acceptance.

## Static validation and packaging

`python build_document_index.py` regenerated the maintained locator.
`python validate_project.py` passed with `errors: []` and 2,499 CONTEXT words.
Normal `powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1`
packaging passed with 16,073 files and no directory entries. All members match
the final native-tested runtime. `git diff --check` passed. The cycling session
confirmed 37 successful real equipment operations. Unrelated local dirt remains
outside this patch; no prior evidence or source file was deleted.
