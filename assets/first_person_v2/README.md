# First-person corrections — 4.36.0d

Historical art-package record. Version labels, integration instructions and test
statuses below describe the original delivery. For current checkout setup, use
the root README.md; outstanding author checks are tracked in pending_test.txt.
Do not repeat archived resource installation on the current checkout.

Historical source record for **4.36.0d**. Current affected poses and bow art
are documented in `../first_person_v3/`; v2 records remain unchanged.

This source supplement records the author's requested grip and size corrections.
Runtime source of truth: `src/caelum/equipment/CaelumFirstPersonLayers.zs`.
The original First-person v1 PNG files remain byte-identical.

Two original transparent images were generated with OpenAI imagegen, using
the supplied hand sheet for style and the author's hand photograph for the
left bow grip. They live in `src/graphics/caelum/first_person/v2/` and are used
directly by native TEXTURES. No stock/Doom artwork or pixel-processing script
was used. `PROVENANCE.json` records their hashes and references.

`POSES.json` separates source image pivots from final runtime grip positions,
scale, hand offsets and layer order. `TEXTURES_4_36_0d.txt` is an archival copy
of the fragment already integrated into src/TEXTURES; do not load it twice.
`PROMPTS.txt` records the generation briefs and native integration choices.

Only the requested left bow hand and unarmed fists are new raster art. Existing
weapon shapes are flipped, positioned and enlarged through native layers.
The dagger and magic weapon art remain accepted as supplied. Native 4:3 and
16:9 captures were reviewed; final visual acceptance belongs to the author.
