"""Assemble the reviewed revision-4 MAP03 base under build/.

Reuse the reviewed shell, existing port content, private house identities,
factory services, generated siege data and residential sky policy. This command
never replaces src/maps; install_barracas_map.py owns reviewed installation.
"""
from pathlib import Path
import argparse
import json
import math
import generate_barracas_preview as shell
import generate_coastal_trials as coastal
import generate_city_ceilings as ceilings
import generate_shop_catalogue as catalogue
from generate_port_city import tower_rect

ROOT = Path(__file__).resolve().parents[2]


def read(name):
    return json.loads((ROOT / name).read_text(encoding='utf-8'))


def point(layout, x, y):
    transform = layout['port_transform']
    for _ in range(transform['quarter_turns'] % 4): x, y = -y, x
    return x + transform['offset'][0], y + transform['offset'][1]


def add_port(port, layout, out):
    captured = []
    coastal.generate(out / 'original-port', port_extension=captured.append, include_coast=False)
    old = captured[0]
    retired = read('assets/map06_port/INTERIORS.json')['retired_house_shells']
    for (x, y), cell in old.cells.items():
        if any(a <= x < c and b <= y < d for a, b, c, d in retired): continue
        floor, flat, wall, light, volume = cell
        if volume in (201, 202): continue
        # Remove the retired isolated port's low boundary walls. The complete
        # revised city perimeter owns access; the transformed quay is outside it.
        if floor == 112 and (x == -1280 or y in (-128, 2240)): continue
        corners = [point(layout, x + dx, y + dy) for dx, dy in ((0, 0), (64, 0), (0, 64), (64, 64))]
        port.room(min(p[0] for p in corners), min(p[1] for p in corners),
                  max(p[0] for p in corners), max(p[1] for p in corners),
                  floor=floor, flat=flat, wall=wall, light=light, volume=volume)
    for tag, profile in old.volumes.items():
        if tag not in (201, 202): port.volumes[tag] = profile
    for thing in old.things:
        row = dict(thing)
        row['x'], row['y'] = point(layout, row['x'], row['y'])
        row['angle'] = (row.get('angle', 0) + 90 * layout['port_transform']['quarter_turns']) % 360
        port.things.append(row)


