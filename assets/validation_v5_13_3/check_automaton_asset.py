"""Validate native MD3 structure and planted lower limbs in stationary actions."""
from pathlib import Path
import json
import struct
import sys

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
import generate_tarot_automaton as art


def main():
    design=json.loads((art.SOURCE/'DESIGN.json').read_bytes())
    parts=art.create_parts(design);poses,labels=art.poses(parts,design)
    neutral=poses[labels.index(('idle',0))]
    lower=('left_thigh','right_thigh','left_shin','right_shin')
    checked=0
    for pose,(action,_) in zip(poses,labels):
        if action not in ('attack','guard'):continue
        for name in lower:
            if pose[name]!=neutral[name]:raise AssertionError(f'{action} moves planted lower limb {name}')
        checked+=1
    blob=(ROOT/art.RUNTIME/'automaton.md3').read_bytes()
    magic,version,_,flags,frames,tags,surfaces,skins,fo,to,so,end=struct.unpack_from('<4sI64s9I',blob)
    assert magic==b'IDP3' and version==15 and frames==len(poses) and tags==0
    assert fo==108 and to==so==fo+frames*56 and end==len(blob)
    offset=so;vertices=triangles=0
    for _ in range(surfaces):
        magic,name,flags,nf,ns,nv,nt,tri,skin,uv,xyz,size=struct.unpack_from('<4s64s10I',blob,offset)
        assert magic==b'IDP3' and nf==frames and ns==1 and 0<nv<=4096 and 0<nt<=8192
        assert tri==108 and skin==tri+12*nt and uv==skin+68 and xyz==uv+8*nv and size==xyz+8*nv*nf
        for i in range(nt):assert max(struct.unpack_from('<3I',blob,offset+tri+i*12))<nv
        shader=struct.unpack_from('<64sI',blob,offset+skin)[0].split(b'\0')[0].decode()
        assert (ROOT/'src'/shader).is_file(),shader
        offset+=size;vertices+=nv;triangles+=nt
    assert offset==end and surfaces==4
    print(json.dumps(dict(passed=True,frames=frames,surfaces=surfaces,vertices=vertices,triangles=triangles,stationary_poses_with_planted_legs=checked)))


if __name__=='__main__':main()
