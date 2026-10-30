"""Reuse the native speed room for isolated species damage/save checks."""
from pathlib import Path
import importlib.util
import zipfile

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("room", ROOT / "assets/validation_v5_11_4/prepare_speed.py")
room = importlib.util.module_from_spec(spec)
spec.loader.exec_module(room)
OUT = ROOT / "build/issue586"
OUT.mkdir(parents=True, exist_ok=True)
files = {"ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
         "checks.zs": Path(__file__).with_name("checks.zs").read_bytes(),
         "maps/MAP03.wad": room.wad,
         "MAPINFO": b'GameInfo { AddEventHandlers="CA586Checks" }\n'}
with zipfile.ZipFile(OUT / "checks.pk3", "w") as archive:
    for name, data in sorted(files.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
with zipfile.ZipFile(OUT / "manual-view.pk3", "w") as archive:
    for name, data in {"ZSCRIPT": b'version "4.14"\n#include "manual_view.zs"\n',
                       "manual_view.zs": Path(__file__).with_name("manual_view.zs").read_bytes(),
                       "MAPINFO": b'GameInfo { AddEventHandlers="CA586ManualView" }\n'}.items():
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
