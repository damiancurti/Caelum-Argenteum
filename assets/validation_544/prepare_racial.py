"""Package the shared racial controller with an isolated instrumented effect."""
from pathlib import Path
import argparse,importlib.util,json
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
def module(path,name):
    spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
shared=module(HERE.parent/'validation_541/prepare.py','package541')
room=module(HERE.parent/'validation_5218/prepare.py','room5218')
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--directory',required=True);args=parser.parse_args()
if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):parser.error('Plain directory name required.')
out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
manifest={'runtime_sha256':shared.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=shared.package(out/'racial.pk3',{'ZSCRIPT':b'version "4.14"\n#include "equipment.zs"\n#include "racial.zs"\n','equipment.zs':(HERE.parent/'validation_541/session.zs').read_bytes(),'racial.zs':(HERE/'racial.zs').read_bytes(),'maps/MAP99.wad':room.room(),'maps/MAP98.wad':room.room(),'MAPINFO':b'GameInfo { AddEventHandlers="CA238RacialProbe" PlayerClasses="CA238RacialTestPlayer" }\ncluster 99 { hub }\nmap MAP99 "Racial fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Racial fixture hub" { cluster=99 sky1="SKY1",0 }\n'})
steps=['wait 100','netevent c238_racial_setup','wait 100']
cycle=['+user1','wait 35','netevent c238_racial_on','-user1','wait 2','+user1','wait 35','netevent c238_racial_off','-user1','wait 2']
for weapon in range(9):steps += [f'netevent c238_racial_weapon {weapon}','wait 80']+cycle
steps += ['netevent c238_racial_unarmed','wait 80']+cycle+['netevent c238_racial_done','wait 2','quit']
(out/'racial.cfg').write_text('; '.join(steps)+'\n',encoding='utf-8')
start='wait 100; netevent c238_racial_setup; wait 100; +user1; wait 35; -user1; wait 2; '
(out/'save.cfg').write_text(start+'netevent c238_racial_save_check; save racial.zds; wait 2; netevent c238_racial_done; wait 2; quit\n',encoding='utf-8')
(out/'load.cfg').write_text('wait 5; netevent c238_racial_load; wait 5; +user1; wait 20; -user1; netevent c238_racial_off; netevent c238_racial_done; wait 2; quit\n',encoding='utf-8')
(out/'hub.cfg').write_text(start+'changemap MAP98; wait 10; netevent c238_racial_hub; changemap MAP99; wait 10; netevent c238_racial_hub; netevent c238_racial_done; wait 2; quit\n',encoding='utf-8')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
