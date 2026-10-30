"""Check immutable prisoner alpha and inspect native guard compositions."""
from pathlib import Path
import hashlib
import json
import re
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent

def main():
    count=0;changed=0
    for p in sorted((ROOT/'src/graphics/caelum/port_wardrobe/prisoners').glob('*/*.png')):
        original=ROOT/'src/sprites/caelum/prisoners'/p.parent.name/p.name
        a=Image.open(original).convert('RGBA');b=Image.open(p).convert('RGBA')
        assert a.size==b.size and a.getchannel('A').tobytes()==b.getchannel('A').tobytes(),p
        count+=1;changed+=a.tobytes()!=b.tobytes()
    source=(ROOT/'src/graphics/caelum/port-wardrobe.textures').read_text()
    names=re.findall(r'Sprite "([^"]+)"',source);assert len(names)==544 and len(set(names))==544
    board=Image.new('RGBA',(8*224,4*208),(35,38,43,255))
    for row,frame in enumerate('AJIO'):
        for view in range(8):
            entry=re.search(r'Sprite "V9G0'+frame+str(view+1)+r'".*?(?=\nSprite |\Z)',source,re.S).group(0)
            im=Image.new('RGBA',(224,208))
            for path,x,y,options in re.findall(r'Patch "([^"]+)", (-?\d+), (-?\d+)([^\n]*)',entry):
                layer=Image.open(ROOT/'src'/path).convert('RGBA');blend=re.search(r'Blend (\d+), (\d+), (\d+)',options)
                if blend:
                    rgb=tuple(map(int,blend.groups()));layer.putdata([(*(round(c*k/255) for c,k in zip(px[:3],rgb)),px[3]) for px in layer.getdata()])
                im.alpha_composite(layer,(int(x),int(y)))
            board.alpha_composite(im,(view*224,row*208))
    board.save(HERE/'guard-eight-views.png')
    result={'exact_prisoner_alpha':count,'changed_cloth_frames':changed,'unique_guard_compositions':len(names),
        'textures_sha256':hashlib.sha256(source.encode()).hexdigest()}
    (HERE/'art-check.json').write_text(json.dumps(result,indent=2)+'\n')
    print(result)

if __name__=='__main__':main()
