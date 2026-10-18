"""Geometry-cost ablation only: collinear boundaries, explicitly changed UV phase.

No production map is modified. Fresh MAP06 only; old saves are not compatible.
Sector/thing records and boundary positions remain, but texture repeats can change.
"""
from pathlib import Path
import argparse
import collections
import hashlib
import json
import re
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue318-audit-02'

def read_wad(path):
    raw=path.read_bytes();magic,count,offset=struct.unpack_from('<4sii',raw)
    assert magic in (b'PWAD',b'IWAD')
    return [(name.rstrip(b'\0').decode(),raw[start:start+size]) for start,size,name in
            (struct.unpack_from('<ii8s',raw,offset+16*i) for i in range(count))]

def pack_wad(lumps):
    data=b''.join(v for _,v in lumps);position=12;directory=[]
    for name,value in lumps:
        directory.append(struct.pack('<ii8s',position,len(value),name.encode().ljust(8,b'\0')));position+=len(value)
    return struct.pack('<4sii',b'PWAD',len(lumps),position)+data+b''.join(directory)

def parse(text):
    groups=collections.defaultdict(list)
    for kind,body in re.findall(r'\b(vertex|linedef|sidedef|sector|thing)\s*\{([^}]+)\}',text):
        fields=dict(re.findall(r'(\w+)\s*=\s*("[^"\n]*"|[^;]+);',body))
        groups[kind].append({k:v.strip() for k,v in fields.items()})
    return groups

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--name',default='collinear-diagnostic-v2');args=parser.parse_args()
    target=OUT/(args.name+'.pk3');assert not target.exists()
    source=ROOT/'src/maps/MAP06.wad';lumps=read_wad(source)
    text=dict(lumps)['TEXTMAP'].decode();groups=parse(text)
    lines=groups['linedef'];vertices=groups['vertex'];sides=groups['sidedef']
    before=len(lines);incident=collections.defaultdict(set)
    def point(i):return tuple(float(vertices[i][k]) for k in ('x','y'))
    def signature(line):
        fields=tuple(sorted((k,v) for k,v in line.items() if k not in ('v1','v2','sidefront','sideback')))
        faces=tuple(tuple(sorted(sides[int(line[k])].items())) if k in line else None for k in ('sidefront','sideback'))
        return fields,faces
    def eligible(line):
        return all(int(line.get(k,'0'))==0 for k in ('special','id','arg0','arg1','arg2','arg3','arg4'))
    signatures=[signature(line) for line in lines]
    for i,line in enumerate(lines):
        for key in ('v1','v2'):incident[int(line[key])].add(i)
    merges=0;removed=set()
    for vertex in sorted(incident):
        joins=incident[vertex]
        if len(joins)!=2:continue
        ia,ib=sorted(joins);a,b=lines[ia],lines[ib]
        if not (eligible(a) and eligible(b)) or signatures[ia]!=signatures[ib]:continue
        if int(a['v1'])==vertex and int(b['v2'])==vertex:ia,ib=ib,ia;a,b=b,a
        if not (int(a['v2'])==vertex and int(b['v1'])==vertex):continue
        start=point(int(a['v1']));middle=point(vertex);end=point(int(b['v2']))
        u=(middle[0]-start[0],middle[1]-start[1]);v=(end[0]-middle[0],end[1]-middle[1])
        if u[0]*v[1]!=u[1]*v[0] or u[0]*v[0]+u[1]*v[1]<=0:continue
        # The exact same oriented straight boundary is retained; no new opening.
        incident[int(a['v1'])].discard(ia);incident[int(a['v2'])].discard(ia)
        incident[int(b['v1'])].discard(ib);incident[int(b['v2'])].discard(ib)
        a['v2']=b['v2'];removed.add(ib)
        incident[int(a['v1'])].add(ia);incident[int(a['v2'])].add(ia);merges+=1
    groups['linedef']=[line for i,line in enumerate(lines) if i not in removed]
    used_sides=sorted({int(line[key]) for line in groups['linedef'] for key in ('sidefront','sideback') if key in line})
    used_vertices=sorted({int(line[key]) for line in groups['linedef'] for key in ('v1','v2')})
    side_map={old:new for new,old in enumerate(used_sides)};vertex_map={old:new for new,old in enumerate(used_vertices)}
    for line in groups['linedef']:
        for key in ('sidefront','sideback'):
            if key in line:line[key]=str(side_map[int(line[key])])
        for key in ('v1','v2'):line[key]=str(vertex_map[int(line[key])])
    groups['vertex']=[vertices[i] for i in used_vertices];groups['sidedef']=[sides[i] for i in used_sides]
    output='namespace = "ZDoom";\n'
    for kind in ('vertex','sector','sidedef','linedef','thing'):
        for fields in groups[kind]:output+=kind+'\n{\n'+''.join(f'{k} = {v};\n' for k,v in fields.items())+'}\n'
    original=parse(text);reparsed=parse(output)
    for kind in ('sector','thing'):assert original[kind]==reparsed[kind]
    assert [original['vertex'][i] for i in used_vertices]==reparsed['vertex']
    assert [original['sidedef'][i] for i in used_sides]==reparsed['sidedef']
    def special_records(g):
        result=[]
        for line in g['linedef']:
            if eligible(line):continue
            record={k:v for k,v in line.items() if k not in ('v1','v2','sidefront','sideback')}
            for key in ('v1','v2'):record[key]=g['vertex'][int(line[key])]
            for key in ('sidefront','sideback'):
                if key in line:record[key]=g['sidedef'][int(line[key])]
            result.append(record)
        return result
    assert special_records(original)==special_records(reparsed)
    assert before-len(reparsed['linedef'])==merges
    # Fresh native node building: retain scripts, omit only derived node data.
    retained=[(n,output.encode() if n=='TEXTMAP' else value) for n,value in lumps if n not in ('ZNODES','BLOCKMAP','REJECT')]
    wad=pack_wad(retained)
    with zipfile.ZipFile(target,'w') as archive:
        archive.writestr(zipfile.ZipInfo('maps/MAP06.wad',(2000,1,1,0,0,0)),wad)
    report={'scope':'Diagnostic only; texture phase and line-endpoint thermal shelter classification may change; fresh map only; no save migration implemented',
            'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'input_lumps':[n for n,_ in lumps],
            'before_linedefs':before,'after_linedefs':len(reparsed['linedef']),'merges':merges,
            'before_vertices':len(vertices),'after_vertices':len(used_vertices),'after_sidedefs':len(used_sides),
            'sectors_retained':len(groups['sector']),'things_retained':len(groups['thing']),
            'overlay_sha256':hashlib.sha256(target.read_bytes()).hexdigest()}
    target.with_suffix('.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
