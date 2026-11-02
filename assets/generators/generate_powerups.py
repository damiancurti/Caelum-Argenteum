"""Deterministic #614 placements and original model geometry; no bitmap edits."""
from pathlib import Path
import hashlib
import json
import math
import re
import sys
sys.dont_write_bytecode=True
from generate_arenas import maze_cells
from generate_environment_models import Mesh

ROOT=Path(__file__).resolve().parents[2]

def box(mesh,material,center,size):
    x,y,z=center;a,b,c=(v/2 for v in size)
    v=[(x+dx*a,y+dy*b,z+dz*c) for dx,dy,dz in
       ((-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1))]
    for face in ((0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5)):
        mesh.add_quad(material,[v[i] for i in face])

def generate():
    data=json.loads((ROOT/'assets/powerups/DATA.json').read_text())
    visual=data['visual'];material=visual['emblem']
    for name in ('silver','gold','emblem'):
        assert (ROOT/'src'/visual[name]).is_file(),visual[name]
    points={}
    for name,count in data['maps'].items():
        if name=='CASEWER':
            venue=json.loads((ROOT/'assets/arenas/VENUES.json').read_text())['venues'][1]
            cell=venue['passage_m']*32;size=venue['size_m']//venue['passage_m']
            cells=maze_cells(size,venue['seed']);excluded={(int(x/cell),int(y/cell)) for x,y,_ in venue['starts']}
        else:
            source=(ROOT/'src/caelum/data/CaelumHuntData.zs').read_text()
            size=int(re.search(r'const GRID=(\d+)',source)[1]);cell=int(re.search(r'const CELL=(\d+)',source)[1])
            nodes=[int(x) for x in re.search(r'GridNode.*?data\[\]=\{([^}]+)',source,re.S)[1].split(',')]
            cells={(i%size,i//size) for i,n in enumerate(nodes) if n>=0}
            report=json.loads((ROOT/'assets/hunt/GENERATED.json').read_text())
            excluded={tuple(p) for p in report['essences']}
            for t in report['traps']:
                cx,cy=t['cell'];excluded.update((x,y) for x in range(cx-2,cx+2) for y in range(cy-2,cy+2))
            excluded.update((x,y) for x,y in cells if (x<4 and y<4) or (x>=size-4 and y>=size-4))
        chosen=[];half=size//2
        for quarter in range(4):
            candidates=sorted(p for p in cells-excluded if p[0]//half+2*(p[1]//half)==quarter
                              and all((p[0]-q[0])**2+(p[1]-q[1])**2>4 for q in excluded))
            # Distance-only choice spreads sites, without new geometry or balance.
            local=[]
            for _ in range(count//4):
                p=max(candidates,key=lambda p:(min(((p[0]-q[0])**2+(p[1]-q[1])**2 for q in local),default=1),p))
                local.append(p);candidates.remove(p)
            chosen.extend(local)
        assert len(set(chosen))==count and all(p in cells for p in chosen)
        points[name]=[[int((x+.5)*cell),int((y+.5)*cell),0] for x,y in chosen]
    lines=['// #614: generado desde assets/powerups/DATA.json.','class CaelumPowerupData : Object','{']
    for i,name in enumerate(data['names']):lines.append(f'    const {name}={i};')
    for key,value in [('COMMON_PERCENT',data['common_percent']),('RESPAWN_TICS',data['respawn_seconds']*35),
                      ('REST_SECONDS',data['seated_seconds']),('SLEEP_SECONDS',data['sleep_seconds']),
                      ('MAX_TIER',data['max_tier']),('ANIMA_FRACTION',data['anima_fraction'])]:lines.append(f'    const {key}={value};')
    lines+=['    static clearscope int PointCount(){return level.MapName=="CASEWER"?8:level.MapName=="CAHUNT"?16:0;}',
            '    static clearscope String Key(int kind){static const String keys[]={'+','.join(json.dumps(n) for n in data['names'])+'};return kind>=0 && kind<6?keys[kind]:"REST";}',
            '    static clearscope vector3 Point(int index){switch((level.MapName=="CAHUNT"?8:0)+index){']
    for i,p in enumerate(points['CASEWER']+points['CAHUNT']):lines.append(f'        case {i}:return ({",".join(map(str,p))});')
    lines+=['    }return (0,0,0);}','}']
    (ROOT/'src/caelum/data/CaelumPowerupData.zs').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    target=ROOT/'src/models/caelum/powerups';target.mkdir(parents=True,exist_ok=True)
    models=[]
    for color in ('silver','gold'):
        mesh=Mesh('PowerupShell');r=visual['radius_mu'];y=visual['center_height_mu']
        mesh.add_ellipsoid(visual[color],(0,y,0),(r,r,r),614,visual['rings'],visual['segments'],0)
        models.append((color,mesh))
    for kind in range(6):
        mesh=Mesh('PowerupEmblem');y=visual['center_height_mu']
        if kind in (0,4):
            # Table/bed silhouettes with supporting legs; the bed has a pillow.
            box(mesh,material,(0,y,0),(17,2,11))
            for x,z in ((-7,-4),(7,-4),(-7,4),(7,4)):box(mesh,material,(x,y-4,z),(1.5,7,1.5))
            if kind==0:
                mesh.add_frustum(visual['gold'],(0,y+1,0),(0,y+6,0),2,1.5,12)
            else:
                box(mesh,visual['silver'],(-5,y+2,0),(4,2,9))
                box(mesh,material,(-8,y+4,0),(1.5,8,12))
        elif kind==1:
            for x in (-5,0):
                mesh.add_frustum(visual['gold'],(x,y-6,0),(x,y+4,0),1.5,1.5,12)
                mesh.add_frustum(visual['gold'],(x,y+4,0),(x,y+7,0),1.5,0,12)
            mesh.add_ellipsoid(material,(6,y,0),(3,7,3),614,2,6,0)
        elif kind==2:
            box(mesh,material,(-5,y+2,0),(2,14,1.5));box(mesh,visual['gold'],(-5,y-4,0),(7,1.5,2))
            box(mesh,material,(-5,y-7,0),(2,5,2));mesh.add_ellipsoid(visual['silver'],(5,y,0),(5,7,1.5),614,4,8,0)
        elif kind==3:
            mesh.add_frustum(material,(0,y-7,0),(0,y+5,0),5,7,8)
            mesh.add_ellipsoid(visual['silver'],(0,y+7,0),(4,4,4),614,4,8,0)
        else:
            box(mesh,material,(0,y-5,0),(12,3,7));box(mesh,material,(0,y-2,0),(5,5,5));box(mesh,material,(0,y+1,0),(17,3,7))
            for angle in (0,math.pi/2):
                mesh.add_frustum(visual['gold'],(-6*math.cos(angle),y+8-6*math.sin(angle),0),(6*math.cos(angle),y+8+6*math.sin(angle),0),.9,.9,8)
        models.append((f'emblem{kind}',mesh))
    for name,mesh in models:
        mesh.vertices=[(x,y*1.2,z) for x,y,z in mesh.vertices]
        mesh.write(target/f'{name}.obj')
        p=target/f'{name}.obj';p.write_text(p.read_text(encoding='utf-8'),encoding='utf-8',newline='\n')
    defs=[]
    for actor,names,sprite in [('CaelumLabyrinthPowerup',['silver','gold'],'CPU0'),('CaelumPowerupEmblem',[f'emblem{i}' for i in range(6)],'CPU1')]:
        defs += [f'Model {actor}','{','    Path "models/caelum/powerups"','    CorrectPixelStretch','    AngleOffset 0']
        for i,name in enumerate(names):defs.append(f'    Model {i} "{name}.obj"')
        # MODELDEF inherits other model slots between frames unless disabled.
        for frame in range(len(names)):
            for model in range(len(names)):
                defs.append(f'    FrameIndex {sprite} {chr(65+frame)} {model} {0 if model==frame else -1}')
        defs.append('}')
    (ROOT/'src/caelum/data/powerups.modeldef').write_text('\n'.join(defs)+'\n',encoding='utf-8',newline='\n')
    textures=[f'Sprite "{sprite}{chr(65+i)}0", 1, 1 {{ Patch "graphics/caelum/bull_invisible.png", 0, 0 }}' for sprite,n in [('CPU0',2),('CPU1',6)] for i in range(n)]
    (ROOT/'src/caelum/data/powerups.textures').write_text('\n'.join(textures)+'\n',encoding='utf-8',newline='\n')
    hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(target.glob('*.obj'))}
    (ROOT/'assets/powerups/GENERATED.json').write_text(json.dumps(dict(points=points,sha256=hashes),indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Generated 24 saved pickup points and eight original model meshes.')

if __name__=='__main__':generate()
