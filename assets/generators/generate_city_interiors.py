"""Deterministic #133 interiors and shared occupancy/commerce coordinates."""
import json
import heapq
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = json.loads((ROOT/'assets/map06_port/INTERIORS.json').read_text(encoding='utf-8'))


def houses(city):
    result = []
    width, height = DATA['house_size']
    for b in city['buildings']:
        if b['kind'] != 'house':
            continue
        x1, y1, x2, y2 = b['lot']
        x = x1 + ((x2-x1-width)//128)*64
        y = y1 + ((y2-y1-height)//128)*64
        result.append(dict(b, bounds=[x,y,x+width,y+height], door_y=y+DATA['entrance'][1]))
    result.extend(DATA['retained_houses'])
    return result


def build_house(port, b):
    d = DATA
    x, y, x2, y2 = b['bounds']
    tag, wall, flat = b['tag'], b['wall'], b['floor']
    port.volume(tag,d['headroom'],d['height'],d['roof'],'CVCI04')
    port.room(x,y,x2,y2,floor=d['height'],flat=d['roof'],wall=wall)
    for name, rect in d['rooms'].items():
        a,c,e,f = rect
        port.room(x+a,y+c,x+e,y+f,flat=flat,wall=wall,light=168,volume=tag)
    for rect in [d['entrance'], *d['doorways']]:
        a,c,e,f = rect
        port.room(x+a,y+c,x+e,y+f,flat=flat,wall=wall,light=168,volume=tag)
    a,c,e,f=d['entrance']
    port.room(x2,y+c,x2+d['forecourt_depth'],y+f,flat='CMST02',wall='CMST01')
    for side in (-1,1):
        port.prop(18099,x+e-d['door_inset'],y+(c+f)//2+side*d['leaf_half_width'],
                  args=(d['door_group_base']+b['id'],side,1))
    # Windows use the existing sill/header profile; no new access bypass.
    window_tag=d['window_tag_base']+b['id']
    port.volume(window_tag,d['window_head'],d['height'],d['roof'],'CVCI04')
    for a,c,e,f in d['windows']:
        port.room(x+a,y+c,x+e,y+f,floor=d['window_sill'],flat='CMST03',
                  wall=wall,light=176,volume=window_tag)


def apply(port, city):
    # The two historical shells are rebuilt within the empty western apron.
    # Original actor coordinates, docks and all exits remain intact.
    for rect in DATA['retired_house_shells']:
        port.room(*rect)
    homes=houses(city)
    for b in homes:
        if 'lot' in b:
            port.room(*b['lot'],flat=city['urban_grid']['lot_flat'],wall=b['wall'])
        build_house(port,b)
    factories=[b for b in city['buildings'] if b['kind']=='factory']
    for i,b in enumerate(factories):
        profile=DATA['factory_profiles'][i%len(DATA['factory_profiles'])]
        for j,kind in enumerate(profile['stations']):
            dx,dy=DATA['station_positions'][j]
            port.prop(DATA['station_editors'][kind],b['bounds'][0]+dx,b['bounds'][1]+dy)
    return homes


def deployment_routes(port, city, south):
    """Ground routes use native empty cells; crew stairs retain their old routes."""
    homes=houses(city)
    cell=port.CELL
    def key(p):
        return (int(p[0])//cell*cell,int(p[1])//cell*cell)
    layout=json.loads((ROOT/'assets/map06_port/LAYOUT.json').read_text(encoding='utf-8'))
    body_height=layout['defender_height_m']*32
    walkable={p for p,v in port.cells.items() if v[0]==0 and (not v[4] or port.volumes[v[4]][0]>=body_height)}
    # Long routes stay on public roads, clear of open door sweeps, awnings,
    # counters and the unpredictable occupied interiors of private lots.
    for b in city['buildings']:
        x1,y1,x2,y2=b['lot']
        walkable.difference_update((x,y) for x in range(x1,x2,cell) for y in range(y1,y2,cell))
    def path(start,goal):
        assert start in walkable and goal in walkable, (start,goal)
        queue=[(0,0,start)];cost={start:0};parent={}
        while queue:
            _,g,node=heapq.heappop(queue)
            if g!=cost[node]:continue
            if node==goal:break
            for dx,dy in ((cell,0),(-cell,0),(0,cell),(0,-cell)):
                nxt=(node[0]+dx,node[1]+dy)
                if nxt not in walkable or g+1>=cost.get(nxt,10**9):continue
                cost[nxt]=g+1;parent[nxt]=node
                h=(abs(nxt[0]-goal[0])+abs(nxt[1]-goal[1]))//cell
                heapq.heappush(queue,(g+1+h,g+1,nxt))
        assert goal in cost, ('unreachable formation',start,goal)
        result=[goal]
        while result[-1]!=start:result.append(parent[result[-1]])
        result.reverse()
        turns=[]
        for i,p in enumerate(result):
            if i==0 or i==len(result)-1 or (p[0]-result[i-1][0],p[1]-result[i-1][1])!=(result[i+1][0]-p[0],result[i+1][1]-p[1]):
                turns.append([p[0]+cell//2,p[1]+cell//2,0])
        return turns
    result=[]
    for soldier in range(south['defenders']):
        b=homes[soldier%len(homes)]
        origin=b['bounds'][:2]
        road=DATA.get('house_road_overrides',{}).get(str(soldier%len(homes)),DATA['house_road'])
        start=[origin[i]+road[i] for i in range(2)]
        guard=soldier-2*len(south['defending_guns'])
        goal=south['crew_routes'][soldier//2][0] if guard<0 else DATA['guard_station_corrections'].get(str(guard),south['guard_positions'][guard])
        result.append(path(key(start),key(goal))+[goal])
    return result


def runtime(city, port=None, south=None):
    homes=houses(city)
    shops=[b for b in city['buildings'] if b['kind']=='shop']
    code='// Generado desde assets/map06_port/INTERIORS.json y CITY.json.\nclass CaelumCityData : Object play\n{\n'
    for name,value in DATA['constants'].items():
        code+=f'    const {name} = {value};\n'
    code+=f'    const HOUSE_COUNT = {len(homes)};\n    const SHOP_COUNT = {len(shops)};\n'
    code+='    static bool Enabled(){let p=CaelumPortSiege.Get();return p!=null && p.args[0]>=LAYOUT_REVISION;}\n'
    # The nearest authored city boundary defines which formation rows are deep.
    # It is routing metadata, not a change to the existing 40-MU post spacing.
    formation=json.loads((ROOT/'assets/map06_port/SOUTH.json').read_text(encoding='utf-8'))
    spacing=json.loads((ROOT/'assets/map06_port/LAYOUT.json').read_text(encoding='utf-8'))['guard_spacing']
    code+=f'    const CREW_COUNT = {2*len(formation["defending_guns"])};\n'
    points=[DATA['guard_station_corrections'].get(str(i),p) for i,p in enumerate(formation['guard_positions'])]
    remaining=set(range(len(points)));inward={};x1,y1,x2,y2=city['bounds']
    while remaining:
        group=[];queue=[min(remaining)];remaining.remove(queue[0])
        while queue:
            i=queue.pop();group.append(i)
            near=[j for j in sorted(remaining) if max(abs(points[i][k]-points[j][k]) for k in range(2))<=spacing]
            for j in near:remaining.remove(j);queue.append(j)
        cx=sum(points[i][0] for i in group)/len(group);cy=sum(points[i][1] for i in group)/len(group)
        direction=min([(cx-x1,(1,0)),(x2-cx,(-1,0)),(cy-y1,(0,1)),(y2-cy,(0,-1))])[1]
        for i in group:inward[i]=direction
    code+='    static vector2 FormationInward(int guard){switch(guard){\n'+''.join(f'        case {i}:return ({d[0]},{d[1]});\n' for i,d in sorted(inward.items()))+'        }return (0,0);}\n'
    code+='    static vector3 GuardStation(int i){switch(i){\n'+''.join(f'        case {i}:return ({",".join(map(str,p))});\n' for i,p in DATA['guard_station_corrections'].items())+'        }return CaelumPortData.GuardPosition(i);}\n'
    code+='    static vector3 HouseOrigin(int i){switch(i){\n'
    for i,b in enumerate(homes):
        code+=f'        case {i}:return ({b["bounds"][0]},{b["bounds"][1]},0);\n'
    code+='        }return (0,0,0);}\n'
    code+='    static int DoorGroup(int i){switch(i){\n'
    for i,b in enumerate(homes):
        code+=f'        case {i}:return {DATA["door_group_base"]+b["id"]};\n'
    code+='        }return 0;}\n'
    for name,key in [('TablePosition','table'),('BedPosition','bed'),('DoorInside','door_inside'),('DoorOutside','door_outside'),('HouseRoad','house_road')]:
        code+=f'    static vector3 {name}(int i){{'
        if key=='house_road':
            for identity,point in DATA.get('house_road_overrides',{}).items():
                code+=f'if(i=={identity})return HouseOrigin(i)+({",".join(map(str,point))});'
        code+=f'return HouseOrigin(i)+({",".join(map(str,DATA[key]))});}}\n'
    code+='    static vector3 HomePosition(int soldier){int house=soldier%HOUSE_COUNT; switch(soldier/HOUSE_COUNT){\n'
    for i,p in enumerate(DATA['occupancy']):
        code+=f'        case {i}:return HouseOrigin(house)+({",".join(map(str,p))});\n'
    code+='        }return HouseOrigin(house);}\n'
    code+='    static vector3 ShopPosition(int i){switch(i){\n'
    for i,b in enumerate(shops):
        dx,dy=DATA['vendor_offset']
        code+=f'        case {i}:return ({b["bounds"][0]+dx},{b["bounds"][1]+dy},0);\n'
    code+='        }return (0,0,0);}\n'
    if port is not None:
        routes=deployment_routes(port,city,south)
        route_code='// Rutas de suelo calculadas desde la geometría autoral; escaleras en CaelumPortData.\nclass CaelumCityRoutes : Object play\n{\n'
        route_code+='    static int Count(int soldier){switch(soldier){\n'+''.join(f'        case {i}:return {len(r)};\n' for i,r in enumerate(routes))+'        }return 0;}\n'
        route_code+='    static vector3 Point(int soldier,int step){switch(soldier){\n'+''.join(f'        case {i}:return Route{i}(step);\n' for i in range(len(routes)))+'        }return (0,0,0);}\n'
        for i,r in enumerate(routes):
            route_code+=f'    static vector3 Route{i}(int step){{switch(step){{\n'+''.join(f'        case {j}:return ({",".join(map(str,p))});\n' for j,p in enumerate(r))+'        }return (0,0,0);}\n'
        route_code+='}\n'
        (ROOT/'src/caelum/world/CaelumCityRoutes.zs').write_text(route_code,encoding='utf-8')
        print(f'City routes: {len(routes)} soldiers; {sum(map(len,routes))} waypoints')
    code+='}\n'
    (ROOT/'src/caelum/world/CaelumCityData.zs').write_text(code,encoding='utf-8')


if __name__=='__main__':
    runtime(json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8')))
