# Issue #234 - Authored exploration catalogue

Version 5.3.7, 2026-10-14. Branch `feat/issue234-authored-cartography`,
baseline `bdcae305` (#233). CA234-01's mansion handoff passed author review on
2026-10-14: labels after entering ground/first/second-floor rooms, beds/stations
only after interaction, no unvisited/secret-room labels, and retaining discovered
markers through save/load. The five presented steps ran in
`author-20261014-064857` on final runtime SHA-256
`8a15c589f40aae6b99708fcb20677f619ac503edc4c3918a8501125577bc67f9`;
the engine exited with code 0. Sewer/city and remaining compatibility checks
stay pending. Physical author acceptance is separate from the native matrix.

Final open-padlock artwork (2026-10-14): the author confirmed the icon now changed,
but expected an open padlock rather than the interim Use hand. Built-in imagegen
edited the existing owned closed padlock; source/runtime preserve the generated
1254x1254 RGBA bytes and alpha. Prompt/reference/output hashes are in
`assets/manifests/map_grate_unlocked_537.json`. Only the observed-open texture
path and its new PNG differ from the earlier icon-routing fix. Native flow and
reload passed **43 assertions**, **2 save comparisons** and **3 inspected captures**,
recorded separately in `unlocked_evidence.json`. The new artwork remains pending
author acceptance. Reproduce on this #234 branch with
`marker_prepare.py --open-padlock`, the recorded `run_native.ps1 -WorkDirectory
build/issue234-open-padlock` runs, normal build and
`marker_collect.py --open-padlock`. `unlocked_handoff.ps1` opens Probar234Candado.
The previous fixtures, packages, logs and hand-symbol evidence remain preserved.

First open-grate icon correction (2026-10-14): the author reported and clarified an
open label with an unchanged padlock. The original native matrix checked access
facts/labels but missed this displayed-state mismatch. CaelumKnownPoiMarker now
selects its texture using the saved observation: an observed-open grate uses the
existing passage/exit artwork, while other grate states keep their category icon.
The patch changes no knowledge event, access rule, balance value or saved field.

`marker_evidence.json` records the focused regression separately. The original
frozen runtime reproduces two expected icon failures. Corrected flow/reload runs
pass **43 assertions**, **2 native-save comparisons** and **3 inspected captures**.
Real native Use first fails without a key, then opens the same grate after the
fixture supplies its existing key. Assertions read the actual MapMarker texture,
identity, position and dormancy; a diagnostic remote state change must not update
the remembered icon. No other grate is discovered. Native reload reconstructs
the correct texture and retains the observed fact/knowledge serial. Static
validation and normal packaging pass; the collector matches the production
build to the tested package and limits its runtime diff to the two icon-routing
sources, normalizing checkout CRLF only for ZScript, KEYCONF, MENUDEF and ZSCRIPT.

The first marker diagnostic failed to compile because its Check helper had play
scope; its corrected UI scope is in all selected runs. The first reload passed
its assertions but captured the closed automap; the selected repeat opens the
map before capture. Both preliminary logs remain in build/issue234-marker-fix.
The original issue234 packages and the author's active session remain untouched.
Reproduce with `python assets/validation_537/marker_prepare.py`, then the recorded
`run_native.ps1 -WorkDirectory build/issue234-marker-fix` arguments and
`python assets/validation_537/marker_collect.py`. The focused author retest uses
`marker_handoff.ps1`: diagnostic grate positioning, F8 for its key, native Use,
map inspection and save/load. This is not ordinary traversal/secrecy acceptance.
CA234-01 remains pending that visual retest and its other unconfirmed cases.

Static validation and normal packaging passed. Sixteen native GZDoom 4.14.2
runs passed 151 assertions, with 16 save comparisons and 12 inspected captures.
`evidence.json` records exact commands, runtime/fixture/save hashes and results.
Native checks ran unpaused in the background with 5% audio and isolated INIs.

The catalogue covers ten ordinary mansion interiors, four beds, five workshop
networks, Palomo, existing sewer grates/travel, and the current city's eight
physical gates, east arch, four towers, shops, house beds and two vehicles.
Registrations neither spawn content nor reveal it. Room/tower entry and actual
service interaction follow the author's decisions. Six south gates remain
separate. Sector warnings remain explicitly deferred.

Native checks exercise real mansion bed/workbench input after a 175-tic delay,
actual native Use on a sewer grate and city gate, denied access, individually
known gates/towers and existing service identities. Diagnostic positioning and
production calls isolate the remaining cases; this is not ordinary traversal
or physical author acceptance. Ground-floor entry cannot discover a bedroom;
secret/cave positions add no annotation. Upper elevator use does not expose its
hidden lower return grate. Lower interaction records its actual access state.
Remote opening changes no previously recorded observation until another use.

A genuine 5.3.6 save preserves every prior character-record value, including
resolved identity objects and manual notes; only LocalKnowledgeRevision changes.
Current MAP01/02/06 reloads retain exact POI records, native automap and linedefs.
Hub travel preserves original-map facts without inventing another map's copy.
The old mansion geometry remains unannotated and reloads with its matching WAD.
Original 1000-attacker and south 6000-attacker port layouts pass focused identity,
actual-position and no-current-landmark checks. No full battle performance or
6000-attacker save/reload claim is made.

Earlier unaffected runs retain their exact package fingerprints. Archive-member
comparison bounds reuse to the MAP02 upper-control secrecy fix, the tower's
inclusive authored parapet height and the mansion's corrected room edges.
Independent native wall traces found that the ground workshops include the
side-door strips up to x=32/704. Their final entry, reload and presentation cases
were rerun; the 56 diagnostic geometry rays are separate from the assertion count.
Affected MAP02 and MAP06 cases were also rerun;
normal packaging matches the final frozen runtime member-for-member. Captures
show both languages, normal/rotated views and explicit mansion storey labels.
An earlier retained mansion service capture records the fixture's still-open
crafting session, which suppresses the map header; final selected captures close
the real session and demonstrate the header. Earlier captures remain diagnostic
history and are not included in the twelve final captures. No UI acceptance is
inferred from fixtures.

Retained diagnostics: initial compile syntax correction; a completion command
queued immediately before quit; native rejection when an old save is paired
with a different WAD; and a first 6000-attacker diagnostic stopped after about
four minutes. Shorter legacy diagnostics completed the catalogue assertions.
None of these diagnostic logs is counted as a passed run. Original saves and
local generated packages are retained; they are not distributed in the PR.

Commands: `python assets/generators/generate_cartography_catalogue.py --check`,
`python build_dialogue_index.py build`, `python build_document_index.py`,
`python validate_project.py`, and
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1`.
`prepare.py` creates deterministic local fixtures; `run_native.ps1` records each
isolated launch; `collect.py` checks/copies the evidence. `handoff.ps1` prepares
Probar234 for author use. The mansion handoff was launched after the return;
later sewer/city sessions use separate labels and preserve original evidence.
