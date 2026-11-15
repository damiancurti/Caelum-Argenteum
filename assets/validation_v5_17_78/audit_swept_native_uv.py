"""Check affected sweep UVs from native MD3 triangles, using serialized OBJ owners."""
from pathlib import Path
from collections import defaultdict
import argparse,hashlib,json,struct

SOURCES=[('quadrupeds_787','ao_ao'),('kasogonaga_795','kasogonaga')]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def audit(root):
 rows=[]
 for folder,species in SOURCES:
  source=root/'assets/source/art'/folder;design=json.loads((source/(species+'.json')).read_text());export=json.loads((source/'EXPORT.json').read_text())
  selected={s['name']:s for s in design['shapes'] if s.get('kind')=='sweep' and (s['name'] in ['left_curled_horn','right_curled_horn','short_tail'] or s['name'].startswith('back_lock_'))}
  vertices=[];owners=defaultdict(list);group=None
  for line in (source/'editable'/(species+'.obj')).read_text().splitlines():
   words=line.split()
   if not words:continue
   if words[0]=='v':x,z,y=map(float,words[1:]);vertices.append((round(x*64),round(-y*64),round(z*64)))
   elif words[0]=='g':group=next((s['name'] for s in design['shapes'] for mat in design['materials'] if words[1]==s['name']+'_'+mat),None);assert group is not None
   elif words[0]=='f':owners[tuple(vertices[int(v.split('/')[0])-1] for v in words[1:])].append(group)
  native_name=next(n for n in export['sha256'] if n.endswith('/'+species+'.md3'));native=root/'src'/native_name;blob=native.read_bytes();header=struct.unpack_from('<4sI64s9I',blob);offset=header[10]
  values={name:{} for name in selected}
  for surface in range(header[6]):
   h=struct.unpack_from('<4s64s10I',blob,offset);points=[struct.unpack_from('<3h',blob,offset+h[10]+i*8) for i in range(h[5])];uvs=[struct.unpack_from('<2f',blob,offset+h[9]+i*8) for i in range(h[5])]
   for i in range(h[6]):
    tri=struct.unpack_from('<3I',blob,offset+h[7]+i*12);key=tuple(points[v] for v in tri);assert owners[key],('Native triangle has no serialized owner',species,surface,i)
    group=owners[key].pop()
    if group in selected:
     for v in tri:values[group][(surface,v)]=uvs[v]
   offset+=h[-1]
  assert not any(owners.values()),'Serialized/native triangle mismatch'
  for name,shape in selected.items():
   assert values[name],name
   tile=design['materials'][shape['material']]['tile'];margin=design['atlas']['inset'];coords=[((u*design['atlas']['columns']-tile[0]-margin)/(1-2*margin),(v*design['atlas']['rows']-tile[1]-margin)/(1-2*margin)) for u,v in values[name].values()]
   outside=sum(not all(-1e-6<=v<=1+1e-6 for v in uv) for uv in coords)
   rows.append(dict(source=(source/(species+'.json')).relative_to(root).as_posix(),shape=name,samples=shape['samples'],uv_repeats=shape['uv_repeats'],native_vertices_checked=len(coords),outside_material_cell=outside,maximum_local_v=max(v for u,v in coords),native_sha256=digest(native)))
 return dict(issue=799,source='Serialized MD3 first-frame triangles and UVs matched to quantized editable OBJ group ownership',rows=rows,outside_material_cell=sum(r['outside_material_cell'] for r in rows))

def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[2]);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--expect-overflow',action='store_true');args=parser.parse_args()
 root=args.root.resolve(strict=True);out=args.output.resolve();out.relative_to(root/'build');report=audit(root)
 assert len(report['rows'])==9
 report['expected_overflow']=args.expect_overflow;report['passed']=all(r['outside_material_cell']>0 for r in report['rows']) if args.expect_overflow else report['outside_material_cell']==0
 out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(passed=report['passed'],shapes=len(report['rows']),outside=report['outside_material_cell'])));raise SystemExit(not report['passed'])

if __name__=='__main__':main()
