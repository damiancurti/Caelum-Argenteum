"""Deterministic sex-specific hand modules and native compositions (#148/#209).

Pillow 11.3.0; technical sprite preparation authorized by the author. Weapon
patches, native canvas coordinates, layer order and original grip pivots stay
unchanged. Male gloves retain accepted resources; female gloves have a shared
anatomical variant. Source artwork and exact prompts are retained in assets.
"""
from pathlib import Path
import colorsys
import hashlib
import json
import re
import struct
from functools import lru_cache
from PIL import Image, ImageDraw
from appearance_pose_modules import save_png

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/appearance_5213'
OUT = ROOT / 'src/graphics/caelum/appearance/hands'
CATALOG = json.loads(Path(__file__).with_name('appearance_catalog.json').read_text())
RECORDS = {}
TEXTURES = []
STATES = []
SERIAL = 0


def clean(im):
    """Remove low-alpha source fringes before downsampling, not opaque art."""
    im = im.convert('RGBA')
    pixels = []
    for r,g,b,a in im.getdata():
        # Generated alpha mattes contain isolated saturated red/yellow edge
        # remnants. Only low-alpha pixels are rejected; opaque art is intact.
        pixels.append((r,g,b,0 if a < 32 else a))
    im.putdata(pixels)
    return im


def fit(im, reference):
    bounds = reference.getbbox()
    own = im.getbbox()
    assert bounds and own
    im = im.crop(own).resize((bounds[2]-bounds[0], bounds[3]-bounds[1]), Image.Resampling.LANCZOS)
    result = Image.new('RGBA', reference.size)
    result.alpha_composite(im, bounds[:2])
    return result


