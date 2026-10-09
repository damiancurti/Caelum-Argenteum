"""Extract the author's original rat death poses without repainting foreground RGB.

Requires Pillow 11.3.0, numpy 2.2.6 and opencv-python-headless 4.12.0.88.
Optional local dependencies can be supplied through PYTHONPATH.
"""
from pathlib import Path
import hashlib, json, re
import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/animal_recovery_518'
OUT = ROOT / 'src/graphics/caelum/rat_original'
BEGIN = '// BEGIN GENERATED RAT DEATH REPAIR 518'
END = '// END GENERATED RAT DEATH REPAIR 518'


def extract(source, rect, preserve=()):
    image = source.crop(rect).convert('RGB')
    rgb = np.array(image)
    h, w = rgb.shape[:2]
    mask = np.full((h, w), cv2.GC_PR_FGD, np.uint8)
    mask[:3,:] = mask[-3:,:] = cv2.GC_BGD
    mask[:,:3] = mask[:,-3:] = cv2.GC_BGD
    known = []
    for spec in preserve:
        old = np.array(Image.open(ROOT/'src/sprites/caelum/actors/giant_rat'/spec['file']))[:,:,3]
        ox,oy = spec['origin']
        a,b = max(rect[0],ox),max(rect[1],oy)
        c,d = min(rect[2],ox+old.shape[1]),min(rect[3],oy+old.shape[0])
        if a>=c or b>=d:continue
        region = old[b-oy:d-oy,a-ox:c-ox]
        target = (slice(b-rect[1],d-rect[1]),slice(a-rect[0],c-rect[0]))
        mask[target] = np.where(region>200,cv2.GC_FGD,np.where(region==0,cv2.GC_BGD,cv2.GC_PR_FGD))
        known.append((target,region))
    cv2.setRNGSeed(137)
    cv2.grabCut(cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR), mask, (3,3,w-6,h-6),
                np.zeros((1,65), np.float64), np.zeros((1,65), np.float64),
                8, cv2.GC_INIT_WITH_MASK)
    alpha = np.where((mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD), 255, 0).astype(np.uint8)
    for target,region in known:
        alpha[target] = region
    assert alpha.any()
    result = Image.fromarray(np.dstack((rgb, alpha)))
    ys,xs = np.where(alpha>=128)
    bounds = (int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1))
    assert bounds[0] >= 2 and bounds[1] >= 2 and bounds[2] <= w-2 and bounds[3] <= h-2, (rect,bounds)
    return result, bounds


def main():
    cv2.setNumThreads(1)
    data = json.loads((SOURCE/'DESIGN.json').read_text(encoding='utf-8'))['rat']
    source = Image.open(SOURCE/data['source'])
    OUT.mkdir(parents=True, exist_ok=True)
    reference, rb = extract(source, data['reference'])
    old = Image.open(ROOT/'src/sprites/caelum/actors/giant_rat/RATGA1.png')
    ob = old.getbbox()
    scale = (rb[3]-rb[1])/(ob[3]-ob[1])
    records = []
    poses = []
    for i, rect in enumerate(data['frames']):
        image, bounds = extract(source, rect, data['preserve_death_alpha'][i])
        name = f'death-{i}.png'
        image.save(OUT/name, compress_level=9)
        poses.append((image.size, bounds, name))
    lines = []
    for frame, i in zip(data['names'], data['state_pose_indices']):
        (w,h), bounds, name = poses[i]
        pivot = [(bounds[0]+bounds[2])//2,bounds[3]]
        sprite = 'RATG'+frame+'0'
        lines.append(f'Sprite "{sprite}", {w}, {h} {{ XScale {scale:.9f} YScale {scale:.9f} Offset {pivot[0]}, {pivot[1]} Patch "graphics/caelum/rat_original/{name}", 0, 0 }}')
        records.append({'sprite':sprite,'source_rect':data['frames'][i],'source_pose':i,'file':name,
                        'bounds':bounds,'pivot':pivot,'scale':scale,'sha256':hashlib.sha256((OUT/name).read_bytes()).hexdigest()})
    for sprite, spec in data['border_repairs'].items():
        rect = spec['rect']
        image, bounds = extract(source, rect, [{'file':sprite+'.png','origin':spec['original_origin']}])
        name = sprite+'.png'
        image.save(OUT/name, compress_level=9)
        w,h = image.size
        # Retain the old grAb anchor relative to the recovered source coordinates.
        origin = spec['original_origin']
        anchor = spec['original_anchor']
        pivot = [anchor[0]+origin[0]-rect[0],anchor[1]+origin[1]-rect[1]]
        lines.append(f'Sprite "{sprite}", {w}, {h} {{ Offset {pivot[0]}, {pivot[1]} Patch "graphics/caelum/rat_original/{name}", 0, 0 }}')
        records.append({'sprite':sprite,'source_rect':rect,'file':name,'bounds':bounds,
                        'pivot':pivot,'scale':1,'sha256':hashlib.sha256((OUT/name).read_bytes()).hexdigest()})
    target = ROOT/'src/TEXTURES'
    text = target.read_text(encoding='utf-8')
    assert text.count(BEGIN) == text.count(END) == 1
    text = text[:text.index(BEGIN)] + BEGIN+'\n'+'\n'.join(lines)+'\n'+END + text[text.index(END)+len(END):]
    target.write_text(text,encoding='utf-8')
    (SOURCE/'REGISTRATION.json').write_text(json.dumps({'dependencies':{'Pillow':Image.__version__,'numpy':np.__version__,'opencv':cv2.__version__},'reference_bounds':rb,'runtime_reference_bounds':ob,'frames':records},indent=2)+'\n',encoding='utf-8')
    print('Recovered seven rat death poses and nine border cuts; existing states/timing preserved.')


if __name__ == '__main__':
    main()
