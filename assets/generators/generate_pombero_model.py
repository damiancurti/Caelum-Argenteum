"""Build the reference-led Pombero visual pilot from editable shape/pose data.

Reuse the owned Nahuelito mesh and MD3 writer. This is a visual editing utility,
not a collision, statistics, population or gameplay animation authority.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
try:
    from .generate_nahuelito_model import Mesh, md3, fixed, add, sub, mul, dot, cross, unit
except ImportError:
    from generate_nahuelito_model import Mesh, md3, fixed, add, sub, mul, dot, cross, unit

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/pombero_455'
MODEL_PATH = 'models/caelum/folklore/pombero'


def orient(mesh, tri, outward):
    a,b,c = (mesh.vertices[i] for i in tri)
    return tuple(reversed(tri)) if dot(cross(sub(b,a),sub(c,a)),outward)<0 else tri


def tube(mesh, shape):
    rows=shape['rows'];segments=shape.get('segments',12);rings=[]
    for i,row in enumerate(rows):
        point=row[:3];direction=unit(sub(rows[min(i+1,len(rows)-1)][:3],rows[max(0,i-1)][:3]))
        reference=(0,0,1) if abs(direction[2])<.9 else (1,0,0)
        across=unit(cross(direction,reference));up=unit(cross(across,direction));ring=[]
        for j in range(segments+1):
            angle=math.tau*j/segments
            vertex=add(point,add(mul(across,row[3]*math.cos(angle)),mul(up,row[4]*math.sin(angle))))
            ring.append(mesh.vertex(vertex,(j/segments,i/(len(rows)-1)),shape['part']))
        rings.append(ring)
    for i in range(len(rings)-1):
        for j in range(segments):
            a,b,c,d=rings[i][j],rings[i+1][j],rings[i+1][j+1],rings[i][j+1]
            outward=sub(mesh.vertices[a],rows[i][:3])
            mesh.faces.extend((shape['material'],orient(mesh,tri,outward)) for tri in ((a,b,c),(a,c,d)))
    for i,neighbor in ((0,1),(-1,-2)):
        center=mesh.vertex(rows[i][:3],(.5,.5),shape['part'])
        for j in range(segments):
            mesh.faces.append((shape['material'],orient(mesh,(center,rings[i][j],rings[i][j+1]),sub(rows[i][:3],rows[neighbor][:3]))))


def loft(mesh,shape):
    rows=shape['rows'];segments=shape.get('segments',24);rings=[]
    start,end=shape.get('angles',[0,360])
    for i,(z,x,y,rx,ry) in enumerate(rows):
        ring=[]
        for j in range(segments+1):
            angle=math.radians(start+(end-start)*j/segments)
            wave=shape.get('wave',0)*math.sin(angle*3+.4)*(i/(len(rows)-1))
            ring.append(mesh.vertex((x+rx*math.cos(angle),y+ry*math.sin(angle),z+wave),
                                    (j/segments,1-i/(len(rows)-1)),shape['part']))
        rings.append(ring)
    for i in range(len(rings)-1):
        for j in range(segments):
            mesh.quad((rings[i][j],rings[i][j+1],rings[i+1][j+1],rings[i+1][j]),shape['material'])
    if shape.get('cap',True) and end-start==360:
        for i,direction in ((0,(0,0,-1)),(-1,(0,0,1))):
            z,x,y,_,_=rows[i];center=mesh.vertex((x,y,z),(.5,.5),shape['part'])
            for j in range(segments):mesh.faces.append((shape['material'],orient(mesh,(center,rings[i][j],rings[i][j+1]),direction)))


def ear(mesh,shape):
    outline=shape['outline'];center=shape['center'];rings=[]
    for scale,depth in shape.get('rim_rings',((1,0),(.72,.65),(.25,-.15))):
        rings.append([mesh.vertex(add(center,add(mul(sub(p,center),scale),(depth,0,0))),
                                  (i/len(outline),scale),shape['part']) for i,p in enumerate(outline)])
    for i in range(len(rings)-1):
        for j in range(len(outline)):
            k=(j+1)%len(outline);a,b,c,d=rings[i][j],rings[i][k],rings[i+1][k],rings[i+1][j]
            mesh.faces.extend((shape['material'],orient(mesh,tri,(1,0,0))) for tri in ((a,b,c),(a,c,d)))
    for ring,position,outward in ((rings[-1],add(center,(shape.get('concha_depth',-.4),0,0)),(1,0,0)),(rings[0],add(center,(shape.get('rear_depth',-1.3),0,0)),(-1,0,0))):
        mid=mesh.vertex(position,(.5,.5),shape['part'])
        for j in range(len(ring)):mesh.faces.append((shape['material'],orient(mesh,(mid,ring[j],ring[(j+1)%len(ring)]),outward)))


def panel(mesh,shape):
    points=shape['outline'];ys=[p[1] for p in points];zs=[p[2] for p in points]
    vertices=[mesh.vertex(p,((p[1]-min(ys))/(max(ys)-min(ys)),(max(zs)-p[2])/(max(zs)-min(zs))),shape['part']) for p in points]
    for i in range(1,len(vertices)-1):
        mesh.faces.append((shape['material'],orient(mesh,(vertices[0],vertices[i],vertices[i+1]),(1,0,0))))


def geometry(design):
    mesh=Mesh()
    for shape in design['shapes']:
        begin=len(mesh.vertices)
        face_begin=len(mesh.faces)
        if shape['kind']=='ellipsoid':
            mesh.ellipsoid(shape['center'],shape['radii'],shape['part'],shape['material'],shape.get('rings',10),shape.get('segments',20))
            for i in range(begin,len(mesh.vertices)):
                x,y,z=mesh.vertices[i];front=max(0,(x-shape['center'][0])/shape['radii'][0])**3
                for bump in shape.get('front_deformation',[]):
                    x+=front*bump['depth']*math.exp(-((y-bump['y'])/bump['width_y'])**2-((z-bump['z'])/bump['width_z'])**2)
                mesh.vertices[i]=(x,y,z)
        elif shape['kind']=='tube':tube(mesh,shape)
        elif shape['kind']=='loft':loft(mesh,shape)
        elif shape['kind']=='ear':ear(mesh,shape)
        elif shape['kind']=='panel':panel(mesh,shape)
        else:raise ValueError('Unknown editable shape: '+shape['kind'])
        material=design['materials'][shape['material']]
        for i in range(begin,len(mesh.vertices)):
            u,v=mesh.uv[i]
            if 'sample' in material:mesh.uv[i]=tuple(material['sample'])
            elif 'tile' in material:
                column,row=material['tile'];margin=design['atlas']['inset']
                mesh.uv[i]=((column+margin+(1-2*margin)*u)/design['atlas']['columns'],
                            (row+margin+(1-2*margin)*v)/design['atlas']['rows'])
            elif 'uv_rect' in material:
                left,top,right,bottom=material['uv_rect']
                mesh.uv[i]=(left+(right-left)*u,top+(bottom-top)*v)
        # A frontal material follows actual head geometry, not a camera-facing plane.
        projection=shape.get('front_projection')
        if projection:
            duplicates={}
            left,right=projection['y_bounds'];bottom,top=projection['z_bounds']
            for face_index in range(face_begin,len(mesh.faces)):
                _,tri=mesh.faces[face_index]
                if sum(mesh.vertices[index][0] for index in tri)/3<projection['minimum_x']:continue
                mapped=[]
                for index in tri:
                    if index not in duplicates:
                        x,y,z=mesh.vertices[index]
                        uv=((y-left)/(right-left),(top-z)/(top-bottom))
                        duplicates[index]=mesh.vertex((x,y,z),uv,mesh.parts[index])
                    mapped.append(duplicates[index])
                mesh.faces[face_index]=(projection['material'],tuple(mapped))
    used=sorted({index for _,tri in mesh.faces for index in tri})
    remap={old:new for new,old in enumerate(used)}
    mesh.vertices=[mesh.vertices[i] for i in used]
    mesh.uv=[mesh.uv[i] for i in used];mesh.parts=[mesh.parts[i] for i in used]
    mesh.faces=[(material,tuple(remap[i] for i in tri)) for material,tri in mesh.faces]
    return mesh


def rotate(point,pivot,axis,degrees):
    p=list(sub(point,pivot));angle=math.radians(degrees);c,s=math.cos(angle),math.sin(angle)
    a,b={'x':(1,2),'y':(2,0),'z':(0,1)}[axis]
    p[a],p[b]=p[a]*c-p[b]*s,p[a]*s+p[b]*c
    return add(p,pivot)


def poses(mesh,design):
    low=min(p[2] for p in mesh.vertices);high=max(p[2] for p in mesh.vertices)
    scale=design['preview']['height_map_units']/(high-low);frames=[];labels=[]
    parts=design['parts']
    for action,motion in design['motion'].items():
        for frame in range(motion['frames']):
            phase=math.tau*frame/motion['frames'];points=[]
            for vertex,part in zip(mesh.vertices,mesh.parts):
                point=vertex
                while part is not None:
                    info=parts[part];pivot=info['pivot']
                    for transform in motion.get('transforms',{}).get(part,[]):
                        pulse=math.sin(phase*transform.get('frequency',1)+transform.get('phase',0))
                        if transform.get('positive_only'):pulse=max(0,pulse)
                        amount=transform.get('offset',0)+transform['amplitude']*pulse
                        if transform['kind']=='rotate':point=rotate(point,pivot,transform['axis'],amount)
                        elif transform['kind']=='scale_xy':
                            delta=sub(point,pivot);point=add(pivot,(delta[0]*(1+amount),delta[1]*(1+amount),delta[2]))
                        elif transform['kind']=='translate_z':point=add(point,(0,0,amount))
                        else:raise ValueError('Unknown visual transform.')
                    part=info['parent']
                points.append(mul(point,scale))
            # Preview-only floor contact; no collision or movement rules are changed.
            floor=min(p[2] for p in points);points=[(x,y,z-floor) for x,y,z in points]
            frames.append(points);labels.append({'action':action,'sample':frame,'tics':motion['tics']})
    return frames,labels


def output_files():
    design=json.loads((SOURCE/'DESIGN.json').read_text(encoding='utf-8'));mesh=geometry(design);frames,labels=poses(mesh,design)
    materials={name:entry['path'] for name,entry in design['materials'].items()}
    # Material labels stay editable in OBJ; native batches share the same atlas.
    native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
    batches={'atlas':f'{MODEL_PATH}/materials.png','dark':f'{MODEL_PATH}/dark.png'}
    for name,entry in design['materials'].items():
        if 'source_file' in entry:batches[entry.get('native_batch',name)]=entry['path']
    native.faces=[(design['materials'][name].get('native_batch','dark' if name=='dark' else 'atlas'),tri) for name,tri in mesh.faces]
    binary,stats,bounds=md3(native,frames,batches)
    # The shared writer's format is unchanged; only the owned model header name differs.
    binary=binary[:8]+fixed('CA-FOLK-006 Pombero visual pilot',64)+binary[72:]
    model=['Model CA455PomberoPreview','{',f'    Path "{MODEL_PATH}"','    Model 0 "pombero.md3"','    Scale 1 1 1']
    states=['// Piloto visual sin combate, población ni colisión final.','class CA455PomberoPreview : Actor','{',
            f'    Default {{ RenderRadius {design["preview"]["render_radius"]}; +NOINTERACTION +NOGRAVITY }}','    States','    {','    Spawn:','        Goto Idle;']
    textures=[]
    for index,label in enumerate(labels):
        action=label['action'];sample=label['sample'];sprite='PBMI' if action=='idle' else 'PBMW';letter=chr(65+sample)
        model.append(f'    FrameIndex {sprite} {letter} 0 {index}')
        textures.append(f'Sprite "{sprite}{letter}0", 1, 1 {{ Patch "graphics/caelum/bull_invisible.png", 0, 0 }}')
        if sample==0:states.append(f'    {action.title()}:')
        states.extend([f'    Frame{index}:',f'        {sprite} {letter} {label["tics"]};'])
        if sample==design['motion'][action]['frames']-1:states.append(f'        Goto {action.title()};')
    states.extend(['    }','}']);model.append('}')
    output={f'{MODEL_PATH}/pombero.md3':binary,f'{MODEL_PATH}/materials.png':(SOURCE/design['atlas']['source_file']).read_bytes(),
            f'{MODEL_PATH}/dark.png':(SOURCE/'dark.png').read_bytes(),
            'ZSCRIPT':('version "4.14.2"\n'+'\n'.join(states)+'\n').encode(),
            'MODELDEF':('\n'.join(model)+'\n').encode(),'TEXTURES':('\n'.join(textures)+'\n').encode()}
    for entry in design['materials'].values():
        if 'source_file' in entry:output[entry['path']]=(SOURCE/entry['source_file']).read_bytes()
    obj=['# CA-FOLK-006 editable neutral pose; OBJ Y up, X forward.','mtllib pombero.mtl']
    obj.extend(f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]);obj.extend(f'vt {u:.6f} {1-v:.6f}' for u,v in mesh.uv)
    previous=None
    for material,tri in mesh.faces:
        if material!=previous:obj.append('usemtl '+material);previous=material
        obj.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
    output['pombero.obj']=('\n'.join(obj)+'\n').encode()
    output['pombero.mtl']=('\n'.join(f'newmtl {name}\nKd 1 1 1\nmap_Kd {path}' for name,path in materials.items())+'\n').encode()
    sources=['DESIGN.json',design['atlas']['source_file'],'dark.png','PROMPT.json','PROMPT-v2.json']
    sources+=design.get('additional_sources',[])
    sources+=sorted({entry['source_file'] for entry in design['materials'].values() if 'source_file' in entry})
    manifest={'schema_revision':1,'issue':455,'catalogue_id':'CA-FOLK-006','status':'unintegrated_visual_pilot',
              'generator_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'shared_writer_sha256':hashlib.sha256(Path(__file__).with_name('generate_nahuelito_model.py').read_bytes()).hexdigest(),
              'source_sha256':{name:hashlib.sha256((SOURCE/name).read_bytes()).hexdigest() for name in sources},
              'vertices':len(mesh.vertices),'triangles':len(mesh.faces),'surfaces':stats,'frames':labels,'bounds':bounds,
              'sha256':{name:hashlib.sha256(data).hexdigest() for name,data in output.items()}}
    output['manifest.json']=(json.dumps(manifest,indent=2)+'\n').encode()
    return output


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--check',action='store_true')
    args=parser.parse_args();files=output_files();target=args.output.resolve()
    for name,data in files.items():
        path=target/name
        if args.check:
            if not path.is_file() or path.read_bytes()!=data:raise SystemExit('Stale Pombero output: '+name)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
    if not args.check:
        with zipfile.ZipFile(target/'preview.pk3','w',compression=zipfile.ZIP_DEFLATED) as archive:
            for name,data in sorted(files.items()):
                if name.endswith(('.obj','.mtl','.json')):continue
                archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),data)
    print(json.dumps({'files':len(files),'output':str(target),'checked':args.check}))


if __name__=='__main__':main()
