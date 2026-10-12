"""Register reusable face/hair modules and native head anchors for issue #148.

Requires Pillow 11.3.0. Source atlases remain untouched. Alpha components provide
measured registration: generated atlas rows need not fall on exact grid cuts.
"""
import argparse
from functools import lru_cache
import hashlib
import importlib.util
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw
from appearance_pose_modules import clean, head_kind, save_png

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/appearance_5213'
OUT = ROOT / 'src/graphics/caelum/appearance/details'
SPEC = json.loads(Path(__file__).with_name('appearance_catalog.json').read_text())
CANVAS = tuple(SPEC['detail_canvas'])
ANCHOR = tuple(SPEC['detail_anchor'])
RECORDS = {}
BOXES = {}


@lru_cache(None)
def atlas(name):
    """Return the 32 main alpha components in row/view order, preserving edges."""
    im = Image.open(SOURCE / name).convert('RGBA')
    width, height = im.size
    seen = bytearray(im.getchannel('A').point(lambda a: 255 if a >= 64 else 0).tobytes())
    components = []
    for start in range(len(seen)):
        if not seen[start]:
            continue
        todo = [start]
        seen[start] = 0
        area = 0
        x0 = x1 = start % width
        y0 = y1 = start // width
        while todo:
            index = todo.pop()
            x, y = index % width, index // width
            area += 1
            x0, x1, y0, y1 = min(x0, x), max(x1, x), min(y0, y), max(y1, y)
            for other in (index-1 if x else -1, index+1 if x < width-1 else -1,
                          index-width if y else -1, index+width if y < height-1 else -1):
                if other >= 0 and seen[other]:
                    seen[other] = 0
                    todo.append(other)
        if area > 800:
            components.append((area, (x0, y0, x1+1, y1+1)))
    assert len(components) >= 32, (name, len(components))
    main = sorted(sorted(components, reverse=True)[:32], key=lambda c: c[1][1]+c[1][3])
    cells = []
    boxes = []
    for row in range(4):
        for _, box in sorted(main[row*8:(row+1)*8], key=lambda c: c[1][0]):
            x0, y0, x1, y1 = box
            box = (max(0,x0-2), max(0,y0-2), min(width,x1+2), min(height,y1+2))
            cell = im.crop(box)
            cell.putalpha(cell.getchannel('A').point(lambda a: a if a >= 16 else 0))
            cells.append(cell)
            boxes.append(box)
    BOXES[name] = boxes
    return cells


def scalp(im):
    """Measure an upper-scalp band, excluding nose, neck and pointed ears."""
    top = max(1, round(im.height*.20))
    box = im.getchannel('A').crop((0, 0, im.width, top)).point(lambda a: 255 if a >= 64 else 0).getbbox()
    assert box
    return (box[0]+box[2])/2, box[2]-box[0]


def place_face(identity, face, view):
    spec = SPEC['heads'][identity]
    cells = atlas(spec['faces_source'])
    reference, im = cells[view], cells[face*8+view]
    _, reference_width = scalp(reference)
    _, source_width = scalp(im)
    vertical = spec['head_height']/im.height
    horizontal = reference_width*spec['head_height']/reference.height/source_width
    resized = im.resize((max(1,round(im.width*horizontal)),spec['head_height']),Image.Resampling.LANCZOS)
    center, _ = scalp(resized)
    result = Image.new('RGBA', CANVAS)
    result.alpha_composite(resized,(round(ANCHOR[0]-center),ANCHOR[1]-spec['head_height']+3))
    return result


def place_hair(identity, style, view):
    reference = atlas('human_male_faces_v1.png')[view]
    target = atlas(SPEC['heads'][identity]['faces_source'])[view]
    hair = atlas(SPEC['hair_source'])[style*8+view]
    _, ref_width = scalp(reference)
    _, target_width = scalp(target)
    height = SPEC['heads'][identity]['head_height']
    factor_y = height/reference.height
    factor_x = target_width*height/target.height/ref_width
    # Measure a fixed scalp-height band, not a percentage of long hair length.
    band = hair.getchannel('A').crop((0,0,hair.width,max(1,round(reference.height*.20))))
    box = band.point(lambda a:255 if a>=64 else 0).getbbox()
    center = (box[0]+box[2])/2
    resized = hair.resize((round(hair.width*factor_x),round(hair.height*factor_y)),Image.Resampling.LANCZOS)
    # Grayscale masks keep palette choices independent of the six source faces.
    result = Image.new('RGBA', CANVAS)
    gray = Image.merge('RGBA',(resized.convert('L'),)*3+(resized.getchannel('A'),))
    result.alpha_composite(gray,(round(ANCHOR[0]-center*factor_x),ANCHOR[1]-height+2))
    return result


