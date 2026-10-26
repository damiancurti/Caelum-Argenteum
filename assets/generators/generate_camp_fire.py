"""Build original campfire meshes using owned wood/ember textures, without raster edits."""
from pathlib import Path
import hashlib
import json
import math
import struct
import sys
sys.dont_write_bytecode = True
from generate_environment_models import Mesh
from generate_camp_tent import constant

ROOT = Path(__file__).resolve().parents[2]
CONFIG = Path(__file__).with_name('camp_fire_art.json')
DEST = ROOT/'src/models/caelum/world/camp'

def main():
    data = json.loads(CONFIG.read_text(encoding='utf-8'))
    art = data['visual_only']; materials = data['materials']
    atlas=json.loads((ROOT/'assets/source/art/elemental_518/DESIGN.json').read_text(encoding='utf-8'))
    atlas_height=struct.unpack('>II',(ROOT/'src'/materials['ember']).read_bytes()[16:24])[1]
    diameter = constant(data['physical_source'], 'FIRE_DIAMETER_M')
    height = constant(data['physical_source'], 'FIRE_HEIGHT_M')
    units = constant(data['units_source'], 'MAP_UNITS_PER_METER')
    result = {}
    for index in range(10):
        frame=index%5
        mesh = Mesh('CaelumCampFire')
        radius = diameter*art['log_radius_fraction']
        length = diameter*art['log_length_fraction']/2
        for i in range(art['log_count']):
            angle = i*math.tau/art['log_count']
            x,z = math.cos(angle)*length,math.sin(angle)*length
            mesh.add_frustum(materials['wood'],(-x,radius,-z),(x,2*radius,z),radius,radius*.8,art['log_sides'])
        if frame:
            for i in range(art['flame_count']):
                angle = i*math.tau/art['flame_count'] + frame*.17
                offset = diameter*.38 if index>=5 else diameter*.18 if i else 0
                x,z = math.cos(angle)*offset,math.sin(angle)*offset
                tip = height if i==0 else height*(.62+.14*math.sin(i+frame))
                half = diameter*(.07 if index>=5 else .12)
                for turn in (0, math.pi/2):
                    dx,dz=math.cos(angle+turn)*half,math.sin(angle+turn)*half
                    first,last=atlas['breath_rows'][frame-1:frame+1]
                    v1,v2=1-first/atlas_height,1-last/atlas_height
                    mesh.add_polygon(materials['ember'],((x-dx,radius,z-dz),(x+dx,radius,z+dz),(x+dx*.3,tip,z+dz*.3),(x-dx*.3,tip,z-dz*.3)),((.92,v1),(.92,v2),(.20,v2),(.20,v1)))
        if index>=5:
            r=constant(data['physical_source'],'POT_DIAMETER_M')/2
            wall=constant(data['physical_source'],'POT_WALL_M')
            depth=constant(data['physical_source'],'POT_LITERS')/1000/(math.pi*r*r)
            bottom=3*radius;top=bottom+depth+wall
            mesh.add_frustum(materials['iron'],(0,bottom,0),(0,top,0),r+wall,r+wall,16,True,False)
            mesh.add_frustum(materials['iron'],(0,bottom+wall,0),(0,top,0),r,r,16,True,False)
            for i in range(16):
                a=i*math.tau/16;b=(i+1)*math.tau/16
                mesh.add_quad(materials['iron'],((math.cos(a)*r,top,math.sin(a)*r),(math.cos(b)*r,top,math.sin(b)*r),(math.cos(b)*(r+wall),top,math.sin(b)*(r+wall)),(math.cos(a)*(r+wall),top,math.sin(a)*(r+wall))))
            for sign in (-1,1):
                for i in range(8):
                    a=i*math.pi/8;b=(i+1)*math.pi/8
                    mesh.add_frustum(materials['iron'],(sign*(r+wall+math.sin(a)*r/3),top-depth/3,math.cos(a)*r/3),(sign*(r+wall+math.sin(b)*r/3),top-depth/3,math.cos(b)*r/3),wall*2,wall*2,5)
        mesh.vertices=[(x*units,y*units*art['pixel_stretch_compensation'],z*units) for x,y,z in mesh.vertices]
        mesh.faces.sort(key=lambda entry:entry[0])
        path=DEST/f'fire_{index}.obj';mesh.write(path)
        result[str(path.relative_to(ROOT)).replace('\\','/')]=hashlib.sha256(path.read_bytes()).hexdigest()
    manifest={
        'issue':411,'generator':str(Path(__file__).relative_to(ROOT)).replace('\\','/'),
        'configuration':str(CONFIG.relative_to(ROOT)).replace('\\','/'),
        'dimensions_m':{'diameter':diameter,'flame_height':height},
        'physical_source':data['physical_source'],
        'materials':{path:hashlib.sha256((ROOT/'src'/path).read_bytes()).hexdigest() for path in materials.values()},
        'models':result,'provenance':'Original procedural geometry; existing project-owned station/stash textures and author-accepted #137 breath atlas, unchanged pixels and measured row boundaries. Visual segmentation has no balance effect.',
        'author_visual_acceptance':'Pending; author away.'
    }
    (ROOT/'assets/art_source/camp_equipment/FIRE_MODEL.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()
