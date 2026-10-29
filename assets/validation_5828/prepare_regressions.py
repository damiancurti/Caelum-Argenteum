"""Reuse accepted fixtures, adapting explicit injected samples to revision3."""
from pathlib import Path
import runpy
import zipfile
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue502-weather'
OLD=ROOT/'build/issue502-hygiene'
OLD.mkdir(exist_ok=True)
runpy.run_path(str(ROOT/'assets/validation_5812/prepare_contact.py'))
runpy.run_path(str(ROOT/'assets/validation_5812/prepare_objects.py'))
runpy.run_path(str(ROOT/'assets/validation_5823/prepare.py'))

def adapt(source,target,changes):
    with zipfile.ZipFile(source) as archive:
        members={n:archive.read(n) for n in archive.namelist()}
    text=members['checks.zs'].decode('utf-8')
    for before,after in changes:
        assert before in text,before
        text=text.replace(before,after)
    members['checks.zs']=text.encode('utf-8')
    with zipfile.ZipFile(WORK/target,'w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)

adapt(OLD/'object-checks.pk3','objects.pk3',[
    ('n.Ambient=80;n.Rain=0;n.Stamp-=10;', 'n.HistoryReady=false;n.Ambient=80;n.Rain=0;n.Stamp-=10;'),
    ('gear.Ambient=80;gear.Rain=0;gear.Stamp-=10;', 'gear.HistoryReady=false;gear.Ambient=80;gear.Rain=0;gear.Stamp-=10;'),
])
adapt(ROOT/'build/issue410-cooking/history-checks.pk3','limbo.pk3',[
    ('Revision==2','Revision==3'),
    ('revision2 constant interval','revision3 constant interval'),
    ('Check(!node.HistoryReady,"variable exterior climate is not frozen into a false constant history");',
     'Check(node.HistoryReady && node.HistoryVariable,"regional weather records natural history rather than a frozen constant");'),
])
(WORK/'objects-core.cfg').write_text('wait 70; netevent ca502o_prepare; wait 3; netevent ca502o_core; wait 3; quit\n')
(WORK/'objects-storage.cfg').write_bytes((OLD/'object-storage.cfg').read_bytes())
for name in ['core','hub']:
    (WORK/('limbo-'+name+'.cfg')).write_bytes((ROOT/'build/issue410-cooking'/('history-'+name+'.cfg')).read_bytes())
print('Prepared scoped storage/ownership and constant-Limbo regressions.')
