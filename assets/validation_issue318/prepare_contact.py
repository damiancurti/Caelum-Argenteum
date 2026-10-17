"""Freeze contact-heat correctness fixtures and a genuine previous-runtime seed."""
from pathlib import Path
import argparse
import importlib.util
import json
import shutil
import hashlib
import zipfile

def package(path,members):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as archive:
        for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
assert a.directory and all(c.isalnum() or c in '-_' for c in a.directory)
spec=importlib.util.spec_from_file_location('geometry',HERE.parent/'validation_5421/prepare.py')
geometry=importlib.util.module_from_spec(spec);spec.loader.exec_module(geometry)
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
for mode in ('current','legacy'):
    work=out/mode;work.mkdir()
    if mode=='current':
        runtime=package(work/'runtime.pk3',{q.relative_to(ROOT/'src').as_posix():q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()})
    else:
        import hashlib
        old=ROOT/'build/issue318-audit-02/base/runtime.pk3'
        assert hashlib.sha256(old.read_bytes()).hexdigest()=='e5d86d59108f3fc3e5a6c16567c31034cc32c0a67e9b7f96ec48079ec3bd8fb2'
        shutil.copyfile(old,work/'runtime.pk3');runtime=hashlib.sha256(old.read_bytes()).hexdigest()
    fixture=package(work/'contact.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "common.zs"\n#include "checks.zs"\n',
        'common.zs':(HERE/'contact_common.zs').read_bytes(),
        'checks.zs':(HERE/('contact_checks.zs' if mode=='current' else 'contact_legacy.zs')).read_bytes(),
        'maps/MAP99.wad':geometry.wad().replace(b'x=640;',b'x=544;'),
        'maps/MAP98.wad':geometry.wad().replace(b'x=640;',b'x=544;'),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA318HeatProbe" }\ncluster 99 { hub }\nmap MAP99 "Contact heat fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Contact heat hub" { cluster=99 nointermission sky1="SKY1",0 }\n'})
    (work/'manifest.json').write_text(json.dumps({'runtime_sha256':runtime,'fixture_sha256':fixture,'mode':mode},indent=2)+'\n')
start='wait 100; netevent c318_setup; wait 5; '
done='netevent c318_done; wait 5; quit\n'
scripts={
    'contact':start+'netevent c318_contact; '+done,
    'status':start+'netevent c318_status; '+done,
    'queue':start+'netevent c318_queue; '+done,
    'player':start+'netevent c318_player; '+done,
    'save':start+'netevent c318_seed; storesavepic false; save contact.zds; wait 5; '+done,
    'load':'wait 5; netevent c318_loaded; storesavepic false; save repeated.zds; wait 5; '+done,
    'consume':'wait 5; netevent c318_loaded; netevent c318_consume; '+done,
    'hub':'wait 5; netevent c318_loaded; changemap MAP98; wait 20; changemap MAP99; wait 20; netevent c318_loaded; '+done,
    'legacy':'wait 100; netevent c318_legacy; storesavepic false; save legacy.zds; wait 5; '+done,
    'upgrade':'wait 5; netevent c318_upgrade; storesavepic false; save upgraded.zds; wait 5; '+done,
}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script,encoding='utf-8')
print(out)
