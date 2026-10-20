"""Collect required #376 native gates and package differences without hiding failures."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / "build/issue376"
LABELS = [
    "baseline-suite-04", "current-suite-final",
    "baseline-save-01", "current-save-final",
    "upgrade-final", "current-reload-final", "upgraded-reload-final",
    "original-rollback-01", "revised-rollback-01",
    "baseline-travel-01", "current-travel-final",
]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    runs = []
    for label in LABELS:
        log = (WORK / f"{label}.txt").read_text(encoding="utf-8-sig")
        record = json.loads((WORK / f"{label}-run.json").read_text(encoding="utf-8-sig"))
        assert record["exit_code"] == 0 and not record.get("timed_out"), label
        assert not re.search(r"CA376 FAIL|Script error|VM execution aborted", log), label
        assert re.search(r"CA376 (RESULT|PERSIST) passed=\d+ failed=0", log), label
        passed = len(re.findall(r"^CA376 PASS ", log, re.M))
        assert passed > 0, label
        observations = re.findall(r"^CA376 (?:PLAN|LAYERS|RESULT|PERSIST|TIMING).*", log, re.M)
        runs.append({"label": label, "passed": passed, "observations": observations,
                     "log_sha256": sha(WORK / f"{label}.txt"), **record})
        for suffix in [".txt", "-run.json"]:
            shutil.copy2(WORK / f"{label}{suffix}", HERE / f"{label}{suffix}")
    def plans(run):
        return [line for line in run["observations"] if re.match(r"CA376 (PLAN|LAYERS)", line)]
    assert plans(runs[0]) == plans(runs[1]), "Baseline/final quantities or durations differ"
    baseline = WORK / "baseline/caelum_argenteum_dev.pk3"
    current = WORK / "current/caelum_argenteum_dev.pk3"
    with zipfile.ZipFile(baseline) as old, zipfile.ZipFile(current) as new:
        old_names, new_names = set(old.namelist()), set(new.namelist())
        added = sorted(new_names - old_names)
        removed = sorted(old_names - new_names)
        changed = sorted(n for n in old_names & new_names
                         if old.read(n).replace(b"\r\n", b"\n") != new.read(n).replace(b"\r\n", b"\n"))
    assert not removed
    assert added == ["caelum/crafting/CaelumCraftingCoordinator.zs"]
    assert changed == [
        "ZSCRIPT", "caelum/player/CaelumPlayer.zs",
        "caelum/world/CaelumPhysicalHazards.zs", "caelum/world/CaelumSewerMaze.zs",
    ], changed
    report = {
        "issue": 376, "version": "5.6.0", "baseline_commit": "92be078e7ee2902a98f2c29603717a35b51647a8",
        "native_runs": runs, "passed_checks": sum(r["passed"] for r in runs),
        "baseline_sha256": sha(baseline), "runtime_sha256": sha(current),
        "package_added": added, "package_changed_ignoring_crlf": changed,
        "package_removed": removed, "author_acceptance": "pending CA376-01",
        "save_sha256": {p.name: sha(p) for p in sorted(WORK.glob("ca376-*.zds"))},
        "limits": [
            "Native-created checkpoints use artificial inventory and stations, not the author's campaign.",
            "No frame-presentation/FPS improvement, ordinary campaign acceptance or multiplayer claim.",
            "The pre-existing typed station traversal remains unchanged; measured fixture timing is not a dynamic-network maximum.",
        ],
        "independent_review": {
            "result": "No blocking findings",
            "scope": "Independent inverse body/signature and whole-pawn token comparison; no qualified local-name shadowing; owner/lifecycle and native evidence review.",
            "qualifications": "Representative recipes, uniform efficiency settings, synthetic native saves and health-zero death simulation.",
        },
    }
    (HERE / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    # Retain exploratory failures separately, outside the successful gate totals.
    for label in ["baseline-suite-01", "baseline-suite-02"]:
        for suffix in [".txt", "-run.json"]:
            shutil.copy2(WORK / f"{label}{suffix}", HERE / f"{label}{suffix}")
    lines = [f"| {r['label']} | {r['passed']} | Pass |" for r in runs]
    results = f"""# V5.6.0 / #376 — crafting coordination

