"""Collect final container gates; preserve failed exploration separately."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / "build/issue381"
REQUIRED = [
    "legacy-save-02", "release-suite", "release-save", "release-reload",
    "release-travel", "release-upgrade", "release-upgraded-reload", "release-reverse",
    "release-reversed-rollback", "original-rollback-01", "release-cardinal",
    "release-cardinal-reload", "release-supply", "release-ui", "release-smoke",
]
ALLOWED = {
    "ZSCRIPT", "LANGUAGE", "localization/index.json", "localization/INDEX.md",
    "caelum/core/CaelumConstants.zs", "caelum/equipment/CaelumContainerStorage.zs",
    "caelum/equipment/CaelumInventoryService.zs", "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/quests/CaelumMainM00RonnieTrial.zs", "caelum/ui/CaelumChestPreview.zs",
    "caelum/ui/CaelumLiveMenu.zs", "caelum/ui/CaelumLiveMenuControls.zs",
    "caelum/world/CaelumSewerMaze.zs", "caelum/world/CaelumStashChest.zs",
    "caelum/world/CaelumPhysicalHazards.zs",
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    hashes = {runtime: sha(WORK / runtime / "caelum_argenteum_dev.pk3")
              for runtime in ("baseline", "current")}
    records = []
    for label in REQUIRED:
        run = json.loads((WORK / f"{label}-run.json").read_text(encoding="utf-8-sig"))
        log = (WORK / f"{label}.txt").read_text(encoding="utf-8-sig")
        assert run["exit_code"] == 0 and not run.get("timed_out"), label
        assert not re.search(r"CA381 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR", log), label
        passes = len(re.findall(r"CA381 PASS ", log))
        assert passes > 0 or label == "release-smoke", label
        assert run["package_sha256"].lower() == hashes[run["runtime"]], label
        for suffix in (".txt", "-run.json"):
            shutil.copy2(WORK / f"{label}{suffix}", HERE / f"{label}{suffix}")
        records.append({
            "label": label, "passes": passes, "runtime": run["runtime"],
            "package_sha256": hashes[run["runtime"]],
            "addon_sha256": run["addon_sha256"].lower(),
            "log_sha256": sha(WORK / f"{label}.txt"),
        })
    # Compare this issue against the preceding #377 delivery, not against 5.5.8a.
    prior = ROOT / "build/issue377/current/caelum_argenteum_dev.pk3"
    with zipfile.ZipFile(prior) as old, zipfile.ZipFile(WORK / "current/caelum_argenteum_dev.pk3") as new:
        old_names, new_names = set(old.namelist()), set(new.namelist())
        assert not old_names - new_names, "Removed package members"
        changed = {
            name for name in new_names
            if name not in old_names
            or old.read(name).replace(b"\r\n", b"\n") != new.read(name).replace(b"\r\n", b"\n")
        }
        assert changed == ALLOWED, changed
        for name in new_names:
            assert (ROOT / "src" / name).read_bytes().replace(b"\r\n", b"\n") == new.read(name).replace(b"\r\n", b"\n"), name
    exploratory = [
        "probe-travel-01", "probe-travel-02", "storage-suite-01", "storage-suite-02",
        "storage-suite-03", "storage-suite-04", "storage-travel-01", "legacy-save-01",
        "storage-cardinal-01", "storage-ui-01", "final-cardinal-reload",
    ]
    for label in exploratory:
        for suffix in (".txt", "-run.json"):
            source = WORK / f"{label}{suffix}"
            if source.exists():
                shutil.copy2(source, HERE / f"exploratory-{label}{suffix}")
    images = {}
    for name in ("storage-en.png", "storage-es.png"):
        shutil.copy2(WORK / name, HERE / name)
        images[name] = sha(HERE / name)
    report = {
        "issue": 381, "release": "5.6.2", "runs": records,
        "passing_assertions": sum(r["passes"] for r in records),
        "unexpected_failures": 0, "package_changed_members": sorted(changed),
        "comparison_package_561_sha256": sha(prior),
        "synthetic_saves_retained_locally": {p.name: sha(p) for p in WORK.glob("ca381-*.zds")},
        "images": images, "author_acceptance": "passed CA381-01 on 2026-10-20; startup qualification in HISTORY",
    }
    (HERE / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    rows = "\n".join(f"| {r['label']} | {r['runtime']} | {r['passes']} |" for r in records)
    text = f"""# Issue #381 validation — release 5.6.2

The final storage runtime passes **{len(records)} required native runs,
{report['passing_assertions']} assertions and zero failures**, including a normal
package-only startup. **CA381-01 passed author review on 2026-10-20 (startup qualification in HISTORY).**

