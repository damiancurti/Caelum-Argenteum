"""Read-only candidate inventory/model discovery for #647, not completion proof."""
from pathlib import Path
import argparse
import collections
import json
import re

root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
out=args.output.resolve();out.relative_to(root/'build');out.mkdir(parents=True,exist_ok=True)
seen={}
def includes(path):
    path=path.resolve()
    if path in seen:return
    text=path.read_text(encoding='utf-8-sig');seen[path]=text
    for name in re.findall(r'^\s*#include\s+"([^"]+)"',text,re.M):
        candidate=path.parent/name
        if not candidate.is_file():candidate=root/'src'/name
        if candidate.is_file():includes(candidate)
def mask(text):
    pattern=r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/'
    return re.sub(pattern,lambda m:re.sub(r'[^\n]',' ',m[0]),text)
def block(text,begin):
    depth=1;end=begin
    while depth and end<len(text):
        if text[end]=='{':depth+=1
        if text[end]=='}':depth-=1
        end+=1
    if depth:raise ValueError('Unclosed block')
    return end

includes(root/'src/ZSCRIPT');classes={}
for path,text in seen.items():
    clean=mask(text)
    for match in re.finditer(r'\bclass\s+(\w+)\s*:\s*(\w+)\s*([^\{;]*)\{',clean):
        name,parent,attributes=match.groups();end=block(clean,match.end())
        classes[name]={'parent':parent,'abstract':'abstract' in attributes,'source':path.relative_to(root).as_posix(),
                       'line':text[:match.start()].count('\n')+1,'body':text[match.end():end-1]}
seen={};includes(root/'src/MODELDEF');bindings=collections.defaultdict(list)
for path,text in seen.items():
    clean=mask(text)
    for match in re.finditer(r'\bModel\s+(\w+)\s*\{',clean,re.I):
        end=block(clean,match.end());body=text[match.end():end-1]
        bindings[match[1]].append({'source':path.relative_to(root).as_posix(),
            'path':re.findall(r'\bPath\s+"([^"]+)"',body,re.I),
            'models':re.findall(r'\bModel\s+(\d+)\s+"([^"]+)"',body,re.I),
            'frames':re.findall(r'\bFrameIndex\s+(\w+)\s+(\w+)\s+(\d+)\s+(\d+)',body,re.I)})
native={'Inventory','Ammo','Weapon','Powerup','PowerupGiver','CustomInventory','Key','Health','HealthPickup','BasicArmor','BasicArmorPickup','BasicArmorBonus','PuzzleItem'}
def chain(name):
    result=[]
    while name in classes:
        if name in result:raise ValueError('Inheritance cycle')
        result.append(name);name=classes[name]['parent']
    result.append(name);return result
entries=[]
for name,record in sorted(classes.items()):
    lineage=chain(name)
    if lineage[-1] not in native:continue
    local=record['body']
    entries.append({'class':name,'parent':record['parent'],'abstract':record['abstract'],'source':record['source'],'line':record['line'],
        'chain':lineage,'direct_model_blocks':bindings[name],
        'ancestor_model_classes':[parent for parent in lineage[1:] if bindings[parent]],
        'undroppable_mentions':[parent for parent in lineage[:-1] if re.search(r'\+\s*INVENTORY\.UNDROPPABLE',classes[parent]['body'])],
        'icons':re.findall(r'Inventory\.Icon\s+"([^"]+)"',local),
        'dynamic_presentation':bool(re.search(r'UpdateWorldSprite|sprite\s*=|A_ChangeModel',local)),
        'states':re.findall(r'^\s*(\w{4})\s+([A-Z]+)\s+(-?\d+)',local,re.M)})
report={'issue':647,'scope':'Static Inventory-family candidates, including internal/non-droppable classes; native defaults and catalogue variants still require verification. Ancestor model bindings are candidates, not assumed inheritance coverage.',
        'source_classes':len(classes),'inventory_candidates':len(entries),'direct_model_classes':sum(bool(x['direct_model_blocks']) for x in entries),
        'candidates':entries}
(out/'candidates.json').write_text(json.dumps(report,indent=2)+'\n')
missing=[x['class'] for x in entries if not x['abstract'] and not x['undroppable_mentions'] and not x['direct_model_blocks']]
print(json.dumps({'source_classes':len(classes),'inventory_candidates':len(entries),'direct_model_classes':report['direct_model_classes'],'missing_direct_candidates':len(missing)}))
