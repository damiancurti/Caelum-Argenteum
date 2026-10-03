"""Apply the approved #77 city geometry without changing siege deployment."""
import json
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parents[1]/'map06_port/CITY.json'
CITY = json.loads(DATA_PATH.read_text(encoding='utf-8'))


def tower_rect(tower, rect):
    x1, y1, x2, y2 = rect
    if tower['rotate']:
        size = CITY['tower_size']
        x1, y1, x2, y2 = size-x2, size-y2, size-x1, size-y1
    x, y = tower['origin']
    return x+x1, y+y1, x+x2, y+y2


def expand_city(port):
    c = CITY
    x1, y1, x2, y2 = c['bounds']
    # Fill only new ground: preserve existing interiors, cargo and arrival.
    for x in range(x1, x2, port.CELL):
        for y in range(y1, y2, port.CELL):
            if (x, y) not in port.cells:
                port.room(x,y,x+port.CELL,y+port.CELL)
    for rect in c['retired_walls']:
        port.room(*rect)
    for rect in c['exterior_ground']:
        port.room(*rect, flat='CMGR03', wall='CMST01')
    port.room(*c['exterior_water'], floor=-128, flat='CVPL02', volume=100)
    port.room(*c['dock_walk'], flat='CVPO01', wall='CVPO06')
    width = c['wall_thickness']
    for rect in [(x1,y1,x1+width,y2),(x2-width,y1,x2,y2),
                 (x1,y1,x2,y1+width),(x1,y2-width,x2,y2)]:
        port.room(*rect,floor=c['wall_height'],flat='CMST01',wall='CMST01')
    for gate in c['gates']:
        height = c['gate_headroom']
        port.volume(gate['tag'],height,height+c['gate_roof_thickness'],'CMST01','CMST01')
        port.room(*gate['bounds'],flat='CMST01',wall='CMST01',volume=gate['tag'])
    for b in c['buildings']:
        port.building(*b['bounds'],b['door_y'],b['tag'],b['wall'],b['floor'])
    for tower in c['towers']:
        size = c['tower_size']
        port.room(*tower_rect(tower,(0,0,size,size)),floor=c['tower_deck_height']+c['tower_parapet'],
                  flat='CMST01',wall='CMST01')
        port.room(*tower_rect(tower,c['tower_entry_local']),flat='CMST01',wall='CMST01')
        for *rect, step in c['tower_stairs_local']:
            port.room(*tower_rect(tower,rect),floor=step*c['tower_step_rise'],flat='CMST01',wall='CMST01')
        port.room(*tower_rect(tower,c['tower_deck_local']),floor=c['tower_deck_height'],flat='CMST01',wall='CMST01')
