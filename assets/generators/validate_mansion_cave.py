"""Read-only structural checks for the native cave and decorative-only rocks."""
from collections import Counter
import math
import re


def cave_checks(obj,report,spec,root):
    data=report['cave'];triangles=data['triangles'];sectors=obj['sector'];vertices=obj['vertex'];lines=obj['linedef'];sides=obj['sidedef']
    def z(sector,point,prefix='floorplane'):
        s=sectors[sector]
        return -(s.get(prefix+'_a',0)*point['x']+s.get(prefix+'_b',0)*point['y']+s.get(prefix+'_d',-s['heightfloor']))/s.get(prefix+'_c',1)
    checks={}
    checks['cave floor normals are normalized for native UDMF']=all(abs(sum(sectors[t['sector']]['floorplane_'+k]**2 for k in 'abc')-1)<1e-10 for t in triangles)
    checks['cave floor planes match authored vertices']=all(abs(z(t['sector'],vertices[i])-h)<1e-5 for t in triangles for i,h in zip(t['vertices'],t['floor']))
    tunnel={t['sector']:t for t in triangles if t['kind']=='tunnel'}
    checks['each tunnel triangle has one solid roof']=Counter(c['target'] for c in data['controls'])==Counter({k:1 for k in tunnel}) and all(any(l.get('special')==160 and l.get('arg0')==c['tag'] and l.get('arg1')==1 and l.get('arg3')==255 for l in lines) for c in data['controls'])
    checks['roof thickness and tunnel clearance are positive']=all(min(z(c['sector'],vertices[i],'ceilingplane')-spec['roof_underside'] for i in tunnel[c['target']]['vertices'])>0 and min(spec['roof_underside']-h for h in tunnel[c['target']]['floor'])>=120 for c in data['controls'])
    open_sectors={t['sector'] for t in triangles if t['kind'] in ('approach','tunnel')};adj={i:set() for i in open_sectors};edges=[]
    for l in lines:
        if l.get('sideback',-1)<0:continue
        a,b=(sides[l[k]]['sector'] for k in ('sidefront','sideback'))
        if a in open_sectors and b in open_sectors:
            adj[a].add(b);adj[b].add(a);edges.append(l)
    reached=set();queue=[min(open_sectors)]
    while queue:
        k=queue.pop()
        if k in reached:continue
        reached.add(k);queue.extend(adj[k]-reached)
    checks['entrance and tunnel form one connected route']=reached==open_sectors
    checks['ramp has no steps or blocking internal edges']=all(not l.get('blocking') and all(abs(z(sides[l['sidefront']]['sector'],vertices[l[k]])-z(sides[l['sideback']]['sector'],vertices[l[k]]))<1e-5 for k in ('v1','v2')) for l in edges)
    code=(root/'src/caelum/world/CaelumDecorativeCave.zs').read_text(encoding='utf-8')
    checks['all five gems inherit Actor without resource or inventory code']=set(re.findall(r'class (\w+) : Actor',code))=={g['classname'] for g in data['gems']} and not any(s in code for s in ('Inventory','EnvironmentProp','Use(','DamageMobj','IsNaturalResource','SHOOTABLE','SPECIAL'))
    checks['five decorative actors use only reserved editor numbers']=len(data['gems'])==5 and all(obj['thing'][g['thing']]['type']==spec['first_editor_number']+i for i,g in enumerate(data['gems']))
    checks['3D-floor controls stay outside the playable horizon']=all(min(vertices[l[k]]['x'] for l in lines if sides[l['sidefront']]['sector']==c['sector'] for k in ('v1','v2'))>30000 for c in data['controls'])
    return checks
