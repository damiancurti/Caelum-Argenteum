"""Build an observation-only addon; never modify the production package."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "build" / "issue116"
HERE = Path(__file__).resolve().parent
OUT.mkdir(exist_ok=True)
baseline = OUT / "baseline.pk3"
if not baseline.exists():
    shutil.copyfile(ROOT / "build/caelum_argenteum_dev.pk3", baseline)
with zipfile.ZipFile(OUT / "benchmark.pk3", "w", zipfile.ZIP_STORED) as package:
    for name, data in {
        "ZSCRIPT": b'version "4.14"\n#include "benchmark.zs"\n',
        "MAPINFO": b'GameInfo { AddEventHandlers = "CA116Benchmark" }\n',
        "benchmark.zs": (HERE / "benchmark.zs").read_bytes(),
    }.items():
        info = zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0))
        package.writestr(info, data)
manifest = {
    "commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
    "package_sha256": hashlib.sha256(baseline.read_bytes()).hexdigest(),
    "addon_sha256": hashlib.sha256((OUT / "benchmark.pk3").read_bytes()).hexdigest(),
    "runtime_members": {},
}
with zipfile.ZipFile(baseline) as package:
    manifest["runtime_members"] = {
        name: hashlib.sha256(package.read(name)).hexdigest() for name in sorted(package.namelist())
    }
(HERE / "BASELINE_IDENTITY.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(json.dumps({k: v for k, v in manifest.items() if k != "runtime_members"}, indent=2))
