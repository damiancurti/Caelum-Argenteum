"""Validate the three reference-based combat meshes without changing actor rules."""
from pathlib import Path
import hashlib
import json
import math
import re
import struct
try:
    from .generate_beast_men_models import prepared_design, geometry
except ImportError:
    from generate_beast_men_models import prepared_design, geometry

ROOT=Path(__file__).resolve().parents[2]


def validate(root=ROOT, source_relative='assets/source/art/beast_men_680', model_relative='models/caelum/folklore/beastmen', definition='caelum/data/beast_men_combat.modeldef', mesh_builder=geometry):
    errors=[]
    try:
        source=root/source_relative
        report=json.loads((source/'EXPORT.json').read_text(encoding='utf-8'))
        config=json.loads((source/'ANIMATION.json').read_text(encoding='utf-8'))
        for name,want in report['source_sha256'].items():
            assert hashlib.sha256((root/name).read_bytes()).hexdigest()==want,'Stale source: '+name
        for name,want in report['sha256'].items():
            path=source/name if name.startswith('editable/') else root/'src'/name
            assert hashlib.sha256(path.read_bytes()).hexdigest()==want,'Stale export: '+name
        assert (root/'src/MODELDEF').read_text().count('#include "'+definition+'"')==1,'Expected one native include'
        modeldef=(root/'src'/definition).read_text()
        blocks=re.findall(r'\bModel\s+(\w+)\s*\{([^}]+)\}',modeldef)
        assert [name for name,_ in blocks]==[v['actor'] for v in config['species'].values()],'Only the configured specific creature classes may be bound'
        inherited=json.loads((root/'assets/source/art/pombero_461/ANIMATION.json').read_text())
        assert config['frames']==inherited['frames'],'Inherited combat-state mapping changed'
        for (species,item),(actor,block) in zip(config['species'].items(),blocks):
            info=report['species'][species]
            design=json.loads((root/item['design']).read_text(encoding='utf-8'))
            for shape in design['shapes']:
                if shape['kind']!='loft' or not shape.get('cap',True):continue
                component=dict(design);component['shapes']=[shape]
                mesh=mesh_builder(prepared_design(component));volume=0
                for _,tri in mesh.faces:
                    a,b,c=[mesh.vertices[i] for i in tri]
                    volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
                assert volume>0,'Inverted closed loft: '+species+'/'+shape['part']+'/'+shape['material']
            model_path=root/'src'/model_relative
            if 'textures' in item:
                textures={Path(path).name:root/path for path in item['textures'].values()}
            else:
                textures={species+'.png':root/item['reference'],'materials.png':source/design['atlas']['source_file']}
            for name,original in textures.items():
                assert (model_path/name).read_bytes()==original.read_bytes(),'Changed source texture pixels'
                assert (source/'editable/src'/model_relative/name).read_bytes()==(model_path/name).read_bytes(),'Stale portable texture'
            expected=[(row['sprite'],row['letter'],'0',str(index)) for index,row in enumerate(config['frames'])]
            assert re.findall(r'FrameIndex\s+(\w+)\s+(\w)\s+(\d+)\s+(\d+)',block)==expected,'Incomplete frame mapping'
            assert 'CorrectPixelStretch' in block
            scales=list(map(float,re.search(r'Scale\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)',block).groups()))
            assert max(scales)-min(scales)<1e-10 and abs(scales[0]-info['modeldef_scale'])<1e-9
            blob=(model_path/(species+'.md3')).read_bytes()
            magic,version,_,flags,frames,tags,surfaces,skins,fo,to,so,end=struct.unpack_from('<4sI64s9I',blob)
            assert magic==b'IDP3' and version==15 and frames==len(config['frames']) and tags==0
            assert fo==108 and to==so==fo+frames*56 and end==len(blob)
            bounds=[]
            for index in range(frames):
                values=struct.unpack_from('<10f16s',blob,fo+56*index)
                assert all(math.isfinite(v) for v in values[:10])
                bounds.append((values[:3],values[3:6]))
            fitted=(bounds[0][1][2]-bounds[0][0][2])*scales[0]*info['native_profile']['Scale']
            assert abs(fitted-info['native_profile']['Height'])<.02,'Standing native height changed'
            offset=so;vertices=triangles=0
            for _ in range(surfaces):
                magic,name,flags,nf,ns,nv,nt,tri,skin,uv,xyz,size=struct.unpack_from('<4s64s10I',blob,offset)
                assert magic==b'IDP3' and nf==frames and ns==1 and 0<nv<=4096 and 0<nt<=8192
                assert tri==108 and skin==tri+12*nt and uv==skin+68 and xyz==uv+8*nv and size==xyz+8*nv*nf
                for index in range(nt):
                    indices=struct.unpack_from('<3I',blob,offset+tri+index*12)
                    assert max(indices)<nv and len(set(indices))==3
                shader=struct.unpack_from('<64sI',blob,offset+skin)[0].split(b'\0')[0].decode()
                assert shader in [model_relative+'/'+name for name in textures],shader
                for index in range(nv):
                    assert all(math.isfinite(v) and 0<=v<=1 for v in struct.unpack_from('<2f',blob,offset+uv+8*index))
                for frame in range(frames):
                    for index in range(nv):
                        point=struct.unpack_from('<3hH',blob,offset+xyz+(frame*nv+index)*8)[:3]
                        assert all(bounds[frame][0][axis]-.02<=point[axis]/64<=bounds[frame][1][axis]+.02 for axis in range(3))
                offset+=size;vertices+=nv;triangles+=nt
            assert offset==end and surfaces==len(info['surfaces']) and triangles==info['triangles']
            assert vertices==sum(v['vertices'] for v in info['surfaces'])
            assert info['hierarchical_parts']==len(design['parts'])
            for name,part in design['parts'].items():
                visited=set();current=name
                while current is not None:
                    assert current not in visited,'Cyclic pose hierarchy'
                    visited.add(current);current=design['parts'][current]['parent']
    except (OSError,KeyError,ValueError,AssertionError,struct.error) as exc:
        errors.append('Beast-men combat art: '+(str(exc) or 'Invalid geometry, binding or provenance'))
    return errors


if __name__=='__main__':
    errors=validate();print(json.dumps({'errors':errors}));raise SystemExit(bool(errors))
