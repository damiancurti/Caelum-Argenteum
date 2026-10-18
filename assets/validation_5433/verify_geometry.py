"""Compare #323 against preserved geometry and repeat deterministic generation."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
old=json.loads((ROOT/'assets/map02_maze/legacy_5432/MAP02_MANIFEST.json').read_text())
new=json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text())
before={(v[0],v[1]):v[2:] for v in old['cells']}
after={(v[0],v[1]):v[2:] for v in new['cells']}
assert before.keys()==after.keys()
changed=[p for p in before if before[p]!=after[p]]
half=new['layout']['crusher_panel_half_width'];grid=new['layout']['grid']
bad=[]
for trap in new['traps']:
    if trap['type']!='crusher':continue
    x,y=trap['position'];tid=trap['tid']
    footprint={(px,py) for px in range(x-half,x+half,grid) for py in range(y-half,y+half,grid)}
    assert {p for p,v in after.items() if v[2]==tid}==footprint
    assert all(after[p]==[0,new['layout']['ceiling'],tid,0,False] for p in footprint)
    if {p for p,v in before.items() if v[2]==tid}!=footprint:bad.append(trap)
assert len(bad)==1 and bad[0]['tid']==43921
assert len(changed)==(2*half//grid)**2
assert all(before[p]==[0,new['layout']['ceiling'],2,0,False]
           and after[p]==[0,new['layout']['ceiling'],43921,0,False] for p in changed)
ignored={'layout_revision','layout','cells','upper_cells','things','geometry'}
assert all(old[k]==new[k] for k in old.keys()-ignored)
assert len(old['things'])==len(new['things'])
for a,b in zip(old['things'],new['things']):
    if a.get('id')==44800:
        assert a['arg0']==4 and b['arg0']==5
        assert {k:v for k,v in a.items() if k!='arg0'}=={k:v for k,v in b.items() if k!='arg0'}
    else:assert a==b
upper_a={(r[0],r[1]):r[2:] for r in old['upper_cells']}
upper_b={(r[0],r[1]):r[2:] for r in new['upper_cells']}
assert upper_a.keys()==upper_b.keys()
assert {p for p in upper_a if upper_a[p]!=upper_b[p]}==set(changed)
outputs=['src/maps/MAP02.wad','assets/map02_maze/MAP02_MANIFEST.json',
         'src/caelum/world/CaelumMazeLayout.zs','src/caelum/world/CaelumMazeLootCatalogue.zs']
hashes=lambda:{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in outputs}
first=hashes()
subprocess.run(['python',str(ROOT/'assets/generators/generate_map02_maze.py')],check=True,stdout=subprocess.DEVNULL)
assert hashes()==first
result={'issue':323,'baseline':'6502e4c0','layout_revision':5,
    'changed_cells':changed,'upper_cells_changed_identically':True,
    'other_manifest_content_equal':True,'things_changed_only_revision_marker':True,
    'deterministic_generation':True,'hashes':first,
    'old_geometry':old['geometry'],'new_geometry':new['geometry']}
(HERE/'static.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result))
