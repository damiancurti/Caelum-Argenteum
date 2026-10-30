"""Generate the authored arrival-household relocation data (#581)."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[2]
d=json.loads((ROOT/'assets/map06_port/ARRIVAL_HOUSEHOLD.json').read_text(encoding='utf-8'))
s='// Generado: editar assets/map06_port/ARRIVAL_HOUSEHOLD.json.\nclass CaelumArrivalHouseholdData : Object\n{\n'
s+=f'    const REVISION={d["revision"]};\n    const HOUSE={d["target_house"]};\n    const COUNT={len(d["items"])};\n'
s+=f'    static clearscope String SourceMap(){{return "{d["source_map"]}";}}\n'
for method,typ,key in [('Kind','Name','class'),('Origin','vector3','source'),('Offset','vector3','offset'),('Facing','double','angle')]:
 s+=f'    static clearscope {typ} {method}(int index){{switch(index){{\n'
 for i,row in enumerate(d['items']):
  v=row[key];v="'"+v+"'" if typ=='Name' else '('+','.join(map(str,v))+')' if typ=='vector3' else str(v)
  s+=f'        case {i}:return {v};\n'
 s+='        }return '+("'None'" if typ=='Name' else '(0,0,0)' if typ=='vector3' else '0')+';}\n'
s+='}\n'
(ROOT/'src/caelum/data/CaelumArrivalHouseholdData.zs').write_text(s,encoding='utf-8',newline='\n')
