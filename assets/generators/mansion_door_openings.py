"""Carve only the four authored doorway rectangles through stacked wall models."""
from copy import deepcopy
from repair_map01_mansion import tags


def carve_openings(obj, config, report):
    vertices,lines,sides,sectors=(obj[k] for k in ('vertex','linedef','sidedef','sector'))
    source_lines=deepcopy(lines)
    source_sides=deepcopy(sides)
    source_sectors=deepcopy(sectors)
    models={}
    for line in source_lines:
        if line.get('special')==160:
            models.setdefault(line['arg0'],[]).append((line,source_sectors[source_sides[line['sidefront']]['sector']]))
    def sector_at(x,y):
        for si in range(config['baseline_sectors']):
            crossings=0
            for line in source_lines[:config['baseline_lines']]:
                a,b=[vertices[line[k]] for k in ('v1','v2')]
                front=source_sides[line['sidefront']]['sector']
                back=source_sides[line['sideback']]['sector'] if line.get('sideback',-1)>=0 else -1
                if (front==si)==(back==si):continue
                if (a['y']>y)!=(b['y']>y) and x<(b['x']-a['x'])*(y-a['y'])/(b['y']-a['y'])+a['x']:crossings+=1
            if crossings%2:return si
        raise ValueError((x,y))
    index={(v['x'],v['y']):i for i,v in enumerate(vertices)}
    def vertex(x,y):
        point=(round(x,6),round(y,6))
        if point not in index:
            index[point]=len(vertices);vertices.append(dict(x=point[0],y=point[1]))
        return index[point]
    report['door_openings']={'changed_lines':[], 'sectors':[], 'controls':[]}
    evidence=report['door_openings'];spec=config['door_openings']
    for rect in spec['rectangles']:
        x0,y0,x1,y1=rect; replacements={}
        def inside(x,y):return x0<x<x1 and y0<y<y1
        def replacement(si):
            if si in replacements:return replacements[si]
            target=deepcopy(source_sectors[si]);tag=spec['first_tag']+len(evidence['sectors'])
            target['id']=tag;target.pop('moreids',None)
            target['comment']='Issue #36: restored existing single-door opening'
            new_si=len(sectors);sectors.append(target);replacements[si]=new_si
            evidence['sectors'].append(dict(source=si,target=new_si,rectangle=rect,tag=tag))
            for oldtag in sorted(tags(source_sectors[si])):
                for line,model in models.get(oldtag,[]):
                    model=deepcopy(model)
                    if model['texturefloor']=='CMIN01' and model['heightfloor']<=spec['bottom'] and model['heightceiling']==spec['top']:
                        model['heightceiling']=spec['bottom']
                    mi=len(sectors);sectors.append(model)
                    x=spec['control_origin'][0]+len(evidence['controls'])*config['control_size']*2
                    y=spec['control_origin'][1];size=config['control_size']
                    vs=[vertex(a,b) for a,b in [(x,y),(x,y+size),(x+size,y+size),(x+size,y)]]
                    for j in range(4):
                        sd=len(sides);sides.append(dict(sector=mi,texturemiddle=sides[line['sidefront']].get('texturemiddle','CMIN01')))
                        item=dict(v1=vs[j],v2=vs[(j+1)%4],sidefront=sd)
                        if j==0:
                            item.update({k:v for k,v in line.items() if k=='special' or k.startswith('arg')})
                            item['arg0']=tag
                        lines.append(item)
                    evidence['controls'].append(mi)
            return new_si
        # Split existing edges only where they cross the rectangle boundary.
        for li in range(len(lines)):
            line=lines[li];a,b=[vertices[line[k]] for k in ('v1','v2')]
            dx,dy=b['x']-a['x'],b['y']-a['y'];cuts={0.0,1.0}
            for x in (x0,x1):
                if dx:
                    t=(x-a['x'])/dx
                    if 0<t<1 and y0<=a['y']+t*dy<=y1:cuts.add(t)
            for y in (y0,y1):
                if dy:
                    t=(y-a['y'])/dy
                    if 0<t<1 and x0<=a['x']+t*dx<=x1:cuts.add(t)
            intervals=list(zip(sorted(cuts),sorted(cuts)[1:]))
            template=deepcopy(line)
            templatesides={key:deepcopy(sides[line[key]]) for key in ('sidefront','sideback') if line.get(key,-1)>=0}
            for part,(start,end) in enumerate(intervals):
                item=deepcopy(template)
                item['v1']=vertex(a['x']+dx*start,a['y']+dy*start)
                item['v2']=vertex(a['x']+dx*end,a['y']+dy*end)
                for key,sign in [('sidefront',1),('sideback',-1)]:
                    if item.get(key,-1)<0:continue
                    side=deepcopy(templatesides[key])
                    mx=a['x']+dx*(start+end)/2+sign*dy*0.00001
                    my=a['y']+dy*(start+end)/2-sign*dx*0.00001
                    changed=inside(mx,my)
                    if changed:side['sector']=replacement(side['sector'])
                    if part:
                        item[key]=len(sides);sides.append(side)
                    elif changed:
                        sides[item[key]]=side
                if part:lines.append(item)
                else:lines[li]=item
            if lines[li]!=template or len(intervals)>1 or any(sides[template[k]]!=side for k,side in templatesides.items()):
                evidence['changed_lines'].append(li)
        # Add missing internal boundaries clockwise (new interior on the right).
        corners=[(x0,y0),(x0,y1),(x1,y1),(x1,y0)]
        for a,b in zip(corners,corners[1:]+corners[:1]):
            dx,dy=b[0]-a[0],b[1]-a[1];axis=0 if dx else 1
            lo,hi=sorted((a[axis],b[axis]))
            points=[p for p in index if p[1-axis]==a[1-axis] and lo<=p[axis]<=hi]
            points=sorted(set(points+[a,b]),key=lambda p:(p[axis]-a[axis])/(b[axis]-a[axis]))
            for p,q in zip(points,points[1:]):
                mx,my=(p[0]+q[0])/2,(p[1]+q[1])/2
                # Already-existing collinear edges received their new sidedefs above.
                exists=False
                along,across=('x','y') if axis==0 else ('y','x')
                for line in lines:
                    v,w=[vertices[line[k]] for k in ('v1','v2')]
                    if v[across]==w[across]==a[1-axis] and min(v[along],w[along])<(mx,my)[axis]<max(v[along],w[along]):
                        exists=True;break
                if exists:continue
                si=sector_at(mx,my);new_si=replacement(si);sd=len(sides)
                sides.extend([dict(sector=new_si,texturetop='CMIN01',texturebottom='CMIN01'),dict(sector=si,texturetop='CMIN01',texturebottom='CMIN01')])
                lines.append(dict(v1=vertex(*p),v2=vertex(*q),sidefront=sd,sideback=sd+1,twosided=True))
    # Keep original sector identities/planes without empty-sector engine warnings.
    # Their full former polygons were replaced above; retain tiny off-map anchors.
    referenced={sides[line[key]]['sector'] for line in lines for key in ('sidefront','sideback') if line.get(key,-1)>=0}
    evidence['retained_sector_anchors']=[]
    for si in range(config['baseline_sectors']):
        if si in referenced:continue
        x=spec['retained_sector_origin'][0]+len(evidence['retained_sector_anchors'])*config['control_size']*2
        y=spec['retained_sector_origin'][1];size=config['control_size']
        vs=[vertex(a,b) for a,b in [(x,y),(x,y+size),(x+size,y+size),(x+size,y)]]
        for j in range(4):
            sd=len(sides);sides.append(dict(sector=si,texturemiddle='CMIN01'))
            lines.append(dict(v1=vs[j],v2=vs[(j+1)%4],sidefront=sd))
        evidence['retained_sector_anchors'].append(si)
