# Issue #148 / 5.2.13 validation

Target: GZDoom 4.14.2 on Windows 11. Baseline: 74c31ca5 (accepted #195).
Author visual acceptance is **pending CA148-01**, separately from these agent checks.
No test IWAD, executable, save or fixture PK3 is distributed. Native run records
retain engine/package hashes, arguments and timing. Tests use background ticking
and 5% audio; the temporary thread-scoped keep-awake request does not change the
power plan and is released after testing.

## Face/hair extension

The author expanded the same unaccepted #148 patch with four faces, four
hairstyles and six hair colors for each human/goblin/Caelith sex. The delivered
extension uses appearance revision 2 and separate head/body composition.
The original evidence below remains the initial delivery's record.

| Run / check | Scope | Result |
| --- | --- | --- |
| details-contract-02 | All 96,768 head textures; editor draft/cancel/confirm; invalid packed choices and stale serial; current save/load; teleport interpolation | PASS |
| details-restart-03 | Cold load retains face/hair, revision and single visual head | PASS |
| details-revone-01 | Actual initial 5.2.13 save preserves tone/form, defaults missing face/hair, saves again | PASS |
| details-travel-02 | Cold load and MAP02/MAP03/MAP02 round trip; one head; map sort override with global compat_spritesort=true | PASS |
| details-profile-01 | Revision-0/1 initialization, idempotence, copying, structural values, resources and committed-profile bridge protection | PASS |
| details-creation-01 | Creator selects tone/face/style/color; real mouse clicks through introduction; new game consumes draft once and preserves previous profile | PASS, exit 0 |
| details-clicks-02 | Actual mouse selection of hair/face/color, keyboard changes, mouse rotation/walking | Agent walkthrough passed; terminated after inspection, not an automated exit-0 run |
| details-world-02 | Front/side/back, long hair overlap, goblin and corpse snapshot; global sort preference cannot change effective map order | PASS, inspected |
| details-poses-01 | Native held crouch and attack captures; teleport API interpolation and controlled FloorClip propagation | PASS, inspected |
| details-layout-en-02 | EN 1024x768 idle/walking layout; all four rows readable | PASS, inspected |
| details-official-01 | Official PK3: head catalog plus original world/hands/gloves/voice checks and full editor/save contract | PASS |
| DETAIL_PACKAGE.json | All 13,555 official package members compared with tested production | Identical content |
| DETAIL_DETERMINISM.json | Repeat detail generator with Pillow 11.3.0 | All 3,843 outputs identical |
| DETAIL_STATIC.json / DETAIL_ASSET_CHECK.json | Project/index validation and 7,191 module hashes | PASS, no errors |

The extension's raw logs and run metadata are retained under `logs/details-*`.
Native captures use `captures/details-*.png`. The four `*-board.png` images are
technical registration sheets, not engine screenshots: they cover the face/hair
joins and all eight views for the six humanoid race/sex identities. Agent visual
inspection passed; final artistic acceptance remains with the author.

Read-only cross-review verified native scale/offset, crouch and sprite-sort
semantics and identified missing Prev/FloorClip propagation, which were fixed.
MASTERNOSEE preserves reflected/portal views by engine code inspection; a
physical mirror capture and full multiplayer are not claimed. Lookup coverage
does not benchmark every combination's GPU cost. The temporary keep-awake request
is thread-scoped; its final release at 2026-10-12 02:55:46 UTC is recorded in
power-request-finish.json. The before/after power plans match.

Failures retained: details-compile-01 had a parenthesis error;
details-compile-02 used private/unsupported actor render fields, replaced by
native A_SetRenderStyle/GetRenderStyle. details-contract-01 used waits too short
for deferred network events; -02 separates dispatch and explicitly verifies
after load. details-restart-01/02 supplied a path rather than the save basename.
details-travel-01 found a real duplicate head on hub return; modules now discard
themselves when they are not body.AppearanceHead. details-world-01 exposed the
legacy sprite-sort reversal; the map-level native override fixes it. The first
EN layout capture changed pose before the deferred screenshot; -02 separates
capture from the next UI event. details-clicks-01 was stopped by the author with
Escape; that interrupted run is not a pass. No runtime cursor fix is claimed.

Reproduce with prepare.py, then run_native.ps1 and the correspondingly named
fixtures/configs. Native -loadgame expects a basename inside the configured
savedir. Run details.cfg before details-restart.cfg/details-travel.cfg; if the
save was made by the official package alias, use that same RuntimeAlias on load.
Source PK3s, IWADs, executables and saved games remain local and are not committed.

## Initial delivery evidence

| Run / check | Scope | Result |
| --- | --- | --- |
| hands-compile-01 | Saved authority, idempotent appearance initialization, copies, resources, default/new-character bridge, voice sex | PASS |
| runtime-final-01 | All 19,488 world texture registrations; 42 look/voice combinations; hand families; owned/broken/boxed/unequipped gloves; preserved resources and fallback pivots | PASS |
| transactions-02 | Real editor cancel/confirm, stale serial and invalid range, same-session save/load | PASS |
| restart-02 | Engine restart with conflicting global/new-character color preferences | PASS |
| travel-01 | MAP01 to MAP02 retains saved appearance and authority | PASS |
| legacy-save-01 / legacy-migrate-02 | Actual 5.2.12 save loads with default tone/form and can save again | PASS |
| retained-03 | Open editor then load: engine clears retained UI reference; no cosmetic commit | PASS |
| replaced-01 | Same pawn and serial, different profile: old editor confirmation rejected | PASS |
| creation-02 | Native creator option/preview keyboard callbacks, allocations and new-game transfer; real mouse clicks through introduction; independent previous profile | PASS |
| visual-02 | Actual equipment service equips/unequips gloves, shield, bell, bolas, shotgun; corpse snapshot survives live profile mutation | PASS |
| after-final-es-02 / after-final-en-01 | Native preview/layout: ES 1280x720 and EN 1024x768 | PASS, inspected |
| after-final-es-03 | ES 1280x720 with native uiscale 2 | PASS, inspected |
| visual-final-01 / world-final-01 | MAP02 first-person equipment and chase-camera world body on final resources | PASS, inspected |
| official-smoke-01 / PACKAGE.json | Official PK3 runtime matrix and all 9,712 package member bytes against the tested package | PASS |
| DETERMINISM.json | Repeat both Pillow 11.3.0 generators | PASS: 3,355 outputs byte-identical |

The final official package smoke, static validator and asset hash report are
stored alongside the collected logs. Texture registration coverage is not a
measurement of rendering cost for every composition. Full multiplayer and a new
animation catalogue are outside this issue. Shared pose/wardrobe limits are
explicitly documented in ASSETS.

Native screenshots cover the old creator, final creator/summary, walking preview,
and actual first-person hands. In interactive-01, agent-operated mouse clicks
selected a different beast form, rotated and animated the preview, then cancelled;
actual hands retained the original jaguar. That exploratory run was intentionally
terminated after observation (exit -1), not labeled an automated pass. Keyboard
callbacks pass in creation-02; this is distinct from physical keyboard acceptance.
Creation-02 completed with exit 0 after two real introduction clicks. No preview
actors are spawned and no state actions/sounds are executed by the UI walker.

## Failures and corrections retained as evidence

- Early prototype registry syntax and clearscope sprite lookup failed compilation;
  registered Actor state references replaced the unsupported lookup.
- Source masking initially recolored Caelith hair and walking rig joints showed
  gaps. Green-keyed heads/hands and an authored shared walking body corrected them.
- Physical preview/world scaling now derives from measured standing alpha height.
- Corpse profile rebinding, fallback grip pivots and shield phase changes were
  reviewed and corrected before final tests.
- transactions-01 used unqualified Menu key constants in the fixture; corrected.
- restart-01 passed an absolute save path that the engine prefixed with savedir;
  restart-02 uses its basename.
- legacy-migrate-01 used colliding fixture include names; each fixture now has a
  unique include path, and legacy-migrate-02 passes.
- visual-01 confused character size tier with equipment-size index. The fixture
  now calls the existing conversion; visual-02 passes real equip actions.
- creation-01 attempted new-game start from a global UiTick callback, which the
  engine rejects. Creation-02 uses actual menu clicks for that transition.
- retained-01/02 incorrectly required a surviving UI reference after load; the
  engine clears it. retained-03 observes that lifecycle, while replaced-01 tests
  an actually retained editor against a replacement profile with the same serial.
  UI failures now contribute to the fixture summary, in addition to the runner's
  independent rejection of any CA148 FAIL line.
- after-ui-01 / after-final-es-01 had deferred screenshot timing; the final scripts
  wait after each screenshot before changing the menu. They are not final captures.

## Reproduction

### Cursor follow-up, 2026-10-11

The author reported an invisible cursor in fullscreen MainMenu, Options and
character creation. Clicks still worked; Alt+Enter restored visibility.
This is an unresolved author-reported issue, not a passed appearance check.

- cursor-before-fullscreen-01 and cursor-before-title-01 started MAP01. The
  latter exposed a fixture error: -skill enables GZDoom autostart even without
  +map. TitleScreen now omits both. Neither run proves title-screen behavior.
- cursor-before-title-02 starts on the title screen. Fullscreen computer-use
  captures did not reliably reflect subsequent game frames; a captured native
  cursor alone does not establish what was visible on the physical display.
- cursor-refresh-01 reassigns vid_cursor=None and opens the creator. The author
  reported recovery, but the log also records fullscreen=false/true transitions;
  the result cannot distinguish cursor refresh from the Alt+Enter workaround.
- cursor-refresh-isolated-01 disables Alt+Enter only in its disposable config.
  Both logged phases remain fullscreen=1/cursor=None, ten seconds apart. The
  author reported the cursor was already visible from startup. No regression
  or recovery was reproduced; DONE failures=0 only confirms fixture completion.

All five processes exited normally. Selected reproducibility metadata and raw-log
hashes are in CURSOR_DIAGNOSTICS.json; full logs are retained under logs/.
The user's config was copied, not edited; only the copy enables background
ticking/audio at 5%. No production cursor workaround was added. The prior
keep-awake request remained released; these probes did not change the power plan.

Read-only cross-review checked g4.14.2 d_main.cpp, i_system.cpp, i_mouse.cpp,
menu.cpp, c_cvars.cpp and common/scripting/interface/vmnatives.cpp. Reassigning
vid_cursor recreates the native handle but does not repair ShowCursor/capture
state. Native CVar writes from ZScript require the engine's menu-input context;
UiTick/Ticker/Drawer alone do not provide it. A speculative per-frame refresh
would therefore be inappropriate. The PNG remains 32x32 with hotspot (31,7).

### Existing appearance probes

Run `python assets/validation_5213/prepare.py`, then the matching cfg/fixture with
`run_native.ps1 -Label <new-label> -Fixture <name> -Script <name>.cfg`.
Use unique labels to retain earlier diagnostics. Current saved-game probes load
`ca148-current.zds` created by transactions.cfg. Legacy migration copies baseline
then production into the same local legacy-runtime.pk3 filename and additionally
loads the legacy fixture, preserving the save's dependency names.
Creation-02 uses creation-interactive.cfg and `-Interactive`: click twice through
the introduction before its 100-second completion window. Do not invoke native
new-game start from a StaticEventHandler. Build outputs remain under build/issue148.

Run `python assets/validation_5213/verify_assets.py`, the project validator and
the normal build. Optional art regeneration requires Pillow 11.3.0; use the two
appearance generators and compare their registration hashes. Runtime does not
require Python or Pillow. Retained source prompts and discarded atlases are art
provenance, not accepted final alternative selections.
