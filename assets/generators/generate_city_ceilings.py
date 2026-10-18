"""Apply the author-adopted #318/#327 sky zones before sector compaction."""
import json
from pathlib import Path
import generate_city_interiors as interiors

ROOT = Path(__file__).resolve().parents[2]
DATA = json.loads((ROOT/'assets/map06_port/CEILINGS.json').read_text(encoding='utf-8'))
MARKER = '__CA318_LOW'


def contains(rect, x, y):
    a, b, c, d = rect
    return a <= x < c and b <= y < d


def zone_rectangles(city):
    homes = interiors.houses(city)
    margin = city['urban_grid']['road_width']//2
    rects = []
    for building in [*homes, *(b for b in city['buildings'] if b['kind']=='shop')]:
        rect = building.get('lot')
        if rect is None:
            x, y, x2, y2 = building['bounds']
            identity = homes.index(building)
            road = interiors.DATA.get('house_road_overrides', {}).get(str(identity), interiors.DATA['house_road'])
            rect = [x, y, max(x2, x+road[0], x+interiors.DATA['door_outside'][0]),
                    max(y2, y+road[1], y+interiors.DATA['door_outside'][1])]
        a, b, c, d = rect
        rects.append([a-margin, b-margin, c+margin, d+margin])
    return rects


def apply(port, city):
    if not DATA['enabled']:
        return
    a,b,c,d = city['bounds']; belt = city['walk_width']
    inside = [a+belt,b+belt,c-belt,d-belt]
    height = interiors.DATA['height']
    rectangles = zone_rectangles(city)
    for (x,y), cell in list(port.cells.items()):
        cx,cy = x+port.CELL/2,y+port.CELL/2
        if not contains(inside,cx,cy) or not any(contains(r,cx,cy) for r in rectangles):
            continue
        floor,flat,wall,light,tag = cell
        if floor>height or (tag in port.volumes and port.volumes[tag][1]>height):
            continue
        port.cells[x,y] = (floor,flat+MARKER,wall,light,tag)

    def transform(groups):
        for sector in groups['sector']:
            flat = sector['texturefloor'].strip('"')
            if not flat.endswith(MARKER):
                continue
            flat = flat.removesuffix(MARKER)
            sector['texturefloor'] = '"'+flat+'"'
            assert int(sector['heightfloor'])<=height
            sector['heightceiling'] = str(height)
            if int(sector['heightfloor'])==height:
                assert flat!='F_SKY1'
                sector['textureceiling'] = sector['texturefloor']
    port.transform_groups = transform
