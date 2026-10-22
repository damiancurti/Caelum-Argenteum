"""Build owned, deterministic 3D dried kelp bundles and iodine containers."""
from pathlib import Path
import json
import math
from generate_environment_models import Mesh

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'src/models/caelum/world/marine_resources'
WOOD = 'models/caelum/props/stations/ca_station_wood.png'
PAPER = 'models/caelum/props/stations/ca_station_paper.png'
IRON = 'models/caelum/props/stations/ca_station_iron.png'
GEM = 'models/caelum/props/stations/ca_station_gem.png'


def kelp():
    mesh = Mesh('ca_dried_cachiyuyo')
    for leaf in range(7):
        x = (leaf-3)*1.25
        z = math.sin(leaf*2.1)*1.4
        mesh.add_frustum(WOOD, (x,0,z), (x,3,z), .25, .2, sides=5)
        # Each blade has thickness, four sides and a closed tip.
        rings = []
        for level in range(7):
            y = 2+level*(1.2+leaf%3*.1)
            cx = x+math.sin(level*.9+leaf)*.7
            cz = z+math.sin(level*1.3+leaf)*.6
            width = .15 if level==6 else (.7+math.sin(level*.6)*.4)
            rings.append([(cx-width,y,cz-.14),(cx+width,y,cz-.14),
                          (cx+width,y,cz+.14),(cx-width,y,cz+.14)])
        for a,b in zip(rings,rings[1:]):
            for i in range(4): mesh.add_quad(WOOD,[a[i],a[(i+1)%4],b[(i+1)%4],b[i]])
        mesh.add_quad(WOOD,rings[-1])
    mesh.add_frustum(PAPER, (0,3,0), (0,3.5,0), 4.7,4.7,sides=12)
    return mesh


def iodine():
    mesh = Mesh('ca_iodine_container')
    mesh.add_frustum(IRON,(0,0,0),(0,5.5,0),3,3,sides=12)
    mesh.add_frustum(IRON,(0,5.5,0),(0,7,0),3,1.4,sides=12)
    mesh.add_frustum(IRON,(0,7,0),(0,8.5,0),1.4,1.4,sides=10)
    mesh.add_frustum(WOOD,(0,8.5,0),(0,9.4,0),1.5,1.5,sides=10)
    mesh.add_frustum(PAPER,(0,1.8,0),(0,4.2,0),3.04,3.04,sides=12)
    # A violet diamond identifies the abstract material without medical claims.
    mesh.add_quad(GEM,[(0,2.1,-3.08),(1,3,-3.08),(0,3.9,-3.08),(-1,3,-3.08)])
    return mesh


def main():
    OUT.mkdir(parents=True,exist_ok=True)
    definitions=['// Geometría propia #407; cada material se representa en 3D.']
    textures=['// Alias de reserva del material; MODELDEF define su representación 3D.']
    records=[]
    data=json.loads(Path(__file__).with_name('marine_resources.json').read_text(encoding='utf-8'))
    icons={row['id']:row['icon'] for row in data['materials']}
    for key,number,mesh in [('dried_kelp',87,kelp()),('iodine',88,iodine())]:
        icon=icons[number]
        mesh.write(OUT/f'{key}.obj')
        definitions += ['Model CaelumMaterialPickup','{','    Path "models/caelum/world/marine_resources"',
                        f'    Model 0 "{key}.obj"','    Scale 4 4 4','    CorrectPixelStretch',
                        '    DontCullBackFaces',f'    FrameIndex M{number:03d} A 0 0','}']
        textures += [f'Sprite "M{number:03d}A0", 128, 128 {{ Offset 64, 128 Patch "graphics/caelum/icons/materials/ca_material_{icon}.png", 0, 0 }}']
        records.append({'file':f'{key}.obj','vertices':len(mesh.vertices),'faces':len(mesh.faces)})
    for extension,lines in [('modeldef',definitions),('textures',textures)]:
        (ROOT/f'src/caelum/data/marine_resources.{extension}').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    manifest={'issue':407,'provenance':'Original deterministic project geometry; existing owned project textures. Icon paths follow marine_resources.json; #471 renders iodine from the accepted mesh.',
              'textures':[WOOD,PAPER,IRON,GEM],'models':records}
    Path(__file__).with_name('marine_models.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Generated two owned 3D marine-material models.')


if __name__=='__main__':main()
