# Issue #236 / 5.3.9 - Exploration navigation evidence

Baseline: `2f738c39` (#235, 5.3.8). Windows 11, GZDoom 4.14.2.
The runtime and fixtures are frozen separately under `build/issue236`;
engine/IWAD, generated PK3s and saves are not distributed.

Static validation and normal packaging passed (exit 0). Fourteen selected native
runs passed **202 assertions**, with **28 save comparisons** and **17 inspected
captures** at 640x480, 1280x720 and 1680x720 (including UI scale 4).
The native matrix uses isolated INIs, background simulation and 5% audio.
It covers fresh/current/older records, the connected screens, native popup
commands, direct remaps, note/map return, travel cancel/confirmation and
Spanish/English presentation. Final counts and hashes are in `evidence.json`.
Author physical-input/usability check CA236-01 is deferred until return.

Native handler calls and console commands are isolated technical evidence,
not physical mouse/keyboard acceptance. GZDoom rejects executing a native
command item from a diagnostic ConsoleProcess; that first failure is retained.
The subsequent fixture inspects the actual native command item, then dispatches
its route from the console separately. Real native item activation remains an
explicit author check. The existing native command-item implementation is reused.

The selected real travel check uses the existing measured MAP03-to-MAP06 route,
native confirmation/cancel handlers and production revalidation. Fresh profiles
and test inventory are diagnostic setup, not normal campaign progression. Hub
compatibility uses native changemap separately, not a claimed authored return.

No new schema is introduced. Read-only comparisons resolve identity/POI/note
references and compare persistent fields, native automap/linedefs and owned
inventory identities. They exclude the thermal observation object, which
continues updating during live simulation; hub return also excludes the three
persisted sleep/hunger/thirst observations. The cancel check proves elapsed
world-clock ticks equal natural map ticks, with no journey/time-skip advancement.
The genuine 5.3.7 note save also receives the already-delivered #235 migration;
that additive tracking revision is accounted for separately.

Reproduction: `python assets/validation_539/prepare.py`, then the commands in
each retained `*-run.json` through `run_native.ps1`. Use new labels to preserve
existing evidence. `collect.py` checks selected logs, saves, hashes and captures.
The exact diagnostic source revisions are retained in `fixture_revisions/` and
reconstructed PK3 hashes must match each selected run. Replay one with
`prepare.py --fixtures-only --probe-source <retained-source-path>`; restore the
current probe with `prepare.py --fixtures-only` afterward. Only diagnostic cases
were added between these revisions. Final review fixed the crafting header
pointer hit-test and exact navigation shortcuts on GUI middle/forward mouse
events. The integrated flow and focused pointer case passed after those fixes. The
final package additionally accepts mixed-case command bindings, covered by a
dedicated case. The collector proves these exact conditions/comparisons are
the entire runtime delta; unchanged save/travel/layout evidence is reused
with its original runtime hash. Earlier failed and preliminary diagnostics
remain evidence, not passing final-package runs.
Run `python build_dialogue_index.py build`, `python build_document_index.py`,
`python validate_project.py`, and `powershell.exe -NoProfile -ExecutionPolicy
Bypass -File .\build_dev.ps1` for the production gates. The collector verifies
the normal build members equal the tested frozen production package.

The author handoff is prepared but not launched during the absence. Original
source saves and earlier issue packages remain preserved. No merge, issue
closure, multiplayer certification or author acceptance is inferred.
