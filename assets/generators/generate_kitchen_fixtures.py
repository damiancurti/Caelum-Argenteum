"""Export original wall cupboard geometry and reuse the accepted domestic sink."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode=True
from PIL import Image
from generate_stash_models import Mesh, WOOD, LOCK

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/art_source/kitchen_fixtures'
DATA=json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
C=DATA['cupboard'];U=DATA['map_units_per_meter']

def cupboard(opened=False,locked=False):
    mesh=Mesh();volume=0
    w,d,h=C['width_m'],C['depth_m'],C['height_m'];t=C['board_m'];back=C['model_back_offset_m']
    def piece(material,center,size,hinge=None,angle=0):
        nonlocal volume
        if material==WOOD:volume+=math.prod(size)
        def transform(point):
            x,y,z=point
            if hinge is not None:
                dx,dz=x-hinge[0]*U,z-hinge[1]*U
                x=hinge[0]*U+dx*math.cos(angle)-dz*math.sin(angle)
                z=hinge[1]*U+dx*math.sin(angle)+dz*math.cos(angle)
            return (x,y,z-back*U)
        mesh.add_box(material,tuple(x*U for x in center),tuple(x*U for x in size),transform)
    for y in (t/2,h-t/2):piece(WOOD,(0,y,0),(w,t,d))
    for x in (-(w-t)/2,(w-t)/2):piece(WOOD,(x,h/2,0),(t,h-2*t,d))
    piece(WOOD,(0,h/2,-(d-C['back_m'])/2),(w-2*t,h-2*t,C['back_m']))
    piece(WOOD,(0,h/2,0),(w-2*t,C['shelf_m'],d-2*t))
    door=(w-3*t)/2
    for sign in (-1,1):
        hinge=(sign*(w/2-t),d/2)
        angle=sign*math.pi/2 if opened else 0
        x=sign*(door/2+t/2)
        piece(WOOD,(x,h/2,d/2),(door,h-4*t,t),hinge,angle)
        # Raised frame and recessed centre remain visible at native scale.
        for dx in (-door/2+.025,door/2-.025):piece(WOOD,(x+dx,h/2,d/2+.017),(.045,h-4*t,.018),hinge,angle)
        for y in (.075,h-.075):piece(WOOD,(x,y,d/2+.017),(door,.045,.018),hinge,angle)
        piece(LOCK,(sign*.065,h/2,d/2+.045),(.025,.025,.03),hinge,angle)
    for y in (.025,h-.025):
        piece(WOOD,(0,y,d/2+.007),(w+.03,.05,.025))
        for x in (-w/2,w/2):piece(WOOD,(x,y,0),(.025,.05,d))
    piece(LOCK,(0,h/2-.055,d/2+.022),(.028,.05,.008))
    if locked:piece(LOCK,(0,h/2-.075,d/2+.055),(.06,.065,.025))
    return mesh,round(volume*C['wood_density_kg_m3']+C['hardware_kg'],3)

def main():
    folder=ROOT/'src/models/caelum/props/kitchen_fixtures';folder.mkdir(parents=True,exist_ok=True)
    outputs=[];models=[];mass=0
    for key,opened in [('closed',False),('open',True),('locked',False)]:
        mesh,mass=cupboard(opened,key=='locked');path=folder/(key+'.obj');mesh.write(path);outputs.append(path)
        letter={'closed':'A','open':'B','locked':'C'}[key]
        actor='CaelumKitchenCupboard'+key.title()+'Visual'
        models.append(f'Model {actor} {{ Path "models/caelum/props/kitchen_fixtures" Model 0 "{key}.obj" Scale 1 1 1 AngleOffset -90 CorrectPixelStretch DontCullBackFaces FrameIndex CKCB {letter} 0 0 }}')
    models.append('Model CaelumKitchenSink { Path "models/caelum/props/bathrooms" Model 0 "sink.obj" Scale 1 1 1 AngleOffset -90 CorrectPixelStretch DontCullBackFaces FrameIndex CDSK A 0 0 }')
    icon=ROOT/'src/graphics/caelum/icons/kitchen_stations/cupboard.png'
    im=Image.open(ART/'cupboard-source-v1.png').convert('RGBA')
    im.putalpha(im.getchannel('A').point(lambda a:255 if a>=128 else 0))
    cut=im.crop(im.getbbox());cut.thumbnail((116,116),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(128,128));out.alpha_composite(cut,((128-cut.width)//2,122-cut.height))
    out.putalpha(out.getchannel('A').point(lambda a:255 if a>=128 else 0));out.save(icon);outputs.append(icon)
    bounds=out.getbbox();scale=max((bounds[2]-bounds[0])/(C['width_m']*U),(bounds[3]-bounds[1])/(C['height_m']*U))
    textures=[f'Sprite CKCB{letter}0,128,128 {{ XScale {scale:.6f} YScale {scale:.6f} Offset 64,122 Patch "graphics/caelum/icons/kitchen_stations/cupboard.png",0,0 }}' for letter in 'ABC']
    cp=','.join(map(str,C['position']));sp=','.join(map(str,DATA['sink']['position']))
    code=['// #410: ubicaciones y construcci?n delegada, generadas desde DATA.json.','class CaelumKitchenFixtureData : Object','{',
          '    const REVISION=1;',f'    const CUPBOARD_KG={mass};',f'    const CUPBOARD_RADIUS={C["width_m"]*U/2};',
          f'    const CUPBOARD_HEIGHT={C["height_m"]*U};',f'    static clearscope Vector3 CupboardPosition(){{return ({cp});}}',
          f'    static clearscope Vector3 SinkPosition(){{return ({sp});}}',f'    const CUPBOARD_FACING={C["facing"]};',
          f'    const SINK_FACING={DATA["sink"]["facing"]};','}']
    for name,lines in [('kitchen_fixtures.modeldef',models),('kitchen_fixtures.textures',textures),('CaelumKitchenFixtureData.zs',code)]:
        path=ROOT/'src/caelum/data'/name;path.write_text('\n'.join(lines)+'\n',encoding='utf-8');outputs.append(path)
    report={'issue':410,'cupboard_mass_kg':mass,'sha256':{p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in outputs}}
    (ART/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'Cupboard {mass}kg; {len(outputs)} outputs.')

if __name__=='__main__':main()
