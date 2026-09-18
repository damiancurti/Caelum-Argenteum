# Weapon corrections — 4.36.0f

Target: GZDoom 4.14.2. The active implementation is in src/TEXTURES and
src/caelum/equipment/CaelumFirstPersonLayers.zs.

Four original imagegen edits broaden the greatsword blade while retaining
the original three material tiers, blue handle and painted style. The PNGs
are copied unchanged from generation. Native TEXTURES crops the first-person
atlas; the three original icon paths now contain the updated icons.
PROMPTS.json records source references and briefs. PROVENANCE.json records
exact output hashes. Historical v1 masters and unused v1 composites are
retained as source history; active greatswords use D091–D093 and the v4 atlas.

The bows retain their v3 PNGs, recolored with native Blend. DH11 crops the
original left thumb; the whole hand is drawn behind the bow. EBST uses native
vertex offsets instead of rotating an anisotropically stretched pixel.
EBAN is drawn last, on layer 53. No stock/Doom artwork is introduced.

All active modular textures use NoTrim and absolute pivots derived from
their Offset and XScale/YScale declarations. Positive PSprite rotation is
counterclockwise on screen in the 4.14.2 renderer; scaling follows rotation.
POSES.json records presentation data. VALIDATION.json records local checks.
Reconstructed previews are diagnostic images, not engine screenshots.
The patch has not been compiled or played in GZDoom in this environment.