def skin_mask(im, kind):
    import colorsys
    values=[]
    for r,g,b,a in im.getdata():
        h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255)
        active=(g>r*1.10 and g>b*1.10 and s>.13 and v>.06) if kind=='caelith' else (.015<h<.15 and s>.18 and v>.18)
        values.append(255 if active and a else 0)
    result=Image.new('L',im.size);result.putdata(values)
    return result


def save_module(im, name):
    im=clean(im)
    bounds = im.getchannel('A').point(lambda a:255 if a>=16 else 0).getbbox()
    assert bounds and bounds[0]>0 and bounds[1]>0 and bounds[2]<CANVAS[0] and bounds[3]<CANVAS[1], name
    path = OUT / (name+'.png')
    path.parent.mkdir(parents=True,exist_ok=True)
    save_png(im.crop(bounds),path)
    RECORDS[path.relative_to(ROOT).as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
    return path.relative_to(ROOT/'src').as_posix(),bounds


def pose_detail(im,angle,kind):
    im=im.rotate(angle,Image.Resampling.BICUBIC,center=ANCHOR)
    if kind=='supine':
        factor=SPEC['authored_registration']['sleep']['head_projection']
        scaled=im.resize((im.width,round(im.height*factor)),Image.Resampling.LANCZOS)
        im=Image.new('RGBA',CANVAS)
        im.alpha_composite(scaled,(0,round(ANCHOR[1]*(1-factor))))
    return im


def base_generator():
    path=Path(__file__).with_name('generate_modular_appearance.py')
    spec=importlib.util.spec_from_file_location('appearance_base',path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module


def anchor_groups(base):
    groups=[[],[]];entries=[]
    for sex in range(2):
        for gloved in (False,True):
            for pose in SPEC['poses']:
                anchors=[]
                for view,raw in enumerate(base.sheet(SPEC['body_sources' if gloved else 'bare_body_sources'][sex])):
                    value=base.authored_pose(view,pose,sex,not gloved) or base.body_pose(raw,view,pose)
                    anchors.append((value[1],value[2]))
                (x,y),angle=anchors[0]
                signature=tuple((point[0]-x,point[1]-y,a,head_kind(pose)) for point,a in anchors)
                if signature not in groups[sex]:groups[sex].append(signature)
                entries.append((groups[sex].index(signature),x-SPEC['neck'][0],y-SPEC['neck'][1]))
    count=max(map(len,groups))
    assert count<=26,('Native head frame letters exhausted',count)
    for group in groups:
        while len(group)<count:group.append(group[0])
    return groups,entries


def prefix(index):
    digits='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    return 'V'+digits[index//1296]+digits[index//36%36]+digits[index%36]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare-only',action='store_true',help='Prepare modules and a contact sheet without native registration.')
    args=parser.parse_args()
    base=base_generator();groups,entries=anchor_groups(base)
    transforms={view:set() for view in range(8)}
    for sex in groups:
        for group in sex:
            for view,(dx,dy,angle,kind) in enumerate(group):
                head_view=(-view)%8 if kind=='supine' else view
                transforms[head_view].add((angle,kind))
    faces={};hairs={}
    for identity,spec in enumerate(SPEC['heads'][:6]):
        for view in range(8):
            for face in range(4):
                raw=place_face(identity,face,view);mask=skin_mask(raw,spec['color_kind'])
                for tone in range(3):
                    colored=base.tone_image(raw,mask,spec['color_kind'],tone)
                    for angle,kind in sorted(transforms[view]):
                        posed=pose_detail(colored,angle,kind)
                        suffix='' if kind=='upright' else '_'+kind
                        faces[identity,tone,face,view,angle,kind]=save_module(posed,f'face/{identity}_{tone}_{face}_{view}_{angle}{suffix}')
            for style in range(4):
                raw=place_hair(identity,style,view)
                for angle,kind in sorted(transforms[view]):
                    posed=pose_detail(raw,angle,kind)
                    suffix='' if kind=='upright' else '_'+kind
                    hairs[identity,style,view,angle,kind]=save_module(posed,f'hair/{identity}_{style}_{view}_{angle}{suffix}')
    board=Image.new('RGBA',(6*192,4*192),(35,40,44,255))
    for identity in range(6):
        for variant in range(4):
            face=place_face(identity,variant,0);hair=place_hair(identity,variant,0)
            face.alpha_composite(hair)
            sample=face.resize((192,192),Image.Resampling.NEAREST)
            board.alpha_composite(sample,(identity*192,variant*192))
    board.save(ROOT/'build/issue148/face-hair-registration.png')
    if not args.prepare_only:
        lines=['// Generated modular heads; body and gloves are registered independently.']
        count=0
        for identity in range(6):
            for tone in range(3):
                for face in range(4):
                    for style in range(4):
                        for color,swatch in enumerate(SPEC['hair_colors']):
                            look=((((identity*3+tone)*4+face)*4+style)*6+color)
                            for group,rotations in enumerate(groups[identity%2]):
                                for view,(dx,dy,angle,kind) in enumerate(rotations):
                                    head_view=(-view)%8 if kind=='supine' else view
                                    fp,fb=faces[identity,tone,face,head_view,angle,kind]
                                    hp,hb=hairs[identity,style,head_view,angle,kind]
                                    bounds=(min(fb[0],hb[0]),min(fb[1],hb[1]),max(fb[2],hb[2]),max(fb[3],hb[3]))
                                    x,y,right,bottom=bounds
                                    ox=SPEC['pivot'][0]+ANCHOR[0]-x-SPEC['neck'][0]-dx
                                    oy=SPEC['pivot'][1]+ANCHOR[1]-y-SPEC['neck'][1]-dy
                                    rgb=', '.join(map(str,swatch['rgb']))
                                    lines += [f'Sprite "{prefix(look)}{chr(65+group)}{view+1}", {right-x}, {bottom-y}', '{', f'    Offset {ox}, {oy}',f'    Patch "{fp}", {fb[0]-x}, {fb[1]-y}',f'    Patch "{hp}", {hb[0]-x}, {hb[1]-y} {{ Blend {rgb} }}','}']
                                    count+=1
        (ROOT/'src/graphics/caelum/appearance-details.textures').write_text('\n'.join(lines)+'\n',encoding='utf-8')
        values=', '.join(str(value) for entry in entries for value in entry)
        registry='// Anclajes y registros generados; ninguna cámara decide la vista.\nclass CaelumAppearanceDetailsRegistry : Actor\n{\n'
        registry+='    static clearscope int, Vector2 Anchor(int sex,bool gloved,int pose)\n    {\n'
        registry+=f'        static const int data[] = {{{values}}};\n'
        registry+=f'        int index=((Clamp(sex,0,1)*2+int(gloved))*{len(SPEC["poses"])}+Clamp(pose,0,{len(SPEC["poses"])-1}))*3;\n'
        registry+='        return data[index],(data[index+1],data[index+2]);\n    }\n    States\n    {\n    Spawn:\n'
        frames=''.join(chr(65+i) for i in range(len(groups[0])))
        for look in range(6*3*4*4*6):registry+=f'    Look{look}:\n        {prefix(look)} {frames} 1;\n'
        registry+='        Stop;\n    }\n}\n'
        (ROOT/'src/caelum/character/CaelumAppearanceDetailsRegistry.zs').write_text(registry,encoding='utf-8')
        print(f'{count} small native head textures; {count//8} frames; {len(groups[0])} anchor groups per sex.')
    manifest={'issue':209,'generator':'assets/generators/generate_appearance_details.py','atlas_boxes':BOXES,'anchor_groups':groups,'pose_anchors':entries,'module_sha256':RECORDS}
    (ROOT/'assets/source/art/appearance_5218/DETAIL_REGISTRATION.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(f'{len(RECORDS)} reusable face/hair modules.')


if __name__=='__main__':
    main()
