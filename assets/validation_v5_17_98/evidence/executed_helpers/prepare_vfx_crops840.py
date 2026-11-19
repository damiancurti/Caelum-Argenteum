"""Prepare a lossless projectile-atlas clipping candidate without production edits."""
from pathlib import Path
import hashlib,io,json,re,struct,zlib,zipfile
from PIL import Image
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
out=root/'build/issue840-crops01';out.mkdir(exist_ok=False)
src=root/'src';atlas=src/'graphics/caelum/vfx/projectiles.png'
im=Image.open(atlas);assert im.mode=='RGBA';im.load()
texture_path='graphics/caelum/vfx/elemental.textures'
original=(src/texture_path).read_bytes();text=original.decode('utf-8')
pattern=re.compile(r'(Sprite "(\w+)", (\d+), (\d+) \{[^\n]*?)(Patch "graphics/caelum/vfx/projectiles.png", (-?\d+), (-?\d+))( \})')
members={};frames=[]
def sha(b):return hashlib.sha256(b).hexdigest()
def png(width,height,pixels):
    def chunk(kind,data):return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
    raw=b''.join(b'\0'+pixels[y*width*4:(y+1)*width*4] for y in range(height))
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(raw,9))+chunk(b'IEND',b'')
def replace(m):
    name=m[2];w,h=int(m[3]),int(m[4]);x,y=-int(m[6]),-int(m[7])
    assert 0<=x<x+w<=im.width and 0<=y<y+h<=im.height
    pixels=im.crop((x,y,x+w,y+h)).tobytes();data=png(w,h,pixels)
    assert Image.open(io.BytesIO(data)).tobytes()==pixels and png(w,h,pixels)==data
    path=f'graphics/caelum/vfx/projectile_frames/{name}.png';members[path]=data
    updated=m[1]+f'Patch "{path}", 0, 0'+m[8]
    assert updated.replace(f'Patch "{path}", 0, 0',m[5])==m[0]
    frames.append(dict(name=name,rect=[x,y,x+w,y+h],path=path,rgba_sha256=sha(pixels),png_sha256=sha(data),bytes=len(data)))
    return updated
updated,count=pattern.subn(replace,text);assert count==36
members[texture_path]=updated.encode('utf-8')
with zipfile.ZipFile(out/'crops.pk3','x') as z:
    for path,data in sorted(members.items()):
        p=out/'source'/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
        z.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data)
manifest=dict(issue=840,source_atlas_sha256=sha(atlas.read_bytes()),original_bindings_sha256=sha(original),candidate_bindings_sha256=sha(members[texture_path]),candidate_overlay_sha256=sha((out/'crops.pk3').read_bytes()),frames=frames,unchanged='Sprite names, dimensions, scales, pivots, order and status bindings; atlas retained for model consumers. Only projectile patch source and its origin change.',qualification='Private candidate. Exact decoded RGBA crop and repeated PNG encoding verified; native compositing/render equivalence and measured effect remain to be checked.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in manifest.items() if k!='frames'},indent=2))
