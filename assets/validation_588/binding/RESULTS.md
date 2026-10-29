# #411 production model binding correction

The author accepted the enlarged dimensions and other terminal checks on
2026-10-25, but reported a miniature tent inside. MODELDEF slots overlay meshes;
the old and new models shared one block (CA-KP-009). The corrected definition uses
one single-slot block per sprite frame. No geometry, balance, collision or saved
data changes. The earlier gallery subclass bypassed the production definition.

Before/after native runs each initialize the real enlarged and legacy actors;
the six retained front/side captures show the old overlay and its correction.
The fixed package differs from the previously tested full package only in
MODELDEF; all 16,857 members match src. Existing functional/save evidence remains
applicable. Hashes, commands and environment are retained in report.json and
run records. These are visual/initialization checks, not FPS or full issue acceptance.

CA411-TENT-01 remains pending only for the corrected visual. No existing model or
inventory artwork was removed. Logs preserve content with whitespace normalized;
raw originals remain in the local build directory.
