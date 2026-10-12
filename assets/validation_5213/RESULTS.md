# Issue #148 / 5.2.13 validation

Target: GZDoom 4.14.2 on Windows 11. Baseline: 74c31ca5 (accepted #195).
Author visual acceptance is **pending CA148-01**, separately from these agent checks.
No test IWAD, executable, save or fixture PK3 is distributed. Native run records
retain engine/package hashes, arguments and timing. Tests use background ticking
and 5% audio; the temporary thread-scoped keep-awake request does not change the
power plan and is released after testing.

## Final evidence

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