| Run | Runtime | Passing assertions |
| --- | --- | ---: |
{rows}

## Evidence and coverage

GZDoom 4.14.2, Windows 11, Vulkan, 1280x720; sequential native sessions, unpaused
background simulation and 5% master audio. Per-run JSON records CPU/GPU/driver,
engine/IWAD/package/addon hashes, command and configuration. No executable, IWAD,
fixture PK3 or save is distributed. The 5.5.8a baseline package is retained
locally with its original synthetic save. The issue-only package comparison
against 5.6.1 permits exactly fifteen changed/new members and no removal
(PhysicalHazards changes only its required release label);
all packaged bytes match source after newline normalization.

The 51-assertion suite covers authored capacity/dimensions/mass, exact equipment
identity/wear, no repeat deposit, recipient-dependent unclaimed equipment,
nonbinding preview/capacity failure, equipped/reserved/temporary/Tarot rejection,
individual water volume and duplicate-personal restrictions, manual learning,
arrow/bolt Box restrictions, partial stacks/provenance, slot and weight bounds,
missing quantities, stale rows/counts, wrong/closed session, unbound pawn, carried
mass/no nesting, placement, destruction and existing native lock state.
Two distinct requesting pawns claim the same entry sequentially by temporarily
rebinding one test PlayerInfo slot; the second authoritative request fails.
This is a local ownership check, not a network multiplayer test.

The actual 5.5.8a fixture contains an open/unlocked prototype and a partly emptied
maze chest with exact native remaining references. Upgrade/reload preserves
those states and repeats revision-1 initialization without reseeding. The revised
filled, carried chest saves/reloads with its storage session open. Equipment,
materials, exact load and nonzero TID survive TMAINT -> THAZARD -> TMAINT ->
MAP02 -> MAP01. A partial cardinal allocation survives MAP02 -> THAZARD ->
MAP02 and a separate reload without materializing retired equipment.
Five MAP01 checks preserve raw-material quota/prepayment and temporary cleanup.

For reversal, the fixture removes the new storage session, restores the prior
open state and saves the original chest/item classes. Actual 5.5.8a loads that
save and the untouched original save successfully. Added metadata is ignored
by the old runtime; this is not a promise that new carried-container classes
can be loaded with the old package. Keep the original save/package pair for
full rollback before adopting new content.

The English and Spanish screenshots were inspected after integrating storage
with CaelumLiveMenu. Keyboard, mouse rows/buttons and wheel share PanelKey/
network commands. Real interaction received separate author acceptance CA381-01 on
2026-10-20; image inspection and scripted commands alone did not establish it.
Independent static AI review covered transfer safeguards and final menu routing.

## Exploratory findings

Failed logs are retained separately and excluded from passing counts. The first
travel probe had a fixture compile error, then confirmed native owner survival.
A nonzero TID later exposed a real map-local registration loss, corrected by
unregistering before travel and reinserting on arrival. Placement initially
tested sight against an intentionally invisible carried body; visibility is
now ignored while geometry is still checked. The first screenshot exposed a
missing native menu context, corrected before final UI inspection.

Other failures were fixture defects: small-tier assignment before storage
initialization, zero-weight equipment setup, nullable legacy catalogue slots,
and an initial changemap before the game had loaded. A short cardinal-reload
script ended without executing its assertion; the collector rejects empty
assertion runs and the longer corrected reload passes. Test additions changed
addon hashes; each run records its exact addon. Production source/package drift
is rejected, and only applicable final-package evidence enters the required set.
The retained pre-release-labels records preceded two required diagnostic version
label corrections. The release-* reruns are the final-package gates above.

## Reproduction and limits

Run `python assets/validation_562/prepare.py`, then
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_562/run_native.ps1`
with a fresh `-Label`, `-Checks`, and the desired `-Script` from prepare.py.
Use `-Runtime baseline -LegacyChecks` for actual 5.5.8a. LoadGame accepts a filename
relative to build/issue381; keep exact packages beside the synthetic saves.
`collect.py` validates/logs final gates; `validate_project.py` and normal packaging
are separate checks. Fixtures are synthetic, not ordinary campaign saves.

No new chest damage threshold, recipe, campaign placement, padlock/title/theft
rule or reward stock is approved here. Existing archived LegacyLoot is excluded
by its native reference; ordinary destruction is tested with acquired equipment,
not every historical archive variation. Native allocation exhaustion, full
network multiplayer, frame presentation/FPS and author acceptance are not claimed.
"""
    (HERE / "RESULTS.md").write_text(text, encoding="utf-8")
    print(f"PASS: {len(records)} final runs, {report['passing_assertions']} assertions; no failures.")


if __name__ == "__main__":
    main()
