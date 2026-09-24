#!/usr/bin/env python3
"""Generate the revision-2 four-section sewer, retaining the accepted T1 catalogue.
Authored layout data is in assets/map02_maze/LAYOUT.json. No other map is written.
"""
from pathlib import Path
from collections import deque, Counter
import random, struct, json, hashlib
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/map02_maze';OUT.mkdir(exist_ok=True)
cfg=json.loads((OUT/'LAYOUT.json').read_text(encoding='utf-8'))
CELL=cfg['grid'];rng=random.Random(cfg['seed'])
cells={};things=[];rooms=[];zones=[];locks={};contents=[];features=[];gates=[];refuges=[];prisoners=[];rats=[]
flags=dict(skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True)
def room(x1,y1,x2,y2,floor=0,ceiling=None,group=0,tag=0,water=False):
 ceiling=cfg['ceiling'] if ceiling is None else ceiling
 assert all(v%CELL==0 for v in (x1,y1,x2,y2))
 for x in range(x1,x2,CELL):
  for y in range(y1,y2,CELL):cells[x,y]=(floor,ceiling,group,tag,water)
def thing(kind,x,y,z=0,angle=90,tid=0,args=()):
 t=dict(x=x,y=y,height=z,angle=angle,type=kind,**flags)
 if tid:t['id']=tid
 for i,a in enumerate(args):t['arg'+str(i)]=a
 things.append(t);return t
def coord(z,n):return (cfg['first_node_x']+n[0]*cfg['node_spacing'],cfg['first_section_y']+z*cfg['section_stride']+n[1]*cfg['node_spacing'])
def corridor(a,b,group,channel=True):
 x,y=a;xx,yy=b;w=cfg['passage_width']//2;c=cfg['channel_width']//2
 assert x==xx or y==yy
 room(min(x,xx)-w,min(y,yy)-w,max(x,xx)+w,max(y,yy)+w,group=group)
 if channel:
  if y==yy:room(min(x,xx),y-c,max(x,xx),y+c,floor=-cfg['channel_depth'],group=group,water=True)
  else:room(x-c,min(y,yy),x+c,max(y,yy),floor=-cfg['channel_depth'],group=group,water=True)
def distances(graph,start):
 out={start:0};q=deque([start])
 while q:
  a=q.popleft()
  for b in sorted(graph[a]):
   if b not in out:out[b]=out[a]+1;q.append(b)
 return out
def gate(center,axis,tag,lock,role,zone):
 x,y=center;w=cfg['passage_width']//2
 if axis=='x':room(x-32,y-w,x+32,y+w,ceiling=cfg['gate_height'],group=tag)
 else:room(x-w,y-32,x+w,y+32,ceiling=cfg['gate_height'],group=tag)
 gates.append(dict(center=[x,y],axis=axis,tag=tag,lock=lock,role=role,zone=zone,width=cfg['passage_width'],height=cfg['gate_height']))
 locks[tag]=lock;thing(30980,x,y,tid=tag,args=[tag,lock])
room(-1920,-320,-768,320,group=0)
corridor((-1152,0),(-1152,512),0,False)
corridor((-1152,512),(-1536,512),0,False)
corridor((-1536,512),coord(0,(0,0)),1,False)
thing(1,-1152,0);thing(30981,-1792,0,tid=44800,args=[cfg['revision']])
# One copy of each T1 entry; 26 chests have two entries, 13 have one.
loot=[];tier=1
for armor in range(4):
 for slot in range(4):loot.append(dict(cls='CaelumArmorPickup',args=[slot,armor,tier,0,0],category='armor',type=armor,slot=slot,tier=tier))
for weapon in range(20):
 for essence in (range(5) if weapon in (1,17,18,19) else [0]):
  loot.append(dict(cls='CaelumWeaponPickup',args=[weapon,tier,0,0,essence+1],category='weapon',type=weapon,essence=essence,tier=tier))
for shield in range(4):loot.append(dict(cls='CaelumShieldPickup',args=[shield,tier,0,0,0],category='shield',type=shield,tier=tier))
for amulet in range(4):loot.append(dict(cls='CaelumAmuletPickup',args=[amulet,tier,0,0,0],category='amulet',type=amulet,tier=tier))
for seal in range(5):loot.append(dict(cls='CaelumSealPickup',args=[seal,tier,0,0,0],category='seal',type=seal,tier=tier))
assert len(loot)==65
for item in loot:
 item["size_policy"]="CHARACTER_DEFAULT" if item["category"] in ("armor","weapon","shield") else "NOT_APPLICABLE"

