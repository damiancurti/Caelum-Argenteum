# Corrections from the annotated reference — 4.36.0h

COMPOSITION.json records the exact clockwise flail rotation, grip and the
bow foreground mask. The red upper index area belongs behind the bow. The
blue bow segment belongs behind the thumb and remaining finger phalanges.
Existing artwork, palettes, hand size and arrow ordering are retained.

PREVIEW_FLAILS.png compares 0g (top) and 0h (bottom), tiers 1–3.
PREVIEW_BOW.png compares the previous and corrected left-hand composition.
These are reconstructed native TEXTURES/PSprite views, not engine screenshots.

VALIDATION.json covers structural/resource checks and scope preservation.
LOGIC_VALIDATION.json describes damage and food-allocation tests using
translated production method bodies with mock inventory APIs. These checks
do not compile ZScript or validate native ownership/save behavior.

No PNG source artwork was modified. No GZDoom execution was performed.
The static-weight formula in docs/SYSTEMS.md is a proposal, not active code.
