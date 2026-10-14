# Issue #235 - Multiple tracked missions

Current-objective marker follow-up (2026-10-14, CA235-02): after accepting the
previous tracking interface, the author requested a spatial symbol restricted
to already-known destinations. Existing native POI markers now use the owned
HUD target icon for the active tracked stage and restore their ordinary symbol
when that stage changes, tracking stops or the mission finishes. The shared
stage selector is read-only across UI/play scopes; no saved fields are added.

`targets_evidence.json`: three corrected GZDoom 4.14.2 runs passed **104
assertions**, **two full resolved-record save comparisons** and **three inspected
captures**. The preceding runtime reproduces **12 expected failures**. Coverage:
known Argento to unknown/then-known Caella, automatic stage changes, two known
destinations for one stage, preservation of other tracked missions, untracking,
completion, marker texture/size/observed coordinates, rotation, old/current
save loading, foreign-map suppression and hub return. CA235-02 passed author
review on 2026-10-14; CA235-01 stays accepted.
Runtime SHA-256: `27081ed0b4059a12bcf9c5ed3868b4ab8094cd1a15698774d3c862d395f9d742`.

Static validation and normal packaging passed (16,071 files on this #235 branch).
Every uncompressed normal-package member equals the isolated final runtime.
Only four runtime source members differ from the accepted baseline after text
line-ending normalization; the save comparison resolves object references and
case-insensitive native field names. The initial flow used generic output save
names; the selected final run preserves names per run. Stage/knowledge events
are diagnostic preparation, not normal campaign traversal or a new multiplayer
certification. Earlier frozen packages/saves remain separate. Reproduce with
`targets_prepare.py`, `targets_run_native.ps1` and `targets_collect.py`; physical
handoff: `targets_handoff.ps1` / `Probar235Objetivo`.

CA235-02 (origin 5.3.8 / #235) passed author acceptance on 2026-10-14.
The author confirmed, "Estas pruebas dieron muy bien." The three presented
steps covered Argento/Caella stage changes, absence of an unknown destination
and appearance after recording it, Track/Untrack and save/load, then completion
restoring the ordinary place symbol. No failures or qualifications were reported.
Session author-20261014-102654 used the final frozen runtime SHA-256
27081ed0b4059a12bcf9c5ed3868b4ab8094cd1a15698774d3c862d395f9d742
and exited with code 0. This author confirmation is separate from the scripted
native evidence; no runtime change or version increment accompanies it.

CA235-01 (origin 5.3.8 / #235) passed the remaining author checks on
2026-10-14. The author explicitly confirmed: "Todas las pruebas esas ya las hice
y dieron correcto." Long bilingual objectives and scale, known versus unknown locations, saved notes/discoveries, reward neutrality and detailed terminal history passed.
This completes the previously partial acceptance, with no reported failures or
qualifications beyond optional hardware applicability. Technical evidence remains
separate; this records author confirmation, not a new instrumented run.

Earlier validation and staged acceptance records follow; pending labels below
describe those earlier checkpoints and are superseded by this confirmation.

Version 5.3.8, 2026-10-14. Baseline fc947471 (#234), branch
`feat/issue235-quest-tracking`. CA235-01 author usability acceptance is partial.
No new manual session was launched during the author's absence. After return,
Probar235 session `author-20261014-080756` opened on 2026-10-14 with runtime SHA-256
`15ff167152e296fc701213ea1d2f49da9518d2a1c2e8fa4cf4bdf90322b87a97` and copied
diagnostic save SHA-256 `20823e86a2b16748a002116d32e62bb563e67f4ea071b4571d6a73ef06df1c4a`.
Startup succeeded. This reuses the tested mission fixture, whose MAP01 tracking
paths are unaffected by #234's subsequent gate artwork/factory corrections.
It does not retest those city changes. On 2026-10-14 the author confirmed all four
presented steps passed: independent T/button tracking and held-key latch; several
map selections with independent removal; filters/detail/Back and saved choices;
terminal objectives leaving the map while remaining in history. The final run
exit code was not captured, so no exit-code success is claimed. Remaining
presentation, knowledge, note/reward and detailed terminal-text checks stay in
CA235-01; physical acceptance is separate from the native matrix below.

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
`handoff.ps1` opens Probar235; the terminal stays available to repeat the author test.
