"""Register original exhalation atlases without changing their raster pixels."""
from pathlib import Path
import hashlib
import json
from register_carbine_world import rgba, alpha_bounds, separated_cells

ROOT=Path(__file__).resolve().parents[2]
PROFILES={
    'mandinga':('MDBR','mandinga/MNDGA1.png'),
    'zupay':('ZUBR','zupay_colossus/ZUPYA1.png'),
}

def main():
    output='// Generated native clipping of unchanged #135 exhalation artwork.\n'
    records={}
    for name,(prefix,reference_path) in PROFILES.items():
        relative=f'sprites/caelum/demon_breath/{name}.png'
        atlas=ROOT/'src'/relative
        width,height,rows=rgba(atlas)
        rw,rh,ref=rgba(ROOT/'src/sprites/caelum/actors'/reference_path)
        rb=alpha_bounds(ref,(0,0,rw,rh));reference_height=rb[3]-rb[1]+1
        frames=[]
        row_cells=separated_cells([any(a>=128 for a in line[3::4]) for line in rows],4)
        for row,(y1,y2) in enumerate(row_cells):
            cells=separated_cells([any(rows[y][4*x+3]>=128 for y in range(y1,y2)) for x in range(width)],8)
            for column,(x1,x2) in enumerate(cells):
                bounds=alpha_bounds(rows,(x1,y1,x2,y2))
                feet=alpha_bounds(rows,(x1,bounds[3]-5,x2,bounds[3]+1))
                frames.append({'name':f'{prefix}{chr(65+row)}{column+1}',
                    'rect':[x1,y1,x2,y2],'alpha_bounds':bounds,
                    'pivot':[round((feet[0]+feet[2])/2)-x1,bounds[3]+1-y1]})
        scale=sum(f['alpha_bounds'][3]-f['alpha_bounds'][1]+1 for f in frames[:8])/8/reference_height
        for f in frames:
            x1,y1,x2,y2=f['rect'];px,py=f['pivot']
            output+=f'Sprite "{f["name"]}", {x2-x1}, {y2-y1}\n{{\n    XScale {scale:.9f}\n    YScale {scale:.9f}\n    Offset {px}, {py}\n    Patch "{relative}", {-x1}, {-y1}\n}}\n'
        records[name]={'atlas_sha256':hashlib.sha256(atlas.read_bytes()).hexdigest(),
            'reference':reference_path,'reference_alpha_height':reference_height,
            'common_texture_scale':scale,'width':width,'height':height,'frames':frames}
        print(f'{name}: {len(frames)} frames, scale={scale:.9f}, reference={reference_height}')
    (ROOT/'src/graphics/caelum/demon_breath.textures').write_text(output,encoding='utf-8')
    (ROOT/'assets/art_source/demon_breath_515/REGISTRATION.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
