"""Verify conservative geometry independently and prepare native comparison cases.

Preserves every output and the old map. Test coordinates come from authored map
data; sampling offsets and trace distances are diagnostic, not gameplay values.
"""
from pathlib import Path
from collections import Counter
import argparse
import hashlib
import json
import shutil
import sys
import zipfile

from geometry_probe import read_wad, parse

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'assets/generators'))
import generate_map06_port as portgen
import generate_city_interiors as interiors
from generate_coastal_trials import generate


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def groups(path):
    return parse(dict(read_wad(path))['TEXTMAP'].decode())


def canonical_edges(data, physical_only=False):
    """Resolve all references and split at the original 64-MU grid independently.

    Omits only invisible boundaries inside identical sectors. Physical edges,
    materials, light, tags, specials, orientation and texture offsets are compared.
    """
    output = Counter()
    for line in data['linedef']:
        a, b = (data['vertex'][int(line[k])] for k in ('v1', 'v2'))
        x, y, endx, endy = (int(v) for v in (a['x'], a['y'], b['x'], b['y']))
        faces = []
        for key in ('sidefront', 'sideback'):
            if key not in line:
                faces.append(None)
                continue
            side = data['sidedef'][int(line[key])]
            sector = data['sector'][int(side['sector'])]
            faces.append((tuple(sorted((k,v) for k,v in side.items() if k != 'sector')),
                          tuple(sorted(sector.items()))))
        attributes = tuple(sorted((k,v) for k,v in line.items()
                                  if k not in ('v1','v2','sidefront','sideback')))
        if physical_only and attributes == (('twosided','true'),) and faces[1] is not None:
            planes = [dict(face[1]) for face in faces]
            if (all(planes[0].get(k)==planes[1].get(k) for k in ('heightfloor','heightceiling','id'))
                    and all(dict(face[0])['texturemiddle']=='"-"' for face in faces)):
                continue
        if (attributes == (('twosided','true'),) and faces[1] is not None
                and faces[0][1] == faces[1][1]
                and all(dict(face[0])['texturemiddle'] == '"-"' for face in faces)):
            continue
        assert x == endx or y == endy, 'Only the generated orthogonal map is supported'
        length = abs(endx-x) + abs(endy-y)
        assert length and length % 64 == 0
        count = 1 if physical_only else length // 64
        dx, dy = (endx-x)//count, (endy-y)//count
        for i in range(count):
            output[((x+i*dx,y+i*dy),(x+(i+1)*dx,y+(i+1)*dy),attributes,tuple(faces))] += 1
    return output


def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, value in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000,1,1,0,0,0)), value)


