"""Append author-requested Tarot example rooms without editing prior geometry."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets/tarot_examples'


def append_examples(blob):
    try:
        from .generate_tarot_justice import lumps, pack, parse
    except ImportError:
        from generate_tarot_justice import lumps, pack, parse
    data = json.loads((DATA/'ROOM.json').read_text(encoding='utf-8'))
    entries = lumps(blob)
    if entries[0][0] != data['map']:
        return blob, None
    text = dict(entries)['TEXTMAP'].decode('utf-8')
    assert 'user_ca_tarot_examples' not in text
    old = parse(text)
    assert not any(row.get('id') == data['water_tag'] for row in old['sector'])
    ox, oy = data['origin']
    width, height = data['width_mu'], data['height_mu']
    # Original control sectors are also excluded. Justice is the only room south
    # of -30000 and lies entirely west of the annex.
    assert all(v['x'] < ox or v['x'] > ox+width or v['y'] < oy or v['y'] > oy+height
               for v in old['vertex'])
    added = {kind: [] for kind in old}
    vertices, edges = {}, {}

    def sector(role, ceiling=None):
        row = dict(heightfloor=0, heightceiling=ceiling or data['headroom_mu'],
                   texturefloor=data['floor'], textureceiling=data['wall'],
                   lightlevel=data['dry_light'], user_ca_tarot_examples=role)
        if role == 4:
            row.update(id=data['water_tag'], user_ca_tarot_room=1)
        index = len(old['sector'])+len(added['sector'])
        added['sector'].append(row)
        return index

    owners = [sector(i) for i in range(5)]
    thresholds = [sector(i, data['door_height_mu']) for i in range(1, 5)]

    def vertex(point):
        if point not in vertices:
            vertices[point] = len(old['vertex'])+len(added['vertex'])
            added['vertex'].append(dict(x=point[0], y=point[1]))
        return vertices[point]

    def rectangle(x0, y0, x1, y1, owner):
        points = [(ox+x0, oy+y0), (ox+x0, oy+y1), (ox+x1, oy+y1), (ox+x1, oy+y0)]
        for a, b in zip(points, points[1:]+points[:1]):
            key = tuple(sorted((a, b)))
            if key in edges:
                assert 'back' not in edges[key]
                edges[key]['back'] = owner
            else:
                edges[key] = dict(a=a, b=b, front=owner)

    dividers = data['room_boundaries_mu'][1:-1]
    half = data['partition_mu']/2
    xs = sorted(set(data['room_boundaries_mu']+sum(data['openings'], [])
                    +[x+offset for x in dividers for offset in (-half, half)]))
    ys = [0, data['corridor_mu'], data['corridor_mu']+data['partition_mu'], height]
    for x0, x1 in zip(xs, xs[1:]):
        x = (x0+x1)/2
        room = next(i for i, end in enumerate(data['room_boundaries_mu'][1:]) if x < end)
        for row, (y0, y1) in enumerate(zip(ys, ys[1:])):
            if row > 0 and any(abs(x-wall) < half for wall in dividers):
                continue
            if row == 1 and not any(a < x < b for a, b in data['openings']):
                continue
            owner = owners[0] if row == 0 else thresholds[room] if row == 1 else owners[room+1]
            rectangle(x0, y0, x1, y1, owner)
    for edge in edges.values():
        front, back = edge['front'], edge.get('back')
        if front == back:
            continue
        side = len(old['sidedef'])+len(added['sidedef'])
        added['sidedef'].append(dict(sector=front, texturemiddle=data['wall'] if back is None else '-',
                                     texturetop=data['wall'], texturebottom=data['wall']))
        line = dict(v1=vertex(edge['a']), v2=vertex(edge['b']), sidefront=side, blocking=back is None)
        if back is not None:
            line.update(sideback=side+1, twosided=True)
            added['sidedef'].append(dict(sector=back, texturemiddle='-', texturetop=data['wall'], texturebottom=data['wall']))
        added['linedef'].append(line)
    # One nonsolid swimmable native floor. Its ceiling is initially at ground
    # level; the Wheel controller will raise it to the approved 64-MU depth.
    control = len(old['sector'])+len(added['sector'])
    added['sector'].append(dict(heightfloor=-data['water_depth_mu'], heightceiling=0,
        texturefloor=data['water'], textureceiling=data['water'], lightlevel=data['dry_light'],
        user_ca_tarot_examples=5, user_ca_potable_water=1))
    points = [(ox, oy-64), (ox, oy-48), (ox+16, oy-48), (ox+16, oy-64)]
    for i, (a, b) in enumerate(zip(points, points[1:]+points[:1])):
        side = len(old['sidedef'])+len(added['sidedef'])
        added['sidedef'].append(dict(sector=control, texturemiddle=data['water']))
        line = dict(v1=vertex(a), v2=vertex(b), sidefront=side, blocking=True)
        if i == 0:
            line.update(special=160, arg0=data['water_tag'], arg1=2, arg2=0, arg3=128)
        added['linedef'].append(line)
    chunks = ['\n// #440: appended Tarot examples; existing map bytes above remain unchanged.']
    for kind, rows in added.items():
        for row in rows:
            chunks.append(kind+'{'+''.join(k+'='+json.dumps(v)+';' for k, v in row.items())+'}')
    suffix = ('\n'.join(chunks)+'\n').encode()
    result = pack([(name, content+suffix if name == 'TEXTMAP' else content) for name, content in entries])
    geometry = dict(sectors=owners, thresholds=thresholds, water_control=control,
                    settings_sha256=hashlib.sha256((DATA/'ROOM.json').read_bytes()).hexdigest(),
                    original_counts={k:len(v) for k,v in old.items()}, added_counts={k:len(v) for k,v in added.items()})
    return result, geometry
