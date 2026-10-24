"""Generate the original A-frame tent mesh from approved dimensions and owned textures."""
from pathlib import Path
import hashlib
import json
import math
import re
import sys

sys.dont_write_bytecode=True
from generate_environment_models import Mesh

ROOT=Path(__file__).resolve().parents[2]
CONFIG=Path(__file__).with_name('camp_tent_art.json')
DEST=ROOT/'src/models/caelum/world/camp'
MANIFEST=ROOT/'assets/art_source/camp_equipment/TENT_MODEL.json'


def constant(path,name):
    text=(ROOT/path).read_text(encoding='utf-8')
    match=re.search(r'\bconst\s+'+re.escape(name)+r'\s*=\s*([0-9.]+)\s*;',text)
    if not match:raise ValueError(f'Missing numeric authoritative constant: {name}')
    return float(match.group(1))


def main():
    data=json.loads(CONFIG.read_text(encoding='utf-8'))
    visual=data['visual_only'];mat=data['materials']
    for path in mat.values():
        if not (ROOT/'src'/path).is_file():raise FileNotFoundError(path)
    width=constant(data['physical_source'],'TENT_WIDTH_M')
    length=constant(data['physical_source'],'TENT_LENGTH_M')
    height=constant(data['physical_source'],'TENT_HEIGHT_M')
    units=constant(data['units_source'],'MAP_UNITS_PER_METER')
    mesh=Mesh('CaelumCampTentDeployed')
    w=width/2;l=length/2;h=height
    def rod(kind,start,end,radius,sides=6):
        mesh.add_frustum(mat[kind],start,end,radius,radius,sides)
    # Keep texture surfaces grouped for the native OBJ loader.
    count=visual['roof_panels']
    for side in (-1,1):
        for segment in range(count):
            z=-l+length*segment/count;nz=-l+length*(segment+1)/count
            midpoint=(z+nz)/2
            a=(0,h,z);b=(0,h,nz);c=(side*w,0,nz);d=(side*w,0,z)
            mid=(side*w/2,h/2-visual['canvas_sag_m'],midpoint)
            for triangle in ((a,b,mid),(b,c,mid),(c,d,mid),(d,a,mid)):
                mesh.add_triangle(mat['canvas'],triangle)
        for segment in range(count+1):
            z=-l+length*segment/count
            rod('canvas_dark',(0,h-0.001,z),(side*w,0.001,z),visual['seam_radius_m'],4)
    floor=visual['groundsheet_offset_m']
    mesh.add_quad(mat['canvas_dark'],((-w,floor,-l),(w,floor,-l),(w,floor,l),(-w,floor,l)))
    mesh.add_triangle(mat['canvas'],((-w,0,-l),(0,h,-l),(w,0,-l)))
    # Two folded front flaps frame the entrance without sealing its middle.
    flap=visual['flap_fold_fraction']
    for side in (-1,1):
        mesh.add_triangle(mat['canvas'],((side*w,0,l),(0,h,l),(side*w*(1-flap),0,l-flap)))
        rod('canvas_dark',(side*w*(1-flap),0,l-flap),(0,h,l),visual['seam_radius_m'],4)
        for z in (-l,l):
            radius=visual['pole_radius_m']
            inset=z*(1-radius/l)
            rod('wood',(side*(w-radius),radius,inset),(0,h-radius,inset),radius)
            rod('iron',(side*(w-0.02),0,z*(1-0.02)),
                (side*(w-0.02),visual['stake_height_m'],z*(1-0.02)),visual['stake_radius_m'])
            rod('rope',(side*w/2,h/2,z*0.5),(side*(w-0.02),0.02,z*(1-0.02)),visual['rope_radius_m'],4)
    rod('wood',(0,h-visual['pole_radius_m'],-l),(0,h-visual['pole_radius_m'],l),visual['pole_radius_m'])
    # The model compensates native pixel stretch exactly as existing vehicles.
    stretch=visual['pixel_stretch_compensation']
    mesh.vertices=[(x*units,y*units*stretch,z*units) for x,y,z in mesh.vertices]
    mesh.faces.sort(key=lambda entry:entry[0])
    DEST.mkdir(parents=True,exist_ok=True)
    output=DEST/'tent.obj';mesh.write(output)
    manifest={
        'issue':411,'generator':'assets/generators/generate_camp_tent.py',
        'configuration':str(CONFIG.relative_to(ROOT)).replace('\\','/'),
        'physical_source':data['physical_source'],'units_source':data['units_source'],
        'dimensions_m':{'width':width,'length':length,'ridge_height':height},
        'canvas_area_m2_closed':width*length+2*length*math.hypot(w,h)+width*h,
        'vertices':len(mesh.vertices),'faces':len(mesh.faces),
        'materials':{path:hashlib.sha256((ROOT/'src'/path).read_bytes()).hexdigest() for path in sorted(mat.values())},
        'model':str(output.relative_to(ROOT)).replace('\\','/'),
        'model_sha256':hashlib.sha256(output.read_bytes()).hexdigest(),
        'native_registration':'CaelumDeployedTent in src/MODELDEF; private gallery retains independent visual evidence.',
        'author_visual_acceptance':'Pending; author away.'
    }
    MANIFEST.write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'vertices':len(mesh.vertices),'faces':len(mesh.faces),'sha256':manifest['model_sha256']}))


if __name__=='__main__':
    main()
