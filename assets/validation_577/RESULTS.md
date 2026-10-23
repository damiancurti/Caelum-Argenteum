# 5.7.7 / #481 - Centered target panel

Presentation and read-only selection only. The author confirmed Insight is the
existing Perspicacia attribute, individual attributes require strict less-than,
and Health/Anima/Air/Adrenaline remain visible. No gameplay resource or action
formula changes. Runtime art remains byte-identical to accepted #471.

## Verification

Final evidence is recorded in report.json and native/. Native fixtures exercise
actor/line selection, strict thresholds, empty aim, walls, invisible helpers,
read-only inspection, current bindings and save reconstruction. Visual captures
are in visuals/. The final full package passed 41 assertions across selection,
live key remapping and current/5.7.6 save reloads. A final fixture-only guard
prevents its F1/F2 commands from running after leaving CTGT481; its native smoke
repeated all 36 selection assertions successfully. All final processes exited 0.
Seven target captures and the Spanish remapped-key capture were inspected.
Author acceptance CA481-01 passed on 2026-10-22 after the interactive handoff:
"La prueba que me diste quedó bien." The original report.json retains its
collection-time pending status; this later confirmation is recorded here and in
the originating 5.7.7 HISTORY entry. No runtime change or repeated native test
was required for this acceptance-only update.

The 16,596-entry package matches every source byte (SHA-256
7baaca0b9dbcbdada22b3cb304b47942dc7e88def532bd0932e56dac89eb1c27).
The validator passes with 2,497 CONTEXT words. Baseline save creation used the
accepted 5.7.6 package; reloading it required preserving the fixture's original
basename. The initial missing-package rejection is retained in diagnostics/.

The isolated 10-second Vulkan sample recorded 35.0001 simulation tics/s and 599
UI callback intervals: mean 16.6667 ms, p95 16.8419 ms, p99 16.9433 ms, maximum
17.1968 ms. These are callback intervals, not measured frame presentation or GPU
time. PresentMon could not start ETW tracing (access denied); its error and
environment are preserved. No whole-map rendering or 60-FPS acceptance is claimed.

The native line tracer uses the blockmap and stops at geometry. A separate
Use-range BlockLinesIterator catches crossable special lines before that same
occlusion distance. No routine global actor iteration is added; the old sewer
hint's per-frame global gate scan is removed. This does not alter the >=500
living-combatant performance policy or offscreen gameplay.

Diagnostic corrections are preserved separately: initial compilation exposed
Actor API/scope mistakes (Inventory.Owner, GetRenderStyle, HasConversation,
clearscope trace helpers). A local distance variable shadowed the cache field
because ZScript identifiers are case-insensitive; the final regression asserts
candidate distance and actor occlusion (CA-KP-054). A diagnostic vector format
error and an isolated fixture's unconnected wall were also corrected.

No gameplay save schema changes: TargetInfo is transient and rebuilt on tick.
Native process completion is required; setup PASS messages are insufficient.
This is not author acceptance or a whole-map 60-FPS claim.

## Reproduction and author handoff

Run the project validator, build_dev.ps1 with destination
build/issue481/current/caelum_argenteum_dev.pk3, then prepare.py and run_native.ps1.
The optional prepare.py --overlay is for development iterations only; final
checks use the full package and a fixture without runtime overrides.
manual.ps1 leaves an interactive native fixture and Spanish instructions;
F1 selects a target and F2 toggles the controlled Insight threshold.
The handoff was opened after the author returned, under label
author-20261022-182920, using the validated package above. The visible instruction
terminal was left open. The temporary keep-awake request was released at return.
