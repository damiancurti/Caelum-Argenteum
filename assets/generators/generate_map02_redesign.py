"""Build the approved #454 sewer from explicit geometry and retained content.

LAYOUT.json owns coordinates and dimensions. The immutable revision-5 manifest
owns retained content identities; this generator changes placement, not balance.
The native cell/3D-floor compiler retains the proven revision-5 implementation.
"""
from collections import deque, Counter
from pathlib import Path
import hashlib
import json
import re
import struct
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/map02_maze'
cfg=json.loads((OUT/'LAYOUT.json').read_text(encoding='utf-8'))
legacy=OUT/'legacy_5161'
old=json.loads((legacy/'MAP02_MANIFEST.json').read_text(encoding='utf-8'))
baseline=old
CELL=cfg['grid']
cells={};things=[];rooms=[];zones=[];locks={};contents=[];features=[];gates=[];refuges=[];prisoners=[];rats=[];drops=[];conduits=[]
flags=dict(skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True)


def room(x1,y1,x2,y2,floor=0,ceiling=None,group=0,tag=0,water=False):
    ceiling=cfg['ceiling'] if ceiling is None else ceiling
    assert all(v%CELL==0 for v in (x1,y1,x2,y2)), (x1,y1,x2,y2)
    for x in range(x1,x2,CELL):
        for y in range(y1,y2,CELL):cells[x,y]=(floor,ceiling,group,tag,water)


def thing(kind,x,y,z=0,angle=90,tid=0,args=()):
    value=dict(x=x,y=y,height=z,angle=angle,type=kind,**flags)
    if tid:value['id']=tid
    for i,a in enumerate(args):value['arg'+str(i)]=a
    things.append(value)
    return value


def corridor(points,group,width=None,channel=True):
    width=cfg['passage_width'] if width is None else width
    w=width//2;c=cfg['channel_width']
    for (x,y),(xx,yy) in zip(points,points[1:]):
        assert x==xx or y==yy
        room(min(x,xx)-w,min(y,yy)-w,max(x,xx)+w,max(y,yy)+w,group=group)
        # Keep the full dry shelf on one side. Junction chambers supply level
        # crossings; the existing shallow channel remains harmless.
        if channel:
            if y==yy:room(min(x,xx),y+w-c,max(x,xx),y+w,floor=-cfg['channel_depth'],group=group,water=True)
            else:room(x+w-c,min(y,yy),x+w,max(y,yy),floor=-cfg['channel_depth'],group=group,water=True)


def gate(center,axis,tag,lock,role,zone,width=None):
    x,y=center;full=cfg['service_width'] if width is None else width;w=full//2
    if axis=='x':room(x-CELL,y-w,x+CELL,y+w,ceiling=cfg['gate_height'],group=tag)
    else:room(x-w,y-CELL,x+w,y+CELL,ceiling=cfg['gate_height'],group=tag)
    gates.append(dict(center=[x,y],axis=axis,tag=tag,lock=lock,role=role,zone=zone,width=full,height=cfg['gate_height']))
    locks[tag]=lock;thing(30980,x,y,tid=tag,args=[tag,lock])


def centered(point,half,group,height=None):
    x,y=point
    room(x-half,y-half,x+half,y+half,group=group,ceiling=cfg['chamber_height'] if height is None else height)


def shifted(point,offset):return [point[0]+offset[0],point[1]+offset[1]]


room(*cfg['hub_bounds'],group=0,ceiling=cfg['chamber_height'])
room(*cfg['arrival_bounds'],group=0,ceiling=cfg['chamber_height'])
thing(1,*cfg['player_start']);thing(30981,*cfg['player_start'],tid=44800,args=[cfg['revision']])
for link in cfg['links']:
    corridor(link['points'],link['zone']+1,cfg['service_width'],False)

