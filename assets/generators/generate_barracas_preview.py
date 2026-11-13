"""Compile an isolated #454 architectural preview; never replace production maps.

The approved reference traces and placements live in barracas_redesign/LAYOUT.
Existing city profiles provide dimensions/materials. This preview has no siege,
quest, service migration or save-compatibility acceptance claim.
"""
from pathlib import Path
from collections import deque
import argparse,json,math,zipfile
from generate_coastal_trials import CoastalMap
from compact_open_geometry import compact_open_geometry

ROOT=Path(__file__).resolve().parents[2]

def inside(p,vertices):
    x,y=p;result=False
    for (a,b),(c,d) in zip(vertices,vertices[1:]+vertices[:1]):
        if (b>y)!=(d>y) and x<(c-a)*(y-b)/(d-b)+a:result=not result
    return result

def distance2(p,a,b):
    vx,vy=b[0]-a[0],b[1]-a[1];length=vx*vx+vy*vy
    t=max(0,min(1,((p[0]-a[0])*vx+(p[1]-a[1])*vy)/length)) if length else 0
    return (p[0]-a[0]-t*vx)**2+(p[1]-a[1]-t*vy)**2

def local_point(building,x,y):
    a,b,c,d=building['bounds'];angle=building['angle']
    if angle==0:return a+x,b+y
    if angle==90:return c-y,b+x
    if angle==180:return c-x,d-y
    return a+y,d-x

class Placement:
    def __init__(self,port,building):self.port=port;self.building=building
    def room(self,a,b,c,d,**kwargs):
        points=[local_point(self.building,x,y) for x,y in [(a,b),(a,d),(c,b),(c,d)]]
        self.port.room(min(p[0] for p in points),min(p[1] for p in points),
                       max(p[0] for p in points),max(p[1] for p in points),**kwargs)

