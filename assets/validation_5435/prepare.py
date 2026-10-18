"""Freeze focused escort diagnostics; reuse the accepted native launch harness."""
from pathlib import Path
import argparse
import importlib.util
import json
import struct
import hashlib
import campaign_route

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('quick', HERE.parent / 'validation_5422/prepare.py')
quick = importlib.util.module_from_spec(spec)
spec.loader.exec_module(quick)

def corridor_wad(stairs=False):
    """Two right-angle turns, a native sector door and two recovery hazards."""
    polygons = [
        (0, [(-600,-48),(-600,48),(-16,48),(-16,-48)]),
        (1, [(-16,-48),(-16,48),(16,48),(16,-48)]),
        (0, [(16,-48),(16,48),(552,48),(552,600),(1048,600),(1048,504),(648,504),(648,-48)]),
        (2, [(4800,-256),(4800,256),(5312,256),(5312,-256)]),
        (3, [(5800,-256),(5800,256),(6312,256),(6312,-256)]),
    ]
    heights=[(0,128),(0,0),(0,32),(-256,128)]
    if stairs:
        bounds=[-256,0,32,64,96,256]
        polygons=[(i,[(a,-128),(a,128),(b,128),(b,-128)]) for i,(a,b) in enumerate(zip(bounds,bounds[1:]))]
        heights=[(i*16,192) for i in range(5)]
    vertices, edges, sides = [], {}, []
    for sector, points in polygons:
        for a, b in zip(points, points[1:]+points[:1]):
            for point in (a,b):
                if point not in vertices: vertices.append(point)
            side = len(sides); sides.append(sector)
            if (b,a) in edges: edges[(b,a)][3] = side
            else: edges[(a,b)] = [vertices.index(a),vertices.index(b),side,None]
    source = 'namespace="ZDoom";\n'
    for x,y in vertices: source += f'vertex {{ x={x}; y={y}; }}\n'
    for sector,(floor,ceiling) in enumerate(heights):
        source += f'sector {{ id={322 if sector==1 else 0}; heightfloor={floor}; heightceiling={ceiling}; texturefloor="FLAT5_4"; textureceiling="CEIL3_5"; lightlevel=224; }}\n'
    for sector in sides: source += f'sidedef {{ sector={sector}; texturemiddle="STARTAN3"; texturetop="STARTAN3"; texturebottom="STARTAN3"; }}\n'
    for a,b,front,back in edges.values():
        source += f'linedef {{ v1={a}; v2={b}; sidefront={front}; '
        source += (f'sideback={back}; twosided=true; '
                   +('special=12; arg0=322; arg1=16; arg2=150; playeruse=true; repeatspecial=true; ' if not stairs else '')
                   +'}\n') if back is not None else 'blocking=true; }\n'
    # Shared door boundaries need no opaque middle texture.
    lines=source.splitlines()
    sidedef_rows=[i for i,line in enumerate(lines) if line.startswith('sidedef')]
    for a,b,front,back in edges.values():
        if back is not None:
            for index in (front,back): lines[sidedef_rows[index]]=lines[sidedef_rows[index]].replace('texturemiddle="STARTAN3"','texturemiddle="-"')
    source='\n'.join(lines)+f'\nthing {{ x={-128 if stairs else -300}; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }}\n'
    data=b''; directory=b''
    for name,payload in [('MAP96' if stairs else 'MAP97',b''),('TEXTMAP',source.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory

def platform_wad():
    """A real solid upper platform with a walkable staircase around its side."""
    cells={(x,y):0 for x in range(-4,4) for y in range(-4,4)}
    heights=[0,0,16,32,48,64,80,96,112,128]
    for x in range(4,9):
        for y in range(0,4):cells[x,y]=x-3
    for x in range(-4,9):
        for y in range(4,6):cells[x,y]=6 if x==8 else 7 if x==7 else 8 if x==6 else 9
    polygons=[(sector,[(x*32,y*32),(x*32,(y+1)*32),((x+1)*32,(y+1)*32),((x+1)*32,y*32)])
              for (x,y),sector in sorted(cells.items())]
    polygons.append((10,[(1000,0),(1000,32),(1032,32),(1032,0)]))
    vertices=[];edges={};sides=[]
    for sector,points in polygons:
        for a,b in zip(points,points[1:]+points[:1]):
            for point in (a,b):
                if point not in vertices:vertices.append(point)
            side=len(sides);sides.append(sector)
            if (b,a) in edges:edges[b,a][3]=side
            else:edges[a,b]=[vertices.index(a),vertices.index(b),side,None]
    source='namespace="ZDoom";\n'
    for x,y in vertices:source+=f'vertex {{ x={x}; y={y}; }}\n'
    for sector,floor in enumerate(heights+[112]):
        source+=f'sector {{ id={323 if sector==0 else 0}; heightfloor={floor}; heightceiling={128 if sector==10 else 256}; texturefloor="FLAT5_4"; textureceiling="CEIL3_5"; lightlevel=224; }}\n'
    for sector in sides:source+=f'sidedef {{ sector={sector}; texturemiddle="-"; texturetop="STARTAN3"; texturebottom="STARTAN3"; }}\n'
    control=False
    for a,b,front,back in edges.values():
        source+=f'linedef {{ v1={a}; v2={b}; sidefront={front}; '
        source+=f'sideback={back}; twosided=true; ' if back is not None else 'blocking=true; '
        if sides[front]==10 and not control:source+='special=160; arg0=323; arg1=1; arg3=255; ';control=True
        source+='}\n'
    source+='thing { x=0; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
    data=b'';directory=b''
    for name,payload in [('MAP95',b''),('TEXTMAP',source.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--legacy-runtime', type=Path)
    parser.add_argument('--campaign', action='store_true')
    args = parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory):
        parser.error('Plain lowercase directory required.')
    out = ROOT / 'build' / args.directory
    out.mkdir(exist_ok=False)
    package = quick.seal.shared.package
    route_source,route_data=campaign_route.source(ROOT)
    manifest = {'runtime_sha256': package(out / 'production.pk3', {
        p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
        for p in (ROOT / 'src').rglob('*') if p.is_file()}),
        'fixture_sha256': package(out / 'quick.pk3', {
            'ZSCRIPT': b'version "4.14"\n#include "quick.zs"\n#include "escort.zs"\n'+(b'#include "route.zs"\n#include "campaign.zs"\n' if args.campaign else b''),
            'quick.zs': (HERE.parent / 'validation_5422/probe.zs').read_bytes(),
            'escort.zs': (HERE / ('legacy.zs' if args.legacy_runtime else 'escort.zs')).read_bytes(),
            'route.zs': route_source,
            'campaign.zs': (HERE/'campaign.zs').read_bytes(),
            'maps/MAP99.wad': quick.seal.wad(),
            'maps/MAP98.wad': quick.seal.wad(),
            'maps/MAP97.wad': corridor_wad(),
            'maps/MAP96.wad': corridor_wad(True),
            'maps/MAP95.wad': platform_wad(),
            'MAPINFO': ('GameInfo { AddEventHandlers="'+('CA322Campaign' if args.campaign else 'CA322Probe')+'" }\ncluster 99 { hub }\nmap MAP99 "Escort fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Escort hub" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP97 "Escort corridor" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP96 "Escort stairs" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP95 "Escort platform" { cluster=99 nointermission sky1="SKY1",0 }\n').encode()})}
    scripts = {
        'trace.cfg': 'wait 70; netevent c322_seed; wait 5; netevent c322_trace; wait 350; netevent c322_far; wait 350; netevent c322_noise; wait 140; netevent c322_done; wait 5; quit\n',
        'manual.cfg': 'wait 70; netevent c322_route; wait 5; netevent c322_manual; netevent c282_manual;\n',
        'route.cfg': 'wait 70; netevent c322_route; wait 5; netevent c322_routestart; wait 1400; netevent c322_routecheck; netevent c322_groupstart; wait 140; netevent c322_groupcheck; netevent c322_done; wait 5; quit\n',
        'seed.cfg': 'wait 70; netevent c322_seed; wait 5; netevent c322_trace; netevent c322_far; wait 35; storesavepic false; save escort.zds; netevent c322_done; wait 5; quit\n',
        'load.cfg': 'wait 10; netevent c322_loaded; netevent c322_done; wait 5; quit\n',
        'corridor.cfg': 'wait 70; netevent c322_route; wait 5; netevent c322_closed; wait 210; netevent c322_closedcheck; wait 105; netevent c322_routestart; wait 2800; netevent c322_routecheck; netevent c322_groupstart; wait 140; netevent c322_groupcheck; netevent c322_done; wait 5; quit\n',
        'resume.cfg': 'wait 70; netevent c322_route; wait 5; netevent c322_closed; wait 210; netevent c322_closedcheck; wait 105; netevent c322_routestart; wait 2800; netevent c322_routecheck; netevent c322_groupstart; wait 140; netevent c322_groupcheck; netevent c322_groupresume; wait 350; netevent c322_groupresumecheck; netevent c322_done; wait 5; quit\n',
        'edges.cfg': 'wait 70; netevent c322_seed; wait 5; netevent c322_trace; wait 5; netevent c322_edges; wait 35; netevent c322_recovered; netevent c322_done; wait 5; quit\n',
        'stairs.cfg': 'wait 70; netevent c322_seed; wait 5; netevent c322_stairs; wait 140; netevent c322_stairscheck; netevent c322_done; wait 5; quit\n',
        'platform.cfg': 'wait 70; netevent c322_seed; wait 5; netevent c322_platform; wait 1400; netevent c322_platformcheck; netevent c322_done; wait 5; quit\n',
        'budget.cfg': 'wait 70; netevent c322_seed; wait 5; netevent c322_budget; netevent c322_done; wait 5; quit\n',
        'snapshot.cfg': 'wait 70; netevent c322_route; wait 5; netevent c322_snapshot; wait 5; storesavepic false; save escort-four.zds; wait 5; netevent c322_done; wait 5; quit\n',
        'ongoing.cfg': 'wait 70; netevent c322_route; wait 5; netevent c322_routestart; wait 100; netevent c322_capture; storesavepic false; save escort-ongoing.zds; wait 5; netevent c322_done; wait 5; quit\n',
        'blocked-save.cfg': 'wait 70; netevent c322_route; wait 5; netevent c322_closed; wait 210; netevent c322_capture; storesavepic false; save escort-blocked.zds; wait 5; netevent c322_done; wait 5; quit\n',
        'savedcheck.cfg': 'wait 10; netevent c322_savedcheck; netevent c322_done; wait 5; quit\n',
        'hub.cfg': 'wait 10; netevent c322_savedcheck; changemap MAP98; wait 70; changemap MAP99; wait 70; netevent c322_savedcheck 2; netevent c322_done; wait 5; quit\n',
        'campaign.cfg': 'wait 70; netevent c322_campaign; wait 35000; netevent c322_campaigncheck; storesavepic false; save campaign-finish.zds; wait 10; changemap MAP03; wait 70; netevent c322_port; save campaign-port.zds; wait 10; quit\n',
        'port-reload.cfg': 'wait 70; netevent c322_portreload; wait 5; quit\n',
        'port-roundtrip.cfg': 'wait 70; netevent c322_portreload; changemap MAP02; wait 70; netevent c322_sewerreturn; changemap MAP03; wait 70; netevent c322_portreload; wait 5; quit\n',
        'campaign-short.cfg': 'wait 70; netevent c322_campaign; wait 3500; netevent c322_campaigncheck; wait 5; quit\n',
        'combat.cfg': 'wait 70; netevent c322_seed; wait 5; netevent c322_trace; wait 5; netevent c322_threat; wait 10; netevent c322_threatcheck; wait 35; netevent c322_resumed; netevent c322_done; wait 5; quit\n',
    }
    for kind in range(4):
        scripts[f'kind{kind}.cfg'] = (f'wait 70; netevent c322_seed {kind}; wait 5; netevent c322_trace; wait 5; netevent c322_noise; wait 140; netevent c322_quietcheck; '
            'netevent c322_talk; wait 70; netevent c322_talkcheck; netevent c322_recovery; netevent c322_formula; '
            'netevent c322_motion; wait 420; netevent c322_motioncheck; netevent c322_done; wait 5; quit\n')
    for name, source in scripts.items():
        (out / name).write_text(source, encoding='utf-8', newline='\n')
    if args.legacy_runtime:
        runtime=args.legacy_runtime.read_bytes()
        (out/'production.pk3').write_bytes(runtime)
        manifest['runtime_sha256']=hashlib.sha256(runtime).hexdigest()
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    (out/'campaign-route.json').write_text(json.dumps(route_data,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(manifest))

if __name__ == '__main__':
    main()
