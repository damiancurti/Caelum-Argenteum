"""Copy isolated saves to test upgrade or the specific 5.4.8 rollback bridge."""
from pathlib import Path
import argparse,importlib.util,shutil,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room209',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True);p.add_argument('--mode',choices=['upgrade','rollback'],required=True)
p.add_argument('--source',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False);shutil.copyfile(a.runtime,out/'production.pk3')
if a.mode=='rollback':
    shutil.copyfile(a.source/'hunter.zds',out/'hunter.zds')
    with zipfile.ZipFile(a.source/'hunter.pk3') as z:entries={n:z.read(n) for n in z.namelist() if n.startswith('maps/') or n=='MAPINFO'}
    entries['MAPINFO']=entries['MAPINFO'].replace(b'CA239Probe',b'CA239Rollback')
    entries['ZSCRIPT']=b'version "4.14"\n#include "rollback.zs"\n';entries['rollback.zs']=(HERE/'rollback_bridge.zs').read_bytes()
    script='wait 25; save rollback.zds; wait 5; quit\n'
else:
    shutil.copyfile(a.source/'stage.zds',out/'stage.zds')
    with zipfile.ZipFile(a.source/'probe-v2.pk3') as z:entries={n:z.read(n) for n in z.namelist()}
    entries['ZSCRIPT']+=b'\n#include "upgrade.zs"\n';entries['upgrade.zs']=(HERE/'upgrade.zs').read_bytes()
    entries['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA239Upgrade" }\n'
    script='wait 25; quit\n'
print(room.package(out/'hunter.pk3',entries));(out/'verify.cfg').write_bytes(script.encode())
