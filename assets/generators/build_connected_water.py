"""Add the #414 installation from the preserved pre-5.8.2 mansion, deterministically.

Standard library only. Existing objects retain their order and fields, except
sector zero's explicit installation metadata. Source geometry is never deleted.
"""
from pathlib import Path
import hashlib
import importlib.util
import json
import math
import struct

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / 'assets/map01_mansion'


def main():
    config = json.loads((DATA/'CONNECTED_WATER.json').read_text(encoding='utf-8'))
    source = DATA/config['baseline']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == config['baseline_sha256']
    spec = importlib.util.spec_from_file_location('mansion_reader', Path(__file__).with_name('repair_map01_mansion.py'))
    reader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reader)
    objects = reader.read_map(source)
    vertices, lines, sides, sectors = (objects[k] for k in ('vertex','linedef','sidedef','sector'))
    original = {kind:len(values) for kind,values in objects.items()}
    floor, rim, ceiling = config['floor'], config['rim_height'], config['ceiling']
    materials, opening, steps = config['materials'], config['opening'], config['steps']
    reserved = config['water_tags']+[config['gate_tag']]+list(range(opening['first_tag'],opening['first_tag']+opening['strips']))+list(range(steps['first_tag'],steps['first_tag']+4))
    assert not any(set(reserved)&reader.tags(row) for row in sectors)
    metadata = sectors[config['ground_sector']]
    lever = config['lever']
    metadata.update(user_ca_connected_water=1,user_ca_water_switch=1,
                    user_ca_water_switch_x=lever[0],user_ca_water_switch_y=lever[1],
                    user_ca_water_switch_z=lever[2],user_ca_water_switch_angle=lever[3])
    vertex_ids, edges, sector_ids = {}, {}, {}

    def vertex(point):
        point = tuple(round(v,9) for v in point)
        if point not in vertex_ids:
            vertex_ids[point] = len(vertices)
            vertices.append(dict(x=point[0],y=point[1]))
        return vertex_ids[point]

    def sector(row):
        identity = json.dumps(row,sort_keys=True)
        if identity not in sector_ids:
            sector_ids[identity] = len(sectors)
            sectors.append(row)
        return sector_ids[identity]

    def rectangle(bounds, owner):
        x0,y0,x1,y1 = bounds
        points=[(x0,y0),(x0,y1),(x1,y1),(x1,y0)]
        for a,b in zip(points,points[1:]+points[:1]):
            key=tuple(sorted((a,b)))
            if key in edges:
                assert 'back' not in edges[key]
                edges[key]['back']=owner
            else:edges[key]=dict(a=a,b=b,front=owner)

    def inside(x,y,bounds):
        return bounds[0]<x<bounds[2] and bounds[1]<y<bounds[3]

    radius=opening['diameter']/2
    hole_x=[round(opening['center_x']-radius+opening['diameter']*i/opening['strips'],9) for i in range(opening['strips']+1)]
    xs={config['walkway'][0],config['walkway'][2],config['rim'][0],config['rim'][2],*steps['x'],*hole_x}
    ys={config['walkway'][1],config['walkway'][3],config['rim'][1],config['rim'][3],*opening['y']}
    for basin in config['basins']:
        xs.update((basin[0],basin[2]));ys.update((basin[1],basin[3]))
        ys.update(basin[1]+offset for offset in steps['y_offsets'])
    xs,ys=sorted(xs),sorted(ys)
    floor_rows=[]
    for x0,x1 in zip(xs,xs[1:]):
        for y0,y1 in zip(ys,ys[1:]):
            x,y=(x0+x1)/2,(y0+y1)/2
            row=dict(heightfloor=rim,heightceiling=ceiling,texturefloor=materials['path'],textureceiling='F_SKY1',lightlevel=184)
            if inside(x,y,config['rim']):row['texturefloor']=materials['rim']
            for index,basin in enumerate(config['basins']):
                if inside(x,y,basin):
                    row.update(heightfloor=floor,texturefloor=materials['basin'],id=config['water_tags'][index])
                    if basin[1]+steps['y_offsets'][0]<y<basin[1]+steps['y_offsets'][1]:
                        for step,(left,right) in enumerate(zip(steps['x'],steps['x'][1:])):
                            if left<x<right:row['moreids']=str(steps['first_tag']+step)
            if opening['y'][0]<y<opening['y'][1] and hole_x[0]<x<hole_x[-1]:
                strip=next(i for i,(left,right) in enumerate(zip(hole_x,hole_x[1:])) if left<x<right)
                half=math.sqrt(max(0,radius*radius-(x-opening['center_x'])**2))
                bottom,top=floor+radius-half,floor+radius+half
                row.update(heightfloor=round(bottom,9),texturefloor=materials['basin'],id=opening['first_tag']+strip,moreids=str(config['gate_tag']))
                floor_rows.append((opening['first_tag']+strip,round(top,9),rim))
            rectangle((x0,y0,x1,y1),sector(row))
    # Preserve the host sector around this inset. Internal edges of a shared
    # sector are unnecessary; removing them here only affects generated edges.
    for edge in edges.values():
        front,back=edge['front'],edge.get('back',config['ground_sector'])
        if front==back:continue
        first=len(sides)
        for owner in (front,back):
            sides.append(dict(sector=owner,texturemiddle='-',texturetop=materials['rim'],texturebottom=materials['basin']))
        lines.append(dict(v1=vertex(edge['a']),v2=vertex(edge['b']),sidefront=first,sideback=first+1,twosided=True))
    control_rows=[]
    for i,tag in enumerate(config['water_tags']):
        control_rows.append((tag,floor,config['water_initial_heights'][i],2,materials['water'],dict(user_ca_connected_water_id=i+1,user_ca_potable_water=1)))
    control_rows.append((config['gate_tag'],floor,floor+opening['diameter'],1,materials['gate'],dict(user_ca_connected_water_gate=1)))
    control_rows.extend((tag,lo,hi,1,materials['rim'],{}) for tag,lo,hi in sorted(set(floor_rows)))
    control_rows.extend((steps['first_tag']+i,top-steps['thickness'],top,1,materials['rim'],{}) for i,top in enumerate(steps['tops']))
    control_indices=[]
    for i,(tag,lo,hi,kind,texture,extra) in enumerate(control_rows):
        x=config['controls']['origin'][0]+i*config['controls']['spacing'];y=config['controls']['origin'][1];size=config['controls']['size']
        assert y>30000  # Existing playable horizon; never create controls inside it.
        owner=sector(dict(heightfloor=lo,heightceiling=hi,texturefloor=texture,textureceiling=texture,lightlevel=176,**extra))
        control_indices.append(owner)
        points=[(x,y),(x,y+size),(x+size,y+size),(x+size,y)]
        for j,(a,b) in enumerate(zip(points,points[1:]+points[:1])):
            side=len(sides);sides.append(dict(sector=owner,texturemiddle=texture))
            line=dict(v1=vertex(a),v2=vertex(b),sidefront=side,blocking=True)
            if j==0:line.update(special=160,arg0=tag,arg1=kind,arg2=0,arg3=128 if kind==2 else 255)
            lines.append(line)
    # Keep all pre-existing things and geometry unchanged. The optional native
    # engine nodes are regenerated by GZDoom for this new geometry.
    chunks=['namespace="ZDoom";','// #414 installation from assets/map01_mansion/CONNECTED_WATER.json.']
    for kind,rows in objects.items():
        chunks.extend(kind+' { '+' '.join(k+'='+json.dumps(v,ensure_ascii=False)+';' for k,v in row.items())+' }' for row in rows)
    text=('\n'.join(chunks)+'\n').encode('utf-8')
    payload=bytearray();directory=bytearray()
    for name,data in [('MAP01',b''),('TEXTMAP',text),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(payload),len(data),name.encode().ljust(8,b'\0'));payload+=data
    blob=struct.pack('<4sii',b'PWAD',3,12+len(payload))+payload+directory
    (ROOT/'src/maps/MAP01.wad').write_bytes(blob)
    report={'issue':414,'baseline_sha256':config['baseline_sha256'],'output_sha256':hashlib.sha256(blob).hexdigest(),
            'original_counts':original,'output_counts':{k:len(v) for k,v in objects.items()},'controls':control_indices,
            'basin_area_m2':[16,16],'nominal_capacity_liters':[32000,32000],
            'opening_geometry':'12-strip native approximation of the approved circular opening; flow uses the circular area',
            'existing_pool':'All original sector/linedef/vertex/thing values preserved, except installation metadata added to sector zero.'}
    (DATA/'connected_water_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()
