"""Build deterministic owned 3D plants, hive and resource bundles for #405."""
from pathlib import Path
import json
import math
import sys

ROOT = Path(__file__).resolve().parents[2]
# The workspace-local optional dependency installation is not packaged.
if (ROOT / 'build/python_deps').is_dir():
    sys.path.insert(0, str(ROOT / 'build/python_deps'))
from generate_environment_models import Mesh

OUT = ROOT / 'src/models/caelum/world/land_resources'
GREEN = 'models/caelum/world/environment/foliage_plains.png'
WOOD = 'models/caelum/props/stations/ca_station_wood.png'
YELLOW = 'models/caelum/props/stations/ca_station_wax.png'
WHITE = 'models/caelum/props/stations/ca_station_paper.png'
PURPLE = 'models/caelum/props/stations/ca_station_gem.png'


def ball(mesh, material, center, radii, seed=405):
    mesh.add_ellipsoid(material, center, radii, seed, rings=3, segments=6, irregularity=0)


def plant(key, bundle=False):
    mesh = Mesh('ca_resource_' + key + ('_bundle' if bundle else ''))
    if key == 'honey':
        if bundle:
            mesh.add_frustum(YELLOW, (0,0,0), (0,9,0), 4, 3.5, sides=10)
            mesh.add_frustum(WOOD, (0,9,0), (0,10,0), 3.7, 3.7, sides=10)
        else:
            mesh.add_frustum(WOOD, (0,1,0), (0,29,0), 13, 10, sides=12)
            mesh.add_frustum(WOOD, (0,29,0), (0,34,0), 14, 8, sides=12)
            for i in range(7):
                a=math.tau*i/6
                x,y=(0,15) if i==6 else (math.cos(a)*4,15+math.sin(a)*4)
                mesh.add_frustum(YELLOW,(x,y,-12),(x,y,-14),2.4,2.4,sides=6)
                mesh.add_frustum(WOOD,(x,y,-14),(x,y,-14.1),1.1,1.1,sides=6)
        return mesh
    if key=='irupe_flower' and not bundle:
        mesh.add_frustum(GREEN,(0,1,0),(0,2,0),18,18,sides=16)
        mesh.add_frustum(GREEN,(0,2,0),(0,9,0),.5,.3,sides=5)
        for i in range(10):
            a=math.tau*i/10
            ball(mesh,WHITE,(math.cos(a)*4,9,math.sin(a)*4),(2.7,1.4,2.7),405+i)
        ball(mesh,YELLOW,(0,10,0),(2,2,2))
        return mesh
    stems = 3 if bundle else (7 if key=='fiber_bush' else 5)
    for i in range(stems):
        a=math.tau*i/stems
        radius=1.4 if bundle else 6
        x,z=math.cos(a)*radius,math.sin(a)*radius
        height=(8+i%3) if bundle else (24+3*(i%4))
        if key=='sugarcane':height*=1.3
        mesh.add_frustum(GREEN if key!='yerba_mate' else WOOD,(x,0,z),(x,height,z),.65,.35,sides=5)
        for leaf in range(3):
            angle=a+leaf*2.1
            length=2.3 if bundle else 5.5
            cx=x+math.cos(angle)*length/2;cz=z+math.sin(angle)*length/2
            cy=height*(.35+.18*leaf)
            ball(mesh,GREEN,(cx,cy,cz),(length,.35,length*.4),405+i*3+leaf)
        if key=='marcela':
            for j in range(3):
                angle=a+j*math.tau/3
                ball(mesh,YELLOW,(x+math.cos(angle)*1.5,height,z+math.sin(angle)*1.5),(1.2,1.3,1.2),420+i*3+j)
        elif key in ('cypella_flower','irupe_flower'):
            for j in range(3 if key=='cypella_flower' else 6):
                angle=a+j*math.tau/(3 if key=='cypella_flower' else 6)
                ball(mesh,YELLOW if key=='cypella_flower' else WHITE,
                     (x+math.cos(angle)*2,height,z+math.sin(angle)*2),(2,1,2),440+i*3+j)
            ball(mesh,PURPLE if key=='cypella_flower' else YELLOW,(x,height+1,z),(.8,1,.8))
        elif key=='cotton':
            for j in range(3):
                ball(mesh,WHITE,(x+math.cos(a+j*2)*2,height-j*2,z+math.sin(a+j*2)*2),(2,2,2),460+i*3+j)
        elif key=='yerba_mate':
            ball(mesh,GREEN,(x,height,z),(3,2,3),480+i)
        elif key=='fiber_bush':
            ball(mesh,GREEN,(x,height-2,z),(6,5,6),500+i)
            ball(mesh,GREEN,(x*.7,height*.65,z*.7),(5,4,5),520+i)
        elif key=='sugarcane':
            for j in range(1,5):
                y=height*j/5
                mesh.add_frustum(WOOD,(x,y,z),(x,y+.35,z),.75,.75,sides=5)
    return mesh


