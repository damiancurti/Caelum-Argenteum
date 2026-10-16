"""Copy an isolated #242 save and supply a 5.4.4-only compatibility bridge."""
from pathlib import Path
import argparse,importlib.util,shutil,zipfile,json
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('package541',HERE.parent/'validation_541/prepare.py');shared=importlib.util.module_from_spec(spec);spec.loader.exec_module(shared)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);p.add_argument('--source',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
shutil.copyfile(a.runtime,out/'production.pk3');shutil.copyfile(a.source/'breathing.zds',out/'breathing.zds')
with zipfile.ZipFile(a.source/'breathing.pk3') as z:entries={n:z.read(n) for n in z.namelist() if n.startswith('maps/') or n=='MAPINFO'}
entries['MAPINFO']=entries['MAPINFO'].replace(b'CA242Probe',b'CA242Rollback')
entries['ZSCRIPT']=b'version "4.14"\n#include "rollback.zs"\n';entries['rollback.zs']=(HERE/'rollback_bridge.zs').read_bytes()
print(shared.package(out/'breathing.pk3',entries))
(out/'rollback.cfg').write_text('wait 25; save rollback.zds; wait 5; quit\n',encoding='utf-8')
