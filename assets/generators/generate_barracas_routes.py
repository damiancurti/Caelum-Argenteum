"""Derive600 resident deployment paths from the final candidate ground cells.

Use the same geometry assembly as the candidate map. Private CAH origins do not
move; routes start at the actual revision4 exterior door of ResidentHouse(id).
"""
from pathlib import Path
import argparse
import hashlib
import heapq
import json
import re
from generate_barracas_map import ROOT,assemble,read
from generate_barracas_preview import inside


def routes(port,layout):
    data=read('assets/barracas_redesign/RUNTIME.json')
    siege=read('assets/barracas_redesign/SIEGE.json')
    south=read('assets/map06_port/SOUTH.json');old=read('assets/map06_port/LAYOUT.json')
    property_source=(ROOT/'src/caelum/data/CaelumPropertyData.zs').read_text(encoding='utf-8')
    central=int(re.search(r'CENTRAL_HOUSE=(\d+)',property_source)[1])
    relocation=int(re.search(r'RELOCATION_HOUSE=(\d+)',property_source)[1])
    cell=port.CELL;height=old['defender_height_m']*32
    physical={p for p,v in port.cells.items() if v[0]==0 and (not v[4] or port.volumes[v[4]][0]>=height)
              and inside((p[0]+cell/2,p[1]+cell/2),layout['perimeter'])}
    street=set(physical);houses={b['house_index']:b for b in layout['buildings'] if b['kind']=='house'}
    # The irregular conceptual lots include shared service passages. Excluding
    # their whole envelopes disconnects genuine streets; exclude actual indoor
    # footprints instead, retaining native-clear public forecourts and alleys.
    for building in layout['buildings']:
        a,b,c,d=building['bounds'];street.difference_update((x,y) for x in range(a,c,cell) for y in range(b,d,cell))
    def key(point):return int(point[0]//cell)*cell,int(point[1]//cell)*cell
    cache={}
    def path(home,start,goal):
        lookup=(home,start,goal)
        if lookup in cache:return cache[lookup]
        usable=street
        assert start in usable and goal in usable,('invalid endpoint',home,start,goal,start in usable,goal in usable)
        queue=[(0,0,start)];cost={start:0};parent={}
        while queue:
            _,g,node=heapq.heappop(queue)
            if g!=cost[node]:continue
            if node==goal:break
            for dx,dy in ((cell,0),(-cell,0),(0,cell),(0,-cell)):
                nxt=(node[0]+dx,node[1]+dy)
                if nxt not in usable or g+1>=cost.get(nxt,10**9):continue
                cost[nxt]=g+1;parent[nxt]=node
                h=(abs(nxt[0]-goal[0])+abs(nxt[1]-goal[1]))//cell
                heapq.heappush(queue,(g+1+h,g+1,nxt))
        assert goal in cost,('unreachable deployment',home,start,goal)
        steps=[goal]
        while steps[-1]!=start:steps.append(parent[steps[-1]])
        steps.reverse();turns=[]
        for i,p in enumerate(steps):
            if i in (0,len(steps)-1) or (p[0]-steps[i-1][0],p[1]-steps[i-1][1])!=(steps[i+1][0]-p[0],steps[i+1][1]-p[1]):
                turns.append([p[0]+cell//2,p[1]+cell//2,0])
        cache[lookup]=(turns,len(steps));return cache[lookup]
    result=[];crew=len(siege['defending_guns'])*2
    for identity in range(south['defenders']):
        home=identity%len(houses)
        if home==central:home=relocation
        start=data['houses'][home]['door_outside']
        destination=siege['defending_guns'][identity//2]['crew_route'][0] if identity<crew else siege['guards'][identity-crew]
        points,length=path(home,key(start),key(destination))
        result.append({'identity':identity,'house':home,'start':start,'destination':destination,'grid_steps':length,'points':[start,*points,destination]})
    return result


def runtime(rows):
    code='// Rutas exteriores derivadas del suelo nativo de Barracas revision4.\nclass CaelumBarracasDeployment : Object play\n{\n'
    code+='    static int Count(int identity){switch(identity){\n'
    code+=''.join(f'        case {r["identity"]}:return {len(r["points"])};\n' for r in rows)+'        }return 0;}\n'
    code+='    static vector3 Point(int identity,int step){switch(identity){\n'
    code+=''.join(f'        case {r["identity"]}:return R{r["identity"]}(step);\n' for r in rows)+'        }return (0,0,0);}\n'
    for row in rows:
        code+=f'    static vector3 R{row["identity"]}(int step){{switch(step){{\n'
        code+=''.join(f'        case {i}:return ('+','.join(f'{v:g}' for v in p)+');\n' for i,p in enumerate(row['points']))
        code+='        }return (0,0,0);}\n'
    return (code+'}\n').encode()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True,help='Disposable candidate assembly directory under build/')
    parser.add_argument('--check',action='store_true');args=parser.parse_args()
    out=args.output.resolve();out.relative_to(ROOT/'build')
    port,layout,*_=assemble(out,False)
    result=routes(port,layout)
    inputs=['assets/barracas_redesign/'+n+'.json' for n in ('LAYOUT','RUNTIME','SIEGE')]+['src/caelum/data/CaelumPropertyData.zs','assets/map06_port/LAYOUT.json']
    document={'schema_revision':1,'geometry_revision':4,'issue':454,'runtime_enabled':False,
              'status':'static_candidate_routes_require_native_deployment','source_sha256':{p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in inputs},
              'contract':'600 original identities,72 crew/528 guards. ResidentHouse relocation69->70 retained. Private-map origins unchanged; ground routes remain inside the perimeter and outside indoor building footprints, using native-clear streets/forecourts/service alleys.',
              'routes':result}
    files={'assets/barracas_redesign/DEPLOYMENT.json':(json.dumps(document,indent=2)+'\n').encode(),
           'src/caelum/world/CaelumBarracasDeployment.zs':runtime(result)}
    for name,blob in files.items():
        target=ROOT/name
        if args.check:assert target.read_bytes()==blob,'Stale Barracas deployment routes: '+name
        else:target.write_bytes(blob)
    print(json.dumps({'routes':len(result),'waypoints':sum(len(r['points']) for r in result),'maximum_grid_steps':max(r['grid_steps'] for r in result)}),flush=True)


if __name__=='__main__':main()
