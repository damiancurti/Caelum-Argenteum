"""Collect issue233 native evidence and compare real engine-created saves."""
from pathlib import Path
import hashlib
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / "build/issue233"
RUNS = ["edit-final-01", "reload-01", "hub-01", "old-save-02",
        "migration-01", "layout-es-02", "layout-en-02", "privacy-01"]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def saved(name, map_id="map04"):
    with zipfile.ZipFile(WORK / (name + ".zds")) as archive:
        return json.loads(archive.read(map_id + ".map.json"))


def objects(data, kind):
    return [o for o in data["objects"] if o["classtype"] == kind]


def notes(data):
    return sorted((o["class:CaelumMapNote"] for o in objects(data, "CaelumMapNote")),
                  key=lambda o: (o.get("MapId", ""), o.get("Id", 0)))


def record(data):
    result = objects(data, "CaelumPersistentCharacterState")[0]["class:CaelumPersistentCharacterState"].copy()
    # Native save object-table indices can change on reload. Compare the owned
    # identity objects' complete values, not their relocation slots.
    for field in ("IdentityProfile", "IdentityAllocation"):
        if field in result:
            result[field] = data["objects"][result[field]]
    return result


runtime = digest(WORK / "production.pk3")
records, captures = [], []
(HERE / "captures").mkdir(exist_ok=True)
for label in RUNS:
    run = json.loads((WORK / (label + "-run.json")).read_text(encoding="utf-8-sig"))
    log = (WORK / (label + ".txt")).read_text(encoding="utf-8-sig")
    assert run["exit_code"] == 0 and "CA233 DONE failures=0" in log, label
    assert not any(s in log for s in ("CA233 FAIL", "Script error", "VM execution aborted",
                                     "This savegame needs")), label
    if label.startswith(("edit", "layout")):
        assert "CA233 UI DONE failures=0" in log, label
    if run["production_sha256"]:
        assert run["runtime_sha256"].lower() == runtime, label
    run["assertions"] = log.count("CA233 PASS ")
    records.append(run)
    for name in (label + ".txt", label + "-run.json", label + "-exec.cfg"):
        shutil.copyfile(WORK / name, HERE / name)
    for path in sorted(WORK.glob(label + "-*.png")):
        shutil.copyfile(path, HERE / "captures" / path.name)
        captures.append({"file": "captures/" + path.name, "sha256": digest(path)})

old = saved("c233-old-verified")
migrated = saved("c233-migrated")
old_fields = {k: v for k, v in record(migrated).items() if not k.startswith("Manual")}
current = saved("c233-notes")
reloaded = saved("c233-reloaded")
returned = saved("c233-hubback")
other_map = saved("c233-map05", "map05")
first = notes(current)[0]
# GZDoom's JSON serializer escapes the internal UTF-8 bytes individually.
unicode_text = first["Text"].encode("latin-1").decode("utf-8")
checks = {
    "old_save_all_prior_character_values": record(old) == old_fields,
    "old_save_native_automap": objects(old, "Automap") == objects(migrated, "Automap"),
    "old_save_native_linedefs": old["linedefs"] == migrated["linedefs"],
    "current_reload_exact_notes": notes(current) == notes(reloaded),
    "current_reload_native_numbered_marks_and_automap": objects(current, "Automap") == objects(reloaded, "Automap"),
    "current_reload_native_linedefs": current["linedefs"] == reloaded["linedefs"],
    "current_long_unicode_text_exact": unicode_text == "Long English / español: áéíóú ñ. " * 40,
    "hub_original_map_exact_notes": notes(current) == [n for n in notes(returned) if n["MapId"] == "MAP04"],
    "hub_other_map_distinct_note": len([n for n in notes(other_map) if n["MapId"] == "MAP05"]) == 1,
    "hub_same_coordinates_different_map": len(notes(returned)) == 2
        and notes(returned)[0]["position"] == notes(returned)[1]["position"],
}
assert all(checks.values()), checks
validation = json.loads((WORK / "validate.json").read_text(encoding="utf-8-sig"))
assert validation["errors"] == []
for name in ("validate.json", "build.txt"):
    shutil.copyfile(WORK / name, HERE / name)
with zipfile.ZipFile(WORK / "production.pk3") as a, zipfile.ZipFile(ROOT / "build/caelum_argenteum_dev.pk3") as b:
    assert set(a.namelist()) == set(b.namelist())
    assert all(a.read(n) == b.read(n) for n in a.namelist())

evidence = {
    "issue": 233, "version": "5.3.6", "baseline_commit": "8f5cf9d8",
    "runtime_sha256": runtime, "runs": records,
    "native_assertions": sum(r["assertions"] for r in records),
    "save_comparisons": checks, "captures": captures,
    "old_save_sha256": digest(WORK / "c233-old-verified.zds"),
    "normal_build_members_match_frozen": True,
    "author_acceptance": {'id': 'CA233-01', 'status': 'Tracked separately in RESULTS.md and docs/HISTORY.md; native runs do not imply author acceptance.'},
    "limits": [
        "Fixture menu dispatch and native commands are not physical typing acceptance.",
        "Manual placement uses native map center; selection uses the list, not cursor-world picking.",
        "Native text append/backspace and controller character-grid capabilities are retained.",
        "Per-character bot isolation does not certify general multiplayer gameplay.",
        "Old-save recovery retains the unchanged old package/save; downgrade of new-schema saves is not promised.",
    ],
}
(HERE / "evidence.json").write_bytes((json.dumps(evidence, indent=2) + "\n").encode())
print(f"Collected {len(records)} runs, {evidence['native_assertions']} assertions, "
      f"{len(checks)} save comparisons and {len(captures)} captures.")
