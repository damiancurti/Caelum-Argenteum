"""Apply the approved #77 city, wall walk and four cannon towers."""
import json
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parents[1]/'map06_port/CITY.json'
CITY = json.loads(DATA_PATH.read_text(encoding='utf-8'))


def tower_rect(tower, rect):
    x1, y1, x2, y2 = rect
    size = CITY['tower_size']
    if tower['flip_x']:
        x1, x2 = size-x2, size-x1
    if tower['flip_y']:
        y1, y2 = size-y2, size-y1
    x, y = tower['origin']
    return x+x1, y+y1, x+x2, y+y2


def urban_building(port,b):
    """Recognizable uses share native roofs, openings and collision geometry."""
    c=CITY; p=c['profiles'][b['kind']]; d=c['detail']
    x1,y1,x2,y2=b['bounds'];tag=b['tag'];w=b['wall'];flat=b['floor']
    port.room(*b['lot'],flat=c['urban_grid']['lot_flat'],wall=w)
    # A paved forecourt joins every entrance to its street.
    port.room(x2,b['door_y'],b['lot'][2]+128,b['door_y']+p['door_width'],flat='CMST02',wall='CMST01')
    if b['kind']=='construction':
        height=d['site_wall_heights'][b['stage']]
        port.room(x1,y1,x2,y2,floor=d['foundation_height'],flat=flat,wall=w)
        for rect in [(x1,y1,x1+64,y2),(x1,y1,x2,y1+64),(x1,y2-64,x2,y2),(x2-64,y1,x2,y2)]:
            port.room(*rect,floor=height,flat=flat,wall=w)
        port.room(x2-64,b['door_y'],x2,b['door_y']+p['door_width'],floor=d['foundation_height'],flat=flat,wall=w)
        # Exposed posts, partial brickwork, timber staging and stored materials.
        if b['stage']>=2:
            port.volume(tag,d['scaffold_bottom'],d['scaffold_top'],'CVPO01','CVPO06')
            port.room(x1+64,y1+64,x1+192,y2-64,floor=d['foundation_height'],flat=flat,wall='CVPO06',volume=tag)
            for y in range(y1+64,y2-64,256):
                port.room(x1+64,y,x1+128,y+64,floor=p['height']+64,flat='CVPO01',wall='CVPO06')
        for i in range(b['stage']+1):
            port.room(x1+256+i*64,y1+128,x1+320+i*64,y1+256,floor=d['crate_height'],flat='CVPO05',wall='CVPO04')
        return
    port.volume(tag,p['headroom'],p['height'],p['roof'],'CVCI04')
    port.room(x1,y1,x2,y2,floor=p['height'],flat=p['roof'],wall=w)
    port.room(x1+64,y1+64,x2-64,y2-64,flat=flat,wall=w,light=168,volume=tag)
    port.room(x2-64,b['door_y'],x2,b['door_y']+p['door_width'],flat=flat,wall=w,light=184,volume=tag)
    port.volume(tag+1,p['window_head'],p['height'],p['roof'],'CVCI04')
    for x in range(x1+128,x2-64,d['window_step']):
        for y in [y1,y2-64]:
            port.room(x,y,x+64,y+64,floor=p['window_sill'],flat='CMST03',wall=w,light=176,volume=tag+1)
    if b['kind']=='shop':
        port.volume(tag+2,d['awning_bottom'],d['awning_top'],'CVPO01','CVPO06')
        port.room(x2,b['door_y']-64,x2+d['awning_depth'],b['door_y']+p['door_width']+64,flat='CMST02',wall='CVPO06',volume=tag+2)
        port.room(x1+128,y1+128,x1+320,y2-128,floor=d['counter_height'],flat='CVPO01',wall='CVCI06',volume=tag)
    elif b['kind']=='factory':
        port.room(x1+128,y1+128,x1+128+d['chimney_size'],y1+128+d['chimney_size'],floor=d['chimney_height'],flat='CMST04',wall='CASWRWAL')
        for y in range(y1+384,y2-128,384):
            port.room(x1+128,y,x1+256,y+128,floor=d['crate_height'],flat='CVPO05',wall='CVPO04',volume=tag)


