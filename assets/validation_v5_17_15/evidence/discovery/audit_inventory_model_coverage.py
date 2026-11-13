from pathlib import Path
import json
import re
ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/v517/work-672'
def clean(text):return re.sub(r'/\*.*?\*/|//[^\n]*','',text,flags=re.S)
visited=set();bindings={}
def include(path):
    if path in visited:return
    visited.add(path);text=clean(path.read_text(encoding='utf-8'))
    for name in re.findall(r'#include\s+"([^"]+)"',text):include(WORK/'src'/name)
    for match in re.finditer(r'\bModel\s+"?(\w+)"?\s*\{',text):
        start=match.end();end=start;depth=1
        while depth and end<len(text):
            if text[end]=='{':depth+=1
            elif text[end]=='}':depth-=1
            end+=1
        pairs=re.findall(r'\bFrameIndex\s+(\w+)\s+(\w+)',text[start:end])
        bindings.setdefault(match[1],[]).append(dict(file=path.relative_to(WORK).as_posix(),pairs=pairs))
include(WORK/'src/MODELDEF')
parents={};locations={}
for path in (WORK/'src/caelum').rglob('*.zs'):
    for name,parent in re.findall(r'\bclass\s+(\w+)\s*:\s*(\w+)',clean(path.read_text(encoding='utf-8'))):
        parents[name]=parent;locations[name]=path.relative_to(WORK).as_posix()
audit=json.loads((ROOT/'build/v517/work-647/build/issue647-defaults01/RESULTS.json').read_text())
rows=[]
for item in audit['defaults']:
    if any(item[key]!='0' for key in ['undroppable','untossable']) or item['visible_spawn']!='1':continue
    name=item['class'];chain=[];current=name
    while current and current not in chain:
        chain.append(current);current=parents.get(current)
    owner=next((kind for kind in chain if kind in bindings),None)
    rows.append(dict(class_name=name,status='direct' if owner==name else 'ancestor-candidate' if owner else 'no-static-binding',
        model_owner=owner,bindings=bindings.get(owner,[]),source=locations.get(name),icon=item['icon']))
report=dict(scope='Read-only discovery for the 87 old native visible droppable defaults. Dynamic TNT1 pickups and per-frame/material coverage remain separate; ancestor candidates require native verification.',
    modeldef_files=len(visited),classes=len(rows),counts={status:sum(x['status']==status for x in rows) for status in ['direct','ancestor-candidate','no-static-binding']},rows=rows)
(ROOT/'build/v516/inventory-model-coverage.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(dict(counts=report['counts'],missing=[x['class_name'] for x in rows if x['status']=='no-static-binding'],ancestor=[(x['class_name'],x['model_owner']) for x in rows if x['status']=='ancestor-candidate'])))
