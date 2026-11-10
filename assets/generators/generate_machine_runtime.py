"""Generate #449 repair materials and an owned barricade from approved geometry."""
from pathlib import Path
import json
from generate_ram_runtime import component_volumes, DATA, U
from generate_siege_models import Mesh, add_box, WOOD, IRON

ROOT=Path(__file__).resolve().parents[2]

def generate():
    work=json.loads(Path(__file__).with_name('machine_work.json').read_text(encoding='utf-8'))
    barrier=work['barricade'];cannon=work['cannon']
    moving_wood,moving_iron,frame_wood,frame_iron=component_volumes()
    wood=(moving_wood+frame_wood)*DATA['oak_kg_m3']/U**3*1000
    iron=(moving_iron+frame_iron)*DATA['iron_kg_m3']/U**3*1000
    thickness=barrier['wood_kg']/DATA['oak_kg_m3']/barrier['width_m']/barrier['height_m']*U
    values=dict(SMALL_RAM_WOOD_GRAMS=wood,SMALL_RAM_IRON_GRAMS=iron,
        BARRICADE_WIDTH=barrier['width_m']*U,BARRICADE_HEIGHT=barrier['height_m']*U,
        BARRICADE_THICKNESS=thickness,BARRICADE_MASS=barrier['wood_kg']+barrier['iron_kg'],
        BARRICADE_WOOD_GRAMS=barrier['wood_kg']*1000,BARRICADE_IRON_GRAMS=barrier['iron_kg']*1000,
        CANNON_WOOD_GRAMS=cannon['wood_kg']*1000,CANNON_IRON_GRAMS=cannon['iron_kg']*1000,
        BARRICADE_SECONDS=barrier['work_seconds'],CANNON_SECONDS=cannon['work_seconds'],
        SMALL_RAM_SECONDS=work['small_ram_repair_seconds'],LARGE_RAM_SECONDS=work['large_ram_repair_seconds'],
        CAPTURE_SECONDS=work['capture_seconds'],SABOTAGE_SECONDS=work['sabotage_seconds'],
        SABOTAGE_REPAIR_FRACTION=work['sabotage_repair_fraction'])
    material_source='\n'.join([
        '// Generado desde las mismas piezas y densidades de ram_physics.json.',
        'class CaelumMachineMaterials : Object','{',
        *[f'    const {key}={value if isinstance(value,int) else format(value,".12f")};' for key,value in values.items()],'}',''])
    (ROOT/'src/caelum/data/CaelumMachineMaterials.zs').write_text(material_source,encoding='utf-8',newline='\n')
    mesh=Mesh('ca_barricade')
    # A full wooden panel carries the exact approved wood volume. Surface bands
    # reuse the owned iron texture; their drawing is not a new resistance model.
    width=values['BARRICADE_WIDTH'];height=values['BARRICADE_HEIGHT']
    add_box(mesh,WOOD,(0,height/2,0),(width,height,thickness))
    for side in (-1,1):
        add_box(mesh,IRON,(side*width*43/96,height/2,0),(width/32,height,thickness))
    mesh.write(ROOT/'src/models/caelum/siege/ca_barricade.obj')
    path=ROOT/'src/MODELDEF';text=path.read_text(encoding='utf-8')
    begin='// BEGIN GENERATED BARRICADE';end='// END GENERATED BARRICADE'
    if begin in text:
        prefix,rest=text.split(begin,1);_,suffix=rest.split(end,1)
    else:prefix,suffix=text.rstrip()+'\n\n','\n'
    binding='\n'.join([begin,'Model CaelumBarricadeVisual','{',
        '    Path "models/caelum/siege"','    Model 0 "ca_barricade.obj"',
        '    Scale 1 1 1','    CorrectPixelStretch','    DontCullBackFaces',
        '    FrameIndex CAGT A 0 0','    FrameIndex CAGT B 0 0','}',end])
    path.write_text(prefix+binding+suffix,encoding='utf-8',newline='\n')
    print(json.dumps(dict(small_ram_wood_kg=wood/1000,small_ram_iron_kg=iron/1000,
        barricade_thickness_mu=thickness)))

if __name__=='__main__':generate()
