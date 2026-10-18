# 5.4.33 / #323 - Western ceiling isolation

Native reproduction and author acceptance are pending. The author's #320
preview remains open; no second engine has been launched.

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
See packaging.json. The native launcher correctly refused a second engine
while the author preview remained open; no native #323 result is claimed.

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

## Native checks prepared, not yet run

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
