"""Deterministically repair issue #36 from the preserved authoring baseline.

Only the standard library is required. Numeric authoring data belongs in the
manifest, and generated output is not used as the input for another generation.
"""
from pathlib import Path
import hashlib
import json
import math
import re
import struct

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets/map01_mansion'
BLOCK = re.compile(r'(vertex|sector|sidedef|linedef|thing)\s*\{(.*?)\}', re.S)
FIELD = re.compile(r'(\w+)\s*=\s*("(?:[^"\\]|\\.)*"|[^;]+);')


def read_map(path):
    blob = path.read_bytes()
    _, count, directory = struct.unpack_from('<4sii', blob)
    lumps = []
    for i in range(count):
        start, size, name = struct.unpack_from('<ii8s', blob, directory + i * 16)
        lumps.append((name.rstrip(b'\0').decode(), blob[start:start + size]))
    text = dict(lumps)['TEXTMAP'].decode('utf-8')
    objects = {kind: [] for kind in ('vertex', 'linedef', 'sidedef', 'sector', 'thing')}
    for kind, body in BLOCK.findall(text):
        objects[kind].append({key: json.loads(value.strip()) for key, value in FIELD.findall(body)})
    return objects


def write_map(objects, path):
    chunks = ['namespace = "ZDoom";', '// Issue #36; generated from assets/map01_mansion.']
    for kind, items in objects.items():
        for i, item in enumerate(items):
            chunks += [f'// {kind} {i}', kind, '{']
            chunks += [f'    {key} = {json.dumps(value, ensure_ascii=False)};' for key, value in item.items()]
            chunks.append('}')
    payload = ('\n'.join(chunks) + '\n').encode('utf-8')
    lumps = [('MAP01', b''), ('TEXTMAP', payload), ('ENDMAP', b'')]
    body = b''; directory = b''
    for name, content in lumps:
        directory += struct.pack('<ii8s', 12 + len(body), len(content), name.encode())
        body += content
    path.write_bytes(struct.pack('<4sii', b'PWAD', len(lumps), 12 + len(body)) + body + directory)


def tags(sector):
    return {sector.get('id', 0)} | set(map(int, sector.get('moreids', '').split()))


def add_tag(sector, tag):
    sector['moreids'] = ' '.join(map(str, sorted((tags(sector) | {tag}) - {sector.get('id', 0), 0})))


