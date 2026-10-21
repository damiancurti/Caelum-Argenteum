# Issue #377 validation — release 5.6.1

The final 5.6.1 runtime passes the focused transaction and persistence gates.
Across 11 required native runs: **212 passing
assertions, three expected defects reproduced only on 5.6.0, zero unexpected
failures**. Author check **CA377-01 passed author review on 2026-10-20**.

| Run | Runtime | Passing assertions | Expected old-runtime defects |
| --- | --- | ---: | ---: |
| current-suite-final-02 | current | 62 | 0 |
| baseline-suite-final-02 | baseline | 59 | 3 |
| legacy-save-01 | legacy | 2 | 0 |
| upgrade-final-02 | current | 7 | 0 |
| current-save-final | current | 2 | 0 |
| current-reload-final | current | 7 | 0 |
| upgraded-reload-final | current | 7 | 0 |
| current-travel-final | current | 26 | 0 |
| baseline-travel-final | legacy | 26 | 0 |
| original-rollback-final | legacy | 7 | 0 |
| revised-rollback-final | legacy | 7 | 0 |

## Scope and evidence

GZDoom 4.14.2 on Windows 11, Vulkan, 1280x720. Tests run sequentially, unpaused
in the background, at 5% master audio. Per-run JSON records command, package,
addon, executable/IWAD hashes, driver, CPU and initial configuration. Logs are
raw native evidence; no IWAD, executable, save or fixture PK3 is distributed.

The suite covers exact equipment identity/size/durability, duplicate copies,
partial/full stack transfer, denomination change, lot rounding, insufficient
money/stock, vendor wallet rejection/saturation, full Box/load, reserved,
equipped/flagged equipment, stale quotes/rows, discount change, foreign session,
foreign inventory item and unbound pawn rejection, close/reopen and distance
loss. Three baseline regressions are isolated: foreign city-session execution,
Palomo's equal-price replacement row, and city-to-Palomo projection cleanup.
Repeated execution after depletion/closure cannot repeat a completed payment.
UI hold behavior has separate author acceptance CA377-01 (2026-10-20); input code is unchanged.

The old save is created by actual **5.5.8a**, with an open session, purchased
equipment and depleted stock. Upgrade, new/upgraded reload, TMAINT → THAZARD →
TMAINT → MAP02 → MAP01, original-package/original-save rollback and loading the
new save under 5.5.8a all preserve totals. Reopening the vendor never reseeds it.
Fixtures use synthetic native saves, not an author's ordinary campaign save.
Saved session object/class fields remain unchanged; no production schema delta.

`extract_merchant.py` verifies 18 adapters, all saved owner fields/signatures,
quoted literals in unchanged bodies, the exact remaining pawn/city source and
all existing inventory service methods. Seven deliberate coordinator policy
changes and four new inventory helpers receive native tests and independent
static AI review. There are no coordinator fields or new routine actor scans.
Package comparison allows exactly seven affected members; all packaged source
matches the final checkout after newline normalization. `report.json` records
member names and save/log hashes.

## Reproduction and limitations

Prepare with `python assets/validation_561/prepare.py`; use
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_561/run_native.ps1`
with a fresh `-Label`, `-Checks`, and `-Script suite`, `baseline-save`,
`current-save`, `upgrade`, `verify` or `travel`. `-Runtime` selects retained
`build/issue377/{legacy,baseline,current}/caelum_argenteum_dev.pk3`.
`-LoadGame` takes a filename relative to that test directory. Save packages and
original saves together before migration. `collect.py` rejects unexpected
failures, source/package drift and changed package members outside the scope.

Exploratory logs are retained separately: the first fixture incorrectly asked
player authority to assign ItemId while the vendor owned an item; corrected
fixtures assign it while player-owned. Initial baseline failures propagated
from an earlier deliberately reproduced defect; the final suite resets that
fixture boundary. One load used an absolute filename that GZDoom appended to
savedir; the runner now rejects that input. Final suites include the corrected
test isolation; saved-state checks were unchanged and are reused with their
recorded addon hashes.

Preallocation failure safety is code-reviewed; native allocator exhaustion was
not injected. These checks establish neither full multiplayer support, display
FPS improvement, ordinary campaign acceptance nor unimplemented restocking.
Static project validation and normal packaging are separate passing gates.
