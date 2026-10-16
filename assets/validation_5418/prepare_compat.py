"""Build the optional #249 compatibility bridge with copied packages/saves."""
from pathlib import Path
import argparse, importlib.util, shutil, zipfile, json, hashlib
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
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
    source='''class CaelumSummonedZupay : CaelumZupayColossus {
CaelumSummoningEffect Binding; double SummonPower; bool AwaitingPlacement;
override bool IsSewerBoss(){return false;} override bool IsRetreatBoss(){return false;}
override void Tick(){} }
class CaelumSummoningEffect : Inventory {
int Revision,RemainingTics; double Range,Power; CaelumSummonedZupay Body;
Default {Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
States {Spawn:TNT1 A -1;Stop;} }
'''+source
if a.mode=='rollback':
    source=source.replace('// ROLLBACK_ACTION','''let it=ThinkerIterator.Create("CaelumSummonedZupay");Actor body;
while((body=Actor(it.Next()))!=null){body.Destroy();Cleared++;}
it=ThinkerIterator.Create("CaelumSummoningEffect");Inventory effect;
while((effect=Inventory(it.Next()))!=null)effect.Destroy();
CaelumClassAbilityRules.Cancel(User);''')
with zipfile.ZipFile(a.fixture) as z:entries={n:z.read(n) for n in z.namelist() if n.startswith('maps/')}
entries['ZSCRIPT']=b'version "4.14"\n#include "compatibility.zs"\n';entries['compatibility.zs']=source.encode()
entries['MAPINFO']=b'GameInfo { AddEventHandlers="CA249Compat" }\ncluster 99 { hub }\nmap MAP99 "Summoning compatibility" { cluster=99 }\nmap MAP98 "Summoning hub" { cluster=99 }\nmap MAP97 "Low ceiling" { cluster=99 }\n'
manifest={'fixture_sha256':room.package(out/'summoning.pk3',entries),'runtime_sha256':hashlib.sha256(a.runtime.read_bytes()).hexdigest()}
if a.save:
    shutil.copyfile(a.save,out/'input.zds');manifest['original_save_sha256']=hashlib.sha256(a.save.read_bytes()).hexdigest()
script='wait 100; netevent c249_seed; wait 2; save neutral.zds; wait 5; netevent c249_done; wait 35; quit\n' if a.mode=='seed' else 'wait 20; netevent c249_verify; wait 2; save migrated.zds; wait 5; netevent c249_done; wait 35; quit\n'
(out/'verify.cfg').write_bytes(script.encode());(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
