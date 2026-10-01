"""Keep detached model sectors outside the explorable horizon, preserving planes."""
from collections import Counter


def relocate_controls(obj,spec):
    vertices,lines,sides=obj['vertex'],obj['linedef'],obj['sidedef']
    moved=[];all_vertices=set()
    for index,sector in enumerate(spec['sectors']):
        edges=[l for l in lines if sides[l['sidefront']]['sector']==sector]
        ids={l[k] for l in edges for k in ('v1','v2')}
        assert len(edges)==4 and len(ids)==4 and all(l.get('sideback',-1)<0 for l in edges)
        assert all(n==2 for n in Counter(l[k] for l in edges for k in ('v1','v2')).values())
        assert not all_vertices & ids
        assert all(sides[l['sidefront']]['sector']==sector for l in lines if l['v1'] in ids or l['v2'] in ids)
        old={i:dict(vertices[i]) for i in ids}
        bounds=[min(p['x'] for p in old.values()),min(p['y'] for p in old.values()),max(p['x'] for p in old.values()),max(p['y'] for p in old.values())]
        assert not any(bounds[0]<=t['x']<=bounds[2] and bounds[1]<=t['y']<=bounds[3] for t in obj['thing'])
        x=spec['destination_origin'][0]+index%spec['columns']*spec['spacing']
        y=spec['destination_origin'][1]+index//spec['columns']*spec['spacing']
        dx,dy=x-bounds[0],y-bounds[1]
        for i in sorted(ids):vertices[i].update(x=old[i]['x']+dx,y=old[i]['y']+dy)
        new_bounds=[bounds[0]+dx,bounds[1]+dy,bounds[2]+dx,bounds[3]+dy]
        a,b,c,d=spec['playable_bounds']
        assert new_bounds[2]<a or new_bounds[0]>c or new_bounds[3]<b or new_bounds[1]>d
        moved.append(dict(sector=sector,vertices=sorted(ids),old_bounds=bounds,new_bounds=new_bounds,delta=[dx,dy]))
        all_vertices.update(ids)
    return moved
