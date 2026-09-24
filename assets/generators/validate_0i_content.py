#!/usr/bin/env python3
"""Check the current MAP02 catalogue, progression and resources; no engine simulation."""
from pathlib import Path
from collections import Counter,deque
import json,struct,re,hashlib
R=Path(__file__).resolve().parents[2];m=json.loads((R/'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
checks=[]
def check(ok,name):
 assert ok,name
 checks.append(name)
loot=m['loot'];unique={(a['category'],a['type'],a['tier'],a.get('slot',0),a.get('essence',0)) for a in loot}
check(len(loot)==len(unique)==65,'65 unique T1 items')
counts=Counter(a['category'] for a in loot)
check(counts==dict(armor=16,weapon=36,shield=4,amulet=4,seal=5),'complete T1 category counts')
for tier in [1]:
 for kind in range(4):
  for slot in range(4):check(('armor',kind,tier,slot,0) in unique,f'armor {kind}, slot {slot}, tier {tier}')
 for kind in range(20):
  for essence in (range(5) if kind in (1,17,18,19) else [0]):check(('weapon',kind,tier,0,essence) in unique,f'weapon {kind}, essence {essence}, tier {tier}')
for category,total in [('shield',4),('amulet',4),('seal',5)]:
 for kind in range(total):check((category,kind,1,0,0) in unique,f'{category} {kind}, T1')
check(all(a['tier']==1 for a in loot),'no T2/T3 in the MAP02 catalogue')
check({a['catalogue_index'] for a in loot}==set(range(65)),'stable complete catalogue indices')
check(Counter(Counter(a['chest'] for a in loot).values())=={2:26,1:13},'65 entries distributed across all 39 chests')
for a in loot:
 check(a['catalogue_index']==a['chest']+a['chest_slot']*39,'catalogue and runtime chest slot mapping agree')
 check(a['size_policy']==('CHARACTER_DEFAULT' if a['category'] in ('weapon','armor','shield') else 'NOT_APPLICABLE'),'explicit recipient-size policy')
catalogue=(R/'src/caelum/world/CaelumMazeLootCatalogue.zs').read_text(encoding='utf-8')
check(len(re.findall(r'item=Inventory\(Actor.Spawn',catalogue))==65,'65 real runtime inventory entries')
check(catalogue.count('.SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT;')==56,'all 56 sized runtime items use explicit recipient policy')
for a in loot:
 block=re.search(rf'case {a["catalogue_index"]}:\s*item=Inventory\(Actor.Spawn\("([^"\n]+)"(.*?)break;',catalogue,re.S)
 check(block is not None and block[1]==a['cls'],'runtime item class matches manifest')
 for index,value in enumerate(a['args']):check(f'item.args[{index}]={value};' in block[2],'runtime item arguments match manifest')
# The map authors no loose equipment or alternate grants; chests are its only equipment source.
check(not any(a['type'] in (18100,18101,18102,18130,18131) for a in m['things']),'no undocumented loose MAP02 equipment sources')
check(Counter(t['type'] for t in m['things'])[30978]*5==120,'120 food rations')
check(Counter(t['type'] for t in m['things'])[30979]*5==120,'120 water rations')
check(Counter(t['type'] for t in m['things'])[18037]==96,'96 Mandingas')
# Radius-aware topology is maintained independently from catalogue assertions.
from validate_map02_layout import main as validate_layout
check(not validate_layout(), 'four-section native geometry, counts and keyed routes')
b=(R/'src/maps/MAP02.wad').read_bytes();magic,n,o=struct.unpack_from('<4sii',b);lumps={}
for i in range(n):
 off,size,name=struct.unpack_from('<ii8s',b,o+i*16);lumps[name.rstrip(b'\0').decode()]=b[off:off+size]
check(magic==b'PWAD' and 'TEXTMAP' in lumps and 'ENDMAP' in lumps,'valid UDMF WAD')
s=lumps['TEXTMAP'].decode();check(s.count('thing\n{')==len(m['things']),'WAD actor count matches manifest')
check(s.count('sector\n{')==m['geometry']['sectors'],'WAD sector count matches manifest')
check(len(re.findall(r'special = 13;',s))==sum(g['width']//32 for g in m['gates']),'all native barred-gate segments')
textures=(R/'src/TEXTURES').read_text()
for family,x in [(16,3),(17,2.45)]:
 for tier in range(1,4):
  for phase in 'ABC':
   block=re.search(rf'Sprite "D{family}{tier}{phase}0",.*?\n\}}',textures,re.S).group()
   check(float(re.search(r'XScale ([\d.]+)',block)[1])==x,'double thickness: '+str(family)+str(tier)+phase)
check('upper.bOnMobj' in (R/'src/caelum/world/CaelumWeightPressure.zs').read_text(),'weight requires native support')
report=dict(version='4.36.5',checks=len(checks),passed=True,category_counts=counts,trap_counts=Counter(t['type'] for t in m['traps']),map02_sha256=hashlib.sha256(b).hexdigest(),limits='Static coverage and floor-connectivity checks; does not replace native engine radius, collision or combat tests.')
(R/'assets/validation_4365').mkdir(exist_ok=True)
(R/'assets/validation_4365/STATIC_CONTENT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
