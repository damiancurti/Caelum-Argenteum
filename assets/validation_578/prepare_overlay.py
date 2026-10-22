"""Prepare a local development overlay against the committed foundation PK3."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue479'
with zipfile.ZipFile(OUT/'current/caelum_argenteum_dev.pk3') as base, zipfile.ZipFile(OUT/'fixture.pk3') as fixture:
    known=set(base.namelist()); members={name:fixture.read(name) for name in fixture.namelist()}
    includes=[]
    for source in sorted((ROOT/'src').rglob('*')):
        if not source.is_file():continue
        name=source.relative_to(ROOT/'src').as_posix()
        if name=='ZSCRIPT':continue
        data=source.read_bytes()
        if name not in known or data!=base.read(name):members[name]=data
        if name not in known and name.endswith('.zs'):includes.append(f'#include "{name}"\n')
    anchor='caelum/data/CaelumSupportImplementData.zs'
    members[anchor]=(ROOT/'src'/anchor).read_bytes()+b'\n'+''.join(includes).encode()
    members['ZSCRIPT']=b'version "4.14"\n'+(ROOT/'assets/validation_578/fixture.zs').read_bytes()+b'\n'+(ROOT/'assets/validation_578/gameplay.zs').read_bytes()
with zipfile.ZipFile(OUT/'overlay.pk3','w',zipfile.ZIP_STORED) as package:
    for name,data in sorted(members.items()):package.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print(f'Prepared {len(members)} overlay entries; final delivery must use a normal full build.')
