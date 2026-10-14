# 5.4.2 / #261 - Equipped-Seal elemental resistance

Baseline: `a88ce908` (5.4.1 / #259). This patch adds only the approved passive
Seal factors and their presentation. Shared lookup uses equipped/unboxed identity;
no native actor receives new equipment and no save schema changes.

## Four-element correction after author review (2026-10-14)

The author reported the prior checks good except the fifth resistance row:
Quintessence protects the four elemental families but has no resistance of its
own. CA261-01 is therefore partial, with a narrow recheck in pending_test.txt.
Human innate magical armor remains 7.5%, the existing #52 value rather than a
Seal bonus. No generic armor rule, essence weapon or save field changes here.

`build/issue261-four-elements-final/contract-01` passed **561 assertions**, exit
0, on GZDoom 4.14.2. The matrix now treats Quintessence damage as an excluded
identity for all five Seals, all tiers, named/prepared attacks, actual player/NPC
direct and area HP. The other four families, burn/poison accumulation and dose
regressions still pass; five additional checks cover item-description percentages.
Production SHA-256:
`211a18ce8ad08a27e7084f137e90084090f71c6a76d02f3926eaf9972e34f221`.
Exact commands, hashes and logs: `four-elements.json`.

`display-01` captures show exactly four rows; Fire displays 53.75% and the other
three 7.50%. With Quintessence all four display 21.38% (1 - 0.925 * 0.85), and its
Spanish item description correctly states 15% across those four families.
The captures are retained under `captures/`. `prior-save-01` loads the saved
previous #261 runtime and retains equipped inventory, burn progress and the
500-HP Fire result. Prior upgrade/rollback/travel evidence below still describes
the earlier package; this correction adds no saved state.

An intermediate screenshot caught the description displaying 0% because it
queried Quintessence against itself. The description now uses a protected
family to calculate its percentage. Intermediate evidence remains under
`build/issue261-four-elements`; that package is not the author handoff.
The original matrix below is superseded for the fifth-family expectation.
Project validation passed (errors: [], 2,488 CONTEXT words). Normal packaging
passed with 16,074 files, no directory entries; every member matches this final
native-tested runtime. Diff checks passed.

## Original native evidence (before the four-element correction)

Windows 11, GZDoom 4.14.2, Vulkan, isolated configuration, unpaused in background,
5% audio. `build/issue261-release/release-01` passed **556 assertions**, exit 0,
without script/VM errors. Production SHA-256:
`a4ef1ab54078e145ec465a3e05e18ec6a6348a2773164233f16c65b908a16996`.
Probe SHA-256:
`75e58c799d03879fd3d46aa5a4dbfc831d75d2ed059eaec28107d85b6af1826b`.

The matrix covers all five Seals, all three tiers, all nine elements via explicit
names and prepared generic-name projectile payloads, and actual player direct
damage. Real player/NPC area damage and NPC direct damage use the production
defense/native HP chain. Additional cases cover owned/boxed identity, physical
impact exclusion, unknown magic, zero/healing inputs, fractional burn/poison,
unchanged healing/duration, and direct-hit status dose without double reduction.
An unrelated native DamageFactor is retained in the status-dose checks.
The native NPC fixture owns a test Seal solely to exercise the shared consumer;
production NPC loadouts remain unchanged.

`cycles-01` under issue261-05 exercised native equipment switching/removal twice
through all five Seals. Spanish final-runtime Character and item-detail captures
were inspected: Fire resistance is 53.75% with 7.5% innate absorption; other rows
remain 7.5%. The item explains its 50% Fire/Light reduction while equipped.
At that checkpoint no author physical-input acceptance was inferred. The later
author handoff and partial result are recorded above; CA261-01 remains pending.

## Save and travel evidence

The same session fixture creates five real inventory Seals on the 5.4.1 baseline,
equips Fire and starts a burn with remaining normalized duration/fractional dose.
`seed-old-01` creates the old save. Final-runtime `old-to-new-01` loads it and
confirms the same owned/equipped inventory, continuing burn and 500 HP from a
controlled 1,000-HP Fire delivery. `reload-01` repeats on the new save.
`rollback-01` loads that new save on 5.4.1, preserves inventory/dose, and restores
the original 1,000-HP delivery. Each exits 0. Packages/saves use identical archive
basenames in separate directories; exact hashes identify their actual version.

`travel-01` follows MAP02 -> MAP03 -> MAP02 using native `changemap`. Both checks
confirm five Seals, the equipped Fire identity, continuing burn progress and the
500-HP factor. No real campaign save or user configuration was modified.

## Earlier failures and scope limits

The first implementation passed 413 checks and failed the burn-source regression:
the direct hit lowered its source dose before the pulse factor lowered it again.
The final implementation compensates the direct Seal contribution when building
that dose, retains observed native damage retention/rounding and preserves the
MAP01 protected floor. A subsequent launch caught `sealed`, a reserved ZScript
keyword; renaming the local and declaring its gameplay scope fixed compilation.
Corrected intermediate matrices passed 416 and 509 checks; the final expanded
matrix passed 556. All original packages/logs remain locally preserved.

Existing HP-loss gates still govern push/status/Lucidity side effects; their
formulas, control durations and thermal-energy transfer are not multiplied by
the Seal. Generic magic with no authoritative element is deliberately unchanged;
the mine's fire-colored visual does not establish an elemental damage identity.
Status healing, disease and cut are not newly classified as elemental damage.
This is focused native evidence, not full-campaign or multiplayer acceptance.

## Reproduction

Use a fresh directory. Engine/IWAD paths are configurable launcher parameters.
The packager reuses the deterministic archive helper from validation_541; both
fixtures remain outside the production package.

```powershell
python assets/validation_542/prepare.py --directory issue261-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_542/run_native.ps1 -Directory issue261-recheck -Label contract
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_542/run_native.ps1 -Directory issue261-recheck -Fixture session.pk3 -Script travel.cfg -Label travel
```

For author review after return, use `-Fixture session.pk3 -Script manual.cfg
-Interactive` with a fresh label; F6 cycles Seals/removal. The game runs until
closed. `pending_test.txt` owns the outstanding author steps. Packages, saves,
engine and development IWAD are not distributed. `evidence.json` records exact
commands, hashes and completion markers.

## Static validation and packaging

Dialogue/localization artifacts were regenerated after the bilingual addition.
Maintained documents and LANGUAGE retain their required LF bytes before index
generation. `python build_document_index.py` refreshed the documentation locator.
`python validate_project.py` passed, `errors: []`, 2,492 CONTEXT words. Initial
checks reported an overlong CONTEXT; shortening the summary resolved that limit.
Normal `build_dev.ps1` passed with 16,074 files and no directory entries; every
member equals the final native-tested runtime. `git diff --check` passed.
Unrelated local dirt and all earlier test evidence remain untouched.
