"""Exercise all four original native escorts on the redesigned map.

An isolated leader follows generated collision paths in cleared corridors.
Enemies and active non-pit hazards are removed only in this fixture; the test
does not certify combat, hazard navigation or ordinary player acquisition.
Native escort AI, closed pit covers, gates, resources and extraction run.
"""
from collections import deque
from pathlib import Path
import argparse
import hashlib
import heapq
import json
import math
import subprocess
import time
import zipfile

from run_native import ENGINE,IWAD,ROOT,HERE,digest

def paths():
    data=json.loads((ROOT/'assets/map02_maze/LAYOUT.json').read_text(encoding='utf-8'))
    manifest=json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    grid=data['grid'];radius=data['largest_player_radius'];height=data['largest_supported_height']
    floor={(r[0],r[1]) for r in manifest['upper_cells'] if r[2]>=-data['channel_depth'] and r[3]>=height}
    offsets=range(-math.ceil(radius/grid),math.ceil(radius/grid)+1)
    walkable={p for p in floor if all((p[0]+dx*grid,p[1]+dy*grid) in floor for dx in offsets for dy in offsets
        if abs(dx)*grid<radius+grid/2 and abs(dy)*grid<radius+grid/2)}
    # Prefer the center of the dry shelf and avoid physically present furniture.
    for t in manifest['things']:
        if t['type'] in [18000,18001,18002,18003,18004,30973,30987]:
            walkable.difference_update((x,y) for x in range(int(t['x'])-64,int(t['x'])+65,grid) for y in range(int(t['y'])-64,int(t['y'])+65,grid))
    def point(p):return (math.floor(p[0]/grid)*grid,math.floor(p[1]/grid)*grid)
    # Walk past the marker so the follower's normal stopping distance still
    # places its body inside the extraction radius. Stopping at the marker's
    # far cell edge leaves the follower just outside that radius.
    goal=point([manifest['extraction'][0],manifest['extraction'][1]-data['service_width']]);routes=[]
    for prisoner in manifest['prisoners']:
        p=prisoner['reserved_actor'];start=point([p[0],p[1]-80])
        assert start in walkable and goal in walkable
        queue=[(0,start)];cost={start:0};previous={start:None}
        while queue:
            _,current=heapq.heappop(queue)
            if current==goal:break
            x,y=current
            for other in [(x-grid,y),(x,y+grid),(x+grid,y),(x,y-grid)]:
                if other not in walkable:continue
                new=cost[current]+1
                if new<cost.get(other,1e30):
                    cost[other]=new;previous[other]=current
                    heapq.heappush(queue,(new+(abs(other[0]-goal[0])+abs(other[1]-goal[1]))/grid,other))
        assert goal in previous
        route=[goal]
        while previous[route[-1]] is not None:route.append(previous[route[-1]])
        route.reverse();compressed=[route[0]]
        for i in range(1,len(route)-1):
            if (route[i][0]-route[i-1][0],route[i][1]-route[i-1][1])!=(route[i+1][0]-route[i][0],route[i+1][1]-route[i][1]):compressed.append(route[i])
        compressed.append(route[-1]);routes.append([[x+grid/2,y+grid/2,0] for x,y in compressed])
    source=['class CA454EscortData : Object play {',f'const RADIUS={radius}; const HEIGHT={height};',
            'static void GiveKeys(CaelumPlayer user) {']
    for cls in sorted({d['cls'] for d in manifest['drops'] if 'Key' in d['cls']}):source.append(f'user.GiveInventoryType("{cls}");')
    source+=['}','static void ClearHazards() {']
    hazard_ids=[]
    for trap in manifest['traps']:
        if trap['type']!='pit':hazard_ids.append(trap['tid'])
        if trap['type'] in ['rolling_rock','falling_rock']:hazard_ids.append(trap['tid']+100)
    for tid in hazard_ids:source.append('{let hazard=ActorIterator.Create('+str(tid)+').Next();if(hazard!=null)hazard.Destroy();}')
    source+=['}','static int Count(int stage) {']
    for stage,route in enumerate(routes):source.append(f'if(stage=={stage})return {len(route)};')
    source+=['return 0;}','static vector3 Point(int stage,int step) {']
    for stage,route in enumerate(routes):
        source.append(f'if(stage=={stage}){{')
        for index,p in enumerate(route):source.append(f'if(step=={index})return ({p[0]},{p[1]},{p[2]});')
        source.append('}')
    source+=['return (0,0,0);}','}']
    return '\n'.join(source).encode(),routes

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    out=args.output.resolve();out.mkdir(parents=True,exist_ok=False);runtime=args.runtime.resolve()
    data,routes=paths();(out/'routes.json').write_text(json.dumps(routes,indent=2)+'\n',encoding='utf-8')
    fixture=out/'escorts.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,content in sorted({'ZSCRIPT':b'version "4.14.2"\n#include "data.zs"\n#include "probe.zs"',
             'MAPINFO':b'gameinfo { AddEventHandlers="CA454EscortProbe" }',
             'data.zs':data,'probe.zs':(HERE/'escort_probe.zs').read_bytes()}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),content)
    config=out/'isolated.ini';config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n',encoding='utf-8')
    command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(fixture),'-config',str(config),'-savedir',str(out),'-window','+logfile',str(out/'engine.log'),'+map','MAP02']
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    passed=False;timeout=False
    with (out/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=out,startupinfo=startup,stdout=stream,stderr=stream)
        try:
            deadline=time.monotonic()+2400
            previous=''
            while process.poll() is None:
                path=out/'engine.log';log=path.read_text(errors='replace') if path.exists() else ''
                updates=[line for line in log[len(previous):].splitlines() if 'CA454 ESCORT' in line]
                for line in updates:print(line,flush=True)
                previous=log
                if 'CA454 ESCORT PASS all_four' in log:passed=True;break
                if any(value in log for value in ('CA454 ESCORT FAIL','Script error','VM execution aborted','DIED WITH FATAL ERROR')):break
                if time.monotonic()>deadline:timeout=True;break
                time.sleep(.5)
        finally:
            if process.poll() is None:process.terminate();process.wait(timeout=10)
    report=dict(issue=454,scope=__doc__.strip(),passed=passed,timed_out=timeout,command=command,
        engine_sha256=digest(ENGINE),runtime_sha256=digest(runtime),fixture_sha256=digest(fixture),
        cleanup='Own disposable engine process terminated after success/failure; no production save modified.')
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'passed':passed,'output':str(out)}));raise SystemExit(not passed)

if __name__=='__main__':main()
