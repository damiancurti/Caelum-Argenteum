# 5.2.22 / #215 - Existing controls on menu options

Baseline: `8fc9bc80` (#216), following `7f801d41` (#213).
Target: GZDoom 4.14.2 / Windows 11 / Vulkan, 2026-10-12 local date.
The author requested existing keyboard controls in parentheses throughout
Caelum and native engine menus, without new direct shortcuts.

## Native evidence

All five contract runs finish with `CA215 DONE failures=0`:

- `menus-input-final`: native key-capture opening/abort; remapped calendar
  priority; Enter and wheel bindings suppressed when menus consume them;
  unbound action text; click on the appended Yes hint selects Yes.
- `menus-es-final`: Spanish, 1280x720, default and native UI scale 3.
  Current Journal K/time-skip U captions, contextual conflicts, Journal notice
  click, actual Truco/Trucazo start clicks and pause ownership, creator Next
  click, temporary decoration/restoration of sound/video/controls/comfort.
- `menus-en-final`: same contract in English at 960x720 (4:3), including
  enlarged creator and native options. Complete captions fit in inspected
  crafting, card, creator and native option captures.
- `menus-coverage-final`: Save/Load keep native types and saved titles across
  real render frames; two submitted searches return 21 and 15 rows; source
  labels remain undecorated. Actual Palomo conversation retains its reply map
  and displays numbered hints. Appearance and confirmation captures included.

`menus-title-final` captures the main menu, options and creator from a fresh
title screen. Captures preserve the existing artwork. Its title-screen log
does not include ConsoleProcess messages, so evidence is its exit code and
the three inspected captures, not an assertion count.

The coverage/title runs precede the final wheel/Pad_Start hint filter. Their
tested wrappers, save/search/dialogue/creator rendering did not change afterward;
the final input and ES/EN contract runs cover the revised shared filter. Run
JSON files retain the actual runtime and fixture hashes for each run.

The final checkout check, `menus-checkout-final`, repeats the 10 input
assertions after normalizing LANGUAGE to its required Git LF format and
regenerating its byte-hash index. Only line endings and the corresponding
localization-index metadata changed from the preceding runtime; all menu code
and localized strings are identical. This prevents a stale index after checkout.
The official-package comparison uses this final, successfully tested runtime.

## Scope and limitations

These are isolated native engine checks, not author acceptance. The fixture
calls menu events and mouse handlers at scaled coordinates. Search populates
the native text editor buffer and submits through the native input callback;
it does not synthesize physical keyboard events. Key capture opens and aborts;
physical rebinding/clearing remains in CA215-01. Representative native menus
were exercised; specialized menu inheritance was also statically reviewed.

Early fixture attempts exposed read-only native event fields, private text
methods and the engine's prohibition on key-binding writes from ConsoleProcess.
Those attempts are not passing evidence. A fixture-only Result/result shadow
initially reported a false confirmation failure; explicit self.Result repaired
the assertion. Final logs contain no such errors. No production test hooks,
gameplay changes, personal INI edits, executables, IWADs or saves are included.

The read-only cross-review found native-navigation/calendar precedence and
confirmation hit bounds; all were corrected. The wheel/Pad_Start follow-up
was corrected and the wheel case was checked natively. Native background tests
use 5% master audio with background pause disabled.

## Reproduction

Run `python assets/validation_5222/prepare.py`, then run `run_native.ps1` with
`-Fixture contract -Script interaction.cfg`, `contract.cfg` or `coverage.cfg`.
Use a unique `-Label`; select `-Language es` or `enu` and optional dimensions.
For title captures use `-Fixture compile -Script compile.cfg -TitleScreen`.
The helper defaults to the locally installed engine and development IWAD;
pass `-Engine` and `-Iwad` for another installation. Generated packages/configs,
saves and full development attempts stay under `build/issue215`.

Current author checks are in root `pending_test.txt`: CA215-01 for this patch,
plus earlier CA213-01 and CA216-01. None has been reported passed yet.

## Delivery checks

`python validate_project.py` passed with no errors. Dialogue/localization and
long-document indexes were regenerated and checked. `build_dev.ps1` passed;
all 16,053 members in the official development package are byte-identical to
the final tested production package (`package-match.json`). There are 95 native
assertions across the five selected contract runs, all passing.

The temporary keep-awake request was released successfully and the power plan
is unchanged (`power-request.json`). Existing #213/#216 author checks remain
pending. Unrelated local source-art deletion and legacy test configurations
were preserved and excluded from this delivery.
