"""Deterministic, reference-led Nahuelito mesh and MD3 visual pilot (#455).

DESIGN.json owns editable anatomy and motion, without gameplay statistics.
The texture is the unchanged image_gen material source. No image processing,
installed engine, renderer or Blender is needed for export. Production actors
and MODELDEF are deliberately not changed while behavior is unauthored.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/nahuelito_455'


def add(a, b): return tuple(x+y for x,y in zip(a,b))
def sub(a, b): return tuple(x-y for x,y in zip(a,b))
def mul(a, f): return tuple(x*f for x in a)
def dot(a, b): return sum(x*y for x,y in zip(a,b))
def cross(a, b): return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def unit(a): return mul(a, 1/max(1e-12,math.sqrt(dot(a,a))))


class Mesh:
    def __init__(self):
        self.vertices=[];self.uv=[];self.parts=[];self.faces=[]

    def vertex(self,p,uv,part):
        self.vertices.append(tuple(p));self.uv.append(tuple(uv));self.parts.append(part)
        return len(self.vertices)-1

    def quad(self,indices,material):
        a,b,c,d=indices;self.faces.extend([(material,(a,b,c)),(material,(a,c,d))])

    def tube(self,rows,part,segments,repeat,flipper=False,material='hide'):
        distance=0;previous=None;rings=[]
        for index,row in enumerate(rows):
            p=tuple(row[:3]);radius,thickness=row[3:]
            before=rows[max(0,index-1)][:3];after=rows[min(len(rows)-1,index+1)][:3]
            tangent=unit(sub(after,before))
            if flipper:
                across=unit((tangent[1],-tangent[0],0));up=unit(cross(across,tangent))
            else:
                across=(0,1,0);up=unit(cross(tangent,across))
            if up[2]<0:up=mul(up,-1)
            if previous:distance+=math.dist(p,previous)
            previous=p;ring=[]
            for j in range(segments+1):
                theta=math.tau*j/segments
                point=add(p,add(mul(across,radius*math.sin(theta)),mul(up,-thickness*math.cos(theta))))
                ring.append(self.vertex(point,(distance/repeat,j/segments),part))
            rings.append(ring)
        for i in range(len(rings)-1):
            for j in range(segments):
                q=(rings[i][j],rings[i+1][j],rings[i+1][j+1],rings[i][j+1])
                # A geometric outward test also handles mirrored flippers.
                a,b,c=(self.vertices[k] for k in q[:3]);middle=mul(add(rows[i][:3],rows[i+1][:3]),.5)
                if dot(cross(sub(b,a),sub(c,a)),sub(a,middle))<0:q=tuple(reversed(q))
                self.quad(q,material)
        for end in (0,-1):
            center=self.vertex(rows[end][:3],(.5,.5),part)
            for j in range(segments):
                tri=(center,rings[end][j],rings[end][j+1])
                a,b,c=(self.vertices[k] for k in tri)
                outward=sub(rows[end][:3],rows[1 if end==0 else -2][:3])
                if dot(cross(sub(b,a),sub(c,a)),outward)<0:tri=tuple(reversed(tri))
                self.faces.append((material,tri))

    def ellipsoid(self,center,radii,part,material='hide',rings=8,segments=16,uv_band=None):
        indices=[]
        for i in range(rings+1):
            theta=math.pi*(.001+.998*i/rings);row=[]
            for j in range(segments+1):
                phi=math.tau*j/segments
                point=add(center,(radii[0]*math.sin(theta)*math.cos(phi),radii[1]*math.sin(theta)*math.sin(phi),radii[2]*math.cos(theta)))
                uv=(j/segments,i/rings) if uv_band is None else (j/segments,uv_band+.03*math.cos(theta))
                row.append(self.vertex(point,uv,part))
            indices.append(row)
        for i in range(rings):
            for j in range(segments):
                self.quad((indices[i][j],indices[i+1][j],indices[i+1][j+1],indices[i][j+1]),material)


def spline(rows,subdivisions):
    """Catmull-Rom authoring controls, clamped radii at tapered ends."""
    result=[]
    for i in range(len(rows)-1):
        p0,p1,p2,p3=(rows[max(0,min(len(rows)-1,k))] for k in (i-1,i,i+1,i+2))
        for step in range(subdivisions):
            t=step/subdivisions
            row=[.5*((2*b)+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t) for a,b,c,d in zip(p0,p1,p2,p3)]
            row[3:]=[max(.08,x) for x in row[3:]];result.append(row)
    return result+[rows[-1]]


def geometry(design):
    g=design['geometry'];mesh=Mesh();segments=g['ring_segments'];repeat=g['skin_repeat_distance']
    body=spline(g['body_neck_tail'],g['subdivisions'])
    mesh.tube(body,'body',segments,repeat)
    for part in ('head','jaw'):
        mesh.tube(spline(g[part],g['subdivisions']),part,segments,repeat)
    for side in (-1,1):
        for label in ('front_flipper','rear_flipper'):
            rows=[[x,side*y,z,w,h] for x,y,z,w,h in g[label]]
            mesh.tube(spline(rows,g['subdivisions']),label+str(side),segments,repeat,True)
        for name in ('eyes','nostrils'):
            data=g[name];x,y,z=data['center'];center=(x,side*y,z)
            if name=='nostrils':mesh.ellipsoid(center,data['radii'],'head','dark');continue
            mesh.ellipsoid(center,data['socket_radii'],'head','hide',uv_band=.5)
            mesh.ellipsoid(add(center,(0,side*.65,0)),data['iris_radii'],'head','iris')
            mesh.ellipsoid(add(center,(0,side*1,0)),data['pupil_radii'],'head','dark')
        for label,radius,material in [('brow',g['brow_radius'],'hide'),('lip',g['lip_radius'],'dark')]:
            rows=[[x,side*y,z,radius,radius] for x,y,z in g[label]]
            mesh.tube(spline(rows,3),'head',8,repeat,False,material)
    # Individual low swept scutes follow the same dorsal centerline as the body.
    distance=0;last=-g['crest_spacing']
    for i in range(1,len(body)-1):
        p=body[i][:3];distance+=math.dist(p,body[i-1][:3])
        if distance-last<g['crest_spacing'] or body[i][3]<3:continue
        last=distance;tangent=unit(sub(body[i+1][:3],body[i-1][:3]));up=unit(cross(tangent,(0,1,0)))
        center=add(p,mul(up,body[i][4]-.25));half=g['crest_length']/2
        a=add(center,mul(tangent,-half));b=add(center,mul(tangent,half))
        peak=add(add(center,mul(tangent,-half*.5)),mul(up,g['crest_height']*min(1,body[i][3]/10)))
        for side in (-1,1):
            points=[add(a,(0,side*g['crest_width'],0)),add(b,(0,side*g['crest_width'],0)),peak]
            indices=[mesh.vertex(q,(j*.3,.5),'body') for j,q in enumerate(points)]
            if side<0:indices.reverse()
            mesh.faces.append(('hide',tuple(indices)))
    for x,y,z,height in g['head_scutes']:
        for side in (-1,1):
            points=[(x-3,side*1.1,z),(x+3,side*1.1,z),(x-2,0,z+height)]
            indices=[mesh.vertex(p,(j*.3,.5),'head') for j,p in enumerate(points)]
            if side<0:indices.reverse()
            mesh.faces.append(('hide',tuple(indices)))
    return mesh


def rotate_x(p,pivot,angle):
    x,y,z=sub(p,pivot);c,s=math.cos(angle),math.sin(angle)
    return add(pivot,(x,y*c-z*s,y*s+z*c))


def poses(mesh,design):
    result=[];labels=[]
    for action,data in design['motion'].items():
        for index in range(data['frames']):
            phase=math.tau*index/data['frames'];frame=[]
            for p,part in zip(mesh.vertices,mesh.parts):
                x,y,z=p
                if 'flipper' in part:
                    side=-1 if part.endswith('-1') else 1
                    name=part.replace('-1','').replace('1','');root=design['geometry'][name][0][:3]
                    pivot=(root[0],side*root[1],root[2]);lag=0 if name.startswith('front') else 1.1
                    angle=side*math.radians(data['flipper_degrees'])*math.sin(phase-lag)
                    x,y,z=rotate_x((x,y,z),pivot,angle)
                tail=max(0,min(1,(-x-70)/170))
                y+=math.sin(phase-tail*1.4)*data['tail_sway']*tail*tail
                neck=max(0,min(1,(z-95)/125))
                y+=math.sin(phase-.6)*data['neck_sway']*neck*neck
                z+=math.sin(phase*2)*data['heave']
                frame.append((x,y,z))
            result.append(frame);labels.append({'action':action,'sample':index,'tics':data['sample_tics']})
    return result,labels


def fixed(text,length):
    raw=text.encode('ascii')
    if len(raw)>=length:raise ValueError(text)
    return raw.ljust(length,b'\0')


def normals(mesh,frame):
    """Smooth seam-aware normals; sharp scutes remain independent geometry."""
    accum={};keys=[(part,tuple(round(c,5) for c in p)) for part,p in zip(mesh.parts,mesh.vertices)]
    for material,tri in mesh.faces:
        a,b,c=(frame[i] for i in tri);n=cross(sub(b,a),sub(c,a))
        for index in tri:accum[keys[index]]=add(accum.get(keys[index],(0,0,0)),n)
    output=[]
    for key in keys:
        n=unit(accum.get(key,(0,0,1)))
        lat=round(math.atan2(n[1],n[0])*128/math.pi)&255
        lng=round(math.acos(max(-1,min(1,n[2])))*128/math.pi)&255
        output.append((lat<<8)|lng)
    return output


def md3(mesh,frames,materials):
    all_normals=[normals(mesh,frame) for frame in frames];surfaces=[];stats=[]
    for material,path in materials.items():
        faces=[tri for mat,tri in mesh.faces if mat==material];batches=[];mapping={};tris=[]
        for tri in faces:
            if len(mapping)+sum(i not in mapping for i in tri)>4096:
                batches.append((mapping,tris));mapping={};tris=[]
            for i in tri:
                if i not in mapping:mapping[i]=len(mapping)
            tris.append(tuple(mapping[i] for i in tri))
        if tris:batches.append((mapping,tris))
        for batch,(mapping,tris) in enumerate(batches):
            triangle_data=b''.join(struct.pack('<3I',*t) for t in tris)
            shader=struct.pack('<64sI',fixed(path,64),0)
            uv=b''.join(struct.pack('<2f',mesh.uv[i][0],mesh.uv[i][1]) for i in mapping)
            vertex=bytearray()
            for frame,frame_normals in zip(frames,all_normals):
                for i in mapping:
                    xyz=[round(c*64) for c in frame[i]]
                    if any(c<-32768 or c>32767 for c in xyz):raise ValueError('MD3 coordinate overflow')
                    vertex.extend(struct.pack('<3hH',*xyz,frame_normals[i]))
            a=108;b=a+len(triangle_data);c=b+len(shader);d=c+len(uv);end=d+len(vertex)
            header=struct.pack('<4s64s10I',b'IDP3',fixed(f'{material}_{batch}',64),0,len(frames),1,len(mapping),len(tris),a,b,c,d,end)
            surfaces.append(header+triangle_data+shader+uv+vertex)
            stats.append({'material':material,'vertices':len(mapping),'triangles':len(tris)})
    frame_headers=bytearray();bounds=[]
    for index,frame in enumerate(frames):
        low=[min(p[i] for p in frame) for i in range(3)];high=[max(p[i] for p in frame) for i in range(3)]
        radius=max(math.sqrt(dot(p,p)) for p in frame)
        frame_headers.extend(struct.pack('<10f16s',*low,*high,0,0,0,radius,fixed(f'pose{index:02}',16)))
        bounds.append({'min':low,'max':high})
    start=108+len(frame_headers);end=start+sum(map(len,surfaces))
    header=struct.pack('<4sI64s9I',b'IDP3',15,fixed('CA-FOLK-055 visual pilot',64),0,len(frames),0,len(surfaces),0,108,start,start,end)
    return header+frame_headers+b''.join(surfaces),stats,bounds


def output_files():
    design=json.loads((SOURCE/'DESIGN.json').read_text(encoding='utf-8'));mesh=geometry(design)
    frames,labels=poses(mesh,design);binary,stats,bounds=md3(mesh,frames,design['materials'])
    model=['Model CA455NahuelitoPreview','{','    Path "models/caelum/folklore/nahuelito"','    Model 0 "nahuelito.md3"',
           '    Scale 1 1 1','    CorrectPixelStretch']
    states=['// Piloto visual aislado: no define combate, población ni colisión final.',
            'class CA455NahuelitoPreview : Actor','{',
            f'    Default {{ RenderRadius {design["preview"]["render_radius"]}; +NOINTERACTION +NOGRAVITY }}','    States','    {','    Spawn:','        Goto Idle;']
    textures=[]
    for index,entry in enumerate(labels):
        action=entry['action'];sample=entry['sample'];letter=chr(65+sample);sprite='NHAI' if action=='idle' else 'NHAS'
        model.append(f'    FrameIndex {sprite} {letter} 0 {index}')
        textures.append(f'Sprite "{sprite}{letter}0", 1, 1 {{ Patch "graphics/caelum/bull_invisible.png", 0, 0 }}')
        if sample==0:states.append(f'    {action.title()}:')
        states.append(f'    Frame{index}:');states.append(f'        {sprite} {letter} {entry["tics"]};')
        if sample==design['motion'][action]['frames']-1:states.append(f'        Goto {action.title()};')
    states.extend(['    }','}']);model.append('}')
    output={'models/caelum/folklore/nahuelito/nahuelito.md3':binary,
            'models/caelum/folklore/nahuelito/skin.png':(SOURCE/'skin.png').read_bytes(),
            design['materials']['iris']:(SOURCE/'iris.png').read_bytes(),
            design['materials']['dark']:(SOURCE/'dark.png').read_bytes(),
            'MODELDEF':('\n'.join(model)+'\n').encode(),'TEXTURES':('\n'.join(textures)+'\n').encode(),
            'ZSCRIPT':('version "4.14.2"\n'+'\n'.join(states)+'\n').encode()}
    obj=['# CA-FOLK-055 editable neutral mesh; OBJ Y up, X forward.','mtllib nahuelito.mtl']
    obj.extend(f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in mesh.vertices)
    obj.extend(f'vt {u:.6f} {1-v:.6f}' for u,v in mesh.uv)
    last=None
    for material,tri in mesh.faces:
        if material!=last:obj.append('usemtl '+material);last=material
        obj.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
    output['nahuelito.obj']=('\n'.join(obj)+'\n').encode()
    output['nahuelito.mtl']=('\n'.join(f'newmtl {name}\nKd 1 1 1\nmap_Kd {path}' for name,path in design['materials'].items())+'\n').encode()
    manifest={'schema_revision':1,'issue':455,'catalogue_id':'CA-FOLK-055','status':design['status'],
              'generator_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'source_sha256':{name:hashlib.sha256((SOURCE/name).read_bytes()).hexdigest() for name in ('DESIGN.json','skin.png','iris.png','dark.png','PROMPT.json')},
              'vertices':len(mesh.vertices),'triangles':len(mesh.faces),'surfaces':stats,'frames':labels,'bounds':bounds,
              'sha256':{name:hashlib.sha256(data).hexdigest() for name,data in output.items()}}
    output['manifest.json']=(json.dumps(manifest,indent=2)+'\n').encode()
    return output


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',required=True,type=Path)
    parser.add_argument('--check',action='store_true');args=parser.parse_args();files=output_files()
    if args.check:
        stale=[name for name,data in files.items() if not (args.output/name).is_file() or (args.output/name).read_bytes()!=data]
        if stale:raise SystemExit('Stale model output: '+', '.join(stale))
    else:
        for name,data in files.items():
            path=args.output/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
        with zipfile.ZipFile(args.output/'preview.pk3','w',zipfile.ZIP_DEFLATED) as package:
            for name,data in sorted(files.items()):
                if name.endswith(('.obj','.mtl','.json')):continue
                info=zipfile.ZipInfo(name,(2026,11,12,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
                package.writestr(info,data)
    manifest=json.loads(files['manifest.json']);print(json.dumps({k:manifest[k] for k in ('vertices','triangles','surfaces')}))


if __name__=='__main__':main()
