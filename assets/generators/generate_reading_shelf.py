"""Generate the original #378 bookshelf deterministically using owned textures."""
from pathlib import Path
import json
import sys
sys.dont_write_bytecode = True
from generate_stash_models import Mesh, WOOD

ROOT = Path(__file__).resolve().parents[2]
data = json.loads((ROOT / 'assets/map01_mansion/READING.json').read_text(encoding='utf-8'))
width, height, depth = (data[key] for key in ('width', 'height', 'depth'))
mesh = Mesh()
paper = 'models/caelum/props/stations/ca_station_paper.png'
covers = ['models/caelum/props/stations/ca_station_leather.png',
          'models/caelum/props/stations/ca_station_cloth.png']
mesh.add_box(WOOD, (0, height/2, -depth/2+1), (width, height, 2))
for side in (-1, 1):
    mesh.add_box(WOOD, (side*(width/2-2), height/2, 0), (4, height, depth))
for shelf in (2, 25, 48, 70):
    mesh.add_box(WOOD, (0, shelf, 0), (width, 3, depth))
for shelf in (2, 25, 48):
    for book in range(10):
        x = -23 + book * 5
        book_height = 15 + (book % 3) * 2
        cover = covers[book % len(covers)]
        mesh.add_box(paper, (x, shelf+1.5+book_height/2, 0), (3.6, book_height, depth-4))
        for side in (-1, 1):
            mesh.add_box(cover, (x+side*1.9, shelf+1.5+book_height/2, 0), (0.3, book_height+0.4, depth-3))
        mesh.add_box(cover, (x, shelf+1.5+book_height/2, depth/2-1.3), (4.1, book_height+0.4, 0.8))
model = ROOT / 'src/models/caelum/props/reading/ca_reading_shelf.obj'
model.parent.mkdir(parents=True, exist_ok=True)
mesh.write(model)
model.write_text(model.read_text(encoding='utf-8').replace('o CaelumStashChest', 'o CaelumReadingShelf'), encoding='utf-8')
position = ','.join(str(value) for value in data['position'])
source = f'''// Generated from assets/map01_mansion/READING.json; #378.
class CaelumReadingFurnitureData : Object
{{
    const RADIUS = {data['radius']};
    const HEIGHT = {height};
    static vector3 Position() {{ return ({position}); }}
    static double Facing() {{ return {data['angle']}; }}
}}
'''
(ROOT / 'src/caelum/world/CaelumReadingFurnitureData.zs').write_text(source, encoding='utf-8')
print('Generated bookshelf model and placement data.')
