#!/usr/bin/env python3
"""MAP02 4.36.0i: laberinto reproducible, tres llaves y catálogo completo.
No reescribe otros WAD. Geometría UDMF nativa; parámetros de trampas existentes.
"""
from pathlib import Path
from collections import deque,Counter
import random,struct,json
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/map02_maze';OUT.mkdir(exist_ok=True)
CELL=32; rng=random.Random(436009)
cells={};things=[]; rooms=[];zones=[];locks={};contents=[];features=[]
flags=dict(skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True)
def room(x1,y1,x2,y2,floor=0,ceiling=320,group=0,tag=0,water=False):
 assert all(v%CELL==0 for v in (x1,y1,x2,y2))
 for x in range(x1,x2,CELL):
  for y in range(y1,y2,CELL):cells[x,y]=(floor,ceiling,group,tag,water)
def thing(kind,x,y,z=0,angle=90,tid=0,args=(),count=1):
 t=dict(x=x,y=y,height=z,angle=angle,type=kind,**flags)
 if tid:t['id']=tid
 for i,a in enumerate(args):t['arg'+str(i)]=a
 things.append(t);return t
def coord(z,n):return (-1152+n[0]*384,512+z*3072+n[1]*384)
def edge(a,b):return tuple(sorted((a,b)))
def distances(graph,start):
 out={start:0};q=deque([start])
 while q:
  a=q.popleft()
  for b in graph[a]:
   if b not in out:out[b]=out[a]+1;q.append(b)
 return out
