# Issue #380 — native cartridge assembly (5.6.9)

Final native evidence: **15 runs, 1,259 PASS, zero FAIL**, GZDoom 4.14.2 on
Windows 11. `report.json` records exact engine, driver, CPU/GPU, commands,
package/fixture/source/save hashes and per-run counts. Tests run unpaused in the
background with audio at 5%; this is functional evidence, not an FPS benchmark.

Production package SHA-256:
`eb8b42df28ab71ca86491bae104dcc891bf9b4e2d2049929dbf5e1395f6dfdce`.
All **16,428** package members match `src/` (text line endings normalized).
Static validation and generated document/dialogue/localization indexes pass.
The two kit exports reproduce byte-for-byte with Pillow 11.3.0; originals,
prompts, alpha bounds and pivots are retained under `assets/art_source/cartridge_kits`.

## Native coverage

- 95 assembly checks: both kit identities, 40/20/10 inputs for ten cartridges,
  mass, price anchor, complexity/mastery, knowledge/station/shortage gates,
  reservation, cancellation, session pause/resume, failed and duplicate completion,
  consumable practice, sheet dependencies, sprite/icon registration and pickup.
  Existing arrow and bolt recipes still consume their 70/30 inputs and complete.
- Capacity covers equal input/output mass at the exact carry limit, personal
  and boxed input/output stacks, a full Box slot count, ammo stack overflow and
  boxed inputs with insufficient personal output capacity.
- Current save/reload and hub/non-hub travel preserve both kits, cartridge
  quantities, pages/progress and a paused reserved shotgun task. A supplementary
  fixture completes the loaded task once and reloads its completed save with
  exact payment/output/practice and no remaining reservation.
- An actual 5.5.8a run saves a paused arrow task, 137/83 cartridges and partial
  magazines of 7/1. Upgrade, upgraded reload and completion preserve those
  counts/magazines and deliver ten arrows once. The original package/save pair
  also reopens successfully. An actual 5.6.6 save retains wet clothing/armor IDs.
- Reused #313 native firing/reload checks: 32 PASS, including twelve shotgun
  pellets, exact ammo/mass debit and native magazines. Reused ranged-defense
  fixture: 1,028 PASS. Their source definitions remain in validation_554/5210.
- `kits-world.png` shows both native ground sprites. Agent inspection confirms
  distinct bronze-case/projectile and paper-case/shot silhouettes. This does not
  substitute for author acceptance.

## Diagnostics and review

Early fixture-only compile errors used reserved `Version`, an incorrect economy
class name and protected `TryPickup`; those were corrected before the suite.
`suite-01` passed before the blueprint mass-label fix and is excluded from final
totals. `fire-final-01` exhausted the original 60-second harness timeout; its
queued script needs over 60 seconds. The complete rerun used a 120-second limit
with one-second exit polling and passed. Diagnostic logs remain separately labeled.

Independent read-only cross-review found the live blueprint's old one-gram
assumption. It now derives kit mass from the node recipe while preserving one
gram for earlier inputs. A second review confirmed that fix; it also requested
explicit loaded-task completion evidence, supplied by `resume.zs`.

## Reproduction and pending acceptance

Build the production PK3 under `build/issue380/current/` with `build_dev.ps1`.
Run `python assets/validation_569/prepare.py`, then `run_native.ps1 -Checks`
with the script and unique label recorded in `report.json`. `-Addon
resume-checks.pk3` selects loaded-task completion checks. Baseline runs use the
retained original private 5.5.8a package; never substitute a rebuilt current tree.
Ballistics preparation reuses `assets/validation_554/prepare.py`; exact arguments
are recorded. Saves, fixtures, IWAD and executable remain private under `build/`.

**CA380-01 passed author review on 2026-10-21** ("La prueba dio correcto"). The isolated author room supplies both sets of kits,
recetario, learned recipes, two ground pickups and the required stations.
The interactive startup initially stayed in TMAINT because a nested `exec` shared
the delayed command line. Loading the control file on its own line restores the
queued room setup. `author-20261021-kits-02` reached CLTHQA and logged `CA380 READY`
with 1,000 kits of each type, recetario and two ground pickups. This launcher fix
does not change the tested production package or assertion fixtures.
Shop/library availability belongs to #383; renewal belongs to #385.
