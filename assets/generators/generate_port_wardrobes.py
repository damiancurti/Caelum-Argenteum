"""Deterministically register #423 authored wardrobe modules and existing faces.

Only cut, align, resize and compose source paintings. No generated body/face
Cartesian PNG set: native TEXTURES shares body, face, hair and cap modules.
"""
from pathlib import Path
import hashlib
import json
import math
import re
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/port_597'
OUT=ROOT/'src/graphics/caelum/port_wardrobe'
SIZE=(224,208)
POSES=[0,2,3,9,10,11,12,13,15,18,19,20,21,22,26,27,28]
GROUPS={'walk_melee':[2,3,9,10],'fire':[18,19,20,21],
        'pain_death':[11,12,13,15],'crouch':[26,27,28,22]}
DETAIL=json.loads((ROOT/'assets/source/art/appearance_5218/DETAIL_REGISTRATION.json').read_text())
HEADS=(ROOT/'src/graphics/caelum/appearance-details.textures').read_text()
REGISTRY=(ROOT/'src/caelum/character/CaelumAppearanceDetailsRegistry.zs').read_text()
HASHES={}
BOXES={}

def silhouettes(name,columns,rows):
    """Use authored silhouettes, not equally spaced rows in an AI atlas."""
    im=clean(Image.open(SOURCE/name));w,h=im.size
    seen=bytearray(im.getchannel('A').point(lambda a:255 if a>=64 else 0).tobytes())
    parts=[]
    for start in range(len(seen)):
        if not seen[start]:continue
        pending=[start];seen[start]=0;area=0;x0=x1=start%w;y0=y1=start//w
        while pending:
            i=pending.pop();x,y=i%w,i//w;area+=1
            x0,x1,y0,y1=min(x0,x),max(x1,x),min(y0,y),max(y1,y)
            for n in (i-1 if x else -1,i+1 if x<w-1 else -1,i-w if y else -1,i+w if y<h-1 else -1):
                if n>=0 and seen[n]:seen[n]=0;pending.append(n)
        if area>800:parts.append((area,(x0,y0,x1+1,y1+1)))
    assert len(parts)>=rows*columns,(name,len(parts),rows*columns)
    parts=sorted(sorted(parts,reverse=True)[:rows*columns],key=lambda p:p[1][1]+p[1][3])
    boxes=[]
    for row in range(rows):boxes.extend(b for _,b in sorted(parts[row*columns:(row+1)*columns],key=lambda p:p[1][0]))
    BOXES[name]=boxes
    return [im.crop(b) for b in boxes]

def clean(im):
    im=im.convert('RGBA')
    im.putdata([(r,g,b,a) if a>=32 else (0,0,0,0) for r,g,b,a in im.getdata()])
    return im

