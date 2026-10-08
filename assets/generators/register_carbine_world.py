"""Register unmodified AI artwork with native TEXTURES clipping and pivots.

This utility never writes raster pixels. PNG decoding only measures alpha;
the original atlas is packaged byte-for-byte and GZDoom clips its frames.
"""
from pathlib import Path
import hashlib
import json
import struct
import zlib

ROOT=Path(__file__).resolve().parents[2]
ATLAS=ROOT/'src/sprites/caelum/carbine_world/atlas.png'


def rgba(path):
    data=path.read_bytes();width,height,depth,kind,_,_,interlace=struct.unpack('>IIBBBBB',data[16:29])
    assert depth==8 and kind==6 and interlace==0
    chunks=[];pos=8
    while pos<len(data):
        size=struct.unpack('>I',data[pos:pos+4])[0]
        if data[pos+4:pos+8]==b'IDAT':chunks.append(data[pos+8:pos+8+size])
        pos+=12+size
    raw=zlib.decompress(b''.join(chunks));stride=width*4;previous=bytearray(stride);rows=[]
    for y in range(height):
        begin=y*(stride+1);kind=raw[begin];row=bytearray(raw[begin+1:begin+1+stride])
        for x in range(stride):
            left=row[x-4] if x>=4 else 0;up=previous[x];corner=previous[x-4] if x>=4 else 0
            if kind==1:predict=left
            elif kind==2:predict=up
            elif kind==3:predict=(left+up)//2
            elif kind==4:
                p=left+up-corner;dist=[abs(p-left),abs(p-up),abs(p-corner)]
                predict=(left,up,corner)[dist.index(min(dist))]
            else:assert kind==0;predict=0
            row[x]=(row[x]+predict)&255
        rows.append(row);previous=row
    return width,height,rows


def alpha_bounds(rows,rect):
    x1,y1,x2,y2=rect;points=[]
    for y in range(y1,y2):
        points.extend((x,y) for x in range(x1,x2) if rows[y][4*x+3]>=128)
    assert points
    return min(x for x,y in points),min(y for x,y in points),max(x for x,y in points),max(y for x,y in points)


def separated_cells(occupied, expected):
    """Clip at measured transparent gaps, not an assumed uniform AI grid."""
    bands=[];start=None
    for index,value in enumerate(occupied+[False]):
        if value and start is None:start=index
        if not value and start is not None:bands.append((start,index-1));start=None
    assert len(bands)==expected, (expected,bands)
    cuts=[0]+[(left[1]+right[0]+1)//2 for left,right in zip(bands,bands[1:])]+[len(occupied)]
    return list(zip(cuts,cuts[1:]))


def main():
    width,height,rows=rgba(ATLAS)
    rw,rh,reference=rgba(ROOT/'src/sprites/caelum/domingo/DOIDA1.png')
    rb=alpha_bounds(reference,(0,0,rw,rh));reference_height=rb[3]-rb[1]+1
    frames=[]
    row_cells=separated_cells([any(a>=128 for a in line[3::4]) for line in rows],6)
    for row,(y1,y2) in enumerate(row_cells):
        column_cells=separated_cells([any(rows[y][4*x+3]>=128 for y in range(y1,y2)) for x in range(width)],8)
        for column,(x1,x2) in enumerate(column_cells):
            rect=[x1,y1,x2,y2]
            bounds=alpha_bounds(rows,rect)
            feet=alpha_bounds(rows,(rect[0],bounds[3]-5,rect[2],bounds[3]+1))
            frames.append({'name':f'CAGN{chr(65+row)}{column+1}','rect':rect,'alpha_bounds':bounds,
                           'pivot':[round((feet[0]+feet[2])/2)-rect[0],bounds[3]+1-rect[1]]})
    # One common scale preserves relative pose sizes. Match idle body height.
    scale=sum(f['alpha_bounds'][3]-f['alpha_bounds'][1]+1 for f in frames[:8])/8/reference_height
    output='// Generated: unchanged atlas, native clipping and measured foot pivots.\n'
    for f in frames:
        x1,y1,x2,y2=f['rect'];px,py=f['pivot']
        output+=f'Sprite "{f["name"]}", {x2-x1}, {y2-y1}\n{{\n    XScale {scale:.9f}\n    YScale {scale:.9f}\n    Offset {px}, {py}\n    Patch "sprites/caelum/carbine_world/atlas.png", {-x1}, {-y1}\n}}\n'
    (ROOT/'src/graphics/caelum/carbine_world.textures').write_text(output,encoding='utf-8')
    manifest={'source_sha256':hashlib.sha256(ATLAS.read_bytes()).hexdigest(),'width':width,'height':height,
              'reference_alpha_height':reference_height,'common_texture_scale':scale,'frames':frames}
    (ROOT/'assets/source/art/carbine_world_513/REGISTRATION.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(f'Registered {len(frames)} original frames; scale {scale:.9f}; PNG bytes unchanged.')


if __name__=='__main__':main()