def generate(out,map_name=None,configure=None):
    """Reuse the approved shell; a candidate caller can add existing services."""
    out=Path(out).resolve()
    if not out.is_relative_to(ROOT/'build'):raise ValueError('The isolated preview must be written under build/.')
    out.mkdir(parents=True,exist_ok=True)
    data=json.loads((ROOT/'assets/barracas_redesign/LAYOUT.json').read_text())
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text())
    interior=json.loads((ROOT/'assets/map06_port/INTERIORS.json').read_text())
    port=CoastalMap(map_name or data['preview_map']);port.compact=True;port.optimize_open_geometry=True;port.add_default_things=False
    port.control_origin=city['control_origin'];port.control_columns=city['control_columns']
    x1,y1,x2,y2=data['bounds'];cell=data['grid'];belt=city['walk_width']
    river=data['river'];port.volume(100,river['floor'],river['surface'],'CVPL06','CVPL06',water=True)
    port.room(x1-belt*2,y1-belt*2,x2+belt*4,river['north_y'],flat='CMGR03',wall='CMST01')
    port.room(x1-belt*2,river['south_y'],x2+belt*4,river['north_y'],floor=river['floor'],flat='CVPL02',volume=100)
    for x in range(x1,x2,cell):
        for y in range(y1,y2,cell):
            if inside((x+cell/2,y+cell/2),data['perimeter']):port.room(x,y,x+cell,y+cell,flat='CMST02')
    for plaza in data['plazas']:
        vertices=plaza['polygon']
        for x in range(min(p[0] for p in vertices),max(p[0] for p in vertices),cell):
            for y in range(min(p[1] for p in vertices),max(p[1] for p in vertices),cell):
                if inside((x+cell/2,y+cell/2),vertices):port.room(x,y,x+cell,y+cell,flat='CMGR02')
    detail=city['detail'];facades={};bindings=[];classes=[];editors=[]
    native_doors=json.loads((ROOT/'assets/map06_port/NATIVE_DOORS.json').read_text())
    import generate_barracas_facades
    for building in data['buildings']:
        kind=building['kind'];profile=city['profiles'][kind];tag=building['tag'];wall=building['wall'];flat=building['floor']
        place=Placement(port,building)
        width,height=interior['house_size'] if kind=='house' else profile['size']
        if building.get('civic'):
            a,b,c,d=building['bounds'];width,height=c-a,d-b
        if kind=='construction':
            level=detail['site_wall_heights'][building['stage']]
            place.room(0,0,width,height,floor=detail['foundation_height'],flat=flat,wall=wall)
            for rect in [(0,0,cell,height),(0,0,width,cell),(0,height-cell,width,height),(width-cell,0,width,height)]:
                place.room(*rect,floor=level,flat=flat,wall=wall)
            place.room(width-cell,cell,width,cell+profile['door_width'],floor=detail['foundation_height'],flat=flat,wall=wall)
            continue
        if kind=='house':
            # Keep each original private interior unchanged. The shell is a
            # real opaque city building; its future portal remains identity-bound.
            place.room(0,0,width,height,floor=interior['height'],flat=interior['roof'],wall=wall)
            profile={**profile,'height':interior['height'],'headroom':interior['headroom'],'door_height':120}
            door_y=(interior['entrance'][1]+interior['entrance'][3])/2
            key=f'house-{width}-{height}'
            if key not in facades:
                editor=31800+len(facades);name='CA454Facade'+str(editor);model=key+'.obj'
                facades[key]=dict(editor=editor,model=model,**generate_barracas_facades.build(out/'models'/model,width,height,profile,detail,native_doors['half_thickness'],door_y))
                classes.append(f'class {name} : Actor {{ Default {{ +NOINTERACTION +NOGRAVITY }} States {{ Spawn: CDLS A -1; Stop; }} }}')
                bindings.append(f'Model {name} {{ Path "models" Model 0 "{model}" Scale 1 1 1 CorrectPixelStretch DontCullBackFaces FrameIndex CDLS A 0 0 }}')
                editors.append(f'{editor}={name}')
            a,b,c,f=building['bounds'];port.prop(facades[key]['editor'],(a+c)/2,(b+f)/2,angle=building['angle'])
            # UDMF thing height is relative to the opaque shell's roof floor.
            port.things[-1]['height']=-interior['height']
            continue
        port.volume(tag,profile['headroom'],profile['height'],profile['roof'],'CVCI04')
        place.room(0,0,width,height,floor=profile['height'],flat=profile['roof'],wall=wall)
        place.room(cell,cell,width-cell,height-cell,flat=flat,wall=wall,light=168,volume=tag)
        door_y=(height//(cell*2))*cell-profile['door_width']//2
        place.room(width-cell,door_y,width,door_y+profile['door_width'],flat=flat,wall=wall,volume=tag)
        if building.get('civic'):
            # An open internal courtyard and connected office/archive wings.
            place.room(width//4//cell*cell,height//4//cell*cell,width*3//4//cell*cell,height*3//4//cell*cell,flat='CMGR02',wall=wall)
        elif kind=='factory':
            place.room(cell*2,cell*2,cell*2+detail['chimney_size'],cell*2+detail['chimney_size'],floor=detail['chimney_height'],flat='CMST04',wall='CASWRWAL')
        else:
            place.room(cell*2,cell*2,cell*4,height-cell*2,floor=detail['counter_height'],flat='CVPO01',wall=wall,volume=tag)
    # A native raised perimeter walk retains open ground underneath. No extra
    # breaches are added for the northeastern docks: their approach is outside.
    vertices=data['perimeter'];edges=list(zip(vertices,vertices[1:]+vertices[:1]))
    walk=230;port.volume(walk,city['walk_height']-city['walk_slab'],city['walk_height'],'CMST01','CMST01')
    for (x,y),value in list(port.cells.items()):
        centre=(x+cell/2,y+cell/2)
        if not (x1-cell<=x<=x2+cell and y1-cell<=y<=y2+cell):continue
        distance=min(distance2(centre,a,b) for a,b in edges)
        if distance<=(city['wall_thickness']/2)**2:
            port.room(x,y,x+cell,y+cell,floor=city['wall_height'],flat='CMST01',wall='CMST01')
        elif distance<belt*belt and inside(centre,vertices):
            floor,flat,wall,light,old=value
            if old==0 and floor==0:port.room(x,y,x+cell,y+cell,flat=flat,wall=wall,light=light,volume=walk)
    for i,gate in enumerate(data['gates']):
        x,y,_=gate['position'];width=city['gate_headroom']//cell*cell*2
        # Cover the oblique raster wall band using the existing 256-MU gate roof
        # depth; the native blocker is deliberately absent from this art probe.
        a,b=(width//2,belt) if gate['outward_angle'] in (90,270) else (belt,width//2)
        tag=220+i;port.volume(tag,city['gate_headroom'],city['gate_headroom']+city['gate_roof_thickness'],'CMST01','CMST01')
        port.room(x-a,y-b,x+a,y+b,flat='CMST01',wall='CMST01',volume=tag)
    bridge=data['bridge'];x=bridge['centre_x'];width=bridge['width']//2
    port.room(x-width,bridge['south_y']-belt,x+width,bridge['north_y'],flat='CVPO01',wall='CVPO06')
    # Existing water texture and floor levels, with dry native wooden dock piers.
    for old_y,old_end in [(448,2048),(1536,1792)]:
        ox,oy=data['port_transform']['offset'];a=ox-old_y-256;c=ox-old_y
        port.room(a,oy+896,c,oy+old_end,flat='CVPO01',wall='CVPO06')
    start=data['plazas'][0]['polygon'];centre=[sum(p[i] for p in start)/len(start) for i in (0,1)]
    port.prop(1,*centre,angle=180);port.prop(30950,*centre,args=(1,0))
    if configure is not None:configure(port,data,city,interior)
    port.write(out)
    body=json.loads((ROOT/'assets/map02_maze/LAYOUT.json').read_text())
    max_height=body['largest_supported_height'];max_radius=body['largest_player_radius']
    assert max_radius<cell/2
    walkable={p for p,v in port.cells.items() if 0<=v[0]<=detail['foundation_height'] and
              (not v[4] or port.volumes[v[4]][0]-v[0]>=max_height)}
    def key(p):return int(p[0]//cell)*cell,int(p[1]//cell)*cell
    reachable={key(centre)};queue=deque(reachable)
    while queue:
        x,y=queue.popleft()
        for nxt in [(x-cell,y),(x+cell,y),(x,y-cell),(x,y+cell)]:
            if nxt in walkable and nxt not in reachable:reachable.add(nxt);queue.append(nxt)
    targets=[]
    for building in data['buildings']:
        profile=city['profiles'][building['kind']]
        width,height=interior['house_size'] if building['kind']=='house' else profile['size']
        door_y=(interior['entrance'][1]+interior['entrance'][3])/2 if building['kind']=='house' else (height//(cell*2))*cell
        if building.get('civic'):
            a,b,c,f=building['bounds'];width,height=c-a,f-b;door_y=(height//(cell*2))*cell
        if building['kind']=='construction':door_y=cell+profile['door_width']/2
        offset=interior['door_outside'][0]-interior['house_size'][0]
        target=local_point(building,width+offset,door_y)
        targets.append({'id':building['id'],'kind':building['kind'],'point':target,'reachable':key(target) in reachable})
        if building['kind']!='house':
            target=local_point(building,width-cell*1.5,door_y)
            targets.append({'id':building['id'],'kind':'interior_'+building['kind'],'point':target,'reachable':key(target) in reachable})
    for gate in data['gates']:
        x,y,z=gate['position'];angle=math.radians(gate['outward_angle'])
        for sign in [-1,1]:
            target=[x+math.cos(angle)*belt*2*sign,y+math.sin(angle)*belt*2*sign]
            targets.append({'id':gate['id'],'kind':'gate_'+str(sign),'point':target,'reachable':key(target) in reachable})
    audit={'issue':454,'scope':'Static cell-centre routes from Plaza Alsina; opaque house shells end at external portal approaches. Not native collision/AI or siege evidence.',
           'clearance_source':'assets/map02_maze/LAYOUT.json accepted largest player radius/height','height':max_height,'radius':max_radius,
           'walkable':len(walkable),'reachable':len(reachable),'targets':targets,'failures':[t for t in targets if not t['reachable']]}
    (out/'routes.json').write_text(json.dumps(audit,indent=2)+'\n',encoding='utf-8')
    with zipfile.ZipFile(out/'preview.pk3','w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
        files={'maps/'+port.name+'.wad':(out/(port.name+'.wad')).read_bytes(),
               'MAPINFO':('map '+port.name+' "Barracas architectural preview" { sky1="CABASKY",0 nointermission }\ndoomednums { '+ '\n'.join(editors)+' }\n').encode(),
               'ZSCRIPT':('version "4.14.2"\n'+'\n'.join(classes)).encode(),
               'MODELDEF':'\n'.join(bindings).encode()}
        files.update({'models/'+v['model']:(out/'models'/v['model']).read_bytes() for v in facades.values()})
        for name,content in sorted(files.items()):
            info=zipfile.ZipInfo(name,(2026,11,12,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;archive.writestr(info,content,compresslevel=9)
    (out/'RESULTS.json').write_text(json.dumps({'issue':454,'scope':__doc__,'buildings':len(data['buildings']),'cells':len(port.cells),'geometry_reduction':port.geometry_reduction,'runtime_enabled':False,'static_route_failures':len(audit['failures'])},indent=2)+'\n')
    print(json.dumps({'route_targets':len(targets),'unreachable':audit['failures']}))
    if audit['failures']:raise SystemExit(1)
    return port,data,facades,classes,bindings,editors,audit


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    generate(args.output)

if __name__=='__main__':main()
