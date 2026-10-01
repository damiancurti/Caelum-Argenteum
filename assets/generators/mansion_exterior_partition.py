"""Partition the oversized exterior floor without changing its height or look."""
from copy import deepcopy


def partition_exterior(obj,spec,report):
    vertices,lines,sides,sectors=(obj[k] for k in ('vertex','linedef','sidedef','sector'))
    horizon={lines[i]['v1']:i for i in spec['horizon_lines']}
    original=[deepcopy(lines[i]) for i in spec['horizon_lines']]
    corners=[vertices[i] for i in horizon]
    xs=[min(p['x'] for p in corners),*spec['inner_x'],max(p['x'] for p in corners)]
    ys=[min(p['y'] for p in corners),*spec['inner_y'],max(p['y'] for p in corners)]
    # Every retained hole/island in sector 0 must remain inside the central cell.
    # Otherwise partitioning would require clipping/reassigning that geometry.
    for i,line in enumerate(lines):
        if i in spec['horizon_lines']:continue
        touches=any(sides[line[k]]['sector']==spec['sector'] for k in ('sidefront','sideback') if line.get(k,-1)>=0)
        if touches:
            assert all(xs[1]<vertices[line[k]]['x']<xs[2] and ys[1]<vertices[line[k]]['y']<ys[2] for k in ('v1','v2')), f'Exterior feature crosses the partition: line {i}'
    ids={(vertices[i]['x'],vertices[i]['y']):i for i in horizon}
    for x in xs:
        for y in ys:
            if (x,y) not in ids:
                ids[x,y]=len(vertices);vertices.append(dict(x=x,y=y))
    base=sectors[spec['sector']];edges={};cells=[]
    for ix in range(3):
        for iy in range(3):
            si=spec['sector'] if (ix,iy)==(1,1) else len(sectors)
            if (ix,iy)!=(1,1):
                sector=deepcopy(base);sector['comment']='Issue #61: bounded exterior floor rendering'
                sectors.append(sector)
            cells.append(dict(sector=si,bounds=[xs[ix],ys[iy],xs[ix+1],ys[iy+1]]))
            points=[(xs[ix],ys[iy]),(xs[ix],ys[iy+1]),(xs[ix+1],ys[iy+1]),(xs[ix+1],ys[iy])]
            for a,b in zip(points,points[1:]+points[:1]):
                va,vb=ids[a],ids[b]
                if (vb,va) in edges:
                    sd=len(sides);sides.append(dict(sector=si))
                    lines[edges[vb,va]].update(sideback=sd,twosided=True)
                    continue
                outer=(a[0]==b[0] and a[0] in (xs[0],xs[-1])) or (a[1]==b[1] and a[1] in (ys[0],ys[-1]))
                if outer and va in horizon:
                    li=horizon[va];line=lines[li];line['v2']=vb
                    sides[line['sidefront']]['sector']=si
                else:
                    sd=len(sides);sides.append(dict(sector=si))
                    li=len(lines);line=dict(v1=va,v2=vb,sidefront=sd)
                    if outer:line.update(special=original[0]['special'],blocking=original[0]['blocking'])
                    lines.append(line)
                edges[va,vb]=li
    report['exterior_partition']=dict(cells=cells,lines=sorted(edges.values()),changed_baseline_lines=spec['horizon_lines'],changed_baseline_sides=[l['sidefront'] for l in original])
