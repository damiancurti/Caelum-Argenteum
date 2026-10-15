"""Package isolated native pose checks; test resources never enter src."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
def module(path,name):
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
shared=module(HERE.parent/'validation_541/prepare.py','package541')
room=module(HERE.parent/'validation_5218/prepare.py','room5218')
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory',required=True)
args=parser.parse_args()
if any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):parser.error('Plain directory name required.')
out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
manifest={'runtime_sha256':shared.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256']=shared.package(out/'poses.pk3',{
    'ZSCRIPT':b'version "4.14"\n#include "poses.zs"\n',
    'poses.zs':(HERE/'sleep_poses.zs').read_bytes(), 'maps/MAP99.wad':room.room(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA238PoseProbe" }\nmap MAP99 "Sleep pose fixture" { sky1="SKY1",0 }\n'})
steps=['con_notifytime 0','wait 100','netevent c238_poses_setup','wait 10','netevent c238_poses_contract','wait 10','netevent c238_poses_expired']
for actor in range(4):
    for view in range(8):steps += [f'netevent c238_pose {actor} {view}','wait 4',f'screenshot pose-{actor}-{view}.png']
steps += ['netevent c238_poses_save','wait 2','save poses.zds','wait 2','netevent c238_poses_done','wait 2','quit']
(out/'poses.cfg').write_text('; '.join(steps)+'\n',encoding='utf-8')
(out/'load.cfg').write_text('wait 2; netevent c238_poses_load; wait 5; netevent c238_poses_done; wait 2; quit\n',encoding='utf-8')
manual='language es; use_mouse true; bind f +user4; bind f6 "netevent c238_poses_reset"; bind f7 "netevent c238_poses_next"; bind f8 "netevent c238_poses_hit"; wait 100; netevent c238_poses_setup; wait 10; netevent c238_poses_reset; '
(out/'manual.cfg').write_text(manual+'netevent c238_poses_done;\n',encoding='utf-8')
(out/'manual-seed.cfg').write_text(manual+'wait 80; +user4; wait 140; -user4; wait 2; netevent c238_poses_cast_check; netevent c238_poses_reset; wait 10; screenshot manual-pose-ready.png; netevent c238_poses_done; wait 2; quit\n',encoding='utf-8')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8');print(json.dumps(manifest))
