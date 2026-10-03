"""Audit the expanded southern city, authored deployment and exact save layouts."""
import hashlib
import json
import tempfile
from collections import Counter
from pathlib import Path
import generate_map06_port as portgen
from generate_port_city import CITY
from generate_coastal_trials import CoastalMap, generate

ROOT = Path(__file__).resolve().parents[2]

def audit():
    checks=[]
    def check(ok,label):
        checks.append(dict(check=label,passed=bool(ok)))
        if not ok:raise AssertionError(label)
    captures=[];writer=CoastalMap.write
    try:
        CoastalMap.write=lambda p,f:captures.append(p)
        generate(ROOT/'build',include_coast=False)
        generate(ROOT/'build',port_extension=portgen.extend,include_coast=False)
    finally:CoastalMap.write=writer
    original,port=captures;c=CITY;s=portgen.S
    x1,y1,x2,y2=c['bounds']
    check(x2-x1==y2-y1==960*32,'Author-approved 960 by 960 metre city')
    counts=Counter(b['kind'] for b in c['buildings']);counts['house']+=c['retained_houses']
    check(dict(counts)==c['city_totals'] and sum(counts.values())==288,'160 houses, 64 shops, 24 factories, 40 construction sites')
    check(len(c['towers'])==4,'Four traversable corner cannon towers')
    check(len([g for g in c['gates'] if g['name'].startswith('south_')])==6,'Six gates integrated into the southern city wall')
    check({g['name'] for g in c['gates'] if not g['name'].startswith('south_')}=={'north','west','east'},'North and west fortified passages plus the eastern docks')
    check(s['mandingas']==6000 and s['defenders']==600,'Sixfold Mandinga and defender populations; commander remains separate')
    check(portgen.D['command_group_limit']==100,'Author-approved maximum of 100 attackers per command group, including its leader')
    check(len(s['defending_guns'])==36 and s['active_defending_guns']==list(range(12)),'36 defensive guns installed, eight southern and four tower guns active')
    check(len(s['attacking_guns'])==6 and len(s['gate_x'])==6,'Six hostile cannons and six ram lanes unchanged in count')
    check(len(s['guard_positions'])+2*len(s['defending_guns'])==600,'Crew assignments and reserves account for exactly 600 defenders')
    check(s['field_bounds'][3]==y1 and s['exit_y']<s['boss_position'][1]<y1,'Attack and physical retreat belong to the southern field')
    check(len(c['access_stairs'])==len(s['crew_routes'])==36,'A physical access stair and crew route for every defensive gun')
    for i,position in enumerate(s['defending_guns']):
        x,y,z=position;cell=port.cells[(x//64*64,y//64*64)]
        surfaces=[cell[0]]+([port.volumes[cell[4]][1]] if cell[4] else [])
        check(z in surfaces,f'Gun {i} stands on a real floor at its authored height')
    for gate in c['gates']:
        a,b,d,e=gate['bounds']
        check(all(port.cells[x,y][0]==0 and port.cells[x,y][4]==gate['tag'] for x in range(a,d,64) for y in range(b,e,64)),gate['name']+' has a continuous native arch')
    for i,(tag,volume) in enumerate(sorted(port.volumes.items())):
        x=c['control_origin'][0]+(i%c['control_columns'])*128;y=c['control_origin'][1]+(i//c['control_columns'])*128
        check((x,y) not in port.cells and abs(x)<32768 and abs(y)<32768,f'Control sector {tag} is outside playable geometry and fixed-point bounds')
    for thing in original.things:check(thing in port.things,f'Retained campaign actor {thing["type"]} at {thing["x"]},{thing["y"]}')
    for rect in [(-1216,384,-448,1152),(-1088,1280,-512,1984)]:
        a,b,d,e=rect
        check(all(original.cells[x,y]==port.cells[x,y] for x in range(a,d,64) for y in range(b,e,64)),'Original port house and contents retained: '+str(rect))
    for folder in ['legacy_4378','legacy_4379_north']:
        path=ROOT/'assets/map06_port'/folder;provenance=json.loads((path/'PROVENANCE.json').read_text())
        for name,digest in provenance['files'].items():check(hashlib.sha256((path/name).read_bytes()).hexdigest()==digest,'Exact compatibility provenance: '+folder+'/'+name)
    hashes=[]
    for iteration in range(2):
        output=Path(tempfile.mkdtemp(prefix='issue77_south_determinism_',dir=ROOT/'build'))
        generate(output,port_extension=portgen.extend,include_coast=False)
        hashes.append(hashlib.sha256((output/'MAP06.wad').read_bytes()).hexdigest())
    current=hashlib.sha256((ROOT/'src/maps/MAP06.wad').read_bytes()).hexdigest()
    check(hashes[0]==hashes[1]==current,'Two independent generations match the shipped map byte for byte')
    report=dict(issue=77,checks=checks,map_sha256=current,determinism=hashes,city_metres=[960,960],buildings=dict(counts),geometry_cells=len(port.cells),evidence='Static topology does not replace the native traversal, combat and author tests.')
    output=ROOT/'assets/validation_4379/south';output.mkdir(parents=True,exist_ok=True)
    (output/'STATIC.json').write_bytes((json.dumps(report,indent=2)+'\n').encode())
    print(f'{len(checks)} static checks passed; MAP06 SHA256 {current}')
    return captures

if __name__=='__main__':audit()
