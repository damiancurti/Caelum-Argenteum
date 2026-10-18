# Issue #319 - Sleeping bag quick items

Release 5.4.30. Author acceptance CA319-01 remains pending.

Final runs pass 30 assertions (21 input/rest/transfers, 3 save, 6 load/hub).
Project validation/build pass; all 16,371 normal package members equal both
the tested runtime and source bytes. Earlier runs are retained separately.

The existing quick-item projection now includes the personally carried sleeping
bag. Native Use delegates to Bag.Open before the consuming inventory path, so
the rest guide retains the selected object. Boxed, detached or depleted bags
are excluded. No schema or balance changes; existing deployment rules remain.

Native GZDoom 4.14.2, Windows 11, Vulkan 1280x720, 5% audio, unpaused background,
one engine at a time. Reused #282 geometry, native commands and isolated launcher.
The fixture uses development IWAD textures; no IWAD/runtime/fixture packages or
saves are distributed. Logs and hashes are in evidence.json and evidence/.

Checks cover native previous/next/Use, repeated Use, one dialogue holding the
exact bag, unchanged quantity, actual Box storage/retrieval, combat rejection,
confirmed wall obstruction, successful deployment/standing, drop/pickup,
save/load and two hub transitions. Captures verify existing icon/name/quantity
and the live rest dialogue. Existing #282 consumable checks remain reusable.

Earlier retained fixture attempts explain failures: input-01/03 asserted a
network event after a subsequent local inventory command had already changed
selection, and closed the menu without ending the native conversation. The
fixed script waits after assertions and sends native Back. input-02 added an
invalid vector-to-string diagnostic; input-04 omitted Menu's constant qualifier.
None established a production failure. The wall check now requires no prior
blocking reason and separately verifies missing room. Independent source review
found no production defect in the focused patch.

Reproduce from this release:

```powershell
python assets/validation_5430/prepare.py --directory issue319-recheck
powershell -File assets/validation_5422/run_native.ps1 -Directory issue319-recheck -Label input -Script input.cfg
powershell -File assets/validation_5422/run_native.ps1 -Directory issue319-recheck -Label save -Script save.cfg
powershell -File assets/validation_5422/run_native.ps1 -Directory issue319-recheck -Label load -Script load.cfg -LoadGame bag.zds
```

For the author preview use the same launcher with `-Script manual.cfg
-Interactive -Language es`. F6/F7 select; F8 uses. The actual hint reflects
these preview-only bindings. The launcher preserves the author's saves/config.
