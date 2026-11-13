"""Generate revision4 exterior coordinates without moving private CAH interiors.

The existing HouseOrigin remains the private-map coordinate source even when a
travelling household calculates its destination from MAP03. Only exterior doors,
public approaches, shops and footprint classification use these new coordinates.
"""
from pathlib import Path
import argparse
import hashlib
import json
from generate_barracas_preview import local_point

ROOT=Path(__file__).resolve().parents[2]
INPUTS=['assets/barracas_redesign/LAYOUT.json','assets/map06_port/CITY.json',
        'assets/map06_port/INTERIORS.json','assets/map06_port/HOUSE_HUBS.json',
        'assets/map06_port/NATIVE_DOORS.json','assets/map06_port/LAYOUT.json']


def vector(values):return '('+','.join(f'{v:g}' for v in values)+')'


def coordinate_method(name,rows,key):
    code=f'    static vector3 {name}(int i){{switch(i){{\n'
    code+=''.join(f'        case {i}:return {vector(row[key])};\n' for i,row in enumerate(rows))
    return code+'        }return (0,0,0);}\n'


def outputs():
    data,city,interior,hubs,doors,port=[json.loads((ROOT/name).read_text(encoding='utf-8')) for name in INPUTS]
    houses=sorted((b for b in data['buildings'] if b['kind']=='house'),key=lambda b:b['house_index'])
    assert [b['house_index'] for b in houses]==list(range(160))
    by_id={b['id']:b for b in data['buildings']}
    width=interior['house_size'][0];door_y=sum(interior['entrance'][i] for i in (1,3))/2
    rows=[]
    for building in houses:
        outside=[*local_point(building,*interior['door_outside'][:2]),interior['door_outside'][2]]
        rows.append({'identity':building['house_index'],'building_id':building['id'],'bounds':building['bounds'],
                     'portal':[ *local_point(building,width+doors['half_thickness'],door_y),0],
                     'door_outside':outside,'public_approach':outside,'angle':building['angle'],
                     'start_index':hubs['start_index_base']+building['house_index']})
    shops=[]
    for old in city['buildings']:
        if old['kind']!='shop':continue
        building=by_id[old['id']]
        shops.append({'identity':len(shops),'building_id':building['id'],
                      'vendor':[ *local_point(building,*interior['vendor_offset']),0],
                      'angle':building['angle']})
    result={'schema_revision':1,'issue':454,'geometry_revision':data['geometry_revision'],
            'status':'Generated exterior coordinates; production activation requires the completed revision4 map and native verification.',
            'private_interior_contract':'HouseOrigin/Table/Bed/Chest/DoorInside/HomePosition retain original CAH coordinates, including calls made from MAP03.',
            'public_approach_contract':'Use the already audited exterior doorstep as the deployment route origin; the legacy1280-MU local offset can land in a neighboring rotated lot.',
            'source_sha256':{name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in INPUTS},
            'houses':rows,'shops':shops,'port_transform':data['port_transform'],
            'services':{key:port[key] for key in ('resource_bed','resource_workbench','completion_position')}}
    code='// Generado desde assets/barracas_redesign y perfiles conservados del puerto.\nclass CaelumBarracasData : Object play\n{\n'
    code+=f'    const GEOMETRY_REVISION={data["geometry_revision"]};\n'
    code+='    static bool IsCurrent(){let port=CaelumPortSiege.Get();return level.MapName=="MAP03" && port!=null && port.args[0]>=GEOMETRY_REVISION;}\n'
    for name,key in [('PortalPosition','portal'),('DoorOutside','door_outside'),('HouseRoad','public_approach')]:
        code+=coordinate_method(name,rows,key)
    code+=coordinate_method('ShopPosition',shops,'vendor')
    code+='    static double HouseAngle(int i){switch(i){\n'+''.join(f'        case {i}:return {row["angle"]};\n' for i,row in enumerate(rows))+'        }return 0;}\n'
    code+='    static double ShopAngle(int i){switch(i){\n'+''.join(f'        case {i}:return {row["angle"]};\n' for i,row in enumerate(shops))+'        }return 0;}\n'
    code+='    static vector2 HouseMinimum(int i){switch(i){\n'+''.join(f'        case {i}:return {vector(row["bounds"][:2])};\n' for i,row in enumerate(rows))+'        }return (0,0);}\n'
    code+='    static vector2 HouseMaximum(int i){switch(i){\n'+''.join(f'        case {i}:return {vector(row["bounds"][2:])};\n' for i,row in enumerate(rows))+'        }return (0,0);}\n'
    code+='    static int HouseAt(vector3 point){if(Abs(point.Z)>16)return -1;for(int i=0;i<CaelumCityData.HOUSE_COUNT;i++){vector2 a=HouseMinimum(i),b=HouseMaximum(i);if(point.X>=a.X && point.Y>=a.Y && point.X<b.X && point.Y<b.Y)return i;}return -1;}\n'
    turns=data['port_transform']['quarter_turns']%4;x,y=data['port_transform']['offset']
    expressions=[('point.X','point.Y'),('-point.Y','point.X'),('-point.X','-point.Y'),('point.Y','-point.X')]
    a,b=expressions[turns];code+=f'    static vector3 PortPoint(vector3 point){{return ({x}+({a}),{y}+({b}),point.Z);}}\n'
    code+='    static vector3 CurrentPortPoint(vector3 point){return IsCurrent()?PortPoint(point):point;}\n'
    code+=f'    static double CurrentPortAngle(double angle){{return IsCurrent()?angle+{turns*90}:angle;}}\n'
    code+='}\n'
    return {'assets/barracas_redesign/RUNTIME.json':(json.dumps(result,ensure_ascii=False,indent=2)+'\n').encode(),
            'src/caelum/world/CaelumBarracasData.zs':code.encode()}


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    for name,data in outputs().items():
        path=ROOT/name
        if args.check:
            if not path.is_file() or path.read_bytes()!=data:raise SystemExit('Stale Barracas runtime data: '+name)
        else:path.write_bytes(data)
    print('Barracas exterior data:160 houses,64 shops; private interior origins retained.')


if __name__=='__main__':main()
