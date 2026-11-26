"""Build the reference-led Cuero Uñudo visual pilot, not gameplay anatomy."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
try:
    from .generate_nahuelito_model import Mesh, md3, fixed, add, sub, mul, cross, unit, spline
    from .generate_pombero_model import tube
except ImportError:
    from generate_nahuelito_model import Mesh, md3, fixed, add, sub, mul, cross, unit, spline
    from generate_pombero_model import tube

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/cuero_455'
MODEL_PATH='models/caelum/folklore/cuero'


def surface(g,x,y):
    rx,ry=g['radii'];radius=min(1,math.hypot(x/rx,y/ry));angle=math.atan2(y/ry,x/rx)
    fx,fy=g['relief_frequency']
    return (g['center_top']+g['rim_rise']*radius**g['rim_power']
            +g['edge_wave']*math.cos(g['edge_lobes']*angle)*radius**8
            +sum(amplitude*math.sin(frequency*angle+phase)*radius**2.5 for frequency,phase,amplitude in g['broad_folds'])
            +g['surface_relief']*math.sin(x*fx)*math.cos(y*fy))


def remap_uv(mesh,begin,design,material):
    atlas=design['atlas'];column,row=atlas['tiles'][material];margin=atlas['inset']
    for i in range(begin,len(mesh.vertices)):
        u,v=mesh.uv[i]
        if material=='hide':
            x,y,_=mesh.vertices[i];rx,ry=design['geometry']['radii']
            u=max(0,min(1,.5+x/(2*rx)));v=max(0,min(1,.5-y/(2*ry)))
        mesh.uv[i]=((column+margin+(1-2*margin)*u)/atlas['columns'],
                    (row+margin+(1-2*margin)*v)/atlas['rows'])


def add_tube(mesh,rows,design,material,part,segments):
    begin=len(mesh.vertices)
    tube(mesh,{'rows':rows,'part':part,'material':material,'segments':segments})
    remap_uv(mesh,begin,design,material)


def geometry(design):
    g=design['geometry'];mesh=Mesh();rx,ry=g['radii'];rings=g['rings'];segments=g['segments']
    surfaces=[]
    for underside in (False,True):
        begin=len(mesh.vertices);rows=[];material='underside' if underside else 'hide'
        center_z=g['center_top']-(g['center_thickness'] if underside else 0)
        center=mesh.vertex((0,0,center_z),(.5,.5),'body')
        for radial in range(1,rings+1):
            radius=radial/rings;row=[]
            for j in range(segments+1):
                angle=math.tau*j/segments;x=rx*radius*math.cos(angle);y=ry*radius*math.sin(angle)
                z=surface(g,x,y)
                if underside:z-=g['center_thickness']+(g['rim_thickness']-g['center_thickness'])*radius**2
                row.append(mesh.vertex((x,y,z),(.5+x/(2*rx),.5-y/(2*ry)),'body'))
            rows.append(row)
        for j in range(segments):
            tri=(center,rows[0][j],rows[0][j+1])
            mesh.faces.append((material,tuple(reversed(tri)) if underside else tri))
        for i in range(len(rows)-1):
            for j in range(segments):
                q=(rows[i][j],rows[i+1][j],rows[i+1][j+1],rows[i][j+1])
                mesh.quad(tuple(reversed(q)) if underside else q,material)
        remap_uv(mesh,begin,design,material);surfaces.append(rows[-1])
    # Close the physical rim; the visual actor still has no gameplay collision.
    begin=len(mesh.vertices)
    for j in range(segments):
        q=[]
        for side,column in ((0,j),(1,j),(1,j+1),(0,j+1)):
            q.append(mesh.vertex(mesh.vertices[surfaces[side][column]],(column/segments,side),'body'))
        mesh.quad(q,'hide')
    remap_uv(mesh,begin,design,'hide')
    claw=g['claws']
    for i in range(claw['count']):
        angle=math.tau*i/claw['count'];cosine=math.cos(angle);sine=math.sin(angle)
        x=rx*claw['start_radius']*cosine;y=ry*claw['start_radius']*sine;z=surface(g,x,y)
        rows=[[x+distance*cosine,y+distance*sine,z+height,width,thickness] for distance,height,width,thickness in claw['rows']]
        add_tube(mesh,spline(rows,claw['subdivisions']),design,'horn','claw'+str(i),claw['segments'])
        begin=len(mesh.vertices)
        mesh.ellipsoid((x,y,z),claw['root_radii'],'claw'+str(i),'hide',4,8)
        remap_uv(mesh,begin,design,'hide')
    rim=[]
    for j in range(segments+1):
        angle=math.tau*j/segments;x=rx*math.cos(angle);y=ry*math.sin(angle)
        rim.append([x,y,surface(g,x,y),g['rim_tube_radius'],g['rim_tube_radius']])
    add_tube(mesh,rim,design,'hide','rim',8)
    ridge=g['ridge']
    details=list(g['warts'])
    for i in range(ridge['count']):
        left,right=ridge['x_range'];x=left+(right-left)*i/(ridge['count']-1)
        begin=len(mesh.vertices)
        mesh.ellipsoid((x,0,surface(g,x,0)),ridge['radii'],'ridge','hide',4,8)
        remap_uv(mesh,begin,design,'hide')
    for x,y,radius in details:
        begin=len(mesh.vertices)
        mesh.ellipsoid((x,y,surface(g,x,y)),(radius,radius,radius*.65),'wart','hide',4,8)
        remap_uv(mesh,begin,design,'hide')
    eyes=g['eyes'];direction=unit(eyes['direction']);across=(0,1,0);up=unit(cross(direction,across))
    for index,(x,y) in enumerate(eyes['centers']):
        center=(x,y,surface(g,x,y)+eyes['height']);part='eye'+str(index);begin=len(mesh.vertices)
        tip=mesh.vertex(add(center,mul(direction,eyes['depth'])),(.5,.5),part);rows=[]
        for radial in range(1,eyes['rings']+1):
            radius=radial/eyes['rings'];row=[]
            for j in range(eyes['segments']+1):
                angle=math.tau*j/eyes['segments'];u=radius*math.cos(angle);v=radius*math.sin(angle)
                point=add(center,add(mul(direction,eyes['depth']*math.sqrt(max(0,1-radius*radius))),
                                     add(mul(across,eyes['radius']*u),mul(up,eyes['radius']*v))))
                row.append(mesh.vertex(point,(.5+.5*u,.5-.5*v),part))
            rows.append(row)
        for j in range(eyes['segments']):mesh.faces.append(('iris',(tip,rows[0][j],rows[0][j+1])))
        for i in range(len(rows)-1):
            for j in range(eyes['segments']):mesh.quad((rows[i][j],rows[i+1][j],rows[i+1][j+1],rows[i][j+1]),'iris')
        remap_uv(mesh,begin,design,'iris')
        rim=[]
        for j in range(eyes['segments']+1):
            angle=math.tau*j/eyes['segments']
            point=add(center,add(mul(across,eyes['radius']*math.cos(angle)),mul(up,eyes['radius']*math.sin(angle))))
            rim.append([*point,eyes['rim_radius'],eyes['rim_radius']])
        add_tube(mesh,rim,design,'hide',part,8)
    return mesh


def poses(mesh,design):
    diameter=max(max(p[axis] for p in mesh.vertices)-min(p[axis] for p in mesh.vertices) for axis in (0,1))
    scale=design['preview']['diameter_map_units']/diameter;rx,ry=design['geometry']['radii']
    frames=[];labels=[]
    for action,motion in design['motion'].items():
        for sample in range(motion['frames']):
            phase=math.tau*sample/motion['frames'];points=[]
            for x,y,z in mesh.vertices:
                edge=min(1.4,math.hypot(x/rx,y/ry))**2
                wave=phase+x/rx*motion['spatial_phase']+y/ry*motion['cross_phase']
                z+=motion['amplitude']*(.25+.75*edge)*math.sin(wave)
                x+=motion['lateral']*edge*math.sin(phase+y/ry*motion['cross_phase'])
                points.append((x*scale,y*scale,z*scale))
            floor=min(point[2] for point in points)
            frames.append([(x,y,z-floor) for x,y,z in points])
            labels.append({'action':action,'sample':sample,'tics':motion['tics'],'sprite':design['native']['sprites'][action]})
    return frames,labels


def output_files():
    design=json.loads((SOURCE/'DESIGN.json').read_text(encoding='utf-8'));mesh=geometry(design);frames,labels=poses(mesh,design)
    native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
    native.faces=[('atlas',tri) for _,tri in mesh.faces]
    binary,stats,bounds=md3(native,frames,{'atlas':MODEL_PATH+'/materials.png'})
    binary=binary[:8]+fixed('CA-FOLK-053 Cuero visual pilot',64)+binary[72:]
    actor=design['native']['class']
    model=[f'Model {actor}','{',f'    Path "{MODEL_PATH}"','    Model 0 "cuero.md3"','    Scale 1 1 1','    CorrectPixelStretch','    UseActorPitch']
    states=['// Piloto visual: sin física, captura, combate ni población autorizados.',f'class {actor} : Actor','{',
            f'    Default {{ RenderRadius {design["preview"]["render_radius"]}; +NOINTERACTION +NOGRAVITY }}','    States','    {','    Spawn:','        Goto Idle;']
    textures=[]
    for index,label in enumerate(labels):
        sprite=label['sprite'];letter=chr(65+label['sample']);action=label['action']
        model.append(f'    FrameIndex {sprite} {letter} 0 {index}')
        textures.append(f'Sprite "{sprite}{letter}0", 1, 1 {{ Patch "graphics/caelum/bull_invisible.png", 0, 0 }}')
        if label['sample']==0:states.append(f'    {action.title()}:')
        states.extend([f'    Frame{index}:',f'        {sprite} {letter} {label["tics"]};'])
        if label['sample']==design['motion'][action]['frames']-1:states.append(f'        Goto {action.title()};')
    states.extend(['    }','}']);model.append('}')
    output={MODEL_PATH+'/cuero.md3':binary,MODEL_PATH+'/materials.png':(SOURCE/'materials.png').read_bytes(),
            'ZSCRIPT':('version "4.14.2"\n'+'\n'.join(states)+'\n').encode(),
            'MODELDEF':('\n'.join(model)+'\n').encode(),'TEXTURES':('\n'.join(textures)+'\n').encode()}
    obj=['# CA-FOLK-053 reference-led neutral mesh; OBJ Y up, X forward.','mtllib cuero.mtl']
    obj.extend(f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]);obj.extend(f'vt {u:.6f} {1-v:.6f}' for u,v in mesh.uv)
    previous=None
    for material,tri in mesh.faces:
        if material!=previous:obj.append('usemtl '+material);previous=material
        obj.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
    output['cuero.obj']=('\n'.join(obj)+'\n').encode()
    output['cuero.mtl']=('\n'.join(f'newmtl {name}\nKd 1 1 1\nmap_Kd {MODEL_PATH}/materials.png' for name in design['atlas']['tiles'])+'\n').encode()
    manifest={'schema_revision':1,'issue':455,'catalogue_id':'CA-FOLK-053','status':'unintegrated_visual_pilot',
              'generator_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'shared_generator_sha256':{name:hashlib.sha256(Path(__file__).with_name(name).read_bytes()).hexdigest() for name in ['generate_nahuelito_model.py','generate_pombero_model.py']},
              'source_sha256':{name:hashlib.sha256((SOURCE/name).read_bytes()).hexdigest() for name in ['DESIGN.json','PROMPT.json','PROVENANCE.json','materials.png']},
              'vertices':len(mesh.vertices),'triangles':len(mesh.faces),'surfaces':stats,'frames':labels,'bounds':bounds,
              'sha256':{name:hashlib.sha256(blob).hexdigest() for name,blob in output.items()}}
    output['manifest.json']=(json.dumps(manifest,indent=2)+'\n').encode()
    return output


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--check',action='store_true')
    args=parser.parse_args();target=args.output.resolve();files=output_files()
    for name,blob in files.items():
        path=target/name
        if args.check:
            if not path.is_file() or path.read_bytes()!=blob:raise SystemExit('Stale Cuero output: '+name)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(target/'preview.pk3','w',zipfile.ZIP_DEFLATED) as package:
            for name,blob in sorted(files.items()):
                if name.endswith(('.obj','.mtl','.json')):continue
                package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    print(json.dumps({'files':len(files),'output':str(target),'checked':args.check}))


if __name__=='__main__':main()
