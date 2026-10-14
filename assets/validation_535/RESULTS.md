# Issue #232 validation — 5.3.5

Baseline: `edf9aa76` (accepted 5.3.4 cartography). Environment: Windows 11,
GZDoom 4.14.2, Vulkan, fixed seed 184, unpaused background, 5% audio.
Final evidence: **10 completed native runs, 98 assertions, 7 exact save
comparisons and 5 inspected captures**, plus a final production compile run.
Static validator: exit 0, `errors: []`; normal build: exit 0, **16,061 files**.
Its uncompressed members exactly match the frozen production package.
Exact packages, fixture hashes, commands, logs, captures and assertions are
recorded in `evidence.json`. Generated packages, native saves, IWAD and engine
stay local; only fixture sources and evidence are retained here.

The final matrix checks five categories, duplicate/conflicting identities,
idempotent empty migration, unknown stacked-floor/secret registrations,
last-observed positions, absent/recreated sources, native icon rendering and
read-only bilingual names. Native `+use` opens real bed/station/merchant/exit
interactions in an isolated registered fixture. Blocked bed, merchant and exit
cases record knowledge without opening/unlocking them, as the author confirmed
on 2026-10-13. The existing MAP06 cart is tested through its normal physical
parts and Use: it becomes known while its coastal route remains disabled by
the accepted world catalogue (`CONNECTION_TO_COAST` is excluded from
`IsSewerConnection`). No travel permission is changed.

The save matrix uses genuine engine-created 5.3.4/5.3.5 saves, checks current
reload, and exercises native MAP03 → MAP04 → MAP03 hub travel. Identical
coordinates and local IDs in different maps remain different facts. Explicit
save comparisons check retained POI values, native lines/marks and unaffected
record fields. The unchanged old save remains the reversible recovery source;
loading a newly written schema into an older package is not promised.

A native second-player bot fixture verifies different character-owned records
and zero displayed private markers with multiple participants. Its executable
is an unchanged local copy with a fixture-only `zcajun/bots.cfg`; the installed
engine configuration is untouched. This is a privacy/ownership check, not a
multiplayer gameplay or networking certification.

Earlier transport diagnostics used an incomplete cart fixture and then assumed
that the existing disabled route would open a preview. They are not successful
transport evidence. The final fixture uses the actual authored cart and the
author-confirmed distinction between knowledge and access. The initial bot
diagnostic had no bots.cfg and could not create a participant; the final native
bot run supplies the isolated config. Earlier logs remain local under
`build/issue232`; only explicitly selected successful runs enter the manifest.

Reproduce with `python assets/validation_535/prepare.py`, then `run_native.ps1`
using the matrix in the manifest. `--fixtures-only` deliberately retains the
already frozen production package. `old-save.cfg` runs with `-Baseline`; old
load uses `-RuntimeAlias load-current/baseline.pk3` because the native save
requires the original archive basename. Fixtures seed character state and
registration; scripted native Use is separate from author keyboard acceptance.
Authored MAP01/MAP02/MAP06 registration/exploration remains #234.

After the behavioral matrix, validation required two existing diagnostic
release labels to change from 5.3.4 to 5.3.5. The collector verifies that these
two literal substitutions are the entire runtime delta; both package hashes
are recorded. The final package passed another native compile/startup check.
No gameplay or presentation code changed after the behavioral matrix.

Static validation and normal build results are retained adjacent to the
manifest. CA232-01 is pending author acceptance; no merge or closure is claimed.