The stateless `CaelumCraftingCoordinator` receives the requesting pawn through
48 retained adapters. `EXTRACTION.json` proves all 653 pawn field declarations,
562 signatures, 514 unmoved bodies and every moved body/quoted literal remain
equivalent after removing only explicit pawn qualification. Inventory commits,
save snapshots, browser state ownership and lifecycle ordering remain unchanged.

## Native evidence

GZDoom 4.14.2 / Windows 11: **{len(runs)} required runs, {report['passed_checks']} new
PASS checks, zero FAIL**. `report.json` records commands, hashes, configuration,
hardware and raw logs. Tests run individually, unpaused in the background, with
5% audio. No keep-awake request is installed.

| Required run | New checks | Result |
| --- | ---: | --- |
{chr(10).join(lines)}

The identical baseline/final suite covers nine recipe families, recursive
25/50/100% choices, utility items, preview/selection/knowledge invariance,
repeat start, pause/resume/combat/distance/death, explicit cancellation,
exact-target repair/dismantle, repeated completion, reserved-material drop,
unknown recipes, missing sessions/materials and final Box/load rejection.
All twelve printed family/layer plans have identical quantities and durations.
Existing recipes/data are the oracle; fixture stock values are synthetic.

Real native saves created with the original 5.5.8a package contain a partially
progressed, paused repair, same-type worn objects with distinct ItemIds, learned
recipes and reserved native material stacks. Upgrade, fresh/upgraded reload,
TMAINT→THAZARD→TMAINT→MAP02→MAP01 travel, original-pair rollback and an upgraded
save opened by the original package retain the asserted state. The original
and revised package/save copies stay under `build/issue376`; no user save is
overwritten and no schema migration is introduced.

## Package and performance boundary

Original runtime SHA-256: `{report['baseline_sha256']}`.
Final runtime SHA-256: `{report['runtime_sha256']}`.
One source is added; only the player adapters, ZSCRIPT include and two release
diagnostic strings otherwise differ after normalizing checkout CRLF.
Recipes, station implementation, inventory service and map bytes are unchanged.

The existing typed station graph scan is triggered by interaction and the
existing session validation cadence, with token/player cycle guards and the
shared time-skip guard. Its population is the current map's stations, with
cost proportional to reachable × total stations. The fixture adds twelve
stations and reports 100 native graph traversals in the raw logs. This is
inherited behavior, not an optimization or a measured dynamic-network maximum.
No presented-frame/FPS or broad performance-acceptance claim is made.

## Fixture corrections and evidence limits

Exploratory baseline-suite-01 failed compilation because its fixture reused a
retired longbow constant and old material field names; current native accessors
and the accepted longbow constant corrected the fixture. Baseline-suite-02
underfunded 25% recursive crafting with only 20,000 raw units, causing four
dependent failures. Only its synthetic raw-input setup was raised to 100,000.
Those logs remain recorded and are excluded from passing gate totals.
The final additional rejection checks do not change saved fixture field layout;
each run records the actual addon hash it used.

These are isolated checks, distinct from ordinary play and author confirmation.
Each family uses a representative recipe; efficiency cases use uniform settings,
not independently mixed layer settings. The death/session check sets health to
zero, rather than exercising an entire death/respawn cycle. An independent
review found no blocking source, ownership or lifecycle defect, independently
restored the full pawn token stream, and verified no local-name shadowing.
CA376-01 remains in `pending_test.txt`. No new recipe, balance, artwork, save
schema, full multiplayer support, merge or issue closure is claimed.

## Reproduction

Run `python assets/validation_560/extract_crafting.py` for source equivalence.
Run `python assets/validation_560/prepare.py` for deterministic addon/scripts,
then `run_native.ps1` with the recorded label/runtime/script/load arguments.
Use new labels to preserve evidence. `collect.py` rejects absent/failed gates
and mismatched baseline/final plans. Test fixtures and private packages are
never included in the production PK3.
"""
    (HERE / "RESULTS.md").write_text(results, encoding="utf-8", newline="\n")
    print(f"PASS: {len(runs)} runs / {report['passed_checks']} checks; package delta limited to extraction and labels")


if __name__ == "__main__":
    main()
