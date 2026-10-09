"""Register original #136 atlases by native clipping, without changing pixels."""
from pathlib import Path
import hashlib
import json
from register_carbine_world import rgba, alpha_bounds, separated_cells

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'src/graphics/caelum/shotgun'

def cells(path, rows_count, columns):
    width,height,rows=rgba(path)
    result=[]
    row_ranges=separated_cells([any(a>=128 for a in row[3::4]) for row in rows],rows_count)
    for r,(y1,y2) in enumerate(row_ranges):
        # Ignore isolated antialias specks when locating a gutter. Pixels are
        # left untouched; the measured cell is clipped by GZDoom at runtime.
        cols=separated_cells([sum(rows[y][4*x+3]>=128 for y in range(y1,y2))>max(3,(y2-y1)*0.02) for x in range(width)],columns)
        for c,(x1,x2) in enumerate(cols):
            b=alpha_bounds(rows,(x1,y1,x2,y2))
            result.append(dict(row=r,column=c,rect=[x1,y1,x2,y2],bounds=b))
    return result

def main():
    output=['// Generated from original unmodified atlases; native texture clipping.']
    report={}
    def texture(kind,name,file,rect,scale,offset):
        x1,y1,x2,y2=rect
        output.append(f'{kind} "{name}", {x2-x1}, {y2-y1}\n{{\n    XScale {scale:.9f}\n    YScale {scale:.9f}\n    Offset {offset[0]}, {offset[1]}\n    Patch "graphics/caelum/shotgun/{file}", {-x1}, {-y1}\n}}')
    # Shared fixed canvases keep interchangeable hand and weapon layers aligned.
    # Never trim them independently: removed hands must not recenter the gun.
    fp=[];hands=[]
    edges=[0,312,580,876,1156,1448]
    _,_,hand_pixels=rgba(ART/'hands_layer.png')
    for pose in range(7):
        weapon_row=2 if pose==5 else 3 if pose==6 else pose
        hand_row=3 if pose==5 else 2 if pose==6 else pose
        hand_rect=[0,edges[hand_row],362,edges[hand_row+1]]
        hand_bottom=alpha_bounds(hand_pixels,hand_rect)[3]+1
        bottom_padding=hand_rect[3]-hand_bottom
        for tier in range(3):
            rect=[tier*362,edges[weapon_row],(tier+1)*362,edges[weapon_row+1]]
            texture('Sprite',f'SHF{tier+1}{chr(65+pose)}0','weapon_layer.png',rect,2.2,[181,rect[3]-rect[1]-bottom_padding])
            fp.append(dict(pose=pose,tier=tier+1,rect=rect))
        rect=[0,edges[hand_row],362,edges[hand_row+1]]
        texture('Sprite',f'SHHD{chr(65+pose)}0','hands_layer.png',rect,2.2,[181,hand_bottom-rect[1]])
        hands.append(dict(pose=pose,rect=rect))
    icons=cells(ART/'icons.png',2,2)
    for f in icons:
        b=f['bounds'];rect=[b[0],b[1],b[2]+1,b[3]+1];w=rect[2]-rect[0];h=rect[3]-rect[1];c=f['row']*2+f['column']
        name=f'CA_SHOTGUN_T{c+1}' if c<3 else 'CA_SHOTGUN_AMMO'
        texture('Graphic',name,'icons.png',rect,h/(120 if c<3 else 64),[0,0])
        if c in (0,3):texture('Sprite','CSGNA0' if c==0 else 'CSAMA0','icons.png',rect,h/120,[w//2,h])
    world=cells(ART/'world.png',6,8)
    rw,rh,rr=rgba(ROOT/'src/sprites/caelum/domingo/DOIDA1.png');rb=alpha_bounds(rr,(0,0,rw,rh))
    scale=sum(f['bounds'][3]-f['bounds'][1]+1 for f in world[:8])/8/(rb[3]-rb[1]+1)
    for f in world:
        x1,y1,x2,y2=f['rect'];b=f['bounds']
        texture('Sprite',f'SHGW{chr(65+f["row"])}{f["column"]+1}','world.png',f['rect'],scale,[(b[0]+b[2])//2-x1,b[3]+1-y1])
    for file,frames in [('weapon_layer.png',fp),('hands_layer.png',hands),('icons.png',icons),('world.png',world)]:
        report[file]={'sha256':hashlib.sha256((ART/file).read_bytes()).hexdigest(),'frames':frames}
    (ROOT/'src/graphics/caelum/shotgun.textures').write_text('\n'.join(output)+'\n',encoding='utf-8',newline='\r\n')
    (ROOT/'assets/source/art/shotgun_517/REGISTRATION.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Registered 21 weapon layers, 7 shared hand layers, 4 icons, 2 pickups and 48 directional world frames.')

if __name__=='__main__':main()
