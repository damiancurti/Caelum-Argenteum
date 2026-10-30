"""Overlay only household relocation and its focused native checks."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
out=ROOT/'build/issue581';out.mkdir(parents=True,exist_ok=True)
files={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','MAPINFO':b'GameInfo { AddEventHandlers="CA581Checks" }\n','checks.zs':Path(__file__).with_name('checks.zs').read_bytes()}
files['ZSCRIPT']+=b'\nclass CA581Legacy : CA581Checks {}\n'
for name in ('caelum/data/CaelumArrivalHouseholdData.zs','caelum/world/CaelumArrivalHousehold.zs','caelum/world/CaelumHouseHub.zs'):
 files[name]=(ROOT/'src'/name).read_bytes()
with zipfile.ZipFile(out/'checks.pk3','w') as z:
 for n,b in sorted(files.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)

with zipfile.ZipFile(out/'legacy-checks.pk3','w') as z:
 for n,b in {'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n','MAPINFO':b'GameInfo { AddEventHandlers="CA581Legacy" }\n','legacy.zs':Path(__file__).with_name('legacy.zs').read_bytes()}.items():z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