def main():
    data = json.loads((DATA / 'REPAIR.json').read_text(encoding='utf-8'))
    source = DATA / data['baseline']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == data['baseline_sha256']
    obj = read_map(source)
    vertices, lines, sides, sectors = (obj[k] for k in ('vertex', 'linedef', 'sidedef', 'sector'))
    controls = {}
    for i, line in enumerate(lines):
        if line.get('special') == 160:
            controls.setdefault(line['arg0'], []).append((i, sectors[sides[line['sidefront']]['sector']]))
    models = lambda sector: [pair for tag in tags(sector) for pair in controls.get(tag, [])]
    report = {'issue': 36, 'baseline_sha256': data['baseline_sha256'], 'gable_sectors': [], 'new_rails': [], 'existing_rails': [], 'materials': []}

    # Extend upper masonry to the underside of each existing roof slope.
    for spec in data['gable_controls']:
        control = dict(sectors[spec['roof_control']])
        control.update(heightfloor=data['gable_base'], heightceiling=data['gable_base'],
                       texturefloor=data['materials']['gable'], textureceiling=data['materials']['gable'])
        for key in list(control):
            if key.startswith('floorplane_'):
                del control[key]
        for component in 'abcd':
            control['ceilingplane_' + component] = -sectors[spec['roof_control']]['floorplane_' + component]
        control['comment'] = 'Issue #36: gable closes at the existing roof underside'
        target = []
        for i, sector in enumerate(sectors):
            if sector.get('id') in data['upper_wall_tags'] and spec['roof_tag'] in tags(sector):
                add_tag(sector, spec['tag']); target.append(i)
        report['gable_sectors'].extend(target)
        si = len(sectors); sectors.append(control)
        x, y, size = spec['control_origin'] + [data['control_size']]
        vi = len(vertices)
        vertices.extend(dict(x=a, y=b) for a,b in [(x,y),(x,y+size),(x+size,y+size),(x+size,y)])
        for j in range(4):
            side = len(sides); sides.append(dict(sector=si, texturemiddle=data['materials']['gable']))
            line = dict(v1=vi+j, v2=vi+(j+1)%4, sidefront=side)
            if j == 0:
                line.update(special=160, arg0=spec['tag'], arg1=1, arg2=16, arg3=255)
                controls[spec['tag']] = [(len(lines), control)]
            lines.append(line)

    # Select the target wall face instead of a shared control-sector wallpaper.
    wall_slots = {}
    for tag, pairs in controls.items():
        walls = [(i,s) for i,s in pairs if s['texturefloor'] == 'CMIN01' and s['heightceiling']-s['heightfloor'] >= data['wall_min_height']]
        if tag in [g['tag'] for g in data['gable_controls']]:
            walls = pairs
        for i, wall in walls:
            highest = max(s['heightfloor'] for _,s in walls)
            slot = 'texturetop' if wall['heightfloor'] == highest else 'texturebottom'
            if tag in [g['tag'] for g in data['gable_controls']]:
                slot = 'texturebottom'
            lines[i]['arg2'] = 16 if slot == 'texturetop' else 32
            wall_slots[i] = slot

    def interior(x, y, z):
        floor = next((level for level in reversed(data['interior_footprints']) if z >= level['z']), data['interior_footprints'][0])
        return any(a < x < c and b < y < d for a,b,c,d in floor['rectangles'])

    for li, line in enumerate(lines[:data['baseline_lines']]):
        a, b = (vertices[line[k]] for k in ('v1','v2'))
        dx,dy = b['x']-a['x'], b['y']-a['y']; length=math.hypot(dx,dy)
        if not length: continue
        for side_key, other_key, sign in [('sidefront','sideback',1), ('sideback','sidefront',-1)]:
            if line.get(side_key,-1)<0: continue
            side = sides[line[side_key]]
            x=(a['x']+b['x'])/2+sign*dy/length*data['face_sample_distance']
            y=(a['y']+b['y'])/2-sign*dx/length*data['face_sample_distance']
            if line.get(other_key,-1)>=0:
                other = sectors[sides[line[other_key]]['sector']]
                for control_id, wall in models(other):
                    if control_id not in wall_slots: continue
                    slot=wall_slots[control_id]
                    material=data['materials']['interior' if interior(x,y,wall['heightfloor']) else 'exterior']
                    if material==data['materials']['exterior'] and length>=data['window_min_span'] and control_id not in [p[0] for g in data['gable_controls'] for p in controls[g['tag']]]:
                        material=data['decoration']['windows']
                    elif material==data['materials']['interior'] and wall['heightfloor']>=data['balcony_levels'][-1]:
                        material=data['decoration']['upper_plaster']
                    side[slot]=material
                    report['materials'].append([line[side_key],slot,material,control_id])
            # Real vertical faces also obey inside/outside placement.
            if side.get('texturemiddle') == 'CMIN01':
                side['texturemiddle']=data['materials']['interior' if interior(x,y,sectors[side['sector']]['heightfloor']) else 'exterior']
            if side.get('texturebottom') == 'CMIN01' and line.get(other_key,-1)>=0:
                other=sectors[sides[line[other_key]]['sector']]
                if other['heightfloor']>sectors[side['sector']]['heightfloor']:
                    side['texturebottom']=data['materials']['interior' if interior(x,y,sectors[side['sector']]['heightfloor']) else 'exterior']

    # Native horizon rendering keeps the existing one-sided collision boundary.
    for index in data['horizon_lines']:
        line=lines[index]; line.update(special=9, blocking=True)
        sides[line['sidefront']]['texturemiddle']='-'

    def solid_spans(sector):
        return [(s['heightfloor'],s['heightceiling']) for i,s in models(sector)
                if lines[i].get('arg1',0)&3==1 and 'floorplane_a' not in s and 'ceilingplane_a' not in s]

    def surface(sector,z):
        spans=solid_spans(sector)
        return (sector['heightfloor']==z or any(top==z for bottom,top in spans)) and not any(bottom<=z<top for bottom,top in spans)

    def blocked(sector,z):
        return sector['heightfloor']>z or any(bottom<=z<top for bottom,top in solid_spans(sector))

    def already_guarded(line,z):
        a,b=[vertices[line[k]] for k in ('v1','v2')]
        dx,dy=b['x']-a['x'],b['y']-a['y'];length=math.hypot(dx,dy)
        intervals=[]
        for rail in lines[:data['baseline_lines']]:
            if f'base z={z}' not in rail.get('comment',''):continue
            c,d=[vertices[rail[k]] for k in ('v1','v2')]
            if abs(dx*(d['y']-c['y'])-dy*(d['x']-c['x']))>0.001:continue
            if abs(dx*(c['y']-a['y'])-dy*(c['x']-a['x']))/length>data['rail_border_width']:continue
            intervals.append(sorted(((v['x']-a['x'])*dx/length+(v['y']-a['y'])*dy/length for v in (c,d))))
        covered=0
        for start,end in sorted(intervals):
            if start>covered+0.001:break
            covered=max(covered,end)
        return covered>=length-0.001

    def faces_walkway_seam(line,z):
        a,b=[vertices[line[k]] for k in ('v1','v2')]
        dx,dy=b['x']-a['x'],b['y']-a['y'];length=math.hypot(dx,dy)
        sf=sectors[sides[line['sidefront']]['sector']]
        facing=1 if surface(sf,z) else -1
        for other in lines[:data['baseline_lines']]:
            if other is line or other.get('sideback',-1)<0:continue
            c,d=[vertices[other[k]] for k in ('v1','v2')]
            cross=dx*(c['y']-a['y'])-dy*(c['x']-a['x'])
            if not 0<cross*facing/length<=data['walkway_seam_width']:continue
            ox,oy=d['x']-c['x'],d['y']-c['y']
            if abs(dx*oy-dy*ox)>0.001:continue
            of,ob=[sectors[sides[other[k]]['sector']] for k in ('sidefront','sideback')]
            if surface(of,z)==surface(ob,z):continue
            other_facing=1 if surface(of,z) else -1
            if (dx*ox+dy*oy)*facing*other_facing>=0:continue
            start,end=sorted(((v['x']-a['x'])*dx/length+(v['y']-a['y'])*dy/length for v in (c,d)))
            if start<=0.001 and end>=length-0.001:return True
        return False

    for li,line in enumerate(lines[:data['baseline_lines']]):
        if line.get('sideback',-1)<0: continue
        boundary=data['balcony_bounds']
        if any(not(boundary[0]<=vertices[line[k]]['x']<=boundary[2] and boundary[1]<=vertices[line[k]]['y']<=boundary[3]) for k in ('v1','v2')):continue
        front,back=[sectors[sides[line[key]]['sector']] for key in ('sidefront','sideback')]
        if sides[line['sidefront']]['sector']==sides[line['sideback']]['sector']: continue
        existing=re.search(r'railing .*base z=(\d+)',line.get('comment',''))
        if existing:
            report['existing_rails'].append([li,int(existing[1])]); continue
        if line.get('special',0) or any(sides[line[k]].get('texturemiddle','-')!='-' for k in ('sidefront','sideback')):continue
        for z in data['balcony_levels']:
            if surface(front,z)==surface(back,z):continue
            drop=back if surface(front,z) else front
            if blocked(drop,z):continue
            floors=[drop['heightfloor']]+[top for bottom,top in solid_spans(drop) if top<=z]
            if z-max(floors)<=data['stair_step_limit']:continue
            if already_guarded(line,z):continue
            if faces_walkway_seam(line,z):continue
            line.update(dontpegbottom=True,midtex3d=True,comment=f'Issue #36 closed balcony / base z={z}')
            offset=(z-max(front['heightfloor'],back['heightfloor']))*data['rail_y_scale']
            for key in ('sidefront','sideback'):
                sides[line[key]].update(texturemiddle='CMRLBAL',offsety_mid=offset)
            report['new_rails'].append([li,z]);break

    # Replace wallpaper on slab fascia and doorway lintels with existing stone.
    for li,line in enumerate(lines):
        if line.get('special')!=160 or li in wall_slots:continue
        side=sides[line['sidefront']]
        if side.get('texturemiddle')=='CMIN01': side['texturemiddle']=data['materials']['trim']

    # Wall-mounted reliefs have no collision and do not intrude into circulation.
    def sector_at(x,y):
        for si,sector in enumerate(sectors[:data.get('baseline_sectors',659)]):
            crossings=0
            for line in lines[:data['baseline_lines']]:
                front=sides[line['sidefront']]['sector']
                back=sides[line['sideback']]['sector'] if line.get('sideback',-1)>=0 else -1
                if (front==si)==(back==si):continue
                a,b=[vertices[line[k]] for k in ('v1','v2')]
                if (a['y']>y)!=(b['y']>y) and x<(b['x']-a['x'])*(y-a['y'])/(b['y']-a['y'])+a['x']:crossings+=1
            if crossings%2:return si
        raise ValueError(f'No sector for relief at {x},{y}')
    report['reliefs']=[]
    for x,y1,y2,z in data['decoration']['panels']:
        si=sector_at(x,(y1+y2)/2)
        vi=len(vertices);vertices.extend([dict(x=x,y=y1),dict(x=x,y=y2)])
        sd=len(sides)
        sides.extend([dict(sector=si,texturemiddle='CMPNL36',offsety_mid=(z-sectors[si]['heightfloor'])*2),dict(sector=si,texturemiddle='-')])
        # Reverse northward orientation so the textured face looks into the room.
        lines.append(dict(v1=vi+1,v2=vi,sidefront=sd,sideback=sd+1,twosided=True,dontpegbottom=True))
        report['reliefs'].append(dict(line=len(lines)-1,sector=si,position=[x,y1,y2,z]))

    write_map(obj, ROOT/'src/maps/MAP01.wad')
    report['output_sha256']=hashlib.sha256((ROOT/'src/maps/MAP01.wad').read_bytes()).hexdigest()
    report['counts']={k:len(v) for k,v in obj.items()}
    (DATA/'GENERATED.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k in ('output_sha256','counts')}))
    print('Gable sectors:',len(report['gable_sectors']),'new railing sections:',len(report['new_rails']))


if __name__=='__main__':
    main()
