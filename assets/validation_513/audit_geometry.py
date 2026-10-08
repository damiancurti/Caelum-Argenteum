"""Read authoritative city cells and verify #133 topology and determinism."""
import hashlib
import json
from collections import Counter,deque
from pathlib import Path
import sys
import tempfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
import generate_map06_port as portgen
import generate_city_interiors as interior
from generate_coastal_trials import CoastalMap,generate
from generate_port_city import CITY


def main():
    results=[]
    def check(value,label):
        results.append({'check':label,'passed':bool(value)})
        if not value:raise AssertionError(label)
    captured=[];writer=CoastalMap.write
    try:
        CoastalMap.write=lambda port,path:captured.append(port)
        generate(ROOT/'build',port_extension=portgen.extend,include_coast=False)
    finally:CoastalMap.write=writer
    port=captured[0];data=interior.DATA;houses=interior.houses(CITY)
    counts=Counter(b['kind'] for b in CITY['buildings']);counts['house']+=2
    check(dict(counts)==CITY['city_totals'],'Original 160/64/24/40 city building counts')
    def walkable(x,y,height=57.6):
        v=port.cells.get((x//64*64,y//64*64))
        return v is not None and v[0]==0 and (not v[4] or port.volumes[v[4]][0]>=height)
    area=Counter()
    for name,(a,b,c,d) in data['rooms'].items():area[name]=(c-a)*(d-b)
    for name,rect in zip(('living','living','bedroom'),[data['entrance'],*data['doorways']]):
        a,b,c,d=rect;area[name]+=(c-a)*(d-b)
    percentages={name:value/sum(area.values())*100 for name,value in area.items()}
    check(area=={'living':503808,'bedroom':253952,'bathroom':81920},'Measured usable areas include assigned threshold/internal circulation')
    check(abs(percentages['living']-60)<1e-9 and abs(percentages['bedroom']-30)<0.25 and abs(percentages['bathroom']-10)<0.25,'60/30/10 allocation with <=0.25 percentage-point grid rounding')
    for i,house in enumerate(houses):
        x,y,x2,y2=house['bounds'];seen=set();start=(x+800,y+384);pending=deque([start])
        while pending:
            px,py=pending.popleft();cell=(px//64*64,py//64*64)
            if cell in seen or not(x<=cell[0]<x2+256 and y<=cell[1]<y2) or not walkable(*cell):continue
            seen.add(cell)
            pending.extend((cell[0]+dx,cell[1]+dy) for dx,dy in ((64,0),(-64,0),(0,64),(0,-64)))
        for name,rect in data['rooms'].items():
            a,b,c,d=rect
            check(all((x+px,y+py) in seen for px in range(a,c,64) for py in range(b,d,64)),f'House {i}: connected usable {name} floor')
        check((x+1024,y+384) in seen,f'House {i}: exterior threshold connected')
        doors=[t for t in port.things if t['type']==18099 and t.get('arg0',t.get('args',[0])[0] if 'args' in t else 0)==data['door_group_base']+house['id']]
        # UDMF source stores individual arg fields; fall back to geometric identity.
        if not doors:doors=[t for t in port.things if t['type']==18099 and t['x']==x+928 and y+320<=t['y']<=y+448]
        check(len(doors)==2,f'House {i}: two native hinged leaves')
        for ox,oy,oz in data['occupancy']:check(walkable(x+ox,y+oy),f'House {i}: unobstructed housing cell')
    factories=[b for b in CITY['buildings'] if b['kind']=='factory']
    for i,b in enumerate(factories):
        profile=data['factory_profiles'][i%len(data['factory_profiles'])]
        for kind,(dx,dy) in zip(profile['stations'],data['station_positions']):
            check(walkable(b['bounds'][0]+dx,b['bounds'][1]+dy,72),f'Factory {i}: {kind} on usable floor')
        check(all(abs(data['station_positions'][j+1][0]-data['station_positions'][j][0])<=128 for j in range(len(profile['stations'])-1)),f'Factory {i}: contiguous native workstation network')
    for i,b in enumerate(b for b in CITY['buildings'] if b['kind']=='shop'):
        dx,dy=data['vendor_offset'];check(walkable(b['bounds'][0]+dx,b['bounds'][1]+dy),f'Shop {i}: vendor on usable floor clear of counter')
    legacy=ROOT/'assets/map06_port/legacy_512/MAP06.wad'
    check(hashlib.sha256(legacy.read_bytes()).hexdigest()=='84f0c18fdb4be7a91eff146845f78dda5082d5b0c9d996928f0652d7c6fc7efd','Exact accepted 5.1.2 layout retained')
    generated=[]
    for run in range(2):
        folder=Path(tempfile.mkdtemp(prefix='ca133_geometry_',dir=ROOT/'build'))
        generate(folder,port_extension=portgen.extend,include_coast=False)
        generated.append(hashlib.sha256((folder/'MAP06.wad').read_bytes()).hexdigest())
    current=hashlib.sha256((ROOT/'src/maps/MAP06.wad').read_bytes()).hexdigest()
    check(generated[0]==generated[1]==current,'Two independent generations match shipped MAP06 byte for byte')
    report={'issue':133,'map_sha256':current,'usable_floor_map_units_squared':dict(area),'percentages':percentages,'building_counts':dict(counts),'checks':results,'limits':'Static topology does not prove actor traffic, interactions or author visual acceptance.'}
    (Path(__file__).parent/'GEOMETRY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'{len(results)} geometry checks passed; MAP06 {current}')


if __name__=='__main__':main()
