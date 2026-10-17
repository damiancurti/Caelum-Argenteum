"""Verify authored house footprints, private links and deterministic WAD output."""
from pathlib import Path
import argparse
import hashlib
import json
import sys
from geometry_probe import read_wad, parse

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'assets/generators'))
import generate_house_hubs as hubs


def groups(path):
    return parse(dict(read_wad(path))['TEXTMAP'].decode())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory', required=True)
    args = p.parse_args()
    out = ROOT/'build'/args.directory
    out.mkdir(parents=True, exist_ok=True)
    city = groups(ROOT/'src/maps/MAP06.wad')
    homes = hubs.interiors.houses(hubs.CITY)
    edges = []
    for line in city['linedef']:
        if 'sideback' not in line:
            continue
        floors = [int(city['sector'][int(city['sidedef'][int(line[key])]['sector'])]['heightfloor'])
                  for key in ('sidefront', 'sideback')]
        if max(floors)!=hubs.interiors.DATA['height'] or min(floors)>=max(floors):
            continue
        points = [tuple(int(city['vertex'][int(line[key])][axis]) for axis in ('x','y'))
                  for key in ('v1','v2')]
        edges.append(points)
    for house in homes:
        x,y,x2,y2 = house['bounds']
        for axis,fixed,low,high in ((0,x,y,y2),(0,x2,y,y2),(1,y,x,x2),(1,y2,x,x2)):
            intervals = sorted((max(low,min(a[1-axis],b[1-axis])),min(high,max(a[1-axis],b[1-axis])))
                               for a,b in edges if a[axis]==b[axis]==fixed
                               and max(a[1-axis],b[1-axis])>low and min(a[1-axis],b[1-axis])<high)
            cursor=low
            for start,end in intervals:
                assert start<=cursor, (house['id'],axis,fixed,cursor,start)
                cursor=max(cursor,end)
            assert cursor==high, (house['id'],axis,fixed,cursor,high)
    portals = [t for t in city['thing'] if int(t['type'])==hubs.DATA['portal_editor']]
    assert sorted(int(t['arg0']) for t in portals)==list(range(len(homes)))
    starts = [t for t in city['thing'] if t['type']=='1' and int(t.get('arg0','0'))>0]
    assert sorted(int(t['arg0']) for t in starts)==list(range(1,len(homes)+1))
    signs = [t for t in city['thing'] if int(t['type'])==hubs.DATA['sign_editor']]
    shops = [b for b in hubs.CITY['buildings'] if b['kind']=='shop']
    assert len(signs)==len(shops)==64
    assert [int(t['arg0']) for t in signs]==[i%6 for i in range(len(shops))]
    generated = out/'regenerated'
    assert not generated.exists(), 'Use a new evidence directory'
    hubs.generate(generated)
    interiors=[]
    for index in range(len(homes)):
        name=hubs.map_name(index)
        source=ROOT/'src/maps'/f'{name}.wad'
        assert source.read_bytes()==(generated/source.name).read_bytes(), name
        data=groups(source)
        assert len(data['sector'])==5, name
        links=[t for t in data['thing'] if int(t['type'])==hubs.DATA['portal_editor']]
        assert len(links)==1 and int(links[0]['arg0'])==index and links[0]['arg1']=='1', name
        assert sum(t['type']=='18099' for t in data['thing'])==4, name
        interiors.append({'map':name,'sha256':digest(source),'counts':{k:len(v) for k,v in data.items()}})
    report={'city_sha256':digest(ROOT/'src/maps/MAP06.wad'),
            'counts':{k:len(v) for k,v in city.items()},'houses':len(homes),
            'exact_original_outer_boundaries':True,'roof_height':hubs.interiors.DATA['height'],
            'portals':len(portals),'return_starts':len(starts),'shop_signs':len(signs),
            'interior_byte_regeneration_matches':True,'interiors':interiors,
            'scope':'Static geometry/data/bytes; native passage and playability require separate evidence.'}
    (out/'HOUSE_GEOMETRY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k!='interiors'},indent=2))


if __name__=='__main__':
    main()
