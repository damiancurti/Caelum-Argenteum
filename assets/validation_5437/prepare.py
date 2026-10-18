"""Freeze current MAP03 CPU/renderer attribution, using unchanged bounded deployment."""
from pathlib import Path
import argparse
import importlib.util
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
HERE=ROOT/'assets/validation_issue318'
spec=importlib.util.spec_from_file_location('previous',HERE/'prepare.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory',required=True)
parser.add_argument('--profile',action='store_true')
args=parser.parse_args()
assert args.directory.startswith('issue318-current') and all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory)
out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
members={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
assert 'maps/MAP03.wad' in members and 'maps/MAP06.wad' not in members
data=members['caelum/data/CaelumReinforcementData.zs'].decode()
for name,value in {'REVISION':2,'GROUP_SIZE':100,'LIVING_CAP':1000,'TOTAL':6600,'INTERVAL':350}.items():
    assert re.search(r'const '+name+r'\s*=\s*'+str(value)+r'\s*;',data),(name,value)
metadata={'base':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
    'scope':'Current MAP03 native CPU/renderer attribution; no ETW/presented FPS claim',
    'army':'Unchanged production admission cap, group size, cadence, reserve total and resurrection rules',
    'retired':'No 6000-simultaneous scenario exists in this fixture'}
if args.profile:
    metadata['methods']=previous.profile(members,deep=True)
    members['ZSCRIPT']+=b'\n#include "ca318_profiler.zs"\n'
    members['ca318_profiler.zs']=(HERE/'profiler.zs').read_bytes()
    members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA318Profiler" }\n'
metadata['runtime_sha256']=previous.package(out/'production.pk3',members)
derived=b'''class CA318Current : CA318Observer
{
 bool Reported;
 override void WorldTick()
 {
  Super.WorldTick();
  if(Finished && !Reported)
  {
   Reported=true;
   if(Phase>0 && (Port==null || !Port.SiegeStarted))Console.Printf("CA282 FAIL normal siege did not start");
   else Console.Printf("CA282 DONE passes=1 failures=0");
  }
 }
}
'''
metadata['fixture_sha256']=previous.package(out/'quick.pk3',{
    'ZSCRIPT':b'version "4.14"\n#include "observer.zs"\n#include "current.zs"\n',
    'observer.zs':(HERE/'observer.zs').read_bytes(),'current.zs':derived,
    'MAPINFO':b'GameInfo { AddEventHandlers="CA318Current" }\n',
    'CVARINFO':b'server int ca318_phase=0; server int ca318_site=1; server int ca318_pitch=0; server int ca318_window=350; server int ca318_warmup=140; server bool ca318_freeze=false; server bool ca318_save=false;\n'})
for phase,site,pitch,label in ((0,0,0,'peace-forward'),(0,0,75,'peace-ground'),(1,0,0,'siege-city'),(1,4,0,'siege-front')):
    warmup=3500 if phase else 140;window=350
    script=f'vid_vsync false; vid_maxfps 0; cl_capfps false; vid_fps true; con_notifylines 0; ca318_phase {phase}; ca318_site {site}; ca318_pitch {pitch}; ca318_warmup {warmup}; ca318_window {window}; wait 100; netevent ca318_begin; wait {warmup+window-5}; screenshot {label}.png; wait 11; bench; wait 210; profilethinkers -t; wait 5; quit\n'
    (out/(label+'.cfg')).write_text(script,encoding='utf-8',newline='\n')
(out/'manifest.json').write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in metadata.items() if k!='methods'}))
