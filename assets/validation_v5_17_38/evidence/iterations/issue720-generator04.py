"""Export continuous posed serpent bodies with original attached anatomy."""
from pathlib import Path
import hashlib,json,math,re
try:
    from .generate_nahuelito_model import Mesh,md3,fixed
    from .generate_peuchen_model import ellipsoid
    from .generate_duende_models import material_uv
    from .generate_beast_men_models import main as shared_main
except ImportError:
    from generate_nahuelito_model import Mesh,md3,fixed
    from generate_peuchen_model import ellipsoid
    from generate_duende_models import material_uv
    from generate_beast_men_models import main as shared_main
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/serpents_720'
MODEL_PATH='models/caelum/folklore/serpents'
DEFINITION='caelum/data/serpent_combat.modeldef'


def digest(blob):return hashlib.sha256(blob).hexdigest()
def add(a,b):return tuple(x+y for x,y in zip(a,b))
def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def mul(a,b):return tuple(x*b for x in a)
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]
def unit(v):
    size=math.sqrt(dot(v,v))
    if size<1e-10:raise ValueError('Degenerate serpent frame')
    return mul(v,1/size)
def smooth(t):t=max(0,min(1,t));return t*t*(3-2*t)


def sample(controls,t):
    pos=t*(len(controls)-1);i=min(len(controls)-2,int(pos));f=pos-i
    a,b,c,d=[controls[max(0,min(len(controls)-1,k))] for k in [i-1,i,i+1,i+2]]
    return tuple(.5*(2*y+(-x+z)*f+(2*x-5*y+4*z-w)*f*f+(-x+3*y-3*z+w)*f*f*f) for x,y,z,w in zip(a,b,c,d))


def frames_for(rows):
    frames=[];across=None
    for i,row in enumerate(rows):
        tangent=unit(sub(rows[min(i+1,len(rows)-1)][:3],rows[max(i-1,0)][:3]))
        projected=sub(across,mul(tangent,dot(across,tangent))) if across is not None else (0,0,0)
        if dot(projected,projected)<1e-10:
            projected=cross(tangent,(0,0,1) if abs(tangent[2])<.9 else (1,0,0))
        across=unit(projected);up=unit(cross(across,tangent));frames.append((tangent,across,up))
    return frames


def sweep(design,shape):
    """Welded continuous sweep, with explicit pole fan and repeated UV seams."""
    mesh=Mesh();weights=[];count=shape['samples'];segments=shape['segments']
    rows=[sample(shape['controls'],i/count) for i in range(count+1)];basis=frames_for(rows);cache={}
    def vertex(i,j,material,v):
        key=(i,j,material,round(v,10))
        if key not in cache:
            row=rows[i];angle=math.tau*j/segments;across,up=basis[i][1:]
            p=add(row[:3],add(mul(across,row[3]*math.cos(angle)),mul(up,row[4]*math.sin(angle))))
            u=j/segments
            if material==shape.get('belly_material'):u=(u-shape['belly_range'][0])/(shape['belly_range'][1]-shape['belly_range'][0])
            cache[key]=mesh.vertex(p,material_uv(design,material,u,v),shape['part']);weights.append(i/count)
        return cache[key]
    first=1 if shape.get('tail_pole') else 0;last=count-1 if shape.get('tip_pole') else count
    for i in range(first,last):
        period=count/shape['uv_repeats'];v0=(i%period)/period;v1=v0+1/period
        for j in range(segments):
            u=(j+.5)/segments;material=shape['material']
            if 'belly_range' in shape and shape['belly_range'][0]<=u<=shape['belly_range'][1]:material=shape['belly_material']
            mesh.quad((vertex(i,j,material,v0),vertex(i+1,j,material,v1),vertex(i+1,j+1,material,v1),vertex(i,j+1,material,v0)),material)
    for i,side,pole in [(first,-1,0 if first else first),(last,1,count if last<count else last)]:
        material=shape['material'];center=mesh.vertex(rows[pole][:3],material_uv(design,material,.5,.5),shape['part']);weights.append(pole/count)
        for j in range(segments):
            tri=(center,vertex(i,j,material,.5),vertex(i,j+1,material,.5))
            a,b,c=[mesh.vertices[k] for k in tri]
            if dot(cross(sub(b,a),sub(c,a)),mul(basis[i][0],side))<0:tri=tuple(reversed(tri))
            mesh.faces.append((material,tri))
    volume=sum(dot(mesh.vertices[a],cross(mesh.vertices[b],mesh.vertices[c]))/6 for _,(a,b,c) in mesh.faces)
    if volume<0:mesh.faces=[(m,tuple(reversed(tri))) for m,tri in mesh.faces]
    return mesh,weights,rows,basis


def geometry(design):
    mesh=Mesh();weights=[];body_rows=body_basis=None
    for shape in design['shapes']:
        if shape['kind']=='sweep':component,w,rows,basis=sweep(design,shape)
        elif shape['kind']=='ellipsoid':component=ellipsoid(design,shape);w=[shape['anchor']]*len(component.vertices)
        else:raise ValueError('Unknown serpent component '+shape['kind'])
        if shape['part']=='body':body_rows,body_basis=rows,basis
        else:w=[shape['anchor']]*len(component.vertices)
        begin=len(mesh.vertices)
        for p,uv,part in zip(component.vertices,component.uv,component.parts):mesh.vertex(p,uv,part)
        mesh.faces.extend((m,tuple(begin+i for i in tri)) for m,tri in component.faces);weights.extend(w)
    return mesh,weights,body_rows,body_basis


