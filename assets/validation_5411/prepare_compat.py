"""Test old-save upgrade and optional 5.4.10 rollback on copied saves only."""
from pathlib import Path
import argparse, importlib.util, shutil, zipfile
ROOT=Path(__file__).resolve().parents[2]; HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--directory',required=True);p.add_argument('--runtime',required=True,type=Path)
p.add_argument('--fixture',required=True,type=Path);p.add_argument('--save',type=Path)
p.add_argument('--mode',choices=['seed','upgrade','rollback','return'],required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False);shutil.copyfile(a.runtime,out/'production.pk3')
source=(HERE/'compatibility.zs').read_text(encoding='utf-8')
if a.mode in ['seed','rollback']:
    source='class CaelumSurvivalInstinctEffect : Inventory { int Revision, RemainingTics; double Multiplier; Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE } States { Spawn: TNT1 A -1; Stop; } }\n'+source
if a.mode=='rollback':
    source=source.replace('// ROLLBACK_ACTION','let it=ThinkerIterator.Create("CaelumSurvivalInstinctEffect"); Inventory effect; while((effect=Inventory(it.Next()))!=null){effect.Destroy();Cleared++;} CaelumClassAbilityRules.Cancel(User);')
with zipfile.ZipFile(a.fixture) as z:entries={n:z.read(n) for n in z.namelist() if n.startswith('maps/')}
entries['ZSCRIPT']=b'version "4.14"\n#include "compatibility.zs"\n';entries['compatibility.zs']=source.encode()
entries['MAPINFO']=b'GameInfo { AddEventHandlers="CA244Compat" }\ncluster 99 { hub }\nmap MAP99 "Survival Instinct compatibility" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Survival Instinct hub" { cluster=99 sky1="SKY1",0 }\n'
print(room.package(out/'instinct.pk3',entries))
if a.save:shutil.copyfile(a.save,out/'input.zds')
script='wait 100; netevent c244_seed; save neutral.zds; wait 5; quit\n' if a.mode=='seed' else 'wait 20; netevent c244_verify; save migrated.zds; wait 5; quit\n'
(out/'verify.cfg').write_bytes(script.encode())
