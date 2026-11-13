"""Derive revision-4 artillery/crew geometry from retained siege identities.

Counts, dimensions, guard formations and stair profiles remain authoritative in
the original city sources. Placement follows the approved irregular perimeter;
candidate geometry must pass clearance and native routes before activation.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
from generate_barracas_preview import inside,distance2

ROOT=Path(__file__).resolve().parents[2]
INPUTS=['assets/barracas_redesign/LAYOUT.json','assets/map06_port/CITY.json',
        'assets/map06_port/SOUTH.json','assets/map06_port/INTERIORS.json']


def overlap(a,b):
    return a[0]<b[2] and b[0]<a[2] and a[1]<b[3] and b[1]<a[3]


def translate(point,delta):
    return [point[0]+delta[0],point[1]+delta[1],*point[2:]]


def rectangle(rect,delta):
    return [rect[0]+delta[0],rect[1]+delta[1],rect[2]+delta[0],rect[3]+delta[1],*rect[4:]]


def wall_point(vertices,indices,axis,value,original):
    for ia,ib in zip(indices,indices[1:]):
        a,b=vertices[ia],vertices[ib]
        if a[axis]==b[axis] or not min(a[axis],b[axis])<=value<=max(a[axis],b[axis]):continue
        other=1-axis;t=(value-a[axis])/(b[axis]-a[axis]);p=[0,0,original[2]]
        p[axis]=value;p[other]=a[other]+t*(b[other]-a[other])
        residue=original[other]%64;p[other]=round((p[other]-residue)/64)*64+residue
        return p
    return None


def outputs():
    layout,city,south,interior=[json.loads((ROOT/n).read_text(encoding='utf-8')) for n in INPUTS]
    perimeter=layout['perimeter'];lots=[b['lot'] for b in layout['buildings']]
    wall_ranges={'south':(0,8,0,[8,9,10,11]),'north':(12,20,0,[0,1,2,3,4,5]),
                 'west':(20,28,1,[11,12,0]),'east':(28,36,1,[5,6,7,8])}
    gate_rects=[]
    for g in layout['gates']:
        x,y,_=g['position'];a,b=(128,256) if g['outward_angle'] in (90,270) else (256,128)
        gate_rects.append([x-a,y-b,x+a,y+b])
    guards_by_gun=[];cursor=0
    for i in range(36):
        # Original formation:14 guards at each first12 posts,15 at each last24.
        count=14 if i<12 else 15
        guards_by_gun.append(south['guard_positions'][cursor:cursor+count]);cursor+=count
    assert cursor==len(south['guard_positions'])==528
    guns=[None]*36;conflicts=[]

    def row(index,p):
        old=south['defending_guns'][index];delta=[p[j]-old[j] for j in (0,1)]
        return {'identity':index,'position':p,'angle':south['defending_angles'][index],
                'translation':delta,'stairs':[rectangle(r,delta) for r in city['access_stairs'][index]['steps']],
                'crew_route':[translate(r,delta) for r in south['crew_routes'][index]],
                'guards':[translate(r,delta) for r in guards_by_gun[index]],'landing_rects':[],
                'stair_placement':'retained straight flight'}

    def wall_flight(r,side,direction=None,tower=False):
        """Keep64-MU treads/16-MU rises in the existing narrow wall-walk belt."""
        index=r['identity'];_,_,axis,indices=wall_ranges[side];other=1-axis
        normal=1 if side in ('south','west') else -1
        old_rise=city['access_stairs'][index]['steps'][0][4]
        count=city['walk_height']//old_rise;cell=layout['grid']
        tail_index=next(i for i,p in enumerate(r['crew_route']) if p[2]==city['walk_height'])
        if tower:
            while tail_index+1<len(r['crew_route']) and r['crew_route'][tail_index+1][2]==city['walk_height']:
                tail_index+=1
        end=r['crew_route'][tail_index] if tower else r['crew_route'][-1]
        stop=round(end[axis]/cell)*cell
        low=min(perimeter[i][axis] for i in indices);high=max(perimeter[i][axis] for i in indices)
        if direction is None:direction=1 if stop-low>high-stop else -1
        start=stop-direction*count*cell
        template=south['defending_guns'][index]

        def centre(along,inset,z):
            p=wall_point(perimeter,indices,axis,along,template)
            if p is None:return None
            p[other]+=normal*inset
            if inset==cell*1.5:
                p[other]=(math.ceil(p[other]/cell) if normal>0 else math.floor(p[other]/cell))*cell
            p[2]=z;return p

        base=centre(start-direction*cell/2,cell*1.5,0)
        if base is None:return None
        steps=[];route=[base]
        for n in range(count):
            p=centre(start+direction*(n+.5)*cell,cell*1.5,(n+1)*old_rise)
            if p is None:return None
            a=p[0]-(cell/2 if axis==0 else cell);b=p[1]-(cell if axis==0 else cell/2)
            c=p[0]+(cell/2 if axis==0 else cell);d=p[1]+(cell if axis==0 else cell/2)
            steps.append([int(a),int(b),int(c),int(d),p[2]]);route.append(p)
        landings=[]
        if tower:
            # Connect the new flight to the retained upper tower stair sequence.
            corner=list(route[-1]);corner[axis]=end[axis]
            for before,after in ((route[-1],corner),(corner,end)):
                a=math.floor((min(before[0],after[0])-cell/2)/cell)*cell
                b=math.floor((min(before[1],after[1])-cell/2)/cell)*cell
                c=math.ceil((max(before[0],after[0])+cell/2)/cell)*cell
                d=math.ceil((max(before[1],after[1])+cell/2)/cell)*cell
                landings.append([a,b,c,d,city['walk_height']])
            route.append(corner);route+=r['crew_route'][tail_index:]
        else:route.append(end)
        originals=guards_by_gun[index];original_base=south['crew_routes'][index][0]
        long_axis=max((0,1),key=lambda a:max(p[a] for p in originals)-min(p[a] for p in originals))
        guards=[]
        for guard in originals:
            p=list(base)
            p[axis]-=direction*abs(guard[long_axis]-original_base[long_axis])
            p[other]+=normal*(guard[1-long_axis]-original_base[1-long_axis])
            guards.append(p)
        return {**r,'stairs':steps,'landing_rects':landings,'crew_route':route,'guards':guards,
                'stair_placement':'wall-following flight; original tread/rise/count and guard spacing retained'}

    def issues(r):
        result=[]
        for step in [*r['stairs'],*r['landing_rects']]:
            if any(overlap(step[:4],lot) for lot in lots):result.append('stair/building');break
        if any(overlap(step[:4],gate) for step in [*r['stairs'],*r['landing_rects']] for gate in gate_rects):result.append('stair/gate')
        for other in guns:
            if other is None or other['identity']==r['identity']:continue
            if any(overlap(step[:4],previous[:4]) for step in [*r['stairs'],*r['landing_rects']]
                   for previous in [*other['stairs'],*other['landing_rects']]):
                result.append('stair/other-flight');break
            def near(point,rect):return overlap([point[0]-32,point[1]-32,point[0]+32,point[1]+32],rect[:4])
            if any(near(point,rect) for point in r['crew_route'] for rect in other['stairs']+other['landing_rects']) or any(near(point,rect) for point in other['crew_route'] for rect in r['stairs']+r['landing_rects']):
                result.append('route/other-flight');break
        for index,tower in enumerate(towers):
            if r['identity']==index+8:continue
            a,b=tower['origin'];box=[a,b,a+city['tower_size'],b+city['tower_size']]
            if any(overlap(rect[:4],box) for rect in r['stairs']+r['landing_rects']):result.append('stair/other-tower');break
        for p in [r['crew_route'][0],*r['guards']]:
            if not inside(p[:2],perimeter):result.append('ground/outside');break
            # Existing 40-MU guard spacing is retained; this margin only keeps
            # authored posts clear of masonry, not other formation members.
            if any(overlap([p[0]-32,p[1]-32,p[0]+32,p[1]+32],lot) for lot in lots):result.append('ground/building');break
        return result

    towers=[]
    for i,(old,new) in enumerate(zip(city['towers'],layout['towers'])):
        assert old['name']==new['id']
        delta=[new['centre'][a]-(old['origin'][a]+city['tower_size']//2) for a in (0,1)]
        tower={**old,'origin':translate(old['origin'],delta)};towers.append(tower)
        r=row(i+8,translate(south['defending_guns'][i+8],delta));r['side']='tower';guns[i+8]=r
        problems=issues(r)
        if problems:
            alternate=wall_flight(r,'west' if i in (0,2) else 'east',1 if i<2 else -1,tower=True)
            if alternate is not None and not issues(alternate):r=alternate;r['side']='tower';guns[i+8]=r;problems=[]
        footprint=[*tower['origin'],tower['origin'][0]+city['tower_size'],tower['origin'][1]+city['tower_size']]
        if any(overlap(footprint,lot) for lot in lots):problems.append('tower/building')
        if problems:conflicts.append({'gun':i+8,'side':'tower','reasons':problems})
    for side,(start,end,axis,indices) in wall_ranges.items():
        low=min(perimeter[i][axis] for i in indices);high=max(perimeter[i][axis] for i in indices)
        old_low,old_high=city['bounds'][axis],city['bounds'][axis+2]
        for index in range(start,end):
            ratio=(south['defending_guns'][index][axis]-old_low)/(old_high-old_low)
            target=round((low+(high-low)*ratio)/64)*64
            # Search within half the original post interval, in stable nearest
            # order. Keep the same wall and never displace an accepted building.
            half=(high-low)/(end-start)/2
            offsets=[0]+[sign*n for n in range(64,int(half)+1,64) for sign in (-1,1)]
            chosen=None;last=[]
            for offset in offsets:
                p=wall_point(perimeter,indices,axis,target+offset,south['defending_guns'][index])
                if p is None:continue
                candidate=row(index,p);last=issues(candidate)
                if not last:chosen=candidate;break
            if chosen is None:
                for offset in offsets:
                    p=wall_point(perimeter,indices,axis,target+offset,south['defending_guns'][index])
                    if p is None:continue
                    for direction in (1,-1):
                        candidate=wall_flight(row(index,p),side,direction)
                        if candidate is not None and not issues(candidate):chosen=candidate;break
                    if chosen is not None:break
            if chosen is None:
                p=wall_point(perimeter,indices,axis,target,south['defending_guns'][index]);chosen=row(index,p)
                conflicts.append({'gun':index,'side':side,'reasons':issues(chosen)})
            chosen['side']=side;guns[index]=chosen
    # Ground formations cannot be inferred from a single unobstructed stair:
    # all flights and tower footprints must exist before choosing their posts.
    obstructions=[r[:4] for gun in guns for r in gun['stairs']+gun['landing_rects']]
    obstructions += [[*t['origin'],t['origin'][0]+city['tower_size'],t['origin'][1]+city['tower_size']] for t in towers]
    edges=list(zip(perimeter,perimeter[1:]+perimeter[:1]))
    def ground_clear(p):
        box=[p[0]-32,p[1]-32,p[0]+32,p[1]+32]
        raster_margin=layout['grid']/math.sqrt(2)
        return inside(p[:2],perimeter) and min(distance2(p[:2],a,b) for a,b in edges)>(city['wall_thickness']/2+32+raster_margin)**2 and not any(overlap(box,r) for r in lots+obstructions+gate_rects)
    occupied=[]
    for gun in guns:
        original=gun['guards'];chosen=None
        offsets=[(dx,dy) for dx in range(-2048,2049,64) for dy in range(-2048,2049,64)]
        offsets.sort(key=lambda d:(d[0]**2+d[1]**2,abs(d[0])+abs(d[1]),d))
        for delta in offsets:
            candidate=[translate(p,delta) for p in original]
            if all(ground_clear(p) for p in candidate) and all((p[0]-q[0])**2+(p[1]-q[1])**2>=40**2 for p in candidate for q in occupied):
                chosen=candidate;gun['guard_translation_after_flights']=list(delta);break
        if chosen is None:conflicts.append({'gun':gun['identity'],'reasons':['no clear ground formation']})
        else:gun['guards']=chosen;occupied.extend(chosen)
    active=list(range(8,12))
    for side,count in [('south',4),('east',2),('west',2)]:
        gate=next(g for g in layout['gates'] if g['id']==side)
        candidates=[g for g in guns if g['side']==side]
        active.extend(g['identity'] for g in sorted(candidates,key=lambda g:sum((g['position'][a]-gate['position'][a])**2 for a in (0,1)))[:count])
    result={'schema_revision':1,'issue':454,'geometry_revision':4,'runtime_enabled':False,
            'status':'candidate_geometry_requires_native_clearance_and_routes',
            'authority':'LAYOUT.json approved four gates, three fronts and active artillery distribution; retained original counts/stats/guard spacing/stair profiles.',
            'source_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in INPUTS},
            'defending_guns':guns,'active_defending_guns':sorted(active),'towers':towers,
            'guards':[p for g in guns for p in g['guards']],
            'guard_identity_contract':'Preserve528 guard indices:14 at first12 posts and15 at last24; no troop duplication or new balance.',
            'placement_conflicts':conflicts}
    assert len({tuple(p) for p in result['guards']})==528
    assert min((p[0]-q[0])**2+(p[1]-q[1])**2 for i,p in enumerate(result['guards']) for q in result['guards'][i+1:])>=40**2
    assert len(set(active))==12
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    result=outputs();blob=(json.dumps(result,indent=2)+'\n').encode();path=ROOT/'assets/barracas_redesign/SIEGE.json'
    if args.check:assert path.read_bytes()==blob,'Stale Barracas siege geometry'
    else:path.write_bytes(blob)
    print(json.dumps({'guns':len(result['defending_guns']),'active':result['active_defending_guns'],'guards':len(result['guards']),'conflicts':result['placement_conflicts']}))
    if result['placement_conflicts']:raise SystemExit(1)


if __name__=='__main__':main()
