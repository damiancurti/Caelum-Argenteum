"""Prepare private fermentation-state save/travel tests, without recipe balance."""
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue471-batches"
OUT.mkdir(parents=True, exist_ok=True)
common = Path(subprocess.check_output(
    ["git", "rev-parse", "--path-format=absolute", "--git-common-dir"],
    cwd=ROOT, text=True).strip()).parent
with zipfile.ZipFile(common / "build/issue405/checks.pk3") as source:
    room = source.read("maps/CARESRC.wad")
members = {
    "ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
    "MAPINFO": b'GameInfo { AddEventHandlers="CA471BatchChecks" }\n'
               b'map CABAT1 "Batch persistence A" { next="CABAT2" }\n'
               b'map CABAT2 "Batch persistence B" {}\n',
    "checks.zs": (HERE / "batch_checks.zs").read_bytes(),
    "maps/CABAT1.wad": room,
    "maps/CABAT2.wad": room,
}
with zipfile.ZipFile(OUT / "checks.pk3", "w", zipfile.ZIP_STORED) as package:
    for name, data in sorted(members.items()):
        package.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
scripts = {
    "seed": "wait 105; netevent ca471b_seed; wait 5; save ca471b-seeded; wait 10; quit",
    "resume": "wait 105; netevent ca471b_resume; wait 10; quit",
    "travel": "wait 105; netevent ca471b_seed; wait 5; netevent ca471b_go; wait 105; netevent ca471b_arrived; wait 10; quit",
}
for name, script in scripts.items():
    (OUT / f"{name}.cfg").write_text(script + "\n", encoding="utf-8")
print(f"Prepared {OUT}")
