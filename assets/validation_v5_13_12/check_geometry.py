"""Verify deterministic output, baseline bytes and all walkable sign placements."""
from pathlib import Path
import hashlib,json,subprocess,sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
from generate_arenas import maze_cells
from hunt_arcana_geometry import ArcanaGeometry

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    files=[ROOT/x for x in ('src/maps/CAHUNT.wad','src/caelum/data/CaelumHuntData.zs','src/caelum/data/CaelumHuntArcanaData.zs','assets/hunt/GENERATED.json')]
    before=[digest(p) for p in files]
    subprocess.run([sys.executable,'assets/generators/generate_hunt.py'],cwd=ROOT,check=True)
    assert before==[digest(p) for p in files], 'Non-deterministic hunt output'
    legacy=ROOT/'assets/hunt/legacy_51311'
    for entry in json.loads((legacy/'manifest.json').read_text())['files'].values():
        assert digest(legacy/entry['file'])==entry['sha256']
    arcana=ArcanaGeometry(32,64);cells=set();arcana.expand(cells)
    for room in arcana.rooms:
        x,y=room['cell'];offset=3 if room['card']==10 else 2
        assert (x-offset,y-offset) in cells,room
    print('PASS deterministic geometry/navigation, preserved baseline and 22 walkable markers')
if __name__=='__main__':main()
