#!/usr/bin/env python3
"""Generate the cardinal sewer, flooded return and finite supply assignments.
Authored layout data is in assets/map02_maze/LAYOUT.json. No other map is written.
"""
from pathlib import Path
from collections import deque, Counter
import random, struct, json, hashlib
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/map02_maze';OUT.mkdir(exist_ok=True)
cfg=json.loads((OUT/'LAYOUT.json').read_text(encoding='utf-8'))
CELL=cfg['grid'];rng=random.Random(cfg['seed'])
cells={};things=[];rooms=[];zones=[];locks={};contents=[];features=[];gates=[];refuges=[];prisoners=[];rats=[];drops=[]
prisoner_types=[(30988,'CaelumPrisonerUnitario'),(30989,'CaelumPrisonerFederal'),(30990,'CaelumPrisonerBestia'),(30991,'CaelumPrisonerTarot')]
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
def coord(z,n):return (cfg['section_origins'][z][0]+n[0]*cfg['node_spacing'],cfg['section_origins'][z][1]+n[1]*cfg['node_spacing'])
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
room(*cfg['hub_bounds'],group=0)
thing(1,*cfg['player_start']);thing(30981,-576,0,tid=44800,args=[cfg['revision']])
for z in range(4):
 entry=coord(z,cfg['entry_nodes'][z])
 corridor(tuple(cfg['player_start']),entry,z+1,False)
 if z>0:gate(tuple(cfg['entrance_gates'][z]),'x' if z in (1,2) else 'y',44699+z,202+z,'section',z-1)
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
 start=tuple(cfg['entry_nodes'][z]);end=(4,4);stack=[start];seen={start}
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

 cx,cy=coord(z,cellnode)
 zones.append(dict(zone=z,name=cfg['section_names'][z],key=z+1,node=list(keynode),position=[kx+192,ky-192],cell_key_position=[cx+192,cy-192],distance=dist[keynode],edges=[[list(a),list(b)] for a in nodes for b in sorted(graph[a]) if a<b]))
 candidates=[n for n in nodes if n not in [start,end]];rng.shuffle(candidates)
 for n in candidates[:cfg['chests_per_section'][z]]:
  x,y=coord(z,n);index=chest_index;chest_index+=1
  thing(30973,x-192,y+192,angle=270,args=[index],tid=43800+index)
  for ci in range(index,len(loot),39):
   item=dict(loot[ci]);item.update(catalogue_index=ci,chest=index,chest_slot=ci//39,position=[x-192,y+192]);contents.append(item)
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
   room(x-128,y-96,x,y+32,floor=cfg['return_network']['floor'],group=tid,water=True)
   thing(30976,x-64,y-32,z=-cfg['return_network']['floor']-8,tid=tid)
  features.append(dict(zone=z,type=kind,position=[x,y],tid=tid))
 enemy_nodes=[n for n in nodes if n!=start]
 ammo=[]
 for key,cls in [('arrow','CaelumArrowAmmo'),('bolt','CaelumBoltAmmo'),('bullet','CaelumCarbineAmmo'),('shotgun','CaelumShotgunAmmo')]:
  ammo += [(cls,cfg['ammunition_bundle_units'])]*cfg[key+'_bundles_per_section'][z]
 progression=['CaelumMazeSluiceKey','CaelumMazeCryptKey','CaelumMazeSanctumKey','CaelumMazeNorthKey']
 cellkeys=['CaelumMazeSouthCellKey','CaelumMazeWestCellKey','CaelumMazeEastCellKey','CaelumMazeNorthCellKey']
 for ni,n in enumerate(enemy_nodes):
  x,y=coord(z,n);tid=47000+z*24+ni
  thing(18037,x+192,y-192,angle=270,tid=tid)
  drop=(progression[z],1) if n==keynode else (cellkeys[z],1) if n==cellnode else ammo.pop(0) if ammo else None
  if drop:drops.append(dict(tid=tid,zone=z,actor='CaelumMandinga',cls=drop[0],amount=drop[1],position=[x+192,y-192,0]))
  for ri,(dx,dy,cls) in enumerate([(-192,-64,'CaelumFoodRation'),(192,64,'CaelumWaterRation')]):
   rtid=48000+z*48+ni*2+ri
   thing(18029,x+dx,y+dy,angle=90 if ri==0 else 270,tid=rtid)
   rats.append(dict(zone=z,node=list(n),position=[x+dx,y+dy]))
   drops.append(dict(tid=rtid,zone=z,actor='CaelumGiantRat',cls=cls,amount=1,position=[x+dx,y+dy,0]))
 assert not ammo
 # A protected service alcove per section. Existing repair rules/stations only.
 sx,sy=coord(z,(0,0));rx=sx-1024
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
 thing(prisoner_types[z][0],cellx+96,ey+96,tid=44820+z,args=[0])
 prisoners.append(dict(zone=z,cell_center=[cellx,ey],bed=[cellx-96,ey-160],reserved_actor=[cellx+96,ey+96],lock=207+z,actor=prisoner_types[z][1],doomednum=prisoner_types[z][0]))
 if z==3:
  bridgey=ey+768
  corridor((ex,ey),(ex,bridgey),z+1,False)
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
# Lower passages are overlaid on the original upper geometry. Solid native
# 3D floors preserve upper routes; only the six trap apertures connect levels.
upper_cells=dict(cells);lower=set();return_grates=[];floor_controls={}
net=cfg['return_network'];lf=net['floor'];lc=net['ceiling'];half=net['width']//2
def lower_rect(x1,y1,x2,y2):
 assert all(v%CELL==0 for v in (x1,y1,x2,y2))
 lower.update((x,y) for x in range(x1,x2,CELL) for y in range(y1,y2,CELL))
def lower_path(points):
 for (x,y),(xx,yy) in zip(points,points[1:]):
  assert x==xx or y==yy
  lower_rect(min(x,xx)-half,min(y,yy)-half,max(x,xx)+half,max(y,yy)+half)
for path in net['paths']:lower_path(path['points'])
r=net['ring_radius'];lower_path([[-r,-r],[r,-r],[r,r],[-r,r],[-r,-r]])
for endpoint in [(0,-r),(-r,0),(r,0),(0,r)]:lower_path([(0,0),endpoint])
ex1,ey1,ex2,ey2=cfg['elevator_reservation'];thick=net['grate_thickness'];gw=net['grate_width']//2
lower_rect(ex1-thick,ey1-thick,ex2+thick,ey2+thick)
for index,(side,axis,sign) in enumerate([('south','y',-1),('west','x',-1),('east','x',1),('north','y',1)]):
 boundary=(ex2 if axis=='x' else ey2)*sign
 return_grates.append(dict(side=side,axis=axis,sign=sign,boundary=boundary,
  outer_boundary=boundary+sign*thick,width=net['grate_width'],tag=net['grate_tags'][index],
  activation_side='tunnel exterior only',key=None,independent=True))
 thing(30992,0 if axis=='y' else boundary+sign*thick,0 if axis=='x' else boundary+sign*thick,tid=net['grate_tags'][index],args=[net['grate_tags'][index],index])
def lower_kind(x,y):
 if ex1<=x<ex2 and ey1<=y<ey2:return ('lift',net['elevator_tag'])
 if ex1-thick<=x<ex2+thick and ey1-thick<=y<ey2+thick:
  for g in return_grates:
   along=y if g['axis']=='x' else x;cross=x if g['axis']=='x' else y
   a,b=sorted((g['boundary'],g['outer_boundary']))
   if -gw<=along<gw and a<=cross<b:return ('grate',g['tag'])
  return ('wall',0)
 return ('tunnel',0)
composites={};lower_cells=[]
for x,y in sorted(lower):
 old=upper_cells.get((x,y));kind,gid=lower_kind(x,y)
 if kind=='lift':
  cells[x,y]=(0,cfg['ceiling'],net['elevator_tag'],net['elevator_tag'],False)
  lower_cells.append([x,y,kind,net['elevator_tag']]);continue
 floor,ceil,group,_,water=old if old else (None,lc,0,0,False)
 slab=kind in ('wall','grate') or (old is not None and floor!=lf)
 bottom=lf if kind in ('wall','grate') else lc
 top=floor if old else 0
 signature=(ceil,group,slab,bottom,top,gid,kind=='tunnel')
 if signature not in composites:
  tag=45000+len(composites);composites[signature]=tag
  floor_controls[tag]=dict(slab=slab,bottom=bottom,top=top,grate=gid,water=kind=='tunnel',top_texture='CAPOOL01' if water else 'CASWRFLR')
 tag=composites[signature]
 cells[x,y]=(lf,ceil,group,tag,kind=='tunnel')
 lower_cells.append([x,y,kind,tag])
# Native map-thing heights are relative to the base floor, including above a
# 3D slab. Keep each upper actor at precisely its former authored world height.
for t in things:
 point=(int(t['x']//CELL)*CELL,int(t['y']//CELL)*CELL)
 old=upper_cells.get(point);new=cells.get(point)
 if old and new and t['type']!=30992:t['height']+=old[0]-new[0]
thing(30993,0,0,tid=net['elevator_tag'])
# Stable sector/line ordering and explicit gate segments preserve reproducibility.
sectors=[];sector_ids={};vertices=[];vertex_ids={};sides=[];lines=[];edges={}
def sector(v):
 if v not in sector_ids:
  floor,ceil,group,tag,water=v;sector_ids[v]=len(sectors)
  tint=int(cfg['section_tints'][group-1],16) if 1<=group<=4 else 0xC8C4B0
  sectors.append(dict(heightfloor=floor,heightceiling=ceil,texturefloor='CASWRPIP' if tag==net['elevator_tag'] else 'CAPOOL01' if water else 'CASWRFLR',textureceiling='CASWRPIP' if group>=46000 else 'CASWRWAL',lightlevel=176 if group==5 else 160,lightcolor=tint,id=tag))
 return sector_ids[v]
def vertex(v):
 if v not in vertex_ids:vertex_ids[v]=len(vertices);vertices.append(dict(x=v[0],y=v[1]))
 return vertex_ids[v]
for (x,y),v in sorted(cells.items()):
 idx=sector(v);corners=[(x,y),(x,y+CELL),(x+CELL,y+CELL),(x+CELL,y)];near=[(x-CELL,y),(x,y+CELL),(x+CELL,y),(x,y-CELL)]
 for j,(a,b) in enumerate(zip(corners,corners[1:]+corners[:1])):
  barrier=None
  return_barrier=None
  for g in return_grates:
   if g['axis']=='x' and a[0]==b[0] and a[0] in (g['boundary'],g['outer_boundary']) and min(a[1],b[1])>=-gw and max(a[1],b[1])<=gw:return_barrier=g;break
   if g['axis']=='y' and a[1]==b[1] and a[1] in (g['boundary'],g['outer_boundary']) and min(a[0],b[0])>=-gw and max(a[0],b[0])<=gw:return_barrier=g;break
  for g in gates:
   gx,gy=g['center'];w=g['width']//2
   if g['axis']=='x' and a[0]==b[0]==gx and min(a[1],b[1])>=gy-w and max(a[1],b[1])<=gy+w:barrier=g;break
   if g['axis']=='y' and a[1]==b[1]==gy and min(a[0],b[0])>=gx-w and max(a[0],b[0])<=gx+w:barrier=g;break
  if cells.get(near[j])==v and barrier is None and return_barrier is None:continue
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
  elif return_barrier:
   l.update(id=return_barrier['tag'],special=13,arg0=return_barrier['tag'],playeruse=True,playeruseback=True,repeatspecial=True)

# Each control polygon is isolated well outside all play space. Water uses the
# existing native swimmable volume, with no damage/current special.
control_index=0
def control(tag,bottom,top,water=False,gate_tag=0,top_texture='CASWRFLR'):
 global control_index
 x=net['control_origin'][0]+control_index*64;y=net['control_origin'][1];control_index+=1
 idx=len(sectors)
 sectors.append(dict(heightfloor=bottom,heightceiling=top,texturefloor='CAPOOL01' if water else 'CASWRWAL',textureceiling='CAPOOL01' if water else top_texture,lightlevel=160,id=gate_tag))
 points=[(x,y),(x,y+32),(x+32,y+32),(x+32,y)]
 for j,(a,b) in enumerate(zip(points,points[1:]+points[:1])):
  side=len(sides);sides.append(dict(sector=idx,texturetop='CASWRWAL',texturebottom='CASWRWAL',texturemiddle='CMGT02' if gate_tag else 'CAPOOL01' if water else 'CASWRWAL'))
  l=dict(v1=vertex(a),v2=vertex(b),sidefront=side,blocking=True)
  if j==0:l.update(special=160,arg0=tag,arg1=2 if water else 1,arg2=0,arg3=160 if water else 255)
  lines.append(l)
for tag,c in floor_controls.items():
 if c['slab']:control(tag,c['bottom'],c['top'],gate_tag=c['grate'],top_texture=c['top_texture'])
 if c['water']:control(tag,lf,lf+net['water_depth'],water=True)
def value(v):return str(v).lower() if isinstance(v,bool) else json.dumps(v) if isinstance(v,str) else str(v)
text=['namespace = "ZDoom";\n// MAP02 revision 4, 4.37.7; generated from LAYOUT.json.\n']
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
zs += ['    static CaelumMazeMaterialBudget MaterialBudget(int chest,int size)', '    {', '        let budget=new("CaelumMazeMaterialBudget");budget.Valid=true;budget.Efficiency=2;', '        for(int slot=0;slot<2;slot++)AddMaterialEntry(budget,ChestEntry(chest,slot),size);', '        return budget;', '    }', '    static void AddMaterialEntry(CaelumMazeMaterialBudget budget,int index,int size)', '    {', '        switch(index)', '        {']
for i,item in enumerate(loot):
 cat=item['category'];typ=item['type']
 if cat=='armor':call=f'budget.AddArmor({typ},size,{item["slot"]});'
 elif cat=='weapon':
  call=f'budget.AddCatalogueWeapon({typ},{item["essence"]},size);'
 elif cat=='shield':call=f'budget.AddShield({typ},size);'
 elif cat=='amulet':call=f'budget.AddAmulet({typ});'
 else:call=f'budget.AddSeal({typ});'
 zs.append(f'        case {i}: {call} break;')
zs += ['        }','    }']
zs.append('}\n');(ROOT/'src/caelum/world/CaelumMazeLootCatalogue.zs').write_text('\n'.join(zs),encoding='utf-8')

manifest=dict(version='4.37.7',layout_revision=cfg['revision'],catalogue_revision=1,size_policy='CHARACTER_DEFAULT',distribution='65 original T1 instances converted to basic recipe inputs; index=chest+slot*39. First successful withdrawal fixes shared recipient-size material budget.',seed=cfg['seed'],layout=cfg,return_grates=return_grates,lower_cells=lower_cells,upper_cells=[list(k)+list(v) for k,v in sorted(upper_cells.items())],zones=zones,rooms=rooms,locks=locks,gates=gates,conduits=conduits,refuges=refuges,prisoners=prisoners,rats=rats,drops=drops,time_advance_zones=time_advance_zones,extraction=extraction,boss_center=boss_center,card=card,travel=travel,loot=contents,traps=features,things=things,counts=dict(rooms=len(rooms),mandingas=96,rats=len(rats),zupays=1,chests=39,equipment=0,converted_equipment=len(contents),food_rations=96,water_rations=96,arrows=240,bolts=120,bullets=120,shotgun_cartridges=sum(cfg['shotgun_bundles_per_section'])*cfg['ammunition_bundle_units'],traps=len(features)),geometry=dict(sectors=len(sectors),lines=len(lines),vertices=len(vertices)),cells=[list(k)+list(v) for k,v in sorted(cells.items())])
# Keep each collision cell on one line so geometry evidence remains reviewable.
manifest_text=json.dumps({**manifest,**{k:'__'+k.upper()+'__' for k in ('cells','upper_cells','lower_cells')}},indent=2)
for key in ('cells','upper_cells','lower_cells'):
 cell_text='[\n'+',\n'.join('    '+json.dumps(row) for row in manifest[key])+'\n  ]'
 manifest_text=manifest_text.replace('"__'+key.upper()+'__"',cell_text)
(OUT/'MAP02_MANIFEST.json').write_text(manifest_text+'\n',encoding='utf-8')
runtime=['// Generado desde LAYOUT.json y generate_map02_maze.py.','class CaelumMazeLayout : Object play','{','    const REVISION = 4;','    static bool IsCurrent(){return level.MapName=="MAP02" && ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next()!=null;}','    static vector3 TravelPosition(int id)','    {']
for key,pos in travel.items():runtime.append(f'        if(id=={key})return ({pos[0]},{pos[1]},0);')
runtime+=['        return (0,0,0);','    }',f'    const TIME_ADVANCE_ZONE_COUNT = {len(time_advance_zones)};','    static vector3 TimeAdvanceZonePosition(int index)','    {']
for index,zone in enumerate(time_advance_zones):
 pos=zone['position'];runtime.append(f'        if(index=={index})return ({pos[0]},{pos[1]},{pos[2]});')
runtime+=['        return (0,0,0);','    }']
for role,pos in cfg['arrival'].items():
 runtime.append(f'    static vector3 Arrival{role.title()}Position(){{return ({pos[0]},{pos[1]},{pos[2]});}}')
runtime += ['    static bool IsCardinal(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]>=3;}',
 '    static Inventory CreateDeathDrop(int tid)', '    {']
for z in range(4):
 runtime.append(f'        if((tid>={47000+z*24} && tid<{47000+(z+1)*24}) || (tid>={48000+z*48} && tid<{48000+(z+1)*48}))return CreateDeathDrop{z}(tid);')
runtime += ['        return null;','    }']
runtime += ['    static bool HasDeathDrop(int tid)',
 '    {return (tid>=47000 && tid<47096) || (tid>=48000 && tid<48192);}']
for z in range(4):
 runtime += [f'    static Inventory CreateDeathDrop{z}(int tid)', '    {', '        Inventory item;']
 for d in drops:
  if d['zone']!=z:continue
  runtime.append(f'        if(tid=={d["tid"]}){{item=Inventory(Actor.Spawn("{d["cls"]}",({d["position"][0]},{d["position"][1]},0),NO_REPLACE));if(item!=null)item.Amount={d["amount"]};return item;}}')
 runtime += ['        return null;','    }']
runtime += [
 f"    const RETURN_FLOOR = {lf};",f"    const RETURN_CEILING = {lc};",
 f"    const RETURN_SPEED = {net['elevator_speed']};",f"    const RETURN_ELEVATOR_TAG = {net['elevator_tag']};",
 '    static bool IsFloodedReturn(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]>=4;}',
 '    static bool IsReturnGrate(int tag){return '+ ' || '.join(f'tag=={g["tag"]}' for g in return_grates)+';}',
 f'    static bool IsInsideElevator(vector2 p){{return p.X>{ex1} && p.X<{ex2} && p.Y>{ey1} && p.Y<{ey2};}}',
 '    static bool IsGrateExterior(int index,vector2 p)','    {']
for index,g in enumerate(return_grates):
 axis='X' if g['axis']=='x' else 'Y';op='>=' if g['sign']>0 else '<='
 runtime.append(f"        if(index=={index})return p.{axis}{op}{g['outer_boundary']};")
runtime += ['        return false;','    }']
runtime += ['    static int PitEntrance(int trap)','    {']
for trap in features:
 if trap['type']=='pit' and trap['zone']>0:
  runtime.append(f"        if(trap=={trap['tid']})return {44699+trap['zone']};")
runtime += ['        return 0;','    }']
runtime.append('}')
(ROOT/'src/caelum/world/CaelumMazeLayout.zs').write_text('\n'.join(runtime)+'\n',encoding='utf-8')
print(manifest['counts']);print(manifest['geometry'])
