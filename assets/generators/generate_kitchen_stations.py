"""Register painted kitchen sprites and original deterministic furniture meshes."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode=True
from PIL import Image
from generate_stash_models import Mesh, WOOD, LOCK
METAL="models/caelum/props/kitchen/iron-painted-v1.png"
BRASS="models/caelum/props/stations/ca_station_brass.png"

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/art_source/kitchen_stations'
DATA=json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
U=DATA['map_units_per_meter']

def box(mesh,material,center,size):
    mesh.add_box(material,tuple(v*U for v in center),tuple(v*U for v in size))

def ring(mesh,material,radius,height,center=(0,0),sides=24):
    for i in range(sides):
        points=[]
        for a,r in [(i,radius),(i+1,radius),(i+1,radius*.90),(i,radius*.90)]:
            angle=2*math.pi*a/sides
            points.append(((center[0]+math.cos(angle)*r)*U,height*U,(center[1]+math.sin(angle)*r)*U))
        mesh.add_quad(material,points)

def cooker(stove):
    mesh=Mesh();t=DATA['iron_shell_m']
    # Hollow shell, not a solid block of iron.
    for x in [-.347,.347]:box(mesh,METAL,(x,.475,0),(t,.65,.65))
    for z in [-.322,.322]:box(mesh,METAL,(0,.475,z),(.688,.65,t))
    for y in [.153,.797]:box(mesh,METAL,(0,y,0),(.688,t,.638))
    for x in [-.29,.29]:
        for z in [-.265,.265]:box(mesh,METAL,(x,.075,z),(.045,.15,.045))
    if stove:
        for x in [-.17,.17]:
            ring(mesh,LOCK,.13,.801,(x,0));ring(mesh,METAL,.085,.802,(x,0))
            box(mesh,METAL,(x,.47,.332),(.27,.40,.014))
            box(mesh,BRASS,(x,.47,.35),(.10,.02,.022))
            for edge in [-.12,.12]:box(mesh,LOCK,(x+edge,.47,.344),(.012,.37,.006))
            for edge in [.285,.655]:box(mesh,LOCK,(x,edge,.344),(.24,.012,.006))
    else:
        box(mesh,METAL,(0,.48,.333),(.59,.48,.016))
        for x in [-.27,.27]:box(mesh,LOCK,(x,.48,.346),(.012,.43,.006))
        for y in [.265,.695]:box(mesh,LOCK,(0,y,.346),(.55,.012,.006))
        box(mesh,BRASS,(0,.48,.36),(.30,.025,.025))
    box(mesh,METAL,(0,.22,.337),(.52,.075,.018))
    box(mesh,BRASS,(0,.22,.352),(.12,.015,.02))
    # Open rear flue: simple segmented tube with visible rim.
    for i in range(20):
        a,b=2*math.pi*i/20,2*math.pi*(i+1)/20
        points=[((.20+.06*math.cos(v))*U,y*U,(-.22+.06*math.sin(v))*U) for v,y in [(a,.8),(b,.8),(b,1.08),(a,1.08)]]
        mesh.add_quad(METAL,points)
    ring(mesh,LOCK,.06,1.08,(.20,-.22))
    area=2*(.65*.65+.688*.65+.688*.638)
    kg=(area*t+4*.045*.045*.15+2*math.pi*.06*.28*.002)*DATA['iron_density_kg_m3']
    # Door/trim mass is explicitly included in the design approximation.
    kg+=(.59*.48*.016+.52*.075*.018)*DATA['iron_density_kg_m3']
    return mesh,round(kg,3)

def counter():
    mesh=Mesh();volume=0
    def wood(center,size):
        nonlocal volume
        box(mesh,WOOD,center,size);volume+=math.prod(size)
    wood((0,.83,0),(1.8,.04,.7))
    wood((0,.16,0),(1.65,.02,.55))
    for x in [-.79,.79]:
        for z in [-.25,.25]:wood((x,.405,z),(.07,.81,.07))
    for z in [-.30,.30]:wood((0,.72,z),(1.65,.18,.02))
    for x in [-.82,.82]:wood((x,.72,0),(.02,.18,.60))
    for x in [-.405,.405]:
        wood((x,.72,.32),(.77,.15,.02));box(mesh,LOCK,(x,.72,.34),(.025,.025,.025))
    # Fixed kneading vessel, empty in world until the actual batch exists.
    wood((0,.86,0),(.65,.02,.34))
    for x in [-.335,.335]:wood((x,.955,0),(.02,.19,.38))
    for z in [-.18,.18]:wood((0,.955,z),(.65,.19,.02))
    return mesh,round(volume*DATA['wood_density_kg_m3'],3)

def main():
    folder=ROOT/'src/models/caelum/props/kitchen';folder.mkdir(parents=True,exist_ok=True)
    icons=ROOT/'src/graphics/caelum/icons/kitchen_stations';icons.mkdir(parents=True,exist_ok=True)
    iron=folder/'iron-painted-v1.png'
    Image.open(ART/'iron-painted-v1.png').convert('RGB').resize((256,256),Image.Resampling.LANCZOS).save(iron)
    models=[];textures=[];records=[];outputs=[iron]
    code=['// #410: generated from kitchen_stations/DATA.json; dimensions and placements.','class CaelumKitchenFurnitureData : Object','{','    const REVISION=1;','    const COUNT=3;']
    rows=DATA['stations']
    for row in rows:
        key=row['key'];mesh,mass=counter() if key=='counter' else cooker(key=='stove')
        model=folder/(key+'.obj');mesh.write(model);outputs.append(model)
        im=Image.open(ART/(key+'.png')).convert('RGBA');im.putalpha(im.getchannel('A').point(lambda a:255 if a>=128 else 0))
        cut=im.crop(im.getbbox());cut.thumbnail((116,116),Image.Resampling.LANCZOS)
        icon=Image.new('RGBA',(128,128));icon.alpha_composite(cut,((128-cut.width)//2,122-cut.height))
        icon.putalpha(icon.getchannel('A').point(lambda a:255 if a>=128 else 0))
        path=icons/(key+'.png');icon.save(path);outputs.append(path)
        bounds=icon.getbbox();size=row['size_m'];scale=max((bounds[2]-bounds[0])/(max(size[:2])*U),(bounds[3]-bounds[1])/(size[2]*U))
        textures.append(f'Sprite {row["sprite"]}A0,128,128 {{ XScale {scale:.6f} YScale {scale:.6f} Offset 64,122 Patch "graphics/caelum/icons/kitchen_stations/{key}.png",0,0 }}')
        models.append(f'Model {row["class"]} {{ Path "models/caelum/props/kitchen" Model 0 "{key}.obj" Scale 1 1 1 AngleOffset -90 CorrectPixelStretch DontCullBackFaces FrameIndex {row["sprite"]} A 0 0 }}')
        records.append({'key':key,'mass_kg':mass,'vertices':len(mesh.vertices),'bounds_mu':[[min(v[i] for v in mesh.vertices),max(v[i] for v in mesh.vertices)] for i in range(3)]})
    def function(kind,name,values):
        code.append(f'    static clearscope {kind} {name}(int id)')
        code.append('    {return '+''.join(f'id=={i}?{v}:' for i,v in enumerate(values[:-1]))+values[-1]+';}')
    function('Name','ActorClass',["'"+r['class']+"'" for r in rows])
    function('Vector3','Position',['('+','.join(map(str,r['position']))+')' for r in rows])
    function('double','Facing',[str(r['facing']) for r in rows])
    function('double','Radius',[str(max(r['size_m'][:2])*U/2) for r in rows])
    function('double','Height',[str(r['size_m'][2]*U) for r in rows])
    function('double','MassKg',[str(r['mass_kg']) for r in records]);code.append('}')
    for name,lines in [('kitchen_stations.modeldef',models),('kitchen_stations.textures',textures),('CaelumKitchenFurnitureData.zs',code)]:
        path=ROOT/'src/caelum/data'/name;path.write_text('\n'.join(lines)+'\n',encoding='utf-8');outputs.append(path)
    manifest={'issue':410,'records':records,'sha256':{str(p.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(p.read_bytes()).hexdigest() for p in outputs}}
    (ART/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(records))
if __name__=='__main__':main()
