"""Collect the final #377 gates, with expected old-runtime defects separated."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / "build/issue377"
REQUIRED = [
    "current-suite-final-02", "baseline-suite-final-02", "legacy-save-01",
    "upgrade-final-02", "current-save-final", "current-reload-final",
    "upgraded-reload-final", "current-travel-final", "baseline-travel-final",
    "original-rollback-final", "revised-rollback-final",
]
EXPECTED_BASELINE = {
    "foreign session cannot transact",
    "Palomo stale row cannot sell equal-price alternative",
    "city to Palomo clears projection",
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    records = []
    for label in REQUIRED:
        run = json.loads((WORK / f"{label}-run.json").read_text(encoding="utf-8-sig"))
        log = (WORK / f"{label}.txt").read_text(encoding="utf-8-sig")
        assert run["exit_code"] == 0 and not run.get("timed_out"), label
        assert not re.search(r"Script error|VM execution aborted|DIED WITH FATAL ERROR", log), label
        failures = re.findall(r"CA377 FAIL (.+)", log)
        expected = EXPECTED_BASELINE if label == "baseline-suite-final-02" else set()
        assert set(failures) == expected and len(failures) == len(expected), (label, failures)
        passes = len(re.findall(r"CA377 PASS ", log))
        assert passes > 0, label
        package = WORK / run["runtime"] / "caelum_argenteum_dev.pk3"
        assert run["package_sha256"].lower() == sha(package), label
        for suffix in (".txt", "-run.json"):
            shutil.copy2(WORK / f"{label}{suffix}", HERE / f"{label}{suffix}")
        records.append({
            "label": label, "passes": passes, "expected_baseline_defects": failures,
            "runtime": run["runtime"], "package_sha256": sha(package),
            "addon_sha256": run["addon_sha256"].lower(),
            "log_sha256": sha(WORK / f"{label}.txt"),
        })
    allowed = {
        "ZSCRIPT", "caelum/player/CaelumPlayer.zs",
        "caelum/equipment/CaelumCityTrade.zs",
        "caelum/equipment/CaelumInventoryService.zs",
        "caelum/equipment/CaelumMerchantCoordinator.zs",
        "caelum/world/CaelumPhysicalHazards.zs",
        "caelum/world/CaelumSewerMaze.zs",
    }
    with zipfile.ZipFile(WORK / "baseline/caelum_argenteum_dev.pk3") as old, \
         zipfile.ZipFile(WORK / "current/caelum_argenteum_dev.pk3") as current:
        old_names = set(old.namelist())
        current_names = set(current.namelist())
        assert old_names - current_names == set()
        changed = {
            name for name in current_names
            if name not in old_names
            or old.read(name).replace(b"\r\n", b"\n") != current.read(name).replace(b"\r\n", b"\n")
        }
        assert changed == allowed, changed
        for name in current.namelist():
            source = ROOT / "src" / name
            assert source.read_bytes().replace(b"\r\n", b"\n") == current.read(name).replace(b"\r\n", b"\n"), name
    saves = {p.name: sha(p) for p in WORK.glob("ca377-*.zds")}
    exploratory = ["current-suite-01", "baseline-suite-01", "baseline-suite-final", "upgrade-final"]
    for label in exploratory:
        for suffix in (".txt", "-run.json"):
            source = WORK / f"{label}{suffix}"
            if source.exists():
                shutil.copy2(source, HERE / f"exploratory-{label}{suffix}")
    report = {
        "issue": 377, "release": "5.6.1", "runs": records,
        "passing_assertions": sum(r["passes"] for r in records),
        "expected_baseline_defects": sorted(EXPECTED_BASELINE),
        "unexpected_failures": 0, "package_changed_members": sorted(changed),
        "synthetic_saves_retained_locally": saves,
        "author_acceptance": "passed CA377-01 on 2026-10-20 without reported exceptions",
    }
    (HERE / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    rows = "\n".join(f"| {r['label']} | {r['runtime']} | {r['passes']} | "
                     f"{len(r['expected_baseline_defects'])} |" for r in records)
    result = f"""# Issue #377 validation — release 5.6.1

The final 5.6.1 runtime passes the focused transaction and persistence gates.
Across {len(records)} required native runs: **{report['passing_assertions']} passing
assertions, three expected defects reproduced only on 5.6.0, zero unexpected
failures**. Author check **CA377-01 passed author review on 2026-10-20**.

| Run | Runtime | Passing assertions | Expected old-runtime defects |
| --- | --- | ---: | ---: |
{rows}

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
`build/issue377/{{legacy,baseline,current}}/caelum_argenteum_dev.pk3`.
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
"""
    (HERE / "RESULTS.md").write_text(result, encoding="utf-8")
    print(f"PASS: {len(records)} runs, {report['passing_assertions']} passing assertions; 3 expected baseline defects, no unexpected failures.")


if __name__ == "__main__":
    main()
