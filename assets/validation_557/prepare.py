"""Prepare the private final-package #315 compilation smoke."""
from pathlib import Path
import shutil
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
out=ROOT/'build/issue315-contract01';out.mkdir(exist_ok=False)
shutil.copyfile(ROOT/'build/caelum_argenteum_dev.pk3',out/'production.pk3')
members={'ZSCRIPT':b'version "4.14"\n#include "smoke.zs"\n',
    'smoke.zs':(HERE/'smoke.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA315Smoke" }\n'}
with zipfile.ZipFile(out/'smoke.pk3','w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
    for name,data in sorted(members.items()):
        info=zipfile.ZipInfo(name,(2026,10,19,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o100644<<16
        archive.writestr(info,data,compresslevel=9)
print(out.relative_to(ROOT))
