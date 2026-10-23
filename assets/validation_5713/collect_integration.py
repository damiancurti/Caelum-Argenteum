"""Retain final packaged native evidence, with byte-level source verification."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / "build/issue471-batches"
NATIVE = HERE / "native"
digest = lambda data: hashlib.sha256(data).hexdigest()
package = WORK / "current/caelum_argenteum_dev.pk3"
package_hash = digest(package.read_bytes())
with zipfile.ZipFile(package) as archive:
    files = {path.relative_to(ROOT / "src").as_posix(): path for path in (ROOT / "src").rglob("*") if path.is_file()}
    assert set(archive.namelist()) == set(files)
    for name, path in files.items():
        assert archive.read(name) == path.read_bytes(), name
runs = []
for case in ("transactions", "processes", "catalogue", "shared", "transaction-travel", "restock", "keys", "preview", "water-seed", "water-load", "transaction-seed", "transaction-load", "old-state-load"):
    label = "final01-" + case
    record = json.loads((WORK / f"{label}-run.json").read_text(encoding="utf-8-sig"))
    log = (WORK / f"{label}.txt").read_bytes()
    decoded = log.decode("utf-8-sig", errors="replace")
    assert record["exit_code"] == 0 and record["package_sha256"].lower() == package_hash
    assert not re.search(r"CA471B FAIL|VM execution aborted|Script error|Execution could not continue", decoded)
    checks = len(re.findall(r"^CA471B PASS ", decoded, re.M))
    assert checks > 0
    if case == "transaction-travel":
        assert "failed=0 map=CABAT2" in decoded and decoded.count("failed=0 map=CABAT1") == 2
    for suffix in (".txt", "-run.json"):
        shutil.copy2(WORK / f"{label}{suffix}", NATIVE / f"{label}{suffix}")
    runs.append({"case": case, "assertions_in_log": checks, "log_sha256": digest(log), "addon_sha256": record["addon_sha256"]})
for name in ("barrel-empty.png", "barrel-active.png", "barrel-ready.png", "chemistry-menu.png", "supplies.png"):
    shutil.copy2(WORK / name, HERE / name)
report = {"issue": 471, "version": "5.7.13", "package_sha256": package_hash,
          "package_entries_matching_source": len(files), "runs": runs,
          "assertions": sum(run["assertions_in_log"] for run in runs),
          "source_hashes": {name: digest(path.read_bytes()) for name, path in files.items() if name.endswith(".zs") or name in ("ZSCRIPT", "LANGUAGE", "MODELDEF", "TEXTURES")},
          "old_save_sha256": digest((WORK / "ca471b-seeded.zds").read_bytes()),
          "author_acceptance": False,
          "limits": "Second native player is an in-process bot, not two network clients or a shared multiplayer-calendar implementation. No FPS claim. Regional mineral placements remain separately authored future content; MAP03 imports are implemented."}
(HERE / "integration_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(json.dumps({key: report[key] for key in ("assertions", "package_entries_matching_source", "package_sha256")}))
