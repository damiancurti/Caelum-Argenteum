"""Build the isolated #377 addon deterministically; never package test data in src."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue377"
OUT.mkdir(parents=True, exist_ok=True)
members = {
    "ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
    "MAPINFO": b'GameInfo { AddEventHandlers = "CA377Checks" }\n',
    "checks.zs": (HERE / "checks.zs").read_bytes(),
}
with zipfile.ZipFile(OUT / "checks.pk3", "w", zipfile.ZIP_STORED) as archive:
    for name, contents in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), contents)
scripts = {
    "suite": "wait 35; netevent ca377_suite; wait 5; quit",
    "baseline-save": "wait 35; netevent ca377_save; wait 5; save ca377-baseline; wait 5; quit",
    "current-save": "wait 35; netevent ca377_save; wait 5; save ca377-current; wait 5; quit",
    "verify": "wait 5; netevent ca377_verify; wait 5; quit",
    "upgrade": "wait 5; netevent ca377_verify; wait 5; save ca377-upgraded; wait 5; quit",
    "travel": "wait 5; netevent ca377_travelcheck; changemap THAZARD; wait 35; netevent ca377_verify; "
              "changemap TMAINT; wait 35; netevent ca377_travelcheck; changemap MAP02; wait 35; "
              "netevent ca377_travelcheck; changemap MAP01; wait 35; netevent ca377_verify; wait 5; quit",
    "interactive": "exec ../../assets/playtest/default_controls.cfg; wait 35; netevent ca377_save; wait 5; toggleconsole",
}
for name, commands in scripts.items():
    (OUT / f"{name}.cfg").write_text(commands + "\n", encoding="utf-8", newline="\n")
print("Prepared #377 isolated addon and scripts.")
