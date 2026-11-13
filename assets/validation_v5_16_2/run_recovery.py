"""Check native lower-branch clearances, independent grates and lift transport.

Queries use the actual map with maximum supported body dimensions, after opening
the keyless grates and lowering the platform. Teleports set up each isolated
mechanism check; this is not an ordinary pit walkthrough.
"""
from pathlib import Path
import argparse
import json
import zipfile
from run_native import run,digest,HERE,ROOT,ENGINE

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    runtime=args.runtime.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    layout=manifest['layout'];net=layout['return_network'];paths=net['paths']
    data=['class CA454RecoveryData : Object play {',
        f'const COUNT={len(paths)}; const RADIUS={layout["largest_player_radius"]}; const HEIGHT={layout["largest_supported_height"]}; const FLOOR={net["floor"]}; const STEP={layout["grid"]};',
        f'const TRAVEL_TICS={(-net["floor"]*8+net["elevator_speed"]-1)//net["elevator_speed"]+35};',
        'static int PointCount(int route){']
    for i,path in enumerate(paths):data.append(f'if(route=={i})return {len(path["points"])};')
    data+=['return 0;}','static vector3 Point(int route,int index){']
    for i,path in enumerate(paths):
        data.append(f'if(route=={i}){{')
        for j,(x,y) in enumerate(path['points']):data.append(f'if(index=={j})return ({x},{y},FLOOR);')
        data.append('}')
    data+=['return (0,0,FLOOR);}','static vector3 Exterior(int side){']
    for i,g in enumerate(manifest['return_grates']):
        cross=g['outer_boundary']+g['sign']*net['width']/2
        x,y=(cross,0) if g['axis']=='x' else (0,cross)
        data.append(f'if(side=={i})return ({x},{y},FLOOR);')
    data+=['return (0,0,FLOOR);}','}']
    fixture=out/'recovery.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,content in sorted({'ZSCRIPT':b'version "4.14.2"\n#include "data.zs"\n#include "probe.zs"',
            'MAPINFO':b'gameinfo { AddEventHandlers="CA454RecoveryProbe" }',
            'data.zs':'\n'.join(data).encode(),'probe.zs':(HERE/'recovery_probe.zs').read_bytes()}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),content)
    result=run(runtime,out,'recovery',fixture,extra='wait 700; netevent ca454_recovery_report; screenshot upper-return.png; ')
    report=dict(issue=454,scope=__doc__.strip(),runtime_sha256=digest(runtime),engine_sha256=digest(ENGINE),fixture_sha256=digest(fixture),runs=[result])
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'passed':result['passed'],'output':str(out)}));raise SystemExit(not result['passed'])

if __name__=='__main__':main()
