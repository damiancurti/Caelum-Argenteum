"""Register unmodified #143 crouched carbine artwork with native clipping."""
from pathlib import Path
import hashlib,json
from register_carbine_world import rgba,alpha_bounds,separated_cells

ROOT=Path(__file__).resolve().parents[2]
def main():
    atlas=ROOT/'src/sprites/caelum/carbine_crouch/atlas.png'
    width,height,rows=rgba(atlas)
    rw,rh,reference=rgba(ROOT/'src/sprites/caelum/domingo/DOIDA1.png')
    rb=alpha_bounds(reference,(0,0,rw,rh));reference_height=rb[3]-rb[1]+1
    frames=[]
    for row,(y1,y2) in enumerate(separated_cells([any(a>=128 for a in line[3::4]) for line in rows],4)):
        columns=separated_cells([any(rows[y][4*x+3]>=128 for y in range(y1,y2)) for x in range(width)],8)
        for column,(x1,x2) in enumerate(columns):
            bounds=alpha_bounds(rows,(x1,y1,x2,y2))
            feet=alpha_bounds(rows,(x1,bounds[3]-5,x2,bounds[3]+1))
            frames.append({'name':f'CAGC{chr(65+row)}{column+1}','rect':[x1,y1,x2,y2],
                'alpha_bounds':bounds,'pivot':[round((feet[0]+feet[2])/2)-x1,bounds[3]+1-y1]})
    scale=sum(f['alpha_bounds'][3]-f['alpha_bounds'][1]+1 for f in frames[:8])/8/(reference_height*0.5)
    output='// Generated: original crouched atlas, native clipping and foot pivots.\n'
    for f in frames:
        x1,y1,x2,y2=f['rect'];px,py=f['pivot']
        output+=f'Sprite "{f["name"]}", {x2-x1}, {y2-y1}\n{{\n    XScale {scale:.9f}\n    YScale {scale:.9f}\n    Offset {px}, {py}\n    Patch "sprites/caelum/carbine_crouch/atlas.png", {-x1}, {-y1}\n}}\n'
    (ROOT/'src/graphics/caelum/carbine_crouch.textures').write_text(output,encoding='utf-8',newline='\r\n')
    report={'source_sha256':hashlib.sha256(atlas.read_bytes()).hexdigest(),'width':width,'height':height,
        'reference_alpha_height':reference_height,'native_crouch_height_factor':0.5,'common_texture_scale':scale,'frames':frames}
    (ROOT/'assets/source/art/carbine_crouch_516/REGISTRATION.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(f'Registered {len(frames)} crouched frames, scale={scale:.9f}, reference={reference_height}.')
if __name__=='__main__':main()
