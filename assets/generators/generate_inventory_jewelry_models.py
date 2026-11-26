"""Export closed jewelry props using unchanged owned painted icon materials."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
from PIL import Image
try:
    from .generate_nahuelito_model import Mesh, md3, fixed
except ImportError:
    from generate_nahuelito_model import Mesh, md3, fixed

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/inventory_models_647/jewelry'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def geometry(item,material,metal):
    mesh=Mesh()
    for part in item['parts']:
        start=len(mesh.faces);first_vertex=len(mesh.vertices);cx,cy=part['center'];name=part['part']
        def vertex(point,paint=False,uv=None):
            x,y,z=point
            u,v=((x+64)/128,(120-z)/128) if uv is None else uv
            left,top,right,bottom=metal['rect_pixels'];w,h=metal['image_size']
            return mesh.vertex(point,((x+64)/128,(120-z)/128) if paint else ((left+(right-left)*u)/w,(top+(bottom-top)*v)/h),name)
        if part['kind']=='solid':
            rows=[];outline=part['outline'];count=len(outline)
            for depth,factor in part['profile']:
                rows.append([vertex((cx-64+x*factor,depth,120-cy+z*factor),part['paint']) for x,z in outline])
            for row in range(len(rows)-1):
                for i in range(count):mesh.quad((rows[row][i],rows[row][(i+1)%count],rows[row+1][(i+1)%count],rows[row+1][i]),'paint' if part['paint'] else 'metal')
            for row in (0,-1):
                depth,factor=part['profile'][row];paint=part['paint'] and row==-1
                center=vertex((cx-64,depth,120-cy),paint)
                points=[vertex((cx-64+x*factor,depth,120-cy+z*factor),paint) for x,z in outline]
                for i in range(count):
                    triangle=(center,points[i],points[(i+1)%count])
                    mesh.faces.append(('paint' if paint else 'metal',tuple(reversed(triangle)) if row==0 else triangle))
        else:
            rx,rz=part['radii'];n=part['segments'];m=part['wire_segments'];wire=part['wire']
            angle=math.radians(part['angle']);tilt=math.radians(part['tilt']);rings=[]
            for i in range(n):
                a=math.tau*i/n;row=[]
                for j in range(m):
                    b=math.tau*j/m
                    x=(rx+wire*math.cos(b))*math.cos(a);z=(rz+wire*math.cos(b))*math.sin(a);y=wire*math.sin(b)
                    x,y=x*math.cos(tilt)-y*math.sin(tilt),x*math.sin(tilt)+y*math.cos(tilt)
                    x,z=x*math.cos(angle)+z*math.sin(angle),-x*math.sin(angle)+z*math.cos(angle)
                    row.append(vertex((cx-64+x,y,120-cy+z),uv=(j/m,i/n)))
                rings.append(row)
            for i in range(n):
                for j in range(m):mesh.quad((rings[i][j],rings[(i+1)%n][j],rings[(i+1)%n][(j+1)%m],rings[i][(j+1)%m]),'metal')
        if part.get('undercoat'):
            mesh.uv[first_vertex:]=[item['undercoat_uv']]*(len(mesh.vertices)-first_vertex)
            mesh.faces[start:]=[('paint',tri) for _,tri in mesh.faces[start:]]
        # Orient each closed component outward, then verify it independently.
        if volume(mesh,mesh.faces[start:])<0:
            mesh.faces[start:]=[(mat,tuple(reversed(tri))) for mat,tri in mesh.faces[start:]]
    edges={};directions={};volumes={}
    for _,tri in mesh.faces:
        points=[tuple(round(v,7) for v in mesh.vertices[i]) for i in tri];part=mesh.parts[tri[0]]
        for a,b in zip(points,points[1:]+points[:1]):
            key=part,tuple(sorted((a,b)));edges[key]=edges.get(key,0)+1;directions[key]=directions.get(key,0)+(1 if a<b else -1)
        volumes[part]=volumes.get(part,0)+signed_volume(points)
    if any(v!=2 for v in edges.values()) or any(directions.values()) or any(v<=0 for v in volumes.values()):
        raise ValueError('Jewelry contains an open, inward or inconsistently wound component: '+str({k:v for k,v in volumes.items() if v<=0})+' edges='+str(sum(v!=2 for v in edges.values()))+' winding='+str(sum(v!=0 for v in directions.values())))
    return mesh,volumes


def signed_volume(points):
    a,b,c=points
    return (a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6


def volume(mesh,faces):return sum(signed_volume([mesh.vertices[i] for i in tri]) for _,tri in faces)


def output_files():
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    for path,checksum in config['source_sha256'].items():
        if digest((ROOT/path).read_bytes())!=checksum:raise ValueError('Changed owned source: '+path)
    files={};records={};definitions=[];mtl=[]
    for name,item in config['variants'].items():
        material=config['materials'][name];mesh,volumes=geometry(item,material,config['materials'][item['metal']])
        mesh.faces=[(name if mat=='paint' else item['metal'],tri) for mat,tri in mesh.faces]
        alpha=Image.open(ROOT/item['reference']).convert('RGBA').getchannel('A')
        bounds=alpha.point(lambda v:255 if v>=128 else 0).getbbox()
        low=[min(p[a] for p in mesh.vertices) for a in range(3)];high=[max(p[a] for p in mesh.vertices) for a in range(3)]
        factor=min((bounds[2]-bounds[0])/(high[0]-low[0]),(bounds[3]-bounds[1])/(high[2]-low[2]))
        frame=[(x*factor,y*factor,(z-low[2])*factor) for x,y,z in mesh.vertices]
        binary,surfaces,native_bounds=md3(mesh,[frame],{m:s['texture'] for m,s in config['materials'].items()})
        files[config['model_path']+'/'+name+'.md3']=binary[:8]+fixed('CA674 '+name,64)+binary[72:]
        for binding in [item,*item.get('additional_bindings',[])]:
            definitions.append(f'Model {binding["class"]} {{ Path "{config["model_path"]}" Model 0 "{name}.md3" Scale 1 1 1 CorrectPixelStretch FrameIndex {binding["sprite"]} A 0 0 }}')
        lines=['# Original volumetric jewelry; OBJ Y up. Separate closed editable parts.','mtllib jewelry.mtl']
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frame]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv]
        previous=None
        for mat,tri in mesh.faces:
            part=mesh.parts[tri[0]]
            if (part,mat)!=previous:lines+=['g '+part,'usemtl '+mat];previous=(part,mat)
            lines.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
        files['editable/'+name+'.obj']=('\n'.join(lines)+'\n').encode()
        records[name]=dict(**{'class':item['class']},parts=volumes,closed_outward_components=len(volumes),vertices=len(mesh.vertices),triangles=len(mesh.faces),surfaces=surfaces,native_bounds=native_bounds,reference_opaque_bounds=bounds,reference_sprite_scale=item['sprite_scale'],uniform_fit=factor)
    for name,material in config['materials'].items():mtl+=['newmtl '+name,'Kd 1 1 1','map_Kd src/'+material['texture']]
    files['editable/jewelry.mtl']=('\n'.join(mtl)+'\n').encode()
    files['caelum/data/inventory_jewelry.modeldef']=('\n'.join(definitions)+'\n').encode()
    report=dict(schema_revision=1,issue=674,parent_issue=647,status=config['status'],variants=records,
                source_sha256={p:digest((SOURCE/p).read_bytes()) for p in ('DESIGN.json','PROVENANCE.json')},
                external_source_sha256=config['source_sha256'],
                generator_sha256={p:digest(Path(__file__).with_name(p).read_bytes()) for p in ('generate_inventory_jewelry_models.py','generate_nahuelito_model.py','generate_pombero_model.py')},
                sha256={p:digest(b) for p,b in files.items()})
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files()
    for name,blob in files.items():
        paths=[args.output/name]
        if args.install:paths.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in paths:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale jewelry model: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,13,0,0,0)),blob)
            config=json.loads((SOURCE/'DESIGN.json').read_text())
            for texture in sorted({s['texture'] for s in config['materials'].values()}):
                blob=(ROOT/'src'/texture).read_bytes()
                package.writestr(zipfile.ZipInfo(texture,(2026,11,13,0,0,0)),blob)
                if args.install:
                    path=SOURCE/'editable/src'/texture;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    print(json.dumps({k:v['triangles'] for k,v in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
