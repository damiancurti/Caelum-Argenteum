"""Retain scoped native state evidence; recipe integration is tested separately."""
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / "build/issue471-batches"
NATIVE = HERE / "native"
NATIVE.mkdir(exist_ok=True)
hash_bytes = lambda value: hashlib.sha256(value).hexdigest()
runs = []
for label, expected in (("batch-seed01", 16), ("batch-load01", 10), ("batch-travel02", 27)):
    log = (WORK / f"{label}.txt").read_bytes()
    decoded = log.decode("utf-8-sig", errors="replace")
    assert len(re.findall(r"^CA471B PASS ", decoded, re.M)) == expected
    assert not re.search(r"CA471B FAIL|VM execution aborted|Script error|Execution could not continue", decoded)
    if "travel" in label:
        assert "failed=0 map=CABAT2" in decoded
    record = json.loads((WORK / f"{label}-run.json").read_text(encoding="utf-8-sig"))
    assert record["exit_code"] == 0
    for suffix in (".txt", "-run.json"):
        shutil.copy2(WORK / f"{label}{suffix}", NATIVE / f"{label}{suffix}")
    runs.append({"label": label, "passed": expected, "package_sha256": record["package_sha256"], "addon_sha256": record["addon_sha256"]})
for suffix in (".txt", "-run.json"):
    shutil.copy2(WORK / f"batch-travel01{suffix}", NATIVE / f"batch-travel01{suffix}")
package = WORK / "current/caelum_argenteum_dev.pk3"
with zipfile.ZipFile(package) as archive:
    modified = {name: hash_bytes(archive.read(name)) for name in ("ZSCRIPT", "caelum/crafting/CaelumFermentationBatch.zs")}
    for name, sha in modified.items():
        assert hash_bytes((ROOT / "src" / name).read_bytes()) == sha
    entries = len(archive.namelist())
report = {"issue": 471, "stage": "fermentation-state foundation", "passed": sum(r["passed"] for r in runs),
          "runs": runs, "package_entries": entries, "package_sha256": hash_bytes(package.read_bytes()),
          "tested_runtime_files": modified, "author_acceptance": False,
          "excluded": [{"label": "batch-travel01", "reason": "Console changemap did not reach CABAT2; seed assertions alone are not travel evidence. Fixed fixture uses native level.ChangeLevel."}],
          "limits": "Tests use synthetic fixture values, not a gameplay recipe. No menu, transaction, catalogue, merchant or multiplayer validation is claimed."}
(HERE / "batch_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(json.dumps({"passed": report["passed"], "runs": len(runs), "entries": entries}))
