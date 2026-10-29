"""Build original period sofa geometry from delegated construction measurements."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode=True
from generate_stash_models import Mesh, WOOD, METAL, INSIDE

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/art_source/sofas'
DATA=json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
U=DATA['map_units_per_meter']

def sofa(row):
    mesh=Mesh()
    volumes={WOOD:0.0,METAL:0.0}
    cloth=0.0
    w,d,h=[row[k] for k in ('width_m','depth_m','height_m')]
    f=DATA['frame_m'];leg=DATA['leg_m'];arm=DATA['arm_width_m']
    top=DATA['seat_top_m'];board=DATA['seat_board_m'];back=DATA['back_board_m']
    def part(material,center,size):
        if material in volumes:volumes[material]+=math.prod(size)
        mesh.add_box(material,tuple(v*U for v in center),tuple(v*U for v in size))
    # Independent solid members keep the bill reproducible and inspectable.
    inside=w-2*arm
    for z in (-d/2+f/2,d/2-f/2):part(WOOD,(0,top-board-f/2,z),(inside,f,f))
    for x in (-w/2+arm/2,w/2-arm/2):
        part(WOOD,(x,top-board-f/2,0),(f,f,d))
        for z in (-d/2+leg/2,d/2-leg/2):
            part(WOOD,(x,(top-board)/2,z),(leg,top-board,leg))
            part(WOOD,(x,0.035,z),(leg*1.25,0.07,leg*1.25))
            part(METAL,(x,0.075,z),(leg*1.08,0.004,leg*1.08))
        part(WOOD,(x,top+0.11,0),(arm,0.05,d))
        for z in (-d/2+leg/2,d/2-leg/2):
            part(WOOD,(x,top+0.05,z),(leg,0.10,leg))
    if row['seats']==3:
        for z in (-d/2+leg/2,d/2-leg/2):part(WOOD,(0,(top-board)/2,z),(leg,top-board,leg))
    for i in range(row['seats']):
        x=(i-(row['seats']-1)/2)*inside/row['seats']
        width=inside/row['seats']-0.006
        part(WOOD,(x,top-board/2,0),(width,board,d-2*f))
        part(INSIDE,(x,top+DATA['cover_thickness_m']/2,0),(width,DATA['cover_thickness_m'],d-2*f))
        cloth+=width*(d-2*f)
    back_height=h-top-f
    part(WOOD,(0,top+back_height/2,-d/2+back/2),(inside,back_height,back))
    part(INSIDE,(0,top+back_height/2,-d/2+back+0.0005),(inside-2*f,back_height-f,0.001))
    cloth+=(inside-2*f)*(back_height-f)
    for x in (-w/2+arm/2,w/2-arm/2):part(WOOD,(x,(top+h-f)/2,-d/2+leg/2),(leg,h-f-top,leg))
    part(WOOD,(0,h-f/2,-d/2+f/2),(w,f,f))
    # Restrained crest and frame trim share the owned wood/metal palette.
    part(WOOD,(0,h-f*1.3,-d/2+f),(inside*0.30,f*0.45,f*0.30))
    for x in (-inside/2+f,inside/2-f):part(METAL,(x,top-f/2,d/2-f-0.001),(0.025,0.05,0.002))
    wood=volumes[WOOD]*DATA['wood_density_kg_m3']
    iron=volumes[METAL]*DATA['iron_density_kg_m3']
    cotton=cloth*DATA['cloth_kg_m2']
    return mesh,{'wood_kg':wood,'iron_kg':iron,'cotton_cloth_kg':cotton,'empty_kg':wood+iron+cotton,
                 'recipe_grams':{'wood':math.ceil(1000*wood),'iron':math.ceil(1000*iron),'cotton_cloth':math.ceil(1000*cotton)}}

def generate():
    folder=ROOT/'src/models/caelum/props/sofas'
    folder.mkdir(parents=True,exist_ok=True)
    rows=[]
    for row in DATA['versions']:
        mesh,bill=sofa(row);name=f"ca_sofa_{row['seats']}.obj";path=folder/name
        mesh.write(path)
        path.write_text(path.read_text(encoding='utf-8').replace('o CaelumStashChest',f"o CaelumSofa{row['seats']}"),encoding='utf-8',newline='\n')
        rows.append(dict(row,**bill,model=name,sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
    report={'issue':410,'models':rows,'textures_reused':[WOOD,METAL,INSIDE],
            'ownership':'Original deterministic mesh; existing project-owned textures. References supply dimensions only; no copied image pixels.'}
    (ART/'GENERATED.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    lines=['// #410: generado desde assets/art_source/sofas/DATA.json.','class CaelumSofaData : Object','{',
           '    const REVISION=1;',f"    const SEAT_STRIDE={DATA['native_seat_stride_m']*U:.9f};",
           f"    const SEAT_RADIUS={DATA['native_seat_radius_m']*U:.9f};",f"    const SEAT_SURFACE={DATA['seat_top_m']*U:.9f};"]
    for method,key,scale in [('Width','width_m',U),('Depth','depth_m',U),('Height','height_m',U),('Weight','empty_kg',1)]:
        lines.append(f'    static clearscope double {method}(int kind){{return kind==1?{rows[1][key]*scale:.9f}:{rows[0][key]*scale:.9f};}}')
    positions=[','.join(str(v) for v in r['mansion_position']) for r in rows]
    for method,key in [('Wood','wood'),('Iron','iron'),('Cloth','cotton_cloth')]:
        lines.append(f"    static clearscope int {method}(int kind){{return kind==1?{rows[1]['recipe_grams'][key]}:{rows[0]['recipe_grams'][key]};}}")
    lines += [f"    static clearscope double VisualStride(int kind){{return (Width(kind)-{2*DATA['arm_width_m']*U:.9f})/(kind==1?3:2);}}",
              '    static clearscope int Seats(int kind){return kind==1?3:2;}',
              f'    static clearscope vector3 Position(int kind){{return kind==1?({positions[1]}):({positions[0]});}}',
              f"    static clearscope double Facing(int kind){{return kind==1?{rows[1]['facing']}:{rows[0]['facing']};}}", '}']
    (ROOT/'src/caelum/data/CaelumSofaData.zs').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print(json.dumps([{'seats':r['seats'],'empty_kg':r['empty_kg'],'recipe_grams':r['recipe_grams']} for r in rows]))

if __name__=='__main__':generate()
