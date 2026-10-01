"""Opaque triangular/segmental tympana with closed stone spandrels, issue #61."""
from collections import defaultdict
import math


def mesh(width,height,spec,path):
    vertices=[];faces=[]
    def face(points,material):
        start=len(vertices)
        vertices.extend(points)
        faces.append((material,tuple(range(start+1,start+len(points)+1))))
    a=width/2;d=spec['depth']/2;b=spec['border']
    stone,field=spec['stone_material'],spec['field_material']
    # A complete six-sided box closes every part of the rectangular opening.
    face([(-a,0,-d),(a,0,-d),(a,height,-d),(-a,height,-d)],stone)
    face([(-a,0,d),(-a,height,d),(a,height,d),(a,0,d)],stone)
    face([(-a,0,-d),(-a,height,-d),(-a,height,d),(-a,0,d)],stone)
    face([(a,0,-d),(a,0,d),(a,height,d),(a,height,-d)],stone)
    face([(-a,height,-d),(a,height,-d),(a,height,d),(-a,height,d)],stone)
    face([(-a,0,-d),(-a,0,d),(a,0,d),(a,0,-d)],stone)
    # The filled inset appears on both sides. The backing above/around it is
    # intentional masonry, rather than empty corners outside a drawn outline.
    if width == spec['leaf_width']:
        contour=[(-a+b,b),(0,height-b),(a-b,b)]
    else:
        half=a-b;rise=height-2*b
        radius=(half*half+rise*rise)/(2*rise)
        contour=[]
        for i in range(spec['arch_segments']+1):
            x=-half+2*half*i/spec['arch_segments']
            y=b+math.sqrt(max(0,radius*radius-x*x))-(radius-rise)
            contour.append((x,y))
    for sign in (-1,1):
        depth=sign*(d+spec['face_relief'])
        for p,q in zip(contour,contour[1:]):
            face([(0,b,depth),(p[0],p[1],depth),(q[0],q[1],depth)],field)
    output=['# Issue #61: original filled tympanum; reused project materials.']
    output += [f'v {x:.6f} {y:.6f} {z:.6f}' for x,y,z in vertices]
    # Stable planar UVs use the accepted 64-MU leaf as the material repeat.
    field_vertices={i for material,indices in faces if material==field for i in indices}
    horizontal={i for material,indices in faces if len({vertices[i-1][1] for i in indices})==1 for i in indices}
    end_faces={i for material,indices in faces if len({vertices[i-1][0] for i in indices})==1 for i in indices}
    for i,(x,y,z) in enumerate(vertices,1):
        u=x/spec['leaf_width'];v=y/spec['leaf_width']
        if i in horizontal:v=z/spec['leaf_width']
        if i in end_faces:u=z/spec['leaf_width']
        if i in field_vertices:
            lo,hi=spec['plaster_v_range'];v=lo+(hi-lo)*y/height
        output.append(f'vt {u:.6f} {v:.6f}')
    for material in (stone,field):
        output.append('usemtl '+material)
        for mat,indices in faces:
            if mat==material:output.append('f '+' '.join(f'{i}/{i}' for i in indices))
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text('\n'.join(output)+'\n',encoding='utf-8')


def add_tympana(obj,spec,report,root):
    groups=defaultdict(list)
    for t in obj['thing']:
        if t['type']==spec['leaf_editor_number']:groups[t['arg0']].append(t)
    variants={}
    report['tympana']=[]
    bottom=spec['leaf_model_height']/spec['pixel_stretch']
    for group,leaves in sorted(groups.items()):
        width=spec['leaf_width']*len(leaves)
        base=leaves[0]['height']
        top=spec['group_undersides'].get(str(group),spec['slab_undersides'][str(int(base))])
        height=top-base-bottom
        key=(width,height)
        if key not in variants:
            index=len(variants)
            name=f'CaelumMansionTympanum{index}'
            model=f'ca_mansion_tympanum_{int(width)}_{int(height)}.obj'
            variants[key]=(index,name,model)
            mesh(width,height,spec,root/'src/models/caelum/mansion'/model)
        index,name,model=variants[key]
        x=sum(t['x'] for t in leaves)/len(leaves);y=sum(t['y'] for t in leaves)/len(leaves)
        angle=90 if leaves[0].get('arg2') else 0
        thing=dict(x=x,y=y,height=base+bottom,angle=angle,type=spec['first_editor_number']+index,skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True,dm=True,comment=f'Issue #61: filled tympanum, door group {group}')
        report['tympana'].append(dict(group=group,thing=len(obj['thing']),center=[x,y],base=base,bottom=base+bottom,top=top,width=width,axis=leaves[0].get('arg2',0),model=model))
        obj['thing'].append(thing)
    code=['// Tímpanos fijos generados desde EXTERIOR.json. Conservan la colisión de las puertas.']
    modeldefs=[];editors=[]
    for (width,height),(index,name,model) in variants.items():
        code += [f'class {name} : Actor', '{', '    Default { +NOGRAVITY }', '    States { Spawn: CDLS A -1; Stop; }', '}']
        modeldefs += [f'Model {name}', '{', '    Path "models/caelum/mansion"', f'    Model 0 "{model}"', f'    Scale 1 1 {spec["pixel_stretch"]}', '    CorrectPixelStretch', '    DontCullBackFaces', '    FrameIndex CDLS A 0 0', '}']
        editors.append(f'    {spec["first_editor_number"]+index} = {name}')
    from mansion_door_gable import add_roof_closure
    add_roof_closure(obj,spec,report,root,code,modeldefs,editors)
    (root/'src/caelum/world/CaelumMansionTympana.zs').write_text('\n'.join(code)+'\n',encoding='utf-8')
    for filename,content in [('MODELDEF',modeldefs),('MAPINFO',editors)]:
        path=root/'src'/filename
        text=path.read_text(encoding='utf-8')
        start='// BEGIN GENERATED MANSION TYMPANA';end='// END GENERATED MANSION TYMPANA'
        block=start+'\n'+'\n'.join(content)+'\n'+end
        if start in text:
            first=text.index(start);last=text.index(end,first)+len(end)
            text=text[:first]+block+text[last:]
        elif filename=='MAPINFO':
            at=text.rfind('}')
            text=text[:at]+block+'\n'+text[at:]
        else:text+='\n'+block+'\n'
        path.write_text(text,encoding='utf-8')
