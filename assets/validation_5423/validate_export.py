"""Read-only MD3 bounds/registration and deterministic-export parity checks."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct

ROOT=Path(__file__).resolve().parents[2]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('first',type=Path);p.add_argument('second',type=Path)
    a=p.parse_args();files=['domingo.md3','domingo_skin.png','frames.zs','MODELDEF','TEXTURES','domingo_invisible.png','manifest.json']
    for f in files:
        assert (a.first/f).read_bytes()==(a.second/f).read_bytes(),f'Non-deterministic output: {f}'
    manifest=json.loads((a.first/'manifest.json').read_text())
    data=(a.first/'domingo.md3').read_bytes()
    h=struct.unpack_from('<4sI64s9I',data)
    magic,version,_,flags,frames,tags,surfaces,skins,ofs_frames,ofs_tags,ofs_surfaces,size=h
    assert magic==b'IDP3' and version==15 and tags==0 and surfaces==1 and size==len(data)
    surface=struct.unpack_from('<4s64s10I',data,ofs_surfaces)
    _,_,_,surface_frames,surface_skins,verts,triangles,ofs_tri,ofs_skin,ofs_uv,ofs_xyz,ofs_end=surface
    assert surface_frames==frames and surface_skins==1 and ofs_surfaces+ofs_end==size
    assert ofs_xyz+frames*verts*8==ofs_end and ofs_tri+triangles*12==ofs_skin
    assert ofs_uv+verts*8==ofs_xyz and ofs_skin+68==ofs_uv
    for i in range(triangles):
        tri=struct.unpack_from('<3I',data,ofs_surfaces+ofs_tri+i*12)
        assert max(tri)<verts
    for i in range(verts):
        assert all(math.isfinite(v) and 0<=v<=1 for v in struct.unpack_from('<2f',data,ofs_surfaces+ofs_uv+i*8))
    bounds={}
    for name,action in manifest['actions'].items():
        values=[struct.unpack_from('<10f16s',data,ofs_frames+(action['start']+i)*56) for i in range(action['count'])]
        assert all(all(math.isfinite(x) for x in v[:10]) for v in values)
        bounds[name]={'min_z':min(v[2] for v in values),'max_z':max(v[5] for v in values)}
    source=ROOT/manifest['source']
    assert hashlib.sha256(source.read_bytes()).hexdigest()==manifest['source_sha256']
    assert data==(ROOT/'src/models/caelum/domingo/domingo.md3').read_bytes()
    assert (a.first/'frames.zs').read_bytes()==(ROOT/'src/caelum/character/CaelumDomingoPilotFrames.zs').read_bytes()
    print(json.dumps({'deterministic_files':len(files),'frames':frames,'vertices':verts,'triangles':triangles,
                      'surfaces':surfaces,'bytes':size,'md3_sha256':manifest['md3_sha256'],'bounds':bounds},indent=2))

if __name__=='__main__':main()