def samples():
    city = json.loads((ROOT/'assets/map06_port/CITY.json').read_text())
    south = portgen.S
    points = []
    def add(label, p):
        points.append({'label':label, 'position':list(p)})
    for home in interiors.houses(city):
        x,y,_,_ = home['bounds']
        prefix = 'house-'+str(home['id'])
        rects = list(interiors.DATA['rooms'].items())
        rects += [('entrance',interiors.DATA['entrance'])]
        rects += [('door-'+str(i),r) for i,r in enumerate(interiors.DATA['doorways'])]
        rects += [('window-'+str(i),r) for i,r in enumerate(interiors.DATA['windows'])]
        for label,(a,b,c,d) in rects:
            z = interiors.DATA['window_sill'] if label.startswith('window') else 0
            add(prefix+'-'+label, (x+(a+c)/2,y+(b+d)/2,z))
        a,b,c,d = interiors.DATA['rooms']['living']
        for label,z in [('roof',interiors.DATA['height']),('above-roof',interiors.DATA['height']+128)]:
            add(prefix+'-'+label, (x+(a+c)/2,y+(b+d)/2,z))
        # Two nearby points exercise the existing thermal endpoint rule.
        add(prefix+'-corner',(x+a+16,y+b+16,0))
    for gate in city['gates']:
        for side in ('inside','outside'):
            add(gate['name']+'-'+side, gate[side])
        a,b,c,d = gate['bounds']
        add(gate['name']+'-arch',((a+c)/2,(b+d)/2,0))
    for i,route in enumerate(south['crew_routes']):
        for j,point in enumerate(route):
            add(f'gun-{i}-route-{j}',point)
    for i,point in enumerate(south['defending_guns']):
        add(f'gun-{i}-platform',point)
    add('entry',(0,320,0))
    add('street-audit',(-2048,320,0))
    add('river',(1536,1152,-128))
    return points


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    args = p.parse_args()
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    original = ROOT/'assets/map06_port/legacy_5427/MAP06.wad'
    if not original.exists():
        original = ROOT/'src/maps/MAP06.wad'
    shutil.copyfile(original,out/'original.wad')
    # Generation normally writes shared runtime data; this audit is read-only.
    saved_runtime = interiors.runtime
    interiors.runtime = lambda *args: None
    try:
        for mode in ('unchanged','safe-a','safe-b'):
            target = out/mode
            target.mkdir()
            def extend(port):
                portgen.extend(port)
                port.optimize_open_geometry = mode != 'unchanged'
            generate(target,extend,include_coast=False)
    finally:
        interiors.runtime = saved_runtime
    assert (out/'unchanged/MAP06.wad').read_bytes() == original.read_bytes(), 'Writer refactor changed baseline'
    assert (out/'safe-a/MAP06.wad').read_bytes() == (out/'safe-b/MAP06.wad').read_bytes(), 'Nondeterministic generation'
    before,after = groups(original),groups(out/'safe-a/MAP06.wad')
    assert canonical_edges(before) == canonical_edges(after), 'Physical/material boundary mismatch'
    assert canonical_edges(before,True) == canonical_edges(after,True), 'Physical wall endpoint mismatch'
    assert before['thing'] == after['thing'], 'Map actors changed'
    tagged = lambda g: Counter(tuple(sorted(s.items())) for s in g['sector'] if int(s.get('id','0')))
    assert tagged(before) == tagged(after), '3D target sectors changed'
    report = {'original_sha256':digest(original), 'generated_sha256':digest(out/'safe-a/MAP06.wad'),
              'before':{k:len(v) for k,v in before.items()}, 'after':{k:len(v) for k,v in after.items()},
              'checks':['Unoptimized serialization byte-identical','Two optimized generations byte-identical',
                        'All oriented boundary segments, materials and specials equal on original grid',
                        'All physical wall endpoints equal','All map actors equal','All tagged sector records equal'],
              'scope':'Static comparison; native results and save migration are separate evidence.'}
    points = samples()
    (out/'samples.json').write_text(json.dumps(points,indent=2)+'\n')
    (out/'STATIC.json').write_text(json.dumps(report,indent=2)+'\n')
    positions = '\n'.join(f'        if(i=={i})return ({",".join(map(str,p["position"]))});' for i,p in enumerate(points))
    code = (HERE/'geometry_checks.zs').read_text().replace('@POSITIONS@',positions).replace('@COUNT@',str(len(points)))
    fixture = {'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n', 'checks.zs':code.encode(),
               'MAPINFO':b'GameInfo { AddEventHandlers="CA318GeometryProbe" }\n'}
    base = ROOT/'build/issue318-geometry-01/base/runtime.pk3'
    for mode in ('base','safe'):
        work = out/mode
        work.mkdir()
        shutil.copyfile(base,work/'runtime.pk3')
        members = dict(fixture)
        if mode == 'safe':
            members['maps/MAP06.wad'] = (out/'safe-a/MAP06.wad').read_bytes()
        package(work/'geometry.pk3',members)
        (work/'manifest.json').write_text(json.dumps({'runtime_sha256':digest(work/'runtime.pk3'),
            'fixture_sha256':digest(work/'geometry.pk3'),'samples':len(points)},indent=2)+'\n')
    # Allow a full diagnostic pass and save the observed state for reload checks.
    (out/'scan.cfg').write_text('wait 100; netevent c318_geometry; wait '+str(len(points)//8+100)+
        '; netevent c318_geometry_done; storesavepic false; save geometry.zds; wait 5; quit\n')
    (out/'reload.cfg').write_text('wait 20; netevent c318_geometry_saved; netevent c318_geometry; wait '+str(len(points)//8+100)+
        '; netevent c318_geometry_done; wait 5; quit\n')
    print(json.dumps(report,indent=2))
    print('Native sample locations:',len(points))


if __name__ == '__main__':
    main()
