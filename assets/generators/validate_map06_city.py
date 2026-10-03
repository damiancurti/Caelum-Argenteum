"""Audit #77 geometry and provenance without modifying runtime sources."""
import hashlib
import json
import tempfile
from pathlib import Path
import generate_map06_port as portgen
from generate_port_city import CITY
from generate_coastal_trials import CoastalMap, generate

ROOT = Path(__file__).resolve().parents[2]


def audit():
    checks = []
    def check(ok, label):
        checks.append({'check': label, 'passed': bool(ok)})
        if not ok:
            raise AssertionError(label)
    snapshots = []
    write = CoastalMap.write
    expand = portgen.expand_city
    try:
        CoastalMap.write = lambda port, folder: snapshots.append(port)
        portgen.expand_city = lambda port: None
        generate(ROOT/'build', port_extension=portgen.extend, include_coast=False)
        portgen.expand_city = expand
        generate(ROOT/'build', port_extension=portgen.extend, include_coast=False)
    finally:
        CoastalMap.write = write
        portgen.expand_city = expand
    before, after = snapshots
    c = CITY
    x1,y1,x2,y2 = c['bounds']
    check(x2-x1 == y2-y1 == 96*32, 'Approved 96 by 96 metre urban footprint')
    check({g['name'] for g in c['gates']} == {'north','south','east','west'}, 'Exactly four cardinal city gates')
    check({t['name'] for t in c['towers']} == {'northwest','northeast','southwest','southeast'}, 'Exactly four corner towers')
    check(len(c['buildings']) == 4, 'Exactly four additional buildings')
    check({p:v for p,v in before.cells.items() if p[1]>=2304} ==
          {p:v for p,v in after.cells.items() if p[1]>=2304}, 'Northern battlefield, ram approaches, platforms and retreat boundary unchanged')
    previous = json.loads((ROOT/'assets/map06_port/legacy_4378/LAYOUT.json').read_text())
    check({k:v for k,v in previous.items() if k!='completion_position'} ==
          {k:v for k,v in portgen.D.items() if k!='completion_position'}, 'All accepted siege data retained; only completion-sign placement changed')
    provenance = json.loads((ROOT/'assets/map06_port/legacy_4378/PROVENANCE.json').read_text())
    for name, digest in provenance['files'].items():
        check(hashlib.sha256((ROOT/'assets/map06_port/legacy_4378'/name).read_bytes()).hexdigest()==digest,
              'Exact legacy provenance: '+name)
    for gate in c['gates']:
        gx1,gy1,gx2,gy2 = gate['bounds']
        check(max(gx2-gx1,gy2-gy1)==256, gate['name']+' gate width 256 MU')
        for x in range(gx1,gx2,64):
            for y in range(gy1,gy2,64):
                cell=after.cells[x,y]
                check(cell[0]==0 and after.volumes[cell[4]][0]==c['gate_headroom'], f'{gate["name"]} supported passage {x},{y}')
    for b in c['buildings']:
        check(after.volumes[b['tag']][0]==160, f'Building {b["tag"]} native roof/headroom')
    for thing in before.things:
        check(thing in after.things, f'Retained port actor {thing["type"]} at {thing["x"]},{thing["y"]}')
    hashes=[]
    # Temporary output stays under the workspace and is retained as local QA.
    for iteration in range(2):
        output=Path(tempfile.mkdtemp(prefix='issue77_determinism_',dir=ROOT/'build'))
        generate(output,port_extension=portgen.extend,include_coast=False)
        hashes.append(hashlib.sha256((output/'MAP06.wad').read_bytes()).hexdigest())
    current=hashlib.sha256((ROOT/'src/maps/MAP06.wad').read_bytes()).hexdigest()
    check(hashes[0]==hashes[1]==current,'Two independent generator runs equal the shipped MAP06 byte for byte')
    result={'issue':77,'checks':checks,'map_sha256':current,'determinism':hashes,
            'old_city_metres':[68,76],'new_city_metres':[96,96],
            'native_clearance_evidence':'See native_geometry.log; static cells alone do not prove actor traversal.'}
    out=ROOT/'assets/validation_4379'
    out.mkdir(exist_ok=True)
    (out/'STATIC.json').write_bytes((json.dumps(result,indent=2)+'\n').encode())
    print(f'{len(checks)} static checks passed; MAP06 SHA256 {current}')
    return snapshots


if __name__=='__main__':
    audit()
