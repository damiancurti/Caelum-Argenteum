"""Generate one persistent native hub map per authored MAP06 house (#318)."""
from pathlib import Path
import json
from generate_coastal_trials import CoastalMap
import generate_city_interiors as interiors
import generate_native_city_doors as doors

ROOT = Path(__file__).resolve().parents[2]
DATA = json.loads((ROOT/'assets/map06_port/HOUSE_HUBS.json').read_text(encoding='utf-8'))
CITY = json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8'))


def map_name(index):
    return f'{DATA["map_prefix"]}{index:03d}'


def exterior(port):
    """Keep footprints, materials, roof heights and public road endpoints."""
    homes = interiors.houses(CITY)
    d = interiors.DATA
    house_groups = {d['door_group_base']+b['id'] for b in homes}
    port.things = [t for t in port.things if not (
        t['type'] == 18099 and t.get('arg0') in house_groups)]
    port.native_city_doors = False
    for i, b in enumerate(homes):
        x, y, x2, y2 = b['bounds']
        port.room(x, y, x2, y2, floor=d['height'], flat=d['roof'], wall=b['wall'])
        centre = y+(d['entrance'][1]+d['entrance'][3])//2
        port.prop(DATA['portal_editor'], x2+doors.DATA['half_thickness'], centre, args=(i, 0))
        return_point = [x+d['door_outside'][0], y+d['door_outside'][1]]
        port.prop(1, *return_point, angle=0, args=(DATA['start_index_base']+i,))
    # Old roof controls have no remaining targets after their rooms are removed.
    used = {cell[4] for cell in port.cells.values()}
    port.volumes = {tag: profile for tag, profile in port.volumes.items() if tag in used}
    for t in port.things:
        if t['type'] == 31050:
            t['arg'+str(DATA['city_marker_argument'])] = DATA['city_marker_value']
    for i,b in enumerate(b for b in CITY['buildings'] if b['kind']=='shop'):
        profile=CITY['profiles']['shop'];detail=CITY['detail']
        port.prop(DATA['sign_editor'],b['bounds'][2]+detail['awning_depth']+doors.DATA['half_thickness'],
                  b['door_y']+profile['door_width']//2,args=(i%d['constants']['SHOP_CATEGORIES'],))
        port.things[-1]['height']=detail['awning_top']-port.CELL


def generate(folder):
    folder.mkdir(parents=True, exist_ok=True)
    d = interiors.DATA
    all_leaves = doors.specs()
    for i, b in enumerate(interiors.houses(CITY)):
        port = CoastalMap(map_name(i))
        port.compact = True
        port.optimize_open_geometry = True
        port.add_default_things = False
        x, y, x2, y2 = b['bounds']
        # A normal ceiling replaces the city roof volume. Exterior/roof space
        # is owned by MAP06; no invisible city or duplicated facade is loaded.
        port.room(x,y,x2,y2,floor=d['headroom'],flat=d['roof'],wall=b['wall'])
        for a,c,e,f in [*d['rooms'].values(), d['entrance'], *d['doorways']]:
            port.room(x+a,y+c,x+e,y+f,flat=b['floor'],wall=b['wall'],light=168)
        for a,c,e,f in d['windows']:
            port.room(x+a,y+c,x+e,y+f,floor=d['window_sill'],flat='CMST03',wall=b['wall'],light=176)
        def close_ceiling(groups):
            for sector in groups['sector']:
                sector['heightceiling'] = str(d['window_head'] if int(sector['heightfloor']) == d['window_sill'] else d['headroom'])
                sector['textureceiling'] = '"'+d['roof']+'"'
            for line in groups['linedef']:
                if line.get('special') == '9':
                    line.pop('special')
        port.transform_groups = close_ceiling
        entrance = d['entrance']
        port.prop(DATA['portal_editor'], x2-doors.DATA['half_thickness'], y+(entrance[1]+entrance[3])//2, args=(i,1))
        point = [x+d['door_inside'][0], y+d['door_inside'][1]]
        port.prop(1,*point,angle=180)
        port.prop(DATA['marker_editor'],*point,args=(i,))
        port.prop(30950,*point,args=(1,0))
        port.native_city_doors = True
        port.native_door_specs = all_leaves[i*6+2:i*6+6]
        port.write(folder)


def runtime():
    homes=interiors.houses(CITY)
    south=json.loads((ROOT/'assets/map06_port/SOUTH.json').read_text(encoding='utf-8'))
    text='// Conexiones autorales; una vivienda por mapa persistente.\nclass CaelumHouseHubData : Object\n{\n'
    text+=f'    const REVISION={DATA["schema_revision"]};\n'
    text+=f'    const RESIDENT_COUNT={south["defenders"]};\n'
    text+='    static clearscope String MapName(int house){switch(house){\n'
    text+=''.join(f'        case {i}:return "{map_name(i)}";\n' for i in range(len(homes)))
    text+='        }return "";}\n'
    text+='    static clearscope int HouseForMap(String mapName){\n'
    text+='        if(mapName.Left(3)!="CAH")return -1;\n'
    text+=''.join(f'        if(mapName=="{map_name(i)}")return {i};\n' for i in range(len(homes)))
    text+='        return -1;}\n}\n'
    (ROOT/'src/caelum/world/CaelumHouseHubData.zs').write_text(text,encoding='utf-8')
    info='// Generated house interiors; each retains independent native hub state.\n'
    for i in range(len(homes)):
        info+=f'map {map_name(i)} "$CA_MAP06_NAME" {{ cluster={DATA["cluster"]} nointermission UnFreezeSinglePlayerConversations music="CA_MUS04_PORT" }}\n'
    (ROOT/'src/caelum/data/house_hubs.mapinfo').write_text(info,encoding='utf-8')


if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    generate(a.output)
    runtime()
