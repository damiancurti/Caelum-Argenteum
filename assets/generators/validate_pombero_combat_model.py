"""Check the installed combat model, inherited frame coverage and original pixels."""
from pathlib import Path
import hashlib
import json
import math
import re
import struct

ROOT=Path(__file__).resolve().parents[2]


def validate(root=ROOT, kind='pombero', issue=461, original_textures=None):
    errors=[]
    try:
        source=root/'assets/source/art'/f'{kind}_{issue}'
        model_path=root/'src/models/caelum/folklore'/f'{kind}{issue}'
        report=json.loads((source/'EXPORT.json').read_text())
        config=json.loads((source/'ANIMATION.json').read_text())
        for name,want in report['source_sha256'].items():
            if hashlib.sha256((root/name).read_bytes()).hexdigest()!=want:errors.append('Stale source: '+name)
        for name,want in report['sha256'].items():
            path=(source/name if '/' not in name else root/'src'/name)
            if hashlib.sha256(path.read_bytes()).hexdigest()!=want:errors.append('Stale export: '+name)
        design_path=root/config['source_design'];design=json.loads(design_path.read_text())
        original=original_textures
        if original is None:
            original={'materials.png':design['atlas']['source_file'],'dark.png':'dark.png'}
            original.update({Path(row['path']).name:row['source_file'] for row in design['materials'].values() if 'source_file' in row})
        for name,original_name in original.items():
            if (model_path/name).read_bytes()!=(design_path.parent/original_name).read_bytes():errors.append('Original texture changed: '+name)
        modeldef=(root/'src/caelum/data'/(kind+'_combat.modeldef')).read_text()
        if (root/'src/MODELDEF').read_text().count('#include "caelum/data/'+kind+'_combat.modeldef"')!=1:errors.append('Expected one native model include')
        if re.findall(r'\bModel\s+(\w+)\s*\{',modeldef)!=[config['actor']]:errors.append('Binding must be specific to '+kind)
        for index,row in enumerate(config['frames']):
            if f'FrameIndex {row["sprite"]} {row["letter"]} 0 {index}' not in modeldef:errors.append('Missing inherited frame binding')
        blob=(model_path/(kind+'.md3')).read_bytes()
        magic,version,_,flags,frames,tags,surfaces,skins,fo,to,so,end=struct.unpack_from('<4sI64s9I',blob)
        assert magic==b'IDP3' and version==15 and frames==len(config['frames']) and tags==0
        assert fo==108 and to==so==fo+frames*56 and end==len(blob)
        bounds=[]
        for index in range(frames):
            values=struct.unpack_from('<10f16s',blob,fo+56*index)
            assert all(math.isfinite(v) for v in values[:10]);bounds.append((values[:3],values[3:6]))
        offset=so;vertices=triangles=0
        for _ in range(surfaces):
            magic,name,flags,nf,ns,nv,nt,tri,skin,uv,xyz,size=struct.unpack_from('<4s64s10I',blob,offset)
            assert magic==b'IDP3' and nf==frames and ns==1 and 0<nv<=4096 and 0<nt<=8192
            assert tri==108 and skin==tri+12*nt and uv==skin+68 and xyz==uv+8*nv and size==xyz+8*nv*nf
            for index in range(nt):
                indices=struct.unpack_from('<3I',blob,offset+tri+index*12)
                assert max(indices)<nv and len(set(indices))==3
            shader=struct.unpack_from('<64sI',blob,offset+skin)[0].split(b'\0')[0].decode()
            assert (root/'src'/shader).is_file(),shader
            for frame in range(frames):
                for index in range(nv):
                    point=struct.unpack_from('<3hH',blob,offset+xyz+(frame*nv+index)*8)[:3]
                    assert all(bounds[frame][0][axis]-.02<=point[axis]/64<=bounds[frame][1][axis]+.02 for axis in range(3))
            offset+=size;vertices+=nv;triangles+=nt
        assert offset==end and surfaces==len(report['surfaces']) and triangles==report['triangles']
    except (OSError,KeyError,ValueError,AssertionError,struct.error) as exc:errors.append(str(exc) or 'Invalid native binary structure or bounds')
    return [kind.title()+' combat art: '+error for error in errors]


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