# Un vestíbulo separado permite llegar desde el Limbo sin activar peligros.
room(-1536,-256,-768,256,group=0)
room(-1216,256,-1088,512,group=0)
thing(1,-1152,0)
for z in range(3):
 nodes=[(x,y) for y in range(7) for x in range(7)];graph={n:set() for n in nodes}
 stack=[(0,0)];seen={(0,0)}
 while stack:
  a=stack[-1];near=[(a[0]+dx,a[1]+dy) for dx,dy in ((1,0),(-1,0),(0,1),(0,-1))]
  near=[b for b in near if b in graph and b not in seen]
  if not near:stack.pop();continue
  b=rng.choice(near);graph[a].add(b);graph[b].add(a);seen.add(b);stack.append(b)
 # Ramales ciegos y algunos bucles para flanquear enemigos y esquivar trampas.
 closed=[(a,(a[0]+dx,a[1]+dy)) for a in nodes for dx,dy in ((1,0),(0,1)) if (a[0]+dx,a[1]+dy) in graph and (a[0]+dx,a[1]+dy) not in graph[a]]
 rng.shuffle(closed)
 for a,b in closed[:8]:graph[a].add(b);graph[b].add(a)
 for n in nodes:
  x,y=coord(z,n);room(x-128,y-128,x+128,y+128,group=z+1);rooms.append(dict(zone=z,node=n,center=[x,y]))
 for a in nodes:
  for b in graph[a]:
   if a>b:continue
   x,y=coord(z,a);xx,yy=coord(z,b)
   room(min(x,xx)-64,min(y,yy)-64,max(x,xx)+64,max(y,yy)+64,group=z+1)
 dist=distances(graph,(0,0));assert len(dist)==49
 keynode=max((n for n in nodes if n not in [(0,0),(6,6)]),key=lambda n:dist[n])
 kx,ky=coord(z,keynode);thing(30970+z,kx,ky,tid=43710+z)
 keyinfo=dict(zone=z,key=z+1,node=list(keynode),position=[kx,ky],distance=dist[keynode])
 zones.append(dict(**keyinfo,edges=[[list(a),list(b)] for a in nodes for b in graph[a] if a<b]))
 # Trece cofres por tier, cinco piezas por cofre: 65 objetos distintos.
 loot=[];tier=z+1
 for armor in range(4):
  for slot in range(4):loot.append(dict(cls='CaelumArmorPickup',args=[slot,armor,tier,3,0],category='armor',type=armor,slot=slot,tier=tier))
 for weapon in range(20):
  for essence in (range(5) if weapon in (1,17,18,19) else [0]):
   loot.append(dict(cls='CaelumWeaponPickup',args=[weapon,tier,3,0,essence+1],category='weapon',type=weapon,essence=essence,tier=tier))
 for shield in range(4):loot.append(dict(cls='CaelumShieldPickup',args=[shield,tier,3,0,0],category='shield',type=shield,tier=tier))
 for amulet in range(4):loot.append(dict(cls='CaelumAmuletPickup',args=[amulet,tier,0,0,0],category='amulet',type=amulet,tier=tier))
 for seal in range(5):loot.append(dict(cls='CaelumSealPickup',args=[seal,tier,0,0,0],category='seal',type=seal,tier=tier))
 assert len(loot)==65
 candidates=[n for n in nodes if n not in [(0,0),(6,6),keynode]];rng.shuffle(candidates)
 chestnodes=candidates[:13]
 for c,n in enumerate(chestnodes):
  x,y=coord(z,n);index=z*13+c;thing(30973,x-64,y+64,angle=270,args=[index],tid=43800+index)
  for item in loot[c*5:(c+1)*5]:item.update(chest=index,position=[x-64,y+64]);contents.append(item)
 # Ocho pilas de cinco unidades por sección, por cada necesidad.
 for n in candidates[13:21]:
  x,y=coord(z,n);thing(30978,x-64,y+64);thing(30979,x+64,y+64)
 # Trampas: minas, transporte, techos, rocas rodantes/verticales y pozos.
 trapnodes=candidates[21:36]
 for k,n in enumerate(trapnodes):
  x,y=coord(z,n);tid=43900+z*100+k
  if k<4:
   thing(30963,x,y,z=.5,tid=tid,args=[100,128]);kind='mine'
  elif k<6:
   dx,dy=coord(z,(0,0));thing(30965,dx+64,dy,tid=tid+50)
   thing(30964,x,y,z=.5,tid=tid,args=[tid+50]);kind='teleport'
  elif k<9:
   room(x-64,y-64,x+64,y+64,group=tid)
   thing(30966,x,y,z=.5,tid=tid,args=[10,8,0]);kind='crusher'
  elif k<11:
   thing(30961,x,y+80,angle=270,tid=tid+50,args=[32])
   thing(30975,x,y-48,z=.5,tid=tid,args=[tid+50]);kind='rolling_rock'
  elif k<13:
   thing(30961,x,y+48,z=192,tid=tid+50)
   thing(30975,x,y+48,z=.5,tid=tid,args=[tid+50]);kind='falling_rock'
  else:
   # Pozo de 96 MU con una salida de seis peldaños de 16 MU, caminable.
   room(x-128,y-96,x,y+32,floor=-96,group=tid,water=True)
   room(x,y-96,x+64,y-64,floor=-96,group=tid)
   for step in range(6):room(x,y-64+step*32,x+64,y-32+step*32,floor=-96+(step+1)*16,group=tid)
   thing(30976,x-64,y-32,z=88,tid=tid);kind='pit'
  features.append(dict(zone=z,type=kind,position=[x,y],tid=tid))
 # 32 Mandingas por sección. Los recursos y las llaves no ocupan su cilindro.
 enemy_nodes=[n for n in candidates if n!=keynode][:32]
 for n in enemy_nodes:
  x,y=coord(z,n);thing(18037,x+64,y-64,angle=270)
 # La única conexión hacia la sección siguiente atraviesa su puerta con llave.
 endy=2816+z*3072;gatey=3072+z*3072;tag=43701+z
 if z<2:
  bridgey=3264+z*3072;room(1088,endy,1216,bridgey+64,group=z+1)
  room(-1216,bridgey-64,1216,bridgey+64,group=z+1)
  room(-1216,bridgey,-1088,3584+z*3072,group=z+2)
 else:
  room(1088,endy,1216,9408,group=3)
 room(1088,gatey-32,1216,gatey+32,ceiling=0,group=tag,tag=tag)
 locks[tag]=203+z
# Cámara final: espacio para el Zupay y pasos libres hacia los accesos.
room(640,9344,1664,10368,ceiling=448,group=4)
thing(18038,1152,9728,angle=270,tid=43799)
thing(30974,1152,10112,z=32,tid=43798)
thing(1,864,9472,args=[1])
# Geometría: unir celdas idénticas evita miles de sectores/líneas superfluos.
sectors=[];sector_ids={};vertices=[];vertex_ids={};sides=[];lines=[];edges={}
def sector(v):
 if v not in sector_ids:
  floor,ceil,group,tag,water=v;sector_ids[v]=len(sectors)
  tint=[0xC8C4B0,0xADBDAF,0xB6ADB9,0xC1AA89,0xA6BDCC][group if group in range(5) else 1]
  sectors.append(dict(heightfloor=floor,heightceiling=ceil,texturefloor='CAPOOL01' if water else 'CASWRFLR',textureceiling='CASWRWAL',lightlevel=160 if group<4 else 176,lightcolor=tint,id=tag))
 return sector_ids[v]