def add_fortifications(port, layout, city):
    """Retain the artillery structures while fitting the approved perimeter."""
    siege = read('assets/barracas_redesign/SIEGE.json')
    assert not siege['placement_conflicts'], siege['placement_conflicts']
    south = read('assets/map06_port/SOUTH.json')
    # Extend the original southern battlefield without erasing the wall bulge.
    a,b,c,d = south['field_bounds']
    for x in range(a,c,port.CELL):
        for y in range(b,d,port.CELL):
            if (x,y) not in port.cells:
                port.room(x,y,x+port.CELL,y+port.CELL,flat='CMGR03',wall='CMST01')
    # The approved east/west assault fronts need ground beyond the former
    # rectangular south-only battlefield. Preserve existing cells, including
    # walls and water. Reuse the original hostile artillery standoff plus two
    # walkway widths for the turn/staging margin; do not change machine sizes.
    standoff=abs(south['gate_y']-south['attacking_gun_y'])
    margin=city['walk_width']*2
    for gate in layout['gates']:
        if gate['outward_angle'] not in (0,180):continue
        x,y,_=gate['position'];sign=1 if gate['outward_angle']==0 else -1
        outer=x+sign*(standoff+margin)
        left=math.floor(min(x,outer)/port.CELL)*port.CELL
        right=math.ceil(max(x,outer)/port.CELL)*port.CELL
        top=math.ceil((y+margin)/port.CELL)*port.CELL
        for px in range(left,right,port.CELL):
            for py in range(b,top,port.CELL):
                if (px,py) not in port.cells:
                    port.room(px,py,px+port.CELL,py+port.CELL,flat='CMGR03',wall='CMST01')
    port.room(*south['field_boundary'],floor=read('assets/map06_port/LAYOUT.json')['wall_height'],flat='CMST01')
    for gun in siege['defending_guns']:
        if gun['side']=='tower': continue
        axis=0 if gun['side'] in ('north','south') else 1
        for (x,y),cell in list(port.cells.items()):
            centre=(x+port.CELL/2,y+port.CELL/2)
            if cell[0]!=city['wall_height']:continue
            if abs(centre[axis]-gun['position'][axis])>=128:continue
            if abs(centre[1-axis]-gun['position'][1-axis])>city['walk_width']:continue
            port.room(x,y,x+port.CELL,y+port.CELL,floor=city['walk_height'],flat='CMST01',wall='CMST01')
        # A cardinal gun/crew pair needs a level footing on the oblique wall.
        # Retain the256-MU notch width and the existing raised-walk slab; ground
        # remains open underneath the small overhanging part of the platform.
        centre=gun['position'];extents=[port.CELL,port.CELL];extents[axis]=128
        a,b=[math.floor((centre[j]-extents[j])/port.CELL)*port.CELL for j in (0,1)]
        c,d=[math.ceil((centre[j]+extents[j])/port.CELL)*port.CELL for j in (0,1)]
        for x in range(a,c,port.CELL):
            for y in range(b,d,port.CELL):
                floor,flat,wall,light,volume=port.cells[x,y]
                if floor>=city['walk_height']:floor=city['walk_height'];volume=0
                else:volume=230
                port.room(x,y,x+port.CELL,y+port.CELL,floor=floor,flat=flat,wall=wall,light=light,volume=volume)
    for index,tower in enumerate(siege['towers']):
        size=city['tower_size'];width=city['wall_thickness']
        port.room(*tower_rect(tower,(0,0,size,size)),floor=city['walk_height'],flat='CMST01',wall='CMST01')
        for rect in [(0,0,width,size),(0,size-width,size,size)]:
            port.room(*tower_rect(tower,rect),floor=city['tower_deck_height']+city['tower_parapet'],flat='CMST01',wall='CMST01')
        for *rect,step in city['tower_stairs_local']:
            port.room(*tower_rect(tower,rect),floor=city['walk_height']+step*city['tower_step_rise'],flat='CMST01',wall='CMST01')
        port.room(*tower_rect(tower,city['tower_deck_local']),floor=city['tower_deck_height'],flat='CMST01',wall='CMST01')
        ox,oy=tower['origin'];a,b,c,d=city['tower_firing_ledge']
        if tower['flip_x']:a,c=size-c,size-a
        if tower['flip_y']:
            port.room(ox+a,oy,ox+c,oy+d,floor=city['tower_deck_height'],flat='CMST01',wall='CMST01')
        else:
            tag=240+index
            port.volume(tag,city['tower_deck_height']-city['walk_slab'],city['tower_deck_height'],'CMST01','CMST01')
            port.room(ox+a,oy,ox+c,oy+d,floor=city['walk_height'],flat='CMST01',wall='CMST01',volume=tag)
    sky_exclusions=[]
    for gun in siege['defending_guns']:
        for a,b,c,d,height in [*gun['stairs'],*gun['landing_rects']]:
            port.room(a,b,c,d,floor=height,flat='CMST01',wall='CMST01')
            sky_exclusions.append((a,b,c,d))
    return sky_exclusions


