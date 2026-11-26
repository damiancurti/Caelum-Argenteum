"""Measure leg coverage inside serialized clothing at opposite strides."""
from pathlib import Path
from collections import defaultdict
import json,struct

ROOT=Path(__file__).resolve().parents[2]


def inspect_stride(root=ROOT,kind='viuda'):
    source=root/'assets/source/art/period_apparitions_811';vertices=[];owners=defaultdict(list);group=None
    design=json.loads((source/(kind+'.json')).read_text());names=[s['name'] for s in design['shapes']]
    for line in (source/('editable/'+kind+'.obj')).read_text().splitlines():
        words=line.split()
        if not words:continue
        if words[0]=='v':
            x,z,y=map(float,words[1:]);vertices.append(tuple(round(v*64) for v in (x,-y,z)))
        elif words[0]=='g':group=next(n for n in sorted(names,key=len,reverse=True) if words[1].startswith(n+'_'))
        elif words[0]=='f':owners[tuple(vertices[int(v.split('/')[0])-1] for v in words[1:])].append(group)
    blob=(root/('src/models/caelum/folklore/periodapparitions/'+kind+'.md3')).read_bytes()
    header=struct.unpack_from('<4sI64s9I',blob);offset=header[10];frames={i:defaultdict(list) for i in [3,5]}
    for _ in range(header[6]):
        h=struct.unpack_from('<4s64s10I',blob,offset)
        triangles=[struct.unpack_from('<3I',blob,offset+h[7]+i*12) for i in range(h[6])]
        neutral=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])]
        labels=[owners[tuple(neutral[i] for i in tri)].pop() for tri in triangles]
        for frame,groups in frames.items():
            points=[struct.unpack_from('<3h',blob,offset+h[10]+(frame*h[5]+i)*8) for i in range(h[5])]
            for tri,name in zip(triangles,labels):groups[name].append(tuple(points[i] for i in tri))
        offset+=h[-1]
    results={};errors=[]
    for frame,groups in frames.items():
        # The clothed hip volume covers the upper thigh where the skirts join.
        cloth=[tri for name in ['pelvis','skirt','lower_flounce','overskirt'] for tri in groups[name]]
        low=min(p[2] for tri in cloth for p in tri);high=max(p[2] for tri in cloth for p in tri)
        surfaces=[(min(p[1] for p in t),max(p[1] for p in t),min(p[2] for p in t),max(p[2] for p in t),t) for t in cloth]
        tested=0;outside=[]
        for name,triangles in groups.items():
            if not (name.startswith(('left_','right_')) and any(token in name for token in ['_thigh','_shin','_foot','_toe_'])):continue
            for x,y,z in set(p for tri in triangles for p in tri):
                if not low+1<z<high-1:continue
                crossings=[]
                for ymin,ymax,zmin,zmax,(a,b,c) in surfaces:
                    if not ymin<=y<=ymax or not zmin<=z<=zmax:continue
                    uy,uz=b[1]-a[1],b[2]-a[2];vy,vz=c[1]-a[1],c[2]-a[2];det=uy*vz-uz*vy
                    if abs(det)<1e-9:continue
                    dy,dz=y-a[1],z-a[2];u=(dy*vz-dz*vy)/det;v=(uy*dz-uz*dy)/det
                    if u>=-1e-7 and v>=-1e-7 and u+v<=1+1e-7:crossings.append(a[0]+u*(b[0]-a[0])+v*(c[0]-a[0]))
                tested+=1
                if not crossings or not min(crossings)-1<=x<=max(crossings)+1:outside.append(dict(part=name,vertex=[x/64,y/64,z/64],cloth_x_bounds=[min(crossings)/64,max(crossings)/64] if crossings else None))
        results[str(frame)]=dict(tested_leg_vertices=tested,outside_envelope=len(outside),examples=outside[:8])
        if outside:errors.append(f'{kind} native stride{frame}: {len(outside)} leg vertices outside clothing above hem')
    return errors,results


def validate(root=ROOT):
    errors=[]
    for kind in ['viuda','llorona']:
        try:errors.extend(inspect_stride(root,kind)[0])
        except (OSError,KeyError,ValueError,IndexError,StopIteration,struct.error) as exc:errors.append(kind+': '+str(exc))
    return errors


if __name__=='__main__':
    data={kind:inspect_stride(ROOT,kind) for kind in ['viuda','llorona']}
    print(json.dumps(dict(errors=[e for value in data.values() for e in value[0]],geometry={k:v[1] for k,v in data.items()}),indent=2))
    raise SystemExit(any(v[0] for v in data.values()))
