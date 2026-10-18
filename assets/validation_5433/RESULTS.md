# 5.4.33 / #323 - Western ceiling isolation

GZDoom 4.14.2 passes 108 current, 26 baseline and 10 old-map recovery
assertions in thirteen final runs. Author preview CA323-01 remains pending.

## Established cause and static verification

Crusher 43921 at (-5280,-1536) originally received a 128x128-MU sector. Later
refuge-corridor painting replaced those cells with western zone group 2. Equal
cell signatures were then compacted into one sector spanning 12,709,888 MU2,
instead of the intended 16,384 MU2. The existing pressure-plate Release selects
that sector correctly; neither a global tag nor the pressure formula caused
the overly broad geometry.

The generator now finalizes all nine panels after upper corridors and checks
that their footprint/base floor survive the lower-network overlay. Revision 5
changes only the sixteen 32-MU cells at x=-5344..-5248, y=-1600..-1504; heights,
water, tags and other geometry cells remain. It adds one sector, sixteen lines
and sixteen vertices. Only the layout marker changes among 441 map things.
Gates, traps, loot, drops, prisoners, refuges and lower cells remain identical.

Run `python assets/validation_5433/verify_geometry.py` to reproduce the comparison
and repeated byte-identical generation. static.json records output hashes.
Independent source review confirmed the same isolated changes and backup hash.
Project validation and normal/compatibility builds pass. All 16,371 normal
package members match the frozen source; compatibility changes only MAP02.wad.
Conflicting compatibility flags fail before modifying the existing package.
See packaging.json and evidence.json. The final normal package matches every
member of the tested current runtime; final recovery differs only in MAP02.wad.
The launcher preserved the author's earlier #320 preview and tests ran only
after it closed.

## Save recovery boundary

assets/map02_maze/legacy_5432 retains the previous WAD, layout and manifest.
The WAD SHA-256 is
6337bc73ca32bb9db9936052ac341d34ace75b3c66858dfc4eaa0e6833ce55f1.
`build_dev.ps1 -LegacyMap02Revision4` selects those exact bytes, preserves the
normal package/map names and verifies its hash before output replacement.
It is mutually exclusive with the original -LegacyMap02 option.

That mode is recovery of the previous geometry, including its known defect;
it is not an in-place migration or a repair of an ongoing saved crusher. A
fresh MAP02 uses the corrected panel after rebuilding without the switch.
The native engine checks map geometry before restoring script state. The
author previously waived save concerns; preserving the old revision also
retains the project's established reversible legacy-layout workflow.

## Native checks and limitations

prepare.py freezes current sources, or accepts --baseline-runtime with the
previous production PK3. Reuse validation_5422/run_native.ps1 with -Map MAP02.
The fixture suppresses other actors' attacks/pressure so ceiling movement can
be attributed to the selected plate. It does not alter crusher code.

- Geometry/area audit of all nine plates before and after.
- Actual forward input across the western plate, recording every changed
  ceiling and the native moved footprint.
- All nine native activation/return cycles, neighboring sectors and repeat use.
- Saves before activation and during movement, then load and continuation.
- Prior-runtime saves loaded with the current runtime and exact revision-4 map.

Physics/damage changes belong to #312 and remain outside this geometry patch.

The final runs are build/issue323-before02, issue323-final02 and
issue323-recovery03. Raw logs are archived compressed with deterministic headers,
alongside launch metadata, exact command scripts and fixture sources; no engine,
IWAD, PK3 or private save is distributed. evidence.json gives hashes and counts.

The initial baseline geometry audit passed, but its 30-tic forward-input run
stopped short of the plate and failed two assertions. The preserved failed log
is in evidence/issue323-before. Extending ordinary input to 350 tics reaches the
plate in both revisions; neither production movement nor the pressure formula
was altered. Native crushing can kill this fixture player, so that input check
establishes activation and geometry isolation, not survivability or #312 damage
correctness. All nine direct-release cycles separately verify completion,
restored ceiling height, exactly one changed sector and no retrigger.

Current saves before/during activation load and continue. The two baseline saves
load under current code plus the exact revision-4 map, retaining the original
large western sector. This verifies recovery, not conversion to revision 5.
The compatibility package was rebuilt after branch checkout to match current
source bytes exactly outside the intentionally replaced WAD.
