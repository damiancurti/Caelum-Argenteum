# Progressive soap bathing - #502 / 5.8.12

Bathing now uses real soap and source water progressively, keeping completed
cleansing and spending on cancellation. The inventory bath selector exposes the
mass-scaled budget and fractional soap credit. Existing bathtub reclining is reused;
connected potable reservoirs lose their actual volume. Source quality, access,
life state and shared availability are checked again each step. Soap's opened-gram
remainder travels/saves with its mass and is consumed before another whole gram.
No cloth, new balance, map geometry or artwork was added.

121 executed native assertions pass in12 selected runs. Coverage includes physical
bathtub interaction, native material inventory and mass, zero/insufficient resources,
late shortage, cancellation, disease/external damage,80/160kg calibration,
full native world-clock completion, independent forecast/native parity, fractional
save/load, hub departure, real MAP01 potable water, changed quality, pre-feature
save migration and original-package rollback. Earlier toilet/posture behavior also
passes. CA502-BATH-01 subsequently passed author review on2026-10-25 without qualifications.

The final bath-final05 package has16,890 source-identical members;169 maps and
13,826 art members match the accepted posture baseline byte for byte. SHA256:
`8eac2129e6a519ede8e347216c19c6ac8667c8975e42438719a4c9fbf0c78f35`.
The report records per-run package hashes. Earlier bath save/core results are
reused only after comparing runtime files: the final differences are UI/localization,
and (for the early save package only) the independently tested forecast adapter.
Static project/localization/document validation passes. Native UI captures were
visually reviewed, including the font-supported minus signs on amount buttons.

Reproduction: prepare_bath.py, run_native.ps1 with report.json's scripts and source
packages, collect_bath.py. author_bath_terminal.ps1 leaves interactive/manual and
serial automated options available. The optional material remainder UI also works
when no whole soap grams remain. The original accepted addons/packages and failed
probes remain in ignored build/; selected raw logs and metadata are retained here.
Resolved fixture failures are recorded in report.json. The pre-feature save used
for migration is a reclining bathtub occupant, not an active toilet task.

Scope limits: this does not implement equipment washing, repair/sleep washing,
persistent dirty surfaces, combat contact or NPC domestic cleaning. Existing
forecast guards still decline changing connected reservoirs or unmodelled effects;
ordinary live waiting remains available. No global actor scan was added: queries
use the actor's inventory, current fixture or current water sector. These functional
checks do not establish campaign-wide rendering performance.
