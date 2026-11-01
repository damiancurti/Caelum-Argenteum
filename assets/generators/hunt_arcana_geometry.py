"""Deterministic, optional Tarot chambers; preserve a perimeter bypass."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class ArcanaGeometry:
    def __init__(self, half, cell):
        self.data = json.loads((ROOT / 'assets/hunt/ARCANA.json').read_text(encoding='utf-8'))
        self.cell = cell
        self.rooms = []
        self.reserved = set()
        self.walls = set()
        for card in range(22):
            quarter, ordinal = card % 4, card // 4
            x = self.data['centres_x'][ordinal % 3] + (quarter % 2) * half
            y = self.data['centres_y'][ordinal // 3] + (quarter // 2) * half
            if card == 6:
                x, y = 8 + (quarter % 2) * half, 10 + (quarter // 2) * half
            self.rooms.append(dict(card=card, quarter=quarter, cell=[x, y], use=self.data['uses'][card]))
            self.reserved.update((xx, yy) for xx in range(x-1, x+1) for yy in range(y-1, y+1))
            if card in (2, 5, 12, 21):
                self.walls.add((x, y))
            if card == 10:
                self.walls.update((x+dx,y+dy) for dx in range(-2,2) for dy in range(-2,2)
                                  if (dx in (-2,1) or dy in (-2,1)) and (dx,dy) not in ((-1,-2),(0,1)))

    def expand(self, cells):
        half = self.data['room_half_cells']
        for room in self.rooms:
            x, y = room['cell']
            extent=half+1 if room['card']==10 else half
            cells.update((xx, yy) for xx in range(x-extent, x+extent) for yy in range(y-extent, y+extent))
        cells.difference_update(self.walls)

    def apply(self, layout):
        c = self.cell
        for room in self.rooms:
            card = room['card']
            if card == 6:
                continue  # Existing trap owns these sector tags.
            x, y = room['cell']
            tag = self.data['room_tag_base'] + card
            water = card in (5, 10, 12)
            if water:
                tag = self.data['water_tags'][(10, 12, 5).index(card)]
            for xx in range(x-1, x+1):
                for yy in range(y-1, y+1):
                    if (xx, yy) in self.walls:
                        continue
                    layout.room(xx*c, yy*c, (xx+1)*c, (yy+1)*c,
                                flat='CMST02', wall='CMST01', light=192 if card == 10 else 176, volume=tag)
            if water:
                layout.volume(tag, -64, 0 if card == 10 else 64, 'CAPOOL01', 'CAPOOL01', water=True)

    def finish(self, groups):
        self.controls = {}
        for line in groups['linedef']:
            if line.get('special') == '160':
                tag = int(line['arg0'])
                if tag in self.data['water_tags']:
                    sector = int(groups['sidedef'][int(line['sidefront'])]['sector'])
                    self.controls[tag] = sector
        for index, sector in enumerate(groups['sector']):
            if index in self.controls.values():
                tag = next(tag for tag, value in self.controls.items() if value == index)
                sector['user_ca_water_quality'] = '1' if tag == self.data['water_tags'][2] else '0'
                sector['user_ca_potable_water'] = '1'
            else:
                sector['heightceiling'] = '160'
                sector['textureceiling'] = '"CMST01"'
            tag = int(sector.get('id', '0'))
            if tag == self.data['water_tags'][0]:
                sector['user_ca_tarot_room'] = '1'
                self.wheel_sector = index
        groups['sector'][0]['user_ca_hunt_arcana'] = '1'

    def write(self):
        rows = ['// #616: generado desde assets/hunt/ARCANA.json.', 'class CaelumHuntArcanaData : Object', '{',
                '    static clearscope bool Present(){return level.MapName=="CAHUNT" && level.Sectors.Size()>0 && level.Sectors[0].GetUDMFInt("user_ca_hunt_arcana")==1;}',
                f'    const WHEEL_ROOM={self.wheel_sector};',
                f'    const WHEEL_WATER={self.controls[self.data["water_tags"][0]]};',
                '    static clearscope vector3 Center(int card){switch(card){']
        for room in self.rooms:
            x, y = room['cell']
            rows.append(f'        case {room["card"]}:return ({x*self.cell},{y*self.cell},0);')
        rows += ['    }return (0,0,0);}',
                 '    static clearscope vector3 Door(int card){return Center(card)+(-CaelumHuntData.CELL/2,CaelumHuntData.CELL/2,0);}',
                 '    static clearscope vector3 Marker(int card){double offset=CaelumHuntData.CELL*(card==10?2.5:1.5);return Center(card)+(-offset,-offset,0);}', '}']
        (ROOT/'src/caelum/data/CaelumHuntArcanaData.zs').write_text('\n'.join(rows)+'\n', encoding='utf-8', newline='\n')

