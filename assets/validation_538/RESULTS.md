# Issue #235 - Multiple tracked missions

Version 5.3.8, 2026-10-14. Baseline fc947471 (#234), branch
`feat/issue235-quest-tracking`. CA235-01 author usability acceptance is deferred
until return. No new manual session was launched during the author's absence.

Static validation and normal packaging passed. Thirteen native runs passed
114 assertions; 18 save comparisons and 19 inspected captures are recorded.

The native matrix verifies independent saved choices, idempotent desired-state
events, native Journal key/button actions and both filter headings, reserved-key
priority, Back/detail behavior, known versus unknown/off-map places, future/secret
negative cases and terminal history. Spanish/English captures use 1280x720,
640x480 and 1680x720 with native uiscale 4. Long text is bounded above resource
bars; full objectives remain in paginated detail. Saved notices can retain the
language in which they were originally recorded; objective labels localize anew.
The first large-scale capture left no room for even the tracked-count notice.
The final cartouche locally fits that notice above the bars without changing the
native preference; the affected large-scale capture is repeated and inspected.

Two genuine 5.3.7 save copies cover six known POIs and a saved manual note.
Migration adds only revision-one tracking and 32 false selections. Every prior
character-record value, native Automap object and linedef survives. Tracking
changes only QuestTracked; a current reload retains the whole record. Hub return
retains all other record values except four legitimately persisted live survival
and thermal observations, explicitly named in collect.py. Other-map facts are
not copied into discoveries on the current map.

The first diagnostic reproduced legacy UpdateLessons activating the main slot
before Palomo and exposing future lesson flags. The read-only catalogue now uses
recorded guidance and authored stage constants; the underlying controller and
stored progress remain unchanged. Main-01 is retained as failing evidence.
Another early port test incorrectly expected an active siege in the quiet city.
The final test first proves the quest absent, then invokes the production
calendar deployment action in this disposable copy and observes its real sealed
encounter. A short capture preceded the rendered automap; the final capture
explicitly checks visible native map state and waits for rendering.

Terminal/rescue/stage cases prepare isolated records; they do not claim ordinary
campaign completion. Existing optional mission movement, one-time receipt,
prerequisite and abandonment rules also execute without tracking changing them.
Native UI actions are dispatched through the actual menu handlers; physical
mouse/keyboard usability remains the author's separate test. No full battle,
multiplayer gameplay or physical-controller certification is claimed.

All selected commands, runtime/fixture/save fingerprints, assertions, comparisons
and captures are in evidence.json. Earlier unaffected cases are reused only
across checked archive-member differences: the already-known practice-room
association, the zero-row cartouche fallback, null-safe menu latch cleanup and
a saved-field comment. Later-stage, large-scale and final navigation cases
exercise affected paths; positive-budget cases do not enter the fallback, and
stored quest/runtime logic is unchanged. Native runs use
GZDoom 4.14.2 on Windows 11, isolated INIs, background
simulation and 5% audio. No reveal cheat is enabled.

Static commands: `python build_dialogue_index.py build`,
`python build_document_index.py`, `python validate_project.py`, and
`powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1`.
Normal packaging is compared member-for-member with the frozen tested runtime.
Local generated packages, engine/IWAD and original saves remain untracked.
`handoff.ps1` prepares Probar235 for the author's return; it is not auto-launched.
