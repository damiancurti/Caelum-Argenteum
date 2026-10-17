"""Append native finite-height door geometry after conservative map compaction.

The original visual leaf remains a non-solid controller/model. Native two-sided
3D midtextures provide finite collision, with invisible faces beneath that model.
No external example assets or authored city coordinates are copied.
"""
from pathlib import Path
import json
import math
import generate_city_interiors as interiors

ROOT=Path(__file__).resolve().parents[2]
DATA=json.loads((ROOT/'assets/map06_port/NATIVE_DOORS.json').read_text())
SHAPE=json.loads((ROOT/'assets/map01_mansion/DOORS.json').read_text())

def specs():
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text())
    result=[]
    for index,house in enumerate(interiors.houses(city)):
        x,y,_,_=house['bounds'];d=interiors.DATA
        a,b,c,e=d['entrance']
        doors=[(d['door_group_base']+house['id'],x+c-d['door_inset'],y+(b+e)//2,1)]
        for door,(a,b,c,e) in enumerate(d['doorways']):
            doors.append((d['constants']['INTERIOR_DOOR_GROUP_BASE']+index*len(d['doorways'])+door,
                          x+(a+c)//2,y+(b+e)//2,0 if c-a>e-b else 1))
        for group,cx,cy,axis in doors:
            for side in (-1,1):
                result.append(dict(group=group,x=cx+(side*d['leaf_half_width'] if axis==0 else 0),
                    y=cy+(side*d['leaf_half_width'] if axis==1 else 0),axis=axis,side=side,id=len(result)+1))
    return result

def token(v):
    return str(v).lower() if isinstance(v,bool) else '"'+v+'"' if isinstance(v,str) else str(v)

def append(groups):
    leaves=specs();vertices=groups['vertex'];sectors=groups['sector'];sides=groups['sidedef'];lines=groups['linedef']
    cell=64 # Existing CoastalMap grid, used only to pack inaccessible storage.
    origin=(max(float(v['x']) for v in vertices)+2*cell,min(float(v['y']) for v in vertices))
    columns=math.ceil(math.sqrt(len(leaves)));rows=math.ceil(len(leaves)/columns)
    def sector():
        sectors.append({k:token(v) for k,v in dict(heightfloor=0,heightceiling=1024,texturefloor='CMST02',textureceiling='F_SKY1',lightlevel=168).items()})
        return len(sectors)-1
    outer,inner=sector(),sector()
    def polygon(points,poly=None):
        vi=len(vertices);vertices.extend(dict(x=token(x),y=token(y)) for x,y in points)
        for i in range(4):
            si=len(sides);sides.append(dict(sector=str(inner if poly else outer),texturemiddle='"CAPODR"' if poly else '"-"'))
            line=dict(v1=vi+i,v2=vi+(i+1)%4,sidefront=si)
            if poly:
                sides.append(dict(sector=str(outer),texturemiddle='"CAPODR"'))
                line.update(sideback=si+1,twosided=True,midtex3d=True,dontpegbottom=True,alpha=0.0,
                    id=DATA['line_id_base']+poly,playeruse=True,playeruseback=True,monsterpush=True,repeatspecial=True)
                if i==0:line.update(special=1,arg0=poly,arg2=DATA['silent_sequence'])
                else:line.update(special=7,arg0=poly)
            else:line['blocking']=True
            lines.append({k:token(v) for k,v in line.items()})
    ox,oy=origin
    polygon([(ox,oy),(ox,oy+(rows+2)*2*cell),(ox+(columns+2)*2*cell,oy+(rows+2)*2*cell),(ox+(columns+2)*2*cell,oy)])
    existing={(int(t.get('arg0','0')),int(t.get('arg1','0'))):t for t in groups['thing'] if t['type']=='18099'}
    def thing(kind,x,y,angle=0,**fields):
        row=dict(type=kind,x=x,y=y,angle=angle,skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True,**fields)
        row={k:token(v) for k,v in row.items()};groups['thing'].append(row);return row
    half=SHAPE['width']/2;thick=DATA['half_thickness']
    for leaf in leaves:
        identity=leaf['id'];axis=leaf['axis'];side=leaf['side']
        x=ox+2*cell+(identity-1)%columns*2*cell;y=oy+2*cell+(identity-1)//columns*2*cell
        offsets=[(-half,-thick),(-half,thick),(half,thick),(half,-thick)]
        polygon([(x+(a if axis==0 else -b),y+(b if axis==0 else a)) for a,b in offsets],identity)
        thing(9300,x+(side*half if axis==0 else 0),y+(side*half if axis==1 else 0),identity)
        thing(9301,leaf['x']+(side*half if axis==0 else 0),leaf['y']+(side*half if axis==1 else 0),identity)
        actor=existing.get((leaf['group'],side))
        if actor is None:actor=thing(18099,leaf['x'],leaf['y'],arg0=leaf['group'],arg1=side,arg2=axis)
        assert float(actor['x'])==leaf['x'] and float(actor['y'])==leaf['y']
        actor['arg4']=str(identity)
    for actor in groups['thing']:
        if actor['type']=='31050':actor['arg4']='1'
    return {'leaves':len(leaves),'storage_origin':origin,'line_id_base':DATA['line_id_base']}

def runtime():
    values={k.upper():v for k,v in DATA.items() if isinstance(v,int) and k not in ('issue','schema_revision')}
    values['LEAF_COUNT']=len(specs())
    text='// Datos nativos de puertas MAP06, derivados sin cambiar sus valores previos.\nclass CaelumNativeDoorData : Object\n{\n'
    text+=''.join(f'    const {key} = {value};\n' for key,value in values.items())+'}\n'
    (ROOT/'src/caelum/world/CaelumNativeDoorData.zs').write_text(text,encoding='utf-8')
    (ROOT/'src/caelum/data/native_doors.textures').write_text(
        f'WallTexture "CAPODR", {SHAPE["width"]}, {SHAPE["height"]} {{ Patch "graphics/caelum/textures/mansion/CMDR03.png",0,0 }}\n',encoding='utf-8')
    (ROOT/'src/SNDSEQ').write_text(
        '// Native motion is silent; the retained leaf plays the owned door sound.\n'
        f':CaelumNativeDoorSilent\ndoor {DATA["silent_sequence"]}\nend\n',encoding='utf-8')

if __name__=='__main__':runtime()