for z,section in enumerate(cfg['sections']):
    nodes=section['nodes'];edges=section['edges'];group=z+1
    for a,b in edges:corridor([nodes[a],nodes[b]],group)
    a,b=section['shortcut'];corridor([nodes[a],nodes[b]],group,cfg['shortcut_width'],False)
    for index,point in enumerate(nodes):
        centered(point,cfg['chamber_width']//2,group)
        rooms.append(dict(zone=z,node=index,center=point))
    anchors=[list(p) for p in section['encounter_anchors']]
    original_drops=[d for d in old['drops'] if d['zone']==z]
    # Keep each carrier TID and its exact accepted inventory identity. Swap
    # positions only, placing the existing two key carriers at authored ends.
    for field,classes in [('key_anchor',{'CaelumMazeSluiceKey','CaelumMazeCryptKey','CaelumMazeSanctumKey','CaelumMazeNorthKey'}),
                          ('cell_key_anchor',{'CaelumMazeSouthCellKey','CaelumMazeWestCellKey','CaelumMazeEastCellKey','CaelumMazeNorthCellKey'})]:
        carrier=next(d['tid'] for d in original_drops if d['cls'] in classes)
        source=anchors.index(section['encounter_anchors'][section[field]])
        target=carrier-(47000+z*24)
        anchors[source],anchors[target]=anchors[target],anchors[source]
    for point in anchors:centered(point,cfg['chamber_width']//2,group)
    zones.append(dict(zone=z,name=section['name'],key=z+1,edges=edges,
                      nodes=nodes,entry=section['entry'],main_circuits=len(edges)-len(nodes)+1,
                      shortcut=section['shortcut'],position=nodes[section['key']],
                      cell_key_position=nodes[section['cell_key']]))
    actor_positions={}
    for index,point in enumerate(anchors):
        tid=47000+z*24+index;position=shifted(point,cfg['enemy_offset'])
        thing(18037,*position,angle=270,tid=tid);actor_positions[tid]=position
        for r,offset in enumerate(cfg['rat_offsets']):
            rtid=48000+z*48+index*2+r;position=shifted(point,offset)
            thing(18029,*position,angle=90 if r==0 else 270,tid=rtid)
            rats.append(dict(zone=z,node=index,position=position));actor_positions[rtid]=position
    for drop in original_drops:drops.append({**drop,'position':actor_positions[drop['tid']]+[0]})
    zones[-1]['position']=next(d['position'][:2] for d in drops if d['zone']==z and 'Key' in d['cls'] and 'CellKey' not in d['cls'])
    zones[-1]['cell_key_position']=next(d['position'][:2] for d in drops if d['zone']==z and 'CellKey' in d['cls'])
    chest_ids=sorted({item['chest'] for item in old['loot'] if any(t.get('id')==43800+item['chest'] and
                      min(abs(t['x']-r['center'][0])+abs(t['y']-r['center'][1]) for r in old['rooms'] if r['zone']==z)<old['layout']['room_width']
                      for t in old['things'])})
    assert len(chest_ids)==old['layout']['chests_per_section'][z]
    for index,chest in enumerate(chest_ids):
        position=shifted(anchors[index],cfg['chest_offset'])
        thing(30973,*position,angle=270,args=[chest],tid=43800+chest)
        contents.extend({**item,'position':position} for item in old['loot'] if item['chest']==chest)
    for index,trap in enumerate(t for t in old['traps'] if t['zone']==z):
        x,y=anchors[index];kind=trap['type'];tid=trap['tid']
        if kind=='mine':thing(30963,x,y,z=.5,tid=tid,args=[100,128])
        elif kind=='teleport':
            position=shifted(nodes[section['entry']],[cfg['service_width']//2,0])
            thing(30965,*position,tid=tid+100);thing(30964,x,y,z=.5,tid=tid,args=[tid+100])
        elif kind=='crusher':thing(30966,x,y,z=.5,tid=tid,args=[10,8,0])
        elif kind=='rolling_rock':
            thing(30961,*shifted([x,y],cfg['rolling_rock_offset']),angle=270,tid=tid+100,args=[32])
            thing(30975,*shifted([x,y],cfg['rolling_trigger_offset']),z=.5,tid=tid,args=[tid+100])
        elif kind=='falling_rock':
            position=shifted([x,y],cfg['falling_rock_offset'])
            thing(30961,*position,z=cfg['falling_rock_height'],tid=tid+100)
            thing(30975,*position,z=.5,tid=tid,args=[tid+100])
        elif kind=='pit':
            px,py=shifted([x,y],cfg['pit_offset']);w=cfg['pit_half_size']
            room(px-w,py-w,px+w,py+w,floor=cfg['return_network']['floor'],ceiling=cfg['chamber_height'],group=tid,water=True)
            thing(30976,px,py,z=-cfg['return_network']['floor']-8,tid=tid)
        else:raise ValueError(kind)
        features.append({**trap,'position':[x,y]})
    for role in ['refuge','cell']:
        position=section[role];start=nodes[section[role+'_node']]
        corridor([start,position],group,cfg['service_width'],False)
        centered(position,cfg[role+'_half_size'],group)
        center=[(a+b)//2 for a,b in zip(start,position)]
        gate(center,'x' if start[1]==position[1] else 'y',44720+z if role=='refuge' else 44710+z,0 if role=='refuge' else 207+z,role,z)
    stations=[]
    for kind,dx,dy in cfg['refuge_station_offsets']:
        position=shifted(section['refuge'],[dx,dy]);thing(kind,*position)
        stations.append(dict(type=kind,position=position))
    refuges.append(dict(zone=z,center=section['refuge'],stations=stations,resource_allowance=old['refuges'][z]['resource_allowance']))
    prisoner={**old['prisoners'][z],'cell_center':section['cell'],
              'bed':shifted(section['cell'],cfg['cell_bed_offset']),
              'reserved_actor':shifted(section['cell'],cfg['prisoner_offset'])}
    prisoners.append(prisoner)
    thing(30987,*prisoner['bed'],tid=44810+z)
    thing(prisoner['doomednum'],*prisoner['reserved_actor'],tid=44820+z)

boss=cfg['boss'];extraction=boss['extraction'];boss_center=boss['center'];card=boss['card']
travel={int(k):v for k,v in boss['travel'].items()}
corridor(boss['approach'],4,cfg['passage_width'],False)
corridor(boss['service_link'],4,cfg['service_width'],False)
room(*boss['bounds'],ceiling=cfg['boss_height'],group=5)
room(*boss['extraction_bounds'],ceiling=cfg['chamber_height'],group=4)
thing(30981,*extraction,tid=44830,args=[20]);thing(18038,*boss_center,angle=0,tid=43799)
thing(30974,*card,z=32,tid=43798);thing(1,*boss['return_start'],args=[1])
room(*boss['drain_bounds'],floor=-cfg['channel_depth'],ceiling=cfg['boss_height'],group=5,water=True)
gate(boss['gate'],'x',44703,206,'boss',3,cfg['passage_width'])
# Stamp lock planes last so crossing geometry cannot silently erase a gate.
for link in cfg['links']:
    if 'gate' in link:gate(link['gate'],link['axis'],link['tag'],link['lock'],'section',link['zone']-1)
for z,section in enumerate(cfg['sections']):
    a,b=[section['nodes'][i] for i in section['shortcut']]
    gate([(u+v)//2 for u,v in zip(a,b)],'x' if a[1]==b[1] else 'y',44724+z,0,'maintenance',z,cfg['shortcut_width'])
    x,y=section['refuge'];pipe=cfg['conduit'];y+=cfg['refuge_half_size']-pipe['width']
    room(x-pipe['length']//2,y-pipe['width']//2,x+pipe['length']//2,y+pipe['width']//2,
         ceiling=pipe['clearance'],group=46000+z)
    conduits.append(dict(zone=z,center=[x,y],width=pipe['width'],clear_height=pipe['clearance'],texture=cfg['materials']['pipe']))
time_advance_zones=[dict(position=cfg['arrival']['bed'],role='arrival_rest'),dict(position=cfg['arrival']['workbench'],role='arrival_workshops')]
time_advance_zones += [dict(position=r['center']+[0],role='refuge',zone=r['zone']) for r in refuges]
time_advance_zones += [dict(position=p['bed']+[0],role='cell_bed',zone=p['zone']) for p in prisoners]
panel_half=cfg['crusher_panel_half_width']
for trap in features:
    if trap['type']=='crusher':
        x,y=trap['position'];room(x-panel_half,y-panel_half,x+panel_half,y+panel_half,ceiling=cfg['chamber_height'],group=trap['tid'])

# Route the lower recovery branches once during generation, never at runtime.
# A shared BFS tree gives deterministic shortest paths with fixed tie-breaking.
net=cfg['return_network'];step=old['layout']['grid'];half=net['width']//2
blocked=set();margin=cfg['return_routing']['surface_panel_clearance']
for trap in features:
    if trap['type']!='crusher':continue
    x,y=trap['position'];reach=panel_half+half+margin
    blocked.update((xx,yy) for xx in range(x-reach,x+reach+step,step) for yy in range(y-reach,y+reach+step,step))
for g in gates:
    x,y=g['center'];reach=g['width']//2+half+margin
    blocked.update((xx,yy) for xx in range(x-reach,x+reach+step,step) for yy in range(y-reach,y+reach+step,step))
pit_points={t['tid']:tuple(shifted(t['position'],cfg['pit_offset'])) for t in features if t['type']=='pit'}
target=(0,-net['ring_radius']);parents={target:None};queue=deque([target]);missing=set(pit_points.values())
limits=[min(p[i] for p in [*pit_points.values(),target])-cfg['return_routing']['search_margin'] for i in range(2)]+[max(p[i] for p in [*pit_points.values(),target])+cfg['return_routing']['search_margin'] for i in range(2)]
while queue and missing:
    point=queue.popleft();missing.discard(point)
    for dx,dy in ((0,step),(-step,0),(step,0),(0,-step)):
        next_point=(point[0]+dx,point[1]+dy)
        if limits[0]<=next_point[0]<=limits[2] and limits[1]<=next_point[1]<=limits[3] and next_point not in blocked and next_point not in parents:
            parents[next_point]=point;queue.append(next_point)
assert not missing, f'No recovery route for {missing}'
net['paths']=[]
for tid,start in sorted(pit_points.items()):
    points=[start]
    while parents[points[-1]] is not None:points.append(parents[points[-1]])
    compressed=[points[0]]
    for i in range(1,len(points)-1):
        if (points[i][0]-points[i-1][0],points[i][1]-points[i-1][1])!=(points[i+1][0]-points[i][0],points[i+1][1]-points[i][1]):compressed.append(points[i])
    compressed.append(points[-1]);net['paths'].append(dict(trap=tid,points=compressed))

# The following compiler is carried from revision 5, with chamber-height support.
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
# Moving sectors must retain exactly their authored footprint and base floor.
for trap in features:
 if trap['type']!='crusher':continue
 x,y=trap['position'];footprint={(px,py) for px in range(x-panel_half,x+panel_half,CELL) for py in range(y-panel_half,y+panel_half,CELL)}
 actual={p for p,v in cells.items() if v[2]==trap['tid']}
 assert actual==footprint, f"Crusher {trap['tid']} lost its isolated footprint"
 assert all(cells[p]==(0,cfg['chamber_height'],trap['tid'],0,False) for p in footprint), f"Crusher {trap['tid']} overlaps a lower passage"
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
text=[f'namespace = "ZDoom";\n// MAP02 revision {cfg["revision"]}; generated from LAYOUT.json.\n']
for kind,entries in [('vertex',vertices),('sector',sectors),('sidedef',sides),('linedef',lines),('thing',things)]:
 for entry in entries:text.append(kind+'\n{\n'+''.join(f'    {k} = {value(v)};\n' for k,v in entry.items())+'}\n')
body=bytearray();directory=bytearray()
for name,data in [('MAP02',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]:
 directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode().ljust(8,b'\0'));body+=data
(ROOT/'assets/map02_maze/BASE_MAP02.wad').write_bytes(struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory)

manifest={**baseline, 'version':'5.16.2', 'layout_revision':cfg['revision'], 'layout':cfg,
 'return_grates':return_grates,'lower_cells':lower_cells,
 'upper_cells':[list(k)+list(v) for k,v in sorted(upper_cells.items())],
 'zones':zones,'rooms':rooms,'locks':locks,'gates':gates,'conduits':conduits,
 'refuges':refuges,'prisoners':prisoners,'rats':rats,'drops':drops,
 'time_advance_zones':time_advance_zones,'extraction':extraction,'boss_center':boss_center,
 'card':card,'travel':travel,'loot':contents,'traps':features,'things':things,
 'geometry':dict(sectors=len(sectors),lines=len(lines),vertices=len(vertices)),
 'cells':[list(k)+list(v) for k,v in sorted(cells.items())]}
manifest['counts']={**baseline['counts'],'rooms':len(rooms)}
manifest_text=json.dumps({**manifest,**{k:'__'+k.upper()+'__' for k in ('cells','upper_cells','lower_cells')}},indent=2)
for key in ('cells','upper_cells','lower_cells'):
    cell_text='[\n'+',\n'.join('    '+json.dumps(row) for row in manifest[key])+'\n  ]'
    manifest_text=manifest_text.replace('"__'+key.upper()+'__"',cell_text)
(OUT/'MAP02_MANIFEST.json').write_text(manifest_text+'\n',encoding='utf-8',newline='\n')
runtime=['// Generado desde LAYOUT.json y generate_map02_maze.py.','class CaelumMazeLayout6 : Object play','{',f'    const REVISION = {cfg["revision"]};','    static bool IsCurrent(){return level.MapName=="MAP02" && ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next()!=null;}','    static vector3 TravelPosition(int id)','    {']
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
# Predefined loot exists only for actual assignments, not every mapped enemy.
# Compress adjacent carrier IDs without introducing a second assignment table.
drop_ranges=[]
for carrier_tid in sorted({d['tid'] for d in drops}):
 if drop_ranges and carrier_tid==drop_ranges[-1][1]+1:drop_ranges[-1][1]=carrier_tid
 else:drop_ranges.append([carrier_tid,carrier_tid])
drop_conditions=[f'tid=={lo}' if lo==hi else f'(tid>={lo} && tid<={hi})' for lo,hi in drop_ranges]
runtime += ['    static bool HasDeathDrop(int tid)',
 '    {return '+' || '.join(drop_conditions)+';}']
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
runtime.insert(-1,'    static vector3 BossEscapePosition(){return ('+','.join(str(v) for v in cfg['boss']['escape'])+');}')

# Dispatch only coordinate-sensitive methods for the new map marker. Existing
# saves keep the original class and exact revision-5 coordinates/drop carriers.
compat=(legacy/'CaelumMazeLayout.zs').read_text(encoding='utf-8')
compat=compat.replace('const REVISION = 5;','const REVISION = 6;')
compat=compat.replace('    static bool IsCurrent()', '    static bool IsRedesigned(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]==6;}\n    static bool IsCurrent()',1)
for name,argument in [('TravelPosition','id'),('TimeAdvanceZonePosition','index'),
                      ('ArrivalChairPosition',''),('ArrivalBedPosition',''),('ArrivalWorkbenchPosition',''),
                      ('CreateDeathDrop','tid'),('HasDeathDrop','tid')]:
    pattern=r'(static (?:vector3|Inventory|bool) '+name+r'\([^)]*\)\s*\{)'
    compat,count=re.subn(pattern,lambda m:m.group(1)+'\n        if(IsRedesigned())return CaelumMazeLayout6.'+name+'('+argument+');',compat,count=1)
    assert count==1,name
output=compat+'\n'+'\n'.join(runtime)+'\n'
(ROOT/'src/caelum/world/CaelumMazeLayout.zs').write_text(output,encoding='utf-8',newline='\n')

# Register a separately owned current source; never rewrite the immutable
# Justice baseline archive used to restore older campaigns.
path=ROOT/'assets/tarot_justice/MAPS.json'
data=json.loads(path.read_text(encoding='utf-8'))
row=next(row for row in data['maps'] if row['file']=='MAP02.wad')
row['source_override']='assets/map02_maze/BASE_MAP02.wad'
row['source_sha256']=hashlib.sha256((OUT/'BASE_MAP02.wad').read_bytes()).hexdigest()
if 'compatibility_geometry' not in row:
    row['compatibility_geometry']={'checksum':'860e3e47c2b89449073b0d27f0b4940b',**row['geometry']}
path.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
subprocess.run([sys.executable,str(ROOT/'assets/generators/generate_tarot_justice.py')],check=True,cwd=ROOT)
subprocess.run([sys.executable,str(ROOT/'assets/generators/generate_cartography_catalogue.py')],check=True,cwd=ROOT)
print(json.dumps({'revision':cfg['revision'],'main_circuits':sum(z['main_circuits'] for z in zones),
                  'shortcuts':4,'counts':manifest['counts'],'geometry':manifest['geometry']}))
