"""Prepare the local author lab using owned actors and the existing fixture map."""
from pathlib import Path
import importlib.util
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue428/manual';OUT.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('communication_fixture',HERE/'prepare.py')
fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
members={'ZSCRIPT':b'version "4.14"\n#include "manual.zs"\n',
    'manual.zs':(HERE/'manual.zs').read_bytes(),'maps/CA510L.wad':fixture.room(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA510Lab" }\nmap CA510L "V5.10 - Perception lab" { }\n'}
with zipfile.ZipFile(OUT/'manual.pk3','w',zipfile.ZIP_STORED) as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print('Prepared visible author lab with native actors and on-screen controls.')
