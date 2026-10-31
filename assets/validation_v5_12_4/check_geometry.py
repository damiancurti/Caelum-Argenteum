"""Check deterministic venue output, connected corridors and approved extents."""
from pathlib import Path
import hashlib, json, sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
from generate_arenas import generate, maze_cells

paths=[ROOT/'src/maps/CARING.wad',ROOT/'src/maps/CASEWER.wad',ROOT/'src/caelum/data/CaelumArenaData.zs',ROOT/'src/caelum/data/arenas.mapinfo',ROOT/'src/models/caelum/world/arenas/ring_frame.obj']
before=[p.read_bytes() for p in paths];generate();assert before==[p.read_bytes() for p in paths]
data=json.loads((ROOT/'assets/arenas/VENUES.json').read_text());maze=data['venues'][1]
assert 0<data['ring_frame_visual_only']['editor_number']<32768
size=maze['size_m']//maze['passage_m'];cells=maze_cells(size,maze['seed'])
pending=[next(iter(cells))];seen=set(pending)
while pending:
    x,y=pending.pop()
    for cell in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
        if cell in cells and cell not in seen:seen.add(cell);pending.append(cell)
assert seen==cells
assert min(x for x,y in cells)==min(y for x,y in cells)==0
assert max(x for x,y in cells)==max(y for x,y in cells)==size-1
cell_units=maze['passage_m']*data['units_per_metre']
assert all((x//cell_units,y//cell_units) in cells for x,y,a in maze['starts'])
assert len(set((x,y) for x,y,a in maze['starts']))==8
report={'issue':438,'deterministic':True,'connected_cells':len(cells),'maze_metres':maze['size_m'],'corridor_metres':maze['passage_m'],'ring_metres':data['venues'][0]['size_m'],'sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}}
(Path(__file__).parent/'geometry-results.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS deterministic outputs, connected full-size maze, eight valid separate starts')
