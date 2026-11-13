"""Check MD3 bounds, topology, materials and native animation frame coverage."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import zipfile


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--model',type=Path,required=True)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--kind',choices=('nahuelito','pombero'),default='nahuelito')
    parser.add_argument('--report-output',type=Path)
    args=parser.parse_args()
    root=args.model;manifest=json.loads((root/'manifest.json').read_text(encoding='utf-8'))
    blob=(root/f'models/caelum/folklore/{args.kind}/{args.kind}.md3').read_bytes()
    magic,version,_,flags,frames,tags,surfaces,skins,fo,to,so,end=struct.unpack_from('<4sI64s9I',blob)
    assert magic==b'IDP3' and version==15 and frames==40 and tags==0
    assert fo==108 and to==so==fo+frames*56 and end==len(blob)
    bounds=[]
    for index in range(frames):
        values=struct.unpack_from('<10f16s',blob,fo+56*index)
        assert all(math.isfinite(v) for v in values[:10]);bounds.append((values[:3],values[3:6]))
    offset=so;vertices=triangles=0;distinct=[]
    with zipfile.ZipFile(args.runtime) as runtime:
        names=set(runtime.namelist())
        for _ in range(surfaces):
            magic,name,flags,nf,ns,nv,nt,tri,skin,uv,xyz,size=struct.unpack_from('<4s64s10I',blob,offset)
            assert magic==b'IDP3' and nf==frames and ns==1 and 0<nv<=4096 and 0<nt<=8192
            assert tri==108 and skin==tri+12*nt and uv==skin+68 and xyz==uv+8*nv and size==xyz+8*nv*nf
            indices=[]
            for i in range(nt):
                values=struct.unpack_from('<3I',blob,offset+tri+i*12)
                assert max(values)<nv and len(set(values))==3;indices.append(values)
            shader=struct.unpack_from('<64sI',blob,offset+skin)[0].split(b'\0')[0].decode()
            assert (root/shader).is_file() or shader in names,shader
            hashes=[]
            for frame in range(frames):
                data=blob[offset+xyz+8*nv*frame:offset+xyz+8*nv*(frame+1)]
                hashes.append(hashlib.sha256(data).hexdigest())
                for v in range(nv):
                    p=struct.unpack_from('<3hH',data,8*v)[:3]
                    assert all(bounds[frame][0][axis]-.02<=p[axis]/64<=bounds[frame][1][axis]+.02 for axis in range(3))
            distinct.append(len(set(hashes)))
            offset+=size;vertices+=nv;triangles+=nt
    assert offset==end and surfaces==len(manifest['surfaces']) and triangles==manifest['triangles']
    assert min(distinct)>1 and max(distinct)==frames
    definition=(root/'MODELDEF').read_text(encoding='utf-8');states=(root/'ZSCRIPT').read_text(encoding='utf-8')
    for index,frame in enumerate(manifest['frames']):
        sprite=('PBMI' if frame['action']=='idle' else 'PBMW') if args.kind=='pombero' else ('NHAI' if frame['action']=='idle' else 'NHAS')
        letter=chr(65+frame['sample'])
        assert f'FrameIndex {sprite} {letter} 0 {index}' in definition
        assert f'{sprite} {letter} {frame["tics"]};' in states
    report={'passed':True,'subject':args.kind,'frames':frames,'surfaces':surfaces,'vertices':vertices,'triangles':triangles,
            'distinct_frames_per_surface':distinct,'binary_coordinate_checks':vertices*frames,
            'scope':'Binary structure/materials/bounds and non-static animation only; not gameplay behavior or visual acceptance.'}
    (args.report_output or root/'static-results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))


if __name__=='__main__':main()