def cells(name, rows):
    im = clean(Image.open(SOURCE/name)); w,h=im.size
    return [im.crop((n%2*w//2,n//2*h//rows,(n%2+1)*w//2,(n//2+1)*h//rows)) for n in range(rows*2)]


@lru_cache(None)
def female_cells(art):
    version=2 if art in ('human','gloves','wolf') else 1
    path=ROOT/f'assets/source/art/appearance_5218/female_{art}_v{version}.png'
    im=clean(Image.open(path));w,h=im.size
    alpha=im.getchannel('A');bands=[];start=None
    for y in range(h):
        occupied=sum(a>=64 for a in alpha.crop((0,y,w,y+1)).getdata())>=12
        if occupied and start is None:start=y
        if not occupied and start is not None:
            if bands and start-bands[-1][1]<12:bands[-1]=(bands[-1][0],y)
            else:bands.append((start,y))
            start=None
    if start is not None:bands.append((start,h))
    bands=[band for band in bands if band[1]-band[0]>30]
    assert len(bands)==7,(art,bands)
    return [im.crop((col*w//2,top,(col+1)*w//2,bottom)) for top,bottom in bands for col in range(2)]


def tinted(im, family, tone, shotgun=False):
    result=im.copy();mask=Image.new('L',im.size);data=[];mp=[]
    for r,g,b,a in im.getdata():
        if a==0:
            data.append((r,g,b,a));mp.append(0);continue
        h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255) if shotgun else (0,0,max(r,g,b)/255)
        # Brass cartridge pixels have yellow hues; protect them in every tone.
        brass=shotgun and .105<h<.19 and s>.45
        selected=a>0 and not brass and (family<2 or v>.24)
        mp.append(255 if selected else 0)
        if not selected or (tone==0 and family!=1): data.append((r,g,b,a));continue
        if family>=2:
            rgb=[min(255,round(c*f)) for c,f in zip((r,g,b),CATALOG['fur_multipliers'][tone])]
        else:
            target=CATALOG['caelith_tones' if family==1 else 'skin_tones'][tone]
            light=(.299*r+.587*g+.114*b)/138
            rgb=[min(255,round(c*light)) for c in target]
        data.append((*rgb,a))
    result.putdata(data);mask.putdata(mp)
    assert result.getchannel('A').tobytes()==im.getchannel('A').tobytes()
    assert all(p==q for p,q,m in zip(im.getdata(),result.getdata(),mp) if not m)
    return result,mask


def save(im,name):
    p=OUT/(name+'.png');p.parent.mkdir(parents=True,exist_ok=True)
    save_png(im,p);RECORDS[p.relative_to(ROOT).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
    return p.relative_to(ROOT/'src').as_posix()


def blocks(text):
    result={}
    for match in re.finditer(r'(Sprite|Graphic)\s+"([^"]+)"\s*,\s*\d+\s*,\s*\d+\s*\{',text):
        end=match.end();depth=1
        while depth:
            depth+=(text[end]=='{')-(text[end]=='}');end+=1
        result[match[2]]=text[match.start():end]
    return result


def sprite(label,body,frame='A',prefix=None):
    global SERIAL
    if prefix is None:
        # Hxxx uses base 36; sprite prefixes must remain exactly four bytes.
        digits='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';n=SERIAL;SERIAL+=1
        prefix='H'+''.join(digits[(n//36**p)%36] for p in (2,1,0))
    name=prefix+frame+'0'
    TEXTURES.append(re.sub(r'^(Sprite|Graphic)\s+"[^"]+"',f'Sprite "{name}"',body))
    STATES.append(f'    {label}:\n        {prefix} {frame} -1; Stop;')
    return prefix


def png_offset(path):
    data=path.read_bytes();pos=8
    while pos<len(data):
        length=int.from_bytes(data[pos:pos+4],'big');tag=data[pos+4:pos+8]
        if tag==b'grAb':return struct.unpack('>ii',data[pos+8:pos+16])
        pos+=12+length
    return (0,0)


def main():
    (ROOT/'build/issue148').mkdir(parents=True,exist_ok=True)
    source_blocks=blocks((ROOT/'src/TEXTURES').read_text(encoding='utf-8-sig'))
    shotgun_blocks=blocks((ROOT/'src/graphics/caelum/shotgun.textures').read_text())
    refs=[Image.open(ROOT/f'src/sprites/caelum/first_person/v1/hands/FH{n:02d}A0.png').convert('RGBA') for n in range(8)]
    shotgun_ref=Image.open(ROOT/'src/graphics/caelum/shotgun/hands_domingo.png').convert('RGBA')
    edges=[0,312,580,876,1156,1448]
    shield_refs={f:Image.open(ROOT/f'src/sprites/LHND{f}0.png').convert('RGBA') for f in 'ABCDHI'}
    base_bolas=Image.open(ROOT/'src/graphics/caelum/bolas/hand-extended.png').convert('RGBA')
    bolas_atlas=clean(Image.open(SOURCE/'first_person_bolas_bare_v1.png'))
    bw,bh=bolas_atlas.size
    bolas_cells=[bolas_atlas.crop((n%3*bw//3,n//3*bh//2,(n%3+1)*bw//3,(n//3+1)*bh//2)) for n in range(5)]
    frames=(ROOT/'src/caelum/equipment/CaelumFirstPersonView.zs').read_text(encoding='utf-8')
    fallback=re.findall(r'CA_FP1_(staff|javelin|spear|bell|book|statuette)_T([123])_([ABC]):\s*(C\d{3})\s+([ABC])',frames)
    art_names=['human','human','wolf','bear','puma','jaguar']*2+['gloves']
    board=Image.new('RGBA',(6*320,3*200),(30,35,40,255))
    for family,art in enumerate(art_names):
        female=family>=6
        color_family=family%6 if family<12 else 6
        hand_cells=female_cells(art)[:8] if female else cells(f'first_person_bare_{art}_v1.png',4)
        # Return-to-hold reuses the actual empty grip; cartridge frames remain
        # confined to reload. Spare generated poses do not become new timings.
        shot_cells=[female_cells(art)[i] for i in (8,9,8,10,12)] if female else cells(f'first_person_shotgun_{art}_v1.png',3)
        for tone in range(1 if art=='gloves' else 3):
            variant=family*3+tone;paths=[];images=[]
            for n,ref in enumerate(refs):
                im,mask=tinted(fit(hand_cells[n],ref),color_family,tone)
                paths.append(save(im,f'{variant}/FH{n:02d}'));images.append(im)
            if not female:board.alpha_composite(images[0],(family*320,tone*200))
            replacements={f'sprites/caelum/first_person/v1/hands/FH{n:02d}A0.png':path for n,path in enumerate(paths)}
            def replace(body):
                for old,new in replacements.items():body=body.replace(old,new)
                return body
            for hand in (0,3,4,5,6,7,9,10):
                sprite(f'V{variant}_Hand_{hand}',replace(source_blocks[f'DH{hand:02d}A0']))
            # Bow finger occlusion uses the same authored clipping rectangles.
            for name,body in source_blocks.items():
                if name.startswith('CA_BOW_') and 'FH03A0' in body:
                    TEXTURES.append(replace(body).replace(name,f'{name}_V{variant}'))
            body=source_blocks['DH12A0']
            for name in re.findall(r'Graphic "([^"]+)"',body):body=body.replace(name,f'{name}_V{variant}')
            sprite(f'V{variant}_Hand_12',body)
            # Closed left grip, fitted to each native shield frame's canvas.
            shield_prefix=None
            for frame,ref in shield_refs.items():
                im,_=tinted(fit(hand_cells[3],ref),color_family,tone)
                path=save(im,f'{variant}/shield_{frame}');offset=png_offset(ROOT/f'src/sprites/LHND{frame}0.png')
                body=f'Sprite "TEMP", {ref.width}, {ref.height}\n{{ NoTrim Offset {offset[0]}, {offset[1]} Patch "{path}", 0, 0 }}'
                shield_prefix=sprite(f'V{variant}_ShieldFrame_{frame}',body,frame,shield_prefix)
            # Animated states retain native timing and settle into the same hold.
            for role,sequence in {
                'Idle':f'{shield_prefix} AB 8; Loop;',
                'Raise':f'{shield_prefix} CD 3; Goto V{variant}_Shield_Idle;',
                'Lower':f'{shield_prefix} D 3; {shield_prefix} C -1; Stop;',
                'Attack':f'{shield_prefix} A 8; Goto V{variant}_Shield_Idle;',
                'Block':f'{shield_prefix} H 3; Goto V{variant}_Shield_Hold;',
                'Hold':f'{shield_prefix} I -1; Stop;'}.items():
                STATES.append(f'    V{variant}_Shield_{role}:\n        {sequence}')
            # The extended arm is authored separately; retain the accepted
            # long-arm canvas and grip registration, without stretching a fist.
            im=fit(female_cells(art)[13] if female else bolas_cells[max(0,family-1)],base_bolas)
            im,_=tinted(im,color_family,tone);path=save(im,f'{variant}/bolas')
            sprite(f'V{variant}_Bolas',f'Sprite "TEMP", 2240, 2800 {{ XScale 7 YScale 7 NoTrim Offset 1512, 1120 Patch "{path}", 1182, 760 }}')
            for pose,row in enumerate((0,1,2,3,4,3,2)):
                ref=shotgun_ref.crop((0,edges[row],362,edges[row+1]))
                im,mask=tinted(fit(shot_cells[row],ref),color_family,tone,True)
                path=save(im,f'{variant}/shotgun_{row}')
                if color_family==1:save(mask,f'{variant}/shotgun_mask_{row}')
                body=shotgun_blocks[f'SHHD{chr(65+pose)}0']
                body=re.sub(r'Patch "graphics/caelum/shotgun/hands_domingo.png", 0, -?\d+',f'Patch "{path}", 0, 0',body)
                sprite(f'V{variant}_Shotgun_{pose}',body)
            for family_name,tier,phase,prefix,frame in fallback:
                body=replace(source_blocks[prefix+frame+'0']).replace('{','{\n    NoTrim',1)
                sprite(f'V{variant}_{family_name}_T{tier}_{phase}',body)
    path=ROOT/'src/graphics/caelum/appearance-hands.textures'
    path.write_text('// Generated from shared hand modules; weapon patches are unchanged.\n'+'\n'.join(TEXTURES)+'\n',encoding='utf-8')
    (ROOT/'src/caelum/character/CaelumAppearanceHandFrames.zs').write_text('// Generado por generate_appearance_hands.py.\nclass CaelumAppearanceHandFrames : Actor\n{\n    States (Weapon, Overlay)\n    {\n'+'\n'.join(STATES)+'\n    }\n}\n',encoding='utf-8')
    board.save(ROOT/'build/issue148/hand-tones.png')
    (ROOT/'assets/source/art/appearance_5218/HAND_REGISTRATION.json').write_text(json.dumps({'issue':209,'variants':37,'prefixes':SERIAL,'module_sha256':RECORDS},indent=2)+'\n',encoding='utf-8')
    print(f'{SERIAL} native hand sprite banks; {len(RECORDS)} shared module files.')


if __name__=='__main__':main()
