"""Reuse the private dialogue room; overlay only the rental-agent correction."""
from pathlib import Path
import importlib.util
import zipfile

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('room',ROOT/'assets/validation_595/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
out=ROOT/'build/issue580';out.mkdir(parents=True,exist_ok=True)
files={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
       'checks.zs':Path(__file__).with_name('checks.zs').read_bytes(),
       'maps/MAP03.wad':room.wad(),
       'MAPINFO':b'GameInfo { AddEventHandlers="CA580Checks" }\n',
       'caelum/dialogue/CaelumRentalAgent.zs':(ROOT/'src/caelum/dialogue/CaelumRentalAgent.zs').read_bytes()}
with zipfile.ZipFile(out/'checks.pk3','w') as archive:
    for name,data in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
