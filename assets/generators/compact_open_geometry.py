"""Merge only physically open, redundant UDMF boundaries deterministically.

Fields are serialized UDMF tokens produced by CoastalMap.write. Physical wall
segments, 3D control ownership, target tags, specials and visible wall UVs remain
unchanged. This does not add opaque barriers or alter overhead space.
"""
import collections

def compact_open_geometry(groups):
    # This pass supports only CoastalMap's flat planes and single target tags.
    # Refuse future slope/portal/extra-tag fields before changing any references.
    supported={
        'vertex':{'x','y'},
        'sector':{'heightfloor','heightceiling','texturefloor','textureceiling','lightlevel','id'},
        'sidedef':{'sector','texturetop','texturebottom','texturemiddle'},
    }
    for kind,allowed in supported.items():
        for entry in groups[kind]:
            if set(entry)-allowed:
                raise ValueError(f'Unsupported {kind} fields in open geometry compaction: {sorted(set(entry)-allowed)}')
    vertices,lines,sides,sectors=(groups[k] for k in ('vertex','linedef','sidedef','sector'))
    controls={int(sides[int(l['sidefront'])]['sector']) for l in lines if l.get('special')=='160'}
    canonical={};sector_map={};kept=[]
    for i,sector in enumerate(sectors):
        signature=tuple(sorted(sector.items()))
        # Distinct 3D control ownership and target tags are never collapsed.
        eligible=i not in controls and int(sector.get('id','0'))==0
        if eligible and signature in canonical:sector_map[i]=canonical[signature]
        else:
            sector_map[i]=len(kept);kept.append(sector)
            if eligible:canonical[signature]=sector_map[i]
    for side in sides:side['sector']=str(sector_map[int(side['sector'])])
    groups['sector']=sectors=kept
    def plain(l):
        # Fail closed if a future generator adds collision/activation flags.
        allowed={'v1','v2','sidefront','sideback','twosided','blocking',
                 'special','id','arg0','arg1','arg2','arg3','arg4'}
        return (set(l)<=allowed and l.get('twosided')=='true'
                and all(int(l.get(k,'0'))==0 for k in ('special','id','arg0','arg1','arg2','arg3','arg4'))
                and l.get('blocking','false')=='false')
    def open_boundary(l):
        if not plain(l) or 'sideback' not in l:return False
        faces=[sides[int(l[k])] for k in ('sidefront','sideback')]
        if any(f.get('texturemiddle','"-"')!='"-"' for f in faces):return False
        a,b=[sectors[int(f['sector'])] for f in faces]
        # Identical physical planes and 3D target tag: no visible vertical wall,
        # no roof edge, and no thermal wall-trace endpoint is modified.
        return all(a.get(k)==b.get(k) for k in ('heightfloor','heightceiling','id'))
    redundant=[i for i,l in enumerate(lines) if open_boundary(l) and
               sides[int(l['sidefront'])]['sector']==sides[int(l['sideback'])]['sector']]
    removed=set(redundant);incident=collections.defaultdict(set)
    for i,l in enumerate(lines):
        if i in removed:continue
        for k in ('v1','v2'):incident[int(l[k])].add(i)
    def point(i):return tuple(float(vertices[i][k]) for k in ('x','y'))
    def signature(l):
        return (tuple(sorted((k,v) for k,v in l.items() if k not in ('v1','v2','sidefront','sideback'))),
                tuple(tuple(sorted(sides[int(l[k])].items())) if k in l else None for k in ('sidefront','sideback')))
    signatures=[signature(l) for l in lines];merges=0
    for vertex in sorted(incident):
        joins=incident[vertex]
        if len(joins)!=2:continue
        ia,ib=sorted(joins);a,b=lines[ia],lines[ib]
        if not open_boundary(a) or not open_boundary(b) or signatures[ia]!=signatures[ib]:continue
        if int(a['v1'])==vertex and int(b['v2'])==vertex:ia,ib=ib,ia;a,b=b,a
        if int(a['v2'])!=vertex or int(b['v1'])!=vertex:continue
        start,middle,end=point(int(a['v1'])),point(vertex),point(int(b['v2']))
        u=(middle[0]-start[0],middle[1]-start[1]);v=(end[0]-middle[0],end[1]-middle[1])
        if u[0]*v[1]!=u[1]*v[0] or u[0]*v[0]+u[1]*v[1]<=0:continue
        for i,l in ((ia,a),(ib,b)):
            for k in ('v1','v2'):incident[int(l[k])].discard(i)
        a['v2']=b['v2'];removed.add(ib);merges+=1
        for k in ('v1','v2'):incident[int(a[k])].add(ia)
    groups['linedef']=[l for i,l in enumerate(lines) if i not in removed]
    for kind,keys in (('sidedef',('sidefront','sideback')),('vertex',('v1','v2'))):
        used=sorted({int(l[k]) for l in groups['linedef'] for k in keys if k in l})
        remap={old:new for new,old in enumerate(used)}
        groups[kind]=[groups[kind][i] for i in used]
        for l in groups['linedef']:
            for k in keys:
                if k in l:l[k]=str(remap[int(l[k])])
    return {'open_boundary_merges':merges,'invisible_redundant_lines':len(redundant),
            'control_sectors_preserved':len(controls)}
