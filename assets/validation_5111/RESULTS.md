# 5.1.11 / #156 - Time-skip input repair

Baseline: fe5ba743, stacked on #154 / PR155. Windows 11, GZDoom 4.14.2,
Vulkan, 1280x720, background unpaused, master volume 0.05.

## Diagnosis and change

The protected `craft-tiempo` checkpoint has an open, completed time-skip panel,
no active crafting task, target local day 0 / 01:24 and CA_SKIP_FUTURE. The
current clock is already later. Enter's rejection is valid: it cannot repeat
the completed task or skip backward. The author confirmed that physical Tab
closes this baseline panel; input-probe-e records its raw scan 15 / character 9
and the resulting ca_skip_cancel network event.

Q and R only checked InputEvent.KeyString. GZDoom 4.14.2 constructs that field
from the physical scan code, while KeyChar contains the ASCII character:
[FInputEvent constructor](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/engine/d_event.cpp)
and [Windows keyboard mapping](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/platform/win32/i_keyboard.cpp).
Q is scan 16 / character 113; R is scan 19 / character 114. Both now accept
KeyChar, including uppercase, consistently with other project panels. Native
InputProcess delegates to the shared Key dispatcher; state still changes only
through the existing network events. No time policy, crafting transaction,
balance or serialized schema changes.

## Native evidence

`regression-final` runs the production dispatcher from a fixture RenderOverlay,
with empty KeyString and real character/scan values, then observes native
network processing and state transitions in the protected author checkpoint.
21 checks pass: completed-panel close, completed work and inventory retention,
uppercase letters, Tab/controller B, R refresh, arrows, past rejection without
time advance, future execution, active stop then close, pending confirmation
cancel and release/Escape/console pass-through. These are callback/state checks,
not synthetic OS input or physical keyboard acceptance. The fixture does not
start a new real crafting recipe; partial-task experience remains an author check.

`reload-final` loads its newly saved result in the final package: closed panel
and completed crafting persist (two checks). Both runs exit 0 without script
errors or VM aborts. Final package, source, original/protected save hashes and
raw run records are in RESULTS.json and this directory. No original save is
rewritten. Baseline `input-probe-e` also loaded that checkpoint successfully.

Earlier diagnostic attempts remain local under build/issue156. Automated Windows
Q/Enter/Tab/Escape did not reliably reach native input, even after activation;
these runs are not passing keyboard tests. input-probe-a had ineffective CRLF
instrumentation; input-probe-c aborted in the observer because a user CVar was
queried without a player argument. Both fixture defects were corrected; neither
is a production failure. The owned diagnostic processes were stopped explicitly.
regression-fixed-a and reload-fixed-a passed before diagnostic release strings
were updated; final runs verify the delivered package. Initial static validation
identified stale release labels, an overlong context and this then-unwritten
result link; final validation is recorded separately.

## Reproduction and limits

Use the existing local engine/IWAD, preserve the original checkpoint and package
under build/issue156, and retain the package basename caelum_argenteum_dev.pk3.
prepare.py builds deterministic isolated addons and the instrumented baseline;
run_native.ps1 rejects overlapping GZDoom processes and records command lines,
configuration and hashes. checks.zs / reload.zs never ship in src. Final run JSON
contains the exact arguments and console scripts; the check save names are
ca156-final / ca156-final-reloaded. Static validation: validate_project.py and
git diff --check. Document index regenerated.

The temporary thread-scoped keep-awake request is released after native testing;
no power plan is changed. The release record is included. Development executables,
IWAD, saves, engine source excerpts and packaged fixtures are not distributed.
The unrelated author deletion of assets/art_source/Caelum Argenteum.png is excluded.

Author evidence on 2026-10-10: physical Tab closes the pre-fix checkpoint. This
does not accept corrected Q/R. CA156-01 remains in pending_test.txt, alongside
CA154-01/02. #154 / PR155 and #156 remain open for review; no merge implied.
