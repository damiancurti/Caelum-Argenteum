#!/usr/bin/env python3
"""Valida cobertura, recorridos y recursos del incremento; no simula GZDoom."""
from pathlib import Path
from collections import Counter,deque
import json,struct,re,hashlib
R=Path(__file__).resolve().parents[2];m=json.loads((R/'assets/map02_maze/MAP02_MANIFEST.json').read_text())
checks=[]
def check(ok,name):
 assert ok,name
 checks.append(name)
loot=m['loot'];unique={(a['category'],a['type'],a['tier'],a.get('slot',0),a.get('essence',0)) for a in loot}
check(len(loot)==len(unique)==195,'195 piezas únicas')
counts=Counter(a['category'] for a in loot)
check(counts==dict(armor=48,weapon=108,shield=12,amulet=12,seal=15),'cobertura de armaduras, armas, escudos, collares y sellos T1–T3')
for tier in range(1,4):
 for kind in range(4):
  for slot in range(4):check(('armor',kind,tier,slot,0) in unique,f'armadura {kind}, pieza {slot}, tier {tier}')
 for kind in range(20):
  for essence in (range(5) if kind in (1,17,18,19) else [0]):check(('weapon',kind,tier,0,essence) in unique,f'arma {kind}, esencia {essence}, tier {tier}')
check(Counter(t['type'] for t in m['things'])[30978]*5==120,'120 raciones de comida')
check(Counter(t['type'] for t in m['things'])[30979]*5==120,'120 raciones de agua')
check(Counter(t['type'] for t in m['things'])[18037]==96,'96 Mandingas')
cells={(a[0],a[1]):a[2:] for a in m['cells']}
def walk(keys):
 start=(-1152,0);seen={start};queue=deque([start])
 while queue:
  a=queue.popleft()
  for dx,dy in [(32,0),(-32,0),(0,32),(0,-32)]:
   b=(a[0]+dx,a[1]+dy)
   if b in seen or b not in cells:continue
   f,c,g,tag,w=cells[b]
   if tag and tag-43701>=keys:continue
   if c-f<56 and not tag:continue
   if f-cells[a][0]>24:continue
   seen.add(b);queue.append(b)
 return seen
progress=[]
for keys in range(4):
 reachable=walk(keys)
 for z in range(3):
  x,y=m['zones'][z]['position'];check(((x//32*32,y//32*32) in reachable)==(z<=keys),f'progresión {keys} llaves, llave {z+1}')
 check(((1152,10112) in reachable)==(keys==3),f'cámara final requiere tres llaves ({keys})')
 progress.append(len(reachable))
check(len(walk(3))==len(cells),'todo el suelo, incluidos pozos y peldaños, es alcanzable')
for trap in m['traps']:
 if trap['type']=='pit':
  x,y=trap['position'];check((x-64,y-32) in walk(3),'pozo comunicado con sus peldaños')
b=(R/'src/maps/MAP02.wad').read_bytes();magic,n,o=struct.unpack_from('<4sii',b);lumps={}
for i in range(n):
 off,size,name=struct.unpack_from('<ii8s',b,o+i*16);lumps[name.rstrip(b'\0').decode()]=b[off:off+size]
check(magic==b'PWAD' and 'TEXTMAP' in lumps and 'ENDMAP' in lumps,'WAD UDMF íntegro')
s=lumps['TEXTMAP'].decode();check(s.count('thing\n{')==len(m['things']),'cantidad de actores en WAD coincide con manifiesto')
check(s.count('sector\n{')==m['geometry']['sectors'],'sectores WAD coinciden con manifiesto')
check(len(re.findall(r'special = 13;',s))==36,'contornos de las tres puertas nativas')
textures=(R/'src/TEXTURES').read_text()
for family,x in [(16,3),(17,2.45)]:
 for tier in range(1,4):
  for phase in 'ABC':
   block=re.search(rf'Sprite "D{family}{tier}{phase}0",.*?\n\}}',textures,re.S).group()
   check(float(re.search(r'XScale ([\d.]+)',block)[1])==x,'espesor doble: '+str(family)+str(tier)+phase)
check('upper.bOnMobj' in (R/'src/caelum/world/CaelumWeightPressure.zs').read_text(),'peso exige apoyo nativo')
report=dict(version='4.36.0i',checks=len(checks),passed=True,category_counts=counts,trap_counts=Counter(t['type'] for t in m['traps']),reachable_cells_by_keys=progress,map02_sha256=hashlib.sha256(b).hexdigest(),limits='Prueba estática de cobertura y suelo; no reemplaza radio/colisión/combate en motor.')
(R/'assets/validation_0i/STATIC_CONTENT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(report,ensure_ascii=False))
