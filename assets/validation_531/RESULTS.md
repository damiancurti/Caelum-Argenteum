# 5.3.1 / #256 validation

Implemented and validated on Windows 11 / GZDoom 4.14.2 (Vulkan, RTX 3070 Ti).
Baseline: commit `12f9b979`, release 5.3.0. Complete runtime, engine, config and
fixture fingerprints, arguments, timestamps and exit codes: [evidence.json](evidence.json).
All eight retained native runs exited 0; 40 explicit native assertions passed.

| Run | Evidence |
| --- | --- |
| final-es | Sword, crouched sword, tier-3 carbine, staff, fists, utility staff and bolas; change equipment before any attack; four-region asymmetric/broken armor; no Toughness in resistance; low/critical hunger, thirst and sleep, heat/cold, recovery and notification coalescing. |
| final-en-small | English, 640x480, HUD scales 1 and 8; Character and simultaneous debuffs. |
| final-es-wide | Spanish, 1920x810, HUD scales 1 and 8; Character and simultaneous debuffs. |
| baseline-save | A real 5.3.0 save containing power/equipment identity, adverse resources and an existing notification inbox. |
| current-load | Load that original save in 5.3.1; silently initialize notification revision 1 and reconstruct current readouts. |
| current-reload | Reload a separate 5.3.1 save; history stays at two pre-existing entries, without replaying adverse-state messages. |
| final-hub | Isolated native MAP03 -> MAP04 -> MAP03 hub round trip; history stays at six entries, equipment identities and state survive. Thermal cooling correctly changes the live message without appending a replay. |
| rollback-old-save | Reopen the untouched original in 5.3.0; verify equipped weapon, Seal and Tarot identities. |

Representative Spanish native chances: sword 15.609184%, crouched sword
31.218368%, tier-3 carbine 24.359184%, staff 16.165900%, fists 0%. Incompatible
categories are Not applicable. The mean-armor test uses one intact magical
piece, one broken piece and two unarmored regions; changing Toughness alone
does not change the readout. The five essence labels expose the existing shared
magical defense, without adding elemental mechanics. Body-region mean is a
presentation choice approved by the author; resistance excludes Toughness.

The maintained gameplay change only extracts the existing five critical
calculations into shared queries; their random streams, order, caps and factors
are preserved. Evasion reads the current capped gameplay value. Native fixture
checks query state without attacking, while the source diff verifies that the
actual attack paths call those same queries. This is not a new combat-balance audit.

Reviewed PNGs show the requested HUD ordering, all Character information,
unsupported/unarmed categories, adverse states, languages and viewport fitting.
Capture scripts use engine console events in isolated fixtures; they do not
claim a scripted screenshot is an ordinary-input author test. The interactive
handoff ran separately as `author-01` with its visible PowerShell terminal left
open, unpaused background simulation and audio 0.05. No keep-awake request was used.

Static checks: `python build_dialogue_index.py build`,
`python build_document_index.py`, `python validate_project.py` (5.3.1, no errors,
CONTEXT under 2,500 words), normal `build_dev.ps1` (16,054 packaged files), and
`git diff --check`. No development IWAD, executable, generated PK3 or save is
included in this evidence directory.

Reproduce with `python assets/validation_531/prepare.py`, then
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_531/run_native.ps1`
and the retained run's label-independent arguments. Choose a new label to
preserve prior evidence. GZDoom exec waits are chained on one generated line;
the initial `probe-es-01` attempt ended early because separate source lines
started separate wait chains. It is retained only in build and excluded from
passing evidence. `probe-es-02` preceded notification coalescing; final-es
retests the final production hash. Generated source fixtures remain outside src.

Save compatibility uses additive fields in the existing notification inbox and
derived player readouts. Original saves remain the reversible recovery path;
downgrading a newly written 5.3.1 save is not promised by this evidence.
Resources naturally drain and thermal damage continues during all unpaused
save/hub runs. No save resets, free recovery or acceptance of unrelated issues
is claimed.

**Author acceptance:** CA256-01, originating in 5.3.1 / #256, passed on
2026-10-13: “Quedó muy bien, apruebo.” No qualifications were stated. The entry
is transferred from pending_test.txt to HISTORY. This acceptance is distinct
from agent fixture checks. Commit/push/PR delivery does not imply merge or closure.
