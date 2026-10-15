"""Freeze copied neutral-save upgrade/rollback checks; retain the original save."""
from pathlib import Path
import argparse,importlib.util,json,zipfile,hashlib,shutil
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True);p.add_argument('--runtime',type=Path,required=True)
p.add_argument('--maps',type=Path,required=True);p.add_argument('--save',type=Path);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False);shutil.copyfile(a.runtime,out/'production.pk3')
with zipfile.ZipFile(a.maps) as z:entries={'maps/MAP99.wad':z.read('maps/MAP99.wad')}
entries.update({'ZSCRIPT':b'version "4.14"\n#include "compatibility.zs"\n','compatibility.zs':(HERE/'compatibility.zs').read_bytes(),
 'MAPINFO':b'GameInfo { AddEventHandlers="CA250Compat" }\nmap MAP99 "Redemption copied-save compatibility" { sky1="SKY1",0 }\n'})
manifest={'runtime_sha256':hashlib.sha256(a.runtime.read_bytes()).hexdigest(),'fixture_sha256':room.package(out/'redemption.pk3',entries)}
if a.save:
    shutil.copyfile(a.save,out/'input.zds');manifest['original_save_sha256']=hashlib.sha256(a.save.read_bytes()).hexdigest()
script='wait 20; netevent c250_verify; wait 2; save migrated.zds; wait 2; netevent c250_done; wait 2; quit\n' if a.save else 'wait 100; netevent c250_seed; wait 2; save neutral.zds; wait 2; netevent c250_done; wait 2; quit\n'
(out/'verify.cfg').write_bytes(script.encode());(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(manifest))
