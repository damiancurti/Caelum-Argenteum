"""Finite cloth-mask palettes for #423; preserve accepted prisoner identity art."""
from pathlib import Path
import colorsys
import hashlib
import json
import re
from PIL import Image, ImageDraw
from generate_prisoner_sprites import PRISONERS, collect_source_files, source_path_for, output_name, build_lut

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/port_597'
SPEC=json.loads((SOURCE/'prisoner_wardrobes.json').read_text())
OUT=ROOT/'src/graphics/caelum/port_wardrobe/prisoners'

def cloth(char,rgb):
    h,s,v=colorsys.rgb_to_hsv(*(c/255 for c in rgb));h*=360
    if char=='rulo':return 55<=h<=120 and s>=.18 and v<.80
    if char=='caella':return 190<=h<=280 and s>=.18 and .10<v<.85
    return 195<=h<=280 and s>=.18 and .10<v<.45

def main():
    textures=(ROOT/'src/TEXTURES').read_text(encoding='utf-8')
    manifest=[];board=Image.new('RGBA',(8*256,4*280),(35,38,43,255));draw=ImageDraw.Draw(board)
    for row,p in enumerate(PRISONERS):
        spec=SPEC['wardrobes'][p['faction']];lut=build_lut(spec['ramp'])
        for role,prefix,filename in collect_source_files(p):
            name=output_name(p,role,prefix,filename)
            original=Image.open(source_path_for(p,role,filename)).convert('RGBA')
            basepath=ROOT/f"src/sprites/caelum/prisoners/{p['faction']}/{name}.png"
            base=Image.open(basepath).convert('RGBA');layer=base.copy()
            assert base.size==original.size
            box=original.getbbox();changed=0
            for y in range(box[1],box[3]):
                for x in range(box[0],box[2]):
                    pixel=original.getpixel((x,y))
                    if not pixel[3] or not cloth(p['source_char'],pixel[:3]):continue
                    # Protect the full head envelope. Fallen/rest figures lie along X.
                    if box[2]-box[0]>box[3]-box[1]:
                        if x<box[0]+.30*(box[2]-box[0]) or x>box[2]-.30*(box[2]-box[0]):continue
                    elif y<box[1]+.30*(box[3]-box[1]):continue
                    luma=round(.299*pixel[0]+.587*pixel[1]+.114*pixel[2])
                    # Keep the exact original alpha, including antialiased cloth edges.
                    if pixel[3]<32:continue
                    layer.putpixel((x,y),(*lut[luma],base.getpixel((x,y))[3]));changed+=1
            target=OUT/p['faction']/(name+'.png');target.parent.mkdir(parents=True,exist_ok=True)
            layer.save(target,compress_level=9)
            path=target.relative_to(ROOT/'src').as_posix()
            base_ref=basepath.relative_to(ROOT/'src').as_posix()
            replacement=f'Sprite "{name}", 256, 256 {{ Offset 128, 244 Patch "{path}", 0, 0 }}'
            textures,n=re.subn(r'^Sprite "'+name+r'"[^\n]*$',lambda m:replacement,textures,flags=re.M)
            assert n==1,(name,n)
            manifest.append({'sprite':name,'changed_cloth_pixels':changed,'sha256':hashlib.sha256(target.read_bytes()).hexdigest()})
            if role=='idle' and filename[-6]=='A' and filename[-5] in '15':
                view=int(filename[-5]);col=0 if view==1 else 2
                board.alpha_composite(base,(col*256,row*280+24))
                preview=layer
                board.alpha_composite(preview,((col+1)*256,row*280+24))
            if role=='rest' and filename.endswith('B1.png'):
                board.alpha_composite(base,(4*256,row*280+24));board.alpha_composite(layer,(5*256,row*280+24))
            if role=='combat' and filename.endswith('L0.png'):
                board.alpha_composite(base,(6*256,row*280+24));board.alpha_composite(layer,(7*256,row*280+24))
        draw.text((5,row*280+4),spec['name']+' — existing / wardrobe, front/back/lying/death',fill='white')
    (ROOT/'src/TEXTURES').write_text(textures,encoding='utf-8',newline='\n')
    (SOURCE/'PRISONER_REGISTRATION.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    board.save(SOURCE/'prisoner_registration.png')
    print(f'Registered {len(manifest)} finite cloth variants; protected pixels, alpha and pose names retained.')

if __name__=='__main__':main()