def posed_spine(design,control,rows):
    rig=design['rig'];result=[]
    for i,row in enumerate(rows):
        t=i/(len(rows)-1);head=smooth((t-rig['neck_start'])/(1-rig['neck_start']));tail=1-head
        x,y,z=row[:3]
        y+=control['sway']*math.sin(t*math.tau*rig['wave_cycles']+control['phase'])*math.sin(t*math.pi)*tail
        x+=control['reach']*head
        y+=control['fall']*rig['fall_side']*head
        z*=1-control['fall']*rig['fall_flatten']*head
        z+=control['lift']*head
        result.append((x,y,z,*row[3:]))
    return result,frames_for(result)


def transport(point,t,old_rows,old_basis,new_rows,new_basis):
    i=max(0,min(len(old_rows)-1,round(t*(len(old_rows)-1))));delta=sub(point,old_rows[i][:3])
    return add(new_rows[i][:3],tuple(sum(dot(delta,old_basis[i][j])*new_basis[i][j][axis] for j in range(3)) for axis in range(3)))


def pose(design,mesh,weights,old_rows,old_basis,control):
    rows,basis=posed_spine(design,control,old_rows);points=[]
    for p,part,t in zip(mesh.vertices,mesh.parts,weights):
        if part=='jaw':
            x,y,z=sub(p,design['rig']['jaw_pivot']);a=math.radians(control['jaw']);p=add(design['rig']['jaw_pivot'],(x*math.cos(a)+z*math.sin(a),y,-x*math.sin(a)+z*math.cos(a)))
        points.append(transport(p,t,old_rows,old_basis,rows,basis))
    floor=min(p[2] for p in points);return [(x,y,z-floor) for x,y,z in points],floor


def output_files():
    config=json.loads((SOURCE/'ANIMATION.json').read_text(encoding='utf-8'));files={};records={};definitions=[]
    for name,h in config['source_sha256'].items():
        if digest((ROOT/name).read_bytes())!=h:raise ValueError('Changed source '+name)
    profile=(ROOT/config['profile_source']).read_text(encoding='utf-8').split('class '+config['profile_class']+' :',1)[1].split('class ',1)[0]
    defaults={k:float(re.search(r'\b'+k+r'\s+([\d.]+)\s*;',profile)[1]) for k in ['Height','Radius','Scale']}
    for kind,item in config['species'].items():
        design=json.loads((ROOT/item['design']).read_text());mesh,weights,rows,basis=geometry(design)
        frames=[];floors=[]
        for frame in config['frames']:
            p,floor=pose(design,mesh,weights,rows,basis,frame['control']);frames.append(p);floors.append(floor)
        shaders={k:MODEL_PATH+'/'+Path(p).name for k,p in item['textures'].items()}
        native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
        native.faces=[(design['materials'][m]['native_batch'],tri) for m,tri in mesh.faces]
        binary,surfaces,bounds=md3(native,frames,shaders);factor=defaults['Height']/(max(p[2] for p in frames[0])-min(p[2] for p in frames[0]))/defaults['Scale']
        files[MODEL_PATH+'/'+kind+'.md3']=binary[:8]+fixed(item['catalogue_id']+' inherited combat',64)+binary[72:]
        for k,p in item['textures'].items():files[shaders[k]]=(ROOT/p).read_bytes()
        definitions+=['Model '+item['actor'],'{',f' Path "{MODEL_PATH}"',f' Model 0 "{kind}.md3"',f' Scale {factor:.12g} {factor:.12g} {factor:.12g}',' CorrectPixelStretch']
        definitions += [f' FrameIndex {f["sprite"]} {f["letter"]} 0 {i}' for i,f in enumerate(config['frames'])];definitions+=['}','']
        lines=['# Original continuous serpent; OBJ Y up. Editable rig and poses in JSON.','mtllib '+kind+'.mtl']
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv];previous=None
        for material,tri in mesh.faces:
            group=mesh.parts[tri[0]];batch=design['materials'][material]['native_batch']
            if previous!=(group,batch):lines+=['g '+group,'usemtl '+batch];previous=(group,batch)
            lines.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
        files['editable/'+kind+'.obj']=('\n'.join(lines)+'\n').encode()
        files['editable/'+kind+'.mtl']=''.join(f'newmtl {k}\nKd 1 1 1\nmap_Kd src/{p}\n' for k,p in shaders.items()).encode()
        records[kind]=dict(actor=item['actor'],catalogue_id=item['catalogue_id'],vertices=len(mesh.vertices),triangles=len(mesh.faces),hierarchical_parts=len(design['shapes']),surfaces=surfaces,native_bounds=bounds,modeldef_scale=factor,native_profile=defaults,source_sha256=digest((ROOT/item['reference']).read_bytes()),pose_floors=floors)
    files[DEFINITION]='\n'.join(definitions).encode()
    sources=dict(config['source_sha256'])
    paths=[SOURCE/'ANIMATION.json',SOURCE/'PROVENANCE.json',*[ROOT/i['design'] for i in config['species'].values()],*[SOURCE/n for n in ['MONAI_SCALES_PROMPT.json','TATA_SCALES_PROMPT.json','MATERIALS_PROMPT.json']],*[Path(__file__).with_name(n) for n in ['generate_serpent_models.py','generate_nahuelito_model.py','generate_peuchen_model.py','generate_duende_models.py','generate_pombero_model.py']]]
    sources.update({p.relative_to(ROOT).as_posix():digest(p.read_bytes()) for p in paths})
    files['manifest.json']=(json.dumps(dict(schema_revision=1,issue=720,parent_issue=461,status=config['status'],frames=config['frames'],species=records,source_sha256=sources,sha256={n:digest(b) for n,b in files.items()}),indent=2)+'\n').encode()
    return files


if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