def expand_city(port):
    c = CITY
    port.control_origin = c['control_origin']
    port.control_columns = c['control_columns']
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
    for rect in c['exterior_water']:
        port.room(*rect, floor=-128, flat='CVPL02', volume=100)
    port.room(*c['dock_walk'], flat='CVPO01', wall='CVPO06')
    width = c['wall_thickness']
    for rect in [(x1,y1,x1+width,y2),(x2-width,y1,x2,y2),
                 (x1,y2-width,x2,y2)]:
        port.room(*rect,floor=c['wall_height'],flat='CMST01',wall='CMST01')
    port.room(x1,y1,x2,y1+width,floor=c['walk_height'],flat='CMST01',wall='CMST01')
    for b in c['buildings']:
        urban_building(port,b)
    # Raised passages retain the street below, including the eastern dock exit.
    w=c['walk_width']; tag=230
    port.volume(tag,c['walk_height']-c['walk_slab'],c['walk_height'],'CMST01','CMST01')
    for rect in [(x1+width,y1+width,x1+w,y2-width),(x2-w,y1+width,x2-width,y2-width),
                 (x1+width,y1+width,x2-width,y1+w),(x1+width,y2-w,x2-width,y2-width)]:
        a,b,d,e=rect
        for x in range(a,d,port.CELL):
            for y in range(b,e,port.CELL):
                floor,flat,wall,light,old=port.cells[x,y]
                assert old in (0,tag), ('overlapping roof',x,y,old)
                port.room(x,y,x+64,y+64,floor=floor,flat=flat,wall=wall,light=light,volume=tag)
    for gate in c['gates']:
        height = c['gate_headroom']
        port.volume(gate['tag'],height,height+c['gate_roof_thickness'],'CMST01','CMST01')
        port.room(*gate['bounds'],flat='CMST01',wall='CMST01',volume=gate['tag'])
    for rect in c['wall_firing_notches']:
        # Artillery sits at wall-walk height; the muzzle is not buried in a parapet.
        port.room(*rect,floor=c['walk_height'],flat='CMST01',wall='CMST01')
    for index,tower in enumerate(c['towers']):
        size = c['tower_size']
        port.room(*tower_rect(tower,(0,0,size,size)),floor=c['walk_height'],flat='CMST01',wall='CMST01')
        for rect in [(0,0,width,size),(0,size-width,size,size)]:
            port.room(*tower_rect(tower,rect),floor=c['tower_deck_height']+c['tower_parapet'],flat='CMST01',wall='CMST01')
        for *rect, step in c['tower_stairs_local']:
            port.room(*tower_rect(tower,rect),floor=c['walk_height']+step*c['tower_step_rise'],flat='CMST01',wall='CMST01')
        port.room(*tower_rect(tower,c['tower_deck_local']),floor=c['tower_deck_height'],flat='CMST01',wall='CMST01')
        # All four guns fire south, from the edge of a real upper platform.
        ox,oy=tower['origin']
        lx1,ly1,lx2,ly2=c['tower_firing_ledge']
        if tower['flip_x']:lx1,lx2=size-lx2,size-lx1
        if tower['flip_y']:
            port.room(ox+lx1,oy,ox+lx2,oy+ly2,floor=c['tower_deck_height'],flat='CMST01',wall='CMST01')
        else:
            tag=240+index
            port.volume(tag,c['tower_deck_height']-c['walk_slab'],c['tower_deck_height'],'CMST01','CMST01')
            port.room(ox+lx1,oy,ox+lx2,oy+192,floor=c['walk_height'],flat='CMST01',wall='CMST01',volume=tag)
    for stair in c['access_stairs']:
        for a,b,d,e,height in stair['steps']:
            port.room(a,b,d,e,floor=height,flat='CMST01',wall='CMST01')
