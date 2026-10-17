"""Prepare then run matched old/native collision measurements without overlap."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('ca318_prepare',HERE/'prepare.py')
prepare=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepare)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','run'])
    p.add_argument('--directory',default='issue318-native-perf-01');a=p.parse_args();out=ROOT/'build'/a.directory
    if a.mode=='prepare':
        prepare.METHODS['CaelumPolyDoors']='Request SweepOccupied Pose Progress Start'
        prepare.METHODS['CaelumPolyDoorMotion']='Tick'
        for name,source in [('legacy','issue318-geometry-04'),('native','issue318-native-08')]:
            with zipfile.ZipFile(ROOT/'build'/source/'current/runtime.pk3') as z:original={n:z.read(n) for n in z.namelist()}
            for profiled in (False,True):
                variant=name+('-profile' if profiled else '');work=out/variant;work.mkdir(parents=True,exist_ok=False)
                members=original.copy();metadata={'scope':'Matched conservative geometry; old actor doors versus native finite doors','source':source}
                if profiled:
                    metadata['methods']=prepare.profile(members)
                    members['ZSCRIPT']+=b'\n#include "ca318_profiler.zs"\n'
                    members['ca318_profiler.zs']=(HERE/'profiler.zs').read_bytes()
                    members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA318Profiler" }\n'
                    prepare.package(work/'runtime.pk3',members)
                else:shutil.copyfile(ROOT/'build'/source/'current/runtime.pk3',work/'runtime.pk3')
                fixture={'ZSCRIPT':b'version "4.14"\n#include "observer.zs"\n#include "door_motion_observer.zs"\n',
                    'observer.zs':(HERE/'observer.zs').read_bytes(),'door_motion_observer.zs':(HERE/'door_motion_observer.zs').read_bytes(),
                    'MAPINFO':b'GameInfo { AddEventHandlers="CA318Observer", "CA318DoorMotionObserver" }\n',
                    'CVARINFO':b'server int ca318_phase=0; server int ca318_site=1; server int ca318_pitch=0; server int ca318_window=350; server int ca318_warmup=140; server bool ca318_freeze=false; server bool ca318_save=false; server bool ca318_door_motion=false;\n'}
                metadata['fixture_sha256']=prepare.package(work/'observer.pk3',fixture)
                metadata['runtime_sha256']=hashlib.file_digest((work/'runtime.pk3').open('rb'),'sha256').hexdigest()
                (work/'manifest.json').write_text(json.dumps(metadata,indent=2)+'\n')
                print('Prepared',variant,flush=True)
        return
    plans=[]
    for pitch in (0,75):
        for repeat,variant in enumerate(('legacy','native','native','legacy'),1):
            plans.append((variant,f'idle-{pitch}-{repeat}',pitch,False))
    for variant in ('legacy','native','legacy-profile','native-profile'):
        plans.append((variant,'active-pair',0,True))
    for variant,label,pitch,moving in plans:
        cmd=[sys.executable,str(HERE/'run.py'),'--directory',a.directory,'--variant',variant,'--label',label,
             '--pitch',str(pitch),'--postwait','210','--global-presentmon']
        if moving:cmd+=['--commands','ca318_door_motion true']
        subprocess.run(cmd,cwd=ROOT,check=True)

if __name__=='__main__':main()
