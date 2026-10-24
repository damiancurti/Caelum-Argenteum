"""Recalculate only relocated residents' routes from the existing authored city geometry."""
from pathlib import Path
import json,re
import generate_coastal_trials as coastal
import generate_map06_port as port_source
import generate_city_interiors as interiors
ROOT=Path(__file__).resolve().parents[2]
def main():
    data=(ROOT/'src/caelum/data/CaelumPropertyData.zs').read_text(encoding='utf-8')
    source=int(re.search(r'CENTRAL_HOUSE=(\d+)',data)[1])
    target=int(re.search(r'RELOCATION_HOUSE=(\d+)',data)[1])
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8'))
    count=len(interiors.houses(city));ids=list(range(source,port_source.S['defenders'],count))
    captured=[]
    original_runtime=interiors.runtime;original_write=coastal.CoastalMap.write
    try:
        interiors.runtime=lambda *args,**kwargs:None
        coastal.CoastalMap.write=lambda self,folder:captured.append(self)
        coastal.generate(ROOT/'build/issue411',port_extension=port_source.extend,include_coast=False)
    finally:
        interiors.runtime=original_runtime;coastal.CoastalMap.write=original_write
    routes=interiors.deployment_routes(captured[0],city,port_source.S,{source:target},ids)
    lines=['// Rutas derivadas de la geometria existente; conserva los destinos de cada defensor.',
           'class CaelumPropertyRoutes : Object play','{',
           '    static int Count(int identity){switch(identity){']
    lines += [f'        case {i}:return {len(r)};' for i,r in zip(ids,routes)]
    lines += ['        }return CaelumCityRoutes.Count(identity);}',
              '    static vector3 Point(int identity,int step){switch(identity){']
    lines += [f'        case {i}:return Route{i}(step);' for i in ids]
    lines += ['        }return CaelumCityRoutes.Point(identity,step);}']
    for i,route in zip(ids,routes):
        lines += [f'    static vector3 Route{i}(int step){{switch(step){{']
        lines += [f'        case {n}:return ({",".join(map(str,point))});' for n,point in enumerate(route)]
        lines += ['        }return (0,0,0);}']
    lines += ['}']
    output=ROOT/'src/caelum/data/CaelumPropertyRoutes.zs'
    output.write_bytes(('\n'.join(lines)+'\n').encode('utf-8'))
    print(f'{len(ids)} relocated routes, {sum(map(len,routes))} waypoints; no map files changed')
if __name__=='__main__':main()
