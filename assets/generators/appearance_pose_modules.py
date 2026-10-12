"""Technical registration of authored #209 poses, independent of identity.

Only crop, clean alpha, scale and register source paintings. Never articulate
an arm by cutting trousers or roll an upright figure to manufacture a corpse.
"""
from functools import lru_cache
from pathlib import Path
from io import BytesIO
import json
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/appearance_5218'
SPEC=json.loads(Path(__file__).with_name('appearance_catalog.json').read_text())
BOXES={}

def save_png(im,path):
    """Encode once; avoid reopening unchanged assets while Windows indexes them."""
    buffer=BytesIO();im.save(buffer,format='PNG',compress_level=9)
    payload=buffer.getvalue()
    if not path.exists() or path.read_bytes()!=payload:path.write_bytes(payload)

def clean(im):
    im=im.convert('RGBA')
    im.putdata([(r,g,b,a) if a>=32 else (0,0,0,0) for r,g,b,a in im.getdata()])
    return im

@lru_cache(None)
def atlas(name,rows):
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
    assert len(parts)>=rows*8,(name,'connected silhouettes',len(parts),rows*8)
    parts=sorted(sorted(parts,reverse=True)[:rows*8],key=lambda p:p[1][1]+p[1][3])
    boxes=[]
    for row in range(rows):boxes.extend(b for _,b in sorted(parts[row*8:row*8+8],key=lambda p:p[1][0]))
    BOXES[name]=boxes
    return [im.crop(b) for b in boxes]

def authored(view,pose,sex):
    data=pose.get('authored')
    if not data:return None
    kind=data['kind'];row=data['row'];source_view=(-view)%8 if data.get('mirror') else view
    name='sleep_v2.png' if kind=='sleep' else f'{kind}_{"female" if sex else "male"}_v1.png'
    rows=2 if kind=='sleep' else 3 if kind=='death' else 4
    raw=atlas(name,rows)[(sex if kind=='sleep' else row)*8+source_view]
    if data.get('mirror'):raw=raw.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    registration=SPEC['authored_registration'][kind]
    if kind=='sleep':
        target=registration['length'][view]
        scale=target/max(raw.size)
    elif kind=='death' and row==2:
        scale=registration['fallen_length'][view]/raw.width
    else:scale=registration['heights'][row]/raw.height
    im=clean(raw.resize((max(1,round(raw.width*scale)),max(1,round(raw.height*scale))),Image.Resampling.LANCZOS))
    if kind=='sleep':
        # Project the atlas's depth onto the low world-camera elevation.
        # Side views retain their torso thickness; end views foreshorten depth.
        im=clean(im.resize((im.width,round(im.height*registration['body_projection'][view])),Image.Resampling.LANCZOS))
    if kind=='sleep' or (kind=='death' and row==2):
        point=registration['neck'][view]
        collar=(round(point[0]*im.width),round(point[1]*im.height))
        angle=registration['angles'][view]
        x=SPEC['pivot'][0]-im.width//2
    else:
        top=im.getchannel('A').crop((0,0,im.width,max(1,round(im.height*.055))))
        b=top.point(lambda a:255 if a>=128 else 0).getbbox()
        collar=((b[0]+b[2])//2,3)
        angle=0
        x=SPEC['neck'][0]-collar[0]
    lift=registration.get('head_clearance',[0]*8)[view]
    y=SPEC['pivot'][1]-im.height-data.get('lift',0)-lift
    result=Image.new('RGBA',tuple(SPEC['canvas']));result.alpha_composite(im,(x,y))
    return result,(x+collar[0],y+collar[1]),angle

def head_kind(pose):
    return 'supine' if pose.get('authored',{}).get('kind')=='sleep' else 'upright'
