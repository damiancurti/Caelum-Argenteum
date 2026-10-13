# 5.2.24 / #220 - MAP02 Mandinga potion drops

The author reported missing drops only from Mandingas. Baseline `2d3cac6e`
has the same loot implementation as parent #219. Target: GZDoom 4.14.2 on
Windows 11/Vulkan, 2026-10-13. Background simulation, isolated INIs, 5% audio.

## Native regression and corrected behavior

`baseline-01` reproduces two expected failures: TID 47009 has no assigned item
but HasDeathDrop returns true, so an actual native death releases no potion
despite remaining supplies. Assigned ammunition and the rat ration pass.
`baseline-save` repeats the expanded assertions under old code and saves both
dead and living carriers; expected potion-fallback assertions fail there.

`loot-final` verifies native deaths of unassigned, ammunition and key carriers,
one-unit debit, exhausted stock, the last remaining potion, a rat ration and
duplicate callbacks. Assigned ammunition still spawns at its original dry
anchor after moving the carrier. `reload-final` reloads these deaths, confirms
saved latches prevent duplicates, and kills a saved living unassigned Mandinga
to receive one potion. `upgrade-final` performs that same check against the
baseline save, without adding fields or replenishing already-dead bodies.
Corrected runs must end with `CA220 DONE failures=0`.

`verify.py` compares every generated assignment branch/predicate to the manifest:
38 Mandingas plus 192 rats, exactly 230 carriers. Two subsequent generator runs
are byte-identical for all four outputs; map geometry and quantities are unchanged.
Independent read-only review confirmed the predicate's exact coverage, source
ownership and unchanged potion exhaustion/death-latch behavior.

## Reproduction and limits

Run prepare.py, then run_native.ps1 with `-Fixture loot -Script loot.cfg
-Map MAP02` and a unique label. Reload with `-LoadGame c220-deaths.zds
-Script reload.cfg`. Baseline uses `-Baseline -ExpectRegression
-Script baseline-save.cfg`. To upgrade its save, copy production.pk3 to a
separate current/baseline.pk3 and use `-RuntimeAlias current/baseline.pk3
-LoadGame c220-baseline.zds -Script reload.cfg`. The basename preserves GZDoom's
map-package requirement while using only patched production code.

These fixtures cause actual engine damage/death and observe inventories; they
do not represent the author's manual acceptance, which remains CA220-01.
Keep generated packages, IWAD, executable and saves local under build/issue220.
No changes to potion amounts, weighting, anchors or already-dead saved actors.

Final checks: static validation/build passed; 24 corrected native assertions
passed, and all 16,053 package members match the final tested runtime. The final
runtime additionally updates the diagnostic supply totals to the existing #183
360 arrows/240 bolts. The expanded old-code save probe has four expected
failures; it is regression evidence, not a passing result. Keep-awake was released
with the power plan unchanged. Author acceptance CA220-01 remains pending.
