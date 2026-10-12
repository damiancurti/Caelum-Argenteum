# Issue #149 validation - 5.2.14

Baseline: main b21e0632 (accepted #148). Target: GZDoom 4.14.2, Windows 11,
Vulkan. Native runs use isolated INIs/save directories, background ticking and
5% master volume. Production data is unchanged by fixtures; packages, INIs,
saves, IWAD and executable remain local under build/issue149.

## Evidence levels

- Static: native API/dispatch source review, generated-default determinism,
  bilingual token audit, project validator and final package comparison.
- Native assertions: grouped descriptors, actual normal bindings/unbound labels,
  localized token resolution, native reset, unrelated preferences, aliases/slot
  dispatch, config/save persistence, legacy import and modal cancellation.
- Agent-operated UI: native Backspace cleared attack, middle click assigned it,
  Defaults displayed native confirmation and restored the isolated preset.
  In live-03, middle mouse opened/closed Journal and remapped F5 closed it.
  Health/Air/Anima/adrenaline stayed at 1248/1084/1249/0 during those checks;
  ordinary survival/time continued while the live Journal was open.
- Partial author acceptance (2026-10-12): in live-03 the author physically pressed
  M twice and confirmed the automap opens AND closes. This is separate from the
  remaining CA149-01 usability matrix in pending_test.txt.

## Reproduction

Run `python assets/validation_5214/prepare.py` with GZDoom stopped. Then use
`run_native.ps1 -Fixture contract -Script <script>.cfg -Label <fresh-label>`.
Use MAP01 for flow.cfg (the fixture moves to the real group-5 workbench), MAP02
for other checks. `-Interactive` enables visible mouse testing; ordinary runs
remain background/unpaused. Each label preserves its original log/run metadata.

| Script / run | Coverage / result |
| --- | --- |
| contract.cfg / contract-05, contract-final-es, contract-final-en | Group uniqueness, save/load classes, all three Use bindings and translated unbound, tokens, native reset and custom F5/mouse/controller handler paths; PASS. Final ES also verifies visual Use/Back ignore Enter/Tab gameplay remaps. |
| flow.cfg / flow-06, flow-official | Actual `slot 2` and console alias each emit exactly one authoritative event; real workshop/time skip cancellation keeps the parent Journal; PASS. |
| persist.cfg / persist-01 | Custom J/Q/F5, cleared Use, custom map mark and double Mouse3; current save/load; PASS. |
| restart.cfg / restart-01 | Restart and load the saved character with the previous INI; all remaps/cleared keys retained; PASS. |
| restart.cfg / legacy-01 | Imports the old KEYCONF normal/double sections without resetting current controls; PASS. |
| visual.cfg / visual-es-02, visual-en-43 | Native captures at 1280x720 Spanish and 1024x768 English: combat/ability labels, all-binding introduction, Journal and existing automap; inspected. |
| first.cfg / first-preset | Generated first-launch preset applies all seven approved bindings before KEYCONF aliases; PASS. |
| interactive-02 | Native clear/mouse bind/reset confirmation observed; manual exit, no automated DONE marker. |
| live-03 | Actual middle-mouse Journal transitions, F5 close, author M confirmation; manual exit, no automated DONE marker. |

Normal and double INI tables are checked separately in summary.json. The native
API does not expose DoubleBindings to ZScript hints; preserving them is distinct
from physical double-click activation coverage. Native controller names and
handler methods are checked; no physical gamepad was available to the agent.
Keyboard injection reached GUI menus but did not activate gameplay bindings
in the isolated session. This is not claimed as a physical keyboard pass or a
production binding defect; the author's M check supplies that specific evidence.

Visual captures are native engine output, not edited images. The first visual-es
captures were taken after menu closure because screenshot is deferred; those
are retained as failed capture timing. The corrected script waits after each
screenshot. Final ES and EN images show current text/layout; the later contextual
button-routing correction changes no rendering.

## Failed iterations retained

- compile-01/02: reserved identifier and protected descriptor field; corrected
  to Matches/GetAction. Subsequent compile/native runs succeed.
- contract-01: multiline console script wait chains raced startup. Scripts now
  use one sequential chain. contract-02 used an invalid Pad_LShoulder key name;
  contract-03 reused Mouse3 for two actions and expected the wrong count. Corrected
  fixtures pass; native navigation precedence is documented, not bypassed.
- interactive-01: user stopped Computer Use; test stopped and its power request
  released. No pass claimed.
- flow-01..04: initial native conversation still active; flow-05: not at a safe
  station. The final fixture ends the initial conversation and opens the actual
  workshop before testing. Production safety rules were preserved.
- visual-es: deferred screenshot timing described above.

## Scope and limits

Native Back/controller navigation keeps engine precedence. F5/Mouse3/Pad_Y
handler coverage does not imply every hardware button reaches OnInputEvent.
Compound console aliases dispatch during gameplay but are not interpreted as
live-panel shortcut bindings. Save/load screens retain native classes. No new
abilities, exploration UI, input polling, balance or save schema is introduced.

Review was performed by a separate read-only agent. It identified modal priority,
semantic Fire/Reload substitutions, native automap M marking and synthetic
button/remap conflicts; all were corrected and covered by focused checks.

## Final verification and cleanup

Final project validation reports no errors. The official build has 13,557
members, byte-for-byte equal to the tested production package. flow-official
passes against that actual release package. contract-final-en verifies active
inventory menu context and both synthetic-button regressions. See run JSON
hashes and summary.json; `python assets/validation_5214/verify.py` regenerates
the package/determinism/config checks. `--prepare-legacy` constructs the isolated
legacy INI from persist-01 for the legacy import run.

Temporary keep-awake was released at 2026-10-12T03:50:32.8666020Z;
its before/after power plan is identical. The earlier interrupted session's
release is retained separately. No test GZDoom process is left running.