def vertex(v):
 if v not in vertex_ids:vertex_ids[v]=len(vertices);vertices.append(dict(x=v[0],y=v[1]))
 return vertex_ids[v]
for (x,y),v in sorted(cells.items()):
 idx=sector(v);corners=[(x,y),(x,y+CELL),(x+CELL,y+CELL),(x+CELL,y)];near=[(x-CELL,y),(x,y+CELL),(x+CELL,y),(x,y-CELL)]
 for j,(a,b) in enumerate(zip(corners,corners[1:]+corners[:1])):
  if cells.get(near[j])==v:continue
  side=len(sides);sides.append(dict(sector=idx,texturetop='CASWRWAL',texturebottom='CASWRWAL',texturemiddle='CASWRWAL'))
  key=tuple(sorted((a,b)))
  if key in edges:
   l=lines[edges[key]];l['sideback']=side;l['twosided']=True;l.pop('blocking',None)
   sides[l['sidefront']]['texturemiddle']='-';sides[side]['texturemiddle']='-'
  else:
   edges[key]=len(lines);l=dict(v1=vertex(a),v2=vertex(b),sidefront=side,blocking=True);lines.append(l)
  tag=v[3] or (cells.get(near[j],(0,0,0,0,False))[3])
  if tag in locks:
   l.update(special=13,arg0=tag,arg1=32,arg2=150,arg3=locks[tag],playeruse=True,playeruseback=True,repeatspecial=True)
def value(v):
 return str(v).lower() if isinstance(v,bool) else json.dumps(v) if isinstance(v,str) else str(v)
text=['namespace = "ZDoom";\n// MAP02 4.36.0i. Fuente: assets/generators/generate_map02_maze.py\n']
for kind,entries in [('vertex',vertices),('sector',sectors),('sidedef',sides),('linedef',lines),('thing',things)]:
 for entry in entries:text.append(kind+'\n{\n'+''.join(f'    {k} = {value(v)};\n' for k,v in entry.items())+'}\n')
body=bytearray();directory=bytearray()
for name,data in [('MAP02',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]:
 directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode().ljust(8,b'\0'));body+=data
(ROOT/'src/maps/MAP02.wad').write_bytes(struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory)
# El mismo catálogo alimenta los cofres reales y el registro de cobertura.
zs=['// Generado por generate_map02_maze.py. Cada cofre tiene cinco objetos únicos.\nclass CaelumMazeLootCatalogue : Object play\n{\n    static Inventory Create(int index, vector3 position)\n    {\n        switch(index / 20)\n        {']
for batch in range((len(contents)+19)//20):
 zs.append(f'        case {batch}: return Create{batch}(index,position);')
zs.append('        }\n        return null;\n    }')
for batch in range((len(contents)+19)//20):
 zs.append(f'    static Inventory Create{batch}(int index, vector3 position)\n    {{\n        Inventory item;\n        switch(index)\n        {{')
 for i in range(batch*20,min((batch+1)*20,len(contents))):
  item=contents[i];args=item['args'];zs.append(f'        case {i}:\n            item=Inventory(Actor.Spawn("{item["cls"]}",position,NO_REPLACE));\n            if(item!=null) {{ '+''.join(f'item.args[{k}]={v};' for k,v in enumerate(args))+' }\n            break;')
 zs.append('        }\n        return item;\n    }')
zs.append('}\n');(ROOT/'src/caelum/world/CaelumMazeLootCatalogue.zs').write_text('\n'.join(zs))
manifest=dict(version='4.36.0i',seed=436009,zones=zones,rooms=rooms,locks=locks,loot=contents,traps=features,things=things,counts=dict(rooms=len(rooms),mandingas=96,zupays=1,chests=39,equipment=len(contents),food_rations=120,water_rations=120,traps=len(features)),geometry=dict(sectors=len(sectors),lines=len(lines),vertices=len(vertices)),cells=[list(k)+list(v) for k,v in cells.items()])
(OUT/'MAP02_MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(manifest['counts']);print(manifest['geometry'])