trap_types=['mine']*12+['teleport']*6+['crusher']*9+['rolling_rock']*6+['falling_rock']*6+['pit']*6
rng.shuffle(trap_types);trap_index=0;chest_index=0
for z in range(4):
 nodes=[(x,y) for y in range(cfg['nodes_per_axis']) for x in range(cfg['nodes_per_axis'])];graph={n:set() for n in nodes}
 start=(0,0);end=(4,4);stack=[start];seen={start}
 while stack:
  a=stack[-1];near=[(a[0]+dx,a[1]+dy) for dx,dy in ((1,0),(-1,0),(0,1),(0,-1))]
  near=[b for b in near if b in graph and b not in seen]
  if not near:stack.pop();continue
  b=rng.choice(near);graph[a].add(b);graph[b].add(a);seen.add(b);stack.append(b)
 closed=[(a,(a[0]+dx,a[1]+dy)) for a in nodes for dx,dy in ((1,0),(0,1)) if (a[0]+dx,a[1]+dy) in graph and (a[0]+dx,a[1]+dy) not in graph[a]]
 rng.shuffle(closed)
 for a,b in closed[:4]:graph[a].add(b);graph[b].add(a)
 for a in nodes:
  for b in sorted(graph[a]):
   if a<b:corridor(coord(z,a),coord(z,b),z+1)
 # Level stone crossings at every bend/junction; shallow channels are harmless.
 half=cfg['room_width']//2
 for n in nodes:
  x,y=coord(z,n);room(x-half,y-half,x+half,y+half,group=z+1);rooms.append(dict(zone=z,node=list(n),center=[x,y]))
 dist=distances(graph,start);keynode=max((n for n in nodes if n not in [start,end]),key=lambda n:(dist[n],n))
 cellnode=max((n for n in nodes if n not in [start,end,keynode]),key=lambda n:(dist[n],n))
 kx,ky=coord(z,keynode);keytype=30970+z if z<3 else 30982
 thing(keytype,kx-256,ky,tid=43710+z)
 cx,cy=coord(z,cellnode);thing(30983+z,cx+256,cy,tid=43720+z)
 zones.append(dict(zone=z,name=cfg['section_names'][z],key=z+1,node=list(keynode),position=[kx-256,ky],cell_key_position=[cx+256,cy],distance=dist[keynode],edges=[[list(a),list(b)] for a in nodes for b in sorted(graph[a]) if a<b]))
 candidates=[n for n in nodes if n not in [start,end]];rng.shuffle(candidates)
 for n in candidates[:cfg['chests_per_section'][z]]:
  x,y=coord(z,n);index=chest_index;chest_index+=1
  thing(30973,x-192,y+192,angle=270,args=[index],tid=43800+index)
  for ci in range(index,len(loot),39):
   item=dict(loot[ci]);item.update(catalogue_index=ci,chest=index,chest_slot=ci//39,position=[x-192,y+192]);contents.append(item)
 for n in candidates[10:16]:
  x,y=coord(z,n);thing(30978,x-128,y-192);thing(30979,x+128,y-192)
 for key,kind,offset in [('arrow',18111,-128),('bolt',18112,0),('bullet',18110,128)]:
  for n in candidates[16:16+cfg[key+'_bundles_per_section'][z]]:
   x,y=coord(z,n);thing(kind,x+offset,y+128)
 for n in candidates[:cfg['traps_per_section'][z]]:
  x,y=coord(z,n);kind=trap_types[trap_index];tid=43900+trap_index;trap_index+=1
  if kind=='mine':thing(30963,x,y,z=.5,tid=tid,args=[100,128])
  elif kind=='teleport':
   dx,dy=coord(z,start);thing(30965,dx+128,dy,tid=tid+100);thing(30964,x,y,z=.5,tid=tid,args=[tid+100])
  elif kind=='crusher':
   room(x-64,y-64,x+64,y+64,group=tid);thing(30966,x,y,z=.5,tid=tid,args=[10,8,0])
  elif kind=='rolling_rock':
   thing(30961,x,y+80,angle=270,tid=tid+100,args=[32]);thing(30975,x,y-48,z=.5,tid=tid,args=[tid+100])
  elif kind=='falling_rock':
   thing(30961,x,y+48,z=192,tid=tid+100);thing(30975,x,y+48,z=.5,tid=tid,args=[tid+100])
  else:
   room(x-128,y-96,x,y+32,floor=-96,group=tid,water=True)
   room(x,y-96,x+128,y-64,floor=-96,group=tid)
   for step in range(6):room(x,y-64+step*32,x+128,y-32+step*32,floor=-96+(step+1)*16,group=tid)
   thing(30976,x-64,y-32,z=88,tid=tid)
  features.append(dict(zone=z,type=kind,position=[x,y],tid=tid))
 for n in [n for n in nodes if n!=start]:
  x,y=coord(z,n);thing(18037,x+192,y-192,angle=270)
  # Two fixed dry-walkway positions per junction keep the 2:1 rat ratio without RNG.
  thing(18029,x-192,y-64,angle=90);thing(18029,x+192,y+64,angle=270)
  rats.append(dict(zone=z,node=list(n),position=[x-192,y-64]))
  rats.append(dict(zone=z,node=list(n),position=[x+192,y+64]))
 # A protected service alcove per section. Existing repair rules/stations only.
 sx,sy=coord(z,start);rx=sx-1024
 corridor((sx,sy),(rx,sy),z+1,False);room(rx-320,sy-320,rx+320,sy+320,group=z+1)
 gate((sx-576,sy),'x',44720+z,0,'refuge',z)
 stations=[]
 for kind,dx,dy in [(18004,-64,-64),(18000,0,0),(18001,64,-64),(18003,0,-128)]:
  thing(kind,rx+dx,sy+dy,angle=90);stations.append(dict(type=kind,position=[rx+dx,sy+dy]))
 refuges.append(dict(zone=z,center=[rx,sy],stations=stations,resource_allowance='none; known recipes and existing finite salvage only'))
 ex,ey=coord(z,end);cellx=ex+1024
 corridor((ex,ey),(cellx,ey),z+1,False);room(cellx-320,ey-320,cellx+320,ey+320,group=z+1)
 gate((ex+576,ey),'x',44710+z,207+z,'cell',z)
 thing(30987,cellx-96,ey-160,angle=90,tid=44810+z)
 thing(30981,cellx+96,ey+96,tid=44820+z,args=[10+z])
 prisoners.append(dict(zone=z,cell_center=[cellx,ey],bed=[cellx-96,ey-160],reserved_actor=[cellx+96,ey+96],lock=207+z))
 bridgey=ey+768
 corridor((ex,ey),(ex,bridgey),z+1,False)
 if z<3:
  nsx,nsy=coord(z+1,start);corridor((ex,bridgey),(nsx,bridgey),z+1,False);corridor((nsx,bridgey),(nsx,nsy),z+2,False)
  gate((ex,ey+384),'y',44700+z,203+z,'section',z)
 else:
  # Refuge/extraction route is outside the final keyed arena; no player exit here.
  extraction=[ex-640,bridgey];corridor((ex,bridgey),tuple(extraction),4,False)
  room(extraction[0]-256,bridgey-256,extraction[0]+256,bridgey+256,group=4)
  thing(30981,*extraction,tid=44830,args=[20])
  bossdoor=[ex,ey+1024];corridor((ex,bridgey),(ex,ey+1408),4,False)
  gate(tuple(bossdoor),'y',44703,206,'boss',z)
  boss_center=[ex,ey+2176];room(ex-1024,ey+1280,ex+1024,ey+3200,ceiling=448,group=5)
  thing(18038,*boss_center,angle=270,tid=43799)
  card=[ex,ey+2880];thing(30974,*card,z=32,tid=43798)
  thing(1,ex-512,ey+1600,args=[1])
  travel={2:[ex-832,ey+1728,0],4:[ex+832,ey+1728,0],6:[ex-832,ey+2624,0],14:[ex,ey+3072,0]}
# Existing iron material forms overhead service conduits, outside all walkways.
conduits=[]
for z in range(4):
 x,y=coord(z,(0,0))
 for strip,ceiling in [(-32,272),(0,256),(32,272)]:
  room(x-256,y+224+strip,x+256,y+256+strip,ceiling=ceiling,group=46000+z)
 conduits.append(dict(zone=z,center=[x,y+240],width=96,clear_height=256,texture='CASWRPIP'))
# Existing safe-time radii are retained: 224 MU for slot 1, 320 MU thereafter.
# Cover the relocated arrival furniture/workshops and the authored service/cell areas.
time_advance_zones=[dict(position=cfg['arrival']['bed'],role='arrival_rest'),dict(position=cfg['arrival']['workbench'],role='arrival_workshops')]
time_advance_zones += [dict(position=r['center']+[0],role='refuge',zone=r['zone']) for r in refuges]
time_advance_zones += [dict(position=p['bed']+[0],role='cell_bed',zone=p['zone']) for p in prisoners]
# Stable sector/line ordering and explicit gate segments preserve reproducibility.
sectors=[];sector_ids={};vertices=[];vertex_ids={};sides=[];lines=[];edges={}
def sector(v):
 if v not in sector_ids:
  floor,ceil,group,tag,water=v;sector_ids[v]=len(sectors)
  tint=int(cfg['section_tints'][group-1],16) if 1<=group<=4 else 0xC8C4B0
  sectors.append(dict(heightfloor=floor,heightceiling=ceil,texturefloor='CAPOOL01' if water else 'CASWRFLR',textureceiling='CASWRPIP' if group>=46000 else 'CASWRWAL',lightlevel=176 if group==5 else 160,lightcolor=tint,id=tag))
 return sector_ids[v]
def vertex(v):
 if v not in vertex_ids:vertex_ids[v]=len(vertices);vertices.append(dict(x=v[0],y=v[1]))
 return vertex_ids[v]
for (x,y),v in sorted(cells.items()):
 idx=sector(v);corners=[(x,y),(x,y+CELL),(x+CELL,y+CELL),(x+CELL,y)];near=[(x-CELL,y),(x,y+CELL),(x+CELL,y),(x,y-CELL)]
 for j,(a,b) in enumerate(zip(corners,corners[1:]+corners[:1])):
  barrier=None
  for g in gates:
   gx,gy=g['center'];w=g['width']//2
   if g['axis']=='x' and a[0]==b[0]==gx and min(a[1],b[1])>=gy-w and max(a[1],b[1])<=gy+w:barrier=g;break
   if g['axis']=='y' and a[1]==b[1]==gy and min(a[0],b[0])>=gx-w and max(a[0],b[0])<=gx+w:barrier=g;break
  if cells.get(near[j])==v and barrier is None:continue
  wall='CASWRPIP' if v[2]>=46000 or cells.get(near[j],(0,0,0,0,False))[2]>=46000 else 'CASWRWAL'
  side=len(sides);sides.append(dict(sector=idx,texturetop=wall,texturebottom='CASWRWAL',texturemiddle=wall))
  key=tuple(sorted((a,b)))
  if key in edges:
   l=lines[edges[key]];l['sideback']=side;l['twosided']=True;l.pop('blocking',None)
   sides[l['sidefront']]['texturemiddle']='-';sides[side]['texturemiddle']='-'
  else:
   edges[key]=len(lines);l=dict(v1=vertex(a),v2=vertex(b),sidefront=side,blocking=True);lines.append(l)
  if barrier:
   # The runtime opens these native blockers; sight deliberately remains clear.
   l.update(id=barrier['tag'],special=13,arg0=barrier['tag'],arg1=32,arg2=150,arg3=barrier['lock'],playeruse=True,playeruseback=True,repeatspecial=True,blocking=True,blockprojectiles=True,blockhitscan=True,blockuse=True,dontpegbottom=True)
   for si in [l['sidefront']]+([l['sideback']] if 'sideback' in l else []):
    sides[si]['texturemiddle']='CMGT02';sides[si]['offsetx']=min(a[1],b[1])%128 if barrier['axis']=='x' else min(a[0],b[0])%128
def value(v):return str(v).lower() if isinstance(v,bool) else json.dumps(v) if isinstance(v,str) else str(v)
text=['namespace = "ZDoom";\n// MAP02 revision 2, 4.36.6; generated from LAYOUT.json.\n']
for kind,entries in [('vertex',vertices),('sector',sectors),('sidedef',sides),('linedef',lines),('thing',things)]:
 for entry in entries:text.append(kind+'\n{\n'+''.join(f'    {k} = {value(v)};\n' for k,v in entry.items())+'}\n')
body=bytearray();directory=bytearray()
for name,data in [('MAP02',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]:
 directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode().ljust(8,b'\0'));body+=data
(ROOT/'src/maps/MAP02.wad').write_bytes(struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory)
# Stable catalogue indices are independent of chest positions and future sections.
zs=['// Generado por generate_map02_maze.py. 65 piezas T1, sin duplicados.\nclass CaelumMazeLootCatalogue : Object play\n{\n    const REVISION = 1;\n    const ENTRY_COUNT = 65;\n    const CHEST_COUNT = 39;\n\n    static int ChestEntry(int chest, int slot)\n    {\n        int index=chest+slot*CHEST_COUNT;\n        return chest>=0 && chest<CHEST_COUNT && slot>=0 && index<ENTRY_COUNT?index:-1;\n    }\n\n    static Inventory Create(int index, vector3 position)\n    {\n        if(index<0 || index>=ENTRY_COUNT)return null;\n        switch(index / 20)\n        {']
for batch in range((len(loot)+19)//20):
 zs.append(f'        case {batch}: return Create{batch}(index,position);')
zs.append('        }\n        return null;\n    }')
for batch in range((len(loot)+19)//20):
 zs.append(f'    static Inventory Create{batch}(int index, vector3 position)\n    {{\n        Inventory item;\n        switch(index)\n        {{')
 for i in range(batch*20,min((batch+1)*20,len(loot))):
  item=loot[i];args=item['args'];policy=f'{item["cls"]}(item).SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT;' if item['size_policy']=='CHARACTER_DEFAULT' else ''
  zs.append(f'        case {i}:\n            item=Inventory(Actor.Spawn("{item["cls"]}",position,NO_REPLACE));\n            if(item!=null) {{ '+''.join(f'item.args[{k}]={v};' for k,v in enumerate(args))+policy+' }\n            break;')
 zs.append('        }\n        return item;\n    }')
zs.append('}\n');(ROOT/'src/caelum/world/CaelumMazeLootCatalogue.zs').write_text('\n'.join(zs),encoding='utf-8')

manifest=dict(version='4.36.6',layout_revision=cfg['revision'],catalogue_revision=1,size_policy='CHARACTER_DEFAULT',distribution='Unchanged 65 unique T1 entries; index=chest+slot*39.',seed=cfg['seed'],layout=cfg,zones=zones,rooms=rooms,locks=locks,gates=gates,conduits=conduits,refuges=refuges,prisoners=prisoners,rats=rats,time_advance_zones=time_advance_zones,extraction=extraction,boss_center=boss_center,card=card,travel=travel,loot=contents,traps=features,things=things,counts=dict(rooms=len(rooms),mandingas=96,rats=len(rats),zupays=1,chests=39,equipment=len(contents),food_rations=120,water_rations=120,arrows=240,bolts=120,bullets=120,traps=len(features)),geometry=dict(sectors=len(sectors),lines=len(lines),vertices=len(vertices)),cells=[list(k)+list(v) for k,v in sorted(cells.items())])
# Keep each collision cell on one line so geometry evidence remains reviewable.
manifest_text=json.dumps({**manifest,'cells':'__COLLISION_CELLS__'},indent=2)
cell_text='[\n'+',\n'.join('    '+json.dumps(row) for row in manifest['cells'])+'\n  ]'
(OUT/'MAP02_MANIFEST.json').write_text(manifest_text.replace('"__COLLISION_CELLS__"',cell_text)+'\n',encoding='utf-8')
runtime=['// Generado desde LAYOUT.json y generate_map02_maze.py.','class CaelumMazeLayout : Object play','{','    const REVISION = 2;','    static bool IsCurrent(){return level.MapName=="MAP02" && ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next()!=null;}','    static vector3 TravelPosition(int id)','    {']
for key,pos in travel.items():runtime.append(f'        if(id=={key})return ({pos[0]},{pos[1]},0);')
runtime+=['        return (0,0,0);','    }',f'    const TIME_ADVANCE_ZONE_COUNT = {len(time_advance_zones)};','    static vector3 TimeAdvanceZonePosition(int index)','    {']
for index,zone in enumerate(time_advance_zones):
 pos=zone['position'];runtime.append(f'        if(index=={index})return ({pos[0]},{pos[1]},{pos[2]});')
runtime+=['        return (0,0,0);','    }']
for role,pos in cfg['arrival'].items():
 runtime.append(f'    static vector3 Arrival{role.title()}Position(){{return ({pos[0]},{pos[1]},{pos[2]});}}')
runtime.append('}')
(ROOT/'src/caelum/world/CaelumMazeLayout.zs').write_text('\n'.join(runtime)+'\n',encoding='utf-8')
print(manifest['counts']);print(manifest['geometry'])
