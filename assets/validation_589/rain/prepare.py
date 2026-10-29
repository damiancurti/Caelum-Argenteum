"""Reuse the accepted isolated exposure fixture with an uncovered urban floor."""
from pathlib import Path
import zipfile,importlib.util,re
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=ROOT/'build/issue502/rain';OUT.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('room',ROOT/'assets/validation_580/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
with zipfile.ZipFile(ROOT/'build/issue502/exposure/checks.pk3') as base:
 members={n:base.read(n) for n in base.namelist()}
members['ZSCRIPT']+=b'#include "rain.zs"\n'
members['rain.zs']=(HERE/'checks.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'CA502ExposureChecks',b'CA502RainChecks')
text=room.room().replace('sector {','sector { user_ca_contamination_class=2;')
text=re.sub(r'textureceiling="[^"]+";', 'textureceiling="F_SKY1";',text)
for name in ['CTX502','CTX502B']:members['maps/'+name+'.wad']=room.wad(text,name)
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
 for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
(OUT/'core.cfg').write_text('wait 35; netevent ca502_rain; wait 5; quit\n',encoding='utf-8')
print('Prepared urban rain fixture.')