def save(im,name):
    path=OUT/(name+'.png');path.parent.mkdir(parents=True,exist_ok=True)
    clean(im).save(path,compress_level=9)
    HASHES[path.relative_to(ROOT).as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
    return path.relative_to(ROOT/'src').as_posix()

def cell(atlas,col,row,cols,rows):
    im=clean(atlas.crop((col*atlas.width//cols,row*atlas.height//rows,
                        (col+1)*atlas.width//cols,(row+1)*atlas.height//rows)))
    assert im.getbbox(),(col,row)
    return im.crop(im.getbbox())

def fit(raw,pose,view):
    reference=clean(Image.open(ROOT/f'src/graphics/caelum/appearance/body/0_{pose}_{view}.png'))
    box=reference.getbbox();im=Image.new('RGBA',SIZE)
    x=box[0]
    if pose!=15:
        navy=[]
        for yy in range(raw.height):
            for xx in range(raw.width):
                r,g,b,a=raw.getpixel((xx,yy))
                if a>128 and b>r*1.20 and b>g*1.03 and 12<b<150:navy.append((xx,yy))
        assert navy,(pose,view)
        top=min(y for x,y in navy);collar=[x for x,y in navy if y<=top+3]
        group,px,py=DETAIL['pose_anchors'][33+pose]
        dx=DETAIL['anchor_groups'][0][group][view][0]
        x=round(112+px+dx-sum(collar)/len(collar)*(box[2]-box[0])/raw.width)
    im.alpha_composite(raw.resize((box[2]-box[0],box[3]-box[1]),Image.Resampling.LANCZOS),(x,box[1]))
    return clean(im)

def sword_fit(raw,pose,view):
    # Identify the top of the navy collar, not the raised blade/glove, for scale.
    navy=[]
    for y in range(raw.height):
        for x in range(raw.width):
            r,g,b,a=raw.getpixel((x,y))
            if a>128 and b>r*1.20 and b>g*1.03 and 12<b<150:navy.append((x,y))
    assert navy
    top=min(y for x,y in navy);collar=[x for x,y in navy if y<=top+3]
    nx=sum(collar)/len(collar);scale=139/(raw.height-top)
    resized=clean(raw.resize((round(raw.width*scale),round(raw.height*scale)),Image.Resampling.LANCZOS))
    im=Image.new('RGBA',SIZE);im.alpha_composite(resized,(round(112-nx*scale),round(61-top*scale)))
    return clean(im)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    bodies={};paths={}
    atlas=Image.open(SOURCE/'guard_idle_v1.png')
    for view in range(8):bodies[0,view]=fit(cell(atlas,view%4,view//4,4,2),0,view)
    for name,poses in GROUPS.items():
        cells=silhouettes(f'guard_{name}_v1.png',8,4)
        for row,pose in enumerate(poses):
            for view in range(8):bodies[pose,view]=fit(cells[row*8+view],pose,view)
    atlas=Image.open(SOURCE/'guard_sword_v2.png')
    for row,pose in enumerate((9,10)):
        for view in range(8):bodies[pose,view]=sword_fit(cell(atlas,view%4,row*2+view//4,4,4),pose,view)
    for (pose,view),im in bodies.items():
        if pose in (2,3):
            hand=ROOT/f'src/graphics/caelum/appearance/world_gloves/0_{pose}_{view}.png'
            if hand.exists():
                layer=Image.open(hand).convert('RGBA')
                layer.putdata([(*(round(c*k/255) for c,k in zip(pixel[:3],(110,65,33))),pixel[3]) for pixel in layer.getdata()])
                im.alpha_composite(layer)
        paths[pose,view]=save(im,f'body/{pose}_{view}')
    cap_atlas=Image.open(SOURCE/'guard_cap_v1.png');caps={}
    for view in range(8):
        raw=cell(cap_atlas,view%4,view//4,4,2)
        width=[29,30,32,30,28,30,32,30][view]
        cap=raw.resize((width,round(raw.height*width/raw.width)),Image.Resampling.LANCZOS)
        im=Image.new('RGBA',SIZE);im.alpha_composite(cap,(112-width//2,23));caps[view]=im
    lines=['// #423: shared authored uniforms; existing faces/hair remain separate patches.']
    board=Image.new('RGBA',(4*224,len(POSES)*208))
    for face in range(4):
        match=re.search(rf'Look{face*24}:\s*(\w+) ',REGISTRY);prefix=match.group(1)
        for frame,pose in enumerate(POSES):
            group,px,py=DETAIL['pose_anchors'][33+pose]
            for view in range(8):
                name=f'{prefix}{chr(65+group)}{view+1}'
                entry=re.search(r'Sprite "'+name+r'".*?(?=\nSprite |\Z)',HEADS,re.S).group(0)
                ox,oy=map(int,re.search(r'Offset (-?\d+), (-?\d+)',entry).groups())
                patches=re.findall(r'Patch "([^"]+)", (-?\d+), (-?\d+)([^\n]*)',entry)
                preview=bodies[pose,view].copy()
                lines.extend([f'Sprite "V9G{face}{chr(65+frame)}{view+1}", 224, 208','{','    Offset 112, 200',f'    Patch "{paths[pose,view]}", 0, 0'])
                for path,x,y,options in patches:
                    x=112-ox+int(x)+px;y=200-oy+int(y)+py
                    lines.append(f'    Patch "{path}", {x}, {y}{options}')
                    layer=Image.open(ROOT/'src'/path).convert('RGBA')
                    blend=re.search(r'Blend (\d+), (\d+), (\d+)',options)
                    if blend:
                        rgb=tuple(map(int,blend.groups()));layer.putdata([(*(round(c*k/255) for c,k in zip(pixel[:3],rgb)),pixel[3]) for pixel in layer.getdata()])
                    preview.alpha_composite(layer,(x,y))
                dx,dy,angle,kind=DETAIL['anchor_groups'][0][group][view]
                assert kind=='upright'
                cap=caps[view].rotate(angle,Image.Resampling.BICUBIC,center=(112,61))
                cap=clean(cap);box=cap.getbbox();cp=save(cap.crop(box),f'cap/{group}_{view}')
                cx=box[0]+dx+px;cy=box[1]+dy+py
                lines.append(f'    Patch "{cp}", {cx}, {cy}');lines.append('}')
                preview.alpha_composite(cap.crop(box),(cx,cy))
                if view==0:board.alpha_composite(preview,(face*224,frame*208))
    (ROOT/'src/graphics/caelum/port-wardrobe.textures').write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    board.save(SOURCE/'guard_registration.png')
    (SOURCE/'REGISTRATION.json').write_text(json.dumps({'issue':423,'poses':POSES,'atlas_boxes':BOXES,'module_sha256':HASHES,'compositions':len(POSES)*4*8},indent=2)+'\n',encoding='utf-8',newline='\n')
    print(f'Registered {len(POSES)*4*8} compositions from {len(HASHES)} shared modules.')

if __name__=='__main__':main()