def apply_sky(port, layout, city, interior, exclusions):
    """Apply the accepted low residential sky without rectangular-wall clipping."""
    if not ceilings.DATA['enabled']: return
    margin = city['urban_grid']['road_width'] // 2
    rectangles = [(a-margin, b-margin, c+margin, d+margin)
                  for building in layout['buildings'] if building['kind'] in ('house', 'shop')
                  for a, b, c, d in [building['lot']]]
    edges = list(zip(layout['perimeter'], layout['perimeter'][1:] + layout['perimeter'][:1]))
    height = interior['height']
    exempt_cells={(x,y) for a,b,c,d in exclusions for x in range(a,c,port.CELL) for y in range(b,d,port.CELL)}
    for (x, y), cell in list(port.cells.items()):
        centre = x+port.CELL/2, y+port.CELL/2
        if (x,y) in exempt_cells:continue
        if not shell.inside(centre, layout['perimeter']) or min(shell.distance2(centre, a, b) for a, b in edges) < city['walk_width']**2: continue
        if not any(ceilings.contains(r, *centre) for r in rectangles): continue
        floor, flat, wall, light, volume = cell
        if floor > height or (volume in port.volumes and port.volumes[volume][1] > height): continue
        port.cells[x, y] = (floor, flat+ceilings.MARKER, wall, light, volume)

    def transform(groups):
        for sector in groups['sector']:
            flat = sector['texturefloor'].strip('"')
            if not flat.endswith(ceilings.MARKER): continue
            flat = flat.removesuffix(ceilings.MARKER)
            sector['texturefloor'] = '"'+flat+'"'
            sector['heightceiling'] = str(height)
            if int(sector['heightfloor']) == height: sector['textureceiling'] = sector['texturefloor']
    port.transform_groups = transform


def configure(port, layout, city, interior, out):
    runtime = read('assets/barracas_redesign/RUNTIME.json')
    hubs = read('assets/map06_port/HOUSE_HUBS.json')
    native = read('assets/map06_port/NATIVE_DOORS.json')
    old = read('assets/map06_port/LAYOUT.json')
    # The actual starting quay replaces the disposable central preview start.
    port.things = [t for t in port.things if t['type'] not in (1, 30950)]
    add_port(port, layout, out)
    for row in runtime['houses']:
        port.prop(hubs['portal_editor'], *row['portal'][:2], angle=row['angle'], args=(row['identity'], 0))
        port.prop(1, *row['door_outside'][:2], angle=row['angle'], args=(row['start_index'],))
    by_id = {b['id']: b for b in layout['buildings']}
    factories = [b for b in city['buildings'] if b['kind'] == 'factory']
    for i, previous in enumerate(factories):
        building = by_id[previous['id']]
        profile = interior['factory_profiles'][i % len(interior['factory_profiles'])]
        for j, kind in enumerate(profile['stations']):
            p = shell.local_point(building, *interior['station_positions'][j])
            port.prop(interior['station_editors'][kind], *p, angle=building['angle'])
    shops = [b for b in city['buildings'] if b['kind'] == 'shop']
    for i, previous in enumerate(shops):
        building = by_id[previous['id']]
        width, height = city['profiles']['shop']['size']
        if building.get('civic'):
            a, b, c, d = building['bounds'];width, height = c-a, d-b
        p = shell.local_point(building, width+city['detail']['awning_depth']+native['half_thickness'], height//128*64)
        port.prop(hubs['sign_editor'], *p, angle=building['angle'], args=(catalogue.category(i, interior['constants']['SHOP_CATEGORIES']),))
        port.things[-1]['height'] = city['detail']['awning_top']-port.CELL
    controller = read('assets/map06_port/SOUTH.json')['controller']
    port.prop(31050, *point(layout, *controller[:2]), tid=46000,
              args=(layout['geometry_revision'], 0, 0, hubs['city_marker_value']))
    for kind, key in [(30987, 'resource_bed'), (18004, 'resource_workbench'), (31051, 'completion_position')]:
        port.prop(kind, *point(layout, *old[key][:2]), angle=90*layout['port_transform']['quarter_turns'])
    exclusions=add_fortifications(port,layout,city)
    apply_sky(port, layout, city, interior, exclusions)


def assemble(out,compile_map=True):
    return shell.generate(out,map_name='MAP03',configure=lambda p,d,c,i:configure(p,d,c,i,out),compile_map=compile_map)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args();out = args.output.resolve()
    out.relative_to(ROOT / 'build')
    assemble(out)


if __name__ == '__main__':
    main()
