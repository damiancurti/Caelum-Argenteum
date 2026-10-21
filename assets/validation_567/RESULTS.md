# V5.6.7 / #387 — individual clothing object artwork

All 25 native garment types have distinct original 128x128 RGBA inventory/crafting
icons and ground sprites. The type-to-art mapping also resolves unacquired actor
arguments. The transient local cache validates the actual sprite/frame because
GZDoom can restore Spawn when dropping the same native object.

This is an object-art stage: worn-character, character-preview and first-person
coverage remain unfinished under #387. CA387-01 is pending author visual review.
It changes no garment mass, recipe, price, warmth, size or saved entitlement.

The pinned Pillow 11.3.0 exporter reproduces all 25 images, the TEXTURES aliases,
source/output manifest and contact sheet byte for byte (28 files). Source images,
exact image_gen prompts and generation identifiers remain in assets/art_source/clothing.
Only technical alpha cropping/resampling/packing is performed by Python.

**12 native runs / 293 passing assertions, zero failures**, including ten runs
on the final package and two preserved original-runtime recovery checks.
Static validation, normal packaging and all 16,425 source/package members agree.
Both the contact sheet and final native Journal/ground captures were reviewed.
Independent static review found no outstanding P1/P2 for this object-art stage.

Native evidence is collected by collect.py. Tests target all 25 sprite/texture
registrations, inventory/crafting agreement, native drops, reacquisition and its
following ownership tick, unacquired HC/BS pickups before and after capacity
rejection, five sizes with saved moisture, actual 5.6.6 saves, current reload,
hub/non-hub travel and the preserved original save/runtime recovery pair.
No new rendering-performance or campaign-gameplay acceptance is claimed.
The accepted #386 gameplay evidence remains in validation_566.

Reproduce with `python assets/validation_567/prepare.py`, build to
`build/issue387/current/caelum_argenteum_dev.pk3`, then use run_native.ps1 with a
unique `-Label`, `-Checks` and `-Script suite`, `save`, `verify`, `travel`,
`upgrade`, `upgrade-verify`, `ui-es` or `world`. Load ca387-current.zds for current
checks; upgrade uses the preserved actual ca386-current.zds and writes
ca387-upgraded.zds. The fixture reuses #386's room and checkpoint definitions.
The baseline-upgrade script additionally loads the actual 5.5.8a save.
The two rollback checks use validation_566/run_native.ps1 and the preserved
5.6.6/current and 5.5.8a/baseline packages, not a recreated old fixture.
Native runs are sequential, unpaused in the background, with 5% audio.
Private fixture PK3s, saves, IWAD and executable are not distributed.

Early runs are retained separately from final evidence. suite-01 used a sprite
lookup without its Actor receiver; suite-04's diagnostic used incompatible
conditional types. suite-02 exposed the real drop-cache defect corrected in
runtime. suite-03/05 tested the native hidden inventory sprite before its next
tick; the final fixture checks reacquisition identity/icon immediately and
the refreshed derived presentation after five actual engine tics.
