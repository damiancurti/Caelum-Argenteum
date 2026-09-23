# Native weapon corrections — 4.36.0g

Historical art-package record. Version labels, integration instructions and test
statuses below describe the original delivery. For current checkout setup, use
the root README.md; outstanding author checks are tracked in pending_test.txt.
Do not repeat archived resource installation on the current checkout.

Runtime definitions live in src/TEXTURES and CaelumFirstPersonLayers.zs.
COMPOSITION.json records source crops, anchors, scales, layer order and
palette recipes. VALIDATION.json records checks and explicit runtime limits.

No bitmap artwork was edited. Axe/halberd parts and bow finger masks are
native crops of the original v1 sprites. The greatsword retains its v4
silhouette; bows retain their v3 silhouettes. Native nested Graphics perform
desaturation followed by RGB multiplication. Three byte-identical raw icon
copies provide independent sources for the public-path Graphic overrides.

PREVIEW_COMPARISON.png shows 0f on the left and 0g on the right.
PREVIEW_BOW_GRIP.png shows the foreground finger-mask change.
These are reconstructed diagnostics, not GZDoom screenshots. The temporary
renderer follows native transform order but does not implement sector
lighting, viewport placement, filtering or engine animation/interpolation.
All three tiers and all bow phases were inspected separately as well.

This source delta has not been compiled or run in GZDoom. The complete
project and Windows 11 runtime checks remain required.

Implementation references, official g4.14.2 source:
- https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_weapon.cpp
- https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/textures/multipatchtexturebuilder.cpp
- https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/textures/multipatchtexture.cpp
- https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/textures/texturemanager.cpp
- https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/textures/bitmap.cpp
- https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/textures/bitmap.h
