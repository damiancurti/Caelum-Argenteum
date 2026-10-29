"""Build the original wardrobe from its delegated physical specification."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode = True
from PIL import Image
from generate_stash_models import Mesh, WOOD, METAL, LOCK

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT/'assets/art_source/wardrobe'
DATA = json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
U = DATA['map_units_per_meter']


def wardrobe(opened=False, locked=False):
    mesh = Mesh()
    volumes = {WOOD: 0.0, METAL: 0.0}
    w, d, h, t = [DATA[k] for k in ('width_m','depth_m','height_m','board_m')]
    def piece(material, center, size, hinge=None, angle=0):
        if material in volumes:
            volumes[material] += math.prod(size)
        def transform(point):
            x, y, z = point
            if hinge is not None:
                dx, dz = x-hinge[0]*U, z-hinge[1]*U
                x = hinge[0]*U+dx*math.cos(angle)-dz*math.sin(angle)
                z = hinge[1]*U+dx*math.sin(angle)+dz*math.cos(angle)
            return x, y, z
        mesh.add_box(material, tuple(v*U for v in center), tuple(v*U for v in size), transform)
    for y in (t/2,h-t/2):
        piece(WOOD,(0,y,0),(w,t,d))
    for x in (-(w-t)/2,(w-t)/2):
        piece(WOOD,(x,h/2,0),(t,h-2*t,d))
    piece(WOOD,(0,h/2,-(d-DATA['back_m'])/2),(w-2*t,h-2*t,DATA['back_m']))
    for y in (0.45,1.55):
        piece(WOOD,(0,y,0),(w-2*t,DATA['shelf_m'],d-2*t))
    door = (w-3*t)/2
    door_h = h-0.15
    for sign in (-1,1):
        hinge = (sign*(w/2-t),d/2)
        angle = -sign*math.pi/2 if opened else 0
        x = sign*(door/2+t/2)
        piece(WOOD,(x,h/2,d/2),(door,door_h,t),hinge,angle)
        frame = DATA['panel_frame_m']
        projection = DATA['panel_projection_m']
        for dx in (-(door-frame)/2,(door-frame)/2):
            piece(WOOD,(x+dx,h/2,d/2+t/2+projection/2),(frame,door_h,projection),hinge,angle)
        for y in (h/2-door_h/2+frame/2,h/2-door_h/6,h/2+door_h/6,h/2+door_h/2-frame/2):
            piece(WOOD,(x,y,d/2+t/2+projection/2),(door-2*frame,frame,projection),hinge,angle)
        for y in (0.25,h/2,h-0.25):
            piece(METAL,(sign*(w/2-t),y,d/2+t),DATA['hinge_size_m'],hinge,angle)
        piece(METAL,(sign*0.045,h/2,d/2+0.035),DATA['knob_size_m'],hinge,angle)
    for y in (0.045,h-0.045):
        piece(WOOD,(0,y,d/2+0.018),(w+0.035,0.09,0.035))
        for x in (-w/2,w/2):
            piece(WOOD,(x,y,0),(0.025,0.09,d))
    piece(METAL,(0,h/2-0.085,d/2+0.018),DATA['latch_size_m'],(w/2-t,d/2),-math.pi/2 if opened else 0)
    if locked:
        piece(LOCK,(0,h/2-0.09,d/2+0.06),(0.06,0.065,0.025))
    wood = volumes[WOOD]*DATA['wood_density_kg_m3']
    iron = volumes[METAL]*DATA['iron_density_kg_m3']
    return mesh, wood, iron


def main():
    folder = ROOT/'src/models/caelum/props/wardrobe'
    folder.mkdir(parents=True,exist_ok=True)
    outputs, models = [], []
    masses = []
    for key, letter in (('closed','A'),('open','B'),('locked','C')):
        mesh, wood, iron = wardrobe(key=='open',key=='locked')
        masses.append((wood,iron))
        path = folder/(key+'.obj')
        mesh.write(path)
        outputs.append(path)
        actor = 'CaelumWardrobe'+key.title()+'Visual'
        models.append(f'Model {actor} {{ Path "models/caelum/props/wardrobe" Model 0 "{key}.obj" Scale 1 1 1 AngleOffset -90 CorrectPixelStretch DontCullBackFaces FrameIndex CWRD {letter} 0 0 }}')
    assert masses[0] == masses[1] == masses[2]
    wood, iron = masses[0]
    image = Image.open(ART/'wardrobe-source-v1.png').convert('RGBA')
    image.putalpha(image.getchannel('A').point(lambda a:255 if a>=128 else 0))
    cut = image.crop(image.getbbox())
    cut.thumbnail((116,116),Image.Resampling.LANCZOS)
    icon = Image.new('RGBA',(128,128))
    icon.alpha_composite(cut,((128-cut.width)//2,122-cut.height))
    icon.putalpha(icon.getchannel('A').point(lambda a:255 if a>=128 else 0))
    path = ROOT/'src/graphics/caelum/icons/furniture/wardrobe.png'
    path.parent.mkdir(parents=True,exist_ok=True)
    icon.save(path)
    outputs.append(path)
    bounds = icon.getbbox()
    scale = max((bounds[2]-bounds[0])/(DATA['width_m']*U),(bounds[3]-bounds[1])/(DATA['height_m']*U))
    textures = [f'Sprite CWRD{letter}0,128,128 {{ XScale {scale:.6f} YScale {scale:.6f} Offset 64,122 Patch "graphics/caelum/icons/furniture/wardrobe.png",0,0 }}' for letter in 'ABC']
    pos = ','.join(map(str,DATA['mansion_position']))
    # The closed silhouette includes the cornice and iron fittings.
    radius = math.hypot(DATA['width_m']+0.035,DATA['depth_m']+0.10)*U/2
    code = ['// #410: especificación delegada de assets/art_source/wardrobe/DATA.json.',
        'class CaelumWardrobeData : Object','{','    const REVISION=1;','    const DISPLAY_TYPE=3;',
        f'    const EMPTY_KG={wood+iron:.9f};',f'    const WOOD_GRAMS={math.ceil(wood*1000)};',
        f'    const IRON_GRAMS={math.ceil(iron*1000)};',f'    const RADIUS={radius:.9f};',
        f'    const HEIGHT={DATA["height_m"]*U:.9f};',
        f'    const FACING={DATA["mansion_facing"]};',
        f'    static clearscope vector3 Position(){{return ({pos});}}','}']
    for name, lines in (('wardrobe.modeldef',models),('wardrobe.textures',textures),('CaelumWardrobeData.zs',code)):
        path = ROOT/'src/caelum/data'/name
        path.write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
        outputs.append(path)
    report = {'issue':410,'wood_kg':wood,'iron_kg':iron,'empty_kg':wood+iron,
        'bill_grams':{'wood':math.ceil(wood*1000),'iron':math.ceil(iron*1000)},
        'mass_policy':'Fittings included; installed padlock remains a separate native item.',
        'source_sha256':hashlib.sha256((ART/'wardrobe-source-v1.png').read_bytes()).hexdigest(),
        'sha256':{p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in outputs}}
    (ART/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:v for k,v in report.items() if k!='sha256'}))


if __name__ == '__main__':
    main()
