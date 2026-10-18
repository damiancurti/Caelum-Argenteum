"""Check #327 map identity, exact geometry adoption and deployment data."""
from pathlib import Path
import argparse
import hashlib
import json
import struct
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'assets/generators'))
from map_catalogue import map_name
from generate_siege_reinforcements import render


def lumps(path):
    raw = path.read_bytes()
    _, count, offset = struct.unpack_from('<4sii',raw)
    result = {}
    for i in range(count):
        start,size,name = struct.unpack_from('<ii8s',raw,offset+i*16)
        result[name.rstrip(b'\0').decode()] = raw[start:start+size]
    return result


def verify(regenerate=False):
    checks = []
    def check(ok,name):
        assert ok,name
        checks.append(name)
    data=json.loads((ROOT/'assets/map_catalogue/MAPS.json').read_text())['maps']
    expected={v['lump'] for v in data.values()} | {f'CAH{i:03}' for i in range(160)}
    check({p.stem for p in (ROOT/'src/maps').glob('*.wad')}==expected,'Exact current map inventory')
    info=(ROOT/'src/MAPINFO').read_text(encoding='utf-8')
    for v in data.values():
        check(f'map {v["lump"]} ' in info,'MAPINFO '+v['lump'])
        actual=lumps(ROOT/f'src/maps/{v["lump"]}.wad')
        check(next(iter(actual))==v['lump'],'WAD marker '+v['lump'])
        if v['previous']!=v['lump'] and v['lump']!=map_name('port'):
            before=lumps(ROOT/f'assets/map_catalogue/legacy_5428/maps/{v["previous"]}.wad')
            check(actual['TEXTMAP']==before['TEXTMAP'],'Unchanged test geometry '+v['lump'])
    city=lumps(ROOT/'src/maps/MAP03.wad')['TEXTMAP']
    check(hashlib.md5(city).hexdigest()=='bfbf3d4ac39f36e7d61a450dbb47b1a2','Exact author-selected #318 low-sky TEXTMAP')
    check(b'__CA318_LOW' not in city,'No internal zoning marker in packaged map')
    check((ROOT/'src/caelum/data/CaelumReinforcementData.zs').read_bytes()==render(),'Fresh reinforcement data')
    catalogue=(ROOT/'src/caelum/world/CaelumWorldCatalogue.zs').read_text(encoding='utf-8')
    roles={'reservoir':'RESERVOIR','tarot':'TAROT_CHAMBERS','maintenance':'MAINTENANCE','port':'PORT','coast':'COAST','hazards':'HAZARD_GALLERY'}
    for role,location in roles.items():
        check(f'if (id == LOCATION_{location}) return "{map_name(role)}";' in catalogue,'Stable location identity '+role)
    for p in (ROOT/'src/caelum').rglob('*.zs'):
        text=p.read_text(encoding='utf-8')
        check(not any(f'"{old}"' in text for old in ('MAP04','MAP05','MAP06','MAP07','MAP08','CADEV02')),'No obsolete map selector '+p.name)
    provenance=json.loads((ROOT/'assets/map_catalogue/legacy_5428/PROVENANCE.json').read_text())
    for name,digest in provenance['files'].items():
        check(hashlib.sha256((ROOT/'assets/map_catalogue/legacy_5428/maps'/name).read_bytes()).hexdigest()==digest,'Preserved original '+name)
    manifest=json.loads((ROOT/'assets/playtest/EXPORT.json').read_text())
    check(set(manifest['runtime_maps'])=={f'maps/{n}.wad' for n in expected},'Export map allowlist matches normal package')
    if regenerate:
        import generate_coastal_trials as coastal
        import generate_map06_port as portgen
        import generate_city_interiors as interiors
        out=ROOT/'build/issue327-regenerated';out.mkdir(exist_ok=False)
        original=interiors.runtime
        try:
            interiors.runtime=lambda *a,**kw:None
            coastal.generate(out,port_extension=portgen.extend,include_coast=False)
        finally:
            interiors.runtime=original
        check((out/'MAP03.wad').read_bytes()==(ROOT/'src/maps/MAP03.wad').read_bytes(),'Second independent normal generation byte-identical')
    result={'issue':327,'checks':checks,'count':len(checks),'city_textmap_md5':hashlib.md5(city).hexdigest()}
    out=ROOT/'assets/validation_5429/STATIC.json'
    out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(f'{len(checks)} static checks passed.')


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--regenerate',action='store_true')
    verify(p.parse_args().regenerate)
