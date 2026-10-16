# Issue #284 - Demon combat and rock evidence (5.4.24)

Implemented in PR302; author acceptance is pending as CA284-01. Combat/personality
and cosmetic work have separate commits. The current frozen author stage is
`build/issue284-author-02`; no campaign saves or settings are used.

## Native evidence

| Stage / run | Scope | Assertions in this log |
| --- | --- | ---: |
| issue284-final-02/contract-01 | compound combat/personality contract | 25 |
| issue284-final-02/native-01 | native machete and projectile actions | 6 |
| issue284-compat-01/upgrade-02 | original-save migration | 6 |
| issue284-compat-01/reload-travel-01 | migrated-save reload and hub return | 12 |
| issue284-author-01/manual-smoke-01 | author controls with ordinary demon attributes | 6 |
| issue284-author-02/preview-01 | final front/side OBJ review | 1 |
| issue284-legacy/seed-01 | old-package save seed | 2 |
| issue284-legacy/rollback-02 | untouched old-save rollback | 4 |

Total: 62 passing assertions across eight runs. Counters saved in
EventHandler state are cumulative; the table counts actual PASS lines in each log.
Fingerprints: evidence.json. Combat/action tests precede only comment spelling and
cosmetic UV changes; the final render checks the revised UVs. Migration tests cover
unchanged personality/rock fields and callbacks; later cold-defense and generic-prop
combat changes do not execute in that frozen compatibility fixture. Rollback means
loading the untouched original save with its original package, not loading a new
save on old code.

The contract checks all twelve Mandinga attributes, exact personalities, idempotent
no-refill migration, independent component defenses, shared critical/evasion, one
weighted Toughness reduction, ordinary burn ownership, Sleep counting/third-hit
multiplier, Fire-seal isolation, real inventory shield, invulnerability, zero-HP
absorption, pre-impact Arenga, generic props and unchanged projectile physics.
Actual native actions additionally verify machete delivery, physical resource cost,
Battle Cry interruption and the original Zupay projectile class/flight/payload.

## Art and packaging

The original OBJ has 128 positions, 576 face UVs and 192 nondegenerate outward-facing
triangles. Its dominant-face UV projection reuses unchanged owned sprite pixels.
Front/side screenshots remain local because the test room uses development IWAD
materials; their hashes are in evidence.json. Three generated artifacts repeat
byte-for-byte. Normal build matches all 16,192 source members. Static project
validation has zero errors and a fresh document index.

## Preserved iterations

- issue284-01 inspected spawned bodies before native initialization; wait before checks.
- issue284-02/03 allowed fixture evasion before the Sleep assertion; force controlled evasion per test.
- issue284-04 supplied a shield model without its native inventory item; fixed the fixture.
- compat upgrade-01 passed an absolute save path that this engine appended to savedir; use a copied input.zds.
- legacy rollback-01 passed four checks but missed its final marker after save/quit; rollback-02 uses a separate completion wait.
- preview-02/03 relocated the player camera unreliably for side capture; preview-04 uses a dedicated native review camera.
- preview-04 exposed stretched side UVs; author-02 verifies corrected dominant-face projection.

## Reproduce and review

Run `python assets/validation_5424/prepare.py --directory <fresh-label>`, then
`run_native.ps1 -Directory <fresh-label> -Label <fresh-run> -Script contract.cfg`
and native.cfg / preview.cfg as needed. The compatibility fixture uses --compat;
--legacy and --runtime preserve the old package; copy saves into its isolated
savedir and use a basename. record_evidence.py verifies the frozen runs, export
repeat and package/source parity. Interactive launch: launch.ps1 from a visible
PowerShell terminal; F6 machete/burn, F7 native throw, F8 close model view.
Manual mode uses ordinary demon attributes; the automated action check raises
only fixture accuracy/critical attributes for deterministic execution.
