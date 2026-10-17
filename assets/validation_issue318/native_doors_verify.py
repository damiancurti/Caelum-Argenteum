"""Independently compare native door additions and deterministic map generation."""
from pathlib import Path
import argparse
import hashlib
import json
import sys
import zipfile
from geometry_verify import groups

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
import generate_map06_port as generator
from generate_coastal_trials import generate

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    out=ROOT/'build'/p.parse_args().directory/'geometry';out.mkdir(parents=True,exist_ok=False)
    generator.interiors.runtime=lambda *args:None
    for name in ('first','second','without-native'):
        def extend(port):
            generator.extend(port)
            if name=='without-native':port.native_city_doors=False
        generate(out/name,port_extension=extend,include_coast=False)
    current=ROOT/'src/maps/MAP06.wad'
    assert digest(current)==digest(out/'first/MAP06.wad')==digest(out/'second/MAP06.wad')
    with zipfile.ZipFile(ROOT/'build/issue318-geometry-04/current/runtime.pk3') as z:
        assert z.read('maps/MAP06.wad')==(out/'without-native/MAP06.wad').read_bytes()
    before=groups(out/'without-native/MAP06.wad');after=groups(current)
    for kind in ('vertex','sector','sidedef','linedef'):
        assert after[kind][:len(before[kind])]==before[kind],kind
    for old,new in zip(before['thing'],after['thing']):
        restored=new.copy()
        if old['type'] in ('18099','31050'):restored.pop('arg4')
        assert restored==old
    added=after['linedef'][len(before['linedef']):]
    assert len(added)==3844
    poly=[l for l in added if 'id' in l];assert len(poly)==3840
    byid={}
    for line in poly:
        byid.setdefault(int(line['arg0']),[]).append(line)
        assert all(line.get(k)=='true' for k in ('twosided','midtex3d','dontpegbottom','playeruse','playeruseback','monsterpush','repeatspecial'))
        assert line['alpha']=='0.0' and not any(k in line for k in ('blocking','blockeverything'))
    assert sorted(byid)==list(range(1,961))
    all_vertices=set()
    for identity,lines in byid.items():
        assert len(lines)==4 and sum(l['special']=='1' for l in lines)==1
        assert all(int(l['id'])==30000+identity for l in lines)
        vertices={int(l['v1']) for l in lines};assert len(vertices)==4 and not vertices&all_vertices
        assert vertices=={int(l['v2']) for l in lines};all_vertices|=vertices
    markers={kind:sorted(int(t['angle']) for t in after['thing'] if t['type']==kind) for kind in ('9300','9301')}
    assert markers['9300']==markers['9301']==list(range(1,961))
    leaves=[t for t in after['thing'] if t['type']=='18099'];assert len(leaves)==960
    assert sorted(int(t['arg4']) for t in leaves)==list(range(1,961))
    report={'deterministic_two_regenerations':True,'sha256':digest(current),
        'without_native_matches_geometry04':True,'original_geometry_prefix_unchanged':True,
        'counts_before':{k:len(v) for k,v in before.items()},'counts_final':{k:len(v) for k,v in after.items()},
        'native_leaves':960,'native_faces':3840,'unique_contours':960,
        'scope':'Static geometry/flags/IDs and deterministic bytes; physical behavior requires native tests.'}
    (out.parent/'NATIVE_GEOMETRY.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
