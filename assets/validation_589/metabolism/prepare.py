"""Reuse native geometry; add metabolic checks without changing prior fixtures."""
from pathlib import Path
import zipfile
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
OUT=ROOT/'build/issue502/metabolism';OUT.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(ROOT/'build/issue502/immersion_wash/checks.pk3') as base:
    members={name:base.read(name) for name in base.namelist()}
members['ZSCRIPT']+=b'#include "metabolism.zs"\n'
members['metabolism.zs']=(HERE/'checks.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'CA502WashChecks',b'CA502MetabolicChecks')
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
 'core':'wait 35; netevent ca502_metabolism; wait 5; quit',
 'forecast':'wait 35; netevent ca502_metabolic_forecast; wait 5; quit',
 'pool':'wait 35; netevent ca502_wash_manual; wait 5; netevent ca502_metabolic_pool; wait 5; quit',
 'save':'wait 35; netevent ca502_metabolic_seed; save ca502-metabolism; wait 5; quit',
 'load':'wait 1; netevent ca502_metabolic_load; wait 5; quit',
 'hub':'wait 1; netevent ca502_metabolic_load; changemap CTX502B; wait 35; netevent ca502_metabolic_load; changemap CTX502; wait 35; netevent ca502_metabolic_load; wait 5; quit'
}
for name,script in scripts.items():(OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
with zipfile.ZipFile(ROOT/'build/issue502/immersion/checks.pk3') as base:
    legacy={name:base.read(name) for name in base.namelist()}
probe=b'''let illness=CaelumFoodIllness.Get(u);
            Check(illness.MetabolismRevision==1 && illness.ToiletCapacity==0,"old save migrates no retrospective metabolic credit");
            illness.Satiation(25);illness.Ensure();
            Check(illness.ToiletCapacity==1.25,"migrated capacity survives repeated initialization");'''
legacy['immersion.zs']=legacy['immersion.zs'].replace(b'Check(CaelumFoodIllness.Value(u)>=25,',probe+b'\n            Check(CaelumFoodIllness.Value(u)>=25,')
(OUT/'legacy').mkdir(exist_ok=True)
with zipfile.ZipFile(OUT/'legacy/checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(legacy.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
print('Prepared metabolic fixtures.')