def main():
    data=json.loads((Path(__file__).with_name('land_resources.json')).read_text(encoding='utf-8'))
    catalog=json.loads((Path(__file__).with_name('resource_catalog.json')).read_text(encoding='utf-8'))
    OUT.mkdir(parents=True,exist_ok=True)
    definitions=['// Modelos 3D propios, generados para #405.']
    records=[]
    def emit(key,bundle=False):
        mesh=plant(key,bundle);filename=key+('_bundle' if bundle else '')+'.obj'
        mesh.write(OUT/filename)
        records.append({'key':key,'bundle':bundle,'file':filename,'vertices':len(mesh.vertices),'faces':len(mesh.faces)})
        return filename
    def define(actor,sprite,filename,scale=1):
        definitions.extend([f'Model {actor}','{','    Path "models/caelum/world/land_resources"',
            f'    Model 0 "{filename}"',f'    Scale {scale} {scale} {scale}',
            '    CorrectPixelStretch','    DontCullBackFaces',f'    FrameIndex {sprite} A 0 0','}'])
    for row in catalog['sources']:
        key=row['key'];name='CaelumSource'+''.join(w.title() for w in key.split('_'))
        filename=emit(key)
        define(name,'CFBH',filename)
        if any(p['key']==key and p['decorative'] for p in data['placements']):define(name+'Decoration','CFBH',filename)
        if key in data['new_material_ids']:
            filename=emit(key,True)
            define('CaelumMaterialPickup',f'M{data["new_material_ids"][key]:03d}',filename,4)
    filename=emit('fiber_bush')
    for actor in ['CaelumFiberBush','CaelumMansionSceneryShrub']:
        define(actor,'CFBH',filename,20)
    (ROOT/'src/caelum/data/land_resources.modeldef').write_text('\n'.join(definitions)+'\n',encoding='utf-8')
    textures=['// Alias de reserva; la representación normal de estos materiales es 3D.']
    for key,number in data['new_material_ids'].items():
        icon='wood' if key=='sugarcane' else 'plant_fiber'
        textures.append(f'Sprite "M{number:03d}A0", 128, 128 {{ Offset 64, 128 Patch "graphics/caelum/icons/materials/ca_material_{icon}.png", 0, 0 }}')
    (ROOT/'src/caelum/data/land_resources.textures').write_text('\n'.join(textures)+'\n',encoding='utf-8')
    manifest={'issue':405,'provenance':'Original deterministic geometry by the project; only existing owned project textures are referenced.',
              'textures':[GREEN,WOOD,YELLOW,WHITE,PURPLE],'models':records}
    (Path(__file__).with_name('land_resource_models.json')).write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(f'Generated {len(records)} owned 3D meshes and {len(definitions)} MODELDEF lines.')


if __name__=='__main__':
    main()
