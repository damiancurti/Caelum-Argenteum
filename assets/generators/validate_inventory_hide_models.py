"""Check four hide drops using the shared independent serialized geometry inspector."""
import hashlib,json,struct
from collections import defaultdict
from PIL import Image
try:
    from .validate_inventory_ammunition_models import ROOT,validate as validate_family
    from .validate_inventory_weapon_components_models import inspect_geometry
except ImportError:
    from validate_inventory_ammunition_models import ROOT,validate as validate_family
    from validate_inventory_weapon_components_models import inspect_geometry


def inspect_surface_uv(root,kind):
    source=root/'assets/source/art/inventory_models_647/hides'
    config=json.loads((source/'DESIGN.json').read_text());part=config['families'][kind]['parts'][0]
    points=[];uvs=[];faces=[];levels=defaultdict(set);errors=[]
    for line in (source/'editable'/(kind+'.obj')).read_text().splitlines():
        row=line.split()
        if not row:continue
        if row[0]=='v':
            p=tuple(map(float,row[1:]));points.append(p);levels[(p[0],p[2])].add(p[1])
        elif row[0]=='vt':uvs.append((float(row[1]),1-float(row[2])))
        elif row[0]=='f':faces.append([tuple(int(v)-1 for v in cell.split('/')) for cell in row[1:]])
    if any(len(v)!=2 for v in levels.values()):errors.append('Hide sheet needs exactly two surface levels per planar point')
    counts=dict(top=0,underside=0,rim=0)
    material=config['materials'][part['material']];w,h=material['image_size'];a,b,c,d=material['rect_pixels']
    for face in faces:
        vertices=[points[v] for v,_ in face]
        if all(p[1]==max(levels[(p[0],p[2])]) for p in vertices):side='top'
        elif all(p[1]==min(levels[(p[0],p[2])]) for p in vertices):side='underside'
        else:side='rim'
        counts[side]+=1;l,t,r,bottom=part[side+'_uv_rect'];rect=((a+(c-a)*l)/w,(b+(d-b)*t)/h,(a+(c-a)*r)/w,(b+(d-b)*bottom)/h)
        coords=[uvs[uv] for _,uv in face]
        if any(not(rect[0]-1e-7<=u<=rect[2]+1e-7 and rect[1]-1e-7<=v<=rect[3]+1e-7) for u,v in coords):errors.append('Wrong atlas region on '+side)
        p,q,r=coords
        if abs((q[0]-p[0])*(r[1]-p[1])-(q[1]-p[1])*(r[0]-p[0]))<1e-12:errors.append('Collapsed surface UV on '+side)
    if not all(counts.values()):errors.append('Missing textured hide surface')
    return errors,counts


def validate(root=ROOT):
    errors=validate_family(root,'hides',4,distinct_classes=False)
    try:
        source=root/'assets/source/art/inventory_models_647/hides';config=json.loads((source/'DESIGN.json').read_text());report=json.loads((source/'EXPORT.json').read_text())
        ids=[19,76,77,78]
        if [(v['class'],v['sprite'],v['item_type']) for v in config['variants'].values()]!=[('CaelumMaterialPickup',f'M{n:03}',n) for n in ids]:errors.append('Unexpected hide world bindings')
        if config['runtime_cases']!=[dict(item_type=n,tier=t) for n in ids for t in ([1,2,3] if n==19 else [1])]:errors.append('Changed hide type/tier cases')
        for name,checksum in report['sha256'].items():
            if name.startswith('editable/') and hashlib.sha256((source/name).read_bytes()).hexdigest()!=checksum:errors.append('Stale portable mesh '+name)
        for settings in config['materials'].values():
            texture=settings['texture']
            if (source/'editable/src'/texture).read_bytes()!=(root/'src'/texture).read_bytes():errors.append('Changed portable material '+texture)
            a,b,c,d=settings['rect_pixels']
            if Image.open(root/'src'/texture).convert('RGBA').getchannel('A').crop((a-1,b-1,c+1,d+1)).getextrema()!=(255,255):errors.append('Nonopaque hide material')
        for kind in config['variants']:
            more,_=inspect_geometry(root,kind,'hides');errors.extend(kind+': '+e for e in more)
            more,_=inspect_surface_uv(root,kind);errors.extend(kind+': '+e for e in more)
    except (OSError,ValueError,KeyError,struct.error) as exc:errors.append(str(exc))
    return errors


if __name__=='__main__':
    errors=validate();stats={k:inspect_geometry(ROOT,k,'hides')[1] for k in ['leather','cow_hide','predator_hide','monster_hide']}
    print(json.dumps(dict(errors=errors,geometry=stats,surface_triangles={k:inspect_surface_uv(ROOT,k)[1] for k in stats})));raise SystemExit(bool(errors))
