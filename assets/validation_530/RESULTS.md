# Issue #255 / 5.3.0 - Power indicator layout

The production delta only changes drawing rectangles and their shared transform.
Seal is 88x88 and Tarot 64x96 virtual units, versus 44x44 and 32x48 on baseline
7e79bcb7. Tarot remains above Seal; captions follow the right-edge group.

Windows 11, native GZDoom g4.14.2, installed development IWAD; Vulkan,
unpaused background rendering, master audio 0.05. No engine/IWAD/package/save
is distributed. Reproduction sources are in this directory; generated evidence
is under build/issue255. Each runner record supplies exact arguments, times,
exit code and engine/runtime/fixture hashes.

Native reference runs use `probe.cfg`, an actual equipped sword and Seal, and
the existing saved Tarot state. Ready, active, cooldown, unavailable and absent
states are diagnostic fixture cases, not a claim of normal Tarot acquisition.
`baseline-ref` and `final-ref` compare 1280x720 English with the same native
HUD scale. `final-4x3-ref` is 1024x768 Spanish; `final-wide-ref` is 1920x810
Spanish. `final-large` uses 640x480 Spanish and hud_scale=8. Captures show the
complete column above retained bars and no centered-canvas drift. At the small
large-scale viewport the fit cap reduces the entire column: this is not an
uncapped 2x pixel-size claim. Current resources/art and notification area remain.

Earlier preparation runs exposed fixture errors (incorrect field names, a
protected pickup call, and an unequipped Seal). Those were corrected before
the reference runs; earlier captures are not final evidence. The original
runtime compiled independently. No gameplay repair is claimed by this patch.

Static validation and packaging commands/exit codes are recorded in evidence.json.
The reference images precede the author's correction of the delivery label from
5.2.28 to 5.3.0; only diagnostic version strings changed in the runtime afterward.
The final package is compiled and exercised by current-load-final and the live
author session. Individual package hashes remain explicit in the run records.
Save compatibility uses an engine-created baseline save loaded against the new
runtime with the same archive basename; identity and live timers are observed.
The patch adds no saved fields or migrations. Ordinary hub progression, live
window resizing and author visual judgment remain CA255-01 author checks.
The adjacent survival-debuff group belongs to separate issue #256; its combined
layout is not claimed as tested here. No author acceptance has been recorded.
